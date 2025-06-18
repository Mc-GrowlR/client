local RoleEffectLayout = class( "RoleEffectLayout" )
local Queue            = requireUtil( "queue" )


local function animCallback( anim, eventType )
    if eventType == 1 then    -- end
        anim:Stop()
        anim:setVisible( false )
    end
end

function  RoleEffectLayout:ctor()
    self._sfxCache = {}
end


function RoleEffectLayout.create()
    local layout = RoleEffectLayout.new()
    if layout:Init() then
        return layout
    else
        return nil
    end
end

function RoleEffectLayout:Init()

    return true
end

function RoleEffectLayout:OnClose()
    if self._upgradeAnim then
        self._upgradeAnim:removeFromParent()
        self._upgradeAnim:autorelease()
    end

    if self._selectRing then
        self._selectRing:removeFromParent()
        self._selectRing:autorelease()
    end

    if self._upILvAnim then
        self._upILvAnim:removeFromParent()
        self._upILvAnim:autorelease()
    end

    if self._upHeroILvAnim then
        self._upHeroILvAnim:removeFromParent()
        self._upHeroILvAnim:autorelease()
    end

    for _, cache in pairs( self._sfxCache ) do
        local cacheSize = cache:size()
        if cacheSize > 0 then
            for i = 1, cacheSize do
                local sfx = cache:pop()
                sfx:autorelease()

            end

        end
    end

end

function RoleEffectLayout:OnRoleLevelUp( actor )
    if not self._upgradeAnim then
        self._upgradeAnim = global.FrameAnimManager:CreateSFXAnim( global.MMO.SFX_UPGRADE  )
        self._upgradeAnim:retain()
        actor:GetNode():addChild( self._upgradeAnim )

        self._upgradeAnim:SetAnimEventCallback( animCallback )
    end


    self._upgradeAnim:setVisible( true )
    self._upgradeAnim:Stop()
    self._upgradeAnim:Play( 0, 0, false )
end

function RoleEffectLayout:OnSelectRole( actor )
    if not self._selectRing then
        self._selectRing = global.FrameAnimManager:CreateSFXAnim( global.MMO.SFX_SELECT_PLAYER  )
        self._selectRing:Play( 0, 0, true )
        self._selectRing:retain()
    end

    self._selectRing:removeFromParent()
    self._selectRing:setVisible( true )
    self._selectRing:Stop()
    self._selectRing:Play( 0, 0, true )
    actor:GetNode():addChild( self._selectRing, -10, 10 )
end

function RoleEffectLayout:OnClearSelect()
    if self._selectRing and self._selectRing:getParent() then
        self._selectRing:removeFromParent()
        self._selectRing:setVisible( true )
        self._selectRing:Stop()
    end
end

function RoleEffectLayout:OnRoleInternalLevelUp(actor)
    if not self._upILvAnim then
        self._upILvAnim = global.FrameAnimManager:CreateSFXAnim(global.MMO.SFX_INTERNAL_LV_UP)
        self._upILvAnim:retain()
        actor:GetNode():addChild(self._upILvAnim)

        self._upILvAnim:SetAnimEventCallback( animCallback )
    end

    self._upILvAnim:setVisible(true)
    self._upILvAnim:Stop()
    self._upILvAnim:Play(0, 0, false)
end

function RoleEffectLayout:OnHeroInternalLevelUp(actor)
    if not self._upHeroILvAnim then
        self._upHeroILvAnim = global.FrameAnimManager:CreateSFXAnim(global.MMO.SFX_INTERNAL_LV_UP)
        self._upHeroILvAnim:retain()
        actor:GetNode():addChild(self._upHeroILvAnim)

        self._upHeroILvAnim:SetAnimEventCallback( animCallback )
    end

    self._upHeroILvAnim:setVisible(true)
    self._upHeroILvAnim:Stop()
    self._upHeroILvAnim:Play(0, 0, false)
end

function RoleEffectLayout:createSfx( sfxID )
    if not self._sfxCache[sfxID] then
        self._sfxCache[sfxID] = Queue.new()
    end
    local cache = self._sfxCache[sfxID]

    local sfx = nil
    if cache:empty() then
        sfx = global.FrameAnimManager:CreateSFXAnim( sfxID )
        sfx:setTag( sfxID )
        sfx:retain()
    else
        sfx = cache:pop()
    end

    return sfx
end

function RoleEffectLayout:cacheAnimCallback( anim, eventType )
    if eventType == 1 then    -- end
        anim:Stop()
        anim:setVisible( false )
        anim:removeFromParent()

        local sfxID = anim:getTag()
        local cache = self._sfxCache[sfxID]
        cache:push( anim )
    end
end

function RoleEffectLayout:OnCollect( actor, sfxID )
    local actorAnim = actor:GetAnimation()
    if not actorAnim then
        return nil
    end


    local anim      = global.FrameAnimManager:CreateSFXAnim( sfxID )
    local actorNode = actor:GetNode()
    local rect      = actorAnim:GetBoundingBox() 

    anim:setPosition( 0 , rect.height )
    anim:Play( 0, 0, true )
    actorNode:addChild( anim )
end


function RoleEffectLayout:OnFlyIn( data, stype )
    local f_actor_node = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ACTOR_SFX_FRONT)
    local animPos      = global.sceneManager:MapPos2WorldPos(data.x, data.y, true)

    local sfxID = stype > 1 and stype
    if not sfxID then
        sfxID = stype == 1 and global.MMO.SFX_FLY_IN_2 or global.MMO.SFX_FLY_IN
    end
    local anim  = self:createSfx( sfxID )
    anim:setVisible( true )
    anim:Play( 0, 0, true )
    anim:SetAnimEventCallback( handler( self, self.cacheAnimCallback ) )
    anim:setPosition(cc.pAdd(cc.p(animPos.x, animPos.y), global.MMO.PLAYER_AVATAR_OFFSET))
    f_actor_node:addChild( anim )
end

function RoleEffectLayout:OnFlyOut( actor, stype )
    local actorNode    = actor:GetNode() 
    local f_actor_node = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ACTOR_SFX_FRONT)
    local animPos      = cc.p( actorNode:getPosition() )

    local sfxID = stype > 1 and stype
    if not sfxID then
        sfxID = stype == 1 and global.MMO.SFX_FLY_OUT_2 or global.MMO.SFX_FLY_OUT
    end
    local anim  = self:createSfx( sfxID )
    anim:setVisible( true )
    anim:Play( 0, 0, true )
    anim:SetAnimEventCallback( handler( self, self.cacheAnimCallback ) )
    -- anim:setPosition( animPos.x, animPos.y )
    anim:setPosition(cc.pAdd(cc.p(animPos.x, animPos.y), global.MMO.PLAYER_AVATAR_OFFSET))
    f_actor_node:addChild( anim )
end

return RoleEffectLayout
