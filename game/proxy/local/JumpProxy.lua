local RemoteProxy = requireProxy("remote/RemoteProxy")
local JumpProxy = class("JumpProxy", RemoteProxy)
JumpProxy.NAME = global.ProxyTable.JumpProxy

local LINK_TYPE = {
    Equip               = 1,            -- 角色-装备
    State               = 2,            -- 角色-状态
    Attri               = 3,            -- 角色-属性
    Skill               = 4,            -- 角色-技能
    Title               = 5,            -- 角色-装备
    BestRing            = 6,            -- 角色-首饰盒
    Bag                 = 7,            -- 背包
    Stall               = 8,            -- 摆摊
    StoreHot            = 9,            -- 商城-热销
    StoreBeauty         = 10,           -- 商城-装饰
    StoreEngine         = 11,           -- 商城-功能
    StoreFestival       = 12,           -- 商城-节日
    GuildMain           = 13,           -- 行会-主界面
    GuildMember         = 14,           -- 行会成员列表
    GuildList           = 15,           -- 行会列表
    Mail                = 16,           -- 邮件
    Team                = 17,           -- 组队
    NearPlayer          = 18,           -- 附近玩家
    Buff                = 19,           -- 角色-buff/天赋

    MiniMap             = 24,           -- 小地图
    SkillSetting        = 25,           -- 技能设置
    StoreRecharge       = 26,           -- 充值
    Auction             = 27,           -- 拍卖行
    Friend              = 28,           -- 好友
    ExitToRole          = 29,           -- 小退
    GuildCreate         = 30,           -- 行会创建
    Guild               = 31,           -- 智能行会界面
    Rank                = 32,           -- 排行榜
    Trade               = 33,           -- 面对面交易 请求
    ForceExitToRole     = 34,           -- 强制小退
    TradingBank         = 35,           -- 交易行
    GuideEnter          = 36,           -- 引导进入[主界面按钮块显示切换]
    SuperEquip          = 37,           -- 角色-神装
    HeroEquip           = 41,           -- 英雄-装备
    HeroState           = 42,           -- 英雄-状态
    HeroAttri           = 43,           -- 英雄-属性
    HeroSkill           = 44,           -- 英雄-技能
    HeroTitle           = 45,           -- 英雄-称号
    HeroBestRing        = 46,           -- 英雄-首饰盒
    HeroBag             = 47,           -- 英雄-背包
    HeroSuperEquip      = 48,           -- 英雄-神装
    HeroBuff            = 49,           -- 英雄-BUFF
    ReinAttrPoint       = 51,           -- 转生属性点
    Chat                = 52,           -- 聊天
    PCPrivate           = 53,           -- PC 私聊记录页

    MagicJointAttack    = 99,           -- 释放合击

    AssistChange        = 110,          -- 主界面-任务栏
    Box996              = 111,          -- 盒子称号
    MainMiniMapChange   = 112,          -- 小地图伸缩
    PCResolution        = 113,          -- PC 分辨率设置
    ChatExtendEmoj      = 114,          -- 角色-表情
    ChatExtendBag       = 115,          -- 聊天小框-背包
    MainNear            = 116,          -- 主界面-附近列表
    CallPay             = 117,          -- 调用-支付

    SettingBasic        = 300,          -- 基础设置
    SettingWindowRange  = 301,          -- 视距
    SettingFight        = 302,          -- 战斗
    SettingProtect      = 303,          -- 保护
    SettingAuto         = 304,          -- 挂机
    SettingHelp         = 305,          -- 帮助
    SettingAutoPick     = 306,          -- 拾取
    
    KeFu                = 310,          -- 调用客服界面
    Community           = 320,          -- 社区帖子
    Compound            = 2201,         -- 合成

                                        -- 人物
    PlayerInternalState     = 401,      -- 内功状态
    PlayerInternalSkill     = 402,      -- 内功技能
    PlayerInternalMeridian  = 403,      -- 内功经络
    PlayerInternalCombo     = 404,      -- 内功连击

                                        -- 英雄
    HeroInternalState       = 501,      -- 内功状态
    HeroInternalSkill       = 502,      -- 内功技能
    HeroInternalMeridian    = 503,      -- 内功经络
    HeroInternalCombo       = 504,      -- 内功连击

    ReviewGift              = 311,      -- 好评有礼

    Purchase                = 601,      -- 求购
    
    ManualService996        = 701,      -- 996客服
}

function JumpProxy:ctor()
    JumpProxy.super.ctor(self)
    self._links = self:LoadDefine()
end

function JumpProxy:RegisterMsgHandler()
    JumpProxy.super.RegisterMsgHandler(self)
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_HYPERLINK_JUMP, handler(self, self.RespHyperlinkJump))
end

function JumpProxy:LoadDefine()
    return {
        [LINK_TYPE.Equip]               = {open = function () SL:OpenMyPlayerUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP}) end,  close = function () SL:CloseMyPlayerUI() end,       mediator = "PlayerEquipLayerMediator"},
        [LINK_TYPE.State]               = {open = function () SL:OpenMyPlayerUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI}) end,  close = function () SL:CloseMyPlayerUI() end,       mediator = "PlayerBaseAttLayerMediator"},
        [LINK_TYPE.Attri]               = {open = function () SL:OpenMyPlayerUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO}) end,  close = function () SL:CloseMyPlayerUI() end,       mediator = "PlayerExtraAttLayerMediator"},
        [LINK_TYPE.Skill]               = {open = function () SL:OpenMyPlayerUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL}) end,  close = function () SL:CloseMyPlayerUI() end,       mediator = "PlayerSkillLayerMediator"},
        [LINK_TYPE.Title]               = {open = function () SL:OpenMyPlayerUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE}) end,  close = function () SL:CloseMyPlayerUI() end,       mediator = "PlayerTitleLayerMediator"},
        [LINK_TYPE.SuperEquip]          = {open = function () SL:OpenMyPlayerUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP}) end,  close = function () SL:CloseMyPlayerUI() end,       mediator = "PlayerSuperEquipMediator"},
        [LINK_TYPE.Buff]                = {open = function () SL:OpenMyPlayerUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF}) end, close = function () SL:CloseMyPlayerUI() end,       mediator = "PlayerBuffMediator"},

        [LINK_TYPE.BestRing]            = {open = function () SL:OpenBestRingBoxUI(1) end,          close = function () SL:CloseBestRingBoxUI(1) end,   mediator = "PlayerBestRingLayerMediator"},
        [LINK_TYPE.Bag]                 = {open = function () SL:OpenBagUI() end,                   close = function () SL:CloseBagUI() end,            mediator = tonumber(SL:GetMetaValue("GAME_DATA", "playerInfoMode")) == 1 and "MergeBagLayerMediator" or "BagLayerMediator"},
        [LINK_TYPE.Stall]               = {open = function () SL:OpenStallLayerUI() end,            close = function () SL:CloseStallLayerUI() end,     mediator = "StallLayerMediator"},

        [LINK_TYPE.StoreHot]            = {open = function () SL:OpenStoreUI(1) end,                close = function () SL:CloseStoreUI() end,          mediator = "PageStoreLayerMediator"},
        [LINK_TYPE.StoreBeauty]         = {open = function () SL:OpenStoreUI(2) end,                close = function () SL:CloseStoreUI() end,          mediator = "PageStoreLayerMediator"},
        [LINK_TYPE.StoreEngine]         = {open = function () SL:OpenStoreUI(3) end,                close = function () SL:CloseStoreUI() end,          mediator = "PageStoreLayerMediator"},
        [LINK_TYPE.StoreFestival]       = {open = function () SL:OpenStoreUI(4) end,                close = function () SL:CloseStoreUI() end,          mediator = "PageStoreLayerMediator"},
        [LINK_TYPE.StoreRecharge]       = {open = function () SL:OpenStoreUI(5) end,                close = function () SL:CloseStoreUI() end,          mediator = "PageStoreLayerMediator"},
        [LINK_TYPE.CallPay]             = {open = function () SL:OpenCallPayUI() end},

        [LINK_TYPE.GuildMain]           = {open = function () SL:OpenGuildMainUI(1) end,            close = function () SL:CloseGuildMainUI() end,      mediator = "GuildMainMediator"},
        [LINK_TYPE.GuildMember]         = {open = function () SL:OpenGuildMainUI(2) end,            close = function () SL:CloseGuildMainUI() end,      mediator = "GuildMemberLayerMediator"},
        [LINK_TYPE.GuildList]           = {open = function () SL:OpenGuildMainUI(3) end,            close = function () SL:CloseGuildMainUI() end,      mediator = "GuildListLayerMediator"},
        [LINK_TYPE.Guild]               = {open = function () SL:OpenGuildMainUI() end,             close = function () SL:CloseGuildMainUI() end,      mediator = "GuildFrameMediator"},
        [LINK_TYPE.GuildCreate]         = {open = function () SL:OpenGuildCreateUI() end,           close = function () SL:CloseGuildCreateUI() end,    mediator = "GuildCreateLayerMediator"},
        
        [LINK_TYPE.NearPlayer]          = {open = function () SL:OpenSocialUI(1) end,               close = function () SL:CloseSocialUI() end,         mediator = "NearPlayerMediator"},
        [LINK_TYPE.Team]                = {open = function () SL:OpenSocialUI(2) end,               close = function () SL:CloseSocialUI() end,         mediator = "TeamMediator"},
        [LINK_TYPE.Friend]              = {open = function () SL:OpenSocialUI(3) end,               close = function () SL:CloseSocialUI() end,         mediator = "FriendMediator"},
        [LINK_TYPE.Mail]                = {open = function () SL:OpenSocialUI(4) end,               close = function () SL:CloseSocialUI() end,         mediator = "MailMediator"},

        [LINK_TYPE.MiniMap]             = {open = function () SL:OpenMiniMap() end,                 close = function () SL:CloseMiniMap() end,          mediator = "MiniMapMediator"},
        [LINK_TYPE.SkillSetting]        = {open = function () SL:OpenSkillSettingUI() end,          close = function () SL:CloseSkillSettingUI() end,   mediator = "Layer_SkillSetting_Open"},
        [LINK_TYPE.Auction]             = {open = function () SL:OpenAuctionUI() end,               close = function () SL:CloseAuctionUI() end,        mediator = "AuctionMainMediator"},

        [LINK_TYPE.ExitToRole]          = {open = function () SL:ExitToRoleUI() end},
        [LINK_TYPE.ForceExitToRole]     = {open = function () SL:ForceExitToRoleUI() end},

        [LINK_TYPE.GuideEnter]          = {open = function (param) SL:OpenGuideEnter(param) end,    close = function () SL:CloseGuideEnter() end},


        [LINK_TYPE.Rank]                = {open = function(param) SL:OpenRankUI(param) end,         close = function () SL:CloseRankUI() end,           mediator = "RankLayerMediator"},
        [LINK_TYPE.Trade]               = {open = function () SL:OpenTradeUI() end,                 close = function () SL:CloseTradeUI() end,          mediator = "TradeMediator"},
        [LINK_TYPE.TradingBank]         = {open = function () SL:OpenTradingBankUI() end,           close = function () SL:CloseTradingBankUI() end,    mediator = "TradingBankFrameMediator"},

        [LINK_TYPE.HeroEquip]           = {open = function () SL:OpenMyPlayerHeroUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroEquipLayerMediator"},
        [LINK_TYPE.HeroState]           = {open = function () SL:OpenMyPlayerHeroUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroBaseAttLayerMediator"},
        [LINK_TYPE.HeroAttri]           = {open = function () SL:OpenMyPlayerHeroUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroExtraAttLayerMediator"},
        [LINK_TYPE.HeroSkill]           = {open = function () SL:OpenMyPlayerHeroUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroSkillLayerMediator"},
        [LINK_TYPE.HeroTitle]           = {open = function () SL:OpenMyPlayerHeroUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroTitleLayerMediator"},
        [LINK_TYPE.HeroSuperEquip]      = {open = function () SL:OpenMyPlayerHeroUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroSuperEquipMediator"},
        [LINK_TYPE.HeroBuff]            = {open = function () SL:OpenMyPlayerHeroUI({extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroBuffMediator"},
        [LINK_TYPE.HeroBestRing]        = {open = function () SL:OpenBestRingBoxUI(2) end,          close = function () SL:CloseBestRingBoxUI(2) end,   mediator = "HeroBestRingLayerMediator"},
        [LINK_TYPE.HeroBag]             = {open = function () SL:OpenHeroBagUI() end,               close = function () SL:CloseHeroBagUI() end,        mediator = "HeroBagLayerMediator"},
        [LINK_TYPE.ReinAttrPoint]       = {open = function () SL:OpenReinAttrUI() end,              close = function () SL:CloseReinAttrUI() end,       mediator = "ReinAttrMediator"},


        [LINK_TYPE.Chat]                = {open = function () SL:OpenChatUI() end,                  close = function () SL:CloseChatUI() end,           mediator = "ChatMediator"},
        [LINK_TYPE.ChatExtendEmoj]      = {open = function () SL:OpenChatExtendUI(2) end,           close = function () SL:CloseChatExtendUI() end,     mediator = "ChatExtendMediator"},
        [LINK_TYPE.ChatExtendBag]       = {open = function () SL:OpenChatExtendUI(3) end,           close = function () SL:CloseChatExtendUI() end,     mediator = "ChatExtendMediator"},

        [LINK_TYPE.MagicJointAttack]    = {open = function () SL:RequestMagicJointAttack() end},
        [LINK_TYPE.AssistChange]        = {open = function () SL:OpenAssistUI() end,                close = function () SL:CloseAssistUI() end},
        [LINK_TYPE.Box996]              = {open = function(param) SL:OpenBox996UI(param) end,       close = function () SL:CloseBox996UI() end,         mediator = "Box996MainLayerMediator"},
        [LINK_TYPE.MainMiniMapChange]   = {open = function () SL:OpenMiniMapChangeUI() end,         close = function () SL:CloseMiniMapChangeUI() end},
        [LINK_TYPE.PCResolution]        = {open = function () SL:OpenResolutionSetUI() end,         close = function () SL:CloseResolutionSetUI() end,  mediator = "setResolutionSizeLayerMediator"},
        [LINK_TYPE.MainNear]            = {open = function () SL:OpenMainNearUI() end,              close = function () SL:CloseMainNearUI() end,       mediator = "MainNearPanelMediator"},

        [LINK_TYPE.SettingBasic]        = {open = function () SL:OpenSettingUI(1) end,               close = function () SL:CloseSettingUI() end,       mediator = "SettingBasicMediator"},
        [LINK_TYPE.SettingWindowRange]  = {open = function () SL:OpenSettingUI(2) end,               close = function () SL:CloseSettingUI() end,       mediator = "SettingWindowRangeMediator"},
        [LINK_TYPE.SettingFight]        = {open = function () SL:OpenSettingUI(3) end,               close = function () SL:CloseSettingUI() end,       mediator = "SettingLaunchMediator"},
        [LINK_TYPE.SettingProtect]      = {open = function () SL:OpenSettingUI(4) end,               close = function () SL:CloseSettingUI() end,       mediator = "SettingProtectMediator"},
        [LINK_TYPE.SettingAuto]         = {open = function () SL:OpenSettingUI(5) end,               close = function () SL:CloseSettingUI() end,       mediator = "SettingAutoMediator"},
        [LINK_TYPE.SettingHelp]         = {open = function () SL:OpenSettingUI(6) end,               close = function () SL:CloseSettingUI() end,       mediator = "SettingHelpMediator"},
        [LINK_TYPE.SettingAutoPick]     = {open = function () SL:OpenPickSettingUI() end,            close = function () SL:ClosePickSettingUI() end,   mediator = "PickSettingLayerMediator"},


        [LINK_TYPE.KeFu]                = {open = function () SL:OpenKefuUI() end},

        [LINK_TYPE.PCPrivate]           = {open = function() SL:OpenPCPrivateUI() end,              close = function() SL:ClosePCPrivateUI() end,       mediator = "PrivateChatMediator"}, 
        
        [LINK_TYPE.Compound]            = {open = function(param) SL:OpenCompoundItemsUI(param) end,          close = function() SL:CloseCompoundItemsUI() end,   mediator = "CompoundItemLayerMediator"},
    
        [LINK_TYPE.PlayerInternalState]     = {open = function () SL:OpenMyPlayerUI({extent = 1, type = 2}) end,         close = function () SL:CloseMyPlayerUI() end,   mediator = "PlayerInternalStateLayerMediator"},
        [LINK_TYPE.PlayerInternalSkill]     = {open = function () SL:OpenMyPlayerUI({extent = 2, type = 2}) end,         close = function () SL:CloseMyPlayerUI() end,   mediator = "PlayerInternalSkillLayerMediator"},
        [LINK_TYPE.PlayerInternalMeridian]  = {open = function () SL:OpenMyPlayerUI({extent = 3, type = 2}) end,         close = function () SL:CloseMyPlayerUI() end,   mediator = "PlayerInternalMeridianLayerMediator"},
        [LINK_TYPE.PlayerInternalCombo]     = {open = function () SL:OpenMyPlayerUI({extent = 4, type = 2}) end,         close = function () SL:CloseMyPlayerUI() end,   mediator = "PlayerInternalComboLayerMediator"},

        [LINK_TYPE.HeroInternalState]       = {open = function () SL:OpenMyPlayerHeroUI({extent = 1, type = 2}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroInternalStateLayerMediator"},
        [LINK_TYPE.HeroInternalSkill]       = {open = function () SL:OpenMyPlayerHeroUI({extent = 2, type = 2}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroInternalSkillLayerMediator"},
        [LINK_TYPE.HeroInternalMeridian]    = {open = function () SL:OpenMyPlayerHeroUI({extent = 3, type = 2}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroInternalMeridianLayerMediator"},
        [LINK_TYPE.HeroInternalCombo]       = {open = function () SL:OpenMyPlayerHeroUI({extent = 4, type = 2}) end,         close = function () SL:CloseMyPlayerHeroUI() end,   mediator = "HeroInternalComboLayerMediator"},
        
        [LINK_TYPE.ReviewGift]              = {open = function () SL:ReviewGift() end},
        [LINK_TYPE.Purchase]                = {open = function () SL:OpenPurchaseUI() end,              close = function () SL:ClosePurchaseUI() end,           mediator = "PurchaseMainMediator"},
        [LINK_TYPE.Community]               = {open = function () SL:OpenCommunityUI() end, close = function ()  SL:CloseCommunityUI() end},

        [LINK_TYPE.ManualService996]        = {open = function() SL:RequestOpen996ManualService() end},
    }
end

function JumpProxy:FindLinkByID(jumpID)
    -- 兼容老跳转id
    local map = {
        [20] = LINK_TYPE.SettingProtect,
        [21] = LINK_TYPE.SettingAutoPick,
        [22] = LINK_TYPE.SettingFight,
        [23] = LINK_TYPE.SettingBasic
    }
    if jumpID >= 20 and jumpID <= 23 then
        local key = map[jumpID]
        return self._links[key]
    end
    return self._links[jumpID]
end

function JumpProxy:ExecuteByParam(param, jumpID, destPos,isOpen)
    if not param then
        return nil
    end
    local JumpLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.JumpLayerProxy)
    local slices = string.split(param, "#")
    local command = slices[1]

    if command == "find_point" then
        local movePos = 
        {
            mapID   = slices[2],
            x       = tonumber(slices[3]),
            y       = tonumber(slices[4]),
            autoMoveType = global.MMO.AUTO_MOVE_TYPE_CHAT
        }
        global.Facade:sendNotification(global.NoticeTable.AutoMoveBegin, movePos)
    
    elseif command == "item_tips" then
        self:JumpToItemTips(tonumber(slices[2]), destPos)
    end
end

function JumpProxy:JumpToItemTips(itemIndex, destPos)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemInfo  = ItemConfigProxy:GetItemDataByIndex(itemIndex)
    local data      = {}
    data.itemData   = itemInfo
    data.pos        = destPos
    global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, data)
end

function JumpProxy:JumpTo(jumpID, param, param1)
    print("+++++++++++++hyper link jump", jumpID)
    local link  = self:FindLinkByID(tonumber(jumpID) or 0)
    local openLayer = function()
        if link and link.open then
            link.open(param)           
        end
    end
    local closeLayer = function()
        if link and link.close then
            link.close(param)
        end
    end
    if not param1 or param1 == 0 then--0走打开 但是已经打开的有些layer会自己关闭
        -- 伸缩类型
        if jumpID == LINK_TYPE.MainMiniMapChange then
            global.Facade:sendNotification(global.NoticeTable.MainMiniMapChange, MainMiniMap._showState)
            return
        elseif jumpID == LINK_TYPE.AssistChange then
            global.Facade:sendNotification(global.NoticeTable.Layer_Assist_ChangeHide, MainAssist._hideAssist)
            return
        end
        if link and link.close and link.mediator and global.Facade:retrieveMediator(link.mediator) and global.Facade:retrieveMediator(link.mediator)._layer then
            closeLayer() 
        else
            openLayer()
        end
    else
        if param1 == 1 then -- 强制打开
            if link and link.mediator and global.Facade:retrieveMediator(link.mediator) and global.Facade:retrieveMediator(link.mediator)._layer then
                return 
            end
            openLayer()
        else --关闭
            closeLayer()
        end
    end
end

function JumpProxy:RespHyperlinkJump(msg)
    local header = msg:GetHeader()
    local jumpID = header.recog
    print("++++++++++++++++++++++++++++++ service jump", jumpID)
    
    local param1 = tonumber(header.param1) or 0--0走打开 但是已经打开的有些lyaer会自己关闭 1强制打开 2关闭;
    local param2 = header.param2 or 0
    self:JumpTo(jumpID, param2, param1)
end

function JUMPTO(id, param)
    local JumpProxy = global.Facade:retrieveProxy(global.ProxyTable.JumpProxy)
    JumpProxy:JumpTo(id, param)
end

return JumpProxy