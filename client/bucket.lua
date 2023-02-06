IsPlacingPreview = false
local previewedObject = nil

RegisterNetEvent('qw_fishing:client:pickupBucket', function(data)
    exports.ox_target:removeEntity(data.netId, { ("baitbucket:%s"):format(data.netId) })
    exports.ox_target:removeEntity(data.netId, { ("getbait:%s"):format(data.netId) })
    if lib.progressBar({ duration = 2000, label = 'Picking Up', useWhileDead = false, canCancel = true,
        disable = { car = true } }) then
        TriggerServerEvent('qw_fishing:server:pickupBaitBucket', { netId = data.netId })
    end
end)

RegisterNetEvent('qw_fishing:client:grabBait', function(data)
    if lib.progressBar({ duration = 2000, label = 'Grabbing Bait', useWhileDead = false, canCancel = true,
        disable = { car = true } }) then
        TriggerServerEvent('qw_fishing:server:grabBaitFromBucket', { netId = data.netId })
    end
end)

function CancelPlacement()
    IsPlacingPreview = false
    DeleteObject(previewedObject)
    previewedObject = nil
    lib.hideTextUI()
end

function PlaceSpawnedObject(coords, object, slot, bait)
    LocalPlayer.state.invHotkeys = false
    lib.hideTextUI()
    if lib.progressCircle({ duration = 2000, position = 'bottom', useWhileDead = false, canCancel = true,
        disable = { car = true } }) then
        FreezeEntityPosition(previewedObject, true)
        IsPlacingPreview = false

        TriggerServerEvent('qw_fishing:server:spawnNewBucket', coords, object, slot, bait)

        DeleteObject(previewedObject)

        previewedObject = nil
        HasAlreadyPlacedTable = true
        LocalPlayer.state.invHotkeys = true
    else
        CancelPlacement()
        LocalPlayer.state.invHotkeys = true
    end

end

function CreatePreviewedObject(model, hasDistanceCheck, slot, bait)

    IsPlacingPreview = true
    lib.requestModel(model)

    previewedObject = CreateObject(model, GetEntityCoords(cache.ped), true, true, false)

    SetEntityAlpha(previewedObject, 150, false)
    SetEntityCollision(previewedObject, false, false)
    FreezeEntityPosition(previewedObject, true)

    while IsPlacingPreview do
        lib.showTextUI('[E] - Place Bucket \n [Q] - Cancel')

        local hit, _, coords, _, _ = lib.raycast.cam(1, 4)

        if hit then
            SetEntityCoords(previewedObject, coords.x, coords.y, coords.z)
            PlaceObjectOnGroundProperly(previewedObject)
            local distanceCheck = #(coords - GetEntityCoords(cache.ped))

            if IsControlJustPressed(0, 44) then CancelPlacement() end

            if IsControlJustPressed(0, 38) then
                if not hasDistanceCheck then
                    PlaceSpawnedObject(coords, model, slot, bait)
                    return
                end

                if distanceCheck < 2.5 then
                    PlaceSpawnedObject(coords, model, slot, bait)
                else
                    lib.notify({
                        title = 'Placement',
                        description = 'you may not place this object here...',
                        style = {
                            backgroundColor = '#141517',
                            color = '#909296'
                        },
                        icon = 'xmark',
                        iconColor = 'red',
                    })
                end
            end
        end

        Wait(1)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CancelPlacement()
    end
end)
