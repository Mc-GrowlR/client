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
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_EQUIP_WIN32)
    PlayerEquip.main(data)

    self._root = self._ui.Panel_1
    refPositionByParent(self)

    self:InitEditMode()
    global.Facade:sendNotification(global.NoticeTable.Layer_Player_Equip_Load_Success)
end

function PlayerEquipLayer:InitEditMode()
    local items = 
    {
        "Image_equippanel",
        "Text_guildinfo",
        "Image_box",
        "Best_ringBox",
        "Panel_pos4",   --头盔
        "Panel_pos16",
        "Panel_pos1",
        "Panel_pos0",
        "Node_playerModel",
        "Node_55",
        "Panel_pos55",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end

    for i= 2, 15 do
        local posPanel = self._ui["Panel_pos"..i] 
        if posPanel then
            local Image_bg = self._ui["Panel_pos"..i]:getChildByName("Image_bg")
            Image_bg.editMode = 1
            local Image_icon = self._ui["Panel_pos"..i]:getChildByName("Image_icon")
            Image_icon.editMode = 1

            local posNode = self._ui["Node_"..i]
            if posNode then
                self._ui["Node_"..i].editMode = 1
                self._ui["Panel_pos"..i].editMode = 1
            end
        end 
    end
end

function PlayerEquipLayer:RefreshInitPos( ... )
    if PlayerEquip.InitHideNodePos then
        PlayerEquip.InitHideNodePos()
    end
    if PlayerEquip.InitSamePosDiff then
        PlayerEquip.InitSamePosDiff(true)
    end
end

function PlayerEquipLayer:OnClose()
    PlayerEquip.CloseCallback()
end

return PlayerEquipLayer