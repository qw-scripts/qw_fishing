local spawnedInBuckets = {}

RegisterNetEvent('qw_fishing:server:pickupBaitBucket', function(data)
    local src = source
    local ped = GetPlayerPed(src)

    local netId = data.netId
    local ent = NetworkGetEntityFromNetworkId(netId)


    if ent == 0 then return end

    local distanceFromBucket = #(GetEntityCoords(ped) - GetEntityCoords(ent))

    if distanceFromBucket > 2.0 then return end

    exports.ox_inventory:AddItem(src, 'bucket', 1, { ['bait'] = Entity(ent).state['bait'] })
    Wait(200)
    DeleteEntity(ent)

    local tempTable = {}
    for i = 1, #spawnedInBuckets do
        local bucket = spawnedInBuckets[i]
        if bucket ~= netId then
            tempTable[#tempTable + 1] = bucket
        end
    end

    spawnedInBuckets = tempTable
end)

RegisterNetEvent('qw_fishing:server:grabBaitFromBucket', function(data)
    local src = source
    local ped = GetPlayerPed(src)

    local netId = data.netId
    local ent = NetworkGetEntityFromNetworkId(netId)

    if ent == 0 then return end

    local bait = Entity(ent).state['bait']

    if bait <= 0 then return end

    local distanceFromBucket = #(GetEntityCoords(ped) - GetEntityCoords(ent))

    if distanceFromBucket > 2.0 then return end

    Entity(ent).state['bait'] = bait - 1

    exports.ox_inventory:AddItem(src, 'fishbait', 1)
end)

RegisterNetEvent('qw_fishing:server:spawnNewBucket', function(coords, object, slot, bait)
    local src = source
    local ped = GetPlayerPed(src)

    local distanceFromBucket = #(GetEntityCoords(ped) - coords)

    if distanceFromBucket > 2.0 then return end

    local obj = CreateObjectNoOffset(object, coords.x, coords.y, coords.z, true, false, false)

    local bucketBaitAmount = bait

    FreezeEntityPosition(obj, true)

    Entity(obj).state['bait'] = bucketBaitAmount
    Entity(obj).state['isBaitBucket'] = true

    local netId = NetworkGetNetworkIdFromEntity(obj)

    spawnedInBuckets[#spawnedInBuckets + 1] = netId
    exports.ox_inventory:RemoveItem(src, 'bucket', 1, _, slot)
end)

RegisterNetEvent('qw_fishing:server:giveFish', function(fish, slot, durability)

    local src = source
    local quality = math.ceil(math.random() * 100)
    local qualIndentifier = nil

    for i = 1, #Config.FishQualityIdentifiers do
        if quality >= Config.FishQualityIdentifiers[i].min and quality <= Config.FishQualityIdentifiers[i].max then
            qualIndentifier = Config.FishQualityIdentifiers[i].label
        end
    end

    if exports.ox_inventory:CanCarryItem(src, fish.name, 1) then
        exports.ox_inventory:AddItem(src, fish.name, 1, { ['fish_quality'] = qualIndentifier })
        exports.ox_inventory:RemoveItem(src, 'fishbait', 1)
        exports.ox_inventory:SetDurability(src, slot, durability - Config.RodDegen)
    end
end)

RegisterNetEvent('qw_fishing:server:sellFish', function() -- TODO: re-write this terrible event at some point
    local src = source
    local paymentTotal = 0
    local itemsToRemove = {}

    for i = 1, #Config.FishingLoot do
        local fish = Config.FishingLoot[i]
        for j, k in pairs(fish['quality_payment']) do
            local item = exports.ox_inventory:Search(src, 'count', fish.name, { ['fish_quality'] = j })
            if item ~= 0 then
                local payment = k * item
                paymentTotal = paymentTotal + payment

                itemsToRemove[#itemsToRemove + 1] = { ['name'] = fish.name, ['count'] = item }
            end
        end
    end

    for i = 1, #itemsToRemove do
        local item = itemsToRemove[i]
        exports.ox_inventory:RemoveItem(src, item.name, item.count)
    end

    if paymentTotal > 0 and exports.ox_inventory:AddItem(src, 'money', paymentTotal) then
        TriggerClientEvent('ox_lib:notify', src,
            { type = 'success', description = 'You have made $' .. paymentTotal .. ' in total!' })
    end
end)

RegisterNetEvent('qw_fishing:server:fillBaitBucket', function(moneyToCharge)
    local src = source

    local items = exports.ox_inventory:Search(src, 'slots', 'bucket', { ['bait'] = 0 })

    if #items == 0 then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'You still have some bait left...' })
        return
    end

    if exports.ox_inventory:RemoveItem(src, 'money', moneyToCharge) then
        for i = 1, #items do
            local slot = items[i].slot
            exports.ox_inventory:SetMetadata(src, slot, { ['bait'] = Config.BaitBucketStartingAmount })
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for i = 1, #spawnedInBuckets do
            local netId = spawnedInBuckets[i]
            local ent = NetworkGetEntityFromNetworkId(netId)
            DeleteEntity(ent)
        end
    end
end)
