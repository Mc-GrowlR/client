local EquipPosTypeConfig = {
    --普通装备
    Equip_Type_Dress       = 0,            --// 衣服
    Equip_Type_Weapon      = 1,            --// 武器
    Equip_Type_RightHand   = 2,            --// 勋章
    Equip_Type_Necklace    = 3,            --// 项链
    Equip_Type_Helmet      = 4,            --// 头盔
    Equip_Type_ArmRingL    = 5,            --// 左手镯
    Equip_Type_ArmRingR    = 6,            --// 右手镯      左右以人物内观内的左右为标准
    Equip_Type_RingL       = 7,            --// 左戒指
    Equip_Type_RingR       = 8,            --// 右戒指
    Equip_Type_Bujuk       = 9,            --// 护身符位置 玉佩 宝珠
    Equip_Type_Belt        = 10,           --// 腰带
    Equip_Type_Boots       = 11,           --// 鞋子
    Equip_Type_Charm       = 12,           --// 宝石        
    Equip_Type_Cap         = 13,           --// 斗笠
    Equip_Type_LeftBottom  = 14,           --// 左下 军鼓
    Equip_Type_RightBottom = 15,           --// 右下 马牌
    Equip_Type_Shield      = 16,           --// 盾牌
    
    Equip_Type_Super_Dress = 17,           --// 神装衣服 --冰雪是神魔套装
    Equip_Type_Super_Weapon= 18,           --// 神装武器
    Equip_Type_Super_Cap   = 19,           --// 时装斗笠
    Equip_Type_Super_Necklace = 20,        --// 时装项链
    Equip_Type_Super_Helmet = 21,          --// 时装头盔
    Equip_Type_Super_ArmRingL = 22,        --// 时装左手镯
    Equip_Type_Super_ArmRingR = 23,        --// 时装右手镯
    Equip_Type_Super_RingL = 24,           --// 时装左戒指
    Equip_Type_Super_RingR = 25,           --// 时装右戒指
    Equip_Type_Super_RightHand = 26,       --// 时装勋章
    Equip_Type_Super_Belt = 27,            --// 时装腰带
    Equip_Type_Super_Boots = 28,           --// 时装靴子
    Equip_Type_Super_Charm = 29,           --// 时装宝石
    Equip_Type_Super_RightBottom = 42,     --// 时装马牌
    Equip_Type_Super_Bujuk = 43,           --// 时装符印
    Equip_Type_Super_LeftBottom = 44,      --// 时装军鼓
    Equip_Type_Super_Shield = 45,          --// 时装盾牌
    Equip_Type_Super_Veil = 46,            --// 时装面巾

    Equip_Type_BestRing1   = 30,           --// 极品首饰1
    Equip_Type_BestRing2   = 31,           --// 极品首饰2
    Equip_Type_BestRing3   = 32,           --// 极品首饰3
    Equip_Type_BestRing4   = 33,           --// 极品首饰4
    Equip_Type_BestRing5   = 34,           --// 极品首饰5
    Equip_Type_BestRing6   = 35,           --// 极品首饰6
    Equip_Type_BestRing7   = 36,           --// 极品首饰7
    Equip_Type_BestRing8   = 37,           --// 极品首饰8
    Equip_Type_BestRing9   = 38,           --// 极品首饰9
    Equip_Type_BestRing10  = 39,           --// 极品首饰10
    Equip_Type_BestRing11  = 40,           --// 极品首饰11
    Equip_Type_BestRing12  = 41,           --// 极品首饰12


    Equip_Type_Veil        = 55,           --// 面纱

    Equip_Type_Max         = 30,

    Equip_Special_RingL    = 47,            -- 特戒左
    Equip_Special_RingR    = 48,            -- 特戒右

    Equip_Fashion_Dress    = 49,            -- 时装衣服 --冰雪
    Equip_Fashion_Weapon   = 50,            -- 时装武器

    -- 71-100 后端发送，脚本自定义
}

local EquipPosByStdMode = {
    [5] = {EquipPosTypeConfig.Equip_Type_Weapon,},
    [6] = {EquipPosTypeConfig.Equip_Type_Weapon,},
    [7] = {EquipPosTypeConfig.Equip_Type_Charm,},
    [10] = {EquipPosTypeConfig.Equip_Type_Dress,},
    [11] = {EquipPosTypeConfig.Equip_Type_Dress,},
    [14] = {EquipPosTypeConfig.Equip_Type_Veil,},
    [15] = {EquipPosTypeConfig.Equip_Type_Helmet,},
    [16] = {EquipPosTypeConfig.Equip_Type_Cap,}, -- 斗笠 要加位置
    [19] = {EquipPosTypeConfig.Equip_Type_Necklace,},
    [20] = {EquipPosTypeConfig.Equip_Type_Necklace,},
    [21] = {EquipPosTypeConfig.Equip_Type_Necklace,},
    [22] = {EquipPosTypeConfig.Equip_Type_RingL,EquipPosTypeConfig.Equip_Type_RingR,},
    [23] = {EquipPosTypeConfig.Equip_Type_RingL,EquipPosTypeConfig.Equip_Type_RingR,},
    [24] = {EquipPosTypeConfig.Equip_Type_ArmRingL,EquipPosTypeConfig.Equip_Type_ArmRingR,},
    [25] = {EquipPosTypeConfig.Equip_Type_Bujuk,EquipPosTypeConfig.Equip_Type_ArmRingL},
    [26] = {EquipPosTypeConfig.Equip_Type_ArmRingL,EquipPosTypeConfig.Equip_Type_ArmRingR,},
    [28] = {EquipPosTypeConfig.Equip_Type_RightBottom,},
    [29] = {EquipPosTypeConfig.Equip_Type_RightHand,},
    [30] = {EquipPosTypeConfig.Equip_Type_RightHand,},
    [48] = {EquipPosTypeConfig.Equip_Type_Shield,},  -- 盾牌 加位置
    [51] = {EquipPosTypeConfig.Equip_Type_Bujuk,},
    [52] = {EquipPosTypeConfig.Equip_Type_Boots,},
    [53] = {EquipPosTypeConfig.Equip_Type_Charm,},
    [54] = {EquipPosTypeConfig.Equip_Type_Belt,},
    [62] = {EquipPosTypeConfig.Equip_Type_Boots,},
    [63] = {EquipPosTypeConfig.Equip_Type_Charm,},
    [64] = {EquipPosTypeConfig.Equip_Type_Belt,},
    [65] = {EquipPosTypeConfig.Equip_Type_LeftBottom,},
    -- [90] = {EquipPosTypeConfig.Equip_Type_Bujuk,},
    [96] = {EquipPosTypeConfig.Equip_Type_Bujuk,},
    [100] = {EquipPosTypeConfig.Equip_Type_BestRing1,},
    [101] = {EquipPosTypeConfig.Equip_Type_BestRing2,},
    [102] = {EquipPosTypeConfig.Equip_Type_BestRing3,},
    [103] = {EquipPosTypeConfig.Equip_Type_BestRing4,},
    [104] = {EquipPosTypeConfig.Equip_Type_BestRing5,},
    [105] = {EquipPosTypeConfig.Equip_Type_BestRing6,},
    [106] = {EquipPosTypeConfig.Equip_Type_BestRing7,},
    [107] = {EquipPosTypeConfig.Equip_Type_BestRing8,},
    [108] = {EquipPosTypeConfig.Equip_Type_BestRing9,},
    [109] = {EquipPosTypeConfig.Equip_Type_BestRing10,},
    [110] = {EquipPosTypeConfig.Equip_Type_BestRing11,},
    [111] = {EquipPosTypeConfig.Equip_Type_BestRing12,},

    [66] = {EquipPosTypeConfig.Equip_Type_Super_Dress,},
    [67] = {EquipPosTypeConfig.Equip_Type_Super_Dress,},
    [68] = {EquipPosTypeConfig.Equip_Type_Super_Weapon,},
    [69] = {EquipPosTypeConfig.Equip_Type_Super_Weapon,},
    [75] = {EquipPosTypeConfig.Equip_Type_Super_Necklace,},
    [76] = {EquipPosTypeConfig.Equip_Type_Super_Necklace,},
    [77] = {EquipPosTypeConfig.Equip_Type_Super_Necklace,},
    [78] = {EquipPosTypeConfig.Equip_Type_Super_Helmet,},
    [79] = {EquipPosTypeConfig.Equip_Type_Super_ArmRingL,EquipPosTypeConfig.Equip_Type_Super_ArmRingR,},
    [80] = {EquipPosTypeConfig.Equip_Type_Super_ArmRingL,EquipPosTypeConfig.Equip_Type_Super_ArmRingR,},
    [81] = {EquipPosTypeConfig.Equip_Type_Super_RingL,EquipPosTypeConfig.Equip_Type_Super_RingR,},
    [82] = {EquipPosTypeConfig.Equip_Type_Super_RingL,EquipPosTypeConfig.Equip_Type_Super_RingR,},
    [83] = {EquipPosTypeConfig.Equip_Type_Super_RightHand,},
    [84] = {EquipPosTypeConfig.Equip_Type_Super_Belt,},
    [85] = {EquipPosTypeConfig.Equip_Type_Super_Belt,},
    [86] = {EquipPosTypeConfig.Equip_Type_Super_Boots},
    [87] = {EquipPosTypeConfig.Equip_Type_Super_Boots,},
    [88] = {EquipPosTypeConfig.Equip_Type_Super_Charm,},
    [89] = {EquipPosTypeConfig.Equip_Type_Super_Charm,},
    [90] = {EquipPosTypeConfig.Equip_Type_Super_RightBottom,},
    [91] = {EquipPosTypeConfig.Equip_Type_Super_Bujuk,},
    [92] = {EquipPosTypeConfig.Equip_Type_Super_LeftBottom,},
    [93] = {EquipPosTypeConfig.Equip_Type_Super_Shield,},
    [94] = {EquipPosTypeConfig.Equip_Type_Super_Veil,},

    [50] = {EquipPosTypeConfig.Equip_Type_Veil},
    [71] = {EquipPosTypeConfig.Equip_Type_Super_Cap},

    [112] = {EquipPosTypeConfig.Equip_Special_RingL,EquipPosTypeConfig.Equip_Special_RingR,},

    [166] = {EquipPosTypeConfig.Equip_Fashion_Dress},
    [167] = {EquipPosTypeConfig.Equip_Fashion_Dress},
    [168] = {EquipPosTypeConfig.Equip_Fashion_Weapon},
    [169] = {EquipPosTypeConfig.Equip_Fashion_Weapon},

}



-- 用于装备界面中一个部位可以实现穿戴多个部位， 纯显示上
-- 禁止用于一个stdmode 穿多个位置 要实现这个 用上面的
local EquipPosMapping = {
    [EquipPosTypeConfig.Equip_Type_Helmet] = {
        EquipPosTypeConfig.Equip_Type_Cap,
        EquipPosTypeConfig.Equip_Type_Veil,
        EquipPosTypeConfig.Equip_Type_Helmet,
    },  --斗笠在显示上为在头盔位置
    [EquipPosTypeConfig.Equip_Type_Super_Helmet] = {
        EquipPosTypeConfig.Equip_Type_Super_Cap,
        EquipPosTypeConfig.Equip_Type_Super_Veil,
        EquipPosTypeConfig.Equip_Type_Super_Helmet,
    }
}

local EquipSexNeed = {
    [10] = global.MMO.ACTOR_PLAYER_SEX_M,
    [11] = global.MMO.ACTOR_PLAYER_SEX_F,
    [66] = global.MMO.ACTOR_PLAYER_SEX_M,
    [67] = global.MMO.ACTOR_PLAYER_SEX_F,
}

local EquipHandWeightType = {
    [5] = 1,
    [6] = 1
}

-- tips对比判断  首先找这里  没有再找EquipPosByStdMode
local TipsEquipPosByStdMode = {
    [25] = {EquipPosTypeConfig.Equip_Type_Bujuk}
}

local EquipPosData = {
    EquipPosByStdMode = EquipPosByStdMode,
    EquipPosTypeConfig = EquipPosTypeConfig,
    EquipPosMapping = EquipPosMapping,
    EquipSexNeed = EquipSexNeed,
    EquipHandWeightType = EquipHandWeightType,
    EquipPosByStdModeTemp = clone(EquipPosByStdMode),
    TipsEquipPosByStdMode = TipsEquipPosByStdMode
}
return EquipPosData