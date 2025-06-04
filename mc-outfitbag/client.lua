local QBCore = exports['qb-core']:GetCoreObject()
local bagObject = nil
local bagNetId = nil

-- Place bag
RegisterNetEvent('mc-outfitbag:client:placeBag', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    RequestModel(`prop_cs_suitcase`)
    while not HasModelLoaded(`prop_cs_suitcase`) do
        Wait(100)
    end
    
    bagObject = CreateObject(`prop_cs_suitcase`, coords.x, coords.y, coords.z - 0.95, true, true, false)
    SetEntityHeading(bagObject, heading)
    PlaceObjectOnGroundProperly(bagObject)
    bagNetId = NetworkGetNetworkIdFromEntity(bagObject)
    
    -- Add qb-target zone
    exports['qb-target']:AddTargetEntity(bagNetId, {
        options = {
            {
                type = "client",
                event = "mc-outfitbag:client:tryOpen",
                icon = Config.TargetIcon,
                label = Config.TargetLabel,
            },
        },
        distance = 2.0,
    })
end)

-- Try to open bag
RegisterNetEvent('mc-outfitbag:client:tryOpen', function()
    TriggerServerEvent('mc-outfitbag:server:open')
end)

-- Open outfit menu with animation
RegisterNetEvent('mc-outfitbag:client:openOutfitBag', function()
    local playerPed = PlayerPedId()
    
    -- Load and play crouching animation
    local animDict = Config.AnimDict
    local animName = Config.AnimName
    QBCore.Functions.RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(100)
    end
    
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 5000, 1, 0, false, false, false)
    QBCore.Functions.Notify('Opening outfit bag...', 'success')
    Wait(5000) -- 5-second animation
    
    -- Trigger iLLeniumStudios outfit menu
    TriggerEvent('illenium-appearance:client:openOutfitMenu')
end)

-- Pickup bag
RegisterNetEvent('mc-outfitbag:client:pickupBag', function()
    if bagObject and DoesEntityExist(bagObject) then
        exports['qb-target']:RemoveTargetEntity(bagNetId, 'Open Outfit Bag')
        DeleteEntity(bagObject)
        bagObject = nil
        bagNetId = nil
        TriggerServerEvent('mc-outfitbag:server:pickup')
    end
end)