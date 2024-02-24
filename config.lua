Config = {}


Config.allowedJob = { --letak job yang nak guna ramp. ** WIP - nanti nak try apply dekat work dekat radial menu
    'mechanic',
	'police',
	'sheriff',
}

Config.whitelist = { -- tambah kereta untuk guna ramp . ( KENA TAHU OFFSET )
    'FLATBED',
}

Config.offsets = { -- OFFSET RAMP
    {model = 'FLATBED', offset = {x = 0.0, y = -9.0, z = -1.25}}, -- x -> Left/Right adjustment | y -> Forward/Backward adjustment | z -> Height adjustment
}

RampHash = 'imp_prop_flatbed_ramp'
