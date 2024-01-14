-- Load Ban Data
ListBan = {}
function GuardGetBanData()
    ListBan = {}
    isBanDataLoaded = false
    lastBanId = 0
    MySQL.query('SELECT * FROM fsguard', {}, function(result)
        if result[1] then
            for i = 1, #result, 1 do
                table.insert(ListBan, {
                    banid              = result[i].id,
                    name              = result[i].name,
                    license              = result[i].license,
                    steam              = result[i].steam,
                    hwid              = result[i].hwid,
                    discord              = result[i].discord,
                    ip              = result[i].ip,
                })
                lastBanId = tonumber(result[i].id)
            end
        end
    end)
    isBanDataLoaded = true
    print("Ban Data Loaded")
end

function GuardNotify(name, ip, steam, hwid, license, discord, reason, detail)
    lastBanId = lastBanId+1
	local msg = {["author"] = {["name"] = "FS-OCR", ["url"] = "https://discord.gg/TRwcswBhg3", ["icon_url"] = "https://cdn.discordapp.com/attachments/1128226169339265125/1182355502802415646/fstech_logo.png"} ,["thumbnail"]= {["url"] = "https://cdn.discordapp.com/attachments/1128226169339265125/1182355502802415646/fstech_logo.png"}, ["color"] = "10552316", ["type"] = "rich", ["title"] = "Player Banned", ["url"] = "https://discord.gg/TRwcswBhg3", ["description"] =  "**Name : **" ..name .. "\n **Reason : **" ..reason.. "\n **Detail : **||" ..detail.. "||\n **IP : **||" ..ip.. "||\n **Steam : **||" .. steam .. "||\n **HWID: **||" ..hwid.. "||\n **Rockstar License : **||" .. license .. "||\n **Discord : **<@" .. discord .. ">".."||\n **Ban ID : **"..tostring(lastBanId), ["footer"] = { ["icon_url"] = "https://cdn.discordapp.com/attachments/1128226169339265125/1182355502802415646/fstech_logo.png", ["text"] = "FutureSeekerTech | "..os.date("%Y/%m/%d | %X")}}
	if name ~= "Unknown" then
	  PerformHttpRequest(WebhookUrl, function(err, text, headers) end, "POST", json.encode({username = "FS OCR", embeds = {msg}, avatar_url = "https://cdn.discordapp.com/attachments/1078837522882367508/1114897951177855059/fstech_logo.png"}), {["Content-Type"] = "application/json"})
	end
end exports("GuardNotify", GuardNotify)

function ExploitBan(id, license, steam, hwid, discord, ip, reason)
	MySQL.insert('INSERT INTO fsguard (id, name, license, steam, hwid, discord, ip, reason) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        lastBanId,
		GetPlayerName(id),
		license, 
		steam, 
		hwid, 
		discord, 
		ip, 
		reason
	})
	DropPlayer(id, 'You are banned\nReason: Exploit\nBan ID: '..lastBanId..'Please contact the server owner for more information.')
	GuardGetBanData()
end exports("ExploitBan", ExploitBan)

-- Get Player Data
function GuardGetPlayerData(source)
    local license = nil
    local playerip      = nil
    local playerdiscord = nil
    local hwid        = GetPlayerToken(source, 0)
    local steam       = nil
    local name  = GetPlayerName(source)

    for k,v in pairs(GetPlayerIdentifiers(source))do   
        if string.sub(v, 1, string.len("license:")) == "license:" then
        license = v
        elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
        steam  = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
        playerip = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
        playerdiscord = v
        end
    end
    
    if playerip == nil then
        playerip = GetPlayerEndpoint(source)
        if playerip == nil then
        playerip = '-'
        end
    end
    if playerdiscord == nil then
        playerdiscord = '-'
    end
    if steam == nil then
        steam = '-'
    end
    if hwid == nil then
        hwid = '-'
    end
    local data = {}
    data.name = name or '-'
    data.license = license or '-'
    data.steam = steam or '-'
    data.discord = playerdiscord or '-'
    data.hwid = hwid or '-'
    data.ip = playerip or '-'
    return data
end exports('GuardGetPlayerData', GuardGetPlayerData)

-- Ban Player
function GuardBanPlayer(source, eventName)
    local data = GuardGetPlayerData(source)
	GuardNotify(data.name, data.ip, data.steam, data.hwid, data.license, data.discord, eventName)
	ExploitBan(source, data.license, data.steam, data.hwid, data.discord, data.ip, "Exploiting "..eventName)
end exports("GuardBanPlayer", GuardBanPlayer)

-- Player Checker
AddEventHandler('playerConnecting', function (playerName,setKickReason, deferrals)
    local data = GuardGetPlayerData(source)
    deferrals.defer()
    -- mandatory wait!
    Wait(0)
    deferrals.update(string.format("Checking your ban status."))
    while not isBanDataLoaded do
        Citizen.Wait(100)
    end
    for i = 1, #ListBan, 1 do
        -- Rockstar License Checker
        if not((tostring(ListBan[i].license)) == "-" ) and (tostring(ListBan[i].license)) == tostring(data.license) then
            deferrals.done('You are banned by the server for exploiting. Your ban id: '..ListBan[i].banid)
            CancelEvent()
        end
        -- Steam Checker
        if not((tostring(ListBan[i].steam)) == "-" ) and (tostring(ListBan[i].steam)) == tostring(data.steam) then
            deferrals.done('You are banned by the server for exploiting. Your ban id: '..ListBan[i].banid)
            CancelEvent()
        end
        -- HWID Checker
        if not((tostring(ListBan[i].hwid)) == "-" ) and (tostring(ListBan[i].hwid)) == tostring(data.hwid) then
            deferrals.done('You are banned by the server for exploiting. Your ban id: '..ListBan[i].banid)
            CancelEvent()
        end
        -- IP Checker Bypassed
        -- if not((tostring(ListBan[i].ip)) == "-" ) and (tostring(ListBan[i].ip)) == tostring(data.ip) then
        --     deferrals.done('You are banned by the server for exploiting. Your ban id: '..ListBan[i].banid)
        --     CancelEvent()
        -- end
        -- Discord Checker
        if not((tostring(ListBan[i].discord)) == "-" ) and (tostring(ListBan[i].discord)) == tostring(data.discord) then
            deferrals.done('You are banned by the server for exploiting. Your ban id: '..ListBan[i].banid)
            CancelEvent()
        end
    end
    Citizen.Wait(5000)
    deferrals.done()
end)


RegisterNetEvent('fs-balaupata:server:link', function()
    TriggerClientEvent("fs-balaupata:client:link", source, WebhookUrl)
end)

RegisterNetEvent('fs-balaupata:server:foundString')
AddEventHandler('fs-balaupata:server:foundString', function(word)
    local src = source
    local data = GuardGetPlayerData(src)
    GuardNotify(data.name, data.ip, data.steam, data.hwid, data.license, data.discord, "OCR DETECTION", word)
    ExploitBan(src, data.license, data.steam, data.hwid, data.discord, data.ip, "OCR DETECTION: "..word)
end)

RegisterCommand("fsocr", function(source, args, rawCommand)
    if args[1] == nil then 
      print("Gunakan fsocr unban <banid>")
    end
    -- If the source is > 0, then that means it must be a player.
    if (source > 0) then
      return false
    -- If it's not a player, then it must be RCON, a resource, or the server console directly.
    else
      if args[1] == "unban" then
        if args[2] == nil then
            print("Gunakan fsocr unban <banid>")
        else
            MySQL.query('DELETE from fsguard WHERE id = ?', {
                tonumber(args[2]),
            })
            print("Unban command executed")
            GuardGetBanData()
        end
      end
      if args[1] == "refresh" then
        GuardGetBanData()
        print("Ban data refreshed")
      end
    end
end, true)


-- OnResourceStart
AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        print("=====================================================")
        print("FS-OCR by FutureSeekerTech Started")
        if GetResourceState("screenshot-basic") == "started" then
            print("OCR MODULE STARTED")
        else
            print("OCR Module Dependency Not Ready, Waiting For Ready....")
            StartResource("yarn")
            StartResource("webpack")
            StartResource("screenshot-basic")
            print("OCR Module Dependency Ready")
        end
        print("FS-OCR Version 0.1.0")
        print("=====================================================")
        GuardGetBanData()
    end
end)