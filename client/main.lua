--[[
                           ___           __            __   _        
   ___  __ _________  ___ / _ \___ ___ _/ /__ _______ / /  (_)__  ___
  / _ \/ // / __/ _ \(_-</ // / -_) _ `/ / -_) __(_-</ _ \/ / _ \(_-<
 / .__/\_, /_/  \___/___/____/\__/\_,_/_/\__/_/ /___/_//_/_/ .__/___/
/_/   /___/                                               /_/        
]]--

local QBCore = exports['qb-core']:GetCoreObject()
local PreviewVehicles = {}
local SpawnedPodiumVehicles = {}
local showingText = false

CreateThread(function()
    Wait(1000)
    print('Config exists:', Config ~= nil)
    print('Config.Stores:', Config and Config.Stores)
end)

CreateThread(function()
	while true do
		local sleep = 1500
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

		for _, store in pairs(Config.Stores) do
	        for _, podium in pairs(store.podiums) do
	            local dist = #(coords - vector3(
	                podium.coords.x,
	                podium.coords.y,
	                podium.coords.z
	            ))

	            if dist <= Config.InteractDistance then
	            	sleep = 0
	            	if not showingText then
	            		exports['qb-core']:DrawText(
	            			'[E] View Vehicles',
	            			'left'
	            		)
	            		showingText = true
	            	end

	                if IsControlJustPressed(0, 38) then
	                    OpenPodiumMenu(store, podium)
	                end
	            end
	        end
	    end

	    if showingText and sleep ~= 0 then
	    	exports['qb-core']:HideText()
	    	showingText = false
	    end

	    Wait(sleep)
	end
end)

-- ==============================
-- Create Podium Vehicles
-- ==============================
local function SpawnPodiumVehicle(podium, vehicle)
	local podiumId = podium.id

	if SpawnedPodiumVehicles[podiumId] then
		DeleteEntity(SpawnedPodiumVehicles[podiumId])
		SpawnedPodiumVehicles[podiumId] = nil
	end

	local model = joaat(vehicle.model)
	RequestModel(model)
	while not HasModelLoaded(model) do Wait(0) end

	local veh = CreateVehicle(
		model,
		podium.coords.x,
		podium.coords.y,
		podium.coords.z-1,
		podium.coords.w,
		false,
		false
	)

	SetEntityInvincible(veh, true)
	FreezeEntityPosition(veh, true)
	SetVehicleDoorsLocked(veh, 2)
	SetVehicleDirtLevel(veh, 0.0)
	SetVehicleCustomPrimaryColour(
		veh,
		Config.VehicleColour.r,
		Config.VehicleColour.g,
		Config.VehicleColour.b
	)
	SetVehicleCustomSecondaryColour(
		veh,
		Config.VehicleColour.r,
		Config.VehicleColour.g,
		Config.VehicleColour.b
	)

	SpawnedPodiumVehicles[podiumId] = veh
	podium.currentVehicle = vehicle

	SetModelAsNoLongerNeeded(model)
end

CreateThread(function()
    Wait(1000)

    for _, store in pairs(Config.Stores) do
        for _, podium in pairs(store.podiums) do
            if podium.vehicles and #podium.vehicles > 0 then
                local randomVehicle = podium.vehicles[math.random(#podium.vehicles)]
                SpawnPodiumVehicle(podium, randomVehicle)
            end
        end
    end
end)

-- ==============================
-- Menus
-- ==============================
function OpenPodiumMenu(store, podium)
	local mainMenu = MenuV:CreateMenu(
		'Dealership',
		store.label,
		'topright',
		154, 42, 42,
		'size-125'
	)
	local vehicleMenu = MenuV:CreateMenu(
		podium.label,
		store.label or 'Dealership',
		'topright',
		154, 42, 42,
		'size-125'
	)

	for _, vehicle in pairs(podium.vehicles) do
		vehicleMenu:AddButton({
			label = vehicle.label .. ' — $' .. vehicle.price,
			select = function()
				SpawnPreviewVehicle(podium, vehicle)
				OpenPurchaseMenu(store, vehicle)
			end
		})
	end


	local vmbtn = mainMenu:AddButton({
		label = 'Choose A Vehicle --->',
		description = '',
		submenu = vehicleMenu
	})
	vmbtn:On('select', function()
		MenuV:CloseMenu(mainMenu)
		Wait()
		MenuV:OpenMenu(vehicleMenu)
	end)

	MenuV:OpenMenu(mainMenu)
end

function OpenPurchaseMenu(store, vehicle)
	local purchaseMenu = MenuV:CreateMenu(
		vehicle.label,
		store.label,
		'topright',
		154, 42, 42,
		'size-125'
	)


	local vmbtn = purchaseMenu:AddButton({
		label = 'Choose A Vehicle --->',
		description = '',
		submenu = vehicleMenu
	})
	vmbtn:On('select', function()
		MenuV:CloseMenu(purchaseMenu)
		Wait()
		MenuV:OpenMenu(vehicleMenu)
	end)
	purchaseMenu:AddButton({ label = '--------------------------' })
	purchaseMenu:AddButton({ label = 'Price: $' .. vehicle.price })
	purchaseMenu:AddButton({ label = 'Top Speed: ' .. vehicle.speed .. ' mph' })
	purchaseMenu:AddButton({ label = 'Trunk Slots: ' .. vehicle.slots })
	purchaseMenu:AddButton({ label = 'Trunk Max Weight: ' .. vehicle.weight })
	purchaseMenu:AddButton({ label = '--------------------------' })

	purchaseMenu:AddButton({
		label = 'Purchase Vehicle',
		select = function()
			TriggerServerEvent('pd:server:purchaseVehicle', vehicle)
			MenuV:CloseAll()
		end
	})

	MenuV:OpenMenu(purchaseMenu)
end

-- ==============================
-- Vehicle Preview
-- ==============================
function SpawnPreviewVehicle(podium, vehicle)
	local podiumId = podium.id

	if PreviewVehicles[podiumId] then
		DeleteEntity(PreviewVehicles[podiumId])
		PreviewVehicles[podiumId] = nil
	end

	QBCore.Functions.LoadModel(vehicle.model)

	local veh = CreateVehicle(
		joaat(vehicle.model),
		podium.coords.x,
		podium.coords.y,
		podium.coords.z,
		podium.coords.w,
		false,
		false
	)

	SetEntityInvincible(veh, true)
	FreezeEntityPosition(veh, true)
	SetVehicleDoorsLocked(veh, 2)
	SetVehicleDirtLevel(veh, 0.0)
	SetVehicleCustomPrimaryColour(
		veh,
		Config.VehicleColour.r,
		Config.VehicleColour.g,
		Config.VehicleColour.b
	)
	SetVehicleCustomSecondaryColour(
		veh,
		Config.VehicleColour.r,
		Config.VehicleColour.g,
		Config.VehicleColour.b
	)

	PreviewVehicles[podiumId] = veh
end