function ToggleIPL(hash)
    local activate = not IsIplActiveHash(hash)
    if (activate) then
        RequestIplHash(hash)
    else
        RemoveIplHash(hash)
    end
    TriggerServerEvent("srb_iplviewer:server:setIPLState", hash, activate)
end

function ResolveHash(str)
    return str:match("^0x(%x+)$") and tonumber(str) or joaat(str)
end