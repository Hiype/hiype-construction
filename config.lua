Config = {} -- Don't touch this
Config.DeliveryTruck = {}

Config.PolyzoneDebug = false
Config.IsVehicleAffectedByCargo = true

Config.NPCLocation = vector4(-96.7, -1014.0, 26.28, 166.69)
Config.NPCModel = 'cs_floyd'
Config.ContractSignTime = 5000
Config.ModelLoadingTimeout = 7000

-- Workbench
Config.WorkbenchModel = 'prop_tool_bench02'
Config.WorkbenchLocation = vector4(1074.71, -1996.75, 29.89, 232.27)

Config.BlipScale = 0.8

Config.DeliveryTruck.Model = 'flatbed'
Config.DeliveryTruck.SpawnLocation = vector4(-121.66, -1041.46, 27.27, 236.55)
Config.DeliveryTruck.RentPrice = 500
Config.DeliveryTruck.RentReturn = 200
Config.DeliveryTruck.SignTime = 7000
Config.DeliveryTruck.RentPriceType = 'cash'
Config.DeliveryTruck.RentReturnPriceType = 'cash'
Config.DeliveryTruck.RentReturnDistance = 30

Config.ConstructionSites = {
    ['windmill_park_construction_windmill'] = {
        type = 'object',
        listingIcon = 'fa-solid fa-wind',
        listingText = 'Build the windmill',
        locationName = 'Construction | Windmill',
        buildObjectLocation = vector4(2237.47, 1617.56, 74.77, 170.92),
        reward = 6000,
        rewardType = 'cash',
        pickupDropoff = vector3(2221.68, 1615.73, 75.72),
        deliverables = {
            ['pipes_1'] = {
                model = 'prop_pipes_ld_01',
                blipName = "Deliverable | Pipes",
                interactionText = 'Moving pipes',
                pickupLocation = vector4(-103.45, -1051.17, 26.32, 73.76),
                pickupDistance = 10,
                pickupDestination = vector4(2230.4, 1631.83, 75.35, 358.06),
                vehiclePowerModifier = 0.5,
                pickupInteractionTime = 5000,
                placementOnTruck = {
                    x = 0.0,
                    y = -3.3,
                    z = 0.8,
                    xRot = 0.0,
                    yRot = 0.0,
                    zRot = 0.0
                },
                RUNTIME_delivered = false, -- Dynamicaly changes at runtime, don't change this
                RUNTIME_unpacked = false
            },
        },
        workStages = {
            {
                ipl = nil,
                name = 'Building preparation',
                interactionIcon = 'fa-solid fa-hammer',
                interactionText = 'Prepare',
                interactionSubText = 'Unpacking material',
                interactionTime = 7000,
                unpackDeliverables = true,
                transitionLocation = vector4(2228.03, 1616.41, 75.00, 258.7),
                locations = {
                    { model = 'prop_conc_blocks01c', coord = vector4(2230.97, 1612.54, 74.55, 273.59) },
                    { model = 'prop_conc_blocks01c', coord = vector4(2231.18, 1619.63, 74.64, 338.08) },
                }
            },
            {
                ipl = 'windmill_1_1',
                name = 'Base building',
                interactionIcon = 'fa-solid fa-hammer',
                interactionText = 'Build',
                interactionSubText = 'Building windmill base',
                interactionTime = 7000,
                transitionLocation = vector4(2228.03, 1616.41, 75.73, 258.7),
                requirements = {
                    ['windmill_base_part'] = 1
                },
                locations = {
                    { model = 'prop_conc_blocks01c', coord = vector4(2230.97, 1612.54, 74.55, 273.59) },
                    { model = 'prop_conc_blocks01c', coord = vector4(2231.18, 1619.63, 74.64, 338.08) },
                }
            },
            {
                ipl = 'windmill_1_2',
                name = 'Finish build',
                interactionIcon = 'fa-solid fa-hammer',
                interactionText = 'Finish build',
                interactionSubText = 'Adding finishing touches...',
                interactionItem = 'windmill_details_part',
                interactionTime = 30000,
                interactionCount = 1,
                transitionLocation = vector4(2228.03, 1616.41, 75.73, 258.7),
                interactionBox = {
                    location = vector3(2237.13, 1617.96, 75.55),
                    length = 4,
                    width = 4,
                    heading = 0,
                    minZ = 74.8,
                    maxZ = 78.8
                },
            }
        }
    },
    ['mirror_park_construction_house'] = {
        type = 'house',
        listingIcon = 'fa-solid fa-house',
        listingText = 'Build the house',
        locationName = 'Construction | Mirror park house',
        buildObjectLocation = vector4(1392.8, -768.35, 66.3, 31.16),
        reward = 8000,
        rewardType = 'cash',
        pickupDropoff = vector3(1377.29, -745.43, 67.23),
        deliverables = {
            ['pipes_1'] = {
                model = 'prop_pipes_01b',
                blipName = "Deliverable | Pipes",
                interactionText = 'Moving pipes',
                pickupLocation = vector4(-103.45, -1051.17, 26.32, 73.76),
                pickupDistance = 10,
                pickupDestination = vector4(1394.39, -755.12, 66.40, 237.42),
                vehiclePowerModifier = 0.5,
                pickupInteractionTime = 5000,
                placementOnTruck = {
                    x = 0.0,
                    y = -3.0,
                    z = 0.4,
                    xRot = 0.0,
                    yRot = 0.0,
                    zRot = 0.0
                },
                RUNTIME_delivered = false, -- Dynamicaly changes at runtime, don't change this
                RUNTIME_unpacked = false
            },
        },
        workStages = {
            {
                ipl = 'house_1_1',
                name = 'Base building',
                interactionIcon = 'fa-solid fa-hammer',
                interactionText = 'Build',
                interactionSubText = 'Building house base',
                interactionTime = 5000,
                unpackDeliverables = true,
                transitionLocation = vector4(1383.04, -755.6, 67.19, 220.11),
                requirements = {
                    ['house_base_part'] = 1
                },
                locations = {
                    { model = 'prop_conc_blocks01c', coord = vector4(1384.5, -760.85, 65.85, 216.49) },
                    { model = 'prop_conc_blocks01c', coord = vector4(1390.4, -763.23, 65.93, 214.47) },
                    { model = 'prop_conc_blocks01c', coord = vector4(1394.94, -760.95, 65.88, 270.79) },
                    { model = 'prop_conc_blocks01c', coord = vector4(1396.92, -769.06, 65.51, 211.53) },
                }
            },
            {
                ipl = 'house_1_2',
                name = 'Wall and roof building',
                interactionIcon = 'fa-solid fa-hammer',
                interactionText = 'Build',
                interactionSubText = 'Building house walls and roof',
                interactionTime = 6000,
                transitionLocation = vector4(1383.04, -755.6, 67.19, 220.11),
                requirements = {
                    ['house_wall_part'] = 1,
                    ['house_roof_part'] = 1,
                },
                locations = {
                    { model = 'prop_paints_pallete01', coord = vector4(1390.31, -766.23, 65.64, 193.94) },
                    { model = 'prop_paints_pallete01', coord = vector4(1395.85, -769.65, 65.55, 174.58) },
                    { model = 'prop_paints_pallete01', coord = vector4(1400.03, -772.2, 65.44, 207.71) },
                    { model = 'prop_paints_pallete01', coord = vector4(1391.96, -776.15, 65.35, 136.1) },
                }
            },
            {
                ipl = 'house_1_3',
                name = 'Interior building',
                interactionIcon = 'fa-solid fa-hammer',
                interactionText = 'Build interior',
                interactionSubText = 'Building house interior',
                interactionItem = 'house_interior_part',
                interactionTime = 15000,
                interactionCount = 5,
                transitionLocation = vector4(1383.04, -755.6, 67.19, 220.11),
                interactionBox = {
                    location = vector3(1393.62, -769.82, 67.19),
                    length = 18.4,
                    width = 16,
                    heading = 210,
                    minZ = 66.19,
                    maxZ = 70.39
                },
            }
        }
    }
}

Config.Job = {
    ['construction'] = {
        label = 'Construction',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'Helper',
                payment = 100
            }
        }
    }
}

Config.ItemRequirements = {
    ['house_base_part'] = {
        ['plastic'] = 3,
        ['steel'] = 10,
        ['aluminum'] = 15
    },
    ['house_wall_part'] = {
        ['plastic'] = 5,
        ['steel'] = 4,
        ['rubber'] = 5,
        ['glass'] = 10
    },
    ['house_roof_part'] = {
        ['plastic'] = 10,
        ['steel'] = 6,
        ['rubber'] = 2,
    },
    ['house_interior_part'] = {
        ['plastic'] = 10,
        ['glass'] = 4,
        ['rubber'] = 6,
    },
    ['windmill_base_part'] = {
        ['plastic'] = 3,
        ['steel'] = 10,
        ['aluminum'] = 15
    },
    ['windmill_details_part'] = {
        ['plastic'] = 10,
        ['glass'] = 4,
        ['rubber'] = 6,
    }
}

Config.Items = {
    ['house_base_part'] = {
        name = 'house_base_part',
        label = 'House base part',
        weight = 10,
        type = 'item',
        image = 'concrete_block.png',
        unique = false,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = 'Used in house construction',
    },
    ['house_wall_part'] = {
        name = 'house_wall_part',
        label = 'House wall part',
        weight = 10,
        type = 'item',
        image = 'concrete_block.png',
        unique = false,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = 'Used in house construction',
    },
    ['house_roof_part'] = {
        name = 'house_roof_part',
        label = 'House roof part',
        weight = 10,
        type = 'item',
        image = 'concrete_block.png',
        unique = false,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = 'Used in house construction',
    },
    ['house_interior_part'] = {
        name = 'house_interior_part',
        label = 'House interior part',
        weight = 10,
        type = 'item',
        image = 'concrete_block.png',
        unique = false,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = 'Used in house construction',
    },
    ['windmill_base_part'] = {
        name = 'windmill_base_part',
        label = 'Windmill base part',
        weight = 10,
        type = 'item',
        image = 'concrete_block.png',
        unique = false,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = 'Used in windmill construction',
    },
    ['windmill_details_part'] = {
        name = 'windmill_details_part',
        label = 'Windmill details part',
        weight = 10,
        type = 'item',
        image = 'concrete_block.png',
        unique = false,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = 'Used in windmill construction',
    },
}

Config.IPLs = {
    'house_1_1',
    'house_1_2',
    'house_1_3',
    'windmill_1_1',
    'windmill_1_2'
}
