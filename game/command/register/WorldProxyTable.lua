local registerTable =
{
    "local/JumpLayerProxy" ,                    -- jump layer(必须放在前面)
    "local/JumpProxy",                          -- 超链跳转
    "local/CodeDOMUIProxy",                     -- 自动生成代码界面管理
    "local/AttrConfigProxy",                    -- 一些前端基础设定数据
    "local/SceneOptionsProxy",                  -- scene options
    "local/ThrowDamageNumProxy",                -- 伤害飘字
    -- "local/NativeBridgeProxy",                  -- 底层交互
    "local/VoiceManagerProxy",                  -- 语音
    "local/ActorPickerProxy" ,                  -- actor picker
    "local/PlayerInputProxy" ,                  -- player input
    "local/ManualService996Proxy",              -- 客服会话

    "remote/RedPointProxy",                     -- 前端条件判断红点提示
    "remote/PlayerPropertyProxy",               -- 角色属性数据 proxy
    "remote/MoneyProxy",                        -- 货币
    "local/ItemConfigProxy",                    -- 道具相关
    "remote/BagProxy" ,                         -- 背包数据 Proxy
    "remote/EquipProxy" ,                       -- 装备数据 Proxy
    "remote/SkillProxy" ,                       -- 技能(服务器下发, Proxy
    "remote/DarkLayerProxy",                    -- 黑夜模式 --要在map前面
    "remote/MapProxy" ,                         -- 地图相关
    "remote/AutoProxy" ,                        -- 角色 一些状态数据
    "remote/PayProxy" ,                         -- 付费 proxy
    "remote/NPCProxy",                          -- npc 相关
    "remote/NPCRepaireProxy",                   -- npc 修理
    "remote/NPCSellProxy",                      -- npc 出售
    "remote/NPCStorageProxy",                   -- npc 仓库
    "remote/QuickUseProxy",                     -- 快捷栏
    "remote/BuffProxy",                         -- buff proxy
    "remote/AssistProxy",                       -- 内挂
    "remote/NPCDoSomethingProxy",               -- 自定义放入框  类似于NPC修理/出售

    ---------------------

    -- 
    "remote/ChatProxy",                         -- 聊天
    "remote/TradeProxy",                        -- 交易
    "remote/StallProxy",                    -- 摆摊
    "remote/GameSettingProxy",                  -- 游戏设置
    "remote/BubbleTipsProxy",                   -- 气泡
    "remote/GameConfigMgrProxy",                -- 游戏配置
    "remote/RechargeProxy",                     -- 充值
    "remote/SummonsProxy",                      -- 召唤物
    "remote/CloudStorageProxy",                 -- 云端存储
    "remote/MissionProxy",                      -- 任务系统
    "remote/AuctionProxy",                      -- 拍卖行
    "remote/ServerOptionsProxy",                -- 游戏内开关
    "remote/GuideProxy",                        -- 新手指引
    "remote/MiniMapProxy",                      -- 小地图


    "remote/ItemTipsProxy",                     -- ItemTipsProxy
    "remote/FriendProxy",                       -- 好友
    "remote/GuildPlayerProxy",                  -- 行会职位相关
    "remote/GuildProxy",                        -- 行会相关
    "remote/MailProxy",
    "remote/FuncDockProxy",                     -- 功能按钮
    "remote/TeamProxy",                         -- 组队
    "remote/ServerOpenUrlProxy",                -- 打开网页
    "remote/PlayerTitleProxy",                  -- 称号

    "local/ItemUseProxy",                       -- 道具使用
    "local/ItemMoveProxy",                      -- 道具丢弃
    "remote/AutoUseItemProxy",                  -- 自动使用
    "remote/PageStoreProxy",                    -- 商城
    "remote/RankProxy",                         -- 排行榜

    "remote/LookPlayerProxy",                   -- 查看玩家

    "remote/DisconnectProxy",                   -- disconnect

    "remote/ServerTimeProxy",                   -- 获取服务器时间

    "local/ItemManagerProxy",                   -- 道具一些管理
    "remote/SceneEffectProxy",                  -- 场景特效

    "remote/FireWorkHallProxy",                 -- 烟花
    
    "remote/GoldBoxProxy",                      -- 宝箱抽奖
    "remote/EquipRetrieveProxy",                -- 装备回收

    -- zfs begin --- 
    "remote/TradingBankLookPlayerProxy",        -- 交易行查看玩家
    "remote/RemindUpgradeProxy",                -- 提升提示
    "remote/RedDotProxy",                       -- 红点提示
    "remote/BubbleProxy",                       -- 前端条件 气泡

    "remote/HeroEquipProxy",                    -- 英雄装备信息
    "remote/HeroPropertyProxy",                 -- 英雄属性    
    "remote/HeroSkillProxy",                    -- 英雄技能   
    "remote/HeroBagProxy",                      -- 英雄背包
    "remote/HeroTitleProxy",                    -- 英雄称号
    "remote/PickupSpriteProxy",
    "remote/RealNameProxy",                     -- 实名认证

    "remote/DarkLayerProxy",                    -- 黑夜模式
    "remote/QuestionProxy",                     -- 答题
    
    -- zfs end ---

    "remote/ReinAttrProxy",                     -- 转生属性点
    "remote/NPCNewTypeOkProxy",                 -- OK框新类型
    "remote/TextReviewProxy",                   -- 文本审核

    "remote/SceneImprisonEffectProxy",          -- 禁锢

    "remote/CDKProxy",                          -- 兑换码

    "remote/PetsEquipProxy",                    -- 宠物装备

    "remote/ItemCompoundProxy",                 -- 合成
    "remote/Box996Proxy",                       -- 996传奇盒子

    "remote/InformationProxy",                  -- 收集个人信息

    "remote/HorseProxy",                        -- 骑马

    "remote/MeridianProxy",                     -- 内功经络

    "remote/PurchaseProxy",                     -- 求购
}

return registerTable