local BaseLayer = requireLayerUI("BaseLayer")
local ChatExtendLayer = class("ChatExtendLayer", BaseLayer)

function ChatExtendLayer:ctor()
    ChatExtendLayer.super.ctor(self)
end

function ChatExtendLayer.create()
    local layer = ChatExtendLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function ChatExtendLayer:Init()
    self._ui = ui_delegate(self)

    return true
end

function ChatExtendLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_CAHTEXTEND)
    ChatExtend.main()
end

function ChatExtendLayer:OnSelectGroup(data)
    if ChatExtend.SelectGroup then
        ChatExtend.SelectGroup(data.group or 1)
    end
end

return ChatExtendLayer
