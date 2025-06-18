local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local RankLayerMediator = class('RankLayerMediator', BaseUIMediator)
RankLayerMediator.NAME = "RankLayerMediator"

function RankLayerMediator:ctor()
    RankLayerMediator.super.ctor(self)
end

function RankLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Rank_Open,
            noticeTable.Layer_Rank_Close,
        }
end

function RankLayerMediator:handleNotification(notification)
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()
    
    if noticeTable.Layer_Rank_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_Rank_Close == noticeName then
        self:CloseLayer()
    end
end

function RankLayerMediator:OpenLayer(data)
    if not (self._layer) then
        local path = "rank_layer/RankLayer"
        if global.isWinPlayMode then
            path = "rank_layer/RankLayer-win32"
        end
        self._layer = requireLayerUI( path ).create(data)
        self._type  = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.RankGUI
        RankLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI(data)

        LoadLayerCUIConfig(global.CUIKeyTable.RANK, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root  = self._layer.Panel1,
            index = global.SUIComponentTable.Rank
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        self:CloseLayer()
    end
end

function RankLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.Rank
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    RankLayerMediator.super.CloseLayer(self)
end

return RankLayerMediator
