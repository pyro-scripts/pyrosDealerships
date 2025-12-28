--[[
                           ___           __            __   _        
   ___  __ _________  ___ / _ \___ ___ _/ /__ _______ / /  (_)__  ___
  / _ \/ // / __/ _ \(_-</ // / -_) _ `/ / -_) __(_-</ _ \/ / _ \(_-<
 / .__/\_, /_/  \___/___/____/\__/\_,_/_/\__/_/ /___/_//_/_/ .__/___/
/_/   /___/                                               /_/        
]]--

local QBCore = exports['qb-core']:GetCoreObject()

-- ==============================
-- Plate Generation
-- ==============================
local NumberCharset = {}
local Charset = {}

for i = 48, 57 do
    table.insert(NumberCharset, string.char(i))
end

for i = 65, 90 do
    table.insert(Charset, string.char(i))
end

local function GetRandomNumber(length)
    math.randomseed(GetGameTimer())
    local result = ''
    for _ = 1, length do
        result = result .. NumberCharset[math.random(1, #NumberCharset)]
    end
    return result
end

local function GetRandomLetter(length)
    math.randomseed(GetGameTimer())
    local result = ''
    for _ = 1, length do
        result = result .. Charset[math.random(1, #Charset)]
    end
    return result
end

local function GeneratePlate()
    return GetRandomNumber(2) ..
           GetRandomLetter(3) ..
           GetRandomNumber(3)
end

-- ==============================
-- Purchase Vehicle
-- ==============================
RegisterNetEvent('pd:server:purchaseVehicle', function(vehicle)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local price = tonumber(vehicle.price)
    if not price then return end

    if Player.Functions.RemoveMoney('cash', price, 'vehicle-purchase') then
        local plate
        local isUnique = false

        while not isUnique do
            plate = GeneratePlate()

            local result = MySQL.scalar.await(
                'SELECT plate FROM player_vehicles WHERE plate = ?',
                { plate }
            )

            if not result then
                isUnique = true
            end
        end


        MySQL.insert.await([[
            INSERT INTO player_vehicles
            (license, citizenid, vehicle, hash, mods, plate, garage, fuel, engine, body, state)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]],{
            Player.PlayerData.license,
            Player.PlayerData.citizenid,
            vehicle.model,
            GetHashKey(vehicle.model),
            '{"color1":111,"color2":111}',
            plate,
            'pillboxgarage',
            100.0,
            1000.0,
            1000.0,
            1
        })

        if Config.Notifications == "pyrosNotifs" then
            TriggerClientEvent('pyrosNotifs:send',
                src,
                'Success',
                'Vehicle purchased successfully!',
                'success',
                5000
            )
        elseif Config.Notifications == "qb" then
            TriggerClientEvent('QBCore:Notify',
                src,
                'Vehicle purchased successfully!',
                'success'
            )
        elseif Config.Notifications == "ox" then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Success',
                description = 'Vehicle purchased successfully!',
                type = 'success'
            })
        else
            return print("pyrosDealerships (ERROR): Notifications Config Set Incorrectly! Please Fix and Restart Script")
        end
    else
        if Config.Notifications == "pyrosNotifs" then
            TriggerClientEvent('pyrosNotifs:send',
                src,
                'Error',
                'Insufficient Funds',
                'error',
                5000
            )
        elseif Config.Notifications == "qb" then
            TriggerClientEvent('QBCore:Notify',
                src,
                'Insufficient Funds',
                'error'
            )
        elseif Config.Notifications == "ox" then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Error',
                description = 'Insufficient Funds',
                type = 'error'
            })
        else
            return print("pyrosDealerships (ERROR): Notifications Config Set Incorrectly! Please Fix and Restart Script")
        end
    end
end)