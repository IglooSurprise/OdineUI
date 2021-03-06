local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

if not C["unitframes"].enable == true then return end


if T.lowversion then
	T.Player, T.Target, T.ToT, T.Pet, T.Focus, T.Boss = 200, 200, 130, 130, 130, 200
else
	T.Player, T.Target, T.ToT, T.Pet, T.Focus, T.Boss = 215, 215, 130, 130, 130, 200
end

local font, fonts, fontf = C["media"].uffont, 14, "THINOUTLINE"

------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local normTex = C["media"].normTex
local glowTex = C["media"].glowTex

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	-- set our own colors
	self.colors = T.oUF_colors
	
	-- register click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- menu? lol
	self.menu = T.SpawnMenu
	
	------------------------------------------------------------------------
	--	Features we want for all units at the same time
	------------------------------------------------------------------------
	
	-- here we create an invisible frame for all element we want to show over health/power.
	local InvFrame = CreateFrame("Frame", nil, self)
	InvFrame:SetFrameStrata("MEDIUM")
	InvFrame:SetFrameLevel(50)
	InvFrame:SetAllPoints()
	
	-- symbols, now put the symbol on the frame we created above.
	if unit ~= party then
		local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		RaidIcon:Size(18, 18)
		RaidIcon:SetPoint("TOP", 0, 11)
		self.RaidIcon = RaidIcon
	end

	------------------------------------------------------------------------
	--	Player and Target units layout
	------------------------------------------------------------------------
	
	if (unit == "player" or unit == "target") then	
		-- health
		local health = CreateFrame('StatusBar', nil, self)
		health:SetFrameLevel(5)
		health:Height(30)
		health:SetPoint("TOPLEFT", T.mult, -T.mult)
		health:SetPoint("TOPRIGHT", -T.mult, T.mult)
		health:SetStatusBarTexture(C["media"].normTex)
		health:GetStatusBarTexture():SetHorizTile(false)
		self.Health = health
		
		local healthBg = health:CreateTexture(nil, "BORDER")
		healthBg:SetAllPoints()
		healthBg:SetTexture(unpack(C["unitframes"].healthBgColor))
		self.Health.bg = healthBg
		
		local healthB = CreateFrame("Frame", nil, health)
		healthB:SetFrameLevel(health:GetFrameLevel() - 1)
		healthB:Point("TOPLEFT", -2, 2)
		healthB:Point("BOTTOMRIGHT", 2, -2)
		healthB:SetTemplate("Default")
		healthB:CreateShadow("Default")
		self.Health.border = healthB
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(10)
		power:SetPoint("TOPLEFT", healthB, "BOTTOMLEFT", T.Scale(2), -T.Scale(6))
		power:SetPoint("TOPRIGHT", healthB, "BOTTOMRIGHT", T.Scale(-2), -T.Scale(6))
		power:SetStatusBarTexture(normTex)
		power:GetStatusBarTexture():SetHorizTile(false)
		self.Power = power
		
		local powerBg = power:CreateTexture(nil, "BORDER")
		powerBg:SetAllPoints()
		powerBg:SetTexture(unpack(C["unitframes"].healthBgColor))
		powerBg.multiplier = 0.3
		self.Power.bg = powerBg
		
		local powerB = CreateFrame("Frame", nil, power)
		powerB:SetFrameLevel(power:GetFrameLevel() - 1)
		powerB:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(3))
		powerB:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-3))
		powerB:SetTemplate("Default")
		powerB:CreateShadow("Default")
		self.Power.border = powerB	
		
		-- create a panel
		local panel = CreateFrame("Frame", nil, self)
		panel:CreatePanel("Default", 1, 20, "BOTTOM", self, "BOTTOM", 0, 0)
		panel:SetFrameLevel(self.Health:GetFrameLevel())
		panel:ClearAllPoints()
		panel:SetPoint("BOTTOMLEFT", healthB, "TOPLEFT", 0, T.Scale(3))
		panel:SetPoint("BOTTOMRIGHT", healthB, "TOPRIGHT", 0, T.Scale(3))
		self.panel = panel

		-- portraits
		if (C["unitframes"].charportrait == true) then
			local portrait = CreateFrame("PlayerModel", self:GetName().."_Portrait", self)
		    portrait.parent = panel
			portrait:SetFrameLevel(panel:GetFrameLevel() + 1)
		    portrait:SetPoint("TOPLEFT", panel, "TOPLEFT", 2, -2)
		    portrait:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -2, 2)
			table.insert(self.__elements, T.HidePortrait)
			portrait.PostUpdate = T.PortraitUpdate --Worgen Fix (Hydra)
      
				portrait.PostUpdate = function(self) -- hide the portrait partionally for a cool effect
				self:SetAlpha(0) 
				self:SetAlpha(0.25)       
			end
			self.Portrait = portrait
		end
		
		health.frequentUpdates = true
		power.frequentUpdates = true
		
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
			power.Smooth = true
		end
		
		if C["general"].classcolortheme ~= true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthColor))
			health.bg:SetTexture(1, 1, 1)
			health.bg:SetVertexColor(unpack(C["unitframes"].healthBgColor))
			
			power.colorTapping = true
			power.colorDisconnected = true
			power.colorClass = true
			power.colorReaction = true
			power.bg.multiplier = 0.1
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
			
			power.colorPower = true
		end
		
		health.value = T.SetFontString(health, font, fonts, fontf)
		health.value:Point("RIGHT", panel, "RIGHT", -4, 0)
    
		if C["unitframes"].percentage == true then
			health.percent = T.SetFontString(health, font, health:GetHeight(), fontf)
			if unit == "player" then
				health.percent:Point("RIGHT", health, "LEFT", -6, 0)
				health.percent:SetShadowOffset(2, -2)
			elseif unit == "target" then
				health.percent:Point("LEFT", health, "RIGHT", 6, 0)
				health.percent:SetShadowOffset(-2, -2)
			end
		end
			
		health.PostUpdate = T.PostUpdateHealth
		
		power.value = T.SetFontString(panel, font, fonts, fontf)
		power.value:Point("LEFT", self.panel, "LEFT", 4, 0)

		if C["unitframes"].percentage == true then
			power.percent = T.SetFontString(panel, font, panel:GetHeight(), fontf)
			if unit == "player" then
				power.percent:Point("RIGHT", panel, "LEFT", -6, 0)
				power.percent:SetShadowOffset(1, -1)
			elseif unit == "target" then
				power.percent:Point("LEFT", panel, "RIGHT", 6, 0)
				power.percent:SetShadowOffset(-1, -1)
			end
		end
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
		
		if T.myclass == "PRIEST" and C["unitframes"].weakenedsoulbar then
			local ws = CreateFrame("StatusBar", self:GetName().."_WeakenedSoul", power)
			ws:SetAllPoints(power)
			ws:SetStatusBarTexture(normTex)
			ws:GetStatusBarTexture():SetHorizTile(false)
			ws:SetBackdrop(backdrop)
			ws:SetBackdropColor(unpack(C.media.backdropcolor))
			ws:SetStatusBarColor(191/255, 10/255, 10/255)
			
			self.WeakenedSoul = ws
		end
					
		if (unit == "player") then		
			-- combat icon
			local Combat = health:CreateTexture(nil, "OVERLAY")
			Combat:Height(25/1.25)
			Combat:Width(25/1.25)
			Combat:SetPoint("TOPRIGHT", 2, 8)
			Combat:SetVertexColor(0.69, 0.31, 0.31)
			self.Combat = Combat
			
			-- resting icon
			local Resting = health:CreateTexture(nil, "OVERLAY")
			Resting:SetHeight(25/1.5)
			Resting:SetWidth(25/1.5)
			Resting:SetPoint("CENTER", 0, 12)
			Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
			Resting:SetTexCoord(0, 0.5, 0, 0.421875)
			self.Resting = Resting

			-- custom info (low mana warning)
			FlashInfo = CreateFrame("Frame", "TukuiFlashInfo", self)
			FlashInfo:SetScript("OnUpdate", T.UpdateManaLevel)
			FlashInfo.parent = self
			FlashInfo:SetAllPoints(panel)
			FlashInfo.ManaLevel = T.SetFontString(FlashInfo, font, fonts, fontf)
			FlashInfo.ManaLevel:SetPoint("CENTER", panel, "CENTER", 0, 0)
			self.FlashInfo = FlashInfo
			
			-- pvp status text
			local status = T.SetFontString(panel, font, fonts, fontf)
			status:SetPoint("CENTER", panel, "CENTER", 0, 0)
			status:SetTextColor(0.69, 0.31, 0.31, 0)
			self.Status = status
			self:Tag(status, "[pvp]")
			
			-- leader icon
			local Leader = InvFrame:CreateTexture(nil, "OVERLAY")
			Leader:Height(25/2)
			Leader:Width(25/2)
			Leader:Point("TOPLEFT", 2, 8)
			self.Leader = Leader
			
			-- master looter
			local MasterLooter = InvFrame:CreateTexture(nil, "OVERLAY")
			MasterLooter:Height(25/2)
			MasterLooter:Width(25/2)
			self.MasterLooter = MasterLooter
			self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)
			
			-- Vengeance Bar			
			if C["unitframes"].vengeance then
				local Vengeance = CreateFrame("StatusBar", self:GetName()..'_Vengeance', TukuiBottomStats)
				Vengeance:SetFrameStrata("TOOLTIP")
				Vengeance:SetFrameLevel(20)
				Vengeance:Point("TOPLEFT", TukuiBottomStats, 2, -2)
				Vengeance:Point("BOTTOMRIGHT", TukuiBottomStats, -2, 2)
				Vengeance:SetStatusBarTexture(normTex)
				Vengeance:GetStatusBarTexture():SetHorizTile(false)
				Vengeance:SetStatusBarColor(unpack(C["unitframes"].healthBgColor))
				Vengeance:SetTemplate("Default", true)
				Vengeance:SetBackdropBorderColor(0, 0, 0, 0)
				Vengeance.Text = T.SetFontString(Vengeance, font, fonts, fontf)
				Vengeance.Text:SetPoint("CENTER")
				self.Vengeance = Vengeance
			end
			
			-- Swing Bar				
			if C["unitframes"].swingbar == true then
				local Swing = CreateFrame("StatusBar", self:GetName().."_SwingBar", TukuiMainMenuBar)
				Swing:SetPoint("BOTTOMLEFT", TukuiMainMenuBar, "TOPLEFT", T.Scale(2), T.Scale(T.buttonsize+6))
				Swing:SetPoint("BOTTOMRIGHT", TukuiMainMenuBar, "TOPRIGHT", T.Scale(-2), T.Scale(T.buttonsize+6))
				Swing:SetHeight(T.Scale(4))
				Swing:SetStatusBarTexture(C["media"].normTex)
				Swing:GetStatusBarTexture():SetHorizTile(false)
				Swing:SetStatusBarColor(unpack(C["unitframes"].healthBgColor))
				
				--local c = T.oUF_colors.class[T.myclass]
				--Swing:SetStatusBarColor(c[1], c[2], c[3])

				self.Swing = Swing
				self.Swing.bg = CreateFrame("Frame", nil, self.Swing)
				self.Swing.bg:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(2))
				self.Swing.bg:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				self.Swing.bg:SetFrameStrata("BACKGROUND")
				self.Swing.bg:SetFrameLevel(Swing:GetFrameLevel() - 1)
				self.Swing.bg:SetTemplate("Default", true)
				
				self.Swing.disableMelee = false
				self.Swing.disableRanged = false
				self.Swing.hideOoc = true
				
				-- sigh hacks to hide swingbar when OOC
				local ChatCombatHider = CreateFrame("Frame")
				ChatCombatHider:RegisterEvent("PLAYER_REGEN_ENABLED")
				ChatCombatHider:RegisterEvent("PLAYER_REGEN_DISABLED")
				ChatCombatHider:RegisterEvent("PLAYER_ENTERING_WORLD")
				ChatCombatHider:SetScript("OnEvent", function(self, event)
					if event == "PLAYER_REGEN_ENABLED" then
						Swing:Hide()
					elseif event == "PLAYER_ENTERING_WORLD" then
						Swing:Hide()
					else
						Swing:Show()
					end
				end)
			end
			
			-- show druid mana when shapeshifted in bear, cat or whatever
			if T.myclass == "DRUID" then
				CreateFrame("Frame"):SetScript("OnUpdate", function() T.UpdateDruidMana(self) end)
				local DruidMana = T.SetFontString(health, font, fonts, fontf)
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
			end
			
			if C["unitframes"].classbar then
				if T.myclass == "DRUID" then			
					local eclipseBar = CreateFrame('Frame', nil, self)
					eclipseBar:Point("LEFT", panel, "TOPLEFT", 10, 5)
					if T.lowversion then
						eclipseBar:Size(102, 6)
					else
						eclipseBar:Size(150, 6)
					end
					eclipseBar:SetBackdropBorderColor(0,0,0,0)
					eclipseBar:SetScript("OnShow", function() T.EclipseDisplay(self, false) end)
					eclipseBar:SetScript("OnUpdate", function() T.EclipseDisplay(self, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
					eclipseBar:SetScript("OnHide", function() T.EclipseDisplay(self, false) end)
					eclipseBar:SetFrameLevel(panel: GetFrameLevel() + 2)
					eclipseBar:SetFrameStrata(panel:GetFrameStrata())

					local eclipseBarBG = CreateFrame("Frame", nil, eclipseBar)
					eclipseBarBG:CreatePanel("Default", 1, 1, "TOPLEFT", -2, 2)
					eclipseBarBG:Point("BOTTOMRIGHT", 2, -2)
					eclipseBarBG:SetFrameLevel(eclipseBar: GetFrameLevel())
					eclipseBarBG:SetFrameStrata(eclipseBar:GetFrameStrata())
					eclipseBarBG.shadow:SetFrameStrata("BACKGROUND")

					local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
					lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
					lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					lunarBar:SetStatusBarTexture(normTex)
					lunarBar:SetStatusBarColor(.30, .52, .90)
					eclipseBar.LunarBar = lunarBar

					local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
					solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
					solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					solarBar:SetStatusBarTexture(normTex)
					solarBar:SetStatusBarColor(.80, .82,  .60)
					eclipseBar.SolarBar = solarBar
					
					local eclipseBarText = eclipseBar:CreateFontString(nil, 'OVERLAY')
					eclipseBarText:SetPoint('TOP', panel)
					eclipseBarText:SetPoint('BOTTOM', panel)
					eclipseBarText:SetFont(font, fonts, fontf)
					eclipseBar.PostUpdatePower = T.EclipseDirection
					
					-- hide "low mana" text on load if eclipseBar is show
					if eclipseBar and eclipseBar:IsShown() then FlashInfo.ManaLevel:SetAlpha(0) end

					self.EclipseBar = eclipseBar
					self.EclipseBar.Text = eclipseBarText
				end

				-- set holy power bar or shard bar
				if (T.myclass == "WARLOCK" or T.myclass == "PALADIN") then		
					local bars = CreateFrame("Frame", nil, self)
					bars:CreatePanel("Default", 150, 9, "LEFT", panel, "TOPLEFT", 10, 5)
					if T.lowversion then
						bars:Width(102)
					end
					bars:SetFrameLevel(panel: GetFrameLevel() + 2)
					bars:SetFrameStrata(panel:GetFrameStrata())
					bars.shadow:SetFrameStrata("BACKGROUND")
					
					for i = 1, 3 do					
						bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
						bars[i]:Height(bars:GetHeight() - 4)
						bars[i]:Width(bars:GetWidth() / 3 - 2)
						
						bars[i]:SetStatusBarTexture(normTex)
						bars[i]:GetStatusBarTexture():SetHorizTile(false)
						bars[i]:SetFrameLevel(bars:GetFrameLevel())
						bars[i]:SetFrameStrata(bars:GetFrameStrata())
						
						bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
						bars[i].bg:SetAllPoints(bars[i])
						bars[i].bg:SetTexture(normTex)					
						bars[i].bg:SetAlpha(.15)

						if T.myclass == "WARLOCK" then
							bars[i]:SetStatusBarColor(255/255,163/255,255/255)
							bars[i].bg:SetTexture(255/255,163/255,255/255)
						elseif T.myclass == "PALADIN" then
							bars[i]:SetStatusBarColor(255/255,253/255,173/255)
							bars[i].bg:SetTexture(255/255,253/255,173/255)
						end
						
						if i == 1 then
							bars[i]:SetPoint("TOPLEFT", bars, 2, -2)
						else
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", 1, 0)
						end
					end
					
					if T.myclass == "WARLOCK" then
						bars.Override = T.UpdateShards				
						self.SoulShards = bars
					elseif T.myclass == "PALADIN" then
						bars.Override = T.UpdateHoly
						self.HolyPower = bars
					end
				end

				-- deathknight runes
				if T.myclass == "DEATHKNIGHT" then
					local Runes = CreateFrame("Frame", nil, self)
					local rB = CreateFrame("Frame", nil, self)
					for i = 1, 6 do
						rB[i] = CreateFrame("Frame", nil, self)
						rB[i]:Height(10)
						rB[i]:SetWidth((T.Player + 7) / 6)
						rB[i]:SetFrameLevel(health:GetFrameLevel() + 1)
						
						if (i == 1) then
							rB[i]:SetPoint("BOTTOMLEFT", self.panel, "TOPLEFT", 0, 2)
						else
							rB[i]:SetPoint("TOPLEFT", rB[i-1], "TOPRIGHT", -T.mult, 0)
						end

						Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
						Runes[i]:Point("TOPLEFT", rB[i], "TOPLEFT", 2, -2)
						Runes[i]:Point("BOTTOMRIGHT", rB[i], "BOTTOMRIGHT", -2, 2)
						Runes[i]:SetFrameLevel(health:GetFrameLevel() + 2)
						Runes[i]:SetStatusBarTexture(normTex)			
						Runes[i]:GetStatusBarTexture():SetHorizTile(false)
												
						rB[i]:SetTemplate("Default", true)
						rB[i]:CreateShadow("Default")
					end
					
					self.Runes = Runes
				end
				
				-- shaman totem bar
				if T.myclass == "SHAMAN" and not IsAddOnLoaded("TotemTimers") then					
					local TotemBar = {}
					local tB = CreateFrame("Frame", nil, self)
					TotemBar.Destroy = true
					for i = 1, 4 do
						tB[i] = CreateFrame("Frame", nil, self)
						tB[i]:SetFrameLevel(health:GetFrameLevel() + 1)
						tB[i]:Height(10)
						tB[i]:SetWidth((T.Player + 5) / 4)
					
						if (i == 1) then
							tB[i]:Point("BOTTOMLEFT", self.panel, "TOPLEFT", 0, 2)
						else
							tB[i]:Point("TOPLEFT", tB[i-1], "TOPRIGHT", -1, 0)
						end

						TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_Totem"..i, self)
						TotemBar[i]:Point("TOPLEFT", tB[i], "TOPLEFT", 2, -2)
						TotemBar[i]:Point("BOTTOMRIGHT", tB[i], "BOTTOMRIGHT", -2, 2)
						TotemBar[i]:SetFrameLevel(health:GetFrameLevel() + 2)
						TotemBar[i]:SetStatusBarTexture(normTex)			
						TotemBar[i]:GetStatusBarTexture():SetHorizTile(false)
						TotemBar[i]:SetMinMaxValues(0, 1)
						
						TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, 'BORDER')			
						TotemBar[i].bg:SetTexture(TotemBar[i]:GetStatusBarTexture())
						TotemBar[i].bg:Point("TOPLEFT", TotemBar[i], "TOPLEFT", 2, -2)
						TotemBar[i].bg:Point("BOTTOMRIGHT", TotemBar[i], "BOTTOMRIGHT", -2, 2)
						
						tB[i]:SetTemplate("Default", true)
						tB[i]:CreateShadow("Default")
					end
					self.TotemBar = TotemBar
				end
			end
			
			-- script for pvp status and low mana
			self:SetScript("OnEnter", function(self)
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Hide()
				end
				FlashInfo.ManaLevel:Hide()
				status:Show()
				UnitFrame_OnEnter(self) 
			end)
			self:SetScript("OnLeave", function(self) 
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Show()
				end
				FlashInfo.ManaLevel:Show()
				status:Hide()
				UnitFrame_OnLeave(self) 
			end)
		end
		
		if (unit == "target") then			
			-- Unit name on target
			local Name = panel:CreateFontString(nil, "OVERLAY")
			Name:Point("LEFT", self.panel, "LEFT", 4, 1)
			Name:SetJustifyH("LEFT")
			Name:SetFont(font, fonts, fontf)

			self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
			self.Name = Name
			
			-- combo point bar on target
			if (T.myclass == "ROGUE" or T.myclass == "DRUID") then
				local CPoints = {}
				CPoints.unit = PlayerFrame.unit
				local cB = CreateFrame("Frame", nil, self)
				local bars = MAX_COMBO_POINTS
				for i = 1, bars do
					cB[i] = CreateFrame("Frame", nil, self)
					cB[i]:Height(10)
					cB[i]:SetWidth((T.Target + 6) / bars)
					cB[i]:SetFrameLevel(health:GetFrameLevel() + 1)
					
					if (i == 1) then
						cB[i]:SetPoint("BOTTOMLEFT", self.panel, "TOPLEFT", 0, 3)
					else
						cB[i]:SetPoint("TOPLEFT", cB[i-1], "TOPRIGHT", -T.mult, 0)
					end
					
					CPoints[i] = CreateFrame("StatusBar", self:GetName().."_Combo"..i, self)
					CPoints[i]:Point("TOPLEFT", cB[i], "TOPLEFT", 2, -2)
					CPoints[i]:Point("BOTTOMRIGHT", cB[i], "BOTTOMRIGHT", -2, 2)
					CPoints[i]:SetFrameLevel(health:GetFrameLevel() + 2)
					CPoints[i]:SetStatusBarTexture(normTex)
					
					CPoints[i].bg = CPoints[i]:CreateTexture(nil, 'BORDER')
					CPoints[i].bg:SetTexture(CPoints[i]:GetStatusBarTexture())
					CPoints[i].bg:SetAlpha(.15)
					
					if i == 1 then
						CPoints[i]:SetStatusBarColor(0.69, 0.31, 0.31)
					elseif i == 2 then
						CPoints[i]:SetStatusBarColor(0.69, 0.31, 0.31)
					elseif i == 3 then
						CPoints[i]:SetStatusBarColor(0.65, 0.63, 0.35)
					elseif i == 4 then
						CPoints[i]:SetStatusBarColor(0.65, 0.63, 0.35)
					elseif i == 5 then
						CPoints[i]:SetStatusBarColor(0.33, 0.59, 0.33)
					end
					
					cB[i]:SetTemplate("Default", true)
					cB[i]:CreateShadow("Default")
					
					-- some extra code to hide it ooc and if target has 0 points, taken from sCombo
					cB[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
					cB[i]:RegisterEvent("UNIT_COMBO_POINTS")
					cB[i]:RegisterEvent("PLAYER_TARGET_CHANGED")
					cB[i]:SetScript("OnEvent", function(self, event)
					local points, pt = 0, GetComboPoints("player", "target")
						if pt == points then
							cB[i]:Hide()
						elseif pt > points then
							for i = points + 1, pt do
								cB[i]:Show()
							end
						else
							for i = pt + 1, points do
								cB[i]:Hide()
							end
						end
						points = pt	
					end)
				end
				
				self.CPoints = CPoints
			end
		end

		if (unit == "player" and C["unitframes"].playerauras) then
			local buffs = CreateFrame("Frame", nil, self.panel)
			local debuffs = CreateFrame("Frame", nil, self.panel)
			
			if (T.myclass == "SHAMAN" or
				T.myclass == "DEATHKNIGHT" or
				T.myclass == "WARLOCK" or
				T.myclass == "PALADIN" or
				T.myclass == "DRUID") and (C["unitframes"].classbar and unit == "player") then
				buffs:SetPoint("BOTTOMLEFT", self.panel, "TOPLEFT", 0, 14)
			else
				buffs:SetPoint("BOTTOMLEFT", self.panel, "TOPLEFT", 0, 3)
			end
			
			buffs.num = C["unitframes"].buffsperrow
			buffs:SetWidth(T.Player)
			buffs.spacing = T.Scale(1*T.raidscale)
			buffs.size = ((T.Player - (buffs.spacing*(buffs.num - 1))) / buffs.num)*T.raidscale
			buffs:SetHeight(buffs.size)
			
			debuffs.num = C["unitframes"].debuffsperrow
			debuffs:SetWidth(T.Player)
			debuffs.spacing = T.Scale(1*T.raidscale)
			debuffs.size = ((T.Player - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)*T.raidscale
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("BOTTOMRIGHT", buffs, "TOPRIGHT", 2, 5)


			buffs.initialAnchor = "BOTTOMLEFT"
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			if C["unitframes"].playershowonlydebuffs == false then
				self.Buffs = buffs	
			end

			debuffs.initialAnchor = "BOTTOMRIGHT"
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			debuffs.CustomFilter = T.AuraFilter			
			self.Debuffs = debuffs
			
		end
		
		-- target frame
		if (unit == "target" and C["unitframes"].targetauras) then
			local buffs = CreateFrame("Frame", nil, self.panel)
			local debuffs = CreateFrame("Frame", nil, self.panel)
			
			if (T.myclass == "ROGUE" or
				T.myclass == "DRUID") and (unit == "target") then
				buffs:SetPoint("BOTTOMLEFT", self.panel, "TOPLEFT", 0, 14)
			else
				buffs:SetPoint("BOTTOMLEFT", self.panel, "TOPLEFT", 0, 3)
			end

			buffs.num = C["unitframes"].buffsperrow
			buffs:SetWidth(T.Target)
			buffs.spacing = T.Scale(1*T.raidscale)
			buffs.size = ((T.Target - (buffs.spacing*(buffs.num - 1))) / buffs.num)*T.raidscale
			buffs:SetHeight(buffs.size)
			
			debuffs.num = C["unitframes"].debuffsperrow
			debuffs:SetWidth(T.Target)
			debuffs.spacing = T.Scale(1*T.raidscale)
			debuffs.size = ((T.Target - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)*T.raidscale
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("BOTTOMRIGHT", buffs, "TOPRIGHT", 2, 5)


			buffs.initialAnchor = "BOTTOMLEFT"
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs	

			debuffs.initialAnchor = "BOTTOMRIGHT"
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			debuffs.CustomFilter = T.AuraFilter			
			self.Debuffs = debuffs
			
		end
		
		-- cast bar for player and target
		if (C["unitframes"].unitcastbar == true) then
			-- castbar of player and target
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(normTex)
			castbar:GetStatusBarTexture():SetHorizTile(false)
			
			if C["unitframes"].cbinside and C["unitframes"].large_player ~= true then
				castbar.bg = castbar:CreateTexture(nil, "BORDER")
				castbar.bg:SetAllPoints(castbar)
				castbar.bg:SetTemplate("Default")
				castbar:SetFrameLevel(panel:GetFrameLevel() + 2)
				castbar:Point("TOPLEFT", panel, 1, -1)
				castbar:Point("BOTTOMRIGHT", panel, -1, 1)
			
				castbar.CustomTimeText = T.CustomCastTimeText
				castbar.CustomDelayText = T.CustomCastDelayText
				castbar.PostCastStart = T.PostCastStart
				castbar.PostChannelStart = T.PostCastStart

				castbar.time = T.SetFontString(castbar, font, fonts, "THINOUTLINE")
				castbar.time:Point("RIGHT", panel, "RIGHT", -4, 0)
				castbar.time:SetTextColor(0.84, 0.75, 0.65)
				castbar.time:SetJustifyH("RIGHT")

				castbar.Text = T.SetFontString(castbar, font, fonts, "THINOUTLINE")
				castbar.Text:Point("LEFT", panel, "LEFT", 4, 0)
				castbar.Text:SetWidth(150)
				castbar.Text:SetTextColor(0.84, 0.75, 0.65)
						
				if C["unitframes"].cbicons == true and not T.lowversion then
					castbar.button = CreateFrame("Frame", nil, castbar)
					castbar.button:Size(panel:GetHeight(), panel:GetHeight())
					castbar.button:SetTemplate("Default", true)
					castbar.button:CreateShadow("Default")

					castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
					castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
					castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
					castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			
					if unit == "player" then
						castbar.button:SetPoint("TOPRIGHT", castbar, "TOPLEFT", -T.buttonspacing*2, 1)
					elseif unit == "target" then
						castbar.button:SetPoint("TOPLEFT", castbar, "TOPRIGHT", T.buttonspacing*2, 1)
					end
				end
			else -- outside of UF
				castbar:SetHeight(20)
				if unit == "player" then
					if C["unitframes"].large_player == true then
						castbar:SetHeight(T.buttonsize - 5)
						if C["unitframes"].cbicons == true then
							castbar:SetWidth(TukuiMainMenuBar:GetWidth() - T.buttonsize - (T.buttonspacing + 3) )
							castbar:SetPoint("BOTTOMLEFT", TukuiMainMenuBar, "TOPLEFT", T.buttonsize + 5, 5)
							--castbar:SetWidth(583)
							--castbar:SetPoint("BOTTOMLEFT", TukuiSplitBarLeft, "TOPLEFT", T.buttonsize + 5, 5)
						else
							castbar:SetWidth(TukuiMainMenuBar:GetWidth() - 5)
							castbar:SetPoint("BOTTOMLEFT", TukuiMainMenuBar, "TOPLEFT", 2, 5)
						end
					else
						castbar:Point("BOTTOM", TukuiPlayer, "TOP", T.buttonspacing, 295)
						castbar:SetWidth(T.Player)
					end
				elseif unit == "target" then
					castbar:Point("BOTTOM", TukuiTarget, "TOP", T.buttonspacing, 295) -- 168
					castbar:SetWidth(T.Target)
				end
			
				local castbarBg = CreateFrame("Frame", nil, castbar)
				castbarBg:SetPoint("TOPLEFT", -T.Scale(2), T.Scale(2))
				castbarBg:SetPoint("BOTTOMRIGHT", T.Scale(2), -T.Scale(2))
				castbarBg:SetFrameLevel(castbar:GetFrameLevel() - 1)
				castbarBg:SetTemplate("Default")
				castbarBg:CreateShadow("Default")			
					
				castbar.CustomTimeText = T.CustomCastTimeText
				castbar.CustomDelayText = T.CustomCastDelayText
				castbar.PostCastStart = T.PostCastStart
				castbar.PostChannelStart = T.PostCastStart

				castbar.time = T.SetFontString(castbar, font, fonts, fontf)
				castbar.time:Point("RIGHT", castbar, "RIGHT", -T.buttonspacing, 0)
				castbar.time:SetTextColor(0.8, 0.75, 0.85)
				
				castbar.Text = T.SetFontString(castbar, font, fonts, fontf)
				castbar.Text:SetTextColor(0.8, 0.75, 0.85)
				
				if C["unitframes"].cbicons == true and not T.lowversion then
					castbar.button = CreateFrame("Frame", nil, castbar)
					castbar.button:SetTemplate("Default", true)
					castbar.button:CreateShadow("Default")

					castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
					castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
					castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
					castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
					
					if unit == "player" then
						if C["unitframes"].large_player == true then
							castbar.button:SetPoint("RIGHT", castbarBg, "LEFT", -3, 0)
							castbar.button:Size(T.buttonsize, T.buttonsize)
						else
							castbar.button:Size(T.buttonsize, T.buttonsize)
							castbar.button:SetPoint("BOTTOM", castbarBg, "TOP", 0, 3)
						end
					elseif unit == "target" then
						castbar.button:Size(T.buttonsize, T.buttonsize)
						castbar.button:SetPoint("BOTTOM", castbarBg, "TOP", 0, 3)
					end
					
					castbar.Text:Point("LEFT", castbar, "LEFT", T.buttonspacing, 0)
					castbar.Text:SetWidth(T.Player - (T.buttonsize * 2))
				else
					castbar.Text:Point("CENTER", castbar, "CENTER")
					if C["unitframes"].large_player == true then
						castbar.Text:SetWidth(360)
						--castbar.Text:SetWidth(583)
					else
						castbar.Text:SetWidth(T.Player - T.buttonsize)
					end
				end
			end
			
			-- cast bar latency on player
			if unit == "player" and C["unitframes"].cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end
					
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end

		-- Debuff Highlight
		if C["unitframes"].debuffhighlight == true then
			local dbh = self.Health:CreateTexture(nil, "OVERLAY", healthBg)
			dbh:SetAllPoints(self)
			dbh:SetTexture(C["media"].blank)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.35
		end
		
		-- add combat feedback support
		if C["unitframes"].combatfeedback == true then
			local CombatFeedbackText 
			CombatFeedbackText = T.SetFontString(health, font, fonts, fontf)
			CombatFeedbackText:SetShadowColor(0, 0, 0)
			CombatFeedbackText:SetShadowOffset(1.25, -1.25)
			CombatFeedbackText:SetPoint("CENTER", 0, 1)
			CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
			self.CombatFeedbackText = CombatFeedbackText
		end
		
		if C["unitframes"].healcomm then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			if T.lowversion then
				mhpb:SetWidth(T.Player)
			else
				mhpb:SetWidth(T.Player)
			end
			mhpb:SetStatusBarTexture(normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
			mhpb:SetMinMaxValues(0,1)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetWidth(T.Player)
			ohpb:SetStatusBarTexture(normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		-- player aggro
		if C["unitframes"].playeraggro == true then
			table.insert(self.__elements, T.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
		end
	end
	
	------------------------------------------------------------------------
	--	Focus unit, pet unit, and targetoftarget layout
	------------------------------------------------------------------------
	
	if (unit == "targettarget") or (unit == "pet") or (unit == "focus") then
		-- health
		local health = CreateFrame('StatusBar', nil, self)
		health:SetFrameLevel(5)
		health:Height(20)
		health:SetPoint("TOPLEFT", T.mult, -T.mult)
		health:SetPoint("TOPRIGHT", -T.mult, T.mult)
		health:SetStatusBarTexture(C["media"].normTex)
		self.Health = health
		
		local healthBg = health:CreateTexture(nil, "BORDER")
		healthBg:SetAllPoints()
		healthBg:SetTexture(unpack(C["unitframes"].healthBgColor))
		self.Health.bg = healthBg
		
		local healthB = CreateFrame("Frame", nil, health)
		healthB:SetFrameLevel(health:GetFrameLevel() - 1)
		healthB:Point("TOPLEFT", -2, 2)
		healthB:Point("BOTTOMRIGHT", 2, -2)
		healthB:SetTemplate("Default", true)
		healthB:CreateShadow("Default")
		self.Health.border = healthB

		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(20/4)
		power:SetPoint("TOPLEFT", healthB, "BOTTOMLEFT", T.Scale(2), -T.Scale(6))
		power:SetPoint("TOPRIGHT", healthB, "BOTTOMRIGHT", T.Scale(-2), -T.Scale(6))
		power:SetStatusBarTexture(normTex)
		self.Power = power
		
		local powerBg = power:CreateTexture(nil, "BORDER")
		powerBg:SetAllPoints()
		powerBg:SetTexture(unpack(C["unitframes"].healthBgColor))
		powerBg.multiplier = 0.3
		self.Power.bg = powerBg
		
		local powerB = CreateFrame("Frame", nil, power)
		powerB:SetFrameLevel(power:GetFrameLevel() - 1)
		powerB:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(3))
		powerB:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-3))
		powerB:SetTemplate("Default")
		powerB:CreateShadow("Default")
		self.Power.border = powerB	
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetFont(font, fonts, fontf)
		Name:SetJustifyH("CENTER")
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:name_medium][Tukui:dead][Tukui:afk]')
		self.Name = Name
		
		health.frequentUpdates = true
		power.frequentUpdates = true

		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["general"].classcolortheme ~= true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthColor))
			health.bg:SetTexture(1, 1, 1)
			health.bg:SetVertexColor(unpack(C["unitframes"].healthBgColor))
			
			power.colorTapping = true
			power.colorDisconnected = true
			power.colorClass = true
			power.colorReaction = true
			power.bg.multiplier = 0.1
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
			
			power.colorPower = true
		end
		
		-- auras
		if (unit == "targettarget" and C["unitframes"].totdebuffs == true) or (unit == "focus" and C["unitframes"].focusdebuffs == true) then	
			local debuffs = CreateFrame("Frame", nil, power)
			debuffs.num = 5
			debuffs:SetWidth(T.Focus)
			debuffs.spacing = T.Scale(1*T.raidscale)
			debuffs.size = ((T.Focus - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)*T.raidscale
			debuffs:SetHeight(debuffs.size)
			debuffs:Point("TOP", power, "BOTTOM", 0, -4*T.raidscale)	
			debuffs.initialAnchor = 'BOTTOMRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			debuffs.CustomFilter = T.AuraFilter
			self.Debuffs = debuffs
		end
		
		-- focus castbar
		if C["unitframes"].unitcastbar and unit == "focus" then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:Height(20)
			castbar:Width(250)
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			castbar:SetPoint("CENTER", UIParent, "CENTER", 0, 200)		
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			castbar.bg:SetTemplate("Default", true)
			castbar.bg:CreateShadow("Default")			
			castbar.bg:Point("TOPLEFT", -2, 2)
			castbar.bg:Point("BOTTOMRIGHT", 2, -2)
			castbar.bg:SetFrameLevel(5)
			
			castbar.time = T.SetFontString(castbar, font, fonts, "THINOUTLINE")
			castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")

			castbar.Text = T.SetFontString(castbar, font, fonts, "THINOUTLINE")
			castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomTimeText = CustomCastTimeText
			castbar.CustomDelayText = T.CustomCastDelayText
			castbar.PostCastStart = T.PostCastStart
			castbar.PostChannelStart = T.PostCastStart
			
			if C["unitframes"].cbicons then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:Height((T.buttonsize-4) * 2)
				castbar.button:Width((T.buttonsize-4) * 2)
				castbar.button:Point("CENTER", 0, 20 * 2)
				castbar.button:SetTemplate("Default", true)
				castbar.button:CreateShadow("Default")			

				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
				castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			end

			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- aggro
		if C["unitframes"].playeraggro and unit == "pet" then
			table.insert(self.__elements, T.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
		end

		-- update pet name, this should fix "UNKNOWN" pet names on pet unit.
		self:RegisterEvent("UNIT_PET", T.updateAllElements)
	end
	
	------------------------------------------------------------------------
	--	Focus target unit layout
	------------------------------------------------------------------------

	if (unit == "focustarget") then
		-- no
	end

	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and C["arena"].unitframes == true) or (unit and unit:find("boss%d") and C["unitframes"].showboss == true) then
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(20*1.5)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(C["media"].normTex)
		self.Health = health
		
		local healthBg = health:CreateTexture(nil, "BORDER")
		healthBg:SetAllPoints()
		healthBg:SetTexture(unpack(C["unitframes"].healthBgColor))
		self.Health.bg = healthBg
		
		local healthB = CreateFrame("Frame", nil, health)
		healthB:SetFrameLevel(health:GetFrameLevel() - 1)
		healthB:Point("TOPLEFT", -2, 2)
		healthB:Point("BOTTOMRIGHT", 2, -2)
		healthB:SetTemplate("Default", true)
		healthB:CreateShadow("Default")
		self.Health.border = healthB
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(20/2)
		power:SetPoint("TOPLEFT", healthB, "BOTTOMLEFT", T.Scale(2), T.Scale(-6))
		power:SetPoint("TOPRIGHT", healthB, "BOTTOMRIGHT", T.Scale(-2), T.Scale(-6))
		power:SetStatusBarTexture(normTex)
		self.Power = power
		
		local powerBg = power:CreateTexture(nil, "BORDER")
		powerBg:SetAllPoints()
		powerBg:SetTexture(unpack(C["unitframes"].healthBgColor))
		powerBg.multiplier = 0.3
		self.Power.bg = powerBg
		
		local powerB = CreateFrame("Frame", nil, power)
		powerB:SetFrameLevel(power:GetFrameLevel() - 1)
		powerB:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(3))
		powerB:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-3))
		powerB:SetTemplate("Default", true)
		powerB:CreateShadow("Default")
		self.Power.border = powerB
		
		health.value = T.SetFontString(health, font, fonts, fontf)
		
		if C["unitframes"].percentage == true then
			health.percent = T.SetFontString(health, font, health:GetHeight(), fontf)
			health.percent:Point("RIGHT", health, "LEFT", -6, 0)
			health.percent:SetShadowOffset(-2,-2)
			power.percent = T.SetFontString(health, font, fonts, fontf)		-- hack to disable error
		end
		
		health.PostUpdate = T.PostUpdateHealth
		
		power.value = T.SetFontString(power, font, fonts, fontf)
		power.value:Point("RIGHT", self.Health, "RIGHT", -6, 0)
		
		
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
		
		health.frequentUpdates = true
		power.frequentUpdates = true
		
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
			power.Smooth = true
		end
		
		if C["general"].classcolortheme ~= true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthColor))
			health.bg:SetTexture(1, 1, 1)
			health.bg:SetVertexColor(unpack(C["unitframes"].healthBgColor))
			
			power.colorTapping = true
			power.colorDisconnected = true
			power.colorClass = true
			power.colorReaction = true
			power.bg.multiplier = 0.1
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
			
			power.colorPower = true
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("LEFT", health, "LEFT", 6, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font, fonts, fontf)
		Name.frequentUpdates = 0.2		
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name
		
		if (unit and unit:find("boss%d")) then			
			-- alt power bar
			local AltPowerBar = CreateFrame("StatusBar", nil, self.Power)
			AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 4)
			AltPowerBar:Height(10)
			AltPowerBar:SetWidth(T.Boss)
			AltPowerBar:SetStatusBarTexture(normTex)
			AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
			AltPowerBar:SetStatusBarColor(1, 0, 0)
			AltPowerBar:SetPoint("LEFT", self.Power, "TOPLEFT", 0, -6)
			AltPowerBar:SetPoint("RIGHT", self.Power, "TOPRIGHT", 0, -6)
			self.AltPowerBar = AltPowerBar
		end
		
		if (unit and unit:find("arena%d") and C["unitframes"].arenabuffs == true) or (unit and unit:find("boss%d") and C["unitframes"].bossbuffs == true) then
			local buffs = CreateFrame("Frame", nil, health)	
			
			buffs.num = 7
			buffs:SetWidth(T.Boss)
			buffs.spacing = T.Scale(1*T.raidscale)
			buffs.size = ((T.Boss - (buffs.spacing*(buffs.num - 1))) / buffs.num)*T.raidscale
			buffs:SetHeight(buffs.size)
			buffs:SetPoint("BOTTOMLEFT", health, "TOPLEFT", -2, T.Scale(5)) -- was 13
			buffs.initialAnchor = "TOPLEFT"
			buffs["growth-y"] = "UP"
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			
			if (unit and unit:find('arena%d')) then
				buffs.CustomFilter = T.AuraFilter
			end
			self.Buffs = buffs
		end
		
		if (unit and unit:find("arena%d") and C["unitframes"].arenadebuffs == true) or (unit and unit:find("boss%d") and C["unitframes"].bossdebuffs == true) then
			local debuffs = CreateFrame("Frame", nil, self)
			
			debuffs.num = 3
			debuffs:SetWidth(T.Boss)
			debuffs.spacing = T.Scale(1*T.raidscale)
			debuffs.size = 20*1.5
			debuffs:Point("TOPLEFT", self, "TOPRIGHT", 4, 0)
			debuffs:SetHeight(debuffs.size)
			debuffs.initialAnchor = 'LEFT'
			debuffs["growth-y"] = "UP"	
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			debuffs.CustomFilter = T.AuraFilter
			self.Debuffs = debuffs	
		end

		-- trinket feature via trinket plugin
		if (C.arena.unitframes) and (unit and unit:find('arena%d')) then
			local Trinketbg = CreateFrame("Frame", nil, self)
			Trinketbg:SetHeight(20*1.65)
			Trinketbg:SetWidth(20*1.65)
			Trinketbg:SetPoint("LEFT", self, "RIGHT", 6, 0)				
			Trinketbg:SetTemplate("Default", true)
			Trinketbg:CreateShadow("Default")
			Trinketbg:SetFrameLevel(0)
			self.Trinketbg = Trinketbg
			
			local Trinket = CreateFrame("Frame", nil, Trinketbg)
			Trinket:SetAllPoints(Trinketbg)
			Trinket:SetPoint("TOPLEFT", Trinketbg, T.Scale(2), T.Scale(-2))
			Trinket:SetPoint("BOTTOMRIGHT", Trinketbg, T.Scale(-2), T.Scale(2))
			Trinket:SetFrameLevel(1)
			Trinket.trinketUseAnnounce = true
			self.Trinket = Trinket
		end
		
		-- boss & arena frames cast bar!
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", power)
		castbar:SetPoint("TOPLEFT", power, "BOTTOMLEFT", 0, -7)
		castbar:SetPoint("TOPRIGHT", power, "BOTTOMRIGHT", 0, -7)
		
		castbar:Height(20 / 1.5)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("Default", true)
		castbar.bg:CreateShadow("Default")
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, font, fonts, fontf)
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, font, fonts, fontf)
		castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText	
		castbar.PostCastStart = T.PostCastStart
		castbar.PostChannelStart = T.PostCastStart
								
		castbar.button = CreateFrame("Frame", nil, castbar)
		castbar.button:Height(castbar:GetHeight()+4)
		castbar.button:Width(castbar:GetHeight()+4)
		castbar.button:Point("RIGHT", castbar, "LEFT",-4, 0)
		castbar.button:SetTemplate("Default", true)
		castbar.button:CreateShadow("Default")
		castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
		castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
		castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
		castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
		self.Castbar.Icon = castbar.icon
	end

	------------------------------------------------------------------------
	--	Main tanks and Main Assists layout (both mirror'd)
	------------------------------------------------------------------------
	
	if(self:GetParent():GetName():match"TukuiMainTank" or self:GetParent():GetName():match"TukuiMainAssist") then
		-- Right-click focus on maintank or mainassist units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(20 / 2)
		health:SetPoint("TOPLEFT", T.mult, -T.mult)
		health:SetPoint("TOPRIGHT", -T.mult, T.mult)
		health:SetStatusBarTexture(normTex)
		self.Health = health
		
		local healthBg = health:CreateTexture(nil, "BORDER")
		healthBg:SetAllPoints()
		healthBg:SetTexture(unpack(C["media"].bgcolor))
		self.Health.bg = healthBg

		local healthB = CreateFrame("Frame", nil, health)
		healthB:SetFrameLevel(health:GetFrameLevel() - 1)
		healthB:Point("TOPLEFT", -2, 2)
		healthB:Point("BOTTOMRIGHT", 2, -2)
		healthB:SetTemplate("Default", true)
		healthB:CreateShadow("Default")
		self.Health.border = healthB
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER")
		Name:SetFont(font, fonts, fontf)
		Name:SetShadowOffset(1, -1)
		
		self.Name = Name
		
		--[[if C["general"].classcolortheme ~= true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthColor))
			health.bg:SetTexture(1, 1, 1)
			health.bg:SetVertexColor(unpack(C["unitframes"].healthBgColor))
			
			power.colorTapping = true
			power.colorDisconnected = true
			power.colorClass = true
			power.colorReaction = true
			power.bg.multiplier = 0.1
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
			
			power.colorPower = true
		end--]]
		
		if C["general"].classcolortheme == false then
			health.colorTapping = true
			health.colorDisconnected = true
			health.colorReaction = true
			health.colorClass = true
			healthBg.multiplier = 0.2
			
			self:Tag(Name, '[Tukui:nameshort]')
		else
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health.colorReaction = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthColor))
			health.bg:SetVertexColor(unpack(C["unitframes"].healthBgColor))
			
			self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		end
	end
	
	return self
end

------------------------------------------------------------------------
--	Default position of Tukui unitframes
------------------------------------------------------------------------

oUF:RegisterStyle('Tukui', Shared)

-- spawn
local player = oUF:Spawn('player', "TukuiPlayer")
local target = oUF:Spawn('target', "TukuiTarget")
local tot = oUF:Spawn('targettarget', "TukuiTargetTarget")
local pet = oUF:Spawn('pet', "TukuiPet")
local focus = oUF:Spawn('focus', "TukuiFocus")

-- sizes
player:Size(T.Player, player.Health:GetHeight() + player.Power:GetHeight() + 25)
target:Size(T.Target, target.Health:GetHeight() + target.Power:GetHeight() + 25)

if T.lowversion then
	tot:Size(T.ToT, tot.Health:GetHeight() + 20)
	pet:Size(T.Pet, pet.Health:GetHeight() + 20)
else
	tot:SetSize(T.ToT, tot.Health:GetHeight() + tot.Power:GetHeight() + 25)
	pet:SetSize(T.Pet, pet.Health:GetHeight() + pet.Power:GetHeight() + 25)	
end

focus:SetSize(T.Focus, focus.Health:GetHeight() + focus.Power:GetHeight() + 3)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)

	if addon == "Tukui_DPS" then
		--[ DPS ]--
		-- points
		player:Point("TOP", TopMainBar, "BOTTOM", -240 , 135)
		target:Point("TOP", TopMainBar, "BOTTOM", 240, 135)
		tot:Point("TOPRIGHT", TukuiTarget, "BOTTOMRIGHT", 0, -5)
		pet:Point("TOPLEFT", TukuiPlayer, "BOTTOMLEFT", 0, -5)

		focus:Point("TOP", UIParent, "BOTTOM", 0, 230)
	elseif addon == "Tukui_Heal" then
		--[ HEAL ]--
		-- points
		player:Point("TOP", TopMainBar, "BOTTOM", -320 , 135)
		target:Point("TOP", TopMainBar, "BOTTOM", 320, 135)
		tot:Point("TOPRIGHT", TukuiTarget, "BOTTOMRIGHT", 0, -5)
		pet:Point("TOPLEFT", TukuiPlayer, "BOTTOMLEFT", 0, -5)

		focus:Point("BOTTOMRIGHT", ChatLBackground2, "TOPRIGHT", 0, 150)
	end
end)


if C.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "TukuiArena"..i)
		if i == 1 then
			arena[i]:SetPoint("BOTTOMLEFT", ChatRBackground2, "TOPLEFT", 0, 175)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, T.Scale(80))
		end
		arena[i]:Size(T.Boss, 20*1.5)
	end
end


if C["unitframes"].showboss then
	for i = 1,MAX_BOSS_FRAMES do
		local t_boss = _G["Boss"..i.."TargetFrame"]
		t_boss:UnregisterAllEvents()
		t_boss.Show = T.dummy
		t_boss:Hide()
		_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
		_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
	end

	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "TukuiBoss"..i)
		if i == 1 then
			boss[i]:SetPoint("BOTTOMLEFT", ChatRBackground2, "TOPLEFT", 0, 175)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, T.Scale(80))             
		end
		boss[i]:Size(T.Boss, 20*1.5)
	end
end

-- main tank
if C["unitframes"].maintank == true then
	local tank = oUF:SpawnHeader('TukuiMainTank', nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(100, 20),
		'showRaid', true,
		'groupFilter', 'MAINTANK',
		'yOffset', 5,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	tank:SetPoint("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", 0, T.Scale(200))
end
 
-- main assist
if C["unitframes"].mainassist == true then
	local assist = oUF:SpawnHeader("TukuiMainAssist", nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(100, 20),
		'showRaid', true,
		'groupFilter', 'MAINASSIST',
		'yOffset', 5,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	if C["unitframes"].maintank == true then
		assist:SetPoint("TOPLEFT", TukuiMainTank, "BOTTOMLEFT", T.buttonspacing, T.Scale(-20*2))
	else
		assist:SetPoint("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", T.Scale(1), T.Scale(200))
	end
end

-- Testui Command
local testui = TestUI or function() end
TestUI = function(msg)
	if msg == "a" or msg == "arena" then
		TukuiArena1:Show(); TukuiArena1.Hide = function() end; TukuiArena1.unit = "player"
		TukuiArena2:Show(); TukuiArena2.Hide = function() end; TukuiArena2.unit = "player"
		TukuiArena3:Show(); TukuiArena3.Hide = function() end; TukuiArena3.unit = "player"
		TukuiArena4:Show(); TukuiArena4.Hide = function() end; TukuiArena4.unit = "player"
		TukuiArena5:Show(); TukuiArena5.Hide = function() end; TukuiArena5.unit = "player"
	elseif msg == "boss" or msg == "b" then
		TukuiBoss1:Show(); TukuiBoss1.Hide = function() end; TukuiBoss1.unit = "player"
		TukuiBoss2:Show(); TukuiBoss2.Hide = function() end; TukuiBoss2.unit = "player"
		TukuiBoss3:Show(); TukuiBoss3.Hide = function() end; TukuiBoss3.unit = "player"
		TukuiBoss4:Show(); TukuiBoss4.Hide = function() end; TukuiBoss4.unit = "player"
	elseif msg == "pet" or msg == "p" then
		TukuiPet:Show(); TukuiPet.Hide = function() end; TukuiPet.unit = "player"
	elseif msg == "buffs" then -- better dont test it ^^
		UnitAura = function()
			-- name, rank, texture, count, dtype, duration, timeLeft, caster
			return 139, 'Rank 1', 'Interface\\Icons\\Spell_Holy_Penance', 1, 'Magic', 0, 0, "player"
		end
		if(oUF) then
			for i, v in pairs(oUF.units) do
				if(v.UNIT_AURA) then
					v:UNIT_AURA("UNIT_AURA", v.unit)
				end
			end
		end
	end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"

-- this is just a fake party to hide Blizzard frame if no Tukui raid layout are loaded.
local party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)

if C["classtimer"].enable == true then
	T.LoadClassTimers(TukuiPlayer, TukuiTarget)
end

------------------------------------------------------------------------
-- Right-Click on unit frames menu. 
-- Doing this to remove SET_FOCUS eveywhere.
-- SET_FOCUS work only on Default unitframes.
-- Main Tank and Main Assist, use /maintank and /mainassist commands.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
	UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
	UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
	UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end