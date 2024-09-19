local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('smdx-npcrobbery:giveReward')
AddEventHandler('smdx-npcrobbery:giveReward', function(type, value)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if type == 'item' then
        Player.Functions.AddItem(value, 1)
        TriggerClientEvent('QBCore:Notify', src, Config.Reciveditem .. value, "success", 5000)
    elseif type == 'money' then
        Player.Functions.AddMoney('cash', value)
        TriggerClientEvent('QBCore:Notify', src, Config.Recived, Config.Money .. value, "success", 5000)
    end
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
    local Player = QBCore.Functions.GetPlayer(src)

    if robberyCooldown then
        local remainingCooldown = math.ceil(cooldownEndTime - GetGameTimer()) / 1000
        if remainingCooldown > 0 then
            TriggerClientEvent('QBCore:Notify', src, Config.Wait .. remainingCooldown .. " " .. Config.Sec, 'error', 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, "No active cooldown!", 'success', 5000)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "No active cooldown!", 'success', 5000)
    end
end)

