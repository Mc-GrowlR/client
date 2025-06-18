
local PreviewSkillAction = class("PreviewSkillAction",function()
    return cc.Node:create()
end)

local ACTIONS = {
    [1] = {
        action = global.MMO.ACTION_ATTACK,
        name = "平砍",
        speed = 1000,
    },
    [2] = {
        action = global.MMO.ACTION_SKILL,
        name = "施法",
        speed = 1000,
    }
}

local effectOff = {
    [131] = {
        x = -25,
        y = 0
    }
}
local offsetys = {
    [13] = 1,
    [14] = 1,
    [15] = 1,
    [19] = 1,
    [38] = 1,
    [44] = 1,
    [63] = 1
} -- 13灵魂火符 14幽灵盾 15神圣战甲术 19集体隐身术  38诅咒术 44寒冰掌 85裂神符 63噬魂沼泽需要向上偏移

local dir1t8 = {
    [9] = true
}

local monsterDir = {global.MMO.ORIENT_R, global.MMO.ORIENT_RB}

local PLAYER_DIR = global.MMO.ORIENT_L
local MONSTER1_DIR = global.MMO.ORIENT_R
local MONSTER2_DIR = global.MMO.ORIENT_RB

local LAUNCH_EFFECT_GUI_ID = 1000
local FLY_LAUNCH_EFFECT_GUI_ID = 1001
local HIT_LAUNCH_EFFECT_GUI_ID = 1002

function PreviewSkillAction:ctor()
    self._select_model = global.MMO.SFANIM_TYPE_PLAYER
    self._select_action = global.MMO.ACTION_ATTACK
    self._select_id = nil
    self._config = {}
end

function PreviewSkillAction.create( param )
    local layout = PreviewSkillAction.new()
    if layout and layout:Init( param ) then
        return layout
    end 
    return nil
end

function PreviewSkillAction:Init( param )
    self._root = CreateExport( "preview_skill/previre_skill_action" )
    if not self._root then
        return false
    end
    self:addChild(self._root)

    self._ui = ui_delegate(self._root)

    local player = global.gamePlayerController:GetMainPlayer()
    if player then
        ACTIONS[1].speed = player:GetAttackStepTime() / player:GetAttackSpeed() / 0.001
        ACTIONS[2].speed = player:GetMagicStepTime() / player:GetMagicSpeed() / 0.001
    end

    self._config = param and param.config or clone(requireGameConfig("cfg_skill_present"))

    self:UpdatePlayerModelTX()
    self:UpdateMonsterModelTX()
    return true
end

--- 更新怪物模型
---@param txID1 integer 怪物1模型
---@param txID2 integer 怪物2模型
function PreviewSkillAction:UpdateMonsterModelTX(txID1, txID2)
    self._ui.Node_monster1:removeAllChildren()
    self._ui.Node_monster2:removeAllChildren()
    local monster1 = global.FrameAnimManager:CreateActorMonsterAnim(txID1 or 0, global.MMO.ANIM_IDLE)
    monster1:setName("MONSTER_ANIM1")
    monster1:Play(global.MMO.ANIM_IDLE, MONSTER1_DIR, true, 1)
    self._ui.Node_monster1:addChild(monster1)

    local monster2 = global.FrameAnimManager:CreateActorMonsterAnim(txID2 or 0, global.MMO.ANIM_IDLE)
    monster2:setName("MONSTER_ANIM2")
    monster2:Play(global.MMO.ANIM_IDLE, MONSTER1_DIR, true, 1)
    self._ui.Node_monster2:addChild(monster2)
end

--- 更新人物模型
---@param txID integer 模型ID
function PreviewSkillAction:UpdatePlayerModelTX(txID)
    self._ui.Node_player:removeAllChildren()

    local player = nil
    if self._select_model == global.MMO.SFANIM_TYPE_PLAYER then
        player = global.FrameAnimManager:CreateActorPlayerAnim(txID or 9999, global.MMO.ANIM_IDLE)
    elseif self._select_model == global.MMO.SFANIM_TYPE_MONSTER then
        player = global.FrameAnimManager:CreateActorMonsterAnim(txID or 9999, global.MMO.ANIM_IDLE)
    end

    if player then
        local speed = self:GetActionSpeed()
        player:setName("PLAYER_ANIM")
        player:Play(global.MMO.ANIM_IDLE, PLAYER_DIR, true, speed)
        self._ui.Node_player:addChild(player)
    end
end

--- 获取攻击速度
function PreviewSkillAction:GetAttrSpped()
    local delay = SL:GetMetaValue("GAME_DATA", "attack_network_delay") == 1 and global.MMO.NETWORK_DELAY or 0
    local player = global.gamePlayerController:GetMainPlayer()
    local attrStepTime = global.MMO.DEFAULT_ATTACK_TIME
    if player then
        attrStepTime = player:GetAttackStepTime()
    end
    local attrSpeed = ACTIONS[1].speed
    local speed = attrStepTime / (attrSpeed * 0.001 + delay)
    return speed
end

--- 获取施法速度
function PreviewSkillAction:GetMagicSpeed()
    local delay = SL:GetMetaValue("GAME_DATA", "attack_network_delay") == 1 and global.MMO.NETWORK_DELAY or 0
    local player = global.gamePlayerController:GetMainPlayer()
    local magicStepTime = global.MMO.DEFAULT_MAGIC_TIME
    if player then
        magicStepTime = player:GetMagicStepTime()
    end
    local magicSpeed = ACTIONS[2].speed
    local speed = magicStepTime / (magicSpeed * 0.001 + delay)
    return speed
end

--- 获取攻击/施法速度
function PreviewSkillAction:GetActionSpeed()
    local action = self._select_action or global.MMO.ACTION_ATTACK
    if action == global.MMO.ACTION_ATTACK then
        return self:GetAttrSpped()
    elseif action == global.MMO.ACTION_SKILL then
        return self:GetMagicSpeed()
    end
    return 1
end

--- 执行预览
---@param skillID integer 预览id
---@param noPlayStarAction boolean 不执行起手式动作
function PreviewSkillAction:OnPreviewSkill(cfg,noPlayStarAction)
    if not cfg then
        SL:ShowSystemTips("cfg_skill_present表未找到该技能")
        return
    end

    if not self._select_id then
        return
    end

    if cfg.id ~= self._select_id then
        return
    end

    local action = self._select_action
    if not noPlayStarAction then
        local player = self._ui.Node_player:getChildByName("PLAYER_ANIM")
        if player then
            local isFinish = false
            player:stopAllActions()
            local speed = self:GetActionSpeed(action)
            player:Stop()
            player:Play(action, PLAYER_DIR, false, speed)
            player:SetAnimEventCallback(function(sneder)
                if not isFinish then
                    isFinish = true
                    performWithDelay(sneder,function()
                        sneder:Stop()
                        sneder:Play(global.MMO.ANIM_READY, PLAYER_DIR, true, speed)
                        performWithDelay(sneder, function()
                            sneder:Stop()
                            sneder:Play(global.MMO.ACTION_IDLE, PLAYER_DIR, true, speed)
                        end, 3)
                    end,0.001)
                end
            end)
        end
    end

    local launchID, flyID, hitID = tonumber(cfg.launchID), tonumber(cfg.flyID), tonumber(cfg.hitID)
    if (launchID and launchID > 0) or (flyID and flyID > 0) or (hitID and hitID > 0) then
        self:OnLaunch(cfg)
    end
end

--- 释放特效
---@param cfg table 技能预览表数据
function PreviewSkillAction:OnLaunch(cfg)
    if not cfg then
        return
    end

    local sfxID = tonumber(cfg.launchID)
    if not sfxID or sfxID < 0 then
        self:OnFlyLaunch(cfg)
        return
    end

    local sfxNodeP = self._ui.Node_Play
    if not sfxNodeP then
        return
    end

    local sfxGUIID = LAUNCH_EFFECT_GUI_ID .. cfg.id
    local sfxNode = sfxNodeP:getChildByName(sfxGUIID)
    if sfxNode then
        GUI:stopAllActions(sfxNode)
    else
        sfxNode = GUI:Node_Create(sfxNodeP,sfxGUIID,0,0)
    end

    local delayTime = cfg.delaytime
    delayTime = tonumber(delayTime) or 0
    local speed = self:GetActionSpeed()
    local launchAction1 = GUI:DelayTime(delayTime * 0.001 / speed)
    local launchAction2 = GUI:CallFunc(function()
        local dir = (cfg.launchDir == 8 and PLAYER_DIR or 0)
        local player = self._ui.Node_player
        local pos = cc.p(GUI:getPositionX(player), GUI:getPositionY(player))
        local effect = GUI:Effect_Create(sfxNode, cfg.launchID, pos.x, pos.y, 3, sfxID, SL:GetMetaValue("SEX"),
            0, dir, speed)

        if not effect then
            if sfxNode then
                GUI:removeFromParent(sfxNode)
                sfxNode = nil
            end
            self:OnFlyLaunch(cfg)
            return
        end

        if cfg.pos ~= 0 then
            GUI:setLocalZOrder(sfxNodeP, -1)
        else
            GUI:setLocalZOrder(sfxNodeP, 1)
        end

        GUI:Effect_addOnCompleteEvent(effect, function()
            GUI:removeFromParent(effect)
            effect = nil
            if sfxNode then
                GUI:removeFromParent(sfxNode)
                sfxNode = nil
            end
            self:OnFlyLaunch(cfg)
        end)
    end)

    local sequence = GUI:ActionSequence(launchAction1, launchAction2)
    GUI:runAction(sfxNode, sequence)

    if cfg.linkSkill and cfg.linkSkill > 0 and self._config[cfg.linkSkill] then
        self:OnLaunch(self._config[cfg.linkSkill])
    end
end

--- 飞行特效
---@param cfg table 技能预览表数据
function PreviewSkillAction:OnFlyLaunch(cfg)
    if not cfg then
        return
    end

    local sfxID = tonumber(cfg.flyID)
    if not sfxID or sfxID < 0 then
        self:OnHitLaunch(cfg)
        return
    end

    local sfxNodeP = self._ui.Node_Play
    if not sfxNodeP then
        return
    end

    local sfxGUIID = FLY_LAUNCH_EFFECT_GUI_ID .. cfg.id
    local sfxNode = GUI:getChildByName(sfxNodeP,sfxGUIID)
    if sfxNode then
        GUI:stopAllActions(sfxNode)
    else
        sfxNode = GUI:Node_Create(sfxNodeP,sfxGUIID,0,0)
    end

    local delayTime = cfg.flyDelayTime
    local speed = self:GetActionSpeed()
    delayTime = tonumber(delayTime) or 0
    local magicDelayTime = self._select_action == global.MMO.ACTION_SKILL and (0.1 / speed) or 0 -- 延迟一帧的速度
    local flyLaunchAction1 = GUI:DelayTime(delayTime * 0.001 / speed + magicDelayTime)
    local flyLaunchAction2 = GUI:CallFunc(function()

        local player = self._ui.Node_player
        local target = self._select_action == global.MMO.ACTION_SKILL and
                           self._ui.Node_monster2 or
                           self._ui.Node_monster1

        local destWorldPos = GUI:getPosition(target)
        local currWorldPos = GUI:getPosition(player)
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local moveDir = inputProxy:calcMapDirection(destWorldPos, currWorldPos)
        local animDir = cfg.flyDir == 8 and 8 or 0
        local dir = (animDir == 8 and not dir1t8[sfxID]) and moveDir or 0
        local flySpeed = ((not cfg.flySpeed or cfg.flySpeed == 0) and 700.0 or cfg.flySpeed) * speed
        currWorldPos.y = currWorldPos.y + 40 - 32 * 0.5
        destWorldPos.y = destWorldPos.y + 40 - 32 * 0.5
        local pos = currWorldPos
        if effectOff[cfg.flyID] then
            pos.x = pos.x + effectOff[cfg.flyID].x
            pos.y = pos.y + effectOff[cfg.flyID].y
        end
        local effect = GUI:Effect_Create(sfxNode, cfg.flyID, pos.x, pos.y, 3, sfxID,
            SL:GetMetaValue("SEX"), 0, dir, speed)

        if not effect then
            if sfxNode then
                GUI:removeFromParent(sfxNode)
                sfxNode = nil
            end
            self:OnHitLaunch(cfg)
            return
        end

        if cfg.pos ~= 0 then
            GUI:setLocalZOrder(sfxNodeP, -1)
        else
            GUI:setLocalZOrder(sfxNodeP, 1)
        end

        if cfg.needTarget == 1 then
            destWorldPos = GUI:getPosition(target)
            destWorldPos.y = destWorldPos.y + 40 - 32 * 0.5
        end
        local destSub = cc.pSub(destWorldPos, currWorldPos)
        local flyDir = cc.pNormalize(destSub)
        local angle = cc.pGetAngle(flyDir, cc.p(0, 1))
        local rotate = (animDir == 0) and angle * 57.29577951 or 0
        GUI:setRotation(effect, rotate)

        local scheduleid = nil
        local isLaunchNext = false

        effect:scheduleUpdate(function(dt)
            local distance = flySpeed * dt
            if isLaunchNext then
                effect:unscheduleUpdate()
                GUI:setVisible(effect, false)
                performWithDelay(effect, function()
                    GUI:removeFromParent(effect)
                    effect = nil
                    if sfxNode then
                        GUI:removeFromParent(sfxNode)
                        sfxNode = nil
                    end
                end, 0.001)
                self:OnHitLaunch(cfg, target)
                return
            end

            local destSub = cc.pSub(destWorldPos, currWorldPos)
            local destDist = cc.pGetLength(destSub)
            if destDist <= distance * 3 then
                isLaunchNext = true
            else
                local offy = 0
                if cfg.id and offsetys[cfg.id] then
                    offy = 20
                end
                local displ = cc.pMul(flyDir, distance)
                local posNew = cc.pAdd(currWorldPos, displ)
                GUI:setPosition(effect, posNew.x, posNew.y + offy)
                currWorldPos = posNew
            end
        end)
    end)
    local sequence = GUI:ActionSequence(flyLaunchAction1, flyLaunchAction2)
    GUI:runAction(sfxNode, sequence)
end

--- 击中特效
---@param cfg table 技能预览表数据
---@param target userdata 怪物目标的特效节点
function PreviewSkillAction:OnHitLaunch(cfg, target)
    if not cfg then
        return
    end

    local sfxID = tonumber(cfg.hitID)
    if not sfxID or sfxID < 0 then
        local linkSkill = tonumber(cfg.linkSkill)
        if not linkSkill or linkSkill <= 0 then
            local lauchCfg = self._config[self._select_id]
            self:OnPreviewSkill(lauchCfg)
        end
        return
    end

    local sfxNodeP = self._ui.Node_Play
    if not sfxNodeP then
        return
    end

    local sfxGUIID = HIT_LAUNCH_EFFECT_GUI_ID .. cfg.id
    local sfxNode = GUI:getChildByName(sfxNodeP,sfxGUIID)
    if sfxNode then
        GUI:stopAllActions(sfxNode)
    else
        sfxNode = GUI:Node_Create(sfxNodeP,sfxGUIID,0,0)
    end

    if not target then
        target = self._select_action == global.MMO.ACTION_SKILL and
                           self._ui.Node_monster2 or
                           self._ui.Node_monster1
    end

    local delayTime = cfg.hitDelayTime
    delayTime = tonumber(delayTime) or 0
    local speed = self:GetActionSpeed()
    local hitLaunchAction1 = GUI:DelayTime(delayTime * 0.001 / speed)
    local hitLaunchAction2 = GUI:CallFunc(function()

        local player = self._ui.Node_player
        local destWorldPos = GUI:getPosition(target)
        local currWorldPos = GUI:getPosition(player)
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local moveDir = inputProxy:calcMapDirection(destWorldPos, currWorldPos)

        local dir = (cfg.hitDir == 8 and moveDir or 0)
        local pos = cc.p(GUI:getPositionX(target), GUI:getPositionY(target))
        local effect = GUI:Effect_Create(sfxNode, cfg.hitID, pos.x, pos.y, 3, sfxID,
            SL:GetMetaValue("SEX"), 0, dir, speed)

        if not effect then
            if sfxNode then
                GUI:removeFromParent(sfxNode)
                sfxNode = nil
            end
            local linkSkill = tonumber(cfg.linkSkill)
            if not linkSkill or linkSkill <= 0 then
                local lauchCfg = self._config[self._select_id]
                self:OnPreviewSkill(lauchCfg)
            end
            return
        end

        if cfg.hitPos ~= 0 then
            GUI:setLocalZOrder(sfxNodeP, -1)
        else
            GUI:setLocalZOrder(sfxNodeP, 1)
        end

        GUI:Effect_addOnCompleteEvent(effect, function()
            GUI:removeFromParent(effect)
            effect = nil
            if sfxNode then
                GUI:removeFromParent(sfxNode)
                sfxNode = nil
            end
            local linkSkill = tonumber(cfg.linkSkill)
            if not linkSkill or linkSkill <= 0 then
                local lauchCfg = self._config[self._select_id]
                self:OnPreviewSkill(lauchCfg)
            end
        end)
    end)
    local sequence = GUI:ActionSequence(hitLaunchAction1, hitLaunchAction2)
    GUI:runAction(sfxNode, sequence)
end

function PreviewSkillAction:OnRefresh(param)
    if not param or not next(param) then
        return
    end

    if param.action then
        self._select_action = param.action
    end

    if param.model then
        self._select_model = param.model
    end

    if param.playerid then --刷新playerid
        self:UpdatePlayerModelTX(param.playerid)
    end

    if param.monsterid1 or param.monsterid2 then  --刷新monster
        self:UpdateMonsterModelTX(param.monsterid1,param.monsterid2)
    end

    if param.attrSpeed then
        ACTIONS[1].speed = param.attrSpeed
    end

    if param.magicSpeed then
        ACTIONS[2].speed = param.magicSpeed
    end

    if param.cfg then
        self._select_id = param.cfg.id
        self:OnPreviewSkill( param.cfg,param.noPlayStarAction )
    end
end

return PreviewSkillAction