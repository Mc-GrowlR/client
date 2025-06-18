local MainCollectMediator = class("MainCollectMediator", framework.Mediator)
MainCollectMediator.NAME = "MainCollectMediator"
local proxyUtils = requireProxy("proxyUtils")

function MainCollectMediator:ctor()
    MainCollectMediator.super.ctor(self, self.NAME)

    self._isCollecting = false
    self._collectData = {}
end

function MainCollectMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.MainPlayerActionEnded,
        noticeTable.CollectVisible,
        noticeTable.CollectCheckInview,
        noticeTable.CollectBegin,
        noticeTable.CollectCompleted,
        noticeTable.ActorMonsterDie
    }
end

function MainCollectMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnOpen(data)
    elseif noticeTable.MainPlayerActionEnded == noticeID then
        self:onMainPlayerActionEnded(data)
    elseif noticeTable.CollectVisible == noticeID then
        self:OnAutoCollectingVisible(data)
    elseif noticeTable.CollectCheckInview == noticeID then
        self:CheckCollection(data)
    elseif noticeTable.CollectBegin == noticeID then
        self:OnCollectingBegan(data)
    elseif noticeTable.CollectCompleted == noticeID then
        self:OnCollectingCompleted(data)
    elseif noticeTable.ActorMonsterDie == noticeID then
        self:OnRefreshCollect(data)
    end
end

function MainCollectMediator:OnOpen()
    if not (self._layer) then
        self._layer = requireMainUI("MainCollectLayout").create()
        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_MB
        self:getFacade():sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        ssr.GUI.ATTACH_PARENT = self._layer
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()
    end
end

function MainCollectMediator:OnCollectingBegan(data)
    self._isCollecting = true
end

function MainCollectMediator:OnCollectingCompleted()
    self._isCollecting = false
end

function MainCollectMediator:onMainPlayerActionEnded(act)
    if not (act == global.MMO.ACTION_WALK or act == global.MMO.ACTION_RUN or act == global.MMO.ACTION_RIDE_RUN) then
        return false
    end
    self:CheckCollection()
end

function MainCollectMediator:CheckCollection()
    -- 采集中
    if self._isCollecting then
        return false
    end

    -- 数量不够
    local inputProxy = self:getFacade():retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local collectCount = inputProxy:GetCollectCount()
    if collectCount <= 0 then
        return false
    end

    -- 采集物列表
    local monsterVec, nMonster = global.monsterManager:FindMonsterInCurrViewFieldByRace(global.MMO.ACTOR_RACE_COLLECTION)

    -- 距离
    local collections = {}
    if nMonster > 0 then
        local hideSelect = tonumber(SL:GetMetaValue("GAME_DATA", "Hide_Select_Collection")) == 1
        local findCollectRange = tonumber(SL:GetMetaValue("GAME_DATA", "FindRange_Collection")) or 0
        local player = global.gamePlayerController:GetMainPlayer()
        local playerPos = cc.p(player:GetMapX(), player:GetMapY())
        for i = 1, nMonster do
            local monster = monsterVec[i]
            local collectionPos = cc.p(monster:GetMapX(), monster:GetMapY())
            if proxyUtils:CheckCollectionEnable(monster, player) and cc.pGetDistance(collectionPos, playerPos) <= findCollectRange then
                collections[monster:GetID()] = monster
                if hideSelect then
                    break
                end
            end
        end
    end

    if next(collections) then
        self:ShowCollect(collections)
    else
        self:HideCollect()
    end
end

function MainCollectMediator:ShowCollect(collections)
    if not self._layer then
        return false
    end
    self._layer:ShowCollect(collections)
end

function MainCollectMediator:HideCollect()
    if not self._layer then
        return false
    end
    self._layer:HideCollect()
end

function MainCollectMediator:OnAutoCollectingVisible(visible)
    if visible then
        self:CheckCollection()
    else
        self:HideCollect()
    end
end

function MainCollectMediator:OnRefreshCollect(data)
    if self._layer then
        self._layer:OnRefreshCollect(data)
    end
end

function MainCollectMediator:onRegister()
    MainCollectMediator.super.onRegister(self)
end

return MainCollectMediator