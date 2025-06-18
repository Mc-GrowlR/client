local EquipPosData = requireConfig("EquipPosTypeConfig")
local EquipMapByStdMode = {}

for stdMode,humPos in pairs(EquipPosData.EquipPosByStdMode or {}) do
    EquipMapByStdMode[stdMode] = true
end

local DuraMapByShap = {
    [0] = true,
    [1] = true,
    [3] = true
}

local ItemsShowLasting = { --除了上述EquipMapByStdMode装备显示 5 6 武器 11 12 衣服 30照明物
    [5] = true,
    [6] = true,
    [11] = true,
    [12] = true,
    [30] = true,
}

local QuickUseStdMode = {
    [0] = true,
    [2] = true,
    [3] = true,
}

--生肖
local BestRingMapByStdMode = {
    [100]=true,
    [101]=true,
    [102]=true,
    [103]=true,
    [104]=true,
    [105]=true,
    [106]=true,
    [107]=true,
    [108]=true,
    [109]=true,
    [110]=true,
    [111]=true,
}

local ItemsConfig = {
    DuraMapByShap = DuraMapByShap,
    EquipMapByStdMode = EquipMapByStdMode,
    QuickUseStdMode = QuickUseStdMode,
    ItemsShowLasting = ItemsShowLasting,
    BestRingMapByStdMode = BestRingMapByStdMode,
    EquipMapByStdModeTemp = clone(EquipMapByStdMode),
}

return ItemsConfig