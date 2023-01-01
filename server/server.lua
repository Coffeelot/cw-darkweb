local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

local function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end


QBCore.Functions.CreateUseableItem(Config.LaptopItem, function(source, Item)
    TriggerClientEvent("cw-darkweb:client:openInteraction", source)
end)

QBCore.Commands.Add('cwdebugdarkweb', 'toggle debug for darkweb', {}, true, function(source, args)
    useDebug = not useDebug
    print('debug is now:', useDebug)
    TriggerClientEvent('cw-darkweb:client:toggleDebug',source, useDebug)
end, 'admin')