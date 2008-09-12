local function formats(value)
	if(value > 999) then
		return format('%.1f MiB', value / 1024)
	else
		return format('%.1f KiB', value)
	end
end

local function OnEnter(self)
	local db = _G.pStatsDB
	local down, up, latency = GetNetStats()
	local fps = format('%.1f fps', GetFramerate())
	local net = format('%d ms', latency)

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 0, self:GetHeight())
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(fps, net, db.r, db.g, db.b, db.r, db.g, db.b)
	GameTooltip:AddLine('\n')

	local addons, entry, total = {}, {}, 0
	UpdateAddOnMemoryUsage()

	for i = 1, GetNumAddOns() do
		if(IsAddOnLoaded(i)) then
			entry = {GetAddOnInfo(i), GetAddOnMemoryUsage(i)}
			table.insert(addons, entry)
			total = total + GetAddOnMemoryUsage(i)
		end
	end

	if(db.sorted) then
		table.sort(addons, (function(a, b) return a[2] > b[2] end))
	end

	for i,entry in pairs(addons) do
		GameTooltip:AddDoubleLine(entry[1], formats(entry[2]), 1, 1, 1)
	end

	GameTooltip:AddLine('\n')
	GameTooltip:AddDoubleLine('User Addon Memory Usage:', formats(total), db.r, db.g, db.b, db.r, db.g, db.b)
	GameTooltip:AddDoubleLine('Default UI Memory Usage:', formats(gcinfo() - total), db.r, db.g, db.b, db.r, db.g, db.b)
	GameTooltip:AddDoubleLine('Total Memory Usage:', formats(gcinfo()), db.r, db.g, db.b, db.r, db.g, db.b)

	GameTooltip:Show()
end

local function OnClick(self, button)
	if(button == "RightButton") then
		local collected = collectgarbage('count')
		collectgarbage('collect')
		OnEnter(self)
		GameTooltip:AddLine('')
		GameTooltip:AddDoubleLine('Garbage Collected:', formats(collected - collectgarbage('count')))
		GameTooltip:Show()
	else
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, 'MiniMapTracking', 0, self:GetHeight())
		GameTooltip:Hide()
	end
end

local function OnMouseWheel(self, dir)
	GameTooltip:SetClampedToScreen(false)
	local point, region, pointTo, x, y = GameTooltip:GetPoint()
	if(dir > 0) then
		if(IsShiftKeyDown()) then
			GameTooltip:SetPoint(point, region, pointTo, x, y + 30)
		else
			GameTooltip:SetPoint(point, region, pointTo, x, y + 15)
		end
	else
		if(IsShiftKeyDown()) then
			GameTooltip:SetPoint(point, region, pointTo, x, y - 30)
		else
			GameTooltip:SetPoint(point, region, pointTo, x, y - 15)
		end
	end
end

local wotlk = select(4, GetBuildInfo()) >= 3e4
if(wotlk) then
	MiniMapTrackingButton:RegisterForClicks('AnyUp')
	MiniMapTrackingButton:SetScript('OnClick', OnClick)
	MiniMapTrackingButton:EnableMouseWheel(true)
	MiniMapTrackingButton:SetScript('OnMouseWheel', OnMouseWheel)
	MiniMapTrackingButton:SetScript('OnEnter', OnEnter)
	MiniMapTrackingButton:SetScript('OnLeave', function()
		GameTooltip:SetClampedToScreen(true)
		GameTooltip:Hide()
	end)
else
	MiniMapTracking:SetScript('OnMouseUp', OnClick)
	MiniMapTracking:EnableMouseWheel(true)
	MiniMapTracking:SetScript('OnMouseWheel', OnMouseWheel)
	MiniMapTracking:SetScript('OnEnter', OnEnter)
	MiniMapTracking:SetScript('OnLeave', function()
		GameTooltip:SetClampedToScreen(true)
		GameTooltip:FadeOut()
	end)
end