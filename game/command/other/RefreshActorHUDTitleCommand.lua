local RefreshActorHUDTitleCommand = class('RefreshActorHUDTitleCommand', framework.SimpleCommand)

local sLen   = string.len

local MMO    = global.MMO
local IsPC   = global.isWinPlayMode
local IsAuto = tonumber(SL:GetMetaValue("GAME_DATA", "auto_set_topHat_posY")) == 1

local GetTag = function (type)
    return (({
        [MMO.ACTOR_MONSTER] = MMO.ACTOR_MONSTER, [MMO.ACTOR_NPC] = MMO.ACTOR_NPC
    })[type] or (function ()
        return MMO.ACTOR_NONE
    end)())    
end

local GetAnr1 = function (anim, sfxID)
    local sfx = anim:getChildByTag(sfxID)
    return sfx and sfx:GetStandPoint() or {x = 0, y = 0}
end

local GetAnr2 = function (sfxID)
    local modelProxy = global.Facade:retrieveProxy( global.ProxyTable.ModelConfigProxy )
    local config = modelProxy:GetConfig(GetFrameAnimConfigID(sfxID, 0, 4))
    return config and {x = config.stand_pos_x or 0.5, y = config.stand_pos_y or 0.5} or {x = 0.5, y = 0.5}
end


-- 以下三个局部变量改变的时候
-- 解决封号显示隐藏后现有机制下动态改变上部称号问题
--[[
    整体结构：
        图片称号
        封号
        血量文本
        血条
        ------------ 分割
        前缀文本
        行会信息
        角色名
    
    血量血条固定 封号称号在上
    下部为分割线为起点 向下排
]]
local DEFAUTL_HEIGHT = 25

local SPRITE_HUD_OFFX = {
    [MMO.HUD_SPRITE_TITLE_1] = -40,
    [MMO.HUD_SPRITE_TITLE_2] = -40,
    [MMO.HUD_SPRITE_TITLE_3] = -40
}

local animHUDTable = {
    [0]  = MMO.HUD_NODE_TITLE_1,
    [1]  = MMO.HUD_NODE_TITLE_2,
    [2]  = MMO.HUD_NODE_TITLE_3,
    [3]  = MMO.HUD_NODE_TITLE_4,
    [4]  = MMO.HUD_NODE_TITLE_5,
    [5]  = MMO.HUD_NODE_TITLE_6,
    [6]  = MMO.HUD_NODE_TITLE_7,
    [7]  = MMO.HUD_NODE_TITLE_8,
    [8]  = MMO.HUD_NODE_TITLE_9,
    [9]  = MMO.HUD_NODE_TITLE_10,
    [10] = MMO.HUD_NODE_TITLE_11
}

local spriteHUDTable = {
    [0]  = MMO.HUD_SPRITE_ICON_1,
    [1]  = MMO.HUD_SPRITE_ICON_2,
    [2]  = MMO.HUD_SPRITE_ICON_3,
    [3]  = MMO.HUD_SPRITE_ICON_4,
    [4]  = MMO.HUD_SPRITE_ICON_5,
    [5]  = MMO.HUD_SPRITE_ICON_6,
    [6]  = MMO.HUD_SPRITE_ICON_7,
    [7]  = MMO.HUD_SPRITE_ICON_8,
    [8]  = MMO.HUD_SPRITE_ICON_9,
    [9]  = MMO.HUD_SPRITE_ICON_10,
    [10] = MMO.HUD_SPRITE_ICON_11
}

function RefreshActorHUDTitleCommand:ctor()
    self._upOffY = 78
    self._titleH = 0
end

function RefreshActorHUDTitleCommand:execute(notification)
    local data = notification:getBody()
    if not data.actorID then
        return false
    end
    local actor = global.actorManager:GetActor(data.actorID)
    if not actor then
        return false
    end

    local actorID = actor:GetID()

    -- check visible
    local visible = actor:GetValueByKey(MMO.HUD_TITLE_VISIBLE)

    -- 称号-文本、图片
    local titles = GetActorAttrByID(actorID, MMO.ACTOR_ATTR_HUDTITLE)
    if titles then
        self:loadTitles(actor, titles, visible)
    end

    -- 顶戴花翎 - 特效、图片
    local icons = GetActorAttrByID(actorID, MMO.ACTOR_ATTR_HUDICONS)
    if icons then
        self:loadTopHat(actor, icons, visible)
    end

    -- refresh actor position
    local pos = actor:getPosition()
    actor:setPosition(pos.x, pos.y)
end

-- 称号
function RefreshActorHUDTitleCommand:loadTitles(actor, titles, visible)
    local offsetY = 0
    
    local t1 = self:refreshTitleImage(actor, MMO.HUD_SPRITE_TITLE_1, titles.t1, visible)
    local l1 = self:refreshTitleLabel(actor, MMO.HUD_LABEL_TITLE_1,  titles.t1, visible)
    offsetY = (t1 or l1) and offsetY + DEFAUTL_HEIGHT or offsetY

    local t2 = self:refreshTitleImage(actor, MMO.HUD_SPRITE_TITLE_2, titles.t2, visible)
    local l2 = self:refreshTitleLabel(actor, MMO.HUD_LABEL_TITLE_2,  titles.t2, visible)
    offsetY = (t2 or l2) and offsetY + DEFAUTL_HEIGHT or offsetY

    local t3 = self:refreshTitleImage(actor, MMO.HUD_SPRITE_TITLE_3, titles.t3, visible)
    local l3 = self:refreshTitleLabel(actor, MMO.HUD_LABEL_TITLE_3,  titles.t3, visible)
    offsetY = (t3 or l3) and offsetY + DEFAUTL_HEIGHT or offsetY

    self._titleH = self._titleH + offsetY
end

-- 顶戴
function RefreshActorHUDTitleCommand:loadTopHat(actor, icons, visible)
    if IsAuto then
        self._upOffY = self._upOffY + self._titleH
    end

    local lastY = 0 -- 顶戴的最后一个高度
    for i = 0, 10 do
        local params = icons[i + 1]

        if params and params.iY then
            params.Y = self._upOffY - params.iY
        end

        -- 记录是否是996盒子专属顶戴
        if params and params.iId == 10 then
            if lastY ~= 0 then
                params.Y = lastY
            end
            if not IsAuto then
                params.Y = math.max(self._titleH + self._upOffY, params.Y)
            end
            params.isBox996 = true
            local Box996Proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
            local visible = Box996Proxy:isShowTitleByActor(actor)
            self:refreshTopHat(actor, i, params, visible)
        else
            local titleH, anr = self:refreshTopHat(actor, i, params, visible)
            if params and params.after ~= 1 then
                local Y  = params.Y or 0
                local aY = anr and anr.y or 0
                lastY = math.max(lastY, math.ceil(Y + titleH * aY))
            end
        end 
    end
end

-- 称号图标
function RefreshActorHUDTitleCommand:refreshTitleImage(actor, hudIndex, titleID, visible)
    local actorID = actor:GetID()

    local imagePath = ""
    if titleID and titleID > 0 then
        local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
        imagePath = PlayerTitleProxy:getSceneTitleImage(titleID)
    end
    
    if sLen(imagePath) < 1 then
        global.HUDManager:RemoveHUD(actorID, MMO.HUD_TYPE_SPRITE, hudIndex)
        return false
    end

    -- reserved: 0 图标显示在左边; 1 图标显示在中间; 2不显示图标
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local reserved = ItemConfigProxy:GetItemReservedByIndex(titleID)
    if reserved == 2 then
        global.HUDManager:RemoveHUD(actorID, MMO.HUD_TYPE_SPRITE, hudIndex)
        return false 
    end

    local oY = IsPC and 0 or 5

    local offsetX = reserved == 1 and 0 or (SPRITE_HUD_OFFX[hudIndex] or 0)
    local offsetY = self._upOffY + oY
    local p = cc.p(offsetX, offsetY)

    local sprite = global.HUDManager:GetHUD(actorID, MMO.HUD_TYPE_SPRITE, hudIndex)
    if not sprite then
        sprite = global.HUDManager:CreateHUD(actorID, MMO.HUD_TYPE_SPRITE, hudIndex, p)
        sprite:setAnchorPoint(0.5, 0.5)
    end
    global.HUDManager:SetHUDOffset(actorID, MMO.HUD_TYPE_SPRITE, hudIndex, p)
    sprite:setTexture(imagePath)
    sprite:setTag(GetTag(actor:GetType()))

    sprite:setVisible(visible)

    return visible
end

-- 称号文本
function RefreshActorHUDTitleCommand:refreshTitleLabel(actor, hudIndex, titleID, visible)
    local actorID  = actor:GetID()
    local hudType  = MMO.HUD_TYPE_BATCH_LABEL

    local color    = MMO.HUD_COLOR_DEFAULT
    local itemName = ""
    local reserved = 0
    if titleID then
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        color    = ItemConfigProxy:GetItemNameColorId(titleID)
        itemName = ItemConfigProxy:GetItemNameByIndex(titleID)
        reserved = ItemConfigProxy:GetItemReservedByIndex(titleID)
    end

    -- reserved: 0 显示称号名字; 否则不显示称号名字
    if reserved > 0 or sLen(itemName) < 1 then
        global.HUDManager:RemoveHUD(actorID, hudType, hudIndex)
        return false
    end

    local p = cc.p(0, self._upOffY)

    local hudLabel = global.HUDManager:GetHUD(actorID, hudType, hudIndex) 
    if not hudLabel then
        hudLabel = global.HUDManager:CreateHUD(actorID, hudType, hudIndex, p)
        hudLabel:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
    end

    global.HUDManager:SetHUDOffset(actorID, hudType, hudIndex, p)
    hudLabel:setString(itemName)
    hudLabel:setColor(GET_COLOR_BYID_C3B(color))

    hudLabel:setVisible(visible)

    return visible
end

function RefreshActorHUDTitleCommand:refreshTopHat(actor, idx, params, visible)
    params          = params or {}               
    local efftype   = params.iEff or 0           -- 0：图片; 1：特效
    local effSrc    = params.sEffSrc or ""       -- 图片名字或者特效ID
    local x         = params.iX or 0             -- X
    local y         = params.Y or 0              -- Y
    local isBox996  = params.isBox996 or false   -- 是否是盒子顶戴
    local isBehide  = params.after == 1          -- after：1 在后面播放; 否则在前面

    if isBehide then
        y = y - MMO.PLAYER_AVATAR_OFFSET.y
    end

    local actorID = actor:GetID()

    local hudSpriteIndex = spriteHUDTable[idx]
    local hudAnimIndex   = animHUDTable[idx]

    -- 顶戴的高度(图片读取真实高度, 特效读取默认高度DEFAUTL_HEIGHT)
    local p = cc.p(x, y)


    if efftype > 0 then
        -- 先移除旧的图片
        global.HUDManager:RemoveHUD(actorID, MMO.HUD_TYPE_SPRITE, hudSpriteIndex)

        local animID = tonumber(effSrc) or -1
        if animID < 0 then
            global.HUDManager:RemoveHUD(actorID, MMO.HUD_TYPE_ANIM, hudAnimIndex)
            return 0
        end

        local hudTitleH = DEFAUTL_HEIGHT
        local hudAnimName = "HUD_ANIM_" .. animID


        local hudAnim = global.HUDManager:GetHUD(actorID, MMO.HUD_TYPE_ANIM, hudAnimIndex, isBehide)
        if hudAnim and hudAnimName == hudAnim:getName() then
            global.HUDManager:SetHUDOffset(actorID, MMO.HUD_TYPE_ANIM, hudAnimIndex, p)
            return hudTitleH, GetAnr1(hudAnim, animID)
        end

        -- 移除旧的
        if hudAnim then
            global.HUDManager:RemoveHUD(actorID, MMO.HUD_TYPE_ANIM, hudAnimIndex)
        end

        -- 添加新的
        hudAnim = global.HUDManager:CreateHUD(actorID, MMO.HUD_TYPE_ANIM, hudAnimIndex, p, animID, isBehide)
        hudAnim:setName(hudAnimName)
        global.HUDManager:SetHUDOffset(actorID, MMO.HUD_TYPE_ANIM, hudAnimIndex, p)

        hudAnim.isBox996 = isBox996

        hudAnim:setTag(GetTag(actor:GetType()))

        hudAnim:setVisible(visible)
        return hudTitleH, GetAnr2(animID)
    else
        -- 先移除旧的特效
        global.HUDManager:RemoveHUD(actorID, MMO.HUD_TYPE_ANIM, hudAnimIndex)

        local picPath = effSrc
        if sLen(picPath) < 1 or tonumber(picPath) == -1 then
            global.HUDManager:RemoveHUD(actorID, MMO.HUD_TYPE_SPRITE, hudSpriteIndex)
            return 0
        end

        local hudSprite = global.HUDManager:GetHUD(actorID, MMO.HUD_TYPE_SPRITE, hudSpriteIndex, isBehide)
        if not hudSprite then
            hudSprite = global.HUDManager:CreateHUD(actorID, MMO.HUD_TYPE_SPRITE, hudSpriteIndex, p, 0, isBehide)
            hudSprite:setAnchorPoint({x = 0.5, y = 0.5})
        else
            global.HUDManager:SetHUDOffset(actorID, MMO.HUD_TYPE_SPRITE, hudSpriteIndex, p)
        end

        local filePath = string.format("res/Topwear/%s.png", picPath)
        hudSprite:setTexture(filePath)
        hudSprite.isBox996 = isBox996

        hudSprite:setTag(GetTag(actor:GetType()))

        hudSprite:setVisible(visible)

        return hudSprite:getContentSize().height, {x = 0.5, y = 0.5}
    end

    return 0
end

return RefreshActorHUDTitleCommand
