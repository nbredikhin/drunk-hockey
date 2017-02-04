local composer = require("composer")

local scene = composer.newScene()

local aboutLines = {
    "Programming and art",
    "Nikita Bredikhin",
    "", "",
    "Programming",
    "Evgeniy Morozov",
    "", "",
    "Music",
    "Azureflux, mathgrant",
    "", "",
    "Thanks for playing!"
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
        y    = display.contentCenterY + 50,
        font = native.systemFont,
        fontSize = 7,
        align = "center"
    })
    self.scrollingGroup:insert(text)

    self.minY = -40
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