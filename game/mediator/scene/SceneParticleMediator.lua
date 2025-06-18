local BaseUIMediator   = requireMediator( "BaseUIMediator" )
local SceneParticleMediator = class('SceneParticleMediator', BaseUIMediator )
SceneParticleMediator.NAME  = "SceneParticleMediator"

function SceneParticleMediator:ctor()
    SceneParticleMediator.super.ctor( self )

    self._particlesList = {}
    self._path = global.MMO.PATH_RES_PRIVATE.."particles/"
end

function SceneParticleMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
        {
            noticeTable.ChangeScene,
            noticeTable.MainPlayerActionEnded,
            noticeTable.Scene_Weather_Effect_Add,  
            noticeTable.Scene_Weather_Effect_Remove,
        }
end

function SceneParticleMediator:handleNotification(notification)
    local noticeID      = notification:getName()
    local noticeTable   = global.NoticeTable
    local data          = notification:getBody()

    if noticeTable.ChangeScene == noticeID then
        self:OnMapInfoChange()

    elseif noticeTable.MainPlayerActionEnded == noticeID then
        self:OnMainPlayerActionEnded()

    elseif noticeTable.Scene_Weather_Effect_Add == noticeID then
        self:UpdateParticle(data)
    
    elseif noticeTable.Scene_Weather_Effect_Remove == noticeID then
        self:RemoveParticles(data)
    end
end

function SceneParticleMediator:OnMapInfoChange()
    self:RemoveParticles()
end

function SceneParticleMediator:OnMainPlayerActionEnded()
    -- self:UpdateParticlePosition()
end

function SceneParticleMediator:UpdateParticle(data)

    local SceneEffectProxy = global.Facade:retrieveProxy(global.ProxyTable.SceneEffectProxy)
    local effectList = SceneEffectProxy:GetWeatherEffList()
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local curMapId = MapProxy:GetMapID()
    if not effectList[curMapId] and data.init then  -- 
        return
    end

    local proxyMap      = global.Facade:retrieveProxy( global.ProxyTable.Map )
    local particleRoot  = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_UI )

    if (not particleRoot) then
        return
    end

    local viewSize  = global.Director:getVisibleSize()
    local viewWid   = viewSize.width
    local viewHei   = viewSize.height

    -- 根据模式创建
    -- 1黄沙 2花瓣 3下雪
    local scene_particles = {
        [2] = "petal_1#petal_2#petal_3#petal_4",
        [3] = "snow_1#snow_2#snow_3#snow_4",
    }

    local addList = {}
    if data.init then
        addList = effectList[curMapId]
    else
        table.insert(addList, data.params)
    end
   
    if next(addList) then
        for _, effect in ipairs(addList) do
            --避免重复添加
            if self._particlesList[effect.mode] then 
                self:RemoveParticles(effect.mode)
            end

            if scene_particles[effect.mode] and string.len(scene_particles[effect.mode]) > 0 then
                local particlesSplit = string.split( scene_particles[effect.mode], "#" )
                local _particles = {}
                for _, vParticleName in pairs(particlesSplit) do
                    local particle = cc.ParticleSystemQuad:create( string.format( self._path .. "%s.plist", vParticleName ) )
                    particle:setPositionType( 1 )
                    particleRoot:addChild(particle, -1)
                    particle:setPosVar(cc.p(viewWid/2, viewHei/2) )
                    particle:setPosition(cc.p(viewWid/2, viewHei/2) )
                
                    table.insert( _particles, particle )
                end
                self._particlesList[effect.mode] = _particles
                
            elseif effect.mode == 1 then -- 黄沙
                local ext = {
                count = 10,
                speed = 20,
                }
                local frames = ssr.GUI:Frames_Create(particleRoot, "HS_effect", viewWid/2, viewHei/2, "private/particles/0000", ".png", nil, ext )
                frames:setLocalZOrder(-1)
                frames:setOpacity(130)
                ssr.GUI:setContentSize(frames, cc.size(viewWid, viewHei))
                local _particles = {}
                table.insert( _particles, frames )
                self._particlesList[effect.mode] = _particles
            end
        end
    end

end

function SceneParticleMediator:UpdateParticlePosition()
    if not next(self._particles) then
        return
    end

    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if (not mainPlayer) then
        return
    end

    local viewSize  = global.Director:getVisibleSize()
    local viewWid   = viewSize.width
    local viewHei   = viewSize.height
    
    for _, vParticle in pairs(self._particles) do
        if (not tolua.isnull( vParticle )) then
            vParticle:setPosition(cc.p(viewWid / 2, viewHei / 2) )
        end
    end
end

function SceneParticleMediator:RemoveParticles( mode )
    if not mode or mode == 0 then
        for _, particles in pairs(self._particlesList) do
            for _, vParticle in pairs( particles ) do
                if (not tolua.isnull( vParticle )) then
                    if vParticle.stopAllActions then
                        vParticle:stopAllActions()
                    end
                    vParticle:removeFromParent()
                end
            end
        end
        self._particlesList = {}

        local SceneEffectProxy = global.Facade:retrieveProxy(global.ProxyTable.SceneEffectProxy)
        SceneEffectProxy:ClearWeatherEffList()
    end

    if mode and self._particlesList[mode] then
        for _, vParticle in pairs( self._particlesList[mode] ) do
            if (not tolua.isnull( vParticle )) then
                if vParticle.stopAllActions then
                    vParticle:stopAllActions()
                end
                vParticle:removeFromParent()
            end
        end
        self._particlesList[mode] = nil
    end
end

return SceneParticleMediator