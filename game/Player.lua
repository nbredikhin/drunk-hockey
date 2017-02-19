local physics = require("physics")
local utils   = require("lib.utils")

local MAX_HEALTH = 100
local STICK_DAMAGE = 38
-- Время лежания после падения
local DOWN_TIME = 3500
local PUCK_DOWN_TIME = 1500

local HEALTH_REGEN_SPEED = 0.3

local function hideHitMark(event)
    local self = event.source.params

    self.hitmark.isVisible = false
end

local function increaseRotationSpeed(self, speedMultiplier, timeout)
    self.rotationSpeed = self.rotationSpeed * speedMultiplier
    self.isUsingBottle = true
    self.resetSpeedTimer = timer.performWithDelay(timeout,
        function()
            self.isUsingBottle = false
            self.rotationSpeed = self.defaultRotationSpeed
        end)
end

local function collision(self, event)
    if event.phase ~= "began" then
        return
    end

    if event.other.isPlayer
        -- Нас бьют клюшкой
        and event.otherElement == 2
        -- Нас бьют по телу
        and event.selfElement == 1
        -- Игрок из другой команды
        and event.other.colorName ~= self.colorName then

        self.hitmark.x = event.other.x
        self.hitmark.y = event.other.y
        self.hitmark.isVisible = true
        local hideTimer = timer.performWithDelay(100, hideHitMark, 1)
        hideTimer.params = self

        -- Если игрок с бутылкой
        if event.other.isUsingBottle then
            self:hurt(MAX_HEALTH)
        else
            -- Сила удара зависит от скорости вращения
            local force = utils.clamp((math.abs(event.other.angularVelocity) - 0) / 600, 0, 1)
            self:hurt(STICK_DAMAGE * force)
        end
    elseif event.other.isPuck then
        -- Падение от шайбы
        local force = utils.vectorLength(event.other:getLinearVelocity())
        if force > 120 then
            self:fall(PUCK_DOWN_TIME)
        end
    end
end

-- Падение игрока
local function fall(self, resetDelay)
    if self.isFallen then
        return
    end
    self.fallen.isVisible = true
    self.body.isVisible = false
    self.angularDamping = 10

    self.isFallen = true

    audio.play(self.hurtSound, { channel = 8 })

    if resetDelay then
        timer.performWithDelay(resetDelay, function ()
            if self.isFallen then
                self:reset()
            end
        end)
    end
end

-- Нанесение удара по игроку
local function hurt(self, damage)
    if not damage then
        return
    end
    self.health = self.health - damage
    if self.health <= 0 then
        self:fall(DOWN_TIME)
        self.health = 0
        return
    end
    audio.play(self.hurtSound, { channel = 8 })
end

local function reset(self)
    self:setLinearVelocity(0, 0)
    self.angularVelocity = 0
    self.rotationSpeed = self.defaultRotationSpeed
    self.angularDamping = 0

    self.fallen.isVisible = false
    self.body.isVisible = true
    self.isFallen = false
    self.isUsingBottle = false

    if self.resetSpeedTimer ~= nil then
        timer.cancel(self.resetSpeedTimer)
    end
end

local function resetStats(self)
    self.goalShots = 0
    self.savesCount = 0
end

local function update(self, dt)
    if not self.isFallen then
        self.angularVelocity = self.rotationSpeed * dt
    end
    self.health = utils.clamp(self.health + dt * HEALTH_REGEN_SPEED, 0, MAX_HEALTH)
    self.shadow.rotation = -self.rotation
end

local function move(self, x, y, dt)
    if self.isFallen then
        return
    end
    local magnitude = math.sqrt(x * x + y * y)
    if magnitude == 0 then
        return
    end
    x = x / magnitude
    y = y / magnitude
    self:applyLinearImpulse(x * self.maxMovementSpeed * dt, y * self.maxMovementSpeed * dt, self.x, self.y)
end

local function constructor(colorName, isBot, isMLG)
    if not colorName then
        colorName = "blue"
    end
    local self = display.newGroup()

    local path = "assets/sounds/hurt.wav"
    if isMLG then
        path = "assets/sounds/hurt_mlg.wav"
    end

    self.hitmark = display.newImage("assets/hitmark.png")
    self.hitmark.xScale = 0.5
    self.hitmark.yScale = 0.5
    self.hitmark.isVisible = false

    self.hurtSound = audio.loadSound(path)
    self.health = MAX_HEALTH

    local scaleX = 1
    local scaleY = 1
    local aplha = 1
    local path = "assets/player_shadow.png"
    if isMLG then
        path = "assets/player_shadow_mlg.png"
        scaleX = 0.1
        scaleY = 0.1
        alpha = 0.3
    end
    self.shadow = display.newImage(path)
    self.shadow.xScale = scaleX
    self.shadow.yScale = scaleY
    self.shadow.alpha = alpha
    self:insert(self.shadow)

    path = "assets/player_".. colorName ..".png"
    if isBot then
        path = "assets/player_".. colorName .."_bot.png"
    end
    self.body = display.newImage(path)
    self:insert(self.body)
    self.body.anchorX = 0.3
    self.body.anchorY = 0.7
    -- Упавший игрок
    self.fallen = display.newImage("assets/player_down_" .. colorName .. ".png")
    self.fallen.anchorX = 0.3
    self.fallen.anchorY = 0.6
    self.fallen.isVisible = false
    self:insert(self.fallen)

    self.isFallen = false

    self.colorName = colorName

    self.goalShots = 0
    self.savesCount = 0

    self.defaultRotationSpeed = -500

    self.movementSpeed = 0.0008
    self.rotationSpeed = self.defaultRotationSpeed

    self.maxMovementSpeed = 0.0002

    -- Physics setup
    physics.addBody(self,
    -- Stick body
    {
        bounce = 2,
        filter = { groupIndex = -1 },
        box = {
            halfWidth  = 5,
            halfHeight = 0.5,
            x          = 5,
            y          = -5.7,
            angle      = -15,
        }
    },
    -- Player's body
    {
        density = 0.03,
        bounce = 0,
        radius = 4
    })
    self.linearDamping = 5
    self.isPlayer = true

    -- Methods
    self.update = update
    self.move   = move
    self.increaseRotationSpeed = increaseRotationSpeed
    self.reset = reset
    self.resetStats = resetStats
    self.fall = fall
    self.hurt = hurt
    self.collision = collision

    -- Events
    self:addEventListener("collision")
    return self
end

return constructor