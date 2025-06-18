local LayerTable = 
{
    TradingBankBuyLayer   = 60,             -- 交易行购买
    TradingBankSellLayer  = 61,             -- 交易行寄售
    TradingBankGoodsLayer = 62,             -- 交易行货架
    TradingBankMeLayer    = 63,             -- 交易行我的

    Trade                 = 601,            -- 交易
    StallLayer            = 602,            -- 摆摊界面

    PlayerLayer           = 101,            -- 装备
    PlayerStateLayer      = 102,            -- 状态
    PlayerAttLayer        = 103,            -- 属性
    PlayerSkillLayer      = 104,            -- 技能
    PlayerTitleLayer      = 106,            -- 称号
    PlayerSuperEquipLayer = 1011,           -- 时装
    PlayerBestRingLayer   = 105,            -- 极品首饰盒
    PlayerBuffLayer       = 120,            -- BUFF
    SkillSetting          = 1401,           -- 技能设置

    BagPanel              = 201,            -- 背包界面

    SettingBasic          = 300,            -- 基础设置
    SettingWindowRange    = 301,            -- 视距
    SettingFight          = 302,            -- 战斗
    SettingProtect        = 303,            -- 保护
    SettingAuto           = 304,            -- 挂机
    SettingHelp           = 305,            -- 帮助

    StoreHotLayer         = 901,             -- 商城热销页签
    StoreBeautyLayer      = 902,             -- 商城装饰页签
    StoreEngineLayer      = 903,             -- 商城功能页签
    StoreFestivalLayer    = 904,             -- 商城节日页签
    StoreRechargeLayer    = 905,             -- 充值

    RankLayer             = 501,            -- 排行榜

    GuildMain             = 1201,           -- 行会主界面
    GuildMember           = 1202,           -- 行会成员列表
    GuildList             = 1203,           -- 行会列表
    GuildApply            = 1204,           -- 行会申请
    GuildCreate           = 1205,           -- 行会创建

    Mail                  = 401,            -- 邮件 
    Friend                = 402,            -- 好友
    Team                  = 801,            -- 组队
    NearPlayer            = 802,            -- 附近玩家

    Dress                 = 2101,           -- 装扮
    Auction               = 1901,           -- 拍卖行
    MainButtonPosLayer    = 110,            -- 按钮位置
    CompoundLayer         = 2201,           -- 合成
    
    Box996Layer           = 2202,           -- 996传奇盒子

    InternalState         = 701,            -- 内功状态
    InternalSkill         = 702,            -- 内功技能
    InternalMeridian      = 703,            -- 内功经络
    InternalCombo         = 704,            -- 内功连击
}

return LayerTable