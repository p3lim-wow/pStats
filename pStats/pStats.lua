local function GetClassColors()
	local _, enClass = UnitClass('player')
	local colorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[enClass] or RAID_CLASS_COLORS[enClass]

	return colorTable.r, colorTable.g, colorTable.b
end

local function ReformatValue(value)
	if(value > 999) then
		return string.format('%.1f MiB', value / 1024)
	else
		return string.format('%.1f KiB', value)
	end
end

local function OnEnter(self)
	local r, g, b = GetClassColors()
	local _, _, latency = GetNetStats()
	local addons, total = {}, 0

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 0, self:GetHeight())
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(string.format('%.1f fps', GetFramerate()), string.format('%d ms', latency), r, g, b, r, g, b)
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
		GameTooltip:AddDoubleLine(value[1], ReformatValue(value[2]), 1, 1, 1)
	end

	GameTooltip:AddLine('\n')
	GameTooltip:AddDoubleLine('User AddOn memory usage:', ReformatValue(total), r, g, b, r, g, b)
	GameTooltip:AddDoubleLine('Default UI memory usage:', ReformatValue(gcinfo() - total), r, g, b, r, g, b)
	GameTooltip:AddDoubleLine('Total memory usage:', ReformatValue(gcinfo()), r, g, b, r, g, b)
	GameTooltip:Show()
end

local function OnClick(self)
	if(GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end

	ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, 'MiniMapTracking')
end

MiniMapTrackingButton:SetScript('OnClick', OnClick)
MiniMapTrackingButton:SetScript('OnEnter', OnEnter)