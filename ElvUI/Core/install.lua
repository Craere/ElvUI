local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local _G = _G
local format = string.format
--WoW API / Variables
local ChangeChatColor = ChangeChatColor
local ChatFrame_ActivateCombatMessages = ChatFrame_ActivateCombatMessages
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local CreateFrame = CreateFrame
local FCF_DockFrame, FCF_UnDockFrame = FCF_DockFrame, FCF_UnDockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_SetLocked = FCF_SetLocked
local FCF_SetWindowName = FCF_SetWindowName
local GetScreenWidth = GetScreenWidth
local IsAddOnLoaded = IsAddOnLoaded
local PlaySoundFile = PlaySoundFile
local ReloadUI = ReloadUI
local SetCVar = SetCVar
local UIFrameFadeOut = UIFrameFadeOut

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS

local CHAT_LABEL, CLASS, CONTINUE, PREV = CHAT_LABEL, CLASS, CONTINUE, PREV
local GUILD_EVENT_LOG = GUILD_EVENT_LOG
local LOOT, GENERAL, TRADE = LOOT, GENERAL, TRADE
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS

local CURRENT_PAGE = 0
local MAX_PAGE = 8

local function FCF_ResetChatWindows()
	ChatFrame1:ClearAllPoints()
	E:Point(ChatFrame1, "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, 95)
	E:Size(ChatFrame1, 430, 120)
	ChatFrame1.isInitialized = 0
	FCF_SetButtonSide(ChatFrame1, "left")
	FCF_SetChatWindowFontSize(ChatFrame1, 14)
	FCF_SetWindowName(ChatFrame1, GENERAL)
	FCF_SetWindowColor(ChatFrame1, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b)
	FCF_SetWindowAlpha(ChatFrame1, DEFAULT_CHATFRAME_ALPHA)
	FCF_UnDockFrame(ChatFrame1)
	FCF_ValidateChatFramePosition(ChatFrame1)
	ChatFrame_RemoveAllChannels(ChatFrame1)
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	DEFAULT_CHAT_FRAME = ChatFrame1
	SELECTED_CHAT_FRAME = ChatFrame1
	ChatFrameEditBox.chatFrame = DEFAULT_CHAT_FRAME
	DEFAULT_CHAT_FRAME.editBox = ChatFrameEditBox
	DEFAULT_CHAT_FRAME.chatframe = DEFAULT_CHAT_FRAME

	FCF_SetChatWindowFontSize(ChatFrame2, 14)
	FCF_SetWindowName(ChatFrame2, COMBAT_LOG)
	FCF_SetWindowColor(ChatFrame2, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b)
	FCF_SetWindowAlpha(ChatFrame2, DEFAULT_CHATFRAME_ALPHA)
	ChatFrame_RemoveAllChannels(ChatFrame2)
	ChatFrame_RemoveAllMessageGroups(ChatFrame2)
	FCF_UnDockFrame(ChatFrame2)
	ChatFrame2.isInitialized = 0

	for i = 2, NUM_CHAT_WINDOWS do
		local chatFrame = _G["ChatFrame"..i]
		chatFrame.isInitialized = 0
		FCF_SetTabPosition(chatFrame, 0)
		FCF_Close(chatFrame)
		FCF_UnDockFrame(chatFrame)
		FCF_SetChatWindowFontSize(chatFrame, 14)
		FCF_SetWindowName(chatFrame, "")
		FCF_SetWindowColor(chatFrame, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b)
		FCF_SetWindowAlpha(chatFrame, DEFAULT_CHATFRAME_ALPHA)
		ChatFrame_RemoveAllChannels(chatFrame)
		ChatFrame_RemoveAllMessageGroups(chatFrame)
	end

	ChatFrame1.init = 0
	FCF_DockFrame(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2, 2)
end

local function FCF_StopDragging(chatFrame)
	if not chatFrame then
		return
	end

	chatFrame:StopMovingOrSizing()

	local activeDockRegion = FCF_GetActiveDockRegion()
	if activeDockRegion then
		FCF_DockFrame(chatFrame, activeDockRegion, true)
	else
		FCF_SetTabPosition(chatFrame, 0)
		FCF_ValidateChatFramePosition(chatFrame)
		FCF_SelectDockFrame(DOCKED_CHAT_FRAMES[1])
	end

	MOVING_CHATFRAME = nil
end

local function SetupChat()
	InstallStepComplete.message = L["Chat Set"]
	InstallStepComplete:Show()
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)

	FCF_OpenNewWindow(LOOT)
	FCF_UnDockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	ChatFrame3:Show()

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]

		-- move general bottom left
		if i == 1 then
			frame:ClearAllPoints()
			E:Point(frame, "BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
		elseif i == 3 then
			frame:ClearAllPoints()
			E:Point(frame, "BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
		end

		FCF_StopDragging(frame)

		-- set default Elvui font size
		FCF_SetChatWindowFontSize(frame, 12)

		-- rename windows general because moved to chat #3
		if i == 1 then
			FCF_SetWindowName(frame, GENERAL)
		elseif i == 2 then
			FCF_SetWindowName(frame, GUILD_EVENT_LOG)
		elseif i == 3 then
			FCF_SetWindowName(frame, LOOT.." / "..TRADE)
		end
	end

	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "CHANNEL")

	ChatFrame_ActivateCombatMessages(ChatFrame2)

	ChatFrame_AddChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveMessageGroup(ChatFrame1, "SKILL")
	ChatFrame_RemoveMessageGroup(ChatFrame1, "LOOT")
	ChatFrame_RemoveMessageGroup(ChatFrame1, "MONEY")
	ChatFrame_RemoveMessageGroup(ChatFrame1, "COMBAT_FACTION_CHANGE")
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)

	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddChannel(ChatFrame3, TRADE)

	--Adjust Chat Colors
	--General
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255)
	--Trade
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255)
	--Local Defense
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255)

	if E.Chat then
		E.Chat:PositionChat(true)
		if E.db["RightChatPanelFaded"] then
			RightChatToggleButton:Click()
		end

		if E.db["LeftChatPanelFaded"] then
			LeftChatToggleButton:Click()
		end
	end
end

local function SetupCVars()
	SHOW_NEWBIE_TIPS = 0
	SetCVar("showLootSpam", 1)
	SetCVar("UberTooltips", 1)
	ALWAYS_SHOW_MULTIBARS = 1
	LOCK_ACTIONBAR = 1
	SetActionBarToggles(1, 0, 1, 1)
	TutorialFrame_HideAllAlerts()
	ClearTutorials()

	InstallStepComplete.message = L["CVars Set"]
	InstallStepComplete:Show()
end

function E:GetColor(r, b, g, a)
	return {r = r, b = b, g = g, a = a}
end

function E:SetupTheme(theme, noDisplayMsg)
	local classColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
	E.private.theme = theme

	--Set colors
	if theme == "classic" then
		E.db.general.bordercolor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.06, .06, .06, .8)

		E.db.unitframe.colors.borderColor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.unitframe.colors.healthclass = false
		E.db.unitframe.colors.health = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.auraBarBuff = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.castColor = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.castClassColor = false
	elseif theme == "class" then
		E.db.general.bordercolor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.06, .06, .06, .8)
		E.db.unitframe.colors.borderColor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.unitframe.colors.auraBarBuff = E:GetColor(classColor.r, classColor.b, classColor.g)
		E.db.unitframe.colors.healthclass = true
		E.db.unitframe.colors.castClassColor = true
	else
		E.db.general.bordercolor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.1, .1, .1))
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.054, .054, .054, .8)
		E.db.unitframe.colors.borderColor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.1, .1, .1))
		E.db.unitframe.colors.auraBarBuff = E:GetColor(.1, .1, .1)
		E.db.unitframe.colors.healthclass = false
		E.db.unitframe.colors.health = E:GetColor(.1, .1, .1)
		E.db.unitframe.colors.castColor = E:GetColor(.1, .1, .1)
		E.db.unitframe.colors.castClassColor = false
	end

	--Value Color
	if theme == "class" then
		E.db.general.valuecolor = E:GetColor(classColor.r, classColor.b, classColor.g)
	else
		E.db.general.valuecolor = E:GetColor(.09, .819, .513)
	end

	if not noDisplayMsg then
		E:UpdateAll(true)
	end

	if InstallStatus then
		if InstallStepComplete and not noDisplayMsg then
			InstallStepComplete.message = L["Theme Set"]
			InstallStepComplete:Show()
		end
	end
end

function E:SetupResolution(noDataReset)
	if not noDataReset then
		E:ResetMovers("")
	end

	if self == "low" then
		if not E.db.movers then E.db.movers = {} end
		if not noDataReset then
			E.db.chat.panelWidth = 400
			E.db.chat.panelHeight = 180

			E.db.bags.bagWidth = 394
			E.db.bags.bankWidth = 394

			E:CopyTable(E.db.actionbar, P.actionbar)

			E.db.actionbar.bar1.heightMult = 2
			E.db.actionbar.bar2.enabled = true
			E.db.actionbar.bar3.enabled = false
			E.db.actionbar.bar5.enabled = false
		end

		if not noDataReset then
			E.db.auras.wrapAfter = 10
		end

		E.db.movers.ElvAB_2 = "CENTER,ElvUIParent,BOTTOM,0,56.18"

		if not noDataReset then
			E:CopyTable(E.db.unitframe.units, P.unitframe.units)

			E.db.unitframe.fontSize = 11

			E.db.unitframe.units.player.width = 200
			E.db.unitframe.units.player.castbar.width = 200
			E.db.unitframe.units.player.classbar.fill = "fill"
			E.db.unitframe.units.player.health.text_format = "[healthcolor][health:current]"

			E.db.unitframe.units.target.width = 200
			E.db.unitframe.units.target.castbar.width = 200
			E.db.unitframe.units.target.health.text_format = "[healthcolor][health:current]"

			E.db.unitframe.units.pet.power.enable = false
			E.db.unitframe.units.pet.width = 200
			E.db.unitframe.units.pet.height = 26

			E.db.unitframe.units.targettarget.debuffs.enable = false
			E.db.unitframe.units.targettarget.power.enable = false
			E.db.unitframe.units.targettarget.width = 200
			E.db.unitframe.units.targettarget.height = 26
		end

		local isPixel = E.private.general.pixelPerfect
		local xOffset = isPixel and 103 or 106
		local yOffset = isPixel and 125 or 135
		local yOffsetSmall = isPixel and 76 or 80

		E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,"..-xOffset..","..yOffset
		E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,"..xOffset..","..yOffsetSmall
		E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,"..xOffset..","..yOffset
		E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,"..-xOffset..","..yOffsetSmall
		E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"

		E.db.lowresolutionset = true
	elseif not noDataReset then
		E.db.chat.panelWidth = P.chat.panelWidth
		E.db.chat.panelHeight = P.chat.panelHeight

		E.db.bags.bagWidth = P.bags.bagWidth
		E.db.bags.bankWidth = P.bags.bankWidth

		E:CopyTable(E.db.actionbar, P.actionbar)
		E:CopyTable(E.db.unitframe.units, P.unitframe.units)
		E.db.auras.wrapAfter = P.auras.wrapAfter

		E.db.lowresolutionset = nil
	end

	if not noDataReset and E.private.theme then
		E:SetupTheme(E.private.theme, true)
	end

	E:UpdateAll(true)

	if InstallStepComplete and not noDataReset then
		InstallStepComplete.message = L["Resolution Style Set"]
		InstallStepComplete:Show()
	end
end

function E:SetupLayout(layout, noDataReset)
	--Unitframes
	if not noDataReset then
		E:CopyTable(E.db.unitframe.units, P.unitframe.units)
	end

	if not noDataReset then
		E:ResetMovers("")
		if not E.db.movers then E.db.movers = {} end

		E.db.actionbar.bar2.enabled = E.db.lowresolutionset
		if E.PixelMode then
			E.db.movers.ElvAB_2 = "BOTTOM,ElvUIParent,BOTTOM,0,38"
		else
			E.db.movers.ElvAB_2 = "BOTTOM,ElvUIParent,BOTTOM,0,40"
		end
		if not E.db.lowresolutionset then
			E.db.actionbar.bar3.buttons = 6
			E.db.actionbar.bar5.buttons = 6
			E.db.actionbar.bar4.enabled = true
		end
	end

	if layout == "healer" then
		if not IsAddOnLoaded("Clique") then
			E:StaticPopup_Show("CLIQUE_ADVERT")
		end

		if not noDataReset then
			E.db.unitframe.units.raid.horizontalSpacing = 9
			E.db.unitframe.units.raid.rdebuffs.enable = false
			E.db.unitframe.units.raid.verticalSpacing = 9
			E.db.unitframe.units.raid.debuffs.sizeOverride = 16
			E.db.unitframe.units.raid.debuffs.enable = true
			E.db.unitframe.units.raid.debuffs.anchorPoint = "TOPRIGHT"
			E.db.unitframe.units.raid.debuffs.xOffset = -4
			E.db.unitframe.units.raid.debuffs.yOffset = -7
			E.db.unitframe.units.raid.height = 45
			E.db.unitframe.units.raid.buffs.noConsolidated = false
			E.db.unitframe.units.raid.buffs.xOffset = 50
			E.db.unitframe.units.raid.buffs.yOffset = -6
			E.db.unitframe.units.raid.buffs.clickThrough = true
			E.db.unitframe.units.raid.buffs.noDuration = false
			E.db.unitframe.units.raid.buffs.playerOnly = false
			E.db.unitframe.units.raid.buffs.perrow = 1
			E.db.unitframe.units.raid.buffs.useFilter = "TurtleBuffs"
			E.db.unitframe.units.raid.buffs.sizeOverride = 22
			E.db.unitframe.units.raid.buffs.useBlacklist = false
			E.db.unitframe.units.raid.buffs.enable = true
			E.db.unitframe.units.raid.growthDirection = "LEFT_UP"

			E.db.unitframe.units.party.growthDirection = "LEFT_UP"
			E.db.unitframe.units.party.horizontalSpacing = 9
			E.db.unitframe.units.party.verticalSpacing = 9
			E.db.unitframe.units.party.debuffs.sizeOverride = 16
			E.db.unitframe.units.party.debuffs.enable = true
			E.db.unitframe.units.party.debuffs.anchorPoint = "TOPRIGHT"
			E.db.unitframe.units.party.debuffs.xOffset = -4
			E.db.unitframe.units.party.debuffs.yOffset = -7
			E.db.unitframe.units.party.height = 45
			E.db.unitframe.units.party.buffs.noConsolidated = false
			E.db.unitframe.units.party.buffs.xOffset = 50
			E.db.unitframe.units.party.buffs.yOffset = -6
			E.db.unitframe.units.party.buffs.clickThrough = true
			E.db.unitframe.units.party.buffs.noDuration = false
			E.db.unitframe.units.party.buffs.playerOnly = false
			E.db.unitframe.units.party.buffs.perrow = 1
			E.db.unitframe.units.party.buffs.useFilter = "TurtleBuffs"
			E.db.unitframe.units.party.buffs.sizeOverride = 22
			E.db.unitframe.units.party.buffs.useBlacklist = false
			E.db.unitframe.units.party.buffs.enable = true
			E.db.unitframe.units.party.roleIcon.position = "BOTTOMRIGHT"
			E.db.unitframe.units.party.health.text_format = "[healthcolor][health:deficit]"
			E.db.unitframe.units.party.health.position = "BOTTOM"
			E.db.unitframe.units.party.GPSArrow.size = 40
			E.db.unitframe.units.party.width = 80
			E.db.unitframe.units.party.height = 45
			E.db.unitframe.units.party.name.text_format = "[namecolor][name:short]"
			E.db.unitframe.units.party.name.position = "TOP"
			E.db.unitframe.units.party.power.text_format = ""

			-- E.db.unitframe.units.raid40.height = 30
			-- E.db.unitframe.units.raid40.growthDirection = "LEFT_UP"

			E.db.unitframe.units.party.health.frequentUpdates = true
			E.db.unitframe.units.raid.health.frequentUpdates = true
			-- E.db.unitframe.units.raid40.health.frequentUpdates = true

			E.db.unitframe.units.party.healPrediction = true
			E.db.unitframe.units.raid.healPrediction = true
			-- E.db.unitframe.units.raid40.healPrediction = true

			E.db.unitframe.units.player.castbar.insideInfoPanel = false
			E.db.actionbar.bar2.enabled = true
			if not E.db.lowresolutionset then
				E.db.actionbar.bar3.buttons = 12
				E.db.actionbar.bar5.buttons = 12
				E.db.actionbar.bar4.enabled = false
				if not E.PixelMode then
					E.db.actionbar.bar1.heightMult = 2
				end
			end
		end

		if not E.db.movers then E.db.movers = {} end
		local xOffset = ((GetScreenWidth() - E.diffGetLeft - E.diffGetRight) * 0.34375)

		if E.PixelMode then
			E.db.movers.ElvAB_3 = "BOTTOM,ElvUIParent,BOTTOM,312,4"
			E.db.movers.ElvAB_5 = "BOTTOM,ElvUIParent,BOTTOM,-312,4"
			E.db.movers.ElvUF_PartyMover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"
			E.db.movers.ElvUF_RaidMover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"

			E.db.movers.ElvUF_Raid40Mover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"

			if not E.db.lowresolutionset then
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,278,132"
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-278,132"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,176"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,132"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,432"
			else
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-102,182"
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,182"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,120"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-102,120"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
			end
		else
			E.db.movers.ElvAB_3 = "BOTTOM,ElvUIParent,BOTTOM,332,4"
			E.db.movers.ElvAB_5 = "BOTTOM,ElvUIParent,BOTTOM,-332,4"
			E.db.movers.ElvUF_PartyMover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"
			E.db.movers.ElvUF_RaidMover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"
			E.db.movers.ElvUF_Raid40Mover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"

			if not E.db.lowresolutionset then
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,307,145"
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-307,145"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,186"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,145"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,432"
			else
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-118,182"
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,182"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,120"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-118,120"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
			end
		end
	elseif E.db.lowresolutionset then
		if not E.db.movers then E.db.movers = {} end
		if E.PixelMode then
			E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-102,135"
			E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,135"
			E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,80"
			E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-102,80"
			E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
		else
			E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-118,142"
			E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,142"
			E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,84"
			E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-118,84"
			E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
		end
	end

	if layout ~= "healer" and not E.db.lowresolutionset then
		E.db.actionbar.bar1.heightMult = 1
	end

	if E.db.lowresolutionset and not noDataReset then
		E.db.unitframe.units.player.width = 200
		if layout ~= "healer" then
			E.db.unitframe.units.player.castbar.width = 200
		end
		E.db.unitframe.units.player.classbar.fill = "fill"

		E.db.unitframe.units.target.width = 200
		E.db.unitframe.units.target.castbar.width = 200

		E.db.unitframe.units.pet.power.enable = false
		E.db.unitframe.units.pet.width = 200
		E.db.unitframe.units.pet.height = 26

		E.db.unitframe.units.targettarget.debuffs.enable = false
		E.db.unitframe.units.targettarget.power.enable = false
		E.db.unitframe.units.targettarget.width = 200
		E.db.unitframe.units.targettarget.height = 26
	end

	if layout == "dpsCaster" or layout == "healer" or (layout == "dpsMelee" and E.myclass == "HUNTER") then
		if not E.db.movers then E.db.movers = {} end
		E.db.unitframe.units.player.castbar.width = E.PixelMode and 406 or 436
		E.db.unitframe.units.player.castbar.height = 28
		E.db.unitframe.units.player.castbar.insideInfoPanel = false
		local yOffset = 80
		if not E.db.lowresolutionset then
			if layout ~= "healer" then
				yOffset = 42

				if E.PixelMode then
					E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-278,110"
					E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,278,110"
					E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,110"
					E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,150"
				else
					E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-307,110"
					E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,307,110"
					E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,110"
					E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,150"
				end
			else
				yOffset = 76
			end
		elseif E.db.lowresolutionset then
			if E.PixelMode then
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-102,182"
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,182"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,120"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-102,120"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
			else
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-118,182"
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,182"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,120"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-118,120"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
			end
		end

		if E.PixelMode then
			E.db.movers.ElvUF_PlayerCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,0,"..yOffset
		else
			E.db.movers.ElvUF_PlayerCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,-2,"..(yOffset + 5)
		end
	elseif (layout == "dpsMelee" or layout == "tank") and not E.db.lowresolutionset and not E.PixelMode then
		E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-307,76"
		E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,307,76"
		E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,76"
		E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,115"
	end

	if not noDataReset then
		E:CopyTable(E.db.datatexts.panels, P.datatexts.panels)
		if layout == "tank" then
			E.db.datatexts.panels.LeftChatDataPanel.left = "Armor"
			E.db.datatexts.panels.LeftChatDataPanel.right = "Avoidance"
		elseif layout == "healer" or layout == "dpsCaster" then
			E.db.datatexts.panels.LeftChatDataPanel.left = "Spell/Heal Power"
			E.db.datatexts.panels.LeftChatDataPanel.right = "Haste"
		else
			E.db.datatexts.panels.LeftChatDataPanel.left = "Attack Power"
			E.db.datatexts.panels.LeftChatDataPanel.right = "Haste"
		end

		if InstallStepComplete then
			InstallStepComplete.message = L["Layout Set"]
			InstallStepComplete:Show()
		end
	end

	E.db.layoutSet = layout

	if not noDataReset and E.private.theme then
		E:SetupTheme(E.private.theme, true)
	end

	E:UpdateAll(true)
end

local function SetupAuras(style)
	local UF = E:GetModule("UnitFrames")

	local frame = UF["player"]
	E:CopyTable(E.db.unitframe.units.player.buffs, P.unitframe.units.player.buffs)
	E:CopyTable(E.db.unitframe.units.player.debuffs, P.unitframe.units.player.debuffs)
	E:CopyTable(E.db.unitframe.units.player.aurabar, P.unitframe.units.player.aurabar)

	if frame then
		UF:Configure_Auras(frame, "Buffs")
		UF:Configure_Auras(frame, "Debuffs")
		-- UF:Configure_AuraBars(frame)
	end

	frame = UF["target"]
	E:CopyTable(E.db.unitframe.units.target.buffs, P.unitframe.units.target.buffs)
	E:CopyTable(E.db.unitframe.units.target.debuffs, P.unitframe.units.target.debuffs)
	E:CopyTable(E.db.unitframe.units.target.aurabar, P.unitframe.units.target.aurabar)
	E.db.unitframe.units.target.smartAuraDisplay = P.unitframe.units.target.smartAuraDisplay

	if frame then
		UF:Configure_Auras(frame, "Buffs")
		UF:Configure_Auras(frame, "Debuffs")
		-- UF:Configure_AuraBars(frame)
	end

	if not style then
		E.db.unitframe.units.player.buffs.enable = true
		E.db.unitframe.units.player.buffs.attachTo = "FRAME"
		E.db.unitframe.units.player.buffs.noDuration = false
		E.db.unitframe.units.player.debuffs.attachTo = "BUFFS"
		E.db.unitframe.units.player.aurabar.enable = false
		E:GetModule("UnitFrames"):CreateAndUpdateUF("player")

		E.db.unitframe.units.target.smartAuraDisplay = "DISABLED"
		E.db.unitframe.units.target.debuffs.enable = true
		E.db.unitframe.units.target.aurabar.enable = false
		E:GetModule("UnitFrames"):CreateAndUpdateUF("target")
	end

	if InstallStepComplete then
		InstallStepComplete.message = L["Auras Set"]
		InstallStepComplete:Show()
	end
end

local function InstallComplete()
	E.private.install_complete = E.version

	ReloadUI()
end

local function ResetAll()
	InstallNextButton:Disable()
	InstallPrevButton:Disable()

	InstallOption1Button:Hide()
	InstallOption1Button:SetScript("OnClick", nil)
	InstallOption1Button:SetText("")

	InstallOption2Button:Hide()
	InstallOption2Button:SetScript("OnClick", nil)
	InstallOption2Button:SetText("")

	InstallOption3Button:Hide()
	InstallOption3Button:SetScript("OnClick", nil)
	InstallOption3Button:SetText("")

	InstallOption4Button:Hide()
	InstallOption4Button:SetScript("OnClick", nil)
	InstallOption4Button:SetText("")

	ElvUIInstallFrame.SubTitle:SetText("")
	ElvUIInstallFrame.Desc1:SetText("")
	ElvUIInstallFrame.Desc2:SetText("")
	ElvUIInstallFrame.Desc3:SetText("")
	E:Size(ElvUIInstallFrame, 550, 400)
end

local function SetPage(PageNum)
	CURRENT_PAGE = PageNum
	ResetAll()
	InstallStatus.anim.progress:SetChange(PageNum)
	InstallStatus.anim.progress:Play()
	InstallStatus.text:SetText(format("%d / %d", CURRENT_PAGE, MAX_PAGE))

	local r, g, b = E:ColorGradient(CURRENT_PAGE / MAX_PAGE, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	ElvUIInstallFrame.Status:SetStatusBarColor(r, g, b)

	local f = ElvUIInstallFrame

	if PageNum == MAX_PAGE then
		InstallNextButton:Disable()
	else
		InstallNextButton:Enable()
	end

	if PageNum == 1 then
		InstallPrevButton:Disable()
	else
		InstallPrevButton:Enable()
	end

	if PageNum == 1 then
		f.SubTitle:SetText(format(L["Welcome to ElvUI version %s!"], E.version))
		f.Desc1:SetText(L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."])
		f.Desc2:SetText(L["The in-game configuration menu can be accessed by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."])
		f.Desc3:SetText(L["Please press the continue button to go onto the next step."])

		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", InstallComplete)
		InstallOption1Button:SetText(L["Skip Process"])
	elseif PageNum == 2 then
		f.SubTitle:SetText(L["CVars"])
		f.Desc1:SetText(L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."])
		f.Desc2:SetText(L["Please click the button below to setup your CVars."])
		f.Desc3:SetText(L["Importance: |cff07D400High|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", SetupCVars)
		InstallOption1Button:SetText(L["Setup CVars"])
	elseif PageNum == 3 then
		f.SubTitle:SetText(CHAT_LABEL)
		f.Desc1:SetText(L["This part of the installation process sets up your chat windows names, positions and colors."])
		f.Desc2:SetText(L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", SetupChat)
		InstallOption1Button:SetText(L["Setup Chat"])
	elseif PageNum == 4 then
		f.SubTitle:SetText(L["Theme Setup"])
		f.Desc1:SetText(L["Choose a theme layout you wish to use for your initial setup."])
		f.Desc2:SetText(L["You can always change fonts and colors of any element of ElvUI from the in-game configuration."])
		f.Desc3:SetText(L["Importance: |cffFF0000Low|r"])

		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", function() E:SetupTheme("classic") end)
		InstallOption1Button:SetText(L["Classic"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript("OnClick", function() E:SetupTheme("default") end)
		InstallOption2Button:SetText(L["Dark"])
		InstallOption3Button:Show()
		InstallOption3Button:SetScript("OnClick", function() E:SetupTheme("class") end)
		InstallOption3Button:SetText(CLASS)
	elseif PageNum == 5 then
		f.SubTitle:SetText(L["Resolution"])
		f.Desc1:SetText(format(L["Your current resolution is %s, this is considered a %s resolution."], E.resolution, E.lowversion == true and L["low"] or L["high"]))
		if E.lowversion then
			f.Desc2:SetText(L["This resolution requires that you change some settings to get everything to fit on your screen."].." "..L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."].." "..L["You may need to further alter these settings depending how low you resolution is."])
			f.Desc3:SetText(L["Importance: |cff07D400High|r"])
		else
			f.Desc2:SetText(L["This resolution doesn't require that you change settings for the UI to fit on your screen."].." "..L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."].." "..L["This is completely optional."])
			f.Desc3:SetText(L["Importance: |cffFF0000Low|r"])
		end

		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", function() E.SetupResolution("high") end)
		InstallOption1Button:SetText(L["High Resolution"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript("OnClick", function() E.SetupResolution("low") end)
		InstallOption2Button:SetText(L["Low Resolution"])
	elseif PageNum == 6 then
		f.SubTitle:SetText(L["Layout"])
		f.Desc1:SetText(L["You can now choose what layout you wish to use based on your combat role."])
		f.Desc2:SetText(L["This will change the layout of your unitframes and actionbars."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", function() E.db.layoutSet = nil E:SetupLayout("tank") end)
		InstallOption1Button:SetText(L["Tank"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript("OnClick", function() E.db.layoutSet = nil E:SetupLayout("healer") end)
		InstallOption2Button:SetText(L["Healer"])
		InstallOption3Button:Show()
		InstallOption3Button:SetScript("OnClick", function() E.db.layoutSet = nil E:SetupLayout("dpsMelee") end)
		InstallOption3Button:SetText(L["Physical DPS"])
		InstallOption4Button:Show()
		InstallOption4Button:SetScript("OnClick", function() E.db.layoutSet = nil E:SetupLayout("dpsCaster") end)
		InstallOption4Button:SetText(L["Caster DPS"])
	elseif PageNum == 7 then
		f.SubTitle:SetText(L["Auras"])
		f.Desc1:SetText(L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."])
		f.Desc2:SetText(L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", function() --[[SetupAuras(true)--]] end)
		InstallOption1Button:SetText(L["Aura Bars & Icons"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript("OnClick", function() --[[SetupAuras()--]] end)
		InstallOption2Button:SetText(L["Icons Only"])
	elseif PageNum == 8 then
		f.SubTitle:SetText(L["Installation Complete"])
		f.Desc1:SetText(L["You are now finished with the installation process. If you are in need of technical support please visit us at https://github.com/ElvUI-Vanilla/ElvUI"])
		f.Desc2:SetText(L["Please click the button below so you can setup variables and ReloadUI."])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", InstallComplete)
		InstallOption1Button:SetText(L["Finished"])
		E:Size(ElvUIInstallFrame, 550, 350)
	end
end

local function NextPage()
	if CURRENT_PAGE ~= MAX_PAGE then
		CURRENT_PAGE = CURRENT_PAGE + 1
		SetPage(CURRENT_PAGE)
	end
end

local function PreviousPage()
	if CURRENT_PAGE ~= 1 then
		CURRENT_PAGE = CURRENT_PAGE - 1
		SetPage(CURRENT_PAGE)
	end
end

--Install UI
function E:Install()
	if not InstallStepComplete then
		local imsg = CreateFrame("Frame", "InstallStepComplete", E.UIParent)
		E:Size(imsg, 418, 72)
		E:Point(imsg, "TOP", 0, -190)
		imsg:Hide()
		imsg:SetScript("OnShow", function()
			if this.message then
				PlaySoundFile([[Sound\Interface\LevelUp.wav]])
				this.text:SetText(this.message)
				UIFrameFadeOut(this, 3.5, 1, 0)
				E:Delay(4, function() this:Hide() end)
				this.message = nil
			else
				this:Hide()
			end
		end)

		imsg.firstShow = false

		imsg.text = imsg:CreateFontString(nil, "OVERLAY")
		E:FontTemplate(imsg.text, E["media"].normFont, 32, "OUTLINE")
		E:Point(imsg.text, "BOTTOM", 0, 16)
		imsg.text:SetTextColor(1, 0.82, 0)
		imsg.text:SetJustifyH("CENTER")
	end

	if not ElvUIInstallFrame then
		local f = CreateFrame("Button", "ElvUIInstallFrame", E.UIParent)
		f.SetPage = SetPage
		E:Size(f, 550, 400)
		E:SetTemplate(f, "Transparent")
		E:Point(f, "CENTER", 0, 0)
		f:SetFrameStrata("TOOLTIP")

		f.Title = f:CreateFontString(nil, "OVERLAY")
		E:FontTemplate(f.Title, nil, 17, nil)
		E:Point(f.Title, "TOP", 0, -5)
		f.Title:SetText(L["ElvUI Installation"])

		f.Next = CreateFrame("Button", "InstallNextButton", f, "UIPanelButtonTemplate")
		E:StripTextures(f.Next)
		E:SetTemplate(f.Next, "Default", true)
		E:Size(f.Next, 110, 25)
		E:Point(f.Next, "BOTTOMRIGHT", -5, 5)
		f.Next:SetText(CONTINUE)
		f.Next:Disable()
		f.Next:SetScript("OnClick", NextPage)
		E.Skins:HandleButton(f.Next, true)

		f.Prev = CreateFrame("Button", "InstallPrevButton", f, "UIPanelButtonTemplate")
		E:StripTextures(f.Prev)
		E:SetTemplate(f.Prev, "Default", true)
		E:Size(f.Prev, 110, 25)
		E:Point(f.Prev, "BOTTOMLEFT", 5, 5)
		f.Prev:SetText(PREV)
		f.Prev:Disable()
		f.Prev:SetScript("OnClick", PreviousPage)
		E.Skins:HandleButton(f.Prev, true)

		f.Status = CreateFrame("StatusBar", "InstallStatus", f)
		f.Status:SetFrameLevel(f.Status:GetFrameLevel() + 2)
		E:CreateBackdrop(f.Status, "Default")
		f.Status:SetStatusBarTexture(E["media"].normTex)
		E:RegisterStatusBar(f.Status)
		f.Status:SetMinMaxValues(0, MAX_PAGE)
		E:Point(f.Status, "TOPLEFT", f.Prev, "TOPRIGHT", 6, -2)
		E:Point(f.Status, "BOTTOMRIGHT", f.Next, "BOTTOMLEFT", -6, 2)

		f.Status.anim = CreateAnimationGroup(f.Status)
		f.Status.anim.progress = f.Status.anim:CreateAnimation("Progress")
		f.Status.anim.progress:SetSmoothing("Out")
		f.Status.anim.progress:SetDuration(.3)

		f.Status.text = f.Status:CreateFontString(nil, "OVERLAY")
		E:FontTemplate(f.Status.text)
		E:Point(f.Status.text, "CENTER", 0, 0)
		f.Status.text:SetText(format("%d / %d", CURRENT_PAGE, MAX_PAGE))

		f.Option1 = CreateFrame("Button", "InstallOption1Button", f, "UIPanelButtonTemplate")
		E:StripTextures(f.Option1)
		E:Size(f.Option1, 160, 30)
		E:Point(f.Option1, "BOTTOM", 0, 45)
		f.Option1:SetText("")
		f.Option1:Hide()
		E.Skins:HandleButton(f.Option1, true)

		f.Option2 = CreateFrame("Button", "InstallOption2Button", f, "UIPanelButtonTemplate")
		E:StripTextures(f.Option2)
		E:Size(f.Option2, 110, 30)
		E:Point(f.Option2, "BOTTOMLEFT", f, "BOTTOM", 4, 45)
		f.Option2:SetText("")
		f.Option2:Hide()
		f.Option2:SetScript("OnShow", function() E:Width(f.Option1, 110) f.Option1:ClearAllPoints() E:Point(f.Option1, "BOTTOMRIGHT", f, "BOTTOM", -4, 45) end)
		f.Option2:SetScript("OnHide", function() E:Width(f.Option1, 160) f.Option1:ClearAllPoints() E:Point(f.Option1, "BOTTOM", 0, 45) end)
		E.Skins:HandleButton(f.Option2, true)

		f.Option3 = CreateFrame("Button", "InstallOption3Button", f, "UIPanelButtonTemplate")
		E:StripTextures(f.Option3)
		E:Size(f.Option3, 110, 30)
		E:Point(f.Option3, "LEFT", f.Option2, "RIGHT", 4, 0)
		f.Option3:SetText("")
		f.Option3:Hide()
		f.Option3:SetScript("OnShow", function() E:Width(f.Option1, 100) f.Option1:ClearAllPoints() E:Point(f.Option1, "RIGHT", f.Option2, "LEFT", -4, 0) E:Width(f.Option2, 100) f.Option2:ClearAllPoints() E:Point(f.Option2, "BOTTOM", f, "BOTTOM", 0, 45) end)
		f.Option3:SetScript("OnHide", function() E:Width(f.Option1, 160) f.Option1:ClearAllPoints() E:Point(f.Option1, "BOTTOM", 0, 45) E:Width(f.Option2, 110) f.Option2:ClearAllPoints() E:Point(f.Option2, "BOTTOMLEFT", f, "BOTTOM", 4, 45) end)
		E.Skins:HandleButton(f.Option3, true)

		f.Option4 = CreateFrame("Button", "InstallOption4Button", f, "UIPanelButtonTemplate")
		E:StripTextures(f.Option4)
		E:Size(f.Option4, 110, 30)
		E:Point(f.Option4, "LEFT", f.Option3, "RIGHT", 4, 0)
		f.Option4:SetText("")
		f.Option4:Hide()
		f.Option4:SetScript("OnShow", function()
			E:Width(f.Option1, 100)
			E:Width(f.Option2, 100)

			f.Option1:ClearAllPoints()
			E:Point(f.Option1, "RIGHT", f.Option2, "LEFT", -4, 0)
			f.Option2:ClearAllPoints()
			E:Point(f.Option2, "BOTTOMRIGHT", f, "BOTTOM", -4, 45)
		end)
		f.Option4:SetScript("OnHide", function() E:Width(f.Option1, 160) f.Option1:ClearAllPoints() E:Point(f.Option1, "BOTTOM", 0, 45) E:Width(f.Option2, 110) f.Option2:ClearAllPoints() E:Point(f.Option2, "BOTTOMLEFT", f, "BOTTOM", 4, 45) end)
		E.Skins:HandleButton(f.Option4, true)

		f.SubTitle = f:CreateFontString(nil, "OVERLAY")
		E:FontTemplate(f.SubTitle, nil, 15, nil)
		E:Point(f.SubTitle, "TOP", 0, -40)

		f.Desc1 = f:CreateFontString(nil, "OVERLAY")
		E:FontTemplate(f.Desc1)
		E:Point(f.Desc1, "TOPLEFT", 20, -75)
		E:Width(f.Desc1, f:GetWidth() - 40)

		f.Desc2 = f:CreateFontString(nil, "OVERLAY")
		E:FontTemplate(f.Desc2)
		E:Point(f.Desc2, "TOPLEFT", 20, -125)
		E:Width(f.Desc2, f:GetWidth() - 40)

		f.Desc3 = f:CreateFontString(nil, "OVERLAY")
		E:FontTemplate(f.Desc3)
		E:Point(f.Desc3, "TOPLEFT", 20, -175)
		E:Width(f.Desc3, f:GetWidth() - 40)

		local close = CreateFrame("Button", "InstallCloseButton", f, "UIPanelCloseButton")
		E:Point(close, "TOPRIGHT", f, "TOPRIGHT")
		close:SetScript("OnClick", function()
			f:Hide()
		end)
		E.Skins:HandleCloseButton(close)

		f.tutorialImage = f:CreateTexture("InstallTutorialImage", "OVERLAY")
		E:Size(f.tutorialImage, 256, 128)
		f.tutorialImage:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\logo.tga")
		E:Point(f.tutorialImage, "BOTTOM", 0, 70)

	end

	ElvUIInstallFrame:Show()
	NextPage()
end