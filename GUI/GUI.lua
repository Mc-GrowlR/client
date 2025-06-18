GUI = {}

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
local ssplit = string.split
local sformat = string.format

local scheduleActionTag = 9961
local performActionTag = 9962
local NONEED_PARENT_CODE = -1

-------------------------------------------------------------
local cjson = require("cjson")
local GUIQuickCell = require("GUI/GUIQuickCell")
local TableViewEx = requireUtil("TableViewEx")

-------------------------------------------------------------
-- defines
GUI.PATH_FONT2        = "fonts/font2.ttf"
GUI.PATH_RES_ALPHA    = "res/public/alpha_1px.png"
GUI.FILENAME_PREFIX   = "GUILayout/"
GUI.EXPORTNAME_PREFIX = "GUIExport/"

-------------------------------------------------------------
local checkValueValid = function (value)
    if value == nil then
        return true
    end
    if value == global.MMO.MeTaInvalidKey or value == global.MMO.MeTaInvalidValue then
        return true
    end
    return false
end

-- helper
GUI._disableFixPosition = false
function GUI:DisableFixPosition()
    GUI._disableFixPosition = true
end
local function fixPosition(p)
    if type(p) ~= "table" then
        if checkValueValid(p) or p == "" then
            SL:Print("[GUI ERROR] GUI:setPosition, param nil")
            p = 0
        end
    else
        if checkValueValid(p.x) then
            SL:Print("[GUI ERROR] GUI:setPosition, X nil")
            p.x = 0
        end
        if checkValueValid(p.y) then
            SL:Print("[GUI ERROR] GUI:setPosition, Y nil")
            p.y = 0
        end
    end

    if GUI._disableFixPosition then
        return p
    end
    if tonumber(p) then
        return math.floor(p)
    end

    return cc.p(math.floor(p.x), math.floor(p.y))
end

-- Button Label offset
local setButtonLabelOffset = function (widget)
    local x = widget._x_
    local y = widget._y_
    if x and y then
        widget:getTitleRenderer():setPosition(cc.p(x, y))
    elseif x then
        widget:getTitleRenderer():setPositionX(x)
    elseif y then
        widget:getTitleRenderer():setPositionY(y)
    end
end

-- check invalid cobj
local function CheckIsInvalidCObject(widget)
    -- 开关，不检测
    if SL:GetMetaValue("GAME_DATA", "disable_check_cobject") == 1 then
        return false
    end

    -- 
    if widget == nil then
        release_print("----------------------------------------")
        release_print("LUA ERROR: target is nil value")
        release_print(debug.traceback())
        release_print("----------------------------------------")
        return true
    end

    -- 
    if tolua.isnull(widget) then
        release_print("----------------------------------------")
        release_print("LUA ERROR: target is invalid cobj")
        release_print(debug.traceback())
        release_print("----------------------------------------")
        return true
    end

    return false
end

-------------------------------------------------------------
-- load ccexport
local function GUICreateCCSExport(fileName)
    local ui = require(fileName).create()
    if ui.root then
        local new_widget = ccui.Widget:create()
        new_widget:setAnchorPoint(cc.p(0, 0))

        local children = ui.root:getChildren()
        for _, child in pairs(children) do
            child:removeFromParent()
        end
        for _, child in pairs(children) do
            new_widget:addChild(child)
        end

        local name = ui.root:getName()
        -- 自适应代码
        if name ~= "Layer" and name ~= "Node" then
            local visible = cc.Director:getInstance():getVisibleSize()
            new_widget:setContentSize(visible)
            ccui.Helper:doLayout(new_widget)
        else
            new_widget:setContentSize(ui.root:getContentSize())
        end

        rawset(ui, "root", new_widget)
        return new_widget, ui
    end
    return nil
end

-- load ccexport
function GUI:LoadCCSExport(parent, ID, filename)
    if not ID then
        SL:Print("[GUI ERROR] GUI:LoadCCSExport can't set ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:LoadCCSExport can't find parent")
        return nil
    end

    if SL._DEBUG and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:LoadCCSExport ID is exists", ID)
        return nil
    end

    local widget, quickUI = GUICreateCCSExport( filename )
    parent:addChild(widget)
    widget:setName(ID)

    return widget, quickUI
end

local GetScriptFunc = function (path)
    if not global.FileUtilCtl:isFileExist(path) then
        return false
    end

    local script = global.FileUtilCtl:getDataFromFileEx(path)
    script = sgsub(script, ";", "")

    local scFunc = load(script)
    if not scFunc then
        return false
    end

    local myfunc = scFunc()
    if not myfunc then
        return false
    end

    local func = myfunc.init or myfunc.main
    if not func then
        return false
    end

    return func
end

GUI.WinExports = {}
function GUI:LoadExport(parent, filename, loadCB)
    if not parent then
        SL:Print("[GUI ERROR] GUI:LoadGUIExport can't find parent")
        return nil
    end

    local luafile = GUI.EXPORTNAME_PREFIX .. sgsub(filename, ".lua$", "")
    local newfilename = luafile .. ".lua"

    local clock = os.clock()

    if SL._DEBUG then
        global.FileUtilCtl:purgeCachedEntries()

        local func = GetScriptFunc(newfilename)
        if func then
            func(parent)
        end
    else
        local func = GUI.WinExports[newfilename] or GetScriptFunc(newfilename)
        if func then
            func(parent)
            GUI.WinExports[newfilename] = func
        end
    end

    -- 增加加载回调，兼容H5异步加载写法
    if loadCB then
        loadCB()
    end
end

GUI.WinExportsEx = {}
function GUI:LoadExportEx(parent, filename, page, data)
    if not parent then
        SL:Print("[GUI ERROR] GUI:LoadExportEx can't find parent")
        return nil
    end

    local luafile = GUI.EXPORTNAME_PREFIX .. sgsub(filename, ".lua$", "")
    local newfilename = luafile .. ".lua"

    local clock = os.clock()

    if SL._DEBUG then
        global.FileUtilCtl:purgeCachedEntries()

        local func = GetScriptFunc(newfilename)
        if func then
            func(parent, false, page, data)
            GUI.WinExportsEx[newfilename] = func
        end
    else
        local func = GUI.WinExports[newfilename] or GetScriptFunc(newfilename)
        if func then
            func(parent, false, page, data)
            GUI.WinExportsEx[newfilename] = func
        end
    end
end

-- 更新Export中变量
function GUI:UpdateExportEx(parent, filename, page)
    if not parent then
        SL:Print("[GUI ERROR] GUI:LoadGUIExport can't find parent")
        return nil
    end

    local luafile = GUI.EXPORTNAME_PREFIX .. sgsub(filename, ".lua$", "")
    local newfilename = luafile .. ".lua"

    local func = GUI.WinExportsEx[newfilename]
    if func then
        func(parent, true, page)
    end
end

function GUI:LoadExportVar(parent, filename, data)
    if not parent then
        SL:Print("[GUI ERROR] GUI:LoadExportEx can't find parent")
        return nil
    end

    local luafile = GUI.EXPORTNAME_PREFIX .. sgsub(filename, ".lua$", "")
    local newfilename = luafile .. ".lua"

    local clock = os.clock()

    if SL._DEBUG then
        global.FileUtilCtl:purgeCachedEntries()

        local func = GetScriptFunc(newfilename)
        if func then
            func(parent, data)
            GUI.WinExportsEx[newfilename] = func
        end
    else
        local func = GUI.WinExports[newfilename] or GetScriptFunc(newfilename)
        if func then
            func(parent, data)
            GUI.WinExportsEx[newfilename] = func
        end
    end
end

-- 更新Export中变量
function GUI:UpdateExportVar(parent, filename, data)
    if not parent then
        SL:Print("[GUI ERROR] GUI:LoadGUIExport can't find parent")
        return nil
    end

    local luafile = GUI.EXPORTNAME_PREFIX .. sgsub(filename, ".lua$", "")
    local newfilename = luafile .. ".lua"

    local func = GUI.WinExportsEx[newfilename]
    if func then
        func(parent, data, true)
    end
end

--使用内置的导出目录
function GUI:LoadInternalExport(parent, filename, loadCB)
    if not parent then
        SL:Print("[GUI ERROR] GUI:LoadInternalExport can't find parent")
        return nil
    end

    local luafile = "game/view/export/" .. filename

    if SL._DEBUG then
        package.loaded[luafile] = nil
    end

    local file = require(luafile)

    local func = file.init or file.main
    if func then
        func(parent)
    end

    -- 增加加载回调，兼容H5异步加载写法
    if loadCB then
        loadCB()
    end
end

-- load say
function GUI:LoadSay(parent, ID, str, linkCB)
    if not ID then
        SL:Print("[GUI ERROR] GUI:LoadSay, can't find ID", ID)
        return nil
    end

    local fakeMediator  = nil
    if not parent or parent == 0 then -- WIN 同步ssr
        local visibleSize = global.Director:getVisibleSize()
        local _, rootRect = checkNotchPhone()
        local layout = ccui.Layout:create()
        layout:setContentSize(visibleSize.width, visibleSize.height)
        layout:setPositionX(rootRect.x)

        -- mediator
        if nil == GUI.Mediators[ID] then
            local GUIMediator   = require("GUI/GUIMediator")
            fakeMediator        = GUIMediator.new(ID)
            GUI.Mediators[ID]   = fakeMediator
        else
            fakeMediator        = GUI.Mediators[ID]
        end
        fakeMediator:setSavedPosition(cc.p(0, 0))
        fakeMediator._type      = global.UIZ.UI_NORMAL
        fakeMediator._layer     = layout
        fakeMediator._voice     = false
        fakeMediator._hideMain  = false
        fakeMediator._hideLast  = false
        fakeMediator._escClose  = false
        fakeMediator._GUI_ID    = ID
        fakeMediator._LuaEvent  = {}
        fakeMediator._NetMsgEvent       = {}
        fakeMediator._LuaNetMsgEvent    = {}

        parent = layout
    end

    if parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:LoadSay ID is exists", ID)
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
            fakeMediator._resetPostion  = (tonumber(element.attr.reset) or 1) == 1
            fakeMediator._escClose      = (tonumber(element.attr.esc) or 1) == 1
            fakeMediator._hideMain      = (tonumber(element.attr.hideMain) or 0) == 1
            fakeMediator._adapet        = (tonumber(element.attr.show) or 0) == 6      --加黑幕
        end
        fakeMediator:OpenLayer()

        if background and background.render then
            local element = background.element
            local canmove = (element and tonumber(element.attr.move) or 0) == 1
            if canmove then
                fakeMediator:setLayerMoveEnable(background.render)
            end
        end
        return parent
    end

    return widget
end

-------------------------------------------------------------
GUI.ATTACH_LEFTTOP      = nil       -- 主界面挂接，左上
GUI.ATTACH_RIGHTTOP     = nil       -- 主界面挂接，右上
GUI.ATTACH_LEFTBOTTOM   = nil       -- 主界面挂接，左下
GUI.ATTACH_RIGHTBOTTOM  = nil       -- 主界面挂接，右下
GUI.ATTACH_MAINMINIMAP  = nil       -- 主界面挂接，小地图
GUI.ATTACH_MAINTOP      = nil       -- 主界面挂接，顶部装饰

GUI.ATTACH_PARENT       = nil       -- 当前界面挂节点，挂节点是变化的
GUI.ATTACH_PARENT_UITOP = nil       -- 提供通知层挂接点

GUI._sceneRootNodeF     = nil       -- 场景节点，在前
GUI._sceneRootNodeB     = nil       -- 场景节点，在后

GUI._actorRootNode      = nil       -- ACTOR节点

-- 主界面最底层
GUI.ATTACH_LEFTTOP_B    = nil
GUI.ATTACH_RIGHTTOP_B   = nil
GUI.ATTACH_LEFTBOTTOM_B = nil
GUI.ATTACH_RIGHTBOTTOM_B= nil

-- 主界面最顶层 (高于小地图)
GUI.ATTACH_LEFTTOP_T    = nil
GUI.ATTACH_RIGHTTOP_T   = nil
GUI.ATTACH_LEFTBOTTOM_T = nil
GUI.ATTACH_RIGHTBOTTOM_T= nil

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

function GUI:Attach_MainMiniMap()
    return GUI.ATTACH_MAINMINIMAP
end

function GUI:Attach_MainTop()
    return GUI.ATTACH_MAINTOP
end

function GUI:Attach_Parent()
    return GUI.ATTACH_PARENT
end

function GUI:Attach_UITop()
    return GUI.ATTACH_PARENT_UITOP
end

function GUI:Attach_SceneF()
    return GUI._sceneRootNodeF
end

function GUI:Attach_SceneB()
    return GUI._sceneRootNodeB
end

function GUI:Attach_ActorNode()
    return GUI._actorRootNode
end

-- bottom
function GUI:Attach_LeftTop_B()
    return GUI.ATTACH_LEFTTOP_B
end

function GUI:Attach_RightTop_B()
    return GUI.ATTACH_RIGHTTOP_B
end

function GUI:Attach_LeftBottom_B()
    return GUI.ATTACH_LEFTBOTTOM_B
end

function GUI:Attach_RightBottom_B()
    return GUI.ATTACH_RIGHTBOTTOM_B
end

-- top
function GUI:Attach_LeftTop_T()
    return GUI.ATTACH_LEFTTOP_T
end

function GUI:Attach_RightTop_T()
    return GUI.ATTACH_RIGHTTOP_T
end

function GUI:Attach_LeftBottom_T()
    return GUI.ATTACH_LEFTBOTTOM_T
end

function GUI:Attach_RightBottom_T()
    return GUI.ATTACH_RIGHTBOTTOM_T
end

-- 父节点
GUI._Parent = {}
function GUI:SetGUIParent(index, parent)
    GUI._Parent[index] = parent
end

function GUI:Win_FindParent(ID)
    return GUI._Parent[ID or 0] or GUI._Parent[0]
end

-------------------------------------------------------------
-- gui
function GUI:Win_Open(filename)
    SL:Print("[GUI LOG] GUI:Win_Open", filename)
    local clock = os.clock()

    local fileUtil = global.FileUtilCtl
    local newfilename = GUI.FILENAME_PREFIX .. filename ..".lua"
    
    if not fileUtil:isFileExist(newfilename) then
        SL:Print("[GUI ERROR] GUI:Win_Open, can't find file", newfilename)
        return false
    end

    local clock = os.clock()

    local script = fileUtil:getDataFromFileEx(newfilename)
    local scFunc = nil
    if script ~= "" then
        if SL._DEBUG then
            assert(load(script))
        end
        scFunc = load(script)
    end

    if not scFunc then
        SL:Print("[GUI ERROR] GUI:Win_Open, load lua string error", newfilename)
        return false
    end
    scFunc()

    SL:Print("[GUI LOG] GUI:Win_Open, load cost(milliseconds) ", filename, (os.clock() - clock) * 1000)

    return true
end

function GUI:Win_AddFile(parent, filename)
    local newfilename = GUI.FILENAME_PREFIX .. filename ..".lua"
    if not global.FileUtilCtl:isFileExist(newfilename) then
        SL:Print("[GUI ERROR] GUI:Win_Open, can't find file", newfilename)
        return false
    end
    
    local CUILoader = requireCUI("CUILoader")
    CUILoader:ParseLuaFile2(global.FileUtilCtl:getDataFromFileEx(newfilename), parent)
end

GUI.WinLayers = {} -- GUI 界面管理
GUI.Mediators = {} -- GUI 界面管理
-- orderParam 0主界面 1普通 2通知层
function GUI:Win_Create(ID, x, y, width, height, hideMain, hideLast, needVoice, escClose, isRevmsg, npcID, orderParam)
    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_WORLD then
        SL:Print("[GUI ERROR] GUI:Win_Create, game world Only", ID)
        return nil
    end
    if not ID then
        SL:Print("[GUI ERROR] GUI:Win_Create, can't find ID", ID)
        return nil
    end
    if GUI.WinLayers[ID] then
        SL:Print("[GUI WARNING] GUI:Win_Create, Win exist, close it", ID)

        -- close, if open
        local window = GUI:GetWindow(nil, ID)
        GUI:Win_Close(window)
    end

    -- 默认值
    hideMain = hideMain or false
    hideLast = hideLast or false
    needVoice = (needVoice == nil or needVoice == true) and true or false
    isRevmsg = (isRevmsg == nil or isRevmsg == true) and true or false
    escClose = (escClose == nil or escClose == true) and true or false

    -- new widget
    local widget = cc.Layer:create()
    widget:setName(ID)

    -- attr
    x = x or 0
    y = y or 0

    -- 屏蔽触摸
    if isRevmsg then
        local touchLayout = ccui.Layout:create()
        widget:addChild(touchLayout)
        touchLayout:setName("__GUI_WIN_TOUCH")
        touchLayout:setPosition(cc.p(fixPosition(x), fixPosition(y)))
        touchLayout:setContentSize(cc.size(width, height))
        touchLayout:setTouchEnabled(true)

        if SL:GetMetaValue("WINPLAYMODE") then
            GUI:setMouseEnabled(touchLayout, true)
        end
    end

    -- mediator
    local fakeMediator = nil
    if nil == GUI.Mediators[ID] then
        local GUIMediator   = require("GUI/GUIMediator")
        fakeMediator        = GUIMediator.new(ID)
        GUI.Mediators[ID]   = fakeMediator
    else
        fakeMediator        = GUI.Mediators[ID]
    end
    fakeMediator:setSavedPosition(cc.p(x, y))

    local type = global.UIZ.UI_NORMAL
    if orderParam == 2 then
        type = global.UIZ.UI_NOTICE
    elseif orderParam == 0 then
        type = global.UIZ.UI_MAIN
    end
    fakeMediator._type      = type
    fakeMediator._layer     = widget
    fakeMediator._voice     = needVoice
    fakeMediator._hideMain  = hideMain
    fakeMediator._hideLast  = hideLast
    fakeMediator._escClose  = escClose
    fakeMediator._GUI_ID    = ID
    fakeMediator._NPCID     = npcID
    fakeMediator._LuaEvent  = {}
    fakeMediator._NetMsgEvent       = {}
    fakeMediator._LuaNetMsgEvent    = {}

    fakeMediator:OpenLayer()

    return widget
end

function GUI:Win_BindLuaEvent(widget, eventID, eventTag)
    if not widget then
        SL:Print("[GUI ERROR] GUI:Win_BindLuaEvent, can't find Win")
        return false
    end
    if not widget.ID then
        SL:Print("[GUI ERROR] GUI:Win_BindLuaEvent, invalid Win")
        return false
    end

    if not eventID then
        SL:Print("[GUI ERROR] eventID is null", eventID)
        return false
    end
    if not eventTag then
        SL:Print("[GUI ERROR] eventTag is null", eventTag)
        return false
    end
    
    local fakeMediator = widget.mediator
    fakeMediator._LuaEvent = fakeMediator._LuaEvent or {}
    fakeMediator._LuaEvent[eventID] = fakeMediator._LuaEvent[eventID] or {}
    fakeMediator._LuaEvent[eventID][eventTag] = true
end

local UnBindLuaEvent = function (widget)
    for eID, eTags in pairs(widget.mediator._LuaEvent or {}) do
        for eTag, _ in pairs(eTags or {}) do
            if SLBridge.LUAEvent[eID] and SLBridge.LUAEvent[eID][eTag] then
                SLBridge.LUAEvent[eID][eTag] = nil
            end
        end
    end
    widget.mediator._LuaEvent = {}
end

function GUI:Win_BindNetMsgEvent(widget, msgID)
    if not widget then
        SL:Print("[GUI ERROR] GUI:Win_BindNetMsgEvent, can't find Win")
        return false
    end
    if not widget.ID then
        SL:Print("[GUI ERROR] GUI:Win_BindNetMsgEvent, is valid Win")
        return false
    end

    if not msgID then
        SL:Print("[GUI ERROR] msgID is null", msgID)
        return false
    end

    local fakeMediator = widget.mediator
    fakeMediator._NetMsgEvent = fakeMediator._NetMsgEvent or {}
    fakeMediator._NetMsgEvent[msgID] = true
end

local UnBindNetMsgEvent = function (widget)
    for msgID, _ in pairs(widget.mediator._NetMsgEvent or {}) do
        SL.NetworkUtil:UnRegisterNetworkHandler(msgID)
    end
    widget.mediator._NetMsgEvent = {}
end

function GUI:Win_BindLuaNetMsgEvent(widget, msgID)
    if not widget then
        SL:Print("[GUI ERROR] GUI:Win_BindLuaNetMsgEvent, can't find Win")
        return false
    end
    if not widget.ID then
        SL:Print("[GUI ERROR] GUI:Win_BindLuaNetMsgEvent, is valid Win")
        return false
    end

    if not msgID then
        SL:Print("[GUI ERROR] Lua msgID is null", msgID)
        return false
    end

    local fakeMediator = widget.mediator
    fakeMediator._LuaNetMsgEvent = fakeMediator._LuaNetMsgEvent or {}
    fakeMediator._LuaNetMsgEvent[msgID] = true
end

local UnBindLuaNetMsgEvent = function (widget)
    for msgID, _ in pairs(widget.mediator._LuaNetMsgEvent or {}) do
        SL.NetworkUtil:UnRegisterLuaNetworkHandler(msgID)
    end
    widget.mediator._LuaNetMsgEvent = {}
end

function GUI:Win_Close(widget)
    if not widget then
        SL:Print("[GUI ERROR] GUI:Win_Close, can't find Win")
        return nil
    end
    if not widget.ID then
        SL:Print("[GUI ERROR] GUI:Win_Close, is valid Win")
        return nil
    end

    UnBindLuaEvent(widget)
    UnBindNetMsgEvent(widget)
    UnBindLuaNetMsgEvent(widget)

    local fakeMediator = widget.mediator
    fakeMediator:CloseLayer()
end

function GUI:Win_CloseAll()
    while true do
        local key, window = next(GUI.WinLayers)
        if not key or not window then
            break
        end
        GUI:Win_Close(window)
    end
end

function GUI:Win_CloseByID(ID)
    local window = GUI:GetWindow(nil, ID)
    if not window then
        return
    end

    GUI:Win_Close(window)
end

function GUI:Win_CloseByNPCID(NPCID)
    for _, v in pairs(GUI.WinLayers) do
        if v.mediator and v.mediator._NPCID == tonumber(NPCID) then
            GUI:Win_Close(v)
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
        window = GUI:getChildByName(parent, slices[1])
    end
    if not window then
        return nil
    end
    for i = 2, #slices do
        window = GUI:getChildByName(window, slices[i])
        if not window then
            return nil
        end
    end

    return window
end

function GUI:Win_GetParam(widget)
    return widget.param
end

function GUI:Win_SetParam(widget, param, uitype)
    widget.param = param
end

function GUI:Win_SetESCClose(widget, value)
    if not widget then
        SL:Print("[GUI ERROR] GUI:SetESCClose, can't find Win")
        return
    end
    if not widget.mediator then
        SL:Print("[GUI ERROR] GUI:SetESCClose, win only")
        return
    end

    widget.mediator._escClose = value
end

function GUI:Win_SetSwallowRightMouseTouch(widget, state)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if not widget then
        SL:Print("[GUI WARNING] GUI:SetSwallowRightMouseTouch can't find Win")
        return nil
    end

    local function onMouseDown(sender)
        local button = sender:getMouseButton()
        if button == cc.MouseButton.BUTTON_RIGHT then 
            sender:stopPropagation()   
        end
    end
    local listener        = cc.EventListenerMouse:create()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    if state then
        listener:registerScriptHandler(onMouseDown, cc.Handler.EVENT_MOUSE_DOWN)
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, widget)
    else
        eventDispatcher:removeEventListenersForTarget(widget)
    end
end

function GUI:Win_SetDrag(widget, dragLayer)
    if not widget then
        SL:Print("[GUI ERROR] GUI:Win_SetDrag, can't find Win")
        return
    end
    if not widget.mediator then
        SL:Print("[GUI ERROR] GUI:Win_SetDrag, win only")
        PrintTraceback()
        return
    end

    widget.mediator:setLayerMoveEnable(dragLayer)
end

--拖动页面 透明
function GUI:SetLayerMovingOpacity(b)
    local layerFacadeMediator = global.Facade:retrieveMediator("LayerFacadeMediator")
    layerFacadeMediator:SetOnMovingOpacity(b)
end

function GUI:Win_SetMainHide(widget, value)
    if not widget then
        SL:Print("[GUI ERROR] GUI:Win_SetDrag, can't find Win")
        return
    end
    if not widget.mediator then
        SL:Print("[GUI ERROR] GUI:Win_SetDrag, win only")
        PrintTraceback()
        return
    end

    widget.mediator:setHideMainUI(value)
end

function GUI:Win_BindNPC(widget, npcID)
    if not widget then
        SL:Print("[GUI ERROR] GUI:Win_BindNPC, can't find Win")
        return
    end
    if not widget.mediator then
        SL:Print("[GUI ERROR] GUI:Win_BindNPC, win only")
        return
    end

    widget.mediator._NPCID = npcID
end

function GUI:Win_SetZPanel(widget, zPanel)
    if not widget then
        SL:Print("[GUI ERROR] GUI:Win_SetZPanel, can't find Win")
        return
    end
    if not widget.mediator then
        SL:Print("[GUI ERROR] GUI:Win_SetZPanel, win only")
        return
    end

    widget.mediator:setLayerZPanel(zPanel)
end

function GUI:Win_IsNull(widget)
    if not widget then
        return true
    end
    return tolua.isnull(widget)
end

function GUI:Win_IsNotNull(widget)
    return not GUI:Win_IsNull(widget)
end

function GUI:SetRefreshVarFunc(widget, callback)
    widget._refreshVarFunc = callback
end

function GUI:GetRefreshVarFunc(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    return widget._refreshVarFunc
end

-------------------------------------------------------------
function GUI:setColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setColor(SL:ConvertColorFromHexString(value))
end

--
function GUI:setPosition(widget, x, y)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    x = fixPosition(x)
    if type(x) ~= "table" then
        y = fixPosition(y)
    end

    local originX = widget:getPositionX()
    local originY = widget:getPositionY()
    if originX ~= x or originY ~= y then
        SLHandlerEvent:GetCallBack(widget, WND_EVENT_WND_POS_CHANGE, true)
    end

    widget:setPosition(cc.p(x, y))
end
function GUI:getPosition(widget)
    if CheckIsInvalidCObject(widget) then
        return cc.p(0, 0)
    end

    if widget.getTurePosition then
        return widget:getTurePosition()
    end

    return cc.p(widget:getPosition())
end

--
function GUI:setPositionX(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setPositionX, param nil")
        value = 0
    end


    local x = fixPosition(value)

    local originX = widget:getPositionX()
    if originX ~= x then
        SLHandlerEvent:GetCallBack(widget, WND_EVENT_WND_POS_CHANGE, true)
    end

    widget:setPositionX(x)
end
function GUI:getPositionX(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end

    if widget.getTurePosition then
        return widget:getTurePosition().x
    end

    return widget:getPositionX()
end

--
function GUI:setPositionY(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setPositionY, param nil")
        value = 0
    end

    local y = fixPosition(value)

    local originY = widget:getPositionY()
    if originY ~= y then
        SLHandlerEvent:GetCallBack(widget, WND_EVENT_WND_POS_CHANGE, true)
    end
    
    widget:setPositionY(y)
end
function GUI:getPositionY(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end
    
    if widget.getTurePosition then
        return widget:getTurePosition().y
    end

    return widget:getPositionY()
end

--
function GUI:setAnchorPoint(widget, x, y)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if type(x) ~= "table" and checkValueValid(x) then
        SL:Print("[GUI ERROR] GUI:setAnchorPoint, X nil")
        x = 0
    end

    if type(x) ~= "table" and checkValueValid(y) then
        SL:Print("[GUI ERROR] GUI:setAnchorPoint, Y nil")
        y = 0
    end

    widget:setAnchorPoint(cc.p(x, y))
end
function GUI:getAnchorPoint(widget)
    if CheckIsInvalidCObject(widget) then
        return cc.p(0, 0)
    end

    return widget:getAnchorPoint()
end

function GUI:setIgnoreContentAdaptWithSize(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:ignoreContentAdaptWithSize(value)

    if tolua.type(widget) == "ccui.Button" then
        setButtonLabelOffset(widget)
    end
end

--
function GUI:setContentSize(widget, sizeW, sizeH)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    local size = nil
    if nil == sizeH then
        size = { width = sizeW.width, height = sizeW.height }
    else
        if checkValueValid(sizeW) then
            SL:Print("[GUI ERROR] GUI:setContentSize, width nil")
            sizeW = 0
        end

        if checkValueValid(sizeH) then
            SL:Print("[GUI ERROR] GUI:setContentSize, height nil")
            sizeH = 0
        end

        size = { width = sizeW, height = sizeH }
    end

    local originS = widget:getContentSize()
    if originS.width ~= size.width or originS.height ~= size.height then
        SLHandlerEvent:GetCallBack(widget, WND_EVENT_WND_SIZECHANGE, true)
    end

    if widget.ignoreContentAdaptWithSize then
        widget:ignoreContentAdaptWithSize(false)
    end
    widget:setContentSize(size)
end
function GUI:getContentSize(widget)
    if CheckIsInvalidCObject(widget) then
        return cc.size(0, 0)
    end

    return widget:getContentSize()
end

function GUI:setTag(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setTag, tag nil")
        value = -1
    end

    widget:setTag(value)
end

function GUI:getTag(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end

    return widget:getTag()
end

function GUI:setName(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setName(value)
end

function GUI:setGrey(widget, isGrey)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if isGrey then
        Shader_Grey(widget)
    else
        Shader_Normal(widget)
    end
end

--
function GUI:setRotation(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setRotation, rotate nil")
        value = 0
    end

    widget:setRotation(value)
end
function GUI:getRotation(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end

    return widget:getRotation()
end
function GUI:setRotationSkewX(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setRotationSkewX(value)
end
function GUI:setRotationSkewY(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setRotationSkewY(value)
end

--
function GUI:setVisible(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setVisible, param nil")
        value = false
    end

    local visible = widget:isVisible()

    if visible ~= value then
        SLHandlerEvent:GetCallBack(widget, WND_EVENT_WND_VISIBLE, true)
    end

    widget:setVisible(value)
end
function GUI:getVisible(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    return widget:isVisible()
end

--
function GUI:setOpacity(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setOpacity, opacity nil")
        value = 255
    end

    widget:setOpacity(value)
end
function GUI:getOpacity(widget)
    if CheckIsInvalidCObject(widget) then
        return 255
    end

    return widget:getOpacity()
end

--
function GUI:setScale(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setScale, scale nil")
        value = 1
    end

    local originScale = widget:getScale()
    if originScale ~= value then
        SLHandlerEvent:GetCallBack(widget, WND_EVENT_WND_SIZECHANGE, true)
    end

    widget:setScale(value)
end
function GUI:getScale(widget)
    if CheckIsInvalidCObject(widget) then
        return 1
    end

    return widget:getScale()
end

--
function GUI:setScaleX(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setScaleX, X nil")
        value = 1
    end

    local originScaleX = widget:getScaleX()
    if originScaleX ~= value then
        SLHandlerEvent:GetCallBack(widget, WND_EVENT_WND_SIZECHANGE, true)
    end


    widget:setScaleX(value)
end
function GUI:getScaleX(widget)
    if CheckIsInvalidCObject(widget) then
        return 1
    end

    return widget:getScaleX()
end

--
function GUI:setScaleY(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setScaleY, Y nil")
        value = 1
    end

    local originScaleY = widget:getScaleY()
    if originScaleY ~= value then
        SLHandlerEvent:GetCallBack(widget, WND_EVENT_WND_SIZECHANGE, true)
    end


    widget:setScaleY(value)
end
function GUI:getScaleY(widget)
    if CheckIsInvalidCObject(widget) then
        return 1
    end

    return widget:getScaleY()
end

--
function GUI:setFlippedX(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setFlippedX, X nil")
        value = 0
    end

    widget:setFlippedX(value)
end
function GUI:getFlippedX(widget)
    if CheckIsInvalidCObject(widget) then
        return 1
    end

    return widget:isFlippedX()
end

--
function GUI:setFlippedY(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setFlippedY, Y nil")
        value = 0
    end

    widget:setFlippedY(value)
end
function GUI:getFlippedY(widget)
    if CheckIsInvalidCObject(widget) then
        return 1
    end
    
    return widget:isFlippedY()
end

function GUI:addChild(widget, child)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    if CheckIsInvalidCObject(child) then
        return false
    end
    
    return widget:addChild(child)
end

function GUI:Clone(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:clone()
end

function GUI:setMouseEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setMouseEnabled(value)
end

function GUI:setTouchEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if checkValueValid(value) then
        SL:Print("[GUI ERROR] GUI:setTouchEnabled, param nil")
        value = true
    end
    
    widget:setTouchEnabled(value)
end
function GUI:getTouchEnabled(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:isTouchEnabled()
end

function GUI:getParent(widget)
    if CheckIsInvalidCObject(widget) then
        return nil
    end
    
    return widget:getParent()
end

function GUI:getChildren(widget)
    if CheckIsInvalidCObject(widget) then
        return {}
    end
    
    return widget:getChildren()
end

function GUI:getBoundingBox(widget)
    if CheckIsInvalidCObject(widget) then
        return cc.rect(0, 0, 1, 1)
    end
    
    if widget.GetBoundingBox then
        return widget:GetBoundingBox()
    end

    return widget:getBoundingBox()
end

function GUI:getName(widget)
    if CheckIsInvalidCObject(widget) then
        return ""
    end
    
    return widget:getName()
end

function GUI:getChildByName(widget, name)
    if CheckIsInvalidCObject(widget) then
        return nil
    end
    
    return widget:getChildByName(name)
end

function GUI:getChildByTag(widget, tag)
    if CheckIsInvalidCObject(widget) then
        return nil
    end
    
    return widget:getChildByTag(tag)
end

function GUI:removeFromParent(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeFromParent()
end

function GUI:removeChildByName(widget, name)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeChildByName(name)
end

function GUI:removeAllChildren(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeAllChildren()
end

function GUI:runAction(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:runAction(value)
end

function GUI:stopAllActions(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:stopAllActions()
end

function GUI:getActionByTag(widget, tag)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:getActionByTag(tag)
end

function GUI:stopActionByTag(widget, tag)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:stopActionByTag(tag)
end

function GUI:delayTouchEnabled(widget, delay)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    delay = delay or 0.2

    widget:stopActionByTag(10999)
    widget:setTouchEnabled(false)
    local action = performWithDelay(
        widget,
        function()
            widget:setTouchEnabled(true)
        end,
        delay
    )
    action:setTag(10999)
end

function GUI:addOnClickEvent(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    -- global.ScriptHandlerMgr:removeObjectAllHandlers(widget)
    widget:_addClickEventListener(value)
end

function GUI:addOnTouchEvent(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    global.ScriptHandlerMgr:removeObjectAllHandlers(widget)
    widget:addTouchEventListener(value)
end

function GUI:addMouseMoveEvent(widget, param)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    global.mouseEventController:registerMouseMoveEvent(
        widget,
        {
            enter = param.onEnterFunc,
            inside = param.onInsideFunc,
            leave = param.onLeaveFunc,
            checkIsVisible = param.checkIsVisible,
        }
    )
end

function GUI:addMouseButtonEvent(widget, param)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local function setNoSwallowMouse()
        return -1
    end
    global.mouseEventController:registerMouseButtonEvent(
        widget,
        {
            down_r = (param.onRightDownFunc or param.OnRightDownFunc) or setNoSwallowMouse,
            up_r = param.OnRightUpFunc,
            special_r = param.OnSpecialRFunc,
            scroll = param.OnScrollFunc,
            moveTouch = param.needTouchPos,
        }
    )
end

function GUI:addMouseOverTips(widget, str, pos, anr, param)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addMouseOverTips(str, pos, anr, param)
end

function GUI:addMouseStyle(widget, styleType)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addMouseStyle(styleType)
end

function GUI:addOnLongTouchEvent(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    -- global.ScriptHandlerMgr:removeObjectAllHandlers(widget)
    widget:_addLongTouchEventListener(value)
end

function GUI:setLocalZOrder(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setLocalZOrder(value)
end

function GUI:setCascadeOpacityEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setCascadeOpacityEnabled(value)
end

function GUI:setChildrenCascadeOpacityEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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

function GUI:getWorldPosition(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:getWorldPosition()
end

function GUI:getTouchMovePosition(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:getTouchMovePosition()
end

function GUI:getTouchBeganPosition(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:getTouchBeganPosition()
end

function GUI:getTouchEndPosition(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:getTouchEndPosition()
end

function GUI:convertToWorldSpace(widget, x, y)
    if CheckIsInvalidCObject(widget) then
        return cc.p(0, 0)
    end
    
    return widget:convertToWorldSpace(cc.p(x, y))
end

function GUI:convertToNodeSpace(widget, x, y)
    if CheckIsInvalidCObject(widget) then
        return cc.p(0, 0)
    end
    
    return widget:convertToNodeSpace(cc.p(x, y))
end

function GUI:getDescription(widget)
    if CheckIsInvalidCObject(widget) then
        return "nil"
    end
    
    return widget:getDescription()
end

function GUI:setSwallowTouches(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setSwallowTouches(value)
end

function GUI:getSwallowTouches(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:isSwallowTouches()
end

function GUI:setMouseRSwallowTouches(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    global.mouseEventController:registerMouseButtonEvent(widget, {checkSwallowTouches = true})
end

function GUI:schedule(widget, callback, delay)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    delay = delay or 1
    local action = schedule(widget, callback, delay)
    action:setTag(scheduleActionTag)
end

function GUI:unSchedule(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:stopActionByTag(scheduleActionTag)
end

function GUI:performWithDelay(widget, callback, delay)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    delay = delay or 1
    local action = performWithDelay(widget, callback, delay)
    action:setTag(performActionTag)
end

function GUI:unPerformWithDelay(widget, callback, delay)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:stopActionByTag(performActionTag)
end

function GUI:addKeyboardEvent(codeKeys, pressedCB, releaseCB, checkFullSort)
    local keyCodes = {}
    if type(codeKeys) == "string" then
        table.insert(keyCodes, cc.KeyCode[codeKeys])
    elseif type(codeKeys) == "table" then
        for _, v in ipairs(codeKeys) do
            table.insert(keyCodes, cc.KeyCode[v])
        end
    end
    if not next(keyCodes) then
        SL:Print("[GUI ERROR] keyCode is invalid!")
        return
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB, releaseCB, nil, checkFullSort)
end

function GUI:removeKeyboardEvent(codeKeys)
    local keyCodes = {}
    if type(codeKeys) == "string" then
        table.insert(keyCodes, cc.KeyCode[codeKeys])
    elseif type(codeKeys) == "table" then
        for _, v in ipairs(codeKeys) do
            table.insert(keyCodes, cc.KeyCode[v])
        end
    end
    global.userInputController:rmvKeyboardListener(keyCodes)
end

function GUI:addStateEvent(widget, func)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:registerScriptHandler(func)
end

-------------------------------------------------------------
-- ex
GUI.getChildByID = GUI.getChildByName
GUI.removeChildByID = GUI.removeChildByName

------------------------------------------------------------
-- Node
function GUI:Node_Create(parent, ID, x, y)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Node_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Node_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Node_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.Widget:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end
        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget)
        else
            parent:addChild(widget)
        end
    end
    
    return widget
end


-------------------------------------------------------------
-- widget
function GUI:Widget_Create(parent, ID, x, y, width, height)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Widget_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Widget_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Widget_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.Widget:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setContentSize(cc.size(width, height))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end
        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget) 
        else
            parent:addChild(widget) 
        end
    end

    return widget
end


-------------------------------------------------------------
-- image
function GUI:Image_Create(parent, ID, x, y, nimg)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Image_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Image_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Image_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.ImageView:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:loadTexture(FixPath(nimg))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end
        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget) 
        else
            parent:addChild(widget) 
        end
    end

    return widget
end

function GUI:Image_loadTexture(widget, filepath)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:loadTexture(FixPath(filepath))
end

function GUI:Image_setScale9Slice(widget, scale9l, scale9r, scale9t, scale9b)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setScale9Enabled(true)
    local contentSize   = widget:getVirtualRendererSize()
    local x             = scale9l
    local y             = scale9t
    local width         = contentSize.width-scale9l-scale9r
    local height        = contentSize.height-scale9t-scale9b
    widget:setCapInsets({x = x, y = y, width = width, height = height})
end

function GUI:Image_setGrey( widget, isGrey )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
        SL:Print("[GUI ERROR] GUI:Button_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Button_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Button_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.Button:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:loadTextureNormal(FixPath(nimg))
    widget:setTitleFontName(GUI.PATH_FONT2)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return false
        end
        
        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget) 
        else
            parent:addChild(widget) 
        end
    end

    return widget
end

function GUI:Button_loadTextureNormal(widget, filepath)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:loadTextureNormal(FixPath(filepath))
end

function GUI:Button_loadTexturePressed(widget, filepath)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:loadTexturePressed(FixPath(filepath))
end

function GUI:Button_loadTextureDisabled(widget, filepath)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:loadTextureDisabled(FixPath(filepath))
end

function GUI:Button_loadTextures(widget, Normalfilepath, Pressedfilepath, Disabledfilepath, TextureType)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    if Normalfilepath and Pressedfilepath and Disabledfilepath and TextureType then 
        widget:loadTextures(FixPath(Normalfilepath), FixPath(Pressedfilepath), FixPath(Disabledfilepath), TextureType)
    elseif Normalfilepath and  Pressedfilepath and Disabledfilepath then
        widget:loadTextures(FixPath(Normalfilepath), FixPath(Pressedfilepath), FixPath(Disabledfilepath))
    elseif Normalfilepath and  Pressedfilepath  then
        widget:loadTextures(FixPath(Normalfilepath), FixPath(Pressedfilepath))
    elseif Normalfilepath then
        widget:loadTextures(FixPath(Normalfilepath))
    end
end

function GUI:Button_setTitleText(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local label = widget:getTitleRenderer()
    label:setPosition(cc.p(fixPosition(label:getPositionX()), fixPosition(label:getPositionY())))
    widget:setTitleText(value)

    setButtonLabelOffset(widget)
end

function GUI:Button_getTitleText(widget)
    if CheckIsInvalidCObject(widget) then
        return ""
    end
    
    return widget:getTitleText()
end

function GUI:Button_setTitleColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTitleColor(SL:ConvertColorFromHexString(value))
end

function GUI:Button_setTitleFontSize(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTitleFontSize(value)

    setButtonLabelOffset(widget)
end

function GUI:Button_setTitleFontName(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTitleFontName(value)

    setButtonLabelOffset(widget)
end

function GUI:Button_setBright(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBright(value)
end

function GUI:Button_setBrightEx(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTouchEnabled(value)
    widget:setBright(value)
end

function GUI:Button_setZoomScale(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget.invalidZoomScale = true
    widget:setZoomScale(value)
end

function GUI:Button_setTitleOffset(widget, x, y)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget._x_ = fixPosition(x)
    widget._y_ = fixPosition(y)
    setButtonLabelOffset(widget)
end

function GUI:Button_setBrightStyle(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBrightStyle(value)
end

function GUI:Button_setMaxLineWidth(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getTitleRenderer():setMaxLineWidth(tonumber(value) or 0)
end

function GUI:Button_titleEnableOutline( widget, color, outline )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getTitleRenderer():enableOutline(SL:ConvertColorFromHexString(color), outline)
end

function GUI:Button_titleDisableOutLine( widget )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getTitleRenderer():disableEffect(cc.LabelEffect.OUTLINE)
end

function GUI:Button_setGrey( widget, isGrey )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    if isGrey then
        Shader_Grey(widget)
    else
        Shader_Normal(widget)
    end
end

function GUI:Button_setScale9Slice(widget, scale9l, scale9r, scale9t, scale9b)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setScale9Enabled(true)
    local contentSize   = widget:getVirtualRendererSize()
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
        SL:Print("[GUI ERROR] GUI:Text_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Text_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Text_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.Text:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setFontName(GUI.PATH_FONT2)
    widget:setFontSize(fontSize)
    if type(fontColor) == "string" and string.find(fontColor, "#") then
        fontColor = SL:ConvertColorFromHexString(fontColor)
    end
    widget:setTextColor(fontColor)
    widget:setString(str)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget)
        else
            parent:addChild(widget)
        end
    end

    return widget
end

--pc 12号宋体
function GUI:BmpText_Create(parent, ID, x, y, fontColor, str, fontPath)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Text_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Text_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Text_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.Text:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    if type(fontColor) == "string" and string.find(fontColor, "#") then
        fontColor = SL:ConvertColorFromHexString(fontColor)
    end

    GUI:SetBmpTextProperties(widget)
    widget:setBMFontFilePath(fontPath)
    widget:setFontSize(12)
    if fontColor then
        widget:setTextColor(fontColor)
    end
    widget:setString(str)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return false
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget)
        else
            parent:addChild(widget)
        end
    end

    return widget
end

function GUI:SetBmpTextProperties(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget.getDescription = function ()
        return "BmpText"
    end

    local labelRenderer = widget:getVirtualRenderer()
    widget.setTextColor = function(self, c4b)
        labelRenderer:setColor(c4b)
    end
    widget.getTextColor = function(self)
        return self:getVirtualRenderer():getColor()
    end
    widget.setFontName = function(self, fontName)
    end

    widget.setBMFontFilePath = function (self, fontPath)
        self:getVirtualRenderer():setBMFontFilePath(fontPath or global.MMO.PATH_ST_FONT, cc.p(0, 0), 0)
    end

    widget.getBMPFontpath = function ()
        return global.MMO.PATH_ST_FONT
    end

    widget.setFontSize = function(self, fontSize)
        self:getVirtualRenderer():setBMFontSize(fontSize)
    end
    widget.getFontSize = function (self)
        return self:getVirtualRenderer():getBMFontSize()
    end

    widget.enableOutline = function(self, ...)
    end
    local color = labelRenderer:getTextColor()
    labelRenderer:setColor(color)
    labelRenderer.setTextColor = function (self, c4b)
        labelRenderer:setColor(c4b)
    end
    labelRenderer.enableOutline = function ( )
    end
    widget.getContentSize = function (self)
        return self:getVirtualRenderer():getContentSize()
    end
    labelRenderer.enableUnderline = function()
        if labelRenderer.underline and ( not tolua.isnull( labelRenderer.underline ) ) then
            labelRenderer.underline:removeFromParent()
            labelRenderer.underline = nil
        end
        local underline = UnderLineComponent:create()
        underline:attachToNode( labelRenderer, labelRenderer:getColor() )
        labelRenderer.underline = underline
    end
end

function GUI:Text_setString(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setString(value)
end

function GUI:Text_getString(widget)
    if CheckIsInvalidCObject(widget) then
        return ""
    end
    
    return widget:getString()
end

function GUI:Text_setTextColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTextColor(SL:ConvertColorFromHexString(value))
end

function GUI:Text_setFontSize(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setFontSize(value)
end

function GUI:Text_getFontSize(widget)
    if CheckIsInvalidCObject(widget) then
        return nil
    end
    
    return widget:getFontSize()
end

function GUI:Text_setFontName(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setFontName(value)
end

function GUI:Text_enableOutline(widget, color, size)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:enableOutline(SL:ConvertColorFromHexString(color), size)
end

function GUI:Text_enableUnderline(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getVirtualRenderer():enableUnderline()
end

function GUI:Text_setMaxLineWidth(widget, width)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getVirtualRenderer():setMaxLineWidth(tonumber(width) or 0)
end

function GUI:Text_disableEffect( widget, param )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getVirtualRenderer():disableEffect(param)
end

function GUI:Text_disableNormal( widget )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getVirtualRenderer():disableEffect(cc.LabelEffect.NORMAL)
end

function GUI:Text_disableOutLine( widget )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getVirtualRenderer():disableEffect(cc.LabelEffect.OUTLINE)
end

function GUI:Text_disableShadow( widget )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getVirtualRenderer():disableEffect(cc.LabelEffect.SHADOW)
end

function GUI:Text_disableGlow( widget )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:getVirtualRenderer():disableEffect(cc.LabelEffect.GLOW)
end

function GUI:Text_setTextVerticalAlignment(widget, value) 
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTextVerticalAlignment(value)
end

function GUI:Text_setTextHorizontalAlignment(widget, value) 
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTextHorizontalAlignment(value)
end

function GUI:Text_setTextAreaSize(widget, sizeW, sizeH) 
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local size = nil
    if nil == sizeH then
        size = { width = sizeW.width, height = sizeW.height }
    else
        size = { width = sizeW, height = sizeH }
    end
    widget:setTextAreaSize(size)
end

function GUI:Text_COUNTDOWN(widget, time, callback, showType) 
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local tag = 9963
    local endTime = SL:GetMetaValue("SERVER_TIME") + time
    local remaining = time
    local type = tonumber(showType) or 0

    local function scheduleCB()
        remaining = math.max(endTime - SL:GetMetaValue("SERVER_TIME"), 0)
        local str = ""
        if not type or type == 0 then
            str = SecondToHMS(remaining, true)
        elseif type == 1 then
            str = TimeFormatToString(remaining)
        end
        widget:setString(str)
    
        if remaining == 0 then

            if callback then
                callback(remaining)
            end
            
            widget:stopActionByTag(tag)
        end
    end
    local action = schedule(widget, scheduleCB, 1)
    action:setTag(tag)
    scheduleCB()
end

function GUI:Text_AutoUpdateMetaValue(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    -- 加入元变量组件管理
    local metaValue = {}
    local content = value
    local isMetaValue = false
    while content and string.len(content) > 0 do
        local find_info = {sfind(content, "$STM%((.-)%)")}
        local begin_pos = find_info[1]
        local end_pos   = find_info[2]

        if begin_pos and end_pos then
            isMetaValue = true

            -- prefix
            if begin_pos ~= 1 then
                local substr = string.sub(content, 1, begin_pos - 1)
                table.insert(metaValue, substr)
            end

            -- metaValue
            local slices = ssplit(find_info[3], "_")
            table.insert(metaValue, {key = slices[1], param = slices[2]})

            -- suffix
            content = string.sub(content, end_pos + 1, string.len(content))
        else
            table.insert(metaValue, content)
            content = ""
        end
    end

    if isMetaValue then
        global.Facade:sendNotification(global.NoticeTable.SUIMetaWidgetAdd, {metaValue = metaValue, widget = widget, lifewidget = widget})
        return true
    else
        widget:setString(value)
        return false
    end
end 

-- scroll text
function GUI:ScrollText_Create(parent, ID, x, y, width, fontSize, fontColor, str, scrollTime, fontPath)
    if not ID then
        SL:Print("[GUI ERROR] GUI:ScrollText_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:ScrollText_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:ScrollText_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.Layout:create()
    widget:setName(ID)
    widget:setClippingEnabled(true)
    widget:setClippingType(0)
    widget:setTouchEnabled(false)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget)
        else
            parent:addChild(widget)
        end
    end

    local Text = ccui.Text:create()
    Text:setName("Text")
    Text:setFontName(fontPath or GUI.PATH_FONT2)
    Text:setFontSize(fontSize)
    Text:setTextColor(SL:ConvertColorFromHexString(fontColor))
    Text:setAnchorPoint(cc.p(0, 0))
    Text:setPosition(cc.p(0, 0))
    Text:setString(str)
    if scrollTime then
        Text._scrollTime = scrollTime
    end

    widget:setContentSize({width = width, height = Text:getContentSize().height})
    widget:addChild(Text)
    GUI:refScrollText(widget, Text, scrollTime)

    return widget
end

function GUI:refScrollText(widget, Text, scrollTime)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    Text:stopAllActions()
    scrollTime = scrollTime or 4
    local textWid   = Text:getContentSize().width
    local widgetWid = widget:getContentSize().width
    local dis = textWid - widgetWid
    if dis > 0 then
        local anrX = Text:getAnchorPoint().x
        local x = (widgetWid+dis) * anrX
        Text:setPositionX(x)
        Text:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(scrollTime, cc.p(-textWid, 0)), cc.MoveBy:create(0, cc.p(textWid, 0)))))
    else
        local anr = Text:getAnchorPoint()
        local x = math.abs(dis/2) + textWid * anr.x
        Text:setPositionX(x)
    end
end

function GUI:ScrollText_setString(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local Text = widget:getChildByName("Text")
    if Text then
        Text:setString(value)
        widget:setContentSize({width = widget:getContentSize().width, height = Text:getContentSize().height})
        GUI:refScrollText(widget, Text, Text._scrollTime)
    end
end

function GUI:ScrollText_enableOutline(widget, color, size)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local Text = widget:getChildByName("Text")
    if Text then
        Text:enableOutline(SL:ConvertColorFromHexString(color), size)
        widget:setContentSize({width = widget:getContentSize().width, height = Text:getContentSize().height})
    end
end

function GUI:ScrollText_getString(widget, value)
    if CheckIsInvalidCObject(widget) then
        return ""
    end
    
    local Text = widget:getChildByName("Text")
    if Text then
        return Text:getString()
    end
end

-- value: 1: 左; 2: 中; 3：右
function GUI:ScrollText_setHorizontalAlignment(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local Text = widget:getChildByName("Text")
    if Text then
        local width = widget:getContentSize().width
        local anrX = value == 2 and 0.5 or (value == 3 and 1 or 0)
        local posX = value == 2 and width / 2 or (value == 3 and width or 0)
        Text:setAnchorPoint(cc.p(anrX, 0))
        Text:setPositionX(posX)
    end
end

function GUI:ScrollText_setTextColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local Text = widget:getChildByName("Text")
    if Text then
        Text:setTextColor(SL:ConvertColorFromHexString(value))
    end
end

-------------------------------------------------------------
-- Label
function GUI:Label_Create(parent, ID, x, y, text, fontPath, fontSize, fontColor)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Label_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Label_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Label_Create ID is exists", ID)
        return nil
    end

    if not fontPath or not SL:IsFileExist(fontPath) then
        SL:Print("[GUI ERROR] GUI:Label_Create can't find fontPath ", fontPath)
        return nil
    end

    local widget = cc.Label:createWithTTF(text, fontPath, fontSize)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    if type(fontColor) == "string" and string.find(fontColor, "#") then
        fontColor = SL:ConvertColorFromHexString(fontColor)
    end
    if fontColor then
        widget:setColor(fontColor)
    end
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget)
        else
            parent:addChild(widget)
        end
    end

    return widget
end

-------------------------------------------------------------
-- Layout
function GUI:Layout_Create(parent, ID, x, y, width, height, isClip)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Layout_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Layout_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Layout_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.Layout:create()
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget)
        elseif "ccui.PageView" == tolua.type(parent) then
            parent:addPage(widget)
        else
            parent:addChild(widget) 
        end
    end
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setContentSize(cc.size(width, height))

    if isClip and type(isClip) == "boolean" then
        widget:setClippingEnabled(isClip)
    end
    widget:setClippingType(0)

    return widget
end

function GUI:Layout_setBackGroundColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    local paramList = {}
    if type(value) == "table" then
        for i, v in ipairs(value) do
            paramList[i] = SL:ConvertColorFromHexString(v)
        end
    else
        paramList[1] = SL:ConvertColorFromHexString(value)
    end
    if #paramList == 2 then
        widget:setBackGroundColor(paramList[1], paramList[2])
    else
        widget:setBackGroundColor(paramList[1])
    end
end

function GUI:Layout_setBackGroundColorType(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setBackGroundColorType(value)
end

function GUI:Layout_setBackGroundColorOpacity(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundColorOpacity(value)
end

function GUI:Layout_setClippingEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setClippingEnabled(value)
end

function GUI:Layout_setBackGroundImage(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundImage(value, 0)
end

function GUI:Layout_setBackGroundImageScale9Slice(widget, scale9l, scale9r, scale9t, scale9b)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundImageScale9Enabled(true)
    local contentSize = widget:getBackGroundImageTextureSize()
    local x           = scale9l
    local y           = scale9t
    local width       = contentSize.width-scale9l-scale9r
    local height      = contentSize.height-scale9t-scale9b

    local capInsets = RestrictCapInsetRect({x = x, y = y, width = width, height = height}, contentSize)
    widget:setBackGroundImageCapInsets(capInsets)
end

function GUI:Layout_removeBackGroundImage(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeBackGroundImage()
end

function GUI:Layout_getBackGroundImageFile(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local data = widget:getRenderFile() or {}
    return data.file, data.type
end

function GUI:Layout_debug(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundColorType(1)
    widget:setBackGroundColorOpacity(155)
    widget:setBackGroundColor(cc.c3b(0xff, 0, 0))
end

function GUI:Layout_getLayoutType(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end
    
    return widget:getLayoutType()
end

function GUI:Layout_setLayoutType(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setLayoutType(value)
end

-------------------------------------------------------------
-- LoadingBar
function GUI:LoadingBar_Create(parent, ID, x, y, nimg, direction)
    if not ID then
        SL:Print("[GUI ERROR] GUI:LoadingBar_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:LoadingBar_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:LoadingBar_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.LoadingBar:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:loadTexture(FixPath(nimg))
    widget:setDirection(direction)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:LoadingBar_loadTexture(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:loadTexture(FixPath(value))
end

function GUI:LoadingBar_setDirection(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setDirection(value)
end

function GUI:LoadingBar_setPercent(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setPercent(value)
end

function GUI:LoadingBar_getPercent(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end
    
    return widget:getPercent()
end

function GUI:LoadingBar_setColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setColor(SL:ConvertColorFromHexString(value))
end

function GUI:LoadingBar_getColor(widget)
    if CheckIsInvalidCObject(widget) then
        return "#ffffff"
    end
    
    return GetColorHexFromRBG(widget:getColor())
end
-------------------------------------------------------------
-- TextInput
function GUI:TextInput_Create(parent, ID, x, y, width, height, fontSize)
    if not ID then
        SL:Print("[GUI ERROR] GUI:TextInput_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:TextInput_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:TextInput_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.EditBox:create(cc.size(width, height), GUI.PATH_RES_ALPHA)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    if global.isMobile then
        widget:setFontName(GUI.PATH_FONT2)
    end
    widget:setFontSize( fontSize )
    widget:setFontColor(cc.c3b(255, 255, 255))
    widget:setPlaceholderFontSize(fontSize)

    if global.Platform == cc.PLATFORM_OS_ANDROID then
        x = x + 1
        y = y + 1
        widget:setNativeOffset(cc.p(0, -13))
    end
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return false
        end
        
        parent:addChild(widget)
    end

    return widget
end

function GUI:TextInput_setFontColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setFontColor(SL:ConvertColorFromHexString(value))
end

function GUI:TextInput_setFont(widget, value, value2)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    if global.isMobile then
        widget:setFont(value, value2)
    else
        widget:setFontSize(value2)
        SL:Print("[GUI LOG] GUI:TextInput_setFont will support on mobile device")
    end
end

function GUI:TextInput_setFontSize(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setFontSize(value)
end

function GUI:TextInput_setPlaceholderFont(widget, value, value2)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setPlaceholderFont(value, value2)
end

function GUI:TextInput_setPlaceholderFontColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setPlaceholderFontColor(SL:ConvertColorFromHexString(value))
end

function GUI:TextInput_setPlaceholderFontSize(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setPlaceholderFontSize(value)
end

function GUI:TextInput_setPlaceHolder(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setPlaceHolder(value)
end

function GUI:TextInput_setMaxLength(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setMaxLength(value)
end

function GUI:TextInput_setString(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setString(value)
end

function GUI:TextInput_getString(widget)
    if CheckIsInvalidCObject(widget) then
        return ""
    end
    
    return widget:getString()
end

function GUI:TextInput_setTextHorizontalAlignment(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTextHorizontalAlignment(value)
end

-- 增加空方法防止报错
function GUI:TextInput_setTextVerticalAlignment(widget, value)
    
end

function GUI:TextInput_setInputFlag(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setInputFlag(value)
end

function GUI:TextInput_setInputMode(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setInputMode(value)
end

function GUI:TextInput_setNativeOffset(widget, value, value1)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setNativeOffset( cc.p( value, value1 ) )
end

function GUI:TextInput_setReturnType(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setReturnType(value)
end

function GUI:TextInput_addOnEvent(widget, eventCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

function GUI:TextInput_touchDownAction(widget, type)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:touchDownAction(widget, type)
end

function GUI:TextInput_closeInput(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    if widget.closeKeyboard then
        widget:closeKeyboard()
    end
end

-------------------------------------------------------------
-- TextAtlas
function GUI:TextAtlas_Create(parent, ID, x, y, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
    if not ID then
        SL:Print("[GUI ERROR] GUI:TextAtlas_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:TextAtlas_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:TextAtlas_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.TextAtlas:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))

    -- Custom Func
    if SL._DEBUG then
        GUI:TextAtlas_SetCustomFunc(widget)
    end
    GUI:TextAtlas_setProperty(widget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return false
        end
        
        parent:addChild(widget)
    end

    return widget
end

function GUI:TextAtlas_SetCustomFunc(widget)
    -- Set Func
    widget.setStringValue = function (self, value)
        self._stringValue_ = value
    end
    widget.setCharMapFile = function (self, value)
        self._charMapFile_ = value
    end
    widget.setItemWidth = function (self, value)
        self._itemWidth_ = value
    end
    widget.setItemHeight = function (self, value)
        self._itemHeight_ = value
    end
    widget.setStartCharMap = function (self, value)
        self._startCharMap_ = value
    end

    -- Get Func
    widget.getStringValue = function (self)
        return self._stringValue_ or ""
    end

    widget.getCharMapFile = function (self)
        return self._charMapFile_ or "res/private/gui_edit/TextAtlas.png"
    end

    widget.getItemWidth = function (self)
        return self._itemWidth_ or 0
    end

    widget.getItemHeight = function (self)
        return self._itemHeight_ or widget:getContentSize().height
    end

    widget.getStartCharMap = function (self)
        return self._startCharMap_ or ""
    end
end

function GUI:TextAtlas_setProperty(widget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if SL._DEBUG then
        widget:setStringValue(stringValue)
        widget:setCharMapFile(charMapFile)
        widget:setItemWidth(itemWidth)
        widget:setItemHeight(itemHeight)
        widget:setStartCharMap(startCharMap)
    end
    widget:setProperty(stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
end

function GUI:TextAtlas_setString(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setString(value)
end

function GUI:TextAtlas_getString(widget)
    if CheckIsInvalidCObject(widget) then
        return ""
    end

    return widget:getString()
end

-------------------------------------------------------------
-- Slider
function GUI:Slider_Create(parent, ID, x, y, barimg, pbarimg, nimg)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Slider_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Slider_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Slider_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.Slider:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:loadBarTexture(FixPath(barimg) or "res/public/bg_szjm_01.png", 0)
    widget:loadProgressBarTexture(FixPath(pbarimg) or "res/public/bg_szjm_02.png", 0)
    widget:loadSlidBallTextureNormal(FixPath(nimg) or "res/private/setting_basic/icon_xdtzy_17.png", 0)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:Slider_loadBarTexture(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:loadBarTexture(FixPath(value))
end

function GUI:Slider_loadProgressBarTexture(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:loadProgressBarTexture(FixPath(value))
end

function GUI:Slider_loadSlidBallTextureNormal(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:loadSlidBallTextureNormal(FixPath(value))
end

function GUI:Slider_setPercent(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setPercent(value)
end

function GUI:Slider_getPercent(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end

    return widget:getPercent()
end

function GUI:Slider_setMaxPercent(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setMaxPercent(value)
end

function GUI:Slider_addOnEvent(widget, eventCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

-------------------------------------------------------------
-- ListView
function GUI:ListView_Create(parent, ID, x, y, width, height, direction)
    if not ID then
        SL:Print("[GUI ERROR] GUI:ListView_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:ListView_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:ListView_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.ListView:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setContentSize(cc.size(width, height))
    widget:setClippingEnabled(true)
    widget:setClippingType(0)
    widget:setTouchEnabled(true)
    widget:setDirection(direction)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget)
        else
            parent:addChild(widget)
        end
    end
    
    return widget
end

function GUI:ListView_setGravity(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setGravity(value)
end

function GUI:ListView_setDirection(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setDirection(value)
end

function GUI:ListView_setItemsMargin(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setItemsMargin(value)
end

function GUI:ListView_setBounceEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBounceEnabled(value)
end

function GUI:ListView_setClippingEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setClippingEnabled(value)
end

function GUI:ListView_setBackGroundColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local paramList = {}
    if type(value) == "table" then
        for i, v in ipairs(value) do
            paramList[i] = SL:ConvertColorFromHexString(v)
        end
    else
        paramList[1] = SL:ConvertColorFromHexString(value)
    end
    if #paramList == 2 then
        widget:setBackGroundColor(paramList[1], paramList[2])
    else
        widget:setBackGroundColor(paramList[1])
    end
end

function GUI:ListView_setBackGroundColorType(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundColorType(value)
end

function GUI:ListView_setBackGroundColorOpacity(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundColorOpacity(value)
end

function GUI:ListView_pushBackCustomItem(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:pushBackCustomItem(value)
end

function GUI:ListView_insertCustomItem(widget, value, value2)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:insertCustomItem(value, value2)
end

function GUI:ListView_removeAllItems(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeAllItems()
end

function GUI:ListView_removeItemByIndex(widget, index)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeItem(index)
end

function GUI:ListView_jumpToItem(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local index = math.max(value, 0)
    widget:jumpToItem(index, cc.p(0, 0), cc.p(0, 0))
end

function GUI:ListView_getItemIndex(widget, value)
    if CheckIsInvalidCObject(widget) then
        return 0
    end
    
    return widget:getIndex(value)
end

function GUI:ListView_getItemByIndex(widget, value)
    if CheckIsInvalidCObject(widget) then
        return nil
    end
    
    return widget:getItem(value)
end

function GUI:ListView_doLayout(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:doLayout()
end

function GUI:ListView_setBackGroundImage(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundImage(value, 0)
end

function GUI:ListView_setBackGroundImageScale9Slice(widget, scale9l, scale9r, scale9t, scale9b)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundImageScale9Enabled(true)
    local contentSize = widget:getBackGroundImageTextureSize()
    local x           = scale9l
    local y           = scale9t
    local width       = contentSize.width-scale9l-scale9r
    local height      = contentSize.height-scale9t-scale9b

    local capInsets = RestrictCapInsetRect({x = x, y = y, width = width, height = height}, contentSize)
    widget:setBackGroundImageCapInsets(capInsets)
end

function GUI:ListView_removeBackGroundImage(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeBackGroundImage()
end

function GUI:ListView_getItemsMargin(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end
    
    return widget:getItemsMargin()
end

function GUI:ListView_getItems(widget)
    if CheckIsInvalidCObject(widget) then
        return {}
    end
    
    return widget:getItems()
end

function GUI:ListView_getItemCount(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end
    
    return #widget:getItems()
end

function GUI:ListView_getInnerContainer(widget)
    if CheckIsInvalidCObject(widget) then
        return nil
    end
    
    return widget:getInnerContainer()    
end

function GUI:ListView_addOnScrollEvent(widget, eventCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addScrollViewEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

function GUI:ListView_paintItems(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:paintItems()
end

function GUI:ListView_autoPaintItems(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local function eventCB(_, eventType)
        if eventType == 9 then
            widget:paintItems()
        end
    end
    widget:addScrollViewEventListener(eventCB)
end

function GUI:ListView_removeChild(widget, item)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeChild(item, true)
end

function GUI:ListView_jumpToBottom(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:jumpToBottom()
end

function GUI:ListView_jumpToTop(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:jumpToTop()
end

function GUI:ListView_getTopmostItemInCurrentView(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return ({[1] = widget:getTopmostItemInCurrentView(), [2] = widget:getLeftmostItemInCurrentView()})[widget:getDirection()] or nil
end

function GUI:ListView_getBottommostItemInCurrentView(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return ({[1] = widget:getBottommostItemInCurrentView(), [2] = widget:getRightmostItemInCurrentView()})[widget:getDirection()] or nil
end

function GUI:ListView_scrollToTop(widget,time, boolvalue)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:scrollToTop(time, boolvalue)
end

function GUI:ListView_scrollToBottom(widget, time, boolvalue)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:scrollToBottom(time, boolvalue)
end

function GUI:ListView_getInnerContainerSize(widget)
    if CheckIsInvalidCObject(widget) then
        return cc.size(0, 0)
    end
    
    return widget:getInnerContainerSize()
end

function GUI:ListView_getInnerContainerPosition(widget)
    if CheckIsInvalidCObject(widget) then
        return cc.p(0, 0)
    end
    
    return widget:getInnerContainerPosition()
end

function GUI:ListView_setInnerContainerPosition(widget, value1, value2)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    if type(value1) == "table" then
        widget:setInnerContainerPosition(value1)
    elseif value1 and value2 then
        widget:setInnerContainerPosition(cc.p(value1, value2))
    end
end

-- bool 是否衰减滚动速度(垂直方向)
function GUI:ListView_scrollToPercentVertical(widget, percent, time, bool)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:scrollToPercentVertical(percent, time, bool)
end

-- bool 是否衰减滚动速度(水平方向)
function GUI:ListView_scrollToPercentHorizontal(widget, percent, time, bool)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:scrollToPercentHorizontal(percent, time, bool)
end

function GUI:ListView_addMouseScrollPercent(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addMouseScrollPercent()
end
-------------------------------------------------------------
-- ScrollView
function GUI:ScrollView_Create(parent, ID, x, y, width, height, direction)
    if not ID then
        SL:Print("[GUI ERROR] GUI:ScrollView_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:ScrollView_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:ScrollView_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.ScrollView:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setContentSize(cc.size(width, height))
    widget:setClippingEnabled(true)
    widget:setClippingType(0)
    widget:setTouchEnabled(true)
    widget:setDirection(direction)   -- direction: 1-垂直; 2-水平
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end
    
    return widget
end

function GUI:ScrollView_setInnerContainerSize(widget, sizeW, sizeH)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    local size = nil
    if nil == sizeH then
        size = { width = sizeW.width, height = sizeW.height }
    else
        size = { width = sizeW, height = sizeH }
    end
    widget:setInnerContainerSize(size)
end

function GUI:ScrollView_getInnerContainerSize(widget)
    if CheckIsInvalidCObject(widget) then
        return cc.size(0, 0)
    end

    return widget:getInnerContainerSize()
end

function GUI:ScrollView_getInnerContainerPosition(widget)
    if CheckIsInvalidCObject(widget) then
        return cc.p(0, 0)
    end
    
    return widget:getInnerContainerPosition()
end

function GUI:ScrollView_setDirection(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setDirection(value)
end

function GUI:ScrollView_setBounceEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setBounceEnabled(value)
end

function GUI:ScrollView_setClippingEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setClippingEnabled(value)
end

function GUI:ScrollView_setBackGroundColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    local paramList = {}
    if type(value) == "table" then
        for i, v in ipairs(value) do
            paramList[i] = SL:ConvertColorFromHexString(v)
        end
    else
        paramList[1] = SL:ConvertColorFromHexString(value)
    end
    if #paramList == 2 then
        widget:setBackGroundColor(paramList[1], paramList[2])
    else
        widget:setBackGroundColor(paramList[1])
    end
end

function GUI:ScrollView_setBackGroundColorType(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setBackGroundColorType(value)
end

function GUI:ScrollView_setBackGroundColorOpacity(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setBackGroundColorOpacity(value)
end

function GUI:ScrollView_addChild(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    if CheckIsInvalidCObject(value) then
        return false
    end

    widget:addChild(value)
end

function GUI:ScrollView_removeAllChildren(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:removeAllChildren()
end

function GUI:ScrollView_scrollToTop(widget, time, boolvalue)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:scrollToTop(time, boolvalue)
end

function GUI:ScrollView_scrollToBottom(widget, time, boolvalue)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:scrollToBottom(time, boolvalue)
end

function GUI:ScrollView_scrollToLeft(widget, time, boolvalue)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:scrollToLeft(time, boolvalue)
end

function GUI:ScrollView_scrollToRight(widget, time, boolvalue)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:scrollToRight(time, boolvalue)
end

function GUI:ScrollView_scrollToTopLeft(widget, time, boolvalue)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:scrollToTopLeft(time, boolvalue)
end

function GUI:ScrollView_setBackGroundImage(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundImage(value, 0)
end

function GUI:ScrollView_setBackGroundImageScale9Slice(widget, scale9l, scale9r, scale9t, scale9b)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundImageScale9Enabled(true)
    local contentSize = widget:getBackGroundImageTextureSize()
    local x           = scale9l
    local y           = scale9t
    local width       = contentSize.width-scale9l-scale9r
    local height      = contentSize.height-scale9t-scale9b

    local capInsets = RestrictCapInsetRect({x = x, y = y, width = width, height = height}, contentSize)
    widget:setBackGroundImageCapInsets(capInsets)
end

function GUI:ScrollView_removeBackGroundImage(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeBackGroundImage()
end

function GUI:ScrollView_addOnScrollEvent(widget, eventCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

-- bool 是否衰减滚动速度(垂直方向)
function GUI:ScrollView_scrollToPercentVertical(widget, percent, time, bool)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:scrollToPercentVertical(percent, time, bool)
end

-- bool 是否衰减滚动速度(水平方向)
function GUI:ScrollView_scrollToPercentHorizontal(widget, percent, time, bool)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:scrollToPercentHorizontal(percent, time, bool)
end

-------------------------------------------------------------
-- CheckBox
function GUI:CheckBox_Create(parent, ID, x, y, nimg, pimg)
    if not ID then
        SL:Print("[GUI ERROR] GUI:CheckBox_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:CheckBox_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:CheckBox_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.CheckBox:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:loadTextureBackGround(FixPath(nimg))
    widget:loadTextureFrontCross(FixPath(pimg))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end
        parent:addChild(widget)
    end
    return widget
end

function GUI:CheckBox_loadTextureBackGround(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:loadTextureBackGround(FixPath(value))
end

function GUI:CheckBox_loadTextureFrontCross(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:loadTextureFrontCross(FixPath(value))
end

function GUI:CheckBox_loadTextureFrontCrossDisabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:loadTextureFrontCrossDisabled(FixPath(value))
end

function GUI:CheckBox_setSelected(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setSelected(value)
end

function GUI:CheckBox_isSelected(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:isSelected()
end

function GUI:CheckBox_addOnEvent(widget, eventCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

function GUI:CheckBox_setZoomScale(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setZoomScale(value)
end

-------------------------------------------------------------
-- Effect
function GUI:Effect_Create(parent, ID, x, y, effectType, effectId, sex, act, dir, speed)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Effect_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Effect_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Effect_Create ID is exists", ID)
        return nil
    end

    sex = sex or 0
    act = act or 0
    dir = dir or 0
    speed = speed or 1

    local widget        = nil
    if effectType == 0 then
        -- 特效
        widget = global.FrameAnimManager:CreateSFXAnim(effectId)
        widget:Play(0, 0, true, speed)
        
    elseif effectType == 1 then
        -- NPC
        widget = global.FrameAnimManager:CreateActorNpcAnim(effectId)
        widget:Play(act, dir, true, speed)

    elseif effectType == 2 then
        -- 怪物
        widget = global.FrameAnimManager:CreateActorMonsterAnim(effectId, act)
        widget:Play(act, dir, true, speed)

    elseif effectType == 3 then
        -- 技能
        widget = global.FrameAnimManager:CreateSkillEffAnim(effectId, dir)
        widget:Play(act, dir, true, speed)

    elseif effectType == 4 then
        -- 人物
        widget = global.FrameAnimManager:CreateActorPlayerAnim(effectId, sex, act)
        widget:Play(act, dir, true, speed)

    elseif effectType == 5 then
        -- 武器
        widget = global.FrameAnimManager:CreateActorPlayerWeaponAnim(effectId, sex, act)
        widget:Play(act, dir, true, speed)

    elseif effectType == 6 then
        -- 翅膀
        widget = global.FrameAnimManager:CreateActorPlayerWingsAnim(effectId, sex, act)
        widget:Play(act, dir, true, speed)

    elseif effectType == 7 then
        -- 发型
        widget = global.FrameAnimManager:CreateActorPlayerHairAnim(effectId, sex, act)
        widget:Play(act, dir, true, speed)

    elseif effectType == 8 then
        -- 盾牌
        widget = global.FrameAnimManager:CreateActorPlayerShieldAnim(effectId, sex, act)
        widget:Play(act, dir, true, speed)

    else
        widget = global.FrameAnimManager:CreateSFXAnim(1)
        widget:Play(0, 0, true, speed)
    end

    
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:Effect_play(widget, act, dir, isLoop, speed, isSequence)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:Stop()
    widget:Play(act, dir, isLoop, speed, isSequence)
end

function GUI:Effect_stop(widget, frameIndex, act, dir)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:Stop(frameIndex, act, dir)
end

function GUI:Effect_addOnCompleteEvent(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:SetAnimEventCallback(value)
end

function GUI:Effect_setGlobalElapseEnable(widget, elapseEnable)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:SetGlobalElapseEnable(elapseEnable)
end

function GUI:Effect_setAutoRemoveOnFinish(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    local function removeEvent()
        if CheckIsInvalidCObject(widget) then
            return false
        end
        widget:removeFromParent()
    end
    widget:SetAnimEventCallback(removeEvent)
end

-------------------------------------------------------------
-- RichText
function GUI:RichText_Create(parent, ID, x, y, str, width, fontSize, fontColor, vspace, hyperlinkCB, defaultFontFace)
    if not ID then
        SL:Print("[GUI ERROR] GUI:RichText_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:RichText_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:RichText_Create ID is exists", ID)
        return nil
    end

    local color
    if type(fontColor) == "table" then
        color = GetColorHexFromRBG(fontColor)
    end

    local RichTextHelp = requireUtil("RichTextHelp")
    local widget = RichTextHelp:CreateRichTextWithXML(str, width, fontSize, color or fontColor, defaultFontFace, hyperlinkCB, vspace)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:formatText()
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

-- 原始富文本
function GUI:RichTextFCOLOR_Create(parent, ID, x, y, str, width, fontSize, color, vspace, hyperlinkCB, fontPath, outlineParam)
    if not ID then
        SL:Print("[GUI ERROR] GUI:RichTextFCOLOR_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:RichTextFCOLOR_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:RichTextFCOLOR_Create ID is exists", ID)
        return nil
    end

    if type(color) == "string" and string.find(color, "#") then
        color = SL:ConvertColorFromHexString(color)
    end

    local RichTextHelp = requireUtil("RichTextHelp")
    local ttfConfig = {
        outlineSize = outlineParam and outlineParam.outlineSize,
        outlineColor= outlineParam and outlineParam.outlineColor
    }
    local widget = RichTextHelp:CreateRichTextWithFCOLOR(str, width, fontSize, color, ttfConfig, hyperlinkCB, vspace, fontPath)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:formatText()
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end
        
        parent:addChild(widget)
    end
    
    return widget
end

-- 自定义富文本带道具图片
function GUI:RichTextCustom_Create(parent, ID, x, y, str, width, vspace)
    if not ID then
        SL:Print("[GUI ERROR] GUI:RichTextCustom_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:RichTextCustom_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:RichTextCustom_Create ID is exists", ID)
        return nil
    end

    local RichTextHelpEx = requireUtil("RichTextHelpEx")
    local widget = RichTextHelpEx:CreateRichTextWithCustom(str, width, vspace)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:RichTextFCOLOR_setBackgroundColor(widget, color)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if type(color) == "string" and string.find(color, "#") then
        color = SL:ConvertColorFromHexString(color)
    end
    widget:setBackgroundColor(color)
    widget:setBackgroundColorEnable(true)
end

-- SRText富文本
function GUI:RichTextSR_Create(parent, ID, x, y, str, width, fontSize, color, vspace, hyperlinkCB, fontPath)
    if not ID then
        SL:Print("[GUI ERROR] GUI:RichTextFCOLOR_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:RichTextFCOLOR_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:RichTextFCOLOR_Create ID is exists", ID)
        return nil
    end

    local RichTextHelp = requireUtil("RichTextHelp")
    local widget = RichTextHelp:CreateRichTextWidthSRText(str, width, fontSize, color, fontPath, hyperlinkCB, vspace)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:formatText()
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end
    
    return widget
    
end

-- 自定义组合富文本
function GUI:RichTextCombine_Create(parent, ID, x, y, width, vspace)
    if not ID then
        SL:Print("[GUI ERROR] GUI:RichTextCombine_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:RichTextCombine_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:RichTextCombine_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.RichText:create()
    widget:ignoreContentAdaptWithSize(false)
    widget:setContentSize(width, 0)
    widget:setVerticalSpace(vspace)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setName(ID)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:RichTextCombine_pushBackElements(widget, elements)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if not elements then
        return 
    end
    if next(elements) then
        for _, v in ipairs(elements) do
            widget:pushBackElement(v)
        end
    else
        widget:pushBackElement(elements)
    end
end

function GUI:RichTextCombine_format(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:formatText()
end

local ELEMENT_TEXT_WAY = {
    ITALICS_FLAG    = 1,            -- italic text
    BOLD_FLAG       = 2,            -- bold text 
    UNDERLINE_FLAG  = 4,            -- underline 
    STRIKETHROUGH_FLAG = 8,         -- strikethrough
    URL_FLAG        = 16,           -- url of anchor
    OUTLINE_FLAG    = 32,           -- outline effect
    SHADOW_FLAG     = 64,           -- shadow effect
    GLOW_FLAG       = 128
}

function GUI:RichTextCombineCell_Create(parent, ID, x, y, type, param)
    if not ID then
        SL:Print("[GUI ERROR] GUI:RichTextCombineCell_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:RichTextCombineCell_Create can't find parent", ID)
        return nil
    end

    if parent ~= NONEED_PARENT_CODE and tolua.type(parent) ~= "ccui.RichText" then
        SL:Print("[GUI ERROR] GUI:RichTextCombineCell_Create parent type is wrong", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:RichTextCombineCell_Create ID is exists", ID)
        return nil
    end

    local widget = nil
    local color = param.color and GetColorFromHexString(param.color) or cc.Color3B.WHITE
    local opacity   = param.opacity or 255
    local fontPath  = param.fontPath or global.MMO.PATH_FONT2
    local fontSize  = param.fontSize or global.ConstantConfig.DEFAULT_FONT_SIZE
    local outlineColor = param.outlineColor and GetColorFromHexString(param.outlineColor) or cc.Color3B.BLACK
    local outlineSize  = param.outlineSize or 0
    if type == 1 or string.upper(type) == "TEXT" then
        local wayType = ELEMENT_TEXT_WAY.OUTLINE_FLAG 
        if param.link then
            wayType = wayType + ELEMENT_TEXT_WAY.URL_FLAG
        end
        widget = ccui.RichElementText:create(0, color, opacity, param.str or "", fontPath, fontSize, wayType, param.link or "", outlineColor, outlineSize)
    elseif type == 2 or string.upper(type) == "NODE" then
        widget = ccui.RichElementCustomNode:create(0, color, opacity, param.node)
    elseif type == 3 or string.upper(type) == "NEWLINE" then
        widget = ccui.RichElementNewLine:create(0, color, opacity)
    end
    if widget and parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:pushBackElement(widget)
    end

    return widget
end

function GUI:RichText_setBackgroundColor(widget, color)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if type(color) == "string" and string.find(color, "#") then
        color = SL:ConvertColorFromHexString(color)
    end
    widget:setBackgroundColor(color)
    widget:setBackgroundColorEnable(true)
end

function GUI:RichText_setOpenUrlEvent(widget, handle)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setOpenUrlHandler(function(sender, str)
        handle(sender, str)
    end)
end

-------------------------------------------------------------
-- PageView
function GUI:PageView_Create(parent, ID, x, y, width, height)
    if not ID then
        SL:Print("[GUI ERROR] GUI:CheckBox_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:PageView_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:CheckBox_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.PageView:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setClippingType(0)
    widget:setContentSize(cc.size(width, height))
    widget:setClippingEnabled(true)
    widget:setTouchEnabled(true)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:PageView_setClippingEnabled(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setClippingEnabled(value)
end

function GUI:PageView_setBackGroundColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local paramList = {}
    if type(value) == "table" then
        for i, v in ipairs(value) do
            paramList[i] = SL:ConvertColorFromHexString(v)
        end
    else
        paramList[1] = SL:ConvertColorFromHexString(value)
    end
    if #paramList == 2 then
        widget:setBackGroundColor(paramList[1], paramList[2])
    else
        widget:setBackGroundColor(paramList[1])
    end
end

function GUI:PageView_setBackGroundColorType(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundColorType(value)
end

function GUI:PageView_setBackGroundColorOpacity(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundColorOpacity(value)
end

function GUI:PageView_setBackGroundImage(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundImage(value, 0)
end

function GUI:PageView_setBackGroundImageScale9Slice(widget, scale9l, scale9r, scale9t, scale9b)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setBackGroundImageScale9Enabled(true)
    local contentSize = widget:getBackGroundImageTextureSize()
    local x           = scale9l
    local y           = scale9t
    local width       = contentSize.width-scale9l-scale9r
    local height      = contentSize.height-scale9t-scale9b

    local capInsets = RestrictCapInsetRect({x = x, y = y, width = width, height = height}, contentSize)
    widget:setBackGroundImageCapInsets(capInsets)
end

function GUI:PageView_removeBackGroundImage(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:removeBackGroundImage()
end

function GUI:PageView_scrollToItem(widget, index)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:scrollToItem(index)
end

function GUI:PageView_setCurrentPageIndex(widget, index)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setCurrentPageIndex(index)
end

function GUI:PageView_getCurrentPageIndex(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end
    
    return widget:getCurrentPageIndex()
end

function GUI:PageView_getItems(widget)
    if CheckIsInvalidCObject(widget) then
        return {}
    end
    
    return widget:getItems()
end

function GUI:PageView_getItemCount(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end
    
    return #widget:getItems()
end

function GUI:PageView_addPage(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    if CheckIsInvalidCObject(value) then
        return false
    end
    
    widget:addPage(value)
end

function GUI:PageView_addOnEvent(widget, eventCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addEventListener(function(_, eventType)
        eventCB(widget, eventType)
    end)
end

------------------------------------------------------------
--- TableView
function GUI:TableView_Create(parent, ID, x, y, width, height, direction, cellWid, cellHei, num, jumpIndex)
    if not ID then
        SL:Print("[GUI ERROR] GUI:TableView_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:TableView_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:TableView_Create ID is exists", ID)
        return nil
    end

    local tableViewDirection = {    -- 1垂直; 2水平
        [1] = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        [2] = cc.SCROLLVIEW_DIRECTION_HORIZONTAL,
    }

    local widget = nil
    widget = TableViewEx.create({
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

            if widget and widget.TableViewCell_Create then
                widget.TableViewCell_Create(cell, i, ID)
            end

            return cell
        end
    })

    widget.getDescription = function() 
        return "TableView" 
    end

    widget:setCascadeColorEnabled(true)
    widget:setCascadeOpacityEnabled(true)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:setContentSize(cc.size(width, height))
    widget:setTouchEnabled(true)
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:TableView_setCellCreateEvent(widget, func)
    if type(func) == "function" then
        widget.TableViewCell_Create = func
    end

    widget:registerScriptHandler()
end

function GUI:TableView_setDirection(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    local tableViewDirection = {  
        [1] = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        [2] = cc.SCROLLVIEW_DIRECTION_HORIZONTAL,
    }
    if value and tableViewDirection[value] then
        widget:setDirection(tableViewDirection[value])
    end
end

function GUI:TableView_setVerticalFillOrder(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setVerticalFillOrder(value)
end

function GUI:TableView_setContentOffset(widget, x, y)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setContentOffset(cc.p(x, y))
end

function GUI:TableView_getContentOffset(widget)
    if CheckIsInvalidCObject(widget) then
        return nil
    end

    return widget:getContentOffset()
end

function GUI:TableView_setBackGroundColor(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    if type(value) == "string" and string.find(value, "#") then
        value = GetColorFromHexString(value)
    end
    widget:SetBackColor(value)
end

function GUI:TableView_addTableCellAtIndexEvent(widget, func)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTableCellAtIndexHandler(func)
end

function GUI:TableView_addOnTouchedCellEvent(widget, func)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTableCellTouchedHandler(func)
end

function GUI:TableView_scrollToCell(widget, index)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:scrollToCell(index)
end

function GUI:TableView_addOnScrollEvent(widget, func)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTableViewScrollHandler(func)
end

function GUI:TableView_reloadData(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:reloadData()
end

function GUI:TableView_reloadDataEx(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:reloadDataEx()
end

function GUI:TableView_setTableViewCellsNumHandler(widget, func)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTableViewCellsNumHandler(func)
end

function GUI:TableView_addMouseScrollEvent(widget, func)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    local call_scrolling = nil
    if func and type(func) == "function" then
        call_scrolling = func
    else
        call_scrolling = function(param)
            local widget        = param.widget
            local speed         = 40
            local scorllX       = param.x
            local scorllY       = param.y
            local contentSize   = widget:getContentSize()
            local cellSize      = widget:getCellSize()
            local innerHei      = cellSize.height * widget:getTotalCellNums()
            local innerPos      = widget:getContentOffset()
            local vHeight       = innerHei - contentSize.height
            if innerHei > contentSize.height then
                local dis           = speed * scorllY
                local offsetY       = innerPos.y + dis
                offsetY             = math.max(math.min(offsetY, 0), - vHeight)
                widget:setContentOffset(cc.p(innerPos.x, offsetY), true)
            end
        end
    end

    widget:addMouseScrollEvent(call_scrolling)
end

-- TableViewCell 
function GUI:TableViewCell_getIdx(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    if widget.getIdx then
        return widget:getIdx() + 1
    end
end

-------------------------------------------------------------
-- ProgressTimer
function GUI:ProgressTimer_Create(parent, ID, x, y, img, width, height)
    if not ID then
        SL:Print("[GUI ERROR] GUI:CheckBox_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:ProgressTimer_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:CheckBox_Create ID is exists", ID)
        return nil
    end

    local spriteCD = cc.Sprite:create(img)
    if width and height then
        spriteCD:setContentSize(width, height)
    end
    local widget = cc.ProgressTimer:create(spriteCD)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:ProgressTimer_setPercentage(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setPercentage(value)
end

function GUI:ProgressTimer_getPercentage(widget)
    if CheckIsInvalidCObject(widget) then
        return 0
    end
    
    return widget:getPercentage()
end

-- value顺时针, false逆时针
function GUI:ProgressTimer_setReverseDirection(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setReverseDirection(value)
end

function GUI:ProgressTimer_progressFromTo(widget, time, from, to, completeCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    if completeCB then
        widget:runAction(cc.Sequence:create(
            cc.ProgressFromTo:create(time or 0.5, from, to), cc.CallFunc:create(completeCB)
        ))
    else
        widget:runAction(cc.ProgressFromTo:create(time or 0.5, from, to))
    end
end

function GUI:ProgressTimer_ChangeImg(widget, img)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local spriteCD = cc.Sprite:create(img)
    if spriteCD then
        widget:setSprite(spriteCD)
    end
end

function GUI:ProgressTimer_progressTo(widget, time, to, completeCB, tag)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local action = nil
    if completeCB then
        action = cc.Sequence:create(
            cc.ProgressTo:create(time or 0, to),
            cc.CallFunc:create(completeCB)
        )
    else
        action = cc.ProgressFromTo:create(time or 0, to)
    end
    widget:runAction(action)
    if tag then
        action:setTag(tag) 
    end
end

-------------------------------------------------------------
-- ItemShow
function GUI:ItemShow_Create(parent, ID, x, y, data)
    if not ID then
        SL:Print("[GUI ERROR] GUI:ItemShow_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:ItemShow_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:ItemShow_Create ID is exists", ID)
        return nil
    end

    if not data then
        SL:Print("[GUI ERROR] GUI:ItemShow_Create itemData is nil", ID)
        return nil
    end

    local widget = GoodsItem:create(data)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget) 
        else
            parent:addChild(widget)
        end
    end

    return widget
end

function GUI:ItemShow_addReplaceClickEvent(widget, eventCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:addReplaceClickEventListener(eventCB)
end

function GUI:ItemShow_addPressEvent(widget, eventCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addPressCallBack(eventCB)
end

function GUI:ItemShow_addDoubleEvent(widget, eventCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addDoubleEventListener(eventCB)
end

function GUI:ItemShow_setIconGrey( widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setIconGrey(value)
end

function GUI:ItemShow_setItemPowerTag(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setItemPowerTag()
end

function GUI:ItemShow_setItemShowChooseState(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:SetChooseState(value)
end

function GUI:ItemShow_setMoveEable(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:SetMoveEable(value)
end

function GUI:ItemShow_GetLayoutExtra(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:GetLayoutExtra()
end

function GUI:ItemShow_resetMoveState(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:resetMoveState(value)
end

function GUI:ItemShow_RDItem(widget, itemData)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:UpdateItem(itemData)
end

function GUI:ItemShow_updateItem(widget, itemData)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:UpdateItem(itemData)
end

function GUI:ItemShow_updateItemCount(widget, itemData)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:UpdateGoodsItem(itemData)
end

function GUI:ItemShow_OnRunFunc(widget, funcname, ...)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:OnRunFunc(funcname, ...)
end

function GUI:ItemShow_setItemTouchSwallow(widget, bool)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setItemTouchSwallow(bool)
end

-------------------------------------------------------------
-- ItemBox
function GUI:ItemBox_Create(parent, ID, x, y, img, boxindex, stdmode)
    if not ID then
        SL:Print("[GUI ERROR] GUI:ItemBox_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:ItemBox_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:ItemBox_Create ID is exists", ID)
        return nil
    end

    local setData = {}
    setData.img = img
    setData.boxindex = boxindex
    setData.stdmode = stdmode

    local widget = SItemBox:create(setData)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end
    
    return widget
end

function GUI:ItemBox_GetItemData(widget, boxindex)
    if CheckIsInvalidCObject(widget) then
        return nil
    end

    local SSRUIManager = global.Facade:retrieveMediator("SSRUIManager")
    return SSRUIManager:GetItemDataByboxIndex(boxindex)
end

function GUI:ItemBox_RemoveBoxData(widget, boxindex)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    global.Facade:sendNotification(global.NoticeTable.SSR_ITEMBOXWidget_Remove, {boxindex = boxindex})
end

function GUI:ItemBox_UpdateBoxData(widget, boxindex, itemData)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    local updateData = true
    if itemData and next(itemData) then
        updateData = false
    end
    global.Facade:sendNotification(global.NoticeTable.SSR_ITEMBOXWidget_Update, {boxindex = boxindex, updateData = updateData, itemData = itemData})
end

-------------------------------------------------------------
-- EquipShow
function GUI:EquipShow_Create(parent, ID, x, y, pos, isHero, data)
    if not ID then
        SL:Print("[GUI ERROR] GUI:EquipShow_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:EquipShow_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:EquipShow_Create ID is exists", ID)
        return nil
    end

    if not tonumber(pos) then
        SL:Print("[GUI ERROR] GUI:EquipShow_Create pos is nil", ID)
        return nil
    end

    local pos               = tonumber(pos)
    local isLookPlayer      = data and data.lookPlayer
    local ItemMoveProxy     = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local EquipProxy        = isHero and global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy) or global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local LookPlayerProxy   = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
    local size              = cc.size(64, 64)
    local equipData         = nil
    if isLookPlayer then
        equipData = LookPlayerProxy:GetLookPlayerItemDataByPos(pos)
    else
        equipData = EquipProxy:GetEquipDataByPos(pos)
    end

    local widget = ccui.Widget:create()
    widget:setContentSize(size)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget._EQUIP_POS = pos
    widget._isHero = isHero
    widget._param = data
    
    if equipData then
        local info      = data or {}
        info.index      = equipData.Index
        info.itemData   = equipData
        info.from       = isHero and ItemMoveProxy.ItemFrom.HERO_EQUIP or ItemMoveProxy.ItemFrom.PALYER_EQUIP
        local item      = GoodsItem:create(info)
        item:setPosition(cc.p(size.width / 2, size.height / 2))
        widget:addChild(item)

        if data.doubleTakeOff and not isLookPlayer then
            if not (info.look) then
                item:addLookItemInfoEvent(nil, 2)
            end
            item:addDoubleEventListener(function()
                local takeOffEquipData = {
                    itemData = equipData,
                    pos = equipData.Where
                }
                if isHero then
                    ItemMoveProxy:TakeOffEquip_Hero(takeOffEquipData)
                else
                    ItemMoveProxy:TakeOffEquip(takeOffEquipData)
                end
            end)
        end
    end

    local function addItemIntoEquip(touchPos)
        local state = ItemMoveProxy:GetMovingItemState()
        local canMove = widget._param and widget._param.movable and not widget._param.lookPlayer
        if state and canMove then
            local goToName = isHero and ItemMoveProxy.ItemGoTo.HERO_EQUIP or ItemMoveProxy.ItemGoTo.PALYER_EQUIP 
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.equipPos = pos
            ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end
    local function setNoswallowMouse(touchPos)
        return -1
    end
    global.mouseEventController:registerMouseButtonEvent(
        widget,
        {
            down_r = setNoswallowMouse,
            special_r = addItemIntoEquip,
            checkIsVisible = true
        }
    )
    
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget) 
        else
            parent:addChild(widget)
        end
    end

    return widget
end

function GUI:EquipShow_setAutoUpdate(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    local lookPlayer = widget._param and widget._param.lookPlayer
    if not widget._EQUIP_POS or lookPlayer then
        return false
    end

    global.Facade:sendNotification(global.NoticeTable.AutoEquipShowWidgetAdd, {widget = widget})
end

-------------------------------------------------------------
-- MoveWidget
function GUI:MoveWidget_Create(parent, ID, x, y, width, height, from, ext)
    if not ID then
        SL:Print("[GUI ERROR] GUI:MoveWidget_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:MoveWidget_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:MoveWidget_Create ID is exists", ID)
        return nil
    end

    ext = ext or {}

    local widget = ccui.Layout:create()
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget)
        elseif "ccui.PageView" == tolua.type(parent) then
            parent:addPage(widget)
        else
            parent:addChild(widget) 
        end
    end
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setContentSize(cc.size(width, height))
    widget:setTouchEnabled(true)

    local itemMoveState = {
        begin = 1,
        moving = 2,
        end_move = 3,
    }

    local ITEMFROMUI = SL:GetMetaValue("ITEMFROMUI_ENUM")

    local beginMoveCallBack = ext.beginMoveCB
    local endMoveCallBack = ext.endMoveCB
    local cancelMoveCallBack = ext.cancelMoveCB

    local pressCallBack = ext.pressCB
    local clickCallBack = ext.clickCB
    local pcDoubleCallBack = ext.pcDoubleCB
    local mouseScrollCallBack = ext.mouseScrollCB

    local function resetMoveState(mySelf, bool, isCancel)
        if mySelf and not tolua.isnull(mySelf) then
            mySelf._movingState = bool
            if bool then
                if beginMoveCallBack then
                    beginMoveCallBack( mySelf, bool )
                end
            else
                if isCancel then
                    if cancelMoveCallBack then
                        cancelMoveCallBack( mySelf, bool )
                    end
                else
                    if endMoveCallBack then
                        endMoveCallBack( mySelf, bool )
                    end
                end
            end   
        end
    end

    local function SetGoodItemState(state, movePos)
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local itemData = nil 
        if from == ITEMFROMUI.PALYER_EQUIP and ext.equipPos then
            itemData = EquipProxy:GetEquipDataByPos(ext.equipPos, ext.equipList == true)
        elseif from == ITEMFROMUI.HERO_EQUIP and ext.equipPos then
            local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
            itemData = HeroEquipProxy:GetEquipDataByPos(ext.equipPos, ext.equipList == true)
        end
        
        if (from == ITEMFROMUI.PALYER_EQUIP or from == ITEMFROMUI.HERO_EQUIP) and not itemData then
            return
        end

        if itemMoveState.begin == state then
            resetMoveState(widget, true)
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Begin,{
                pos = movePos,
                itemData = itemData,
                cancelCallBack = function()
                    resetMoveState(widget, false, true)
                end,
                from = from,
                movingNode = not itemData and widget:clone()
            })
        elseif itemMoveState.moving == state then
    
        elseif itemMoveState.end_move == state then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End, movePos)
            resetMoveState(widget, false)
        end
    end

    local function clickEventCallBack(node)
        --不在道具移动
        if node._movingState then
            return
        end
        local panelPos = node:getWorldPosition()
        if global.isWinPlayMode then
            SetGoodItemState(itemMoveState.begin, panelPos)
        end
        if clickCallBack then
            clickCallBack(node)
        end
    end

    local function pressEventCallBack(node)
        --不在道具移动
        if node._movingState then
            return
        end
        local panelPos = node:getWorldPosition()
        if global.isWinPlayMode then
            SetGoodItemState(itemMoveState.begin, panelPos)
        end
        if pressCallBack then
            pressCallBack(node)
        end
    end

    local isEventPress = false
    local isMoved = true
    local hasEventCallOnTouchBegin = false        --只有在响应了touchbegin 时才会去响应延时方法 因为在延时后 鼠标事件的 状态已经被置掉
    local isMobile = not global.isWinPlayMode
    local clickTimes = 0

    -- 延迟
    local function delayCallback()
        isEventPress = true

        if pressEventCallBack then
            if not pressEventCallBack then
                return false
            end

            if not isMoved then
                pressEventCallBack(widget)
                return false
            end

            local movedPos = widget:getTouchMovePosition()
            local beganPos = widget:getTouchBeganPosition()

            local diff = cc.pSub(movedPos, beganPos)
            local distSq = cc.pLengthSQ(diff)
            if distSq <= 100 then
                pressEventCallBack(widget)
            end
        end
    end

    local function touchEvent(touch, eventType)
        if global.isWinPlayMode then
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local itemMoving = ItemMoveProxy:GetMovingItemState()
            if itemMoving then --在道具移动中
                resetMoveState(widget, false)
                return
            else  -- 辅助清理状态
                if widget and not tolua.isnull(widget) and widget._movingState then
                    widget._movingState = false
                end
            end
        end
        if eventType == 0 then
            isEventPress = false
            isMoved = false
            hasEventCallOnTouchBegin = true

            if pressEventCallBack then
                performWithDelay(widget, delayCallback, global.MMO.CLICK_DOUBLE_TIME)
            end
        elseif eventType == 1 then
            local movedPos = widget:getTouchMovePosition()
            local beganPos = widget:getTouchBeganPosition()

            local diff = cc.pSub(movedPos, beganPos)
            local distSq = cc.pLengthSQ(diff)
            if not isMoved and distSq > 100 then
                isMoved = true
                if isMobile then
                    local beginMovePos = widget:getWorldPosition()
                    SetGoodItemState(itemMoveState.begin, beginMovePos)
                end
            end
            if isMobile then
                local movedPos = widget:getTouchMovePosition()
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Moving, {pos = movedPos})
            end
        elseif eventType == 2 then
            widget:stopAllActions()
            if not isMoved then
                if not isEventPress then
                    local stateOnbegin = hasEventCallOnTouchBegin
                    if clickEventCallBack and stateOnbegin then
                        clickEventCallBack(widget, eventType)
                    end
                    if global.isWinPlayMode and pcDoubleCallBack then
                        clickTimes = clickTimes + 1
                        if clickTimes >= 2 then
                            clickTimes = 0
                            if widget._clickDelayHandler then
                                UnSchedule(widget._clickDelayHandler)
                                widget._clickDelayHandler = nil                            
                            end

                            if pcDoubleCallBack then
                                pcDoubleCallBack()
                            end
                            return
                        end

                        widget._clickDelayHandler = PerformWithDelayGlobal(function()
                            clickTimes = 0
                        end, global.MMO.CLICK_DOUBLE_TIME)
                    end
                end
            else
                if isMobile then
                    local endPos = widget:getTouchEndPosition()
                    SetGoodItemState(itemMoveState.end_move, endPos)
                end
            end
            hasEventCallOnTouchBegin = false
        elseif eventType == 3 then
            if isMobile then
                local endPos = widget:getTouchEndPosition()
                SetGoodItemState(itemMoveState.end_move, endPos)
            end
            hasEventCallOnTouchBegin = false
        end
    end
    widget:addTouchEventListener(touchEvent)

    local function addIntoPanel(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = from
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.equipPos = ext.equipPos
            ItemMoveProxy:CheckAndCallBack( data )
        else
            return -1
        end
    end

    local function setNoswallowMouse(touchPos)
        --不在道具移动
        local itemData = SL:GetMetaValue("EQUIP_DATA", ext.equipPos) 
        if ((from == ITEMFROMUI.PALYER_EQUIP or from == ITEMFROMUI.HERO_EQUIP) and not itemData) or widget._movingState then
            return
        end
        local panelPos = widget:getWorldPosition()
        SetGoodItemState(itemMoveState.begin, panelPos)
    end
    global.mouseEventController:registerMouseButtonEvent(
        widget,
        {
            down_r = setNoswallowMouse,
            special_r = addIntoPanel,
            scroll = mouseScrollCallBack,
            checkIsVisible = true
        }
    )

    return widget
end

function GUI:AddMoveWidgetTypeEvent(from, to, fromToEvent, toFromEvent)
    if not from or not to then
        SL:Print("[GUI ERROR] GUI:AddMoveWidgetTypeEvent can't find type")
        return
    end
    if not fromToEvent and not toFromEvent then
        SL:Print("[GUI ERROR] GUI:AddMoveWidgetTypeEvent can't find event")
        return
    end

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    ItemMoveProxy:AddMoveTypeAndFunc(from, to, fromToEvent, toFromEvent)
end
-------------------------------------------------------------
-- Frames
function GUI:Frames_Create(parent, ID, x, y, prefix, suffix, beginframe, finishframe, ext)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Frames_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Frames_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Frames_Create ID is exists", ID)
        return nil
    end

    finishframe             = tonumber(finishframe)
    local speed             = ext and tonumber(ext.speed) or 100
    local count             = ext and tonumber(ext.count) or 1
    local loop              = ext and tonumber(ext.loop) or -1
    local finishhide        = ext and tonumber(ext.finishhide)
    local callback          = ext and ext.callback


    local fullPath  = string.format("%s%s%s", prefix, beginframe or "1", suffix)

    local widget = ccui.ImageView:create()
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:loadTexture(FixPath(fullPath))
        
    local function finishCB()
        if finishframe then
            fullPath = string.format("%s%s%s", prefix, finishframe, suffix)
            widget:loadTexture(FixPath(fullPath))
        end
        if finishhide == 1 then
            widget:setVisible(false)
        end
        if callback then
            callback()
        end
    end

    local index     = beginframe and tonumber(beginframe) or 1
    local counting  = 0
    local function delayCB()
        fullPath    = string.format("%s%s%s", prefix, index, suffix)
        widget:loadTexture(FixPath(fullPath))
        
        index       = index + 1
        if index > (count + beginframe) then
            index   = beginframe and tonumber(beginframe) or 1

            counting = counting + 1
            if loop ~= -1 and counting >= loop then
                widget:stopAllActions()
                finishCB()
            end
        elseif finishframe and index == finishframe then
            if loop ~= -1 and counting + 1 == loop then
                widget:stopAllActions()
                performWithDelay(widget, finishCB, speed*0.001)
            end
        end
    end
    schedule(widget, delayCB, speed*0.001)
    delayCB()

    return widget
end

-------------------------------------------------------------
-- CircleBar
function GUI:CircleBar_Create(parent, ID, x, y, bgImg, barImg, startper, endper, time)
    if not ID then
        SL:Print("[GUI ERROR] GUI:CircleBar_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:CircleBar_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:CircleBar_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.ImageView:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:loadTexture(FixPath(bgImg))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    local contentSize = widget:getContentSize()
    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(FixPath(barImg)))
    widget:addChild(progressTimer)
    progressTimer:setName("PROGRESS_TIMER")
    progressTimer:setPosition(cc.p(contentSize.width / 2 , contentSize.height / 2 ))
    progressTimer:setPercentage(startper)
    local function loadCompleteCB()
        progressTimer:stopAllActions()

        -- event
        local completeCB = widget.completeCB
        if completeCB then
            completeCB()
        end
    end
    progressTimer:runAction(
        cc.Sequence:create(
            cc.ProgressFromTo:create(time, startper, endper),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(loadCompleteCB)
        )
    )

    return widget
end

function GUI:CircleBar_setBarOffSet(widget, offsetX, offsetY)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if widget and widget:getChildByName("PROGRESS_TIMER") then
        local bar = widget:getChildByName("PROGRESS_TIMER")
        local contentSize = widget:getContentSize()
        bar:setPosition(cc.p(contentSize.width / 2 + offsetX, contentSize.height / 2 + offsetY))
    end
end

function GUI:CircleBar_addOnCompleteEvent(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget.completeCB = value
end

-------------------------------------------------------------
-- PercentImg 
function GUI:PercentImg_Create(parent, ID, x, y, img, direction, minValue, maxValue)
    if not ID then
        SL:Print("[GUI ERROR] GUI:PercentImg_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:PercentImg_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:PercentImg_Create ID is exists", ID)
        return nil
    end

    local widget = ccui.LoadingBar:create()
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    widget:loadTexture(FixPath(img))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    direction       = tonumber(direction) or 0
    local min       = tonumber(minValue) or 100
    local max       = tonumber(maxValue) or 100
    local percent   = math.floor(min / max * 100) or 100

    if direction == 0 or direction == 1 then
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
            barRenderer:setAnchorPoint(0, 0)
            barRenderer:setPosition(0, 0)
        else
            barRenderer:setAnchorPoint(0, 1)
            barRenderer:setPosition(0, contentSize.height)
        end
        if innerSprite then
            local rect = innerSprite:getTextureRect()
            rect.height = barRendererTextureSize.height * percent / 100
            innerSprite:setTextureRect(rect, innerSprite:isTextureRectRotated(), cc.size(rect.width, rect.height))
            if direction == 2 then
                innerSprite:setFlippedY(true)
            else
                innerSprite:setFlippedY(false)
            end
        end
    end

    return widget
end

-------------------------------------------------------------
-- UIModel 
function GUI:UIModel_Create(parent, ID, x, y, sex, feature, scale, useStaticScale, job, ext_param)
    if not ID then
        SL:Print("[GUI ERROR] GUI:UIModel_Create can't find ID")
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:UIModel_Create ID is exists", ID)
        return nil
    end

    local param = not useStaticScale and {ignoreStaticScale = true} or nil
    if job then
        param = param or {}
        param.job = job
    end
    if ext_param and next(ext_param) then
        param = param or {}
        for k, v in pairs(ext_param) do
            param[k] = v
        end
    end
    local widget = CreateStaticUIModel(sex, feature, scale, param)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

-------------------------------------------------------------
-- QuickCell 
function GUI:QuickCell_Create(parent, ID, x, y, w, h, createCB, activeCheckCB, ext_param)
    if not ID then
        SL:Print("[GUI ERROR] GUI:QuickCell_Create can't find ID")
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:QuickCell_Create ID is exists", ID)
        return nil
    end

    local widget = GUIQuickCell:Create({
        wid = w,
        hei = h,
        activeEvent = activeCheckCB,
        tick_interval = ext_param and ext_param.tick_interval
    })
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget) 
        else
            parent:addChild(widget) 
        end
    end
    widget:Update({createCell = createCB})
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))

    return widget
end

function GUI:QuickCell_Refresh(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:Refresh()
end

function GUI:QuickCell_Exit(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:Exit()
end

function GUI:QuickCell_Sleep(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:Sleep()
end

function GUI:QuickCell_Active(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:Active()
end

-------------------------------------------------------------
-- Animation
function GUI:Animation_Create()
    local widget = cc.Animation:create()
    return widget
end

function GUI:Animation_addSpriteFrame(widget, frame)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:addSpriteFrame(frame)
end

function GUI:Animation_setDelayPerUnit(widget, time)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setDelayPerUnit(time)
end

function GUI:Animation_setLoops(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setLoops(value)
end

function GUI:Animation_setRestoreOriginalFrame(widget, bool)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setRestoreOriginalFrame(bool)
end

------------------------------------------------------------
-- Sprite
function GUI:Sprite_Create(parent, ID, x, y, path)
    if not ID then
        SL:Print("[GUI ERROR] GUI:Sprite_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:Sprite_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:Sprite_Create ID is exists", ID)
        return nil
    end

    local widget = nil
    if path and SL:IsFileExist(path) then
        widget = cc.Sprite:create(path)
    else
        widget = cc.Sprite:create()
    end
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:Sprite_getSpriteFrame(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    return widget:getSpriteFrame()
end

-----------------------------------------------------------
--- LineWidget

local LineWidget = class("LineWidget", function() 
    return ccui.Widget:create() 
end)

function LineWidget:ctor()
    self._size = cc.size(0, 0)
    self._cells = {}
    self._offset = {}
end

function LineWidget:pushCell(cell, offset, isadd)
    if not cell then return end
    if isadd then
        self:addChild(cell)
    end
    local size = cell:getContentSize()
    cell:setPositionX(self._size.width + size.width / 2 + offset.x)
    table.insert(self._cells, cell)

    self._offset[#self._cells] = offset

    self._size.width = self._size.width + size.width
    self._size.height = self._size.height + size.height
end

function LineWidget:getSize()
    return self._size
end

function LineWidget:reSize()
    self:setContentSize(self._size)
    for i,cell in pairs(self._cells) do
        local offset = self._offset[i] or cc.p(0, 0)
        cell:setPositionY(self._size.height / 2 + offset.y)
    end
end

function GUI:TipLineWidget_Create(parent, ID, x, y)
    if not ID then
        SL:Print("[GUI ERROR] GUI:TipLineWidget_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:TipLineWidget_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:TipLineWidget_Create ID is exists", ID)
        return nil
    end

    local widget = LineWidget.new()
    widget:setTouchEnabled(false)
    widget:setAnchorPoint(0,0)
    widget:setName(ID)
    widget:setPosition(cc.p(x, y))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:TipLineWidget_updateSize( widget )
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if widget.reSize then
        widget:reSize()
    end
end

function GUI:TipLineWidget_getSize( widget )
    if CheckIsInvalidCObject(widget) then
        return cc.size(0, 0)
    end

    return widget:getSize()
end

function GUI:TipLineWidget_pushCell( widget , cell, offset )
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:pushCell(cell, offset)
end

function GUI:TipLineWidget_pushChildCell( widget , cell, offset )
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:pushCell(cell, offset, true)
end

------------------------------------------------------------
-- 粒子特效
function GUI:ParticleEffect_Create(parent, ID, x, y, res)
    if not ID then
        SL:Print("[GUI ERROR] GUI:ParticleEffect_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:ParticleEffect_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:ParticleEffect_Create ID is exists", ID)
        return nil
    end

    local widget  = cc.ParticleSystemQuad:create(res)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        parent:addChild(widget)
    end

    return widget
end

function GUI:ParticleEffect_setTotalParticles(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setTotalParticles(value)
end

function GUI:ParticleEffect_setSpeed(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setSpeed(value)
end

function GUI:ParticleEffect_setSpeedVar(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setSpeedVar(value)
end

function GUI:ParticleEffect_setAngle(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setAngle(widget, value)
end

function GUI:ParticleEffect_setAngleVar(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setAngleVar(widget, value)
end

-- 持续时间 -1 永久
function GUI:ParticleEffect_setDuration(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setDuration(value) 
end

-- 开始大小
function GUI:ParticleEffect_setStartSize(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setStartSize(value)
end

function GUI:ParticleEffect_setStartSizeVar(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setStartSizeVar(value)
end

-- 结束大小
function GUI:ParticleEffect_setEndSize(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setEndSize(value)
end

function GUI:ParticleEffect_setEndSizeVar(widget, value)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setEndSizeVar(value)
end

--------------------------------------------------------------
-- 骨骼动画
function GUI:SpineAnim_Create(parent, ID, x, y, jsonPath, atlasPath, trackIndex, name, loop)
    if not ID then
        SL:Print("[GUI ERROR] GUI:SpineAnim_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:SpineAnim_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:SpineAnim_Create ID is exists", ID)
        return nil
    end

    local widget  = spine.SkeletonAnimation:createWithFile(jsonPath, atlasPath)
    widget:setAnimation(trackIndex, name, loop)
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end
        parent:addChild(widget)
    end

    return widget
end

function GUI:SpineAnim_setAnimation(widget, trackIndex, name, loop)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setAnimation(trackIndex, name, loop)
end

function GUI:SpineAnim_addAnimation(widget, trackIndex, name, loop)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:addAnimation(trackIndex, name, loop)
end

-- duration 过渡时间
function GUI:SpineAnim_setMix(widget, fromAnimName, toAnimName, duration)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:setMix(fromAnimName, toAnimName, duration)
end

-------------------------------------------------------------
-- WebView
function GUI:WebView_Create(parent, ID, x, y, width, height, index)
    if not ID then
        SL:Print("[GUI ERROR] GUI:WebView_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:WebView_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:WebView_Create ID is exists", ID)
        return nil
    end

    local widget  = ccexp.CustomView and ccexp.CustomView:create() or (ccexp.WebView and ccexp.WebView:create())
    local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local URLList = envProxy:GetCustomDataByKey("useUrlList")
    if widget then
        widget:setName(ID)
        widget:setContentSize(cc.size(width, height))
        if URLList and URLList[index] then
            widget:loadURL(URLList[index])
        else
            ShowSystemTips("链接未配置!")
        end
        if parent ~= NONEED_PARENT_CODE then
            if CheckIsInvalidCObject(parent) then
                return nil
            end

            parent:addChild(widget)
        end
        widget:setAnchorPoint(cc.p(0, 0))
        widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    end

    return widget
end

-------------------------------------------------------------
-- ScrapePic
function GUI:ScrapePic_Create(parent, ID, x, y, bgImg, maskImg, clearHei, moveTime, beginTime, callback)
    if not ID then
        SL:Print("[GUI ERROR] GUI:ScrapePic_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:ScrapePic_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:ScrapePic_Create ID is exists", ID)
        return nil
    end

    if not bgImg or not global.FileUtilCtl:isFileExist(bgImg) then
        SL:Print("[GUI ERROR] GUI:ScrapePic_Create showImg can't find res path! ")
        return nil
    end

    local widget = ccui.Layout:create()
    if parent ~= NONEED_PARENT_CODE then
        if CheckIsInvalidCObject(parent) then
            return nil
        end

        if "ccui.ListView" == tolua.type(parent) then
            parent:pushBackCustomItem(widget) 
        else
            parent:addChild(widget) 
        end
    end
    widget:setName(ID)
    widget:setPosition(cc.p(fixPosition(x), fixPosition(y)))
    widget:setAnchorPoint(cc.p(0, 0))

    local img = ccui.ImageView:create()
    img:loadTexture(bgImg)
    local imgSize = img:getContentSize()
    widget:setContentSize(imgSize)
    widget:addChild(img)
    img:setPosition(cc.p(fixPosition(imgSize.width / 2), fixPosition(imgSize.height / 2)))

    local radius = clearHei and math.floor(clearHei / 2) or 8
    local drawNode = cc.DrawNode:create()
    widget:addChild(drawNode)
    drawNode:retain()
    drawNode:drawSolidCircle(cc.p(0, 0), radius, 0, radius, 1, 1, cc.c4b(0, 0, 0, 0))
    drawNode:setVisible(false)

    local renderTexture = cc.RenderTexture:create(imgSize.width, imgSize.height)
    renderTexture:retain()
    renderTexture:setPosition(cc.p(fixPosition(imgSize.width / 2), fixPosition(imgSize.height / 2)))
    widget:addChild(renderTexture, 10)

    local mask = ccui.ImageView:create()
    mask:loadTexture(maskImg)
    mask:ignoreContentAdaptWithSize(false)
    mask:setContentSize(imgSize)
    mask:setPosition(cc.p(fixPosition(imgSize.width / 2), fixPosition(imgSize.height / 2)))
    renderTexture:begin()
    mask:visit()
    renderTexture:endToLua()


    local lastMovePos = nil
    local moveBT = nil
    local iMoveTime = 0
    local iBeginAct = nil
    local releaseCount = 0
    local touchPosList = {}

    local function timeCB()
        if releaseCount == 0 then
            releaseCount = releaseCount + 1

            if drawNode then
                drawNode:removeFromParent()
                drawNode:autorelease()
                drawNode = nil
            end

            if renderTexture then
                renderTexture:removeFromParent()
                renderTexture:autorelease()
                renderTexture = nil
            end
            if callback and type(callback) == "function" then
                callback()
            end
        end
    end

    local function getKey(x, y)
        return x * 10000 + y
    end

    local function addTouchPoint(x, y)
        local key = getKey(x, y)
        if touchPosList[key] then
            return
        end
        if x <= 0 or x >= imgSize.width then
            return
        end
        if y <= 0 or y >= imgSize.height then
            return
        end
        
        if not touchPosList[key] then
            touchPosList[key] = true
        end
    end

    widget:setTouchEnabled(true)
    widget:addTouchEventListener(function (node, eventType)
        if eventType == 0 then
            local beganPos = node:getTouchBeganPosition()
            lastMovePos = nil
            moveBT = os.clock()
            if tonumber(beginTime) and not iBeginAct then
                iBeginAct = performWithDelay(widget, function()
                    timeCB()
                end, tonumber(beginTime))
            end
        elseif eventType == 1 then
            if releaseCount > 0 then
                return
            end

            local movedPos = node:getTouchMovePosition()
            local beganPos = node:getTouchBeganPosition()
            local tt = GUI:convertToNodeSpace(widget, movedPos.x, movedPos.y)
            tt = fixPosition(tt)
            local key = getKey(tt.x, tt.y)
            if touchPosList[key] then
                return
            end

            drawNode:setPosition(tt)
            drawNode:setBlendFunc({src = gl.ONE, dst = gl.ZERO})
            drawNode:setVisible(true)
            renderTexture:begin()
            drawNode:visit()
            renderTexture:endToLua()
            drawNode:setVisible(false)

            if lastMovePos then
                local distance = math.abs(cc.pGetDistance(lastMovePos, movedPos))
                local pos = cc.pSub(lastMovePos, movedPos)
                local angle = 180 * (cc.pToAngleSelf(pos) / math.pi)

                local height = radius * 2
                local midPos = cc.pMidpoint(lastMovePos, movedPos)
                local rectNode = cc.DrawNode:create()
                local posList = {
                    cc.p(- distance / 2 , - height / 2),
                    cc.p(- distance / 2 , height / 2),
                    cc.p(distance / 2 , height / 2),
                    cc.p(distance / 2 , - height / 2)
                }
                rectNode:drawSolidPoly(posList, 4, cc.c4b(0,0,0,0))
                midPos = fixPosition(GUI:convertToNodeSpace(widget, midPos.x, midPos.y))
                rectNode:setPosition(midPos)
                rectNode:setRotation(angle)
                rectNode:setBlendFunc({src = gl.ONE, dst = gl.ZERO})
                renderTexture:begin()
                rectNode:visit()
                renderTexture:endToLua()
            end

            -- pos
            local mPos = GUI:convertToNodeSpace(widget, movedPos.x, movedPos.y)
            mPos = fixPosition(mPos)
            for i = mPos.x - radius, mPos.x + radius do
                for j = mPos.y - radius, mPos.y + radius do
                    if math.pow(i - mPos.x, 2) + math.pow(j - mPos.y, 2) <= math.pow(radius, 2) then
                        addTouchPoint(i, j)
                    end
                end
            end

            if moveBT then
                iMoveTime = iMoveTime + (os.clock() - moveBT)
            end
            moveBT = os.clock()

            if tonumber(moveTime) then
                if iMoveTime >= tonumber(moveTime) then
                    timeCB()
                end
            end
            
            lastMovePos = movedPos

        elseif eventType == 2 or eventType == 3 then
            local endPos = node:getTouchEndPosition()
            lastMovePos = nil
            moveBT = nil
        end
    end)

    return widget
end

-------------------------------------------------------------
-- MoveTo
function GUI:ActionMoveTo(time, x, y)
    return cc.MoveTo:create(time, cc.p(x, y))
end
-- MoveBy
function GUI:ActionMoveBy(time, x, y)
    return cc.MoveBy:create(time, cc.p(x, y))
end

-- ScaleTo
function GUI:ActionScaleTo(time, ratio, ...)
    return cc.ScaleTo:create(time, ratio, ...)
end
-- ScaleBy
function GUI:ActionScaleBy(time, ratio, ...)
    return cc.ScaleBy:create(time, ratio, ...)
end

function GUI:ActionScaleXTo(time, x)
    return cc.ScaleTo:create(time, x, 1)
end
function GUI:ActionScaleYTo(time, y)
    return cc.ScaleTo:create(time, 1, y)
end

function GUI:ActionScaleXBy(time, x)
    return cc.ScaleBy:create(time, x, 1)
end

function GUI:ActionScaleYBy(time, y)
    return cc.ScaleBy:create(time, 1, y)
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

-- RemoveSelf
function GUI:ActionRemoveSelf()
    return cc.RemoveSelf:create()
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

-- BezierTo
function GUI:ActionBezierTo(time, ...)
    return cc.BezierTo:create(time, { ... })
end

-- Animate
function GUI:ActionAnimate(animation)
    return cc.Animate:create(animation)
end

-- EaseExponentialIn
function GUI:ActionEaseExponentialIn(action)
    return cc.EaseExponentialIn:create(action)
end

-- EaseExponentialOut
function GUI:ActionEaseExponentialOut(action)
    return cc.EaseExponentialOut:create(action)
end

-- EaseExponentialOut
function GUI:ActionEaseExponentialInOut(action)
    return cc.EaseExponentialInOut:create(action)
end


------------------------------------------
-- timeline
function GUI:Timeline_Window1(widget, timelineCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end

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
    if CheckIsInvalidCObject(widget) then
        return false
    end

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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:stopAllActions()
end

function GUI:Timeline_SetTag(action, tag)
    if CheckIsInvalidCObject(action) then
        return false
    end
    
    action:setTag(tag)
end

function GUI:Timeline_StopByTag(widget, tag)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:stopActionByTag(tag)
end

function GUI:Timeline_FadeOut(widget, time, timelineCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
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

function GUI:Timeline_EaseSineIn_MoveTo(widget, value, time, timelineCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    value = value or cc.p(0, 0)
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.EaseSineIn:create(cc.MoveTo:create(time, value)), cc.CallFunc:create(timelineCB))
    else
        action = cc.EaseSineIn:create(cc.MoveTo:create(time, value))
    end
    widget:runAction(action)

    return action
end

function GUI:Timeline_EaseSineOut_MoveTo(widget, value, time, timelineCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    value = value or cc.p(0, 0)
    time = time or 1

    local action = nil
    if timelineCB then
        action = cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(time, value)), cc.CallFunc:create(timelineCB))
    else
        action = cc.EaseSineOut:create(cc.MoveTo:create(time, value))
    end
    widget:runAction(action)

    return action
end

function GUI:TimeLine_BezierTo(time, ...)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return cc.BezierTo:create(time, { ... })
end

function GUI:Timeline_Waggle(widget, time, angle)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    time = time or 0.05
    angle = angle or 20
    widget:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.RotateBy:create(time, angle),
                cc.RotateBy:create(time, -angle), 
                cc.RotateBy:create(time, -angle),
                cc.RotateBy:create(time, angle),
                cc.RotateBy:create(time, angle),
                cc.RotateBy:create(time, -angle), 
                cc.RotateBy:create(time, -angle),
                cc.RotateBy:create(time, angle),
                cc.RotateBy:create(time, angle),
                cc.RotateBy:create(time, -angle), 
                cc.RotateBy:create(time, -angle),
                cc.RotateBy:create(time, angle),
                cc.DelayTime:create(3)
            )
        )
    )
end

function GUI:Timeline_OrbitCamera(widget, time, radius, deltaRadius, angleZ, deltaAngleZ, angleX, deltaAngleX, timelineCB)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local oribitAction = cc.OrbitCamera:create(time, radius, deltaRadius, angleZ, deltaAngleZ, angleX, deltaAngleX)
    if timelineCB then
        widget:runAction(cc.Sequence:create(
            oribitAction,
            cc.CallFunc:create(timelineCB)
        ))
    else
        widget:runAction(oribitAction)
    end
end

-- 点击间隔
function GUI:setClickDelay(widget, time)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    DelayTouchEnabled(widget, time or global.MMO.CLICK_DOUBLE_TIME)
end

function GUI:ui_delegate(nativeUI)
    return ui_delegate(nativeUI)
end

-- 数字滚动动画
function GUI:Timeline_DigitChange(widget, cur, target, interval)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    if tolua.isnull(widget) then
        return false
    end

    local _SetText = {
        ["Label"]  = function (widget, value) widget:setString(value) end,
        ["Button"] = function (widget, value) widget:setTitleText(value) end,
        ["TextAtlas"] = function (widget, value) widget:setString(value) end,
    }

    local descript = widget:getDescription()
    if not _SetText[descript] then
        return false
    end

    -- 数字动态变化(val1 -> val2)
    local function _ChangeNum(val1, val2)
        local isUp = val2 > val1
        local str = isUp and tostring(val2) or tostring(val1)
        for i=1,string.len(str) do
            if val1 % 10 ^ i ~= val2 % 10 ^ i then
                if isUp then    -- 递增
                    return val1 + 10 ^ (i-1)
                else            -- 递减
                    return val1 - 10 ^ (i-1)
                end
            end
        end
    end

    local function _Stop()
        if SL.DigitChangeTimerID then
            SL:UnSchedule(SL.DigitChangeTimerID)
            SL.DigitChangeTimerID = nil
        end
    end

    _Stop()

    local isUp = target > cur

    SL.DigitChangeTimerID = SL:Schedule(function ()

        if isUp then
            if cur >= target then
                return _Stop()
            end
        else
            if cur <= target then
                return _Stop()
            end
        end

        cur = _ChangeNum(cur, target)

        if widget and not tolua.isnull(widget) then
            _SetText[descript](widget, cur)
        else
            _Stop()
        end
        
    end, interval or 0.01)
end

-- 进度条动画
-- widget:进度条
-- widgetBg:进度条变化时的底(背景是进度条的话  type传值1或者不传；  如果Layout的话 必须传一个值，这个值不能是1)
-- param = {
--     count:       重置次数
--     num:         当前剩余血条的数量
--     to:          目标进度值
--     step:        动画步长
--     interval:    增长的速度， 默认0.01
--     colors:      血条颜色变化顺序
--     callback:    回调函数
--     opacity:     血条透明度
--     type:        进度条类型
-- }

function GUI:Timeline_Progress(widget, widgetBg, param)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    local count    = param.count or 0
    local num      = param.num or 1
    local to       = param.to or 0
    local step     = param.step or 0
    local interval = param.interval or 0.01
    local colors   = param.colors or nil
    local callback = param.callback or nil
    local opacity  = param.opacity or 255
    local type     = param.type or 1
    

    local from = widget:getPercent()
    widget:setPercent(from)

    local function _GetColor(n)
        return colors[n] or colors[#colors]
    end

    local k = 0
    local function _CallFunc()
        from = from + step
        if k == count then
            if step > 0 and from > to then
                from = to
            elseif step < 0 and from < to then
                from = to
            end
        end
        
        local percent = from
        if k < count then
            if step < 0 then
                if from <= 0 then
                    from = 100   
                    k = k + 1
                    if colors then
                        local n = #colors
                        if type == 1 then
                            widget:loadTexture(_GetColor(k % n))
                        else
                            widget:setColor(SL:ConvertColorFromHexString(_GetColor(k % n)))
                        end

                        if widgetBg then
                            if num == 1 then
                                widgetBg:setOpacity(0)
                            else
                                if type == 1 then
                                    widgetBg:loadTexture(_GetColor((k+1) % n))
                                    widgetBg:setPercent(100)
                                else
                                    widgetBg:setBackGroundColor(SL:ConvertColorFromHexString(_GetColor((k+1) % n)))
                                end
                                widgetBg:setOpacity(255)
                            end
                        end
                    end
                    if callback then
                        callback(k)
                    end
                end
            else
                if from >= 100 then
                    from = 0   
                    k = k + 1
                    if colors then
                        local n = #colors
                        if type == 1 then
                            widget:loadTexture(_GetColor(k % n))
                        else
                            widget:setColor(SL:ConvertColorFromHexString(_GetColor(k % n)))
                        end
                        if widgetBg then
                            if num == 1 then
                                widgetBg:setOpacity(0)
                            else
                                if type == 1 then
                                    widgetBg:loadTexture(_GetColor((k+1) % n))
                                    widgetBg:setPercent(100)
                                else
                                    widgetBg:setBackGroundColor(SL:ConvertColorFromHexString(_GetColor((k+1) % n)))
                                end
                                widgetBg:setOpacity(255)
                            end
                        end
                    end
                    if callback then
                        callback(k)
                    end
                end
            end
        else
            local isStop = (step < 0 and from <= to) or (step >= 0 and from >= to)
            if isStop then
                from = to
                widget:stopAllActions()
                
                if callback then
                    callback(k, true)
                end
            end

            if colors then
                if type == 1 then
                    widget:loadTexture(_GetColor(1))
                else
                    widget:setColor(SL:ConvertColorFromHexString(_GetColor(1)))
                end

                if widgetBg then
                    if num == 1 then
                        widgetBg:setOpacity(0)
                    else
                        if type == 1 then
                            widgetBg:loadTexture(_GetColor(2))
                            widgetBg:setPercent(100)
                        else
                            widgetBg:setBackGroundColor(SL:ConvertColorFromHexString(_GetColor(2)))
                        end
                        widgetBg:setOpacity(255)
                    end
                end
            end
        end
        widget:setPercent(percent)
    end

    schedule(widget, _CallFunc, interval)
end

-- 自适应布局
-- pNode: ScrollView(常用)、Panel（pNode 中的子控件不显示，则不参与排版）
-- param = {
--     dir： 1：垂直; 2: 水平; 3： 两者
--     gap:  x: 左右间距; y: 上下间距; l: 左边距; t: 上边距
--     addDir: 动画增长方式 1: 从上到下（从左到右）（多行从左上角）, 2：中间到两边（多行从右上角）, 3：从下到上（从右到左）
--     colnum: 多行列数（dir必须是2）
--     autosize: 根据内容自适应容器
--     sortfunc: 排序函数
--     interval：增长方式动画播放时间间隔, 不传值则不播放动画
--     rownums ： 每一行的数量table ; 例如：rownums = {3, 2} （第一行3个元素，第二行2个元素）
-- }
function GUI:UserUILayout(pNode, param)
    if CheckIsInvalidCObject(pNode) then
        return false
    end

    local isScrollView = tolua.type(pNode) == "ccui.ScrollView"
    pNode:stopAllActions()

    --初始化默认值
    param           = param or {}
    local dir       = param.dir and param.dir or (isScrollView and pNode:getDirection() or 3)
    dir             = math.min(dir, 3)
    local gap       = param.gap
    local addDir    = param.addDir or 1
    local colnum    = param.colnum or 0
    local autosize  = param.autosize or false
    local sortfunc  = param.sortfunc
    local interval  = param.play and 0.01 or param.interval
    local rownums   = param.rownums or {}
    local loadStyle = param.loadStyle or 1

    local xGap = (gap and gap.x) and gap.x or (param.x or 0)     -- 控件左右间距
    local yGap = (gap and gap.y) and gap.y or (param.y or 0)     -- 控件上下间距

    local xMar = (gap and gap.l) and gap.l or (param.l or 0)     -- 左边距
    local yMar = (gap and gap.t) and gap.t or (param.t or 0)     -- 上边距

    --水平和垂直方向只能有一个
    local visibleChildren = {}
    for i,v in ipairs(pNode:getChildren()) do
        if v and v:isVisible() then
            v:setAnchorPoint({x = 0.5, y = 0.5})
            table.insert(visibleChildren, v)
        end
    end
    local num = #visibleChildren
    if num == 0 then
        return cc.size(0, 0)
    end

    if isScrollView then
        pNode:setDirection(dir)
    end

    local cSize  = visibleChildren[1]:getContentSize()
    local pSize  = pNode:getContentSize()
    local width  = xMar * 2
    local height = yMar * 2
    local offX   = 0
    local offY   = 0
    
    if dir == 1 then    -- 垂直
        height = height + num * (cSize.height + yGap) - yGap
        width  = pSize.width
        if width > cSize.width then
            width = cSize.width
        end
    elseif dir == 2 then    -- 水平
        width  = width  + num * (cSize.width  + xGap) - xGap
        height = pSize.height
        if height > cSize.height then
            height = cSize.height
        end
    else    -- 多行多列
        local rownum = 0
        for i,cnt in ipairs(rownums) do
            if cnt and tonumber(cnt) then
                colnum = math.max(colnum, cnt)
                if autosize then
                    if cnt > 0 then
                        rownum = rownum + 1
                    end
                else
                    rownum = rownum + 1
                end
            end
        end

        if colnum < 1 then
            colnum = math.max(1, math.floor(pSize.width / cSize.width))
        end

        if rownum == 0 then
            rownum = math.ceil(num / colnum)
        end

        width  = width  + colnum * (cSize.width + xGap)  - xGap
        height = height + rownum * (cSize.height + yGap) - yGap
    end

    -- 设置容器的尺寸
    if autosize then
        pNode:setContentSize({width = width, height = height})
        if isScrollView then
            pNode:setInnerContainerSize({width = width, height = height})
        end
    else
        if pSize.width > width then
            offX = (pSize.width - width) / 2
        end
        if pSize.height > height then
            offY = (pSize.height - height) / 2
        end

        width  = math.max(pSize.width, width)
        height = math.max(pSize.height, height)
        if isScrollView then
            pNode:setInnerContainerSize({width = width, height = height})
        else
            pNode:setContentSize({width = width, height = height})
        end
    end
    
    -- 自己排序
    if sortfunc then
        sortfunc(visibleChildren)
    end

    local scrollFunc = {
        [1] = function ()
            if addDir == 2 then
                pNode:scrollToPercentVertical(50, 0.01, false)
            elseif addDir == 3 then
                pNode:scrollToPercentVertical(100, 0.01, false)
            end
        end,
        [2] = function ()
            if addDir == 2 then
                pNode:scrollToPercentHorizontal(50, 0.01, false)
            elseif addDir == 3 then
                pNode:scrollToPercentHorizontal(100, 0.01, false)
            end
        end
    }

    -- 水平垂直滚动指定位置
    if isScrollView and (dir == 1 or dir == 2) then
        local func = scrollFunc[dir]
        if func then
            func()
        end
    end

    if dir > 2 then -- 双方向
        local rows = {}
        local cnum = 0
        for i,cnt in ipairs(rownums) do
            if cnt and tonumber(cnt) then
                cnum = cnum + cnt
                if autosize then
                    if cnt > 0 then
                        rows[#rows+1] = cnum
                    end
                else
                    rows[i] = cnum
                end
            end
        end

        for i,item in ipairs(visibleChildren) do
            local hang = math.ceil(i / colnum)
            local k = i

            for r,v in ipairs(rows) do
                if i <= v then
                    hang = r
                    if rows[r-1] then
                        k = i - rows[r-1]
                    end
                    break
                end
            end

            local x = 0
            local y = 0

            local mod = k % colnum
            if addDir == 2 then
                if autosize then
                    x = mod == 0 and xMar + offX + cSize.width/2 or (xMar + (colnum - mod + 1-0.5) * (cSize.width + xGap) - xGap/2) + offX
                else
                    x = mod == 0 and xMar + offX * 2 + cSize.width/2 or (xMar + (colnum - mod + 1-0.5) * (cSize.width + xGap) - xGap/2) + offX * 2
                end
            else
                if autosize then
                    x = mod == 0 and (width - xMar - cSize.width/2) - offX or (xMar + (mod-0.5) * (cSize.width + xGap) - xGap/2) + offX
                else
                    x = mod == 0 and (width - xMar - cSize.width/2) - offX * 2 or (xMar + (mod-0.5) * (cSize.width + xGap) - xGap/2)
                end
            end

            if loadStyle == 3 then
                y = yMar + (hang - 0.5) * cSize.height + (hang - 1) * yGap
            elseif loadStyle == 2 then
                y = height - yMar - (hang - 0.5) * cSize.height - (hang - 1) * yGap - offY
            else
                y = height - yMar - (hang - 0.5) * cSize.height - (hang - 1) * yGap
            end

            item:setPosition({x = x, y = y})
            if interval then
                item:setVisible(false)
                item:runAction(cc.Sequence:create(cc.DelayTime:create(i*interval), cc.Show:create()))
            else
                item:setVisible(true)
            end
        end
    else    -- 水平、垂直
        for i,item in ipairs(visibleChildren) do
            local x = 0
            local y = 0
            if dir == 1 then
                x = width / 2
                if addDir == 1 then     -- 上到下
                    y = height - yMar - cSize.height*(i-0.5) - (i-1) * yGap
                elseif addDir == 3 then -- 下到上
                    y = yMar + cSize.height*(i-0.5) + (i-1) * yGap
                else    -- 居中
                    y = height - yMar - cSize.height*(i-0.5) - (i-1) * yGap - offY
                    item.__pos = clone({x = x, y = y})
                    y = height / 2
                end
            elseif dir == 2 then
                y = height / 2
                if addDir == 1 then     -- 左到右
                    x = xMar + cSize.width*(i-0.5) + (i-1) * xGap
                elseif addDir == 3 then -- 右到左
                    x = width - xMar - cSize.width*(i-0.5) - (i-1) * xGap
                else    -- 居中
                    x = width - xMar - cSize.width*(i-0.5) - (i-1) * xGap - offX
                    item.__pos = clone({x = x, y = y})
                    x = width / 2
                end
            end
            item:setPosition({x = x, y = y})

            if interval then
                item:setVisible(false)
            else
                item:setVisible(true)
            end
        end

        if interval then
            if addDir == 2 then
                local r = math.floor(num / 2)
                local minR = num % 2 == 0 and r or r + 1
                local maxR = r + 1
                for i=1,num do
                    local item = visibleChildren[i]
                    if item then
                        local t = 1
                        t = i > maxR and i - maxR or t
                        t = i < minR and minR - i or t
                        item:setLocalZOrder(t)
                        item:setVisible(true)
                        item:setOpacity(0)
                        item:runAction(cc.Spawn:create(cc.FadeTo:create(interval * t, 255), cc.EaseExponentialOut:create(cc.MoveTo:create(interval * t, item.__pos))))
                    end
                end
            else
                for i=1,num do
                    local item = visibleChildren[i]
                    if item then
                        item:runAction(cc.Sequence:create(cc.DelayTime:create(i*interval), cc.Show:create()))
                    end
                end
            end
        end
    end
    return cc.size(width, height)
end
--[[
    param = {
        bgPic:      背景图  
        barPic:     滑动按钮图片
        Arr1PicN:   上（正常图）
        Arr1PicP:   上（按下图）可不传
        Arr2PicN:   下（正常图）
        Arr2PicP:   下（按下图）可不传
        default:    进度条值（默认是0）
        x:          进度条坐标 x
        y:          进度条坐标 y
        list:       滚动的容器 list
        callFunc:   容器滚动的回调函数
    }
]]
function GUI:SetScrollViewVerticalBar(parent, param)
    if CheckIsInvalidCObject(parent) then
        return false
    end
    
    local bgPic = FixPath(param.bgPic)
    local barPic = FixPath(param.barPic)
    local Arr1PicN = FixPath(param.Arr1PicN)
    local Arr1PicP = FixPath(param.Arr1PicP)
    local Arr2PicN = FixPath(param.Arr2PicN)
    local Arr2PicP = FixPath(param.Arr2PicP)
    local default = param.default or 0
    local x = param.x
    local y = param.y
    local list = param.list
    local callFunc = param.callFunc

    -- 背景
    local bar_bg = GUI:Image_Create(parent, "bar_bg", x, y, bgPic)

    local bgWidth  = GUI:getContentSize(bar_bg).width
    local bgHeight = GUI:getContentSize(list).height

    GUI:setContentSize(bar_bg, bgWidth, bgHeight)

    -- 上
    local btnArr_1 = GUI:Button_Create(bar_bg, "btnArr_1", bgWidth/2, bgHeight, Arr1PicN)
    if Arr1PicP then
        GUI:Button_loadTexturePressed(btnArr_1, Arr1PicP)
    end
    GUI:setAnchorPoint(btnArr_1, 0.5, 1)
    -- 下
    local btnArr_2 = GUI:Button_Create(bar_bg, "btnArr_2", bgWidth/2, 0, Arr2PicN)
    if Arr2PicP then
        GUI:Button_loadTexturePressed(btnArr_2, Arr2PicP)
    end
    GUI:setAnchorPoint(btnArr_2, 0.5, 0)
    --bar
    local sliderBar = GUI:Slider_Create(bar_bg, "sliderBar", bgWidth/2, bgHeight/2, "res/public/0.png", "res/public/0.png", barPic)
    local btnArr_1_hh = GUI:getContentSize(btnArr_1).height
    local btnArr2Pichh = GUI:getContentSize(btnArr_2).height
    local Image = ccui.ImageView:create(barPic)
    local imageWidth  = GUI:getContentSize(Image).width
    local imageHeight = GUI:getContentSize(Image).height
    GUI:setContentSize(sliderBar, bgHeight - btnArr_1_hh - btnArr2Pichh - imageHeight  , imageWidth)

    GUI:setAnchorPoint(sliderBar, 0.5, 0.5)
    GUI:setRotation(sliderBar, 90)
    GUI:Slider_setPercent(sliderBar, default)

    -- 计算偏移
    local function GetListOffY()
        return list:getInnerContainerSize().height - list:getContentSize().height
    end

    -- list_cells
    local function listCallback(sender, eventType)
        if callFunc then
            callFunc(sender, eventType)
        end

        local setBarPercent = function ()
            local posY = list:getInnerContainerPosition().y
            local offY = GetListOffY()
            local percent = 100
            if offY > 0 then
                percent = math.min(math.max(0, (offY + posY) / offY * 100), 100)
            end
            sliderBar:setPercent(percent)    
        end
        performWithDelay(sliderBar, setBarPercent, 0.01)
    end

    if tolua.type(list) == "ccui.ListView" then
        list:addScrollViewEventListener(listCallback)
    else
        list:addEventListener(listCallback)
    end
    list:addMouseScrollPercent()

    -- Slider_bar
    sliderBar:addEventListener(function ()
        local offY = GetListOffY()
        if offY > 0 then
            list:scrollToPercentVertical(sliderBar:getPercent(), 0.03, false)
        else
            sliderBar:setPercent(100)
        end
    end)

    local function UpOrDown(percent)
        sliderBar:setPercent(percent)
        list:scrollToPercentVertical(percent, 0.03, false)
    end
    
    btnArr_1:addClickEventListener(function ()
        local offY = GetListOffY()
        if offY > 0 then
            UpOrDown(0)
        end
    end)
    btnArr_1:setTouchEnabled(true)

    btnArr_2:addClickEventListener(function ()
        local offY = GetListOffY()
        if offY > 0 then
            UpOrDown(100)
        end
    end)
    btnArr_2:setTouchEnabled(true)
end

function GUI:ShowWorldTips(tips, worldPos, anchorPoint)
    showWorldTips(tips, worldPos, anchorPoint)
end

function GUI:HideWorldTips()
    hideMouseOverTips()
end

--创建技能item
function GUI:CreateSkillItem(parent, skillID)
    if CheckIsInvalidCObject(parent) then
        return false
    end
    
    local item = SkillItem:create(skillID)
    parent:addChild(item)
    return item
end

function GUI:Retain(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:retain()
end

function GUI:addRef(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:retain()
end

function GUI:Release(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    widget:release()
end

function GUI:decRef(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:release()
end

-- FIXME: 写错了方法名，但是不能删
function GUI:defRef(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:release()
end

function GUI:autoDecRef(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:autorelease()
end

-- FIXME: 写错了方法名，但是不能删
function GUI:autoDefRef(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:autorelease()
end

function GUI:Rect(x, y, width, height)
    return cc.rect(x, y, width, height)
end

function GUI:RectContainsPoint(Rect, position)
    return cc.rectContainsPoint(Rect, position)
end

function GUI:Size(width, height)
    return cc.size(width, height)
end

function GUI:p(x, y)
    return cc.p(x, y)
end

--获取图片尺寸
function GUI:getImageContentSize(path)
    local img = ccui.ImageView:create(path)
    return  img:getContentSize() 
end

--[[
    文本提示框
    str文本
    width文本宽度
]]
function GUI:GetWordTips(str, width)
    return GetWordTips({str = str,width = width})
end

function GUI:isClippingParentContainsPoint(widget, position)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    return widget:isClippingParentContainsPoint(position)
end

function GUI:setEnabled(widget, enable)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    
    widget:setEnabled(enable)
end

-- 刷坐标整数
function GUI:RefPosByParent(widget)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if widget then
        refPositionByParent(widget)
    end
end

-- 旋转滑动 容器
function GUI:RotateView_Create(parent, ID, x, y, width, height, scrollGap, param)
    if not ID then
        SL:Print("[GUI ERROR] GUI:RotateView_Create can't find ID")
        return nil
    end

    if not parent then
        SL:Print("[GUI ERROR] GUI:RotateView_Create can't find parent", ID)
        return nil
    end

    if SL._DEBUG and parent ~= NONEED_PARENT_CODE and parent:getChildByName(ID) then
        SL:Print("[GUI ERROR] GUI:RotateView_Create ID is exists", ID)
        return nil
    end

    if CheckIsInvalidCObject(parent) then
        return nil
    end

    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_UI_ROTATEVIEW)
    local rotateView = UIRotateView.main(parent, ID, x, y, width, height, scrollGap, param)

    return rotateView
end 

function GUI:RotateView_addChild(widget, value, index)
    if CheckIsInvalidCObject(widget) then
        return false
    end
    if CheckIsInvalidCObject(value) then
        return false
    end
    if not index then 
        SL:Print("[GUI ERROR] GUI:RotateView_addChild index is nil")
        return false
    end 

    UIRotateView.addRotateViewChild(widget, value, index)
end 

function GUI:RotateView_getChildByIndex(widget, index)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if not index then 
        SL:Print("[GUI ERROR] GUI:RotateView_getChildByIndex index is nil")
        return false
    end 

    return UIRotateView.getRotateViewChildByIndex(widget, index)
end 

function GUI:RotateView_getItemByIndex(widget, index)
    if CheckIsInvalidCObject(widget) then
        return false
    end

    if not index then 
        SL:Print("[GUI ERROR] GUI:RotateView_getChildByIndex index is nil")
        return false
    end 

    return UIRotateView.getRotateViewItemByIndex(widget, index)
end

-- 不提供对外函数 --------------------------------------------------------------------------------------------------------------------------
function GUI:setChineseName(widget, value)
    widget._chinesename = value
end

function GUI:getChineseName(widget)
    return widget._chinesename or ""
end

function GUI:setID(widget, value)
    widget._ID = value
end

function GUI:getID(widget)
    return widget._ID or 0
end

function GUI:setChildID(widget, value)
    widget._childID = value
end

function GUI:getChildID(widget)
    return widget._childID or 0
end

function GUI:setJumpIndex(widget, value)
    widget._jump_index = value
end

function GUI:getJumpIndex(widget)
    return widget._jump_index or 0
end

function GUI:setClickStatus(widget, value)
    widget._Click_Status = value
end

function GUI:setContainerIndexTable(widget, value)
    widget._Container_table = value
end

function GUI:setButtonPage(widget, value)
    widget._Button_page = value
end

function GUI:setButtonPressColor(widget, value)
    widget._Button_press_C = value
end

function GUI:setUIIDs(widget, value)
    widget._uiIDs = value
end

function GUI:getRedID(widget)
    if tolua.isnull(widget) then
        return false
    end
    if widget._uiIDs then
        return false
    end
    return tonumber(widget._uiIDs.redID)
end

function GUI:getGuideID(widget)
    if tolua.isnull(widget) then
        return false
    end
    if widget._uiIDs then
        return false
    end
    return tonumber(widget._uiIDs.guideID)
end
-----------------------------------------------------------------------------------------------------------------------------------------------