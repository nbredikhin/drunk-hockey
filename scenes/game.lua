local composer = require("composer")
local physics  = require("physics")
local widget   = require("widget")

local Area     = require("game.Area")
local Player   = require("game.Player")
local Puck     = require("game.Puck")
local Gates    = require("game.Gates")
local Joystick = require("game.Joystick")
local Bot      = require("game.Bot")
local Bottle   = require("game.Bottle")

local GameUI   = require("game.ui.GameUI")

physics.start()
physics.setGravity(0, 0)
if DEBUG.drawPhysics then
    physics.setDrawMode("hybrid")
end

local scene = composer.newScene()

local function spawnBottle(event)
    local scene = event.source.params.scene
    scene:delayBottleSpawn()
    -- If not spawned
    if not scene.bottle.isVisible then
        scene.bottle.isVisible = true
        scene.bottle.x = math.random((scene.area.x + scene.area.width  * 0.15) +
            scene.area.width  * 0.7 * math.random())
        scene.bottle.y = math.random((scene.area.y + scene.area.height * 0.15) +
            scene.area.height * 0.7 * math.random())

        DEBUG.Log("Spawning a bottle")
    end
end

function scene:create(event)
    if not event.params then
        event.params = {}
    end
    if not event.params.difficulty then
        event.params.difficulty = "easy"
    end

    self.bottleSpawnDelayMin   = 7 * 1000
    self.bottleSpawnDelayRange = 10 * 1000

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

    -- Бутылка
    self.bottle = Bottle()
    group:insert(self.bottle)
    self.bottle.isVisible = false
    self:delayBottleSpawn()

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

    self.joysticks = { Joystick("full") }

    self.uiManagers = {}
    if event.params.gamemode == "multiplayer" then
        -- Два UI
        self.uiManagers[1] = GameUI("red")
        self.uiManagers[1].x = display.contentCenterX
        self.uiManagers[1].y = display.contentCenterY * 1.3
        group:insert(self.uiManagers[1])

        self.uiManagers[2] = GameUI("blue")
        self.uiManagers[2].x = display.contentCenterX
        self.uiManagers[2].y = display.contentCenterY * 0.7
        self.uiManagers[2].rotation = 180
        group:insert(self.uiManagers[2])

        -- Два джойстика
        self.joysticks[2] = Joystick()
        self.joysticks[1].side = "bottom"
        self.joysticks[2].side = "top"
    elseif event.params.gamemode == "singleplayer" then
        self.uiManagers[1] = GameUI("blue")
        self.uiManagers[1].x = display.contentCenterX
        self.uiManagers[1].y = display.contentCenterY
        group:insert(self.uiManagers[1])
        -- TODO: поставить difficulty
        self.joysticks[2] = Bot(self.puck, self.players[2], difficulty[event.params.difficulty])
    end

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

function scene:delayBottleSpawn()
    local spawnTimer = timer.performWithDelay(
        math.random(self.bottleSpawnDelayRange) + self.bottleSpawnDelayMin,
        spawnBottle)

    spawnTimer.params = {
        scene = self
    }
end

function scene:respawn()
    self.playersFrozen = true
    self.puck.x, self.puck.y = display.contentCenterX, display.contentCenterY
    self.puck:setLinearVelocity(0, 0)

    self.players[1].x = display.contentCenterX
    self.players[1].y = display.contentCenterY + self.area.height * 0.32
    self.players[1]:reset()

    self.players[2].x = display.contentCenterX
    self.players[2].y = display.contentCenterY - self.area.height * 0.32
    self.players[2]:reset()
end

function scene:startCountdown()
    local scene = self
    local duration = 0
    for i, ui in ipairs(self.uiManagers) do
        duration = ui.countdown:show()
    end

    timer.performWithDelay(duration, function ()
        self:startRound()
    end)
end

function scene:endRound(goalTo)
    if goalTo == "blue" then
        self.score[1] = self.score[1] + 1
    else
        self.score[2] = self.score[2] + 1
    end
    for i, ui in ipairs(self.uiManagers) do
        ui.score:show(unpack(self.score))
    end

    for i, joystick in ipairs(self.joysticks) do
        joystick.alpha = 0
    end
    self:respawn()

    timer.performWithDelay(2000, function ()
        for i, ui in ipairs(self.uiManagers) do
            ui.score:hide()
        end
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

    if not self.playersFrozen then
        -- Управление игроками
        for i, joystick in ipairs(self.joysticks) do
            joystick:update()
            if joystick.active then
                self.players[i]:move(joystick.inputX, joystick.inputY)
            end
        end

        -- Обновление игроков
        for i, player in ipairs(self.players) do
            player:update()
        end
    end

    for i, gate in ipairs(self.gates) do
        gate:update()
    end
end

function scene:touch(event)
    for i, joystick in ipairs(self.joysticks) do
        joystick:touch(event)
    end
end

function scene:shake(mul)
    self.currentShakeMultiplier = mul
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene