local QBCore = exports['qb-core']:GetCoreObject()

local robberyCooldown = {}

local discordWebhook = Config.WebhookURL

local function sendDiscordLog(playerName, rewardItem, money)
    local embed = {
        {
            ["color"] = Config.Color,
            ["title"] = Config.title,
            ["description"] = "**" .. playerName .. "** Robbed a Local.",
            ["fields"] = {
                {
                    ["name"] = Config.Reward,
                    ["value"] = rewardItem and ("items: " .. rewardItem) or "Inga föremål",
                    ["inline"] = true
                },
                {
                    ["name"] = Config.Money,
                    ["value"] = money and ("$" .. money) or "Inga pengar",
                    ["inline"] = true
                },
            },
            ["footer"] = {
                ["text"] = "SMDX-NPCRobbery",
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ") 
        }
    }

    PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({
        username = Config.Botname, 
        embeds = embed 
    }), { ['Content-Type'] = 'application/json' })
end

QBCore.Functions.CreateCallback('smdx-npcrobbery:getPoliceCount', function(source, cb)
    local policeCount = 0
    for _, player in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(player)
        if Player and Player.PlayerData.job and Player.PlayerData.job.name == "police" then
            policeCount = policeCount + 1
        end
    end
    cb(policeCount)
end)

RegisterNetEvent('smdx-npcrobbery:giveReward')
AddEventHandler('smdx-npcrobbery:giveReward', function(item, money)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerName = GetPlayerName(src)
    local rewardItem = nil

    if item then
        Player.Functions.AddItem(item, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
        TriggerClientEvent('QBCore:Notify', src, Config.Reciveditem .. item, "success", 5000)
        rewardItem = item 
    end

    if money then
        Player.Functions.AddMoney('cash', money)
        TriggerClientEvent('QBCore:Notify', src, Config.Recived .. Config.Money .. money, "success", 5000)
    end
    sendDiscordLog(playerName, rewardItem, money)
end)

RegisterNetEvent('smdx-npcrobbery:sellItem')
AddEventHandler('smdx-npcrobbery:sellItem', function(itemData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local itemName = itemData.itemName
    local itemPrice = itemData.itemPrice

    if not Config.ItemSellPrice[itemName] then
        TriggerClientEvent('QBCore:Notify', src, Config.Cannotsold, "error", 5000)
        return
    end

    local item = Player.Functions.GetItemByName(itemName)
    if item then
        local minPrice = Config.ItemSellPrice[itemName].min
        local maxPrice = Config.ItemSellPrice[itemName].max
        local itemPrice = math.random(minPrice, maxPrice)

        Player.Functions.RemoveItem(itemName, 1)

        if Config.MoneyType == 'cash' then
            Player.Functions.AddMoney('cash', itemPrice)
        elseif Config.MoneyType == 'bank' then
            Player.Functions.AddMoney('bank', itemPrice)
        else
            TriggerClientEvent('QBCore:Notify', src, Config.InvalidMoney, "error", 5000)
            return
        end

       TriggerClientEvent('QBCore:Notify', src, Config.Sold .. itemName .. Config.For .. itemPrice, "success", 5000)

    else
        TriggerClientEvent('QBCore:Notify', src, Config.Donthave, "error", 5000)
    end
end)

QBCore.Commands.Add("checkcooldown", "Check robbery cooldown", {}, false, function(source, args)
    local src = source
    local cooldown = robberyCooldown[src]

    if cooldown and cooldown > GetGameTimer() then
        local remainingCooldown = math.ceil((cooldown - GetGameTimer()) / 1000)
        TriggerClientEvent('QBCore:Notify', src, Config.Wait .. remainingCooldown .. " " .. Config.Sec, 'error', 5000)
    else
        TriggerClientEvent('QBCore:Notify', src, Config.NoActiveCooldown, 'success', 5000)
    end
end)

RegisterNetEvent('smdx-npcrobbery:setCooldown')
AddEventHandler('smdx-npcrobbery:setCooldown', function(cooldownTime)
    local src = source
    robberyCooldown[src] = GetGameTimer() + (cooldownTime * 1000)
end)
