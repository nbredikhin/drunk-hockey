
local function animateNumber(self)
    self.number.alpha = 1
    self.number.xScale = 1
    self.number.yScale = 1
    transition.from(self.number, {transition=easing.outBack, alpha=0, delay=0,   time=200, xScale=0.8, yScale=0.1})
    transition.to(self.number, {transition=easing.inBack, alpha=0, delay=200,   time=400, xScale=0.8, yScale=1.5})
end

local function show(self)
    local frame = 4
    self.number:setFrame(frame)
    self:animateNumber()
    audio.play(self.sound1)

    timer.performWithDelay(900, function ()
        frame = frame - 1
        self.number:setFrame(frame)
        self:animateNumber(self.number)

        if frame == 1 then
            audio.play(self.sound2)
        else
            audio.play(self.sound1)
        end
    end, 3)
    self.isVisible = true

    return 900 * 3
end

local function constructor(colorName, isMLG)
    local self = display.newGroup()

    self.sound1 = audio.loadSound("assets/sounds/countdown1.wav")
    local path = "assets/sounds/countdown2.wav"
    if isMLG then
        path = "assets/sounds/countdown_2_mlg.wav"
    end
    self.sound2 = audio.loadSound(path)

    self.numbers = {}
    local imageSheet = graphics.newImageSheet("assets/ui/numbers.png", {
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
    if colorName == "blue" then
        self.number:setFillColor(0.15, 0.4, 1)
    else
        self.number:setFillColor(1, 0.1, 0.1)
    end

    self.isVisible = false

    self.show = show
    self.animateNumber = animateNumber
    return self
end

return constructor