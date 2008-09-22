local function CreateOptions(self, db)
	local title, sub = self:MakeTitleTextAndSubText('pStats', 'These options allow you to customize the looks of pStats.')
	
	self:MakeButton(
		'name', 'Class Color',
		'description', 'Set text color based on player class',
		'func', function()
			local l, class = UnitClass('player')
			local c = RAID_CLASS_COLORS[class]
			db.colors[1], db.colors[2], db.colors[3] = c.r, c.g, c.b
			self:Refresh()
		end
	):SetPoint('TOPLEFT', sub, 'BOTTOMLEFT', 0, -16)

	self:MakeColorPicker(
		'name', 'Custom Color',
		'description', 'Set custom text colors with a palette',
		'hasAlpha', false,
		'defaultR', 0, 'defaultG', 1, 'defaultB', 1,
		'getFunc', function() return unpack(db.colors) end,
		'setFunc', function(r, g, b)
			db.colors[1], db.colors[2], db.colors[3] = r, g, b
		end
	):SetPoint('TOPLEFT', sub, 'BOTTOMLEFT', 0, -46)

	self:MakeToggle(
		'name', 'Toggle sorting method',
		'description', 'Check to sort by memory.\nUn-check to sort by name',
		'default', true,
		'current', db.sorted,
		'setFunc', function(value)
			db.sorted = value
		end
	):SetPoint('TOPLEFT', sub, 'BOTTOMLEFT', 0, -76)
end

local function OnEvent(self, event)
	local db = pStatsDB or {colors = {0, 1, 1}, sorted = true}

	LibStub('LibSimpleOptions-1.0').AddOptionsPanel('pStats', function(self) CreateOptions(self, db) end)
	LibStub('LibSimpleOptions-1.0').AddSlashCommand('pStats', '/pstats')

	self:UnregisterEvent(event)

	pStatsDB = db
end

local addon = CreateFrame('Frame')
addon:RegisterEvent('PLAYER_ENTERING_WORLD')
addon:SetScript('OnEvent', OnEvent)