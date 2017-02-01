local Score     = require("game.ui.Score")
local Winner    = require("game.ui.Winner")
local Countdown = require("game.ui.Countdown")

local function constructor(colorName, isMultiplayer)
    if not colorName then
        colorName = "red"
    end
    local self = display.newGroup()

    if colorName == "blue" then
        self.bg = display.newRect(0, 0, display.contentWidth, display.contentHeight * 2)
        self.bg:setFillColor(0, 0, 0, 0.9)
        self.bg.alpha = 0
        self:insert(self.bg)
    end

    self.score = Score(colorName)
    self:insert(self.score)

    self.countdown = Countdown(colorName)
    self:insert(self.countdown)

    self.winner = Winner(isMultiplayer, self.bg)
    self:insert(self.winner)
    return self
end

return constructor