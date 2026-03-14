function ToggleIPL(iplHash)
    local activate = not IsIplActiveHash(iplHash)
    if (activate) then
        RequestIplHash(iplHash)
    else
        RemoveIplHash(iplHash)
    end
    TriggerServerEvent("srb_ipl:server:setIPLState", iplHash, activate)
end

function ResolveHash(str)
    return str:match("^0x(%x+)$") and tonumber(str) or joaat(str)
end