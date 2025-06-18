local BaseUIMediator = requireMediator( "BaseUIMediator" )
local BeStrongUpMediator = class("BeStrongUpMediator", BaseUIMediator)
BeStrongUpMediator.NAME = "BeStrongUpMediator"

function BeStrongUpMediator:ctor()
    BeStrongUpMediator.super.ctor( self )
end

function BeStrongUpMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
            noticeTable.Layer_BeStrong_refButton,
            noticeTable.SummonsAliveStatusChange,
    }
end

function BeStrongUpMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()

    if noticeTable.Layer_BeStrong_refButton == noticeName then
        self:RefreshLayer()
    elseif noticeTable.SummonsAliveStatusChange == noticeName then
        self:RefreshPos()
    end
end

function BeStrongUpMediator:RefreshLayer()
    local RemindUpgradeProxy = global.Facade:retrieveProxy( global.ProxyTable.RemindUpgradeProxy )
    local btnData = RemindUpgradeProxy:getButtonData()
    local nums = table.nums(btnData)
    if nums > 0 and not self._layer then
        self._layer = requireLayerUI("be_strong_layer/BeStrongUpLayer").create()
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_RB
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        LoadLayerCUIConfig(global.CUIKeyTable.BESTRONG, self._layer)
    end

    if nums == 0 then
        self:CloseNode()
    else
        self._layer:UpdateList()
    end
end

function BeStrongUpMediator:RefreshPos( )
    if self._layer then 
        SL:onLUAEvent(LUA_EVENT_BESTRONG_POS_REFRESH)
    end 
end

function BeStrongUpMediator:CloseNode( )
    if self._layer then
        self._layer:OnClose()
        self._layer:removeAllChildren()
        self._layer = nil
    end
end

return BeStrongUpMediator