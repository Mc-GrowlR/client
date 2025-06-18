local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankSuggestPanel = class("TradingBankSuggestPanel", BaseLayer)

function TradingBankSuggestPanel:ctor()
    TradingBankSuggestPanel.super.ctor(self)
    self._otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankSuggestPanel.create(...)
    local layer = TradingBankSuggestPanel.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function TradingBankSuggestPanel:Init(data)
    GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_suggest_panel")
    self._root = ui_delegate(self)
    self._selectItems = {}
    self._selectData = {}
    self:GetSuggestType()
    self:InitAdapt()
    self:InitUI()
    return true
end

function TradingBankSuggestPanel:GetSuggestType()
    if #self._selectItems > 0 then
        return
    end
    self._reqState = true
    self._otherTradingBankProxy:userFeedBackTypeList(self, {}, function(code, data, msg)
        self._reqState = false
        if code == 200 then
            for i, v in ipairs(data) do
                table.insert(self._selectItems, v.typeName or "")
            end
            self._selectData = data
        else
            ShowSystemTips(msg or "")        
        end
    end)
end

function TradingBankSuggestPanel:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")

    GUI:setPosition(self._root.Panel_2, winSizeW / 2, winSizeH / 2)
end


function TradingBankSuggestPanel:InitUI()
    local selectfunc = function(res)
        if res ~= 0 then --0关闭  非0 选中的编号
            GUI:Text_setMaxLineWidth(self._root.Text_select, 215)
            self._root.Text_select:setString(self._selectItems[res])
            local labelSize = self._root.Text_select:getContentSize()
            self._root.ScrollView:setInnerContainerSize(labelSize)
            self._root.Text_select:setPositionY(labelSize.height)
            self._root.Text_select._selectType = self._selectData[res].id
        end
    end
    local showList = function()
        if #self._selectItems == 0 then
            if self._reqState then
                ShowSystemTips(GET_STRING(600000472))
            else
                ShowSystemTips(GET_STRING(600000473))
            end
        else
            local worldPos = self._root.Image_selectBg:getWorldPosition()
            local size = self._root.Image_selectBg:getContentSize()
            SL:OpenSelectListUI(self._selectItems, worldPos, size.width, size.heigth, selectfunc, {autoNext = true})--打开选则列表
        end
    end
    self._root.ScrollView:addClickEventListener(function()--选择类型
        showList()
    end)
    self._root.Image_selectBg:addClickEventListener(function()--选择类型
        showList()
    end)

    self._root.Button_submit:addClickEventListener(function()--提交
        if not self._root.Text_select._selectType then
            ShowSystemTips(GET_STRING(600000474))
            return 
        end

        local content = self._root.Input_desc:getString()
        if string.len(content) <= 0 then
            ShowSystemTips(GET_STRING(600000471))
            return
        end
        local params = {
            id = self._root.Text_select._selectType,
            content = content
        }
        self._otherTradingBankProxy:userFeedBack(self, params, function(code, data, msg)
            ShowSystemTips(msg or "")
            if code == 200 then 
                local data = {}
                data.type = 1
                data.btntext = GET_STRING(600000476)
                data.text = GET_STRING(600000475)
                data.titleImg = global.MMO.PATH_RES_PRIVATE.."trading_bank_other/img_suggest_title.png"
                data.callback = function(res)
                    if res == 1 then
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                    end
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, data)
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankSuggestPanelLayer_Close_other)
            end
        end)
    end)
    self._root.Button_close:addClickEventListener(function()--关闭
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankSuggestPanelLayer_Close_other)
    end)


end

function TradingBankSuggestPanel:ResCancelorder(code, data, msg)
    dump({ code, data, msg }, "resCancelorder___")
    ShowSystemTips(msg)
    if code == 200 then
        if self._callback then
            self._callback()
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankWaitPayPanelLayer_Close_other)
    end
end

function TradingBankSuggestPanel:ExitLayer()
    self._otherTradingBankProxy:removeLayer(self)
end

return TradingBankSuggestPanel