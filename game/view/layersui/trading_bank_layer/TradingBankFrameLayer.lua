

local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankFrameLayer = class("TradingBankFrameLayer", BaseLayer)

function TradingBankFrameLayer:ctor()
    TradingBankFrameLayer.super.ctor(self)
    self._GROUPID = 111
    self._Pages = {}
    self._index = 0
    self._ui = nil
    -- 页签ID
    self._pageIDs = {
        global.LayerTable.TradingBankBuyLayer,
        global.LayerTable.TradingBankSellLayer,
        global.LayerTable.TradingBankGoodsLayer,
        global.LayerTable.TradingBankMeLayer,
    }
end

function TradingBankFrameLayer.create(...)
    local layer = TradingBankFrameLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function TradingBankFrameLayer:Init(skipPage)
    self._quickUI = ui_delegate(self)
    self._ui = self._quickUI
    GUI:LoadInternalExport(self, "trading_bank/trading_bank_frame")
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")

    local PMainUI = self._ui["PMainUI"]
    GUI:setPosition(PMainUI, winSizeW / 2, winSizeH / 2)

    -- 关闭按钮
    GUI:addOnClickEvent(self._ui["CloseButton"], function() GUI:Win_Close(self) end)

    self._Pages = {}
    self._index = 0

    local posY = 380
    local distance = 75

    for i, layerId in ipairs(self._pageIDs) do
        local btnName = "page_cell_"..i
        local page = self._ui[btnName]
        GUI:Win_SetParam(page, layerId)
        if SL:CheckMenuLayerConditionByID(layerId) then
            GUI:addOnClickEvent(GUI:getChildByName(page, "TouchSize"), function()
                self:PageTo(layerId)
                SL:RequestTradingBankBtnUpload(i)
            end)
        else
            GUI:addOnClickEvent(GUI:getChildByName(page, "TouchSize"), function()
                SL:ShowSystemTips("条件不满足!")
            end)
        end
        self._Pages[btnName] = page
    end
    self:PageTo(self._pageIDs[skipPage or 1])
    return true
end



function TradingBankFrameLayer:PageTo(index)
    if not index or self._index == index then
        return false
    end

    self:OnClose()

    self._index = index

    self:OnOpen()
    self:SetPageStatus()
end

function TradingBankFrameLayer:OnClose()
    SL:CloseMenuLayerByID(self._index)
end

function TradingBankFrameLayer:getCurPageID()
    return self._index
end

function TradingBankFrameLayer:changPageById(id)
    self:PageTo(id)
end

function TradingBankFrameLayer:OnOpen()
    if self._ui and self._ui["AttachLayout"] then
        SL:OpenMenuLayerByID(self._index, self._ui["AttachLayout"])
    end
end

function TradingBankFrameLayer:SetPageStatus()
    for k, uiPage in pairs(self._Pages) do
        if uiPage then
            local index = GUI:Win_GetParam(uiPage)
            local isSel = index == self._index and true or false
            GUI:Button_setBright(uiPage, not isSel)
            GUI:setLocalZOrder(uiPage, isSel and 2 or 0)

            local uiText = GUI:getChildByName(uiPage, "PageText")
            if uiText then
                GUI:Text_setFontSize(uiText, SL:GetMetaValue("WINPLAYMODE") and 13 or 16)
                local selColor = SL:GetMetaValue("WINPLAYMODE") and "#e6e7a7" or "#f8e6c6"
                GUI:Text_setTextColor(uiText, isSel and selColor or "#807256")
                GUI:Text_enableOutline(uiText, "#111111", 2)
                if isSel then
                    self:UpdateTitle(string.gsub(GUI:Text_getString(uiText), "\n", ""))
                end
            end
        end
    end
end

function TradingBankFrameLayer:UpdateTitle(text)
    if not self._ui then
        return false
    end
    if not self._ui["TitleText"] then
        return false
    end
    self._ui.TitleText:setString(text)
end

function TradingBankFrameLayer:changPage(id)
    self:changPageById(id)
end

return TradingBankFrameLayer
