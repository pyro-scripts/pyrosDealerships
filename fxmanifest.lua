fx_version 'cerulean'
game 'gta5'

author 'Pyro - the.pyro_'
description 'QBCore Customisable Vehicle Dealerships Using MenuV'
version '1.0.2'

--shared_scripts { 'config.lua' }
client_scripts { '@menuv/menuv.lua', 'client/*.lua', 'config.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/*.lua', 'config.lua' }

dependencies {
    'qb-core',
    'menuv'
}
