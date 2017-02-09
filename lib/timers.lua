local activeTimersList = {}
local _performWithDelay = timer.performWithDelay

timer.performWithDelay = function (delay, ...)
    local t
    if type(delay) == "boolean" and delay then
        _performWithDelay(...)
        return
    else
        t = _performWithDelay(delay, ...)
    end
    table.insert(activeTimersList, t)
    return t
end

timer.cancelAll = function ()
    for i, t in ipairs(activeTimersList) do
        timer.cancel(t)
    end
    activeTimersList = {}
end

timer.pauseAll = function ()
    for i, t in ipairs(activeTimersList) do
        timer.pause(t)
    end
end

timer.resumeAll = function ()
    for i, t in ipairs(activeTimersList) do
        timer.resume(t)
    end
end