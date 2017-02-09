DEBUG = {
    skipMenu         = false,
    skipIntro        = true,
    skipCountdown    = false,
    showAbout        = false,
    drawPhysics      = false,
    disableSounds    = true,
    -- Вызов функций с клавиатуры
    enableShortcuts  = true,
    -- Сброс прогресса игры
    resetProgress    = false,
    -- Открыть всю игру
    unlockEverything = true,
    oneGoalToWin     = false,
    disableAnalytics = false,
    disableAds       = false,
    forceFourPlayers = false,
    -- forceLang        = "english",

    Log = function (s, ...)
        local info = debug.getinfo(2, "Sl")
        local pre_str = string.format("[%s]:%3d", info.source, info.currentline)
        local str = string.format(s, ...)
        print(pre_str .. " " .. str)
    end
}

local function disableDebug()
    DEBUG = {}
    DEBUG.Log = function () end
end

-- Выключить режим отладки
-- disableDebug()

local composer  = require("composer")
local ads       = require("lib.ads")
local adsconfig = require("adsconfig") or {}
local storage   = require("lib.storage")
local analytics = require("plugin.flurry.analytics")

require("lib.lang")
lang.init()
if DEBUG.forceLang then
    lang.setLang(DEBUG.forceLang)
end

Globals = {
    analytics = analytics,
    soundEnabled = storage.get("sound_enabled", true)
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

-- Свои таймеры

local activeTimersList = {}
local _performWithDelay = timer.performWithDelay

timer.performWithDelay = function (delay, ...)
    local t
    if type(delay) == "boolean" and delay then
        _performWithDelay(...)
        return
    else
        t = _performWithDelay(delay, ...)
    end
    table.insert(activeTimersList, t)
    DEBUG.Log("timer: New timer with delay %s", tostring(delay))
    return t
end

timer.cancelAll = function ()
    for i, t in ipairs(activeTimersList) do
        timer.cancel(t)
    end
    activeTimersList = {}
    DEBUG.Log("timer: Cancel all timers")
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
    if event.isError or event.phase == "shown" then
        ads.load(adsconfig.adType, { testMode = adsconfig.testMode })
    end
end)
ads.load(adsconfig.adType, { testMode = adsconfig.testMode })

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
