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

        if scene and event.other.isPlayer then
            self.lastTouchingPlayer = event.other
            if self.shotOnGoal then
                local toPlayerX, toPlayerY = self.lastTouchingPlayer.x - self.x, self.lastTouchingPlayer.y - self.y;
                local vx, vy = self:getLinearVelocity()
                local indicator = toPlayerX * vx + toPlayerY * vy
                DEBUG.Log("Save by " ..  event.other.colorName)
                if indicator > 0 then
                    scene:showGameText("save", self.x, self.y, event.other.colorName)
                    self.lastTouchingPlayer.savesCount = self.lastTouchingPlayer.savesCount + 1
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
    end
end

local function checkShotOnGoal(self)
    local vx, vy = self:getLinearVelocity()
    local hits = physics.rayCast(self.x, self.y, self.x + vx * RAYCAST_DISTANCE_MUL,
        self.y + vy * RAYCAST_DISTANCE_MUL, "unsorted")
    if hits then
        local gate
        for i, hit in ipairs(hits) do
            if hit.object.isGate then
                gate = hit.object
                break
            end
        end
        if not gate then
            return false
        end
        if gate.y < display.contentCenterY / 2 and self.y < gate.y + gate.height * 2 or
           gate.y > display.contentCenterY / 2 and self.y > gate.y - gate.height * 2
        then
            return false
        end
        DEBUG.Log("Shot on goal!!!")
        return true
    end
    return false
end

local function update(self)
    self.shotOnGoal = self:checkShotOnGoal()
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
    self.linearDamping = 0.2
    self.angularDamping = 5
    self.isPuck = true
    self.shotOnGoal = false

    -- Methods
    self.collision       = collision
    self.update          = update
    self.checkShotOnGoal = checkShotOnGoal

    self:addEventListener("collision")
    return self
end

return constructor