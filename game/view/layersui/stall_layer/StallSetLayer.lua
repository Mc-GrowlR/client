local BaseLayer = requireLayerUI("BaseLayer")
local StallSetLayer = class("StallSetLayer", BaseLayer)

function StallSetLayer:ctor()
    StallSetLayer.super.ctor(self)
    self.goldType = 0
    self.sellPrice = 0
end

function StallSetLayer.create()
    local layer = StallSetLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function StallSetLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function StallSetLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_STALL_SET)
    StallSet.main()
    self:InitTips()
end

function StallSetLayer:InitTips()
    local btnOk = UIGetChildByName(self._ui.PMainUI, "Button_ok")
    local btnClose = UIGetChildByName(self._ui.PMainUI, "Button_close")
 
    local showStallName = CHECK_SERVER_OPTION(global.MMO.SERVER_SHOW_STALL_NAME)
    local placeHolder = showStallName == 0 and SL:GetMetaValue("GAME_DATA","StallName") or nil
    if placeHolder then
        local PlayerPropertyProxy = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
        placeHolder = string.gsub(placeHolder, "<$USERNAME>",PlayerPropertyProxy:GetName())
        self._ui.Text_name:setString(placeHolder)
    end

    self._ui.TextField_name:setMaxLength(50)

    local function CancelCallBack()
        global.Facade:sendNotification(global.NoticeTable.Layer_Stall_Set_Close)
    end
    btnClose:addClickEventListener(CancelCallBack)

    local function SellCallBack()
        local name = self._ui.TextField_name:getString()
        if name ~= "" and string.len(name) > 0 then
        else
            name = placeHolder or ""
        end

        if placeHolder and name == placeHolder then
            -- 默认的不检测敏感字
            local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
            StallProxy:RequestAutoStall( name )
            CancelCallBack()
            return
        end

        -- 敏感字
        local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
        local function handle_Func(state)
            if not state then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1006))
                return
            end

            local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
            StallProxy:RequestAutoStall( name )
            CancelCallBack()
        end
        SensitiveWordProxy:IsHaveSensitiveAddFilter(name, handle_Func)
    end
    btnOk:addClickEventListener(SellCallBack)

    --输入框事件
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "began" then
            self._ui.Text_name:setVisible(false)
        elseif strEventName == "ended" or strEventName == "return" then                                 --键盘消失
            if IsForbidName(true) then
                pSender:setString("")
            end
            local str = pSender:getString()
            self._ui.Text_name:setVisible(string.len(str) <= 0)
        end
    end
    self._ui.TextField_name:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

return StallSetLayer