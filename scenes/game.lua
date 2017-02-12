local composer    = require("composer")
local physics     = require("physics")
local widget      = require("widget")

local storage     = require("lib.storage")
local utils       = require("lib.utils")

local Area        = require("game.Area")
local Player      = require("game.Player")
local Puck        = require("game.Puck")
local Gates       = require("game.Gates")
local Joystick    = require("game.Joystick")
local Bot         = require("game.Bot")
local Bottle      = require("game.Bottle")

local GameUI      = require("game.ui.GameUI")
local GameText    = require("game.ui.GameText")
local Pause       = require("game.ui.Pause")
local PauseButton = require("game.ui.PauseButton")

local ads      = require("lib.ads")
local vibrator = require('plugin.vibrator')

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
    end
end

function scene:create(event)
    if not event.params then
        event.params = {}
    end
    print("Four players: " .. tostring(event.params.fourPlayers))
    if not event.params.difficulty then
        event.params.difficulty = "medium"
    end

    self.bottleSpawnDelayMin = GameConfig.bottleSpawnDelayMin * 1000
    self.bottleSpawnDelayMax = GameConfig.bottleSpawnDelayMax * 1000

    self.difficulty = event.params.difficulty
    self.gamemode = event.params.gamemode

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
    if event.params.fourPlayers then
        print("Four players ")
        for i = 1, 4 do
            local colorName = "red"
            local rotation = 0
            if i > 2 then
                colorName = "blue"
                rotation = 180
            end
            self.players[i] = Player(colorName, i >= 2)
            self.players[i].rotation = rotation
            group:insert(self.players[i])
        end
    else
        self.players[1] = Player("red")
        group:insert(self.players[1])

        self.players[2] = Player("blue", self.gamemode == "singleplayer")
        self.players[2].rotation = 180
        group:insert(self.players[2])
    end

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
        self.uiManagers[1] = GameUI("red", true)
        self.uiManagers[1].x = display.contentCenterX
        self.uiManagers[1].y = display.contentCenterY * 1.3
        group:insert(self.uiManagers[1])

        self.uiManagers[2] = GameUI("blue", true)
        self.uiManagers[2].x = display.contentCenterX
        self.uiManagers[2].y = display.contentCenterY * 0.7
        self.uiManagers[2].rotation = 180
        group:insert(self.uiManagers[2])

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

        for i = 2, #self.players do
            local gates = self.gates[2]
            local AIMode = AIConfig.forward
            if self.players[i].colorName == "red" then
                gates = self.gates[1]
            end

            if i == 4 then
                AIMode = AIConfig.goalie
            end

            self.joysticks[i] = Bot(self.puck, self.players[i],
                difficulty[event.params.difficulty], gates, AIMode)
        end
    end

    -- Экран паузы
    self.pauseUI = Pause()
    self.pauseUI.x = display.contentCenterX
    self.pauseUI.y = display.contentCenterY
    group:insert(self.pauseUI)

    -- Кнопка паузы
    self.pauseButton = PauseButton()
    self.pauseButton.x = display.contentWidth - self.pauseButton.width / 2 - 2
    if self.gamemode == "multiplayer" then
        self.pauseButton.y = display.contentCenterY
    else
        self.pauseButton.y = self.pauseButton.height / 2 + 2
        self.pauseButton.alpha = 0.7
    end
    group:insert(self.pauseButton)

    -- Фоновая музыка
    self.music = audio.loadStream("assets/music/game.mp3")

    -- Параметры тряски камеры
    self.currentShakeMultiplier = 0
    self.shakePower = GameConfig.cameraShakePowerMultiplier

    -- Количество голов для завершения игры
    self.maxGoals = GameConfig.defaultMaxGoals
    if self.gamemode == "singleplayer" and self.difficulty == "easy" then
        self.maxGoals = GameConfig.easyMaxGoals
    end

    if DEBUG.oneGoalToWin then
        self.maxGoals = 1
    end

    self.state = nil
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

    if #self.players == 2 then
        self.players[1].x = display.contentCenterX
        self.players[1].y = display.contentCenterY + self.area.height * 0.32

        self.players[2].x = display.contentCenterX
        self.players[2].y = display.contentCenterY - self.area.height * 0.32
    elseif #self.players == 4 then
        self.players[1].x = display.contentCenterX - 10
        self.players[1].y = display.contentCenterY + self.area.height * 0.28

        self.players[2].x = display.contentCenterX + 10
        self.players[2].y = display.contentCenterY + self.area.height * 0.28

        self.players[3].x = display.contentCenterX - 10
        self.players[3].y = display.contentCenterY - self.area.height * 0.28

        self.players[4].x = display.contentCenterX + 10
        self.players[4].y = display.contentCenterY - self.area.height * 0.28
    end

    for i, player in ipairs(self.players) do
        player:reset()
    end
end

function scene:startCountdown()
    if self.state == "countdown" then
        return
    end
    if DEBUG.skipCountdown then
        self:startRound()
        return
    end
    self:respawn()
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
    if self.state and self.state ~= "ended" then
        return
    end
    self.state = "waiting"
    self.score = {0, 0}

    for i, player in ipairs(self.players) do
        player:resetStats()
    end

    for i, ui in ipairs(self.uiManagers) do
        ui.winner:hide()
    end
    -- Запустить игру
    self:respawn()
    timer.performWithDelay(GameConfig.delayBeforeCountdown, function ()
        self:startCountdown()
    end)
    self.pauseButton.isVisible = true
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
    self.pauseButton.isVisible = false
    -- Отобразить экран победителя
    for i, ui in ipairs(self.uiManagers) do
        ui.winner:show(winner, self.score, self.players[i].goalShots, self.players[i].savesCount)
    end
end

-- Goal handling
function scene:endRound(goalTo)
    if self.state ~= "running" then
        return
    end
    self.state = "waiting"
    Globals.analytics.endTimedEvent("Game round", { gamemode = self.gamemode, difficulty = self.difficulty })

    -- Выключить музыку
    audio.stop(3)
    -- Замедление игры в 10 раз
    physics.setTimeStep(1/60 * GameConfig.goalGameSlowdownMultiplier)
    -- Тряска камеры
    scene:shake(GameConfig.goalCameraShakePower)

    -- Прибавление счёта
    if goalTo == "blue" then
        self.score[1] = self.score[1] + 1
    else
        self.score[2] = self.score[2] + 1
    end

    -- Скрыть джойстики
    for i, joystick in ipairs(self.joysticks) do
        joystick:hide()
    end

    -- Проверить, не забито ли максимальное кол-во голов
    if self.score[1] >= self.maxGoals then
        self:endGame("red")
        return
    elseif self.score[2] >= self.maxGoals then
        self:endGame("blue")
        return
    end
    -- Отобразить счёт
    for i, ui in ipairs(self.uiManagers) do
        ui.score:show(unpack(self.score))
    end
    -- Скрыть счёт
    timer.performWithDelay(GameConfig.scoreDisplayTime, function ()
        for i, ui in ipairs(self.uiManagers) do
            ui.score:hide()
        end
    end)
    -- Запустить следующий раунд
    timer.performWithDelay(GameConfig.scoreDisplayTime + GameConfig.delayBeforeCountdown, function ()
        self:startCountdown()
    end)
end

-- Запуск раунда
function scene:startRound()
    if self.state == "running" then
        return
    end
    self.state = "running"
    Globals.analytics.startTimedEvent("Game round", { gamemode = self.gamemode, difficulty = self.difficulty })
    -- Восстановить время
    physics.setTimeStep(-1)
    -- Запустить музыку
    audio.seek(0, self.music)
    audio.play(self.music, { channel = 3, loops = -1 })
    audio.setVolume(GameConfig.gameMusicVolume,  { channel = 3 })
end

function scene:show(event)
    if event.phase == "did" then
        self.loaded = true
        Globals.analytics.startTimedEvent("Game screen", { gamemode = self.gamemode, difficulty = self.difficulty })
    end

    ads.hide()
end

function scene:hide(event)
    if event.phase == "will" then
        self.loaded = false
        audio.stop(3)
        Globals.analytics.endTimedEvent("Game screen", { gamemode = self.gamemode, difficulty = self.difficulty })
        timer.cancelAll()
    end

    ads.hide()
end

function scene:enterFrame()
    local dt = getDeltaTime()
    if self.isPaused or not self.currentShakeMultiplier or not self.loaded then
        return
    end
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
    if self.isPaused then
        return
    end
    for i, joystick in ipairs(self.joysticks) do
        joystick:touch(event)
    end
    self.pauseButton:touch(event)
end

function scene:shake(mul)
    local haptic = vibrator.newHaptic('impact', 'hard')
    if haptic then
        haptic:invoke()
    end

    self.currentShakeMultiplier = mul
end

function scene:showGameText(text, x, y, colorName)
    local reversed = self.gamemode == "multiplayer" and y < display.contentCenterY / 2
    local text = GameText(text, x, y, colorName, reversed)
    self.view:insert(text)
end

function scene:gotoPreviousScene()
    if self.pauseUI.isVisible then
        self.pauseUI:hide()
        timer.resumeAll()
        physics.start()
        self.isPaused = false
        if self.state == "running" then
            audio.play(self.music, { channel = 3, loops = -1 })
        end
        self.pauseButton.isVisible = true
    elseif self.state ~= "ended" then
        self.pauseUI:show()
        timer.pauseAll()
        physics.pause()
        self.isPaused = true
        audio.stop(3)
        self.pauseButton.isVisible = false
    end
end

-- Системный эвент
function scene:system(event)
    if event.type == "applicationSuspend" then
        if not self.pauseUI.isVisible then
            self:gotoPreviousScene()
        end
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

if DEBUG.enableShortcuts then
    Runtime:addEventListener("key", function(event)
        if event.phase == "down" then
            if event.keyName == "1" then
                scene:endRound("red")
            elseif event.keyName == "2" then
                scene:endRound("blue")
            elseif event.keyName == "0" then
                scene:shake(5)
            elseif event.keyName == "3" then
                scene:endGame("red")
            end
        end
    end)
end

return scene
