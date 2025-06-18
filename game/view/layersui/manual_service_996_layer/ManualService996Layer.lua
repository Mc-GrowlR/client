local BaseLayer = requireLayerUI( "BaseLayer" )
local ManualService996Layer = class( "ManualService996Layer", BaseLayer )

function ManualService996Layer:ctor()
    ManualService996Layer.super.ctor(self)

    self._show_state = false

    self._move_action_time = 0.5
    self._web_view_width = SL:GetMetaValue("SCREEN_WIDTH") * 0.5
    self._close_button_width = 0
end

function ManualService996Layer.create(data)
    local layer = ManualService996Layer.new()
    if layer and layer:Init(data) then
        return layer
    end
    return nil
end

function ManualService996Layer:Init(data)
    local url = data and data.url
    if not url then
        return false
    end

    local view = ccexp.CustomView or ccexp.WebView
    if not view then
        ShowSystemTips(GET_STRING(600000900))
        return false
    end

    local panel1 = GUI:Layout_Create(self, "panel_1", 0, 0, SL:GetMetaValue("SCREEN_WIDTH"), SL:GetMetaValue("SCREEN_HEIGHT"), true)
    GUI:setTouchEnabled(panel1, true)
    GUI:addOnClickEvent(panel1, function()
        GUI:setTouchEnabled(panel1, false)
        self:ShowHideUI(false)
    end)

    local widget  = view:create()
    GUI:addRef(widget)
    GUI:setName(widget, "WEB_VIEW")
    GUI:setPositionX(widget, -1 * self._web_view_width)
    GUI:setAnchorPoint(widget, 0, 0)
    GUI:setContentSize(widget, cc.size(self._web_view_width, SL:GetMetaValue("SCREEN_HEIGHT")))
    GUI:addChild(panel1, widget)

    widget:loadURL(url)

    local widgetSize = GUI:getContentSize(widget)
    -- 关闭按钮
    local closeButton = GUI:Button_Create(widget, "close_button", widgetSize.width , widgetSize.height)
    GUI:Button_loadTextureNormal(closeButton, global.MMO.PATH_RES_PUBLIC .. "1900000510.png")
    GUI:Button_loadTexturePressed(closeButton, global.MMO.PATH_RES_PUBLIC .. "1900000511.png")

    local buttonSize = GUI:getContentSize(closeButton)
    GUI:setPositionY(closeButton, widgetSize.height-buttonSize.height)
    self._close_button_width = buttonSize.width

    GUI:addOnClickEvent(closeButton, function()
        local ManualService996Proxy = global.Facade:retrieveProxy(global.ProxyTable.ManualService996Proxy)
        ManualService996Proxy:SetShowMaulServiceState(false)
        global.Facade:sendNotification(global.NoticeTable.Layer_Manual_Service_996_Close)
    end)

    self:ShowHideUI(true)

    local ManualService996Proxy = global.Facade:retrieveProxy(global.ProxyTable.ManualService996Proxy)
    ManualService996Proxy:SetWebOpenState(true)

    return true
end

function ManualService996Layer:ShowHideUI( isShow, url )
    if self._show_state == isShow then
        return false
    end
    self._show_state = isShow

    local ManualService996Proxy = global.Facade:retrieveProxy(global.ProxyTable.ManualService996Proxy)
    ManualService996Proxy:SetShowMaulServiceState(isShow)

    local panel1 = GUI:getChildByName(self, "panel_1")
    if not panel1 then
        return false
    end
    GUI:setTouchEnabled(panel1, isShow==true)

    local widget = GUI:getChildByName(panel1, "WEB_VIEW")
    if not widget then
        return false
    end

    local movePos = isShow and cc.p(0, 0) or cc.p(-1 * (self._web_view_width + self._close_button_width), 0)
    local move = GUI:ActionMoveTo(self._move_action_time, movePos.x, movePos.y)
    local callback = GUI:CallFunc(function()
        if url then
            widget:loadURL(url, true)
        end 
    end)
    GUI:runAction(widget, GUI:ActionSequence(move, callback))

    if isShow then
        ManualService996Proxy:RemoveCheck(true)
        widget:evaluateJS("getModelVisible(true)")
    else
        local glview = global.Director:getOpenGLView()
        if glview then
            glview:setIMEKeyboardState(false)
        end
        ManualService996Proxy:OnCheckRedPoint()
        widget:evaluateJS("getModelVisible(false)")
    end

    return true
end

function ManualService996Layer:OnClose()

    local panel1 = GUI:getChildByName(self, "panel_1")
    if panel1 then
        local widget = GUI:getChildByName(panel1, "WEB_VIEW")
        if widget then
            widget:evaluateJS("getModelVisible(false)")
            GUI:decRef(widget)
        end
    end

    local glview = global.Director:getOpenGLView()
    if glview then
        glview:setIMEKeyboardState(false)
    end

    local ManualService996Proxy = global.Facade:retrieveProxy(global.ProxyTable.ManualService996Proxy)
    ManualService996Proxy:SetWebOpenState(false)
    ManualService996Proxy:RemoveCheck()
end

return ManualService996Layer