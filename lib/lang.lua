lang = {}

local DEFAULT_LOCALE = "english"
local activeLocale = {}
local activeLocaleName = ""

local languageNames = {
    ru_RU = "russian",
    uk_UA = "russian",
    be_BY = "russian"
}

function lang.getString(name)
    if type(name) ~= "string" then
        error("Expected string got " .. tostring(type(name)))
    end
    if activeLocale[name] then
        return activeLocale[name]
    else
        DEBUG.Log("Missing string '%s' for locale '%s'", tostring(name), tostring(activeLocaleName))
        return name
    end
end

function lang.setLang(name)
    activeLocale = require("locales."..tostring(name))
    activeLocaleName = name
    if not activeLocale then
        activeLocale = require("locales." .. DEFAULT_LOCALE)
        activeLocaleName = DEFAULT_LOCALE
    end
    DEBUG.Log("Loaded locale '%s'", activeLocaleName)
end

function lang.init()
    local name = system.getPreference("locale", "identifier")
    if type(name) == "string" and languageNames[name] then
        lang.setLang(languageNames[name])
    else
        lang.setLang(DEFAULT_LOCALE)
    end
end