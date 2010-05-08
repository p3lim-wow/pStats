--[[

	Copyright (c) 2009-2010, Adrian L Lange
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local class = select(2, UnitClass('player'))

local function FormattedLatency()
	local _, _, latency = GetNetStats()
	if(latency > PERFORMANCEBAR_MEDIUM_LATENCY) then
		return latency, 1, 0, 0
	elseif(latency > PERFORMANCEBAR_LOW_LATENCY) then
		return latency, 1, 1, 0
	else
		return latency, 0, 1, 0
	end
end

local function FormatValue(value)
	if(value > 1e3) then
		return string.format('%.1f |cffff0000m|r', value / 1024)
	else
		return string.format('%d |cff00ff00k|r', value)
	end
end

MiniMapTrackingButton:SetScript('OnEnter', function(self)
	local colors = RAID_CLASS_COLORS[class]
	local latency, r, g, b = FormattedLatency()
	local total = 0

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
	GameTooltip:AddDoubleLine(date('%a %d %b'), string.format('%d', latency), colors.r, colors.g, colors.b, r, g, b)
	GameTooltip:AddLine('\n')

	UpdateAddOnMemoryUsage()
	for index = 1, GetNumAddOns() do
		if(IsAddOnLoaded(index)) then
			local usage = GetAddOnMemoryUsage(index)
			GameTooltip:AddDoubleLine(GetAddOnInfo(index), FormatValue(usage), 1, 1, 1)
			total = total + usage
		end
	end

	GameTooltip:AddLine('\n')
	GameTooltip:AddDoubleLine('Total Usage:', FormatValue(total), colors.r, colors.g, colors.b)
	GameTooltip:Show()
end)
