local resourceName = GetCurrentResourceName()
local githubUrl = 'https://raw.githubusercontent.com/pyro-scripts/pyrosDealerships'

local function GetCurrentVersion()
    local count = GetNumResourceMetadata(resourceName, 'version')
    if count == 0 then return nil end

    for i = 0, count - 1 do
        local v = GetResourceMetadata(resourceName, 'version', i)
        if v and v ~= '' then
            return v
        end
    end

    return nil
end

CreateThread(function()
    Wait(3000) -- wait for server startup

    local currentVersion = GetCurrentVersion()

    if not currentVersion then
        print(('^1[%s]^7 Version metadata missing in fxmanifest.lua'):format(resourceName))
        return
    end

    PerformHttpRequest(githubUrl..'/main/version', function(statusCode, response)
        if statusCode ~= 200 or not response then
            print(('^3[%s]^7 Version check failed (GitHub unreachable)'):format(resourceName))
            return
        end

        local latestVersion = response:gsub('%s+', '')

        if latestVersion == currentVersion then
        	print('===============================================================================')
            print(('^2[%s]^7 is up to date (v%s)'):format(resourceName, currentVersion))
        	print('===============================================================================')
        else
        	print('===============================================================================')
            print(('^3[%s]^7 is outdated!'):format(resourceName))
            print(('^3Current:^7 %s'):format(currentVersion))
            print(('^3Latest:^7 %s'):format(latestVersion))
            print(('^3Download:^7 '..githubUrl..'/releases/latest'):format())
        	print('===============================================================================')
        end
    end, 'GET')
end)
