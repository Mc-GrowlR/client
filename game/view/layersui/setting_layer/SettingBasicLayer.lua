local BaseLayer = requireLayerUI("BaseLayer")
local SettingBasicLayer = class("SettingBasicLayer", BaseLayer)

function SettingBasicLayer:ctor()
    SettingBasicLayer.super.ctor(self)
end

function SettingBasicLayer.create(...)
    local layer = SettingBasicLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function SettingBasicLayer:init(data)
    self._ui = ui_delegate(self)
    return true
end

function SettingBasicLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_BASIC)
    SettingBasic.main()

    self:AddShow()
end

function SettingBasicLayer:AddShow()
    -- 版本号
    local counting = 0
    local viewSize = cc.size(732, 445)
    local layout = ccui.Layout:create()
    self:addChild(layout)
    layout:setTouchEnabled(true)
    layout:setContentSize(50, 50)
    layout:setAnchorPoint(cc.p(0, 0))
    layout:addClickEventListener(
        function()
            counting = counting + 1
            if counting == 4 then
                counting = 0

                local LoginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
                local service       = LoginProxy:GetServiceVer()
                ShowSystemTips(service or "ERROR VERSION")
            end
        end
    )
end

function SettingBasicLayer:GetSUIParent()
    return self._ui.Panel_1
end

function SettingBasicLayer:CloseLayer()
    if SettingBasic.CloseLayer then 
        SettingBasic.CloseLayer()
    end
end
return SettingBasicLayer
