local composer = require("composer")
local utils = require("lib.utils")

local function touch() end
local function update() end
local function hide() end

local function randomState(event)
    local self = event.source.params

    local probability = math.random()
    local availiableStates = {}
    for k,v in pairs(self.character.states[self.state]) do
        if probability < v then
            table.insert(availiableStates, k)
        end
    end

    if #availiableStates == 0 then
        return
    end
    local newStateIndex = math.random(1, #availiableStates)
    local newState = availiableStates[newStateIndex]

    self.state = newState
    DEBUG.Log("New random state: %s", newState)
end

local function stateManagement(event)
    local self = event.source.params
    local target = nil
    local puck = self.puck
    local gates = self.gates
    local scene = composer.getScene(composer.getSceneName("current"))
    local distance = utils.vectorLength(self.player.x - self.prevX, self.player.y - self.prevY)
    if distance < 4 then
        local number = math.random(1, 6)
        local str = "stuck"
        scene:showGameText("stuck" .. tostring(number), self.player.x, self.player.y, self.player.colorName)
    end
    local probability = math.random()
    if self.state == "defend" then
        self.target = gates
        if math.abs(self.gates.y - self.puck.y) < display.contentHeight / 3.5 and probability < self.character.states[self.state].defend then
            self.state = "defend"
        else
            self.state = "attack"
        end
    elseif self.state == "chase" then
        self.state = "attack"
    elseif self.state == "attack" then
        self.target = puck
        if math.abs(self.gates.y - self.puck.y) < display.contentHeight / 3.5 and probability < self.character.states[self.state].defend then
            self.state = "defend"
        else
            self.state = "attack"
        end
    end
    self.prevX, self.prevY = self.player.x, self.player.y
end

local function updateInput(event)
    local self = event.source.params
    -- "Паника" бота
    local pX, pY = self.puck.x, self.puck.y
    local target = self.target

    local targetSpeed = utils.vectorLength(target:getLinearVelocity())

    local targetX = target.x
    local targetY = target.y

    if targetSpeed > self.panicPuckSpeed then
        local currentChance = math.random()
        if currentChance <= self.difficulty.panicChance then
            targetX = math.random(200) - 100
            targetY = math.random(200) - 100
        end
    end

    local x = targetX - self.player.x
    local y = targetY - self.player.y

    self.inputX = x
    self.inputY = y
end

function startTimers(event)
    local self = event.source.params
    DEBUG.Log("Timers started")
    local stateTimer = timer.performWithDelay(1000, stateManagement, 0)
    stateTimer.params = self

    local randomState = timer.performWithDelay(5000, randomState, 0)
    randomState.params = self
end


local function constructor(puck, player, difficulty, gates, character)
    local self = {}
    self.alpha = 0

    self.touch  = touch
    self.update = update
    self.hide   = hide
    self.prevX, self.prevY = 0, 0
    self.puck   = puck
    self.player = player
    self.active = true
    self.state  = character.initialState
    self.gates  = gates
    self.target = gates
    self.character = character
    DEBUG.Log("%s", self.state)
    self.difficulty = difficulty
    self.panicPuckSpeed = 80
    self.player.maxMovementSpeed = self.difficulty.speed * self.player.maxMovementSpeed

    local reactionTimer = timer.performWithDelay(self.difficulty.reactionDelay,
                                                 updateInput, 0)
    reactionTimer.params = self

    local randomStart = math.random(500, 2000)
    local startTimers = timer.performWithDelay(randomStart, startTimers, 1)
    startTimers.params = self

    return self
end

return constructor
