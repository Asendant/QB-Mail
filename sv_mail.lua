local QBCore = exports['qb-core']:GetCoreObject()

-- Events
RegisterNetEvent('qb-mail:server:finishedRoute', function(pay)
    local src= source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.AddMoney('cash', pay, 'Finished Delivery')
end)

RegisterNetEvent('qb-mail:server:returnDeposit', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Config.UseDeposit then
        Player.Functions.AddMoney('cash', Config.DepositAmount, 'Mail Truck Deposit Return')
    end
end)

-- Callbacks
QBCore.Functions.CreateCallback('qb-mail:server:hasPayment', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.PlayerData.money.cash >= Config.DepositAmount then
        Player.Functions.RemoveMoney('cash', Config.DepositAmount, "Mail Truck Deposit")
        cb(true)
        return
    end

    cb(false)
end)