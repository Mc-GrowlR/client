local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankDownGetEquipPanel = class("TradingBankDownGetEquipPanel", BaseLayer)
local cjson = require("cjson")
local QuickCell = requireUtil("QuickCell")
local RichTextHelp = require("util/RichTextHelp")

function TradingBankDownGetEquipPanel:ctor()
    TradingBankDownGetEquipPanel.super.ctor(self)
    self._tradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    self._equipOptState = self._tradingBankProxy:GetEquipOptState()
end

function TradingBankDownGetEquipPanel.create(...)
    local ui = TradingBankDownGetEquipPanel.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankDownGetEquipPanel:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_down_get_equip_panel")
    self._root = ui_delegate(self)

    self._data = data
    self:InitUI()
    
    return true
end

function TradingBankDownGetEquipPanel:InitUI() 
    self._root.Button_next:addClickEventListener(function ()
    end)
    self._root.Button_close:addClickEventListener(function ()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankDownGetEquipPanel_Close)
    end)
    
    local itemData = self._data.itemData
    local goodsItem = GoodsItem:create({index = itemData.Index, itemData = itemData, look = true})
    self._root.Image_equipBg:addChild(goodsItem)
    local size = self._root.Image_equipBg:getContentSize()
    goodsItem:setPosition(size.width/2, size.height/2)

    local color = (itemData.Color and itemData.Color > 0) and itemData.Color or 255
    local name = itemData.Name or ""
    -- 道具名字
    self._root.Text_equip_name:setString(name)
    self._root.Text_equip_name:setTextColor(SL:GetColorByStyleId(color))

    self._root.Text_price:setString(self._data.price or 0)
    local resPath = global.MMO.PATH_RES_PRIVATE.."trading_bank/img_title_down.png"
    self._root.Button_next:setTitleText(GET_STRING(600000618))
    if self._equipOptState.Get == self._data.opt then 
        resPath = global.MMO.PATH_RES_PRIVATE.."trading_bank/img_title_get.png"
        self._root.Button_next:setTitleText(GET_STRING(600000619))
    end
    self._root.Image_title:loadTexture(resPath)
end

function TradingBankDownGetEquipPanel:ExitLayer()
    self._tradingBankProxy:removeLayer(self)
end

return TradingBankDownGetEquipPanel