local QBCore = exports['qb-core']:GetCoreObject()
local ox_inventory = exports.ox_inventory
local duffleBagObject = nil
local isUsingBag = false

-- Load outfits from JSON with error handling
local function LoadOutfits()
    local resourceName = GetCurrentResourceName()
    local fileContent = LoadResourceFile(resourceName, 'outfits.json')
    if not fileContent then
        print('[ERROR] Failed to load outfits.json - file not found or inaccessible')
        return {}
    end
    local success, outfits = pcall(json.decode, fileContent)
    if not success or not outfits then
        print('[ERROR] Failed to parse outfits.json - invalid JSON format')
        return {}
    end
    if type(outfits) ~= 'table' or #outfits == 0 then
        print('[ERROR] outfits.json is empty or not an array')
        return {}
    end
    print('[DEBUG] Successfully loaded ' .. #outfits .. ' outfits from outfits.json')
    return outfits
end

local outfits = LoadOutfits()

-- Apply an outfit from JSON
local function ApplyOutfit(outfit)
    local playerPed = PlayerPedId()
    if not playerPed or playerPed == 0 then
        print('[ERROR] Failed to get player ped for applying outfit')
        return
    end
    for componentId, component in pairs(outfit.components or {}) do
        SetPedComponentVariation(playerPed, tonumber(componentId), component.drawable, component.texture, 0)
    end
    for propId, prop in pairs(outfit.props or {}) do
        if prop.drawable == -1 then
            ClearPedProp(playerPed, tonumber(propId))
        else
            SetPedPropIndex(playerPed, tonumber(propId), prop.drawable, prop.texture, true)
        end
    end
    print('[DEBUG] Applied outfit: ' .. outfit.name)
end

-- Show outfit menu
local function ShowOutfitMenu()
    if not lib then
        print('[DEBUG] ox_lib not loaded, cannot show menu')
        return
    end
    local menuOptions = {}
    if #outfits == 0 then
        print('[WARNING] No outfits available to display in menu')
        QBCore.Functions.Notify('No outfits available', 'error')
    else
        print('[DEBUG] Loading ' .. #outfits .. ' outfits into menu')
        for i, outfit in ipairs(outfits) do
            if outfit.name and outfit.components then
                table.insert(menuOptions, {
                    title = outfit.name,
                    description = "Apply " .. outfit.name .. " outfit",
                    onSelect = function()
                        ApplyOutfit(outfit)
                        QBCore.Functions.Notify('Outfit applied: ' .. outfit.name, 'success')
                    end
                })
                print('[DEBUG] Added outfit to menu: ' .. outfit.name)
            else
                print('[DEBUG] Outfit at index ' .. i .. ' is invalid (missing name or components), skipping')
            end
        end
    end
    lib.registerContext({
        id = 'outfit_bag_menu',
        title = 'Select Outfit',
        options = menuOptions
    })
    lib.showContext('outfit_bag_menu')
    print('[DEBUG] Outfit menu displayed')
end

-- Spawn duffle bag on ground
local function SpawnDuffleBag()
    local playerPed = PlayerPedId()
    if not playerPed or playerPed == 0 then
        print('[ERROR] Failed to get player ped for spawning bag')
        return
    end
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnCoords = vector3(coords.x + forward.x * 1.0, coords.y + forward.y * 1.0, coords.z - 1.0)

    print('[DEBUG] Loading prop model: ' .. Config.DuffleBagProp)
    RequestModel(Config.DuffleBagProp)
    while not HasModelLoaded(Config.DuffleBagProp) do
        Wait(0)
    end

    duffleBagObject = CreateObject(GetHashKey(Config.DuffleBagProp), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
    print('[DEBUG] Spawned dufflebag object: ' .. tostring(duffleBagObject))
    if duffleBagObject and DoesEntityExist(duffleBagObject) then
        PlaceObjectOnGroundProperly(duffleBagObject)
        SetEntityHeading(duffleBagObject, heading)
        SetModelAsNoLongerNeeded(Config.DuffleBagProp)
    else
        print('[DEBUG] Failed to spawn dufflebag object')
        isUsingBag = false
        return
    end

    CreateThread(function()
        while duffleBagObject do
            local playerCoords = GetEntityCoords(playerPed)
            local bagCoords = GetEntityCoords(duffleBagObject)
            local distance = #(playerCoords - bagCoords)

            if distance < Config.InteractDistance then
                BeginTextCommandDisplayHelp('STRING')
                AddTextComponentSubstringPlayerName('Press ~INPUT_CONTEXT~ to Open Bag | Press ~INPUT_VEH_HEADLIGHT~ to Pick Up Bag')
                EndTextCommandDisplayHelp(0, false, true, -1)

                if IsControlJustPressed(0, Config.InteractKey) then
                    RequestAnimDict(Config.OpenAnimation.dict)
                    while not HasAnimDictLoaded(Config.OpenAnimation.dict) do
                        Wait(0)
                    end
                    TaskPlayAnim(playerPed, Config.OpenAnimation.dict, Config.OpenAnimation.clip, 8.0, -8.0, -1, 49, 0, false, false, false)

                    print('[DEBUG] Opening custom outfit menu')
                    ShowOutfitMenu()

                    Wait(2000)
                    ClearPedTasks(playerPed)
                end

                if IsControlJustPressed(0, 74) then
                    print('[DEBUG] Picking up dufflebag')
                    TriggerServerEvent(Shared.ResourceName .. ':server:pickupDuffleBag')
                    DeleteDuffleBag()
                    break
                end
            end

            Wait(0)
        end
    end)
end

-- Delete duffle bag object
function DeleteDuffleBag()
    if duffleBagObject then
        print('[DEBUG] Deleting dufflebag object: ' .. tostring(duffleBagObject))
        DeleteObject(duffleBagObject)
        duffleBagObject = nil
        isUsingBag = false
    end
end

-- Handle using the duffle bag item
RegisterNetEvent(Shared.ResourceName .. ':client:useDuffleBag', function()
    print('[DEBUG] Client received useDuffleBag event')
    if isUsingBag then
        QBCore.Functions.Notify('You are already using a bag!', 'error')
        return
    end

    isUsingBag = true

    local playerPed = PlayerPedId()
    if not playerPed or playerPed == 0 then
        print('[ERROR] Failed to get player ped for using bag')
        return
    end
    RequestAnimDict(Config.UseAnimation.dict)
    while not HasAnimDictLoaded(Config.UseAnimation.dict) do
        Wait(0)
    end
    TaskPlayAnim(playerPed, Config.UseAnimation.dict, Config.OpenAnimation.clip, 8.0, -8.0, -1, 49, 0, false, false, false)

    lib.progressBar({
        duration = 3000,
        label = 'Placing Outfit Bag...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true
        }
    })

    ClearPedTasks(playerPed)
    SpawnDuffleBag()
end)

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == Shared.ResourceName then
        DeleteDuffleBag()
    end
end)