DEBUG = {
    skipMenu = true,
    skipIntro = true,
    drawPhysics = false,
    -- Сброс прогресса игры
    resetProgress = false,
    -- Открыть всю игру
    unlockEverything = true,

    Log = function (s, ...)
        local str = string.format(s, ...)
        print(str)
    end
}

local composer  = require("composer")
local ads       = require("lib.ads")
local adsconfig = require("adsconfig") or {}
local storage   = require("lib.storage")

composer.recycleOnSceneChange = true

display.setStatusBar(display.HiddenStatusBar)
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "nearest")

-- Поддержка кнопки "назад" на Android и WindowsPhone (или backspace на Windows)
local platform = system.getInfo("platform")
if platform == "android" or platform == "winphone" or platform == "win32" then
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

-- Сброс прогресса
if DEBUG.resetProgress then
    storage.clear()
end

if DEBUG.unlockEverything then
    storage.set("levels_unlocked", 4)
end

-- Setup ads
ads.init(adsconfig.provider, adsconfig.appId)
ads.load(adsconfig.adType, { testMode = adsconfig.testMode })
-- if ads.isLoaded() then
--     ads.show(adsconfig.adType, { testMode = adsconfig.testMode })
-- end

-- Load menu
if DEBUG.skipMenu then
    composer.gotoScene("scenes.game", { params = { gamemode = "singleplayer" } })
else
    composer.gotoScene("scenes.intro", { effect = "fade", time = 1000 })
end
