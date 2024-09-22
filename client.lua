Config = require('config')

local isPromptActive = false

-- Function to display notifications to police
RegisterNetEvent('gmack_witness_master:notifyPolice')
AddEventHandler('gmack_witness_master:notifyPolice', function(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, true)
end)

-- Function to display a UI prompt for police to respond to a shooting
function ShowShootingAlertPrompt(coords)
    local scaleform = RequestScaleformMovie("instructional_buttons")

    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    -- Adding instructional buttons
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(2, 191, true)) -- Accept button (A on controller, Enter on keyboard)
    PushScaleformMovieFunctionParameterString("Accept Shooting Alert")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(2, 194, true)) -- Decline button (B on controller, Backspace on keyboard)
    PushScaleformMovieFunctionParameterString("Decline Shooting Alert")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    isPromptActive = true

    Citizen.CreateThread(function()
        while isPromptActive do
            Citizen.Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)

            -- Detect input for Accept (Enter or A button)
            if IsControlJustPressed(1, 191) then
                -- Accepted the shooting alert
                isPromptActive = false
                SetNewWaypoint(coords.x, coords.y)
                TriggerEvent('gmack_witness_master:notifyPolice', 'You have accepted the shooting alert.')
            end

            -- Detect input for Decline (Backspace or B button)
            if IsControlJustPressed(1, 194) then
                -- Declined the shooting alert
                isPromptActive = false
                TriggerEvent('gmack_witness_master:notifyPolice', 'You have declined the shooting alert.')
            end
        end
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

        -- Notify the player with a shooting alert
        TriggerEvent('gmack_witness_master:notifyPolice', Config.NotificationText)

        -- Show the UI prompt for the police to accept or decline the shooting report
        ShowShootingAlertPrompt(coords)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.ShootingDetectionInterval)
        local playerPed = PlayerPedId()
        if IsPedShooting(playerPed) then
            local coords = GetEntityCoords(playerPed)
            TriggerServerEvent('gmack_witness_master:reportShooting', coords)
            TriggerServerEvent('gmack_witness_master:witnessReport', coords)
        end
    end
end)
