
local BaseLayer = requireLayerUI( "BaseLayer" )
local Box996MainLayer = class( "Box996MainLayer", BaseLayer )

function Box996MainLayer:ctor()
    Box996MainLayer.super.ctor( self )

    self._proxy = global.Facade:retrieveProxy( global.ProxyTable.Box996Proxy )

    self._jump_notice = {
        [1] = { onOpen=global.NoticeTable.Layer_Box996Title_Attach, onClose=global.NoticeTable.Layer_Box996Title_UnAttach },
        [2] = { onOpen=global.NoticeTable.Layer_Box996EveryDay_Attach, onClose=global.NoticeTable.Layer_Box996EveryDay_UnAttach },
        [3] = { onOpen=global.NoticeTable.Layer_Box996Super_Attach, onClose=global.NoticeTable.Layer_Box996Super_UnAttach },
        [4] = { onOpen=global.NoticeTable.Layer_Box996VIP_Attach, onClose=global.NoticeTable.Layer_Box996VIP_UnAttach },
        [5] = { onOpen=global.NoticeTable.Layer_Box996SVIP_Attach, onClose=global.NoticeTable.Layer_Box996SVIP_UnAttach },
        [6] = { onOpen=global.NoticeTable.Layer_Box996CloudPhone_Attach, onClose=global.NoticeTable.Layer_Box996CloudPhone_UnAttach },
    }

    self._hideButton = {
        [self._proxy.BOX_TYPE.TYPE_VIP] = true,
        [self._proxy.BOX_TYPE.TYPE_SVIP] = true,
    }
end

function Box996MainLayer.create( data )
    local layer = Box996MainLayer.new()

    if layer and layer:Init( data ) then
        return layer
    end

    return nil
end

function Box996MainLayer:Init( data )
    self._root = CreateExport( "box996_ui/box996_main_layer.lua" )
    if not self._root then
        return false
    end
    data = data or {}

    self:addChild( self._root )

    self._ui = ui_delegate( self._root )

    local dataIndex = tonumber(data.index) or 0
    local openIndex = dataIndex > 0 and dataIndex or self._proxy.BOX_TYPE.TYPE_TITLE
    
    self._ui.Button_close:addClickEventListener( function()
        self:onRemoveAllAttach()
        global.Facade:sendNotification( global.NoticeTable.Layer_Box996Main_Close )
    end)

    local isShowSVIP = self._proxy:IsShowSVIP()
    self._hideButton[self._proxy.BOX_TYPE.TYPE_SVIP] = not isShowSVIP

    local isShowCloudPhone = self._proxy:getCloudPhoneShow()
    self._hideButton[self._proxy.BOX_TYPE.TYPE_CLOUD_PHONE] = not isShowCloudPhone

    -- 上报埋点
    if isShowCloudPhone then
        self._proxy:requestLogUp(self._proxy.BOX_UP_YUN_PHONE[1])
    end

    --vip切页先隐藏
    if not openIndex or self._hideButton[openIndex] then
        openIndex = self._proxy.BOX_TYPE.TYPE_TITLE
    end

    for _btn_idx,v in pairs(self._hideButton) do
        local item = self._ui.ListView_box_btn:getChildByTag( 100 + _btn_idx )
        if item and v then
            item:setVisible(false)
        end
        if item and v and _btn_idx == self._proxy.BOX_TYPE.TYPE_SVIP and isShowSVIP ~= nil then
            self._ui.ListView_box_btn:removeChild(item, true)
            item = nil
        elseif item and v and _btn_idx == self._proxy.BOX_TYPE.TYPE_CLOUD_PHONE and isShowCloudPhone ~= nil then
            self._ui.ListView_box_btn:removeChild(item, true)
            item = nil
        end
    end

    self.openinitIndex = openIndex
    self:changeListButtonState( openIndex, true )

    self._proxy:openUIRequest()
    return true
end

--listview按钮的状态
function Box996MainLayer:changeListButtonState( index,isinit )
    local list = self._ui.ListView_box_btn
    local items = list:getItems()

    local tagid = 100+index
    for k,v in ipairs(items) do
        local boxtype = v:getTag() % 100
        if v:getTag() == tagid then
            v:setBright(false)

            if self._jump_notice[boxtype] then
                global.Facade:sendNotification(self._jump_notice[boxtype].onOpen,{parent=self._ui.Node_child,isinit=isinit})
            end
        else
            v:setBright(true)
            if self._jump_notice[boxtype] then
                global.Facade:sendNotification(self._jump_notice[boxtype].onClose)
            end
        end

        if isinit then
           self:onButtonEvent( v )
        end
    end
end

function Box996MainLayer:onButtonEvent( btn )
    btn:addClickEventListener(function( sender )
        local boxtype = sender:getTag() % 100
        self:changeListButtonState( boxtype )

        local upid = self._proxy.BOX_UP_DATA[boxtype]
        self._proxy:requestLogUp(self._proxy.BOX_UP_BTN[upid])
    end)
end

function Box996MainLayer:onRemoveAllAttach()
    for i,v in pairs(self._jump_notice or {}) do
        if v and v.onClose then
            global.Facade:sendNotification(v.onClose)
        end
    end
end

-- 刷新
function Box996MainLayer:OnRefresh( data )

    if data and data.list_view_show_state then
        self._ui.ListView_box_btn:setVisible(data.list_view_show_state==1)
        return
    end
    
    if data and data.isSvipBtn then
        local item = self._ui.ListView_box_btn:getChildByTag( 100 + self._proxy.BOX_TYPE.TYPE_SVIP )
        if item then
            item:setVisible(data.value == true)
        end

        if not data.value and item then
            self._ui.ListView_box_btn:removeChild(item, true)
            item = nil
        end
        return
    end

    if data and data.isCloudPhoneBtn then
        local item = self._ui.ListView_box_btn:getChildByTag( 100 + self._proxy.BOX_TYPE.TYPE_CLOUD_PHONE )
        if item then
            item:setVisible(data.value == true)
        end

        if not data.value and item then
            self._ui.ListView_box_btn:removeChild(item, true)
            item = nil
        end

        -- 上报埋点
        if data.value == true then
            self._proxy:requestLogUp(self._proxy.BOX_UP_YUN_PHONE[1])
        end

        return
    end

    local vipBoxGift = self._proxy:getBoxGiftData( self._proxy.BOX_TYPE.TYPE_VIP )
    if vipBoxGift and next(vipBoxGift) then
        local item = self._ui.ListView_box_btn:getChildByTag( 100 + self._proxy.BOX_TYPE.TYPE_VIP )
        if item then
            item:setVisible(true)
        end
    end

    if self.openinitIndex then
        local boxData = self._proxy:getBoxData()
        local titleid = boxData and boxData.BoxTitleID or 0
        local isShowTitle = titleid > 0
        local item = self._ui.ListView_box_btn:getChildByTag( 100 + self._proxy.BOX_TYPE.TYPE_TITLE )
        if item then
            item:setVisible(isShowTitle)
        end

        if not isShowTitle and item then
            item:removeFromParent()
            item = nil

            if self.openinitIndex == self._proxy.BOX_TYPE.TYPE_TITLE then
                self:changeListButtonState( self._proxy.BOX_TYPE.TYPE_EVERY_DAY )
            end
        end
        self.openinitIndex = nil
    end
end

function Box996MainLayer:OnClose()
    for i,v in pairs(self._jump_notice or {}) do
        if v.onClose then
            global.Facade:sendNotification(v.onClose)
        end
    end
end

return Box996MainLayer