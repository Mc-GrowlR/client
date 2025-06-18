local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankLookTextureLayer = class("TradingBankLookTextureLayer", BaseLayer)
local cjson = require("cjson")

function TradingBankLookTextureLayer:ctor()
    TradingBankLookTextureLayer.super.ctor(self)
end

function TradingBankLookTextureLayer.create(...)
    local ui = TradingBankLookTextureLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankLookTextureLayer:Init(data)
    GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_look_texture")
    self._root = ui_delegate(self)
    self:InitAdapt()
    local root = self._root.Scene
    local IMG = nil
    if data.path then
        self._root.Image_1:loadTexture(data.path)
        IMG = self._root.Image_1
    else
        local img = data:cloneEx()
        self._root.Image_1:setVisible(false)
        img:addTo(root)
        img:setPosition(self._root.Image_1:getPosition())
        IMG = img
    end
    local jt = IMG:getChildByName("Image_jt")
    if jt then
        jt:setVisible(false)
    end
    IMG:ignoreContentAdaptWithSize(true)
    local size = IMG:getContentSize()
    if size.width > 1000 then
        IMG:ignoreContentAdaptWithSize(false)
        IMG:setContentSize(714, 450)
    end
    IMG:setTouchEnabled(false)
    self._root.Panel_1:addTouchEventListener(handler(self, self.onButtonClick))

    return true
end

function TradingBankLookTextureLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_1, winSizeW, winSizeH)
    GUI:setPosition(self._root.Image_1, winSizeW / 2, winSizeH / 2)
end

function TradingBankLookTextureLayer:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "Panel_1" then -- 取消
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankLookTexture_Close_other)
    end

end

return TradingBankLookTextureLayer