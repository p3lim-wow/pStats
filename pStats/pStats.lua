local function compare(a, b) return a.memory > b.memory end
local function formats(num)
	if(num > 999) then
		return format("%.1f MiB", num / 1024)
	else
		return format("%.1f KiB", num)
	end
end

local function ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	
	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end


local function GarbageTooltip_Show(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, self:GetHeight())
	GameTooltip:AddLine("Garbage collected!")
	GameTooltip:Show()
end

local function OnMouseUp(self, button)
	if(GameTooltip:GetOwner() == self) then GameTooltip:Hide() end
	if(button == "RightButton") then
		GarbageTooltip_Show(self)
		collectgarbage("collect")
	elseif(button == "MiddleButton") then
		GameTimeFrame_OnClick()
	else
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "MiniMapTracking", 0, self:GetHeight())
	end
end

local function OnEnter(self)
	local db = _G.pStatsDB
	local fps = format("%d fps", floor(GetFramerate()))
	local net = format("%d ms", select(3, GetNetStats()))

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, self:GetHeight())
	GameTooltip:AddDoubleLine(fps, net, db.r, db.g, db.b, db.r, db.g, db.b)
	GameTooltip:AddLine("\n")

	local addons, entry, total = {}, {}, 0
	UpdateAddOnMemoryUsage()

	-- todo: mem color by gradient green-yellow-red
	for i = 1, GetNumAddOns(), 1 do
		if IsAddOnLoaded(i) then
			entry = {name = GetAddOnInfo(i), memory = GetAddOnMemoryUsage(i)}
			table.insert(addons, entry)
			total = total + GetAddOnMemoryUsage(i)
		end
	end

	if(db.sorted) then
		table.sort(addons, compare)
	end

	for _,entry in pairs(addons) do
		local r, g, b = ColorGradient((entry.memory / 800), 0, 1, 0, 1, 1, 0, 1, 0, 0)
		GameTooltip:AddDoubleLine(entry.name, formats(entry.memory), 1, 1, 1, r, g, b)
	end

	GameTooltip:AddLine("\n")
	GameTooltip:AddDoubleLine("Total", formats(total), db.r, db.g, db.b, db.r, db.g, db.b)
	GameTooltip:AddDoubleLine("Total w/Blizzard", formats(gcinfo()), db.r, db.g, db.b, db.r, db.g, db.b)

	if(db.help) then
		GameTooltip:AddLine("\n")
		GameTooltip:AddLine("Middle-Click to toggle time settings")
		GameTooltip:AddLine("Right-Click to force garbage collection")
		GameTooltip:AddLine("Left-Click to choose tracking type")
	end

	GameTooltip:Show()
end

-- hijack the MiniMapTracking frame
MiniMapTracking:SetScript("OnMouseUp", OnMouseUp)
MiniMapTracking:SetScript("OnEnter", OnEnter)