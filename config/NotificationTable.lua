local NoticeTable =
{
    -- start notice
    StartUp                               = "StartUp",                                    -- 框架启动

    -- state trigger
    ChangeGameState                       = "ChangeGameState",                            -- 切换游戏状态
    EndGameState                          = "EndGameState",                               -- 退出当前状态
    
    LoadingBegin                          = "LoadingBegin",                               -- loading开始
    LoadingCompleted                      = "LoadingCompleted",                           -- loading完成
    PreloadBegin                          = "PreloadBegin",                               -- 预加载开始
    GameWorldConfirm                      = "GameWorldConfirm",                           -- 游戏确认进入
    GameWorldCheckTimeout                 = "GameWorldCheckTimeout",                      -- 游戏确认进入超时
    GameWorldInfoInitBegin                = "GameWorldInfoInitBegin",                     -- 游戏必要的数据初始化，比Init先到
    GameWorldInfoInit                     = "GameWorldInfoInit",                          -- 游戏必要的数据初始化
    GameWorldInitComplete                 = "GameWorldInitComplete",                      -- 游戏必要的数据初始化 完成
    GameWorldLoadinTipsTimeout            = "GameWorldLoadinTipsTimeout",                 -- 游戏获取公告超时
    GameWorldLoadinTipsFinish             = "GameWorldLoadinTipsFinish",                  -- 游戏公告获取完成

    GameResumed                           = "GameResumed",                                -- 游戏从后台恢复
    GameSuspend                           = "GameSuspend",                                -- 游戏挂起到后台

    RegisterWorldController               = "RegisterWorldController",                    -- 注册world Controller
    RegisterWorldMediator                 = "RegisterWorldMediator",                      -- 注册world Mediator
    RegisterWorldProxy                    = "RegisterWorldProxy",                         -- 注册world Proxy
    UnRegisterWorldController             = "UnRegisterWorldController",                  -- 注销world Controller
    UnRegisterWorldMediator               = "UnRegisterWorldMediator",                    -- 注销world Mediator
    UnRegisterWorldProxy                  = "UnRegisterWorldProxy",                       -- 注销world Proxy

    RestartGame                           = "RestartGame",                                -- 重启游戏
    ReleaseMemory                         = "ReleaseMemory",                              -- 释放内存
    EnterLogin                            = "EnterLogin",                                 -- 进入登录
    LeaveRole                             = "LeaveRole",                                  -- 离开角色
    LeaveWorld                            = "LeaveWorld",                                 -- 离开游戏世界，返回角色界面
    RequestLeaveWorld                     = "RequestLeaveWorld",                          -- 请求 离开游戏世界，返回角色界面

    -- func notice
    ChangeResolution                      = "ChangeResolution",                           -- 改变设计分辨率
    WindowResized                         = "WindowResized",                              -- 改变Window大小
    DRotationChanged                      = "DRotationChanged",                           -- 设备刘海屏方向改变
    
    DeviceRotationChanged                 = "DeviceRotationChanged",                      -- 设备方向改变

    -- shader
    GrayNodeShader                        = "GrayNodeShader",                             -- 把某个node渲染成灰色
    NormalNodeShader                      = "NormalNodeShader",                           -- 把某个node按正常渲染
    HighLightNodeShader                   = "HighLightNodeShader",                        -- 把某个node按高亮渲染


    -- auto state
    AFKBegin                              = "AFKBegin",                                 -- 开始 挂机
    AFKEnd                                = "AFKEnd",                                   -- 结束 挂机
    AutoFightBegin                        = "AutoFightBegin",                           -- 开始 自动战斗
    AutoFightEnd                          = "AutoFightEnd",                             -- 结束 自动战斗
    AutoMoveBegin                         = "AutoMoveBegin",                            -- 开始 自动寻路
    AutoMoveEnd                           = "AutoMoveEnd",                              -- 结束 自动寻路
    AutoFindNPC                           = "AutoFindNPC",                              -- 自动 锁定NPC
    AutoFindMonster                       = "AutoFindMonster",                          -- 自动 锁定怪
    AutoFindPlayer                        = "AutoFindPlayer",                           -- 自动 锁定人物
    AutoFindCollection                    = "AutoFindCollection",                       -- 自动 锁定采集物
    AutoFindDropItem                      = "AutoFindDropItem",                         -- 自动 锁定掉落物
    LaunchAttackSkill                     = "LaunchAttackSkill",                        -- 自动 释放强攻技能

    ClearAllInputState                    = "ClearAllInputState",                       -- 清理 输入状态
    ClearAllAutoState                     = "ClearAllAutoState",                        -- 清理 自动状态
    AutoPickBegin                         = "AutoPickBegin",                            -- 开始 自动捡物
    AutoPickEnd                           = "AutoPickEnd",                              -- 结束 自动捡物
    AutoPickBeginTips                     = "AutoPickBeginTips",                        -- 开始 自动捡物 tips
    AutoPickEndTips                       = "AutoPickEndTips",                          -- 结束 自动捡物 tips
    PickupModeUpdate                      = "PickupModeUpdate",                         -- 自动捡物模式
    AutoFightBack                         = "AutoFightBack",                            -- 自动反击


    -- scene
    ShakeScene                            = "ShakeScene",                               -- 抖动场景
    RefreshActorSceneOptions              = "RefreshActorSceneOptions",                 -- 刷新一个角色的场景选项
    RefreshOneActorCloth                  = "RefreshOneActorCloth",                     -- 刷新一个角色的外观
    ShowThrowDamage                       = "ShowThrowDamage",                          -- 显示飘血(添加到队列)
    MapPickCursorPosChange                = "MapPickCursorPosChange",                   -- 场景点击特效


    -- actor action
    ActorEnterIdleAction                  = "ActorEnterIdleAction",                     -- 进入idle状态
    ActorEnterWalkAction                  = "ActorEnterWalkAction",                     -- 进入walk状态
    ActorEnterRunAction                   = "ActorEnterRunAction",                      -- 进入run状态
    ActorEnterAttackAction                = "ActorEnterAttackAction",                   -- 进入attack状态
    ActorEnterSkillAction                 = "ActorEnterSkillAction",                    -- 进入skill状态


    -- input
    InputIdle                             = "InputIdle",
    InputLaunch                           = "InputLaunch",
    InputMove                             = "InputMove",
    InputCorpse                           = "InputCorpse",
    InputMining                           = "InputMining",
    UserInputMove                         = "UserInputMove",                            -- 手动 发起移动
    UserInputLaunch                       = "UserInputLaunch",                          -- 手动 释放技能
    UserInputCorpse                       = "UserInputCorpse",                          -- 手动 挖尸体
    UserInputMining                       = "UserInputMining",                          -- 手动 挖矿
    UserPressedShift                      = "UserPressedShift",                         -- shift按下
    UserReleaseShift                      = "UserReleaseShift",                         -- shift抬起
    TargetChange                          = "TargetChange",                             -- 目标改变

    --keep touch moving
    keepMovingBegin                       = "keepMovingBegin",                          -- 左右键触摸按住移动
    keepMovingUpdate                      = "keepMovingUpdate",
    keepMovingEnded                       = "keepMovingEnded",

    -- mouse move with actor events
    MouseMoveOutActorSide                 = "MouseMoveOutActorSide",                      -- 鼠标移出某个对象
    MouseMoveInActorSide                  = "MouseMoveInActorSide",                       -- 鼠标移入某个对象

    -- actor
    BindMainPlayer                        = "BindMainPlayer",                           -- 绑定主玩家
    ActorDie                              = "ActorDie",                                 -- actor 死亡
    ActorRevive                           = "ActorRevive",                              -- actor 复活
    ActorPlayerDie                        = "ActorPlayerDie",                           -- player 死亡
    ActorMonsterDie                       = "ActorMonsterDie",                          -- monster 死亡
    ActorMonsterDeath                     = "ActorMonsterDeath",                        -- monster 死亡
    ActorMonsterBorn                      = "ActorMonsterBorn",                         -- monster 出生
    ActorMonsterBirth                     = "ActorMonsterBirth",                        -- monster 出生完成
    ActorMonsterCave                      = "ActorMonsterCave",                         -- monster 钻回地下
    ActorMonsterCaved                     = "ActorMonsterCaved",                        -- monster 钻回地下，完成
    ActorOutOfView                        = "ActorOutOfView",                           -- actor 从视野消失
    ActorInOfView                         = "ActorInOfView",                            -- actor 进入视野
    NpcInOfView                           = "NpcInOfView",                              -- NPC进入视野
    NpcOutOfView                          = "NpcOutOfView",                             -- NPC出视野
    DropItemOutOfView                     = "DropItemOutOfView",                        -- 掉落物 从视野消失
    DropItemInOfView                      = "DropItemInOfView",                         -- 掉落物 进入视野
    RefreshDropItem                       = "RefreshDropItem",                          -- 刷新掉落物信息
    ActorFeatureChange                    = "ActorFeatureChange",                       -- actor 外观改变
    MainPlayerDie                         = "MainPlayerDie",                            -- 主玩家死亡
    MainPlayerRevive                      = "MainPlayerRevive",                         -- 主玩家复活
    ActorSay                              = "ActorSay",                                 -- actor 说话
    RefreshActorBooth                     = "RefreshActorBooth",                        -- 摆摊名字改变
    PlayerStallStatucChange               = "PlayerStallStatucChange",                  -- 摆摊状态改变
    RefreshActorSafeZone                  = "RefreshActorSafeZone",                     -- 安全区状态
    ActorSafeZoneChange                   = "ActorSafeZoneChange",                      -- 安全区状态发生改变
    ActorMoveForce                        = "ActorMoveForce",                           -- actor 强制刷新位置
    ActorEffectOutOfView                  = "ActorEffectOutOfView",                     -- 特效出视野
    ActorEffectInOfView                   = "ActorEffectInOfView",                      -- 特效进入视野
    ActorMapXYChange                      = "ActorMapXYChange",                           -- actor map位置更改
    RefreshActorShaBaKeZone               = "RefreshActorShaBaKeZone",                  -- 沙巴克区域
    RefreshActorNameColor                 = "RefreshActorNameColor",                    -- 刷新actor名字颜色
    RefreshGuildActorColor                = "RefreshGuildActorColor",                   -- 刷新行会actor名字颜色
    
    -- actor feature
    SetPlayerFeature                      = "SetPlayerFeature",                         -- 设置player实际外观参数
    SetPlayerFeatureEX                    = "SetPlayerFeatureEX",                       -- 设置player要显示的外观参数(0:means cleanup)

    -- actor effect
    ActorCollect                          = "ActorCollect",                             -- actor 采集标志
    ActorFlyIn                            = "ActorFlyIn",                               -- actor 飞入
    ActorFlyOut                           = "ActorFlyOut",                              -- actor 飞出

    -- actor buff
    AddBuffEntity                         = "AddBuffEntity",
    ActorBuffPresentUpdate                = "ActorBuffPresentUpdate",
    BuffEntitiesChange                    = "BuffEntitiesChange",
    RefreshBuffVisible                    = "RefreshBuffVisible",

    -- HUD
    RefreshHUDLabel                       = "RefreshHUDLabel",                          -- HUD label 刷新
    RefreshHUDTitle                       = "RefreshHUDTitle",                          -- HUD title 刷新
    RefreshActorHP                        = "RefreshActorHP",                           -- 刷新 actor HP
    RefreshHUDHP                          = "RefreshHUDHP",
    RefreshActorIForce                    = "RefreshActorIForce",                       -- 刷新 actor 内力值

    -- delay refresh
    DelayRefreshHUDLabel                  = "DelayRefreshHUDLabel",                     -- 
    DelayRefreshHUDTitle                  = "DelayRefreshHUDTitle",                     -- 
    DelayActorFeatureChange               = "DelayActorFeatureChange",
    DelayCreateHUDBar                     = "DelayCreateHUDBar",
    DelayDirtyFeature                     = "DelayDirtyFeature",

    RefreshMoveInView                     = "RefreshMoveInView",                        -- 视野内怪物移动刷新 actor 显示

    QuickSelectTarget                     = "QuickSelectTarget",                        -- 快速选择目标

    -- summons alive status
    SummonsAliveStatusChange              = "SummonsAliveStatusChange",                 -- 召唤物存活状态更新


    -- audio
    Audio_Play                            = "Audio_Play",                               -- 播放音频( 背景音乐、音效 )
    Audio_Play_BGM                        = "Audio_Play_BGM",                           -- 播放背景音乐
    Audio_Stop_BGM                        = "Audio_Stop_BGM",                           -- 关闭背景音乐
    Audio_Play_EffectId                   = "Audio_Play_EffectId",                      -- 播放音效
    Audio_Pause_All                       = "Audio_Pause_All",                          -- 暂停所有音效
    Audio_Resume_All                      = "Audio_Resume_All",                         -- 恢复所有音效
    Audio_Stop_All                        = "Audio_Stop_All",                           -- 停止所有音效
    Audio_Stop_EffectId                   = "Audio_Stop_EffectId",                      -- 停止对应音效

    -- ++++++++++++++++++++++++ model notice ++++++++++++++++++++++++
    -- 角色属性
    PlayerPropertyChange                    = "PlayerPropertyChange",                       -- 角色属性发生改变
    PlayerPKModeChange                      = "PlayerPKModeChange",                         -- 角色 PK State 发生改变
    PlayerPropertyInited                    = "PlayerPropertyInited",                       -- 主角属性初始化完毕
    PlayerExpChange                         = "PlayerExpChange",                            -- 角色 经验发生改变
    PlayerManaChange                        = "PlayerManaChange",                           -- 角色 hp/mp 发生改变
    PlayerLevelChange                       = "PlayerLevelChange",                          -- 角色 等级 发生改变
    PlayerBeDamaged                         = "PlayerBeDamaged",                            -- 角色被攻击(掉血了)
    PlayerWeightChange                      = "PlayerWeightChange",                         -- 角色负重发生变化
    PlayerMoneyChange                       = "PlayerMoneyChange",                          -- 角色 money 发生改变
    PlayerMapPosChange                      = "PlayerMapPosChange",                         -- 角色 地图坐标 发生变化
    PlayerLevelInit                         = "PlayerLevelInit",                            -- 角色等级初始化  红点用
    
    -- 充值
    PayProductRequest                       = "PayProductRequest",                          -- 充值

    TakeOnRequest                         = "TakeOnRequest",                            -- 穿装备    请求
    TakeOffRequest                        = "TakeOffRequest",                           -- 脱装备    请求
    TakeOnResponse                        = "TakeOnResponse",                           -- 穿装备    返回
    TakeOffResponse                       = "TakeOffResponse",                          -- 脱装备    返回
    
    Layer_Player_Open                     = "Layer_Player_Open",                        --人物主界面
    Layer_Player_Close                    = "Layer_Player_Close",                       --人物主界面关闭
    Layer_PlayerFrame_Load_Success        = "Layer_PlayerFrame_Load_Success",           --人物主面板加载完成
    Layer_Player_Child_Del                = "Layer_Player_Child_Del",
    Layer_Player_Equip_Open               = "Layer_Player_Equip_Open",                  --装备面板
    Layer_Player_Equip_State_Change       = "Layer_Player_Equip_State_Change",          --装备状态状态刷新
    Layer_Player_Equip_Load_Success       = "Layer_Player_Equip_Load_Success",          --装备面板加载完成
    Layer_Player_Base_Att_Open            = "Layer_Player_Base_Att_Open",               --基础属性面板
    Layer_Player_Extra_Att_Open           = "Layer_Player_Extra_Att_Open",              --额外属性面板
    Layer_Player_Skill_Open               = "Layer_Player_Skill_Open",                  --技能面板
    Layer_PlayerBestRing_Open             = "Layer_PlayerBestRing_Open",                --极品首饰面板开启
    Layer_PlayerBestRing_Close            = "Layer_PlayerBestRing_Close",               --极品首饰面板关闭
    Layer_PlayerBestRing_State            = "Layer_PlayerBestRing_State",               --极品首饰面板开启状态
    Layer_Player_Super_Equip_Open         = "Layer_Player_Super_Equip_Open",            --时装面板
    Layer_Player_Buff_Open                = "Layer_Player_Buff_Open",                   --buff面板


    -- 技能相关
    RequestLaunchSkill                    = "RequestLaunchSkill",                       -- 请求释放技能
    RequestSkillPresent                   = "RequestSkillPresent",                      -- 请求技能表现
    SkillAdd                              = "SkillAdd",                                 -- 新增 技能
    SkillDel                              = "SkillDel",                                 -- 删除 技能
    SkillUpdate                           = "SkillUpdate",                              -- 技能更新
    SkillDeleteKey                        = "SkillDeleteKey",                           -- 技能删除快捷键
    SkillChangeKey                        = "SkillChangeKey",                           -- 技能改变快捷键
    SkillEnterCD                          = "SkillEnterCD",                             -- 技能进入CD
    SkillCDTimeChange                     = "SkillCDTimeChange",                        -- 技能cd改变广播
    ClearSelectSkill                      = "ClearSelectSkill",
    SkillOn                               = "SkillOn",                                  -- 技能开启
    SkillOff                              = "SkillOff",                                 -- 技能关闭
    ComboSkillEnterCD                     = "ComboSkillEnterCD",                        -- 连击技能进入CD
    ComboSkillCDTimeChange                = "ComboSkillCDTimeChange",                   -- 连击技能CD改变广播

    -- 地图相关
    MapStateChange                        = "MapStateChange",                           -- 是否是安全区域
    MapInfoChange                         = "MapInfoChange",                            -- 地图信息改变
    ChangeScene                           = "ChangeScene",                              -- 地图信息改变,类似于MapInfoChange
    InitedWorldTree                       = "InitedWorldTree",                          -- 初始化游戏树
    SiegeAreaChange                       = "SiegeAreaChange",                          -- 攻城区域改变
    SceneFollowMainPlayer                 = "SceneFollowMainPlayer",                    -- 地图跟随主玩家刷新

    -- for debug
    DebugMapOpen                          = "DebugMapOpen",                             -- 调试地图 打开
    DebugMapClose                         = "DebugMapClose",                            -- 调试地图 关闭
    DebugMapSwitch                        = "DebugMapSwitch",                           -- 调试地图信息 开关

    PreviewAnimOpen                       = "PreviewAnimOpen",                          -- 预览动画 界面打开
    PreviewAnimClose                      = "PreviewAnimClose",                         -- 预览动画 界面关闭
    AnimSetOpen                           = "AnimSetOpen",                              -- 预览动画设置 打开
    AnimSetClose                          = "AnimSetClose",                             -- 预览动画设置 关闭

    -- picker相关
    PickerChange                          = "PickerChange",                             -- picker改变

    MainPlayerActionBegan                 = "MainPlayerActionBegan",                    -- 动作 开始
    MainPlayerActionEnded                 = "MainPlayerActionEnded",                    -- 动作 结束
    MainPlayerActionProcess               = "MainPlayerActionProcess",                  -- 动作进行中

    -- ++++++++++++++++++++++++ model notice end ++++++++++++++++++++++++

    -- layer facade  所有的界面的开关都应发这2个通知
    Layer_Open                            = "Layer_Open",                                 -- 某个界面打开
    Layer_Close                           = "Layer_Close",                                -- 某个关闭
    Layer_Close_Current                   = "Layer_Close_Current",                        -- 关闭当前界面
    Layer_Enter_Current                   = "Layer_Enter_Current",                        -- 确认当前界面
    Layer_SetMoveEnable                   = "Layer_SetMoveEnable",                        -- 设置界面可拖动
    Layer_HideMainEvent                   = "Layer_HideMainEvent",                        -- 隐藏主界面通知
    Layer_SetZOrderPanel                  = "Layer_SetZOrderPanel",                       -- 设置界面点击浮起块

    -- ++++++++++++++++++++++++ layer notice ++++++++++++++++++++++++

    -- 提示信息
    ShowServerNotice                      = "ShowServerNotice",                           -- 全服公告
    ShowSystemNotice                      = "ShowSystemNotice",                           -- 系统公告
    ShowTimerNotice                       = "ShowTimerNotice",                            -- 倒计时
    DeleteTimerNotice                     = "DeleteTimerNotice",                          -- 删除倒计时公告
    ShowChatExNotice                      = "ShowChatExNotice",                           -- 固定聊天
    ShowSystemNoticeXY                    = "ShowSystemNoticeXY",
    ShowSystemNoticeScale                 = "ShowSystemNoticeScale",
    ShowTimerNoticeXY                     = "ShowTimerNoticeXY",
    DeleteTimerNoticeXY                   = "DeleteTimerNoticeXY",
    ServerNoticeEvent                     = "ServerNoticeEvent",
    SystemTips                            = "SystemTips",                                 -- 系统 提示信息(中间位置)
    ShowCostItem                          = "ShowCostItem",                               -- 消耗物品提示
    ShowGetBagItem                        = "ShowGetBagItem",                             -- 获得物品提示
    ShowPlayerEXPNotice                   = "ShowPlayerEXPNotice",                        -- 获取经验提示XY
    Layer_Notice_Open                     = "Layer_Notice_Open",                          -- 通知 打开
    Layer_Notice_Close                    = "Layer_Notice_Close",                         -- 通知 关闭
    Layer_Notice_AddChild                 = "Layer_Notice_AddChild",
    Layer_Notice_RemoveChild              = "Layer_Notice_RemoveChild",
    Layer_Notice_Attribute                = "Layer_Notice_Attribute",

    -- main layer
    Layer_Main_Open                       = "Layer_Main_Open",                          -- 打开主界面
    Layer_Main_Init                       = "Layer_Main_Init",                          -- 初始化主界面
    Layer_Main_AddChild                   = "Layer_Main_AddChild",                      -- 添加view元素
    Layer_Main_Show                       = "Layer_Main_Show",                          -- 显示主界面
    Layer_Main_Hide                       = "Layer_Main_Hide",                          -- 隐藏主界面

    Skill_PanelActive_AddChild            = "Skill_PanelActive_AddChild",
    Skill_PanelSkill_AddChild             = "Skill_PanelSkill_AddChild",

    -- main assist - mission
    Layer_Assist_MissionAdd               = "Layer_Assist_MissionAdd",                  -- 主界面-辅助-任务改变
    Layer_Assist_MissionRemove            = "Layer_Assist_MissionRemove",               -- 主界面-辅助-任务改变
    Layer_Assist_MissionChange            = "Layer_Assist_MissionChange",               -- 主界面-辅助-任务改变
    Layer_Assist_MissionTop               = "Layer_Assist_MissionTop",                  -- 主界面-辅助-任务置顶
    Layer_Assist_Show                     = "Layer_Assist_Show",
    Layer_Assist_Hide                     = "Layer_Assist_Hide",
    Layer_Assist_HideMission              = "Layer_Assist_HideMission",
    Layer_Assist_ShowMission              = "Layer_Assist_ShowMission",
    Layer_Assist_ChangeHide               = "Layer_Assist_ChangeHide",

    -- main win32
    Layer_MainMiniMapWin32_Tab            = "Layer_MainMiniMapWin32_Tab",

    Layer_Main_JoystickUpdate             = "Layer_Main_JoystickUpdate",                  -- 摇杆走跑切换

    -- collect
    CollectVisible                        = "CollectVisible",                             -- 自动 采集相关显示
    CollectBegin                          = "CollectBegin",                               -- 采集 开始
    CollectCompleted                      = "CollectCompleted",                           -- 采集 完成
    CollectCheckInview                    = "CollectCheckInview",

    Layer_RTouch_Open                     = "Layer_RTouch_Open",                        -- 主界面右键触发层
    
    Layer_RTouch_State_Change             = "Layer_RTouch_State_Change",                -- 改变下当前状态
    Layer_Moved_Open                      = "Layer_Moved_Open",                         -- 加载拖动层
    Layer_Moved_Begin                     = "Layer_Moved_Begin",                        -- 开始拖动
    Layer_Moved_Moving                    = "Layer_Moved_Moving",                       -- 更新拖动
    Layer_Moved_End                       = "Layer_Moved_End",                          -- 结束拖动
    Layer_Moved_Cancel                    = "Layer_Moved_Cancel",                       -- 取消拖动
    Layer_Moved_UpDate                    = "Layer_Moved_UpDate",                       -- 更新部分数据
    Layer_Moved_Cancel_Notice             = "Layer_Moved_Cancel_Notice",                -- 广播更新拖动取消 对应节点做状态更新
    Item_Move_begin_On_BagPosChang        = "Item_Move_begin_On_BagPosChang",           -- 道具换位后开始拖动
    Item_Move_cancel_On_BagPosChang       = "Item_Move_cancel_On_BagPosChang",          -- 道具移动中取消操作

    -- main menu 功能菜单
    BattreyChange                         = "BattreyChange",                              -- 电量改变
    NetStateChange                        = "NetStateChange",                             -- 网络状态

    -- auth 
    AuthRegisterSuccess                   = "AuthRegisterSuccess",                        -- 授权中心-注册成功
    AuthLoginSuccess                      = "AuthLoginSuccess",                           -- 授权中心-登录成功
    AuthVisitorSuccess                    = "AuthVisitorSuccess",                         -- 授权中心-游客注册成功
    AuthCheckTokenSuccess                 = "AuthCheckTokenSuccess",                      -- 授权中心-token验证成功
    AuthCheckTokenFailure                 = "AuthCheckTokenFailure",                      -- 授权中心-token验证失败
    AuthChangePwdResp                     = "AuthChangePwdResp",                          -- 授权中心-修改密码成功
    AuthChangePwdByPhoneResp              = "AuthChangePwdByPhoneResp",                   -- 授权中心-手机号修改密码成功
    AuthChangeMbResp                      = "AuthChangeMbResp",                           -- 授权中心-修改密保成功
    AuthBindPhoneResp                     = "AuthBindPhoneResp",                          -- 授权中心-手机号绑定成功

    --
    Layer_Login_Server_Open               = "Layer_Login_Server_Open",                    -- 选择服务器 打开
    Layer_Login_Server_Close              = "Layer_Login_Server_Close",                   -- 选择服务器 关闭
    RequestLoginServer                    = "RequestLoginServer",                         -- 请求游服 
    LoginServerSuccess                    = "LoginServerSuccess",                         -- 请求游服 成功
    
    -- account login layer
    Layer_Login_Account_Open              = "Layer_Login_Account_Open",                   -- 登录界面 打开
    Layer_Login_Account_Close             = "Layer_Login_Account_Close",                  -- 登录界面 关闭

    Layer_Login_Role_Open                 = "Layer_Login_Role_Open",                      -- 角色 打开
    Layer_Login_Role_Close                = "Layer_Login_Role_Close",                     -- 角色 关闭
    Layer_Login_Role_Update               = "Layer_Login_Role_Update",                    -- 角色 更新
    Layer_Login_Role_RandNameResp         = "Layer_Login_Role_RandNameResp",              -- 创建角色 取名
    Layer_Login_Role_RestoreSuccess       = "Layer_Login_Role_RestoreSuccess",            -- 恢复角色 成功
    Layer_Login_Role_EnterGame_Delay      = "Layer_Login_Role_EnterGame_Delay",           -- 角色 重登延迟    

    Layer_Login_Version_Open              = "Layer_Login_Version_Open",                   -- 版本号 打开
    Layer_Login_Version_Close             = "Layer_Login_Version_Close",                  -- 版本号 关闭
    
    Layer_LoadingBar_Open                 = "Layer_LoadingBar_Open",                      -- 菊花转 显示
    Layer_LoadingBar_Close                = "Layer_LoadingBar_Close",

    -- chat 聊天
    Layer_Chat_Open                       = "Layer_Chat_Open",
    Layer_Chat_Close                      = "Layer_Chat_Close",
    Layer_Chat_PushInput                  = "Layer_Chat_PushInput",
    Layer_Chat_ReplaceInput               = "Layer_Chat_ReplaceInput",
    SendChatMsg                           = "SendChatMsg",
    AddChatItem                           = "AddChatItem",
    RemoveChatItem                        = "RemoveChatItem",    
    PrivateChatWithTarget                 = "PrivateChatWithTarget",   
    ChatTargetChange                      = "ChatTargetChange",
    AddChatExItem                         = "AddChatExItem",                              -- 固定聊天的数据
    Chat_Refresh_Mobile_AutoShout         = "Chat_Refresh_Mobile_AutoShout",              -- 聊天  移动端自动喊话
    Layer_Chat_RemoveItem                 = "Layer_Chat_RemoveItem",

    Layer_ChatMini_AddItem                = "Layer_ChatMini_AddItem",                     -- Mini聊天 新增一条
    Layer_ChatMini_RemoveItem             = "Layer_ChatMini_RemoveItem",                  -- Mini聊天 删 通过发送者id 
    BubbleTipsStatusChange                = "BubbleTipsStatusChange",                     -- 气泡提醒

    Layer_ChatExtend_Open                 = "Layer_ChatExtend_Open",
    Layer_ChatExtend_Close                = "Layer_ChatExtend_Close",
    Layer_ChatExtend_Exit                 = "Layer_ChatExtend_Exit",

    -- buff 
    ForbiddenMoveBuffBegan                = "ForbiddenMoveBuffBegan",
    ForbiddenMoveBuffEnd                  = "ForbiddenMoveBuffEnd",

    
    -- guide 引导
    Layer_Guide_Open                      = "Layer_Guide_Open",
    Layer_Guide_Close                     = "Layer_Guide_Close",
    GuideStart                            = "GuideStart",
    GuideStop                             = "GuideStop",
    GuideEventBegan                       = "GuideEventBegan",
    GuideEventEnded                       = "GuideEventEnded",
    GuideEnterTransition                  = "GuideEnterTransition",
    
    --map minimap 小地图
    Layer_MiniMap_Open                    = "Layer_MiniMap_Open",                       -- 小地图 打开
    Layer_MiniMap_Close                   = "Layer_MiniMap_Close",                      -- 小地图 关闭
    FindPathPointsBegin                   = "FindPathPointsBegin",
    FindPathPointsEnd                     = "FindPathPointsEnd",
    MiniMap_Download_Success              = "MiniMap_Download_Success",
    MapData_Load_Success                  = "MapData_Load_Success",                     --地图数据加载完成
    Map_Refresh_Throug_HHum               = "Map_Refresh_Throug_HHum",                  -- 刷新地图的穿人穿怪
    
    -- 进入游戏公告
    Layer_GameWorldConfirm_Open           = "Layer_GameWorldConfirm_Open",
    Layer_GameWorldConfirm_Close          = "Layer_GameWorldConfirm_Close",
    Layer_GameWorldConfirm_Update         = "Layer_GameWorldConfirm_Update",

    -- 通用消耗
    AddCostItemCell                       = "AddCostItemCell",
    RmvCostItemCell                       = "RmvCostItemCell",

    -- 技能设置
    Layer_SkillSetting_Open               = "Layer_SkillSetting_Open",
    Layer_SkillSetting_Close              = "Layer_SkillSetting_Close",

    -- 充值
    Layer_Recharge_Open                   = "Layer_Recharge_Open",
    Layer_Recharge_Close                  = "Layer_Recharge_Close",
    Layer_Recharge_QRCode_Open            = "Layer_Recharge_QRCode_Open",
    Layer_Recharge_QRCode_Close           = "Layer_Recharge_QRCode_Close",
    RechargeReceivedResp                  = "RechargeReceivedResp",

    -- 脚本组件
    SUIComponentAttach                    = "SUIComponentAttach",
    SUIComponentDetach                    = "SUIComponentDetach",
    SUIComponentUpdate                    = "SUIComponentUpdate",

    SUIComponentUpdateByLua               = "SUIComponentUpdateByLua",
    SUIComponentAttachBySSR               = "SUIComponentAttachBySSR",

    -- sui
    SUIEditorOpen                         = "SUIEditorOpen",
    SUIEditorClose                        = "SUIEditorClose",
    SUIITEMBOXWidgetAdd                   = "SUIITEMBOXWidgetAdd",
    SUIITEMBOXPutoutAll                   = "SUIITEMBOXPutoutAll",
    SUIMetaWidgetAdd                      = "SUIMetaWidgetAdd",

    -- cui
    CUIEditorOpen                         = "CUIEditorOpen",
    CUIEditorClose                        = "CUIEditorClose",

    UserInputEventNotice                  = "UserInputEventNotice",

    CloudStorageInit                      = "CloudStorageInit",                         -- 云端存储

    Layer_PlayDice_Open                   = "Layer_PlayDice_Open",                      -- 骰子
    Layer_PlayDice_Close                  = "Layer_PlayDice_Close",

    Layer_ProgressBar_Open                = "Layer_ProgressBar_Open",                   -- 进度条
    Layer_ProgressBar_Close               = "Layer_ProgressBar_Close",

    -- 竞拍
    Layer_AuctionMain_Open                = "Layer_AuctionMain_Open",
    Layer_AuctionMain_Close               = "Layer_AuctionMain_Close",

    Layer_AuctionWorld_Open               = "Layer_AuctionWorld_Open",
    Layer_AuctionWorld_Close              = "Layer_AuctionWorld_Close",

    Layer_AuctionBidding_Open             = "Layer_AuctionBidding_Open",
    Layer_AuctionBidding_Close            = "Layer_AuctionBidding_Close",

    Layer_AuctionPutList_Open             = "Layer_AuctionPutList_Open",
    Layer_AuctionPutList_Close            = "Layer_AuctionPutList_Close",

    Layer_AuctionBid_Open                 = "Layer_AuctionBid_Open",
    Layer_AuctionBid_Close                = "Layer_AuctionBid_Close",

    Layer_AuctionBuy_Open                 = "Layer_AuctionBuy_Open",
    Layer_AuctionBuy_Close                = "Layer_AuctionBuy_Close",

    Layer_AuctionPutin_Open               = "Layer_AuctionPutin_Open",
    Layer_AuctionPutin_Close              = "Layer_AuctionPutin_Close",

    Layer_AuctionPutout_Open              = "Layer_AuctionPutout_Open",
    Layer_AuctionPutout_Close             = "Layer_AuctionPutout_Close",

    Layer_AuctionTimeout_Open             = "Layer_AuctionTimeout_Open",
    Layer_AuctionTimeout_Close            = "Layer_AuctionTimeout_Close",

    AuctionItemListClear                  = "AuctionItemListClear",                   -- 拍卖行 清理
    AuctionPutinResp                      = "AuctionPutinResp",
    AuctionPutoutResp                     = "AuctionPutoutResp",
    AuctionItemListResp                   = "AuctionItemListResp",
    AuctionItemListComplete               = "AuctionItemListComplete",
    AuctionBidResp                        = "AuctionBidResp",
    AuctionAcquireResp                    = "AuctionAcquireResp",
    AuctionItemUpdate                     = "AuctionItemUpdate",
    AuctionWorldItemAdd                   = "AuctionWorldItemAdd",
    AuctionWorldItemDel                   = "AuctionWorldItemDel",
    AuctionWorldItemChange                = "AuctionWorldItemChange",
    AuctionPutListResp                    = "AuctionPutListResp",
    AuctionBiddingListResp                = "AuctionBiddingListResp",
    AuctionWorldItemSearch                = "AuctionWorldItemSearch",
    -- sfy

    -- trade 交易
    Layer_Trade_Open                      = "Layer_Trade_Open",                       -- 交易系统 打开
    Layer_Trade_Close                     = "Layer_Trade_Close",                      -- 交易系统 关闭
    Layer_Trade_MoneyChange               = "Layer_Trade_MoneyChange",                -- 交易货币改变
    Layer_Trade_MyMoneyChange             = "Layer_Trade_MyMoneyChange",              -- 交易自己货币改变
    Layer_Trade_StatusChange              = "Layer_Trade_StatusChange",               -- 交易状态改变
    Layer_Trade_MyStatusChange            = "Layer_Trade_MyStatusChange",             -- 交易自己状态改变
    Layer_Trade_TraderItemChange          = "Layer_Trade_TraderItemChange",
    Layer_Trade_MyselfItemChange          = "Layer_Trade_MyselfItemChange",

    -- func dock layer
    Layer_Func_Dock_Open                  = "Layer_Func_Dock_Open",                       -- 功能菜单 打开
    Layer_Func_Dock_Close                 = "Layer_Func_Dock_Close",                      -- 功能菜单 关闭
    Layer_Func_Dock_RequsetInfo           = "Layer_Func_Dock_RequsetInfo",                --先向服务端请求玩家信息 再根据信息显示按钮
    Layer_Func_Dock_Response              = "Layer_Func_Dock_Response",                   --服务端返回玩家数据

    Bag_Oper_Data                 = "Bag_Oper_Data",        --背包数据操作
    Bag_Oper_Data_Delay           = "Bag_Oper_Data_Delay",  --背包数据操作
    Bag_State_Change              = "Bag_State_Change",     --背包状态刷新
    Bag_Pos_Reset                 = "Bag_Pos_Reset",        -- 背包整理
    Bag_Item_Collimator           = "Bag_Item_Collimator",  -- 道具准星
    Bag_Size_Change               = "Bag_Size_Change",      -- 背包大小变化

    QuickUseDataInit              = "QuickUseDataInit",     -- 快捷栏数据初始化
    QuickUseItemAdd               = "QuickUseItemAdd",      -- 快捷栏数据增加
    QuickUseItemRmv               = "QuickUseItemRmv",      -- 快捷栏数据删除
    QuickUseItemChange            = "QuickUseItemChange",   -- 快捷栏数据刷新
    QuickUseItemRefresh           = "QuickUseItemRefresh",  -- 快捷栏界面刷新


    IntoDropItem                  = "IntoDropItem",     --发起道具丢弃

    PlayEquip_Oper_Data           = "PlayEquip_Oper_Data", --角色装备数据操作
    PlayEquip_Oper_Init           = "PlayEquip_Oper_Init", --角色装备数据操作


    --背包
    Layer_Bag_Open                = "Layer_Bag_Open",                             -- 背包界面 打开
    Layer_Bag_Close               = "Layer_Bag_Close",                            --背包界面 关闭
    Layer_Bag_ResetPos            = "Layer_Bag_ResetPos",
    Bag_Item_Pos_Change           = "Bag_Item_Pos_Change",                        -- 背包道具位置信息变化
    Bag_Item_Choose_State         = "Bag_Item_Choose_State",                      -- 背包物品勾选状态
    Layer_Bag_Load_Success        = "Layer_Bag_Load_Success",                     -- 背包界面 加载完成
    
    -- npc storage layer
    Layer_NPC_Storage_Open        = "Layer_NPC_Storage_Open",                     -- npc仓库界面 打开
    Layer_NPC_Storage_Close       = "Layer_NPC_Storage_Close",                    -- npc仓库界面 关闭
    Layer_NPC_Storage_Update      = "Layer_NPC_Storage_Update",
    Layer_NPC_Storage_Item_State  = "Layer_NPC_Storage_Item_State",
    Layer_NPC_Storage_Size_Change = "Layer_NPC_Storage_Size_Change",              -- 仓库格子数改变

    Layer_Auto_Use_Attach          = "Layer_Auto_Use_Attach",                       -- 自动使用tips
    Layer_Auto_Use_UnAttach        = "Layer_Auto_Use_UnAttach",

    ItemUpdate                            = "ItemUpdate",                               -- 更新道具属性

    -- 设置 setting
    GameSettingInited                     = "GameSettingInited",
    GameSettingChange                     = "GameSettingChange",
    GamePickSettingChange                 = "GamePickSettingChange",

    -- 设置个人信息收集清单
    Layer_SettingInformationCollect_Open  = "Layer_SettingInformationCollect_Open",
    Layer_SettingInformationCollect_Close = "Layer_SettingInformationCollect_Close",
    Layer_SettingInformationCollect_OnRefresh = "Layer_SettingInformationCollect_OnRefresh",


    --ItemTips
    Layer_ItemTips_Open                    = "Layer_ItemTips_Open",                       --打开道具tips面板
    Layer_ItemTips_Close                   = "Layer_ItemTips_Close",                      --关闭道具tips面板
    Layer_ItemTips_Mouse_Scroll            = "Layer_ItemTips_Mouse_Scroll",               --道具pc的滚轮事件

    --CommonTips
    Layer_CommonTips_Open                   = "Layer_CommonTips_Open",                       --打开通用tips面板
    Layer_CommonTips_Close                  = "Layer_CommonTips_Close",                      --关闭通用tips面板

    --NPC
    Layer_NPC_Talk_Open                     = "Layer_NPC_Talk_Open",                          -- NPC对话
    Layer_NPC_Talk_Close                    = "Layer_NPC_Talk_Close",                         -- 关闭NPC对话

    --NPC STORE
    Layer_NPC_Store_Open                  = "Layer_NPC_Store_Open",
    Layer_NPC_Store_Close                 = "Layer_NPC_Store_Close",
    Layer_NPC_Store_Item_Remove           = "Layer_NPC_Store_Item_Remove",

    --NPC SELL OR REPAIRE
    Layer_NPC_Sell_Repaire_Open           = "Layer_NPC_Sell_Repaire_Open",
    Layer_NPC_Sell_Repaire_Close          = "Layer_NPC_Sell_Repaire_Close",
    Layer_NPC_Sell_Repaire_UpDate         = "Layer_NPC_Sell_Repaire_UpDate",

    --NPC STORE
    Layer_NPC_Make_Drug_Open                  = "Layer_NPC_Make_Drug_Open",
    Layer_NPC_Make_Drug_Close                 = "Layer_NPC_Make_Drug_Close",

    -- 断线重连相关
    Disconnect                            = "Disconnect",                             -- 断线
    IllegalMsg                            = "IllegalMsg",                             -- 非法消息包
    OtherClientLogin                      = "OtherClientLogin",                       -- 另外一个客户端登录
    Reconnect                             = "Reconnect",                              -- 重连
    ReconnectForbidden                    = "ReconnectForbidden",                     -- 禁止断线重连
    ConnectGameWorld                      = "ConnectGameWorld",

    --屏蔽场景特效变更
    SetChange_AllPlayer                   = "SetChange_AllPlayer",                    --所有玩家 屏蔽设置的修改
    SetChange_OwnSidePlayer               = "SetChange_OwnSidePlayer",                --己方玩家
    SetChange_AllEffect                   = "SetChange_AllEffect",                    --所有特效 (除技能特效2022.10.18 技能特效单独设置)
    SetChange_SkillEffect                 = "SetChange_SkillEffect",                  --屏蔽技能特效
    SetChange_NormalMonster               = "SetChange_NormalMonster",                --普通怪物
    SetChange_MonsterPet                  = "SetChange_MonsterPet",                   --屏蔽召唤物
    SetChange_SimpleDressPlayer           = "SetChange_SimpleDressPlayer",            -- 人物简装
    SetChange_SimpleDressMonster          = "SetChange_SimpleDressMonster",           -- 怪物简装
    SetChange_SimpleDressMonsterBoss      = "SetChange_SimpleDressMonsterBoss",       -- Boss不简装
    SetChange_AllHero                     = "SetChange_AllHero",                      --英雄屏蔽设置

    Layer_RichTextTest_Open               = "Layer_RichTextTest_Open",
    Layer_RichTextTest_Close              = "Layer_RichTextTest_Close",

    Layer_ButtonPos_Open                  = "Layer_ButtonPos_Open",                   -- TXT按钮位置
    Layer_ButtonPos_Close                 = "Layer_ButtonPos_Close",

    Layer_FrameRateClose                  = "Layer_FrameRateClose",

    -- 社交
    Layer_Social_Open                     = "Layer_Social_Open",                      -- 社交外框打开
    Layer_Social_Close                    = "Layer_Social_Close",                     -- 社交外框关闭
    Layer_Mail_Attach                     = "Layer_Mail_Attach",                      -- 邮件 挂载
    Layer_Mail_UnAttach                   = "Layer_Mail_UnAttach",                    -- 邮件 卸载
    Layer_Mail_DelOneMailSucc             = "Layer_Mail_DelOneMailSucc",              -- 删除了一个邮件    
    Layer_Mail_DelAllMailSucc             = "Layer_Mail_DelAllMailSucc",        

    -- 行会外框
    Layer_GuildFrame_Open = "Layer_GuildFrame_Open",
    Layer_GuildFrame_Close = "Layer_GuildFrame_Close",
    Layer_GuildFrame_Refresh = "Layer_GuildFrame_Refresh",
    
    -- 行会信息主界面
    Layer_Guild_Main_Open = "Layer_Guild_Main_Open",
    Layer_Guild_Main_Close = "Layer_Guild_Main_Close",
    Layer_Guild_Main_Refresh = "Layer_Guild_Main_Refresh",

    -- 行会创建
    Layer_Guild_Create_Open = "Layer_Guild_Create_Open",
    Layer_Guild_Create_Close = "Layer_Guild_Create_Close",

    -- 行会成员
    Layer_Guild_Member_Open = "Layer_Guild_Member_Open",
    Layer_Guild_Member_Close = "Layer_Guild_Member_Close",
    Layer_Guild_Member_Refresh = "Layer_Guild_Member_Refresh",
    Layer_Guild_Member_Rank_Refresh = "Layer_Guild_Member_Rank_Refresh",
    Layer_Guild_Member_Remove = "Layer_Guild_Member_Remove",
    GuildInfo_Refresh = "GuildInfo_Refresh",

    Layer_Guild_EditTitle_Open = "Layer_Guild_EditTitle_Open",--编辑行会称谓
    Layer_Guild_EditTitle_Close = "Layer_Guild_EditTitle_Close",

    -- 世界行会列表
    Layer_Guild_List_Open = "Layer_Guild_List_Open",    
    Layer_Guild_List_Close = "Layer_Guild_List_Close",

    -- 行会申请列表
    Layer_Guild_ApplyList_Open = "Layer_Guild_ApplyList_Open",  
    Layer_Guild_ApplyList_Close = "Layer_Guild_ApplyList_Close",
    Layer_Guild_ApplyList_Refresh = "Layer_Guild_ApplyList_Refresh",

    Layer_Guild_Ally_Apply_Open = "Layer_Guild_Ally_Apply_Open",
    Layer_Guild_Ally_Apply_Close = "Layer_Guild_Ally_Apply_Close",

    Layer_Guild_WarSponsor_Open = "Layer_Guild_WarSponsor_Open",        --发起行会宣战
    Layer_Guild_WarSponsor_Close = "Layer_Guild_WarSponsor_Close",

    Join_Guild = "Join_Guild", -- 加入行会
    Exit_Guild = "Exit_Guild", -- 退出行会

    --队伍
    Layer_Team_Attach   = "Layer_Team_Attach",
    Layer_Team_UnAttach = "Layer_Team_UnAttach",
    Layer_TeamInvite_Open   = "Layer_TeamInvite_Open",
    Layer_TeamInvite_Close  = "Layer_TeamInvite_Close",
    Layer_TeamApply_Open       = "Layer_TeamApply_Open",
    Layer_TeamApply_Close      = "Layer_TeamApply_Close",
    Layer_Team_BeInvite_Open       = "Layer_Team_BeInvite_Open",
    Layer_Team_BeInvite_Close      = "Layer_Team_BeInvite_Close",


    ReloadMap = "ReloadMap",--重新加载地图

    -- 好友
    Layer_Friend_Attach         = "Layer_Friend_Attach",
    Layer_Friend_UnAttach       = "Layer_Friend_UnAttach",
    Layer_AddFriend_Open        = "Layer_AddFriend_Open",
    Layer_AddFriend_Close       = "Layer_AddFriend_Close",
    Layer_FriendApply_Open      = "Layer_FriendApply_Open",
    Layer_FriendApply_Close     = "Layer_FriendApply_Close",
    Layer_FriendApply_Refresh   = "Layer_FriendApply_Refresh",

    Layer_StallLayer_Open                   = "Layer_StallLayer_Open",                       -- 摆摊系统 打开
    Layer_StallLayer_Close                  = "Layer_StallLayer_Close",                      -- 摆摊系统 关闭
    Layer_StallLayer_ItemChange             = "Layer_StallLayer_ItemChange",
    Layer_StallLayer_SelfItemChange         = "Layer_StallLayer_SelfItemChange",
    Layer_StallLayer_StatusChange           = "Layer_StallLayer_StatusChange",
    Layer_Stall_Put_Open                    = "Layer_Stall_Put_Open",
    Layer_Stall_Put_Close                   = "Layer_Stall_Put_Close",
    Layer_Stall_Set_Open                    = "Layer_Stall_Set_Open",
    Layer_Stall_Set_Close                   = "Layer_Stall_Set_Close",


    Layer_Title_Attach = "Layer_Title_Attach",--称号界面
    Layer_Title_Refresh = "Layer_Title_Refresh",
    Layer_TitleTips_Open = "Layer_TitleTips_Open",
    Layer_TitleTips_Close = "Layer_TitleTips_Close",

    -- 商城
    Layer_PageStore_Open                    = "Layer_PageStore_Open",                       -- 商城
    Layer_PageStore_Close                   = "Layer_PageStore_Close",
    Layer_PageStore_Refresh                 = "Layer_PageStore_Refresh",
    Layer_StoreBuy_Open                     = "Layer_StoreBuy_Open",                        -- 商城购买
    Layer_StoreBuy_Close                    = "Layer_StoreBuy_Close",
    Layer_StoreFrame_Open                   = "Layer_StoreFrame_Open",                      -- 商城外框打开
    Layer_StoreFrame_Close                  = "Layer_StoreFrame_Close",                     -- 商城外框关闭

    Layer_Treasure_Box_Open         = "Layer_Treasure_Box_Open",
    Layer_Treasure_Box_Close        = "Layer_Treasure_Box_Close",
    Layer_Treasure_Box_Refresh      = "Layer_Treasure_Box_Refresh",
    Layer_Gold_Box_Open             = "Layer_Gold_Box_Open",
    Layer_Gold_Box_Close            = "Layer_Gold_Box_Close",
    Layer_Gold_Box_Open_Anim        = "Layer_Gold_Box_Open_Anim",
    Layer_Gold_Box_Refresh          = "Layer_Gold_Box_Refresh",

    Layer_NearPlayer_Attach = "Layer_NearPlayer_Attach",--附近玩家
    Layer_NearPlayer_UnAttach = "Layer_NearPlayer_UnAttach",

    -- rank layer
    Layer_Rank_Open                       = "Layer_Rank_Open",                            --排行榜界面打开
    Layer_Rank_Close                      = "Layer_Rank_Close",                           --排行榜界面关闭

    Equip_Retrieve_State              = "Equip_Retrieve_State",       -- 装备回收

    Layer_CommonBubbleInfo_Open = "Layer_CommonBubbleInfo_Open",--组队邀请
    Layer_CommonBubbleInfo_Close = "Layer_CommonBubbleInfo_Close",



    ----zfs began --
    
    -- 查看他人  begin
    Layer_TradingBank_Look_Player_Close                    = "Layer_TradingBank_Look_Player_Close",                       --人物主界面关闭
    Layer_TradingBank_Look_Player_Child_Del                = "Layer_TradingBank_Look_Player_Child_Del",
    Layer_TradingBank_Look_Player_Equip_Open               = "Layer_TradingBank_Look_Player_Equip_Open",                  --装备面板
    Layer_TradingBank_Look_Player_Base_Att_Open            = "Layer_TradingBank_Look_Player_Base_Att_Open",               --基础属性面板
    Layer_TradingBank_Look_Player_Extra_Att_Open           = "Layer_TradingBank_Look_Player_Extra_Att_Open",              --额外属性面板
    Layer_TradingBank_Look_Player_Skill_Open               = "Layer_TradingBank_Look_Player_Skill_Open",                  --技能面板
    Layer_TradingBank_Look_PlayerBestRing_Open             = "Layer_TradingBank_Look_PlayerBestRing_Open",                --极品首饰面板开启
    Layer_TradingBank_Look_PlayerBestRing_Close            = "Layer_TradingBank_Loo_PlayerBestRing_Close",               --极品首饰面板关闭
    Layer_TradingBank_Look_Player_Super_Equip_Open         = "Layer_TradingBank_Look_Player_Super_Equip_Open",            --时装面板
    Layer_TradingBank_Look_Title_Attach                    = "Layer_TradingBank_Look_Title_Attach",                       --称号界面
    Layer_TradingBank_Look_Player_LookShowPanel            = "Layer_TradingBank_Look_Player_LookShowPanel",
    Layer_TradingBank_Look_Player_LookShowPanel_Hero       = "Layer_TradingBank_Look_Player_LookShowPanel_Hero",
    
    Layer_TradingBank_Look_Player_Close_Hero                    = "Layer_TradingBank_Look_Player_Close_Hero",                       --英雄主界面关闭
    Layer_TradingBank_Look_Player_Child_Del_Hero                = "Layer_TradingBank_Look_Player_Child_Del_Hero",
    Layer_TradingBank_Look_Player_Equip_Open_Hero               = "Layer_TradingBank_Look_Player_Equip_Open_Hero",                  --装备面板
    Layer_TradingBank_Look_Player_Base_Att_Open_Hero            = "Layer_TradingBank_Look_Player_Base_Att_Open_Hero",               --基础属性面板
    Layer_TradingBank_Look_Player_Extra_Att_Open_Hero           = "Layer_TradingBank_Look_Player_Extra_Att_Open_Hero",              --额外属性面板
    Layer_TradingBank_Look_Player_Skill_Open_Hero               = "Layer_TradingBank_Look_Player_Skill_Open_Hero",                  --技能面板
    Layer_TradingBank_Look_PlayerBestRing_Open_Hero             = "Layer_TradingBank_Look_PlayerBestRing_Open_Hero",                --极品首饰面板开启
    Layer_TradingBank_Look_PlayerBestRing_Close_Hero            = "Layer_TradingBank_Loo_PlayerBestRing_Close_Hero",               --极品首饰面板关闭
    Layer_TradingBank_Look_Player_Super_Equip_Open_Hero         = "Layer_TradingBank_Look_Player_Super_Equip_Open_Hero",            --时装面板
    Layer_TradingBank_Look_Title_Attach_Hero                    = "Layer_TradingBank_Look_Title_Attach_Hero",                       --称号界面

    Layer_Login_RoleLock_Open                                   = "Layer_Login_RoleLock_Open",        -- （取回） 角色锁定 打开
    Layer_Login_RoleLock_Close                                  = "Layer_Login_RoleLock_Close",       -- （取回） 角色锁定 关闭
    -- 查看他人  end

    Layer_TradingBankFrame_Open    = "Layer_TradingBankFrame_Open",--交易行外框
    Layer_TradingBankFrame_Close    = "Layer_TradingBankFrame_Close",
    Layer_TradingBankBuyLayer_Open = "Layer_TradingBankBuyLayer_Open",--交易行购买
    Layer_TradingBankBuyLayer_Close = "Layer_TradingBankBuyLayer_Close",
    Layer_TradingBankPlayerInfo_Open = "Layer_TradingBankPlayerInfo_Open",--用户信息
    Layer_TradingBankPlayerInfo_Close = "Layer_TradingBankPlayerInfo_Close",
    Layer_TradingBankPlayerPanel_Open = "Layer_TradingBankPlayerPanel_Open",--用户信息
    Layer_TradingBankPlayerPanel_Close = "Layer_TradingBankPlayerPanel_Close",
    Layer_TradingBankBuyTipsLayer_Open = "Layer_TradingBankBuyTipsLayer_Open",--筛选
    Layer_TradingBankBuyTipsLayer_Close = "Layer_TradingBankBuyTipsLayer_Close",
    Layer_TradingBankTipsLayer_Open = "Layer_TradingBankTipsLayer_Open",--提示
    Layer_TradingBankTipsLayer_Close = "Layer_TradingBankTipsLayer_Close",
    Layer_TradingBankTips2Layer_Open = "Layer_TradingBankTips2Layer_Open",--提示2
    Layer_TradingBankTips2Layer_Close = "Layer_TradingBankTips2Layer_Close",
    Layer_TradingBankBuyRoleLayer_Open = "Layer_TradingBankBuyRoleLayer_Open",--角色
    Layer_TradingBankBuyRoleLayer_Close = "Layer_TradingBankBuyRoleLayer_Close",
    Layer_TradingBankBuyRoleLayer_Search = "Layer_TradingBankBuyRoleLayer_Search",
    Layer_TradingBankBuyMoneyLayer_Open = "Layer_TradingBankBuyMoneyLayer_Open",--货币
    Layer_TradingBankBuyMoneyLayer_Close = "Layer_TradingBankBuyMoneyLayer_Close",
    Layer_TradingBankBuyEquipLayer_Open = "Layer_TradingBankBuyEquipLayer_Open",--装备
    Layer_TradingBankBuyEquipLayer_TypeChange = "Layer_TradingBankBuyEquipLayer_TypeChange",
    Layer_TradingBankBuyEquipLayer_Search = "Layer_TradingBankBuyEquipLayer_Search",
    Layer_TradingBankBuyEquip_Tips = "Layer_TradingBankBuyEquip_Tips",
    Layer_TradingBankBuyEquipLayer_Close = "Layer_TradingBankBuyEquipLayer_Close",
    Layer_TradingBankUpModifyEquipPanel_Open = "Layer_TradingBankUpModifyEquipPanel_Open",--装备上架 修改价格
    Layer_TradingBankUpModifyEquipPanel_Close = "Layer_TradingBankUpModifyEquipPanel_Close",
    Layer_TradingBankUpModifyEquipPanel_CheckSuccess = "Layer_TradingBankUpModifyEquipPanel_CheckSuccess",
    Layer_TradingBankDownGetEquipPanel_Open = "Layer_TradingBankDownGetEquipPanel_Open", --装备 下架 和取回
    Layer_TradingBankDownGetEquipPanel_Close = "Layer_TradingBankDownGetEquipPanel_Close",
    Layer_TradingBankBuyMeLayer_Open = "Layer_TradingBankBuyMeLayer_Open",--指定我
    Layer_TradingBankBuyMeLayer_Close = "Layer_TradingBankBuyMeLayer_Close",
    Layer_TradingBankPhoneLayer_Open = "Layer_TradingBankPhoneLayer_Open", -- 验证手机
    Layer_TradingBankPhoneLayer_Close = "Layer_TradingBankPhoneLayer_Close", -- 
    Layer_TradingBankZFLayer_Open = "Layer_TradingBankZFLayer_Open",--支付面板
    Layer_TradingBankZFLayer_Close = "Layer_TradingBankZFLayer_Close",
    Layer_TradingBankZFPanel_Open = "Layer_TradingBankZFPanel_Open",--支付面板
    Layer_TradingBankZFPanel_Close = "Layer_TradingBankZFPanel_Close",
    Layer_TradingBankCostZFLayer_Open = "Layer_TradingBankCostZFLayer_Open",
    Layer_TradingBankCostZFLayer_Close = "Layer_TradingBankCostZFLayer_Close",
    Layer_TradingBankCostZFPanel_Open = "Layer_TradingBankCostZFPanel_Open",
    Layer_TradingBankCostZFPanel_Close = "Layer_TradingBankCostZFPanel_Close",
    Layer_TradingBankSellLayer_Open = "Layer_TradingBankSellLayer_Open",--交易行寄售
    Layer_TradingBankSellLayer_RefGoodList = "Layer_TradingBankSellLayer_RefGoodList",
    Layer_TradingBankSellLayer_Close = "Layer_TradingBankSellLayer_Close",
    Layer_TradingBankZFPlayerLayer_Open = "Layer_TradingBankZFPlayerLayer_Open",
    Layer_TradingBankZFPlayerLayer_Close = "Layer_TradingBankZFPlayerLayer_Close",
    Layer_TradingBankGoodsLayer_Open = "Layer_TradingBankGoodsLayer_Open",--交易行货架
    Layer_TradingBankGoodsLayer_Close = "Layer_TradingBankGoodsLayer_Close",
    Layer_TradingBankMeLayer_Open = "Layer_TradingBankMeLayer_Open",--交易行我的
    Layer_TradingBankMeLayer_Close = "Layer_TradingBankMeLayer_Close",
    Layer_TradingBankPowerfulLayer_Open = "Layer_TradingBankPowerfulLayer_Open",--支付
    Layer_TradingBankPowerfulLayer_Close = "Layer_TradingBankPowerfulLayer_Close",

    Layer_TradingBankCaptureLayer_Open = "Layer_TradingBankCaptureLayer_Open",--交易行截图
    Layer_TradingBankCaptureLayer_Close = "Layer_TradingBankCaptureLayer_Close",
    Layer_TradingBankCaptureMaskLayer_Open = "Layer_TradingBankCaptureMaskLayer_Open",
    Layer_TradingBankCaptureMaskLayer_Close = "Layer_TradingBankCaptureMaskLayer_Close",
    Layer_TradingBankLookTexture_Open = "Layer_TradingBankLookTexture_Open",--交易查看图片
    Layer_TradingBankLookTexture_Close = "Layer_TradingBankLookTexture_Close",
    Layer_TradingBankReceiveLayer_Open = "Layer_TradingBankReceiveLayer_Open",--收货
    Layer_TradingBankReceiveLayer_Close = "Layer_TradingBankReceiveLayer_Close",
    Layer_TradingBankRefuseLayer_Open  = "Layer_TradingBankRefuseLayer_Open",--拒绝收货
    Layer_TradingBankRefuseLayer_Close = "Layer_TradingBankRefuseLayer_Close",

    ----------- 三方 交易行 ------------------
    Layer_TradingBankFrame_Open_other    = "Layer_TradingBankFrame_Open_other",--交易行外框
    Layer_TradingBankFrame_Close_other   = "Layer_TradingBankFrame_Close_other",
    Layer_TradingBankBuyLayer_Open_other = "Layer_TradingBankBuyLayer_Open_other",--交易行购买
    Layer_TradingBankBuyLayer_Close_other = "Layer_TradingBankBuyLayer_Close_other",
    Layer_TradingBankPlayerInfo_Open_other = "Layer_TradingBankPlayerInfo_Open_other",--用户信息
    Layer_TradingBankPlayerInfo_Close_other = "Layer_TradingBankPlayerInfo_Close_other",
    Layer_TradingBankPlayerPanel_Open_other = "Layer_TradingBankPlayerPanel_Open_other",--用户信息
    Layer_TradingBankPlayerPanel_Close_other = "Layer_TradingBankPlayerPanel_Close_other",
    Layer_TradingBankBuyTipsLayer_Open_other = "Layer_TradingBankBuyTipsLayer_Open_other",--筛选
    Layer_TradingBankBuyTipsLayer_Close_other = "Layer_TradingBankBuyTipsLayer_Close_other",
    Layer_TradingBankTipsLayer_Open_other = "Layer_TradingBankTipsLayer_Open_other",--提示
    Layer_TradingBankTipsLayer_Close_other = "Layer_TradingBankTipsLayer_Close_other",
    Layer_TradingBankTips2Layer_Open_other = "Layer_TradingBankTips2Layer_Open_other",--提示2
    Layer_TradingBankTips2Layer_Close_other = "Layer_TradingBankTips2Layer_Close_other",
    Layer_TradingBankBuyRoleLayer_Open_other = "Layer_TradingBankBuyRoleLayer_Open_other",--角色
    Layer_TradingBankBuyRoleLayer_Close_other = "Layer_TradingBankBuyRoleLayer_Close_other",
    Layer_TradingBankBuyRoleLayer_Search_other = "Layer_TradingBankBuyRoleLayer_Search_other",
    Layer_TradingBankBuyMoneyLayer_Open_other = "Layer_TradingBankBuyMoneyLayer_Open_other",--货币
    Layer_TradingBankBuyMoneyLayer_Close_other = "Layer_TradingBankBuyMoneyLayer_Close_other",
    Layer_TradingBankBuyRequestLayer_Open_other = "Layer_TradingBankBuyRequestLayer_Open_other",--求购
    Layer_TradingBankBuyRequestLayer_Close_other = "Layer_TradingBankBuyRequestLayer_Close_other",
    Layer_TradingBankBuyRequestLayer_RefList_other = "Layer_TradingBankBuyRequestLayer_RefList_other",
    Layer_TradingBankBuyMeLayer_Open_other = "Layer_TradingBankBuyMeLayer_Open_other",--指定我
    Layer_TradingBankBuyMeLayer_Close_other = "Layer_TradingBankBuyMeLayer_Close_other",
    Layer_TradingBankPhoneLayer_Open_other = "Layer_TradingBankPhoneLayer_Open_other", -- 验证手机
    Layer_TradingBankPhoneLayer_Close_other = "Layer_TradingBankPhoneLayer_Close_other", -- 
    Layer_TradingBankZFPanel_Open_other = "Layer_TradingBankZFPanel_Open_other",--支付面板
    Layer_TradingBankZFPanel_Close_other = "Layer_TradingBankZFPanel_Close_other",
    Layer_TradingBankCostZFLayer_Open_other = "Layer_TradingBankCostZFLayer_Open_other",
    Layer_TradingBankCostZFLayer_Close_other = "Layer_TradingBankCostZFLayer_Close_other",
    Layer_TradingBankCostZFPanel_Open_other = "Layer_TradingBankCostZFPanel_Open_other",
    Layer_TradingBankCostZFPanel_Close_other = "Layer_TradingBankCostZFPanel_Close_other",
    Layer_TradingBankSellLayer_Open_other = "Layer_TradingBankSellLayer_Open_other",--交易行寄售
    Layer_TradingBankSellLayer_Close_other = "Layer_TradingBankSellLayer_Close_other",
    Layer_TradingBankZFPlayerLayer_Open_other = "Layer_TradingBankZFPlayerLayer_Open_other",
    Layer_TradingBankZFPlayerLayer_Close_other = "Layer_TradingBankZFPlayerLayer_Close_other",
    Layer_TradingBankGoodsLayer_Open_other = "Layer_TradingBankGoodsLayer_Open_other",--交易行货架
    Layer_TradingBankGoodsLayer_Close_other = "Layer_TradingBankGoodsLayer_Close_other",
    Layer_TradingBankMeLayer_Open_other = "Layer_TradingBankMeLayer_Open_other",--交易行我的
    Layer_TradingBankMeLayer_Close_other = "Layer_TradingBankMeLayer_Close_other",
    Layer_TradingBankMeLayer_ShowGetMoneyRecord_other = "Layer_TradingBankMeLayer_ShowGetMoneyRecord_other",
    Layer_TradingBankMeGetMoneyPanelLayer_Open_other = "Layer_TradingBankMeGetMoneyPanelLayer_Open_other",
    Layer_TradingBankMeGetMoneyPanelLayer_Close_other = "Layer_TradingBankMeGetMoneyPanelLayer_Close_other",
    Layer_TradingBankMeRecordPanelLayer_Open_other = "Layer_TradingBankMeRecordPanelLayer_Open_other",
    Layer_TradingBankMeRecordPanelLayer_Close_other = "Layer_TradingBankMeRecordPanelLayer_Close_other",
    Layer_TradingBankPowerfulLayer_Open_other = "Layer_TradingBankPowerfulLayer_Open_other",--支付
    Layer_TradingBankPowerfulLayer_Close_other = "Layer_TradingBankPowerfulLayer_Close_other",
    Layer_TradingBankCaptureLayer_Open_other = "Layer_TradingBankCaptureLayer_Open_other",--交易行截图
    Layer_TradingBankCaptureLayer_Close_other = "Layer_TradingBankCaptureLayer_Close_other",
    Layer_TradingBankCaptureMaskLayer_Open_other = "Layer_TradingBankCaptureMaskLayer_Open_other",
    Layer_TradingBankCaptureMaskLayer_Close_other = "Layer_TradingBankCaptureMaskLayer_Close_other",
    Layer_TradingBankLookTexture_Open_other = "Layer_TradingBankLookTexture_Open_other",--交易查看图片
    Layer_TradingBankLookTexture_Close_other = "Layer_TradingBankLookTexture_Close_other",
    Layer_TradingBankReceiveLayer_Open_other = "Layer_TradingBankReceiveLayer_Open_other",--收货
    Layer_TradingBankReceiveLayer_Close_other = "Layer_TradingBankReceiveLayer_Close_other",
    Layer_TradingBankRefuseLayer_Open_other  = "Layer_TradingBankRefuseLayer_Open_other",--拒绝收货
    Layer_TradingBankRefuseLayer_Close_other = "Layer_TradingBankRefuseLayer_Close_other",
    Layer_TradingBankWaitPayPanelLayer_Open_other = "Layer_TradingBankWaitPayPanelLayer_Open_other",--待支付
    Layer_TradingBankWaitPayPanelLayer_Close_other = "Layer_TradingBankWaitPayPanelLayer_Close_other",
    Layer_TradingBankSuggestPanelLayer_Open_other = "Layer_TradingBankSuggestPanelLayer_Open_other",--意见反馈
    Layer_TradingBankSuggestPanelLayer_Close_other = "Layer_TradingBankSuggestPanelLayer_Close_other",
    Layer_TradingBank_Interface_other = "Layer_TradingBank_Interface_other",--交易行接口
    Layer_TradingBankBindIdentityLayer_Open_other = "Layer_TradingBankBindIdentityLayer_Open_other", -- 身份证绑定
    Layer_TradingBankBindIdentityLayer_Close_other = "Layer_TradingBankBindIdentityLayer_Close_other", -- 
    Layer_TradingBankBuyServerNameTipsLayer_Open_other = "Layer_TradingBankBuyServerNameTipsLayer_Open_other",
    Layer_TradingBankBuyServerNameTipsLayer_Close_other = "Layer_TradingBankBuyServerNameTipsLayer_Close_other",
    Layer_TradingBankLookOtherServerPlayerLayer_Open_other = "Layer_TradingBankLookOtherServerPlayerLayer_Open_other",
    Layer_TradingBankLookOtherServerPlayerLayer_Close_other = "Layer_TradingBankLookOtherServerPlayerLayer_Close_other",
    Layer_TradingBankSearchServerLayer_Open_other = "Layer_TradingBankSearchServerLayer_Open_other",
    Layer_TradingBankSearchServerLayer_Close_other = "Layer_TradingBankSearchServerLayer_Close_other",

    -----------------------------------------
    Layer_BeStrong_refButton = "Layer_BeStrong_refButton",    --提升提示 按钮增加
    Layer_BeStrong_List_Open = "Layer_BeStrong_List_Open",    --列表打开
    Layer_BeStrong_List_Close = "Layer_BeStrong_List_Close",  --列表关闭

    Layer_RedDot_refData = "Layer_RedDot_refData", --红点提醒




    Layer_Look_Player_Open_Hero                     = "Layer_Look_Player_Open_Hero",                        --人物主界面
    Layer_Look_Player_Close_Hero                    = "Layer_Look_Player_Close_Hero",                       --人物主界面关闭
    Layer_Look_Player_Child_Del_Hero                = "Layer_Look_Player_Child_Del_Hero",
    Layer_Look_Player_Equip_Open_Hero               = "Layer_Look_Player_Equip_Open_Hero",                  --装备面板
    Layer_Look_Player_Base_Att_Open_Hero            = "Layer_Look_Player_Base_Att_Open_Hero",               --基础属性面板
    Layer_Look_Player_Extra_Att_Open_Hero           = "Layer_Look_Player_Extra_Att_Open_Hero",              --额外属性面板
    Layer_Look_Player_Skill_Open_Hero               = "Layer_Look_Player_Skill_Open_Hero",                  --技能面板
    Layer_Look_PlayerBestRing_Open_Hero             = "Layer_Look_PlayerBestRing_Open_Hero",                --极品首饰面板开启
    Layer_Look_PlayerBestRing_Close_Hero            = "Layer_Loo_PlayerBestRing_Close_Hero",               --极品首饰面板关闭
    Layer_Look_Player_Super_Equip_Open_Hero         = "Layer_Look_Player_Super_Equip_Open_Hero",            --时装面板
    Layer_Look_Title_Attach_Hero                    = "Layer_Look_Title_Attach_Hero",                       --称号界面
    Layer_Look_Buff_Attach_Hero                     = "Layer_Look_Buff_Attach_Hero",                        -- BUFF



    Layer_Player_Open_Hero                      = "Layer_Player_Open_Hero",                        --英雄主界面
    Layer_Player_Close_Hero                     = "Layer_Player_Close_Hero",                       --英雄主界面关闭
    Layer_HeroFrame_Load_Success                = "Layer_HeroFrame_Load_Success",                  --英雄主界面加载完成
    Layer_Player_Child_Del_Hero                 = "Layer_Player_Child_Del_Hero",
    Layer_Player_Equip_Open_Hero                = "Layer_Player_Equip_Open_Hero",                  --装备面板
    Layer_Player_Equip_State_Change_Hero        = "Layer_Player_Equip_State_Change_Hero",          --装备状态状态刷新
    Layer_Hero_Equip_Load_Success               = "Layer_Hero_Equip_Load_Success",                 --英雄装备面板加载完成
    Layer_Player_Base_Att_Open_Hero             = "Layer_Player_Base_Att_Open_Hero",               --基础属性面板
    Layer_Player_Extra_Att_Open_Hero            = "Layer_Player_Extra_Att_Open_Hero",              --额外属性面板
    Layer_Player_Skill_Open_Hero                = "Layer_Player_Skill_Open_Hero",                  --技能面板
    Layer_PlayerBestRing_Open_Hero              = "Layer_PlayerBestRing_Open_Hero",                --极品首饰面板开启
    Layer_PlayerBestRing_Close_Hero             = "Layer_PlayerBestRing_Close_Hero",               --极品首饰面板关闭
    Layer_PlayerBestRing_State_Hero             = "Layer_PlayerBestRing_State_Hero",               --极品首饰面板开启状态
    Layer_Player_Super_Equip_Open_Hero          = "Layer_Player_Super_Equip_Open_Hero",            --时装面板
    Layer_Player_Buff_Open_Hero                 = "Layer_Player_Buff_Open_Hero",                   --buff面板

    PlayEquip_Oper_Data_Hero                    = "PlayEquip_Oper_Data_Hero",                      --英雄角色装备数据操作
    PlayEquip_Oper_Init_Hero                    = "PlayEquip_Oper_Init_Hero",                      --角色装备数据操作
    PlayerManaChange_Hero                       = "PlayerManaChange_Hero",
    PlayerPropertyChange_Hero                   = "PlayerPropertyChange_Hero",
    PlayerExpChange_Hero                        = "PlayerExpChange_Hero",
    SkillAdd_Hero                               = "SkillAdd_Hero",
    SkillDel_Hero                               = "SkillDel_Hero",
    SkillUpdate_Hero                            = "SkillUpdate_Hero",

    SkillEnterCD_Hero                          = "SkillEnterCD_Hero",                             -- 技能进入CD


    Layer_Super_Equip_Setting_Refresh_Hero      = "Layer_Super_Equip_Setting_Refresh_Hero",
    Layer_Title_Attach_Hero                     = "Layer_Title_Attach_Hero",
    Layer_Title_Refresh_Hero                    = "Layer_Title_Refresh_Hero",
    Layer_Hero_Login                            = "Layer_Hero_Login",                      --英雄登录
    Layer_Hero_Logout                           = "Layer_Hero_Logout",                   --英雄退出
    Layer_Hero_Button_Show                      = "Layer_Hero_Button_Show",                 --英雄召唤按钮显示与否
    Layer_Hero_StateSelect_Open                 = "Layer_Hero_StateSelect_Open",
    Layer_Hero_StateSelect_Close                = "Layer_Hero_StateSelect_Close",  

    --状态
    HeroState_change                            = "HeroState_change",  
    HeroBeDamaged                               = "HeroBeDamaged",--被攻击
    --lock
    HeroLock_Icon                               = "HeroLock_Icon",                              
        ---bag
    HeroBag_Oper_Data                           = "HeroBag_Oper_Data" , -- 英雄背包操作
    Layer_HeroBag_Open                          = "Layer_HeroBag_Open",  -- 背包界面 打开
    Layer_HeroBag_Close                         = "Layer_HeroBag_Close",  --背包界面 关闭
    Layer_HeroBag_Load_Success                  = "Layer_HeroBag_Load_Success", --背包加载成功
    Item_Move_begin_On_HeroBagPosChang          = "Item_Move_begin_On_HeroBagPosChang", 
    HeroBag_Item_Pos_Change                     = "HeroBag_Item_Pos_Change",    -- 背包道具位置信息变化
    HeroBag_State_Change                        = "HeroBag_State_Change", ----背包状态刷新
    HeroBagCountChnage                          = "HeroBagCountChnage",--背包格子变化
    HeroBag_Pos_Reset                           = "HeroBag_Pos_Reset",    -- 背包整理
    TakeOnRequestFromHeroBag                    = "TakeOnRequestFromHeroBag",  -- 穿装备来源英雄背包    请求
        --equip
    HeroTakeOnRequest                           = "HeroTakeOnRequest",  -- 穿装备    请求
    HeroTakeOffRequest                          = "HeroTakeOffRequest", -- 脱装备    请求
    HeroTakeOnResponse                          = "HeroTakeOnResponse", -- 穿装备    返回
    HeroTakeOffResponse                         = "HeroTakeOffResponse",-- 脱装备    返回
    HeroTakeOffRequestToHumBag                  = "HeroTakeOffRequestToHumBag",--脱装备到人物背包
    TakeOffToHeroBagRequest                     = "TakeOffToHeroBagRequest",
    HeroTakeOnRequestFromHumBag                 = "HeroTakeOnRequestFromHumBag",  -- 穿装备    请求

    AutoPickupBySprite                          = "AutoPickupBySprite",--小精灵拾取
    GuideLayerResetPos                           = "GuideLayerResetPos",
    ShowCostItem_Hero                           = "ShowCostItem_Hero",                               -- 消耗物品提示
    ShowGetBagItem_Hero                         = "ShowGetBagItem_Hero",                             -- 获得物品提示

    IntoDropItem_Hero                           = "IntoDropItem_Hero",     --发起道具丢弃

    RealNameInfo                                = "RealNameInfo",--实名认证


    MainMiniMapChange                           = "MainMiniMapChange",--小地图伸缩

    QuestionLayer_Open                          = "QuestionLayer_Open",--答题
    QuestionLayer_Close                         = "QuestionLayer_Close",

    ResolutionSizeChange                        = "ResolutionSizeChange",--pc分辨率改变
    Layer_setResolutionSize_Open                = "Layer_setResolutionSize_Open",--分辨率设置
    Layer_setResolutionSize_Close               = "Layer_setResolutionSize_Close",
    NPCTalkLayer_Open_Success                   = "NPCTalkLayer_Open_Success",--NPC打开完成
    PlayerAttribute_Change                      = "PlayerAttribute_Change",--玩家属性改变
    PlayerReinLevelChange                       = "PlayerReinLevelChange", --转生改变
    PlayerJobChange                             = "PlayerJobChange", --职业
    PlayerSexChange                             = "PlayerSexChange", --性别
    PlayerAttribute_Change_Hero                 = "PlayerAttribute_Change_Hero",--玩家属性改变
    PlayerReinLevelChange_Hero                  = "PlayerReinLevelChange_Hero", --转生改变
    PlayerJobChange_Hero                        = "PlayerJobChange_Hero", --职业
    PlayerSexChange_Hero                        = "PlayerSexChange_Hero", --性别
    PlayerLevelChange_Hero                      = "PlayerLevelChange_Hero",--英雄等级

    VerificationLayer_Open                      = "VerificationLayer_Open",--验证
    VerificationLayer_Close                     = "VerificationLayer_Close",--

    Layer_SettingFrame_Open                     = "Layer_SettingFrame_Open",--设置
    Layer_SettingFrame_Close                    = "Layer_SettingFrame_Close",
    Layer_SettingBasic_Open                     = "Layer_SettingBasic_Open",--设置
    Layer_SettingBasic_Close                    = "Layer_SettingBasic_Close",
    Layer_SettingWindowRange_Open               = "Layer_SettingWindowRange_Open",--视距
    Layer_SettingWindowRange_Close              = "Layer_SettingWindowRange_Close", 
    Layer_SettingLaunch_Open                    = "Layer_SettingLaunch_Open",--战斗
    Layer_SettingLaunch_Close                   = "Layer_SettingLaunch_Close",
    
    Rocker_Show_Distance_Change                 = "Rocker_Show_Distance_Change",--轮盘侧边距改变
    Skill_Show_Distance_Change                  = "Skill_Show_Distance_Change",--技能侧边距改变
    Layer_BossTipsLayer_Open                    = "Layer_BossTipsLayer_Open",--boss提醒
    Layer_BossTipsLayer_Close                   = "Layer_BossTipsLayer_Close",
    Layer_addMonsterNameLayer_Open              = "Layer_addMonsterNameLayer_Open",
    Layer_addMonsterNameLayer_Close             = "Layer_addMonsterNameLayer_Close",
    Layer_addMonsterTypeLayer_Open              = "Layer_addMonsterTypeLayer_Open",
    Layer_addMonsterTypeLayer_Close             = "Layer_addMonsterTypeLayer_Close",
    Layer_Common_SelectList_Open                = "Layer_Common_SelectList_Open",
    Layer_Common_SelectList_Close               = "Layer_Common_SelectList_Close",
    Layer_pickSettingLayer_Open                 = "Layer_pickSettingLayer_Open",
    Layer_pickSettingLayer_Close                = "Layer_pickSettingLayer_Close",
    Layer_SettingProtect_Open                   = "Layer_SettingProtect_Open",--保护设置
    Layer_SettingProtect_Close                  = "Layer_SettingProtect_Close",
    Layer_ProtectSettingLayer_Open              = "Layer_ProtectSettingLayer_Open",--保护物品设置
    Layer_ProtectSettingLayer_Close             = "Layer_ProtectSettingLayer_Close",
    Layer_SettingAuto_Open                      = "Layer_SettingAuto_Open", -- 挂机
    Layer_SettingAuto_Close                     = "Layer_SettingAuto_Close", 
    Layer_SettingHelp_Open                      = "Layer_SettingHelp_Open",
    Layer_SettingHelp_Close                     = "Layer_SettingHelp_Close",
    Layer_SkillPanel_Open                       = "Layer_SkillPanel_Open",
    Layer_SkillPanel_Close                      = "Layer_SkillPanel_Close",
    Layer_SkillRankPanel_Open                   = "Layer_SkillRankPanel_Open",
    Layer_SkillRankPanel_Close                  = "Layer_SkillRankPanel_Close",
    MainExChatClean                             = "MainExChatClean",
    
    SelfHeroDie                                 = "SelfHeroDie",                            -- 英雄死亡
    SelfHeroRevive                              = "SelfHeroRevive",                         -- 英雄复活
    Layer_Embattle_Refresh                      = "Layer_Embattle_Refresh",                 -- 法阵刷新
    Layer_Embattle_Refresh_Hero                 = "Layer_Embattle_Refresh_Hero",            -- 英雄法阵刷新
    Refresh_RestoreRole_UI                      = "Refresh_RestoreRole_UI",                 -- 恢复角色ui刷新
    TradingBank_other_Capture                   = "TradingBank_other_Capture",              -- 截图   
    Layer_CommunityLayer_Open                   = "Layer_CommunityLayer_Open",              -- 社区帖子
    Layer_CommunityLayer_Close                  = "Layer_CommunityLayer_Close", 
    ----zfs end -- 

    Layer_Split_Open = "Layer_Split_Open",--拆分
    Layer_Split_Close = "Layer_Split_Close",

    -- 查看他人  begin
    Layer_Look_Player_Open                     = "Layer_Look_Player_Open",                        --人物主界面
    Layer_Look_Player_Close                    = "Layer_Look_Player_Close",                       --人物主界面关闭
    Layer_Look_Player_Child_Del                = "Layer_Look_Player_Child_Del",
    Layer_Look_Player_Equip_Open               = "Layer_Look_Player_Equip_Open",                  --装备面板
    Layer_Look_Player_Base_Att_Open            = "Layer_Look_Player_Base_Att_Open",               --基础属性面板
    Layer_Look_Player_Extra_Att_Open           = "Layer_Look_Player_Extra_Att_Open",              --额外属性面板
    Layer_Look_Player_Skill_Open               = "Layer_Look_Player_Skill_Open",                  --技能面板
    Layer_Look_PlayerBestRing_Open             = "Layer_Look_PlayerBestRing_Open",                --极品首饰面板开启
    Layer_Look_PlayerBestRing_Close            = "Layer_Loo_PlayerBestRing_Close",               --极品首饰面板关闭
    Layer_Look_Player_Super_Equip_Open         = "Layer_Look_Player_Super_Equip_Open",            --时装面板
    Layer_Look_Title_Attach                    = "Layer_Look_Title_Attach",                       --称号界面
    Layer_Look_TitleTips_Open                  = "Layer_Look_TitleTips_Open",
    Layer_Look_TitleTips_Close                 = "Layer_Look_TitleTips_Close",     
    Layer_Look_Player_Buff_Open                = "Layer_Look_Player_Buff_Open",                   -- BUFF界面 
    -- 查看他人  end

    Layer_Sight_Bead_Show                      = "Layer_Sight_Bead_Show", --显示准星
    Layer_Sight_Bead_Hide                      = "Layer_Sight_Bead_Hide", --关闭准星
    
    Layer_Rein_Attr_Open                       = "Layer_Rein_Attr_Open",                   --转生属性点分配页
    Layer_Rein_Attr_Close                      = "Layer_Rein_Attr_Close",
    Player_Rein_Attr_Change                    = "Player_Rein_Attr_Change",                --玩家转生属性点改变   
    
    Layer_Common_Desc_Open                     = "Layer_Common_Desc_Open",                 --通用描述页
    Layer_Common_Desc_Close                    = "Layer_Common_Desc_Close",

    Play_Main_MagicBall_Effect                 = "Play_Main_MagicBall_Effect",             -- 播放魔血球特效
    
    Layer_IdentifyID_Open                      = "Layer_IdentifyID_Open",                   --跳实名认证

    Layer_Fire_Work_Hall_Show                  = "Layer_Fire_Work_Hall_Show",   --烟花特效

    --- ssr Guide 引导
    Layer_SGuide_Open                      = "Layer_SGuide_Open",
    Layer_SGuide_Close                     = "Layer_SGuide_Close",

    SSR_ITEMBOXWidget_Add                      = "SSR_ITEMBOXWidget_Add",       -- SSR ItemBox
    SSR_ITEMBOXWidget_Remove                   = "SSR_ITEMBOXWidget_Remove",
    SSR_ITEMBOXWidget_Update                   = "SSR_ITEMBOXWidget_Update",

    Layer_CacheTest_Open                       = "Layer_CacheTest_Open",
    Layer_CacheTest_Close                      = "Layer_CacheTest_Close", 
    
    Layer_GUIEditor_Open                       = "Layer_GUIEditor_Open",
    Layer_GUIEditor_Close                      = "Layer_GUIEditor_Close",

    Layer_GUIResSelector_Open                  = "Layer_GUIResSelector_Open",
    Layer_GUIResSelector_Close                 = "Layer_GUIResSelector_Close",

    Layer_GUIColorSelector_Open                = "Layer_GUIColorSelector_Open",
    Layer_GUIColorSelector_Close               = "Layer_GUIColorSelector_Close",

    Layer_ExtraColorEditor_Open                = "Layer_ExtraColorEditor_Open",
    Layer_ExtraColorEditor_Close               = "Layer_ExtraColorEditor_Close",

    Layer_GUITXTEditor_Open                    = "Layer_GUITXTEditor_Open",
    Layer_GUITXTEditor_Close                   = "Layer_GUITXTEditor_Close",

    Layer_GUITXTEditorEvent_Open               = "Layer_GUITXTEditorEvent_Open",
    Layer_GUITXTEditorEvent_Close              = "Layer_GUITXTEditorEvent_Close",

    Layer_GUIVarManager_Open                   = "Layer_GUIVarManager_Open",
    Layer_GUIVarManager_Close                  = "Layer_GUIVarManager_Close",

    Layer_CompoundItemLayer_Open               = "Layer_CompoundItemLayer_Open",  -- 合成
    Layer_CompoundItemLayer_Close              = "Layer_CompoundItemLayer_Close",
    Layer_CompoundItemLayer_Update             = "Layer_CompoundItemLayer_Update",

    Layer_Box996Main_Open                      = "Layer_Box996Main_Open",           --996传奇盒子
    Layer_Box996Main_Close                     = "Layer_Box996Main_Close",          --996传奇盒子
    Layer_Box996Main_Refresh                   = "Layer_Box996Main_Refresh",        --996传奇盒子
    Layer_Box996Title_Attach                   = "Layer_Box996Title_Attach",        --996传奇盒子  称号
    Layer_Box996Title_UnAttach                 = "Layer_Box996Title_UnAttach",      --996传奇盒子  称号
    Layer_Box996Title_Refresh                  = "Layer_Box996Title_Refresh",       --996传奇盒子  称号 刷新
    Layer_Box996EveryDay_Attach                = "Layer_Box996EveryDay_Attach",     --996传奇盒子  每日礼包
    Layer_Box996EveryDay_UnAttach              = "Layer_Box996EveryDay_UnAttach",   --996传奇盒子  每日礼包
    Layer_Box996EveryDay_Refresh               = "Layer_Box996EveryDay_Refresh",    --996传奇盒子  每日礼包 刷新
    Layer_Box996Super_Attach                   = "Layer_Box996Super_Attach",        --996传奇盒子  超级礼包
    Layer_Box996Super_UnAttach                 = "Layer_Box996Super_UnAttach",      --996传奇盒子  超级礼包
    Layer_Box996Super_Refresh                  = "Layer_Box996Super_Refresh",       --996传奇盒子  超级礼包 刷新
    Layer_Box996VIP_Attach                     = "Layer_Box996VIP_Attach",          --996传奇盒子  盒子vip会员
    Layer_Box996VIP_UnAttach                   = "Layer_Box996VIP_UnAttach",        --996传奇盒子  盒子vip会员
    Layer_Box996VIP_Refresh                    = "Layer_Box996VIP_Refresh",         --996传奇盒子  盒子vip会员 刷新
    Layer_Box996Guide_Open                     = "Layer_Box996Guide_Open",          --996传奇盒子  引导界面
    Layer_Box996Guide_Close                    = "Layer_Box996Guide_Close",         --996传奇盒子  引导界面
    Layer_Box996Guide_Refresh                  = "Layer_Box996Guide_Refresh",       --996传奇盒子  引导界面 刷新
    Layer_Box996SVIP_Attach                    = "Layer_Box996SVIP_Attach",         --996传奇盒子  svip
    Layer_Box996SVIP_UnAttach                  = "Layer_Box996SVIP_UnAttach",       --996传奇盒子  svip
    Layer_Box996SVIP_Refresh                   = "Layer_Box996SVIP_Refresh",        --996传奇盒子  svip 刷新
    Layer_Box996CloudPhone_Attach              = "Layer_Box996CloudPhone_Attach",   --996传奇盒子  云手机
    Layer_Box996CloudPhone_UnAttach            = "Layer_Box996CloudPhone_UnAttach", --996传奇盒子  云手机
    Layer_Box996CloudPhone_Refresh             = "Layer_Box996CloudPhone_Refresh",  --996传奇盒子  云手机 刷新

    Layer_Private_Chat_Open                    = "Layer_Private_Chat_Open",         -- 私聊界面 (PC端)
    Layer_Private_Chat_Close                   = "Layer_Private_Chat_Close",
    Layer_Private_Chat_AddItem                 = "Layer_Private_Chat_AddItem",
    Layer_Private_Chat_RemoveItem              = "Layer_Private_Chat_RemoveItem",

    Scene_Weather_Effect_Add                   = "Scene_Weather_Effect_Add",        -- 新增地图天气特效
    Scene_Weather_Effect_Remove                = "Scene_Weather_Effect_Remove",     -- 删除地图天气特效

    Main_Add_QuitTimeTips                      = "Main_AddQuitTimeTips",            -- 添加退出倒计时提示
    Main_Remove_QuitTimeTips                   = "Main_RemoveQuitTimeTips",         -- 移除  

    ShowItemDropNotice                         = "ShowItemDropNotice",              -- 掉落物品提示

    ActorOwnerChange                           = "ActorOwnerChange",                -- 归属改变

    Layer_Monster_Belong_TargetChange          = "Layer_Monster_Belong_TargetChange", -- 快捷归属操作
    Layer_Monster_Belong_Select                = "Layer_Monster_Belong_Select",       -- 快捷归属选中
    TargetChange_After                         = "TargetChange_After",                -- 目标TargetChange通知之后的通知
    Layer_UI_ROOT_Add_Child                    = "Layer_UI_ROOT_Add_Child",           -- 添加子节点

    PCFillChatInput                            = "PCFillChatInput",                 -- 填充PC聊天输入框

    Layer_MainNear_Open                        = "Layer_MainNear_Open",             -- 附近展示页
    Layer_MainNear_Close                       = "Layer_MainNear_Close",
    Layer_MainNear_Refresh                     = "Layer_MainNear_Refresh",

    Layer_AddBlackList_Open                    = "Layer_AddBlackList_Open",         -- 添加黑名单小页
    Layer_AddBlackList_Close                   = "Layer_AddBlackList_Close",    

    Server_Var_Change                          = "Server_Var_Change",               -- 红点变量改变
    CustomAttrWidgetAdd                        = "CustomAttrWidgetAdd",             -- 自定义角色属性添加
    AutoEquipShowWidgetAdd                     = "AutoEquipShowWidgetAdd",          -- 自定义EquipShow添加自动刷新

    Layer_TopTouch_Open                        = "Layer_TopTouch_Open",             -- Top层触摸页（PC技能
    TopTouch_Add_Child                         = "TopTouch_Add_Child",
    TopTouch_Remove_Child                      = "TopTouch_Remove_Child",
    
    Cross_Server_Status_Change                 = "Cross_Server_Status_Change",      -- 跨服状态改变

    AddBoxDayBtnToScreen                       = "AddBoxDayBtnToScreen",            -- 添加天天省钱按钮
    AddTradingBankBtnToScreen                  = "AddTradingBankBtnToScreen",       -- 添加交易行按钮

    SUISlider_Value_Change                     = "SUISlider_Value_Change",          -- 脚本组件拉杆值变动

    -- 预览技能
    PreviewSkillOpen                            = "PreviewSkillOpen",               -- 预览技能 界面打开
    PreviewSkillClose                           = "PreviewSkillClose",              -- 预览技能 界面关闭
    
    -- 预览动作
    Preview_Skill_Action_Attach                 = "Preview_Skill_Action_Attach",    -- 预览技能动作
    Preview_Skill_Action_UnAttach               = "Preview_Skill_Action_UnAttach",
    Preview_Skill_Action_Refresh                = "Preview_Skill_Action_Refresh",

    -- 技能表
    MagicInfoOpen                               = "MagicInfoOpen",                  -- 技能表 界面打开
    MagicInfoClose                              = "MagicInfoClose",                 -- 技能表 界面关闭

    Layer_ConfigSetting_Open                   = "Layer_ConfigSetting_Open",        -- 配置表设置面板
    Layer_ConfigSetting_Close                  = "Layer_ConfigSetting_Close",

    Delay_Exit_Game_Window_Close_Notice        = "Delay_Exit_Game_Window_Close_Notice", -- 延迟退出游戏通知
    Delay_Exit_Game_Window_Leave_World         = "Delay_Exit_Game_Window_Leave_World",  -- 游戏小退

    Layer_PreviewNode_Open                     = "Layer_PreviewNode_Open",
    Layer_PreviewNode_Close                    = "Layer_PreviewNode_Close",

    Layer_Player_Internal_Child_Del             = "Layer_Player_Internal_Child_Del", -- 人物内功
    Layer_Player_Internal_State_Open            = "Layer_Player_Internal_State_Open", 
    Layer_Player_Internal_Skill_Open            = "Layer_Player_Internal_Skill_Open",
    Layer_Player_Internal_Meridian_Open         = "Layer_Player_Internal_Meridian_Open",
    Layer_Player_Internal_Combo_Open            = "Layer_Player_Internal_Combo_Open",

    Layer_Hero_Internal_Child_Del               = "Layer_Hero_Internal_Child_Del", -- 英雄内功
    Layer_Hero_Internal_State_Open              = "Layer_Hero_Internal_State_Open", 
    Layer_Hero_Internal_Skill_Open              = "Layer_Hero_Internal_Skill_Open",
    Layer_Hero_Internal_Meridian_Open           = "Layer_Hero_Internal_Meridian_Open",
    Layer_Hero_Internal_Combo_Open              = "Layer_Hero_Internal_Combo_Open",

    PlayerInternalLevelChange                   = "PlayerInternalLevelChange",      -- 人物内功等级改变
    HeroInternalLevelChange                     = "HeroInternalLevelChange",        -- 英雄内功等级改变

    RefreshRecoverEditBox                       = "RefreshRecoverEditBox",      -- 关闭键盘

    Layer_PurchaseMain_Open                     = "Layer_PurchaseMain_Open",            -- 求购主界面
    Layer_PurchaseMain_Close                    = "Layer_PurchaseMain_Close",           
    Layer_PurchaseWorld_Open                    = "Layer_PurchaseWorld_Open",           -- 世界求购
    Layer_PurchaseWorld_Close                   = "Layer_PurchaseWorld_Close",
    Layer_PurchaseMy_Open                       = "Layer_PurchaseMy_Open",              -- 我的求购
    Layer_PurchaseMy_Close                      = "Layer_PurchaseMy_Close", 
    Layer_PurchaseSell_Open                     = "Layer_PurchaseSell_Open",            -- 求购-出售
    Layer_PurchaseSell_Close                    = "Layer_PurchaseSell_Close",  
    Layer_PurchasePutIn_Open                    = "Layer_PurchasePutIn_Open",           -- 求购-上架
    Layer_PurchasePutIn_Close                   = "Layer_PurchasePutIn_Close",          

    ChatFakeDropChange                          = "ChatFakeDropChange",               -- 假掉落分类显示开关改变

    Layer_Manual_Service_996_Open               = "Layer_Manual_Service_996_Open",    -- 打开996客服WebView
    Layer_Manual_Service_996_Close              = "Layer_Manual_Service_996_Close",   -- 关闭996客服WebView
}

return NoticeTable
