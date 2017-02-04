local widget    = require("widget")
local composer  = require("composer")
local adsconfig = require("adsconfig")
local ads       = require("lib.ads")

local function show(self, winner, score)
    if self.isVisible then
        return
    end
    if not score then
        score = {0, 0}
    end
    self.isVisible = true

    self.winner = winner

    if winner == "blue" then
        if self.isMultiplayer then
            self.winnerText.text = "Blue player won!"
            self.winnerText:setFillColor(0.15, 0.4, 1)
        else
            self.winnerText.text = "You loose!"
        end
    else
        if self.isMultiplayer then
            self.winnerText.text = "Red player won!"
            self.winnerText:setFillColor(1, 0.1, 0.1)
        else
            self.winnerText.text = "You win!"
            self.button:setLabel("Tap to continue")
        end
    end
    self.scoreText.text = "Score is " .. score[1] .. ":" .. score[2]

    if self.bg then
        self.bg.alpha = 1
        self.bg.xScale = 1
        self.bg.yScale = 1

        transition.from(self.bg, { time = 300, alpha = 0 })
    end

    self.winnerText.alpha = 1
    self.winnerText.xScale = 1
    self.winnerText.yScale = 1

    self.scoreText.alpha = 1
    self.scoreText.xScale = 1
    self.scoreText.yScale = 1

    self.button.alpha = 1
    self.button.xScale = 1
    self.button.yScale = 1

    transition.from(self.winnerText, { transition=easing.outBack, delay = 500, time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.scoreText, { transition=easing.outBack, delay = 1000, time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.button, { transition=easing.outBack, delay = 1500, time = 500, alpha = 0, xScale = 0.3, yScale = 0.8 })
end

local function hide(self)
    if not self.isVisible then
        return
    end
    local state = { time = 300, alpha = 0 }
    if self.bg then
        transition.to(self.bg, state)
    end
    transition.to(self.winnerText, state)
    transition.to(self.scoreText, state)
    transition.to(self.button, { time = state.time, alpha = state.alpha, onComplete = function ()
        self.isVisible = false
    end})
end

local function constructor(isMultiplayer, bg)
    self = display.newGroup()
    self.isMultiplayer = isMultiplayer

    self.bg = bg

    self.winnerText = display.newText("Player won!", 0, 0, native.systemFont, 10)
    self.winnerText:setFillColor(0.15, 0.4, 1)
    self:insert(self.winnerText)

    self.scoreText = display.newText("Score is 5:5", 0, 10, native.systemFont, 7)
    self.scoreText:setFillColor(0.15, 0.4, 1)
    self:insert(self.scoreText)

    self.button = widget.newButton({
        x = 0,
        y = 25,
        width = display.contentWidth,
        height = display.contentHeight,

        fontSize = 5,
        label = "Tap to play again",
        labelColor = { default = {1, 1, 1} },

        defaultFile = "assets/empty.png",

        onRelease = function ()
            Globals.adsCounter = Globals.adsCounter + 1
            DEBUG.Log("Ads counter: %i", Globals.adsCounter)
            if Globals.adsCounter >= Globals.adsInterval then
                Globals.adsCounter = 0
                if ads.isLoaded(adsconfig.adType) then
                    DEBUG.Log("Show ad")
                    ads.show(adsconfig.adType, { testMode = adsconfig.testMode })
                else
                    DEBUG.Log("Can't show ad. Ad is not loaded yet")
                end
            end

            if not self.isMultiplayer and self.winner == "red" then
                composer.gotoScene("scenes.menu", {time = 500, effect = "slideRight"})
                return
            end
            local scene = composer.getScene(composer.getSceneName("current"))
            if scene and scene.shake then
                scene:restartGame()
            end
        end
    })
    self:insert(self.button)


    self.isVisible = false

    self.show = show
    self.hide = hide
    return self
end

return constructor