local SafeCallEvent = TriggerServerEvent
local isBusy = false
discordwebhook = nil
Wordlist = {
    "FlexSkazaMenu","SidMenu","Lynx8","LynxEvo","Maestro Menu","redEngine","HamMafia","HamHaxia","Dopameme","redMENU","Desudo","explode","gamesense","Anticheat","Tapatio","Malossi","RedStonia","Chocohax",
    "skin changer","torque multiple","override player speed","colision proof","explosion proof","copy outfit","play single particle","infinite ammo","rip server","remove ammo","remove all weapons",
    "V1s_u4l","D3str_0y","D3str_Oy","S3tt1ngs","P4rt1cl_3s","Pl4y3rz","D3l3t3","Sp4m","V3h1cl3s","T4ze","1nv1s1bll3","R41nb_0w","Sp33d","R41nb_Ow","F_ly","3xpl_0d3","Pr0pz","D3str_0y","M4p","G1v3",
    "Convert Vehicle Into Ramps","injected at","Explode Players","Ram Players","Force Third Person","fallout","godmode","ANTI-CHEAT","god mode","modmenu","esx money","give armor","aimbot","trigger",
    "triggerbot","rage bot","ragebot","rapidfire","freecam","execute","noclip","ckgangisontop","lumia1","ISMMENU","TAJNEMENUMenu","rootMenu","Outcasts666","WaveCheat","NacroxMenu","MarketMenu","topMenu",
    "Flip Vehicle","Rainbow Paintjob","Combat Assiters","Damage Multiplier","Give All Weapons","Teleport To Impact","Explosive Impact","Server Nuke Options","No Ragdoll","Super Powers",
    "invisible all vehicles","Spam Message","Destroy Map","Give RPG","max Speed Vehicles","Rainbow All Vehicles","Delete Props","Cobra Menu","Bind Menu Key","Clone Outfit","Give Health",
    "Rp_GG","V3h1cl3","Sl4p","D4nce","3mote","D4nc3","no-clip","injected","Money Options","Nuke Options","Razer","Aimbot","TriggerBot","RageBot","RapidFire",
    "Force Player Blips","Force Radar","Force Gamertags","ESX Money Options","press AV PAG","TP to Waypoint","Self Options","Vehicle options","Weapon Options","spam Vehicles","taze All",
    "explosive ammo","super damage","rapid fire","Super Jump","Infinite Roll","No Criticals","Move On Water","Disable Ragdoll","CutzuSD","Vertisso","M3ny00","Pl4y_3r","W34p_On","W34p_0n","V3h1_cl3",
    "fuck server","lynx","absolute","Lumia","Gamesense","Fivesense","SkidMenu","Dopamine","Explode","Teleport Options","infnite combat roll","Hydro Menu","Enter Menu Open Key",
    "Give Single Weapon","Airstrike Player","Taze Player","Razer Menu","Swagamine","Visual Options","d0pamine","Infinite Stamina","Blackout","Delete Vehicles Within Radius","Engine Power Boost",
    "Teleport Into Player's Vehicle","fivesense","menu keybind","nospread","transparent props","bullet tracers","model chams","reload images","fade out in speed","cursor size","custom weapons texture",
    "Inyection","Inyected","Dumper","LUA Executor","Executor","Lux Menu","Event Blocker","Spectate","Wallhack","triggers","crosshair","Alokas66","Hacking System!","Destroy Menu","Server IP","Teleport To",
    "Butan Premium", "RAIDEN"
}

RegisterNetEvent('fs-balaupata:client:link', function(data)
    discordwebhook = data
end)

RegisterNUICallback("checktext", function(data)
    if data.image and data.text then
        for index, word in next, Wordlist, nil do
            if string.find(string.lower(data.text), string.lower(word)) then
                if discordwebhook == nil then
                    SafeCallEvent("fs-balaupata:server:link")
                    isBusy = false
                    break
                end
                exports['screenshot-basic']:requestScreenshotUpload(discordwebhook, 'files[]', {encoding = "webp", quality = 1}, function(result)
                    local resp = json.decode(result)
					SafeCallEvent("fs-balaupata:server:foundString", word)
                end)
                break
            end
        end
    end
    isBusy = false
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.CreateThread(function()
			SafeCallEvent("fs-balaupata:server:link")
            while true do
                if GetResourceState("screenshot-basic") == "started" then 
                    if not isBusy then
                    --    Screenshot basic take screenshot with encoding webp and quality 1
                    exports['screenshot-basic']:requestScreenshot(
                        {encoding = "webp", quality = 1},  -- options
                        function(data)
                            SendNUIMessage({
                                action = GetCurrentResourceName()..":checkString",
                                image = data
                            })
                            isBusy = true
                    end)
                end
                Wait(2500)
                end
            end
        end)
    end
end)