local FuncDockProxy  = global.Facade:retrieveProxy( global.ProxyTable.FuncDockProxy )

local BaseLayer = requireLayerUI("BaseLayer")
local FuncDockLayer = class("FuncDockLayer", BaseLayer)

function FuncDockLayer:ctor()
    FuncDockLayer.super.ctor(self)
end

function FuncDockLayer.create(data)
    local layer = FuncDockLayer.new()
    if layer:Init(data) then
        return layer
    else
        return nil
    end
end

function FuncDockLayer:Init(data)
    self._ui = ui_delegate(self)

    return true
end

function FuncDockLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_FUNC_DOCK)
    FuncDock.main(data)

end

return FuncDockLayer