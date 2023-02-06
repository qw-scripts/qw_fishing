-- MAKE SURE TO SET THE LOCATION OF THE SHOP TO THE SAME LOCATION YOU HAVE THE PED SPAWNING AT
Fishing = {
    name = 'Fishing',
    blip = {
        id = 210, colour = 69, scale = 0.8
    }, inventory = {
        { name = 'bucket', price = 150, metadata = { bait = 10 } },
        { name = 'fishingrod', price = 100, metadata = { durability = 100 } }
    }, locations = {
        vec3(-1694.65, -1057.43, 13.02 - 1)
    }, targets = {
        { loc = vec3(-1694.65, -1057.43, 13.02 - 1), length = 0.6, width = 3.0, heading = 51.19, minZ = 12.0, maxZ = 13.8,
            distance = 3.0 }
    }
}
