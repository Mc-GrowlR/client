local BaseUIMediator = requireMediator( "BaseUIMediator" )
local CommonDescTipsMediator = class('CommonDescTipsMediator', BaseUIMediator)
CommonDescTipsMediator.NAME = "CommonDescTipsMediator"

function CommonDescTipsMediator:ctor()
    CommonDescTipsMediator.super.ctor(self, self.NAME)
end

function CommonDescTipsMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Common_Desc_Open,
            noticeTable.Layer_Common_Desc_Close,
            noticeTable.UserInputEventNotice,
        }
end

function CommonDescTipsMediator:handleNotification(notification)
    local noticeID = notification:getName()
    local notices = global.NoticeTable
    local data = notification:getBody()
    
    if notices.Layer_Common_Desc_Open == noticeID then
        self:OpenLayer(data)
    
    elseif notices.Layer_Common_Desc_Close == noticeID then
        self:CloseLayer()
    elseif notices.UserInputEventNotice == noticeID then
        self:OnUserInputEventNotice()
    end
end

function CommonDescTipsMediator:OpenLayer(data)
    if not (self._layer) then
        local layer = requireLayerUI("common_tips_layer/CommonDescTipsLayer").create(data)
        self._layer         = layer
        self._type          = global.UIZ.UI_NOTICE
        self._hideMain = false

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        local function setNoswallowMouse()
            if self._layer then
                self:CloseLayer()
            end
            return -1
        end
        self._mouseBtnParam = {
            down_r = setNoswallowMouse,
            -- swallow = -1
        }
        CommonDescTipsMediator.super.OpenLayer(self)
    end
end

function CommonDescTipsMediator:CloseLayer()
    CommonDescTipsMediator.super.CloseLayer(self)
end

function CommonDescTipsMediator:OnUserInputEventNotice()
    if self._layer then
        self:CloseLayer()
    end
end

return CommonDescTipsMediator
