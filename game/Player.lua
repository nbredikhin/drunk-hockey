local physics = require("physics")

local function update(self)
    self.angularVelocity = self.rotationSpeed
    self.shadow.rotation = -self.rotation
end

local function move(self, x, y)
    x = math.max(-self.maxMovementSpeed, math.min(x, self.maxMovementSpeed))
    y = math.max(-self.maxMovementSpeed, math.min(y, self.maxMovementSpeed))
    self:applyForce(x * self.movementSpeed, y * self.movementSpeed, self.x, self.y)
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

    self.movementSpeed = 0.0008
    self.rotationSpeed = -500

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

    -- Methods
    self.update = update
    self.move   = move
    return self
end 

return constructor