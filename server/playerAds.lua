local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

function GetCurrentTimeMillis()
    local seconds = os.time()
    local milliseconds = math.floor(os.clock() * 1000) % 1000
    return seconds * 1000 + milliseconds
end

local availablePlayerAds = {}

local function notify(src, text, type)
    if Config.OxLibNotify then
        TriggerClientEvent('ox_lib:notify', src, {title= text, type=type})
    else 
        TriggerClientEvent('QBCore:Notify', src, text, type)
    end
end

function notifyPlayerByCitizenId(citizenId, message, type)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenId)
    if not Player then print('Could not find player', citizenId) return end
    
    local src = Player.PlayerData.source
    notify(src, message, type)
end


local function getAdById(adId)
    for i, ad in ipairs(availablePlayerAds) do
        if ad.id == adId then return ad, i end
    end
    return nil
end

local function addBid(adId, amount, bidderAccount)
    local ad, index = getAdById(adId)
    if not ad or not index then return 'NO_EXIST' end

    local bid = bidderAccount
    
    notifyPlayerByCitizenId(ad.seller.citizenId, Config.Locale['newBidSeller'])
    for i, bidder in pairs(ad.bids) do
        notifyPlayerByCitizenId(bidder.citizenId, Config.Locale['newBidBuyer'])
    end

    bid.amount = amount
    ad.bids[#ad.bids+1] = bid
    availablePlayerAds[index] = ad
    TriggerClientEvent('cw-darkweb:client:updatePlayerAds', -1, availablePlayerAds)
end

local function getHighestBidder(ad)
    local highestBidder = nil
    
    if not ad.bids[1] then return end
    highestBidder = ad.bids[1]

    for index, bid in pairs(ad.bids) do
        if bid.amount > highestBidder.amount then
            highestBidder = bid
        end
    end

    return highestBidder
end

local function acceptBid(adId)
    local ad, index = getAdById(adId)
    if not ad or not index then print('Trying to accept for ad that does not exist') return end

    availablePlayerAds[index].buyer = getHighestBidder(ad)
    if not availablePlayerAds[index].buyer then
        availablePlayerAds[index].status = 'DONE'
        TriggerClientEvent('cw-darkweb:client:updatePlayerAds', -1, availablePlayerAds)
    end
    availablePlayerAds[index].status = 'ACCEPTED'
    notifyPlayerByCitizenId(availablePlayerAds[index].buyer.citizenId, Config.Locale['bidAccepted'], 'success')
    TriggerClientEvent('cw-darkweb:client:updatePlayerAds', -1, availablePlayerAds)
end

local function confirmDelivery(adId)
    local ad, index = getAdById(adId)
    if not ad or not index then print('Trying to find ad that does not exist') return end

    availablePlayerAds[index].status = 'AWAITING_RATING'
    addSales(ad.seller.citizenId, 1)
    addPurchases(ad.buyer.citizenId, 1)
    changeRating(ad.buyer.citizenId, 1)
    TriggerClientEvent('cw-darkweb:client:updatePlayerAds', -1, availablePlayerAds)
end

local function markNoShow(adId)
    local ad, index = getAdById(adId)
    if not ad or not index then print('Trying to find ad that does not exist') return end
    notifyPlayerByCitizenId(ad.buyer.citizenId, Config.Locale['ratedBad'], 'error')
    availablePlayerAds[index].status = 'DONE'
    changeRating(ad.buyer.citizenId, -1)
    TriggerClientEvent('cw-darkweb:client:updatePlayerAds', -1, availablePlayerAds)
end

local function rateSeller(adId, change)
    local ad, index = getAdById(adId)
    if not ad or not index then print('Trying to find ad that does not exist') return end

    availablePlayerAds[index].status = 'DONE'
    if tonumber(change) > 0 then
        notifyPlayerByCitizenId(ad.seller.citizenId, Config.Locale['ratedGood'], 'success')
    else
        notifyPlayerByCitizenId(ad.seller.citizenId, Config.Locale['ratedBad'], 'error')
    end
    changeRating(ad.seller.citizenId, change)
    TriggerClientEvent('cw-darkweb:client:updatePlayerAds', -1, availablePlayerAds)
end

RegisterServerEvent('cw-darkweb:server:getLatestList', function()
    local src = source
    if useDebug then print('Fetching player ads') end
    TriggerClientEvent('cw-darkweb:client:updatePlayerAds', src, availablePlayerAds)
end)

RegisterServerEvent('cw-darkweb:server:acceptBid', function(adId)
    local src = source
    if useDebug then print('Accepting bid for', adId) end
    acceptBid(adId)
end)

RegisterServerEvent('cw-darkweb:server:confirmDelivery', function(adId)
    local src = source
    if useDebug then print('Confirmig Delivery', adId) end
    confirmDelivery(adId)
end)

RegisterServerEvent('cw-darkweb:server:markNoShow', function(adId)
    local src = source
    if useDebug then print('Marking no show', adId) end
    markNoShow(adId)
end)

RegisterServerEvent('cw-darkweb:server:rateSeller', function(adId, change)
    local src = source
    if useDebug then print('rating seller', adId, change) end
    rateSeller(adId, change)
end)

local function checkPlayerAds()
    if #availablePlayerAds > 0 then
        local removed = false
        for i, ad in ipairs(availablePlayerAds) do
            if ad and ad.status == 'AVAILABLE' and ad.endtime < GetCurrentTimeMillis() then
                if #availablePlayerAds[i].bids > 0 then
                    availablePlayerAds[i].status = 'WAITING'
                else
                    availablePlayerAds[i].status = 'DONE'
                    notifyPlayerByCitizenId(availablePlayerAds[i].seller.citizenId, Config.Locale['noBuyers'], 'error')
                end
                removed = true
            end
        end
        if removed then
            TriggerClientEvent('cw-darkweb:client:updatePlayerAds', -1, availablePlayerAds)
        end
    end
end

local function generateId()
    local prefix = "CWDW"
    local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local idLength = 8 -- Adjust this for a different length after the prefix
    local randomId = prefix

    math.randomseed(os.time()) -- Seed the random number generator

    for i = 1, idLength do
        local randomIndex = math.random(1, #characters)
        randomId = randomId .. characters:sub(randomIndex, randomIndex)
    end

    return randomId
end

local function createAd(src, data)
    if not chargePlayer(src, Config.AdCreationCost) then return 'CAN_NOT_PAY' end
    data.id = generateId()
    data.buyer = {}
    data.bids = {}
    data.status = 'AVAILABLE'
    data.endtime = GetCurrentTimeMillis() + tonumber(data.minutesUntilEnd)*60*1000

    availablePlayerAds[#availablePlayerAds+1] = data
    TriggerClientEvent('cw-darkweb:client:updatePlayerAds', -1, availablePlayerAds)
    return 'OK'
end

if Config.OxForCallbacks then
    lib.callback.register('cw-darkweb:server:getPlayerAds', function(source)
        if useDebug then print('Calling OX callback to fetch player ads') end
        return availablePlayerAds
    end)
    lib.callback.register('cw-darkweb:server:attemptPlayerBid', function(source, adId, amount, bidderAccount)
        if useDebug then print('Calling OX callback to bid on', adId, amount) end
        if useDebug then print('Player account', json.encode(bidderAccount, {indent=true})) end
        return addBid(adId, amount, bidderAccount)
    end)
    lib.callback.register('cw-darkweb:server:attemptCreateAd', function(source, data)
        if useDebug then print('Calling OX callback to create ad') end
        return createAd(soruce, data)
    end)
else
    QBCore.Functions.CreateCallback('cw-darkweb:server:getPlayerAds', function(source, cb)
        if useDebug then print('Calling QB callback to fetch player ads') end
        cb(availablePlayerAds)
    end)
    QBCore.Functions.CreateCallback('cw-darkweb:server:attemptPlayerBid', function(source, cb, adId, amount, bidderAccount)
        if useDebug then print('Calling OX callback to bid on', adId, amount) end
        if useDebug then print('Player account', json.encode(bidderAccount, {indent=true})) end
        cb(addBid(adId, amount, bidderAccount))
    end)
    QBCore.Functions.CreateCallback('cw-darkweb:server:attemptCreateAd', function(source, cb, data)
        if useDebug then print('Calling OX callback to create ad') end
        cb(createAd(source, data))
    end)
end

CreateThread(function()
    while true do
        Wait(1000)
        checkPlayerAds()
    end
end)