local physics = require("physics")

local function constructor(isMLG)
    local path = "assets/area.png"
    if isMLG then
        path = "assets/area_mlg.png"
    end
    local self = display.newImage(path, display.contentCenterX, display.contentCenterY)

    local cornerSize = 5.5
    local material = { friction = 0, bounce = 1 }

    local boxes = {
        {-self.width / 2, 0,              1,             self.height / 2},
        {self.width / 2,  0,              1,             self.height / 2},
        {0,               self.height/2,  self.width/2,  1},
        {0,              -self.height/2,  self.width/2,  1},
        {-self.width/2,  -self.height/2,  cornerSize,    cornerSize, 45},
        {self.width/2,   -self.height/2,  cornerSize,    cornerSize, 45},
        {self.width/2,    self.height/2,  cornerSize,    cornerSize, 45},
        {-self.width/2,   self.height/2,  cornerSize,    cornerSize, 45}
    }

    local bodies = {}
    for i, box in ipairs(boxes) do
        table.insert(bodies, {
            friction = material.friction,
            bounce   = material.bounce,
            filter = { groupIndex = -1 },
            box = {
                x          = box[1],
                y          = box[2],
                halfWidth  = box[3],
                halfHeight = box[4],
                angle      = box[5]
            }
        })
    end
    -- Physics setup
    physics.addBody(self, "static", unpack(bodies))
    return self
end

return constructor