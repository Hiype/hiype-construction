local QBCore = exports['qb-core']:GetCoreObject()

-- Add jobs and items to qb-core
QBCore.Functions.AddJobs(Config.Job)
QBCore.Functions.AddItems(Config.Items)

RegisterNetEvent('hiype-construction:server:addItem', function(pItemName, pAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.AddItem(pItemName, pAmount)
end)

RegisterNetEvent('hiype-construction:server:removeItem', function(pItemName, pAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem(pItemName, pAmount)
end)

RegisterNetEvent('hiype-construction:server:set-job', function(job, grade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    Player.Functions.SetJob(job, grade)
end)

RegisterNetEvent('hiype-construction:server:add-money', function(amount, m_type)
    local Player = QBCore.Functions.GetPlayer(source)
    if m_type == "cash" then
        Player.Functions.AddMoney("cash", amount)
    else
        Player.Functions.AddMoney("bank", amount)
    end
end)