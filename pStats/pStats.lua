local function formats(value)
	if(value > 999) then
		return format('%.1f MiB', value / 1024)
	else
		return format('%.1f KiB', value)
	end
end

local dataobj, elapsed = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject('Stats', {text = '2.0 MiB', icon = [=[Interface\AddOns\pStats\icon]=]}), 0.5

CreateFrame('Frame'):SetScript('OnUpdate', function(self, al)
	elapsed = elapsed + al
	if(elapsed > 0.5) then
		dataobj.text = formats(gcinfo())
		elapsed = 0
	end
end)

function dataobj.OnLeave()
	GameTooltip:SetClampedToScreen(true)
	GameTooltip:Hide()
end

function dataobj.OnEnter(self)
	local db = pStatsDB
	local r, g, b = unpack(db.colors)
	local down, up, latency = GetNetStats()
	local fps = format('%.1f fps', GetFramerate())
	local net = format('%d ms', latency)

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 0, self:GetHeight())
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(fps, net, r, g, b, r, g, b)
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
	GameTooltip:AddDoubleLine('User Addon Memory Usage:', formats(total), r, g, b, r, g, b)
	GameTooltip:AddDoubleLine('Default UI Memory Usage:', formats(gcinfo() - total), r, g, b, r, g, b)
	GameTooltip:AddDoubleLine('Total Memory Usage:', formats(gcinfo()), r, g, b, r, g, b)

	GameTooltip:Show()
end

local function collect(self)

end

function dataobj.OnClick(self, button)
	if(button == "RightButton") then
		local collected = collectgarbage('count')
		collectgarbage('collect')
		dataobj.OnEnter(self)
		GameTooltip:AddLine('\n')
		GameTooltip:AddDoubleLine('Garbage Collected:', formats(collected - collectgarbage('count')))
		GameTooltip:Show()
	else
		if(self:GetName() == 'MiniMapTrackingButton') then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, 'MiniMapTracking', 0, self:GetHeight())
		else
			InterfaceOptionsFrame_OpenToFrame('pStats')
		end
		GameTooltip:Hide()
	end
end

local function OnMouseWheel(self, dir)
	GameTooltip:SetClampedToScreen(false)
	local point, region, pointTo, x, y = GameTooltip:GetPoint()
	if(dir > 0) then
		GameTooltip:SetPoint(point, region, pointTo, x, y + (IsShiftKeyDown() and 30 or 15))
	else
		GameTooltip:SetPoint(point, region, pointTo, x, y - (IsShiftKeyDown() and 30 or 15))
	end
end

MiniMapTrackingButton:EnableMouseWheel()
MiniMapTrackingButton:RegisterForClicks('AnyUp')
MiniMapTrackingButton:SetScript('OnMouseWheel', OnMouseWheel)
MiniMapTrackingButton:SetScript('OnClick', dataobj.OnClick)
MiniMapTrackingButton:SetScript('OnEnter', dataobj.OnEnter)
MiniMapTrackingButton:SetScript('OnLeave', dataobj.OnLeave)