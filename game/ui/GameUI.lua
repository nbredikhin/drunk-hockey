local Score = require("game.ui.Score")
local Countdown = require("game.ui.Countdown")

local function constructor(colorName)
    if not colorName then
        colorName = "red"
    end
    local self = display.newGroup()
    self.score = Score(colorName)
    self:insert(self.score)

    self.countdown = Countdown(colorName)
    self:insert(self.countdown)
    return self
end

return constructor