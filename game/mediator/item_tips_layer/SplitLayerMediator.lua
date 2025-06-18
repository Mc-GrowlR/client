--[[
    author:yzy
    time:2021-01-29 15:34:05
]]

local BaseUIMediator = requireMediator("BaseUIMediator")
local SplitLayerMediator = class('SplitLayerMediator', BaseUIMediator)
SplitLayerMediator.NAME = "SplitLayerMediator"

function SplitLayerMediator:ctor()
    SplitLayerMediator.super.ctor(self)
end

function SplitLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Split_Open,
            noticeTable.Layer_Split_Close,
        }
end

function SplitLayerMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local data          = notification:getBody()
    
    if noticeTable.Layer_Split_Open == noticeName then
        self:OpenLayer( data )
    elseif noticeTable.Layer_Split_Close == noticeName then
        self:CloseLayer()
    end
end

function SplitLayerMediator:OpenLayer( data )
    if not (self._layer) then
        self._layer = requireLayerUI("item_tips_layer/SplitLayer").create(data)
        self._type = global.UIZ.UI_TOBOX
        SplitLayerMediator.super.OpenLayer(self)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)
    end
end

function SplitLayerMediator:CloseLayer()
    if self._layer then
        SplitLayerMediator.super.CloseLayer(self)
    end
end

return SplitLayerMediator
