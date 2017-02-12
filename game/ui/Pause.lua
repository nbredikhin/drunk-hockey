local widget    = require("widget")
local composer  = require("composer")
local ads       = require("lib.ads")
local adsconfig = require("config.adsconfig") or {}

local function show(self)
    self.isVisible = true

    self.background.alpha = 0
    transition.to(self.background, {
        time = 100,
        alpha = 1,
    })

    ads.show(adsconfig.bannerType, { testMode = adsconfig.testMode, appId = adsconfig.bannerId })
end

local function hide(self)
    self.isVisible = false

    ads.hide()
end

local function constructor()
    local self = display.newGroup()
    self.isVisible = false
    -- Тёмный фон
    self.background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    self.background:setFillColor(0, 0, 0, 0.9)
    self.background.alpha = 0
    self:insert(self.background)

    self.pauseText = display.newText(lang.getString("pause_title"), 0, -19, "pixel_font.ttf", 10)
    self.pauseText:setFillColor(0.15, 0.4, 1)
    self:insert(self.pauseText)

    self.continueButton = widget.newButton({
        x = 0,
        y = 0,
        width = display.contentWidth,
        height = 16,

        font = "pixel_font.ttf",
        fontSize = 5,
        label = lang.getString("pause_continue"),
        labelColor = { default = {1, 1, 1} },

        defaultFile = "assets/empty.png",

        onRelease = function ()
            local scene = composer.getScene(composer.getSceneName("current"))
            if scene and scene.gotoPreviousScene then
                scene:gotoPreviousScene()
            end
        end
    })
    self:insert(self.continueButton)

    self.menuButton = widget.newButton({
        x = 0,
        y = 16,
        width = display.contentWidth,
        height = 16,

        font = "pixel_font.ttf",
        fontSize = 5,
        label = lang.getString("pause_back_to_menu"),
        labelColor = { default = {1, 1, 1} },

        defaultFile = "assets/empty.png",

        onRelease = function ()
            composer.gotoScene("scenes.menu", {time = 500, effect = "slideRight" })
        end
    })
    self:insert(self.menuButton)

    self.show = show
    self.hide = hide
    return self
end
return constructor
