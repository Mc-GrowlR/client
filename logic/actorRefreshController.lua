local DebugMediator = requireMediator("DebugMediator")
local actorRefreshController = class("actorRefreshController", DebugMediator)
actorRefreshController.NAME = "actorRefreshController"

local optionsUtils = requireProxy( "optionsUtils" )

local REFRESH_TYPE_HUDLABEL      = 1
local REFRESH_TYPE_HUDTITLE      = 2
local REFRESH_TYPE_FEATURE       = 3
local REFRESH_TYPE_HUDBAR        = 4
local REFRESH_TYPE_DIRTY_FEATURE = 5

function actorRefreshController:ctor()
    actorRefreshController.super.ctor(self)

    self._createCache = {}
    self._refreshCache = {}

    self._npcCreateCache = {}
    self._npcRefreshCache = {}
end

function actorRefreshController:destory()
    if actorRefreshController.instance then
        global.Facade:removeMediator( actorRefreshController.NAME )
        actorRefreshController.instance = nil
    end
end

function actorRefreshController:Inst()
    if not actorRefreshController.instance then
        actorRefreshController.instance = actorRefreshController.new()
        global.Facade:registerMediator(actorRefreshController.instance)
    end
    return actorRefreshController.instance
end

function actorRefreshController:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.ActorOutOfView,
        noticeTable.DropItemOutOfView,
        noticeTable.ActorEffectOutOfView,
        noticeTable.DelayRefreshHUDLabel,
        noticeTable.DelayRefreshHUDTitle,
        noticeTable.DelayActorFeatureChange,
        noticeTable.DelayDirtyFeature,
        noticeTable.DelayCreateHUDBar,
    }
end

function actorRefreshController:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.ActorOutOfView == noticeID then
        self:OnActorOutOfView(data)

    elseif noticeTable.DropItemOutOfView == noticeID then
        self:OnDropItemOutOfView(data)

    elseif noticeTable.ActorEffectOutOfView == noticeID then
        self:OnActorEffectOutOfView(data)
        
    elseif noticeTable.DelayRefreshHUDLabel == noticeID then
        self:OnDelayRefreshHUDLabel(data)
        
    elseif noticeTable.DelayRefreshHUDTitle == noticeID then
        self:OnDelayRefreshHUDTitle(data)

    elseif noticeTable.DelayActorFeatureChange == noticeID then
        self:OnDelayActorFeatureChange(data)

    elseif noticeTable.DelayDirtyFeature == noticeID then
        self:OnDelayDirtyFeature(data)

    elseif noticeTable.DelayCreateHUDBar == noticeID then
        self:OnDelayCreateHUDBar(data)

    end
end

function actorRefreshController:Cleanup()
    self._createCache = {}
    self._refreshCache = {}

    self._npcCreateCache = {}
    self._npcRefreshCache = {}
end

function actorRefreshController:CleanupByActorID(actorID)
    self._createCache[actorID] = nil
    self._refreshCache[actorID] = nil

    self._npcCreateCache[actorID] = nil
    self._npcRefreshCache[actorID] = nil
end

function actorRefreshController:Tick()
    local n = 0
    for i = 1, 3 do
        n = n + self:nextCreate(self._npcCreateCache)
        self:nextRefresh(self._npcRefreshCache)
    end

    for i = n+1, 3 do
        self:nextCreate(self._createCache)
        self:nextRefresh(self._refreshCache)
    end
end

function actorRefreshController:nextCreate(caches)
    local actorID = next(caches)
    if not actorID then
        return 0
    end

    local cache = caches[actorID]
    local item = nil

    -- hud bar
    item = cache[REFRESH_TYPE_HUDBAR]
    if item then
        self:OnCreateHUDBar(item)
    end

    -- feature
    item = cache[REFRESH_TYPE_FEATURE]
    if item then
        global.Facade:sendNotification( global.NoticeTable.ActorFeatureChange, item)
    end

    -- feature
    item = cache[REFRESH_TYPE_DIRTY_FEATURE]
    if item then
        self:DirtyFeature(item)
    end

    -- cleanup
    caches[actorID] = nil

    return 1
end

function actorRefreshController:nextRefresh(caches)
    local actorID = next(caches)
    if not actorID then
        return nil
    end

    local refresh = caches[actorID]
    local item = nil

    -- hud label
    item = refresh[REFRESH_TYPE_HUDLABEL]
    if item then
        if item.hudParam then
            local actor = item.actor
            optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_NAMELabel_VISIBLE)
            optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_GUILDLabel_VISIBLE)
            optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_TITLELabel_VISIBLE)

            global.Facade:sendNotification( global.NoticeTable.RefreshHUDLabel, item )
            global.Facade:sendNotification( global.NoticeTable.RefreshActorNameColor, item )
        else
            global.Facade:sendNotification( global.NoticeTable.RefreshActorNameColor, item )
        end
    end

    -- hud title
    item = refresh[REFRESH_TYPE_HUDTITLE]
    if item then
        local actor = item.actor
        optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_TITLE_VISIBLE)

        global.Facade:sendNotification( global.NoticeTable.RefreshHUDTitle, item )
    end

    -- cleanup
    caches[actorID] = nil
end

function actorRefreshController:OnActorOutOfView(data)
    if not data.actorID or not data.actor then
        return nil
    end

    self:CleanupByActorID(data.actorID)
end

function actorRefreshController:OnDropItemOutOfView(data)
    if not data.actorID then
        return nil
    end

    self:CleanupByActorID(data.actorID)
end

function actorRefreshController:OnActorEffectOutOfView(data)
    if not data.actorID then
        return nil
    end

    self:CleanupByActorID(data.actorID)
end

function actorRefreshController:OnDelayRefreshHUDLabel(data)
    local hudParam = data.hudParam
    local actorID = data.actorID
    local actor = data.actor
    if not actorID or not actor then
        return nil
    end

    local caches = actor:IsNPC() and self._npcRefreshCache or self._refreshCache

    if not hudParam and caches[actorID] and caches[actorID][REFRESH_TYPE_HUDLABEL] then
        return nil
    end

    caches[actorID] = caches[actorID] or {}
    caches[actorID][REFRESH_TYPE_HUDLABEL] = data
end

function actorRefreshController:OnDelayRefreshHUDTitle(data)
    local actorID = data.actorID
    local actor = data.actor
    if not actorID or not actor then
        return nil
    end

    local caches = actor:IsNPC() and self._npcRefreshCache or self._refreshCache
    caches[actorID] = caches[actorID] or {}
    caches[actorID][REFRESH_TYPE_HUDTITLE] = data
end

function actorRefreshController:OnDelayActorFeatureChange(data)
    local actorID = data.actorID
    local actor = data.actor
    if not actorID or not actor then
        return nil
    end

    local caches = actor:IsNPC() and self._npcCreateCache or self._createCache
    caches[actorID] = caches[actorID] or {}
    caches[actorID][REFRESH_TYPE_FEATURE] = data
end

function actorRefreshController:OnDelayCreateHUDBar(data)
    local actorID = data.actorID
    local actor = data.actor
    if not actorID or not actor then
        return nil
    end

    local caches = actor:IsNPC() and self._npcCreateCache or self._createCache
    caches[actorID] = caches[actorID] or {}
    caches[actorID][REFRESH_TYPE_HUDBAR] = data
end

function actorRefreshController:OnCreateHUDBar(data)
    local actorID = data.actorID
    local actor = global.actorManager:GetActor(actorID)
    if not actorID or not actor then
        return false
    end

    -- HUD for actor  
    local hpSpriteID = global.MMO.HP_SPRITE_ID
    if actor:IsPlayer() and actor:IsMainPlayer() and SL:GetMetaValue("GAME_DATA", "hight_main_player_hp") == 1 then
        hpSpriteID = global.MMO.HP_MAIN_SPRITE_ID
    end
    local hpBorder = global.HUDManager:CreateHUDBar( actorID, global.MMO.HUD_SPRITE_HP_BG, global.MMO.HUD_OFFSET_BG_1, global.MMO.HP_BG_SPRITE_ID )
    local hpBar    = global.HUDManager:CreateHUDBar( actorID, global.MMO.HUD_SPRITE_HP, global.MMO.HUD_OFFSET_1, hpSpriteID )
    actor.mHUDUI[global.MMO.HUDHPUI_BAR]    = hpBar
    actor.mHUDUI[global.MMO.HUDHPUI_BORDER] = hpBorder
    local HP      = actor:GetHP()
    local maxHP   = actor:GetMaxHP()

    local percent = HP / maxHP

    if global.ConstantConfig.showFewHp == 1 and not actor:GetValueByKey(global.MMO.HUD_BAR_SHOW_FULL_HP) then
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        local heroActor  = HeroPropertyProxy:GetHeroActor()
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        if actor ~= heroActor and actor ~= mainPlayer then 
            percent = 1
        end
    end

    global.HUDManager:SetHUDBarPercent( hpBar, percent )

    -- HUD MP for actor
    local mpBorder  = global.HUDManager:CreateHUDBar( actorID, global.MMO.HUD_SPRITE_MP_BG, global.MMO.HUD_OFFSET_BG_2, global.MMO.HP_BG_SPRITE_ID )
    local mpBar     = global.HUDManager:CreateHUDBar( actorID, global.MMO.HUD_SPRITE_MP, global.MMO.HUD_OFFSET_2, global.MMO.MP_SPRITE_ID )
    actor.mHUDUI[global.MMO.HUDMPUI_BAR]    = mpBar
    actor.mHUDUI[global.MMO.HUDMPUI_BORDER] = mpBorder
    local MP      = actor:GetMP()
    local maxMP   = actor:GetMaxMP()
    local percent = MP / maxMP
    global.HUDManager:SetHUDBarPercent( mpBar, percent )

    -- HUD NG for actor
    local ngBorder  = global.HUDManager:CreateHUDBar( actorID, global.MMO.HUD_SPRITE_NG_BG, global.MMO.HUD_OFFSET_BG_3, global.MMO.HP_BG_SPRITE_ID )
    local ngBar     = global.HUDManager:CreateHUDBar( actorID, global.MMO.HUD_SPRITE_NG, global.MMO.HUD_OFFSET_3, global.MMO.NG_SPRITE_ID )
    actor.mHUDUI[global.MMO.HUDNGUI_BAR]    = ngBar
    actor.mHUDUI[global.MMO.HUDNGUI_BORDER] = ngBorder
    if actor.GetForce and actor.GetMaxForce then
        local force     = actor:GetForce()
        local maxForce  = actor:GetMaxForce()
        local percent = maxForce == 0 and 0 or (force / maxForce)
        global.HUDManager:SetHUDBarPercent( ngBar, percent )
    end

    -- 刷新坐标
    local position = actor:getPosition()
    actor:setPosition(position.x, position.y)

    global.Facade:sendNotification(global.NoticeTable.RefreshActorSceneOptions, actor)
end

function actorRefreshController:OnDelayDirtyFeature(data)
    local actorID = data.actorID
    local actor = global.actorManager:GetActor(actorID)
    if not actorID or not actor then
        return nil
    end

    local caches = actor:IsNPC() and self._npcCreateCache or self._createCache
    caches[actorID] = caches[actorID] or {}
    caches[actorID][REFRESH_TYPE_DIRTY_FEATURE] = data
end

function actorRefreshController:DirtyFeature(data)
    local actorID = data.actorID
    local actor = global.actorManager:GetActor(actorID)
    if not actorID or not actor then
        return nil
    end

    actor:dirtyFeature()
end

return actorRefreshController
