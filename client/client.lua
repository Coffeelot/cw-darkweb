local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug
local availableAds = {}
local activeDropoffSpots = {}
local attachedProp = nil
local blips = {}
local purchasedIds = {}

local function notify(text, type)
    if Config.OxLibNotify then
        lib.notify({
            title = text,
            type = type,
        })
    else 
        QBCore.Functions.Notify(text, type)
    end
end

local function getItemsInPockets()
    if Config.Inventory == 'ox' then
        return exports.ox_inventory:GetPlayerItems()
    elseif Config.Invenotry == 'qb' then
        return QBCore.Functions.GetPlayerData().items
    else
        print('^1USING AN UNSUPPORTED INVENTORY SYSTEM^0')
    end

end

local function getSizeOfTable(table)
    local count = 0
    if table then
        for i, item in pairs(table) do
            count = count + 1
        end
    end
    return count
end

local function clearProp()
    if useDebug then
       print('REMOVING PROP', attachedProp)
    end
    if DoesEntityExist(attachedProp) then
        DeleteEntity(attachedProp)
        attachedProp = 0
    end
end

local function stopAnimation()
    ClearPedTasks(PlayerPedId())
    clearProp()
end


local function attachProp()
    clearProp()
    local model = 'prop_cs_tablet'
    local boneNumber = 28422
    SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263)
    local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumber)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
    attachedProp = CreateObject(model, 1.0, 1.0, 1.0, 1, 1, 0)
    local x, y,z = 0.0, -0.03, 0.0
    local xR, yR, zR = 20.0, -90.0, 0.0
    AttachEntityToEntity(attachedProp, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, 0, true, false, true, 2, true)
end

local function handleAnimation()
    local animDict = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a'
    if not DoesAnimDictExist(animDict) then
        print('animation dict does not exist')
        return false
    end
    RequestAnimDict(animDict)
    while (not HasAnimDictLoaded(animDict)) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, "idle_a", 5.0, 5.0, -1, 51, 0, false, false, false)
    attachProp()
end

local function getStuffAtLocation(coords)
    if not activeDropoffSpots or getSizeOfTable(activeDropoffSpots) == 0 then if useDebug then print('^4No dropoffs available') end return nil end
    for i, dropOffLocation in pairs(activeDropoffSpots) do
        if dropOffLocation.coords == coords then
            if useDebug then print('^2Spot had a dropoff!') end
            notify('Found stuff', 'success')
            return dropOffLocation
        else
            if useDebug then print('^1Spot did not have a dropoff!') end
            return nil
        end
    end
end

local animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
local animName = "weed_crouch_checkingleaves_idle_04_inspector"
local animNameHigh = "weed_stand_checkingleaves_idle_02_inspector"

local function animDictIsLoaded()
    if HasAnimDictLoaded(animDict) then if useDebug then print('^6Animation was already loaded') end return true end

    RequestAnimDict(animDict)

    local retrys = 0
    while not HasAnimDictLoaded(animDict) do
        if useDebug then print('Loading animation dict for gearbox', animDict) end
        retrys = retrys + 1
        if retrys > 10 then if useDebug then print('Breaking early') end return false end
        Wait(0)
    end
    return true
end

local function cancelAnimation(high)
    local animationName = animName
    if high then animationName = animNameHigh end
    StopAnimTask(PlayerPedId(), animDict, animationName, 1.0)
    RemoveAnimDict(animDict)
end

local function applyAnimate(coords, high)
    local animationName = animName
    if high then animationName = animNameHigh end
    TaskTurnPedToFaceCoord(PlayerPedId(), coords.x, coords.y, coords.z, 400)
    Citizen.SetTimeout(400, function()
        if animDictIsLoaded() then
            if useDebug then print('^2Animation loaded successfully') end
            TaskPlayAnim(PlayerPedId(), animDict, animationName, 8.0, 1.0, Config.ProgressbarTimeMS, 1, 0, 0, 0, 0)
        else
            if useDebug then print('^1Could not load animation') notify('Animation broke', 'error') end
        end
    end)
end

local function grabLoot(coords)
    local dropoff = getStuffAtLocation(coords)
    if dropoff then
        TriggerServerEvent('cw-darkweb:server:doPickup', dropoff.id)
    else
        notify('Nothing here', 'error')
    end
end

local function attemptPickup(locationId)
    local location = Config.DropoffLocations[locationId]
    applyAnimate(location.coords, location.animateHigh)

    if Config.UseOxLibForProgressbar then
        if lib.progressBar({
            label = 'Searching...',
            duration = Config.ProgressbarTimeMS,
            useWhileDead = false,
            canCancel = true,
            disable = { car = true }
        }) then
            grabLoot(location.coords)
            cancelAnimation(location.animateHigh)
        else
            cancelAnimation(location.animateHigh)
        end
    else
        QBCore.Functions.Progressbar("darkweb_loot", "Searching...", Config.ProgressbarTimeMS, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
        }, {}, {}, function() -- Done
            grabLoot(location.coords)
            cancelAnimation(location.animateHigh)
        end, function() -- Cancel
            cancelAnimation(location.animateHigh)
        end)
    end
end

local function closeDarkwebTablet()
    SetNuiFocus(false, false)
    stopAnimation()
    StopScreenEffect('MenuMGIn')
    SendNUIMessage({
        action = "cwDarkweb",
        toggle = false,
        type = 'toggleUi',
    })
end

local function openDarkwebTablet()
    TriggerServerEvent('cw-darkweb:server:getLatestList')
    handleAnimation()
    SetNuiFocus(true, true)
    StartScreenEffect('MenuMGIn', 1, true)
    SendNUIMessage({
        action = "cwDarkweb",
        toggle = true,
        type = 'toggleUi',
        inventory = getItemsInPockets()
    })
end

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    TriggerServerEvent('cw-darkweb:server:getLatestList')
    SendNUIMessage({
        action = "cwDarkweb",
        type = 'baseData',
        baseData = {
            useLocalImages= Config.UseLocalImages,
            oxInventory= Config.Inventory == 'ox',
            currency= Config.CurrencyString
        },
    })
end)

RegisterNetEvent("cw-darkweb:client:openApp", function()

    local skills = nil
    if Config.UseCwRep then
        skills = exports['cw-rep']:getAllSkillsAndLevel()
    end

    SendNUIMessage({
        action = "cwDarkweb",
        type = 'baseData',
        baseData = {
            useLocalImages= Config.UseLocalImages,
            oxInventory= Config.Inventory == 'ox',
            currency= Config.CurrencyString,
            playerRep = skills,
            useLevelsInsteadOfXp = Config.UseLevelInsteadOfXP
        },
    })
    openDarkwebTablet()
end)

local function myPickups()
    local pickups = {}
    for i, id in pairs(purchasedIds) do
        for j, pickup in pairs(activeDropoffSpots) do
            if id == j then
                pickups[#pickups+1] = pickup
            end
        end
    end
    return pickups
end

RegisterNetEvent('cw-darkweb:client:updateGlobalList', function(ads, dropOffs)
	availableAds = ads
    activeDropoffSpots = dropOffs
    if useDebug then 
        print('new ads:', json.encode(ads, {indent=true}))
        print('new pickups:', json.encode(dropOffs, {indent=true}))
    end
    SendNUIMessage({
        action = "cwDarkweb",
        type = 'updateList',
        ads = ads,
        pickups = myPickups()
    })
end)


RegisterNetEvent('cw-darkweb:client:notifyPickup', function(dropoff)
    for blipId, coords in pairs(blips) do
        if dropoff.coords == coords then 
            RemoveBlip(blipId)
            blips[blipId] = nil
        end
    end
    notify('Your items have been collected', 'success')

end)

RegisterNetEvent('cw-darkweb:client:notifyBuyer', function(coords, id)
    purchasedIds[#purchasedIds+1] = id 
    notify('Your pickup has been marked on your gps', 'success')
    local blipId = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blipId, Config.Blip.sprite)
    SetBlipColour(blipId, Config.Blip.color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Blip.label)
    EndTextCommandSetBlipName(blipId)
    blips[blipId] = coords
end)

CreateThread(function()
    for i, dropoff in ipairs(Config.DropoffLocations) do
        local name = 'darkweb-dropoff-'..i
        local options = {}
        options[1] = {
            type = 'client',
            label = Config.DropoffTargetTitle,
            icon = Config.DropoffTargetIcon,
            action = function()
                attemptPickup(i)
            end,
            onSelect = function()
                attemptPickup(i)
            end,
        }
        if Config.QbTarget then
            exports['qb-target']:AddBoxZone(name, dropoff.coords,1.5, 1.5, {
                name = name,
                heading = 0,
                debugPoly = useDebug,
                minZ = dropoff.coords.z - 0.5,
                maxZ = dropoff.coords.z + 0.5
            }, {
                options = options,
                distance = 2.0
            })
        else
            exports.ox_target:addSphereZone({
                name = name,
                coords = dropoff.coords,
                radius = 1.5,
                options = options
            })
        end
    end
end)

RegisterNUICallback('UiCloseUi', function(_, cb)
    closeDarkwebTablet()
    cb(true)
end)

RegisterNUICallback('UiSetWaypoint', function(coords, cb)
    if useDebug then print('setting wp to ', json.encode(coords, {indent=true})) end
    SetNewWaypoint(coords.x, coords.y)
end)

RegisterNUICallback('UiAttemptPurchase', function(adId, cb)
    if not adId then
        print('^1SETUP ERROR: No id')
        cb(false)
        return
    end
    if useDebug then print('Attempting to purchase ad with id', adId) end
    if Config.OxForCallbacks then
        local result = lib.callback.await('cw-darkweb:server:attemptPurchase', false, adId)
        if useDebug then print('Purchase attempt result:', result) end
        cb(result)
    else
        QBCore.Functions.TriggerCallback('cw-darkweb:server:attemptPurchase', function(result)
            cb(result)
        end, adId)
    end
end)