local config = 
{
    outlineSize                 = 1,
    DEFAULT_FONT_SIZE           = (global.isWinPlayMode and 12 or 16),  -- edit on active
    DEFAULT_FONT_SIZE_NOTICE    = 14,
    DEFAULT_VSPACE              = (global.isWinPlayMode and 2 or 4),
    SCENE_FONT_SIZE             = 12,
    SCENE_FONT_SIZE_PC          = 12,
    
    -- auto find npc/monster range
    AutoMoveRange_NPC           = 1,
    AutoMoveRange_Monster       = 2,
    AutoMoveRange_Collection    = 1,
    
    -- check joystick move range
    Joystick_Check_Range        = 3,
    
    FindDropItemRange           = 9,       -- 寻找掉落物的范围
    FindRange_Collection        = 3,       -- 搜索采集物范围
    
    gameOption_WalkOnly         = 0,       -- 是否开启走代替跑
    
    -- framerate
    FrameRateFade               = 20,      -- 低帧率框多久自动隐藏
    FrameRateInterval           = 120,     -- 低帧率框弹出间隔
    
    -- scene options
    unkown_model                = "17#22#2#1001|18#21#2#1001|19#20#2#1001",
    
    PickupTime                  = 200,
    
    
    cityStone                   = {},       
    randStone                   = {},
    drugHY                      = {},
    drugLY                      = {},
    drugSHY                     = {},
    allDrugPack                 = {},
    fixItemDrug                 = {},
    Progressbarmode             = 0,
    showFewHp                   = 0,
    dark                        = 0,

    FrameWidth                  = 790,      -- 通用界面的 宽
    FrameHeight                 = 536,      -- 通用界面的 高
    ContentWidth                = 732,      -- 挂接区域的 宽
    ContentHeight               = 445,      -- 挂接区域的 高
    ContentHookX                = 30,       -- 挂接区域的 x
    ContentHookY                = 40,       -- 挂接区域的 y
}

return config
