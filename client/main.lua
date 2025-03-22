local QBCore = exports['qb-core']:GetCoreObject()

-- NUI mesajlarını dinle
RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('setJob', function(data, cb)
    TriggerServerEvent('qb-jobadmin:server:SetJob', data.playerId, data.job, data.grade)
    cb('ok')
end)

-- Menüyü aç
RegisterNetEvent('qb-jobadmin:client:OpenMenu', function()
    QBCore.Functions.TriggerCallback('qb-jobadmin:server:GetAllPlayers', function(players)
        if players then
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "openMenu",
                players = players
            })
        else
            QBCore.Functions.Notify('Bu menüyü açma yetkiniz yok!', 'error')
        end
    end)
end)