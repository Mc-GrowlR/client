local BaseUIMediator = requireMediator("BaseUIMediator")
local AutoUseTipsMediator = class("AutoUseTipsMediator", BaseUIMediator)
AutoUseTipsMediator.NAME = "AutoUseTipsMediator"

function AutoUseTipsMediator:ctor()
    AutoUseTipsMediator.super.ctor(self, self.NAME)
end

function AutoUseTipsMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Auto_Use_Attach,
        noticeTable.Layer_Auto_Use_UnAttach,
        noticeTable.Bag_Oper_Data,
        noticeTable.HeroBag_Oper_Data
    }
end

function AutoUseTipsMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id   = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Auto_Use_Attach == id then
        self:OnOpen(data)

    elseif noticeTable.Layer_Auto_Use_UnAttach == id then
        self:OnClose(data)

    elseif noticeTable.Bag_Oper_Data == id then
        self:PushItemIntoTipsList(data)

    elseif noticeTable.HeroBag_Oper_Data == id then
        self:PushItemIntoTipsList_Hero(data)
    end
end

function AutoUseTipsMediator:OnOpen(data)
    if not data or not data.id then
        return false
    end

    if not self._layer then
        self._layer = requireLayerUI("auto_use_tips_layer/AutoUseTipsLayer").create()
        self._type  = global.UIZ.UI_FUNC

        AutoUseTipsMediator.super.OpenLayer(self)    
    end
    GUI.ATTACH_PARENT = self._layer
    self._layer:InitGUI(data)
end

function AutoUseTipsMediator:OnClose(data)
    if not data or not data.id then
        return
    end
    
    if self._layer then
        self._layer:RemoveTips(data)
        if not self._layer._tipsList or not next(self._layer._tipsList) then
            AutoUseTipsMediator.super.CloseLayer(self)
        end
    end

    local AutoUseItemProxy = global.Facade:retrieveProxy(global.ProxyTable.AutoUseItemProxy)
    if AutoUseItemProxy then
        local playerType = data.isHero and 2 or 1
        if not data.pos then
            data.pos = AutoUseItemProxy:GetBagPosByMakeIndex(data.id)
        end
        AutoUseItemProxy:RemoveEquipTip(data.pos, playerType)
    end
end

local function _CallFunc(data, isHero)
    local AutoUseItemProxy = global.Facade:retrieveProxy(global.ProxyTable.AutoUseItemProxy)
    for _, v in pairs(data.operID) do
        if not v.isHad or (v.change and v.change > 0) then
            local item = v.item or {}
            local isEquipOff = AutoUseItemProxy:IsEquipOffByMakeIndex(item.MakeIndex)
            local isNotTip   = AutoUseItemProxy:IsEquipNotTip(item)
            if not isEquipOff and not isNotTip then
                
                -- 英雄拾取穿戴不互通
                local isHumToHeroBag = SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_HUM_TO_HERO_BAG)
                if not isHumToHeroBag then
                    if isHero then
                        GUIFunction:OnAutoUseCheckItem_Hero(v.item)
                    else
                        GUIFunction:OnAutoUseCheckItem(v.item)
                    end
                else

                    local firstHero = SL:GetMetaValue("GAME_DATA", "firstHeroAutoUse")  -- 先检测英雄
                    if isHero then
                        GUIFunction:OnAutoUseCheckItem_Hero(v.item)
                    else
                        if firstHero == 1 then 
                            local bSuccess = GUIFunction:OnAutoUseCheckItem_Hero(v.item)
                            if not bSuccess then 
                                GUIFunction:OnAutoUseCheckItem(v.item)
                            end 
                        else 
                            local bSuccess = GUIFunction:OnAutoUseCheckItem(v.item)
                            if not bSuccess then 
                                GUIFunction:OnAutoUseCheckItem_Hero(v.item)
                            end 
                        end 
                    end

                end     
            end
        end
    end
end

function AutoUseTipsMediator:PushItemIntoTipsList(data)
    if data and data.opera and (data.opera == global.MMO.Operator_Add or data.opera == global.MMO.Operator_Change) then
        _CallFunc(data)
    end
end

function AutoUseTipsMediator:PushItemIntoTipsList_Hero(data)
    if data and data.opera and (data.opera == global.MMO.Operator_Add or data.opera == global.MMO.Operator_Change) then
        _CallFunc(data, true)
    end
end

return AutoUseTipsMediator