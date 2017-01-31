local composer = require("composer")
local physics  = require("physics")
local utils    = require("lib.utils")

local MIN_SHAKE_FORCE = 100
local MAX_SHAKE_FORCE = 250

local function collision(self, event)
    if event.phase == "began" then
        local force = utils.vectorLength(self:getLinearVelocity())
        if force > MIN_SHAKE_FORCE then
            local scene = composer.getScene(composer.getSceneName("current"))
            if scene and scene.shake then
                local mul = (force - MIN_SHAKE_FORCE) / (MAX_SHAKE_FORCE - MIN_SHAKE_FORCE)
                scene:shake(mul)
            end
        end
    elseif event.phase == "ended" then
        self.angularVelocity = (math.random() - 0.5) * 1000
    end
end

local function constructor()
    local self = display.newImage("assets/puck.png")

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

    -- Methods
    self.collision = collision

    self:addEventListener("collision")
    return self
end

return constructor