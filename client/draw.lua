local TextsCache = {}

function GetCursorScreenPosition()
    return vector2(GetControlNormal(0, `INPUT_CURSOR_X`), GetControlNormal(0, `INPUT_CURSOR_Y`))
end

function GetTextSize(text, scale)
    local len = string.len(text)
    local width = len * (scale * 0.007)
    local height = len * (scale * 0.006)
    return width, height
end

function DrawText(text, x, y, r, g, b, a)
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