local json = require( "json" )

local storage = {}
local filename = "storage.dat"

function storage.save(data)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if not file then
        return false
    end
    file:write(json.encode(data))
    io.close(file)
    return true
end

function storage.load()
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local file = io.open(path, "r")
    if not file then
        return {}
    end
    local data = file:read("*a")
    io.close(file)
    data = json.decode(data)
    if type(data) ~= "table" then
        data = {}
    end
    return data
end

function storage.clear()
    storage.save({})
end

function storage.set(key, value)
    if not key then
        return false
    end

    local data = storage.load()
    data[key] = value
    return storage.save(data)
end

function storage.get(key, default)
    if not key then
        return false
    end
    local value = storage.load()[key]
    if value == nil then
        value = default
    end
    return value
end

return storage