local composer = require("composer")
local physics  = require("physics")
local widget   = require("widget")

local storage  = require("lib.storage")

local Area     = require("game.Area")
local Player   = require("game.Player")
local Puck     = require("game.Puck")
local Gates    = require("game.Gates")
local Joystick = require("game.Joystick")
local Bot      = require("game.Bot")
local Bottle   = require("game.Bottle")

local GameUI   = require("game.ui.GameUI")
local GameText = require("game.ui.GameText")

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
        scene.bottle.x = scene.area.x + scene.area.width  * (0.15 + math.random() * 0.7 - 0.5)
        scene.bottle.y = scene.area.y + scene.area.height * (0.15 + math.random() * 0.7 - 0.5)

        Globals.analytics.logEvent("Bottle", { action = "Spawned" })
        DEBUG.Log("scene.x = %f, scene.y = %f, scene.width = %f, scene.height = %f, x = %f, y = %f", scene.area.x, scene.area.y, scene.area.width, scene.area.height, scene.bottle.x, scene.bottle.y)
    end
end

function scene:create(event)
    if not event.params then
        event.params = {}
    end
    if not event.params.difficulty then
        event.params.difficulty = "medium"
    end

    self.bottleSpawnDelayMin = 20 * 1000
    self.bottleSpawnDelayMax = 30 * 1000

    self.difficulty = event.params.difficulty
    self.gamemode = event.params.gamemode

    scene.gotoPreviousScene = "scenes.menu"

    self.music = audio.loadStream("assets/music/action.ogg")
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

    self.joysticks = {}
    self.joysticks[1] = Joystick("full")
    group:insert(self.joysticks[1])

    self.uiManagers = {}
    if event.params.gamemode == "multiplayer" then
        -- Два UI
        self.uiManagers[2] = GameUI("blue", true)
        self.uiManagers[2].x = display.contentCenterX
        self.uiManagers[2].y = display.contentCenterY * 0.7
        self.uiManagers[2].rotation = 180
        group:insert(self.uiManagers[2])

        self.uiManagers[1] = GameUI("red", true)
        self.uiManagers[1].x = display.contentCenterX
        self.uiManagers[1].y = display.contentCenterY * 1.3
        group:insert(self.uiManagers[1])

        -- Два джойстика
        self.joysticks[2] = Joystick()
        group:insert(self.joysticks[2])
        self.joysticks[1].side = "bottom"
        self.joysticks[2].side = "top"
    elseif event.params.gamemode == "singleplayer" then
        self.uiManagers[1] = GameUI("red")
        self.uiManagers[1].x = display.contentCenterX
        self.uiManagers[1].y = display.contentCenterY
        group:insert(self.uiManagers[1])

        self.joysticks[2] = Bot(self.puck, self.players[2], difficulty[event.params.difficulty])
    end

    -- Параметры тряски камеры
    self.currentShakeMultiplier = 0
    self.shakePower = 4

    -- Количество голов для завершения игры
    self.maxGoals = 5
    if DEBUG.oneGoalToWin then
        self.maxGoals = 1
    end
    self:restartGame()
end

function scene:delayBottleSpawn()
    local spawnTimer = timer.performWithDelay(
        math.random(self.bottleSpawnDelayMin, self.bottleSpawnDelayMax),
        spawnBottle)

    spawnTimer.params = {
        scene = self
    }
end

function scene:respawn()
    self.puck.x, self.puck.y = display.contentCenterX, display.contentCenterY
    self.puck:setLinearVelocity(0, 0)

    self.players[1].x = display.contentCenterX
    self.players[1].y = display.contentCenterY + self.area.height * 0.32
    self.players[1]:reset()

    self.players[2].x = display.contentCenterX
    self.players[2].y = display.contentCenterY - self.area.height * 0.32
    self.players[2]:reset()

    self.state = "waiting"
end

function scene:startCountdown()
    if self.state == "countdown" then
        return
    end
    if DEBUG.skipCountdown then
        self:startRound()
        return
    end
    local scene = self
    local duration = 0
    for i, ui in ipairs(self.uiManagers) do
        duration = ui.countdown:show()
    end

    timer.performWithDelay(duration, function ()
        self:startRound()
    end)

    self.state = "countdown"
end

function scene:restartGame()
    if self.state == "waiting" then
        DEBUG.Log("DAFUQ?")
        return
    end
    self.score = {0, 0}
    for i, ui in ipairs(self.uiManagers) do
        ui.winner:hide()
    end
    -- Запустить игру
    self:respawn()
    timer.performWithDelay(1500, function ()
        self:startCountdown()
    end)
end

function scene:endGame(winner)
    self.state = "ended"
    -- Обновить прогресс одиночной игры
    if self.gamemode == "singleplayer" then
        if winner == "red" then
            local levelsUnlocked = storage.get("levels_unlocked", 1)
            if self.difficulty == "easy" then
                storage.set("levels_unlocked", math.max(2, levelsUnlocked))
            elseif self.difficulty == "medium" then
                storage.set("levels_unlocked", math.max(3, levelsUnlocked))
            elseif self.difficulty == "hard" then
                storage.set("levels_unlocked", math.max(4, levelsUnlocked))
            end
        end
    end
    -- Скрыть джойстики
    for i, joystick in ipairs(self.joysticks) do
        joystick:hide()
    end
    -- Отобразить экран победителя
    for i, ui in ipairs(self.uiManagers) do
        ui.winner:show(winner, self.score, self.players[i].goalShots, self.players[i].savesCount)
    end
end

-- Goal handling
function scene:endRound(goalTo)
    system.vibrate()
    Globals.analytics.endTimedEvent("Game round", { gamemode = self.gamemode, difficulty = self.difficulty })
    if goalTo == "blue" then
        self.score[1] = self.score[1] + 1
    else
        self.score[2] = self.score[2] + 1
    end
    audio.stop(3)

    if self.score[1] >= self.maxGoals then
        self:endGame("red")
        return
    elseif self.score[2] >= self.maxGoals then
        self:endGame("blue")
        return
    end
    self:respawn()
    -- Скрыть джойстики
    for i, joystick in ipairs(self.joysticks) do
        joystick:hide()
    end

    for i, ui in ipairs(self.uiManagers) do
        ui.score:show(unpack(self.score))
    end

    timer.performWithDelay(2000, function ()
        for i, ui in ipairs(self.uiManagers) do
            ui.score:hide()
        end
    end)

    timer.performWithDelay(3500, function ()
        self:startCountdown()
    end)
end

function scene:startRound()
    self.state = "running"
    audio.seek(0, self.music)
    audio.play(self.music, { channel = 3, loops = -1 })
    audio.setVolume(0.45, { channel = 3 })

    Globals.analytics.startTimedEvent("Game round", { gamemode = self.gamemode, difficulty = self.difficulty })
end

function scene:show(event)
    if event.phase == "did" then
        self.loaded = true
        Globals.analytics.startTimedEvent("Game screen", { gamemode = self.gamemode, difficulty = self.difficulty })
    end
end

function scene:hide(event)
    if event.phase == "will" then
        self.loaded = false
        audio.stop(3)
        Globals.analytics.endTimedEvent("Game screen", { gamemode = self.gamemode, difficulty = self.difficulty })
        timer.cancelAll()
    end
end

function scene:enterFrame()
    if not self.currentShakeMultiplier or not self.loaded then
        return
    end
    local dt = getDeltaTime()
    -- Тряска камеры
    if self.currentShakeMultiplier > 0 then
        self.view.x = (math.random() - 0.5) * self.currentShakeMultiplier * self.shakePower * dt
        self.view.y = (math.random() - 0.5) * self.currentShakeMultiplier * self.shakePower * dt
        self.currentShakeMultiplier = self.currentShakeMultiplier * 0.9
    end

    if self.state == "running" then
        -- Управление игроками
        for i, joystick in ipairs(self.joysticks) do
            joystick:update(dt)
            if joystick.active then
                self.players[i]:move(joystick.inputX, joystick.inputY, dt)
            end
        end

        -- Обновление игроков
        for i, player in ipairs(self.players) do
            player:update(dt)
        end

        self.puck:update()
    end

    for i, gate in ipairs(self.gates) do
        gate:update(dt)
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

function scene:showGameText(text, x, y, colorName)
    local reversed = self.gamemode == "multiplayer" and y < display.contentCenterY / 2
    local text = GameText(text, x, y, colorName, reversed)
    self.view:insert(text)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
