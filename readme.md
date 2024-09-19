# SMDX-NPCROBBERY
Welcome to a new script! SMDX-NPCRobbery!
Discord: https://discord.gg/NKaDpHKkkH


# Features:
- Dispatch System, In the config we have qb-dispatch and ps-dispatch
- "PoliceAlertChance", How big of a chance it is for the police to get alerted.
- Cooldown for 300 seconds (Config option) Around 5 minutes.
- Choose what items the players could use to rob the NPCs in the "Config.RequiredItems", It's important to hold the item in the hand.
- Choose between differnet types of minigames. Circle, Maze, VAR, Thermite, Scrambler.
- Choose between differnet types of loot. Cash and Items.
- We have a "BlacklistedPeds" in the config, Choose peds you want to be blacklisted, And can't be robbed.
- We have a "Peds" in the config, in this you have almost every ped listed.
- Turn on/off the blip for the selling NPC.
- Let the NPCs to have the chance to get aggressive towards the robber. You'll choose what weapon the NPC will use in the config.

# Install:
ps-dispatch/client/alerts.lua
local function localrobbery()
    local coords = GetEntityCoords(cache.ped)

    local dispatchData = {
        message = locale('localrobbery'),
        codeName = 'Local Robbery',
        code = '10-10',
        icon = 'fas fa-hand-fist',
        priority = 2,
        coords = coords,
        gender = GetPlayerGender(),
        street = GetStreetAndZone(coords),
        alertTime = nil,
        jobs = { 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('localrobbery', localrobbery)

ps-dispatch/shared/config.lua

    ['localrobbery'] = { 
        radius = 0,
        sprite = 119,
        color = 1,
        scale = 1.5,
        length = 2,
        sound = 'Lose_1st',
        sound2 = 'GTAO_FM_Events_Soundset',
        offset = false,
        flash = false
    },

 IF you want to use ps-dispatch, Yes. That's it. If not, Just drag and drop.