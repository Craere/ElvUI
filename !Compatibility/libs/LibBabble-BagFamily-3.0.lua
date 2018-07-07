local MAJOR_VERSION = "LibBabble-BagFamily-3.0"
local MINOR_VERSION = 90000 + tonumber(string.match("$Revision: 50 $", "%d+"))

if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub("LibBabble-3.0"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local GAME_LOCALE = GetLocale()

lib:SetBaseTranslations {
	["Bag"] = true,
	["Quiver"] = true,
	["Ammo Pouch"] = true,
	["Soul Bag"] = true,
	["Leatherworking Bag"] = true,
	["Herb Bag"] = true,
	["Enchanting Bag"] = true,
	["Engineering Bag"] = true,
	["Mining Bag"] = true,
}

if GAME_LOCALE == "enUS" then
	lib:SetCurrentTranslations(true)
elseif GAME_LOCALE == "deDE" then
	lib:SetCurrentTranslations {
		["Bag"] = "Bag",
		["Quiver"] = "Quiver",
		["Ammo Pouch"] = "Ammo Pouch",
		["Soul Bag"] = "Soul Bag",
		["Leatherworking Bag"] = "Leatherworking Bag",
		["Herb Bag"] = "Herb Bag",
		["Enchanting Bag"] = "Enchanting Bag",
		["Engineering Bag"] = "Engineering Bag",
		["Mining Bag"] = "Mining Bag",
	}
elseif GAME_LOCALE == "frFR" then
	lib:SetCurrentTranslations {
		["Bag"] = "Bag",
		["Quiver"] = "Quiver",
		["Ammo Pouch"] = "Ammo Pouch",
		["Soul Bag"] = "Soul Bag",
		["Leatherworking Bag"] = "Leatherworking Bag",
		["Herb Bag"] = "Herb Bag",
		["Enchanting Bag"] = "Enchanting Bag",
		["Engineering Bag"] = "Engineering Bag",
		["Mining Bag"] = "Mining Bag",
	}
elseif GAME_LOCALE == "zhCN" then
	lib:SetCurrentTranslations {
		["Bag"] = "Bag",
		["Quiver"] = "Quiver",
		["Ammo Pouch"] = "Ammo Pouch",
		["Soul Bag"] = "Soul Bag",
		["Leatherworking Bag"] = "Leatherworking Bag",
		["Herb Bag"] = "Herb Bag",
		["Enchanting Bag"] = "Enchanting Bag",
		["Engineering Bag"] = "Engineering Bag",
		["Mining Bag"] = "Mining Bag",
	}
elseif GAME_LOCALE == "zhTW" then
	lib:SetCurrentTranslations {
		["Bag"] = "Bag",
		["Quiver"] = "Quiver",
		["Ammo Pouch"] = "Ammo Pouch",
		["Soul Bag"] = "Soul Bag",
		["Leatherworking Bag"] = "Leatherworking Bag",
		["Herb Bag"] = "Herb Bag",
		["Enchanting Bag"] = "Enchanting Bag",
		["Engineering Bag"] = "Engineering Bag",
		["Mining Bag"] = "Mining Bag",
	}
elseif GAME_LOCALE == "koKR" then
	lib:SetCurrentTranslations {
		["Bag"] = "Bag",
		["Quiver"] = "Quiver",
		["Ammo Pouch"] = "Ammo Pouch",
		["Soul Bag"] = "Soul Bag",
		["Leatherworking Bag"] = "Leatherworking Bag",
		["Herb Bag"] = "Herb Bag",
		["Enchanting Bag"] = "Enchanting Bag",
		["Engineering Bag"] = "Engineering Bag",
		["Mining Bag"] = "Mining Bag",
	}
elseif GAME_LOCALE == "esES" then
	lib:SetCurrentTranslations {
		["Bag"] = "Bag",
		["Quiver"] = "Quiver",
		["Ammo Pouch"] = "Ammo Pouch",
		["Soul Bag"] = "Soul Bag",
		["Leatherworking Bag"] = "Leatherworking Bag",
		["Herb Bag"] = "Herb Bag",
		["Enchanting Bag"] = "Enchanting Bag",
		["Engineering Bag"] = "Engineering Bag",
		["Mining Bag"] = "Mining Bag",
	}
elseif GAME_LOCALE == "esMX" then
	lib:SetCurrentTranslations {
		["Bag"] = "Bag",
		["Quiver"] = "Quiver",
		["Ammo Pouch"] = "Ammo Pouch",
		["Soul Bag"] = "Soul Bag",
		["Leatherworking Bag"] = "Leatherworking Bag",
		["Herb Bag"] = "Herb Bag",
		["Enchanting Bag"] = "Enchanting Bag",
		["Engineering Bag"] = "Engineering Bag",
		["Mining Bag"] = "Mining Bag",
	}
elseif GAME_LOCALE == "ruRU" then
	lib:SetCurrentTranslations {
		["Bag"] = "Bag",
		["Quiver"] = "Quiver",
		["Ammo Pouch"] = "Ammo Pouch",
		["Soul Bag"] = "Soul Bag",
		["Leatherworking Bag"] = "Leatherworking Bag",
		["Herb Bag"] = "Herb Bag",
		["Enchanting Bag"] = "Enchanting Bag",
		["Engineering Bag"] = "Engineering Bag",
		["Mining Bag"] = "Mining Bag",
	}
else
	error(string.format("%s: Locale %q not supported", MAJOR_VERSION, GAME_LOCALE))
end