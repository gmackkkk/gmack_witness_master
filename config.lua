Config = {}

Config.NotificationDistance = 1000.0   -- Maximum distance to display the shooting alert to police
Config.NotificationText = "A shooting has been reported in your area."  -- Message shown to police
Config.NPCNotificationText = "A local reported gunshots nearby."  
Config.NotificationDisplayTime = 5000  

-- Notification settings
Config.Notification = {
    Title = "Shooting Alert",
    Icon = "fas fa-bullhorn",
}

-- Blip settings
Config.Blip = {
    Sprite = 1,              -- Blip sprite ID (1 is default)
    Scale = 0.7,             -- Blip size/scale
    Colour = 1,              -- Blip color (1 = red)
    BlipName = "Shooting Alert",  -- Blip label name
}

Config.ShootingDetectionInterval = 500  -- Interval (in ms) to check if the player is shooting

Config.NPCReportingRadius = 50.0  -- Radius for NPCs to witness shooting events

return Config

