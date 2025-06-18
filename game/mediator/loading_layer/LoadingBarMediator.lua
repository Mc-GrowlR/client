local BaseUIMediator = requireMediator("BaseUIMediator")
local LoadingBarMediator = class("LoadingBarMediator", BaseUIMediator)
LoadingBarMediator.NAME = "LoadingBarMediator"

function LoadingBarMediator:ctor()
    LoadingBarMediator.super.ctor(self)

    self._ratation = 0
end

function LoadingBarMediator:listNotificationInterests()
    local notice = global.NoticeTable
    return {
        notice.Layer_LoadingBar_Open,
        notice.Layer_LoadingBar_Close,
    }
end

function LoadingBarMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if notices.Layer_LoadingBar_Open == id then
        self:OnOpen(data)
    elseif notices.Layer_LoadingBar_Close == id then
        self:OnClose()
    end
end

function LoadingBarMediator:OnOpen(data)
    if not self._layer then
        self._layer = requireLayerUI("loading_layer/LoadingBarLayer").create()
        self._type = global.UIZ.UI_LOADINGBAR

        LoadingBarMediator.super.OpenLayer(self)
    end

    self:Init(data)

    global.userInputController:setKeyboardAble(false)
end

function LoadingBarMediator:OnClose()
    LoadingBarMediator.super.CloseLayer(self)

    global.userInputController:setKeyboardAble(true)
end

function LoadingBarMediator:Init(delayTime)
    if not self._layer then
        return false
    end
    self._layer:InitBar(delayTime, self._ratation)
end

function LoadingBarMediator:OnRotate(data)
    self._ratation = data
    if self._ratation >= 360 then
        self._ratation = self._ratation % 360
    end
end

return LoadingBarMediator
