local composer = require("composer")
local widget   = require("widget")
local ads      = require("lib.ads")
local storage  = require("lib.storage")

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
        { name = "singleplayer", label = lang.getString("menu_button_singleplayer") },
        { name = "multiplayer",  label = lang.getString("menu_button_multiplayer")  }
    }
    local buttonY = display.contentCenterY
    local buttonWidth = display.contentWidth * 0.8
    local buttonHeight = buttonWidth * 0.220703125

    self.selectSound = audio.loadSound("assets/sounds/select.wav")
    self.buttonSound = audio.loadSound("assets/sounds/button.wav")

    self.menuTheme = audio.loadStream("assets/music/menu.ogg")
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

    local levelsUnlocked = storage.get("levels_unlocked", 1)
    if type(levelsUnlocked) ~= "number" then
        levelsUnlocked = 1
    end

    self.difficultyButtons = {
        { difficulty = "easy",   label = lang.getString("menu_button_easy") },
        { difficulty = "medium", label = lang.getString("menu_button_medium") },
        { difficulty = "hard",   label = lang.getString("menu_button_hard") },
    }
    buttonY = display.contentCenterY - 5
    for i, b in ipairs(self.difficultyButtons) do
        local imagePath = "assets/ui/button.png"
        if i > levelsUnlocked then
            imagePath = "assets/ui/button_locked.png"
        end
        local button = widget.newButton({
            x = display.contentCenterX,
            y = buttonY,
            width = buttonWidth,
            height = buttonHeight,

            fontSize = 7,
            label = b.label,
            labelColor = { default = {1, 1, 1} },
            labelYOffset = -0.8,

            isEnabled = i <= levelsUnlocked,

            defaultFile = imagePath,
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

    self.aboutButton = widget.newButton({
        x = display.contentCenterX,--math.floor(buttonHeight / 2) + 2,
        y = display.contentHeight - math.floor(buttonHeight / 2) - 2,
        width = buttonHeight,
        height = buttonHeight,
        fontSize = 10,
        label = "?",
        labelColor = { default = {1, 1, 1} },
        labelYOffset = -0.5,

        defaultFile = "assets/ui/about.png",
        onRelease = function ()
            composer.gotoScene("scenes.about", {time = 500, effect = "slideRight" })
            audio.play(self.buttonSound)
        end
    })
    group:insert(self.aboutButton)
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end
    self.loaded = true
    audio.play(self.menuTheme, { channel = 1, loops = -1 })
    Globals.analytics.startTimedEvent("Main menu")
end

function scene:hide(event)
    if event.phase == "will" then
        Globals.analytics.endTimedEvent("Main menu")
        timer.cancelAll()
    end
end

function scene:startGameWithDifficulty(difficultyName)
    local params = {
        gamemode   = "singleplayer",
        difficulty = difficultyName
    }
    Globals.analytics.logEvent("Menu selection", {
        location="Main Menu",
        selection="Singleplayer " .. tostring(difficultyName)
    })
    composer.gotoScene("scenes.game", {time = 500, effect = "slideLeft", params = params})
    audio.play(self.buttonSound)
    audio.stop(1)
end

function scene:menuButtonPressed(name)
    if name == "singleplayer" then
        transition.to(self.buttons[1].button, { transition=easing.outBack, time = 800, delta = true, y = -20, alpha = -1, xScale = 0.1})
        transition.to(self.buttons[2].button, { transition=easing.outBack, time = 700, delta = true, y = 25.5})

        for i, b in ipairs(self.difficultyButtons) do
            b.button.xScale = 0.1
            b.button.yScale = 0.1
            transition.to(b.button, { transition=easing.outBack, delay = (i - 1) * 200, time = 300, delta = false, xScale = 1, yScale = 1, alpha = 1})
        end
        audio.play(self.selectSound)
    elseif name == "multiplayer" then
        Globals.analytics.logEvent("Menu selection", {
            location="Main Menu",
            selection="Multiplayer"
        })
        composer.gotoScene("scenes.game", {time = 500, effect = "slideLeft", params = { gamemode = "multiplayer" }})
        audio.play(self.buttonSound)
        audio.stop(1)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene