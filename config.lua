Config = {}
Config.Debug = true
Config.AmountOfAds = { min = 5, max = 10 } -- Min and max of how many ads will be generated every x minute
Config.MinutesBetweenAdRefresh = 10 -- How many minutes until the list of ads refresh
Config.Inventory = 'ox' -- Supported: ox and qb
Config.QbTarget = false
Config.OxForCallbacks = false
Config.OxLibNotify = true
Config.UseOxLibForProgressbar = true
Config.ProgressbarTimeMS = 2000

Config.UseCwRep = true -- Use CW-rep
Config.UseLevelInsteadOfXP = true -- Use Levels instead of XP for CW Rep

Config.Blip = {
    label = Config.BlipLabel,
    sprite = 468, -- https://docs.fivem.net/docs/game-references/blips/
    color = 24 -- https://docs.fivem.net/docs/game-references/blips/
}

Config.MoneyType = 'cash' -- crypto, bank, cash
Config.CurrencyString = '$' -- text that shows up in the app for currency

Config.UseCustomChargeFunction = true -- if true then when charging a player crypto it will use the current function, modify for your own needs:
Config.CustomCharge = function (src, price) 
    if Config.Debug then print('^2calling custom cryto function') end
    if exports['qb-phone']:hasEnough(src, 'cdc', math.floor(price)) then
        exports['qb-phone']:RemoveCrypto(src, 'cdc', math.floor(price)) -- this example is for Renewed Phone, using crypto with id 'cdc'
        return true -- If you modify this function make sure it returns true when successful and false when not
    else
        return false
    end
end

Config.DarkwebAds = {
    { -- basic example
        title = "Beer bottle",
        description = 'This a beer bottle',
        items = {
            { itemName = 'beer', amount = 1, metadata = nil },
        },
        price = { min = 1, max = 5 },
        chance = 10 -- chance of being included in list, defaults to 100. 100 = 100% chance
    },
    { -- example with several of one type of item
        title = "Package of Coffee",
        description = 'This is a box with several coffees in it',
        items = {
            { itemName = 'coffee', amount = 20, metadata = nil },
        },
        price = { min = 5, max = 20 },
        rep = {
            name = 'delivery', -- The name of the rep/skill you want to check (needs to match the name (not label) of what is in cw-rep)
            required = 10, -- XP required, or level if Config.UseLevelInsteadOfXP = true
            label= 'Coffee Drinkers' --overwrites the rep label/name in ui
        },
    },
    { -- example with different items in it
        title = "Package of Candy",
        description = 'This is a box with different candy in it',
        items = {
            { itemName = 'twerks_candy', amount = 5, metadata = nil },
            { itemName = 'snikkel_candy', amount = 5, metadata = nil },
        },
        price = { min = 5, max = 10 }
    },
    { -- example with item requirement 
        title = "AP pistol",
        description = 'AP pistol, you know to shoot people with',
        items = {
            { itemName = 'weapon_appistol', amount = 1, metadata = nil },
        },
        price = { min = 7000, max = 11000 },
        required = {
            item = 'vpn',
        }
    },
}

Config.DropoffTargetTitle = "Investigate"
Config.DropoffTargetIcon = "fas fa-search"

Config.DropoffLocations = {
    { coords = vector3(1317.69, -1658.05, 50.24), description = "Behind the dumpster" },
    { coords = vector3(1162.89, -1411.4, 33.95), description = "Behind the dumpster" },
    { coords = vector3(996.39, -1483.75, 31.63), description = "In the AC unit", animateHigh = true },
    { coords = vector3(958.21, -1492.51, 30.83), description = "Inside the concrete pipe" },
    { coords = vector3(1001.61, -1536.55, 29.84), description = "By the boxes" },
    { coords = vector3(920.25, -1891.38, 30.68), description = "By the boxes" },
    { coords = vector3(889.37, -2174.67, 30.08), description = "By the boxes" },
    { coords = vector3(834.02, -2305.2, 30.74), description = "Inside the dumpster" },
    { coords = vector3(264.7, -3234.85, 5.16), description = "Inside the toilet in the portapotty. Bring gloves." },
    { coords = vector3(-130.56, -2234.37, 6.81), description = "Behind the blue pallets" },
    { coords = vector3(-1167.0, -2052.96, 13.78), description = "Inside the cardboard boxes next to the wreck" },
    { coords = vector3(-1108.93, -1642.15, 4.11), description = "Inside the building. You can enter a door in the alleyway" },
    { coords = vector3(-1473.63, -924.59, 9.9), description = "In a blue plastic pallet" },
    { coords = vector3(-1762.62, -261.85, 47.31), description = "There's a grave that has not been filled yet. Package is in there." },
    { coords = vector3(-3185.46, 1253.52, 5.6), description = "Wedged between some rocks under the bridge" },
    { coords = vector3(-2080.46, 2612.77, 2.09), description = "Behind the barrel" },
    { coords = vector3(497.64, 2967.41, 41.39), description = "Inside the portapotty" },
    { coords = vector3(1580.9, 3581.93, 33.84), description = "In the trash pile that used to be a pool" },
    { coords = vector3(2937.63, 4619.75, 48.17), description = "In the green box inside the train workshop building" },
    { coords = vector3(1677.78, 6434.01, 30.77), description = "Tucked underneath the abandoned caravan" },
    { coords = vector3(-215.5, 6269.41, 30.71), description = "In the trunk of the Peyote wreck" },
    { coords = vector3(-444.58, 1597.66, 357.14), description = "In the rear, under the deck of the building" },
    { coords = vector3(-155.44, -24.2, 59.02), description = "In the top left post box" },
}