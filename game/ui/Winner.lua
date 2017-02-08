local widget    = require("widget")
local composer  = require("composer")
local adsconfig = require("adsconfig")
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
    self.button:setLabel(lang.getString("game_restart_button"))

    if winner == self.colorName then
        self.winnerText.text = lang.getString("game_you_win")
        if not self.isMultiplayer then
            self.button:setLabel(lang.getString("game_end_button"))
        end
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

    self.button.alpha = 1
    self.button.xScale = 1
    self.button.yScale = 1

    transition.from(self.winnerText, { transition=easing.outBack, delay = 500, time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.scoreText, { transition=easing.outBack, delay = 1000, time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.infoText, { transition=easing.outBack, delay = 1500, time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.button, { transition=easing.outBack, delay = 2000, time = 500, alpha = 0, xScale = 0.3, yScale = 0.8 })
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

    self.button = widget.newButton({
        x = 0,
        y = 35,
        width = display.contentWidth,
        height = display.contentHeight,

        font = "pixel_font.ttf",
        fontSize = 5,
        label = lang.getString("game_restart_button"),
        labelColor = { default = {1, 1, 1} },

        defaultFile = "assets/empty.png",

        onRelease = function ()
            if ads.isLoaded(adsconfig.adType) then
                DEBUG.Log("Show ad")
                ads.show(adsconfig.adType, { testMode = adsconfig.testMode })
            else
                DEBUG.Log("Can't show ad. Ad is not loaded yet")
            end

            if not self.isMultiplayer and self.winner == "red" then
                DEBUG.Log("SHIIIIET")
                composer.gotoScene("scenes.menu", {time = 500, effect = "slideRight"})
                return
            end
            local scene = composer.getScene(composer.getSceneName("current"))
            if scene and scene.shake then
                DEBUG.Log("RESTARTING)")
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