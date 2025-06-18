local registerTable =
{
    -- 缓存
    "WidgetCacheMediator",
    "CustomCacheMediator",
    "moved_layer/RTouchLayerMediator",                  -- 主界面邮件触发层
    "moved_layer/MovedLayerMediator",                   -- 移动层
    "role/KeepMovingController",                        -- 持续移动
    "role/RoleEffectMediator",                          -- 角色特效
    "scene/SceneOptionsMediator" ,                      -- 场景元素设置
    "scene/SceneParticleMediator",                      -- 场景粒子
    "scene/SceneEffectMediator",                        -- 场景特效
    "couping/CalcSkillCDMediator" ,                     -- 技能CD计算
    "couping/RobotMediator" ,                           -- 辅助机器人
    "couping/RobotHeroMediator" ,                       -- 辅助机器人
    "couping/CalcComboSkillCDMediator",                 -- 连击技能CD计算
    
    "couping/FrameRateMediator" ,                       -- 帧率检测
    "role/PlayerInputController" ,                      -- 玩家输入逻辑
    "role/AutoController" ,                             -- 自动策略路基
    "role/QuickSelectMediator" ,                        -- 快速选择目标
    "role/AssistMediator" ,                             -- 内挂辅助
    "throw_damage_number/ThrowDamageNumMediator" ,      -- 伤害飘字
    "disconnect/DisconnectMediator" ,                   -- disconnect

    --
    "mini_map/MiniMapMediator",                         -- 地图
    "chat_layer/ChatMediator" ,                         -- 聊天
    "chat_layer/ChatExtendMediator" ,                   -- 聊天 扩展
    "setting_layer/SettingInformationCollectMediator",  -- 设置-个人信息收集清单
    "extra_layer/CostItemCellMediator",                 -- 通用消耗
    "suicomponent/SUIComponentMediator",                -- 自定义组件
    "suicomponent/MetaValueMediator",                   -- 自定义组件
    "top_touch_layer/TopTouchMediator",                 -- 最上层点击
    "script_layer/PlayDiceMediator",                    -- 骰子
    "script_layer/ProgressBarMediator",                 -- 进度条
    "auction_layer/AuctionMainMediator",                -- 拍卖-主面板
    "auction_layer/AuctionWorldMediator",               -- 拍卖-世界拍卖
    "auction_layer/AuctionBiddingMediator",             -- 拍卖-竞拍中
    "auction_layer/AuctionPutListMediator",             -- 拍卖-上架列表
    "auction_layer/AuctionPutinMediator",               -- 拍卖-上架
    "auction_layer/AuctionPutoutMediator",              -- 拍卖-下架
    "auction_layer/AuctionTimeoutMediator",             -- 拍卖-超时
    "auction_layer/AuctionBidMediator",                 -- 拍卖-竞价
    "auction_layer/AuctionBuyMediator",                 -- 拍卖-一口价
    "guide_layer/GuideTaskMediator",                    -- 指引
    "guide_layer/GuideMediator",                        -- 指引


    "trade_layer/TradeMediator",                        -- 交易
    "stall/StallLayerMediator",                         -- 摆摊
    "stall/StallPutMediator",                           -- 摆摊输入价格窗口
    "stall/StallSetMediator",                           -- 摆摊输入摊位名

    
    "npc_layer/NPCLayerMediator",                       -- NPC
    "npc_layer/NPCStoreMediator",                       -- NPC store
    "npc_layer/NPCMakeDrugMediator",                    -- NPC 炼药
    "npc_layer/NPCSellOrRepaireMediator",               -- NPC 出售修理
    "npc_layer/NPCStorageMediator",                     -- npc 仓库
    
    
    "page_store_layer/PageStoreLayerMediator",          -- 商城
    "page_store_layer/StoreDetailLayerMediator",        -- 商城购买
    "page_store_layer/StoreFrameMediator",              -- 商城外框
    "page_store_layer/StoreRechargeMediator",           -- 充值
    "recharge_layer/RechargeQRCodeMediator",            -- 充值 二维码

    "rank_layer/RankLayerMediator",                     -- 排行榜

    "item_tips_layer/ItemTipsMediator" ,
    "item_tips_layer/FuncDockMediator",

    "mail_layer/SocialFrameMediator",                   -- 社交 外框
    "mail_layer/MailMediator",                          -- 邮件界面

    -- 组队
    "team_layer/TeamMediator",
    "team_layer/TeamInviteMediator",
    "team_layer/TeamApplyMediator",
    "team_layer/TeamBeInviteMediator",

    -- 行会
    "guild_layer/GuildFrameMediator",
    "guild_layer/GuildListLayerMediator",
    "guild_layer/GuildMainMediator",
    "guild_layer/GuildMemberLayerMediator",
    "guild_layer/GuildCreateLayerMediator", 
    "guild_layer/GuildApplyListLayerMediator",      -- 行会申请列表
    "guild_layer/GuildAllyApplyLayerMediator",      -- 行会结盟申请列表
    "guild_layer/GuildWarSponsorLayerMediator",     -- 发起行会宣战
    "guild_layer/GuildEditTitleLayerMediator",      -- 编辑行会称谓


    "near_player_layer/NearPlayerMediator",--附近玩家
    "common_tips_layer/CommonBubleInfoMediator",--组队邀请

    "friend_layer/FriendMediator",              --好友
    "friend_layer/AddFriendMediator",
    "friend_layer/FriendApplyMediator",
    "friend_layer/AddBlackListMediator",

    "firework_hall/FireWorkHallMediator",           --烟花
    "gold_box_layer/TreasureBoxMediator",           --宝箱
    "gold_box_layer/GoldBoxMediator",           --宝箱抽奖

    

    "auto_use_tips/AutoUseTipsMediator",            --自动使用tips


    "item_tips_layer/SplitLayerMediator",           --拆分

    --zfs begin----
    "player_layer/PlayerEquipLayerMediator",                        -- 人物装备
    "player_layer/PlayerBaseAttLayerMediator",                      -- 人物基础属性
    "player_layer/PlayerExtraAttLayerMediator",                     -- 人物额外属性
    "player_layer/PlayerBestRingLayerMediator",                     -- 人物极品首饰
    "player_layer/PlayerSkillLayerMediator",                        -- 人物技能
    "player_layer/PlayerTitleLayerMediator",                        -- 称号
    "player_layer/PlayerTitleTipsMediator",                         -- 称号提示
    "player_layer/PlayerSuperEquipMediator",                        -- 神装面板
    "player_layer/PlayerBuffMediator",                              -- buff面板

                                                                    
                                                                    --查看他人
    "player_look_layer/LookPlayerFrameMediator",                    -- 人物信息面板
    "player_look_layer/LookPlayerEquipLayerMediator",               -- 人物装备
    "player_look_layer/LookPlayerBestRingLayerMediator",             -- 人物极品首饰
    "player_look_layer/LookPlayerTitleLayerMediator",               -- 称号
    "player_look_layer/LookPlayerTitleTipsMediator",                -- 称号tips
    "player_look_layer/LookPlayerSuperEquipMediator",               -- 神装面板
    "player_look_layer/LookPlayerBuffMediator",                     -- buff面板

                                                                    --英雄
    "hero_layer/HeroEquipLayerMediator",                            -- 英雄装备
    "hero_layer/HeroBaseAttLayerMediator",                          -- 英雄基础属性
    "hero_layer/HeroExtraAttLayerMediator",                         -- 英雄额外属性
    "hero_layer/HeroBestRingLayerMediator",                         -- 英雄极品首饰
    "hero_layer/HeroSkillLayerMediator",                            -- 英雄技能
    "hero_layer/HeroStateLayerMediator",                            -- 英雄状态
    "hero_layer/HeroStateSelectLayerMediator",                      -- 英雄选择状态
    "hero_layer/HeroTitleLayerMediator",                            -- 英雄称号
    "hero_layer/HeroSuperEquipMediator",                            -- 英雄时装
    "hero_layer/HeroBuffMediator",                                  -- 英雄BUFF
                                                                    --查看英雄
    "hero_look_layer/LookHeroFrameMediator",                        -- 英雄信息面板
    "hero_look_layer/LookHeroEquipLayerMediator",                   -- 英雄装备
    "hero_look_layer/LookHeroBestRingLayerMediator",                -- 英雄极品首饰
    "hero_look_layer/LookHeroTitleLayerMediator",                   -- 称号
    "hero_look_layer/LookHeroSuperEquipMediator",                   -- 神装面板
    "hero_look_layer/LookHeroBuffMediator",                                  -- 英雄BUFF

    "trading_bank_layer/TradingBankFrameMediator", --交易行外框
    "trading_bank_layer/TradingBankBuyLayerMediator", --交易行购买
    "trading_bank_layer/TradingBankBuyRoleLayerMediator",--角色 
    "trading_bank_layer/TradingBankBuyEquipLayerMediator",--装备 
    "trading_bank_layer/TradingBankBuyMoneyLayerMediator", --货币
    "trading_bank_layer/TradingBankBuyMeLayerMediator", --指定我
    "trading_bank_layer/TradingBankBuyTipsLayerMediator",--筛选
    "trading_bank_layer/TradingBankSellLayerMediator", --交易行寄售
    "trading_bank_layer/TradingBankGoodsLayerMediator", --交易行货架
    "trading_bank_layer/TradingBankCaptureLayerMediator", -- 交易行截图界面
    "trading_bank_layer/TradingBankCaptureMaskLayerMediator",--截图遮罩
    -- "trading_bank_layer/TradingBankPhoneLayerMediator", --验证手机
    -- "trading_bank_layer/TradingBankTipsLayerMediator", --提示
    "trading_bank_layer/TradingBankPlayerPanelMediator",--用户信息
    "trading_bank_layer/TradingBankZFPanelMediator", -- 支付面版
    "trading_bank_layer/TradingBankCostZFPanelMediator", -- 支付面版
    "trading_bank_layer/TradingBankPlayerInfoMediator",--用户信息
    "trading_bank_layer/TradingBankZFLayerMediator", -- 支付面版
    "trading_bank_layer/TradingBankCostZFLayerMediator", -- 支付面版
    "trading_bank_layer/TradingBankZFPlayerLayerMediator", -- 支付面版
    "trading_bank_layer/TradingBankLookTextureMediator", -- 支付面版
    "trading_bank_layer/TradingBankMeLayerMediator", -- 我的
    "trading_bank_layer/TradingBankPowerfulLayerMediator",
    "trading_bank_layer/TradingBankReceiveLayerMediator",--收货
    "trading_bank_layer/TradingBankRefuseLayerMediator",--拒绝收货
    "trading_bank_layer/TradingBankUpModifyEquipPanelMediator", --上架 修改价格 装备
    "trading_bank_layer/TradingBankDownGetEquipPanelMediator", --下架 取回

    
    "trading_bank_layer_other/TradingBankFrameMediator_other", --交易行外框
    "trading_bank_layer_other/TradingBankBuyLayerMediator_other", --交易行购买
    "trading_bank_layer_other/TradingBankBuyRoleLayerMediator_other",--角色 
    "trading_bank_layer_other/TradingBankBuyMoneyLayerMediator_other", --货币
    "trading_bank_layer_other/TradingBankBuyRequestLayerMediator_other",--求购
    "trading_bank_layer_other/TradingBankBuyMeLayerMediator_other", --指定我
    "trading_bank_layer_other/TradingBankBuyTipsLayerMediator_other",--筛选
    "trading_bank_layer_other/TradingBankBuyServerNameTipsLayerMediator_other", -- 服务器名字筛选
    "trading_bank_layer_other/TradingBankSellLayerMediator_other", --交易行寄售
    "trading_bank_layer_other/TradingBankGoodsLayerMediator_other", --交易行货架
    "trading_bank_layer_other/TradingBankCaptureLayerMediator_other", -- 交易行截图界面
    "trading_bank_layer_other/TradingBankCaptureMaskLayerMediator_other",--截图遮罩
    "trading_bank_layer_other/TradingBankPlayerPanelMediator_other",--用户信息
    "trading_bank_layer_other/TradingBankZFPanelMediator_other", -- 支付面版
    "trading_bank_layer_other/TradingBankCostZFPanelMediator_other", -- 支付面版
    "trading_bank_layer_other/TradingBankPlayerInfoMediator_other",--用户信息
    "trading_bank_layer_other/TradingBankCostZFLayerMediator_other", -- 支付面版
    "trading_bank_layer_other/TradingBankZFPlayerLayerMediator_other", -- 支付面版
    "trading_bank_layer_other/TradingBankLookTextureMediator_other", -- 支付面版
    "trading_bank_layer_other/TradingBankMeLayerMediator_other", -- 我的
    "trading_bank_layer_other/TradingBankMeGetMoneyPanelLayerMediator_other", -- 我的-提现弹窗
    "trading_bank_layer_other/TradingBankMeRecodPanelLayerMediator_other", -- 我的-购买记录弹窗
    "trading_bank_layer_other/TradingBankPowerfulLayerMediator_other",
    "trading_bank_layer_other/TradingBankReceiveLayerMediator_other",--收货
    "trading_bank_layer_other/TradingBankRefuseLayerMediator_other",--拒绝收货
    "trading_bank_layer_other/TradingBankWaitPayPanelLayerMediator_other",--待支付
    "trading_bank_layer_other/TradingBankSuggestPanelLayerMediator_other",--意见反馈
    "trading_bank_layer_other/TradingBankIdentityLayerMediator_other",--实名
    "trading_bank_layer_other/TradingBankLookOtherServerPlayerLayerMediator_other",--查看其他服的角色信息
    "trading_bank_layer_other/TradingBankSearchServerLayerMediator_other",--筛选服务器

    
    
    
    "player_look_tradingbank_layer/TradingBankLookPlayerEquipLayerMediator",            -- 人物装备
    "player_look_tradingbank_layer/TradingBankLookPlayerBaseAttLayerMediator",          -- 人物基础属性
    "player_look_tradingbank_layer/TradingBankLookPlayerExtraAttLayerMediator",         -- 人物额外属性
    "player_look_tradingbank_layer/TradingBankLookPlayerSkillLayerMediator",
    "player_look_tradingbank_layer/TradingBankLookPlayerBestRingLayerMediator",         -- 人物极品首饰
    "player_look_tradingbank_layer/TradingBankLookPlayerTitleLayerMediator",            -- 称号
    "player_look_tradingbank_layer/TradingBankLookPlayerSuperEquipMediator",            -- 神装面板
    
    "hero_look_tradingbank_layer/TradingBankLookHeroEquipLayerMediator",                -- 人物装备
    "hero_look_tradingbank_layer/TradingBankLookHeroBaseAttLayerMediator",              -- 人物基础属性
    "hero_look_tradingbank_layer/TradingBankLookHeroExtraAttLayerMediator",             -- 人物额外属性
    "hero_look_tradingbank_layer/TradingBankLookHeroSkillLayerMediator",
    "hero_look_tradingbank_layer/TradingBankLookHeroBestRingLayerMediator",             -- 人物极品首饰
    "hero_look_tradingbank_layer/TradingBankLookHeroTitleLayerMediator",                -- 称号
    "hero_look_tradingbank_layer/TradingBankLookHeroSuperEquipMediator",                -- 神装面板

    "be_strong_layer/BeStrongUpMediator",
    "common_tips_layer/RedDotMediator", -- 红点提示
    "common_tips_layer/RedPointMediator", -- 红点提示
    
    "hero_look_layer/LookHeroFrameMediator",                    -- 人物信息面板
    "hero_look_layer/LookHeroEquipLayerMediator",               -- 人物装备
    "hero_look_layer/LookHeroBestRingLayerMediator",            -- 人物极品首饰
    "hero_look_layer/LookHeroTitleLayerMediator",               -- 称号
    "hero_look_layer/LookHeroSuperEquipMediator",               -- 神装面板

    "dark_layer/darklayerMediator",                                   --夜晚模式
    "common_tips_layer/CommonQuestionMediator",                       --答题
    "set_resolution_size_layer/setResolutionSizeLayerMediator",       --设置分辨率

        --新版设置
    "setting_layer/SettingFrameMediator",
    "setting_layer/SettingBasicMediator",                --基础设置
    "setting_layer/SettingWindowRangeMediator",          --视距
    "setting_layer/SettingLaunchMediator",               --战斗
    "setting_layer/SettingProtectMediator",              --保护
    "setting_layer/BossTipsLayerMediator",                   --boss提示
    "setting_layer/AddMonsterNameLayerMediator",                --增加boss
    "setting_layer/AddMonsterTypeMediator" ,               --增加boss Type
    "setting_layer/PickSettingLayerMediator",                -- 拾取设置父面板
    "setting_layer/ProtectSettingLayerMediator",             --保护物品设置
    "common_tips_layer/CommonSelectListMediator",                --选中文本
    "setting_layer/SettingAutoMediator",                 --挂机
    "setting_layer/SettingHelpMediator",                 --帮助
    "setting_layer/SkillPanelMediator",                      --已学技能
    "setting_layer/SkillRankPanelMediator",                  --技能排序
    "community_layer/CommunityLayerMediator",       
    --zfs end-----
    

    

    "sight_bead_layer/SightBeadMediator",                           --准星触摸移动
    
    "reincarnate_attr/ReinAttrMediator",            --转生属性点
    "common_tips_layer/CommonDescTipsMediator",     --通用描述页
    "hurt_tips_layer/HurtTipsMediator",             --残血提示
    "hurt_tips_layer/HeroHurtTipsMediator",         --英雄残血提示  

    "ssr_guide/SGuideMediator",                     -- ssr引导 
    "ssr/SSRUIManager",                             -- SSR ItemBox管理
    "compound_item_layer/CompoundItemLayerMediator",   -- 合成

    "box996_layer/Box996MainLayerMediator",             -- 996盒子
    "box996_layer/Box996TitleLayerMediator",            -- 996盒子  称号
    "box996_layer/Box996EveryDayLayerMediator",         -- 996盒子  每日礼包
    "box996_layer/Box996SuperLayerMediator",            -- 996盒子  超级礼包
    "box996_layer/Box996VIPLayerMediator",              -- 996盒子  盒子会员VIP
    "box996_layer/Box996GuideLayerMediator",            -- 996盒子  引导界面
    "box996_layer/Box996SVIPLayerMediator",             -- 996盒子  SVIP
    "box996_layer/Box996CloudPhoneLayerMediator",       -- 996盒子  云手机
    
    "main_monster/MainMonsterLayerMediator",            -- 怪物归属   
    "main_monster/MonsterBelongNetPlayerMediator",      -- 快捷归属操作  
    "main_near/MainNearPanelMediator",                  -- 附近显示页

    "internal_player/PlayerInternalStateLayerMediator",     -- 内功状态
    "internal_player/PlayerInternalSkillLayerMediator",     -- 内功技能
    "internal_player/PlayerInternalMeridianLayerMediator",  -- 内功经络
    "internal_player/PlayerInternalComboLayerMediator",     -- 内功连击

    "internal_hero/HeroInternalStateLayerMediator",     -- 内功状态
    "internal_hero/HeroInternalSkillLayerMediator",     -- 内功技能
    "internal_hero/HeroInternalMeridianLayerMediator",  -- 内功经络
    "internal_hero/HeroInternalComboLayerMediator",     -- 内功连击

    "purchase_layer/PurchaseMainMediator",                  -- 求购 - 主界面
    "purchase_layer/PurchaseWorldMediator",                 -- 世界求购                  
    "purchase_layer/PurchaseMyMediator",                    -- 我的求购
    "purchase_layer/PurchaseSellMediator",                  -- 求购 - 出售页  
    "purchase_layer/PurchasePutInMediator",                 -- 求购 - 上架

}


local table_mobile = 
{
    -- main ui
    "mainui/MainRootMediator" ,                         -- 主界面
    "mainui/MainTopMediator" ,                          -- 主界面 上方属性
    "mainui/MainPropertyMediator" ,                     -- 主界面 属性
    "mainui/MainMiniMapMediator" ,                      -- 主界面 小地图
    "mainui/MainGamePadMediator" ,                      -- 主界面 摇杆
    "mainui/MainSkillMediator" ,                        -- 主界面 技能
    "mainui/MainTargetMediator" ,                       -- 主界面 选择目标
    "mainui/MainSummonsMediator" ,                      -- 主界面 召唤物
    "mainui/MainAssistMediator" ,                       -- 主界面 任务
    "mainui/MainDigMediator" ,                          -- 主界面 挖肉
    "mainui/MainExtraMediator",                         -- 主界面 debug
    "mainui/MainCollectMediator",                       -- 采集物

    "player_layer/SkillSettingMediator",                -- 人物技能设置

    "manual_service_996_layer/ManualService996Mediator",    -- 客服  996客服 WebView
}

local table_pc = 
{
    -- main ui
    "mainui/MainRootMediator" ,                             -- 主界面
    "mainui-win32/MainPropertyMediator-win32" ,             -- 主界面 属性
    "mainui-win32/MainMiniMapMediator_win32" ,              -- 主界面 小地图
    "mainui-win32/MainAssistMediator-win32" ,               -- 主界面 任务
    "mainui/MainTargetMediator" ,                           -- 主界面 选择目标
    "mainui/MainExtraMediator",

    "player_layer/SkillSettingMediator_win32",              -- 人物技能设置
    "mainui-win32/PrivateChatMediator-win32",               -- 私聊
    "moved_layer/TopTouchLayerMediator",                    -- Top触摸层
}

local t = (global.isWinPlayMode and table_pc or table_mobile)
for _, v in ipairs(t) do
    table.insert(registerTable, v)
end

-- debug
if global.isDebugMode or global.isGMMode then
    local t = 
    {
        "test_layer/RichTextTestMediator",                  -- 测试面板
        "test_layer/CacheTestMediator",                     -- 内存展示面板
        "test_layer/ButtonPosMediator",                     -- TXT按钮位置
    }
    for _, v in ipairs(t) do
        table.insert(registerTable, v)
    end
end


------------------
local playerInfoMode2 = {
    "hero_layer/HeroFrameMediator",                     -- 英雄信息面板
    "player_layer/PlayerFrameMediator",                 -- 人物信息面板
    "bag_layer_hero/HeroBagLayerMediator",              -- 英雄背包
    "bag_layer/BagLayerMediator",                       -- 背包

}
local playerInfoMode1 = {
    "player_layer_merge/MergePlayerLayerMediator",                 -- 合并信息面板
    "bag_layer_merge/MergeBagLayerMediator",                       -- 合并背包

}
local t2 = playerInfoMode2

if not global.isWinPlayMode and tostring(SL:GetMetaValue("GAME_DATA","playerInfoMode")) == "1" and tostring(SL:GetMetaValue("GAME_DATA","syshero")) == "1" then--heromode 单面板模式
    t2 = playerInfoMode1
end
for _, v in ipairs(t2) do
    table.insert(registerTable, v)
end

--------------------
return registerTable