local QBCore = exports['qb-core']:GetCoreObject()

-- Discord ID kontrolü
local function isAuthorized(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.find(id, "discord:") then
            local discordId = string.gsub(id, "discord:", "")
            for _, authorizedId in ipairs(Config.AuthorizedDiscordIDs) do
                if discordId == authorizedId then
                    return true
                end
            end
        end
    end
    return false
end

-- Webhook ile log gönderme
local function sendToDiscord(title, message, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["type"] = "rich",
            ["color"] = color or 16711680,
            ["footer"] = {
                ["text"] = "QB JobAdmin"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    PerformHttpRequest(Config.WebhookURL, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
end

-- Tüm oyuncuları getir
QBCore.Functions.CreateCallback('qb-jobadmin:server:GetAllPlayers', function(source, cb)
    if not isAuthorized(source) then
        cb(false)
        return
    end

    local players = {}
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        table.insert(players, {
            source = v.PlayerData.source,
            citizenid = v.PlayerData.citizenid,
            name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
            job = v.PlayerData.job
        })
    end
    cb(players)
end)

-- Meslek değiştirme
RegisterNetEvent('qb-jobadmin:server:SetJob', function(targetId, job, grade)
    local source = source
    if not isAuthorized(source) then return end
    
    local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Player then
        local oldJob = Player.PlayerData.job.name
        local oldGrade = Player.PlayerData.job.grade.level
        
        Player.Functions.SetJob(job, grade)
        
        local adminPlayer = QBCore.Functions.GetPlayer(source)
        local logMessage = string.format("%s (%s) changed %s's (%s) job from %s (grade %s) to %s (grade %s)",
            adminPlayer.PlayerData.charinfo.firstname .. " " .. adminPlayer.PlayerData.charinfo.lastname,
            adminPlayer.PlayerData.citizenid,
            Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
            Player.PlayerData.citizenid,
            oldJob, oldGrade,
            job, grade
        )
        
        sendToDiscord("Job Changed", logMessage, 65280)
    end
end)

-- Komut kaydı
QBCore.Commands.Add(Config.CommandName, 'İş yönetim menüsünü aç', {}, false, function(source)
    if isAuthorized(source) then
        TriggerClientEvent('qb-jobadmin:client:OpenMenu', source)
    else
        TriggerClientEvent('QBCore:Notify', source, 'Bu komutu kullanma yetkiniz yok!', 'error')
    end
end)