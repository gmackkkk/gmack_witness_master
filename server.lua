-- server.lua

-- Function to display notifications to police
RegisterNetEvent('gmack_witness_master:notifyPolice')
AddEventHandler('gmack_witness_master:notifyPolice', function(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, true)
end)

-- Function to check if a player is a police officer
local function isPolice(playerId)
    local user = exports.vorp:getUser(playerId)
    if user then
        local job = user:getJob()
        -- Adjust the job check based on your server's job system
        return job == 'police' -- Change this if your police job is named differently
    end
    return false
end

-- Handle shooting event from client
RegisterNetEvent('gmack_witness_master:reportShooting')
AddEventHandler('gmack_witness_master:reportShooting', function(coords)
    -- Notify all police officers
    for _, playerId in ipairs(GetPlayers()) do
        if isPolice(playerId) then
            TriggerClientEvent('gmack_witness_master:alertPolice', playerId, coords)
        end
    end
end)

-- Handle witness reporting shooting
RegisterNetEvent('gmack_witness_master:witnessReport')
AddEventHandler('gmack_witness_master:witnessReport', function(coords)
    local radius = 500.0 -- Radius within which witnesses can report shootings
    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(ped)
        if Vdist(playerCoords.x, playerCoords.y, playerCoords.z, coords.x, coords.y, coords.z) <= radius then
            if isPolice(playerId) then
                TriggerClientEvent('gmack_witness_master:notifyPolice', playerId, 'A witness reported gunshots nearby.')
            end
        end
    end
end)


