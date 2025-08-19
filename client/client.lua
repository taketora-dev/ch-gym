local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local Config = {
    TargetingSystem = 'ox_target' 
}
local stressRemovalAmount = GetStressRemovalAmount()
local isLiftWeightsPlaying = false
local leftDumbbellProp = nil
local rightDumbbellProp = nil
local chinUpLocations = {
    vector3(-1205.08, -1563.87, 4.61),
    vector3(-1199.65, -1571.6, 4.61)
}
local chinUpTeleportLocations = {
    vector4(-1204.93, -1564.12, 3, 212.16),
    vector4(-1199.5, -1571.39, 3, 35)
}
local pushupSitupLocations = {
    vector3(-1201.68, -1570.35, 4),
    vector3(-1204.96, -1560.92, 4)
}
local dumbbellLocations = {
    vector3(-1202.68, -1573.37, 4.61), 
    vector3(-1197.97, -1565.4, 4.62), 
    vector3(-1209.69, -1559.07, 4.61)
}
local function createDumbbellProps()
    local model = GetHashKey("v_res_tre_weight")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(1)
    end
    local playerPed = PlayerPedId()
    local leftBoneIndex = GetPedBoneIndex(playerPed, 18905)
    local rightBoneIndex = GetPedBoneIndex(playerPed, 57005)
    if leftDumbbellProp then
        ESX.Game.DeleteObject(leftDumbbellProp)
    end
    if rightDumbbellProp then
        ESX.Game.DeleteObject(rightDumbbellProp)
    end
    leftDumbbellProp = ESX.Game.SpawnObject(model, 0, 0, 0, true, true, true)
    AttachEntityToEntity(leftDumbbellProp, playerPed, leftBoneIndex, 0.1, 0, -0.001, 0, 0, 0, true, true, false, true, 1, true)
    rightDumbbellProp = ESX.Game.SpawnObject(model, 0, 0, 0, true, true, true)
    AttachEntityToEntity(rightDumbbellProp, playerPed, rightBoneIndex, 0.1, 0.0, -0.09, 0, 0, 0, true, true, false, true, 1, true)
end
local function deleteDumbbellProps()
    if leftDumbbellProp and DoesEntityExist(leftDumbbellProp) then
        ESX.Game.DeleteObject(leftDumbbellProp)
        leftDumbbellProp = nil
    end
    if rightDumbbellProp and DoesEntityExist(rightDumbbellProp) then
        ESX.Game.DeleteObject(rightDumbbellProp)
        rightDumbbellProp = nil
    end
end
local function playWorkoutAnimation(coords, animDict, animName, duration, heading)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    ESX.Game.SetEntityHeading(PlayerPedId(), heading or 0) 
    ClearPedTasksImmediately(PlayerPedId())
    RequestAnimDict(animDict)
    local waitTime = 0
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
        waitTime = waitTime + 100
        if waitTime > 5000 then 
            return
        end
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 8.0, duration, 1, 0, false, false, false)
end
local function doChinUps(locationIndex)
    local isChinUpsPlaying = true
    local wasCancelled = false
    local coords = chinUpTeleportLocations[locationIndex]
    local heading = coords.w or 0
    local duration = 15000  
    exports['mythic_progbar']:Progress({
        name = "chin_ups_progress",
        duration = duration,
        label = "Doing Chin-Ups",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {},
        prop = {},
    }, function(cancelled)
        if not cancelled then
            isChinUpsPlaying = false
            TriggerServerEvent('hud:server:RelieveStress', stressRemovalAmount)
        else
            wasCancelled = true
            isChinUpsPlaying = false
        end
    end)
    playWorkoutAnimation(coords, "amb@prop_human_muscle_chin_ups@male@base", "base", duration, heading)
    Citizen.CreateThread(function()
        while isChinUpsPlaying do
            Citizen.Wait(0)
            if IsControlJustPressed(0, 73) then  
                exports['cm-notification']:Notify('Cancelling Chin-Ups...', 'error')
                TriggerEvent('QBCore:Client:OnProgressCancel')
                TriggerEvent('progressbar:client:cancel')
                break
            end
        end
    end)
end
local function doPushUps()
    local isPushUpsPlaying = true
    local animDict = "amb@world_human_push_ups@male@base"
    local animName = "base"
    local duration = 15000
    exports['mythic_progbar']:Progress({
        name = "push_ups_progress",
        duration = duration,
        label = "Doing Push-Ups",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {},
        prop = {},
    }, function(cancelled)
        isPushUpsPlaying = false
        if cancelled then
            -- cancelled
        end
    end)
    playWorkoutAnimation(pushupSitupLocations[1], animDict, animName, duration)
    Citizen.CreateThread(function()
        while isPushUpsPlaying do
            Citizen.Wait(0)
            if IsControlJustPressed(0, 73) then
                exports['cm-notification']:Notify('Cancelling Push-Ups...', 'error')
                break
            end
        end
    end)
end
local function doSitUps()
    local isSitUpsPlaying = true
    local animDict = "amb@world_human_sit_ups@male@base"
    local animName = "base"
    local duration = 15000
    exports['mythic_progbar']:Progress({
        name = "sit_ups_progress",
        duration = duration,
        label = "Doing Sit-Ups",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {},
        prop = {},
    }, function(cancelled)
        isSitUpsPlaying = false
        if cancelled then
            -- cancelled
        end
    end)
    playWorkoutAnimation(pushupSitupLocations[2], animDict, animName, duration)
    Citizen.CreateThread(function()
        while isSitUpsPlaying do
            Citizen.Wait(0)
            if IsControlJustPressed(0, 73) then
                exports['cm-notification']:Notify('Cancelling Sit-Ups...', 'error')
                break
            end
        end
    end)
end
local function doLiftWeights()
    isLiftWeightsPlaying = true
    local animDict = "amb@world_human_muscle_free_weights@male@barbell@base"
    local animName = "base"
    local duration = 15000
    createDumbbellProps()
    exports['mythic_progbar']:Progress({
        name = "lifting_weights_progress",
        duration = duration,
        label = "Lifting Weights",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {},
        prop = {},
    }, function(cancelled)
        deleteDumbbellProps()
        isLiftWeightsPlaying = false
        if cancelled then
            -- cancelled
        end
    end)
    playWorkoutAnimation(dumbbellLocations[1], animDict, animName, duration)
    Citizen.CreateThread(function()
        while isLiftWeightsPlaying do
            Citizen.Wait(0)
            if IsControlJustPressed(0, 73) then
                exports['cm-notification']:Notify('Cancelling Workout...', 'error')
                break
            end
        end
    end)
end
local function setupTargeting()
    if Config.TargetingSystem == 'ox_target' then
        for i, location in ipairs(chinUpLocations) do
            exports.ox_target:addBoxZone({
                coords = location,
                size = vec3(2, 2, 2),
                rotation = 0,
                debug = false,
                options = {
                    {
                        name = "chinup_" .. i,
                        event = "ch-gym:doChinUps",
                        icon = "fas fa-dumbbell",
                        label = "Do Chin Ups",
                        locationIndex = i,
                    }
                },
                distance = 2.5
            })
        end
        for i, location in ipairs(pushupSitupLocations) do
            exports.ox_target:addBoxZone({
                coords = location,
                size = vec3(3, 3, 2),
                rotation = 0,
                debug = false,
                options = {
                    {
                        name = "situp_" .. i,
                        event = "ch-gym:doSitUps",
                        icon = "fas fa-dumbbell",
                        label = "Do Sit Ups",
                    },
                    {
                        name = "pushup_" .. i,
                        event = "ch-gym:doPushUps",
                        icon = "fas fa-dumbbell",
                        label = "Do Push Ups",
                    }
                },
                distance = 2.5
            })
        end
        for i, location in ipairs(dumbbellLocations) do
            exports.ox_target:addBoxZone({
                coords = location,
                size = vec3(2, 2, 2),
                rotation = 0,
                debug = false,
                options = {
                    {
                        name = "dumbbell_" .. i,
                        event = "ch-gym:doLiftWeights",
                        icon = "fas fa-dumbbell",
                        label = "Lift Weights",
                    }
                },
                distance = 2.5
            })
        end
    end
end
setupTargeting()
RegisterNetEvent('ch-gym:doChinUps', function(data)
    doChinUps(data.locationIndex)
end)
RegisterNetEvent('ch-gym:doSitUps', function()
    doSitUps()
end)
RegisterNetEvent('ch-gym:doPushUps', function()
    doPushUps()
end)
RegisterNetEvent('ch-gym:doLiftWeights', function()
    doLiftWeights()
end)
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        deleteDumbbellProps()
    end
end)
