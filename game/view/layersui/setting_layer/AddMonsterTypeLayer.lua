local BaseLayer = requireLayerUI("BaseLayer")
local AddMonsterTypeLayer = class("AddMonsterTypeLayer", BaseLayer)

function AddMonsterTypeLayer:ctor()
    AddMonsterTypeLayer.super.ctor(self)
    
end

function AddMonsterTypeLayer.create(...)
    local layer = AddMonsterTypeLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function AddMonsterTypeLayer:init(data)
    self:InitGUI(self,data)
    return true
end

function AddMonsterTypeLayer:InitGUI(parent,data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_ADDMONSTERTYPE)
    SettingAddMonsterType.main(parent,data)
    self._quickUI =  ui_delegate(parent)
end



return AddMonsterTypeLayer
