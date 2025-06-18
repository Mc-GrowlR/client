local BaseLayer = requireLayerUI( "BaseLayer" )
local BeStrongUpLayer = class( "BeStrongUpLayer", BaseLayer )


function  BeStrongUpLayer:ctor()
    BeStrongUpLayer.super.ctor( self )
end

function BeStrongUpLayer.create()
    local layer = BeStrongUpLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function BeStrongUpLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function BeStrongUpLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_BESTRONG_UP)
    BeStrongUp.main()
    self:InitEditMode()
end

function BeStrongUpLayer:OnClose()
    if BeStrongUp and BeStrongUp.close then 
        BeStrongUp.close()
    end 
end

function BeStrongUpLayer:UpdateList()
    local showList = false
    if BeStrongUp and BeStrongUp._ui then
        showList = GUI:getVisible(BeStrongUp._ui["Panel_bg"])
        if showList and BeStrongUp.refreshBeStrongList then
            BeStrongUp.refreshBeStrongList()
        end
    end
end

function BeStrongUpLayer:InitEditMode()
    if self._ui.Button_up then
        self._ui.Button_up.editMode = 1
    end
    if self._ui.Panel_bg then
        self._ui.Panel_bg.editMode = 1
    end
end

return BeStrongUpLayer