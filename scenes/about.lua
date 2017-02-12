local composer = require("composer")
local widget   = require("widget")

local scene = composer.newScene()

local aboutLines = {
    "Programming and art",
    "Nikita Bredikhin",
    "", "",
    "Programming",
    "Evgeniy Morozov",
    "", "",
    "iOS Developer",
    "Vladimir Burmistrov",
    "","",
    "Music",
    "Azureflux, mathgrant",
}

function scene:create(event)
    local group = self.view

    local background = display.newImage("assets/background.png", display.contentCenterX, display.contentCenterY)
    background.width = display.contentWidth
    background.height = display.contentHeight
    group:insert(background)

    -- Logo
    self.scrollingGroup = display.newGroup()
    self.scrollingGroup.y = display.contentHeight + 5
    group:insert(self.scrollingGroup)

    local logo = display.newImage(self.scrollingGroup, "assets/ui/about_logo.png")
    local logoScale = display.contentWidth / logo.width
    logo.width = logo.width * logoScale
    logo.height = logo.height * logoScale
    logo.x = display.contentCenterX
    logo.y = display.contentCenterY / 3

    local y = logo.y + 25

    logo = display.newImage(self.scrollingGroup, "assets/ui/logo.png")
    local logoScale = display.contentWidth / logo.width
    logo.width = logo.width * logoScale
    logo.height = logo.height * logoScale
    logo.x = display.contentCenterX
    logo.y = y

    local text = display.newText({
        text = table.concat(aboutLines, "\n"),
        x    = display.contentCenterX,
        y    = display.contentCenterY + 40,
        font = "pixel_font.ttf",
        fontSize = 5,
        align = "center"
    })
    self.scrollingGroup:insert(text)

    self.backButton = widget.newButton({
        x = 8,
        y = display.contentHeight - 8,
        width = 14,
        height = 13,

        defaultFile = "assets/ui/back_button.png",
        onRelease = function ()
            self:gotoPreviousScene()
        end
    })
    group:insert(self.backButton)
    self.backButton.alpha = 0.5

    self.minY = -35
    getDeltaTime()
    --self.scrollingGroup.y = self.minY
end

function scene:gotoPreviousScene()
    composer.gotoScene("scenes.menu", {time = 500, effect = "slideLeft"})
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end
    self.loaded = true
end

function scene:enterFrame()
    local dt = getDeltaTime()
    self.scrollingGroup.y = self.scrollingGroup.y - 0.3 * dt
    if self.scrollingGroup.y < self.minY then
        self.scrollingGroup.y = self.minY
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene