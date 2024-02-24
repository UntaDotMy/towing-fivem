local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('deployramp', function ()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)

    if vehicle ~= 0 then
        local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

        drawNotification("Trying to deploy a ramp for: " .. vehicleName)

        -- Check if player has the allowed job
        if IsPlayerAllowedJob() then
            if contains(vehicleName, Config.whitelist) then
                local vehicleCoords = GetEntityCoords(vehicle)

                for _, value in pairs(Config.offsets) do
                    if vehicleName == value.model then
                        local ramp = CreateObject(RampHash, vector3(value.offset.x, value.offset.y, value.offset.z), true, false, false)
                        AttachEntityToEntity(ramp, vehicle, GetEntityBoneIndexByName(vehicle, 'chassis'), value.offset.x, value.offset.y, value.offset.z , 180.0, 180.0, 0.0, 0, 0, 1, 0, 0, 1)
                    end
                end

                drawNotification("Ramp has been deployed.")
                return
            end
            drawNotification("You can't deploy a ramp for this vehicle.")
            return
        else
            drawNotification("You don't have permission to use this command.")
        end
    else
        drawNotification("You're not in a vehicle.")
    end
end)

RegisterCommand('ramprm', function()
    if IsPlayerAllowedJob() then
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)

        local object = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, RampHash, false, 0, 0)

        if DoesEntityExist(object) then
            DeleteObject(object)
            drawNotification("Ramp removed successfully.")
            return
        else
            drawNotification("No ramp found nearby.")
            return
        end
    else
        drawNotification("You don't have permission to use this command.")
    end
end)

RegisterCommand('attach', function()
    if IsPlayerAllowedJob() then
        local player = PlayerPedId()
        local vehicle = nil

        if IsPedInAnyVehicle(player, false) then
            vehicle = GetVehiclePedIsIn(player, false)
            if GetPedInVehicleSeat(vehicle, -1) == player then
                local vehicleCoords = GetEntityCoords(vehicle)
                local vehicleOffset = GetOffsetFromEntityInWorldCoords(vehicle, 1.0, 0.0, -1.5)
                local vehicleRotation = GetEntityRotation(vehicle, 2)
                local belowEntity = GetVehicleBelowMe(vehicleCoords, vehicleOffset)
                local vehicleBelowRotation = GetEntityRotation(belowEntity, 2)
                local vehicleBelowName = GetDisplayNameFromVehicleModel(GetEntityModel(belowEntity))

                local vehiclesOffset = GetOffsetFromEntityGivenWorldCoords(belowEntity, vehicleCoords)

                local vehiclePitch = vehicleRotation.x - vehicleBelowRotation.x
                local vehicleYaw = vehicleRotation.z - vehicleBelowRotation.z

                if contains(vehicleBelowName, Config.whitelist) then
                    if not IsEntityAttached(vehicle) then
                        AttachEntityToEntity(vehicle, belowEntity, GetEntityBoneIndexByName(belowEntity, 'chassis'), vehiclesOffset, vehiclePitch, 0.0, vehicleYaw, false, false, true, false, 0, true)
                        return drawNotification('Vehicle attached properly.')
                    end
                    return drawNotification('Vehicle already attached.')
                end
                return drawNotification('Can\'t attach to this entity: ' .. vehicleBelowName)
            end
            return drawNotification('Not in driver seat.')
        end
        drawNotification('You\'re not in a vehicle.')
    else
        drawNotification("You don't have permission to use this command.")
    end
end)

RegisterCommand('detach', function()
    if IsPlayerAllowedJob() then
        local player = PlayerPedId()
        local vehicle = nil

        if IsPedInAnyVehicle(player, false) then
            vehicle = GetVehiclePedIsIn(player, false)
            if GetPedInVehicleSeat(vehicle, -1) == player then
                if IsEntityAttached(vehicle) then
                    DetachEntity(vehicle, false, true)
                    return drawNotification('The vehicle has been successfully detached.')
                else
                    return drawNotification('The vehicle isn\'t attached to anything.')
                end
            else
                return drawNotification('You are not in the driver seat.')
            end
        else
            return drawNotification('You are not in a vehicle.')
        end
    else
        drawNotification("You don't have permission to use this command.")
    end
end)

function IsPlayerAllowedJob()
    local jobName = QBCore.Functions.GetPlayerData().job.name
    for _, allowedJob in ipairs(Config.allowedJob) do
        if jobName == allowedJob then
            return true
        end
    end
    return false
end

function getClosestVehicle(coords)
    local ped = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end

function GetVehicleBelowMe(cFrom, cTo)
    local rayHandle = CastRayPointToPoint(cFrom.x, cFrom.y, cFrom.z, cTo.x, cTo.y, cTo.z, 10, PlayerPedId(), 0)
    local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end

function contains(item, list)
    for _, value in ipairs(list) do
        if value == item then return true end
    end
    return false
end

function drawNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, false)
end
