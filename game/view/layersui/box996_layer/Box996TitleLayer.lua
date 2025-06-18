
local BaseLayer = requireLayerUI( "BaseLayer" )
local Box996TitleLayer = class( "Box996TitleLayer", BaseLayer )

local RichTextHelp  = require("util/RichTextHelp")

function Box996TitleLayer:ctor()
    Box996TitleLayer.super.ctor( self )

    self._proxy = global.Facade:retrieveProxy( global.ProxyTable.Box996Proxy )

    self._init_finish = false  --是否初始化完成
end

function Box996TitleLayer.create( data )
    local layer = Box996TitleLayer.new()

    if layer and layer:Init( data ) then
        return layer
    end

    return nil
end

function Box996TitleLayer:Init( data )
    self._root = CreateExport( "box996_ui/box996_title_layer.lua" )
    if not self._root then
        return false
    end

    self:addChild( self._root )

    self._ui = ui_delegate( self._root )


    -- 自己的称号显示
    self._ui.Button_yc_s:addClickEventListener( function()
        if not self._init_finish then
            return
        end
        local state = self._proxy:isShowOneTitle()
        self._proxy:requestBoxTitleState(1, not state)
        local upEventID = state and self._proxy.BOX_UP_TITLE[2] or self._proxy.BOX_UP_TITLE[1]
        self._proxy:requestLogUp(upEventID)
    end )

    -- 他人的称号显示
    self._ui.Button_yc_o:addClickEventListener( function()
        if not self._init_finish then
            return
        end
        local state = self._proxy:isShowOtherTitle()
        self._proxy:requestBoxTitleState(2, not state)
        local upEventID = state and self._proxy.BOX_UP_TITLE[4] or self._proxy.BOX_UP_TITLE[3]
        self._proxy:requestLogUp(upEventID)
    end )

    -- 下载盒子
    self._ui.Button_download:addClickEventListener( function()
        if not self._init_finish then
            return
        end
        -- 下载盒子
        self._proxy:getBox996DownloadURL( 1 )
        self._proxy:requestLogUp(self._proxy.BOX_UP_TITLE[5])
    end)

    if not self._proxy:isBoxOpen() then
        local posx = self._ui.Button_yc_s:getPositionX()
        self._ui.Image_download:setPositionX(posx)
    end

    local animId = 5110
    local anim = self:addAnim( self._ui.Button_download,animId )
    if anim then
        anim:setPosition( 45,-8)
        anim:setScale(1)
    end

    local anim = self:addAnim( self._ui.Button_yc_s,animId )
    if anim then
        anim:setPosition( 80,3)
        anim:setScale(1)
    end

    local anim = self:addAnim( self._ui.Button_yc_o,animId )
    if anim then
        anim:setPosition( 80,3)
        anim:setScale(1)
    end

    self._ui.Text_state_1:enableOutline( cc.Color4B.BLACK, 2 )
    self._ui.Text_state:enableOutline( cc.Color4B.BLACK, 2 )

    self:updateBoxOpenTitle( data.openTitle )

    if not data.isinit then
        self:OnRefresh( self._proxy:getBoxData() or {} )
    end

    return true
end

function Box996TitleLayer:addAnim(parentNode,animId)
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

-- 更新特效
function Box996TitleLayer:updateTitleTx( txid )
    local txNode = self._ui.Node_tx
    txNode:removeAllChildren()
    if tonumber(txid) then
        local anim = global.FrameAnimManager:CreateSFXAnim( tonumber(txid) )
        anim:Play(0,0,true)
        txNode:addChild( anim )
    end
end

-- 更新状态
function Box996TitleLayer:updateTitleState( state )
    self._ui.Text_state:setString(state and GET_STRING(310000401) or GET_STRING(310000400) )
    GUI:Text_setTextColor(self._ui.Text_state, state and "#28ef01" or "#ff0500")
end

-- 更新描述
function Box996TitleLayer:updateTitleDesc( desc )
    local list = self._ui.ListView_attr
    list:removeAllChildren()

    if global.isWinPlayMode then
        list:setItemsMargin(4)
    end

    desc = desc or {}
    local outlineStr = "<outline color='#000000' size='2' >%s</outline>"
    local count = #desc
    local defaultColorID = {250,254,70,58,253}
    for i,v in ipairs(desc) do
        if v and v.desc then
            local indexStr = string.format("<font color='%s' size='%s'>%d、</font>", "#ffffff", SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16, i)
            local colorStyleID = defaultColorID[i]
            local colorHex = colorStyleID and GET_COLOR_BYID(colorStyleID) or "#ffffff"
            local size = SL:GetMetaValue("GAME_DATA", "DEFAULT_FONT_SIZE") or 16
            local desc = string.format("<font color='%s' size='%s'>%s</font>", GET_COLOR_BYID(colorStyleID), SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16, v.desc)
            local str = string.format(outlineStr, indexStr .. desc)
            local textRich = RichTextHelp:CreateRichTextWithXML(str, 280, size, colorHex)
            textRich:formatText()
            list:pushBackCustomItem(textRich)
        end
    end
end

-- 更新自己称号显示状态
function Box996TitleLayer:updateOneButtonTitleState( state )
    local imgPath = string.format("%sbox_996_ui/%s.png",global.MMO.PATH_RES_PRIVATE,state and "hz_yczjch" or "hz_xszjch")
    self._ui.Button_yc_s:loadTextureNormal(imgPath)
    self._ui.Button_yc_s:loadTexturePressed(imgPath)
end

-- 更新他人称号显示状态
function Box996TitleLayer:updateOtherButtonTitleState( state )
    local imgPath = string.format("%sbox_996_ui/%s.png",global.MMO.PATH_RES_PRIVATE,state and "hz_yctrch" or "hz_xstrch")
    self._ui.Button_yc_o:loadTextureNormal(imgPath)
    self._ui.Button_yc_o:loadTexturePressed(imgPath)
end

-- 更新盒子开启游戏提示
function Box996TitleLayer:updateBoxOpenTitle( title )
    local titleNode = self._ui.Node_title
    titleNode:removeAllChildren()

    local str = title
    if not str then
        str = GET_STRING(310000402)
    end

    local outlineStr = "<outline color='#000000' size='2' >%s</outline>"
    local newStr = string.format( outlineStr,str )
    local textRich = RichTextHelp:CreateRichTextWithXML(newStr, 500, 16, "#ffffff")
    textRich:formatText()
    titleNode:addChild(textRich)
end

-- 更新按钮状态
function Box996TitleLayer:updateBtnState( isBoxOpen )
    isBoxOpen = isBoxOpen or false
    self._ui.Button_yc_s:setVisible( isBoxOpen )
    self._ui.Button_yc_o:setVisible( true )
    self._ui.Image_download:setVisible( not isBoxOpen )
end

function Box996TitleLayer:OnRefresh( data )
    if not data then
        return
    end

    release_print( "===data.BoxTitleID: ", data.BoxTitleID, data.BoxTitle)
    self._init_finish = true
    if data.BoxTitleID then
        self:updateTitleTx( data.BoxTitleID )
    end

    if data.BoxTitle then
        self:updateTitleDesc( data.BoxTitle )
    end

    release_print( "Box996TitleLayer: ", data.sState, data.oState)
    self:updateOneButtonTitleState( data.sState == true )

    self:updateOtherButtonTitleState( data.oState == true )
    
    self:updateTitleState( data.isBoxOpen == true )
    self:updateBtnState( data.isBoxOpen == true )
end

return Box996TitleLayer