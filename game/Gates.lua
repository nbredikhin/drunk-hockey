local physics  = require("physics")
local composer = require("composer")

local function update(self)
    local dx = (self.initialX - self.x) * self.returnForce
    local dy = (self.initialY - self.y) * self.returnForce
    self:applyForce(dx, dy, self.x, self.y)
end 

local function collision(self, event)
    if event.phase == "began" and event.other.isPuck and event.selfElement == 4 then
        local scene = composer.getScene(composer.getSceneName("current"))
        if scene and scene.endRound then
            timer.performWithDelay(1, function ()
                scene:endRound(self.colorName)
            end)
        end
    end
end

local function constructor(colorName, x, y)
    local self = display.newImage("assets/gate_".. colorName ..".png")
    self.colorName = colorName
    self.initialX = x
    self.initialY = y

    self.x = x
    self.y = y

    self.returnForce = 0.05
    local filter = { groupIndex = -1 }
    -- Physics setup
    physics.addBody(self,
    -- Stick body
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        box = {
            halfWidth  = self.width * 0.4,
            halfHeight = 0.5,
            x          = 0,
            y          = self.height / 2,
            angle      = 0,
        }
    },
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        box = {
            halfWidth  = self.height / 2,
            halfHeight = 0.5,
            x          = -self.width / 2,
            y          = 0,
            angle      = 80,
        }
    },
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        box = {
            halfWidth  = self.height / 2,
            halfHeight = 0.5,
            x          = self.width / 2,
            y          = 0,
            angle      = -80,
        }
    },
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        isSensor = true,
        box = {
            halfWidth  = self.width * 0.4,
            halfHeight = 0.5,
            x          = 0,
            y          = self.height * -0.1,
            angle      = 0,
        }
    })

    self.linearDamping = 100
    self.isFixedRotation = true

    self.update = update
    self.collision = collision

    self:addEventListener("collision")
    return self
end

return constructor