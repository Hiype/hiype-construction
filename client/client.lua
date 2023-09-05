local QBCore = exports['qb-core']:GetCoreObject()


local isBuildActive = false
local isAnimating = false
local isAttached = false

local npc
local blip
local workbench
local truck
local loadBox
local currentSpeedModifier
local titleText
local subText

local deliverableObjects = {}

RegisterCommand('loadipl', function(source, args)
    RequestIpl(args[1])
end, false)

RegisterCommand('removeipl', function(source, args)
    RemoveIpl(args[1])
end, false)

local function IsPlayerJobLabelCorrect()
    local PlayerData = QBCore.Functions.GetPlayerData()

    for _, v in pairs(Config.Job) do
        if PlayerData.job.label == v.label then return true end
    end

    return false
end

local function RemoveAllIPLs()
    local IPLs = Config.IPLs
    for i = 1, #IPLs do
        RemoveIpl(IPLs[i])
    end
end

local function LoadModel(pModel)
    RequestModel(pModel)
    while not HasModelLoaded(pModel) do
        Wait(5)
    end
end

local function AddBlipCoord(coord, name)
    blip = AddBlipForCoord(coord)
    SetBlipSprite(blip, 478)
    SetBlipScale(blip, Config.BlipScale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
end

local function PlayerHasAllItemsCraft(pItemKey)
    for k, v in pairs(Config.ItemRequirements[pItemKey]) do
        if not QBCore.Functions.HasItem(k, v) then return false end
    end

    return true
end

local function Draw2DText(x, y, text, scale, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function GetItemLabel(key)
    for k, v in pairs(Config.Items) do
        if k == key then
            return v.label
        end
    end
end

local function PlayerHasAllItems(pItemsArr)
    if type(pItemsArr) == 'table' then
        for k, v in pairs(pItemsArr) do
            if not QBCore.Functions.HasItem(k, v) then
                QBCore.Functions.Notify(string.format(Lang:t('error.you_dont_have_item'), GetItemLabel(k)), 'error', 5000)
                return false
            end
        end
    else
        if not QBCore.Functions.HasItem(pItemsArr, 1) then
            QBCore.Functions.Notify(string.format(Lang:t('error.you_dont_have_item'), tostring(pItemsArr)), 'error', 5000)
            return false
        end
    end

    return true
end

local function RemoveAllItems(pItemsArr)
    for k, v in pairs(pItemsArr) do
        TriggerServerEvent('hiype-construction:server:removeItem', k, v)
    end
end

local function GenerateSubText(stage)
    local text = ""

    if stage.locations ~= nil then
        if stage.requirements ~= nil then
            for k, _ in pairs(stage.requirements) do
                text = text .. CountTableElements(stage.locations) .. 'x ' .. GetItemLabel(k) .. '\n'
            end
        end

        if stage.unpackDeliverables then
            text = text .. Lang:t("info.unpack_deliverables") .. '\n'
        end
    else
        text = text .. stage.interactionCount .. 'x ' .. GetItemLabel(stage.interactionItem) .. '\n'
    end

    return text
end

local function RemoveItem(pItemName, pAmount)
    TriggerServerEvent('hiype-construction:server:removeItem', pItemName, pAmount)
end

local function GenerateItemRequirementsString(pItemKey)
    local str = ''

    for k, v in pairs(Config.ItemRequirements[pItemKey]) do
        str = str .. string.format('%s: %s<br>', QBCore.Shared.Items[k].label, v)
    end

    return str
end

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

local function AllDeliverablesDelivered(deliverables)
    for k, v in pairs(deliverables) do
        if not v.RUNTIME_delivered then
            return false
        end
    end

    return true
end

local function AllDeliverablesUnpacked(deliverables)
    for _, v in pairs(deliverables) do
        if not v.RUNTIME_unpacked then
            return false
        end
    end

    return true
end

local function DeleteDeliverables()
    for _, v in pairs(deliverableObjects) do
        DeleteEntity(v)
    end
end

-- Function from dpemotes
local function AddPropToPlayer(propHash, bone, off1, off2, off3, rot1, rot2, rot3)
    local Player = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(Player))
    local timeout = Config.ModelLoadingTimeout
    local loadingFailed = false
    local prop

    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        if timeout < 5 then
            print('Model loading timed out for prop: ' .. tostring(propHash))
            loadingFailed = true
            return
        end

        timeout = timeout - 5
        Wait(5)
    end

    if not loadingFailed then
        prop = CreateObject(GetHashKey(propHash), x, y, z + 0.2, true, true, true)
        SetEntityInvincible(prop, true)
        AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true,
            false, true, 1, true)
        SetModelAsNoLongerNeeded(prop)
    end

    return prop
end

-- Edited function from qb-mechanicjob
local function Anim(time, dict, anim)
    CreateThread(function()
        loadAnimDict(dict)
        isAnimating = true

        TaskPlayAnim(PlayerPedId(), dict, anim, 3.0, 3.0, -1, 16, 0, false, false, false)

        while true do
            TaskPlayAnim(PlayerPedId(), dict, anim, 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Wait(500)
            time = time - 500
            if time <= 0 or not isAnimating then
                StopAnimTask(PlayerPedId(), dict, anim, 1.0)
                return
            end
        end
    end)
end

-- Edited function from qb-mechanicjob
local function AnimWithProp(time, dict, anim, propHash, bone, location)
    CreateThread(function()
        loadAnimDict(dict)
        isAnimating = true

        TaskPlayAnim(PlayerPedId(), dict, anim, 3.0, 3.0, -1, 16, 0, false, false, false)
        local prop = AddPropToPlayer(propHash, bone, location[1], location[2], location[3], location[4], location[5],
            location[6])

        while true do
            TaskPlayAnim(PlayerPedId(), dict, anim, 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Wait(500)
            time = time - 500
            if time <= 0 or not isAnimating then
                StopAnimTask(PlayerPedId(), dict, anim, 1.0)
                DeleteObject(prop)
                return
            end
        end
    end)
end

local function SpawnDeliverables(deliverables)
    for k, v in pairs(deliverables) do
        LoadModel(v.model)
        local object = CreateObject(v.model, v.pickupLocation.x, v.pickupLocation.y, v.pickupLocation.z, true, true,
            false)
        SetEntityHeading(object, v.pickupLocation.w)
        SetEntityInvincible(object, true)
        FreezeEntityPosition(object, true)

        local blip = AddBlipForEntity(object)
        SetBlipScale(blip, Config.BlipScale)
        BeginTextCommandSetBlipName("BLIPNAME_CONSTR")
        AddTextComponentString(v.blipName)
        EndTextCommandSetBlipName(blip)

        exports['qb-target']:AddTargetEntity(object, {
            options = {
                {
                    num = 1,
                    icon = 'fa-solid fa-hand',
                    label = Lang:t("info.interact"),
                    action = function(entity)
                        if not v.RUNTIME_delivered then
                            if not isAttached then
                                if #(GetEntityCoords(entity) - GetEntityCoords(truck)) <= v.pickupDistance then
                                    Anim(v.pickupInteractionTime, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                        "machinic_loop_mechandplayer")
                                    QBCore.Functions.Progressbar('prepare_base_progress_bar' .. k, v.interactionText,
                                        v.pickupInteractionTime, false, true, {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true
                                        }, {}, {}, {}, function()
                                            AttachEntityToEntity(entity, truck,
                                                GetEntityBoneIndexByName(truck, 'frame_pickup_1'),
                                                v.placementOnTruck.x,
                                                v.placementOnTruck.y,
                                                v.placementOnTruck.z,
                                                v.placementOnTruck.xRot,
                                                v.placementOnTruck.yRot,
                                                v.placementOnTruck.zRot, false, false, true, false, 2, true)
                                            RemoveBlip(blip)
                                            isAttached = true
                                            currentSpeedModifier = v.vehiclePowerModifier
                                        end, function() end
                                    )
                                else
                                    QBCore.Functions.Notify(Lang:t('error.out_of_range'), 'error', 5000)
                                end
                            else
                                if loadBox:isPointInside(GetEntityCoords(truck)) then
                                    Anim(v.pickupInteractionTime, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                        "machinic_loop_mechandplayer")
                                    QBCore.Functions.Progressbar('prepare_base_progress_bar' .. k, v.interactionText,
                                        v.pickupInteractionTime, false, true, {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true
                                        }, {}, {}, {}, function()
                                            DetachEntity(entity, false, false)
                                            SetEntityCoords(entity, v.pickupDestination.x, v.pickupDestination.y,
                                                v.pickupDestination.z, false, false, false, true)
                                            SetEntityHeading(entity, v.pickupDestination.w)
                                            SetEntityInvincible(entity, true)
                                            SetModelAsNoLongerNeeded(v.model)
                                            blip = AddBlipForEntity(object)
                                            SetBlipScale(blip, Config.BlipScale)
                                            BeginTextCommandSetBlipName("blip_name_" .. tostring(k))
                                            AddTextComponentString(v.blipName)
                                            EndTextCommandSetBlipName(blip)

                                            isAttached = false
                                            v.RUNTIME_delivered = true
                                            currentSpeedModifier = 1 -- Resets vehicle speed to stock
                                        end, function() end
                                    )
                                else
                                    QBCore.Functions.Notify(Lang:t('error.not_in_range_of_destination'), 'error', 5000)
                                end
                            end
                        else
                            Anim(v.pickupInteractionTime, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                "machinic_loop_mechandplayer")
                            QBCore.Functions.Progressbar('prepare_deliverables_progress_bar' .. k, v.interactionText,
                                v.pickupInteractionTime, false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true
                                }, {}, {}, {}, function()
                                    exports['qb-target']:RemoveTargetEntity(object, 'Do I need this?')
                                    DeleteEntity(entity)
                                    v.RUNTIME_unpacked = true
                                end, function() end
                            )
                        end
                    end,
                }
            },
            distance = 2.5,
        })
    end
end

local function AddWorkbench()
    local workbenchLocation = Config.WorkbenchLocation
    local workbenchModel = Config.WorkbenchModel

    LoadModel(workbenchModel)
    workbench = CreateObject(workbenchModel, workbenchLocation.x, workbenchLocation.y, workbenchLocation.z, false, true,
        false)
    SetEntityHeading(workbench, workbenchLocation.w)

    exports['qb-target']:AddTargetEntity(workbench, {
        options = {
            {
                num = 1,
                icon = 'fa-solid fa-hammer',
                label = Lang:t("info.craft"),
                action = function(entity)
                    local craftables = {}

                    craftables[#craftables + 1] = {
                        isMenuHeader = true,
                        header = Lang:t("info.construction_sites_header"),
                        icon = nil
                    }

                    for k, v in pairs(Config.Items) do
                        craftables[#craftables + 1] = {
                            header = v.label,
                            txt = GenerateItemRequirementsString(k),
                            icon = 'fa-solid fa-hammer',
                            params = {
                                event = 'hiype-construction:client:craft-menu-return',
                                args = {
                                    name = k,
                                    value = v
                                }
                            }
                        }
                    end

                    exports['qb-menu']:openMenu(craftables)
                end
            },
        },
        distance = 2.5,
    })
end

local function StopBuild()
    isBuildActive = false
    RemoveAllIPLs()
end

local function StartBuild(pJobKey, pJobValue)
    CreateThread(function()
        titleText = Lang:t("info.preparation_work")
        subText = Lang:t("info.deliver_deliverables")

        isBuildActive = true
        QBCore.Functions.Notify(Lang:t("info.build_location_marked"), 'primary', 5000)
        AddBlipCoord(pJobValue.pickupDropoff, pJobValue.locationName)
        SpawnDeliverables(pJobValue.deliverables)

        loadBox = BoxZone:Create(pJobValue.pickupDropoff, 30.0, 30.0, {
            name = "hiype-construction:load-box",
            heading = 0,
            debugPoly = Config.PolyzoneDebug,
            minZ = 0.0,
            maxZ = 1000.0,
        })

        if not IsPlayerJobLabelCorrect() then return end

        while not AllDeliverablesDelivered(pJobValue.deliverables) do
            Wait(2000)
        end

        loadBox:destroy()
        RemoveBlip(blip)

        local currentStage = 1
        local stagesCount = CountTableElements(pJobValue.workStages)

        for index, v in ipairs(pJobValue.workStages) do
            local stageComplete = false
            local counter = 0

            titleText = v.name
            subText = GenerateSubText(v)

            if not IsScreenFadedOut() then
                DoScreenFadeOut(2000)

                while not IsScreenFadedOut() do
                    Wait(100)
                end
            end

            SetEntityCoords(PlayerPedId(), v.transitionLocation.x, v.transitionLocation.y, v.transitionLocation.z, false,
                false, false, false)
            SetEntityHeading(PlayerPedId(), v.transitionLocation.w)

            if v.ipl ~= nil then
                RequestIpl(v.ipl)
            end

            Wait(500)
            DoScreenFadeIn(2000)

            if v.locations ~= nil then
                for i, location in ipairs(v.locations) do
                    LoadModel(location.model)

                    local object = CreateObject(location.model, location.coord.x, location.coord.y, location.coord.z,
                        false, true, false)
                    exports['qb-target']:AddTargetEntity(object, {
                        options = {
                            {
                                num = 1,
                                icon = v.interactionIcon,
                                label = v.interactionText,
                                action = function(entity)
                                    if v.requirements ~= nil then
                                        if PlayerHasAllItems(v.requirements) then
                                            Anim(v.interactionTime, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                                "machinic_loop_mechandplayer")
                                            QBCore.Functions.Progressbar('prepare_base_progress_bar' .. i,
                                                v.interactionSubText, v.interactionTime, false, true, {
                                                    disableMovement = true,
                                                    disableCarMovement = true,
                                                    disableMouse = false,
                                                    disableCombat = true
                                                }, {}, {}, {}, function()
                                                    RemoveAllItems(v.requirements)
                                                    DeleteEntity(entity)
                                                    counter += 1

                                                    if counter >= #v.locations then
                                                        stageComplete = true
                                                        if currentStage >= stagesCount then
                                                            QBCore.Functions.Notify(Lang:t('info.job_done'), 'success',
                                                                5000)
                                                            isBuildActive = false
                                                            TriggerServerEvent('hiype-construction:server:add-money',
                                                                pJobValue.reward, pJobValue.rewardType)
                                                            DeleteDeliverables()
                                                        end
                                                    end
                                                end, function() end
                                            )
                                        else
                                            QBCore.Functions.Notify(Lang:t("error.not_all_items_in_inventory"), 'error',
                                                5000)
                                        end
                                    else
                                        Anim(v.interactionTime, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                            "machinic_loop_mechandplayer")
                                        QBCore.Functions.Progressbar('prepare_base_progress_bar' .. i,
                                            v.interactionSubText, v.interactionTime, false, true, {
                                                disableMovement = true,
                                                disableCarMovement = true,
                                                disableMouse = false,
                                                disableCombat = true
                                            }, {}, {}, {}, function()
                                                DeleteEntity(entity)
                                                counter += 1

                                                if counter >= #v.locations then
                                                    stageComplete = true
                                                    if currentStage >= stagesCount then
                                                        QBCore.Functions.Notify(Lang:t('info.job_done'), 'success', 5000)
                                                        isBuildActive = false
                                                        TriggerServerEvent('hiype-construction:server:add-money',
                                                            pJobValue.reward, pJobValue.rewardType)
                                                        DeleteDeliverables()
                                                    end
                                                end
                                            end, function() end
                                        )
                                    end
                                end
                            },
                        },
                        distance = 2.5,
                    })
                end
            else
                local iBox = v.interactionBox
                local interactionCounter = 0

                exports['qb-target']:AddBoxZone("hiype-construction:target:stage-construction",
                    vector3(iBox.location.x, iBox.location.y, iBox.location.z), iBox.length, iBox.width, {
                        name = "hiype-construction:target:stage-construction",
                        heading = iBox.heading,
                        debugPoly = Config.PolyzoneDebug,
                        minZ = iBox.minZ,
                        maxZ = iBox.maxZ,
                    }, {
                        options = {
                            {
                                icon = v.interactionIcon,
                                label = v.interactionText,
                                action = function(entity)
                                    if not PlayerHasAllItems(v.interactionItem) then
                                        QBCore.Functions.Notify(Lang:t("error.not_all_items_in_inventory"), 'error',
                                            5000)
                                        return
                                    end

                                    Anim(v.interactionTime, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                        "machinic_loop_mechandplayer")
                                    QBCore.Functions.Progressbar('stage_progress_bar', v.interactionSubText,
                                        v.interactionTime, false, true, {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true
                                        }, {}, {}, {}, function()
                                            interactionCounter = interactionCounter + 1
                                            if interactionCounter >= v.interactionCount then
                                                stageComplete = true
                                                exports['qb-target']:RemoveZone(
                                                    "hiype-construction:target:stage-construction")

                                                if currentStage >= stagesCount then
                                                    QBCore.Functions.Notify(Lang:t('info.job_done'), 'success', 5000)
                                                    isBuildActive = false
                                                    TriggerServerEvent('hiype-construction:server:add-money',
                                                        pJobValue.reward,
                                                        pJobValue.rewardType)
                                                    DeleteDeliverables()
                                                end
                                            end
                                            RemoveItem(v.interactionItem)
                                        end, function() end
                                    )
                                end
                            }
                        },
                        distance = 2.5,
                    }
                )
            end

            while not stageComplete do
                Wait(1000)
            end

            if v.unpackDeliverables ~= nil and v.unpackDeliverables then
                while not AllDeliverablesUnpacked(pJobValue.deliverables) do
                    Wait(1000)
                end
            end

            if isBuildActive then
                DoScreenFadeOut(2000)

                while not IsScreenFadedOut() do
                    Wait(100)
                end

                if v.ipl ~= nil then
                    RemoveIpl(v.ipl)
                end
            end

            currentStage = currentStage + 1
        end
    end)
end

local function InitializeNPC()
    local location = Config.NPCLocation
    local model = Config.NPCModel

    LoadModel(model)

    npc = CreatePed(0, model, location.x, location.y, location.z, location.w, false, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CLIPBOARD", 0, true)
    FreezeEntityPosition(npc, true)

    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                num = 1,
                icon = 'fa-solid fa-pen',
                label = Lang:t("info.signup"),
                action = function(entity)
                    if IsPlayerJobLabelCorrect() then
                        QBCore.Functions.Notify(Lang:t("error.already_active"), 'error', 4000)
                        return
                    end

                    for k, _ in pairs(Config.Job) do
                        AnimWithProp(Config.ContractSignTime, "missfam4", "base", 'p_amb_clipboard_01', 36029,
                            { 0.16, 0.08, 0.1, -130.0, -50.0, 0.0 })
                        QBCore.Functions.Progressbar('singup_job_progress_bar', Lang:t('info.signing_job_documents'),
                            Config.ContractSignTime, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true
                            }, {}, {}, {}, function()
                                TriggerServerEvent('hiype-construction:server:set-job', k, 0)
                            end, function() end
                        )
                        break
                    end
                end
            },
            {
                num = 2,
                icon = 'fa-solid fa-pen',
                label = Lang:t("info.signout"),
                action = function(entity)
                    if not IsPlayerJobLabelCorrect() then
                        QBCore.Functions.Notify(Lang:t("error.not_active"), 'error', 4000)
                        return
                    end

                    TriggerServerEvent('hiype-construction:server:set-job', 'unemployed', 0)
                end
            },
            {
                num = 3,
                icon = 'fa-solid fa-pen',
                label = Lang:t("info.request_build"),
                action = function(entity)
                    if not IsPlayerJobLabelCorrect() then
                        QBCore.Functions.Notify(Lang:t("error.not_active"), 'error', 4000)
                        return
                    end

                    if isBuildActive then
                        QBCore.Functions.Notify(Lang:t("error.you_have_an_active_build"), 'error', 4000)
                        return
                    end

                    local constructionSites = {}

                    constructionSites[#constructionSites + 1] = {
                        isMenuHeader = true,
                        header = Lang:t("info.construction_sites_header"),
                        icon = nil
                    }

                    for k, v in pairs(Config.ConstructionSites) do
                        constructionSites[#constructionSites + 1] = {
                            header = v.locationName,
                            txt = v.listingText,
                            icon = v.listingIcon,
                            params = {
                                event = 'hiype-construction:client:construction-menu-return',
                                args = {
                                    name = k,
                                    value = v
                                }
                            }
                        }
                    end

                    exports['qb-menu']:openMenu(constructionSites)
                end
            },
            {
                num = 4,
                icon = 'fa-solid fa-xmark',
                label = Lang:t("info.cancel_build"),
                action = function(entity)
                    if not isBuildActive then
                        QBCore.Functions.Notify(Lang:t("error.no_active_build"), 'error', 4000)
                        return
                    end

                    StopBuild()
                end,
                job = 'construction'
            },
            {
                num = 5,
                icon = 'fa-solid fa-truck',
                label = Lang:t("info.rent_truck"),
                action = function(entity)
                    if IsVehicleDriveable(truck, false) and truck ~= nil then
                        local vehicleLocation = GetEntityCoords(truck)

                        QBCore.Functions.Notify(Lang:t("error.truck_already_rented_set_waypoint"), 'error', 5000)
                        SetNewWaypoint(vehicleLocation.x, vehicleLocation.y)

                        return
                    end

                    AnimWithProp(Config.DeliveryTruck.SignTime, "missfam4", "base", 'p_amb_clipboard_01', 36029,
                        { 0.16, 0.08, 0.1, -130.0, -50.0, 0.0 })
                    QBCore.Functions.Progressbar('rent_truck_progress_bar', 'Signing rent documents',
                        Config.DeliveryTruck.SignTime, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }, {}, {}, {}, function()
                            QBCore.Functions.SpawnVehicle(Config.DeliveryTruck.Model, function(veh)
                                truck = veh
                                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(truck))
                                TriggerServerEvent("hiype-construction:server:add-money",
                                    Config.DeliveryTruck.RentPrice * -1,
                                    Config.DeliveryTruck.RentPriceType)
                            end, Config.DeliveryTruck.SpawnLocation, true)
                        end, function() end
                    )
                end,
                job = 'construction'
            },
            {
                num = 6,
                icon = 'fa-solid fa-truck',
                label = Lang:t("info.return_truck"),
                action = function(entity)
                    if #(GetEntityCoords(entity) - GetEntityCoords(truck)) > Config.DeliveryTruck.RentReturnDistance then
                        QBCore.Functions.Notify(Lang:t("error.truck_not_close_enough"), 'error', 5000)
                        return
                    end

                    QBCore.Functions.DeleteVehicle(truck)
                    TriggerServerEvent("hiype-construction:server:add-money", Config.DeliveryTruck.RentReturn,
                        Config.DeliveryTruck.RentReturnPriceType)
                end,
                job = 'construction'
            }
        },
        distance = 2.5,
    })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LocalPlayer.state:set('isLoggedIn', true, false)
    InitializeNPC()
    CreateThread(function()
        Wait(50)
        RemoveAllIPLs()
    end)
    AddWorkbench()
end)


RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    StopBuild()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    -- TODO: Remove after development
    InitializeNPC()
    CreateThread(function()
        Wait(50)
        RemoveAllIPLs()
    end)
    AddWorkbench()
end)

RegisterNetEvent('hiype-construction:client:craft-menu-return', function(data)
    if not PlayerHasAllItemsCraft(data.name) then
        QBCore.Functions.Notify(Lang:t("error.not_all_items_in_inventory"), 'error', 5000)
        return
    end

    Anim(Config.ContractSignTime, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer")
    QBCore.Functions.Progressbar('join_construction_progress_bar', Lang:t("info.crafting"), Config.ContractSignTime,
        false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        }, {}, {}, {}, function()
            RemoveAllItems(Config.ItemRequirements[data.name])
            TriggerServerEvent('hiype-construction:server:addItem', data.name, 1)
        end, function() end
    )
end)

RegisterNetEvent('hiype-construction:client:construction-menu-return', function(data)
    AnimWithProp(Config.ContractSignTime, "missfam4", "base", 'p_amb_clipboard_01', 36029,
        { 0.16, 0.08, 0.1, -130.0, -50.0, 0.0 })
    QBCore.Functions.Progressbar('join_construction_progress_bar', Lang:t("info.signing_contract"),
        Config.ContractSignTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        }, {}, {}, {}, function()
            StartBuild(data.name, data.value)
        end, function() end
    )
end)

-- Every frame actions
CreateThread(function()
    local vehicleAffected = Config.IsVehicleAffectedByCargo
    while true do
        while isBuildActive do
            Draw2DText(0.9, 0.2, titleText, 0.50, 225, 0, 0, 255) -- Title
            Draw2DText(0.9, 0.25, subText, 0.40, 255, 255, 255, 255)  -- Sub text

            if vehicleAffected and isAttached then
                if GetVehiclePedIsIn(PlayerPedId(), false) == truck then
                    SetVehicleCheatPowerIncrease(truck, currentSpeedModifier)
                end
            end

            Wait(1)
        end

        Wait(4000)
    end
end)
