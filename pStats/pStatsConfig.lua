local db
local _G = getfenv(0)
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

	local sortcheck = self:MakeToggle(
		'name', "Toggle sorting method",
		'description', "Check to sort by memory.\nUn-check to sort by name",
		'default', true,
		'current', db.sorted,
		'setFunc', function(value) db.sorted = value end)
	sortcheck:SetPoint("TOPLEFT", custom, "BOTTOMLEFT", 0, -8)
end

local function OnEvent(self, name)
	if(name == "pStats") then
		db = _G.pStatsDB
		if(not db) then
			db = { r = 0, g = 1, b = 1, sorted = true }
			_G.pStatsDB = db
		end

		-- setup options
		LibStub("LibSimpleOptions-1.0").AddOptionsPanel("pStats", Options)
		LibStub("LibSimpleOptions-1.0").AddSlashCommand("pStats", "/pstats")

		self:UnregisterEvent("ADDON_LOADED")
	end
end

local event = CreateFrame("Frame")
event:RegisterEvent("ADDON_LOADED")
event:SetScript("OnEvent", function(self, event, ...) OnEvent(self, ...) end)