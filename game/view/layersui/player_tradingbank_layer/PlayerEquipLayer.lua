local BaseLayer = requireLayerUI("BaseLayer")
local PlayerEquipLayer = class("PlayerEquipLayer", BaseLayer)

function PlayerEquipLayer:ctor()
    PlayerEquipLayer.super.ctor(self)
end

function PlayerEquipLayer.create(...)
    local ui = PlayerEquipLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end

function PlayerEquipLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function PlayerEquipLayer:InitGUI(data)
    self.samePosDiff = {}
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_PLAYER_EQUIP)
    PlayerEquip_Look_TradingBank.main(data)

    self._root = PlayerEquip_Look_TradingBank._ui.Panel_1
end

function PlayerEquipLayer:OnClose()
    PlayerEquip_Look_TradingBank.CloseCallback()
end

return PlayerEquipLayer