local BaseLayer = requireLayerUI("BaseLayer")
local BossTipsLayer = class("BossTipsLayer", BaseLayer)

local RichTextHelp = requireUtil("RichTextHelp")

function BossTipsLayer:ctor()
    BossTipsLayer.super.ctor(self)
end

function BossTipsLayer.create(...)
    local layer = BossTipsLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function BossTipsLayer:init(data)
    self:InitGUI(self,data)
    return true
end

function BossTipsLayer:InitGUI(parent,data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_BOSSTIPS)
    SettingBossTips.main(parent,data)
    self._quickUI =  ui_delegate(parent)
end

function BossTipsLayer:OnClose()
    SettingBossTips.CloseCallback()
end

return BossTipsLayer
