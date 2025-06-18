local BaseLayer = requireLayerUI( "BaseLayer" )
local CommonSelectListPanel = class( "common_select_list", BaseLayer )

local RichTextHelp = require( "util/RichTextHelp" )

function  CommonSelectListPanel:ctor()
    CommonSelectListPanel.super.ctor( self )
end

function CommonSelectListPanel.create(noticeData)
    local layer = CommonSelectListPanel.new()
    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function CommonSelectListPanel:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function CommonSelectListPanel:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_COMMON_SELECT_LIST)
    CommonSelectList.main(data)
end

return CommonSelectListPanel