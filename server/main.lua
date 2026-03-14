local Database = {}

local function HasPlayerPermission(playerSource)
    local steamId = GetPlayerIdentifierByType(playerSource, "steam")
    return Config.Users[steamId] == true
end

---
---@param iplHash integer
---@param activate boolean
function SetIPLState(iplHash, activate)
    Database[tostring(iplHash)] = activate
    SaveResourceFile(GetCurrentResourceName(), "data/database.json", json.encode(Database), -1)

    TriggerClientEvent("srb_ipl:client:updateIPLState", -1, iplHash, activate)
end
exports("SetIPLState", SetIPLState)

CreateThread(function()
    Database = LoadJSONFile("data/database.json")
end)

RegisterServerEvent("srb_ipl:server:requestIPLStates", function()
    local _source = source
    TriggerClientEvent("srb_ipl:client:receiveIPLStates", _source, json.encode(Database))
end)

RegisterServerEvent("srb_ipl:server:setIPLState", function(iplHash, activate)
    local _source = source
    if (not HasPlayerPermission(_source)) then return end
    if (type(activate) ~= "boolean") then return end

    SetIPLState(iplHash, activate)
end)

RegisterCommand(Config.Command, function(source)
    if (not HasPlayerPermission(source)) then return end
    TriggerClientEvent("srb_ipl:client:toggleIPLViewer", source)
end, false)