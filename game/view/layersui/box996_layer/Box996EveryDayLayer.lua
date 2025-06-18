local BaseLayer = requireLayerUI( "BaseLayer" )
local Box996EveryDayLayer = class( "Box996EveryDayLayer", BaseLayer )

local RichTextHelp  = require("util/RichTextHelp")

local function calcListWidth(node_list, defaultWidth)
    local itemCnt = node_list:getChildrenCount()
    if itemCnt > 0 then
        local item = node_list:getItem(0)
        local itemW = item:getContentSize().width
        local listSize = node_list:getContentSize()
        local margin = node_list:getItemsMargin()
        local newW = itemCnt * itemW + (itemCnt-1) * margin
        if newW < 0 or newW > defaultWidth then
            newW = defaultWidth
        end
        node_list:setContentSize(cc.size(newW, listSize.height))
    end
end

function Box996EveryDayLayer:ctor()
    Box996EveryDayLayer.super.ctor( self )

    self._proxy = global.Facade:retrieveProxy( global.ProxyTable.Box996Proxy )
    self._init_finsh = false
end

function Box996EveryDayLayer.create( data )
    local layer = Box996EveryDayLayer.new()
    if layer and layer:Init(data) then
        return layer
    end
    return nil
end

function Box996EveryDayLayer:Init( data )
    self._root = CreateExport( "box996_ui/box996_everyday_layer.lua" )
    if not self._root then
        return false
    end

    self:addChild( self._root )
    
    self._ui = ui_delegate( self._root )

    -- 领取按钮/下载
    self._ui.Button_get:addClickEventListener( function()
        if not self._init_finsh then
            return
        end

        if not self._proxy:isBoxOpen() then
            self._proxy:getBox996DownloadURL( 2 )
            self._proxy:requestLogUp( self._proxy.BOX_UP_EVERY[2] )
            return
        end

        local isGet = self._proxy:getGifGetState(1) --是否已经领取
        if not isGet then --请求领取
            self._proxy:requestBoxReward( 1 )
            self._proxy:requestLogUp( self._proxy.BOX_UP_EVERY[1] )
        end
    end)

    local animId = 5110
    local anim = self:addAnim( self._ui.Button_get,animId )
    if anim then
        anim:setPosition( 45,-8)
        anim:setScale(1)
    end

    self._ui.ListView_rewards:setItemsMargin( 10 )

    self:updateOpenTitle()

    if not data.isinit then
        self:OnRefresh( self._proxy:getBoxData() or {} )
    end
    
    return true
end

function Box996EveryDayLayer:addAnim(parentNode,animId)
    if not animId then
        return
    end
    
    parentNode:removeChildByTag(animId)
    local anim = global.FrameAnimManager:CreateSFXAnim( animId )
    if anim then
        anim:setTag(animId)
        anim:Play( 0, 0, true )
        parentNode:addChild( anim )
    end
    return anim
end

function Box996EveryDayLayer:updateRewards( rewards )
    local list = self._ui.ListView_rewards

    list:removeAllChildren()

    for idx,item in ipairs( rewards or {} ) do
        if item and item ~= "" then
            local panel = self:CreateRewardItem( item )
            list:pushBackCustomItem(panel)
        end
    end

    list:doLayout()
    calcListWidth( list,245 )
end

-- 创建奖励item
function Box996EveryDayLayer:CreateRewardItem( data )
    data = data or {}
    local panel = ccui.Layout:create()
    panel:setAnchorPoint(cc.p(0.5,0.5))

    local goodsItem = GoodsItem:create({index = data.id,count = data.count, bgVisible = true,look = true})

    local newSz = {width=68, height=68}
    panel:setContentSize( cc.size(newSz.width,newSz.height) )


    goodsItem:setPosition(newSz.width/2,newSz.width/2)
    panel:addChild( goodsItem )

    local sfx = self:addAnim( panel,5111 )

    sfx:setScale(1)
    
    sfx:setPosition( newSz.width/2, 10 )

    return panel
end

function Box996EveryDayLayer:updateBtnState( isGet )
    if isGet == nil then
        isGet = self._proxy:getGifGetState(1)
    end
    local btn = self._ui.Button_get
    
    local normalPath = ""
    local pressedPath = ""
    local isBoxOpen = self._proxy:isBoxOpen()
    if isBoxOpen then
        normalPath = string.format("%sbox_996_ui/%s.png", global.MMO.PATH_RES_PRIVATE, isGet and "hz_ylq0" or "hz_lqhz0")
        pressedPath = string.format("%sbox_996_ui/%s.png", global.MMO.PATH_RES_PRIVATE, isGet and "hz_ylq1" or "hz_lqhz1")
    else
        normalPath = string.format("%sbox_996_ui/%s.png", global.MMO.PATH_RES_PRIVATE, "hz_xzhz0")
        pressedPath = string.format("%sbox_996_ui/%s.png", global.MMO.PATH_RES_PRIVATE, "hz_xzhz1")
    end
    
    btn:loadTextureNormal(normalPath)
    btn:loadTexturePressed(pressedPath)
end

function Box996EveryDayLayer:updateOpenTitle( title )
    local titleNode = self._ui.Node_title
    titleNode:removeAllChildren()

    local str = title
    if not str then
        local newTitle = string.format(GET_STRING(310000403),3)
        str = string.format( newTitle,"" )
    end

    local outlineStr = "<outline color='#000000' size='2' >%s</outline>"
    local newStr = string.format( outlineStr,str )
    local textRich = RichTextHelp:CreateRichTextWithXML(newStr, 500, 16, "#ffffff")
    textRich:formatText()
    titleNode:addChild(textRich)
end

function Box996EveryDayLayer:OnRefresh( data )
    if not data then
        return
    end

    self._init_finsh = true

    local rewards = self._proxy:getBoxGiftData( self._proxy.BOX_TYPE.TYPE_EVERY_DAY )
    if rewards and next(rewards) then
        self:updateRewards( rewards )
    end

    local state = false
    if data.gifGet then
        state = self._proxy:getGifGetState(1) 
    end
    self:updateBtnState(state)

    release_print( "===Box996EveryDayLayer: ", data.BoxGift, state)
end

return Box996EveryDayLayer