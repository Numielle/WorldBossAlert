-- construct from Programming in Lua, taken from
-- http://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
local function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local function wbPrint(msg)
	if msg then 
		DEFAULT_CHAT_FRAME:AddMessage(msg, 255, 255, 0)		
	end
end

-- auxiliary function for printing flags
local function wbFlag(flag)
	if flag then return "ON" else return "OFF" end
end

local wbTargets = Set {"Azuregos", "Lord Kazzak", "Ysondre", "Lethon", "Emeriss", "Taerar"} 


local wbPrefix = "WorldBossAlert" -- future releases may use SendAddonMessage 

local wbFrame = CreateFrame("frame")

local wbPvp = false
local wbDeath = false
local wbScouting = false
local wbBroadcasted = false

local wbChannel = "GUILD"

-- required events 
local wbEvents = {}
wbEvents.scouting = {"CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES"}
wbEvents.pvp = {"CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS", "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE"}
wbEvents.death = {"PLAYER_DEAD"}

-- provide one of the arrays above with a true/false/nil flag to enable/disable the desired subfeature
local function wbToggle(array, flag)
	for _,event in ipairs(array) do
		if flag then 
			wbFrame:RegisterEvent(event)
		else
			wbFrame:UnregisterEvent(event)
		end
	end
	
	wbBroadcasted = false
end	

local function wbNotify(msg)
	-- don't send out notifications if you're in a raid group (or msg is nil)
	if not msg or GetNumRaidMembers() > 0 then return end
	
	-- currently spamming preconfigured channel (default GUILD)
	for n = 1,3 do
		SendChatMessage(msg, wbChannel)
	end
end

local function wbCheck(attacker,event)
	local px,py=GetPlayerMapPosition("player")

	if wbTargets[attacker] and not string.find(event, "HOSTILEPLAYER") then	
		wbNotify(format("%s IS UP!!!", string.upper(attacker)))
	elseif wbPvp and string.find(event, "HOSTILEPLAYER") then	
		-- in this version reduced to a single notification to broadcasting channel (default GUILD)
		SendChatMessage(
			format("PvP attack by %s. [%s @ %.1f, %.1f]", attacker, GetZoneText(), px*100, py*100), wbChannel) 		
	end
end

local function wbEvent()
	if event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or
		event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS" or
		event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then				
		
		if wbBroadcasted then return end
		
		local _,_,attacker = string.find(arg1, "(.+)% hits you")
		local _,_,miss = string.find(arg1, "(.+)% misses you")
		local _,_,dodge = string.find(arg1, "(.+)% attacks. You dodge.")
		
		-- check for miss or dodge and copy name to attacker
		if miss and not attacker then attacker = miss end 
		if dodge and not attacker then attacker = dodge end		
		
		wbCheck(attacker,event)	
		wbBroadcasted = true				

	elseif event == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE" then
		
		if wbBroadcasted then return end

		local _,_,attacker = string.find(arg1, "(.+)%'s")
		--local _,_,caster = string.find(arg1, "(.+)% begins") -- causes erroneous behavior
		
		if caster then
			wbCheck(caster,event) -- avoiding being stuck in wbBroadcasted = true state
		elseif attacker then
			wbCheck(attacker,event)
			wbBroadcasted = true
		end

	elseif event == "PLAYER_DEAD" then
		local px,py = GetPlayerMapPosition("player")
		
		if wbDeath then 
			SendChatMessage(
				format("Scout %s has died. [%s @ %.1f, %.1f]", UnitName("player"), GetZoneText(), px*100, py*100), wbChannel) 
		end		
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- combat over, reset the wbBroadcasted boolean
		wbBroadcasted = false
		
	elseif event == "ADDON_LOADED" and arg1 == "WorldBossAlert" then
		
		if not WorldBossAlertDB then
			-- initialize DB (first time addon is loaded)
			WorldBossAlertDB = {}
			WorldBossAlertDB.wbPvp = false			
			WorldBossAlertDB.wbDeath = false
			WorldBossAlertDB.wbScouting = false
		end
		
		-- retrieve config from DB
		wbPvp = WorldBossAlertDB.wbPvp  	
		wbDeath = WorldBossAlertDB.wbDeath	
		wbScouting = WorldBossAlertDB.wbScouting 
			
		-- enable/disable subfeatures by (un-)registering the required events
		wbToggle(wbEvents.pvp, wbPvp)
		wbToggle(wbEvents.death, wbDeath)
		wbToggle(wbEvents.scouting, wbScouting)		
		
		wbPrint(arg1 .. " loaded.")			
		
	elseif event == "PLAYER_LOGOUT" then
		-- save config to DB
		WorldBossAlertDB.wbPvp = wbPvp 
		WorldBossAlertDB.wbScouting = wbScouting
		WorldBossAlertDB.wbDeath = wbDeath
	end		
end



SLASH_AZUSPAWN1 = '/wbalert'
function SlashCmdList.AZUSPAWN(msg, editbox)	
  if msg == "enable" then
    
  elseif msg == "disable" then

	elseif msg == "pvp" then
		if wbPvp then wbPvp = false else wbPvp = true end 
		
		wbToggle(wbEvents.pvp, wbPvp)
		wbPrint(format("WorldBossAlert PvP notification turned %s.", wbFlag(wbPvp)))
		
	elseif msg == "death" then
		if wbDeath then wbDeath = false else wbDeath = true end
					
		wbToggle(wbEvents.death, wbDeath)
		wbPrint(format("WorldBossAlert death notification turned %s.", wbFlag(wbDeath)))
	
	elseif msg == "scout" then
		if wbScouting then wbScouting = false else wbScouting = true end
		
		wbToggle(wbEvents.scouting, wbScouting)
		wbPrint(format("WorldBossAlert scouting turned %s.", wbFlag(wbScouting)))		
	else
		wbPrint("[WorldBossAlert]")		
		wbPrint("Usage: /wbalert {death | pvp | scout}")		
		wbPrint(format(" - death: Toggle death notification. [%s]", wbFlag(wbDeath)))
		wbPrint(format(" - pvp:  Toggle pvp notification. [%s]", wbFlag(wbPvp)))
		wbPrint(format(" - scout: Toggle boss scouting. [%s]", wbFlag(wbScouting)))
	end
end


wbFrame:SetScript("onEvent", wbEvent)

wbFrame:RegisterEvent("ADDON_LOADED")
wbFrame:RegisterEvent("PLAYER_LOGOUT")
wbFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
