local RefreshActorHUDHPLabelCommand = class('RefreshActorHUDHPLabelCommand', framework.SimpleCommand)
local optionsUtils = requireProxy("optionsUtils")

local MMO          = global.MMO

local HudType      = MMO.HUD_TYPE_BATCH_LABEL
local HudIndex     = MMO.HUD_LABEL_HP


local sformat      = string.format
local hPos         = global.isWinPlayMode and cc.p(2, 62) or (SL:GetMetaValue("GAME_DATA", "MobileHudNotUseBmpFont") == 1 and cc.p(2, 62) or cc.p(2, 55) )

local GetJobMask = function (job)
    local jobStr = {
        [0] = "Z",
        [1] = "F",
        [2] = "D"
    }
    -- 多职业未配置默认X
    if job >= 5 and job <= 15 then
        local jobData   = SL:GetMetaValue("GAME_DATA", "MultipleJobSetMap")[job]
        local isOpen    = jobData and jobData.isOpen
        local str       = isOpen and jobData.hudStr or "X"
        return str
    end
    return jobStr[job] or "Z"
end

-- 是否显示怪物等级
local IsShowMonsterLv = SL:GetMetaValue("GAME_DATA", "Monsterlevel") == 1

function RefreshActorHUDHPLabelCommand:ctor()
    
end

function RefreshActorHUDHPLabelCommand:execute(notification)
    local actor = notification:getBody()
    if not actor then
        return false
    end

    local visible = actor:GetValueByKey(MMO.HUD_HMPLabel_VISIBLE)
    local label   = self:GetLabel(actor, visible)
    self:refreshContent(actor, label)
    
    -- refresh actor position
    local pos = actor:getPosition()
    actor:setPosition(pos.x, pos.y)
end

function RefreshActorHUDHPLabelCommand:GetLabel(actor, visible)
    local actorID = actor:GetID()

    local label = global.HUDManager:GetHUD(actorID, HudType, HudIndex)
    if not visible and label then
        global.HUDManager:RemoveHUD(actorID, HudType, HudIndex)
        return false
    end

    if not label then
        label = global.HUDManager:CreateHUD(actorID, HudType, HudIndex, hPos)
        label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
    end
    label:setVisible(visible)

    return label
end

function RefreshActorHUDHPLabelCommand:refreshContent(actor, label)
    if not label then
        return false
    end

    local Hp = actor:GetHP()
    if not Hp then
        return false
    end

    local MaxHp = actor:GetMaxHP()
    if not MaxHp then
        return false
    end

    local MP = 0
    local maxMP = 0
    if actor:GetValueByKey(MMO.HUD_MPBAR_VISIBLE) then
        MP = actor:GetMP() or 0
        maxMP = actor:GetMaxMP() or 0
    end

    -- 浑水摸鱼 显示百分比
    local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if mapProxy:IsHPPercent() then
        Hp    = math.ceil( ((Hp+MP) / (MaxHp+maxMP)) * 100 )
        MP    = 0
        MaxHp = 100
    end

    local formatStr = GET_STRING(1053)

    if mapProxy:IsForbidLvJob() or CHECK_SETTING(MMO.SETTING_IDX_PLAYER_JOB_LEVEL) ~= 1 then
        local hpStr = sformat(formatStr, SL:HPUnit(Hp + MP), SL:HPUnit(MaxHp))
        return label:setString(hpStr)
    end

    local levelJob = nil
    if actor:IsPlayer() then
        levelJob = GetJobMask(actor:GetJobID()) .. actor:GetLevel() or ""
    elseif actor:IsMonster()then
        if IsShowMonsterLv then
            levelJob = "J" .. actor:GetLevel() or ""
        end
    end

    -- 只显示职业等级
    if GET_SETTING(MMO.SETTING_IDX_PLAYER_JOB_LEVEL) == 1 then
        return label:setString(levelJob)
    end

    local hpStr = sformat(formatStr, SL:HPUnit(Hp + MP), SL:HPUnit(MaxHp))
    if levelJob then
        hpStr = sformat(formatStr, hpStr, levelJob)
    end
    label:setString(hpStr)
end

return RefreshActorHUDHPLabelCommand