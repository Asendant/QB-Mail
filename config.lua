Config = Config or {}

-- Peds
Config.StartJobPedSpawn = vector4(81.28, 81.97, 78.62, 34.26)
Config.StartJobPedModel = "s_m_m_ups_01"

Config.PedModels = {
    [1] = "a_f_y_business_01",
    [2] = "a_m_m_hasjew_01",
    [3] = "a_f_m_ktown_01",
    [4] = "a_f_y_bevhills_02",
    [5] = "a_f_y_business_03",
    [6] = "a_f_y_golfer_01",
    [7] = "a_f_y_scdressy_01",
    [8] = "a_m_m_bevhills_02",
    [9] = "a_m_m_business_0",
    [10] = "a_m_m_golfer_01",
    [11] = "a_m_m_fatlatin_01",
    [12] = "a_m_m_eastsa_02",
    [13] = "a_m_m_prolhost_01",
    [14] = "a_m_m_socenlat_01",
    [15] = "a_m_m_skidrow_01",
    [16] = "a_m_m_trampbeac_01"
}

Config.DropOffLocations = {
    [1] = vector4(1168.91, -325.7, 69.3, 151.67),
    [2] = vector4(634.1, 247.49, 103.3, 25.3),
    [3] = vector4(288.4, -1273.98, 29.44, 71.36),
    [4] = vector4(-47.63, -1762.37, 29.41, 99.16),
    [5] = vector4(-704.68, -917.47, 19.21, 132.89),
    [6] = vector4(-44.44, -794.87, 44.23, 347.26),
    [7] = vector4(25.99, -1351.01, 29.33, 201.69),
    [8] = vector4(378.53, 320.11, 103.38, 139.13),
    [9] = vector4(-1425.67, -272.61, 46.26, 98.18)
}

-- Vehicle
Config.JobVehicleModel = "mule3"
Config.UseDeposit = true
Config.DepositAmount = 10000

Config.VehicleSpawnLocation = vector4(81.07, 95.39, 78.76, 67.7)

Config.ReturnDistance = 30
Config.UseReturnDistance = true

-- Misc
Config.MinPayout = 100
Config.MaxPayout = 300

-- Blips
Config.DropOffBlip = 103
Config.DropOffBlipScale = 0.65
Config.DropoffBlipColor = 3
Config.UseGpsRoute = true