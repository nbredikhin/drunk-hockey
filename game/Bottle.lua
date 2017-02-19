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

local function constructor()
    -- TODO: Починить спрайт бутылки
    self = display.newImage("assets/bottle.png")
    self.sound = audio.loadSound("assets/sounds/powerup.wav")
    physics.addBody(self, {
        isSensor = true,
    })

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