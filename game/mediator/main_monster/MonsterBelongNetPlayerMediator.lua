local BaseUIMediator = requireMediator("BaseUIMediator")
local MonsterBelongNetPlayerMediator = class("MonsterBelongNetPlayerMediator", BaseUIMediator)
MonsterBelongNetPlayerMediator.NAME = "MonsterBelongNetPlayerMediator"

function MonsterBelongNetPlayerMediator:ctor()
    MonsterBelongNetPlayerMediator.super.ctor(self)

    self._inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
end

function MonsterBelongNetPlayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable

    return {
        noticeTable.TargetChange_After,
        noticeTable.RefreshActorHP,
        noticeTable.Layer_Monster_Belong_Select,
        noticeTable.UserInputMove,
        noticeTable.ActorOwnerChange,
        noticeTable.PlayerPKModeChange,
        noticeTable.ActorOutOfView,
        noticeTable.MainPlayerActionEnded
    }
end

function MonsterBelongNetPlayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.TargetChange_After == noticeID then
        self:OnTargetChange(data)

    elseif noticeTable.RefreshActorHP == noticeID then
        self:OnRefreshHP(data)

    elseif noticeTable.Layer_Monster_Belong_Select == noticeID then
        self:OnSelectRefresh(data)

    elseif noticeTable.UserInputMove == noticeID then -- 移动
        if data and data.type == global.MMO.INPUT_MOVE_TYPE_JOYSTICK then -- 摇杆移动取消自动跟踪
            self:OnMoveCancelTracking()
            self:OnActorOwnerChange(data)
        end

    elseif noticeTable.ActorOwnerChange == noticeID then
        self:OnActorOwnerChange(data)

    elseif noticeTable.PlayerPKModeChange == noticeID then
        self:OnUpdateUIVisible()

    elseif noticeTable.ActorOutOfView == noticeID then
        if self._inputProxy:GetOwnerPlayerID() == data.actorID then
            self._inputProxy:SetOwnerPlayerID(nil)
            self._inputProxy:SetTraceOwnerPlayerState(false)
            self:OnUnAttach()
        end

    elseif noticeTable.MainPlayerActionEnded == noticeID then
        self:onMainPlayerActionEnded(data)

    end

end

function MonsterBelongNetPlayerMediator:OnTargetChange(data)
    if not data or not data.targetID then
        self:OnUnAttach()
        return
    end

    if self._layer then
        self:OnUnAttach()
    end

    if not self._layer then
        self:OnAttach(data)
    end
end

function MonsterBelongNetPlayerMediator:OnAttach(data)
    if not self._layer then
        local layer = requireLayerUI("main_monster/MonsterBelongNetPlayerLayer").create(data)
        if layer then
            layer:setName("MONSTER_BELONG_ROOT")
            layer:InitGUI({
                parent = layer,
                targeData = data
            })

            global.Facade:sendNotification(global.NoticeTable.Layer_UI_ROOT_Add_Child, {
                data = data,
                func = function(parent, type)
                    if not parent then
                        self:OnUnAttach()
                        return
                    end

                    if layer then
                        local childNode = parent:getChildByName("MONSTER_BELONG_ROOT")
                        if childNode then
                            childNode:removeFromParent()
                            childNode = nil
                        end

                        if not data then
                            data = {}
                        end
                        local posx = data.pos and data.pos.x or 0
                        local posy = data.pos and data.pos.y or 0
                        local parentSz = parent:getContentSize()
                        layer:setPosition(parentSz.width + posx, parentSz.height + posy)
                        parent:addChild(layer, 999)
                        self._layer = layer

                        self._layer.type = type

                        LoadLayerCUIConfig(string.format("%s_%s", global.isWinPlayMode and "pc" or "mobile", type), self._layer)
                    end
                end
            })

        end
    end
end

function MonsterBelongNetPlayerMediator:OnUnAttach()
    if self._layer then
        self._inputProxy:SetOwnerPlayerID(nil)
        self._inputProxy:SetTraceOwnerPlayerState(false)

        self._layer:removeFromParent()
        self._layer = nil
    end
end

function MonsterBelongNetPlayerMediator:OnRefreshHP(data)
    if not self._layer then
        return
    end
    if data and data.actorID then
        data.targetID = data.actorID
    end
    self._layer:UpdateHP(data)
end

function MonsterBelongNetPlayerMediator:OnSelectRefresh(data)
    if not self._layer then
        return
    end
    self._layer:OnSelectRefresh(data)
end

function MonsterBelongNetPlayerMediator:OnCheckMoveAttack(data)
    if data and data.actor then
        if data.actor:GetID() == self._inputProxy:GetOwnerPlayerID() then -- 检测是否在攻击范围

        end
    end
end

function MonsterBelongNetPlayerMediator:OnActorOwnerChange(data)
    if not self._layer then
        return
    end

    self._inputProxy:SetOwnerPlayerID(nil)
    self._layer:OnActorOwnerChange(data)
end

function MonsterBelongNetPlayerMediator:OnUpdateUIVisible()
    if not self._layer then
        return
    end
    self._layer:UpdateUIVisible()
end

function MonsterBelongNetPlayerMediator:OnMoveCancelTracking()
    self._inputProxy:SetTraceOwnerPlayerState(false)
    local targetID = self._inputProxy:GetTargetID()
    global.Facade:sendNotification(global.NoticeTable.TargetChange, {
        targetID = targetID
    })
end

-- 超出范围不追踪
function MonsterBelongNetPlayerMediator:onMainPlayerActionEnded(act)
    if not self._layer then
        return
    end

    if not self._inputProxy:IsTraceOwnerPlayer() then
        return
    end

    local ownerID = self._inputProxy:GetOwnerPlayerID()
    if ownerID then
        local ownerRange = 8
        local player = global.gamePlayerController:GetMainPlayer()
        if not player then
            return
        end
        local playerPos = cc.p(player:GetMapX(), player:GetMapY())

        local actor = global.actorManager:GetActor(ownerID)
        if not actor then
            return
        end

        local actorPos = cc.p(actor:GetMapX(), actor:GetMapY())
        if cc.pGetDistance(actorPos, playerPos) > ownerRange then
            self:OnMoveCancelTracking()
            self:OnActorOwnerChange()
        end
    end
end

return MonsterBelongNetPlayerMediator