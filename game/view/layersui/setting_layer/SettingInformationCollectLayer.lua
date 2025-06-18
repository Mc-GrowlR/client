local BaseLayer = requireLayerUI("BaseLayer")
local SettingInformationCollectLayer = class("SettingInformationCollectLayer", BaseLayer)

local RichTextHelp = require("util/RichTextHelp")

function SettingInformationCollectLayer:ctor()
	SettingInformationCollectLayer.super.ctor(self)

    self._proxy = global.Facade:retrieveProxy( global.ProxyTable.InformationProxy )
end

function SettingInformationCollectLayer.create( data )
	local layer = SettingInformationCollectLayer.new()
	if layer and layer:init( data ) then
		return layer
	end
	return nil
end

function SettingInformationCollectLayer:init(data)
	-- body
	if not data or not next(data) then
		-- return false
	end

    -- root
    local visibleSize   = cc.Director:getInstance():getVisibleSize()
    local Panel_1       = ccui.Layout:create()
    Panel_1:setName( "Panel_1" )
    Panel_1:setContentSize(visibleSize)
    Panel_1:setTouchEnabled( true )
    Panel_1:setSwallowTouches( true )
    self:addChild( Panel_1 )

    -- 背景图
    local csize = {width=600, height=400}
    local Image_bg = ccui.ImageView:create()
    Image_bg:loadTexture("res/public/1900000605.png",0)
    Image_bg:setPosition( visibleSize.width/2, visibleSize.height/2 )
    Image_bg:setTouchEnabled( true )
    Image_bg:setSwallowTouches( true )
    local x             = 30
    local y             = 30
    local width         = 452-60
    local height        = 179-60
    Image_bg:setScale9Enabled(true)
    Image_bg:setCapInsets({x = x, y = y, width = width, height = height})
    Image_bg:setContentSize(csize)
    Panel_1:addChild( Image_bg )

    -- 关闭按钮
    local Button_close = ccui.Button:create()
    Button_close:loadTextureNormal(global.MMO.PATH_RES_PUBLIC .. "1900000510.png")
    Button_close:loadTexturePressed(global.MMO.PATH_RES_PUBLIC .. "1900000511.png")

    local closeBtnSz = Button_close:getContentSize()
    Button_close:setPosition({x=csize.width + closeBtnSz.width/2, y=csize.height - closeBtnSz.height/2})

    Button_close:addClickEventListener(function()
        global.Facade:sendNotification( global.NoticeTable.Layer_SettingInformationCollect_Close )
    end)
    Image_bg:addChild(Button_close)
    
    -- 标题 需要收集的信息类型相关的panel  
    local Panel_main = ccui.Layout:create()
    Panel_main:setName( "Panel_main" )
    Panel_main:setAnchorPoint( cc.p(0.5,0.5) )
    Panel_main:setPosition( csize.width/2, csize.height/2 )
    Panel_main:setContentSize(csize)
    Image_bg:addChild( Panel_main )
    self.Panel_main = Panel_main

    -- 标题
    local data = {
        str = GET_STRING(310000303),
        posx = csize.width/2,
        posy = csize.height - 50
    }
    local Text_title = self:createNewText(data)
    Image_bg:addChild(Text_title)

    -- 内容List
    local innerSize         = {width=500,height=300}
    local ListView_content  = ccui.ListView:create()
    ListView_content:ignoreContentAdaptWithSize(false)
    ListView_content:setClippingEnabled(true)
    ListView_content:setTouchEnabled(true)
    ListView_content:setAnchorPoint(0.5,1)
    ListView_content:setPosition( csize.width/2, csize.height - 100)
    ListView_content:setContentSize( {width=560, height=280} )
    ListView_content:setItemsMargin( 10 )
    ListView_content:setInnerContainerSize( innerSize )
    self.ListView_content = ListView_content

    local ListView_information = ListView_content:cloneEx()
    self.ListView_information = ListView_information 

    local ListView_request = ListView_content:cloneEx()
    self.ListView_request = ListView_request

    local btns = self._proxy:GetConfig()
    for i,v in ipairs( btns ) do
        local btn = self:createContentItem( {name=v.page1name} , function()
            self:updateInformationUI( v )
        end )
        ListView_content:pushBackCustomItem( btn )
    end

    Panel_main:addChild( ListView_content )

    --收集信息Panel
    local Panel_information = ccui.Layout:create()
    Panel_information:setName( "Panel_information" )
    Panel_information:setAnchorPoint( cc.p(0.5,0.5) )
    Panel_information:setPosition( csize.width/2, csize.height/2 )
    Panel_information:setContentSize(csize)
    Image_bg:addChild( Panel_information )
    Panel_information:setVisible( false )
    self.Panel_information = Panel_information

    local Panel_request = Panel_information:cloneEx()
    self.Panel_request = Panel_request

    -- 返回按钮
    local Button_back = self:createNewButton( {name=GET_STRING(310000304)},function()
        self.Panel_main:setVisible( true )
        self.Panel_information:setVisible( false )
        self.Panel_request:setVisible( false )
    end)
    local backBtnSz = Button_back:getContentSize()
    Button_back:setPosition({x=backBtnSz.width/2 + 10, y=csize.height - backBtnSz.height/2 - 10})
    Panel_information:addChild(Button_back)

    ListView_information:setItemsMargin( 15 )
    ListView_information:setContentSize( {width=560, height=280} )
    Panel_information:addChild( ListView_information )

    --请求天数次数Panel
    Panel_request:setName( "Panel_request" )
    Image_bg:addChild( Panel_request )
    Panel_request:setVisible( false )

    self.Panel_request = Panel_request

    ListView_request:setContentSize( {width=120, height=280} )
    Panel_request:addChild( ListView_request )

    return true
end

-- 创建收集信息的ListView的item
function SettingInformationCollectLayer:createContentItem( data,callback )
    data = data or {}
    local Panel_item = ccui.Layout:create()
    Panel_item:setName( "Panel_item" )
    Panel_item:setContentSize(cc.size(560,35))

    local btn = self:createNewButton( data,callback )
    btn:setPosition( cc.p(560/2,0) )
    Panel_item:addChild( btn )
    return Panel_item
end

-- 创建ccui.Text
function SettingInformationCollectLayer:createNewText(data)
    data = data or {}
    local Text_new = ccui.Text:create()
    Text_new:setFontName(global.MMO.PATH_FONT2)
    Text_new:setFontSize(data.fontSzie or 20)
    Text_new:setAnchorPoint( cc.p(0.5,0.5) )
    Text_new:setPosition( data.posx or 0, data.posy or 0 )
    Text_new:setString( data.str or "" )
    return Text_new
end

-- 创建 ccui.Button
function SettingInformationCollectLayer:createNewButton( data,callback )
    data = data or {}
    local Button_new = ccui.Button:create()
    Button_new:setAnchorPoint(cc.p(0.5,0.5))
    Button_new:setPosition( cc.p(120/2,35/2) )
    Button_new:loadTextureNormal(global.MMO.PATH_RES_PUBLIC .. "1900001022.png")
    Button_new:loadTexturePressed(global.MMO.PATH_RES_PUBLIC .. "1900001022.png")
    Button_new:setScale9Enabled(true)
    Button_new:setCapInsets({x = 10, y = 10, width = 75, height = 34})
    Button_new:setContentSize( {width = 120, height = 35} )
    Button_new:setTouchEnabled(true)
    Button_new:setTitleFontName(global.MMO.PATH_FONT2)
    Button_new:setTitleFontSize( 18 )
    Button_new:setTitleText(data.name or "")

    Button_new:addClickEventListener(function()
        if callback then
            callback()
        end
    end)
    return Button_new 
end

-- 收集信息ui
function SettingInformationCollectLayer:updateInformationUI( data )
    self.Panel_main:setVisible( false )
    self.Panel_request:setVisible( false )
    self.Panel_information:setVisible( true )

    self.ListView_information:removeAllChildren()

    data = data or {}
    local config = self._proxy:GetConfigByID( data.id ) or ""

    local btns = self._proxy:PareseInformationName( config.id )

    local day = self._proxy:GetDayByID( data.id )
    local btnName = string.format( GET_STRING(310000305),"",self._proxy:GetDayMath( day ))

    local count = self._proxy:GetInformationCount( day,data.id )
    local countStr = string.format( GET_STRING(310000309),count )
    local txtStr = string.format( GET_STRING(310000305),config.page1name or "",self._proxy:GetDayMath( day ) .. countStr)
    table.insert( btns, {name=btnName,isClick=true, txtStr = txtStr })

    for i, v in ipairs( btns ) do
        v.data = data
        v.tag = i
        local item = self:createInformationItem( v )
        self.ListView_information:pushBackCustomItem( item )
    end
end

-- 创建收集信息的ListView的item
function SettingInformationCollectLayer:createInformationItem( data )
    data = data or {}
    local Panel_item = ccui.Layout:create()
    Panel_item:setName( "Panel_item" )
    Panel_item:setContentSize(cc.size(560,80))
    Panel_item:setTag( data.tag or 0)

    local btn = self:createNewButton( {name = data.name or ""}, function()
        if data.isClick then
            self._refresh_item_tag = Panel_item:getTag()
            self:updateRequestUI( data.data )
        end
    end)
    btn:setPosition( 560/2,45 )
    btn:setName( "Button_Information" )
    Panel_item:addChild( btn )

    local txt = self:createNewText( {fontSize=18,posx=560/2,posy = 25, str="154544" })
    txt:setAnchorPoint( cc.p(0.5,1) )
    txt:ignoreContentAdaptWithSize( false )
    txt:setTextAreaSize( {width=500,height=50} )
    txt:setTextHorizontalAlignment( 1 )
    txt:setName( "Text_Information" )
    txt:setString( data.txtStr or "" )
    Panel_item:addChild( txt )

    return Panel_item
end

-- 请求天数次数ui
function SettingInformationCollectLayer:updateRequestUI( data )
    self.Panel_main:setVisible( false )
    self.Panel_information:setVisible( false )
    self.Panel_request:setVisible( true )

    self.ListView_request:removeAllChildren()

    data = data or {}
    local btns = {
        1,7,30,90,180,365   --天数
    }
    
    for i, v in ipairs( btns ) do
        local btnName = string.format( GET_STRING(310000305),"", self._proxy:GetDayMath(v) )
        local btn = self:createNewButton( {name=btnName}, function()
            --请求
            self._proxy:SetDayByID(data.id,v)
            global.Facade:sendNotification( global.NoticeTable.Layer_SettingInformationCollect_OnRefresh,{day=v,data=data} )          
        end)
        self.ListView_request:pushBackCustomItem( btn )
    end
end

-- 刷新请求的后的数据
function SettingInformationCollectLayer:OnRefresh( data )
    self.Panel_main:setVisible( false )
    self.Panel_request:setVisible( false )
    self.Panel_information:setVisible( true )

    data = data or {}
    if self._refresh_item_tag then
        local day = data.day
        local item = self.ListView_information:getChildByTag( self._refresh_item_tag )
        if item then
            local btn = item:getChildByName("Button_Information")
            if btn then
                if day then
                    local btnName = string.format( GET_STRING(310000305),"",self._proxy:GetDayMath( day ))
                    btn:setTitleText(btnName)
                end
            end

            local txt = item:getChildByName("Text_Information")
            if txt and day then
                local config = data.data or {}
                local count = self._proxy:GetInformationCount( day,config.id ) or 0
                if config.page1name then
                    local countStr = string.format( GET_STRING(310000309),count )
                    local txtStr = string.format( GET_STRING(310000305),config.page1name,self._proxy:GetDayMath( day ) .. countStr )
                    txt:setString(txtStr)
                end
            end
        end
    end
end

return SettingInformationCollectLayer