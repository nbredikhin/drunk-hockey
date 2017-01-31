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
