local composer = require("composer")
local widget = require("widget")

local scene = composer.newScene()

function scene:create(event)
    if not event.params then
        event.params = {}
    end
    local group = self.view
    local scene = self

    local background = display.newImage("assets/background.png", display.contentCenterX, display.contentCenterY)
    background.width = display.contentWidth
    background.height = display.contentHeight
    group:insert(background)

    -- Logo
    local logo = display.newImage(group, "assets/ui/logo.png")
    local logoScale = display.contentWidth / logo.width
    logo.width = logo.width * logoScale
    logo.height = logo.height * logoScale
    logo.x = display.contentCenterX
    logo.y = display.contentCenterY / 3

    if event.params.firstTime then
        transition.from(logo, { time = 500, alpha = 0, xScale = 0.1, yScale = 0.1, transition= easing.inOutCubic})
    end

    -- Menu buttons
    local buttons = {
        { name = "singleplayer", label = "Singleplayer" },
        { name = "multiplayer",  label = "Multiplayer"  }
    }
    local buttonY = display.contentCenterY
    local buttonWidth = display.contentWidth * 0.8
    local buttonHeight = buttonWidth * 0.220703125
    for i, b in ipairs(buttons) do
        local button = widget.newButton({
            x = display.contentCenterX, 
            y = buttonY,
            width = buttonWidth,
            height = buttonHeight,

            fontSize = 7,
            label = b.label,
            labelColor = { default = {1, 1, 1} },
            labelYOffset = -0.8,

            defaultFile = "assets/ui/button.png",
            onRelease = function ()
                scene:menuButtonPressed(b.name)
            end
        })
        buttonY = buttonY + buttonHeight + 1
        group:insert(button)

        if event.params.firstTime then
            transition.from(button, { time = 500, alpha = 0, delay = 250 * i, xScale = 0.1, yScale = 0.1, transition = easing.inOutCubic})
        end
    end
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end
    self.loaded = true
end

function scene:menuButtonPressed(name)
    if name == "singleplayer" then
        composer.gotoScene("scenes.game", {time = 500, effect = "slideLeft"})
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene