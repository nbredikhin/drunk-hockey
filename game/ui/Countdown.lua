
local function animateNumber(number)
    number.alpha = 1
    number.xScale = 1
    number.yScale = 1
    transition.from(number, {transition=easing.outBack, alpha=0, delay=0,   time=200, xScale=0.8, yScale=0.1})
    transition.to(number, {transition=easing.inBack, alpha=0, delay=200,   time=400, xScale=0.8, yScale=1.5})
end

local function show(self, callback)
    local frame = 4
    self.number:setFrame(frame)
    animateNumber(self.number)

    timer.performWithDelay(900, function ()
        frame = frame - 1
        self.number:setFrame(frame)
        animateNumber(self.number)

        if frame == 1 and callback then
            callback()
        end
    end, 3)
    self.isVisible = true
end

local function constructor()
    local self = display.newGroup()

    self.numbers = {}
    local imageSheet = graphics.newImageSheet("assets/ui/score.png", {
        width = 24, 
        height = 24,
        numFrames = 6
    })

    self.number = display.newSprite(self, imageSheet, {
        name = "default",
        start = 1,
        count = 6
    })
    self.number:setFrame(1)

    self.isVisible = false

    self.show = show
    return self
end

return constructor