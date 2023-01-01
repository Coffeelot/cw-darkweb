# Dark Web 💻🦹‍♂️
This script is used to add a dark web tablet. 
Right now this is mostly intended to replace the token trader from [cw-tokens](https://github.com/Coffeelot/cw-tokens). More features coming.

Currently only hosts a per-client randomized list of purchaseable tokens. Can handle buy tokens. You can change the refresh times and other fun stuff in the config.


Version 1.0:
Token purchases

Planned:
Anonymous chat rooms (think IRC)
Anonymous Player 2 Player sales 

# Developed by Coffeelot and Wuggie
[More scripts by us](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈

**Support, updates and script previews**:

[![Join The discord!](https://cdn.discordapp.com/attachments/977876510620909579/1013102122985857064/discordJoin.png)](https://discord.gg/FJY4mtjaKr )

**All our scripts are and will remain free**. If you want to support what we do, you can buy us a coffee here:

[![Buy Us a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/cwscriptbois )
# Showcase 📽
[![YOUTUBE VIDEO](http://img.youtube.com/vi/prR0wx2UbSw/0.jpg)](https://youtu.be/prR0wx2UbSw)

# Add to qb-core ❗
Items to add to qb-core>shared>items.lua 
```
	-- CW darkweb
	["sketchy_tablet"] =          {["name"] = "sketchy_tablet",         ["label"] = "An totally normal tablet",                  ["weight"] = 1, ["type"] = "item", ["image"] = "sketchy_tablet.png", ["unique"] = false, ["useable"] = true, ['shouldClose'] = false, ["combinable"] = nil, ["description"] = "This tablet certainly isn't used for anything illegal"},

```
 
Also make sure the images are in qb-inventory>html>images
