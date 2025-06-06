local bagOwners = {}

RegisterServerEvent('mc-outfitbag:requestOpen', function(netId)
    local src = source
    local owner = bagOwners[netId]

    if owner ~= src then
        print(('^1[Anti-Cheat]^0 Player %s tried to open bag owned by %s'):format(src, owner or "nil"))
        DropPlayer(src, "Unauthorized bag access detected.")
        return
    end

    TriggerClientEvent('mc-outfitbag:openBag', src)
end)

RegisterServerEvent('mc-outfitbag:requestPickup', function(netId)
    local src = source
    local owner = bagOwners[netId]

    if owner ~= src then
        print(('^1[Anti-Cheat]^0 Player %s tried to pick up bag owned by %s'):format(src, owner or "nil"))
        DropPlayer(src, "Unauthorized bag pickup detected.")
        return
    end

    bagOwners[netId] = nil
    TriggerClientEvent('mc-outfitbag:pickupBag', src)
end)

RegisterNetEvent('mc-outfitbag:giveItemBack', function()
    local xPlayer = source
    exports.ox_inventory:AddItem(xPlayer, Config.ItemName, 1)
end)

-- Track ownership
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        bagOwners = {}
    end
end)
