local RefreshActorHUDLabelCommand = class('RefreshActorHUDLabelCommand', framework.SimpleCommand)

local MMO                       = global.MMO
local sLen                      = string.len
local proxyUtils                = requireProxy( "proxyUtils" )
local optionsUtils              = requireProxy( "optionsUtils" )
local checkPlayerGuildName      = proxyUtils.checkPlayerGuildName

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
local heightMob                 = (SL:GetMetaValue("GAME_DATA","sceneFontSize") or SL:GetMetaValue("GAME_DATA","SCENE_FONT_SIZE")) + 2
local heightWin                 = (SL:GetMetaValue("GAME_DATA","sceneFontSize_pc") or SL:GetMetaValue("GAME_DATA","SCENE_FONT_SIZE_PC")) + 2
local height                    = global.isWinPlayMode and heightWin or heightMob

local LABEL_HUD_HEIGHT = 
{
    [MMO.HUD_LABEL_NAME]       = height,
    [MMO.HUD_LABEL_GUILD]      = height,
    [MMO.HUD_LABEL_HP]         = 18,
    [MMO.HUD_LABEL_PRE_NAME1]  = height,
    [MMO.HUD_LABEL_PRE_NAME2]  = height,
    [MMO.HUD_LABEL_PRE_NAME3]  = height,
    [MMO.HUD_LABEL_PRE_NAME4]  = height,
    [MMO.HUD_LABEL_PRE_NAME5]  = height,
    [MMO.HUD_LABEL_PRE_NAME6]  = height,
    [MMO.HUD_LABEL_PRE_NAME7]  = height,
    [MMO.HUD_LABEL_PRE_NAME8]  = height,
    [MMO.HUD_LABEL_PRE_NAME9]  = height,
    [MMO.HUD_LABEL_PRE_NAME10] = height,
    [MMO.HUD_LABEL_PRE_NAME11] = height,
    [MMO.HUD_LABEL_PRE_NAME12] = height,
}

function RefreshActorHUDLabelCommand:ctor()
    self._downOffY = 0

    if global.isWinPlayMode then
        self._downOffY = self._downOffY + 5
    elseif SL:GetMetaValue("GAME_DATA", "MobileHudNotUseBmpFont") == 1 then
        self._downOffY = self._downOffY + 5
    end
end

function RefreshActorHUDLabelCommand:execute(notification)
    local data = notification:getBody()
    if not data.actor or not data.hudParam then
        return nil
    end
    local actor = global.actorManager:GetActor(data.actorID)
    if not actor then
        return nil
    end

    local hudParam     = data.hudParam
    local nameColor    = hudParam and hudParam.nameColor
    if nameColor then   --只更新名字颜色
        self:refreshLableNameColor(actor,nameColor)
        return
    end

    local actorID       = actor:GetID()
    local actorType     = actor:GetType()
    local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()

    -- 行会战、安全区内
    local oldColor = nil
    if actor:IsPlayer() or actor:IsMonster() then
        if hudParam.Color and actor:IsWarZone() and actor:GetInSafeZone() then
            oldColor = hudParam.Color
            hudParam.Color = 255
        end
    end

    -- 解开称号字符 分为称号列表和玩家名字
    -- 展示顺序 1.前缀文本 2.行会信息 3.角色名
    local spName = actor:GetONameStr()
    local nameStr = string.split(spName, "\\")
    local showName = nameStr[1]
    table.remove(nameStr, 1)
    table.removebyvalue(nameStr, "", true)

    if actor:IsNPC() then 
        if actor:GetBubbleName() then
            showName = ""
        end
    end

    -- check visible
    local labelNameVisible = actor:GetValueByKey(MMO.HUD_NAMELabel_VISIBLE) or actor:GetValueByKey(MMO.HUD_PC_MOUSE_SHOW)
    local labelGuildVisible = actor:GetValueByKey(MMO.HUD_GUILDLabel_VISIBLE) or actor:GetValueByKey(MMO.HUD_PC_MOUSE_SHOW)
    local labelTitleVisible = actor:GetValueByKey(MMO.HUD_TITLELabel_VISIBLE) or actor:GetValueByKey(MMO.HUD_PC_MOUSE_SHOW)

    -- 封号
    for index=1,12 do
        self:refreshLabelTitle(actor, hudParam, labelTitleVisible, nameStr[index], index)
    end
    
    -- guild name
    self:refreshLabelGuild( actor, hudParam, labelGuildVisible )
    
    -- name
    self:refreshLabelName( actor, hudParam, labelNameVisible, showName)
    optionsUtils:refreshLabelName( actor )

    -- refresh actor position
    local pos = actor:getPosition()
    actor:setPosition( pos.x, pos.y )

    -- record player hud param
    if actorType == MMO.ACTOR_PLAYER then
        SetActorAttr( actor, MMO.ACTOR_ATTR_HUDPARAM, hudParam )
    end

    if oldColor then
        hudParam.Color = oldColor
    end
end

function RefreshActorHUDLabelCommand:operateLabelHUD( actorID, hudType, hudIndex, content, color, visible, offsetY, offsetX )
    local hudLabel = nil
    offsetX = offsetX or 0

    if not content or "" == content then -- remove
        global.HUDManager:RemoveHUD( actorID, hudType, hudIndex )
    else
        hudLabel = global.HUDManager:GetHUD( actorID, hudType, hudIndex )
        if not hudLabel then -- create
            hudLabel = global.HUDManager:CreateHUD( actorID, hudType, hudIndex, cc.p(offsetX, offsetY) )
            hudLabel:setAlignment( cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM )
        end

        global.HUDManager:SetHUDOffset(actorID, hudType, hudIndex,  cc.p(offsetX, offsetY) )
        hudLabel:setVisible( visible )
        hudLabel:setString( content )
        hudLabel:setColor( color )
    end
    
    return hudLabel
end

function RefreshActorHUDLabelCommand:refreshLabelName( actor, hudParam, visible, showName)
    local actorID = actor:GetID()
    local hudType = MMO.HUD_TYPE_BATCH_LABEL

    local color = nil
    if actor:IsDropItem() then
        color = GetColorFromHex( hudParam.Color or MMO.HUD_COLOR_DEFAULT )
        hudType = MMO.HUD_TYPE_BATCH_LABEL
    else
        color = GET_COLOR_BYID_C3B( hudParam.Color or MMO.HUD_COLOR_DEFAULT )
    end

    local offX = 2
    local hudLabel = self:operateLabelHUD( actorID, hudType, MMO.HUD_LABEL_NAME, showName, color, visible, self._downOffY, offX )

    -- record off y
    if visible and showName then
        self._downOffY = self._downOffY - LABEL_HUD_HEIGHT[MMO.HUD_LABEL_NAME]
    end
end

function RefreshActorHUDLabelCommand:refreshLabelTitle( actor, hudParam, visible, titleStr, index)
    local actorID = actor:GetID()
    local hudType = MMO.HUD_TYPE_BATCH_LABEL
    local hudIndex = MMO.HUD_LABEL_PRE_NAME1 - 1 + index

    if not LABEL_HUD_HEIGHT[hudIndex] then
        return
    end

    local offX = 2
    local color = GET_COLOR_BYID_C3B( hudParam.Color or MMO.HUD_COLOR_DEFAULT )
    local hudLabel = self:operateLabelHUD( actorID, hudType, hudIndex, titleStr, color, visible, self._downOffY, offX )

    -- record off y
    if visible and titleStr and sLen(titleStr) > 0 then
        self._downOffY = self._downOffY - LABEL_HUD_HEIGHT[hudIndex]
    end
end

function RefreshActorHUDLabelCommand:refreshLabelGuild( actor, hudParam, visible )
    local actorID = actor:GetID()
    local hudType = MMO.HUD_TYPE_BATCH_LABEL
    local guildName = hudParam.GuildName

    -- guild name
    if guildName and actor:IsPlayer() then
        guildName = checkPlayerGuildName(guildName, hudParam.RankName, hudParam.castlename)
    end

    local color = GET_COLOR_BYID_C3B(  hudParam.Color or MMO.HUD_COLOR_DEFAULT )
    self:operateLabelHUD( actorID, hudType, MMO.HUD_LABEL_GUILD, guildName, color, visible, self._downOffY )

    -- record off y
    if visible and guildName and sLen(guildName)>0 then
        self._downOffY = self._downOffY - LABEL_HUD_HEIGHT[MMO.HUD_LABEL_GUILD]
    end
end

-- 刷新label颜色
function RefreshActorHUDLabelCommand:refreshLableNameColor(actor, nameColor)
    local actorID = actor:GetID()
    local hudType = MMO.HUD_TYPE_BATCH_LABEL
    local color = nil
    if actor:IsDropItem() then
        color = GetColorFromHex( nameColor or MMO.HUD_COLOR_DEFAULT )
        hudType = MMO.HUD_TYPE_BATCH_LABEL
    else
        color = GET_COLOR_BYID_C3B( nameColor or MMO.HUD_COLOR_DEFAULT )
    end

    -- 角色名
    local nameHudLabel = global.HUDManager:GetHUD( actorID, hudType, MMO.HUD_LABEL_NAME )
    if nameHudLabel then
        nameHudLabel:setColor(color)
    end
    
    -- 行会名
    local guildHudLabel = global.HUDManager:GetHUD( actorID, hudType, MMO.HUD_LABEL_GUILD )
    if guildHudLabel then
        guildHudLabel:setColor(color)
    end
    
    -- 封号
    for index=1,12 do
        local hudIndex = MMO.HUD_LABEL_PRE_NAME1 - 1 + index
        local titleHudLabel = global.HUDManager:GetHUD( actorID, hudType, hudIndex )
        if titleHudLabel then
            titleHudLabel:setColor(color)
        end
    end
end

return RefreshActorHUDLabelCommand
