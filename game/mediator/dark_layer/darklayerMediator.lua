local BaseUIMediator = requireMediator("BaseUIMediator")
local darklayerMediator = class('darklayerMediator', BaseUIMediator)
darklayerMediator.NAME = "darklayerMediator"
local cjson = require("cjson")

function darklayerMediator:ctor()
    darklayerMediator.super.ctor(self)
end

function darklayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.MapData_Load_Success,
        noticeTable.ReleaseMemory,
        noticeTable.ActorInOfView,
        noticeTable.ActorOutOfView,
        noticeTable.ActorEffectOutOfView,
        noticeTable.ActorEffectInOfView
    }
end

function darklayerMediator:handleNotification(notification)
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()
    if SL:GetMetaValue("GAME_DATA", "dark") ~= 1 then
        return
    end
    if noticeTable.Layer_Main_Init == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.MapData_Load_Success == noticeName then
        self:OnMapData_Load_Success(noticeData)
    elseif noticeTable.ReleaseMemory == noticeName then
        self:CloseLayer()
    elseif noticeTable.ActorInOfView == noticeName then
        self:OnActorInOfView(noticeData)
    elseif noticeTable.ActorOutOfView == noticeName then
        self:OnActorOutOfView(noticeData)
    elseif noticeTable.ActorEffectOutOfView == noticeName then
        self:OnActorEffectOutOfView(noticeData)
    elseif noticeTable.ActorEffectInOfView == noticeName then
        self:OnActorEffectInOfView(noticeData)
    end
end

function darklayerMediator:OpenLayer(Data)
    if not (self._layer) then
        self._layer = requireLayerUI("darklayer/darklayer").create(Data)
        -- self._type = global.UIZ.UI_MAIN
        -- darklayerMediator.super.OpenLayer( self )


        -- self._layer = requireLayerUI( path ).create()
        self._type = global.UIZ.UI_MAIN
        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_BOTTOM_LB
        self._layer:setLocalZOrder(-999)
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)
    end
end

function darklayerMediator:OnMapData_Load_Success()
    global.darkNodeManager:InitmapInfo()
end

function darklayerMediator:OnActorInOfView(data)
    local hudParam = data and data.hudParam
    local actor = data and data.actor
    local actorPos = cc.p(0, 0)

    if hudParam and hudParam.Candle and actor then
        local ismain = false
        if actor:IsPlayer() and actor:IsMainPlayer() then
            ismain = true
        end
        actorPos = actor:getPosition()
        local DarkLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
        local lightData = nil
        if hudParam.Candle == 0 then --啥也没带
            if ismain then 
                lightData = DarkLayerProxy.LIGHT_TYPE.Default
            end
        else 
            lightData = clone(DarkLayerProxy.LIGHT_TYPE.Custom1)
            lightData.r = lightData.r + hudParam.Candle
            lightData.w = lightData.w + hudParam.Candle
        end
        local lightID = actor:GetLightID()
        if not lightID then
            if lightData then
                lightID = global.darkNodeManager:createNode({x = actorPos.x, y = actorPos.y, r = lightData.r, w = lightData.w})
                actor:SetLightID(lightID)
            end
        else
            if lightData then
                global.darkNodeManager:updateNode(lightID, {x = actorPos.x, y = actorPos.y, r = lightData.r, w = lightData.w})
            else
                global.darkNodeManager:removeNode(lightID)
                actor:SetLightID(nil)
            end
        end
    end

end

function darklayerMediator:OnActorOutOfView(data)
    local actorID = data and data.actorID
    if not actorID then
        return
    end
    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end
    local lightID = actor:GetLightID()
    if lightID then
        global.darkNodeManager:removeNode(lightID)
        actor:SetLightID(nil)
    end
end

function darklayerMediator:OnActorEffectOutOfView(data)
    local actorID = data and data.actorID
    if not actorID then
        return
    end
    local sfxActor = global.actorManager:GetActor(actorID)
    if not sfxActor then
        return nil
    end
    if sfxActor:GetLightID() then
        global.darkNodeManager:removeNode(sfxActor:GetLightID())
        sfxActor:SetLightID(nil)
    end
end

function darklayerMediator:OnActorEffectInOfView(data)
    local needLight = data.needLight
    local actorID = data and data.actorID
    if not actorID then
        return
    end
    local sfxActor = global.actorManager:GetActor(actorID)
    if not sfxActor then
        return nil
    end
    if needLight then --火墙等
        if not sfxActor:GetLightID() then
            local actorPos = sfxActor:getPosition()
            local DarkLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
            local lightData = DarkLayerProxy.LIGHT_TYPE.Two_Skill
            local lightID = global.darkNodeManager:createNode({ x = actorPos.x, y = actorPos.y, r = lightData.r, w = lightData.w })
            sfxActor:SetLightID(lightID)
        end
    end
end

function darklayerMediator:CloseLayer()
    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return darklayerMediator