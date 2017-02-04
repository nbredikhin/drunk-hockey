DEBUG = {
    skipMenu         = false,
    skipIntro        = true,
    drawPhysics      = false,
    disableSounds    = true,
    -- Сброс прогресса игры
    resetProgress    = false,
    -- Открыть всю игру
    unlockEverything = true,
    oneGoalToWin     = true,
    disableAnalytics = false,
    disableAds       = true,

    Log = function (s, ...)
        local str = string.format(s, ...)
        print(str)
    end
}

local composer  = require("composer")
local ads       = require("lib.ads")
local adsconfig = require("adsconfig") or {}
local storage   = require("lib.storage")
local googleAnalytics = require("plugin.googleAnalytics")

Globals = {
    googleAnalytics = googleAnalytics,
    soundEnabled = storage.get("sound_enabled", true),
    adsCounter   = 0,
    adsInterval  = 2 -- Показ рекламы через каждые N игр (1 - каждый раунд, 2 - через раунд и т. д.)
}

composer.recycleOnSceneChange = true

system.activate("multitouch")

display.setStatusBar(display.HiddenStatusBar)
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "nearest")

-- Поддержка кнопки "назад" на Android и WindowsPhone (или backspace на Windows)
local platform = system.getInfo("platform")
if platform == "android" or platform == "winphone" or platform == "win32" or platform == "macos" then
    Runtime:addEventListener("key", function(event)
        if event.phase == "down" and (event.keyName == "back" or event.keyName == "deleteBack") then
            local scene = composer.getScene(composer.getSceneName("current"))
            if scene and scene.loaded then
                if type(scene.gotoPreviousScene) == "function" then
                    scene:gotoPreviousScene()
                    return true
                elseif type(scene.gotoPreviousScene) == "string" then
                    composer.gotoScene(scene.gotoPreviousScene, {time = 500, effect = "slideRight"})
                    return true
                end
            end
        end
    end)
end

-- Automatically call event handlers on current scene
local passEvents = {
    "enterFrame",
    "touch"
}

for i, eventName in ipairs(passEvents) do
    Runtime:addEventListener(eventName, function (event)
        local scene = composer.getScene(composer.getSceneName("current"))
        if scene then
            if type(scene[eventName]) == "function" then
                scene[eventName](scene, event)
            end
        end
    end)
end

-- Обработка ошибок
Runtime:addEventListener("unhandledError", function (event)
    return true
end)

-- Сброс прогресса
if DEBUG.resetProgress then
    storage.clear()
end

if DEBUG.unlockEverything then
    storage.set("levels_unlocked", 4)
end
if DEBUG.disableSounds then
    storage.set("sounds_enabled", false)
    Globals.soundEnabled = false
end

local _audio_play = audio.play
function audio.play(...)
    if not Globals.soundEnabled then
        return
    end
    _audio_play(...)
end

-- Реклама
ads.init(adsconfig.provider, adsconfig.appId, function (event)
    if event.isError or event.phase == "shown" then
        ads.load(adsconfig.adType, { testMode = adsconfig.testMode })
    end
end)
ads.load(adsconfig.adType, { testMode = adsconfig.testMode })

-- Аналитика
if DEBUG.disableAnalytics then
    googleAnalytics = {
        init = function () end,
        logScreenName = function () end,
        logEvent = function () end
    }
    Globals.googleAnalytics = googleAnalytics
end
googleAnalytics.init("Drunk Hockey", "UA-91387170-1")

-- Load menu
if DEBUG.skipMenu then
    composer.gotoScene("scenes.game", { params = { gamemode = "singleplayer" } })
else
    composer.gotoScene("scenes.intro", { effect = "fade", time = 1000 })
end
