-- config.lua

Config = {}

-- Notification settings
Config.NotificationDistance = 1000.0   -- Maximum distance to display the shooting alert to police
Config.NotificationText = "A shooting has been reported in your area."  -- Message shown to police
Config.NotificationDisplayTime = 5000  -- Time in milliseconds that the notification will be displayed

-- Blip settings
Config.Blip = {
    Sprite = 1,              -- Blip sprite ID (1 is default)
    Scale = 0.7,             -- Blip size/scale
    Colour = 1,              -- Blip color (1 = red)
    BlipName = "Shooting Alert",  -- Blip label name
}

-- Shooting detection settings
Config.ShootingDetectionInterval = 500  -- Interval (in ms) to check if the player is shooting

return Config
