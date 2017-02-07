local function constructor(text, x, y, colorName, reversed)
    local self = display.newText(lang.getString("game_text_" .. tostring(text)), 0, 0, "pixel_font.ttf", 8)
    if colorName == "red" then
        self:setFillColor(255, 0, 0)
    else
        self:setFillColor(0, 0, 255)
    end
    self.x = x
    self.y = y

    self.rotation = (math.random() - 0.5) * 20
    local dy = -20
    if reversed then
        self.rotation = self.rotation + 180
        dy = 20
    end
    self.xScale = 0.8
    self.yScale = 0.8
    transition.to(self, { time = 700, delta = true, y = dy, alpha = -1, xScale = 0.2, yScale = 0.2})
    timer.performWithDelay(1000, function ()
        self:removeSelf()
    end)
    return self
end

return constructor