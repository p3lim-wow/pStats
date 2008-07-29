local function compare(a, b) return a.mem > b.mem end
local function formats(num)
	if(num > 999) then
		return format("%.1f MiB", num / 1024)
	else
		return format("%.1f KiB", num)
	end
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

	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			entry = {name = GetAddOnInfo(i), mem = GetAddOnMemoryUsage(i)}
			table.insert(addons, entry)
			total = total + GetAddOnMemoryUsage(i)
		end
	end

	if(db.sorted) then
		table.sort(addons, compare)
	end

	for _,entry in pairs(addons) do
		GameTooltip:AddDoubleLine(entry.name, format("|cff%s%s|r", LibStub("LibCrayon-3.0"):GetThresholdHexColor(entry.mem, 1024, 640, 320, 180, 0), formats(entry.mem)), 1, 1, 1)
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