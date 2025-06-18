local ActorInOfViewCommand = class('ActorInOfViewCommand', framework.SimpleCommand)

local optionsUtils = requireProxy("optionsUtils")

function ActorInOfViewCommand:ctor()
end

function ActorInOfViewCommand:execute(notification)
    local data = notification:getBody()
    local actor = data.actor
    if not actor then
        return
    end

    local actorID = actor:GetID()
    local hudParam = data.hudParam

    -- hud
    self:setActorHUD(actor, actorID, hudParam)

    if actor:IsMonster() then
        self:onMonsterInOfView(actor, actorID, hudParam)
        global.actorInViewController:AddActor(actor)

        optionsUtils:InitHUDVisibleValue(actor, global.MMO.MONSTER_NORMAL)
        optionsUtils:InitHUDVisibleValue(actor, global.MMO.MONSTER_CLEAR)
    elseif actor:IsPlayer() then
        self:onPlayerInOfView(actor, actorID, hudParam)
        global.actorInViewController:AddActor(actor)

        if actor:IsHumanoid() then
            optionsUtils:InitHUDVisibleValue(actor, global.MMO.MONSTER_NORMAL)
            optionsUtils:InitHUDVisibleValue(actor, global.MMO.MONSTER_CLEAR)
        end

    elseif actor:IsNPC() then
        self:onNPCInOfView(actor, actorID, hudParam)
    end
end

function ActorInOfViewCommand:setActorHUD(actor, actorID, hudParam)
    SetActorName(actor, hudParam)
    SetActorAttrByID(actorID, global.MMO.ACTOR_ATTR_HUDICONS, hudParam.icons)
    SetActorAttrByID(actorID, global.MMO.ACTOR_ATTR_HUDTITLE, hudParam.title)
    global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actorID, hudParam = hudParam })
    global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDTitle, { actor = actor, actorID = actorID, hudParam = hudParam })
end

function ActorInOfViewCommand:onPlayerInOfView(actor, actorID, jsonData)
    -- 外观
    SetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE, jsonData)
    jsonData.actor = actor
    jsonData.actorID = jsonData.UserID
    global.Facade:sendNotification(global.NoticeTable.DelayActorFeatureChange, jsonData)

    -- 摆摊
    -- 摆摊状态 (0, 1)
    actor:SetSellStatus((jsonData.stallname and jsonData.stallname ~= "") and 1 or 0)
    actor:SetStallName(jsonData.stallname)
    if actorID == global.gamePlayerController:GetMainPlayerID() then
        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        StallProxy:SetMyTradingStatus(actor:IsStallStatus())
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_StatusChange, { status = actor:IsStallStatus(), userid = actorID })
    global.Facade:sendNotification(global.NoticeTable.PlayerStallStatucChange, { actorID = actorID, actor = actor })
    global.Facade:sendNotification(global.NoticeTable.RefreshActorBooth, { actorID = actorID, actor = actor })
end

function ActorInOfViewCommand:onMonsterInOfView(actor, actorID, jsonData)
    -- 进视野提醒
    local value     = CHECK_SETTING(global.MMO.SETTING_IDX_BOSS_TIPS)--总开关
    local enable    = value == 1
    local name      = actor:GetName()
    local tipsData  = CHECK_SETTING_BOSSTIPS(name)
    if enable and tipsData and tipsData[2] == 1 and not actor:IsDie() and not actor:IsDeath() then
        local mapX          = actor:GetMapX()
        local mapY          = actor:GetMapY()
        local MonsterType   = tipsData[3] or ""
        local MapProxy      = global.Facade:retrieveProxy(global.ProxyTable.Map)
        local mapID         = MapProxy:GetMapID()
        local inputProxy    = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local mainPlayer    = global.gamePlayerController:GetMainPlayer()
        local dir           = mainPlayer and inputProxy:calcMapDirection(cc.p(mapX, mapY), cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())) or 3
        local str           = string.format(GET_STRING(30103100), mapID, mapX, mapY, MonsterType, name, GET_STRING(30103101 + dir), mapX, mapY)
        local ChatProxy     = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        local mdata = {
            Msg             = str,
            FColor          = 249,
            BColor          = 255,
            ChannelId       = ChatProxy.CHANNEL.System,
            mt              = ChatProxy.MSG_TYPE.SystemTips
        }
        global.Facade:sendNotification(global.NoticeTable.AddChatItem, mdata)
    end

    -- collection
    if actor:IsCollection() then
        self:onCollectionInOfView(actor, actorID)
    end

    if actor:IsHaveMaster() then
        global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actorID } )
    end
end

function ActorInOfViewCommand:onNPCInOfView(actor, actorID, jsonData)
    global.Facade:sendNotification(global.NoticeTable.NpcInOfView, actor:GetID())
end

function ActorInOfViewCommand:onCollectionInOfView(actor, actorID)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    inputProxy:AddCollectCount()

    global.Facade:sendNotification(global.NoticeTable.ActorCollect, { actor = actor, sfxID = global.MMO.SFX_MINE })
    global.Facade:sendNotification(global.NoticeTable.CollectVisible, true)
end


return ActorInOfViewCommand