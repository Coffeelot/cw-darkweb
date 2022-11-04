Config = {}

Config.Debug = false
Config.UseBuyTokens = false

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
}