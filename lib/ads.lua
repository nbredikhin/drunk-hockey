if system.getInfo("environment") ~= "simulator" then
    return require("ads")
end

local ads = {}
local adImage = display.newImage("assets/ads.png")
adImage.isVisible = false
adImage.x = display.contentCenterX
adImage.y = display.contentCenterY
adImage.width = display.contentWidth
adImage.height = display.contentHeight
function ads.show(...)
    adImage.isVisible = true

    timer.performWithDelay(3000, function ()
        adImage.isVisible = false
    end)
end

function ads.load(...)

end

function ads.init(...)

end

function ads.isLoaded()
    return true
end

return ads