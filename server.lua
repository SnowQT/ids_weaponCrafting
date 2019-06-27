ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("weaponCrafting:getReward")
AddEventHandler("weaponCrafting:getReward",function(chance)
    local xPlayer = ESX.GetPlayerFromId(source)
    if chance <= 10000 then
        xPlayer.addWeapon("WEAPON_ASSAULTRIFLE",60)
    elseif chance <= 100000 then
        xPlayer.addWeapon("WEAPON_PISTOL",60)
    end
    xPlayer.removeInventoryItem("weaponcraftcompo",Config.Quantity)
end)

RegisterServerEvent("weaponCrafting:giveCompo")
AddEventHandler("weaponCrafting:giveCompo",function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem("weaponcraftcompo",1)
end)

ESX.RegisterServerCallback('weaponCrafting:getItem', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local compo = xPlayer.getInventoryItem("weaponcraftcompo")
    cb(compo.count)
end)
