local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
--------------------------------------------------------------------
 -- CURRENCY
--------------------------------------------------------------------

if C["datatext"].currency and C["datatext"].currency > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C["media"].dfont, C["datatext"].fsize, "OUTLINE")
	T.PP(C["datatext"].currency, Text)
	
	local function update()
		local _text = "---"
		for i = 1, MAX_WATCHED_TOKENS do
			local name, count, _, _, _ = GetBackpackCurrencyInfo(i)
			if name and count then
				if(i ~= 1) then _text = _text .. " " else _text = "" end
				words = { strsplit(" ", name) }
				for _, word in ipairs(words) do
					_text = _text .. string.sub(word,1,1)
					_text = T.cStart .. _text
				end
				_text = _text .. "|r: " .. count .. T.cStart
			end
		end
		
		Text:SetText(_text)
	end
	
	local function OnEvent(self, event, ...)
		update()
		self:SetAllPoints(Text)
		Stat:UnregisterEvent("PLAYER_LOGIN")	
	end

	Stat:RegisterEvent("PLAYER_LOGIN")	
	hooksecurefunc("BackpackTokenFrame_Update", update)
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnMouseDown", function()
		-- For now we cannot go directly to the currency tab stupid blizzard erorrs, even this hack for now can still cause
		-- a blank currency window which there is nothing i can do about... 
		ToggleCharacter("PaperDollFrame")
		--ToggleCharacter("TokenFrame")
	end)
end