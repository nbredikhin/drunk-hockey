local composer = require("composer")

local scene = composer.newScene()

function scene:create(event)
    local group = self.view

    local logo = display.newImage(group, "assets/ui/logo.png")
    local logoScale = display.contentWidth / logo.width
    logo.width = logo.width * logoScale
    logo.height = logo.height * logoScale
    logo.x = display.contentCenterX
    logo.y = display.contentCenterY 
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end
    self.loaded = true

    local delay = 1500
    if DEBUG.skipIntro then
        delay = 0
    end
    timer.performWithDelay(delay, function ()
        composer.gotoScene("scenes.menu", { effect = "fade", time = 500, params = { firstTime = true }})
    end)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene