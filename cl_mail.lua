local QBCore = exports['qb-core']:GetCoreObject()

-- Job
local JobStarted = false
local pay = 0

-- Vehicle
local Vehicle = nil
local VehicleSpawned = false

-- Delivery
local PackageAmountSelected = 0
local PackagesInTruck = 0
local PackagesDelivered = 0
local HasBox = false
local HasSelectedAmountOfPackages = false
local LastLocation = nil

-- Peds
local StartPed = nil

RegisterNetEvent('qb-mail:client:initialize', function()
    QBCore.Functions.LoadModel(Config.StartJobPedModel)
    StartPed = CreatePed(0, Config.StartJobPedModel, Config.StartJobPedSpawn.x, Config.StartJobPedSpawn.y, Config.StartJobPedSpawn.z - 1, Config.StartJobPedSpawn.w, false, false)
    
    StartPedBlip = AddBlipForCoord(Config.StartJobPedSpawn.x, Config.StartJobPedSpawn.y, Config.StartJobPedSpawn.z)
    SetBlipSprite(StartPedBlip, 1)
    SetBlipScale(StartPedBlip, 0.9)
    SetBlipColour(StartPedBlip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mail Job")
    EndTextCommandSetBlipName(StartPedBlip)

    TaskStartScenarioInPlace(StartPed, "WORLD_HUMAN_CLIPBOARD", true)
    FreezeEntityPosition(StartPed, true)
    SetEntityInvincible(StartPed, true)
    SetBlockingOfNonTemporaryEvents(StartPed, true)

    exports['qb-target']:AddTargetEntity(StartPed, {
        options = {
            {
                num = 1,
                icon = "fas fa-circle",
                label = "Start Job",
                canInteract = function()
                    if not JobStarted and not VehicleSpawned then return true end
                    return false
                end,
                action = function()
                    JobStarted = true
                    TriggerEvent("QBCore:Notify", "You have now started a job.  Please select the amount of packages you want to deliver.")
                end,
            },
            {
                num = 2,
                icon = "fas fa-circle",
                label = "Select Amount of Packages",
                canInteract = function()
                    if JobStarted and not HasSelectedAmountOfPackages then return true end
                    return false
                end,
                action = function()
                    TriggerEvent('qb-mail:client:openMenu')
                end,
            },
            {
                num = 4,
                icon = "fas fa-circle",
                label = "Take Out Vehicle",
                canInteract = function()
                    if JobStarted and not VehicleSpawned and HasSelectedAmountOfPackages then return true end
                    return false
                end,
                action = function()
                    if Config.UseDeposit then
                        CheckDeposit()
                    else
                        SpawnVehicle()
                    end
                end,
            },
            {
                num = 5,
                icon = "fas fa-circle",
                label = "Return Vehicle",
                canInteract = function()
                    if VehicleSpawned then return true end
                    return false
                end,
                action = function()
                    if Vehicle and VehicleSpawned then
                        if Config.UseReturnDistance then
                            local pos = GetEntityCoords(PlayerPedId())
                            local vehPos = GetEntityCoords(Vehicle)
                            local dist = #(pos - vehPos)

                            if dist < Config.ReturnDistance then
                                QBCore.Functions.DeleteVehicle(Vehicle)
                                VehicleSpawned = false
                                Vehicle = nil
                                PackagesInTruck = 0
                            else
                                QBCore.Functions.Notify("You are not close enough to the vehicle!", "error")
                            end
                        else
                            QBCore.Functions.DeleteVehicle(Vehicle)
                            VehicleSpawned = false
                            Vehicle = nil
                            PackagesInTruck = 0
                        end
                    end

                    if Config.UseDeposit then
                        TriggerServerEvent('qb-mail:server:returnDeposit')
                    end
                end,
            },
            {
                num = 6,
                icon = "fas fa-circle",
                label = "End Job",
                canInteract = function()
                    if JobStarted and not HasBox then return true end
                    return false
                end,
                action = function()
                    JobStarted = false
                    PackagesInTruck = 0
                    PackagesDelivered = 0
                    PackageAmountSelected = 0
                    HasBox = false
                    HasSelectedAmountOfPackages = false

                    if VehicleSpawned and Vehicle then
                        QBCore.Functions.DeleteVehicle(Vehicle)
                    end

                    Vehicle = nil
                    VehicleSpawned = false
                end,
            },
            {
                num = 3,
                icon = "fas fa-circle",
                label = "Collect A Package",
                canInteract = function()
                    if JobStarted and VehicleSpawned and PackagesInTruck < PackageAmountSelected and not HasBox then return true end
                    return false
                end,
                action = function()
                    CollectPackage()
                end,
            },
        },
        distance = 2.0
    })
end)

function CollectPackage()
    HasBox = true
    TriggerEvent('animations:client:EmoteCommandStart', {"box"})

    exports['qb-target']:AddTargetEntity(Vehicle, {
        options = {
            {
                icon = "fas fa-circle",
                label = "Store Package",
                canInteract = function()
                    if HasBox and HasSelectedAmountOfPackages then return true end
                    return false
                end,
                action = function()
                    StorePackage()
                end,
            }
        }
    })
end

function StorePackage()
    HasBox = false
    PackagesInTruck = PackagesInTruck + 1

    exports['qb-target']:AddTargetEntity(Vehicle, {
        options = {
            {
                icon = "fas fa-circle",
                label = "Retrieve a Package",
                canInteract = function()
                    if PackagesInTruck > 0 and not HasBox then return true end
                    return false
                end,
                action = function()
                    RetrievePackage()
                end,
            },
        },
        distance = 2.0
    })

    if PackagesInTruck < PackageAmountSelected then
        TriggerEvent('QBCore:Notify', "You have another " .. PackageAmountSelected - PackagesInTruck .. " packages left to store.", "success")
    else
        TriggerEvent('QBCore:Notify', "You have stored all " .. PackagesInTruck .. " packages in the truck.", "success")
        TriggerEvent('QBCore:Notify', "Go deliver the packages to the people marked on the map.", "info")
        SpawnDeliveryPed()
    end

    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
end

function RetrievePackage()
    HasBox = true
    PackagesInTruck = PackagesInTruck - 1

    TriggerEvent('animations:client:EmoteCommandStart', {"box"})
end

function CheckDeposit()
    local money = QBCore.Functions.TriggerCallback('qb-mail:server:hasPayment', function(result)
        if result == true then
            SpawnVehicle()
        else
            QBCore.Functions.Notify("You don't have enough money for the deposit!", "error")
        end
    end)
end

function SpawnVehicle()
    local civ = PlayerPedId()
    SetEntityCoords(civ, Config.VehicleSpawnLocation.x, Config.VehicleSpawnLocation.y, Config.VehicleSpawnLocation.z, false, false, false, true)
    SetEntityHeading(civ, Config.VehicleSpawnLocation.w)

    Citizen.Wait(100) -- Give time for the civ to TP before spawning vehicle

    QBCore.Functions.SpawnVehicle(Config.JobVehicleModel, function(veh)
        Vehicle = veh
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(civ, veh, -1)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
    end, Config.VehicleSpawnLocation, true)

    Citizen.Wait(100)

    Citizen.CreateThread(function()
        while true do
            if not DoesEntityExist(Vehicle) then
                Citizen.Wait(100)
            else
                break
            end
        end
    end)

    VehicleSpawned = true
end

function SpawnDeliveryPed()
    local NextLocation = Config.DropOffLocations[math.random(#Config.DropOffLocations)]

    while NextLocation == LastLocation do
        NextLocation = Config.DropOffLocations[math.random(#Config.DropOffLocations)]
    end

    local CurrentModel = Config.PedModels[math.random(#Config.PedModels)]
    QBCore.Functions.LoadModel(CurrentModel)
    DeliverToPed = CreatePed(0, CurrentModel, NextLocation.x, NextLocation.y, NextLocation.z - 1, NextLocation.w, false, false)

    -- Blips
    DropoffBlip = AddBlipForEntity(DeliverToPed)
    SetBlipSprite(DropoffBlip, 1)
    SetBlipColour(DropoffBlip, 2)
    SetBlipScale(DropoffBlip, 0.9)
    SetBlipRoute(DropoffBlip, Config.UseGpsRoute)
    SetBlipRouteColour(DropoffBlip, Config.DropoffBlipColor)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Dropoff Location")
    EndTextCommandSetBlipName(DropoffBlip)

    LastLocation = NextLocation
    
    FreezeEntityPosition(DeliverToPed, true)
    SetEntityInvincible(DeliverToPed, true)
    SetBlockingOfNonTemporaryEvents(DeliverToPed, true)

    exports['qb-target']:AddTargetEntity(DeliverToPed, {
        options = {
            {
                icon = "fas fa-circle",
                label = "Deliver Package",
                canInteract = function()
                    if HasBox and HasSelectedAmountOfPackages then return true end
                    return false
                end,
                action = function()
                    DeliverPackage(DeliverToPed, DropoffBlip)
                end,
            }
        }
    })
end

function DeliverPackage(ped, blip)
    HasBox = false
    PackagesDelivered += 1
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})

    SetPedAsNoLongerNeeded(ped)
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, false)

    RemoveBlip(blip)

    if PackagesInTruck > 0 then
        pay += math.random(Config.MinPayout, Config.MaxPayout)
        TriggerEvent('QBCore:Notify', "Deliver the next package to the next person.", "info")
        SpawnDeliveryPed()
    else
        TriggerServerEvent('qb-mail:server:finishedRoute', pay)

        JobStarted = false
        pay = 0

        PackageAmountSelected = 0
        PackagesInTruck = 0
        PackagesDelivered = 0
        HasBox = false
        HasSelectedAmountOfPackages = false
        LastLocation = nil
    end
end

-- UI

RegisterNUICallback("setPackageAmount", function(data)
    PackageAmountSelected = data.amount
    HasSelectedAmountOfPackages = true
    TriggerEvent('qb-mail:client:closeMenu')
end)

RegisterNUICallback("error", function(data)
    TriggerEvent('QBCore:Notify', data.error, "error")
end)

RegisterNetEvent('qb-mail:client:openMenu', function(value)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "ui",
        display = true
    })
end)

RegisterNetEvent('qb-mail:client:closeMenu', function(value)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "ui",
        display = false
    })
end)

TriggerEvent('qb-mail:client:initialize')
