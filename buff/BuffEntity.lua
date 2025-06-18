local BuffEntity = class("BuffEntity")

function BuffEntity:ctor(data)
    self._data = data
    
    self._actorID   = data.actorID
    self._buffID    = data.buffID
    self._param     = data.param
    self._ol        = data.ol

    if self._buffID > 10000 then
        self._endTime  = tonumber(data.param) or GetServerTime()
    else
        self._endTime   = (tonumber(data.param) or 0) + GetServerTime()
    end
    
    self._autoRemove= data.autoRemove

    self._isInvalid = false

    self._visible   = true
    -- 检测是不是副驾的玩家   副驾玩家的buff特效都不显示出来
    local actor = global.actorManager:GetActor(self._actorID)
    if actor and actor:IsPlayer() and actor:IsHoreseCopilot() then
        self._visible = false
    end
end

function BuffEntity:OnEnter()
end

function BuffEntity:OnExit()
end

function BuffEntity:Tick(dt)
    if self._autoRemove then
        if GetServerTime() > self._endTime then
            self:disable()
        end
    end
end

function BuffEntity:IsInvalid()
    return self._isInvalid
end

function BuffEntity:disable()
    self._isInvalid = true
end

function BuffEntity:abort()
    self:disable()
end

function BuffEntity:GetActorID()
    return self._actorID
end

function BuffEntity:GetBuffID()
    return self._buffID
end

function BuffEntity:GetData()
    return self._data
end

function BuffEntity:GetEndTime()
    return self._endTime
end

function BuffEntity:GetParam()
    return self._param
end


function BuffEntity:IsAllowAnimUpdate()
    return true
end

function BuffEntity:UpdatePresent()
    return false
end

function BuffEntity:OnActorStuck()
    return false
end

function BuffEntity:UpdateParam(param)
    self._param   = param
    if self._buffID > 10000 then
        self._endTime  = tonumber(param) or GetServerTime()
    else
        self._endTime   = (tonumber(param) or 0) + GetServerTime()
    end
end

function BuffEntity:UpdateOl(ol)
    if ol then
        self._ol = ol
    end
end

function BuffEntity:GetOl()
    return self._ol
end

function BuffEntity:setPosition(x, y)
end

function BuffEntity:setVisible(visible)
end

function BuffEntity:updatePosition()
end

return BuffEntity
