local QBCore = exports['qb-core']:GetCoreObject()
local bowls = {}
local Targets = {}
local choosetime = false
local currentgame = 0
local peds = {}
local pedSpawned = false
local PlayerJob, onDuty = {}, false

AddEventHandler('onResourceStart', function(resource) if GetCurrentResourceName() ~= resource then return end QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job createPeds() end) end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() local player = QBCore.Functions.GetPlayerData() PlayerJob = player.job.name createPeds() end)
RegisterNetEvent('QBCore:Client:SetDuty', function(duty) onDuty = duty end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo onDuty = true end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() deletePeds() end)
function loadModel(model) if not HasModelLoaded(model) then RequestModel(model) while not HasModelLoaded(model) do Wait(0) end end end
function loadAnimDict(dict) while not HasAnimDictLoaded(dict) do RequestAnimDict(dict) Wait(5) end end

local function playanim(ped, animdic, anim, time)
    loadAnimDict(animdic)
    TaskPlayAnim(ped, animdic, anim, 1.0, -1.0,-1,1,0,0, 0,0)
    if time ~= nil then
        Citizen.Wait(time)
        ClearPedTasks(ped)
    end
end

local function playspeech(k, speech)
	Citizen.CreateThread(function()
		StopCurrentPlayingAmbientSpeech(peds[k])
		PlayAmbientSpeech1(peds[k], speech, "SPEECH_PARAMS_FORCE_NORMAL_CLEAR")
	end)
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        for k, v in pairs(Config.Locations) do
            local dist = #(pos - vec3(v.coords.x, v.coords.y, v.coords.z))
            if dist < Config.SpawnDistance then
            else
                if v.spawned then
                    if currentgame == k then
                        choosetime = false
                        TriggerServerEvent('flex-shellgame:server:setstate', currentgame, false)
                    end
                    exports['qb-target']:RemoveZone("b1"..k)
                    exports['qb-target']:RemoveZone("b2"..k)
                    exports['qb-target']:RemoveZone("b3"..k)
                    DeleteObject(bowls['b1'..k])
                    DeleteObject(bowls['b2'..k])
                    DeleteObject(bowls['b3'..k])
                    readytoplay = false
                end
            end
        end
        Wait(1000 * Config.LoopDelay)
    end
end)

function createPeds()
    if pedSpawned then return end

    for k, v in pairs(Config.Locations) do
        local current = type(v.ped) == "number" and v.ped or joaat(v.ped)

        RequestModel(current)
        while not HasModelLoaded(current) do
            Wait(0)
        end

        peds[k] = CreatePed(4, current, v.coords.x, v.coords.y+0.5, v.coords.z - 1.0, 180.0, false, false)
        TaskStartScenarioInPlace(peds[k], 'WORLD_HUMAN_AA_SMOKE', 0, true)
        SetEntityCanBeDamaged( peds[k], false)
        FreezeEntityPosition(peds[k], true)
        SetEntityInvincible(peds[k], true)
        SetBlockingOfNonTemporaryEvents(peds[k], true)
        SetPedCanRagdollFromPlayerImpact(peds[k], false)
        SetPedResetFlag(peds[k], 249, true)
		SetPedConfigFlag(peds[k], 185, true)
		SetPedConfigFlag(peds[k], 108, true)
		SetPedConfigFlag(peds[k], 208, true)
		
        v.spawned = true
    end
    pedSpawned = true
end

function deletePeds()
    if not pedSpawned then return end

    for _, v in pairs(peds) do
        DeletePed(v)
    end
    pedSpawned = false
end

local waittime = 1
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        if not IsPedInAnyVehicle(ped, false) then
            for k, v in pairs(Config.Locations) do
                local dist = #(pos - vec3(v.coords.x, v.coords.y, v.coords.z))
                if dist < 3 and not v.arrested then
                    waittime = 1
                    if v.spawned and not v.bussy then
                        if PlayerJob.name == 'police' and onDuty then
                            QBCore.Functions.DrawText3D(v.coords.x, v.coords.y, v.coords.z-0.4, '[~o~E~w~] '..Lang:t("info.play", {value = tostring(v.betamount)})..' [~o~G~w~] '..Lang:t("info.arrest"))
                        else
                            QBCore.Functions.DrawText3D(v.coords.x, v.coords.y, v.coords.z-0.4, '[~o~E~w~] '..Lang:t("info.play", {value = tostring(v.betamount)}))
                        end
                        DrawMarker(2, v.coords.x, v.coords.y, v.coords.z-0.5, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, 255, 255, 255, 100, false, true, 2, nil, nil, false)
                        if IsControlJustPressed(0, 38) and dist < 1.5 then
                            QBCore.Functions.TriggerCallback('flex-shellgame:server:HasMoney', function(HasMoney)
                                if not HasMoney then
                                    QBCore.Functions.Notify(Lang:t("error.nomoney"), "error", 5000)
                                else
                                    QBCore.Functions.FaceToPos(v.coords.x, v.coords.y, v.coords.z)
                                    playanim(peds[k], 'random@domestic', 'pickup_low', 1100)
                                    loadModel('ex_mp_h_acc_bowl_ceramic_01')
                                    local bowl1 = vec3(v.coords.x-0.5, v.coords.y, v.coords.z)
                                    local bowl2 = vec3(v.coords.x, v.coords.y, v.coords.z)
                                    local bowl3 = vec3(v.coords.x+0.5, v.coords.y, v.coords.z)
                                    local pedcoords = vec3(v.coords.x, v.coords.y+0.5, v.coords.z - 1.0)
                                    if not DoesObjectOfTypeExistAtCoords(bowl1, 2.0, 'ex_mp_h_acc_bowl_ceramic_01', true) then
                                        bowls['b1'..k] = CreateObject('ex_mp_h_acc_bowl_ceramic_01', bowl1.x, bowl1.y, bowl1.z-0.82, true, true, true)
                                        SetEntityRotation(bowls['b1'..k], 180.0, 0.0, v.coords.w, false, false)
                                        SetEntityCollision(bowls['b1'..k], true)
                                        FreezeEntityPosition(bowls['b1'..k], true)
                                    end
                                    if not DoesObjectOfTypeExistAtCoords(bowl2, 2.0, 'ex_mp_h_acc_bowl_ceramic_01', true) then
                                        bowls['b2'..k] = CreateObject('ex_mp_h_acc_bowl_ceramic_01', bowl2.x, bowl2.y, bowl2.z-0.82, true, true, true)
                                        SetEntityRotation(bowls['b2'..k], 180.0, 0.0, v.coords.w, false, false)
                                        SetEntityCollision(bowls['b2'..k], true)
                                        FreezeEntityPosition(bowls['b2'..k], true)
                                    end
                                    if not DoesObjectOfTypeExistAtCoords(bowl3, 2.0, 'ex_mp_h_acc_bowl_ceramic_01', true) then
                                        bowls['b3'..k] = CreateObject('ex_mp_h_acc_bowl_ceramic_01', bowl3.x, bowl3.y, bowl3.z-0.82, true, true, true)
                                        SetEntityRotation(bowls['b3'..k], 180.0, 0.0, v.coords.w, false, false)
                                        SetEntityCollision(bowls['b3'..k], true)
                                        FreezeEntityPosition(bowls['b3'..k], true)
                                    end
                                    Wait(1000)
                                    TriggerServerEvent('flex-shellgame:server:play', v.betamount)
                                    playspeech(k, "MINIGAME_DEALER_GREET")
                                    playanim(ped, 'random@domestic', 'pickup_low', 1100)
                                    currentgame = k
                                    choosetime = false
                                    TriggerServerEvent('flex-shellgame:server:setstate', k, true)
                                    local r = math.random(1,3)
                                    local pos = GetEntityCoords(bowls['b'..tostring(r)..k])
                                    playanim(peds[k], 'random@domestic', 'pickup_low', 1100)
                                    SetEntityCoords(bowls['b'..tostring(r)..k], pos.x, pos.y, pos.z+0.4)
                                    loadModel('prop_tennis_ball')
                                    if not DoesObjectOfTypeExistAtCoords(pos, 2.0, 'prop_tennis_ball', true) then
                                        bowls['ball'..k] = CreateObject('prop_tennis_ball', pos.x, pos.y, pos.z-0.175, true, true, true)
                                        SetEntityCollision(bowls['ball'..k], true)
                                        FreezeEntityPosition(bowls['ball'..k], true)
                                    end
                                    Wait(4000)
                                    playspeech(k, "MINIGAME_DEALER_COMMENT_SLOW")
                                    playanim(peds[k], 'random@domestic', 'pickup_low', 1100)
                                    SetEntityCoords(bowls['b'..tostring(r)..k], pos.x, pos.y, pos.z)
                                    playGame(k)
                                end
                            end, v.betamount)
                        end
                        if IsControlJustReleased(0, 47) and dist < 1.5 and PlayerJob.name == 'police' and onDuty and not v.bussy then
                            QBCore.Functions.FaceToPos(v.coords.x, v.coords.y, v.coords.z)
                            local cuffdict = 'mp_arrest_paired'
                            local cuffanim = 'cop_p2_back_right'
                            ClearPedTasksImmediately(GetPlayerPed(-1))
                            RequestAnimDict(cuffdict)
                            while not HasAnimDictLoaded(cuffdict) do
                                Citizen.Wait(100)
                            end
                            TriggerServerEvent("InteractSound_SV:PlayOnSource", "Cuff", 0.2)
                            TaskPlayAnim(GetPlayerPed(-1), cuffdict, cuffanim, 8.0, -8, 3500, 16, 0, 0, 0, 0)
                            Citizen.Wait(3500)
                            ClearPedTasks(GetPlayerPed(-1))
                            exports['qb-target']:RemoveZone("b1"..k)
                            exports['qb-target']:RemoveZone("b2"..k)
                            exports['qb-target']:RemoveZone("b3"..k)
                            TriggerServerEvent('flex-shellgame:server:arrested', k, true)
                            SetTimeout(1000*60*Config.ArrestTimeOut, function()
                                TriggerServerEvent('flex-shellgame:server:arrested', k, false)
                            end)
                        end
                    end
                -- else
                --     waittime = 1000
                end
            end
        end
        Wait(waittime)
    end
end)

function playGame(k)
    QBCore.Functions.Notify(Lang:t("info.howtoplay"), "success", 5000)
    DeleteObject(bowls['ball'..k])
    playanim(peds[k], 'mini@repair', 'fixing_a_ped')
    local time = 0
    while time <= Config.ShuffleTimes do
        if math.random(0,1) == 1 then
            local b1 = GetEntityCoords(bowls['b1'..k])
            local b2 = GetEntityCoords(bowls['b2'..k])
            SetEntityCoords(bowls['b1'..k], b1.x+0.22, b1.y, b1.z)
            SetEntityCoords(bowls['b2'..k], b2.x-0.18, b2.y, b2.z)
            Wait(500)
            SetEntityCoords(bowls['b1'..k], b2.x, b2.y, b2.z)
            SetEntityCoords(bowls['b2'..k], b1.x, b1.y, b1.z)
        else
            local b2 = GetEntityCoords(bowls['b2'..k])
            SetEntityCoords(bowls['b2'..k], b2.x-0.21, b2.y, b2.z)
            Wait(500)
            SetEntityCoords(bowls['b2'..k], b2.x, b2.y, b2.z)
        end
        Wait(250)
        if math.random(0,1) == 1 then
            local b2 = GetEntityCoords(bowls['b2'..k])
            local b3 = GetEntityCoords(bowls['b3'..k])
            SetEntityCoords(bowls['b2'..k], b2.x+0.22, b2.y, b2.z)
            SetEntityCoords(bowls['b3'..k], b3.x-0.18, b3.y, b3.z)
            Wait(500)
            SetEntityCoords(bowls['b2'..k], b3.x, b3.y, b3.z)
            SetEntityCoords(bowls['b3'..k], b2.x, b2.y, b2.z)
        else
            local b1 = GetEntityCoords(bowls['b1'..k])
            SetEntityCoords(bowls['b1'..k], b1.x-0.21, b1.y, b1.z)
            Wait(500)
            SetEntityCoords(bowls['b1'..k], b1.x, b1.y, b1.z)
        end
        time = time + 1
        Wait(500)
    end
    local b1 = GetEntityCoords(bowls['b1'..k])
    Targets["b1"..k] = exports['qb-target']:AddBoxZone("b1"..k, b1, 0.2, 0.2, {
        name = "b1"..k,
        heading = 0.0,
        debugPoly = Config.Debug,
        minZ = b1.z-0.2,
        maxZ = b1.z+0.2,
    }, {
        options = {
            {
                type = "client",
                event = "flex-shellgame:client:choose",
                icon = "fa fa-sort-numeric-desc",
                label = Lang:t('info.choose', {value = tostring(1)}),
                action = function()
                    TriggerEvent("flex-shellgame:client:choose", k, 1)
                end,
                canInteract = function()
                    return choosetime
                end,
            }
        },
        distance = 1.5
    })
    local b2 = GetEntityCoords(bowls['b2'..k])
    Targets["b2"..k] = exports['qb-target']:AddBoxZone("b2"..k, b2, 0.2, 0.2, {
        name = "b2"..k,
        heading = 0.0,
        debugPoly = Config.Debug,
        minZ = b2.z-0.2,
        maxZ = b2.z+0.2,
    }, {
        options = {
            {
                type = "client",
                event = "flex-shellgame:client:choose",
                icon = "fa fa-sort-numeric-desc",
                label = Lang:t('info.choose', {value = tostring(2)}),
                action = function()
                    TriggerEvent("flex-shellgame:client:choose", k, 2)
                end,
                canInteract = function()
                    return choosetime
                end,
            }
        },
        distance = 1.5
    })
    local b3 = GetEntityCoords(bowls['b3'..k])
    Targets["b3"..k] = exports['qb-target']:AddBoxZone("b3"..k, b3, 0.2, 0.2, {
        name = "b3"..k,
        heading = 0.0,
        debugPoly = Config.Debug,
        minZ = b3.z-0.2,
        maxZ = b3.z+0.2,
    }, {
        options = {
            {
                type = "client",
                event = "flex-shellgame:client:choose",
                icon = "fa fa-sort-numeric-desc",
                label = Lang:t('info.choose', {value = tostring(3)}),
                action = function()
                    TriggerEvent("flex-shellgame:client:choose", k, 3)
                end,
                canInteract = function()
                    return choosetime
                end,
            }
        },
        distance = 1.5
    })
    choosetime = true
    ClearPedTasks(peds[k])
end

RegisterNetEvent('flex-shellgame:client:setstate', function(id, state)
    Config.Locations[id].bussy = state
end)

RegisterNetEvent('flex-shellgame:client:arrested', function(id, state)
    Config.Locations[id].spawned = not state
    Config.Locations[id].arrested = state
    if state then
        DeletePed(peds[id])
    end
    if not state then
        if not DoesObjectOfTypeExistAtCoords(pedcoords, 2.0, Config.Locations[id].ped, true) then
            local current = type(Config.Locations[id].ped) == "number" and Config.Locations[id].ped or joaat(Config.Locations[id].ped)
            RequestModel(current)
            while not HasModelLoaded(current) do
                Wait(0)
            end

            peds[id] = CreatePed(0, current, Config.Locations[id].coords.x, Config.Locations[id].coords.y+0.5, Config.Locations[id].coords.z - 1.0, 180.0, false, false)
            TaskStartScenarioInPlace(peds[id], 'WORLD_HUMAN_AA_SMOKE', 0, true)
            FreezeEntityPosition(peds[id], true)
            SetEntityInvincible(peds[id], true)
            SetBlockingOfNonTemporaryEvents(peds[id], true)
            Config.Locations[id].spawned = true
        end
    end
end)

RegisterNetEvent('flex-shellgame:client:choose', function(k, id)
    local pos = GetEntityCoords(bowls['b'..tostring(id)..k])
    local r = math.random(1,3)
    local winpos = GetEntityCoords(bowls['b'..tostring(r)..k])
    playanim(peds[k], 'random@domestic', 'pickup_low', 1100)
    SetEntityCoords(bowls['b'..tostring(id)..k], pos.x, pos.y, pos.z+0.4)
    loadModel('prop_tennis_ball')
    if r == id then
        playspeech(k, "MINIGAME_DEALER_BUSTS")
        QBCore.Functions.Notify(Lang:t("success.win"), "success", 5000)
        TriggerServerEvent('flex-shellgame:server:win', Config.Locations[k].betamount)
        if not DoesObjectOfTypeExistAtCoords(winpos, 2.0, 'prop_tennis_ball', true) then
            bowls['ball'..k] = CreateObject('prop_tennis_ball', winpos.x, winpos.y, winpos.z-0.175, true, true, true)
            SetEntityCollision(bowls['ball'..k], true)
            FreezeEntityPosition(bowls['ball'..k], true)
        end
    end
    Wait(4000)
    if r ~= id then
        QBCore.Functions.Notify(Lang:t("error.nowin"), "error", 5000)
        if not DoesObjectOfTypeExistAtCoords(winpos, 2.0, 'prop_tennis_ball', true) then
            bowls['ball'..k] = CreateObject('prop_tennis_ball', winpos.x, winpos.y, winpos.z-0.175, true, true, true)
            SetEntityCollision(bowls['ball'..k], true)
            FreezeEntityPosition(bowls['ball'..k], true)
        end
        playspeech(k, "MINIGAME_DEALER_WINS")
        playanim(peds[k], 'random@domestic', 'pickup_low', 1100)
    end
    SetEntityCoords(bowls['b'..tostring(r)..k], winpos.x, winpos.y, winpos.z+0.4)
    Wait(4000)
    playanim(peds[k], 'random@domestic', 'pickup_low', 1100)
    if r ~= id then
        SetEntityCoords(bowls['b'..tostring(r)..k], winpos.x, winpos.y, winpos.z)
        SetEntityCoords(bowls['b'..tostring(id)..k], pos.x, pos.y, pos.z)
    else
        SetEntityCoords(bowls['b'..tostring(id)..k], pos.x, pos.y, pos.z)
    end
    DeleteObject(bowls['ball'..k])
    SetEntityCoords(bowls['b1'..k], Config.Locations[k].coords.x-0.5, Config.Locations[k].coords.y, Config.Locations[k].coords.z-0.82)
    SetEntityCoords(bowls['b2'..k], Config.Locations[k].coords.x, Config.Locations[k].coords.y, Config.Locations[k].coords.z-0.82)
    SetEntityCoords(bowls['b3'..k], Config.Locations[k].coords.x+0.5, Config.Locations[k].coords.y, Config.Locations[k].coords.z-0.82)
    exports['qb-target']:RemoveZone("b1"..k)
    exports['qb-target']:RemoveZone("b2"..k)
    exports['qb-target']:RemoveZone("b3"..k)
    Wait(1500)
    DeleteObject(bowls['b1'..k])
    DeleteObject(bowls['b2'..k])
    DeleteObject(bowls['b3'..k])
    TriggerServerEvent('flex-shellgame:server:setstate', k, false)
    choosetime = false
    readytoplay = false
    TaskStartScenarioInPlace(peds[k], 'WORLD_HUMAN_AA_SMOKE', 0, true)
end)

AddEventHandler('onResourceStop', function(resource) if resource ~= GetCurrentResourceName() then return end
    for k, v in pairs(bowls) do DeleteObject(v) end
    for k, v in pairs(peds) do DeletePed(peds[k]) end
    for k, v in pairs(Config.Locations) do
        exports['qb-target']:RemoveZone("b1"..k)
        exports['qb-target']:RemoveZone("b2"..k)
        exports['qb-target']:RemoveZone("b3"..k)
    end
end)