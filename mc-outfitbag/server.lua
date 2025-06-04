local QBCore = exports['qb-core']:GetCoreObject()
local activeBags = {} -- Track player bags

-- Place bag
RegisterNetEvent('mc-outfitbag:server:placeBag', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if activeBags[src] then
        TriggerClientEvent('QBCore:Notify', src, 'You already have a bag placed!', 'error')
        return
    end
    
    local item = exports.ox_inventory:Search(src, 'count', 'outfitbag')
    if item >= 1 then
        activeBags[src] = true
        TriggerClientEvent('mc-outfitbag:client:placeBag', src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You need an outfit bag!', 'error')
    end
end)

-- Open bag
RegisterNetEvent('mc-outfitbag:server:open', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if not activeBags[src] then
        TriggerClientEvent('QBCore:Notify', src, 'No bag placed!', 'error')
        return
    end
    
    local item = exports.ox_inventory:Search(src, 'count', 'outfitbag')
    if item >= 1 then
        TriggerClientEvent('mc-outfitbag:client:openOutfitBag', src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You need an outfit bag!', 'error')
    end
end)

-- Pickup bag
RegisterNetEvent('mc-outfitbag:server:pickup', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if activeBags[src] then
        activeBags[src] = nil
        TriggerClientEvent('QBCore:Notify', src, 'Bag picked up!', 'success')
    end
end)