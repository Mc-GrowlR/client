ssr = ssr or {}
ssr.GUI = ssr.GUI or {}
local GUI = ssr.GUI

local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next
local sfind = string.find
local ssub = string.sub
local slen = string.len
local sbyte = string.byte
local sgsub = string.gsub
local sformat = string.format
local ssplit = string.split
local cjson = require("cjson")
local SUIHelper = require("sui/SUIHelper")
local QuickCell = require("ssr/ssrengine/ssrQuickCell")
local TableViewEx = requireUtil("TableViewEx")


-------------------------------------------------------------
local _, rootRect = checkNotchPhone()
local winWidth = ssr.getWinWidth()
local winHeight = ssr.getWinHeight()
local anchorPoints = {[0]={x=0,y=1}, [1]={x=1,y=1}, [2]={x=0,y=0}, [3]={x=1,y=0}, [4]={x=0.5,y=0.5}}
local winPositions = {[0]={x=rootRect.x,y=winHeight}, [1]={x=winWidth,y=winHeight}, [2]={x=rootRect.x,y=0}, [3]={x=winWidth,y=0}, [4]={x=winWidth/2,y=winHeight/2}}

------------------------------------------------------------
-- check invalid cobj
local function CheckIsInvalidCObject(widget)
    -- 开关，不检测
    if SL:GetMetaValue("GAME_DATA", "disable_check_cobject") == 1 then
        return false
    end

    -- 
    if widget == nil then
        release_print("----------------------------------------")
        release_print("LUA ERROR: target is nil value .")
        release_print(debug.traceback())
        release_print("----------------------------------------")
        return true
    end

    -- 
    if tolua.isnull(widget) then
        release_print("----------------------------------------")
        release_print("LUA ERROR: target is invalid cobj .")
        release_print(debug.traceback())
        release_print("----------------------------------------")
        return true
    end

    return false
end
------------------------------------------------------------
GUI.ATTACH_LEFTTOP      = nil       -- 主界面挂接，左上
GUI.ATTACH_RIGHTTOP     = nil       -- 主界面挂接，右上
GUI.ATTACH_LEFTBOTTOM   = nil       -- 主界面挂接，左下
GUI.ATTACH_RIGHTBOTTOM  = nil       -- 主界面挂接，右下
GUI.ATTACH_MAINTOP      = nil       -- 主界面挂接，顶部栏
GUI.ATTACH_MAINMINIMAP  = nil       -- 主界面挂接，小地图

GUI.ATTACH_PARENT       = nil       -- 当前界面挂接点

function GUI:Attach_LeftTop()
    return GUI.ATTACH_LEFTTOP
end

function GUI:Attach_RightTop()
    return GUI.ATTACH_RIGHTTOP
end

function GUI:Attach_LeftBottom()
    return GUI.ATTACH_LEFTBOTTOM
end

function GUI:Attach_RightBottom()
    return GUI.ATTACH_RIGHTBOTTOM
end

function GUI:Attach_MainTop()
    return GUI.ATTACH_MAINTOP
end

function GUI:Attach_MainMiniMap()
    return GUI.ATTACH_MAINMINIMAP
end

function GUI:Attach_Parent()
    return GUI.ATTACH_PARENT
end

-------------------------------------------------------------
-- 父节点
-- 0         -- 普通面板
-- 1,        -- 通知层
-- 100,      -- 主界面左下(不适配刘海屏)
-- 101,      -- 主界面左上
-- 102,      -- 主界面右上
-- 103,      -- 主界面左下
-- 104,      -- 主界面右下
-- 105,      -- 主界面左中
-- 106,      -- 主界面上中
-- 107,      -- 主界面右中
-- 108,      -- 主界面下中
-- 109,      -- 主界面 - 按钮模块（技能
-- 父节点
GUI.Parent = {}
function GUI:SetGUIParent(index, parent)
    GUI.Parent[index] = parent
end
function GUI:GetSUIParent(index)
    return GUI.Parent[index] or GUI.Parent[0]
end

-- 普通界面的Z轴 (Win不再使用)
function GUI:FindLocalZOrder(ID)
    local LayerFacadeMediator = global.Facade:retrieveMediator("LayerFacadeMediator")
    if not LayerFacadeMediator then
        return 0
    end
    local localZOrder = LayerFacadeMediator:GetLayerLocalZorder({_mediatorName = "__SSR_GUI_MEDIATOR"..(ID and "_"..ID  or "")})
    localZOrder = math.max(localZOrder, 0)
    return localZOrder
end


-------------------------------------------------------------
-- gui
function GUI:GetParent(ID)
    return GUI:GetSUIParent(ID)
end

function GUI:Win_FindParent(ID)
    return GUI:GetSUIParent(ID)
end

-------------------------------------------------------------
--- NEW GUI
GUI.WinLayers = {} -- GUI 界面管理
GUI.Mediators = {} -- GUI 界面管理

function GUI:NewWin_Create(ID, x, y, width, height, hideMain, hideLast, needVoice, escClose, isRevmsg)
    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_WORLD then
        release_print("[GUI ERROR] GUI:NewWin_Create, game world Only", ID)
        return nil
    end
    if not ID then
        release_print("[GUI ERROR] GUI:NewWin_Create, can't find ID", ID)
        return nil
    end
    if GUI.WinLayers[ID] then
        release_print("[GUI WARNING] GUI:NewWin_Create, Win exist, close it", ID)

        -- close, if open
        local window = GUI:GetWindow(nil, ID)
        GUI:NewWin_Close(window)
    end

    -- 默认值
    hideMain = hideMain or false
    hideLast = hideLast or false
    needVoice = needVoice or false
    isRevmsg = isRevmsg or false
    escClose = (escClose == nil or escClose == true) and true or false

    -- new widget
    local widget = cc.Layer:create()
    widget:setName(ID)

    -- 屏蔽触摸
    if isRevmsg then
        local touchLayout = ccui.Layout:create()
        widget:addChild(touchLayout)
        touchLayout:setName("__GUI_WIN_TOUCH")
        touchLayout:setPosition(cc.p(0, 0))
        touchLayout:setContentSize(cc.size(width, height))
        touchLayout:setTouchEnabled(true)
    end

    -- mediator
    local fakeMediator = nil
    if nil == GUI.Mediators[ID] then
        local GUIMediator   = require("ssr/ssrengine/ssrGUIMediator")
        fakeMediator        = GUIMediator.new(ID)
        GUI.Mediators[ID]   = fakeMediator

        -- attr
        x = x or 0
        y = y or 0
        fakeMediator:setSavedPosition(cc.p(x, y))
    else
        fakeMediator        = GUI.Mediators[ID]
    end
    fakeMediator._type      = global.UIZ.UI_NORMAL
    fakeMediator._layer     = widget
    fakeMediator._voice     = needVoice
    fakeMediator._hideMain  = hideMain
    fakeMediator._hideLast  = hideLast
    fakeMediator._escClose  = escClose
    fakeMediator._GUI_ID    = ID

    fakeMediator:OpenLayer()

    return widget
end

function GUI:NewWin_Close(widget)
    if not widget then
        release_print("[GUI ERROR] GUI:NewWin_Close, can't find Win")
        return nil
    end
    if not widget.ID then
        release_print("[GUI ERROR] GUI:NewWin_Close, is valid Win")
        return nil
    end

    ssr.ssrBridge:OnGUINewWinClose( widget.ID )

    local fakeMediator = widget.mediator
    fakeMediator:CloseLayer()
end

function GUI:NewWin_CloseAll()
    while true do
        local key, window = next(GUI.WinLayers)
        if not key or not window then
            break
        end
        GUI:NewWin_Close(window)
    end
end

function GUI:NewWin_CloseByID(ID)
    local window = GUI:GetWindow(nil, ID)
    if not window then
        return
    end

    GUI:NewWin_Close(window)
end

function GUI:NewWin_CloseByNPCID(NPCID)
    for _, v in pairs(GUI.WinLayers) do
        if tolua.isnull(v) then
            GUI.WinLayers[_] = nil
        elseif v.mediator and v.mediator._NPCID == NPCID then
            GUI:NewWin_Close(v)
            break
        end
    end
end

function GUI:GetWindow(parent, ID)
    local slices = ssplit(ID, "/")

    -- find parent
    local window = nil
    if parent == nil then
        window = GUI.WinLayers[slices[1]]
    else
        window = parent:getChildByName(slices[1])
    end
    if not window then
        return nil
    end
    for i = 2, #slices do
        window = window:getChildByName(slices[i])
        if not window then
            return nil
        end
    end

    return window
end

function GUI:NewWin_GetParam(widget)
    return widget.param
end

function GUI:NewWin_SetParam(widget, param)
    widget.param = param
end

function GUI:NewWin_SetESCClose(widget, value)
    if not widget then
        release_print("[GUI ERROR] GUI:NewWin_SetESCClose, can't find Win")
        return
    end
    if not widget.mediator then
        release_print("[GUI ERROR] GUI:NewWin_SetESCClose, win only")
        return
    end

    widget.mediator._escClose = value
end

function GUI:NewWin_SetDrag(widget, dragLayer)
    if not widget then
        release_print("[GUI ERROR] GUI:NewWin_SetDrag, can't find Win")
        return
    end
    if not widget.mediator then
        release_print("[GUI ERROR] GUI:NewWin_SetDrag, win only")
        return
    end

    widget.mediator:setLayerMoveEnable(dragLayer)
end

function GUI:NewWin_BindNPC(widget, npcID)
    if not widget then
        release_print("[GUI ERROR] GUI:NewWin_BindNPC, can't find Win")
        return
    end
    if not widget.mediator then
        release_print("[GUI ERROR] GUI:NewWin_BindNPC, win only")
        return
    end

    widget.mediator._NPCID = npcID
end

function GUI:NewWin_SetTouchZPanel(widget, touchPanel)
    if not widget then
        release_print("[GUI ERROR] GUI:NewWin_SetTouchZPanel, can't find Win")
        return
    end
    if not widget.mediator then
        release_print("[GUI ERROR] GUI:NewWin_SetTouchZPanel, win only")
        return
    end

    widget.mediator:setLayerZPanel(touchPanel)
end

function GUI:NewWin_RegisterGameEvent(widget, eventName, func)
    if not widget then
        release_print("[GUI ERROR] GUI:NewWin_RegisterGameEvent, can't find Win")
        return
    end
    if not widget.mediator then
        release_print("[GUI ERROR] GUI:NewWin_RegisterGameEvent, win only")
        return
    end

    ssr.ssrBridge:NewWin_RegisterGameEvent(widget, eventName, func)
end

-------------------------------------------------------------
GUI.FILENAME_PREFIX = "GUILayout/"

function GUI:Win_Open(filename)
    local clock = os.clock()

    local fileUtil = global.FileUtilCtl
    local newfilename = GUI.FILENAME_PREFIX .. filename ..".lua"
    
    if not fileUtil:isFileExist(newfilename) then
        release_print("[GUI ERROR] GUI:Win_Open, can't find file", newfilename)
        return false
    end

    local clock = os.clock()

    local script = fileUtil:getDataFromFileEx(newfilename)
    local scFunc = nil
    if script ~= "" then
        if _SSR_DEBUG then
            assert(load(script))
        end
        scFunc = load(script)
    end

    if not scFunc then
        release_print("[GUI ERROR] GUI:Win_Open, load lua string error", newfilename)
        return false
    end
    scFunc()

    release_print("[GUI LOG] GUI:Win_Open, load cost(milliseconds) ", filename, (os.clock() - clock) * 1000)

    return true
end

-------------------------------------------------------------
function GUI:Win_Close(widget)
    if not widget then
        release_print("[WARNING] GUI:WinClose can't find Win")
    end

    local LayerFacadeMediator = global.Facade:retrieveMediator("LayerFacadeMediator")
    if LayerFacadeMediator then
        LayerFacadeMediator:RemoveSSRNormalLayerZOrder(widget)
    end

    if widget and widget.Mediator then
        widget.Mediator:CloseLayer()
    elseif widget then
        widget:removeFromParent()
    end
end

function GUI:Win_Create(parent, ID, x, y, width, height, canMove)
    if not ID then
        release_print("[ERROR] GUI:WinCreate can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:WinCreate ID is exists", ID)
        return nil
    end

    -- fix size
    local visibleSize = global.Director:getVisibleSize()
    if not width then
        width = visibleSize.width
    end
    if not height then
        height = visibleSize.height
    end

    local widget = ccui.Layout:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    if not isNeedZOrder then
        parent:addChild(widget)
    end
    widget:setName(ID)
    widget:setLocalZOrder(0)
    
    widget:setPosition(cc.p(x, y))
    widget:setContentSize(cc.size(width, height))

    if canMove then
        local function setOnMovingOpacity(isBegin)
            if CHECK_SETTING and CHECK_SETTING(global.MMO.SETTING_IDX_LAYER_OPACITY) ~= 1 then 
                return
            end
            if isBegin == widget.OnMovingOpacity then
                return
            end
            if not widget then 
                return 
            end
            widget.OnMovingOpacity = isBegin
            ssr.GUI:setChildrenOpacityEnabled(widget, isBegin)
            widget:setOpacity(isBegin and 150 or 255)
        end

        local function checkPos(x, y)
            local minRect = {width = 80, height = 80} -- 预留
            local touchNodeSize = widget:getContentSize()
            local touchNodeAnchor = widget:getAnchorPoint()
            local winSize = global.Director:getWinSize()

            if not widget.maxX then
                widget.maxX = winSize.width + touchNodeSize.width*touchNodeAnchor.x - minRect.width
                widget.minX =  - (touchNodeSize.width*(1-touchNodeAnchor.x) - minRect.width)

                widget.maxY = winSize.height + touchNodeSize.height*touchNodeAnchor.y - minRect.height
                widget.minY =  - (touchNodeSize.height*(1-touchNodeAnchor.y) - minRect.height)
            end

            x = math.max(math.min(x, widget.maxX), widget.minX)
            y = math.max(math.min(y, widget.maxY), widget.minY)
            return x, y
        end
        local basePosX, basePosy = 0, 0
        local function ontouch(sender, event)
            if event == ccui.TouchEventType.began then
                basePosX, basePosy= sender:getPosition()
                widget._firstMove = true
            elseif event == ccui.TouchEventType.moved then
                if widget._firstMove then
                    setOnMovingOpacity(true)
                    widget._firstMove = false
                end
                local sPos = sender:getTouchBeganPosition()
                local ePos = sender:getTouchMovePosition()
                local x = basePosX + ePos.x - sPos.x
                local y = basePosy  + ePos.y - sPos.y
                x, y = checkPos(x, y)
                sender:setPosition(x, y)
            elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
                local endPosX, endPosY = sender:getPosition()
                endPosX, endPosY = checkPos(endPosX, endPosY)
                widget.historyPos = cc.p(endPosX, endPosY)
                setOnMovingOpacity(false)
            end
        end
        widget:setTouchEnabled(true)
        widget:addTouchEventListener(ontouch)
    end

     -- mediator
    if isNeedZOrder then
        local fakeMediator = nil
        if nil == GUI.Mediators[ID] then
            local GUIMediator   = require("ssr/ssrengine/ssrGUIMediator")
            fakeMediator        = GUIMediator.new(ID)
            GUI.Mediators[ID]   = fakeMediator

            -- attr
            x = x or 0
            y = y or 0
            fakeMediator:setSavedPosition(cc.p(x, y))
        else
            fakeMediator        = GUI.Mediators[ID]
        end
        fakeMediator._type      = global.UIZ.UI_NORMAL
        fakeMediator._layer     = widget
        fakeMediator._voice     = false
        fakeMediator._hideMain  = false
        fakeMediator._hideLast  = false
        fakeMediator._escClose  = false
        fakeMediator._GUI_ID    = ID
        widget.Mediator = fakeMediator

        fakeMediator:OpenLayer()
    end

    return widget
end

function GUI:Win_SetInESCClose(widget)
    if not widget then
        release_print("[WARNING] GUI:SetInESCClose can't find Win")
    end
    local SUIComponentMediator = global.Facade:retrieveMediator("SUIComponentMediator")
    SUIComponentMediator:AddToESCList( widget )
end

function GUI:Win_SetBindNPCIndex( widget, npcID )
    if not widget then
        release_print("[WARNING] GUI:SetBindNPCIndex can't find Win")
    end

    local NPCLayerMediator = global.Facade:retrieveMediator("NPCLayerMediator")
    NPCLayerMediator:AddWinBindNPCIdx(widget, npcID)
end

function GUI:Win_SetSwallowRightMouseTouch( widget, state)
    if not widget then
        release_print("[WARNING] GUI:SetSwallowRightMouseTouch can't find Win")
    end

    local function checkNodePos(node, touchPos)
        if tolua.isnull(node) or not next(touchPos) then
            return false
        end
        local worldPos = node:getWorldPosition()
        local anchor = node:getAnchorPoint()
        local content = node:getContentSize()
        local leftPos = worldPos.x - anchor.x*content.width
        local rightPos = worldPos.x + (1-anchor.x)*content.width
        local bottomPos = worldPos.y - anchor.y*content.height
        local topPos = worldPos.y + (1-anchor.y)*content.height
        local isInSide = false
        if touchPos.x > leftPos and  touchPos.x < rightPos and
        touchPos.y > bottomPos and touchPos.y < topPos then
            isInSide = true
        end
        return isInSide
    end

    local function onMouseDown(sender)
        local button = sender:getMouseButton()
        if button == cc.MouseButton.BUTTON_RIGHT then 
            local mousePosX = sender:getCursorX()
            local mousePosY = sender:getCursorY()
            local touchPos = {
                x = mousePosX,
                y = mousePosY
            }
            local isInSide = checkNodePos(widget, touchPos)
            if isInSide then
                sender:stopPropagation()   
            end
        end
    end
    local listener        = cc.EventListenerMouse:create()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    if state then
        listener:registerScriptHandler( onMouseDown, cc.Handler.EVENT_MOUSE_DOWN )
        eventDispatcher:addEventListenerWithSceneGraphPriority( listener, widget )
    else
        eventDispatcher:removeEventListenersForTarget(widget)
    end
end

-- load say
function GUI:LoadSay(parent, ID, str, linkCB)
    if not ID then
        release_print("[ERROR] GUI:LoadSay can't find ID")
        return nil
    end

    local isNeedZOrder = false
    local fakeMediator = nil
    -- 默认父节点
    if not parent or parent == 0 then
        parent = GUI:Win_FindParent(0)
        if parent:getChildByName(ID) then
            release_print("[ERROR] GUI:LoadSay ID is exists", ID)
            return nil
        end
        isNeedZOrder = true

        local visibleSize = global.Director:getVisibleSize()
        local _, rootRect = checkNotchPhone()
        local layout = ccui.Layout:create()
        layout:setContentSize(visibleSize.width, visibleSize.height)
        layout:setPositionX(rootRect.x)

        -- mediator
        if nil == GUI.Mediators[ID] then
            local GUIMediator   = require("ssr/ssrengine/ssrGUIMediator")
            fakeMediator        = GUIMediator.new(ID)
            GUI.Mediators[ID]   = fakeMediator

            fakeMediator:setSavedPosition(cc.p(0, 0))
        else
            fakeMediator        = GUI.Mediators[ID]
        end
        fakeMediator._type      = global.UIZ.UI_NORMAL
        fakeMediator._layer     = layout
        fakeMediator._voice     = false
        fakeMediator._hideMain  = false
        fakeMediator._hideLast  = false
        fakeMediator._escClose  = false
        fakeMediator._GUI_ID    = ID

        parent = layout
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:LoadSay ID is exists", ID)
        return nil
    end

    local contentSize = parent:getContentSize()
    local rootRect = cc.rect(0, 0, contentSize.width, contentSize.height)

    local LexicalHelper = require("sui/LexicalHelper")
    local elements      = LexicalHelper:Parse(str)
    local SUILoader     = require("sui/SUILoader").new()
    local trunk, background = SUILoader:loadContent(elements, linkCB, closeCB, rootRect)
    local widget        = trunk.render
    parent:addChild(widget)
    widget:setName(ID)
    if fakeMediator then
        local element = background and background.element
        if element then
            fakeMediator._escClose      = (tonumber(element.attr.esc) or 1) == 1
            fakeMediator._hideMain      = (tonumber(element.attr.hideMain) or 0) == 1
            fakeMediator._adapet        = (tonumber(element.attr.show) or 0) == 6      --加黑幕
        end
        fakeMediator:OpenLayer()
    end
    widget.Mediator = fakeMediator
    if fakeMediator and background and background.render then
        local element = background.element
        local canmove = (element and tonumber(element.attr.move) or 0) == 1
        if canmove then
            widget.Mediator:setLayerMoveEnable(background.render)
        end
    end

    return widget
end

-- load ccexport
function GUI:LoadExport(parent, ID, filename)
    if not ID then
        release_print("[ERROR] GUI:LoadExport can't set ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:LoadExport ID is exists", ID)
        return nil
    end

    local widget, quickUI = ssr.CreateExport( filename )
    widget:setName(ID)
    widget:setLocalZOrder(0)
    if isNeedZOrder then
        local fakeMediator = nil
        if nil == GUI.Mediators[ID] then
            local GUIMediator   = require("ssr/ssrengine/ssrGUIMediator")
            fakeMediator        = GUIMediator.new(ID)
            GUI.Mediators[ID]   = fakeMediator

            fakeMediator:setSavedPosition(cc.p(0, 0))
        else
            fakeMediator        = GUI.Mediators[ID]
        end
        fakeMediator._type      = global.UIZ.UI_NORMAL
        fakeMediator._layer     = widget
        fakeMediator._voice     = false
        fakeMediator._hideMain  = false
        fakeMediator._hideLast  = false
        fakeMediator._escClose  = false
        fakeMediator._GUI_ID    = ID
        widget.Mediator = fakeMediator

        fakeMediator:OpenLayer()
    else
        parent:addChild(widget)
    end
    return widget, quickUI
end

-------------------------------------------------------------
-- 常用方法

--
function GUI:setPosition(widget, x, y)
    widget:setPosition(cc.p(x, y))
end
function GUI:getPosition(widget)
    return widget:getPosition()
end

--
function GUI:setPositionX(widget, value)
    widget:setPositionX(value)
end
function GUI:getPositionX(widget)
    return widget:getPositionX()
end

--
function GUI:setPositionY(widget, value)
    widget:setPositionY(value)
end
function GUI:getPositionY(widget)
    return widget:getPositionY()
end

--
function GUI:setAnchorPoint(widget, x, y)
    widget:setAnchorPoint(cc.p(x, y))
end
function GUI:getAnchorPoint(widget)
    return widget:getAnchorPoint()
end

--
function GUI:setContentSize(widget, sizeW, sizeH)
    local size = nil
    if nil == sizeH or type(sizeW) == "table" then
        size = { width = sizeW.width, height = sizeW.height }
    else
        size = { width = sizeW, height = sizeH }
    end
    if widget.ignoreContentAdaptWithSize then
        widget:ignoreContentAdaptWithSize(false)
    end
    widget:setContentSize(size)
end
function GUI:getContentSize(widget)
    return widget:getContentSize()
end

--
function GUI:setRotation(widget, value)
    widget:setRotation(value)
end
function GUI:getRotation(widget)
    return widget:getRotation()
end

--
function GUI:setVisible(widget, value)
    widget:setVisible(value)
end
function GUI:getVisible(widget)
    return widget:isVisible()
end

--
function GUI:setOpacity(widget, value)
    widget:setOpacity(value)
end
function GUI:getOpacity(widget)
    widget:getOpacity()
end

--
function GUI:setScale(widget, value)
    widget:setScale(value)
end
function GUI:getScale(widget)
    return widget:getScale()
end

--
function GUI:setScaleX(widget, value)
    widget:setScaleX(value)
end
function GUI:getScaleX(widget)
    return widget:getScaleX()
end

--
function GUI:setScaleY(widget, value)
    widget:setScaleY(value)
end
function GUI:getScaleY(widget)
    return widget:getScaleY()
end

--
function GUI:setFlippedX(widget, value)
    widget:setFlippedX(value)
end
function GUI:getFlippedX(widget)
    return widget:isFlippedX()
end

--
function GUI:setFlippedY(widget, value)
    widget:setFlippedY(value)
end
function GUI:getFlippedY(widget)
    return widget:isFlippedY()
end

--
function GUI:setTouchEnabled(widget, value)
    widget:setTouchEnabled(value)
end
function GUI:getTouchEnabled(widget)
    return widget:isTouchEnabled()
end

--
function GUI:setName(widget, name)
    widget:setName(name)
end
function GUI:getName(widget)
    return widget:getName()
end

--
function GUI:setTag(widget, tag)
    widget:setTag(tag)
end
function GUI:getTag(widget)
    return widget:getTag()
end

-- 
function GUI:getParent(widget)
    return widget:getParent()
end

function GUI:getChildren(widget)
    return widget:getChildren()
end

function GUI:getChildByName(widget, name)
    return widget:getChildByName(name)
end

function GUI:getChildByTag(widget, tag)
    return widget:getChildByTag(tag)
end

function GUI:removeFromParent(widget)
    widget:removeFromParent()
end

function GUI:removeChildByName(widget, name)
    return widget:removeChildByName(name)
end

function GUI:removeAllChildren(widget)
    return widget:removeAllChildren()
end

function GUI:runAction(widget, value)
    widget:runAction(value)
end

function GUI:stopAllActions(widget)
    widget:stopAllActions()
end

function GUI:addOnClick(widget, value)
    widget:addClickEventListener(value)
end

function GUI:addOnTouch(widget, value)
    widget:addTouchEventListener(value)
end

function GUI:addMouseMoveEvent(widget, param)
    global.mouseEventController:registerMouseMoveEvent(
        widget,
        {
            enter = param.onEnterFunc,
            leave = param.onLeaveFunc
        }
    )
end

function GUI:setCascadeOpacityEnabled(widget, value)
    widget:setCascadeOpacityEnabled(value)
end

function GUI:setChildrenOpacityEnabled(widget, value)
    local node_list = {}
    local function seach_child(parente)
        local childCount = parente:getChildrenCount()
        if childCount >= 1 then
            for i = 1, childCount do
                seach_child(parente:getChildren()[i])
            end
        end
        table.insert(node_list, parente)
    end
    seach_child(widget)

    for i,v in ipairs(node_list) do
        v:setCascadeOpacityEnabled(value)
    end
end

function GUI:setCascadeColorEnabled(widget, value)
    widget:setCascadeColorEnabled(value)
end

function GUI:setSwallowTouches(widget, value)
    widget:setSwallowTouches(value)
end

function GUI:posConvertToNodeSpace( widget, value1, value2 )
    if value1 and value2 then
        return widget:convertToNodeSpace({x = value1, y = value2})
    elseif type(value1) == "table" and value1.x then
        return widget:convertToNodeSpace(value1)
    end
end

function GUI:setLocalZOrder(widget, value)
    widget:setLocalZOrder(value)
end

function GUI:addChild( widget, child )
    widget:addChild(child)
end

-------------------------------------------------------------
-- ex
GUI.getChildByID = GUI.getChildByName
GUI.removeChildByID = GUI.removeChildByName

-------------------------------------------------------------
-- Win
function GUI:Win_setShow(widget, show)
    if show == 5 or show == 6 then 
        show = 4
    end
    local anchorPoint = anchorPoints[show] or anchorPoints[4]
    local position = winPositions[show] or cc.p(0, 0)
    widget:setAnchorPoint(anchorPoint)
    widget:setPosition(position)
end

function GUI:Win_setBackGroundColor(widget, value)
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:setBackGroundColor(value)
    widget:setBackGroundColorType(1)
end

function GUI:Win_setBackGroundOpacity(widget, value)
    widget:setBackGroundColorOpacity(value)
end

------------------------------------------------------------
-- Node
function GUI:Node_Create(parent, ID, x, y)
    if not ID then
        release_print("[ERROR] GUI:Node_Create can't find ID")
        return nil
    end

    if not parent then
        release_print("[ERROR] GUI:Node_Create can't find parent", ID)
        return nil
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:Node_Create ID is exists", ID)
        return nil
    end

    local widget = cc.Node:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    
    return widget
end

-------------------------------------------------------------
-- widget
function GUI:Widget_Create(parent, ID, x, y, width, height)
    if not ID then
        release_print("[ERROR] GUI:Widget_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:Widget_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.Widget:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:setContentSize(cc.size(width, height))

    return widget
end


-------------------------------------------------------------
-- image
function GUI:Image_Create(parent, ID, x, y, nimg, resType)
    if not ID then
        release_print("[ERROR] GUI:Image_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:Image_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.ImageView:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    if resType then
        widget:loadTexture(nimg, resType)
    else
        widget:loadTexture(nimg)
    end

    return widget
end

function GUI:Image_loadTexture(widget, filepath, resType)
    if resType then
        widget:loadTexture(filepath, resType)
    else
        widget:loadTexture(filepath)
    end
end

function GUI:Image_setScale9Slice(widget, scale9l, scale9r, scale9t, scale9b)
    widget:setScale9Enabled(true)
    local contentSize   = widget:getContentSize()
    local x             = scale9l
    local y             = scale9t
    local width         = contentSize.width-scale9l-scale9r
    local height        = contentSize.height-scale9t-scale9b
    widget:setCapInsets({x = x, y = y, width = width, height = height})
end

function GUI:Image_SetGrey( widget, isGrey )
    if isGrey then
        Shader_Grey(widget)
    else
        Shader_Normal(widget)
    end
end

-------------------------------------------------------------
-- Button
function GUI:Button_Create(parent, ID, x, y, nimg)
    if not ID then
        release_print("[ERROR] GUI:Button_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:Button_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.Button:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:loadTextureNormal(nimg)
    widget:setTitleFontName(ssr.define.PATH_FONT2)

    return widget
end

function GUI:Button_loadTextureNormal(widget, filepath)
    widget:loadTextureNormal(filepath)
end

function GUI:Button_loadTexturePressed(widget, filepath)
    widget:loadTexturePressed(filepath)
end

function GUI:Button_loadTextureDisabled(widget, filepath)
    widget:loadTextureDisabled(filepath)
end

function GUI:Button_setTitleText(widget, value)
    widget:setTitleText(value)
end

function GUI:Button_setTitleColor(widget, value)
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:setTitleColor(value)
end

function GUI:Button_setTitleFontSize(widget, value)
    widget:setTitleFontSize(value)
end

function GUI:Button_setBright(widget, value)
    widget:setBright(value)
end

function GUI:Button_setMaxLineWidth(widget, value)
    widget:getTitleRenderer():setMaxLineWidth(tonumber(value) or 0)
end

function GUI:Button_titleEnableOutline( widget, color, outline )
    if type(color) == "string" and string.find(color, "#") then
        color = ssr.GetColorFromHexString( color )
    end
    widget:getTitleRenderer():enableOutline(color, outline)
end

function GUI:Button_SetGrey( widget, isGrey )
    if isGrey then
        Shader_Grey(widget)
    else
        Shader_Normal(widget)
    end
end

function GUI:Button_setZoomScale( widget, value )
    widget:setZoomScale(value)
end

function GUI:Button_setScale9Slice(widget, scale9l, scale9r, scale9t, scale9b)
    widget:setScale9Enabled(true)
    local contentSize   = widget:getContentSize()
    local x             = scale9l
    local y             = scale9t
    local width         = contentSize.width-scale9l-scale9r
    local height        = contentSize.height-scale9t-scale9b
    widget:setCapInsets({x = x, y = y, width = width, height = height})
end
-------------------------------------------------------------
-- Text
function GUI:Text_Create(parent, ID, x, y, fontSize, fontColor, str)
    if not ID then
        release_print("[ERROR] GUI:Text_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:Text_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.Text:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:setFontName(ssr.define.PATH_FONT2)
    widget:setFontSize(fontSize)
    if type(fontColor) == "string" and string.find(fontColor, "#") then
        fontColor = ssr.GetColorFromHexString( fontColor )
    end
    widget:setTextColor(fontColor)
    widget:setString(str)

    return widget
end

function GUI:Text_setString(widget, value)
    widget:setString(value)
end

function GUI:Text_getString(widget)
    return widget:getString()
end

function GUI:Text_setTextColor(widget, value)
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:setTextColor(value)
end

function GUI:Text_setFontSize(widget, value)
    widget:setFontSize(value)
end

function GUI:Text_setFontName(widget, value)
    widget:setFontName(value)
end

function GUI:Text_enableOutline(widget, color, size)
    if type(color) == "string" and string.find(color, "#") then
        color = ssr.GetColorFromHexString( color )
    end
    widget:enableOutline(color, size)
end

function GUI:Text_enableUnderline(widget)
    widget:getVirtualRenderer():enableUnderline()
end

function GUI:Text_setMaxLineWidth(widget, width)
    widget:getVirtualRenderer():setMaxLineWidth(tonumber(width) or 0)
end

function GUI:Text_disableEffect( widget, param )
    widget:getVirtualRenderer():disableEffect(param)
end

-------------------------------------------------------------
-- Layout
function GUI:Layout_Create(parent, ID, x, y, width, height, isClip)
    if not ID then
        release_print("[ERROR] GUI:Layout_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:Layout_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.Layout:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:setContentSize(cc.size(width, height))
    if isClip and type(isClip) == "boolean" then
        widget:setClippingEnabled(isClip)
    end
    widget:setClippingType(0)

    return widget
end

function GUI:Layout_setBackGroundColor(widget, value)
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:setBackGroundColor(value)
    widget:setBackGroundColorType(1)
end

function GUI:Layout_setBackGroundColorType(widget, value)
    widget:setBackGroundColorType(value)
end

function GUI:Layout_setBackGroundColorOpacity(widget, value)
    widget:setBackGroundColorOpacity(value)
end

function GUI:Layout_setClippingEnabled(widget, value)
    widget:setClippingEnabled(value)
end

function GUI:Layout_setBackGroundImage(widget, value)
    widget:setBackGroundImage(value, 0)
end

function GUI:Layout_setBackGroundImageScale9Slice(widget, scale9l, scale9r, scale9t, scale9b)
    widget:setBackGroundImageScale9Enabled(true)
    local contentSize   = widget:getContentSize()
    local x             = scale9l
    local y             = scale9t
    local width         = contentSize.width-scale9l-scale9r
    local height        = contentSize.height-scale9t-scale9b
    widget:setBackGroundImageCapInsets({x = x, y = y, width = width, height = height})
end

-------------------------------------------------------------
-- LoadingBar
function GUI:LoadingBar_Create(parent, ID, x, y, nimg, direction)
    if not ID then
        release_print("[ERROR] GUI:LoadingBar_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:LoadingBar_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.LoadingBar:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:loadTexture(nimg)
    widget:setDirection(direction)

    return widget
end

function GUI:LoadingBar_loadTexture(widget, value)
    widget:loadTexture(value)
end

function GUI:LoadingBar_setDirection(widget, value)
    widget:setDirection(value)
end

function GUI:LoadingBar_setPercent(widget, value)
    widget:setPercent(value)
end

function GUI:LoadingBar_getPercent(widget)
    return widget:getPercent()
end

-------------------------------------------------------------
-- TextInput
function GUI:TextInput_Create(parent, ID, x, y, width, height, fontSize)
    if not ID then
        release_print("[ERROR] GUI:TextInput_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:TextInput_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.TextInput:create(cc.size(width, height), ssr.define.PATH_RES_ALPHA)
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:setFont(ssr.define.PATH_FONT2, fontSize)
    widget:setFontColor(cc.c3b(255, 0, 0))

    return widget
end

function GUI:TextInput_setFontColor(widget, value)
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:setFontColor(value)
end

function GUI:TextInput_setFont(widget, value, value2)
    widget:setFont(value, value2)
end

function GUI:TextInput_setFontSize(widget, value)
    widget:setFontSize(value)
end

function GUI:TextInput_setPlaceholderFont(widget, value, value2)
    widget:setPlaceholderFont(value, value2)
end

function GUI:TextInput_setPlaceholderFontColor(widget, value)
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:setPlaceholderFontColor(value)
end

function GUI:TextInput_setPlaceholderFontSize(widget, value)
    widget:setPlaceholderFontSize(value)
end

function GUI:TextInput_setPlaceHolder(widget, value)
    widget:setPlaceHolder(value)
end

function GUI:TextInput_setMaxLength(widget, value)
    widget:setMaxLength(value)
end

function GUI:TextInput_setString(widget, value)
    widget:setString(value)
end

function GUI:TextInput_getString(widget)
    return widget:getString()
end

function GUI:TextInput_setTextHorizontalAlignment(widget, value)
    widget:setTextHorizontalAlignment(value)
end

function GUI:TextInput_setInputFlag(widget, value)
    widget:setInputFlag(value)
end

function GUI:TextInput_setInputMode(widget, value)
    widget:setInputMode(value)
end

function GUI:TextInput_setNativeOffset(widget, value, value1)
    widget:setNativeOffset( cc.p( value, value1 ) )
end

function GUI:TextInput_addOnEvent(widget, eventCB)
    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

-------------------------------------------------------------
-- TextAtlas
function GUI:TextAtlas_Create(parent, ID, x, y, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
    if not ID then
        release_print("[ERROR] GUI:TextAtlas_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:TextAtlas_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.TextAtlas:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:setProperty(stringValue, charMapFile, itemWidth, itemHeight, startCharMap)

    return widget
end

function GUI:TextAtlas_setProperty(widget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
    widget:setProperty(stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
end

function GUI:TextAtlas_setString(widget, value)
    widget:setString(value)
end

function GUI:TextAtlas_getString(widget)
    return widget:getString()
end

-------------------------------------------------------------
-- Slider
function GUI:Slider_Create(parent, ID, x, y, barimg, pbarimg, nimg)
    if not ID then
        release_print("[ERROR] GUI:Slider_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:Slider_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.Slider:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:loadBarTexture(barimg or "res/public/bg_szjm_01.png",0)
    widget:loadProgressBarTexture(pbarimg or "res/public/bg_szjm_02.png",0)
    widget:loadSlidBallTextureNormal(nimg or "res/private/setting_basic/icon_xdtzy_17.png",0)

    return widget
end

function GUI:Slider_loadBarTexture(widget, value)
    widget:loadBarTexture(value)
end

function GUI:Slider_loadProgressBarTexture(widget, value)
    widget:loadProgressBarTexture(value)
end

function GUI:Slider_loadSlidBallTextureNormal(widget, value)
    widget:loadSlidBallTextureNormal(value)
end

function GUI:Slider_setPercent(widget, value)
    widget:setPercent(value)
end

function GUI:Slider_getPercent(widget)
    return widget:getPercent()
end

function GUI:Slider_addOnEvent(widget, eventCB)
    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end
 

-------------------------------------------------------------
-- ListView
function GUI:ListView_Create(parent, ID, x, y, width, height, direction)
    if not ID then
        release_print("[ERROR] GUI:ListView_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:ListView_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.ListView:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:setContentSize(cc.size(width, height))
    widget:setClippingEnabled(true)
    widget:setClippingType(0)
    widget:setTouchEnabled(true)
    widget:setDirection(direction)
    
    return widget
end

function GUI:ListView_setGravity(widget, value )
    widget:setGravity(value)
end

function GUI:ListView_setDirection(widget, value)
    widget:setDirection(value)
end

function GUI:ListView_setItemsMargin(widget, value)
    widget:setItemsMargin(value)
end

function GUI:ListView_setBounceEnabled(widget, value)
    widget:setBounceEnabled(value)
end

function GUI:ListView_setClippingEnabled(widget, value)
    widget:setClippingEnabled(value)
end

function GUI:ListView_pushBackCustomItem(widget, value)
    widget:pushBackCustomItem(value)
end

function GUI:ListView_insertCustomItem(widget, value, value2)
    widget:insertCustomItem(value, value2)
end

function GUI:ListView_removeAllItems(widget)
    widget:removeAllItems()
end

function GUI:ListView_JumpToItem(widget, value)
    local index = math.max(value, 0)
    widget:jumpToItem(index, cc.p(0, 0), cc.p(0, 0))
end

function GUI:ListView_GetItemIndex(widget, value)
    return widget:getIndex(value)
end

function GUI:ListView_doLayout(widget)
    widget:doLayout()
end

function GUI:ListView_setBackGroundColor(widget, value)
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:setBackGroundColor(value)
    widget:setBackGroundColorType(1)
end

function GUI:ListView_setBackGroundOpacity(widget, value)
    widget:setBackGroundColorOpacity(value)
end

function GUI:ListView_setSwallowTouches(widget, value)
    widget:setSwallowTouches(value)
end

function GUI:ListView_getItemCount( widget )
    return #widget:getItems()
end

function GUI:ListView_setInnerContainerSize( widget, value1, value2 )
    if value1 and value2 then
        widget:setInnerContainerSize(cc.size(value1, value2))
    elseif type(value1) == "table" and value1.width then
        widget:setInnerContainerSize(value1)
    end
end

function GUI:ListView_getInnerContainerSize(widget)
    return widget:getInnerContainerSize()
end

function GUI:ListView_getInnerContainerPosition(widget)
    return widget:getInnerContainerPosition()
end

-- bool 是否衰减滚动速度
function GUI:ListView_scrollToPercentVertical(widget, percent, time, bool)
    widget:scrollToPercentVertical(percent, time, bool)
end

function GUI:ListView_jumpToPercentVertical(widget, percent)
    widget:jumpToPercentVertical(percent)
end

function GUI:ListView_addOnScrollEvent(widget, eventCB)
    widget:addScrollViewEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

-------------------------------------------------------------
-- CheckBox
function GUI:CheckBox_Create(parent, ID, x, y, nimg, pimg)
    if not ID then
        release_print("[ERROR] GUI:CheckBox_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:CheckBox_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.CheckBox:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    
    widget:loadTextureBackGround(nimg)
    widget:loadTextureFrontCross(pimg)
    return widget
end

function GUI:CheckBox_loadTextureBackGround(widget, value)
    widget:loadTextureBackGround(value)
end

function GUI:CheckBox_loadTextureFrontCross(widget, value)
    widget:loadTextureFrontCross(value)
end

function GUI:CheckBox_loadTextureFrontCrossDisabled(widget, value)
    widget:loadTextureFrontCrossDisabled(value)
end

function GUI:CheckBox_setSelected(widget, value)
    widget:setSelected(value)
end

function GUI:CheckBox_isSelected(widget)
    return widget:isSelected()
end

function GUI:CheckBox_addOnEvent(widget, eventCB)
    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

-------------------------------------------------------------
-- Effect
function GUI:Effect_Create(parent, ID, x, y, effecttype, effectid, sex, act, dir, speed)
    if not ID then
        release_print("[ERROR] GUI:CheckBox_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if not parent then
        release_print("[ERROR] GUI:Effect_Create can't find parent", ID)
        return nil
    end

    if CheckIsInvalidCObject(parent) then
        return nil
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:CheckBox_Create ID is exists", ID)
        return nil
    end

    sex = sex or 0
    act = act or 0
    dir = dir or 0
    speed = speed or 1


    local widget        = nil
    if effecttype == 0 then
        -- 特效
        widget = global.FrameAnimManager:CreateSFXAnim(effectid)
        widget:Play(0, 0, true, speed)
        
    elseif effecttype == 1 then
        -- NPC
        widget = global.FrameAnimManager:CreateActorNpcAnim(effectid)
        widget:Play(act, dir, true, speed)

    elseif effecttype == 2 then
        -- 怪物
        widget = global.FrameAnimManager:CreateActorMonsterAnim(effectid, act)
        widget:Play(act, dir, true, speed)

    elseif effecttype == 3 then
        -- 技能
        widget = global.FrameAnimManager:CreateSkillEffAnim(effectid, dir)
        widget:Play(act, dir, true, speed)

    elseif effecttype == 4 then
        -- 人物
        widget = global.FrameAnimManager:CreateActorPlayerAnim(effectid, sex, act)
        widget:Play(act, dir, true, speed)

    elseif effecttype == 5 then
        -- 武器
        widget = global.FrameAnimManager:CreateActorPlayerWeaponAnim(effectid, sex, act)
        widget:Play(act, dir, true, speed)

    elseif effecttype == 6 then
        -- 翅膀
        widget = global.FrameAnimManager:CreateActorPlayerWingsAnim(effectid, sex, act)
        widget:Play(act, dir, true, speed)

    elseif effecttype == 7 then
        -- 发型
        widget = global.FrameAnimManager:CreateActorPlayerHairAnim(effectid, sex, act)
        widget:Play(act, dir, true, speed)

    else
        widget = global.FrameAnimManager:CreateSFXAnim(1)
        widget:Play(0, 0, true, speed)
    end

    parent:addChild(widget)
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    return widget
end

function GUI:Effect_Play(widget, act, dir, isLoop, speed, isSequence)
    widget:Stop()
    widget:Play(act, dir, isLoop, speed, isSequence)
end

function GUI:Effect_Stop(widget, frameIndex, act, dir)
    widget:Stop(frameIndex, act, dir)
end

function GUI:Effect_addOnCompleteEvent(widget, eventCB)
    widget:SetAnimEventCallback(eventCB)
end

function GUI:Effect_GetBoundingBox(widget)
    return widget:GetBoundingBox()
end

-------------------------------------------------------------
-- RichText
function GUI:RichText_Create(parent, ID, x, y, str, width, fontSize, fontColor, vspace, hyperlinkCB, isTxt, fontPath)
    if not ID then
        release_print("[ERROR] GUI:CheckBox_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:CheckBox_Create ID is exists", ID)
        return nil
    end

    local color
    if type(fontColor) == "table" then
        color = GetColorHexFromRBG(fontColor)
    end

    local widget = nil
    local RichTextHelp = requireUtil("RichTextHelp")
    if isTxt then
        local ttfConfig = {
            outlineSize = isTxt.outline,
            outlineColor = GET_COLOR_BYID_C3B(isTxt.outlinecolor)
        }
        widget = RichTextHelp:CreateRichTextWithFCOLOR(str, width, fontSize, fontColor, ttfConfig, hyperlinkCB, vspace, fontPath)
    else
        local defaultFont = ssr.define.PATH_FONT2
        widget = RichTextHelp:CreateRichTextWithXML(str, width, fontSize, color or fontColor, fontPath or defaultFont, hyperlinkCB, vspace)
    end
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:formatText()

    return widget
end

-------------------------------------------------------------
-- PageView
function GUI:PageView_Create(parent, ID, x, y, width, height, direction)
    if not ID then
        release_print("[ERROR] GUI:CheckBox_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:CheckBox_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.PageView:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    widget:setClippingType(0)
    widget:setContentSize(cc.size(width, height))
    widget:setClippingEnabled(true)
    widget:setTouchEnabled(true)

    return widget
end

function GUI:PageView_setClippingEnabled(widget, value)
    widget:setClippingEnabled(value)
end

function GUI:PageView_setBackGroundColor(widget, value)
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:setBackGroundColor(value)
    widget:setBackGroundColorType(1)
end

function GUI:PageView_setBackGroundColorType(widget, value)
    widget:setBackGroundColorType(value)
end

function GUI:PageView_setBackGroundColorOpacity(widget, value)
    widget:setBackGroundColorOpacity(value)
end

function GUI:PageView_scrollToItem(widget, index)
    widget:scrollToItem(index)
end

function GUI:PageView_getCurrentPageIndex(widget)
    return widget:getCurrentPageIndex()
end

function GUI:PageView_getItems(widget)
    return widget:getItems()
end

function GUI:PageView_getItemCount(widget)
    return #widget:getItems()
end

function GUI:PageView_addPage(widget, value)
    widget:addPage(value)
end

function GUI:PageView_addOnEvent(widget, eventCB)
    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

-------------------------------------------------------------
-- ProgressTimer
function GUI:ProgressTimer_Create(parent, ID, x, y, img)
    if not ID then
        release_print("[ERROR] GUI:CheckBox_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:CheckBox_Create ID is exists", ID)
        return nil
    end

    local spriteCD = cc.Sprite:create(img)
    local widget = cc.ProgressTimer:create(spriteCD)
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    return widget
end

function GUI:ProgressTimer_setPercentage(widget, value)
    widget:setPercentage(value)
end

function GUI:ProgressTimer_getPercentage(widget)
    return widget:getPercentage()
end

function GUI:ProgressTimer_ProgressFromTo(widget, time, from, to, completeCB)
    widget:runAction(cc.Sequence:create(
        cc.ProgressFromTo:create(time or 0.5, from, to),
        cc.CallFunc:create(completeCB)
    ))
end

-------------------------------------------------------------
-- QuickCell 
function GUI:QuickCell_Create(parent, ID, x, y, w, h, createCB)
    if not ID then
        release_print("[ERROR] GUI:QuickCell_Create can't find ID")
        return nil
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:QuickCell_Create ID is exists", ID)
        return nil
    end

    local widget = QuickCell:Create({
        wid = w,
        hei = h
    })
    if "ccui.ListView" == tolua.type(parent) then
        parent:pushBackCustomItem(widget) 
    else
        parent:addChild(widget) 
    end
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    widget:Update({createCell = createCB})
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:setAnchorPoint(cc.p(0, 0))

    return widget
end

function GUI:QuickCell_refresh(widget)
    widget:Refresh()
end

function GUI:QuickCell_exit(widget)
    widget:Exit()
end

function GUI:QuickCell_sleep(widget)
    widget:Sleep()
end

function GUI:QuickCell_active(widget)
    widget:Active()
end

-------------------------------------------------------------
-- ScrollView
function GUI:ScrollView_Create(parent, ID, x, y, width, height, direction)
    if not ID then
        release_print("[ERROR] GUI:ScrollView_Create can't find ID")
        return nil
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:ScrollView_Create ID is exists", ID)
        return nil
    end

    local scrollViewDirection = {    -- 0水平 1垂直
        [1] = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        [2] = cc.SCROLLVIEW_DIRECTION_HORIZONTAL,
    }

    local widget = ccui.ScrollView:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setContentSize(cc.size(width, height))
    widget:setClippingEnabled(true)
    widget:setClippingType(0)
    widget:setTouchEnabled(true)
    if direction and scrollViewDirection[direction] then
        widget:setDirection(scrollViewDirection[direction]) 
    end
    
    return widget
end

function GUI:ScrollView_setInnerContainerSize(widget, value1, value2)
    if value1 and value2 then 
        widget:setInnerContainerSize(cc.size(value1, value2))
    elseif type(value1) == "table" then
        widget:setInnerContainerSize(value1)
    end
end

function GUI:ScrollView_setDirection(widget, value)
    local scrollViewDirection = {    
        [1] = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        [2] = cc.SCROLLVIEW_DIRECTION_HORIZONTAL,
    }
    if value and scrollViewDirection[value] then
        widget:setDirection(scrollViewDirection[value])
    end
end

function GUI:ScrollView_setBounceEnabled(widget, value)
    widget:setBounceEnabled(value)
end

function GUI:ScrollView_setClippingEnabled(widget, value)
    widget:setClippingEnabled(value)
end

function GUI:ScrollView_scrollToTop(widget, time, boolvalue)
    widget:scrollToTop(time, boolvalue)
end

function GUI:ScrollView_scrollToBottom(widget, time, boolvalue)
    widget:scrollToBottom(time, boolvalue)
end

function GUI:ScrollView_scrollToLeft(widget, time, boolvalue)
    widget:scrollToLeft(time, boolvalue)
end

function GUI:ScrollView_scrollToRight(widget, time, boolvalue)
    widget:scrollToRight(time, boolvalue)
end

function GUI:ScrollView_setBackGroundColor(widget, value)
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:setBackGroundColor(value)
    widget:setBackGroundColorType(1)
end

function GUI:ScrollView_setBackGroundOpacity(widget, value)
    widget:setBackGroundColorOpacity(value)
end

function GUI:ScrollView_addOnScrollEvent(widget, eventCB)
    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

------------------------------------------------------------
--- TableView
function GUI:TableView_Create(parent, ID, x, y, width, height, direction, cellWid, cellHei, num)
    if not ID then
        release_print("[ERROR] GUI:TableView_Create can't find ID")
        return nil
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:TableView_Create ID is exists", ID)
        return nil
    end

    local tableViewDirection = {    -- 0水平 1垂直
        [1] = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        [2] = cc.SCROLLVIEW_DIRECTION_HORIZONTAL,
    }

    local widget = TableViewEx.create({
        size = cc.size(width, height),
        direction = direction and tableViewDirection[direction],  
        cellSizeForTable = function (tv, view, idx)
            return cellWid, cellHei
        end,
        numberOfCellsInTableView = function (tv, view)
            return num
        end,
        tableCellAtIndex  = function (tv, view, idx)
            local i = idx + 1
            local cell = view:dequeueCell()
            if not cell then
                cell = cc.TableViewCell:new()
            else
                cell:removeAllChildren()
            end 

            if ssrGlobal_GUITableViewCell_Create and type(ssrGlobal_GUITableViewCell_Create)  == "function" then
                ssrGlobal_GUITableViewCell_Create(cell, i, ID)
            end

            return cell
        end
    })

    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setContentSize(cc.size(width, height))
    widget:setTouchEnabled(true)

    return widget
end

function GUI:TableView_setDirection( widget, value )
    local tableViewDirection = {  
        [1] = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        [2] = cc.SCROLLVIEW_DIRECTION_HORIZONTAL,
    }
    if value and tableViewDirection[value] then
        widget:setDirection(tableViewDirection[value])
    end
end

function GUI:TableView_setVerticalFillOrder( widget, value )
    widget:setVerticalFillOrder(value)
end

function GUI:TableView_setBackGroundColor(widget, value )
    if type(value) == "string" and string.find(value, "#") then
        value = ssr.GetColorFromHexString( value )
    end
    widget:SetBackColor(value)
end

function GUI:TableView_addTableCellAtIndexEvent( widget, func )
    widget:setTableCellAtIndexHandler(func)
end

function GUI:TableView_addOnTouchedCellEvent( widget, func )
    widget:setTableCellTouchedHandler(func)
end

function GUI:TableView_scrollToCell(widget, index)
    widget:scrollToCell(index)
end

-- TableViewCell 
function GUI:TableViewCell_getIdx( widget )
    if widget.getIdx then
        return widget:getIdx() + 1
    end
end

-------------------------------------------------------------
-- ItemShow
function GUI:ItemShow_Create(parent, ID, x, y, setData)
    if not ID then
        release_print("[ERROR] GUI:ItemShow_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:ItemShow_Create ID is exists", ID)
        return nil
    end

    if not setData then
        release_print("[ERROR] GUI:ItemShow_Create setData is nil", ID)
        return nil
    end

    local widget = ssr.ItemShow:create(setData)
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    
    return widget
end

function GUI:ItemShow_AddReplaceClickEvent(widget, eventCB)
    widget:addReplaceClickEventListener(eventCB)
end

function GUI:ItemShow_AddPressEvent(widget, eventCB)
    widget:addPressCallBack(eventCB)
end

function GUI:ItemShow_AddDoubleEvent(widget, eventCB)
    widget:addDoubleEventListener(eventCB)
end

function GUI:ItemShow_setIconGrey( widget, value)
    widget:setIconGrey(value)
end

function GUI:ItemShow_GetLayoutExtra(widget)
    return widget:GetLayoutExtra()
end

-------------------------------------------------------------
-- ItemBox
function GUI:ItemBox_Create(parent, ID, x, y, img, boxindex, stdmode)
    if not ID then
        release_print("[ERROR] GUI:ItemBox_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:ItemBox_Create ID is exists", ID)
        return nil
    end

    local setData = {}
    setData.img = img
    setData.boxindex = boxindex
    setData.stdmode = stdmode

    local widget = ssr.ItemBox:create(setData)
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    
    return widget
end

function GUI:ItemBox_GetItemData(widget, boxindex)
    return ssr.GetItemBoxDataByIndex(boxindex)
end

function GUI:ItemBox_RemoveBoxData(widget, boxindex)
    ssr.RemoveItemBoxDataByIndex(boxindex)
end

-------------------------------------------------------------
-- Frames
function GUI:Frames_Create(parent, ID, x, y, prefix, suffix, finishframe, ext)
    if not ID then
        release_print("[ERROR] GUI:Frames_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:Frames_Create ID is exists", ID)
        return nil
    end

    finishframe             = tonumber(finishframe)
    local speed             = ext and tonumber(ext.speed) or 100
    local count             = ext and tonumber(ext.count) or 1
    local loop              = ext and tonumber(ext.loop) or -1
    local finishhide        = ext and tonumber(ext.finishhide)


    local img       = SUIHelper.fixImageFileName(prefix .. "1" .. suffix)
    local fullPath  = string.format(getResFullPath("res/%s"), img)

    local widget = ssr.ImageView:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:loadTexture(fullPath)
        
    local function finishCB()
        if finishframe then
            fullPath = string.format(getResFullPath("res/%s"), SUIHelper.fixImageFileName(prefix .. finishframe .. suffix))
            widget:loadTexture(fullPath)
        end
        if finishhide == 1 then
            widget:setVisible(false)
        end
    end

    local index     = 1
    local counting  = 0
    local function delayCB()
        fullPath    = string.format(getResFullPath("res/%s"), SUIHelper.fixImageFileName(prefix .. index .. suffix))
        widget:loadTexture(fullPath)
        
        index       = index + 1
        if index > count then
            index = 1

            counting = counting + 1
            if loop ~= -1 and counting >= loop then
                widget:stopAllActions()
                finishCB()
            end
        end
    end
    ssr.schedule(widget, delayCB, speed*0.01)
    delayCB()

    return widget
end

-------------------------------------------------------------
-- EquipShow
function GUI:EquipShow_Create(parent, ID, x, y, pos, bgtype, showtips, showstar, isHero)
    if not ID then
        release_print("[ERROR] GUI:EquipShow_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:EquipShow_Create ID is exists", ID)
        return nil
    end

    local index       = tonumber(pos) or 0
    local contentSize = cc.size(66, 66)

    local widget = ssr.Widget:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:setContentSize(contentSize)

    local equipData    = ssr.getEquipDataByPos(index)
    if isHero then
        local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        equipData = HeroEquipProxy:GetEquipDataByPos(index)
    end
    if equipData then
        local info = {}
        info.index = equipData.Index
        info.itemData = equipData
        info.look  = showtips
        info.bgVisible = bgtype
        info.starLv = showstar
        local equipItem = ssr.ItemShow:create(info)
        widget:addChild(equipItem)
        equipItem:setName("EQUIPSHOW")
        equipItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
    end

    return widget
end

function GUI:EquipShow_setScale( widget, value )
    if widget and widget:getChildByName("EQUIPSHOW") then
        local showItem = widget:getChildByName("EQUIPSHOW")
        showItem:setScale(value)
    end
end

function GUI:EquipShow_setIconGrey( widget, value )
    if widget and widget:getChildByName("EQUIPSHOW") then
        local showItem = widget:getChildByName("EQUIPSHOW")
        showItem:setIconGrey(value)
    end
end

-------------------------------------------------------------
-- DBItemShow
function GUI:DBItemShow_Create(parent, ID, x, y, makeindex, bgtype, showtips, showstar, isHero)
    if not ID then
        release_print("[ERROR] GUI:DBItemShow_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:DBItemShow_Create ID is exists", ID)
        return nil
    end

    local itemData          = nil
    if not isHero then
        if not itemData then
            local EquipProxy    = global.Facade:retrieveProxy(global.ProxyTable.Equip)
            itemData            = EquipProxy:GetEquipDataByMakeIndex(makeindex)
        end
        if not itemData then
            local BagProxy      = global.Facade:retrieveProxy(global.ProxyTable.Bag)
            itemData            = BagProxy:GetItemDataByMakeIndex(makeindex)
        end
    else
        if not itemData then
            local HeroEquipProxy    = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
            itemData                = HeroEquipProxy:GetEquipDataByMakeIndex(makeindex)
        end
        if not itemData then
            local HeroBagProxy      = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
            itemData                = HeroBagProxy:GetItemDataByMakeIndex(makeindex)
        end
    end

    local contentSize = cc.size(66, 66)

    local widget = ssr.Widget:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:setContentSize(contentSize)
    
    if itemData then
        local info          = {}
        info.index          = itemData.Index
        info.itemData       = itemData
        info.look           = showtips
        info.bgVisible      = bgtype
        info.starLv         = showstar
        local goodsItem     = ssr.ItemShow:create(info)
        widget:addChild(goodsItem)
        goodsItem:setName("DBITEMSHOW")
        goodsItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
    end

    return widget
end

function GUI:DBItemShow_setScale( widget, value )
    if widget and widget:getChildByName("DBITEMSHOW") then
        local showItem = widget:getChildByName("DBITEMSHOW")
        showItem:setScale(value)
    end
end

function GUI:DBItemShow_setIconGrey( widget, value )
    if widget and widget:getChildByName("DBITEMSHOW") then
        local showItem = widget:getChildByName("DBITEMSHOW")
        showItem:setIconGrey(value)
    end
end

function GUI:DBItemShow_setCount( widget, value )
    if widget and widget:getChildByName("DBITEMSHOW") then
        local showItem = widget:getChildByName("DBITEMSHOW")
        showItem:setCount(value)
    end
end

function GUI:DBItemShow_AddReplaceClickEvent(widget, eventCB)
    if widget and widget:getChildByName("DBITEMSHOW") then
        local showItem = widget:getChildByName("DBITEMSHOW")
        showItem:addReplaceClickEventListener(eventCB)
    end
end

function GUI:DBItemShow_AddPressEvent(widget, eventCB)
    if widget and widget:getChildByName("DBITEMSHOW") then
        local showItem = widget:getChildByName("DBITEMSHOW")
        showItem:addPressCallBack(eventCB)
    end
end

function GUI:DBItemShow_AddDoubleEvent(widget, eventCB)
    if widget and widget:getChildByName("DBITEMSHOW") then
        local showItem = widget:getChildByName("DBITEMSHOW")
        showItem:addDoubleEventListener(eventCB)
    end
end

-------------------------------------------------------------
-- TIMETIPS
function GUI:TIMETIPS_Create(parent, ID, x, y, size, color, time, linkCB)
    if not ID then
        release_print("[ERROR] GUI:TIMETIPS_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:TIMETIPS_Create ID is exists", ID)
        return nil
    end

    time  = tonumber(time) or 0

    local widget = ssr.Text:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
  
    widget:setFontName(ssr.define.PATH_FONT2)
    widget:setFontSize(size)
    if type(color) == "string" and string.find(color, "#") then
        color = ssr.GetColorFromHexString( color )
    end
    widget:setTextColor(color)
    widget:setString("")

    local endTime  = time + ssr.GetServerTime()
    local function scheduleCB()
        local remaining = math.max(endTime - ssr.GetServerTime(), 0)
        widget:setString(ssr.SecondToHMS(remaining, true))
        if remaining <= 0 then
            widget:stopAllActions()
            
            -- link
            if linkCB and type(linkCB) == "function" then
                linkCB()
            end
        end
    end
    schedule(widget, scheduleCB, 1)
    scheduleCB()

    return widget
end

function GUI:TIMETIPS_enableOutline(widget, color, size)
    if type(color) == "string" and string.find(color, "#") then
        color = ssr.GetColorFromHexString( color )
    end
    widget:enableOutline(color, size)
end

-------------------------------------------------------------
-- CircleBar
function GUI:CircleBar_Create(parent, ID, x, y, bgImg, barImg, startper, endper, time)
    if not ID then
        release_print("[ERROR] GUI:CircleBar_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:CircleBar_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.ImageView:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:loadTexture(bgImg)

    local contentSize = widget:getContentSize()
    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(barImg))
    widget:addChild(progressTimer)
    progressTimer:setName("PROGRESS_TIMER")
    progressTimer:setPosition(cc.p(contentSize.width / 2 , contentSize.height / 2 ))
    progressTimer:setPercentage(startper)
    local function loadEndCallBack()
        progressTimer:stopAllActions()

        --link
        if widget.link and type(widget.link) == "function" then
            widget.link()
        end
    end
    progressTimer:runAction(
        cc.Sequence:create(
            cc.ProgressFromTo:create(time, startper, endper),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(loadEndCallBack)
        )
    )

    return widget
end

function GUI:CircleBar_setBarOffSet(widget, offsetX, offsetY)
    if widget and widget:getChildByName("PROGRESS_TIMER") then
        local bar = widget:getChildByName("PROGRESS_TIMER")
        local contentSize = widget:getContentSize()
        bar:setPosition(cc.p(contentSize.width / 2 + offsetX, contentSize.height / 2 + offsetY))
    end
end

function GUI:CircleBar_AddEndLinkCB(widget, linkCB)
    if linkCB and type(linkCB) == "function" then
        widget.link = linkCB
    end
end

-------------------------------------------------------------
-- PercentImg 
function GUI:PercentImg_Create(parent, ID, x, y, img, direction, minValue, maxValue)
    if not ID then
        release_print("[ERROR] GUI:PercentImg_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:PercentImg_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.LoadingBar:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:loadTexture(img)

    direction       = tonumber(direction) or 0
    local min       = tonumber(minValue) or 100
    local max       = tonumber(maxValue) or 100
    local percent   = math.floor( min/max * 100) or 100

    if direction  == 0 or direction == 1 then
        widget:setPercent(percent)
        if direction == 1 then
            widget:setDirection(1)
        end

    elseif direction == 2 or direction == 3 then
        local barRenderer = widget:getVirtualRenderer()
        local barRendererTextureSize = widget:getVirtualRendererSize()
        local innerSprite = barRenderer:getSprite()
        local contentSize = widget:getContentSize()
        if direction == 2 then 
            barRenderer:setAnchorPoint(0.5, 1);
            barRenderer:setPosition(contentSize.width*0.5, contentSize.height)
        else
            barRenderer:setAnchorPoint(0.5, 0);
            barRenderer:setPosition(contentSize.width*0.5, 0)
        end
        if innerSprite then
            local rect = innerSprite:getTextureRect()
            rect.height = barRendererTextureSize.height * percent/100
            innerSprite:setTextureRect(rect, innerSprite:isTextureRectRotated(), cc.size(rect.width, rect.height))
            if direction == 2 then
                innerSprite:setFlippedY(true)
            else
                innerSprite:setFlippedY(false)
            end
        end
    end

    -- 加入元变量组件管理
    local isMateValue = false
    if not tonumber(minValue) or not tonumber(maxValue) then
        local metaValue = {}
        local content = minValue
        while content and string.len(content) > 0 do
            local find_info = {sfind(content, "$STM%((.-)%)")}
            local begin_pos = find_info[1]
            local end_pos   = find_info[2]

            if begin_pos and end_pos then
                isMateValue = true

                -- prefix
                if begin_pos ~= 1 then
                    local substr = string.sub(content, 1, begin_pos - 1)
                    table.insert(metaValue, substr)
                end

                -- metaValue
                local slices = ssplit(find_info[3], "_")
                table.insert(metaValue, {key = slices[1], param = slices[2]})

                -- suffix
                content = string.sub(content, end_pos+1, string.len(content))
            else
                table.insert(metaValue, content)
                content = ""
            end
        end

        local metaValue2 = {}
        local content2 = maxValue
        while content2 and string.len(content2) > 0 do
            local find_info = {sfind(content2, "$STM%((.-)%)")}
            local begin_pos = find_info[1]
            local end_pos   = find_info[2]

            if begin_pos and end_pos then
                isMateValue = true

                -- prefix
                if begin_pos ~= 1 then
                    local substr = string.sub(content2, 1, begin_pos - 1)
                    table.insert(metaValue2, substr)
                end

                -- metaValue
                local slices = ssplit(find_info[3], "_")
                table.insert(metaValue2, {key = slices[1], param = slices[2]})

                -- suffix
                content2 = string.sub(content2, end_pos+1, string.len(content))
            else
                table.insert(metaValue2, content2)
                content2 = ""
            end
        end

        if isMateValue then
            widget.useMetaValue = true
            global.Facade:sendNotification(global.NoticeTable.SUIMetaWidgetAdd, {metaValue = metaValue, metaValue2 = metaValue2, widget = widget, lifewidget = widget})
        end
    end

    return widget
end

-------------------------------------------------------------
-- UIModel 
function GUI:UIModel_Create(parent, ID, x, y, sex, feature, scale)
    if not ID then
        release_print("[ERROR] GUI:UIModel_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:UIModel_Create ID is exists", ID)
        return nil
    end

    local widget = ssr.CreateStaticUIModel(sex, feature, scale, {ignoreStaticScale = true})
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))

    return widget
end

-------------------------------------------------------------
-- EQUIPITEMS
function GUI:EQUIPITEMS_Create(parent, ID, x, y, positions, count, row, showstar, itemParam, isHero)
    if not ID then
        release_print("[ERROR] GUI:EQUIPITEMS_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:EQUIPITEMS_Create ID is exists", ID)
        return nil
    end

    local itemWid               = itemParam and itemParam.width or 70
    local itemHei               = itemParam and itemParam.height or 70
    local col                   = math.ceil(count / row)
    local contentSize           = cc.size(col * itemWid, row * itemHei)

    local widget                = ssr.Widget:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:setContentSize(contentSize)

    -- 
    local boxes = {}
    for i = 1, count do
        local x                 = ((i-1)%col + 0.5) * itemWid
        local y                 = contentSize.height - (math.floor((i-1)/col) + 0.5) * itemHei
        local fullPath          = itemParam and itemParam.imgBg  or "res/public/1900000664.png"
        local imageBG           = ssr.ImageView:create()
        widget:addChild(imageBG)
        imageBG:loadTexture(fullPath)
        imageBG:ignoreContentAdaptWithSize(true)
        imageBG:setCapInsets(cc.rect(0, 0, 0, 0))
        imageBG:setScale9Enabled(false)
        imageBG:setTouchEnabled(false)
        imageBG:setAnchorPoint(cc.p(0.5,0.5))
        imageBG:setPosition(cc.p(x, y))
        tinsert(boxes, imageBG)
    end

    -- items
    local items                 = {}
    local EquipProxy            = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local HeroEquipProxy            = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    if positions == "*" then
        local equipTypeConfig   = isHero and HeroEquipProxy:GetEquipTypeConfig() or EquipProxy:GetEquipTypeConfig()
        for equipPos = equipTypeConfig.Equip_Type_Dress, equipTypeConfig.Equip_Type_Shield do
            local equipData     = nil
            if isHero then
                equipData = HeroEquipProxy:GetEquipDataByPos(equipPos)
            else
                equipData = EquipProxy:GetEquipDataByPos(equipPos)
            end
            if equipData then
                tinsert(items, equipData)
            end
        end
    elseif type(positions) == "table"  then
        for _, equipPos in ipairs(positions) do
            local equipData     = nil
            if isHero then
                equipData = HeroEquipProxy:GetEquipDataByPos(equipPos)
            else
                equipData = EquipProxy:GetEquipDataByPos(equipPos)
            end
            if equipData then
                tinsert(items, equipData)
            end
        end
    end

    -- show
    for index, item in ipairs(items) do
        local imageBG           = boxes[index]
        if imageBG then
            local size          = imageBG:getContentSize()
            local goodsItem     = ssr.ItemShow:create({index = item.Index, itemData = item, starLv = showstar})
            imageBG:addChild(goodsItem)
            goodsItem:setPosition(cc.p(size.width/2, size.height/2))
            goodsItem._canLooks = true
            goodsItem:addLookItemInfoEvent(nil, 1)
            
        end
    end

    return widget
end

-------------------------------------------------------------
-- BAGITEMS
function GUI:BAGITEMS_Create(parent, ID, x, y, conditionList, count, row, showstar, itemParam, isHero)
    if not ID then
        release_print("[ERROR] GUI:BAGITEMS_Create can't find ID")
        return nil
    end

    local isNeedZOrder = false
    if not parent or parent == 0 then
        isNeedZOrder = true
        parent = GUI:Win_FindParent(0)
    end

    if parent:getChildByName(ID) then
        release_print("[ERROR] GUI:BAGITEMS_Create ID is exists", ID)
        return nil
    end

    local conditionEx           = conditionList and conditionList.conditionEx
    local conditionOnOff        = conditionList and conditionList.conditionOnOff or 0
    local conditionParam        = conditionList and conditionList.conditionParam
    local conditionT            = conditionList and conditionList.condition or {}
    local excludeT              = conditionList and conditionList.exclude or {}
    local filter1T              = conditionList and conditionList.filter1 or {}
    local filter2T              = conditionList and conditionList.filter2 or {}
    local filter3T              = conditionList and conditionList.filter3 or {}

    local function conditionAble(item)
        if conditionEx and tonumber(conditionEx) == 1 then
            local starLv = item.Star or 0
            if conditionOnOff and conditionOnOff == 0 then
                if conditionParam and starLv < tonumber(conditionParam) then
                    return false
                end
            elseif conditionOnOff == 1 then
                if conditionParam and starLv > tonumber(conditionParam) then
                    return false
                end
            end
        end
        -- 被排除
        for _, v in ipairs(excludeT) do
            if v == item.MakeIndex then
                return false
            end
        end

        -- 道具ID过滤
        for _, v in ipairs(filter1T) do
            if v == item.Index then
                return false
            end
        end

        -- 道具名过滤
        for _, v in ipairs(filter2T) do
            if v == item.Name then
                return false
            end
        end

        -- 道具ID/道具名过滤
        if #filter3T > 0 then
            for _, v in ipairs(filter3T) do
                if tonumber(v) == item.Index or v == item.Name then
                    return true
                end
            end
            return false
        end
      
        -- 筛选
        if conditionT == "*" then
            return true
        end
        for _, v in pairs(conditionT) do
            if v.StdMode == item.StdMode and (not v.Shape or v.Shape == item.Shape) then
                return true
            end
        end
        return false
    end


    local itemWid               = itemParam and itemParam.width or 70
    local itemHei               = itemParam and itemParam.height or 70
    local col                   = math.ceil(count / row)
    local contentSize           = cc.size(col * itemWid, row * itemHei)

    local widget                = ssr.Widget:create()
    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    parent:addChild(widget)
    widget:setLocalZOrder(isNeedZOrder and GUI:FindLocalZOrder() or 0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    widget:setContentSize(contentSize)

    -- 
    local boxes = {}
    for i = 1, count do
        local x                 = ((i-1)%col + 0.5) * itemWid
        local y                 = contentSize.height - (math.floor((i-1)/col) + 0.5) * itemHei
        local fullPath          = itemParam and itemParam.imgBg  or "res/public/1900000664.png"
        local imageBG           = ssr.ImageView:create()
        widget:addChild(imageBG)
        imageBG:loadTexture(fullPath)
        imageBG:ignoreContentAdaptWithSize(true)
        imageBG:setCapInsets(cc.rect(0, 0, 0, 0))
        imageBG:setScale9Enabled(false)
        imageBG:setTouchEnabled(false)
        imageBG:setAnchorPoint(cc.p(0.5,0.5))
        imageBG:setPosition(cc.p(x, y))
        tinsert(boxes, imageBG)
    end

    -- items
    local BagProxy              = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local HeroBagProxy          = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    local BagMaxNum             = isHero and global.MMO.MAX_ITEM_NUMBER or BagProxy:GetMaxBag()
    
    local items                 = {}
    if isHero then
        for i = 1, BagMaxNum do
            local itemMakeIndex     = HeroBagProxy:GetMakeIndexByBagPos(i) 
            if itemMakeIndex then
                local itemData      = HeroBagProxy:GetItemDataByMakeIndex(itemMakeIndex)
                if itemData and conditionAble(itemData) then
                    tinsert(items, itemData)
                end
            end
        end
    else
        for i = 1, BagMaxNum do
            local itemMakeIndex     = BagProxy:GetMakeIndexByBagPos(i) 
            if itemMakeIndex then
                local itemData      = BagProxy:GetItemDataByMakeIndex(itemMakeIndex)
                if itemData and conditionAble(itemData) then
                    tinsert(items, itemData)
                end
            end
        end
    end
    -- show
    for index, item in ipairs(items) do
        local imageBG           = boxes[index]
        if imageBG then
            local size          = imageBG:getContentSize()
            local goodsItem     = ssr.ItemShow:create({index = item.Index, itemData = item, starLv = showstar})
            imageBG:addChild(goodsItem)
            goodsItem:setPosition(cc.p(size.width/2, size.height/2))
            goodsItem._canLooks = true
            goodsItem:addLookItemInfoEvent(nil, 1)
            
        end
    end

    return widget
end

-----------------------------------------------------------
--- Action
-- MoveTo
function GUI:ActionMoveTo(time, x, y)
    return cc.MoveTo:create(time, cc.p(x, y))
end
-- MoveBy
function GUI:ActionMoveBy(time, x, y)
    return cc.MoveBy:create(time, cc.p(x, y))
end

-- ScaleTo
function GUI:ActionScaleTo(time, ratio)
    return cc.ScaleTo:create(time, ratio)
end
-- ScaleBy
function GUI:ActionScaleBy(time, ratio)
    return cc.ScaleBy:create(time, ratio)
end

-- RotateTo
function GUI:ActionRotateTo(time, angle)
    return cc.RotateTo:create(time, angle)
end
-- RotateBy
function GUI:ActionRotateBy(time, angle)
    return cc.RotateBy:create(time, angle)
end

-- FadeIn
function GUI:ActionFadeIn(time)
    return cc.FadeIn:create(time)
end
-- FadeOut
function GUI:ActionFadeOut(time)
    return cc.FadeOut:create(time)
end
-- FadeTo
function GUI:ActionFadeTo(time, opacity)
    return cc.FadeTo:create(time, opacity)
end

-- Blink
function GUI:ActionBlink(time, num)
    return cc.Blink:create(time, num)
end

-- CallFunc
function GUI:CallFunc(callback)
    return cc.CallFunc:create(callback)
end

-- DelayTime
function GUI:DelayTime(time)
    return cc.DelayTime:create(time)
end

function GUI:ActionShow()
    return cc.Show:create()
end

function GUI:ActionHide()
    return cc.Hide:create()
end

-- Sequence
function GUI:ActionSequence( ... )
    return cc.Sequence:create( ... ) 
end

-- Spawn
function GUI:ActionSpawn( ... )
    return cc.Spawn:create( ... ) 
end

-- Repeat
function GUI:ActionRepeat(action, time)
    return cc.Repeat:create(action, time) 
end

-- RepeatForever
function GUI:ActionRepeatForever(action)
    return cc.RepeatForever:create(action)
end

-- EaseBounceIn
function GUI:ActionEaseBounceIn(action)
    return cc.EaseBounceIn:create(action)
end
-- EaseBounceOut
function GUI:ActionEaseBounceOut(action)
    return cc.EaseBounceOut:create(action)
end
-- EaseBounceInOut
function GUI:ActionEaseBounceInOut(action)
    return cc.EaseBounceInOut:create(action)
end

-- EaseBackIn
function GUI:ActionEaseBackIn(action)
    return cc.EaseBackIn:create(action)
end
-- EaseBackOut
function GUI:ActionEaseBackOut(action)
    return cc.EaseBackOut:create(action)
end
-- EaseBackInOut
function GUI:ActionEaseBackInOut(action)
    return cc.EaseBackInOut:create(action)
end

-- EaseBackInOut
function GUI:ActionEaseSineInOut(action)
    return cc.EaseSineInOut:create(action)
end

--EaseElasticIn
function GUI:ActionEaseElasticIn(action)
    return cc.EaseElasticIn:create(action)
end
--EaseElasticOut
function GUI:ActionEaseElasticOut(action)
    return cc.EaseElasticOut:create(action)
end
--EaseElasticInOut
function GUI:ActionEaseElasticInOut(action)
    return cc.EaseElasticInOut:create(action)
end

------------------------------------------
-- timeline
function GUI:Timeline_Window1(widget, timelineCB)
    local action = nil
    if timelineCB then
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 0.8),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)),
            cc.CallFunc:create(timelineCB)
        )
    else
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 0.8),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1))
        )
    end
    widget:runAction(action)
end

function GUI:Timeline_Window2(widget, timelineCB)
    local action = nil
    if timelineCB then
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 0.5),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)),
            cc.CallFunc:create(timelineCB)
        )
    else
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 0.5),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1))
        )
    end
    widget:runAction(action)
end

function GUI:Timeline_Window3(widget, timelineCB)
    local action = nil
    if timelineCB then
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 0),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)),
            cc.CallFunc:create(timelineCB)
        )
    else
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 0),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1))
        )
    end
    widget:runAction(action)
end

function GUI:Timeline_Window4(widget, timelineCB)
    local action = nil
    if timelineCB then
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 1.2),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)),
            cc.CallFunc:create(timelineCB)
        )
    else
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 1.2),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1))
        )
    end
    widget:runAction(action)
end

function GUI:Timeline_Window5(widget, timelineCB)
    local action = nil
    if timelineCB then
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 1.5),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)),
            cc.CallFunc:create(timelineCB)
        )
    else
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 1.5),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1))
        )
    end
    widget:runAction(action)
end

function GUI:Timeline_Window6(widget, timelineCB)
    local action = nil
    if timelineCB then
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 2),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)),
            cc.CallFunc:create(timelineCB)
        )
    else
        action = cc.Sequence:create(
            cc.ScaleTo:create(0, 2),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1))
        )
    end
    widget:runAction(action)
end

function GUI:Timeline_StopAll(widget)
    widget:stopAllActions()
end

function GUI:Timeline_SetTag(action, tag)
    action:setTag(tag)
end

function GUI:Timeline_StopByTag(widget, tag)
    widget:stopActionByTag(tag)
end

function GUI:Timeline_FadeOut(widget, time, timelineCB)
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.FadeOut:create(time), cc.CallFunc:create(timelineCB))
    else
        action = cc.FadeOut:create(time)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_FadeIn(widget, time, timelineCB)
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.FadeIn:create(time), cc.CallFunc:create(timelineCB))
    else
        action = cc.FadeIn:create(time)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_FadeTo(widget, value, time, timelineCB)
    value = value or 1
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.FadeTo:create(time, value), cc.CallFunc:create(timelineCB))
    else
        action = cc.FadeTo:create(time, value)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_ScaleTo(widget, value, time, timelineCB)
    time = time or 1
    value = value or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.ScaleTo:create(time, value), cc.CallFunc:create(timelineCB))
    else
        action = cc.ScaleTo:create(time, value)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_RotateTo(widget, value, time, timelineCB)
    value = value or 1
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.RotateTo:create(time, value), cc.CallFunc:create(timelineCB))
    else
        action = cc.RotateTo:create(time, value)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_MoveTo(widget, value, time, timelineCB)
    value = value or cc.p(0, 0)
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.MoveTo:create(time, value), cc.CallFunc:create(timelineCB))
    else
        action = cc.MoveTo:create(time, value)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_DelayTime(widget, time, timelineCB)
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(timelineCB))
    else
        action = cc.DelayTime:create(time)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_Blink(widget, value, time, timelineCB)
    value = value or 1
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.Blink:create(time, value), cc.CallFunc:create(timelineCB))
    else
        action = cc.Blink:create(time, value)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_MoveBy(widget, value, time, timelineCB)
    value = value or cc.p(0, 0)
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.MoveBy:create(time, value), cc.CallFunc:create(timelineCB))
    else
        action = cc.MoveBy:create(time, value)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_ScaleBy(widget, value, time, timelineCB)
    time = time or 1
    value = value or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.ScaleBy:create(time, value), cc.CallFunc:create(timelineCB))
    else
        action = cc.ScaleBy:create(time, value)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_ScaleBy(widget, value, time, timelineCB)
    time = time or 1
    value = value or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.ScaleBy:create(time, value), cc.CallFunc:create(timelineCB))
    else
        action = cc.ScaleBy:create(time, value)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_RotateBy(widget, value, time, timelineCB)
    value = value or 1
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.RotateBy:create(time, value), cc.CallFunc:create(timelineCB))
    else
        action = cc.RotateBy:create(time, value)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_CallFunc(widget, time, timelineCB)
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(timelineCB))
    else
        action = cc.CallFunc:create(timelineCB)
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_Show(widget, time)
    time = time or 1

    local action = nil
    if time then
        action = cc.Sequence:create(cc.DelayTime:create(time), cc.Show:create())
    else
        action = cc.Show:create()
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_Hide(widget, time)
    time = time or 1

    local action = nil
    if time then
        action = cc.Sequence:create(cc.DelayTime:create(time), cc.Hide:create())
    else
        action = cc.Hide:create()
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_Shake(widget, time, x, y, timelineCB)
    time = time or 1
    x = x or 10
    y = y or 10

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.ActionShake:create(time, x, y), cc.CallFunc:create(timelineCB))
    else
        action = cc.ActionShake:create(time, x, y)
    end
    widget:runAction(action)

    return action
end
-----------------------------------
