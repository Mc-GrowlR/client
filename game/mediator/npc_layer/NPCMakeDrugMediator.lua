local BaseUIMediator = requireMediator("BaseUIMediator")
local NPCMakeDrugMediator = class("NPCMakeDrugMediator", BaseUIMediator)
NPCMakeDrugMediator.NAME = "NPCMakeDrugMediator"

function NPCMakeDrugMediator:ctor()
    NPCMakeDrugMediator.super.ctor(self)
    self._layer = nil
end

function NPCMakeDrugMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_NPC_Make_Drug_Open,
        noticeTable.Layer_NPC_Make_Drug_Close,
        noticeTable.Layer_NPC_Talk_Close
    }
end

function NPCMakeDrugMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_NPC_Make_Drug_Open then
        self:OpenLayer(noticeData)

    elseif noticeName == notices.Layer_NPC_Make_Drug_Close or noticeName == notices.Layer_NPC_Talk_Close then
        self:CloseLayer(noticeData)
    end
end

function NPCMakeDrugMediator:OpenLayer(noticeData)
    if not self._layer then
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_Close)
        self._layer = requireLayerUI("npc_layer/NpcMakeDrugLayer").create(noticeData)
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.NPCMakeDrugGUI

        NPCMakeDrugMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
    
    local newBagPos = {
        x = 470,
        y = 20
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, { pos = newBagPos })
end

function NPCMakeDrugMediator:CloseLayer()
    if self._layer then
        NPCMakeDrugMediator.super.CloseLayer(self)
    end
end

return NPCMakeDrugMediator