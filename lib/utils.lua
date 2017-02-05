local utils = {}

function utils.vectorLength(x, y)
    return math.sqrt(x * x + y * y)
end

function utils.clamp(val, min, max)
    return math.min(max, math.max(val, min))
end

return utils