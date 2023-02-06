Item('fishingrod', function(data, slot)
    ox_inventory:useItem(data, function(data)
        if data then
            if data.metadata.durability <= 0 then
                lib.notify({
                    description = 'Your fishing rod is broken',
                    type = 'error'
                })
                return
            end
            TriggerEvent('qw_fishing:client:Fish', data.slot, data.metadata.durability)
        end
    end)
end)

Item('bucket', function(data, slot)
    ox_inventory:useItem(data, function(data)
        if data then
            TriggerEvent('qw_fishing:client:placeBaitBucket', data.slot, data.metadata.bait)
        end
    end)
end)
