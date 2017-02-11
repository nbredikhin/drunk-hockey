local widget    = require("widget")
local composer  = require("composer")
local adsconfig = require("config.adsconfig")
local ads       = require("lib.ads")

local function show(self, winner, score, shotsOnGoal, savesCount)
    if self.isVisible then
        return
    end
    if not score then
        score = {0, 0}
    end
    self.isVisible = true

    self.winner = winner

    if winner == self.colorName then
        self.winnerText.text = lang.getString("game_you_win")
    else
        self.winnerText.text = lang.getString("game_you_lose")
    end
    if winner == "blue" then
        self.winnerText:setFillColor(0.15, 0.4, 1)
    else
        self.winnerText:setFillColor(1, 0.1, 0.1)
    end

    self.infoText.text = lang.getString("game_end_shots_on_goal") .. ": " .. tostring(shotsOnGoal)
        .. "\n\n" .. lang.getString("game_end_saves") .. ": " .. tostring(savesCount)

    self.scoreText.text = lang.getString("game_end_score")  .. " " .. score[1] .. ":" .. score[2]

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

    self.infoText.alpha = 1
    self.infoText.xScale = 1
    self.infoText.yScale = 1

    self.continueButton.alpha = 1
    self.continueButton.xScale = 1
    self.continueButton.yScale = 1

    self.backButton.alpha = 1
    self.backButton.xScale = 1
    self.backButton.yScale = 1

    transition.from(self.winnerText,     { transition = easing.outBack, delay = 500,  time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.scoreText,      { transition = easing.outBack, delay = 1000, time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.infoText,       { transition = easing.outBack, delay = 1500, time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.continueButton, { transition = easing.outBack, delay = 2000, time = 500, alpha = 0, xScale = 0.3, yScale = 0.8 })
    transition.from(self.backButton,     { transition = easing.outBack, delay = 2500, time = 500, alpha = 0, xScale = 0.3, yScale = 0.8 })
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
    transition.to(self.continueButton, state)
    transition.to(self.backButton, { time = state.time, alpha = state.alpha, onComplete = function ()
        self.isVisible = false
    end})

end

local function constructor(isMultiplayer, bg, colorName)
    self = display.newGroup()
    self.isMultiplayer = isMultiplayer

    self.colorName = colorName
    self.bg = bg

    self.winnerText = display.newText("", 0, 0, "pixel_font.ttf", 10)
    self.winnerText:setFillColor(0.15, 0.4, 1)
    self:insert(self.winnerText)

    self.scoreText = display.newText("", 0, 10, "pixel_font.ttf", 7)
    self.scoreText:setFillColor(0.15, 0.4, 1)
    self:insert(self.scoreText)

    self.infoText = display.newText({
        text = "Some text 1: 99\nSome text 2: 99",
        x    = 0,
        y    = 22,
        font = "pixel_font.ttf",
        fontSize = 4,
        align = "center"
    })
    self.infoText:setFillColor(0.15, 0.4, 1)
    self:insert(self.infoText)

    self.continueButton = widget.newButton({
        x = 0,
        y = 35,
        width = display.contentWidth,
        height = 10,

        font = "pixel_font.ttf",
        fontSize = 5,
        label = lang.getString("game_restart_button"),
        labelColor = { default = {1, 1, 1} },

        defaultFile = "assets/empty.png",

        onRelease = function ()
            if ads.isLoaded(adsconfig.adType) then
                ads.show(adsconfig.adType, { testMode = adsconfig.testMode })
            end
            local scene = composer.getScene(composer.getSceneName("current"))
            if scene and scene.shake then
                scene:restartGame()
            end
        end
    })
    self:insert(self.continueButton)

    self.backButton = widget.newButton({
        x = 0,
        y = 45,
        width = display.contentWidth,
        height = 10,

        font = "pixel_font.ttf",
        fontSize = 5,
        label = lang.getString("game_end_button"),
        labelColor = { default = {1, 1, 1} },

        defaultFile = "assets/empty.png",

        onRelease = function ()
            if ads.isLoaded(adsconfig.adType) then
                ads.show(adsconfig.adType, { testMode = adsconfig.testMode })
            end
            composer.gotoScene("scenes.menu", {time = 500, effect = "slideRight"})
        end
    })
    self:insert(self.backButton)

    self.isVisible = false

    self.show = show
    self.hide = hide
    return self
end

return constructor