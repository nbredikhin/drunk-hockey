local composer = require("composer")

local function touch(self, event)
    if not self.isVisible then
        self.touchStarted = false
        return
    end
    if event.x >= self.x - self.width/2 and event.y >= self.y - self.height / 2 and
        event.x <= display.contentWidth and event.y <= self.y + self.height / 2
    then
        if event.phase == "began" then
            self.touchStarted = true
        elseif event.phase == "ended" and self.touchStarted then
            local scene = composer.getScene(composer.getSceneName("current"))
            scene:gotoPreviousScene()
        end
    else
        self.touchStarted = false
    end
end

local function constructor()
    local self = display.newImage("assets/ui/pause_button.png")
    self.alpha = 0.45

    self.touch = touch
    return self
end

return constructor