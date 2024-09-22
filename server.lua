RegisterNetEvent('gmack_witness_master:notifyPolice')
AddEventHandler('gmack_witness_master:notifyPolice', function(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, true)
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
        end
    end
end)

RegisterNetEvent('gmack_witness_master:witnessReport')
AddEventHandler('gmack_witness_master:witnessReport', function(coords)
    local radius = 500.0 -- Radius for reporting
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

-- Handle NPCs reporting shooting events
RegisterNetEvent('gmack_witness_master:reportNPC')
AddEventHandler('gmack_witness_master:reportNPC', function(coords)
    local radius = 50.0  -- Radius for NPCs to witness
    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(ped)
        -- Check if the player is within the radius of any NPCs
        if Vdist(playerCoords.x, playerCoords.y, playerCoords.z, coords.x, coords.y, coords.z) <= radius then
            -- Here you can implement logic to notify the police
            for _, policeId in ipairs(GetPlayers()) do
                if isPolice(policeId) then
                    TriggerClientEvent('gmack_witness_master:notifyPolice', policeId, 'A local NPC reported gunshots nearby.')
                end
            end
        end
    end
end)



