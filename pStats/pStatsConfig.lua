local db
local _G = getfenv(0)
local LibSimpleOptions = LibStub("LibSimpleOptions-1.0")
local c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

local function Options(self)
	local title, subText = self:MakeTitleTextAndSubText("pStats", "These options allow you to change the looks of pStats")

	local class = self:MakeButton(
		'name', "Class Color",
		'description', "Set text color based on player class",
		'func', function() db.r = c.r db.g = c.g db.b = c.b self:Refresh() end)
	class:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 0, -8)

	local custom = self:MakeColorPicker(
		'name', "Custom Color",
		'description', "Set custom text colors with a palette",
		'hasAlpha', false,
		'defaultR', 0,
		'defaultG', 1,
		'defaultB', 1,
		'getFunc', function() return db.r, db.g, db.b end,
		'setFunc', function(r, g, b) db.r = r db.g = g db.b = b end)
	custom:SetPoint("TOPLEFT", class, "BOTTOMLEFT", 0, -8)

	local help = self:MakeToggle(
		'name', "Toggle Help Lines",
		'description', "Set whether the 3 help lines in the tooltip are shown or not",
		'default', true,
		'current', db.help,
		'setFunc', function(value) db.help = value end)
	help:SetPoint("TOPLEFT", custom, "BOTTOMLEFT", 0, -8)
end

local function OnEvent(self, name)
	if(name == "pStats") then
		db = _G.pStatsDB
		if(not db) then
			db = { r = 0, g = 1, b = 1, help = true }
			_G.pStatsDB = db
		end

		-- setup options
		LibSimpleOptions.AddOptionsPanel("pStats", Options)
		LibSimpleOptions.AddSlashCommand("pStats", "/pstats")

		self:UnregisterEvent("ADDON_LOADED")
	end
end

local event = CreateFrame("Frame")
event:RegisterEvent("ADDON_LOADED")
event:SetScript("OnEvent", function(self, event, ...) OnEvent(self, ...) end)