local QBCore = exports['qb-core']:GetCoreObject()

-- Register outfitbag as usable item
QBCore.Functions.CreateUseableItem(Config.DuffleBagItem, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local item = exports.ox_inventory:GetItem(source, Config.DuffleBagItem)
    if item and item.count > 0 then
        exports.ox_inventory:RemoveItem(source, Config.DuffleBagItem, 1)
        TriggerClientEvent(Shared.ResourceName .. ':client:useDuffleBag', source)
    else
        TriggerClientEvent('QBCore:Notify', source, 'You don\'t have an outfit bag!', 'error')
    end
end)

-- Handle picking up the bag
RegisterNetEvent(Shared.ResourceName .. ':server:pickupDuffleBag', function()
    local src = source
    exports.ox_inventory:AddItem(src, Config.DuffleBagItem, 1)
end)