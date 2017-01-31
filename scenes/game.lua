local composer = require("composer")
local physics  = require("physics")
local widget   = require("widget")

local Area     = require("game.Area")
local Player   = require("game.Player")
local Puck     = require("game.Puck")
local Gates    = require("game.Gates")
local Joystick = require("game.Joystick")

local GameUI   = require("game.ui.GameUI")

physics.start()
physics.setGravity(0, 0)
if DEBUG.drawPhysics then
    physics.setDrawMode("hybrid") 
end

local scene = composer.newScene()

function scene:create()
    scene.gotoPreviousScene = "scenes.menu"
    local group = self.view
    local background = display.newImage("assets/background.png", display.contentCenterX, display.contentCenterY)
    background.width = display.contentWidth
    background.height = display.contentHeight
    group:insert(background)

    self.area = Area()
    group:insert(self.area)

    -- Шайба
    self.puck = Puck()
    group:insert(self.puck)    

    -- Игроки
    self.players = {}
    self.players[1] = Player("red")
    group:insert(self.players[1])

    self.players[2] = Player("blue")
    self.players[2].rotation = 180
    group:insert(self.players[2])

    -- Ворота
    self.gates = {}
    self.gates[1] = Gates("red", display.contentCenterX, display.contentCenterY + self.area.height * 0.38)
    group:insert(self.gates[1])

    self.gates[2] = Gates("blue", display.contentCenterX, display.contentCenterY - self.area.height * 0.38)
    self.gates[2].rotation = 180
    group:insert(self.gates[2])

    self.joystick = Joystick()

    self.ui = GameUI()
    self.ui.x = display.contentCenterX
    self.ui.y = display.contentCenterY
    group:insert(self.ui)

    -- Тряска камеры
    self.currentShakeMultiplier = 0
    self.shakePower = 4

    self.playersFrozen = false

    self:respawn()
    timer.performWithDelay(2000, function ()
        self:startCountdown()
    end)

    self.score = {0, 0}
end

function scene:respawn()
    self.playersFrozen = true
    self.puck.x, self.puck.y = display.contentCenterX, display.contentCenterY
    self.puck:setLinearVelocity(0, 0)

    self.players[1].x = display.contentCenterX
    self.players[1].y = display.contentCenterY + self.area.height * 0.32
    self.players[1]:setLinearVelocity(0, 0)

    self.players[2].x = display.contentCenterX
    self.players[2].y = display.contentCenterY - self.area.height * 0.32
    self.players[2]:setLinearVelocity(0, 0)
end

function scene:startCountdown()
    local scene = self
    self.ui.countdown:show(function ()
        self:startRound()
    end)
end

function scene:endRound(goalTo)
    if goalTo == "blue" then
        self.score[1] = self.score[1] + 1
    else
        self.score[2] = self.score[2] + 1
    end
    self.ui.score:show(unpack(self.score))
    self.playersFrozen = true
    self:respawn()

    timer.performWithDelay(2000, function ()
        self.ui.score:hide()
    end)

    timer.performWithDelay(4500, function ()
        self:startCountdown()
    end)
end

function scene:startRound()
    self.playersFrozen = false
end

function scene:onGoal(playerName)
    -- playerName - кому забили
    print("Goal to " .. tostring(playerName))
    self:respawn()
end

function scene:show(event)
    if event.phase == "did" then
        self.loaded = true
    end
end

function scene:enterFrame()
    if not self.currentShakeMultiplier then
        return
    end
    -- Тряска камеры
    if self.currentShakeMultiplier > 0 then
        self.view.x = (math.random() - 0.5) * self.currentShakeMultiplier * self.shakePower
        self.view.y = (math.random() - 0.5) * self.currentShakeMultiplier * self.shakePower
        self.currentShakeMultiplier = self.currentShakeMultiplier * 0.9
    end

    -- Управление игроками
    if not self.playersFrozen then
        self.joystick:update()
        if self.joystick.active then
            self.players[1]:move(self.joystick.inputX, self.joystick.inputY)
        end
    end

    -- self.players[2]:move(self.puck.x - self.players[2].x, self.puck.y - self.players[2].y)

    -- Обновление игроков
    for i, player in ipairs(self.players) do
        player:update()
    end

    for i, gate in ipairs(self.gates) do
        gate:update()
    end    
end

function scene:touch(event)
    self.joystick:touch(event)
end

function scene:shake(mul)
    self.currentShakeMultiplier = mul
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene