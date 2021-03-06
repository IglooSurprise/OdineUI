local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if C["chat"].enable ~= true then return end

-----------------------------------------------------------------------
-- SETUP TUKUI CHATS
-----------------------------------------------------------------------

local TukuiChat = CreateFrame("Frame")
local tabalpha = 1
local tabnoalpha = 0
local _G = _G
local origs = {}
local type = type
local CreatedFrames = 0

-- function to rename channel and other stuff
local AddMessage = function(self, text, ...)
	if(type(text) == "string") then
		text = text:gsub('|h%[(%d+)%. .-%]|h', '|h[%1]|h')
	end
	return origs[self](self, text, ...)
end


_G.CHAT_BATTLEGROUND_GET = "|Hchannel:Battleground|h"..L.chat_BATTLEGROUND_GET.."|h %s:\32"
_G.CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:Battleground|h"..L.chat_BATTLEGROUND_LEADER_GET.."|h %s:\32"
_G.CHAT_BN_WHISPER_GET = L.chat_BN_WHISPER_GET.." %s:\32"
_G.CHAT_GUILD_GET = "|Hchannel:Guild|h"..L.chat_GUILD_GET.."|h %s:\32"
_G.CHAT_OFFICER_GET = "|Hchannel:o|h"..L.chat_OFFICER_GET.."|h %s:\32"
_G.CHAT_PARTY_GET = "|Hchannel:Party|h"..L.chat_PARTY_GET.."|h %s:\32"
_G.CHAT_PARTY_GUIDE_GET = "|Hchannel:party|h"..L.chat_PARTY_GUIDE_GET.."|h %s:\32"
_G.CHAT_PARTY_LEADER_GET = "|Hchannel:party|h"..L.chat_PARTY_LEADER_GET.."|h %s:\32"
_G.CHAT_RAID_GET = "|Hchannel:raid|h"..L.chat_RAID_GET.."|h %s:\32"
_G.CHAT_RAID_LEADER_GET = "|Hchannel:raid|h"..L.chat_RAID_LEADER_GET.."|h %s:\32"
_G.CHAT_RAID_WARNING_GET = L.chat_RAID_WARNING_GET.." %s:\32"
_G.CHAT_SAY_GET = "%s:\32"
_G.CHAT_WHISPER_GET = L.chat_WHISPER_GET.." %s:\32"
_G.CHAT_YELL_GET = "%s:\32"
 
_G.CHAT_FLAG_AFK = "|cffFF0000"..L.chat_FLAG_AFK.."|r "
_G.CHAT_FLAG_DND = "|cffE7E716"..L.chat_FLAG_DND.."|r "
_G.CHAT_FLAG_GM = "|cff4154F5"..L.chat_FLAG_GM.."|r "
 

-- don't replace this with custom colors, since many addons
-- use these strings to detect if friends come on-line or go off-line 
--_G.ERR_FRIEND_ONLINE_SS = "|Hplayer:%s|h[%s]|h "..L.chat_ERR_FRIEND_ONLINE_SS.."!"
--_G.ERR_FRIEND_OFFLINE_S = "%s "..L.chat_ERR_FRIEND_OFFLINE_S.."!"

-- Hide friends micro button (added in 3.3.5)
FriendsMicroButton:Kill()

-- hide chat bubble menu button
ChatFrameMenuButton:Kill()

local EditBoxDummy = CreateFrame("Frame", "EditBoxDummy", UIParent)
EditBoxDummy:SetAllPoints(TukuiInfoLeft)

-- set the chat style
local function SetChatStyle(frame)
	local id = frame:GetID()
	local chat = frame:GetName()
	local tab = _G[chat.."Tab"]
	frame.skinned = true
	tab:SetAlpha(1)
	tab.SetAlpha = UIFrameFadeRemoveFrame	
	
	-- always set alpha to 1, don't fade it anymore
	if C["chat"].background ~= true then
		-- hide text when setting chat
		_G[chat.."TabText"]:Hide()

		-- now show text if mouse is found over tab.
		tab:HookScript("OnEnter", function() _G[chat.."TabText"]:Show() end)
		tab:HookScript("OnLeave", function() _G[chat.."TabText"]:Hide() end)
	end

	local color = RAID_CLASS_COLORS[T.myclass]
	if C["datatext"].classcolor == true then
		_G[chat.."TabText"]:SetTextColor(color.r, color.g, color.b)
	else
		_G[chat.."TabText"]:SetTextColor(unpack(C["datatext"].color))
	end
	_G[chat.."TabText"]:SetFont(C["media"].dfont, C["datatext"].fsize, "THINOUTLINE")
	_G[chat.."TabText"]:SetShadowColor(0, 0, 0, 0.4)
	_G[chat.."TabText"]:SetShadowOffset(T.mult, -T.mult)
	_G[chat.."TabText"].SetTextColor = T.dummy
	local originalpoint = select(2, _G[chat.."TabText"]:GetPoint())
	_G[chat.."TabText"]:SetPoint("LEFT", originalpoint, "RIGHT", -8, (-T.mult*2) - 1)
	_G[chat]:SetMinResize(250,70)
	
	--Reposition the "New Message" orange glow so its aligned with the bottom of the chat tab
	for i=1, tab:GetNumRegions() do
		local region = select(i, tab:GetRegions())
		if region:GetObjectType() == "Texture" then
			if region:GetTexture() == "Interface\\ChatFrame\\ChatFrameTab-NewMessage" then
				if C["chat"].background == true then
					region:ClearAllPoints()
					region:SetPoint("BOTTOMLEFT", 0, T.Scale(4))
					region:SetPoint("BOTTOMRIGHT", 0, T.Scale(4))
				else
					region:Kill()
				end
				if region:GetParent():GetName() == "ChatFrame1Tab" then
					region:Kill()
				end
			end
		end
	end
	-- yeah baby
	_G[chat]:SetClampRectInsets(0,0,0,0)
	
	-- Removes crap from the bottom of the chatbox so it can go to the bottom of the screen.
	_G[chat]:SetClampedToScreen(false)
			
	-- Stop the chat chat from fading out
	_G[chat]:SetFading(C["chat"].fading)
	
	-- move the chat edit box
	_G[chat.."EditBox"]:ClearAllPoints();
	_G[chat.."EditBox"]:SetPoint("TOPLEFT", EditBoxDummy, T.Scale(2), T.Scale(-2))
	_G[chat.."EditBox"]:SetPoint("BOTTOMRIGHT", EditBoxDummy, T.Scale(-2), T.Scale(2))
	
	-- Hide textures
	for j = 1, #CHAT_FRAME_TEXTURES do
		_G[chat..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
	end

	-- Removes Default ChatFrame Tabs texture				
	_G[format("ChatFrame%sTabLeft", id)]:Kill()
	_G[format("ChatFrame%sTabMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabRight", id)]:Kill()

	_G[format("ChatFrame%sTabSelectedLeft", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedRight", id)]:Kill()
	
	_G[format("ChatFrame%sTabHighlightLeft", id)]:Kill()
	_G[format("ChatFrame%sTabHighlightMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabHighlightRight", id)]:Kill()

	-- Killing off the new chat tab selected feature
	_G[format("ChatFrame%sTabSelectedLeft", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedRight", id)]:Kill()

	-- Kills off the new method of handling the Chat Frame scroll buttons as well as the resize button
	-- Note: This also needs to include the actual frame textures for the ButtonFrame onHover
	_G[format("ChatFrame%sButtonFrameUpButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrameDownButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrameBottomButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrameMinimizeButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrame", id)]:Kill()

	-- Kills off the retarded new circle around the editbox
	_G[format("ChatFrame%sEditBoxFocusLeft", id)]:Kill()
	_G[format("ChatFrame%sEditBoxFocusMid", id)]:Kill()
	_G[format("ChatFrame%sEditBoxFocusRight", id)]:Kill()

	-- Kill off editbox artwork
	local a, b, c = select(6, _G[chat.."EditBox"]:GetRegions()); a:Kill(); b:Kill(); c:Kill()
				
	-- Disable alt key usage
	_G[chat.."EditBox"]:SetAltArrowKeyMode(false)
	
	-- hide editbox on login
	_G[chat.."EditBox"]:Hide()
	
	-- script to hide editbox instead of fading editbox to 0.35 alpha via IM Style
	_G[chat.."EditBox"]:HookScript("OnEditFocusGained", function(self) self:Show() end)
	_G[chat.."EditBox"]:HookScript("OnEditFocusLost", function(self) self:Hide() end)
	
	-- rename combag log to log
	if _G[chat] == _G["ChatFrame2"] then
		FCF_SetWindowName(_G[chat], "Log")
	end

	-- create our own texture for edit box
	local EditBoxBackground = CreateFrame("frame", "TukuiChatchatEditBoxBackground", _G[chat.."EditBox"])
	EditBoxBackground:CreatePanel("Default", 1, 1, "LEFT", _G[chat.."EditBox"], "LEFT", 0, 0)
	EditBoxBackground:SetTemplate("Default", true)
	EditBoxBackground:ClearAllPoints()
	EditBoxBackground:SetAllPoints(EditBoxDummy)
	EditBoxBackground:SetFrameStrata("LOW")
	EditBoxBackground:SetFrameLevel(1)
	
	local function colorize(r,g,b)
		EditBoxBackground:SetBackdropBorderColor(r, g, b)
	end
	
	-- update border color according where we talk
	hooksecurefunc("ChatEdit_UpdateHeader", function()
		local type = _G[chat.."EditBox"]:GetAttribute("chatType")
		if ( type == "CHANNEL" ) then
		local id = GetChannelName(_G[chat.."EditBox"]:GetAttribute("channelTarget"))
			if id == 0 then
				colorize(unpack(C.media.bordercolor))
			else
				colorize(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
			end
		else
			colorize(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
		end
	end)
		
	if _G[chat] ~= _G["ChatFrame2"] then
		origs[_G[chat]] = _G[chat].AddMessage
		_G[chat].AddMessage = AddMessage
	end
	CreatedFrames = id
end

-- Setup chatframes 1 to 10 on login.
local function SetupChat(self)	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		SetChatStyle(frame)
		FCFTab_UpdateAlpha(frame)
		_G["ChatFrame"..i]:SetFont(C["media"].cfont, C["chat"].fsize, "NONE")
	end

	-- Remember last channel
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
end

local insidetab = false
local function SetupChatFont(self)
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local tab = _G[format("ChatFrame%sTab", i)]
		local id = chat:GetID()
		local name = FCF_GetChatWindowInfo(id)
		local point = GetChatWindowSavedPosition(id)
		local button = _G[format("ButtonCF%d", i)]
		local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
		
		chat:SetFrameStrata("LOW")
		
		local _, fontSize = FCF_GetChatWindowInfo(id)
		
		--font under fontsize 12 is unreadable.
		if fontSize < 12 then		
			FCF_SetChatWindowFontSize(nil, chat, 12)
		else
			FCF_SetChatWindowFontSize(nil, chat, fontSize)
		end
		
		tab:HookScript("OnEnter", function() insidetab = true end)
		tab:HookScript("OnLeave", function() insidetab = false end)	
	end
	
	-- reposition battle.net popup over chat #1
	BNToastFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:Point("BOTTOMLEFT", ChatLBackground, "TOPLEFT", 0, 27)
	end)
end
hooksecurefunc("FCF_OpenNewWindow", SetupChatFont)
hooksecurefunc("FCF_DockFrame", SetupChatFont)

TukuiChat:RegisterEvent("ADDON_LOADED")
TukuiChat:RegisterEvent("PLAYER_ENTERING_WORLD")
TukuiChat:SetScript("OnEvent", function(self, event, ...)
	local addon = ...
	if event == "ADDON_LOADED" then
		if addon == "Blizzard_CombatLog" then
			self:UnregisterEvent("ADDON_LOADED")
			SetupChat(self)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		SetupChatFont(self)
		GeneralDockManager:SetParent(ChatLBackground)
	end
end)

local chat, tab, id, point, button, docked, chatfound
T.RightChat = true
TukuiChat:SetScript("OnUpdate", function(self, elapsed)
	if(self.elapsed and self.elapsed > 1) then
		if InCombatLockdown() or insidetab == true or IsMouseButtonDown("LeftButton") then self.elapsed = 0 return end
		chatfound = false
		for i = 1, NUM_CHAT_WINDOWS do
			chat = _G[format("ChatFrame%d", i)]
			id = chat:GetID()
			point = GetChatWindowSavedPosition(id)
			
			if point == "BOTTOMRIGHT" and chat:IsShown() then
				chatfound = true
				break
			end
		end
		
		T.RightChat = chatfound
		
		if chatfound == true then
			if ChatRBG then ChatRBG:SetAlpha(1) end
			T.RightChatWindowID = id
		else
			if ChatRBG then ChatRBG:SetAlpha(0) end
			T.RightChatWindowID = nil
		end

		
		for i = 1, CreatedFrames do
			chat = _G[format("ChatFrame%d", i)]
			local bg = format("ChatFrame%dBackground", i)
			button = _G[format("ButtonCF%d", i)]
			id = chat:GetID()
			tab = _G[format("ChatFrame%sTab", i)]
			point = GetChatWindowSavedPosition(id)
			_, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)	
			
			if id > NUM_CHAT_WINDOWS then
				if point == nil then
					point = select(1, chat:GetPoint())
				end
				if select(2, tab:GetPoint()):GetName() ~= bg then
					docked = true
				else
					docked = false
				end	
			end
						
			if point == "BOTTOMRIGHT" and chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and id == T.RightChatWindowID then
				if id ~= 2 then
					chat:ClearAllPoints()
					chat:SetPoint("BOTTOMLEFT", ChatRBackground, "BOTTOMLEFT", T.Scale(2), T.Scale(4))
					chat:SetSize(T.Scale(C["chat"].width - 4), T.Scale(C["chat"].height))
				else
					chat:ClearAllPoints()
					chat:SetPoint("BOTTOMLEFT", ChatRBackground, "BOTTOMLEFT", T.Scale(2), T.Scale(4))
					chat:SetSize(T.Scale(C["chat"].width - 4), T.Scale(C["chat"].height - CombatLogQuickButtonFrame_Custom:GetHeight()))				
				end
				FCF_SavePositionAndDimensions(chat)			
				
				tab:SetParent(ChatRBackground)
				chat:SetParent(tab)
			elseif not docked and chat:IsShown() then
				tab:SetParent(UIParent)
				chat:SetParent(UIParent)
			else
				if chat:GetID() ~= 2 and not (id > NUM_CHAT_WINDOWS) then
					chat:ClearAllPoints()
					chat:SetPoint("BOTTOMLEFT", ChatLBackground, "BOTTOMLEFT", T.Scale(2), T.Scale(4))
					chat:SetSize(T.Scale(C["chat"].width - 4), T.Scale(C["chat"].height))
					FCF_SavePositionAndDimensions(chat)		
				end
				chat:SetParent(ChatLBackground)
				tab:SetParent(GeneralDockManager)
				
			end
		end
		
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end)

-- Setup temp chat (BN, WHISPER) when needed.
local function SetupTempChat()
	local frame = FCF_GetCurrentChatFrame()
	
	-- do a check if we already did a skinning earlier for this temp chat frame
	if frame.skinned then return end

	-- style it
	SetChatStyle(frame)
end
hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

------------------------------------------------------------------------
-- Animation Functions (Credit AlleyCat, Hydra)
------------------------------------------------------------------------

local ChatCombatHider = CreateFrame("Frame")
ChatCombatHider:RegisterEvent("PLAYER_REGEN_ENABLED")
ChatCombatHider:RegisterEvent("PLAYER_REGEN_DISABLED")
ChatCombatHider:SetScript("OnEvent", function(self, event)
	if C["chat"].combathide ~= "Left" and C["chat"].combathide ~= "Right" and C["chat"].combathide ~= "Both" then self:UnregisterAllEvents() return end
	if (C["chat"].combathide == "Right" or C["chat"].combathide == "Both") and T.RightChat ~= true then return end
	
	if event == "PLAYER_REGEN_DISABLED" then
		if C["chat"].combathide == "Both" then	
			if T.ChatRIn ~= false then
				ChatRBackground:Hide()			
				T.ChatRightShown = false
				T.ChatRIn = false
				TukuiInfoRightRButton.text:SetTextColor(unpack(C["media"].txtcolor))
			end
			if T.ChatLIn ~= false then
				ChatLBackground:Hide()	
				T.ChatLIn = false
				TukuiInfoLeftLButton.text:SetTextColor(unpack(C["media"].txtcolor))
			end
		elseif C["chat"].combathide == "Right" then
			if T.ChatRIn ~= false then
				ChatRBackground:Hide()				
				T.ChatRightShown = false
				T.ChatRIn = false
				TukuiInfoRightRButton.text:SetTextColor(unpack(C["media"].txtcolor))
			end		
		elseif C["chat"].combathide == "Left" then
			if T.ChatLIn ~= false then
				ChatLBackground:Hide()
				T.ChatLIn = false
				TukuiInfoLeftLButton.text:SetTextColor(unpack(C["media"].txtcolor))
			end		
		end
	else
		if C["chat"].combathide == "Both" then
			if T.ChatRIn ~= true then
				ChatRBackground:Show()							
				T.ChatRightShown = true
				T.ChatRIn = true
				TukuiInfoRightRButton.text:SetTextColor(1,1,1)
			end
			if T.ChatLIn ~= true then
				ChatLBackground:Show()
				T.ChatLIn = true
				TukuiInfoLeftLButton.text:SetTextColor(1,1,1)
			end
		elseif C["chat"].combathide == "Right" then
			if T.ChatRIn ~= true then
				ChatRBackground:Show()					
				T.ChatRightShown = true
				T.ChatRIn = true
				TukuiInfoRightRButton.text:SetTextColor(1,1,1)
			end		
		elseif C["chat"].combathide == "Left" then
			if T.ChatLIn ~= true then
				ChatLBackground:Show()
				T.ChatLIn = true
				TukuiInfoLeftLButton.text:SetTextColor(1,1,1)
			end		
		end	
	end
end)

T.SetUpAnimGroup(TukuiInfoLeft.shadow)
T.SetUpAnimGroup(TukuiInfoRight.shadow)
local function CheckWhisperWindows(self, event)
	local chat = self:GetName()
	if chat == "ChatFrame1" and T.ChatLIn == false then
		if event == "CHAT_MSG_WHISPER" then
			TukuiInfoLeft.shadow:SetBackdropBorderColor(ChatTypeInfo["WHISPER"].r,ChatTypeInfo["WHISPER"].g,ChatTypeInfo["WHISPER"].b, 1)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			TukuiInfoLeft.shadow:SetBackdropBorderColor(ChatTypeInfo["BN_WHISPER"].r,ChatTypeInfo["BN_WHISPER"].g,ChatTypeInfo["BN_WHISPER"].b, 1)
		end
		TukuiInfoLeft:SetScript("OnUpdate", function(self)
			if not T.ChatLIn then
				T.Flash(self.shadow, 0.5)
			else
				T.StopFlash(self.shadow)
				self:SetScript("OnUpdate", nil)
				self.shadow:SetBackdropBorderColor(0,0,0)
			end
		end)
	elseif T.RightChatWindowID and chat == _G[format("ChatFrame%s", T.RightChatWindowID)]:GetName() and T.RightChat == true and T.ChatRIn == false then
		if event == "CHAT_MSG_WHISPER" then
			TukuiInfoRight.shadow:SetBackdropBorderColor(ChatTypeInfo["WHISPER"].r,ChatTypeInfo["WHISPER"].g,ChatTypeInfo["WHISPER"].b, 1)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			TukuiInfoRight.shadow:SetBackdropBorderColor(ChatTypeInfo["BN_WHISPER"].r,ChatTypeInfo["BN_WHISPER"].g,ChatTypeInfo["BN_WHISPER"].b, 1)
		end
		TukuiInfoRight:SetScript("OnUpdate", function(self)
			if T.RightChatWindowID and chat == _G[format("ChatFrame%s", T.RightChatWindowID)]:GetName() and T.RightChat == true and T.ChatRIn == false then
				T.Flash(self.shadow, 0.5)
			else
				T.StopFlash(self.shadow)
				self:SetScript("OnUpdate", nil)
				self.shadow:SetBackdropBorderColor(0,0,0)
			end
		end)	
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CheckWhisperWindows)	
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", CheckWhisperWindows)