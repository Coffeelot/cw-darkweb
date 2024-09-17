# CW Darkweb

Full rework of the darkweb tablet we had. Images of UI at bottom of this Readme. \
Supports Ox Inv/lib and QBcore. You can select what features you want from whichever in the config.

The randomized ads list work like this:
1) A random number between what is defined in Config.AmountOfAds is created: X
2) X ads are created by randomly picking from the list in Config.DarkwebAds
3) If an ad has `chance` defined then we also check for this chance to be include, if not we skip this ad.

The player auction work like this:
1) Create an account
2) Mark your waypoint (this will be the meeting spot sent to the buyer)
3) Go to the Market tab and create an ad
4) Wait for buyers to bid
5) Accept the bid
6) Meet up

> If you have feedback and suggestions then post about it in the Discord

**Features:**
- Darkweb tablet
- Customizeable generated ads (see Create an Ad section)
- Player accounts
- Player auctions
- Randomly generated ads at set interavals
- Randomly generated dead drops for pickup
- Dead drop export for use with other scripts

**Planned features:**
- Metadata checks for items
- A short-term chat

### THE CONFIG IS SETUP FOR DEBUG/TESTING SO MAKE SURE TO GO OVER IT BEFORE USE!!!
Also, not tested with QB inventory, but should support it

# Preview 📽
COMING SOON?!

# Links
### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐
### 🥳 Get more [Free scripts](https://github.com/stars/Coffeelot/lists/cw-scripts) 🥳

### **Support, updates and script previews**:

<a href="https://discord.gg/FJY4mtjaKr"> <img src="https://media.discordapp.net/attachments/1202695794537537568/1285652389080334337/discord.png?ex=66eb0c97&is=66e9bb17&hm=b1b2c17715f169f57cf646bb9785b0bf833b2e4037ef47609100ec8e902371df&=&format=webp" width="200"></a>

# Setup
1) Get script
2) Add it to your server (make sure to remove -main in folder name)
3) Set up config to work with your server
4) Add the cw tablet item to your `items.lua` and add the image(s) from the `items` folder to your inventory image folder. Example is for OX inventory:
```lua
    ["cw_darkweb_tablet"] = {
		label = "Darkweb Tablet",
		description = "It has a chili dog sticker on it",
		weight = 10,
		close = true
	},
```
5) Start server and spawn the item `cw_darkweb_tablet`
6) Add some way to get the tablets ingame, maybe as loot I dunno I'm not your mom.
7) Make an account if you want to do player trades


# Create an Ad
The ads are defined in the `Config.DarkwebAds` table in the config. This in an example with the options:
```lua
    {
        title = "Sandwich AD", -- Title of the ad
        description = 'One sandwich', -- Description of the ad
        items = { -- A table of items
            {  -- Item entry,
                itemName = 'sandwich', -- item name (MAKE SURE THIS EXISTS IN YOUR ITEMS.LUA)
                amount = 1, -- amount in batch
                metadata = nil -- optional metadata/info table
            },  
        },
        price = { min = 5, max = 200 }, -- price is defined with a min and a max, on list generation it's randomized between these numbers.
        required = { -- OPTIONAL: table that contains requirements
            item = 'vpn', -- item that's required to see this ad
        },
        chance = 10 -- chance of being included in list, defaults to 100. 100 = 100% chance
        rep = { -- this is optional, and only relevant if you want to gate items behind reputation/skills
            name = 'delivery', -- The name of the rep/skill you want to check (needs to match the name (not label) of what is in cw-rep)
            required = 10, -- XP required, or level if Config.UseLevelInsteadOfXP = true
            label= 'Coffee Drinkers' --overwrites the rep label/name in ui
        },
    },
```

> Note: The `chance` doesn't affect the chance of the ad being selected, only that it's included if selected. The system is explained earlier in the readme.

> Note: if you do not meet requirement for the item it won't show up in the ad list at all. 

# Create a dead drop from another script:
You can use the included server export to create dead drops from other scripts, for example if you want to use these for payouts from jobs.

```lua
exports['cw-darkweb']:createCustomDropoff(<source>, <dropoff data>)
```

The source is the source of the player you want to give this to. The dropoff data is defined in the same way as you define Ads, so for example: 
```lua
    local dropoffData = {
        title = "Sandwich Dropoff", -- Title of the ad
        description = 'Thanks for killing that dude, heres your payment', -- Description of the ad
        items = { -- A table of items
            {  -- Item entry,
                itemName = 'sandwich', -- item name (MAKE SURE THIS EXISTS IN YOUR ITEMS.LUA)
                amount = 1, -- amount in batch
                metadata = nil -- optional metadata/info table
            },  
        },
    },
    exports['cw-darkweb']:createCustomDropoff(source, dropoffData)
```
Will generate a custom dead drop containing a slice of 

# How to use
1) Get yourself a tablet
2) Use the tablet
3) Buy thing(s)
4) Pickup things at the given location
5) Enjoy your things

# Images
![List](https://cdn.discordapp.com/attachments/977876510620909579/1247239740302950481/image.png?ex=665f4e06&is=665dfc86&hm=41b27ada2239ecbf74794934788d488643b7c81c37fc1fba896fe605e6bda61d&)
![List](https://cdn.discordapp.com/attachments/977876510620909579/1247244323368599582/image.png?ex=665f524b&is=665e00cb&hm=223594c1e5d644c2a0f81645f9c3fdf582ef3c91ada4d7f2579529361cad0b9e&)
![List](https://cdn.discordapp.com/attachments/977876510620909579/1247244370374295633/image.png?ex=665f5256&is=665e00d6&hm=70817239e314893c39a2184f677f6855bdcd470cad3b79cb27a43e14d3c65616&)


# Want to change the look?
Darkweb is now built in VUE, this means you can't just edit the files directly. This requires some more know-how than just developing with basic html/js. You can find out more information in this [Boilerplate Repo](https://github.com/alenvalek/fivem-vuejs-boilerplate). **We do not offer support on this.**

The very bacis for building and installing it are:
1. Open a command window in the html folder
2. run `npm i`
3. run `npm run build` (to create a new build of the ui), `npm run watch` to dev with it

> If nothing is happening, try deleting the dist folder before you run the build command

> This does require some know-how and use of [NPM](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)

> If you're catching errors, it might be because your Node version is old/to new. I use Node 18. 


# Requirements: 
QBCore (or QBox Core)
