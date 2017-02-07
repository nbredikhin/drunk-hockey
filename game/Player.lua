local physics = require("physics")
local utils   = require("lib.utils")

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
    -- Количество ударов по воротам
    self.goalShots = 0
    self.savesCount = 0

    if self.resetSpeedTimer ~= nil then
        timer.cancel(self.resetSpeedTimer)
    end
end

local function update(self, dt)
    self.angularVelocity = self.rotationSpeed * dt
    self.shadow.rotation = -self.rotation
end

local function move(self, x, y, dt)
    -- local ratio = self.maxMovementSpeed
    -- x = utils.clamp(x, -self.maxMovementSpeed, self.maxMovementSpeed)
    -- y = utils.clamp(y, -self.maxMovementSpeed, self.maxMovementSpeed)
    local magnitude = math.sqrt(x * x + y * y)
    if magnitude == 0 then
        return
    end
    x = x / magnitude
    y = y / magnitude
    self:applyLinearImpulse(x * self.maxMovementSpeed * dt, y * self.maxMovementSpeed * dt, self.x, self.y)
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
    self.colorName = colorName

    self.goalShots = 0
    self.savesCount = 0

    self.defaultRotationSpeed = -500

    self.movementSpeed = 0.0008
    self.rotationSpeed = self.defaultRotationSpeed

    self.maxMovementSpeed = 0.0002

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