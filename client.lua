local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

Config = require('config')

VorpCore.RegisterServerCallback('gmack_witness_master:witnessReport', function(source, cb, coords)
    TriggerEvent('gmack_witness_master:alertPolice', coords)
    cb()
end)

local isPromptActive = false

RegisterNetEvent('gmack_witness_master:notifyPolice')
AddEventHandler('gmack_witness_master:notifyPolice', function(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, true)
end)

-- Show UI prompt for police to respond to a shooting
function ShowShootingAlertPrompt(coords)
    local scaleform = RequestScaleformMovie("instructional_buttons")

    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(2, 191, true)) -- Accept button
    PushScaleformMovieFunctionParameterString("Accept Shooting Alert")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(2, 194, true)) -- Decline button
    PushScaleformMovieFunctionParameterString("Decline Shooting Alert")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    isPromptActive = true

    Citizen.CreateThread(function()
        while isPromptActive do
            Citizen.Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)

            if IsControlJustPressed(1, 191) then -- Accept
                isPromptActive = false
                SetNewWaypoint(coords.x, coords.y)
                TriggerEvent('gmack_witness_master:notifyPolice', 'You have accepted the shooting alert.')
            end

            if IsControlJustPressed(1, 194) then -- Decline
                isPromptActive = false
                TriggerEvent('gmack_witness_master:notifyPolice', 'You have declined the shooting alert.')
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)  -- Check every second
        
        local playerPed = PlayerPedId()
        if IsPedShooting(playerPed) then
            local playerCoords = GetEntityCoords(playerPed)

            -- Check for nearby NPCs
            for _, npc in ipairs(GetAllPeds()) do
                if IsEntityAPed(npc) and not IsPedAPlayer(npc) then
                    local npcCoords = GetEntityCoords(npc)
                    if Vdist(playerCoords.x, playerCoords.y, playerCoords.z, npcCoords.x, npcCoords.y, npcCoords.z) <= 50.0 then
                        -- Trigger server event to report shooting
                        TriggerServerEvent('gmack_witness_master:reportShooting', playerCoords)
                        break  -- Report only once per shooting event
                    end
                end
            end
        end
    end
end)

function GetAllPeds()
    local peds = {}
    for ped in EnumeratePeds() do
        table.insert(peds, ped)
    end
    return peds
end

function EnumeratePeds()
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        local success
        repeat
            coroutine.yield(ped)
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
    end)
end

RegisterNetEvent('gmack_witness_master:alertPolice')
AddEventHandler('gmack_witness_master:alertPolice', function(coords)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, coords.x, coords.y, coords.z)

    if distance <= Config.NotificationDistance then
        -- Add a blip on the map
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipColour(blip, Config.Blip.Colour)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.BlipName)
        EndTextCommandSetBlipName(blip)

        -- Notify the player
        TriggerEvent('gmack_witness_master:notifyPolice', Config.NotificationText)

        -- Show the UI prompt
        ShowShootingAlertPrompt(coords)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.ShootingDetectionInterval)  -- Use your defined interval
        local playerPed = PlayerPedId()
        if IsPedShooting(playerPed) then
            local coords = GetEntityCoords(playerPed)
            TriggerServerEvent('gmack_witness_master:reportShooting', coords)
            TriggerServerEvent('gmack_witness_master:witnessReport', coords)
        end
    end
end)

