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
    return true
end

function PlayerEquipLayer:InitGUI(data)
    self.samePosDiff = {}
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_LOOK_EQUIP)
    PlayerEquip_Look.main(data)

    self._root = PlayerEquip_Look._ui.Panel_1

end

function PlayerEquipLayer:RefreshInitPos( ... )
    if PlayerEquip_Look.InitHideNodePos then
        PlayerEquip_Look.InitHideNodePos()
    end
    if PlayerEquip_Look.InitSamePosDiff then
        PlayerEquip_Look.InitSamePosDiff(true)
    end
end

function PlayerEquipLayer:OnClose()
    PlayerEquip_Look.CloseCallback()
end

return PlayerEquipLayer