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
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_LOOK_EQUIP_WIN32)
    HeroEquip_Look.main(data)
    
    self._root = HeroEquip_Look._ui.Panel_1

    refPositionByParent(self)
end

function HeroEquipLayer:RefreshInitPos( ... )
    if HeroEquip_Look.InitHideNodePos then
        HeroEquip_Look.InitHideNodePos()
    end
    if HeroEquip_Look.InitSamePosDiff then
        HeroEquip_Look.InitSamePosDiff(true)
    end
end

function HeroEquipLayer:OnClose()
    HeroEquip_Look.CloseCallback()
end

return HeroEquipLayer