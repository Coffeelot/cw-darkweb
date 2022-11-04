# Dark Web 💻🦹‍♂️
This script is used to add a dark web tablet. 
Right now this is mostly intended to replace the token trader from [cw-tokens](https://github.com/Coffeelot/cw-tokens). More features coming.

Currently only hosts a per-client randomized list of purchaseable tokens. Can handle buy tokens. You can change the refresh times and other fun stuff in the config.


Version 1.0:
Token purchases

Planned:
Anonymous chat rooms (think IRC)
Anonymous Player 2 Player sales 


# Add to qb-core ❗
Items to add to qb-core>shared>items.lua 
```
	-- CW darkweb
	["sketchy_tablet"] =          {["name"] = "sketchy_tablet",         ["label"] = "An totally normal laptop",                  ["weight"] = 1, ["type"] = "item", ["image"] = "sketchy_tablet.png", ["unique"] = false, ["useable"] = true, ['shouldClose'] = false, ["combinable"] = nil, ["description"] = "This tablet certainly isn't used for anything illegal"},

```
 
Also make sure the images are in qb-inventory>html>images
## Developed by Coffeelot#1586 and Wuggie#1683