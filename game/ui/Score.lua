local function show(self, score1, score2)
    if not score1 then
        score1 = 0
    end
    if not score2 then
        score2 = 0
    end
    for i, number in ipairs(self.numbers) do
        number.alpha = 1
        number.xScale = 1
        number.yScale = 1
    end
    self.numbers[1]:setFrame(score1 + 1)
    self.numbers[2]:setFrame(score2 + 1)
    self.colon.alpha = 1
    self.colon.xScale = 1
    self.colon.yScale = 1

    transition.from(self.numbers[1], {transition=easing.outBack, alpha=0, delay=0,   time=300, xScale=0.8, yScale=0.1})
    transition.from(self.colon,      {transition=easing.outBack, alpha=0, delay=200, time=300, xScale=0.8, yScale=0.1})
    transition.from(self.numbers[2], {transition=easing.outBack, alpha=0, delay=400, time=300, xScale=0.8, yScale=0.1})

    self.isVisible = true
end

local function hide(self)
    transition.to(self.numbers[1], {transition=easing.inBack, alpha=0, delay=0,   time=300, xScale=0.8, yScale=0.7})
    transition.to(self.colon,      {transition=easing.inBack, alpha=0, delay=150, time=300, xScale=0.8, yScale=0.7})
    transition.to(self.numbers[2], {transition=easing.inBack, alpha=0, delay=300, time=300, xScale=0.8, yScale=0.7})

    timer.performWithDelay(600, function ()
        self.isVisible = false
    end)
end

local function constructor(colorName)
    local self = display.newGroup()

    self.numbers = {}
    local imageSheet = graphics.newImageSheet("assets/ui/numbers.png", {
        width = 24, 
        height = 24,
        numFrames = 6
    })

    self.numbers = {}
    for i = 1, 2 do
        self.numbers[i] = display.newSprite(self, imageSheet, {
            name = "default",
            start = 1,
            count = 6
        })
        self.numbers[i]:setFrame(1)
    end
    self.numbers[1].x = -self.numbers[1].width / 2
    self.numbers[2].x = self.numbers[2].width / 2
    self.colon = display.newImage(self, "assets/ui/colon.png")

    if colorName == "blue" then
        self.numbers[1]:setFillColor(0.15, 0.4, 1)
        self.numbers[2]:setFillColor(0.15, 0.4, 1)
        self.colon:setFillColor(0.15, 0.4, 1)
    else
        self.numbers[1]:setFillColor(1, 0.1, 0.1)
        self.numbers[2]:setFillColor(1, 0.1, 0.1)
        self.colon:setFillColor(1, 0.1, 0.1)
    end

    self.isVisible = false
    self.show = show
    self.hide = hide
    return self
end

return constructor