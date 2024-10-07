Config = {}

Config.Lang = "ENG"

Config.MoneyType = "cash" 

Config.AllowPoliceRobbery = false -- False if you don't want the police officers to be able to rob  NPCs.
Config.RequiredPolice = 0 -- Minimum number of police officers required to allow a robbery

Config.AggressiveChance = 50 -- 50% chance of the ped getting aggressive.
Config.Weapon = "weapon_pistol"
Config.RobberyMethod = "E" -- If you want to be able to rob the locals with just pressing E, Turn this to E, If just qb-target. Turn it to just "qb-target"

Config.DispatchSystem = "qb-dispatch" -- qb-dispatch, ps-dispatch, "none" for no dispatch
Config.PoliceAlertChance = 50 -- How big of a chache it is for the police to get alerted, Now it's 50/50 (under 50, The police get alerted, OVer 50, They do not get alerted)

Config.RobberyCooldown = 300

Config.Minigame = "Circle" -- Circle, Maze, VAR, Thermite, Scrambler.

Config.RobKey = 38 -- This is the key for robbing the NPC when having them as Hostage. [38 = E]
Config.Releasekey = 47 -- This is the key for releasing the NPC when holding them as hostage. [47 = G]

Config.MoneyReward = { min = 100, max = 500 }

Config.UseOxLibsNotification = false  -- True for ox_lib, False for qb notify
Config.UseOxLibsProgressbar = false    -- True for ox_lib, False for qb progressbar
Config.UseOxTarget = false -- True for ox_target, False for qb-target             
-- Config.UseOxInventory = false  -- Not working yet. (Working on)   
Config.UseNewQBInventory = false   -- Using the new inventory from may? Turn this to true


Config.RewardItems = {
    { item = "advancedlockpick", chance = 50 },  
    { item = "water", chance = 30 },  
    { item = "lockpick", chance = 20 }  
}

Config.ItemSellPrice = {
    ["advancedlockpick"] = { min = 50, max = 150 },
    ["water"] = { min = 100, max = 200 },
    ["lockpick"] = { min = 20, max = 50 }
}

Config.SellPed = {
    model = "a_m_y_hipster_01", -- Ensure this is a valid model
    coords = { x = 317.86, y = 179.02, z = 102.60 }, -- Use known good coordinates
    heading = 160.04
}

-- Discord Webhook
Config.WebhookURL = "DIN_DISCORD_WEBHOOK_URL"
Config.Botname = "SMDX NPC Robbery"
Config.Title = "NPC Robbery"
Config.Color = "16711680"
Config.Reward = "Reward: " -- Always leave a empty blank in the end
Config.Money = "Money: " -- Always leave a empty blank in the end

Config.ShowBlip = false -- Show blip of the sellped

Config.RequiredItems = { -- The player need some of those weapons to rob the NPCs
"weapon_knife",
"weapon_bat",
"weapon_hatchet",
"weapon_pistol",
"weapon_pistol_mk2",
"weapon_carbineassaultrifle",
"weapon_assaultsmg",
"weapon_advancedrifle",
"weapon_mg",
"weapon_combatmg",
"weapon_pistol50",
"weapon_snspistol",
"weapon_snspistol_mk2",
"weapon_revolver",
"weapon_revolver_mk2",
    --Add more here
}

if Config.Lang == "ENG" then
    Config.Sell = "Sell Stolen Goods"
    Config.Cantrob = "you can't rob this soon! You'll need to wait for " -- Always leave a blank space at the end.
    Config.Robbing = "Robbing Local"
    Config.Wait = "Wait " -- Always leave a blank space at the end.
    Config.Sec = " Seconds " -- Always leave a blank space at the beginning.
    Config.Rob = "Rob Local"
    Config.Yougot = "You got "
    Config.Failed = "Failed to add item"
    Config.Specialitem = "You'll need a weapon in hand to rob"
    Config.RobberyFailed = "The Robbery failed, he flew"
    Config.YouArePolice = "You can't rob as a police officer"
    Config.DispatchMessage = "Local robbery in progress!"
    Config.Sold = " Sold a " -- Always leave a blank space at the end.
    Config.For = " For: " -- Always leave a blank space at the end & beginning.
    Config.InvalidMoney = "Invalid money type in config"
    Config.Recived = "You got " -- Always leave a blank space at the end.
    Config.Money = "$" 
    Config.Reciveditem = "You recived an item "
    Config.Stolen = "Sell stolen things"
    Config.Nostolenitems = "You have no stolen items to sell"
    Config.Donthave = "You don't have these items"
    Config.Cannotsold = "This item cannot be sold"
    Config.CantrobNPC = "You cannot rob this Local"
    Config.sellnpc = "Selling place"
    Config.NoRobberyAsPolice = "You cant rob locals as a police officer"
    Config.CantRobDead = "You can't rob a dead person!"
    Config.NoActiveCooldown = "No active cooldown"
    Config.NotEnoughPolice = "Not enough police officers online!"
    Config.YouReleasedHostage = "You released the hostage"
    Config.HaveAlreadyHostage = "You already got a hostage"
    Config.ReleaseRob = "[G] Release Hostage | [E] Rob Hostage"
    Config.TakeHostage = "Take Hostage"
    Config.NeedToBeBehind = "You need to be behind the local to rob!"
    Config.NeedAim = "You need to aim at the local"
 
elseif Config.Lang == "SWE" then
    Config.Sell = "Sälj stulna saker"
    Config.Cantrob = "Du kan inte råna såhär snart, Du måste vänta i " -- Lämna alltid ett tomt mellanrum i slutet.
    Config.Robbing = "Rånar invånare.."
    Config.Wait = "Vänta " -- Lämna alltid ett tomt mellanrum i slutet.
    Config.Sec = " Sekunder " -- Lämna alltid ett tomt mellanrum i början.
    Config.Rob = "Råna"
    Config.Failed = "Misslyckades att lägga till föremål!"
    Config.Specialitem = "Du behöver ha ett vapen i handen för att råna"
    Config.RobberyFailed = "Rånet misslyckades, Han smet"
    Config.YouArePolice = "Du kan inte råna som polis!"
    Config.DispatchMessage = "Pågående personrån!"
    Config.Sold = "Sålde en " -- Lämna alltid ett tomt mellanrum i slutet.
    Config.For = " För " -- Lämna alltid ett tomt mellanrum i slutet & början.
    Config.InvalidMoney = "Invalid pengar typ i config"
    Config.Recived = "Du fick " -- Lämna alltid ett tomt mellanrum i slutet.
    Config.Money = "SEK"
    Config.Reciveditem = "Du fick ett föremål"
    Config.Stolen = "Sälj stulet gods"
    Config.Nostolenitems = "Du har inga föremål att sälja"
    Config.Donthave = "Du har inte detta föremål"
    Config.Cannotsold = "Detta föremål kan inte säljas"
    Config.CantrobNPC = "Du kan inte råna denna invånaren"
    Config.sellnpc = "Sälj Ställe"
    Config.NoRobberyAsPolice = "Du kan inte råna invånare som polis"
    Config.CantRobDead = " Du kan ju förfan inte råna en dö människa!"
    Config.NoActiveCooldown = "Ingen aktiv cooldown"
    Config.NotEnoughPolice = "Inte tillräckligt med poliser online!"
    Config.YouReleasedHostage = "Du släppte gisslan"
    Config.HaveAlreadyHostage = "Du har redan en gisslan"
    Config.ReleaseRob = "[G] Släpp | [E] Råna"
    Config.TakeHostage = "Ta gisslan"
    Config.NeedToBeBehind = "Du måste vara bakom NPC:n för att ta den som gisslan!"
    Config.NeedAim = "Du måste sikta på NPC:n"
end 

Config.BlacklistedPeds = {
    "mp_m_shopkeep_01",  -- Sell Ped, Keep this here, If you change the model to a new, Then change this to the new ped name.
    "s_m_m_security_01"  -- Security guard
}

Config.Peds = {
    -- Male
    'a_m_m_acult_01',
    'a_m_m_afriamer_01',
    'a_m_m_beach_01',
    'a_m_m_bevhills_01',
    'a_m_m_bevhills_02',
    'a_m_m_business_01',
    'a_m_m_eastsa_01',
    'a_m_m_eastsa_02',
    'a_m_m_farmer_01',
    'a_m_m_fatlatin_01',
    'a_m_m_genfat_01',
    'a_m_m_genfat_02',
    'a_m_m_golfer_01',
    'a_m_m_hasjew_01',
    'a_m_m_hillbilly_01',
    'a_m_m_indian_01',
    'a_m_m_ktown_01',
    'a_m_m_malibu_01',
    'a_m_m_mexcntry_01',
    'a_m_m_mexlabor_01',
    'a_m_m_og_boss_01',
    'a_m_m_paparazzi_01',
    'a_m_m_polynesian_01',
    'a_m_m_prolhost_01',
    'a_m_m_rurmeth_01',
    'a_m_m_salton_01',
    'a_m_m_skater_01',
    'a_m_m_skidrow_01',
    'a_m_m_socenlat_01',
    'a_m_m_soucent_01',
    'a_m_m_soucent_02',
    'a_m_m_soucent_03',
    'a_m_m_soucent_04',
    'a_m_m_stlat_02',
    'a_m_m_tennis_01',
    'a_m_m_tourist_01',
    'a_m_m_tramp_01',
    'a_m_m_trampbeac_01',
    'a_m_m_trucker_01',
    'a_m_m_vinewood_01',
    'a_m_m_vinewood_02',
    'a_m_m_wmex_01',

    --Female
    'a_f_m_beach_01',
    'a_f_m_bevhills_01',
    'a_f_m_bevhills_02',
    'a_f_m_bodybuild_01',
    'a_f_m_business_02',
    'a_f_m_downtown_01',
    'a_f_m_eastsa_01',
    'a_f_m_eastsa_02',
    'a_f_m_fatbla_01',
    'a_f_m_fatcult_01',
    'a_f_m_fatwhite_01',
    'a_f_m_ktown_01',
    'a_f_m_ktown_02',
    'a_f_m_prolhost_01',
    'a_f_m_salton_01',
    'a_f_m_skidrow_01',
    'a_f_m_soucent_01',
    'a_f_m_soucent_02',
    'a_f_m_soucentmc_01',
    'a_f_m_tourist_01',
    'a_f_m_tramp_01',
    'a_f_m_trampbeac_01',
    'a_f_y_beach_01',
    'a_f_y_bevhills_01',
    'a_f_y_bevhills_02',
    'a_f_y_bevhills_03',
    'a_f_y_bevhills_04',
    'a_f_y_business_01',
    'a_f_y_business_02',
    'a_f_y_business_03',
    'a_f_y_eastsa_01',
    'a_f_y_eastsa_02',
    'a_f_y_eastsa_03',
    'a_f_y_epsilon_01',
    'a_f_y_fitness_01',
    'a_f_y_fitness_02',
    'a_f_y_genhot_01',
    'a_f_y_golfer_01',
    'a_f_y_hiker_01',
    'a_f_y_hipster_01',
    'a_f_y_hipster_02',
    'a_f_y_hipster_03',
    'a_f_y_hipster_04',
    'a_f_y_indian_01',
    'a_f_y_juggalo_01',
    'a_f_y_runner_01',
    'a_f_y_rurmeth_01',
    'a_f_y_scdressy_01',
    'a_f_y_skater_01',
    'a_f_y_soucent_01',
    'a_f_y_soucent_02',
    'a_f_y_soucent_03',
    'a_f_y_tennis_01',
    'a_f_y_topless_01',
    'a_f_y_tourist_01',
    'a_f_y_tourist_02',
    'a_f_y_vinewood_01',
    'a_f_y_vinewood_02',
    'a_f_y_vinewood_03',
    'a_f_y_vinewood_04',
    'a_f_y_yoga_01',

    --Male
    'a_m_y_beach_01',
    'a_m_y_beach_02',
    'a_m_y_beach_03',
    'a_m_y_bevhills_01',
    'a_m_y_bevhills_02',
    'a_m_y_breakdance_01',
    'a_m_y_busicas_01',
    'a_m_y_business_01',
    'a_m_y_business_02',
    'a_m_y_business_03',
    'a_m_y_cyclist_01',
    'a_m_y_dhill_01',
    'a_m_y_downtown_01',
    'a_m_y_eastsa_01',
    'a_m_y_eastsa_02',
    'a_m_y_epsilon_01',
    'a_m_y_epsilon_02',
    'a_m_y_gay_01',
    'a_m_y_gay_02',
    'a_m_y_genstreet_01',
    'a_m_y_genstreet_02',
    'a_m_y_golfer_01',
    'a_m_y_hasjew_01',
    'a_m_y_hiker_01',
    'a_m_y_hipster_01',
    'a_m_y_hipster_02',
    'a_m_y_hipster_03',
    'a_m_y_indian_01',
    'a_m_y_jetski_01',
    'a_m_y_juggalo_01',
    'a_m_y_ktown_01',
    'a_m_y_ktown_02',
    'a_m_y_latino_01',
    'a_m_y_methhead_01',
    'a_m_y_mexthug_01',
    'a_m_y_motox_01',
    'a_m_y_motox_02',
    'a_m_y_musclbeac_01',
    'a_m_y_polynesian_01',
    'a_m_y_roadcyc_01',
    'a_m_y_runner_01',
    'a_m_y_runner_02',
    'a_m_y_salton_01',
    'a_m_y_skater_01',
    'a_m_y_skater_02',
    'a_m_y_soucent_01',
    'a_m_y_soucent_02',
    'a_m_y_soucent_03',
    'a_m_y_soucent_04',
    'a_m_y_stbla_01',
    'a_m_y_stbla_02',
    'a_m_y_stlat_01',
    'a_m_y_stwhi_01',
    'a_m_y_stwhi_02',
    'a_m_y_sunbathe_01',
    'a_m_y_surfer_01',
    'a_m_y_vindouche_01',
    'a_m_y_vinewood_01',
    'a_m_y_vinewood_02',
    'a_m_y_vinewood_03',
    'a_m_y_vinewood_04',
    'a_m_y_yoga_01',
}
