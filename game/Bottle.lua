local composer = require("composer")
local physics  = require("physics")
local utils    = require("lib.utils")

local function collision(self, event)
    if not self.isVisible then
        return
    end
    if event.phase == "began" and event.other.isPlayer then
        local player = event.other
        self.isVisible = false
        audio.play(self.sound, { channel = 20 })
        player:increaseRotationSpeed(self.speedUpRatio, self.speedUpDuration)
        Globals.analytics.logEvent("Bottle", { action = "Used" })

        local scene = composer.getScene(composer.getSceneName("current"))
        if scene and scene.showGameText then
            local phraseId = math.random(1, 7)
            scene:showGameText("phrase_bottle_"..phraseId, self.x, self.y, player.colorName)
        end
        scene:delayBottleSpawn()
    end
end

local function constructor(isMLG)
    local physicsParameters = {}

    if isMLG then
        self = display.newImage("assets/mnt_dew.png")
        self.sound = audio.loadSound("assets/sounds/powerup_mlg.wav")
        self.xScale = 0.02
        self.yScale = 0.02
        physicsParameters = {
            isSensor = true,
            box = {
                halfWidth  = self.width  / 2 * self.xScale,
                halfHeight = self.height / 2 * self.yScale
            }
        }
    else
        self = display.newImage("assets/bottle.png")
        self.sound = audio.loadSound("assets/sounds/powerup.wav")

        physicsParameters = {
            isSensor = true,
        }
    end

    physics.addBody(self, physicsParameters)

    self.x = 50
    self.y = 70
    self.angularVelocity = 360
    self.speedUpDuration = 10000
    self.speedUpRatio = 2

    self.collision = collision

    self:addEventListener("collision")
    return self
end

return constructor