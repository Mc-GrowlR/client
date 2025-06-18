
local BaseUIMediator = requireMediator("BaseUIMediator")
local FireWorkHallMediator = class("FireWorkHallMediator",BaseUIMediator)
FireWorkHallMediator.NAME = "FireWorkHallMediator"

function FireWorkHallMediator:ctor()
    FireWorkHallMediator.super.ctor(self)
end

function FireWorkHallMediator:listNotificationInterests(  )
    local notice = global.NoticeTable
    return {
        notice.Layer_Fire_Work_Hall_Show
    }
end

function FireWorkHallMediator:handleNotification( notification )
    
    local noticeName = notification:getName()
    local notice = global.NoticeTable
    local noticeData = notification:getBody()

    if notice.Layer_Fire_Work_Hall_Show == noticeName then
        self:ShowFireWorks( noticeData )
    end
end

--@region 播放烟花特效
--@data: 烟花数据 effid: 烟花id  userid: 玩家id
--@endregion
function FireWorkHallMediator:ShowFireWorks( data )
    self._fireworks_count = self._fireworks_count or 0              --烟花数量
    if self._fireworks_count and self._fireworks_count > 100 then
        return false
    end

    -- if xx return
    if (not data) or (not data.userid) or (not data.effid) then
        return
    end

    local actorId   = data.userid

    local actor = global.playerManager:FindOnePlayerInCurrViewFieldById( actorId )
    if (not actor) then
        return
    end
    local actorNode = actor:GetNode() 
    if (not actorNode) then
        return
    end
    
    --自身的node
    local playerID = global.gamePlayerController:GetMainPlayerID()
    local mActor = global.playerManager:FindOnePlayerInCurrViewFieldById( playerID )
    local mActorNode = mActor:GetNode() 

    local visibleSize = global.Director:getVisibleSize()
    local function AddSFXAnimLayer( sfxAnim )
        if not self._anim_layer then
            local Layout = ccui.Layout:create()
            Layout:setContentSize(visibleSize.width, visibleSize.height)
            Layout:setAnchorPoint(cc.p(0.5, 0.5))
            Layout:setPosition(visibleSize.width/2,visibleSize.height/2)
            Layout:setTouchEnabled(false)
            self._anim_layer = Layout
            global.Facade:sendNotification(global.NoticeTable.Layer_Notice_AddChild, {child = Layout})
        end

        self._anim_layer:addChild( sfxAnim,999 )
    end

    local function CloseSFXAnimLayer( )
        if self._anim_layer then
            self._anim_layer:removeFromParent()
            self._anim_layer = nil
        end
    end

    -- local root   = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_UI_TOPMOST )
    local posX   = math.ceil( actorNode:getPositionX() )
    local posY   = math.ceil( actorNode:getPositionY() )
    local mPosX  = math.ceil( mActorNode:getPositionX() )
    local mPosY  = math.ceil( mActorNode:getPositionY() )
    -- local zorder = math.ceil( 0xffffff - posY )

    -- 播个音效
    -- local audio_data = {}
    -- audio_data.type  = global.MMO.SND_TYPE_MODULE
    -- audio_data.index = global.MMO.SND_MODULE_INDEX_FIREWORKS
    -- global.Facade:sendNotification( global.NoticeTable.Audio_Play, audio_data )

    -- 播放特效
    local sfxAnim = global.FrameAnimManager:CreateSFXAnim(data.effid)
    -- root:addChild( sfxAnim, 999 )
    AddSFXAnimLayer(sfxAnim)

    local offPosX = mPosX - posX
    local offPosY = mPosY - posY
    sfxAnim:setPosition( visibleSize.width/2-offPosX, visibleSize.height/2-offPosY)
    sfxAnim:Play(0, 0)
    local function removeEvent()
        sfxAnim:removeFromParent()

        self._fireworks_count = self._fireworks_count - 1
        if self._fireworks_count == 0 then
            CloseSFXAnimLayer()
        end
    end
    sfxAnim:SetAnimEventCallback( removeEvent )

    -- 计数
    self._fireworks_count = self._fireworks_count + 1
end

function FireWorkHallMediator:Onloaded()
end

function FireWorkHallMediator:OnUnloaded()
end

return FireWorkHallMediator