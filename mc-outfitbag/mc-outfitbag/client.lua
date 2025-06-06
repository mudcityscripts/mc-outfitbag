local placedBag = nil
local bagOwner = nil

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
end

RegisterNetEvent('mc-outfitbag:useBag', function()
    if placedBag then
        lib.notify({type = 'error', description = 'You already placed a bag.'})
        return
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Place animation
    loadAnimDict(Config.Animation.place.dict)
    TaskPlayAnim(playerPed, Config.Animation.place.dict, Config.Animation.place.anim, 8.0, -8, -1, 1, 0, false, false, false)
    Wait(1000)

    local model = Config.PropModel
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    placedBag = CreateObject(model, coords.x, coords.y, coords.z - 1.0, true, true, false)
    SetEntityHeading(placedBag, GetEntityHeading(playerPed))
    PlaceObjectOnGroundProperly(placedBag)
    FreezeEntityPosition(placedBag, true)
    SetEntityAsMissionEntity(placedBag, true, true)

    bagOwner = cache.serverId -- Store ownership

    lib.notify({type = 'inform', description = 'You placed your outfit bag. Use [E] nearby to access or pick it up.'})
end)

-- Listen for keypress when near
CreateThread(function()
    while true do
        Wait(0)
        if placedBag then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local bagCoords = GetEntityCoords(placedBag)
            local dist = #(coords - bagCoords)

            if dist < 2.0 then
                lib.showTextUI('[E] Open Outfit Bag | [G] Pick Up Bag', {
                    icon = 'suitcase',
                    position = "right-center",
                    style = {borderRadius = 10}
                })

                if IsControlJustReleased(0, 38) then -- E
                    TriggerServerEvent('mc-outfitbag:requestOpen', NetworkGetNetworkIdFromEntity(placedBag))
                elseif IsControlJustReleased(0, 47) then -- G
                    TriggerServerEvent('mc-outfitbag:requestPickup', NetworkGetNetworkIdFromEntity(placedBag))
                end
            else
                lib.hideTextUI()
            end
        else
            Wait(1000)
        end
    end
end)

RegisterNetEvent('mc-outfitbag:openBag', function()
    local playerPed = PlayerPedId()
    loadAnimDict(Config.Animation.search.dict)
    TaskPlayAnim(playerPed, Config.Animation.search.dict, Config.Animation.search.anim, 8.0, -8.0, -1, 1, 0, false, false, false)

    Wait(2000)
    exports['illenium-appearance']:openOutfitMenu()
end)

RegisterNetEvent('mc-outfitbag:pickupBag', function()
    local playerPed = PlayerPedId()
    if placedBag then
        loadAnimDict(Config.Animation.pickup.dict)
        TaskPlayAnim(playerPed, Config.Animation.pickup.dict, Config.Animation.pickup.anim, 8.0, -8.0, -1, 1, 0, false, false, false)

        Wait(1000)
        DeleteObject(placedBag)
        placedBag = nil
        bagOwner = nil

        TriggerServerEvent('mc-outfitbag:giveItemBack')
        lib.notify({type = 'success', description = 'You picked up your outfit bag.'})
    end
end)
