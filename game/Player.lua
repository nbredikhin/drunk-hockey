local physics = require("physics")

local function increaseRotationSpeed(self, speedMultiplyer, timeout)
    self.rotationSpeed = self.rotationSpeed * speedMultiplyer
    self.resetSpeedTimer = timer.performWithDelay(timeout,
        function()
            self.rotationSpeed = self.defaultRotationSpeed
        end)
end

local function reset(self)
    self:setLinearVelocity(0, 0)
    self.angularVelocity = 0
    self.rotationSpeed = self.defaultRotationSpeed

    if self.resetSpeedTimer ~= nil then
        timer.cancel(self.resetSpeedTimer)
    end
end

local function update(self, dt)
    self.angularVelocity = self.rotationSpeed * dt
    self.shadow.rotation = -self.rotation * dt
end

local function move(self, x, y, dt)
    x = math.max(-self.maxMovementSpeed, math.min(x, self.maxMovementSpeed))
    y = math.max(-self.maxMovementSpeed, math.min(y, self.maxMovementSpeed))
    self:applyForce(x * self.movementSpeed * dt, y * self.movementSpeed * dt, self.x, self.y)
end

local function constructor(colorName)
    if not colorName then
        colorName = "blue"
    end
    local self = display.newGroup()
    self.shadow = display.newImage("assets/player_shadow.png")
    self:insert(self.shadow)

    self.body = display.newImage("assets/player_".. colorName ..".png")
    self:insert(self.body)
    self.body.anchorX = 0.3
    self.body.anchorY = 0.7

    self.defaultRotationSpeed = -500

    self.movementSpeed = 0.0008
    self.rotationSpeed = self.defaultRotationSpeed

    self.maxMovementSpeed = 25

    -- Physics setup
    physics.addBody(self,
    -- Stick body
    {
        bounce = 2,
        filter = { groupIndex = -1 },
        box = {
            halfWidth  = 5,
            halfHeight = 0.5,
            x          = 5,
            y          = -5.7,
            angle      = -15,
        }
    },
    -- Player's body
    {
        density = 0.03,
        bounce = 0,
        radius = 4
    })
    self.linearDamping = 5
    self.isPlayer = true

    -- Methods
    self.update = update
    self.move   = move
    self.increaseRotationSpeed = increaseRotationSpeed
    self.reset = reset
    return self
end

return constructor