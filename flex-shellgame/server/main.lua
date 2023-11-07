local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('flex-shellgame:server:setstate', function(id, state)
    TriggerClientEvent('flex-shellgame:client:setstate', -1, id, state)
end)

RegisterNetEvent('flex-shellgame:server:arrested', function(id, state)
    TriggerClientEvent('flex-shellgame:client:arrested', -1, id, state)
end)

RegisterNetEvent('flex-shellgame:server:speech', function(k, speech)
    TriggerClientEvent('flex-shellgame:client:speech', -1, k, speech)
end)

RegisterNetEvent('flex-shellgame:server:playanim', function(ped, animdic, anim)
    TriggerClientEvent('flex-shellgame:client:playanim', -1, ped, animdic, anim)
end)

QBCore.Functions.CreateCallback('flex-shellgame:server:HasMoney', function(source, cb, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.money.cash >= amount then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('flex-shellgame:server:play', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveMoney('cash', amount) then
        TriggerClientEvent("QBCore:Notify", src, Lang:t("error.placebet", {value = tostring(amount)}), "error")
    end
end)

RegisterNetEvent('flex-shellgame:server:win', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local reward = amount * Config.RewardMulti
    if Player.Functions.AddMoney('cash', reward) then
        TriggerClientEvent("QBCore:Notify", src, Lang:t("success.getreward", {value = tostring(Config.RewardMulti), value2 = tostring(reward)}), "success")
    end
end)