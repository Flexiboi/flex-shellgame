Config = {}
Config.Debug = false

Config.LoopDelay = 1 -- Seconds to check for spawn
Config.SpawnDistance = 25 -- Distance before spawning
Config.ShuffleTimes = math.random(2,3)
Config.RewardMulti = 2
Config.ArrestTimeOut = 1 --minutes

Config.Locations = {
    [1] = {
        betamount = 85,
        ped = 's_m_y_casino_01',
        coords = vector4(178.33, -959.47, 29.37, 207.11),
        spawned = false,
        bussy = false,
        arrested = false,
    },
    [2] = {
        betamount = 65,
        ped = 's_m_y_casino_01',
        coords = vector4(310.95, 180.91, 103.85, 205.22),
        spawned = false,
        bussy = false,
        arrested = false,
    },
    [3] = {
        betamount = 35,
        ped = 's_m_y_casino_01',
        coords = vector4(-487.82, -227.18, 36.41, 173.84),
        spawned = false,
        bussy = false,
        arrested = false,
    },
    [4] = {
        betamount = 125,
        ped = 's_m_y_casino_01',
        coords = vector4(-1295.98, -1390.08, 4.54, 189.89),
        spawned = false,
        bussy = false,
        arrested = false,
    }
}