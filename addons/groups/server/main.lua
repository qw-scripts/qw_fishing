local FishingGroups = {}

RegisterNetEvent('qw_fishing:groups:startGroupFishing', function()
    local src = source
    local group = exports['qb-phone']:GetGroupByMembers(src)
    if not group then
        TriggerClientEvent('ox_lib:notify', src,
            { type = 'error', description = 'you are not in a group!' })
        return
    end

    if FishingGroups[group] then -- TODO: re-write this into a different event and just add/remove target option based on whether or not they are in a group
        exports['qb-phone']:resetJobStatus(group)
        FishingGroups[group] = nil
        exports['qb-phone']:pNotifyGroup(group, 'Fishing',
            "All done. Hope you enjoyed the fishing!",
            'fa fa-fish',
            '#03adfc', 5000)
        return
    end

    FishingGroups[group] = {
        totalCaught = 0,
    }

    local FishTable = {
        { name = "Catch Fish (0/" .. Config.TotalFishToCatchForGroup .. ")", isDone = false, id = 1 },
    }

    exports['qb-phone']:setJobStatus(group, "Fishing", FishTable)
    exports['qb-phone']:pNotifyGroup(group, 'Fishing', 'Make your way to a legal fishing zone.', 'fa fa-fish',
        '#03adfc', 15000)
end)

RegisterNetEvent('qw_fishing:groups:bumpFishingTask', function(group)
    if not group then
        print('no group', group)
        return
    end

    if not FishingGroups[group] then
        print('no active fishing group')
        return
    end

    FishingGroups[group].totalCaught = FishingGroups[group].totalCaught + 1

    if FishingGroups[group].totalCaught >= Config.TotalFishToCatchForGroup then
        exports['qb-phone']:resetJobStatus(group)
        FishingGroups[group] = nil
        exports['qb-phone']:pNotifyGroup(group, 'Fishing',
            "All done. Hope you enjoyed the fishing!",
            'fa fa-fish',
            '#03adfc', 5000)
        return
    end


    local FishTable = {
        { name = "Catch Fish (" .. FishingGroups[group].totalCaught .. "/" .. Config.TotalFishToCatchForGroup .. ")", isDone = false, id = 1 },
    }

    exports['qb-phone']:setJobStatus(group, "Fishing", FishTable)
    exports['qb-phone']:pNotifyGroup(group, 'Fishing',
        "(" .. FishingGroups[group].totalCaught .. "/" .. Config.TotalFishToCatchForGroup .. ") fish caught.",
        'fa fa-fish',
        '#03adfc', 15000)
end)

AddEventHandler('qb-phone:server:GroupDeleted', function(group)
    if FishingGroups[group] then
        FishingGroups[group] = nil
    end
end)
