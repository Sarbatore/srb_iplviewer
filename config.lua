Config = {}

Config.Debug = true -- Enable fresh start

Config.InitEvent = "vorp:SelectedCharacter" -- If Config.Debug = false, Event initializing the IPLs (for optimization)

Config.Command = "ipl" -- Command to toggle the IPL viewer

Config.Radius = 100.0 -- Radius around the player to show the IPLs, in Rage units (1 unit = 1 cm)

-- List of users steam ID that can use the IPL viewer, set to true to allow access
Config.Users = {
    ["steam:110000119bc77f3"] = true, -- Sarbatore
}