local BaseUIMediator = requireMediator("BaseUIMediator")
local NoticeMediator = class("NoticeMediator", BaseUIMediator)
NoticeMediator.NAME = "NoticeMediator"

local sformat = string.format

function NoticeMediator:ctor()
    NoticeMediator.super.ctor(self)

    self._typeEffects = {{}, {}, {}}
end

function NoticeMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Notice_Open,
        noticeTable.Layer_Notice_Close,
        noticeTable.Layer_Notice_AddChild,
        noticeTable.Layer_Notice_RemoveChild,
        noticeTable.Layer_Notice_Attribute,
        noticeTable.SystemTips,
        noticeTable.ShowServerNotice,
        noticeTable.ShowSystemNotice,
        noticeTable.ShowTimerNotice,
        noticeTable.DeleteTimerNotice,
        noticeTable.UserInputEventNotice,
        noticeTable.ShowCostItem,
        noticeTable.ShowGetBagItem,
        noticeTable.ShowCostItem_Hero,
        noticeTable.ShowGetBagItem_Hero,
        noticeTable.ShowSystemNoticeXY,
        noticeTable.ServerNoticeEvent,
        noticeTable.Layer_Main_Init,
        noticeTable.ShowSystemNoticeScale,
        noticeTable.ShowPlayerEXPNotice,
        noticeTable.ShowTimerNoticeXY,
        noticeTable.DeleteTimerNoticeXY,
        noticeTable.ShowItemDropNotice
    }
end

function NoticeMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Notice_Open == id then
        self:OnOpen()
    elseif noticeTable.Layer_Notice_Close == id then
        self:OnClose(data)
    elseif noticeTable.Layer_Notice_AddChild == id then
        self:OnAddChild(data)
    elseif noticeTable.Layer_Notice_RemoveChild == id then
        self:OnRemoveChild(data)
    elseif noticeTable.Layer_Notice_Attribute == id then
        self:OnShowAttribute(data)
    elseif noticeTable.ShowServerNotice == id then
        self:OnShowServerNotice(data)
    elseif noticeTable.ShowSystemNotice == id then
        self:OnShowSystemNotice(data)
    elseif noticeTable.SystemTips == id then
        self:OnSystemTips(data)
    elseif noticeTable.ShowTimerNotice == id then
        self:OnShowTimerNotice(data)
    elseif noticeTable.DeleteTimerNotice == id then
        self:OnDeleteTimerNotice(data)
    elseif noticeTable.UserInputEventNotice == id then
        self:onUserInputEventNotice()
    elseif noticeTable.ShowGetBagItem == id then
        self:OnShowGetBagItem(data)
    elseif noticeTable.ShowGetBagItem_Hero == id then
        self:OnShowGetBagItem_Hero(data)
    elseif noticeTable.ShowCostItem == id then
        self:OnShowCostBagItem(data)
    elseif noticeTable.ShowCostItem_Hero == id then
        self:OnShowCostBagItem_Hero(data)
    elseif noticeTable.ShowSystemNoticeXY == id then
        self:OnShowSystemNoticeXY(data)
    elseif noticeTable.ServerNoticeEvent == id then
        self:OnServerNoticeEvent(data)
    elseif noticeTable.ShowPlayerEXPNotice == id then
        self:OnShowPlayerEXPNoticeXY(data)
    elseif noticeTable.ShowSystemNoticeScale == id then
        self:OnShowSystemNoticeScale(data)
    elseif noticeTable.ShowTimerNoticeXY == id then
        self:OnShowTimerNoticeXY(data)
    elseif noticeTable.DeleteTimerNoticeXY == id then
        self:OnDeleteTimerNoticeXY(data)
    elseif noticeTable.ShowItemDropNotice == id then
        self:OnShowItemDropNoticeXY(data)
    end
end

function NoticeMediator:OnOpen()
    if not self._layer then
        self._layer = requireLayerUI("message_layer/NoticeLayer").create()
        self._type = global.UIZ.UI_NOTICE

        NoticeMediator.super.OpenLayer(self)

        GUI.ATTACH_PARENT = self._layer
        GUI.ATTACH_PARENT_UITOP = self._layer
        self._layer:InitGUI()
    end
end

function NoticeMediator:OnClose(data)
    if not self._layer then
        return
    end
    self._layer:OnClose(data)
    NoticeMediator.super.CloseLayer(self)
end

function NoticeMediator:OnAddChild(data)
    if not self._layer then
        return false
    end
    self._layer:OnAddChild(data)
end

function NoticeMediator:OnRemoveChild(name)
    if not (self._layer and self._layer._root) then
        return false
    end
    if self._layer._root:getChildByName(name) then
        self._layer._root:removeChildByName(name)
    end
end

function NoticeMediator:OnShowServerNotice(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_SERVER", data)
        --self._layer:OnShowServerNotice(data)
    end
end

function NoticeMediator:OnServerNoticeEvent(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_SERVER_EVENT", data)
        --self._layer:OnServerNoticeEvent(data)
    end
end

function NoticeMediator:OnShowSystemNotice(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_SYSYTEM", data)
        --self._layer:OnShowSystemNotice(data)
    end
end

function NoticeMediator:OnSystemTips(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_SYSYTEM_TIPS", data)
        --self._layer:AddSystemTips(data)
    end

    if _DEBUG and data == "ERROR" then
        release_print("++++++++++++++++++++++++++++++++++++++++")
        local trace = debug.traceback()
        release_print(trace)
        release_print("++++++++++++++++++++++++++++++++++++++++")
    end
end

function NoticeMediator:OnShowSystemNoticeXY(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_SYSYTEM_XY", data)
        --self._layer:OnShowSystemNoticeXY(data)
    end
end

function NoticeMediator:OnShowSystemNoticeScale(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_SYSYTEM_SCALE", data)
        --self._layer:OnShowSystemNoticeScale(data)
    end
end

function NoticeMediator:OnShowTimerNotice(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_TIMER", data)
        --self._layer:OnShowTimerNotice(data)
    end
end

function NoticeMediator:OnDeleteTimerNotice(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_DELETE_TIMER", data)
        --self._layer:OnDeleteTimerNotice(data)
    end
end

function NoticeMediator:OnShowTimerNoticeXY(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_TIMER_XY", data)
        --self._layer:OnShowTimerNoticeXY(data)
    end
end

function NoticeMediator:OnDeleteTimerNoticeXY(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_DELETE_TIMER_XY", data)
        --self._layer:OnDeleteTimerNoticeXY(data)
    end
end

function NoticeMediator:OnShowItemChangeTips(msg, data)
    if self._layer then
        local info = {
            str = msg,
            data = data,
        }
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_ITEM_TIPS", info)
        --self._layer:AddItemTips(msg, data)
    end
end

function NoticeMediator:onUserInputEventNotice(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Notice_RemoveChild, "__MouseTips")
end

function NoticeMediator:OnShowGetBagItem(data)
    if not data or not data.name or not data.num then
        return
    end
    local color = GET_COLOR_BYID(250)
    local name = data.name
    local count = data.num
    local str = sformat(GET_STRING(30006006), color, name, count)

    if SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_GET_ITEM] and SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_GET_ITEM]({name = name, count = count, str = str}) then
        return false
    end

    if global.isWinPlayMode then
        local str = sformat(GET_STRING(600000310), name, count)
        self:OnShowItemChangeTips(str, {color = color})
    else
        self:OnShowItemChangeTips(str)
    end
end
function NoticeMediator:OnShowGetBagItem_Hero(data)
    if not data or not data.name or not data.num then
        return
    end
    local color = GET_COLOR_BYID(250)
    local name = data.name
    local count = data.num
    local str = sformat(GET_STRING(600000217), color, name, count)

    if SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_GET_ITEM] and SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_GET_ITEM]({name = name, count = count, str = str, ishero = true}) then
        return false
    end

    if global.isWinPlayMode then
        local str = sformat(GET_STRING(600000310), name, count)
        self:OnShowItemChangeTips(str, {color = color, heroStr = GET_STRING(600000312), heroColor = "#ff0500"})
    else
        self:OnShowItemChangeTips(str)
    end
end

function NoticeMediator:OnShowCostBagItem(data)
    if not data or not data.name or not data.num then
        return
    end
    local color = GET_COLOR_BYID(22)
    local name = data.name
    local count = data.num
    local str = sformat(GET_STRING(30006007), color, name, count)

    if SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_COST_ITEM] and SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_COST_ITEM]({name = name, count = count, str = str}) then
        return false
    end

    if global.isWinPlayMode then
        local str = sformat(GET_STRING(600000311), name, count)
        self:OnShowItemChangeTips(str, {color = color})
    else
        self:OnShowItemChangeTips(str)
    end
end
function NoticeMediator:OnShowCostBagItem_Hero(data)
    if not data or not data.name or not data.num then
        return
    end
    local color = GET_COLOR_BYID(22)
    local name = data.name
    local count = data.num
    local str = sformat(GET_STRING(600000218), color, name, count)

    if SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_COST_ITEM] and SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_COST_ITEM]({name = name, count = count, str = str, ishero = true}) then
        return false
    end

    if global.isWinPlayMode then
        local str = sformat(GET_STRING(600000311), name, count)
        self:OnShowItemChangeTips(str, {color = color, heroStr = GET_STRING(600000312), heroColor = "#ff0500"})
    else
        self:OnShowItemChangeTips(str)
    end
end

function NoticeMediator:OnShowAttribute(data)
    if not self._layer then
        return false
    end
    SLBridge:onLUAEvent("LUA_EVENT_NOTICE_ATTRIBUTE", data)
    --self._layer:AddNoticeAttribute(data)
end

function NoticeMediator:OnShowPlayerEXPNoticeXY(data)
    if self._layer then
        if SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_EXP_CHANGE] and SL.Triggers[LUA_TRIGGER_NOTICE_SHOW_EXP_CHANGE](data) then
            return false
        end
        --self._layer:OnShowPlayerEXPNoticeXY(data)
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_EXP", data)   
    end
end

function NoticeMediator:OnShowItemDropNoticeXY(data)
    if self._layer then
        SLBridge:onLUAEvent("LUA_EVENT_NOTICE_DROP", data)   
        --self._layer:OnShowItemDropNoticeXY(data)
    end
end

function NoticeMediator:GetEffectsData()
    return self._typeEffects
end

return NoticeMediator
