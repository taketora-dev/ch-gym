local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
RegisterServerEvent('hud:server:RelieveStress')
AddEventHandler('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if not amount or type(amount) ~= "number" then
        return 
    end
    if Player then
        local currentStress = Player.PlayerData.metadata["stress"] or 0 
        local newStress = currentStress - amount
        if newStress < 0 then
            newStress = 0
        Player.Functions.SetMetaData("stress", newStress)
end)
