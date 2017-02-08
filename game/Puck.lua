local composer = require("composer")
local physics  = require("physics")
local utils    = require("lib.utils")

local MIN_SHAKE_FORCE = 100
local MAX_SHAKE_FORCE = 250

local MIN_SOUND_FORCE = 10
local MAX_SOUND_FORCE = 70

local RAYCAST_DISTANCE_MUL = 0.8

local function collision(self, event)
    if event.phase == "began" then
        local scene = composer.getScene(composer.getSceneName("current"))
        local force = utils.vectorLength(self:getLinearVelocity())
        if force > MIN_SOUND_FORCE then
            local volume = (force - MIN_SOUND_FORCE) / (MAX_SOUND_FORCE - MIN_SOUND_FORCE)
            audio.setVolume(volume, { channel = 2 })
            audio.play(self.hitSound, { channel = 2 })
        end
        if force > MIN_SHAKE_FORCE then
            if scene and scene.shake then
                local mul = (force - MIN_SHAKE_FORCE) / (MAX_SHAKE_FORCE - MIN_SHAKE_FORCE)
                scene:shake(mul)
            end
        end

        if scene and (event.other.isPlayer or event.other.isGates) then
            if self:isPlayerShotOnGoal() then
                DEBUG.Log("SHOT ON GOAL: %d", self.lastTouchingPlayer.goalShots)
                self.lastTouchingPlayer.goalShots = self.lastTouchingPlayer.goalShots + 1
            end
        end

        if scene and event.other.isPlayer then
            self.lastTouchingPlayer = event.other

            if self:isShotOnGoal() then
                local toPlayerX, toPlayerY = event.other.x - self.x, event.other.y - self.y;
                local vx, vy = self.prevVx, self.prevVy
                local indicator = toPlayerX * vx + toPlayerY * vy
                DEBUG.Log("Save by " ..  event.other.colorName)
                if indicator > 0 then
                    scene:showGameText("save", self.x, self.y, event.other.colorName)
                    event.other.savesCount = event.other.savesCount + 1
                    self.shotOnGoal = false
                end
            end
            if self.touchTimer then
                timer.cancel(self.touchTimer)
            end
            self.touchTimer = timer.performWithDelay(self.lastTouchingPlayer)
        end
    elseif event.phase == "ended" then
        self.angularVelocity = (math.random() - 0.5) * 1000
        -- Обновим скорости
        self.prevVx, self.prevVy = self:getLinearVelocity()
    end
end

local function isPlayerShotOnGoal(self)
    local gates = self:getGatesInDirection()
    if not gates then
        DEBUG.Log("Player shot on goal: false")
        return false
    end

    if gates.colorName == self.lastTouchingPlayer.colorName then
        DEBUG.Log("Player shot on goal: false")
        return false
    end
    DEBUG.Log("Player shot on goal: true")
    return true
end

local function isShotOnGoal(self)
    local gates = self:getGatesInDirection()
    if gates == nil then
        DEBUG.Log("Shot on goal: false")
        return false
    end
    DEBUG.Log("Shot on goal: true")
    return true
end

local function getGatesInDirection(self)
    local vx, vy = self.prevVx, self.prevVy
    local hits = physics.rayCast(self.x, self.y, self.x + vx * RAYCAST_DISTANCE_MUL,
        self.y + vy * 1, "unsorted")
    if hits then
        local gate
        for i, hit in ipairs(hits) do
            if hit.object.isGate then
                DEBUG.Log("OH YEAH")
                gate = hit.object
                break
            end
        end
        if not gate then
            return nil
        end
        if gate.y < display.contentCenterY / 2 and self.y < gate.y - gate.height * 2 or
           gate.y > display.contentCenterY / 2 and self.y > gate.y + gate.height * 2
        then
            DEBUG.Log("OH NO")
            return nil
        end
        return gate
    end
    return nil
end

local function update(self)
end

local function constructor()
    local self = display.newImage("assets/puck.png")
    self.hitSound = audio.loadSound("assets/sounds/hit.wav")

    -- Physics setup
    physics.addBody(self, {
        density = 0.05,
        bounce = 1,
        friction = 0,
        radius = 2.7
    })
    self.prevVx = 0
    self.prevVy = 0

    self.linearDamping = 0.2
    self.angularDamping = 5
    self.isPuck = true

    -- Methods
    self.collision       = collision
    self.update          = update
    self.isShotOnGoal    = isShotOnGoal
    self.isPlayerShotOnGoal  = isPlayerShotOnGoal
    self.getGatesInDirection = getGatesInDirection

    self:addEventListener("collision")
    return self
end

return constructor