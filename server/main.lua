local Database = {}

local function HasPlayerPermission(playerSource)
    local steamId = GetPlayerIdentifierByType(playerSource, "steam")
    return Config.Users[steamId] == true
end

CreateThread(function()
    Database = LoadJSONFile("data/database.json")
end)

RegisterServerEvent("srb_iplviewer:server:requestIPLStates", function()
    local _source = source
    TriggerClientEvent("srb_iplviewer:client:receiveIPLStates", _source, json.encode(Database))
end)

RegisterServerEvent("srb_iplviewer:server:setIPLState", function(iplHash, activate)
    local _source = source
    if (not HasPlayerPermission(_source)) then return end
    if (type(activate) ~= "boolean") then return end

    Database[tostring(iplHash)] = activate
    SaveResourceFile(GetCurrentResourceName(), "data/database.json", json.encode(Database), -1)

    TriggerClientEvent("srb_iplviewer:client:updateIPLState", -1, iplHash, activate)
end)

RegisterCommand(Config.Command, function(source)
    if (not HasPlayerPermission(source)) then return end
    TriggerClientEvent("srb_iplviewer:client:toggleIPLViewer", source)
end, false)