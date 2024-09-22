local Config = require('config')

local function sendToDiscord(message)
    local data = {
        content = message,
        name = "Witness System" -- Change the username as needed
    }

    PerformHttpRequest(Config.WebhookURL, function(err, text, headers) 
        -- Handle response if necessary
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent('gmack_witness_master:notifyPolice')
AddEventHandler('gmack_witness_master:notifyPolice', function(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, true)

    sendToDiscord(message)
end)

local function isPolice(playerId)
    local user = exports.vorp:getUser(playerId)
    if user then
        local job = user:getJob()
        return job == 'police'  -- Adjust based on your server's job naming
    end
    return false
end

RegisterNetEvent('gmack_witness_master:reportShooting')
AddEventHandler('gmack_witness_master:reportShooting', function(coords)
    for _, playerId in ipairs(GetPlayers()) do
        if isPolice(playerId) then
            TriggerClientEvent('gmack_witness_master:alertPolice', playerId, coords)

            sendToDiscord('A shooting was reported at coordinates: ' .. tostring(coords))
        end
    end
end)

RegisterNetEvent('gmack_witness_master:witnessReport')
AddEventHandler('gmack_witness_master:witnessReport', function(coords)
    local radius = Config.NotificationRadius
    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(ped)
        if Vdist(playerCoords.x, playerCoords.y, playerCoords.z, coords.x, coords.y, coords.z) <= radius then
            if isPolice(playerId) then
                TriggerClientEvent('gmack_witness_master:notifyPolice', playerId, 'A witness reported gunshots nearby.')

                sendToDiscord('A witness reported gunshots nearby at coordinates: ' .. tostring(coords))
            end
        end
    end
end)

-- Handle NPCs reporting shooting events
RegisterNetEvent('gmack_witness_master:reportNPC')
AddEventHandler('gmack_witness_master:reportNPC', function(coords)
    local radius = Config.NPCRadius
    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(ped)
        if Vdist(playerCoords.x, playerCoords.y, playerCoords.z, coords.x, coords.y, coords.z) <= radius then
            for _, policeId in ipairs(GetPlayers()) do
                if isPolice(policeId) then
                    TriggerClientEvent('gmack_witness_master:notifyPolice', policeId, 'A local NPC reported gunshots nearby.')

                    sendToDiscord('A local NPC reported gunshots nearby at coordinates: ' .. tostring(coords))
                end
            end
        end
    end
end)




