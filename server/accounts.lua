local useDebug = Config.Debug

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


local accounts = {}

local function updateCachedAccount(citizenId, newData) 
    if not citizenId or not newData then
        debugLog('Youre lacking data for updating cached account', citizenId, json.encode(newData, {indent=true}))
        return
    end
    local cachedAccount = accounts[citizenId]
    if cachedAccount then
        debugLog('Account existed in cache and has been updated')
    else
        debugLog('Account did not exist in cache. Creating entry')
    end
    accounts[citizenId] = newData
end

local function updateClientAccount(src, newData)
    TriggerClientEvent('cw-darkweb:client:updateAccount',src, newData)
end

local function updateAccountInDB(newData)
    local res = MySQL.Sync.execute('UPDATE darkweb_accounts SET name = ?, rating = ?, sales = ?, purchases = ?, moneyHeld = ?, status = ? WHERE citizenId = ?',
        {newData.name, newData.rating, newData.sales, newData.purchases, newData.moneyHeld, newData.status, newData.citizenId})
    
    local QBCore = exports['qb-core']:GetCoreObject()
    local Player = QBCore.Functions.GetPlayerByCitizenId(newData.citizenId)

    if Player and Player.PlayerData and Player.PlayerData.source then
        updateClientAccount(Player.PlayerData.source, newData)
    end
end

local function fetchAccountFromDb(citizenId)
    local result = MySQL.Sync.fetchAll('SELECT * FROM darkweb_accounts WHERE citizenId = ?', {citizenId})
    
    -- There should only ever be one account per character
    if result[1] then
        debugLog('Found account in DB!')
        return result[1]
    else
        debugLog('Account does not exist for', citizenId)
    end
end

local function fetchAccountFromDbByName(name)
    local result = MySQL.Sync.fetchAll('SELECT * FROM darkweb_accounts WHERE LOWER(name) = LOWER(?)', {name})
    
    -- There should only ever be one account per character
    if result[1] then
        debugLog('Found account in DB!')
        return result[1]
    else
        debugLog('Account does not exist for', name)
    end
end


local function getAccountFromDbOrCache(citizenId)
    local cachedAccount = accounts[citizenId]
    if not cachedAccount then
        -- fetch from db
        local result = fetchAccountFromDb(citizenId)
        updateCachedAccount(citizenId, result)
        return result
    else
        debugLog('Account existed as cached', citizenId, json.encode(cachedAccount, {indent=true}))
        return cachedAccount
    end
end

local function banAccount(citizenId)
    debugLog('Banning account', citizenId)
    local cachedAccount = accounts[citizenId]
    if accounts[citizenId] then
        accounts[citizenId].status = 'BANNED'
        updateAccountInDB(accounts[citizenId])
    else
        debugLog('Account did not exist in cache')
        local result = getAccountFromDbOrCache(citizenId)
        if result then
            result.status = 'BANNED'
            updateAccountInDB(result)
            updateCachedAccount(citizenId, result)
        else
            debugLog('Account does not exist in DB for', citizenId)
        end
    end
    notifyPlayerByCitizenId(citizenId, Config.Locale['accountGotBanned'], 'error')
end

function changeRating(citizenId, change)
    local cachedAccount = accounts[citizenId]
    if accounts[citizenId] then
        accounts[citizenId].rating = accounts[citizenId].rating + tonumber(change)
        if accounts[citizenId].rating < Config.BanThreshold then
            banAccount(citizenId)
        end
        updateAccountInDB(accounts[citizenId])
    else
        debugLog('Account did not exist in cache')
        local result = getAccountFromDbOrCache(citizenId)
        if result then
            result.rating = result.rating + tonumber(change)
            updateAccountInDB(result)
            updateCachedAccount(citizenId, result)
            if accounts[citizenId].rating < Config.BanThreshold then
                banAccount(citizenId)
            end
        else
            debugLog('Account does not exist in DB for', citizenId)
        end
    end
end

function addSales(citizenId, change)
    local cachedAccount = accounts[citizenId]
    if accounts[citizenId] then
        accounts[citizenId].sales = accounts[citizenId].sales + tonumber(change)
        updateAccountInDB(accounts[citizenId])
    else
        debugLog('Account did not exist in cache')
        local result = getAccountFromDbOrCache(citizenId)
        if result then
            result.sales = result.sales + tonumber(change)
            updateAccountInDB(result)
            updateCachedAccount(citizenId, result)
        else
            debugLog('Account does not exist in DB for', citizenId)
        end
    end
end

function addPurchases(citizenId, change)
    local cachedAccount = accounts[citizenId]
    if accounts[citizenId] then
        accounts[citizenId].purchases = accounts[citizenId].purchases + tonumber(change)
        updateAccountInDB(accounts[citizenId])
    else
        debugLog('Account did not exist in cache')
        local result = getAccountFromDbOrCache(citizenId)
        if result then
            result.purchases = result.purchases + tonumber(change)
            updateAccountInDB(result)
            updateCachedAccount(citizenId, result)
        else
            debugLog('Account does not exist in DB for', citizenId)
        end
    end
end


function chargePlayer(src, amount)
    debugLog('attempting to charge player', src, tostring(amount)..' '..Config.MoneyType)
    if Config.UseCustomChargeFunction then
        return Config.CustomCharge(src, amount)
    else
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.Functions.RemoveMoney(Config.MoneyType, amount, "Unknown")
    end
    return false
end

local function createAccount(src, citizenId, name)
    local accountByCitizenId = fetchAccountFromDb(citizenId)
    local accountByName = fetchAccountFromDbByName(name)
    if not accountByCitizenId and not accountByName then
        if chargePlayer(src, Config.AccountCreationCost) then
            MySQL.Sync.insert('INSERT INTO darkweb_accounts (citizenId, name) VALUES (?, ?)', {citizenId, name})
            return 'OK'
        else
            debugLog('Player could not pay')
            return 'CAN_NOT_PAY'
        end
    else
        if accountByCitizenId then
            debugLog('CitizenId already has account')
            return 'HAS_ACCOUNT'
        elseif accountByName then
            debugLog('Name is taken')
            return 'NAME_TAKEN'
        end
    end
    return 'ERROR'
end

local function removeAccount(src, citizenId)
    local accountByCitizenId = fetchAccountFromDb(citizenId)
    if accountByCitizenId then
        if chargePlayer(src, Config.AccountRemovalCost) then
            local affectdRows = MySQL.Sync.execute('DELETE FROM darkweb_accounts WHERE citizenid = ?', {citizenId})
            if affectdRows > 0 then
                return 'OK'
            else
                return 'ERROR'
            end
        else
            debugLog('Player could not pay')
            return 'CAN_NOT_PAY'
        end
    else
        if accountByCitizenId then
            debugLog('CitizenId doesnt have an account')
            return 'HAS_NO_ACCOUNT'
        end
    end
    return 'ERROR'
end


if Config.OxForCallbacks then
    lib.callback.register('cw-darkweb:server:getPlayerAccount', function(source, citizenId)
        debugLog('Calling OX callback for fetching account', source, citizenId)
        local result = getAccountFromDbOrCache(citizenId)
        return result
    end)
    lib.callback.register('cw-darkweb:server:attemptCreate', function(source, name, citizenId)
        debugLog('Calling OX callback for creating account', source, citizenId, name)
        local result = createAccount(source, citizenId, name)
        return result
    end)
    lib.callback.register('cw-darkweb:server:removeAccount', function(source, citizenId)
        debugLog('Calling OX callback for removing account', source, citizenId)
        local result = removeAccount(source, citizenId)
        return result
    end)
else
    local QBCore = exports['qb-core']:GetCoreObject()
    QBCore.Functions.CreateCallback('cw-darkweb:server:getPlayerAccount', function(source, cb, citizenId)
        debugLog('Calling QB callback for fetching account', source, citizenId)
        local result = getAccountFromDbOrCache(citizenId)
        cb(result)
    end)
    QBCore.Functions.CreateCallback('cw-darkweb:server:attemptCreate', function(source, cb, name, citizenId)
        debugLog('Calling QB callback for creating account', source, citizenId, name)
        local result = createAccount(source, citizenId, name)
        cb(result)
    end)
    QBCore.Functions.CreateCallback('cw-darkweb:server:removeAccount', function(source, cb, citizenId)
        debugLog('Calling QB callback for creating account', source, citizenId)
        local result = removeAccount(source, citizenId)
        cb(result)
    end)
end
