function LoadJSONFile(jsonPath)
    if (type(jsonPath) ~= "string") then
        return {}
    end
    
    local jsonData = LoadResourceFile(GetCurrentResourceName(), jsonPath)
    if (not jsonData) then
        return {}
    end

    local status, decoded = pcall(function()
        return json.decode(jsonData)
    end)

    if (not status) then
        return {}
    end

    return decoded
end

function ToggleIPL(hash)
    if (IsIplActiveHash(hash)) then
        RemoveIplHash(hash)
    else
        RequestIplHash(hash)
    end
end

function ResolveHash(str)
    return str:match("^0x(%x+)$") and tonumber(str) or joaat(str)
end