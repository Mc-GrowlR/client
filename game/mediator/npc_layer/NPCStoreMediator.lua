local BaseUIMediator = requireMediator("BaseUIMediator")
local NPCStoreMediator = class("NPCStoreMediator", BaseUIMediator)
NPCStoreMediator.NAME = "NPCStoreMediator"

function NPCStoreMediator:ctor()
    NPCStoreMediator.super.ctor(self)
    self._layer = nil
end

function NPCStoreMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_NPC_Store_Open,
        noticeTable.Layer_NPC_Store_Close,
        noticeTable.Layer_NPC_Talk_Close,
        noticeTable.Layer_NPC_Store_Item_Remove
    }
end

function NPCStoreMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()
    if noticeName == notices.Layer_NPC_Store_Open then
        self:OpenLayer(noticeData)

    elseif noticeName == notices.Layer_NPC_Store_Close or noticeName == notices.Layer_NPC_Talk_Close then
        self:CloseLayer(noticeData)

    elseif noticeName == notices.Layer_NPC_Store_Item_Remove then
        self:RemoveItems(noticeData)
    end
end

function NPCStoreMediator:OpenLayer(noticeData)
    if not self._layer then
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_Close)

        self._layer  = requireLayerUI("npc_layer/NpcStoreLayer").create(noticeData)
        self._type   = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.NPCStoreGUI

        NPCStoreMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

        local _, rect = checkNotchPhone(true)
        self._layer:setPositionX(rect.x)
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

    local newBagPos = {
        x = 470,
        y = 20
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, {pos = newBagPos})
end

function NPCStoreMediator:CloseLayer()
    NPCStoreMediator.super.CloseLayer(self)
end

function NPCStoreMediator:RemoveItems(MakeIndex)
    if self._layer then
        self._layer:RemoveItems(MakeIndex)
    end
end

return NPCStoreMediator