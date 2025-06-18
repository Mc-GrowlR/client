local DebugProxy = requireProxy("DebugProxy")
local JumpLayerProxy = class("JumpLayerProxy", DebugProxy)
JumpLayerProxy.NAME = global.ProxyTable.JumpLayerProxy

local cjson = require("cjson")

function JumpLayerProxy:ctor()
    JumpLayerProxy.super.ctor(self)
    self._config = {}
    self._groupConfig = {}

    self.LayerTable = {}

    self:InitJumpMessage()
end

function JumpLayerProxy:LoadConfig()
    local config = requireGameConfig("cfg_menulayer")
    for _, v in pairs(config) do
        if v.group_id == 0 then
            v.group_id = nil
        end
        self._config[v.id] = v

        if v.group_id then
            self._groupConfig[v.group_id] = self._groupConfig[v.group_id] or {}
            table.insert(self._groupConfig[v.group_id], v)
        end
    end
end

function JumpLayerProxy:GetConfigByID(id)
    return self._config[id]
end

function JumpLayerProxy:GetConfigByGroup(groupId)
    return self._groupConfig[groupId]
end

function JumpLayerProxy:GetGroupByID(id)
    if self:GetConfigByID(id) then
        return self:GetConfigByID(id).group_id
    end
    return nil
end

function JumpLayerProxy:InitJumpMessage()
	local L = global.LayerTable
	local NT = global.NoticeTable
	local JumpMsg = self.LayerTable
    JumpMsg[global.LayerTable.PlayerLayer]              = {open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP}
    JumpMsg[global.LayerTable.PlayerStateLayer]         = {open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI}
    JumpMsg[global.LayerTable.PlayerAttLayer]           = {open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO}
    JumpMsg[global.LayerTable.PlayerSkillLayer]         = {open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL}
    JumpMsg[global.LayerTable.PlayerTitleLayer]         = {open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE}
    JumpMsg[global.LayerTable.PlayerSuperEquipLayer]    = {open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP}
    JumpMsg[global.LayerTable.PlayerBuffLayer]          = {open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF}
    JumpMsg[global.LayerTable.PlayerBestRingLayer]      = {open = NT.Layer_PlayerBestRing_Open, close = NT.Layer_PlayerBestRing_Close}
    JumpMsg[global.LayerTable.BagPanel]                 = {open = NT.Layer_Bag_Open, close = NT.Layer_Bag_Close}
    JumpMsg[global.LayerTable.Trade]                    = {open = NT.Layer_Trade_Open, close = NT.Layer_Trade_Close}
    JumpMsg[global.LayerTable.StallLayer]               = {open = NT.Layer_StallLayer_Open, close = NT.Layer_StallLayer_Close}
    JumpMsg[global.LayerTable.StoreHotLayer]            = {open = NT.Layer_PageStore_Open, close = NT.Layer_PageStore_Close, extent = 1}         -- 热销
    JumpMsg[global.LayerTable.StoreBeautyLayer]         = {open = NT.Layer_PageStore_Open, close = NT.Layer_PageStore_Close, extent = 2}      -- 装饰
    JumpMsg[global.LayerTable.StoreEngineLayer]         = {open = NT.Layer_PageStore_Open, close = NT.Layer_PageStore_Close, extent = 3}      -- 功能
    JumpMsg[global.LayerTable.StoreFestivalLayer]       = {open = NT.Layer_PageStore_Open, close = NT.Layer_PageStore_Close, extent = 4}    -- 节日
    JumpMsg[global.LayerTable.StoreRechargeLayer]       = {open = NT.Layer_Recharge_Open, close = NT.Layer_Recharge_Close, extent = 5}            -- 充值
    JumpMsg[global.LayerTable.RankLayer]                = {open = NT.Layer_Rank_Open, close = NT.Layer_Rank_Close}
    JumpMsg[global.LayerTable.GuildMain]                = {open = NT.Layer_Guild_Main_Open, close = NT.Layer_Guild_Main_Close}
    JumpMsg[global.LayerTable.GuildMember]              = {open = NT.Layer_Guild_Member_Open, close = NT.Layer_Guild_Member_Close}
    JumpMsg[global.LayerTable.GuildList]                = {open = NT.Layer_Guild_List_Open, close = NT.Layer_Guild_List_Close}
    JumpMsg[global.LayerTable.GuildApply]               = {open = NT.Layer_Guild_ApplyList_Open, close = NT.Layer_Guild_ApplyList_Close}
    JumpMsg[global.LayerTable.GuildCreate]              = {open = NT.Layer_Guild_Create_Open, close = NT.Layer_Guild_Create_Close}
    JumpMsg[global.LayerTable.Team]                     = {open = NT.Layer_Team_Attach, close = NT.Layer_Team_UnAttach}
    JumpMsg[global.LayerTable.Mail]                     = {open = NT.Layer_Mail_Attach, close = NT.Layer_Mail_UnAttach}
    JumpMsg[global.LayerTable.Friend]                   = {open = NT.Layer_Friend_Attach, close = NT.Layer_Friend_UnAttach}
    JumpMsg[global.LayerTable.NearPlayer]               = {open = NT.Layer_NearPlayer_Attach, close = NT.Layer_NearPlayer_UnAttach}
    JumpMsg[global.LayerTable.SkillSetting]             = {open = NT.Layer_SkillSetting_Open, close = NT.Layer_SkillSetting_Close}
    JumpMsg[global.LayerTable.Auction]                  = {open = NT.Layer_AuctionMain_Open, close = NT.Layer_AuctionMain_Close}
    JumpMsg[global.LayerTable.CompoundLayer]            = {open = NT.Layer_CompoundItemLayer_Open, close = NT.Layer_CompoundItemLayer_Close}    -- 合成
    if global.OtherTradingBank then 
        JumpMsg[global.LayerTable.TradingBankBuyLayer]      = {open = NT.Layer_TradingBankBuyLayer_Open_other, close = NT.Layer_TradingBankBuyLayer_Close_other}
        JumpMsg[global.LayerTable.TradingBankSellLayer]     = {open = NT.Layer_TradingBankSellLayer_Open_other, close = NT.Layer_TradingBankSellLayer_Close_other}
        JumpMsg[global.LayerTable.TradingBankGoodsLayer]    = {open = NT.Layer_TradingBankGoodsLayer_Open_other, close = NT.Layer_TradingBankGoodsLayer_Close_other}
        JumpMsg[global.LayerTable.TradingBankMeLayer]       = {open = NT.Layer_TradingBankMeLayer_Open_other, close = NT.Layer_TradingBankMeLayer_Close_other}
    else
        JumpMsg[global.LayerTable.TradingBankBuyLayer]      = {open = NT.Layer_TradingBankBuyLayer_Open, close = NT.Layer_TradingBankBuyLayer_Close}
        JumpMsg[global.LayerTable.TradingBankSellLayer]     = {open = NT.Layer_TradingBankSellLayer_Open, close = NT.Layer_TradingBankSellLayer_Close}
        JumpMsg[global.LayerTable.TradingBankGoodsLayer]    = {open = NT.Layer_TradingBankGoodsLayer_Open, close = NT.Layer_TradingBankGoodsLayer_Close}
        JumpMsg[global.LayerTable.TradingBankMeLayer]       = {open = NT.Layer_TradingBankMeLayer_Open, close = NT.Layer_TradingBankMeLayer_Close}
    end
    JumpMsg[global.LayerTable.SettingBasic]             = {open = NT.Layer_SettingBasic_Open, close = NT.Layer_SettingBasic_Close}
    JumpMsg[global.LayerTable.SettingWindowRange]       = {open = NT.Layer_SettingWindowRange_Open, close = NT.Layer_SettingWindowRange_Close}
    JumpMsg[global.LayerTable.SettingFight]             = {open = NT.Layer_SettingLaunch_Open, close = NT.Layer_SettingLaunch_Close}
    JumpMsg[global.LayerTable.SettingProtect]           = {open = NT.Layer_SettingProtect_Open, close = NT.Layer_SettingProtect_Close}
    JumpMsg[global.LayerTable.SettingAuto]              = {open = NT.Layer_SettingAuto_Open, close = NT.Layer_SettingAuto_Close}
    JumpMsg[global.LayerTable.SettingHelp]              = {open = NT.Layer_SettingHelp_Open, close = NT.Layer_SettingHelp_Close}
end

function JumpLayerProxy:GetLayerMessageById(id)
    return self.LayerTable[id]
end

function JumpLayerProxy:CloseAllPanelByGroup(group)
    if self._groupConfig[group] then
        for _,v in pairs(self._groupConfig[group]) do
			self:ClosePanelById(v.id)
        end
    end
end

function JumpLayerProxy:ClosePanelById(id)
	if not id then return end
	if self.LayerTable[id] then
		global.Facade:sendNotification(self.LayerTable[id].close)
	end
end

function JumpLayerProxy:OpenPanelById(id, parent, extent)
	if not id then return end
	if self.LayerTable[id] then
		global.Facade:sendNotification(self.LayerTable[id].open, {parent = parent, extent = extent or self.LayerTable[id].extent})
	end
end

function JumpLayerProxy:CheckCondition(id)
    local config = self:GetConfigByID(id)
    if not config then
        return true
    end
    local ConditionProxy = global.Facade:retrieveProxy(global.ProxyTable.ConditionProxy)
    return ConditionProxy:CheckCondition(config.condition)
end

return JumpLayerProxy
