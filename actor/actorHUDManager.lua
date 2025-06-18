local actorHUDManager = class("actorHUDManager")

local DEFAULT_SPRITE_ID       = 9999

local fontSizeMob = SL:GetMetaValue("GAME_DATA","sceneFontSize") or SL:GetMetaValue("GAME_DATA","SCENE_FONT_SIZE")
local fontSizeWin = SL:GetMetaValue("GAME_DATA","sceneFontSize_pc") or SL:GetMetaValue("GAME_DATA","SCENE_FONT_SIZE_PC")
local fontSize    = global.isWinPlayMode and fontSizeWin or fontSizeMob

local HUD_LABEL_FONTS_SIZE      = fontSize
local HUD_LABEL_FONTS_SIZE2     = fontSize
local HUD_LABEL_FONTS_SIZE3     = fontSize
local HUD_LABEL_OUTLINE_SIZE    = 1
local HUD_SPRITE_FORMAT         =  "actor_hud_%04d.png"
local fontZtPath                =  global.MMO.PATH_FONT2 

local DEFAULT_NODE_INDEX = global.MMO.HUD_TYPE_MAX + 1
local DEFAULT_NODE_ZLOCAL = {
    [global.MMO.HUD_TYPE_BATCH_LABEL] = 0,
    [global.MMO.HUD_TYPE_SPRITE] = 1000000,
    [global.MMO.HUD_TYPE_ANIM] = 2000000,
}

function actorHUDManager:ctor()
    self._hudRoot       = {}
    self._hudRootB      = {}
    self._actorsHUD     = {}
    self._hudCache      = {}
    self._titleAnimCount = 0
    self._titleMaXCount = 50
    self._horseOffset = {}
end

function actorHUDManager:destory()
    if actorHUDManager.instance then
        actorHUDManager.instance = nil
    end
end

function actorHUDManager:Inst()
    if not actorHUDManager.instance then
        actorHUDManager.instance = actorHUDManager.new()
    end

    return actorHUDManager.instance
end

function actorHUDManager:checkParam(actorID, htype, index)
    if htype < 0 or (htype > global.MMO.HUD_TYPE_MAX) or (index <= 0) or (index > global.MMO.HUD_COUNT_MAX) then
        return nil
    end

    local itr = self._actorsHUD[actorID]
    if itr == nil then
        return nil
    end


    local hudArray = itr
    local hud      = hudArray[htype * global.MMO.HUD_COUNT_MAX + index]
    if not hud then
        return nil
    end

    return hudArray
end

function actorHUDManager:Init()
    local mmo = global.MMO

    local actorHUDRoot      = global.sceneGraphCtl:GetSceneNode(mmo.NODE_ACTOR_HUD)
    local actorHUDRootB     = global.sceneGraphCtl:GetSceneNode(mmo.NODE_SKILL_BEHIND)

    self._useBmpFont = false
    if global.isWinPlayMode then
        self._useBmpFont = SL:GetMetaValue("GAME_DATA", "HudNotUseBmpFont") ~= 1
    else
        self._useBmpFont = SL:GetMetaValue("GAME_DATA", "MobileHudNotUseBmpFont") == 1
    end

    if self._useBmpFont then 
        fontZtPath = global.MMO.PATH_ST_FONT
    end

    for i = 0, global.MMO.HUD_TYPE_MAX do
        if i == global.MMO.HUD_TYPE_BATCH_LABEL and not self._useBmpFont then 
            self._hudRoot[mmo.HUD_TYPE_BATCH_LABEL] = LabelBatchNode:create( fontZtPath, HUD_LABEL_FONTS_SIZE, HUD_LABEL_OUTLINE_SIZE )
            self._hudRootB[mmo.HUD_TYPE_BATCH_LABEL] = LabelBatchNode:create( fontZtPath, HUD_LABEL_FONTS_SIZE, HUD_LABEL_OUTLINE_SIZE )
        else
            self._hudRoot[i]       = cc.Node:create()
            self._hudRootB[i]      = cc.Node:create()
        end
        actorHUDRoot:addChild(self._hudRoot[i])
        actorHUDRootB:addChild(self._hudRootB[i])
    end
end

function actorHUDManager:refCameraFontScale()
    if not global.isWinPlayMode 
    and global.LuaBridgeCtl:GetModulesSwitch(global.MMO.Modules_Index_Cpp_Version) >= global.MMO.CPP_VERSION_LABEL_TTF 
    and self._hudRoot[global.MMO.HUD_TYPE_BATCH_LABEL].refCameraFontScale then 
        self._hudRoot[global.MMO.HUD_TYPE_BATCH_LABEL]:refCameraFontScale()  
        self._hudRootB[global.MMO.HUD_TYPE_BATCH_LABEL]:refCameraFontScale()  
    end
end

function actorHUDManager:Cleanup()
    self._hudRoot = {}
    self._hudRootB = {}
    self._horseOffset = {}
    self._titleAnimCount = 0
    -- only release hud cache
    local hud = nil
    for i = 0, global.MMO.HUD_TYPE_MAX do
        local cache = self._hudCache[i]
        if cache ~= nil and #cache > 0 then
            for k,v in pairs(cache) do
                hud = v
                if hud.type == global.MMO.HUD_TYPE_BATCH_LABEL and not self._useBmpFont then
                else
                    hud.hud:release()
                end
                cache[k] = nil
            end
        end
    end
end

function actorHUDManager:newHUD()
    local hud  = {}
    hud.type   = 0
    hud.hud    = nil
    hud.offset = cc.p(0,0)

    return hud
end

function actorHUDManager:CreateHUD(actorID, htype, index, offset, id, isBehide)
    if not id then id = 0 end

    local ret = nil
    if htype < 0 or htype > global.MMO.HUD_TYPE_MAX or index <= 0 or index > global.MMO.HUD_COUNT_MAX then
        return ret
    end

    -- 1.create HUD
    local hud = nil
    if self._hudCache[htype] and #self._hudCache[htype] > 0 then
        hud = table.remove(self._hudCache[htype], 1)
        ret = hud.hud
        if htype == global.MMO.HUD_TYPE_BATCH_LABEL and self._useBmpFont then 
            if ret.setColor  then 
                ret:setColor(cc.c3b(255,255,255))
            end
            ret:setString("")
        end
        
    else
        hud = self:newHUD()
        if htype == global.MMO.HUD_TYPE_BATCH_LABEL then
            if self._useBmpFont then 
                ret = cc.Label:createWithBMFont(fontZtPath, "")
                ret:retain()
            else
                ret = LabelBatchString:new(0, 2)
                --ret:setAnchorPoint(0.5,0)
            end
        elseif htype == global.MMO.HUD_TYPE_SPRITE then
            ret = ccui.Scale9Sprite:create()
            ret:retain()
        elseif htype == global.MMO.HUD_TYPE_TIPS then
            ret = cc.Node:create()
            ret:retain()
        elseif htype == global.MMO.HUD_TYPE_ANIM then
            ret = cc.Node:create()
            ret:retain()
        end
    end

    local hudRoot = isBehide and self._hudRootB or self._hudRoot
    -- 2. add to scene
    if htype == global.MMO.HUD_TYPE_BATCH_LABEL and not self._useBmpFont then 
        local lStr = ret
        lStr:cleanup()
        hudRoot[htype]:addLabelString( lStr )
    elseif htype == global.MMO.HUD_TYPE_SPRITE then
        local sprite = ret
        sprite:setAnchorPoint( 0.5, 0.5 )
        sprite:setVisible( true )
        sprite:setOpacity( 255 )
        sprite:setTag( 0 )
        self:SetSpriteFrame( sprite, id )
        self:AddAnimCount(1)
        hudRoot[htype]:addChild( sprite, 0)
    elseif htype == global.MMO.HUD_TYPE_ANIM then
        local node = ret
        node:setVisible( true )
        node:setOpacity( 255 )
        node:setTag( 0 )
        self:SetAnim( node, id )
        self:AddAnimCount(1)
        hudRoot[htype]:addChild( ret, id )
        hud.oz = index
    else
        local node = ret
        node:setVisible( true )
        node:setOpacity( 255 )
        node:setTag( 0 )
        hudRoot[htype]:addChild( ret, 0 )
    end

    hud.hud    = ret
    hud.type   = htype
    hud.offset = offset
    hud.isBehide = isBehide


    -- 3. trace HUD
    local hudArray = nil
    local itr = self._actorsHUD[actorID]
    if nil == itr then
        hudArray = {}
        self._actorsHUD[actorID] = hudArray
    else
        hudArray = itr
    end
    hudArray[htype * global.MMO.HUD_COUNT_MAX + index] = hud

    return ret
end


function actorHUDManager:CreateHUDBar(actorID, index, offset, id, isBehide)
    local bar = self:CreateHUD( actorID, global.MMO.HUD_TYPE_SPRITE, index, offset, id, isBehide )
    bar:setAnchorPoint( 0.0, 0.0 )
    bar:setVisible( true )

    return bar
end

function actorHUDManager:SetHUDBarPercent( bar, percent )
    if percent > 1.0 then
        percent = 1.0
    end

    local contentSize = bar:getSpriteFrame():getOriginalSize()
    local hpRect      = bar:getTextureRect()
    hpRect.width      = percent * ( contentSize.width )
    bar:setTextureRect( hpRect, bar:isTextureRectRotated(), hpRect )
end


function actorHUDManager:GetHUD(actorID, htype, index, isBehide)
    local hudArray = self:checkParam(actorID, htype, index)
    if not hudArray or hudArray == 0 then
        return nil
    end

    local arrayIndex = htype * global.MMO.HUD_COUNT_MAX + index
    local hud       = hudArray[arrayIndex]
    if isBehide ~= nil and hud.isBehide ~= isBehide then
        self:RemoveHUD( actorID, htype, index )
        return nil
    end
    return hud.hud
end

function actorHUDManager:setPosition(actorID, x, y)
    local itr = self._actorsHUD[actorID]
    if itr == nil then
        return
    end

    local horseOffset = self:GetHorseOffset( actorID )
    local horseOffsetLabel = self:GetHorseOffsetLabel( actorID )

    local hudArray = itr
    local hud      = 0
    for i = 0, global.MMO.HUD_TYPE_MAX do
        for j = 1, global.MMO.HUD_COUNT_MAX do
            hud = hudArray[i * global.MMO.HUD_COUNT_MAX + j]
            if hud then
                if global.MMO.HUD_TYPE_BATCH_LABEL == i and not self._useBmpFont then
                    hud.hud:setPosition( x + hud.offset.x +  horseOffsetLabel.x , y + hud.offset.y +  horseOffsetLabel.y )
                    hud.hud:setLocalZ( math.floor(-y) )
                else
                    local node = hud.hud 
                    node:setPosition( x + hud.offset.x + horseOffset.x, y + hud.offset.y + horseOffset.y )
                    if global.MMO.ACTOR_NPC ~= node:getTag() then
                        node:setLocalZOrder( math.floor(-y) )
                    end
                    if self:CheckAnimCountOM() then
                        node:setLocalZOrder(hud.oz or 0)
                    end
                end
            end
        end
    end
end

function actorHUDManager:setVisible(actorID, htype, index, visible)
    local hudArray = self:checkParam(actorID, htype, index)
    if (not hudArray) or 0 == hudArray then
        return
    end

    local arrayIndex = htype * global.MMO.HUD_COUNT_MAX + index
    local hud = hudArray[arrayIndex]
    if global.MMO.HUD_TYPE_TIPS == htype then
        local childrens = hud.hud:getChildren()
        if #childrens > 0 then
            for _, v in pairs(childrens) do
                v:setVisible( visible )
            end
        end
        hud.hud:setVisible( visible )
    else
        hud.hud:setVisible( visible )
    end
end

function actorHUDManager:RemoveHUD(actorID, htype, index)
    local hudArray = self:checkParam( actorID, htype, index )
    if (not hudArray) or 0 == hudArray then
        return 
    end

    local arrayIndex = htype * global.MMO.HUD_COUNT_MAX + index
    local hud = hudArray[arrayIndex]
    if not hud then
        return 
    end

    if global.MMO.HUD_TYPE_BATCH_LABEL == htype and not self._useBmpFont then
        local hudRoot = hud.isBehide and self._hudRootB[htype] or self._hudRoot[htype]
        hudRoot:removeLabelString( hud.hud )
    elseif global.MMO.HUD_TYPE_SPRITE == htype then
        hud.hud:removeFromParent()
        self:AddAnimCount(-1)
    elseif global.MMO.HUD_TYPE_ANIM == htype then
        hud.hud:removeAllChildren()
        hud.hud:removeFromParent()
        self:AddAnimCount(-1)
    else
        hud.hud:removeFromParent()
    end
    hudArray[arrayIndex] = nil 

    self._hudCache[htype] = self._hudCache[htype] or {}
    self._hudCache[htype][#self._hudCache[htype] + 1] = hud
end

function actorHUDManager:RemoveActorAllHUD(actorID)
    local itr = self._actorsHUD[actorID]
    if itr == nil then
        return
    end

    local hudArray = itr
    local hud       = 0
    local arrayIndex = 0
    for i = 0, global.MMO.HUD_TYPE_MAX do
        for j = 1, global.MMO.HUD_COUNT_MAX do

            arrayIndex = i * global.MMO.HUD_COUNT_MAX + j
            hud        = hudArray[arrayIndex]
            if hud then
                if global.MMO.HUD_TYPE_BATCH_LABEL == i and not self._useBmpFont then
                    local hudRoot = hud.isBehide and self._hudRootB[i] or self._hudRoot[i]
                    hudRoot:removeLabelString(hud.hud)
                elseif global.MMO.HUD_TYPE_ANIM == i then
                    hud.hud:removeAllChildren()
                    hud.hud:removeFromParent()
                    self:AddAnimCount(-1)
                elseif global.MMO.HUD_TYPE_SPRITE == i then
                    hud.hud:removeFromParent()
                    self:AddAnimCount(-1)
                else
                    hud.hud:removeFromParent()
                end
                hudArray[arrayIndex] = nil
                if not self._hudCache[i] then self._hudCache[i] = {} end

                self._hudCache[i] = self._hudCache[i] or {}
                self._hudCache[i][#self._hudCache[i] + 1] = hud
            end
        end
    end
    self._actorsHUD[actorID] = nil
    self._horseOffset[actorID] = nil
end

function actorHUDManager:GetHUDOffset(actorID, htype, index)
    local hudArray = self:checkParam( actorID, htype, index )
    if not hudArray or hudArray == 0 then
        return cc.p(0,0)
    end

    local hud = hudArray[htype * global.MMO.HUD_COUNT_MAX + index]
    return hud.offset
end

function actorHUDManager:SetHUDOffset(actorID, htype, index, offset)
    local hudArray = self:checkParam( actorID, htype, index )
    if not hudArray or hudArray == 0 then
        return 
    end

    local hud = hudArray[htype * global.MMO.HUD_COUNT_MAX + index]
    hud.offset = offset
end

function actorHUDManager:SetSpriteFrame(sprite, id)
    if not id or id == 0 then
        return
    end
    local frameName   = string.format( HUD_SPRITE_FORMAT, id )
    local spriteFrame = global.SpriteFrameCache:getSpriteFrame( frameName )
    if not spriteFrame then
        frameName   = string.format( HUD_SPRITE_FORMAT, global.MMO.HUD_SPRITE_DEFAULT_ID )
        spriteFrame = global.SpriteFrameCache:getSpriteFrame( frameName )
    end
    sprite:setSpriteFrame( spriteFrame )
end

function actorHUDManager:SetAnim( node, animId )
    node:removeAllChildren()
    local anim = global.FrameAnimManager:CreateSFXAnim( animId )
    anim:SetGlobalElapseEnable(true)
    anim:setTag(animId)
    anim:Play( 0, 0, true )
    node:addChild(anim)
end

function actorHUDManager:AddAnimCount(count)
    self._titleAnimCount = self._titleAnimCount + count
end

function actorHUDManager:CheckAnimCountOM()
    return self._titleAnimCount > self._titleMaXCount
end

function actorHUDManager:Pick(pickPos)
    local count = 0
    for k,v in pairs(self._actorsHUD) do
        count = count + 1
        break
    end
    if count == 0 then
        return nil
    end

    local hudArray = 0
    local hud = 0
    local node = 0
    local boundBox = cc.rect(0,0,0,0)
    local anchorPoint = nil
    local contentSize = nil
    for k,v in pairs(self._actorsHUD) do
        hudArray = v
        hud = hudArray[global.MMO.HUD_TYPE_SPRITE * global.MMO.HUD_COUNT_MAX + global.MMO.HUD_SPRITE_TITLE_1]
        if hud then
            node = hud.hud
            if global.MMO.ACTOR_NPC == node:getTag() or global.MMO.ACTOR_MONSTER == node:getTag() or global.MMO.ACTOR_PLAYER == node:getTag() then
                anchorPoint = node:getAnchorPoint()
                contentSize = node:getContentSize()
                boundBox.width = contentSize.width
                boundBox.height = contentSize.height
                boundBox.x = node:getPositionX() - contentSize.width * anchorPoint.x
                boundBox.y = node:getPositionY() - contentSize.height * anchorPoint.y
                if cc.rectContainsPoint( boundBox, pickPos ) then
                    return global.actorManager:GetActor( k )
                end
            end
        end
    end

    return nil
end

--------------------------------骑马时的偏移  BEGIN---------------------------------
function actorHUDManager:GetHorseOffset( actorID )
    if not actorID or not self._horseOffset[actorID] then
        return cc.p(0,0)
    end
    return self._horseOffset[actorID].default or cc.p(0,0)
end

function actorHUDManager:SetHorseOffset( actorID,offset ) 
    if not actorID then
        return
    end
    if not self._horseOffset[actorID] then
        self._horseOffset[actorID] = {}
    end
    self._horseOffset[actorID].default = offset or cc.p(0,0)
end

function actorHUDManager:GetHorseOffsetLabel( actorID )
    if not actorID or not self._horseOffset[actorID] then
        return cc.p(0,0)
    end
    return self._horseOffset[actorID].labelDefault or cc.p(0,0)
end

function actorHUDManager:SetHorseOffsetLabel( actorID,offset )
    if not self._horseOffset[actorID] then
        self._horseOffset[actorID] = {}
    end

    self._horseOffset[actorID].labelDefault = offset or cc.p(0,0)
end
--------------------------------骑马时的偏移  END---------------------------------

return actorHUDManager
