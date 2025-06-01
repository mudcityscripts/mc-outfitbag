fx_version 'cerulean'
game 'gta5'

author 'mc-scripts'
description 'Outfit Bag Script'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'Shared/*.lua',
    'config.lua'
}

client_scripts {
    'Client/*.lua'
}

server_scripts {
    'Server/*.lua'
}

files {
    'outfits.json'
}

dependencies {
    'qb-core',
    'ox_inventory',
    'ox_lib',
    'illenium-appearance'
}