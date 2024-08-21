local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug
local availablePlayerAds = {}
local availableAds = {}
local activeDropoffSpots = {}
local attachedProp = nil
local blips = {}
local purchasedIds = {}
local currentAccount = nil

local function debugLog(message, message2, message3)
    if useDebug then
        print('^2CW-DARKWEB DEBUG:^0', message)
        if message2 then
            print(message2)
        end
        if message3 then
            print(message3)
        end
    end
end

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

local function getCitizenId() 
    return QBCore.Functions.GetPlayerData().citizenid
end

local function fetchPlayerAccount()
    local citizenId = getCitizenId()
    if not citizenId then
        debugLog('Could not find citizenID for player')
    end
    if Config.OxForCallbacks then
        local result = lib.callback.await('cw-darkweb:server:getPlayerAccount', citizenId)
        debugLog('Setting account to', json.encode(result, {indent=true}))
        currentAccount = result
    else
        QBCore.Functions.TriggerCallback('cw-darkweb:server:getPlayerAccount', function(result)
            debugLog('Setting account to', json.encode(result, {indent=true}))
            currentAccount = result
        end, citizenId)
    end
end

local function setupPrintout()
    if useDebug then
        print('^4=== '.. GetCurrentResourceName()..' ===')
        print('^2= Base setup = ')
        print('Using OX Lib for notify', Config.OxLibNotify)
        print('Using OX Lib Callbacks', Config.OxForCallbacks)
        print('Inventory:', Config.Inventory)
    
        print('^2= Rep = ')
        print('Using CW Rep', Config.UseCwRep)
        print('Using Level instead of skill', Config.UseLevelInsteadOfXP)
        if not Config.UseCwRep and Config.UseLevelInsteadOfXP then print('^1Thissetup is incorrect. You need cw rep to use levels') end
        
        print('^2= Accounts =')
        print('Block npc trades with no account:', Config.NoAccountBlocksPublicTrades)
        print('Account creation cost:', Config.AccountCreationCost)
        print('Account removal cost:', Config.AccountRemovalCost)
        print('Ban Threshold:', Config.BanThreshold)
    
        print('^2= Ads =')
        print('Ad creation cost', Config.AdCreationCost )
        print('Money type: ', Config.MoneyType)
        print('Currency string: ', Config.CurrencyString)

        print('^2= General =')
        print('Using custom charge function:', Config.UseCustomChargeFunction)
        print('Amount of ads', #Config.DarkwebAds)
        print('Amount of dropoff locations', #Config.DropoffLocations)
        print('Locale exists:', not not Config.Locale)
    end
end

AddEventHandler('onResourceStart', function (resource)
    if resource ~= GetCurrentResourceName() then return end
    fetchPlayerAccount()
    Wait(1000)
    setupPrintout()
    SendNUIMessage({
        action = "cwDarkweb",
        type = 'baseData',
        baseData = {
            translations = Config.Locale,
            useLocalImages= Config.UseLocalImages,
            oxInventory= Config.Inventory == 'ox',
            currency= Config.CurrencyString,
            accountCost= Config.AccountCreationCost,
            useLevelsInsteadOfXp = Config.UseLevelInsteadOfXP,
            noAccountBlocksPublicTrades = Config.NoAccountBlocksPublicTrades,
            auctionTimes = Config.AuctionTimes,
            playerCitizenId = getCitizenId(),
        },
    })
 end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    fetchPlayerAccount()
    TriggerServerEvent('cw-darkweb:server:getLatestList')
    Wait(1000)
    SendNUIMessage({
        action = "cwDarkweb",
        type = 'baseData',
        baseData = {
            translations = Config.Locale,
            useLocalImages= Config.UseLocalImages,
            oxInventory= Config.Inventory == 'ox',
            currency= Config.CurrencyString,
            accountCost= Config.AccountCreationCost,
            useLevelsInsteadOfXp = Config.UseLevelInsteadOfXP,
            noAccountBlocksPublicTrades = Config.NoAccountBlocksPublicTrades,
            auctionTimes = Config.AuctionTimes,
            playerCitizenId = getCitizenId(),
        },
    })
end)

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
    if not activeDropoffSpots or getSizeOfTable(activeDropoffSpots) == 0 then debugLog('^4No dropoffs available') return nil end
    for i, dropOffLocation in pairs(activeDropoffSpots) do
        if dropOffLocation.coords == coords then
            debugLog('^2Spot had a dropoff!')
            notify('Found stuff', 'success')
            return dropOffLocation
        else
            debugLog('^1Spot did not have a dropoff!')
            return nil
        end
    end
end

local animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
local animName = "weed_crouch_checkingleaves_idle_04_inspector"
local animNameHigh = "weed_stand_checkingleaves_idle_02_inspector"

local function animDictIsLoaded()
    if HasAnimDictLoaded(animDict) then debugLog('^6Animation was already loaded') return true end

    RequestAnimDict(animDict)

    local retrys = 0
    while not HasAnimDictLoaded(animDict) do
        debugLog('Loading animation dict for gearbox', animDict)
        retrys = retrys + 1
        if retrys > 10 then debugLog('Breaking early') return false end
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
            debugLog('^2Animation loaded successfully')
            TaskPlayAnim(PlayerPedId(), animDict, animationName, 8.0, 1.0, Config.ProgressbarTimeMS, 1, 0, 0, 0, 0)
        else
            debugLog('^1Could not load animation') 
            notify('Animation broke', 'error')
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


local function updateUiData()
    local skills = nil
    if Config.UseCwRep then
        skills = exports['cw-rep']:getAllSkillsAndLevel()
    end

    SendNUIMessage({
        action = "cwDarkweb",
        type = 'playerData',
        playerData = {
            playerRep = skills,
            account = currentAccount,
        },
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

RegisterNetEvent("cw-darkweb:client:openApp", function()

    updateUiData()
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
    debugLog('new ads:', json.encode(ads, {indent=true}))
    debugLog('new pickups:', json.encode(dropOffs, {indent=true}))
    SendNUIMessage({
        action = "cwDarkweb",
        type = 'updateList',
        ads = ads,
        pickups = myPickups()
    })
end)

RegisterNetEvent('cw-darkweb:client:updatePlayerAds', function(ads)
	availablePlayerAds = ads
    debugLog('new player ads:', json.encode(ads, {indent=true}))
    SendNUIMessage({
        action = "cwDarkweb",
        type = 'updatePlayerList',
        availablePlayerAds = availablePlayerAds,
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

RegisterNetEvent('cw-darkweb:client:updateAccount', function(data)
    currentAccount = data
    updateUiData()
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
    debugLog('setting wp to ', json.encode(coords, {indent=true}))
    SetNewWaypoint(coords.x, coords.y)
end)

RegisterNUICallback('UiAttemptPurchase', function(adId, cb)
    if not adId then
        print('^1SETUP ERROR: No id')
        cb(false)
        return
    end
    debugLog('Attempting to purchase ad with id', adId)
    if Config.OxForCallbacks then
        local result = lib.callback.await('cw-darkweb:server:attemptPurchase', false, adId)
        debugLog('Purchase attempt result:', result)
        cb(result)
    else
        QBCore.Functions.TriggerCallback('cw-darkweb:server:attemptPurchase', function(result)
            cb(result)
        end, adId)
    end
end)

local function getWaypointCoords()
    if IsWaypointActive() then
        local blip = GetFirstBlipInfoId(8) -- 8 is the blip ID for waypoints
        local coords = GetBlipInfoIdCoord(blip)
        return vector3(coords.x, coords.y, coords.z)
    else
        return nil
    end
end

RegisterNUICallback('UiCreateAd', function(data, cb)
    debugLog('Attempting to create ad')

    data.coords = getWaypointCoords()
    if not data.coords then
        cb('NO_WAYPOINT')
        debugLog('The player had no waypoint set')
        return
    end

    data.seller = currentAccount
    data.price = tonumber(data.price)

    if Config.OxForCallbacks then
        local result = lib.callback.await('cw-darkweb:server:attemptCreateAd', data)
        debugLog('Purchase attempt result:', result)
        cb(result)
    else
        QBCore.Functions.TriggerCallback('cw-darkweb:server:attemptCreateAd', function(result)
            debugLog('Purchase attempt result:', result)
            cb(result)
        end, data)
    end
end)

RegisterNUICallback('UiAttemptBid', function(data, cb)
    if not data.adId then
        print('^1SETUP ERROR: No id')
        cb(false)
        return
    end
    debugLog('Attempting to bid on ad with id', data.adId, data.amount)
    if Config.OxForCallbacks then
        local result = lib.callback.await('cw-darkweb:server:attemptPlayerBid', false, data.adId, tonumber(data.amount), currentAccount)
        debugLog('Purchase attempt result:', result)
        cb(result)
    else
        QBCore.Functions.TriggerCallback('cw-darkweb:server:attemptPlayerBid', function(result)
            cb(result)
        end, data.adId, tonumber(data.amount), currentAccount)
    end
end)

RegisterNUICallback('UiRateSeller', function(data, cb)
    if not data.adId then
        print('^1SETUP ERROR: No id')
        cb(false)
        return
    end
    if not data.change then
        print('^1NO RATING SENT')
    end
    debugLog('Rating seller on', data.adId, data.change)
    TriggerServerEvent('cw-darkweb:server:rateSeller', data.adId, data.change)
end)

RegisterNUICallback('UiAcceptBid', function(adId, cb)
    if not adId then
        print('^1SETUP ERROR: No id')
        cb(false)
        return
    end
    debugLog('accepting bid on', adId)
    TriggerServerEvent('cw-darkweb:server:acceptBid', adId)
end)

RegisterNUICallback('UiConformDelivery', function(adId, cb)
    if not adId then
        print('^1SETUP ERROR: No id')
        cb(false)
        return
    end
    debugLog('Marking goods as delivered', adId)
    TriggerServerEvent('cw-darkweb:server:confirmDelivery', adId)
end)

RegisterNUICallback('UiNoShow', function(adId, cb)
    if not adId then
        print('^1SETUP ERROR: No id')
        cb(false)
        return
    end
    debugLog('Marking as buyer no show', adId)
    TriggerServerEvent('cw-darkweb:server:markNoShow', adId)
end)

RegisterNUICallback('UiCreateAccount', function(name, cb)
    if not name then
        print('^1SETUP ERROR: Name missing')
        cb(false)
        return
    end

    local trimmedName = name:gsub("^%s*(.-)%s*$", "%1")
    debugLog('Trimmed Name:', trimmedName)

    local citizenId = getCitizenId()
    if not citizenId then 
        print('^1SETUP ERROR: citizenId missing')
        cb(false)
        return
    end
    if Config.OxForCallbacks then
        local result = lib.callback.await('cw-darkweb:server:attemptCreate', trimmedName, citizenId)
        debugLog('Purchase attempt result:', result)
        if result == 'OK' then
            local playerAccount = lib.callback.await('cw-darkweb:server:getPlayerAccount', citizenId)
            currentAccount = playerAccount
            updateUiData()
        end
        cb(result)
    else
        QBCore.Functions.TriggerCallback('cw-darkweb:server:attemptCreate', function(result)
            if result == 'OK' then
                QBCore.Functions.TriggerCallback('cw-darkweb:server:getPlayerAccount', function(playerAccount)
                    currentAccount = playerAccount
                    updateUiData()
                end, citizenId)
            end
            cb(result)
        end, trimmedName, citizenId)
    end
end)

local function createAccount(name, citizenId)
    if not name then
        print('^1SETUP ERROR: Name missing')
        cb(false)
        return
    end

    local trimmedName = name:gsub("^%s*(.-)%s*$", "%1")
    debugLog('Trimmed Name:', trimmedName)

    local citizenId = citizenId or getCitizenId()
    if not citizenId then 
        print('^1SETUP ERROR: citizenId missing')
        cb(false)
        return
    end
    if Config.OxForCallbacks then
        local result = lib.callback.await('cw-darkweb:server:attemptCreate', trimmedName, citizenId)
        debugLog('Purchase attempt result:', result)
        if result == 'OK' then
            local playerAccount = lib.callback.await('cw-darkweb:server:getPlayerAccount', citizenId)
            currentAccount = playerAccount
            updateUiData()
        end
        cb(result)
    else
        QBCore.Functions.TriggerCallback('cw-darkweb:server:attemptCreate', function(result)
            if result == 'OK' then
                QBCore.Functions.TriggerCallback('cw-darkweb:server:getPlayerAccount', function(playerAccount)
                    currentAccount = playerAccount
                    updateUiData()
                end, citizenId)
            end
            cb(result)
        end, trimmedName, citizenId)
    end
end exports('createAccount', createAccount)