local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

local availableAds = {}
local activeDropOffs = {}
-- Functions

-- Function to copy a table deeply
local function deepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[deepCopy(key)] = deepCopy(value)
        end
        setmetatable(copy, deepCopy(getmetatable(original)))
    else
        -- Base case: non-table values
        copy = original
    end
    return copy
end

local function getAdByAdId(adId)
    for i, adData in pairs(availableAds) do
        if adData.id == adId then
            return adData
        end
    end
    return nil
end

local function getIndexOfAdByAdId(adId)
    for i, adData in ipairs(availableAds) do
        if adData.id == adId then
            return i
        end
    end
    return nil
end

local function updateGlobalList()
    if useDebug then
       print('Updating global list for all players')
       print('ads', json.encode(availableAds, {indent=true}))
       print('dropoffs', json.encode(activeDropOffs, {indent=true}))
    end
    TriggerClientEvent("cw-darkweb:client:updateGlobalList", -1, availableAds, activeDropOffs)
end

local function removeFromAvailableAds(adId)
    local index = getIndexOfAdByAdId(adId)
    if index then
        table.remove(availableAds, index)
        updateGlobalList()
    else
        if useDebug then print('^1Could not find ad with id', adId) end
    end
end

local function removeFromActiveDropOffs(adId)
    local dropoff = activeDropOffs[adId]
    if dropoff then
        activeDropOffs[adId] = nil
        updateGlobalList()
    else
        if useDebug then print('^1Could not find dropoff in list', adId) end
    end
end

local function getUnusedLocation()
    local dropoffLocations = deepCopy(Config.DropoffLocations)
    for i, dropOffLocation in pairs(activeDropOffs) do
        for j, location in pairs(dropoffLocations) do
            if location.coords == dropoffLocations.coords then
                dropOffLocation[j] = nil
            end
        end
    end
    if #dropoffLocations == 0 then
        print('^1No locations left, you should probably have a lot of these in your config to offset the posibility that all are used...')
        return nil
    end
    return dropoffLocations[math.random(1,#dropoffLocations)]
end

local function notifyBuyer(src, coords, adId)
    TriggerClientEvent('cw-darkweb:client:notifyBuyer', src, coords, adId)
end

local function notifyPickup(ad)
    TriggerClientEvent('cw-darkweb:client:notifyPickup', ad.buyerSource, ad)
end

local function createDropoff(src, ad, location)
    if activeDropOffs[ad.id] then print('^1POSSIBLY ATTEMT TO CHEAT? from src', src) return end
    local dropOff = ad
    dropOff.buyerSource = src
    dropOff.coords = location.coords
    dropOff.locationDescription = location.description or "No description available"
    activeDropOffs[ad.id] = dropOff
    updateGlobalList()
    notifyBuyer(src, location.coords, ad.id)
end

local function giveItems(src, adData)
    if Config.Inventory == 'ox' then
        for i, itemData in pairs(adData.items) do
            exports.ox_inventory:AddItem(src, itemData.itemName, itemData.amount or 1, itemData.metadata or nil)
        end
    elseif Config.Inventory == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        for i, itemData in pairs(adData.items) do
            Player.Functions.AddItem(itemData.itemName, itemData.amount or 1, nil, itemData.metadata or nil)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemData.itemName], "add")
        end
    else
        print('^1YOU ARE USING AN INVENTORY THAT IS NOT SUPPORTED:', Config.Inventory)
    end
end

RegisterServerEvent('cw-darkweb:server:getLatestList', function()
    local src = source
    TriggerClientEvent('cw-darkweb:client:updateGlobalList', src, availableAds, activeDropOffs)
end)

local function chargePlayer(src, ad)
    if useDebug then print('attempting to charge player', src, ' with ', ad.price, ' of type', Config.MoneyType) end
    if Config.UseCustomChargeFunction then
        return Config.CustomCharge(src, ad.price)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.Functions.RemoveMoney(Config.MoneyType, ad.price, "Unknown")
    end
end

local function attemptPurchase(src, adId)
    local ad = getAdByAdId(adId)
    if not ad then
        if useDebug then print('^1 Player', src, 'is trying to buy an ad that does not exist: ', adId) end
        return false
    end 

    -- generate a location
    local location = getUnusedLocation()
    if not location then return false end

    if chargePlayer(src, ad) then
        createDropoff(src, ad, location)
        removeFromAvailableAds(adId)
        return true
    else
        if useDebug then print('^5Player did not have enough money to buy items') end
        -- cant buy
    end
end

local function createCustomDropoff(src, dropOffData)
    local location = getUnusedLocation()
    if not location then return false end
    createDropoff(src, dropOffData, location)
    return location
end exports('createCustomDropoff', createCustomDropoff)

if Config.OxForCallbacks then
    lib.callback.register('cw-darkweb:server:attemptPurchase', function(source, adId)
        if useDebug then print('Calling OX callback for purchase', source, adId) end
        local result = attemptPurchase(source, adId)
        if useDebug then print('Purchase attempt result', result) end
        return result
    end)
else
    QBCore.Functions.CreateCallback('cw-darkweb:server:attemptPurchase', function(source, cb, adId)
        if useDebug then print('Calling QB callback for purchase', source, adId) end
        local result = attemptPurchase(source, adId)
        if useDebug then print('Purchase attempt result', result) end
        cb(result)
    end)
end

RegisterServerEvent('cw-darkweb:server:doPickup', function(adId)
    local src = source
    local dropoffData = activeDropOffs[adId]
    if dropoffData then
        giveItems(src, dropoffData)
        removeFromActiveDropOffs(adId)
        notifyPickup(dropoffData)
    else
        -- cant get items
    end
end)

local function generateAdId()
    return 'DW-'..tostring(math.random(1,9999))
end

local function getLabelForItem(itemName)
    if Config.Inventory == 'ox' then
        if exports.ox_inventory.Items()[itemName] then
            return exports.ox_inventory.Items()[itemName].label
        else
            return nil
        end
    elseif Config.Inventory == 'qb' then
        if QBCore.Shared.Items[itemName] then
            return QBCore.Shared.Items[itemName].label
        else
            return nil
        end
    else
        print('^1YOU ARE USING AN INVENTORY THAT IS NOT DEFINED, SUPPORTED ARE: ox AND qb, YOU ARE USING:', Config.Inventory)
    end
end

local function generateAdList()
    -- Reset job list
    availableAds = {}

    -- Randomize how many jobs
    local amountOfAds = math.random(Config.AmountOfAds.min, Config.AmountOfAds.max)
    if useDebug then print('Amount of ads:', amountOfAds) end
    local possibleAds = deepCopy(Config.DarkwebAds)
    for i = 1, amountOfAds, 1 do
        if #possibleAds > 0 then
            local adIndex = math.random(1, #possibleAds)
            local ad = possibleAds[adIndex]
            if ad then
                if useDebug then print('(Potentially) Adding', ad.title) end

                local chance = 100
                if ad.chance then chance = ad.chance end
                local rollToGet = math.random(0,100)

                if chance > rollToGet then
                    ad.price = math.floor(math.random(ad.price.min, ad.price.max))
                    ad.expires = os.time() + Config.MinutesBetweenAdRefresh*60
                    ad.id = generateAdId()
        
                    if ad.items then
                        for i, item in pairs(ad.items) do
                            local label = getLabelForItem(item.itemName) or 'YOU GOT ITEMS THAT ARE NOT DEFINED! CHECK SERVER LOGS'
                            if label == 'YOU GOT ITEMS THAT ARE NOT DEFINED! CHECK SERVER LOGS' then
                                print('^1==============================================')
                                print('^1THIS ITEM DOES NOT EXIST IN YOUR ITEMS.LUA FILE:', item.itemName)
                                print('^1==============================================')
                            end
                            ad.items[i].label = label
                        end
                    end
        
                    availableAds[#availableAds+1] = ad
                    possibleAds[adIndex] = nil
                else
                    possibleAds[adIndex] = nil
                    if useDebug then print('Roll did not meet requirements. Roll:', rollToGet, 'Chance:', chance ) end
                end
            end
        end    
    end
    if useDebug then
       print('^2Finished generating ad list')
    end
    updateGlobalList()
end

CreateThread(function()
    while true do
        Wait(1000)
        generateAdList()
        Wait(Config.MinutesBetweenAdRefresh * 60 * 1000)
    end
end)

local function openApp(src)
    TriggerClientEvent('cw-darkweb:client:openApp', src)
end

QBCore.Functions.CreateUseableItem('cw_darkweb_tablet', function(source, item)
    openApp(source)
end)