local IPLS_LIST = {}
local IPLS_DATA = {}

local IsActive = false

local IplsDrawn = {}
local IplsToDraw = {}
local IplsToDrawIndex = {}

local function AddIplToDraw(ipl)
    if (IplsToDrawIndex[ipl]) then return end

    local newIndex = #IplsToDraw + 1
    IplsToDraw[newIndex] = ipl
    IplsToDrawIndex[ipl] = newIndex
    IplsDrawn[ipl] = true
end

local function RemoveIplToDraw(ipl)
    local index = IplsToDrawIndex[ipl]
    if (not index) then return end

    local lastIndex = #IplsToDraw
    local lastIpl = IplsToDraw[lastIndex]

    IplsToDraw[index] = lastIpl
    IplsToDraw[lastIndex] = nil
    IplsToDrawIndex[ipl] = nil
    IplsDrawn[ipl] = nil

    if (lastIpl and lastIpl ~= ipl) then
        IplsToDrawIndex[lastIpl] = index
    end
end

function EnableIPLViewer()
    if (IsActive) then return end
    IsActive = true
    
    CreateThread(function()
        while IsActive do
            local playerCoords = GetEntityCoords(PlayerPedId())

            for i = 1, #IPLS_LIST do
                local ipl = IPLS_LIST[i]
                local data = IPLS_DATA[ipl]
                local distance = #(playerCoords - data.coords)
                
                if (IplsDrawn[ipl] and distance > Config.Radius) then
                    RemoveIplToDraw(ipl)
                elseif (not IplsDrawn[ipl] and distance <= Config.Radius) then
                    AddIplToDraw(ipl)
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

            local cursorPosition = GetCursorScreenPosition()
            local isClickPressed = IsDisabledControlJustPressed(0, `INPUT_ATTACK`)
            
            local alreadyHover = false
            for i = 1, #IplsToDraw do
                local ipl = IplsToDraw[i]
                local iplData = IPLS_DATA[ipl]
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(iplData.coords.x, iplData.coords.y, iplData.coords.z)
                if (onScreen) then
                    local isHovered = false
                    if (not alreadyHover) then
                        isHovered = cursorPosition.x >= (screenX - iplData.textWidth) and cursorPosition.y >= screenY and cursorPosition.x < (screenX + iplData.textWidth) and cursorPosition.y < (screenY + iplData.textHeight)
                        if (isHovered) then
                            alreadyHover = true
                        end
                    end

                    local alpha = isHovered and 255 or 200
                    if (IsIplActiveHash(iplData.hash)) then
                        DrawText(ipl, screenX, screenY, 0, 255, 0, alpha)
                    else
                        DrawText(ipl, screenX, screenY, 255, 0, 0, alpha)
                    end
                    
                    if (isHovered and isClickPressed) then
                        ToggleIPL(iplData.hash)
                        print(ipl)
                    end
                end
            end

            if (#IplsToDraw == 0) then
                Wait(250)
            else
                Wait(0)
            end
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

CreateThread(function()
    local ipls = LoadJSONFile("data/ipls.json")

    local validIpls = {}
    for i = 1, #ipls do
        local ipl = ipls[i]
        local iplHash = ResolveHash(ipl)
        local retval, coords, radius = GetIplBoundingSphere(iplHash)

        if (retval and coords) then
            local textWidth, textHeight = GetTextSize(ipl, 0.35)
            IPLS_DATA[ipl] = {
                hash = iplHash,
                coords = coords,
                textWidth = textWidth,
                textHeight = textHeight,
            }
            validIpls[#validIpls + 1] = ipl
        end
    end

    IPLS_LIST = validIpls
end)

RegisterCommand(Config.Command, function()
    if (IsIPLViewerActive()) then
        DisableIPLViewer()
    else
        EnableIPLViewer()
    end
end, false)