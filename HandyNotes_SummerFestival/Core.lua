-- Addon declaration
HandyNotes_SummerFestival = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_SummerFestival","AceEvent-3.0")
local HSF = HandyNotes_SummerFestival
local Astrolabe = DongleStub("Astrolabe-0.4")
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_SummerFestival")

---------------------------------------------------------
-- Our db upvalue and db defaults
local db
local defaults = {
	profile = {
		icon_scale		= 1.0,
		icon_alpha		= 1.0,
		completed 		= false,
	},
}

---------------------------------------------------------
-- Localize some globals
local next = next
local select = select
local string_find = string.find
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip
local HandyNotes = HandyNotes

local tonumber = tonumber
local strsplit = strsplit
---------------------------------------------------------
-- Constants and icons

local defkey = "default"

local iconDB = {
	["FlameKeeper"]   = "Interface\\Icons\\INV_SummerFest_FireSpirit",
	["Extinguishing"] = "Interface\\Icons\\Spell_Fire_MasterOfElements",
	["Thief"] = "Interface\\Icons\\spell_fire_fire",
	[defkey] = "Interface\\Icons\\INV_Misc_QuestionMark", -- default fallback icon
}

setmetatable(iconDB, {__index = function(t, k)
		local v = t[defkey]
		rawset(t, k, v)
		return v
	end
})

---------------------------------------------------------
-- Your nodes stored separately from db, coordinates in [0..1] range
local HSF_Data = {

	--Northrend
	["CrystalsongForest"] = {
		[HandyNotes:getCoord(0.78, 0.75)] = "FlameKeeper:Flame Warden of Northrend::13491",  -- TODO: add vGuild for showing additional info in the tooltip
		[HandyNotes:getCoord(0.80, 0.53)] = "Extinguishing:Extinguishing Northrend::13457",  -- TODO: use AceLocale to localize all user-facing labels
	},
	["TheStormPeaks"] = {
		[HandyNotes:getCoord(0.41, 0.87)] = "FlameKeeper:Flame Warden of Northrend::13490",
		[HandyNotes:getCoord(0.40, 0.85)] = "Extinguishing:Extinguishing Northrend::13455",
	},
	["ZulDrak"] = {
		[HandyNotes:getCoord(0.40, 0.61)] = "FlameKeeper:Flame Warden of Northrend::13492",
		[HandyNotes:getCoord(0.43, 0.71)] = "Extinguishing:Extinguishing Northrend::13458",
	},
	["GrizzlyHills"] = {
		[HandyNotes:getCoord(0.34, 0.60)] = "FlameKeeper:Flame Warden of Northrend::13489",
		[HandyNotes:getCoord(0.19, 0.61)] = "Extinguishing:Extinguishing Northrend::13454",
	},
	["HowlingFjord"] = {
		[HandyNotes:getCoord(0.58, 0.16)] = "FlameKeeper:Flame Warden of Northrend::13488",
		[HandyNotes:getCoord(0.48, 0.13)] = "Extinguishing:Extinguishing Northrend::13453",
	},
	["Dragonblight"] = {
		[HandyNotes:getCoord(0.75, 0.43)] = "FlameKeeper:Flame Warden of Northrend::13487",
		[HandyNotes:getCoord(0.38, 0.48)] = "Extinguishing:Extinguishing Northrend::13451",
	},
	["BoreanTundra"] = {
		[HandyNotes:getCoord(0.55, 0.20)] = "FlameKeeper:Flame Warden of Northrend::13485",
		[HandyNotes:getCoord(0.51, 0.11)] = "Extinguishing:Extinguishing Northrend::13441",
	},
	["SholazarBasin"] = {
		[HandyNotes:getCoord(0.48, 0.66)] = "FlameKeeper:Flame Warden of Northrend::13486",
		[HandyNotes:getCoord(0.47, 0.61)] = "Extinguishing:Extinguishing Northrend::13450",
	},
	--Outland 
	["Hellfire"] = {
		[HandyNotes:getCoord(0.62, 0.58)] = "FlameKeeper:Flame Warden of Outland::11818",
		[HandyNotes:getCoord(0.57, 0.42)] = "Extinguishing:Extinguishing Outland::11775",
	},
	["Zangarmarsh"] = {
		[HandyNotes:getCoord(0.69, 0.52)] = "FlameKeeper:Flame Warden of Outland::11829",
		[HandyNotes:getCoord(0.36, 0.52)] = "Extinguishing:Extinguishing Outland::11787",
	},
	["TerokkarForest"] = {
		[HandyNotes:getCoord(0.54, 0.55)] = "FlameKeeper:Flame Warden of Outland::11825",
		[HandyNotes:getCoord(0.52, 0.43)] = "Extinguishing:Extinguishing Outland::11782",
	},
	["ShadowmoonValley"] = {
		[HandyNotes:getCoord(0.40, 0.55)] = "FlameKeeper:Flame Warden of Outland::11823",
		[HandyNotes:getCoord(0.34, 0.30)] = "Extinguishing:Extinguishing Outland::11779",
	},
	["Nagrand"] = {
		[HandyNotes:getCoord(0.50, 0.69)] = "FlameKeeper:Flame Warden of Outland::11821",
		[HandyNotes:getCoord(0.51, 0.34)] = "Extinguishing:Extinguishing Outland::11778",
	},
	["BladesEdgeMountains"] = {
		[HandyNotes:getCoord(0.41, 0.66)] = "FlameKeeper:Flame Warden of Outland::11807",
		[HandyNotes:getCoord(0.50, 0.59)] = "Extinguishing:Extinguishing Outland::11767",
	},
	["Netherstorm"] = {
		[HandyNotes:getCoord(0.31, 0.63)] = "FlameKeeper:Flame Warden of Outland::11830",
		[HandyNotes:getCoord(0.32, 0.68)] = "Extinguishing:Extinguishing Outland::11799",
	},
	--Kalimdor
	["Ashenvale"] = {
		[HandyNotes:getCoord(0.38, 0.55)] = "FlameKeeper:Flame Warden of Kalimdor::11805",
		[HandyNotes:getCoord(0.70, 0.69)] = "Extinguishing:Extinguishing Kalimdor::11765",
	},
	["AzuremystIsle"] = {
		[HandyNotes:getCoord(0.44, 0.52)] = "FlameKeeper:Flame Warden of Kalimdor::11806",
	},
	["BloodmystIsle"] = {
		[HandyNotes:getCoord(0.56, 0.68)] = "FlameKeeper:Flame Warden of Kalimdor::11809",
	},
	["Darkshore"] = {
		[HandyNotes:getCoord(0.37, 0.46)] = "FlameKeeper:Flame Warden of Kalimdor::11811",
	},
	["Desolace"] = {
		[HandyNotes:getCoord(0.66, 0.17)] = "FlameKeeper:Flame Warden of Kalimdor::11812",
		[HandyNotes:getCoord(0.26, 0.77)] = "Extinguishing:Extinguishing Kalimdor::11769",
	},
	["Dustwallow"] = {
		[HandyNotes:getCoord(0.62, 0.40)] = "FlameKeeper:Flame Warden of Kalimdor::11815",
		[HandyNotes:getCoord(0.33, 0.31)] = "Extinguishing:Extinguishing Kalimdor::11771",
	},
	["Feralas"] = {
		[HandyNotes:getCoord(0.28, 0.44)] = "FlameKeeper:Flame Warden of Kalimdor::11817",
		[HandyNotes:getCoord(0.72, 0.48)] = "Extinguishing:Extinguishing Kalimdor::11773",
	},
	["Silithus"] = {
		[HandyNotes:getCoord(0.57, 0.35)] = "FlameKeeper:Flame Warden of Kalimdor::11831",
		[HandyNotes:getCoord(0.46, 0.45)] = "Extinguishing:Extinguishing Kalimdor::11800",
	},
	["Tanaris"] = {
		[HandyNotes:getCoord(0.53, 0.29)] = "FlameKeeper:Flame Warden of Kalimdor::11833",
		[HandyNotes:getCoord(0.50, 0.27)] = "Extinguishing:Extinguishing Kalimdor::11802",
	},
	["Teldrassil"] = {
		[HandyNotes:getCoord(0.55, 0.60)] = "FlameKeeper:Flame Warden of Kalimdor::11824",
	},
	["Winterspring"] = {
		[HandyNotes:getCoord(0.63, 0.35)] = "FlameKeeper:Flame Warden of Kalimdor::11834",
		[HandyNotes:getCoord(0.60, 0.35)] = "Extinguishing:Extinguishing Kalimdor::11803",
	},
	["Durotar"] = {
		[HandyNotes:getCoord(0.52, 0.47)] = "Extinguishing:Extinguishing Kalimdor::11770",
	},
	["Mulgore"] = {
		[HandyNotes:getCoord(0.52, 0.60)] = "Extinguishing:Extinguishing Kalimdor::11777",
	},
	["StonetalonMountains"] = {
		[HandyNotes:getCoord(0.51, 0.60)] = "Extinguishing:Extinguishing Kalimdor::11780",
	},
	["Barrens"] = {
		[HandyNotes:getCoord(0.52, 0.28)] = "Extinguishing:Extinguishing Kalimdor::11783",
	},
	["ThousandNeedles"] = {
		[HandyNotes:getCoord(0.42, 0.53)] = "Extinguishing:Extinguishing Kalimdor::11785",
	},
	--Eastern Kingdoms
	["Arathi"] = {
		[HandyNotes:getCoord(0.50, 0.44)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11804",
		[HandyNotes:getCoord(0.74, 0.41)] = "Extinguishing:Extinguishing Eastern Kingdoms::11764",
	},
	["BlastedLands"] = {
		[HandyNotes:getCoord(0.59, 0.17)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11808",
	},
	["BurningSteppes"] = {
		[HandyNotes:getCoord(0.81, 0.63)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11810",
		[HandyNotes:getCoord(0.62, 0.29)] = "Extinguishing:Extinguishing Eastern Kingdoms::11768",
	},
	["DunMorogh"] = {
		[HandyNotes:getCoord(0.47, 0.47)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11813",
	},
	["Duskwood"] = {
		[HandyNotes:getCoord(0.73, 0.54)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11814",
	},
	["Elwynn"] = {
		[HandyNotes:getCoord(0.43, 0.63)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11816",  
	},
	["Hilsbrad"] = {
		[HandyNotes:getCoord(0.50, 0.47)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11819",
		[HandyNotes:getCoord(0.58, 0.25)] = "Extinguishing:Extinguishing Eastern Kingdoms::11776",
	},
	["LochModan"] = {
		[HandyNotes:getCoord(0.33, 0.41)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11820",
	},
	["Redridge"] = {
		[HandyNotes:getCoord(0.26, 0.60)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11822",
	},
	["Stranglethorn"] = {
		[HandyNotes:getCoord(0.34, 0.74)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11832",
		[HandyNotes:getCoord(0.33, 0.75)] = "Extinguishing:Extinguishing Eastern Kingdoms::11801",
	},
	["Hinterlands"] = {
		[HandyNotes:getCoord(0.14, 0.50)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11826",
		[HandyNotes:getCoord(0.77, 0.75)] = "Extinguishing:Extinguishing Eastern Kingdoms::11784",
	},
	["Wetlands"] = {
		[HandyNotes:getCoord(0.13, 0.47)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11828",
	},
	["WesternPlaguelands"] = {
		[HandyNotes:getCoord(0.43, 0.82)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11827",
	},
	["Westfall"] = {
		[HandyNotes:getCoord(0.56, 0.53)] = "FlameKeeper:Flame Warden of Eastern Kingdoms::11583",
	},
	["Badlands"] = {
		[HandyNotes:getCoord(0.05, 0.49)] = "Extinguishing:Extinguishing Eastern Kingdoms::11766",
	},
	["EversongWoods"] = {
		[HandyNotes:getCoord(0.46, 0.50)] = "Extinguishing:Extinguishing Eastern Kingdoms::11772",
	},
	["Ghostlands"] = {
		[HandyNotes:getCoord(0.47, 0.26)] = "Extinguishing:Extinguishing Eastern Kingdoms::11774",
	},
	["Silverpine"] = {
		[HandyNotes:getCoord(0.50, 0.38)] = "Extinguishing:Extinguishing Eastern Kingdoms::11580",
	},
	["SwampOfSorrows"] = {
		[HandyNotes:getCoord(0.47, 0.47)] = "Extinguishing:Extinguishing Eastern Kingdoms::11781",
	},
	["Tirisfal"] = {
		[HandyNotes:getCoord(0.57, 0.52)] = "Extinguishing:Extinguishing Eastern Kingdoms::11786",
	},
	--A Thief's Reward
	["SilvermoonCity"] = {
		[HandyNotes:getCoord(0.69, 0.43)] = "Thief:A Thief's Reward::11935",
	},
	["Undercity"] = {
		[HandyNotes:getCoord(0.68, 0.08)] = "Thief:A Thief's Reward::9326",
	},
	["ThunderBluff"] = {
		[HandyNotes:getCoord(0.21, 0.25)] = "Thief:A Thief's Reward::9325",
	},
	["Ogrimmar"] = {
		[HandyNotes:getCoord(0.46, 0.38)] = "Thief:A Thief's Reward::9324",
	},
	
}

local completedQuests = {}
--[[
local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_QUERY_COMPLETE")
frame:SetScript("OnEvent", function()
    for k in pairs(completedQuests) do
        completedQuests[k] = nil
    end
    local t = {}
    GetQuestsCompleted(t)
    for questID, done in pairs(t) do
        if done then
            completedQuests[questID] = true
        end
    end
    HSF:SendMessage("HandyNotes_NotifyUpdate", "SummerFestival")
end)
]]
local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_QUERY_COMPLETE")
frame:RegisterEvent("QUEST_FINISHED")
frame:SetScript("OnEvent", function(self, event)
    if event == "QUEST_FINISHED" then
        QueryQuestsCompleted()
        return
    end

    wipe(completedQuests)
    local t = {}
    GetQuestsCompleted(t)
    for questID, done in pairs(t) do
        if done then
            completedQuests[questID] = true
        end
    end
    HSF:SendMessage("HandyNotes_NotifyUpdate", "SummerFestival")
end)

---------------------------------------------------------
-- Plugin Handlers to HandyNotes
local HSFHandler = {}

local function createWaypoint(button, mapFile, coord)
	local c, z = HandyNotes:GetCZ(mapFile)
	local x, y = HandyNotes:getXY(coord)
	local vType, vName, vGuild = strsplit(":", HSF_Data[mapFile][coord])
	if TomTom then
		TomTom:AddZWaypoint(c, z, x*100, y*100, vName)
	elseif Cartographer_Waypoints then
		Cartographer_Waypoints:AddWaypoint(NotePoint:new(HandyNotes:GetCZToZone(c, z), x, y, vName))
	end
end

local clickedNote, clickedNoteZone
local info = {}
local function generateMenu(button, level)
	if (not level) then return end
	for k in pairs(info) do info[k] = nil end
	if (level == 1) then
		info.isTitle      = 1
		info.text         = L["HandyNotes - SummerFestival"]
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		if TomTom or Cartographer_Waypoints then
			info.disabled     = nil
			info.isTitle      = nil
			info.notCheckable = nil
			info.text = L["Create waypoint"]
			info.icon = nil
			info.func = createWaypoint
			info.arg1 = clickedNoteZone
			info.arg2 = clickedNote
			UIDropDownMenu_AddButton(info, level)
		end

		info.text         = L["Close"]
		info.icon         = nil
		info.func         = function() CloseDropDownMenus() end
		info.arg1         = nil
		info.arg2         = nil
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)
	end
end
local HSF_Dropdown = CreateFrame("Frame", "HandyNotes_SummerFestivalDropdownMenu")
HSF_Dropdown.displayMode = "MENU"
HSF_Dropdown.initialize = generateMenu

function HSFHandler:OnClick(button, down, mapFile, coord)
	if button == "RightButton" and not down then
		clickedNoteZone = mapFile
		clickedNote = coord
		ToggleDropDownMenu(1, nil, HSF_Dropdown, self, 0, 0)
	end
end
--[[
function HSFHandler:OnEnter(mapFile, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if ( self:GetCenter() > UIParent:GetCenter() ) then
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	local vType, vName, vGuild = strsplit(":", HSF_Data[mapFile][coord])
	tooltip:AddLine("|cffe0e0e0"..vName.."|r")
	if (vGuild ~= "") then tooltip:AddLine(vGuild) end
	tooltip:Show()
end
--]]
--======================================================
function HSFHandler:OnEnter(mapFile, coord)
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip

    if self:GetCenter() > UIParent:GetCenter() then
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end

    local raw = HSF_Data[mapFile] and HSF_Data[mapFile][coord]
    if not raw then return end

    local vType, vName, vGuild, questID = string.match(raw, "([^:]+):([^:]+):([^:]*):?(%d*)")

    if vName then
        tooltip:AddLine("|cffe0e0e0" .. vName .. "|r")
    end
    if vGuild and vGuild ~= "" then
        tooltip:AddLine(vGuild)
    end

    if questID and questID ~= "" then
        local qID = tonumber(questID)
        if qID then
            local completed = completedQuests[qID] or false
            if completed then
                tooltip:AddLine("|cff00ff00Completed|r")
            else
                tooltip:AddLine("|cffff0000Not completed|r")
            end
        else
            tooltip:AddLine("|cffff0000Invalid quest ID|r")
        end
    end

    tooltip:Show()
end
--======================================================
function HSFHandler:OnLeave(mapFile, coord)
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end
--[[
do
	local function iter(t, prestate)
		if not t then return nil end
		local state, value = next(t, prestate)
		while state do
			if value then
				local vType, vName, vGuild = strsplit(":", value)
				local icon = iconDB[vType]
				return state, nil, icon, db.profile.icon_scale, db.profile.icon_alpha
			end
			state, value = next(t, state)
		end
		return nil, nil, nil, nil
	end
	function HSFHandler:GetNodes(mapFile)
	print("HandyNotes SummerFestival GetNodes mapFile:", mapFile)
		return iter, HSF_Data[mapFile], nil
	end
end
]]
--======================================================
local function iter(t, prestate)
    if not t then return nil end
    local state, value = next(t, prestate)
    while state do
        if value then
            local vType, vName, vGuild, questID = strsplit(":", value)
            local isCompleted = false
            if questID and questID ~= "" then
                isCompleted = completedQuests[tonumber(questID)] or false
            end

            if db.profile.completed or not isCompleted then
                local icon = iconDB[vType]
                return state, nil, icon, db.profile.icon_scale, db.profile.icon_alpha
            end
        end
        state, value = next(t, state)
    end
    return nil, nil, nil, nil
end

function HSFHandler:GetNodes(mapFile)
--print("HandyNotes SummerFestival GetNodes mapFile:", mapFile)
    return iter, HSF_Data[mapFile], nil
end
--======================================================

---------------------------------------------------------
-- Options table

local options = {
	type = "group",
	name = L["SummerFestival"],
	desc = "Summer Fesitval bonfire locations", -- перевести
	get = function(info) return db.profile[info.arg] end,
	set = function(info, v)
		db.profile[info.arg] = v
		HSF:SendMessage("HandyNotes_NotifyUpdate", "SummerFestival")
	end,
	args = {
		desc = {
			name = L["These settings control the look and feel of the icon"],
			type = "description",
			order = 0,
		},
		icon_scale = {
			type = "range",
			name = L["Icon Scale"],
			desc = L["The scale of the icons"],
			min = 0.25, max = 2, step = 0.01,
			arg = "icon_scale",
			order = 10,
		},
		icon_alpha = {
			type = "range",
			name = L["Icon Alpha"],
			desc = L["The alpha transparency of the icons"],
			min = 0, max = 1, step = 0.01,
			arg = "icon_alpha",
			order = 20,
		},
		show_on_continent = {
			type = "toggle",
			name = L["Show completed"],
			desc = L["Show icons for bonfires you have already visited"],
			arg = "completed",
			order = 30,
		},
	},
}

---------------------------------------------------------
-- Addon initialization

function HSF:OnInitialize()
	db = LibStub("AceDB-3.0"):New("HandyNotes_SummerFestivalDB", defaults)
	self.db = db

	HandyNotes:RegisterPluginDB("SummerFestival", HSFHandler, options)
	
	QueryQuestsCompleted()
end

function HSF:OnEnable()
	-- Force update on enable
	HSF:SendMessage("HandyNotes_NotifyUpdate", "SummerFestival")
end


--====================================================================





