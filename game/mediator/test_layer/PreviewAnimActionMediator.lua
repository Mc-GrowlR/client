local BaseUIMediator = requireMediator("BaseUIMediator")
local PreviewAnimActionMediator = class('PreviewAnimActionMediator', BaseUIMediator)
PreviewAnimActionMediator.NAME = "PreviewAnimActionMediator"

function PreviewAnimActionMediator:ctor()
    PreviewAnimActionMediator.super.ctor(self)
end

function PreviewAnimActionMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.Preview_Skill_Action_Attach,
        noticeTable.Preview_Skill_Action_UnAttach,
        noticeTable.Preview_Skill_Action_Refresh,
    }
end

function PreviewAnimActionMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData  = notification:getBody()
    
    if noticeTable.Preview_Skill_Action_Attach == noticeName then
        self:AttachLayer( noticeData )

    elseif noticeTable.Preview_Skill_Action_UnAttach == noticeName then
        self:UnAttachLayer()

    elseif noticeTable.Preview_Skill_Action_Refresh == noticeName then
        self:OnRefresh(noticeData)

    end
end

function PreviewAnimActionMediator:AttachLayer( data )
    if not self._layer then
        local layer = requireLayerUI("test_layer/PreviewSkillAction").create(data)
        if layer and data.parent then
            data.parent:addChild(layer)
            self._layer = layer
        end
    end
end

function PreviewAnimActionMediator:UnAttachLayer()
    if self._layer then
        self._layer:removeFromParent()        
        self._layer   = nil
    end
end

function PreviewAnimActionMediator:OnRefresh( data )
    if self._layer then
        self._layer:OnRefresh(data)
    end
end

return PreviewAnimActionMediator
