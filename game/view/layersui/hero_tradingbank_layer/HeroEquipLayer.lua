local BaseLayer = requireLayerUI("BaseLayer")
local HeroEquipLayer = class("HeroEquipLayer", BaseLayer)

function HeroEquipLayer:ctor()
    HeroEquipLayer.super.ctor(self)
end

function HeroEquipLayer.create(...)
    local ui = HeroEquipLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end

function HeroEquipLayer:Init(data)
    return true
end

function HeroEquipLayer:InitGUI(data)
    self.samePosDiff = {}
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_HERO_EQUIP)
    HeroEquip_Look_TradingBank.main(data)
    self._root = HeroEquip_Look_TradingBank._ui.Panel_1

end

function HeroEquipLayer:OnClose()
    HeroEquip_Look_TradingBank.CloseCallback()
end

return HeroEquipLayer