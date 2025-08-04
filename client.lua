
local IsEnabled = false

local function LoadJSONFile(jsonPath)
    if (type(jsonPath) ~= "string") then
        return {}
    end
    
    local jsonData = LoadResourceFile(GetCurrentResourceName(), jsonPath)
    if (not jsonDataà then
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

local function GetCursorScreenPosition()
    return vector2(GetControlNormal(0, `INPUT_CURSOR_X`), GetControlNormal(0, `INPUT_CURSOR_Y`))
end

local function GetTextSize(text, scale)
    local len = string.len(text)
    local width = len * (scale * 0.008)
    local height = len * (scale * 0.005)
    return width, height
end

local function DrawText(text, x, y, r, g, b)
    x = x or 0
    y = y or 0
    text = tostring(text)
    r = r or 255
    g = g or 255
    b = b or 255

    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(r, g, b, 255)
    SetTextCentre(1)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)		
end

local function ToggleIPL(hash)
    if (IsIplActiveHash(hash)) then
        RemoveIplHash(hash)
    else
        RequestIplHash(hash)
    end
end

local function EnableIPLViewer(enable)
    if (enable == IsEnabled) then
        return
    end
    
    IsEnabled = enable

    if (enable) then
        local ipls = LoadJSONFile("data/ipls.json")
        local iplsToDraw = {}

        CreateThread(function()
            while IsEnabled do
                for i = #ipls, 1, -1 do
                    local ipl = ipls[i]
                    if (#(GetEntityCoords(PlayerPedId()) - vector3(ipl.x, ipl.y, ipl.z)) <= Config.Radius) then
                        table.insert(iplsToDraw, {name = ipl.name, hash = ipl.hash, x = ipl.x, y = ipl.y, z = ipl.z})
                        table.remove(ipls, i)
                    end
                end
                for i = #iplsToDraw, 1, -1 do
                    local ipl = iplsToDraw[i]
                    if (#(GetEntityCoords(PlayerPedId()) - vector3(ipl.x, ipl.y, ipl.z)) > Config.Radius) then
                        table.insert(ipls, {name = ipl.name, hash = ipl.hash, x = ipl.x, y = ipl.y, z = ipl.z})
                        table.remove(iplsToDraw, i)
                    end
                end
                Wait(2000)
            end
        end)

        CreateThread(function()
            while IsEnabled do
                if (IsControlPressed(0, `INPUT_PC_FREE_LOOK`)) then
                    SetMouseCursorThisFrame()
                    DisableControlAction(0, `INPUT_ATTACK`, true)
                end
                
                local alreadyHover = false
                for i = #iplsToDraw, 1, -1 do
                    local ipl = iplsToDraw[i]
                    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(ipl.x, ipl.y, ipl.z)
                    if (onScreen) then
                        local cursorPosition = GetCursorScreenPosition()
                        local displayText = ipl.hashname ~= "" and ipl.hashname or ipl.hash
                        
                        local textWidth, textHeight = GetTextSize(displayText, 0.35)
                        local isHovered = false
                        if (not alreadyHover) then
                            isHovered = cursorPosition.x >= (screenX - textWidth / 2) and cursorPosition.y >= screenY and cursorPosition.x < screenX + (textWidth + textWidth / 2) and cursorPosition.y < screenY + textHeight
                            if (isHovered) then
                                alreadyHover = true
                            end
                        end

                        if (isHovered) then
                            DrawText(displayText, screenX, screenY, 0, 0, 255)
                        elseif (IsIplActiveHash(ipl.hash)) then
                            DrawText(displayText, screenX, screenY, 0, 255, 0)
                        else
                            DrawText(displayText, screenX, screenY, 255, 0, 0)
                        end
                        
                        if (isHovered and IsDisabledControlJustPressed(0, `INPUT_ATTACK`)) then
                            ToggleIPL(ipl.hash)
                            print(displayText)
                        end
                    end
                end
                Wait(0)
            end
        end)
    end
end

RegisterCommand(Config.Command, function()
    EnableIPLViewer(not IsEnabled)
end)