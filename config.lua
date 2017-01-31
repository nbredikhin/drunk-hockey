local originalWidth, originalHeight = 80, 120
local screenWidth, screenHeight = display.pixelWidth, display.pixelHeight
local scale = math.max(originalWidth / screenWidth, originalHeight / screenHeight)

screenWidth, screenHeight = screenWidth * scale, screenHeight * scale

application = {
    content = {
        width  = screenWidth,
        height = screenHeight,
        scale  = "letterBox",
        fps    = 60,

        --[[
        imageSuffix =
        {
                ["@2x"] = 2,
                ["@4x"] = 4,
        },
        --]]
    },
}
-- Сложность бота
difficulty = {
    easy = {
        speed         = 0.5,
        reactionDelay = 150,
        panicChance   = 0.75
    },
    medium = {
        speed         = 0.75,
        reactionDelay = 100,
        panicChance   = 0.5
    },
    hard = {
        speed         = 1.0,
        reactionDelay = 50,
        panicChance   = 0.25
    },
    hardAsBalls = {
        speed         = 1.5,
        reactionDelay = 0,
        panicChance   = 0
    }
}