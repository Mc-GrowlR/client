
local BaseLayer = requireLayerUI( "BaseLayer" )
local Box996GuideLayer = class( "Box996GuideLayer", BaseLayer )

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

function Box996GuideLayer:ctor()
    Box996GuideLayer.super.ctor( self )

    self._proxy = global.Facade:retrieveProxy( global.ProxyTable.Box996Proxy )
end

function Box996GuideLayer.create( data )
    local layer = Box996GuideLayer.new()
    if layer and layer:Init(data) then
        return layer
    end
    return nil
end

function Box996GuideLayer:Init( data )
    self._root = CreateExport( "box996_ui/box996_guide_layer.lua" )
    if not self._root then
        return false
    end

    self:addChild( self._root )

    self._ui = ui_delegate( self._root )

    
    --下载
    self._ui.Button_download:addClickEventListener( function( sender )
        self._proxy:getBox996DownloadURL( 4 )
    end)

    -- 关闭
    self._ui.Panel_touch:addClickEventListener( function( sender )
        global.Facade:sendNotification( global.NoticeTable.Layer_Box996Guide_Close )
    end)

    -- 关闭
    self._ui.Button_close:addClickEventListener( function( sender )
        global.Facade:sendNotification( global.NoticeTable.Layer_Box996Guide_Close )
    end)

    local animId = 5110
    local anim = self:addAnim( self._ui.Button_download,animId )
    if anim then
        anim:setPosition( 45,-8)
        anim:setScale(1)
    end

    local isBoxOpen = self._proxy:isBoxOpen()
    if isBoxOpen then
        local posy = self._ui.ListView_list:getPositionY()
        self._ui.ListView_list:setPositionY(posy-20)
    end

    self:updateButtonState()
    self:updateListView()

    return true
end

function Box996GuideLayer:addAnim(parentNode,animId)
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

-- 更新下载按钮状态
function Box996GuideLayer:updateButtonState()
    local isBoxOpen = self._proxy:isBoxOpen()
    self._ui.Image_download:setVisible( not (isBoxOpen==true) )
end

-- 更新引导item list
function Box996GuideLayer:updateListView()
    local list = self._ui.ListView_list
    list:removeAllChildren()

    local boxData = self._proxy:getBoxData()  or {}

    local imgdata = boxData.BoxGuide and boxData.BoxGuide.guide_img or {}

    for i,v in ipairs( imgdata ) do
        local item = self:createGuideItem( i,v )
        list:pushBackCustomItem( item )
    end

    list:doLayout()
    calcListWidth( list,619 )
end

-- 创建引导item
function Box996GuideLayer:createGuideItem( index,data )
    local item = self._ui.Panel_item:cloneEx()

    if data.downloadCount then
        data.downloadCount = 0
    end

    local bgImg = item:getChildByName("Image_item_bg")
    local imgPath = self:getGuideImgPath( index,data )
    bgImg:ignoreContentAdaptWithSize( true )
    local isVisible = false
    if imgPath then
        isVisible = true
        bgImg:loadTexture( imgPath )
    end
    bgImg:setVisible( isVisible )

    local boxData = self._proxy:getBoxData()  or {}

    local setpdata = boxData.BoxGuide and boxData.BoxGuide.guide_step or {} 
    local guideStr = setpdata[index] and setpdata[index].uname or ""
    local outlineStr = "<outline color='#000000' size='2' >%s</outline>"
    local newStr = string.format( outlineStr,guideStr )
    local textRich = RichTextHelp:CreateRichTextWithXML(newStr, 200, 16, "#ffffff")
    textRich:setAnchorPoint(0.5,0)
    textRich:formatText()
    item:getChildByName("Text_title"):addChild(textRich)
    return item
end

-- 更新引导item
function Box996GuideLayer:updateGuideItem( index, data )
    if not index or not data then
        return
    end
    local item = self._ui.ListView_list:getItem( index-1 )
    if not item then
        return
    end
    if item then
        local imgPath = self:getGuideImgPath( index, data )
        if imgPath then
            local bgImg = item:getChildByName("Image_item_bg")
            if bgImg then
                bgImg:loadTexture( imgPath )
                bgImg:ignoreContentAdaptWithSize( true )
                bgImg:setVisible( true )
            end
        end
    end
end

-- 获取引导本地图片路径  没有就下载
function Box996GuideLayer:getGuideImgPath( index,data )
    data = data or {}
    local picName = data.filename
    local storagePath = self._proxy:getResLocalPanel()

    if picName and  global.FileUtilCtl:isFileExist( storagePath..picName ) then
        return storagePath..picName
    else
        local downloadCount = data.downloadCount or 0
        if downloadCount > 3 then --下载次数超过三次  不重复下载了
            print("download times more than 3")
            return
        end
        data.downloadCount = downloadCount + 1
        local resPath = data.url or nil
        if picName and resPath and resPath ~= "" then
            global.HttpDownloader:AsyncDownloadEasy(resPath, storagePath .. picName,
                function(isOK)
                    global.Facade:sendNotification( global.NoticeTable.Layer_Box996Guide_Refresh,{isUpdateImg=true,index=index,data=data})
                end,
                0
            )
        end
    end
    return nil
end

-- 通知刷新
function Box996GuideLayer:OnRefresh( data )
    if not data then
        return
    end

    if data.isUpdateImg then
        self:updateGuideItem( data.index, data.data )
    end

    release_print( "Box996GuideLayer: ", data.index, data.data)

end

return Box996GuideLayer