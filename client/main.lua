local QBCore = exports['qb-core']:GetCoreObject()

local robberyCooldown = false

local npcPed = Config.Peds

local function getReward()
    local totalWeight = 0
    for _, reward in pairs(Config.RewardItems) do
        totalWeight = totalWeight + reward.chance
    end
    
    local randomWeight = math.random(0, totalWeight)
    local currentWeight = 0

    for _, reward in pairs(Config.RewardItems) do
        currentWeight = currentWeight + reward.chance
        if randomWeight <= currentWeight then
            return { type = 'item', value = reward.item }
        end
    end
    return { type = 'money', value = math.random(Config.MoneyReward.min, Config.MoneyReward.max) }
end

local function hasRequiredItem()
    local playerPed = PlayerPedId()
    local weapon = GetSelectedPedWeapon(playerPed)

    for _, item in pairs(Config.RequiredItems) do
        local itemHash = GetHashKey(item)
        if weapon == itemHash then
            return true
        end
    end
    return false
end

local function isPlayerPolice()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return PlayerData.job.name == "police"  
end

local function isPedBlacklisted(npcPed)
    local pedModel = GetEntityModel(npcPed)
    for _, blacklistedModel in pairs(Config.BlacklistedPeds) do
        if pedModel == GetHashKey(blacklistedModel) then
            return true
        end
    end
    return false
end

local function handleRobbery(success)
    if success then
        QBCore.Functions.Progressbar("smdx-npcrobbery", Config.Robbing, 5000, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "random@domestic",
            anim = "pickup_low",
            flags = 49,
        }, {}, {}, function()
            local reward = getReward()
            if reward.type == 'item' then
                TriggerServerEvent('smdx-npcrobbery:giveReward', 'item', reward.value)
            elseif reward.type == 'money' then
                TriggerServerEvent('smdx-npcrobbery:giveReward', 'money', reward.value)
            end
            FreezeEntityPosition(npcPed, false)
            Citizen.Wait(Config.RobberyCooldown * 1000)
            robberyCooldown = false
        end, function()
            FreezeEntityPosition(npcPed, false)
            robberyCooldown = false
        end)
    else
        QBCore.Functions.Notify(Config.RobberyFailed, 'error', 5000)
        FreezeEntityPosition(npcPed, false)
        robberyCooldown = false
    end
end

local function startMinigame(callback)
    if Config.Minigame == "Thermite" then
        exports['ps-ui']:Thermite(function(success)
            handleRobbery(success)
        end, 10, 5, 3)
    elseif Config.Minigame == "Circle" then
        exports['ps-ui']:Circle(function(success)
            handleRobbery(success)
        end, 2, 20)
    elseif Config.Minigame == "Maze" then
        exports['ps-ui']:Maze(function(success)
            handleRobbery(success)
        end, 20)
    elseif Config.Minigame == "VAR" then
        exports['ps-ui']:VarHack(function(success)
            handleRobbery(success)
        end, 2, 3)
    elseif Config.Minigame == "Scrambler" then
        exports['ps-ui']:Scrambler(function(success)
            handleRobbery(success)
        end, Config.MinigameType, 30, 0)
    else
        print("No valid minigame selected") 
        callback(false)
    end
end

local function handleAggressiveReaction(npcPed)
    local randomChance = math.random(1, 100)
    if randomChance <= Config.AggressiveChance then
        GiveWeaponToPed(npcPed, GetHashKey(Config.Weapon), 250, false, true)
        TaskCombatPed(npcPed, PlayerPedId(), 0, 16)
        return true 
    end
    return false
end

local function startRobbery(npcPed)
    if robberyCooldown then
        local remainingCooldown = math.ceil(cooldownEndTime - GetGameTimer()) / 1000
        QBCore.Functions.Notify(Config.Wait .. remainingCooldown .. " " .. Config.Sec, 'error', 5000)
        return
    end

    if isPedBlacklisted(npcPed) then
        QBCore.Functions.Notify(Config.CantrobNPC, 'error', 5000)
        return
    end

    if not hasRequiredItem() then
        QBCore.Functions.Notify(Config.Specialitem, 'error', 5000)
        return
    end

    if isPlayerPolice() and not Config.AllowPoliceRobbery then
        QBCore.Functions.Notify(Config.NoRobberyAsPolice, 'error', 5000)
        return
    end

    local playerPed = PlayerPedId()

    robberyCooldown = true
    cooldownEndTime = GetGameTimer() + (Config.RobberyCooldown * 1000) 

    Citizen.SetTimeout(Config.RobberyCooldown * 1000, function()
        robberyCooldown = false
    end)
    if handleAggressiveReaction(npcPed) then
        robberyCooldown = false
        return
    end

    robberyCooldown = true
    TaskPlayAnim(playerPed, "random@mugging3", "handsup_standing_base", 8.0, 8.0, -1, 49, 0, 0, 0, 0)
    FreezeEntityPosition(npcPed, true)
    TaskHandsUp(npcPed, -1, playerPed, -1, false)

    startMinigame()
end

local function openSellMenu()
    local playerPed = PlayerPedId()
    local PlayerData = QBCore.Functions.GetPlayerData()

    local itemsForSale = {} 

    for _, itemData in pairs(PlayerData.items) do
        if itemData.amount > 0 then
            local minPrice = Config.ItemSellPrice[itemData.name] and Config.ItemSellPrice[itemData.name].min or 0
            local maxPrice = Config.ItemSellPrice[itemData.name] and Config.ItemSellPrice[itemData.name].max or 0
            local price = math.random(minPrice, maxPrice)
            
            table.insert(itemsForSale, {
                title = itemData.name,
                description = "Price: $" .. price,
                key = itemData.name,
                price = price
            })
        end
    end

    if #itemsForSale > 0 then
        local menuOptions = {
            {
                header = Config.Stolen,
                isMenuHeader = true
            }
        }

        for _, item in ipairs(itemsForSale) do
            table.insert(menuOptions, {
                header = item.title,
                txt = item.description,
                params = {
                    isServer = true,
                    event = 'smdx-npcrobbery:sellItem',
                    args = {
                        itemName = item.key,
                        itemPrice = item.price,
                        moneyType = Config.SellMoneyType
                    }
                }
            })
        end

        exports['qb-menu']:openMenu(menuOptions)
    else
        QBCore.Functions.Notify(Config.Nostolenitems, "error", 5000)
    end
end


local function handleSellPedInteraction()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local sellPedCoords = Config.SellPed.position
    local dist = #(playerCoords - sellPedCoords)

    if dist < 2.5 then
        openSellMenu()
    end
end

Citizen.CreateThread(function()
    local pedHash = GetHashKey(Config.SellPed.model)
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Citizen.Wait(500)
    end

    local ped = CreatePed(4, pedHash, Config.SellPed.coords, Config.SellPed.heading, false, true)
    SetPedAsEnemy(ped, false)
    SetPedCanRagdoll(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                event = "smdx-npcrobbery:sell",
                icon = "fas fa-money-bill",
                label = Config.Stolen,
                canInteract = function(entity)
                    return IsPedHuman(entity) and not IsPedAPlayer(entity)
                end,
                action = function(entity)
                    openSellMenu()
                end
            }
        },
        distance = 2.5
    })

    if Config.ShowBlip then
        local blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, 408) 
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2) 
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.sellnpc)
        EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    local function setupTargetForPeds()
        local peds = GetGamePool('CPed')
        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                if IsPedHuman(ped) then
                    exports['qb-target']:AddTargetEntity(ped, {
                        options = {
                            {
                                event = "smdx-npcrobbery:start",
                                icon = "fas fa-sack-dollar",
                                label = Config.Rob,
                                canInteract = function(entity)
                                    return IsPedHuman(entity) and not IsPedAPlayer(entity)
                                end,
                                action = function(entity)
                                    startRobbery(entity)
                                end
                            }
                        },
                        distance = 2.5
                    })
                end
            end
        end
    end

    setupTargetForPeds()

    while true do
        Citizen.Wait(60000)
        setupTargetForPeds()
    end
end)
