--[[

 Copyright (c) 2009, Adrian L Lange


--]]

local function classColors()
	local _, enClass = UnitClass('player')
	local colorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[enClass] or RAID_CLASS_COLORS[enClass]
	return colorTable.r, colorTable.g, colorTable.b
end

local function formatValue(value)
	if(value > 999) then
		return string.format('%.1f MiB', value / 1024)
	else
		return string.format('%.1f KiB', value)
	end
end

local function onEnter(self)
	local r, g, b = classColors()
	local _, _, latency = GetNetStats()
	local addons, total = {}, 0

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 0, self:GetHeight())
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(string.format('%01d fps', GetFramerate()), string.format('%d ms', latency), r, g, b, r, g, b)
	GameTooltip:AddLine('\n')

	UpdateAddOnMemoryUsage()

	for index = 1, GetNumAddOns() do
		if(IsAddOnLoaded(index)) then
			local memoryUsage = GetAddOnMemoryUsage(index)
			table.insert(addons, {GetAddOnInfo(index), memoryUsage})
			total = total + memoryUsage
		end
	end

	table.sort(addons, function(a,b) return a[2] > b[2] end)

	for key, value in next, addons do
		GameTooltip:AddDoubleLine(value[1], formatValue(value[2]), 1, 1, 1)
	end

	GameTooltip:AddLine('\n')
	GameTooltip:AddDoubleLine('User AddOn memory usage:', formatValue(total), r, g, b, r, g, b)
	GameTooltip:AddDoubleLine('Default UI memory usage:', formatValue(gcinfo() - total), r, g, b, r, g, b)
	GameTooltip:AddDoubleLine('Total memory usage:', formatValue(gcinfo()), r, g, b, r, g, b)
	GameTooltip:Show()
end

MiniMapTrackingButton:HookScript('OnClick', GameTooltip_Hide)
MiniMapTrackingButton:SetScript('OnEnter', onEnter)