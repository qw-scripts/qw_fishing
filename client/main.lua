local FullyLoaded = LocalPlayer.state.isLoggedIn

local pedSpawned = false
local spawnedPed = nil

local sellPedSpawned = false
local spawnedSellPed = nil

local inZone = false
local PZones = {}

local isFishing = false

local function reelInFish(slot, durability)
    local fish = Config.FishingLoot[math.random(1, #Config.FishingLoot)]
    local chanceToCatch = math.random(1, 100)

    if fish.chance > chanceToCatch then
        lib.notify({
            description = 'got a little nibble...',
            type = 'success'
        })
        Wait(1000)
        local success = lib.skillCheck(fish['skillcheck'])
        if success then
            lib.notify({
                title = 'Fishing',
                description = 'You caught a ' .. fish.name .. '!',
                type = 'success'
            })
            TriggerServerEvent('qw_fishing:server:giveFish', fish, slot, durability)
            exports.scully_emotemenu:CancelAnimation()
            isFishing = false
        else
            lib.notify({
                title = 'Fishing',
                description = 'You lost the fish!',
                type = 'error'
            })
        end
    end
end

local function startFishing(slot, durability)

    if isFishing then return end
    local baitAmount = exports.ox_inventory:Search('count', 'fishbait')

    if baitAmount < 1 then
        lib.notify({
            title = 'Fishing',
            description = 'You don\'t have any bait!',
            type = 'error'
        })
        return
    end

    exports.scully_emotemenu:PlayByCommand('fishing2')

    isFishing = true

    local seconds = 0
    CreateThread(function()
        while isFishing do
            Wait(5000)
            seconds = seconds + 5
            local chance = math.random() * 100
            if chance + seconds > 100 then
                reelInFish(slot, durability)
            end
        end
    end)

end

RegisterNetEvent('qw_fishing:client:Fish', function(slot, durability)
    if not inZone then
        lib.notify({
            title = 'Fishing',
            description = 'Looks like you can\'t fish here...',
            type = 'error'
        })
        return
    end

    startFishing(slot, durability)
end)

RegisterNetEvent('qw_fishing:client:placeBaitBucket', function(slot, bait)
    if IsPlacingPreview then return end
    CreatePreviewedObject(Config.BaitBucketProp, true, slot, bait)
end)

RegisterNetEvent('qw_fishing:client:sellFish', function()
    local fishCount = 0
    for i = 1, #Config.FishingLoot do
        local fish = Config.FishingLoot[i]
        local fishAmount = exports.ox_inventory:Search('count', fish.name)
        fishCount = fishCount + fishAmount
    end

    if fishCount > 0 then
        TriggerServerEvent('qw_fishing:server:sellFish')
    else
        lib.notify({
            title = 'Fishing',
            description = 'You don\'t have any fish to sell!',
            type = 'error'
        })
    end
end)

RegisterNetEvent('qw_fishing:client:fillBaitBucket', function()
    local bucketAmount = exports.ox_inventory:Search('count', 'bucket')
    if bucketAmount < 1 then
        lib.notify({
            title = 'Fishing',
            description = 'You don\'t have any buckets!',
            type = 'error'
        })
    end

    local askToFill = lib.alertDialog({
        header = 'Fishing',
        content = 'Are you sure you want to fill your buckets with bait? \n This will cost $' ..
            Config.BaitPrice * bucketAmount .. '!',
        centered = true,
        cancel = true,
        labels = {
            cancel = 'No',
            confirm = 'Purchase'
        }
    })

    if askToFill == 'confirm' then
        TriggerServerEvent('qw_fishing:server:fillBaitBucket', Config.BaitPrice * bucketAmount)
    end
end)

local function createFishingZones()
    for i = 1, #Config.FishingPoints do
        local zone = Config.FishingPoints[i]

        PZones[#PZones + 1] = lib.zones.poly({
            points = zone,
            thickness = 2,
            debug = Config.Debug,
            inside = function()
                inZone = true
            end,
            onEnter = function()
                inZone = true
            end,
            onExit = function()
                inZone = false
                exports.scully_emotemenu:CancelAnimation()
            end,
        })
    end
end

local function SpawnShopPed()

    if pedSpawned then return end
    local model = joaat(Config.ShopPed.model)

    lib.requestModel(model)

    local coords = Config.ShopPed.coords
    local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1, coords.w, false, false)

    spawnedPed = ped

    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    pedSpawned = true
end

local function SpawnSellPed()
    if sellPedSpawned then return end

    local model = joaat(Config.SellPed.model)

    lib.requestModel(model)

    local coords = Config.SellPed.coords
    local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1, coords.w, false, false)

    spawnedSellPed = ped

    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(spawnedSellPed, {
        {
            name = 'fishing:sellfish',
            label = 'Sell Fish',
            icon = 'fa-solid fa-fish',
            event = 'qw_fishing:client:sellFish',
            canInteract = function(_, distance)
                return distance < 2.0
            end
        },
        {
            name = 'fishing:fillbaitbucket',
            label = 'Fill Bait Bucket',
            icon = 'fa-solid fa-fish',
            event = 'qw_fishing:client:fillBaitBucket',
            canInteract = function(_, distance)
                return distance < 2.0
            end
        }
    })

    sellPedSpawned = true
end

local function deletePeds()
    if not pedSpawned and not sellPedSpawned then return end
    DeleteEntity(spawnedPed)
    DeleteEntity(spawnedSellPed)
    spawnedPed = nil
    pedSpawned = false
    spawnedSellPed = nil
    sellPedSpawned = false
end

local function removePolyZone()
    if PZones == nil then return end

    for i = 1, #PZones do
        PZones[i]:remove()
    end
end

AddStateBagChangeHandler('isBaitBucket', nil, function(bagName, _, value)
    local ent = GetEntityFromStateBagName(bagName)
    if ent == 0 or not value then return end

    local entNetId = ObjToNet(ent)

    local options = {
        {
            name = ("baitbucket:%s"):format(entNetId),
            event = 'qw_fishing:client:pickupBucket',
            icon = 'fa-solid fa-hand',
            netId = entNetId,
            label = 'Pickup Bait Bucket',
            canInteract = function(_, distance)
                return distance < 2.0
            end
        },
        {
            name = ("getbait:%s"):format(entNetId),
            event = 'qw_fishing:client:grabBait',
            icon = 'fa-solid fa-hand',
            netId = entNetId,
            label = 'Grab Some Bait',
            canInteract = function(_, distance)
                return distance < 2.0
            end
        }
    }

    exports.ox_target:addEntity(entNetId, options)
end)

exports.ox_inventory:displayMetadata('bait', 'Bait')
exports.ox_inventory:displayMetadata('fish_quality', 'Quality')

AddStateBagChangeHandler('isLoggedIn', nil, function(_, _, value)
    FullyLoaded = value
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(100)
    SpawnShopPed()
    SpawnSellPed()
    createFishingZones()
    exports.ox_inventory:displayMetadata('bait', 'Bait')
    exports.ox_inventory:displayMetadata('fish_quality', 'Quality')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deletePeds()
    removePolyZone()
end)


AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if not FullyLoaded then return end
    Wait(100)
    SpawnShopPed()
    SpawnSellPed()
    createFishingZones()
    exports.ox_inventory:displayMetadata('bait', 'Bait')
    exports.ox_inventory:displayMetadata('fish_quality', 'Quality')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    deletePeds()
    removePolyZone()
end)
