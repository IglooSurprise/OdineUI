﻿local T, C, L, DB = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

DB["general"] = {
	["autoscale"] = true,                               -- mainly enabled for users that don't want to mess with the config file
	["uiscale"] = 0.72,                                 -- set your value (between 0.64 and 1) of your uiscale if autoscale is off
	["fontscale"] = 12,									-- global font scale most aspect of the ui (UNFINISHED)m
	["resolutionoverride"] = "NONE",					--override lowversion (Low, High)
	["multisampleprotect"] = true,                      -- i don't recommend this because of shitty border but, voila!
	["sharpborders"] = true,							-- Enable use of sharper borders
	["classcolortheme"] = false,						--class colored theme for panels
	["panelheight"] = 23,								-- Height of datatext panels
}

DB["media"] = {
	--fonts
	["font"] = "Tukui Font",
	["uffont"] = "Tukui UF",
	["dmgfont"] = "Tukui Combat",
	["cfont"] = "Tukui Font",
	["dfont"] = "Tukui UF",
	
	-- textures
	["normTex"] = "Tukui Norm",
	["glowTex"] = "Tukui Glow",
	["glossTex"] = "Tukui Glossy",
	["blank"] = "Tukui Blank",
	
	["oTex"] = [[Interface\AddOns\Tukui\medias\textures\overTex]],

	["striped"] = [[Interface\AddOns\Tukui\medias\textures\Striped]], -- unitframes combo points
	["copyicon"] = [[Interface\AddOns\Tukui\medias\textures\copy]], -- copy icon
	["buttonhover"] = [[Interface\AddOns\Tukui\medias\textures\button_hover]],
	
	["bordercolor"] = { .23, .23, .23 }, -- border color of panels
	["backdropcolor"] = { .1, .1, .1 }, -- background color of panels
	["backdropfadecolor"] = { .1, .1, .1, 0.8 }, --this is always the same as the backdrop color with an alpha of 0.9, see colors.lua
	
	
	["txtcolor"] = { .09, .51, .81 },					-- derp shit
	
	-- sound
	["whisper"] = "Tukui Whisper",
	["warning"] = "Tukui Warning",
}

DB["unitframes"] = {
	-- Gen.
	["enable"] = true,                                  -- do i really need to explain this?
	["fontsize"] = 12,									-- font size for most unitframes
	
	-- Colors
	["enemyhcolor"] = false,                            -- enemy target (players) color by hostility, very useful for healer.
	["healthColor"] = { .07, .07, .07 },					-- option only works if theme is NOT set to classcolor
	["healthBgColor"] = { .7, .1, .1 },					-- see above derp
	
	-- Castbar
	["unitcastbar"] = true, 
	["cblatency"] = false, 
	["cbicons"] = true, 
	["cbticks"] = true,
	["cbinside"] = false,								-- castbar inside unit frames, disable for outside of them (will not work if using large player castbar)
	["large_player"] = true,							-- enable larger player castbar above actionbar
	["castbarcolor"] = {.20, .21, .19}, 				-- Color of player castbar
	["nointerruptcolor"] = {0.78, 0.25, 0.25},			-- Color of target castbar
		
	-- Auras
	["auratimer"] = true,                               -- enable timers on buffs/debuffs
	["auratextscale"] = 11,                             -- the font size of buffs/debuffs timers on unitframes
	["playerauras"] = true,                            -- enable auras
	["playershowonlydebuffs"] = true, 					-- only show the players debuffs over the player frame, not buffs (playerauras must be true) (CODE NOT FINISHED)
	["playerdebuffsonly"] = true,						-- show the players debuffs on target, and any debuff in the whitelist.
	["targetauras"] = true,                             -- enable auras on target unit frame
	["totdebuffs"] = true,                             -- enable tot debuffs (high reso only)
	["focusdebuffs"] = true,                            -- enable focus debuffs
	["arenabuffs"] = true,								-- enable arena buffs
	["arenadebuffs"] = true, 							-- enable debuff filter for arena frames
	["bossbuffs"] = true,								-- enable boss buffs
	["bossdebuffs"] = true,								-- enable boss debuffs
	["buffsperrow"] = 8,                  				-- set amount of buffs shown (player/target only)
	["debuffsperrow"] = 7,								-- set amount of debuffs shown (player/target only)	
	
	-- Misc.
	["charportrait"] = true,                           -- do i really need to explain this?
	["showtotalhpmp"] = false,                          -- change the display of info text on player and target with XXXX/Total.
	["targetpowerpvponly"] = true,                      -- enable power text on pvp target only
	["showsmooth"] = true,                              -- enable smooth bar
	["lowThreshold"] = 20,                              -- global low threshold, for low mana warning.
	["combatfeedback"] = false,                          -- enable combattext on player and target.
	["playeraggro"] = true,                             -- color player border to red if you have aggro on current target.
	["debuffhighlight"] = false,						-- Enable highlighting unitframes when there is a debuff you can dispel
	
	-- misc
	["vengeance"] = true,								-- vengeance bar for tanks
	["swingbar"] = false,								-- swing bar
	["percentage"] = true,            					-- shows a hp/pp percent number next to a unitframe on selected frames

	-- Party / Raid
		-- Gen.
		["showrange"] = true,                               -- show range opacity on raidframes
		["raidalphaoor"] = 0.7,                             -- alpha of unitframes when unit is out of range
		["showplayerinparty"] = true,                      -- show my player frame in party
		["showsymbols"] = true,	                            -- show symbol.
		["aggro"] = true,                                   -- show aggro on all raids layouts
		["raidunitdebuffwatch"] = true,                     -- track important spell to watch in pve for grid mode.
		["healcomm"] = true,                               -- enable healprediction support.
		["buffindicatorsize"] = 6,							-- size of the buff indicator on raid/party frames

		-- Heal
		["healthvertical"] = false,
		["healthdeficit"] = false,	
		
		-- Dps
		["hidepower"] = false,

	-- Extra Frames
	["maintank"] = false,                               -- enable maintank
	["mainassist"] = false,                             -- enable mainassist
	["showboss"] = true,                                -- enable boss unit frames for PVELOL encounters.
	
	-- priest only plugin
	["weakenedsoulbar"] = true,                         -- show weakened soul bar
	
	-- class bar
	["classbar"] = true,                                -- enable tukui classbar over player unit, false disables all classes
}

DB["arena"] = {
	["unitframes"] = true,                              -- enable tukz arena unitframes (requirement : tukui unitframes enabled)
}

DB["auras"] = {
	["player"] = true,                                  -- enable tukui buffs/debuffs
}

DB["actionbar"] = {
	["enable"] = true,                     -- enable elvui action bars
	["v12"] = false,							-- enable V12 actionbar style
	["hotkey"] = true,                     -- enable hotkey display because it was a lot requested
	["rightbarmouseover"] = false,         -- enable right bars on mouse over
	["shapeshiftmouseover"] = false,       -- enable shapeshift or totembar on mouseover
	["hideshapeshift"] = false,            -- hide shapeshift or totembar because it was a lot requested.
	["showgrid"] = true,                   -- show grid on empty button
	["bottompetbar"] = false,				-- position petbar below the actionbars instead of the right side
	["buttonsize"] = 30,					--size of action buttons
	["buttonspacing"] = 4,					--spacing of action buttons
	["petbuttonsize"] = 30,					--size of pet/stance buttons
	["swaptopbottombar"] = false,			--swap the main actionbar position with the bottom actionbar
	["macrotext"] = false,					--show macro text on actionbuttons
	["verticalstance"] = false,				--make stance bar vertical
	["microbar"] = false,					--enable microbar display
	["mousemicro"] = false,					--only show microbar on mouseover
	
	["vertical_rightbars"] = true,				-- horizontal rightbars
	
	["enablecd"] = true,                     -- do i really need to explain this?
	["treshold"] = 3,                      -- show decimal under X seconds and text turn red
	["expiringcolor"] = { r = 1, g = 0, b = 0 },		--color of expiring seconds turns to 
	["secondscolor"] = { r = 1, g = 1, b = 0 },			--seconds color
	["minutescolor"] = { r = 1, g = 1, b = 1 },			-- minutes color
	["hourscolor"] = { r = 0.4, g = 1, b = 1 },			-- hours color
	["dayscolor"] = { r = 0.4, g = 0.4, b = 1 },		-- days color	
}

DB["bags"] = {
	["enable"] = true,                                  -- enable an all in one bag mod that fit tukui perfectly
	["placement"] = 1,									-- allows you to position bag windows over chat windows or right above them! (option 1 - over chat windows, option 2 - above chat windows)
}

DB["map"] = {
	["enable"] = true,                                  -- reskin the map to fit tukui
}

DB["loot"] = {
	["lootframe"] = true,                               -- reskin the loot frame to fit tukui
	["rolllootframe"] = true,                           -- reskin the roll frame to fit tukui
	["autogreed"] = true,                               -- auto-dez or auto-greed item at max level, auto-greed Frozen orb
}

DB["cooldown"] = {
	["enable"] = true,                                  -- do i really need to explain this?
	["treshold"] = 6,                                   -- show decimal under X seconds and text turn red
}

DB["datatext"] = {
	["armor"] = 0,                                      -- show your armor value against the level mob you are currently targeting
	["avd"] = 0,                                        -- show your current avoidance against the level of the mob your targeting
	["bags"] = 6,                                       -- show space used in bags on panels
	["crit"] = 10,                                       -- show your crit rating on panels.
	["currency"] = 2,                                   -- show your tracked currency on panels
	["dps_text"] = 0,                                   -- show a dps meter on panels
	["dur"] = 9,                                        -- show your equipment durability on panels.
	["friends"] = 3,                                    -- show number of friends connected.
	["gold"] = 5,                                       -- show your current gold on panels
	["guild"] = 1,                                      -- show number on guildmate connected on panels
	["haste"] = 11,                                      -- show your haste rating on panels.
	["hit"] = 0,
	["hps_text"] = 0,                                   -- show a heal meter on panels
	["mastery"] = 4,
	["spec"] = 8,             							-- show your active talent group and allow you to switch on panels.
	["power"] = 7,                                      -- show your attackpower/spellpower/healpower/rangedattackpower whatever stat is higher gets displayed
	["regen"] = 0,										-- display your mana regen

	["battleground"] = true,                            -- enable 3 stats in battleground only that replace stat1,stat2,stat3.
	["statblock"] = true,								-- enables stat block at top left
	["location"] = true,								-- enables location panel at top middle
	["time24"] = false,                                  -- set time to 24h format.
	["localtime"] = true,                              -- set time to local time instead of server time.
	["bars"] = true,									-- enable rep/exp bars under minimap
		["bar_text"] = false,							-- display text in rep/exp bars
	["fsize"] = 15,										-- default font size
	
	["classcolor"] = true,
		["color"] = { .156, .149, .149 },
}

DB["misc"] = {
	["announceint"] = true,								-- announce your interrupts in chat
	["epgp"] = false,									-- enable to show epgp points in guild datatext
	["viewport"] = false,								-- enable viewport
		--["vp_height"] = T.buttonsize - 9,
	["autoquest"] = false,								-- enable automatic turn in/autoaccept quests
}

DB["chat"] = {
	["enable"] = true,                                  -- blah
	["whispersound"] = true,                            -- play a sound when receiving whisper
	["height"] = 150,									-- adjust the chatframe height
	["width"] = 357,									-- adjust the chatframe width
	["background"] = true,								-- chat frame backgrounds 150
	["fading"] = false,									-- allow chat windows to fade out
	["justifyRight"] = false,							-- when set to true text in right chat box will be aligned towards the right side of the chat box
	["fsize"] = 12,										-- default font size
	["combathide"] = "NONE",							-- Set to "Left", "Right", "Both", or "NONE"
}

DB["nameplate"] = {
	["enable"] = true,                                  -- enable nice skinned nameplates that fit into tukui
	["showhealth"] = true,				                -- show health text on nameplate
	["enhancethreat"] = true,			                -- threat features based on if your a tank or not
	["combat"] = false,					                -- only show enemy nameplates in-combat.
	["goodcolor"] = {75/255,  175/255, 76/255},	        -- good threat color (tank shows this with threat, everyone else without)
	["badcolor"] = {0.78, 0.25, 0.25},			        -- bad threat color (opposite of above)
	["transitioncolor"] = {218/255, 197/255, 92/255},	-- threat color when gaining threat
	["trackcc"] = true,									--track all CC debuffs
	["trackdebuffs"] = true,							--track players debuffs only (debuff list derived from classtimer spell list)
}

DB["tooltip"] = {
	["enable"] = true,                                  -- true to enable this mod, false to disable
	["hidecombat"] = false,                             -- hide bottom-right tooltip when in combat
	["hidecombatraid"] = false,							-- only hide in combat in a raid instance
	["hidebuttons"] = false,                            -- always hide action bar buttons tooltip.
	["hideuf"] = false,                                 -- hide tooltip on unitframes
	["cursor"] = false,                                 -- tooltip via cursor only
}

DB["merchant"] = {
	["sellgrays"] = true,                               -- automaticly sell grays?
	["autorepair"] = false,                              -- automaticly repair?
	["sellmisc"] = true,                                -- sell defined items automatically
}

DB["error"] = {
	["enable"] = true,                                  -- true to enable this mod, false to disable
}

DB["invite"] = { 
	["autoaccept"] = true,                              -- auto-accept invite from guildmate and friends.
}

DB["buffreminder"] = {
	["enable"] = true,                                  -- this is now the new innerfire warning script for all armor/aspect class.
	["sound"] = true,                                   -- enable warning sound notification for reminder.
}

-- Addons skins by Darth Android
DB["addonskins"] = {
	["enable"] = true,
		["reforge"] = true,
		["calendar"] = true,
		["achievement"] = true,
		["lfguild"] = true,
		["inspect"] = true,
		["binding"] = true,
		["gbank"] = true,
		["archaeology"] = true,
		["guildcontrol"] = true,
		["guild"] = true,
		["tradeskill"] = true,
		["raid"] = true,
		["talent"] = true,
		["glyph"] = true,
		["auctionhouse"] = true,
		["barber"] = true,
		["macro"] = true,
		["debug"] = true,
		["trainer"] = true,
		["socket"] = true,
		["achievement_popup"] = true,
		["bgscore"] = true,
		["merchant"] = true,
		["mail"] = true,
		["help"] = true,
		["trade"] = true,
		["gossip"] = true,
		["greeting"] = true,
		["worldmap"] = true,
		["taxi"] = true,
		["lfd"] = true,
		["quest"] = true,
		["petition"] = true,
		["dressingroom"] = true,
		["pvp"] = true,
		["nonraid"] = true,
		["friends"] = true,
		["spellbook"] = true,
		["character"] = true,
		["misc"] = true,
		["lfr"] = true,
		["tabard"] = true,
		["guildregistrar"] = true,
	["kle"] = true,										-- skins KLE
	["tinydps"] = true,									-- skins TinyDPS
	["dbm"] = true,										-- skins DBM
	["recount"] = true,									-- skins Recount 
	["omen"] = true,									-- skins Omen
	["skada"] = true,									-- skins skada
	["coolline"] = true,								-- skins CoolLine
	["bigwigs"] = true,									-- skins BigWigs
	["embed"] = "NONE",
}

DB["classtimer"] = {
	["enable"] = true,
	["bar_height"] = 16,
	["bar_spacing"] = 5,
	["icon_position"] = 2, -- 0 = left, 1 = right, 2 = Outside left, 3 = Outside Right
	["layout"] = 4, --1 - both player and target auras in one frame right above player frame, 2 - player and target auras separated into two frames above player frame, 3 - player, target and trinket auras separated into three frames above player frame, 4 - player and trinket auras are shown above player frame and target auras are shown above target frame, 5 - Everything above player frame, no target debuffs.
	["showspark"] = true,
	["cast_suparator"] = true,
	
	["classcolor"] = false,
	["buffcolor"] = { r = .05, g = .05, b = .05 },
	["debuffcolor"] = { r = 0.78, g = 0.25, b = 0.25 },
	["proccolor"] = { r = 0.84, g = 0.75, b = 0.65 },
	
	["gen_font"] = "Tukui UF",
	["gen_size"] = 13,
}