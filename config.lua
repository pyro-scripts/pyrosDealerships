--[[
                           ___           __            __   _        
   ___  __ _________  ___ / _ \___ ___ _/ /__ _______ / /  (_)__  ___
  / _ \/ // / __/ _ \(_-</ // / -_) _ `/ / -_) __(_-</ _ \/ / _ \(_-<
 / .__/\_, /_/  \___/___/____/\__/\_,_/_/\__/_/ /___/_//_/_/ .__/___/
/_/   /___/                                               /_/        
]]--

Config = {}

Config.Notifications = 'pyrosNotifs'										-- Options: 'qb', 'ox', 'pyrosNotifs'

Config.InteractDistance = 3.0												-- Distance to interact with a podium
Config.VehicleColour = { r=255, g=255, b=255 }								-- Preview & Purchased vehicle color (Default: r=255, g=255, b=255 (White))

Config.Stores = {
	['pdm'] = {
		label = 'Premium Deluxe Motorsport',
		podiums = {
			{
				id = 'pdm_suvs',
				label = 'SUVs',
				coords = vector4(-47.3462, -1093.5022, 25.9359, 187.0555),

				vehicles = {
					--{ label = 'Baller', model = 'baller', price = 60000, speed = 120, slots = 30, weight = 80000 }
				}
			},
			{
				id = 'pdm_compacts',
				label = 'Compacts',
				coords = vector4(-46.3945, -1100.6534, 25.9362, 300.4542),

				vehicles = {
					{ label = 'Rhapsody', model = 'rhapsody', price = 6250, speed = 105, slots = 15, weight = 18000 }
				}
			},
			{
				id = 'pdm_sports',
				label = 'Sports',
				coords = vector4(-41.2565, -1095.3096, 25.8699, 193.4486),

				vehicles = {
					{ label = 'Asterope RS', model = 'asteropers', price = 12350, speed = 115, slots = 22, weight = 25000 }
				}
			}
		}
	}
}