local BaseUIMediator = requireMediator( "BaseUIMediator" )
local ItemTipsMediator = class("ItemTipsMediator", BaseUIMediator)
ItemTipsMediator.NAME = "ItemTipsMediator"

function ItemTipsMediator:ctor()
    ItemTipsMediator.super.ctor( self )
end

function ItemTipsMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_ItemTips_Open,
        noticeTable.Layer_ItemTips_Close,
        noticeTable.Layer_Close_Current,
        noticeTable.Layer_Bag_Close,
        noticeTable.Layer_Player_Close,
        noticeTable.Layer_ItemTips_Mouse_Scroll,
        noticeTable.UserInputEventNotice,
    }
end

function ItemTipsMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_ItemTips_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_ItemTips_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.Layer_Close_Current == noticeName or noticeTable.Layer_Bag_Close == noticeName or noticeTable.Layer_Player_Close == noticeName then
        global.Facade:sendNotification( global.NoticeTable.Layer_ItemTips_Close )
    elseif noticeTable.Layer_ItemTips_Mouse_Scroll == noticeName then
        self:OnMouseScroll( noticeData )
    elseif noticeTable.UserInputEventNotice == noticeName then
        self:OnUserInputEventNotice()
    end
end

function ItemTipsMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local Layer = requireLayerUI("item_tips_layer/ItemTipsLayer")
        local layer = Layer.create(noticeData)
        self._layer         = layer
        self._type          = global.UIZ.UI_MOUSE
        self._GUI_ID        = SLDefine.LAYERID.ItemTipsGUI
        GUI.ATTACH_PARENT   = self._layer
        ssr.GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)
        ItemTipsMediator.super.OpenLayer( self )
    else
        if self._layer then
            self:CloseLayer()
        end
    end
end

function ItemTipsMediator:OnMouseScroll( data )
    if self._layer then
        ssr.ssrBridge:OnItemTipsMouseScroll(data)
        SLBridge:onLUAEvent(LUA_EVENT_ITEMTIPS_MOUSE_SCROLL, data)
    end
end

function ItemTipsMediator:CloseLayer()
    if self._layer then
        if ItemTips and ItemTips.OnClose then
            ItemTips.OnClose()
        end
    end
    ItemTipsMediator.super.CloseLayer(self)
end

function ItemTipsMediator:OnUserInputEventNotice()
    if self._layer then
        self:CloseLayer()
    end
end

function ItemTipsMediator:OnReleaseMemory( )
    local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
    if ItemTipsProxy then
        ItemTipsProxy:Cleanup()
    end  
end

return ItemTipsMediator