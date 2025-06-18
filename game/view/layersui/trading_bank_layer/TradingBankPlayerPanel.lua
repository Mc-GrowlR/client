local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankPlayerPanel = class("TradingBankPlayerPanel", BaseLayer)

function TradingBankPlayerPanel:ctor()
    TradingBankPlayerPanel.super.ctor(self)
end

function TradingBankPlayerPanel.create(...)
    local layer = TradingBankPlayerPanel.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function TradingBankPlayerPanel:Init(data)
    self._quickUI = ui_delegate(self)
    self._prodData = data.prodData
    if self._prodData then 
        local jobid = self._prodData.role_config_id or 0 -- 0-2 战法道
        jobid = tonumber(jobid)
        local jobName = GetJobName(jobid)
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        local upData = {
            prodid = self._prodData.id or 0,--商品id
            prod_name = self._prodData.role or "", --商品名字
            prod_type = "角色",--商品类型
            prod_price = self._prodData.price or 0,--商品价格
            prod_server =  LoginProxy:GetSelectedServerName() or "",--商品区服
            prod_job    = jobName or "",--商品职业
            prod_att    = SL:GetMetaValue("T.M.MAX_ATK") or 0,--"战斗力"
            prod_level  = self._prodData.role_level or 0
        }
        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyLayerRoleDetail, upData)
    end
    return true
end

function TradingBankPlayerPanel:InitGUI(Index)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_PLAYER_FRAME)
    local meta = {}
    meta.doTrack = handler(self, self.doTrack)
    meta.__index = meta
    setmetatable(PlayerHeroFrame_Look_TradingBank, meta)
    PlayerHeroFrame_Look_TradingBank.main(Index)
    self._CaptureNode = PlayerHeroFrame_Look_TradingBank._ui.Panel_1
    self._panel = self._quickUI.Panel_1

    self:InitEditMode()
end

function TradingBankPlayerPanel:InitEditMode( ... )
    local items = 
    {
        "Image_bg",
        "Node_panel",
        "Button_4",
        "Button_1",
        "Button_2",
        "Panel_btnList"
    }
    for _, widgetName in ipairs(items) do
        if self._quickUI[widgetName] then
            self._quickUI[widgetName].editMode = 1
        end
    end

    if PlayerHeroFrame_Look_TradingBank._pageIDs then
        for _, id in ipairs(PlayerHeroFrame_Look_TradingBank._pageIDs) do
            if self._quickUI["Button_page"..id] then
                self._quickUI["Button_page"..id].editMode = 1 
                local btnText = self._quickUI["Button_page"..id]:getChildByName("Text_name")
                if btnText then
                    btnText.editMode = 1
                end
            end
        end
    end
end

--1角色  2 英雄
function TradingBankPlayerPanel:ShowPlayerInfo(data,type)
    if not PlayerHeroFrame_Look_TradingBank._ishero and  type == 2 then
        PlayerHeroFrame_Look_TradingBank._curIdx = 1
        PlayerHeroFrame_Look_TradingBank.setButton(type)
        PlayerHeroFrame_Look_TradingBank.changeHeroAndRole()
        PlayerHeroFrame_Look_TradingBank.RefPanel()
        PlayerHeroFrame_Look_TradingBank.InitPage()
    else
        if PlayerHeroFrame_Look_TradingBank._pageid == data then
            return
        end
        
        if data == SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BAG or data == SLDefine.PlayerPage.MAIN_PLAYER_LAYER_STORAGE then 
            PlayerHeroFrame_Look_TradingBank._curIdx = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BAG == data and 2 or 3
            PlayerHeroFrame_Look_TradingBank.ChangePage({index = data })
        else 
            PlayerHeroFrame_Look_TradingBank._curIdx = 1
            PlayerHeroFrame_Look_TradingBank.OpenPage(data, {pageId = data})
        end
        PlayerHeroFrame_Look_TradingBank.RefPanel()
    end
end

local offset = 500
local EventTypeName = {
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP] = GET_STRING(600001000),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI] = GET_STRING(600001001),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO] = GET_STRING(600001002),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL] = GET_STRING(600001003),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE] = GET_STRING(600001004),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP] = GET_STRING(600001005),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BAG] = GET_STRING(600001006),   
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_STORAGE] = GET_STRING(600001007),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP + offset] = GET_STRING(600001008),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI + offset] = GET_STRING(600001009),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO + offset] = GET_STRING(600001010),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL + offset] = GET_STRING(600001011),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE + offset] = GET_STRING(600001012),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP + offset] = GET_STRING(600001013),
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BAG + offset] = GET_STRING(600001014),   
    [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_STORAGE + offset] = GET_STRING(600001015),
}

function TradingBankPlayerPanel:showHidePanel(data)
    PlayerHeroFrame_Look_TradingBank.showHidePanel(data)
end


function TradingBankPlayerPanel:doTrack(pageId,isHero)
    if not self._prodData then 
        return 
    end
    local pageid = pageId
    pageid = isHero and pageid + offset or pageid
    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    local jobid = self._prodData.role_config_id or 0 -- 0-2 战法道
    jobid = tonumber(jobid)
    local jobName = GetJobName(jobid)
    local upData = {
        prod_job    = jobName or "",--商品职业
        prod_att    = SL:GetMetaValue("T.M.MAX_ATK") or 0,--"战斗力"
        prod_level  = self._prodData.role_level or 0,
        role_second_level_tab_name = EventTypeName[pageid]
    }

    TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyLayerRoleDetailSecondTab, upData)
end

function TradingBankPlayerPanel:OnCloseMainLayer(data)
    PlayerHeroFrame_Look_TradingBank.OnCloseMainLayer(data)
end

return TradingBankPlayerPanel
