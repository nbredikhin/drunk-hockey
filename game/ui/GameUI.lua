local Score = require("game.ui.Score")
local Countdown = require("game.ui.Countdown")

local function constructor()
    local self = display.newGroup()
    self.score = Score()
    self:insert(self.score)

    self.countdown = Countdown()
    self:insert(self.countdown)
    return self
end

return constructor