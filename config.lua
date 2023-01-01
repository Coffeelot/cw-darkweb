Config = {}

Config.Debug = false
Config.UseBuyTokens = false
Config.Inventory = 'ox' -- qb or ox
Config.Phone = 're' -- qb for qb, re for renewed phone
Config.CryptoType = 'moc' -- only relevant for renewed phone!
Config.LaptopItem = 'sketchy_tablet'

Config.Settings = {
    TokensAmount = { min = 3, max = 4}, -- amount of Token ads that will show up
    Cooldown = { min = 20000, max = 50000 }, -- time until ads will renew (in milliseconds)
    VPNConnectionTime = 2000, -- time to open the tablet
    GenericTexts = {
        Tokens = 'Empty token needed to buy',
        BuyTokens = 'You need to have the relevant buy token for this purchase'
    }
}

Config.TokenAds = {
    {
        name = 'raidmeth',
        type = 'token',
        title = 'Meth raid token',
        price = {min = 1, max = 3},
        footer = 'No refunds.'
    },
    {
        name = 'boostsultanrs',
        type = 'token',
        title = 'Sultan RS boost token',
        price = {min = 2, max = 3},
        footer = 'No refunds.'
    },
    {
        name = 'tradeUzi',
        type = 'token',
        title = 'UZI token',
        price = {min = 0.7, max = 2},
        footer = 'No refunds.'
    },
    {
        name = 'raidcocaine',
        type = 'token',
        title = 'Cocaine Raid token',
        price = {min = 3, max = 7},
        footer = 'No refunds.'
    },
    {
        name = 'raidweed',
        type = 'token',
        title = 'Weed Raid token',
        price = {min = 1, max = 3},
        footer = 'No refunds.'
    },
    {
        name = 'boostvoodoo',
        type = 'token',
        title = 'Voodoo Boost token',
        price = {min = 0.1, max = 0.5},
        footer = 'No refunds.'
    },
    {
        name = 'raidart',
        type = 'token',
        title = 'Art raid token',
        price = {min = 7, max = 8},
        footer = 'No refunds.'
    },
    {
        name = 'tradePistol',
        type = 'token',
        title = 'Pistol token',
        price = {min = 0.2, max = 0.9},
        footer = 'No refunds.'
    },
    {
        name = 'tradeSawedOff',
        type = 'token',
        title = 'Sawed Off token',
        price = {min = 0.3, max = 1.2},
        footer = 'No refunds.'
    },
    {
        name = 'tradeMolotov',
        type = 'token',
        title = 'Molotov token',
        price = {min = 0.5, max = 1.2},
        footer = 'No refunds.'
    },
    {
        name = 'tradeDoubleBarrel',
        type = 'token',
        title = 'Art raid token',
        price = {min = 0.8, max = 1.1},
        footer = 'No refunds.'
    },
    {
        name = 'tradeWeedNutrition',
        type = 'token',
        title = 'Weed nutrition token',
        price = {min = 0.1, max = 0.4},
        footer = 'No refunds.'
    },
    {
        name = 'tradeWeedWhiteWidow',
        type = 'token',
        title = 'White Widow seeds token',
        price = {min = 0.9, max = 1.4},
        footer = 'No refunds.'
    },
    {
        name = 'tradeWeedSkunk',
        type = 'token',
        title = 'Skunk seeds token',
        price = {min = 0.9, max = 1.5},
        footer = 'No refunds.'
    },
    {
        name = 'tradeWeedPurpleHaze',
        type = 'token',
        title = 'Purple Haze seeds token',
        price = {min = 0.8, max = 1.7},
        footer = 'No refunds.'
    },
    {
        name = 'tradeWeedOG',
        type = 'token',
        title = 'OG kush seeds token',
        price = {min = 0.5, max = 1.9},
        footer = 'No refunds.'
    },
    {
        name = 'tradeWeedAmnesia',
        type = 'token',
        title = 'Amnesia seeds token',
        price = {min = 0.7, max = 1.4},
        footer = 'No refunds.'
    },
    {
        name = 'tradeMeth',
        type = 'token',
        title = 'meth baggies token',
        price = {min = 0.4, max = 1.0},
        footer = 'No refunds.'
    },
    {
        name = 'tradeCrack',
        type = 'token',
        title = 'crack baggies token',
        price = {min = 0.4, max = 1.0},
        footer = 'No refunds.'
    },
}