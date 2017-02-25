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
    self.showGameText = function() end
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
    -- Текстура кнопки
    local buttonImagePath = "assets/ui/button.png"
    local buttonImageLockedPath = "assets/ui/button_locked.png"

    local buttonImage = display.newImage(buttonImagePath)
    local buttonImageRatio = buttonImage.width / buttonImage.height
    buttonImage:removeSelf()
    -- Кнопка занимает 80% ширины экрана
    local buttonWidth = display.contentWidth * 0.8
    local buttonHeight = buttonWidth / buttonImageRatio

    for i, b in ipairs(buttons) do
        local button = widget.newButton({
            x = display.contentCenterX,
            y = buttonY,
            width = buttonWidth,
            height = buttonHeight,

            font = "pixel_font.ttf",
            fontSize = 7,
            label = b.label,
            labelColor = { default = {1, 1, 1} },
            labelYOffset = -0.8,

            defaultFile = buttonImagePath,
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

    -- Кнопки выбора сложности
    self.difficultyButtons = {
        { difficulty = "easy",   label = lang.getString("menu_button_easy")   },
        { difficulty = "medium", label = lang.getString("menu_button_medium") },
        { difficulty = "hard",   label = lang.getString("menu_button_hard")   },
        { difficulty = "medium", label = lang.getString("menu_button_2vs2"), fourPlayers = true },
        { difficulty = "medium", label = "MLG", isMLG = true },
    }
    -- Количество разблокированных уровней сложности
    local levelsUnlocked = storage.get("levels_unlocked", 1)
    if type(levelsUnlocked) ~= "number" then
        levelsUnlocked = 1
    end
    self.isMLGUnlocked = levelsUnlocked >= 5
    buttonY = display.contentCenterY - 5 - buttonHeight - 1
    for i, b in ipairs(self.difficultyButtons) do
        local imagePath = buttonImagePath
        if i > levelsUnlocked or i == 5 then
            imagePath = buttonImageLockedPath
        end
        local button = widget.newButton({
            x = display.contentCenterX,
            y = buttonY,
            width = buttonWidth * 0.8,
            height = buttonHeight,

            font = "pixel_font.ttf",
            fontSize = 7,
            label = b.label,
            labelColor = { default = {1, 1, 1} },
            labelYOffset = -0.8,

            isEnabled = i <= levelsUnlocked,

            defaultFile = imagePath,
            onRelease = function ()
                scene:startGameWithDifficulty(b.difficulty, b.fourPlayers, b.isMLG)
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
        x = display.contentCenterX,
        y = display.contentHeight - math.floor(buttonHeight / 2) - 2,
        width = buttonHeight,
        height = buttonHeight,
        fontSize = 8,
        font = "pixel_font.ttf",
        label = "?",
        labelColor = { default = {1, 1, 1} },
        labelYOffset = 0,
        labelXOffset = 0.3,
        font = "pixel_font.ttf",

        defaultFile = "assets/ui/about.png",
        onRelease = function ()
            composer.gotoScene("scenes.about", {time = 500, effect = "slideRight" })
            audio.play(self.buttonSound)
        end
    })
    group:insert(self.aboutButton)

    if event.params.firstTime then
        transition.from(self.aboutButton, { time = 500, alpha = 0, delay = 800 + 800, xScale = 0.1, yScale = 0.1, transition = easing.inOutCubic})
    end

    -- Звуки и музыка
    self.selectSound = audio.loadSound("assets/sounds/select.wav")
    self.buttonSound = audio.loadSound("assets/sounds/button.wav")
    self.menuTheme   = audio.loadStream("assets/music/menu.mp3")
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end

    ads.hide()

    self.loaded = true
    audio.play(self.menuTheme, { channel = 1, loops = -1 })
    Globals.analytics.startTimedEvent("Main menu")
end

function scene:hide(event)
    if event.phase == "will" then
        Globals.analytics.endTimedEvent("Main menu")
        timer.cancelAll()
    end

    ads.hide()
end

function scene:startGameWithDifficulty(difficultyName, fourPlayers, isMLG)
    Globals.analytics.logEvent("Menu selection", {
        location  = "Main Menu",
        selection = "Singleplayer " .. tostring(difficultyName)
    })

    local params = {
        gamemode    = "singleplayer",
        difficulty  = difficultyName,
        fourPlayers = fourPlayers,
        isMLG       = isMLG
    }
    composer.gotoScene("scenes.game", {time = 500, effect = "slideLeft", params = params})
    audio.play(self.buttonSound)
    audio.stop(1)
end

function scene:menuButtonPressed(name)
    if name == "singleplayer" then
        transition.to(self.buttons[1].button, { transition=easing.outBack, time = 800, delta = true, y = -20, alpha = -1, xScale = 0.1})
        transition.to(self.buttons[2].button, { transition=easing.outBack, time = 700, delta = true, y = 25.5, alpha = -1})

        for i, b in ipairs(self.difficultyButtons) do
            b.button.xScale = 0.1
            b.button.yScale = 0.1
            transition.to(b.button, { transition=easing.outBack, delay = (i - 1) * 200, time = 300, delta = false, xScale = 1, yScale = 1, alpha = 1})
        end
        transition.to(self.aboutButton, { time = 800, delay = 0, transition = easing.outBack, delta = true, y = self.aboutButton.height + 5})
        audio.play(self.selectSound)

        if self.isMLGUnlocked then
            timer.performWithDelay(1000, function ()
                transition.to(self.difficultyButtons[5].button, {
                    time = 600,
                    xScale = 1.05,
                    yScale = 1.05,
                    iterations = 999,
                    transition=easing.continuousLoop
                })
            end)
        end
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

function hsvToRgb(h, s, v, a)
    if not a then
        a = 1
    end
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return r, g, b, a
end

function scene:enterFrame()
    if self.isMLGUnlocked  then
        local progress = (system.getTimer() * 0.08 % 100) / 100
        local r, g, b = hsvToRgb(progress, 1, 1)
        self.difficultyButtons[5].button:setFillColor(r, g, b)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene