local MainTargetMediator = class("MainTargetMediator", framework.Mediator)
MainTargetMediator.NAME = "MainTargetMediator"

function MainTargetMediator:ctor()
    MainTargetMediator.super.ctor(self, self.NAME)
end

function MainTargetMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.RefreshActorHP,
        noticeTable.Layer_UI_ROOT_Add_Child,
    }
end

function MainTargetMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnOpen()

    elseif noticeTable.RefreshActorHP == noticeID then
        self:OnRefreshActorHP(data)
    
    elseif noticeTable.Layer_UI_ROOT_Add_Child == noticeID then
        self:OnRootAddChild( data )

    end
end

function MainTargetMediator:OnOpen()
    if not (self._layer) then
        self._layer = requireMainUI("MainTargetLayout").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_LT
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        ssr.GUI.ATTACH_PARENT = self._layer
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        LoadLayerCUIConfig(global.CUIKeyTable.MAINTARGET, self._layer)
    end
end

function MainTargetMediator:OnRefreshActorHP(data)
    -- 选中目标受伤
    local proxyPlayerInput = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
    local targetID = proxyPlayerInput:GetTargetID()
    if targetID and targetID == data.actorID then
        SLBridge:onLUAEvent(LUA_EVENT_TARGET_HP_CHANGE, {actorID = data.actorID})

        local targetActor = global.actorManager:GetActor(targetID)
        if targetActor:IsMonster() and targetActor:GetHP() <= 0 then
            local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
            autoProxy:SetAFKTargetDeath(true)
        end
    end
end

function MainTargetMediator:OnRootAddChild( data )
    if not self._layer then
        return
    end

    local isShow = false
    if data and data.data and data.data.targetID then
        isShow = true
        local actor = global.actorManager:GetActor(data.data.targetID)
		if actor and actor:IsMonster() and actor:GetBigTipIcon() then
			isShow = false
		end
    end

    if isShow and data and data.func then
        local parent = nil
        if self._layer and self._layer._quickUI then
            parent = self._layer._quickUI.Panel_1
        end
        data.func( parent , "MainTarget_Belong")
    end
end

return MainTargetMediator
