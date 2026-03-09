local TextsCache = {}

function GetCursorScreenPosition()
    return vector2(GetControlNormal(0, `INPUT_CURSOR_X`), GetControlNormal(0, `INPUT_CURSOR_Y`))
end

function GetTextSize(text, scale)
    local widthLen = string.len(text)
    local width = scale * 0.006 * widthLen
    local height = scale * 0.1
    return width, height
end

function DrawText(text, x, y, r, g, b, a)
    text = tostring(text)

    if (not TextsCache[text]) then
        TextsCache[text] = VarString(10, "LITERAL_STRING", text)
    end

    SetTextScale(0.25, 0.25)
    SetTextFontForCurrentCommand(0)
    SetTextColor(r or 255, g or 255, b or 255, a or 255)
    SetTextCentre(true)
    DisplayText(TextsCache[text], x or 0.0, y or 0.0)
end