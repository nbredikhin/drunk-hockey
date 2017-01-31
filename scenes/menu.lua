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
        transition.from(logo, { delay = 800, time = 500, alpha = 0, xScale = 0.1, yScale = 0.1, transition= easing.inOutCubic})
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
            transition.from(button, { time = 500, alpha = 0, delay = 250 * i + 800, xScale = 0.1, yScale = 0.1, transition = easing.inOutCubic})
        end

        buttons[i].button = button
    end
    self.buttons = buttons

    self.difficultyButtons = {
        { difficulty = "easy", label = "Easy" },
        { difficulty = "easy", label = "Normal" },
        { difficulty = "easy", label = "Hard" },
    }
    buttonY = display.contentCenterY
    for i, b in ipairs(self.difficultyButtons) do
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
                scene:startGameWithDifficulty(b.difficulty)
            end
        })
        buttonY = buttonY + buttonHeight + 1
        group:insert(button)
        button.alpha = 0

        if event.params.firstTime then
            transition.from(button, { time = 500, alpha = 0, delay = 250 * i + 800, xScale = 0.1, yScale = 0.1, transition = easing.inOutCubic})
        end

        self.difficultyButtons[i].button = button
    end    
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end
    self.loaded = true
end

function scene:startGameWithDifficulty(difficulty)
    local params = {
        gamemode   = "singleplayer",
        difficulty = difficulty
    }
    composer.gotoScene("scenes.game", {time = 500, effect = "slideLeft", params = params})
end

function scene:menuButtonPressed(name)
    if name == "singleplayer" then
        -- composer.gotoScene("scenes.game", {time = 500, effect = "slideLeft", params = { gamemode = "singleplayer" }})
        transition.to(self.buttons[1].button, { transition=easing.outBack, time = 800, delta = true, y = -20, alpha = -1, xScale = 0.1})
        transition.to(self.buttons[2].button, { transition=easing.outBack, time = 700, delta = true, y = 30.5})

        for i, b in ipairs(self.difficultyButtons) do
            b.button.xScale = 0.1
            b.button.yScale = 0.1
            transition.to(b.button, { transition=easing.outBack, delay = (i - 1) * 200, time = 300, delta = false, xScale = 1, yScale = 1, alpha = 1})
        end
    elseif name == "multiplayer" then
        composer.gotoScene("scenes.game", {time = 500, effect = "slideLeft", params = { gamemode = "multiplayer" }})
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene