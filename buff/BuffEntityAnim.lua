local BuffEntity = require("buff/BuffEntity")
local BuffEntityAnim = class("BuffEntityAnim", BuffEntity)

function BuffEntityAnim:ctor(data)
    BuffEntityAnim.super.ctor(self, data)

    self._rootNodeB     = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL_BEHIND)
    self._rootNodeF     = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL)
    self._sceneAnims    = {}

    local BuffProxy     = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    self._sfxOffset     = BuffProxy:GetSfxOffset(self._buffID)
    self._sfxSpeed      = BuffProxy:GetSfxSpeed(self._buffID)
    self._unOffset      = nil
    self._horseOffset   = cc.p(0,0)
    self._audioID       = BuffProxy:GetAudio(self._buffID)
end

function BuffEntityAnim:OnEnter()
    BuffEntityAnim.super.OnEnter(self)

    self:setVisible( true )
    self:updatePosition()
    self:PlayBuffAnim()

    if self._audioID then
        global.Facade:sendNotification( global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_SSR_UI, index=self._audioID} )
    end

end

function BuffEntityAnim:OnExit()
    BuffEntityAnim.super.OnExit(self)

    self:HideAnim()
    self:HideAnimStuck()

end

function BuffEntityAnim:PlayBuffAnim()
    local buffid = self._buffID
    if self._data.replaceId and self._data.replaceId > 0 then
        buffid = self._data.replaceId
    end

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local sfxConfig = BuffProxy:GetBuffSfxByID(buffid)
    if sfxConfig then
        local playSfx = sfxConfig.play_sfx
        if playSfx.sfxID then
            local sfxID  = playSfx.sfxID
            local loop   = playSfx.loop
            local data =
            {
                actorID = self._actorID,
                sfxID   = tonumber(sfxID),
                frame   = 0,
                speed   = 1,
                count   = loop or 1,
                front   = true,
                offsetX = 0,
                offsetY = 0,
            }
            global.ActorEffectManager:AddEffect(data)
        end
    end
end

function BuffEntityAnim:ShowAnim(needCheck)
    local buffid = self._buffID
    if self._data.replaceId and self._data.replaceId > 0 then
        buffid = self._data.replaceId
    end

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local sfxConfig = BuffProxy:GetBuffSfxByID(buffid)
    if sfxConfig then
        if sfxConfig.front then
            local sfxID  = sfxConfig.front.sfxID
            local loop   = sfxConfig.front.loop
            local is8dir = sfxConfig.front.is8dir
            self._unOffset = sfxConfig.front.unOffset
            self:addBuffSfx(sfxID, true, loop, is8dir)
        end
        
        if sfxConfig.behind then
            local sfxID  = sfxConfig.behind.sfxID
            local loop   = sfxConfig.behind.loop
            local is8dir = sfxConfig.behind.is8dir
            self:addBuffSfx(sfxID, false, loop, is8dir)
        end

    end
    
    if needCheck then
        local actor = global.actorManager:GetActor(self._actorID)
        if not actor then
            return
        end
        if (actor:IsMonster() or actor:IsHumanoid()) and (actor:IsDeath() or actor:IsDie()) then
            local isHide = tonumber(SL:GetMetaValue("GAME_DATA", "MonsterDieHideAnim")) == 1
            if isHide then
                self:HideAnim()
            end
        end
    end
end

function BuffEntityAnim:HideAnim()
    local buffid = self._buffID
    if self._data.replaceId and self._data.replaceId > 0 then
        buffid = self._data.replaceId
    end

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local sfxConfig = BuffProxy:GetBuffSfxByID(buffid)
    if sfxConfig then
        if sfxConfig.front then
            local sfxID = sfxConfig.front.sfxID
            self:removeBuffSfx(sfxID)
        end
        
        if sfxConfig.behind then
            local sfxID = sfxConfig.behind.sfxID
            self:removeBuffSfx(sfxID)
        end

        if sfxConfig.play_sfx then
            local sfxID = sfxConfig.play_sfx.sfxID
            self:removeBuffSfx(sfxID)
        end
    end
end

function BuffEntityAnim:IsShowStuckAnim( ... )
    local buffid = self._buffID
    if self._data.replaceId and self._data.replaceId > 0 then
        buffid = self._data.replaceId
    end
    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local sfxConfig = BuffProxy:GetBuffSfxByID(buffid)
    local hasSfx = false
    if sfxConfig then
        if sfxConfig.front_stuck and sfxConfig.front_stuck.sfxID and sfxConfig.front_stuck.sfxID ~= 0 then
            hasSfx = true
        end
        
        if sfxConfig.behind_stuck and sfxConfig.behind_stuck.sfxID and sfxConfig.behind_stuck.sfxID ~= 0 then
            hasSfx = true
        end
    end
    return hasSfx
end

function BuffEntityAnim:ShowAnimStuck()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    local buffid = self._buffID
    if self._data.replaceId and self._data.replaceId > 0 then
        buffid = self._data.replaceId
    end

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local sfxConfig = BuffProxy:GetBuffSfxByID(buffid)
    if sfxConfig then
        local falg = false
        local function callback()

            if self:IsInvalid() then
                return
            end

            if falg then
                return
            end
            falg = true
            self:HideAnimStuck()
            self:ShowAnim(true)
        end

        if sfxConfig.front_stuck then
            local sfxID  = sfxConfig.front_stuck.sfxID
            local loop   = sfxConfig.front_stuck.loop
            local is8dir = sfxConfig.front_stuck.is8dir
            self:addBuffSfx(sfxID, true, loop, is8dir, callback)
        end
        
        if sfxConfig.behind_stuck then
            local sfxID  = sfxConfig.behind_stuck.sfxID
            local loop   = sfxConfig.behind_stuck.loop
            local is8dir = sfxConfig.behind_stuck.is8dir
            self:addBuffSfx(sfxID, false, loop, is8dir, callback)
        end
    end
end

function BuffEntityAnim:HideAnimStuck()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    local buffid = self._buffID
    if self._data.replaceId and self._data.replaceId > 0 then
        buffid = self._data.replaceId
    end
    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local sfxConfig = BuffProxy:GetBuffSfxByID(buffid)
    if sfxConfig then
        if sfxConfig.front_stuck then
            local sfxID = sfxConfig.front_stuck.sfxID
            self:removeBuffSfx(sfxID)
        end
        
        if sfxConfig.behind_stuck then
            local sfxID = sfxConfig.behind_stuck.sfxID
            self:removeBuffSfx(sfxID)
        end
    end
end

function BuffEntityAnim:addBuffSfx(sfxID, front, loop, is8dir, callback)
    if not sfxID then
        return nil
    end
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    -- create sfx
    if nil == self._sceneAnims[sfxID] and not actor:GetValueByKey(global.MMO.HUD_SNEAK) then
        local dir  = (is8dir and actor:GetDirection() or 0)
        local sfx  = global.FrameAnimManager:CreateSFXAnim(sfxID)
        sfx:SetGlobalElapseEnable(loop == 0)
        local root = front and self._rootNodeF or self._rootNodeB
        root:addChild(sfx, sfxID)
        local visible      = CHECK_SETTING(global.MMO.SETTING_IDX_EFFECT_SHOW) ~= 1
        sfx:setVisible(visible)
        sfx:Play(0, dir, true)
        self._sceneAnims[sfxID] = sfx

        local count = 0
        local function overCB()

            if self:IsInvalid() then
                return
            end

            if loop > 0 then
                count = count + 1
                if loop == count then
                    sfx:Stop()
                    sfx:setVisible(false)
                end
            end
            
            if callback then
                callback()
            end
        end
        sfx:SetAnimEventCallback(overCB)
    end

    local position = actor:getPosition()
    self:setPosition(position.x, position.y)
end

function BuffEntityAnim:removeBuffSfx(sfxID)
    if not sfxID then
        return nil
    end
    
    if self._sceneAnims[sfxID] then
        self._sceneAnims[sfxID]:removeFromParent()
        self._sceneAnims[sfxID] = nil
    end
end

function BuffEntityAnim:OnActorStuck()
    if not self:IsShowStuckAnim() then
        return false
    end
    self:HideAnim()
    self:HideAnimStuck()

    self:ShowAnimStuck()
    return true
end

function BuffEntityAnim:setPosition(x, y)
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    local notOffset = self._unOffset and self._unOffset == 1
    local horseOffset = self._horseOffset or cc.p(0,0)
    for animID, anim in pairs(self._sceneAnims) do
        if actor:IsDropItem() then
            anim:setPosition(cc.pAdd(cc.pAdd(cc.p(x+horseOffset.x, y+horseOffset.y), notOffset and global.MMO.PLAYER_AVATAR_OFFSET or cc.p(0,0)), self._sfxOffset))
        else
            anim:setPosition(cc.pAdd(cc.pAdd(cc.p(x+horseOffset.x, y+horseOffset.y), global.MMO.PLAYER_AVATAR_OFFSET), self._sfxOffset))
        end
    end
end

function BuffEntityAnim:setVisible(visible)
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return
    end

    if actor:IsPlayer() and actor:IsHoreseCopilot() then
        self:HideAnim()
        return
    end

    if actor:IsPlayer() and actor:GetHorseMasterID() and global.actorManager:GetActor(actor:GetHorseMasterID()) then
        local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        if not BuffProxy:IsHorseShow(self._buffID) then
            self:HideAnim()
            return
        end
    end

    -- 潜行
    if visible and actor:GetValueByKey(global.MMO.HUD_SNEAK) then
        visible = false
    end

    if visible then
        self:ShowAnim()
    else
        self:HideAnim()
    end
end

function BuffEntityAnim:updatePosition()
    local actor = global.actorManager:GetActor(self._actorID)
    if actor and self._buffID == global.MMO.BUFF_ID_MAGIC_SHIELD then
        -- 检测是不是副驾的玩家   副驾玩家的buff特效都不显示出来
        self._horseOffset.y = 0
        local position = actor:getPosition()
        if actor and actor:IsPlayer() and actor:GetHorseMasterID() then
            self._horseOffset.y = 10
        end
        self:setPosition(position.x, position.y)
    elseif actor and actor:IsPlayer() then
        local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        local offset = BuffProxy:GetHorseOffset(self._buffID)
        if offset.x ~= 0 or offset.y ~= 0 then
            if actor:GetHorseMasterID() and global.actorManager:GetActor(actor:GetHorseMasterID()) then
            else
                offset.x = 0
                offset.y = 0
            end
            self._horseOffset = offset
            local position = actor:getPosition()
            self:setPosition(position.x, position.y)
        end
        
    end
end

return BuffEntityAnim
