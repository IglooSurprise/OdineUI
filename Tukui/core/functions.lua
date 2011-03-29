local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

-- just for creating text
T.SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	return fs
end

if C["datatext"].classcolor then
	local color = RAID_CLASS_COLORS[TukuiDB.myclass]
	T.cStart = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
else
	local r, g, b = unpack(C["datatext"].color)
	T.cStart = ("|cff%.2x%.2x%.2x"):format(r * 255, g * 255, b * 255)
end
T.cEnd = "|r"


T.PP = function(p, obj)
	local TukuiInfoLeft = TukuiInfoLeft
	local TukuiInfoRight = TukuiInfoRight
	
	local bottom = TukuiDataBottom
	local leftsplit = TukuiLeftSplitBarData
	local rightsplit = TukuiRightSplitBarData
	
	if p == 1 then
		obj:SetParent(TukuiInfoLeft)
		obj:Height(TukuiInfoLeft:GetHeight())
		obj:Point("LEFT", TukuiInfoLeft, 20, 1)
	elseif p == 2 then
		obj:SetParent(TukuiInfoLeft)
		obj:Height(TukuiInfoLeft:GetHeight())
		obj:Point("CENTER", TukuiInfoLeft, 0, 1)
	elseif p == 3 then
		obj:SetParent(TukuiInfoLeft)
		obj:Height(TukuiInfoLeft:GetHeight())
		obj:Point("RIGHT", TukuiInfoLeft, -20, 1)
	elseif p == 4 then
		obj:SetParent(TukuiInfoRight)
		obj:Height(TukuiInfoRight:GetHeight())
		obj:Point("LEFT", TukuiInfoRight, 20, 1)
	elseif p == 5 then
		obj:SetParent(TukuiInfoRight)
		obj:Height(TukuiInfoRight:GetHeight())
		obj:Point("CENTER", TukuiInfoRight, 0, 1)
	elseif p == 6 then
		obj:SetParent(TukuiInfoRight)
		obj:Height(TukuiInfoRight:GetHeight())
		obj:Point("RIGHT", TukuiInfoRight, -20, 1)
	end
	
	if p == 7 then
		obj:SetHeight(bottom:GetHeight())
		obj:SetPoint("LEFT", bottom, 20, 0)
		obj:SetPoint('TOP', bottom)
		obj:SetPoint('BOTTOM', bottom)
	elseif p == 8 then
		obj:SetHeight(bottom:GetHeight())
		obj:SetPoint('TOP', bottom)
		obj:SetPoint('BOTTOM', bottom)
	elseif p == 9 then
		obj:SetHeight(bottom:GetHeight())
		obj:SetPoint("RIGHT", bottom, -20, 0)
		obj:SetPoint('TOP', bottom)
		obj:SetPoint('BOTTOM', bottom)
	end
	
	if p == 10 then
		obj:SetHeight(leftsplit:GetHeight() - 10)
		obj:SetWidth(leftsplit:GetWidth() - 15)
		obj:SetPoint('CENTER', leftsplit)
	elseif p == 11 then
		obj:SetHeight(rightsplit:GetHeight() - 10)
		obj:SetWidth(rightsplit:GetWidth() - 15)
		obj:SetPoint('CENTER', rightsplit)
	end
	
end

T.DataTextTooltipAnchor = function(self)
	local panel = self:GetParent()
	local anchor = "ANCHOR_TOP"
	local xoff = 0
	local yoff = T.Scale(3)
	
	if panel == TukuiInfoLeft then
		anchor = "ANCHOR_TOPLEFT"
	elseif panel == TukuiInfoRight then
		anchor = "ANCHOR_TOPRIGHT"
	end
	
	return anchor, panel, xoff, yoff
end

T.TukuiShiftBarUpdate = function()
	local numForms = GetNumShapeshiftForms()
	local texture, name, isActive, isCastable
	local button, icon, cooldown
	local start, duration, enable
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		button = _G["ShapeshiftButton"..i]
		icon = _G["ShapeshiftButton"..i.."Icon"]
		if i <= numForms then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
			icon:SetTexture(texture)
			
			cooldown = _G["ShapeshiftButton"..i.."Cooldown"]
			if texture then
				cooldown:SetAlpha(1)
			else
				cooldown:SetAlpha(0)
			end
			
			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_SetTimer(cooldown, start, duration, enable)
			
			if isActive then
				ShapeshiftBarFrame.lastSelected = button:GetID()
				button:SetChecked(1)
			else
				button:SetChecked(0)
			end

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end

T.TukuiPetBarUpdate = function(self, event)
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton" .. i
		petActionButton = _G[buttonName]
		petActionIcon = _G[buttonName.."Icon"]
		petAutoCastableTexture = _G[buttonName.."AutoCastable"]
		petAutoCastShine = _G[buttonName.."Shine"]
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
		
		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end
		
		petActionButton.isToken = isToken
		petActionButton.tooltipSubtext = subtext

		if isActive and name ~= "PET_ACTION_FOLLOW" then
			petActionButton:SetChecked(1)
			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(petActionButton)
			end
		else
			petActionButton:SetChecked(0)
			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(petActionButton)
			end			
		end
		
		if autoCastAllowed then
			petAutoCastableTexture:Show()
		else
			petAutoCastableTexture:Hide()
		end
		
		if autoCastEnabled then
			AutoCastShine_AutoCastStart(petAutoCastShine)
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
		end
		
		-- grid display
		if name then
			if not C["actionbar"].showgrid then
				petActionButton:SetAlpha(1)
			end			
		else
			if not C["actionbar"].showgrid then
				petActionButton:SetAlpha(0)
			end
		end
		
		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(petActionIcon, nil)
			else
				SetDesaturation(petActionIcon, 1)
			end
			petActionIcon:Show()
		else
			petActionIcon:Hide()
		end
		
		-- between level 1 and 10 on cata, we don't have any control on Pet. (I lol'ed so hard)
		-- Setting desaturation on button to true until you learn the control on class trainer.
		-- you can at least control "follow" button.
		if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
			PetActionButton_StopFlash(petActionButton)
			SetDesaturation(petActionIcon, 1)
			petActionButton:SetChecked(0)
		end
	end
end

-- Define action bar buttons size
T.buttonsize = T.Scale(C.actionbar.buttonsize)
T.petbuttonsize = T.Scale(C.actionbar.petbuttonsize)
T.stancebuttonsize = T.Scale(C.actionbar.stancebuttonsize)
T.buttonspacing = T.Scale(C.actionbar.buttonspacing)

-- Base width of panels
if T.lowversion or C["general"].uiscale > 0.85 then
	T.DataWidth = 300
else
	T.DataWidth = (T.buttonsize * 12) + (T.buttonspacing * 11)
end

T.Round = function(number, decimals)
	if not decimals then decimals = 0 end
    return (("%%.%df"):format(decimals)):format(number)
end

T.RGBToHex = function(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

--Check Player's Role
local RoleUpdater = CreateFrame("Frame")
local function CheckRole(self, event, unit)
	local tree = GetPrimaryTalentTree()
	local resilience
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() then
		resilience = true
	else
		resilience = false
	end
	if ((T.myclass == "PALADIN" and tree == 2) or
	(T.myclass == "WARRIOR" and tree == 3) or
	(T.myclass == "DEATHKNIGHT" and tree == 1)) and
	resilience == false or
	(T.myclass == "DRUID" and tree == 2 and GetBonusBarOffset() == 3) then
		T.Role = "Tank"
	else
		local playerint = select(2, UnitStat("player", 4))
		local playeragi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (((playerap > playerint) or (playeragi > playerint)) and not (T.myclass == "SHAMAN" and tree ~= 1 and tree ~= 3) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139)))) or T.myclass == "ROGUE" or T.myclass == "HUNTER" or (T.myclass == "SHAMAN" and tree == 2) then
			T.Role = "Melee"
		else
			T.Role = "Caster"
		end
	end
end
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)
CheckRole()

--Return short value of a number
function T.ShortValue(v)
	if v >= 1e6 then
		return ("%.1fm"):format(v / 1e6):gsub("%.?0+([km])$", "%1")
	elseif v >= 1e3 or v <= -1e3 then
		return ("%.1fk"):format(v / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return v
	end
end