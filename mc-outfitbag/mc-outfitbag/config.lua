Config = {}

Config.ItemName = 'outfit_bag'

Config.PropModel = 'prop_military_pack_01' -- Dufflebag
Config.Animation = {
    place = {
        dict = 'pickup_object',
        anim = 'putdown_low'
    },
    pickup = {
        dict = 'pickup_object',
        anim = 'pickup_low'
    },
    search = {
        dict = 'amb@prop_human_bum_bin@base',
        anim = 'base'
    }
}

-- Anti-cheat settings
Config.UseDistanceCheck = true
Config.MaxUseDistance = 3.0
