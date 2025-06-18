
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerExtraAttLayer = class("PlayerExtraAttLayer", BaseLayer)

function PlayerExtraAttLayer:ctor()
    PlayerExtraAttLayer.super.ctor(self)
end


function PlayerExtraAttLayer.create(...)
    local ui = PlayerExtraAttLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end

function PlayerExtraAttLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function PlayerExtraAttLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_EXTRA_ATT_WIN32)
    PlayerExtraAtt.main(data)
    self._root = PlayerExtraAtt._ui.Panel_1
    refPositionByParent(self)

    self:InitEditMode()
end

function PlayerExtraAttLayer:InitEditMode()
    local items = {
        "Image_1",
        "ListView_extraAtt"
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

--刷新 属性
function PlayerExtraAttLayer:OnRefreshAttri()
    PlayerExtraAtt.UpdateBaseAttri()
end
-- 刷新HP MP属性
function PlayerExtraAttLayer:OnRefreshHPMP()
    PlayerExtraAtt.OnRefreshHPMP()
end
-- 刷新HP MP属性
function PlayerExtraAttLayer:OnClose()
    PlayerExtraAtt.CloseCallback()
end
return PlayerExtraAttLayer