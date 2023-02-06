Config = {}

Config.Debug = false

Config.ShopPed = {
    model = 's_m_m_ammucountry',
    coords = vec4(-1694.91, -1057.22, 13.02, 227.1)
}


Config.SellPed = {
    model = 's_m_m_ammucountry',
    coords = vec4(-1702.2, -1090.26, 13.15, 35.04)
}

Config.BaitBucketStartingAmount = 10

Config.BaitBucketProp = 'prop_bucket_01a'

Config.RodDegen = math.random(1, 10)

Config.BaitPrice = 30

Config.FishingPoints = {
    [1] = {
        vec(-1742.37, -1103.44, 13.02),
        vec(-1739.87, -1104.72, 13.02),
        vec(-1765.49, -1136.07, 13.02),
        vec(-1767.49, -1133.5, 13.02),
    },
    [2] = {
        vec(-1735.55, -1122.92, 13.02),
        vec(-1737.49, -1121.08, 13.14),
        vec(-1794.03, -1188.39, 13.02),
        vec(-1792.21, -1190.24, 13.02)
    }
}

Config.FishingLoot = {
    [1] = {
        ['name'] = 'catfish',
        ['chance'] = 60,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        },
        ['quality_payment'] = {
            ['Trash'] = 10,
            ['Poor'] = 20,
            ['Good'] = 25,
            ['Great'] = 40,
        }
    },
    [2] = {
        ['name'] = 'largemouthbass',
        ['chance'] = 60,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        },
        ['quality_payment'] = {
            ['Trash'] = 10,
            ['Poor'] = 20,
            ['Good'] = 25,
            ['Great'] = 40,
        }
    },
    [3] = {
        ['name'] = 'redfish',
        ['chance'] = 65,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        },
        ['quality_payment'] = {
            ['Trash'] = 10,
            ['Poor'] = 20,
            ['Good'] = 25,
            ['Great'] = 40,
        }
    },
    [4] = {
        ['name'] = 'salmon',
        ['chance'] = 65,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        },
        ['quality_payment'] = {
            ['Trash'] = 15,
            ['Poor'] = 25,
            ['Good'] = 35,
            ['Great'] = 80,
        }
    },
    [5] = {
        ['name'] = 'stingray',
        ['chance'] = 35,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        },
        ['quality_payment'] = {
            ['Trash'] = 25,
            ['Poor'] = 45,
            ['Good'] = 65,
            ['Great'] = 125,
        }
    },
    [6] = {
        ['name'] = 'stripedbass',
        ['chance'] = 45,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        },
        ['quality_payment'] = {
            ['Trash'] = 15,
            ['Poor'] = 25,
            ['Good'] = 30,
            ['Great'] = 45,
        }
    },
    [7] = {
        ['name'] = 'whale',
        ['chance'] = 20,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        },
        ['quality_payment'] = {
            ['Trash'] = 90,
            ['Poor'] = 110,
            ['Good'] = 135,
            ['Great'] = 155,
        }
    },
}


Config.FishQualityIdentifiers = {
    [1] = {
        min = 0,
        max = 25,
        label = 'Trash',
    },
    [2] = {
        min = 26,
        max = 50,
        label = 'Poor',
    },
    [3] = {
        min = 51,
        max = 75,
        label = 'Good',
    },
    [4] = {
        min = 76,
        max = 100,
        label = 'Great',
    },
}
