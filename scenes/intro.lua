local composer = require("composer")

local scene = composer.newScene()

function scene:create(event)
    local group = self.view

    local bg = display.newRect(group, display.contentCenterX, display.contentCenterY,
        display.contentWidth, display.contentHeight)

    local logo = display.newImage(group, "assets/ui/bringdat.png")
    local logoScale = display.contentWidth / logo.width * 0.85
    logo.width = logo.width * logoScale
    logo.height = logo.height * logoScale
    logo.x = display.contentCenterX
    logo.y = display.contentCenterY

    self.logo = logo
    self.logo.alpha = 0
    self.logo.xScale = 0.5
    self.logo.yScale = 0.5

    if DEBUG.skipIntro then
        composer.gotoScene("scenes.menu")
    end
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end
    self.loaded = true

    transition.to(self.logo, {
        transition = easing.outBack,
        delay  = 300,
        time   = 300,
        alpha  = 1,
        xScale = 1,
        yScale = 1
    })
    timer.performWithDelay(GameConfig.introDisplayTime, function ()
        composer.gotoScene("scenes.menu", { effect = "fade", time = 500, params = { firstTime = true }})
    end)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene