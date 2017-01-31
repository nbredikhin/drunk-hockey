local utils = require("lib.utils")

local function touch(self, event)   
    if self.id and event.id ~= self.id then
        return
    end     
    if event.phase == "began" then
        self.sx = event.x
        self.sy = event.y
        self.targetAlpha = 0.2
        self.id = event.id
        self.active = true
    elseif event.phase == "ended" then
        self.targetAlpha = 0
        self.id = nil
        self.active = false
    end

    if self.active then
        local dx = self.sx - event.x
        local dy = self.sy - event.y
        local angle = math.atan2(dy, dx)
        local distance = utils.vectorLength(dx, dy)
        distance = math.min(distance, self.maxDistance)
        local distanceMul = distance / self.maxDistance
        self.targetAlpha = distanceMul * 0.5 + 0.2

        self.inputX = -math.cos(angle) * distance
        self.inputY = -math.sin(angle) * distance

        self.x = self.sx + self.inputX
        self.y = self.sy + self.inputY
        self.rotation = angle / math.pi * 180 

        self.targetScale = distanceMul * 0.3 + 0.7
    end  
end

local function update(self)
    self.alpha = self.alpha + (self.targetAlpha - self.alpha) * 0.1
    self.scale = self.scale + (self.targetScale - self.scale) * 0.2
    if self.scale > 0 then
        self.xScale, self.yScale = self.scale, self.scale
    end
end

local function constructor()
    local self = display.newImage("assets/joystick_arrow.png")

    self.alpha = 0
    self.targetAlpha = 0

    self.scale = 0
    self.targetScale = 0

    self.sx = 0
    self.sy = 0

    self.inputX = 0
    self.inputY = 0

    self.maxDistance = 20

    self.touch = touch
    self.update = update
    return self
end

return constructor