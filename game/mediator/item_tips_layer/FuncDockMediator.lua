local BaseUIMediator   = requireMediator( "BaseUIMediator" )
local FuncDockMediator = class('FuncDockMediator', BaseUIMediator )
FuncDockMediator.NAME  = "FuncDockMediator"

function FuncDockMediator:ctor()
    FuncDockMediator.super.ctor( self )
end

function FuncDockMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Func_Dock_Open,
        noticeTable.Layer_Func_Dock_Close,
        noticeTable.Layer_Func_Dock_RequsetInfo,
        noticeTable.Layer_Func_Dock_Response,
    }
end

function FuncDockMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()

    if noticeTable.Layer_Func_Dock_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_Func_Dock_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.Layer_Func_Dock_RequsetInfo == noticeName then
        self:requestInfo(noticeData)
    elseif noticeTable.Layer_Func_Dock_Response == noticeName then
        self:responseInfo(noticeData)
    end
end

function FuncDockMediator:OpenLayer(noticeData)
    if not ( self._layer ) then
        local FuncDockProxy = global.Facade:retrieveProxy( global.ProxyTable.FuncDockProxy )
        if not FuncDockProxy:CanOpen(noticeData) then
            return false
        end

        self._layer     = requireLayerUI("item_tips_layer/FuncDockLayer").create(noticeData)
        self._type      = global.UIZ.UI_FUNC
        self._hideMain  = false
        self._voice     = false

        FuncDockMediator.super.OpenLayer( self )

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

    end
end

function FuncDockMediator:CloseLayer()
    self.seveData = nil
    FuncDockMediator.super.CloseLayer( self )
end

--先向服务端请求玩家信息 再根据信息显示按钮
function FuncDockMediator:requestInfo( noticeData )
    self.seveData = nil
    if noticeData == nil then
        return
    end
    local uid = noticeData.targetId
    if uid == nil then
        return
    end
    local isHero = noticeData.isHero
    self.seveData = noticeData
    local funcDockProxy  = global.Facade:retrieveProxy( global.ProxyTable.FuncDockProxy )
    funcDockProxy:requestLookStatus(uid,isHero)
end

--服务端返回玩家信息
function FuncDockMediator:responseInfo( noticeData )
    if self.seveData == nil or noticeData == nil then
        return
    end
    if self.seveData.targetId ~= noticeData.UserID then
        return
    end

    local data = self.seveData
    data.basic = noticeData

    global.Facade:sendNotification( global.NoticeTable.Layer_Func_Dock_Open, data)
end

return FuncDockMediator
