
local IsActive = false
local IplsToDraw = {}
local TextsCache = {}

local function LoadJSONFile(jsonPath)
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

local function GetCursorScreenPosition()
    return vector2(GetControlNormal(0, `INPUT_CURSOR_X`), GetControlNormal(0, `INPUT_CURSOR_Y`))
end

local function GetTextSize(text, scale)
    local len = string.len(text)
    local width = len * (scale * 0.007)
    local height = len * (scale * 0.006)
    return width, height
end

local function DrawText(text, x, y, r, g, b, a)
    text = tostring(text)

    if (not TextsCache[text]) then
        TextsCache[text] = VarString(10, "LITERAL_STRING", text)
    end

    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(r or 255, g or 255, b or 255, a or 255)
    SetTextCentre(true)
    DisplayText(TextsCache[text], x or 0.0, y or 0.0)
end

local function ToggleIPL(hash)
    if (IsIplActiveHash(hash)) then
        RemoveIplHash(hash)
    else
        RequestIplHash(hash)
    end
end

function EnableIPLViewer()
    if (IsActive) then return end
    IsActive = true
    CreateThread(function()
        local ipls = LoadJSONFile("data/ipls.json")
        while IsActive do
            for i = #ipls, 1, -1 do
                local ipl = ipls[i]
                if (#(GetEntityCoords(PlayerPedId()) - vector3(ipl.x, ipl.y, ipl.z)) <= Config.Radius) then
                    table.insert(IplsToDraw, {name = ipl.name, hash = ipl.hash, x = ipl.x, y = ipl.y, z = ipl.z})
                    table.remove(ipls, i)
                end
            end
            for i = #IplsToDraw, 1, -1 do
                local ipl = IplsToDraw[i]
                if (#(GetEntityCoords(PlayerPedId()) - vector3(ipl.x, ipl.y, ipl.z)) > Config.Radius) then
                    table.insert(ipls, {name = ipl.name, hash = ipl.hash, x = ipl.x, y = ipl.y, z = ipl.z})
                    table.remove(IplsToDraw, i)
                end
            end
            Wait(1000)
        end
    end)

    CreateThread(function()
        while IsActive do
            if (IsControlPressed(0, `INPUT_PC_FREE_LOOK`)) then
                SetMouseCursorThisFrame()
                DisableControlAction(0, `INPUT_ATTACK`, true)
            end
            
            local alreadyHover = false
            for i = #IplsToDraw, 1, -1 do
                local ipl = IplsToDraw[i]
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(ipl.x, ipl.y, ipl.z)
                if (onScreen) then
                    local cursorPosition = GetCursorScreenPosition()
                    local displayText = ipl.hashname ~= "" and ipl.hashname or ipl.hash
                    
                    local textWidth, textHeight = GetTextSize(displayText, 0.35)
                    local isHovered = false
                    if (not alreadyHover) then
                        isHovered = cursorPosition.x >= (screenX - textWidth) and cursorPosition.y >= screenY and cursorPosition.x < (screenX + textWidth) and cursorPosition.y < (screenY + textHeight)
                        if (isHovered) then
                            alreadyHover = true
                        end
                    end

                    if (IsIplActiveHash(ipl.hash)) then
                        DrawText(displayText, screenX, screenY, 0, 255, 0, isHovered and 255 or 200)
                    else
                        DrawText(displayText, screenX, screenY, 255, 0, 0, isHovered and 255 or 200)
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
exports("EnableIPLViewer", EnableIPLViewer)

function DisableIPLViewer()
    IsActive = false
end
exports("DisableIPLViewer", DisableIPLViewer)

function IsIPLViewerActive()
    return IsActive
end
exports("IsIPLViewerActive", IsIPLViewerActive)

RegisterCommand(Config.Command, function()
    if (IsIPLViewerActive()) then
        DisableIPLViewer()
    else
        EnableIPLViewer()
    end
end, false)