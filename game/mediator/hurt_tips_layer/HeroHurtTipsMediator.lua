local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroHurtTipsMediator = class('HeroHurtTipsMediator', BaseUIMediator)
HeroHurtTipsMediator.NAME = "HeroHurtTipsMediator"

function HeroHurtTipsMediator:ctor()
    HeroHurtTipsMediator.super.ctor(self)
end

function HeroHurtTipsMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.HeroBeDamaged,
            noticeTable.PlayerManaChange_Hero,
            noticeTable.Layer_Hero_Logout,
        }
end

function HeroHurtTipsMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    if noticeTable.HeroBeDamaged == name then
        self:OnPlayerBeAttacked()
    elseif noticeTable.PlayerManaChange_Hero == name then
        self:OnPlayerManaChange()
    elseif noticeTable.Layer_Hero_Logout == name then
        self:CloseLayer()
    end
end

function HeroHurtTipsMediator:OpenLayer()
    if not (self._layer) then
        self._layer = requireLayerUI("hurt_tips_layer/HurtTipsLayer").create()
        global.Facade:sendNotification(global.NoticeTable.Layer_Notice_AddChild, {child = self._layer})
    end
end

function HeroHurtTipsMediator:CloseLayer()
    if not self._layer then
        return nil
    end
    self._layer:removeFromParent()
    self._layer = nil
end

function HeroHurtTipsMediator:OnPlayerBeAttacked()
    if self._layer then
        return nil
    end
    if not (CHECK_SETTING(28) == 1) then--跟人物走一套设置
        return nil
    end
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    local curHp = HeroPropertyProxy:GetRoleCurrHP() or 1
    local maxHp = HeroPropertyProxy:GetRoleMaxHP() or 1
    local percent = curHp / maxHp
    if percent < 0.3 and percent > 0 then
        self:OpenLayer()
    end
end

function HeroHurtTipsMediator:OnPlayerManaChange()
    if not self._layer then
        return nil
    end

    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    local curHp = HeroPropertyProxy:GetRoleCurrHP() or 1
    local maxHp = HeroPropertyProxy:GetRoleMaxHP() or 1
    local percent = curHp / maxHp
    if percent >= 0.3 or percent <= 0 then
        self:CloseLayer()
    end
end

return HeroHurtTipsMediator
