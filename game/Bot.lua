local composer = require("composer")
local utils = require("lib.utils")

local function touch() end
local function update() end

local function updateInput(event)
    local self = event.source.params
    -- "Паника" бота
    local puckSpeed = utils.vectorLength(self.puck:getLinearVelocity())

    local targetX = self.puck.x
    local targetY = self.puck.y

    if puckSpeed > self.panicPuckSpeed then
        local currentChance = math.random()
        if currentChance <= self.difficulty.panicChance then
            DEBUG.Log("OMG PANIC!!!")
            targetX = math.random(200) - 100
            targetY = math.random(200) - 100
        end
    end

    local x = targetX - self.player.x
    local y = targetY - self.player.y

    local magnitude = math.sqrt(x * x + y * y)
    local ratio = self.difficulty.speed * self.player.maxMovementSpeed

    self.inputX = x / magnitude * ratio
    self.inputY = y / magnitude * ratio
end

local function constructor(puck, player, difficulty)
    local self = {}
    self.alpha = 0

    self.touch  = touch
    self.update = update

    self.puck = puck
    self.player = player
    self.active = true

    self.difficulty = difficulty
    self.panicPuckSpeed = 170

    local reactionTimer = timer.performWithDelay(self.difficulty.reactionDelay,
                                                 updateInput, 0)
    reactionTimer.params = self
    DEBUG.Log("Reaction delay: %d",    self.difficulty.reactionDelay)
    DEBUG.Log("Panic chance:   %1.2f", self.difficulty.panicChance)
    DEBUG.Log("Speed:          %1.2f", self.difficulty.speed)

    return self
end

return constructor