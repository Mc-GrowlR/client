local BaseUIMediator = requireMediator("BaseUIMediator")
local HurtTipsMediator = class('HurtTipsMediator', BaseUIMediator)
HurtTipsMediator.NAME = "HurtTipsMediator"

function HurtTipsMediator:ctor()
    HurtTipsMediator.super.ctor(self)
end

function HurtTipsMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.PlayerBeDamaged,
            noticeTable.PlayerManaChange,
            noticeTable.WindowResized,
        }
end

function HurtTipsMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    if noticeTable.PlayerBeDamaged == name then
        self:OnPlayerBeAttacked()
    elseif noticeTable.PlayerManaChange == name then
        self:OnPlayerManaChange()
    elseif noticeTable.WindowResized == name then
        self:OnWindowResized()
    end
end

function HurtTipsMediator:OpenLayer()
    if not (self._layer) then
        self._layer = requireLayerUI("hurt_tips_layer/HurtTipsLayer").create()
        global.Facade:sendNotification(global.NoticeTable.Layer_Notice_AddChild, {child = self._layer})
    end
end

function HurtTipsMediator:CloseLayer()
    if not self._layer then
        return nil
    end
    self._layer:removeFromParent()
    self._layer = nil
end

function HurtTipsMediator:OnWindowResized()
    if self._layer then
        self:CloseLayer()
        self:OpenLayer()
    end
end

function HurtTipsMediator:OnPlayerBeAttacked()
    if self._layer then
        return nil
    end
    if not (CHECK_SETTING(global.MMO.SETTING_IDX_UNSAFE_TIPS) == 1) then
        return nil
    end

    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local curHp = PlayerProperty:GetRoleCurrHP() or 1
    local maxHp = PlayerProperty:GetRoleMaxHP() or 1
    local percent = curHp / maxHp
    if percent < 0.3 and percent > 0 then
        self:OpenLayer()
    end
end

function HurtTipsMediator:OnPlayerManaChange()
    if not self._layer then
        return nil
    end

    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local curHp = PlayerProperty:GetRoleCurrHP() or 1
    local maxHp = PlayerProperty:GetRoleMaxHP() or 1
    local percent = curHp / maxHp
    if percent >= 0.3 or percent <= 0 then
        self:CloseLayer()
    end
end

return HurtTipsMediator
