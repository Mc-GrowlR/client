local BaseLayer = requireLayerUI("BaseLayer")
local AddMonsterNameLayer = class("AddMonsterNameLayer", BaseLayer)
function AddMonsterNameLayer:ctor()
    AddMonsterNameLayer.super.ctor(self)
end

function AddMonsterNameLayer.create(...)
    local layer = AddMonsterNameLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function AddMonsterNameLayer:init(data)
    self:InitGUI(self,data)
    return true
end

function AddMonsterNameLayer:InitGUI(parent,data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_ADDMONSTERNAME)
    SettingAddMonsterName.main(parent,data)
    self._quickUI =  ui_delegate(parent)
end

return AddMonsterNameLayer
