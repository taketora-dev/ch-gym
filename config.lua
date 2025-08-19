Config = {}

-- Planning to add other targeting options in a future version, leave this for now
Config.TargetingSystem = 'ox_target'

-- Set the amount of stress reduced per action
Config.StressRemoval = 10

function GetStressRemovalAmount()
    return Config.StressRemoval

end
