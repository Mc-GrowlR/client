local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBindIdentityLayer = class("TradingBankBindIdentityLayer", BaseLayer)

local cjson = require("cjson")
local utf8 = require("util/utf8")
function TradingBankBindIdentityLayer:ctor()
    TradingBankBindIdentityLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankBindIdentityLayer.create(...)
    local ui = TradingBankBindIdentityLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankBindIdentityLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/bindIdentity/trading_bank_bindIdentity")
    self._root = ui_delegate(self)
    self:InitAdapt()
    self.m_callback = data and data.callback
    self:InitUI()
    return true
end

function TradingBankBindIdentityLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPosition(self._root.PMainUI, winSizeW / 2, winSizeH / 2)
end

function TradingBankBindIdentityLayer:InitUI()
    -- GUI:setVisible(self._root.Panel_BindIdentity, false)
    GUI:setVisible(self._root.Panel_ok, false)
    -------------绑定手机---------------
    --输入框
    self.OtherTradingBankProxy:cancelEmpty(self._root.TextField_name)
    self.OtherTradingBankProxy:cancelEmpty(self._root.TextField_code)
    ------------------------------------------
    --关闭
    self._root.CloseButton:addClickEventListener(function()
        if self.m_callback then
            self.m_callback(0)
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBindIdentityLayer_Close_other)
    end)
    ----------------实名认证 ------------------
    ----实名认证下一步
    self._root.Button_next:addClickEventListener(function()
        local name = self._root.TextField_name:getString()
        if string.len(name) == 0 then 
            ShowSystemTips(GET_STRING(600000650))
            return 
        end
        local idcard = self._root.TextField_code:getString()
        if string.len(idcard) ~= 18 then 
            ShowSystemTips(GET_STRING(600000651))
            return 
        end
        self.OtherTradingBankProxy:identification(self, {name = name, idCard = idcard}, function (code,data,msg)
            dump({code,data,msg},"identification___")
            if code == 200  then 
                GUI:Text_setString(self._root.Text_name, utf8:sub(name,1,1).."**")
                
                local bstr = string.sub(idcard,1,3)
                local estr = string.sub(idcard,-4,-1)

                GUI:Text_setString(self._root.Text_identity,bstr.."******"..estr)
                GUI:setVisible(self._root.Panel_BindIdentity, false)
                GUI:setVisible(self._root.Panel_ok, true)
            else
                local params = {}
                params.type = 1
                params.btntext = GET_STRING(600000139)
                params.text = GET_STRING(600000657) 
                params.titleImg = global.MMO.PATH_RES_PRIVATE .. "trading_bank_other/img_tips.png"
                params.callback = function(res)
                    
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
            end
        end)
    end)
    -----进入交易行
    self._root.Button_next3:addClickEventListener(function()
        if self.m_callback then
            self.m_callback(1)
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBindIdentityLayer_Close_other)
    end)
end

function TradingBankBindIdentityLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end
-------------------------------------
return TradingBankBindIdentityLayer