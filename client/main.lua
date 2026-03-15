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
                local iplData = IPLS_DATA[ipl]
                local distance = #(playerCoords - iplData.coords)
                local mustBeDrawn = distance <= Config.Radius and GetScreenCoordFromWorldCoord(iplData.coords.x, iplData.coords.y, iplData.coords.z)

                if (IplsDrawn[ipl] and not mustBeDrawn) then
                    RemoveIplToDraw(ipl)
                elseif (not IplsDrawn[ipl] and mustBeDrawn) then
                    AddIplToDraw(ipl)
                end
            end

            Wait(1000)
        end
    end)

    CreateThread(function()
        while IsActive do
            local showMouseCursor = IsControlPressed(0, `INPUT_PC_FREE_LOOK`)
            local cursorPosition = GetCursorScreenPosition()
            local isClickPressed = IsDisabledControlJustPressed(0, `INPUT_ATTACK`)

            if (showMouseCursor) then
                SetMouseCursorThisFrame()
                DisableControlAction(0, `INPUT_ATTACK`, true)
            end
            
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
                    
                    local textToDraw = ipl .. "\n" .. iplData.hash
                    local alpha = isHovered and 255 or 200
                    if (IsIplActiveHash(iplData.hash)) then
                        DrawText(textToDraw, screenX, screenY, 0, 255, 0, alpha)
                    else
                        DrawText(textToDraw, screenX, screenY, 255, 0, 0, alpha)
                    end
                    
                    if (isHovered and isClickPressed) then
                        ToggleIPL(iplData.hash)
                        print("-----IPL-----\n"..textToDraw.."\n-------------")
                    end
                end
            end

            if (#IplsToDraw == 0 and not showMouseCursor) then
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
    IplsDrawn = {}
    IplsToDraw = {}
    IplsToDrawIndex = {}
end
exports("DisableIPLViewer", DisableIPLViewer)

function IsIPLViewerActive()
    return IsActive
end
exports("IsIPLViewerActive", IsIPLViewerActive)

---Receive IPL states from server and apply them
RegisterNetEvent("srb_ipl:client:receiveIPLStates", function(databaseJSON)
    local database = json.decode(databaseJSON)
    for iplHash, activate in pairs(database) do
        SetIplHashVisible(tonumber(iplHash), activate)
    end
end)

---Realtime ipl state update
RegisterNetEvent("srb_ipl:client:updateIPLState", function(iplHash, activate)
    SetIplHashVisible(iplHash, activate)
end)

---Toggle IPL viewer from server
RegisterNetEvent("srb_ipl:client:toggleIPLViewer", function()
    if (IsIPLViewerActive()) then
        DisableIPLViewer()
    else
        EnableIPLViewer()
    end
end)

---Enable IPL viewer from server
RegisterNetEvent("srb_ipl:client:enableIPLViewer", function()
    EnableIPLViewer()
end)

---Disable IPL viewer from server
RegisterNetEvent("srb_ipl:client:disableIPLViewer", function()
    DisableIPLViewer()
end)

local function Init()
    CreateThread(function()
        local ipls = LoadJSONFile("data/ipls.json")
        local numIplsAtCoords = {}
        local validIpls = {}

        for i = 1, #ipls do
            local ipl = ipls[i]
            local iplHash = ResolveHash(ipl)
            local retval, coords, radius = GetIplBoundingSphere(iplHash)
            
            if (retval) then
                local x, y, z = math.round(coords.x, 2), math.round(coords.y, 2), math.round(coords.z, 2)
                
                -- Add a offset to prevent overlapping text for IPLs with the same coordinates
                local coordsStr = ("%f, %f, %f"):format(x, y, z)
                if (not numIplsAtCoords[coordsStr]) then
                    numIplsAtCoords[coordsStr] = 1
                else
                    z = z + (numIplsAtCoords[coordsStr] * 0.15)
                    numIplsAtCoords[coordsStr] = numIplsAtCoords[coordsStr] + 1
                end

                local textWidth, textHeight = GetTextSize(ipl, 0.35)
                IPLS_DATA[ipl] = {
                    hash = iplHash,
                    coords = vector3(x, y, z),
                    textWidth = textWidth,
                    textHeight = textHeight,
                }
                validIpls[#validIpls + 1] = ipl
            end
        end

        IPLS_LIST = validIpls
        
        TriggerServerEvent("srb_ipl:server:requestIPLStates")
    end)
end

if (Config.Debug) then
	Init()
else
	RegisterNetEvent(Config.InitEvent, Init)
end