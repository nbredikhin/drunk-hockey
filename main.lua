DEBUG = require("config.debugconfig")
if not DEBUG then
    DEBUG = {}
end

DEBUG.Log = function (s, ...)
    local info = debug.getinfo(2, "Sl")
    local pre_str = string.format("[%s:%3d]", info.source, info.currentline)
    local str = string.format(s, ...)
    print(pre_str .. " " .. str)
end

local function disableDebug()
    DEBUG = {}
    DEBUG.Log = function () end
end

-- Выключить режим отладки
-- disableDebug()

-- Глобальные настройки игры
GameConfig = require("config.gameconfig")
AIConfig   = require("config.aiconfig")

local composer  = require("composer")
local ads       = require("lib.ads")
local adsconfig = require("config.adsconfig") or {}
local storage   = require("lib.storage")
local analytics = require("plugin.flurry.analytics")

require("lib.lang")
lang.init()
if DEBUG.forceLang then
    lang.setLang(DEBUG.forceLang)
end

require("lib.timers")

Globals = {
    analytics = analytics,
    soundEnabled = storage.get("sound_enabled", true)
}

composer.recycleOnSceneChange = true

system.activate("multitouch")

display.setStatusBar(display.HiddenStatusBar)
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "nearest")

native.setProperty("androidSystemUiVisibility", "immersive")

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
    "touch",
    "system"
}

local runtime = 0
function getDeltaTime()
    local temp = system.getTimer()  -- Get current game time in ms
    local dt = (temp - runtime) / (1000 / 60)  -- 60 fps or 30 fps as base
    runtime = temp  -- Store game time
    return dt
end

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
    storage.set("levels_unlocked", 99)
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
    local state = event.phase
    if event.isError then
        state = event.response
    end

    if event.isError or event.phase == "shown" then
        ads.load(adsconfig.adType, { testMode = adsconfig.testMode, appId = adsconfig.appId })
    end

    Globals.analytics.logEvent("Advertisment", { ad_type = event.type, ad_state = state })
    DEBUG.Log("New state for advertisment (%s): %s", event.type, state)
end)
ads.load(adsconfig.adType, { testMode = adsconfig.testMode, appId = adsconfig.appId })

-- Аналитика
if DEBUG.disableAnalytics or system.getInfo("environment") == "simulator" then
    analytics = {
        init            = function () end,
        logEvent        = function () end,
        startTimedEvent = function () end,
        endTimedEvent   = function () end
    }
    Globals.analytics = analytics
end

local function analyticsListener(event)

end
Globals.analytics.init(analyticsListener, { apiKey = adsconfig.analyticsKey })

-- Load menu
if DEBUG.skipMenu then
    composer.gotoScene("scenes.game", { params = { gamemode = "singleplayer", fourPlayers = DEBUG.forceFourPlayers } })
elseif DEBUG.showAbout then
     composer.gotoScene("scenes.about")
else
    composer.gotoScene("scenes.intro", { effect = "fade", time = 500 })
end
