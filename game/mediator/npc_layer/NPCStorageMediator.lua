local BaseUIMediator = requireMediator("BaseUIMediator")
local NPCStorageMediator = class("NPCStorageMediator", BaseUIMediator)
NPCStorageMediator.NAME = "NPCStorageMediator"

function NPCStorageMediator:ctor()
    NPCStorageMediator.super.ctor(self)
    self._layer = nil
end

function NPCStorageMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_NPC_Storage_Open,
        noticeTable.Layer_NPC_Storage_Close,
        noticeTable.Layer_NPC_Talk_Close,
        noticeTable.Layer_NPC_Storage_Update,
        noticeTable.Layer_NPC_Storage_Item_State,
        noticeTable.Layer_NPC_Storage_Size_Change,
    }
end

function NPCStorageMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()
    if noticeName == notices.Layer_NPC_Storage_Open then
        self:OpenLayer(noticeData)

    elseif noticeName == notices.Layer_NPC_Storage_Close or noticeName == notices.Layer_NPC_Talk_Close then
        self:CloseLayer(noticeData)

    elseif noticeName == notices.Layer_NPC_Storage_Update then
        self:UpdateItemList(noticeData)

    elseif noticeName == notices.Layer_NPC_Storage_Item_State then
        self:UpdateStorageItemState(noticeData)

    elseif noticeName == notices.Layer_NPC_Storage_Size_Change then
        self:UpdateStorageOpenNum()
    end
end

function NPCStorageMediator:OpenLayer(noticeData)
    if not self._layer then
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_Close)
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Store_Close)

        self._layer        = requireLayerUI("npc_layer/NpcStorageLayer").create()
        self._type         = global.UIZ.UI_NORMAL
        self._escClose     = true
        self._GUI_ID       = SLDefine.LAYERID.NPCStorageGUI

        NPCStorageMediator.super.OpenLayer(self)
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.NPC_STORAGE, self._layer)
        self._layer:ResetStorageData()

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.Storage
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        local noShowBag = noticeData and noticeData.noShowBag
        if not noShowBag then
            local newBagPos = {
                x = 470,
                y = 0
            }
            global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, {pos = newBagPos})
        end

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function NPCStorageMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.Storage
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    NPCStorageProxy:SetTouchType(0)
    NPCStorageMediator.super.CloseLayer(self)
end

function NPCStorageMediator:UpdateItemList(data)
    if self._layer then
        self._layer:UpdateItemList(data)
    end
end

function NPCStorageMediator:UpdateStorageItemState(data)
    if self._layer then
        self._layer:UpdateStorageItemState(data)
    end
end

function NPCStorageMediator:UpdateStorageOpenNum()
    if self._layer then
        self._layer:UpdateStorageOpenNum()
    end
end

return NPCStorageMediator