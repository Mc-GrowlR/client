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
    self._jobDesc = { GET_STRING(600000110), GET_STRING(600000111), GET_STRING(600000112), GET_STRING(600000113) }
    GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_frame")
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")

    local PMainUI = self._ui["PMainUI"]
    GUI:setPosition(PMainUI, winSizeW / 2, winSizeH / 2)

    GUI:Win_SetDrag(self, PMainUI)
    GUI:setMouseEnabled(PMainUI, true)

    -- 关闭按钮
    GUI:addOnClickEvent(self._ui["CloseButton"], function() GUI:Win_Close(self) end)

    self._Pages = {}
    self._index = 0

    local posY = 380
    local distance = 75

    local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    self.OtherTradingBankProxy = OtherTradingBankProxy
    for i, layerId in ipairs(self._pageIDs) do
        local btnName = "page_cell_"..i
        local page = self._ui[btnName]
        GUI:Win_SetParam(page, layerId)
        if SL:CheckMenuLayerConditionByID(layerId) then
            GUI:addOnClickEvent(GUI:getChildByName(page, "TouchSize"), function()
                if layerId == global.LayerTable.TradingBankBuyLayer then 
                    OtherTradingBankProxy:doTrack(OtherTradingBankProxy.UpLoadData.TraingBuyLayerClick)
                elseif layerId == global.LayerTable.TradingBankSellLayer then 
                    OtherTradingBankProxy:doTrack(OtherTradingBankProxy.UpLoadData.TraingSellLayerClick)
                    local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )
                    if not MapProxy:IsInSafeArea() then--安全区寄售
                        ShowSystemTips(GET_STRING(600000703))
                        return
                    end
                elseif layerId == global.LayerTable.TradingBankGoodsLayer then 
                    OtherTradingBankProxy:doTrack(OtherTradingBankProxy.UpLoadData.TraingGoodsLayerClick)
                elseif layerId == global.LayerTable.TradingBankMeLayer then 
                    OtherTradingBankProxy:doTrack(OtherTradingBankProxy.UpLoadData.TraingMeLayerClick)
                end
                self:PageTo(layerId)
            end)
        else
            GUI:addOnClickEvent(GUI:getChildByName(page, "TouchSize"), function()
                SL:ShowSystemTips("条件不满足!")
            end)
        end
        self._Pages[btnName] = page
    end
    self:PageTo(self._pageIDs[skipPage or 1])

    self:reqNoticeData()
    return true
end

function TradingBankFrameLayer:reqNoticeData()
    self.OtherTradingBankProxy:getNotice(self, {},function (code, data, msg)
        dump({code, data, msg},"联运交易行公告：")
        if code == 200 then 
            self._noticeData = data
            self:showNoticeLabel()
        else
            ShowSystemTips(msg or "")
        end
    end)
end

function TradingBankFrameLayer:showNoticeLabel()
    if not self._noticeData then 
        return 
    end 
    if self._noticeData.enable == 0 then 
        if self._noticePanel then
            self._noticePanel:removeFromParent() 
        end
        return 
    end
    local endShowTime = self._noticeData.endShowTime--"12:00"
    local startDate = self._noticeData.startDate--时间戳
    local endDate = self._noticeData.endDate--时间戳
    local curTime =  GetServerTime() or  os.time()

    local endShowTimeT = string.split(endShowTime,":")
    local endHour = endShowTimeT and tonumber(endShowTimeT[1]) or 0
    local endMin = endShowTimeT and tonumber(endShowTimeT[2]) or 0  
    local endSumMin = endHour * 60 + endMin
    dump(curTime,"curTime____")
    dump(endSumMin,"endSumMin___")
    dump(startDate,"startDate__")
    dump(endDate,"endDate___")

    if curTime < startDate or curTime > endDate then 
        -- dump("不在时间")
        if self._noticePanel then
            self._noticePanel:removeFromParent() 
        end
    else
        local curTimeT = os.date("*t",curTime)
        local startShowTime = self._noticeData.startShowTime--"09:00"
        local startShowTimeT = string.split(startShowTime,":")
        local startHour = startShowTimeT and tonumber(startShowTimeT[1]) or 0
        local startMin = startShowTimeT and tonumber(startShowTimeT[2]) or 0  
        local curSumMin = curTimeT.hour * 60 + curTimeT.min
        local startSumMin = startHour * 60 + startMin
        
        if ( curSumMin >= startSumMin and curSumMin <= endSumMin ) then 
            if not self._noticePanel then 
                local content = self._noticeData.content or ""
                local layout = ccui.Layout:create()
                self._noticePanel = layout
                layout:setBackGroundImage(global.MMO.PATH_RES_PRIVATE.."trading_bank_other/img_notice_bg.png")
                layout:setClippingEnabled(true)
                layout:setContentSize(440,30)
                layout:setAnchorPoint(cc.p(0, 0))
                layout:setPosition(cc.p(269, 485))
                self._ui.FrameBG:addChild(layout)
                local scrolllabel = ccui.Text:create()
                self._scrolllabel = scrolllabel
                layout:addChild(scrolllabel)
                scrolllabel:setPosition(cc.p(450, 5))
                scrolllabel:setAnchorPoint(cc.p(0, 0))
                scrolllabel:setFontSize(16)
                scrolllabel:setTextColor(cc.c3b(0, 0, 0))
                scrolllabel:setString(content)
            end 
            self._scrolllabel:setPositionX(450)
            local speed = 50
            local labelSize = self._scrolllabel:getContentSize()
            local w = labelSize.width + 450 
            local sequence = cc.Sequence:create(
                cc.MoveBy:create(w/speed, cc.p(-w, 0)),
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function ()
                    self:showNoticeLabel()
                end)
                
            )
            self._scrolllabel:runAction(sequence)
            -- dump("显示？")
        else
            -- dump("不在时间22")
            if self._noticePanel then
                self._noticePanel:removeFromParent() 
            end
        end
    end
    
end

function TradingBankFrameLayer:PageTo(index)
    if not index or self._index == index then
        return false
    end

    self:OnClose()

    self._index = index

    self:OnOpen()
    self:SetPageStatus()

    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBindIdentityLayer_Close_other)
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