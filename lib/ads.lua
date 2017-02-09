if system.getInfo("environment") ~= "simulator" and not DEBUG.disableAds then
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
    if DEBUG.disableAds then
        return
    end
    adImage.isVisible = true
    timer.performWithDelay(true, 2000, function ()
        adImage.isVisible = false
    end)
end

function ads.load(...)

end

function ads.init(...)

end

function ads.hide()
    adImage.isVisible = false
end

function ads.isLoaded()
    return true
end

return ads