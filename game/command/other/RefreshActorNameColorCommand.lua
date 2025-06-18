local RefreshActorNameColorCommand = class('RefreshActorNameColorCommand', framework.SimpleCommand)

local actorUtils                 = requireProxy( "actorUtils" )

function RefreshActorNameColorCommand:ctor()
end

function RefreshActorNameColorCommand:execute(notification)
    local data = notification:getBody()
    if not data then
        return false
    end

    local actorID = data.actorID
    if not actorID then
        return false
    end

    local actor = global.actorManager:GetActor(data.actorID)
    if not actor then
        return false
    end

    -- 只更新 player  haveMoaster
    if actor:IsMonster() and not actor:IsHaveMaster() then
        return false
    end

    if not actor:IsMonster() and not actor:IsPlayer() then
        return
    end

    if self:CheckShaBaKeZoneColor(actor) then
        return true
    end

    if self:CheckActorColor(actor) then
        return true
    end

    if self:CheckGuildWarColor(actor) then
        return true
    end

    self:RefreshLableNameColor(actor, actor:GetNameColor())
    return true
end

--- 检测攻杀区域颜色
---@param actor userdata actor
function RefreshActorNameColorCommand:CheckShaBaKeZoneColor(actor)
    if actor:IsWarZone() then
        return false
    end

    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if not MapProxy:IsShaBaKeOpen() then
        return false
    end

    if not MapProxy:IsCheckShaBaKeZone() then
        return false
    end

    if not MapProxy:CheckShaBeKeZone(actor:GetMapX(), actor:GetMapY()) then
        return false
    end

    local function GetMasterGuild(actor)
        if actor:IsHaveMaster() then
            local masterActor = global.actorManager:GetActor(actor:GetMasterID())
            if masterActor then
                return GetMasterGuild(masterActor)
            end
        end
        return actor:GetGuildID()
    end

    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    local color = GuildProxy:GetShaBaKeZoneNameColor(GetMasterGuild(actor))
    if not color then
        return false
    end

    self:RefreshLableNameColor(actor, color)
    return true
end

--- 检测自身颜色
---@param actor userdata actor
function RefreshActorNameColorCommand:CheckActorColor(actor)
    -- 红名不刷新，  使用服务器下发的
    if actor:GetPKLv() == 2 then
        self:RefreshLableNameColor(actor, actor:GetNameColor())
        return true
    end

    -- 安全区内不刷新，使用服务器下发的
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    local inSafeZone = mainPlayer:GetInSafeZone() or actor:GetInSafeZone()
    local MapProxy   = global.Facade:retrieveProxy(global.ProxyTable.Map)

    if actor:IsWarZone() or inSafeZone or MapProxy:IsInSafeArea() then
        if actor:IsPlayer() and actor:GetReLevel() > 0 and actorUtils:actorIsReLvChange() then
            return true
        end
        self:RefreshLableNameColor(actor, actor:GetNameColor())
        return true
    end

    return false
end

--- 检测行会战颜色
---@param actor userdata actor
function RefreshActorNameColorCommand:CheckGuildWarColor(actor)
    if actor:IsWarZone() then
        return false
    end
    
    local function GetMasterGuild(actor)
        if actor:IsHaveMaster() then
            local masterActor = global.actorManager:GetActor(actor:GetMasterID())
            if masterActor then
                return GetMasterGuild(masterActor)
            end
        end
        return actor:GetGuildID()
    end

    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    local color = GuildProxy:GetGuildWarNameColor(GetMasterGuild(actor))
    if not color then
        return false
    end

    self:RefreshLableNameColor(actor, color)
    return true
end

--- 刷新label颜色
---@param actor userdata actor
---@param nameColor integer 颜色ID
function RefreshActorNameColorCommand:RefreshLableNameColor(actor, nameColor)
    local actorID = actor:GetID()
    local hudType = global.MMO.HUD_TYPE_BATCH_LABEL
    local color = GET_COLOR_BYID_C3B(nameColor or global.MMO.HUD_COLOR_DEFAULT)

    -- 角色名
    local nameHudLabel = global.HUDManager:GetHUD(actorID, hudType, global.MMO.HUD_LABEL_NAME)
    if nameHudLabel then
        nameHudLabel:setColor(color)
    end

    -- 行会名
    local guildHudLabel = global.HUDManager:GetHUD(actorID, hudType, global.MMO.HUD_LABEL_GUILD)
    if guildHudLabel then
        guildHudLabel:setColor(color)
    end

    -- 封号
    for index = 1, 12 do
        local hudIndex = global.MMO.HUD_LABEL_PRE_NAME1 - 1 + index
        local titleHudLabel = global.HUDManager:GetHUD(actorID, hudType, hudIndex)
        if titleHudLabel then
            titleHudLabel:setColor(color)
        end
    end

    if actor:IsPlayer() and actor:IsMainPlayer() then
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        PlayerProperty:SetMainPlayerNameColor(nameColor or global.MMO.HUD_COLOR_DEFAULT)
        SL:onLUAEvent(LUA_EVENT_PLAYER_GUILD_INFO_CHANGE)
    end
end

return RefreshActorNameColorCommand
