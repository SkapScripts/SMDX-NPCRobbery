local QBCore = exports['qb-core']:GetCoreObject()

local robberyCooldown = false
local npcPed = Config.Peds
local holdingHostage = false
local hostagePed = nil
local propTwo = propTwo or nil

local function Notify(msg, type, time)
    if Config.UseOxLibsNotification then
        lib.notify({
            title = 'Notification',
            description = msg,
            type = type,
            duration = time
        })
    else
        QBCore.Functions.Notify(msg, type, time)
    end
end

local function ShowProgressBar(name, label, duration, useWhileDead, canCancel, disableControls, animDict, anim, flags, successCallback, failCallback)
    if Config.UseOxLibsProgressbar then
        lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            disable = disableControls,
            anim = {
                dict = animDict,
                clip = anim
            },
            position = 'bottom',
        }, successCallback, failCallback)
    else
        QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, {
            animDict = animDict,
            anim = anim,
            flags = flags
        }, {}, {}, successCallback, failCallback)
    end
end


local function getPoliceCount(callback)
    QBCore.Functions.TriggerCallback('smdx-npcrobbery:getPoliceCount', function(policeCount)
        callback(policeCount)
    end)
end

local function getReward()
    local totalWeight = 0
    for _, reward in pairs(Config.RewardItems) do
        totalWeight = totalWeight + reward.chance
    end

    local randomWeight = math.random(0, totalWeight)
    local currentWeight = 0
    local selectedReward

    for _, reward in pairs(Config.RewardItems) do
        currentWeight = currentWeight + reward.chance
        if randomWeight <= currentWeight then
            selectedReward = reward.item
            break
        end
    end

    local moneyReward = math.random(Config.MoneyReward.min, Config.MoneyReward.max)

    return { item = selectedReward, money = moneyReward }
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

local function isPedDeadOrDying(npcPed)
    return IsPedDeadOrDying(npcPed, true)
end

local function Dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end

local function isBehindPed(playerPed, npcPed)
    local playerCoords = GetEntityCoords(playerPed)
    local npcCoords = GetEntityCoords(npcPed)
    local npcForward = GetEntityForwardVector(npcPed)

    local toPlayer = playerCoords - npcCoords
    toPlayer = toPlayer / #(toPlayer)

    local dotProduct = Dot(npcForward, toPlayer)

    return dotProduct < -0.5
end

function takeHostage(npcPed)
    if not holdingHostage then
        local playerPed = PlayerPedId()

        if not isBehindPed(playerPed, npcPed) then
            Notify(Config.NeedToBeBehind, "error", 5000)
            return
        end

        holdingHostage = true
        hostagePed = npcPed

        TaskSetBlockingOfNonTemporaryEvents(npcPed, true)
        FreezeEntityPosition(npcPed, false)

        RequestAnimDict("anim@gangops@hostage@")
        while not HasAnimDictLoaded("anim@gangops@hostage@") do
            Citizen.Wait(100)
        end

        TaskPlayAnim(playerPed, "anim@gangops@hostage@", "perp_idle", 8.0, -8.0, -1, 49, 0, false, false, false)
        TaskPlayAnim(npcPed, "anim@gangops@hostage@", "victim_idle", 8.0, -8.0, -1, 49, 0, false, false, false)

        AttachEntityToEntity(npcPed, PlayerPedId(), 0, 0.0, 0.45, 0.0, 0, 0, 0, false, false, false, false, 2, true)

        exports['qb-core']:DrawText(Config.ReleaseRob, 'center')

        Citizen.CreateThread(function()
            while holdingHostage do
                if IsControlJustPressed(0, Config.Releasekey) then
                    releaseHostage()
                end

                if IsControlJustPressed(0, Config.RobKey) then
                    TaskPlayAnim(playerPed, "random@mugging3", "handsup_standing_base", 8.0, -8.0, -1, 49, 0, 0, 0, 0)
                    startRobbery(hostagePed)
                    releaseHostage()
                end

                Citizen.Wait(0)
            end
        end)
    else
        Notify(Config.HaveAlreadyHostage, "error", 5000)
    end
end

function releaseHostage()
    if holdingHostage and hostagePed then
        holdingHostage = false

        DetachEntity(hostagePed, true, false)
        ClearPedTasksImmediately(PlayerPedId())
        ClearPedTasksImmediately(hostagePed)

        TaskSmartFleePed(hostagePed, PlayerPedId(), 500.0, -1, true, true)

        exports['qb-core']:HideText()

        Notify(Config.YouReleasedHostage, "success", 5000)
        hostagePed = nil
    end
end

local function handleRobbery(success, npcPed)
    if success then
        ShowProgressBar("smdx-npcrobbery", Config.Robbing, 5000, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, "random@domestic", "pickup_low", 49, function()
            local reward = getReward()
            TriggerServerEvent('smdx-npcrobbery:giveReward', reward.item, reward.money)

            if reward.item then
                if Config.UseOxInventory then
                    exports.ox_inventory:AddItem(PlayerPedId(), reward.item, 1)
                elseif Config.UseNewQBInventory then
                    exports['qb-inventory']:AddItem(reward.item, 1)
                else
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[reward.item], 'add')
                end
            end

            FreezeEntityPosition(npcPed, false)
            TaskSmartFleePed(npcPed, PlayerPedId(), 500.0, -1, true, true)

            Citizen.Wait(Config.RobberyCooldown * 1000)
            robberyCooldown = false

            exports['qb-core']:HideText()

        end, function()
            FreezeEntityPosition(npcPed, false)
            robberyCooldown = false
        end)
    else
        Notify(Config.RobberyFailed, 'error', 5000)
        FreezeEntityPosition(npcPed, false)
        robberyCooldown = false

        exports['qb-core']:HideText()
    end
end

local function startMinigame(npcPed)
    if Config.Minigame == "Thermite" then
        exports['ps-ui']:Thermite(function(success)
            handleRobbery(success, npcPed)
        end, 10, 5, 3)
    elseif Config.Minigame == "Circle" then
        exports['ps-ui']:Circle(function(success)
            handleRobbery(success, npcPed)
        end, 2, 20)
    elseif Config.Minigame == "Maze" then
        exports['ps-ui']:Maze(function(success)
            handleRobbery(success, npcPed)
        end, 20)
    elseif Config.Minigame == "VAR" then
        exports['ps-ui']:VarHack(function(success)
            handleRobbery(success, npcPed)
        end, 2, 3)
    elseif Config.Minigame == "Scrambler" then
        exports['ps-ui']:Scrambler(function(success)
            handleRobbery(success, npcPed)
        end, Config.MinigameType, 30, 0)
    else
        print("No valid minigame selected")
    end
end

function startRobbery(npcPed)
    if robberyCooldown then
        local remainingCooldown = math.ceil(cooldownEndTime - GetGameTimer()) / 1000
        Notify(Config.Wait .. remainingCooldown .. " " .. Config.Sec, 'error', 5000)
        return
    end

    if isPedBlacklisted(npcPed) then
        Notify(Config.CantrobNPC, 'error', 5000)
        return
    end

    if isPedDeadOrDying(npcPed) then
        Notify(Config.CantRobDead, 'error', 5000)
        return
    end

    if not hasRequiredItem() then
        Notify(Config.Specialitem, 'error', 5000)
        return
    end

    if isPlayerPolice() and not Config.AllowPoliceRobbery then
        Notify(Config.NoRobberyAsPolice, 'error', 5000)
        return
    end

    getPoliceCount(function(policeCount)
        if policeCount < Config.RequiredPolice then
            Notify(Config.NotEnoughPolice, 'error', 5000)
            return
        end

        local playerPed = PlayerPedId()

        robberyCooldown = true
        cooldownEndTime = GetGameTimer() + (Config.RobberyCooldown * 1000)

        Citizen.SetTimeout(Config.RobberyCooldown * 1000, function()
            robberyCooldown = false
        end)

        TaskPlayAnim(playerPed, "random@mugging3", "handsup_standing_base", 8.0, 8.0, -1, 49, 0, 0, 0, 0)
        FreezeEntityPosition(npcPed, true)
        TaskHandsUp(npcPed, -1, playerPed, -1, false)

        startMinigame(npcPed)
    end)
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
                description = "Price: " .. Config.Money .. " " .. price,
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
        Notify(Config.Nostolenitems, "error", 5000)
    end
end

local function setupPedInteractions()
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

    if Config.UseOxTarget then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = "ox_sell",
                label = Config.Stolen,
                icon = "fas fa-money-bill",
                onSelect = function()
                    openSellMenu()
                end,
                canInteract = function()
                    return true
                end
            }
        })
    else
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
    end

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
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    setupPedInteractions()
end)

Citizen.CreateThread(function()
    local function setupTargetForPeds()
        local peds = GetGamePool('CPed')
        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                if IsPedHuman(ped) then
                    local pedModel = GetEntityModel(ped)

                    for _, model in ipairs(Config.Peds) do
                        if pedModel == GetHashKey(model) then
                            if Config.UseOxTarget then
                                exports.ox_target:addLocalEntity(ped, {
                                    {
                                        name = "ox_robbery",
                                        label = Config.Rob,
                                        icon = "fas fa-sack-dollar",
                                        onSelect = function()
                                            startRobbery(ped)
                                        end,
                                        canInteract = function()
                                            return not isPedDeadOrDying(ped)
                                        end
                                    },
                                    {
                                        name = "ox_takeHostage",
                                        label = Config.TakeHostage,
                                        icon = "fas fa-handcuffs",
                                        onSelect = function()
                                            takeHostage(ped)
                                        end,
                                        canInteract = function()
                                            return not holdingHostage and not isPedDeadOrDying(ped)
                                        end
                                    }
                                })
                            else
                                exports['qb-target']:AddTargetEntity(ped, {
                                    options = {
                                        {
                                            event = "smdx-npcrobbery:start",
                                            icon = "fas fa-sack-dollar",
                                            label = Config.Rob,
                                            canInteract = function(entity)
                                                return IsPedHuman(entity)
                                            end,
                                            action = function(entity)
                                                startRobbery(entity)
                                            end
                                        },
                                        {
                                            event = "smdx-npcrobbery:takeHostage",
                                            icon = "fas fa-handcuffs",
                                            label = Config.TakeHostage,
                                            canInteract = function(entity)
                                                return not holdingHostage and not IsPedDeadOrDying(entity)
                                            end,
                                            action = function(entity)
                                                takeHostage(entity)
                                            end
                                        }
                                    },
                                    distance = 2.5
                                })
                            end
                        end
                    end
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
