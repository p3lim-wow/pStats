--[[

	Copyright (c) 2009, Adrian L Lange
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local playerClass = select(2, UnitClass('player'))

local function classColors()
	local colorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[playerClass] or RAID_CLASS_COLORS[playerClass]
	return colorTable.r, colorTable.g, colorTable.b
end

local function lagColors(value)
	if(value < 1e2) then
		return 0, 1, 0
	elseif(value < 3e2) then
		return 1, 1, 0
	else
		return 1, 0, 0
	end
end

local function formatValue(value)
	if(value > 1e3) then
		return string.format('%.1f m', value / 1024)
	else
		return string.format('%d k', value)
	end
end

local usage
local addons = {}
local total = 0

MiniMapTrackingButton:SetScript('OnEnter', function(self)
	local r, g, b = classColors()
	local _, _, lag = GetNetStats()
	local lagR, lagG, lagB = lagColors(lag)

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 0, self:GetHeight())
	GameTooltip:AddDoubleLine(date('%a %d %b'), string.format('%d', lag), r, g, b, lagR, lagG, lagB)
	GameTooltip:AddLine('\n')

	total = 0
	table.wipe(addons)

	UpdateAddOnMemoryUsage()
	for index = 1, GetNumAddOns() do
		if(IsAddOnLoaded(index)) then
			usage = GetAddOnMemoryUsage(index)
			table.insert(addons, {GetAddOnInfo(index), usage})
			total = total + usage
		end
	end

	table.sort(addons, function(a,b) return a[2] > b[2] end)

	for _, addon in pairs(addons) do
		GameTooltip:AddDoubleLine(addon[1], formatValue(addon[2]), 1, 1, 1)
	end

	GameTooltip:AddLine('\n')
	GameTooltip:AddDoubleLine('Total Usage:', formatValue(total), r, g, b, r, g, b)
	GameTooltip:Show()
end)
