function LoadJSONFile(filePath)
    local fileContents = LoadResourceFile(GetCurrentResourceName(), filePath)
    local jsonContent = json.decode(fileContents) or {}
    return jsonContent
end