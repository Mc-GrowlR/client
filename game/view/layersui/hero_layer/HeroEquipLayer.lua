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
    self._ui = ui_delegate(self)
    return true
end

function HeroEquipLayer:InitGUI(data)
    self.samePosDiff = {}
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_EQUIP)
    HeroEquip.main(data)

    self._root = self._ui.Panel_1

    self:InitEditMode()

    global.Facade:sendNotification(global.NoticeTable.Layer_Hero_Equip_Load_Success)
end

function HeroEquipLayer:InitEditMode()
    local items =     {
        "Image_20",
        "Text_guildinfo",
        "Image_box",
        "Best_ringBox",
        "Panel_pos4", --头盔
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

    for i = 2, 15 do
        local posPanel = self._ui["Panel_pos" .. i]
        if posPanel then
            local Image_bg = self._ui["Panel_pos" .. i]:getChildByName("Image_bg")
            Image_bg.editMode = 1
            local Image_icon = self._ui["Panel_pos" .. i]:getChildByName("Image_icon")
            Image_icon.editMode = 1

            local posNode = self._ui["Node_" .. i]
            if posNode then
                self._ui["Node_" .. i].editMode = 1
                self._ui["Panel_pos" .. i].editMode = 1
            end
        end
    end
end

function HeroEquipLayer:RefreshInitPos(...)
    if HeroEquip.InitHideNodePos then
        HeroEquip.InitHideNodePos()
    end

    if HeroEquip.InitSamePosDiff then
        HeroEquip.InitSamePosDiff(true)
    end
end

function HeroEquipLayer:OnClose()
    HeroEquip.CloseCallback()
end

return HeroEquipLayer