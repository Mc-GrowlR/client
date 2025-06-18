local cjson     = require("cjson")

local tconcat   = table.concat
local tinsert   = table.insert

local tostring  = tostring
local pairs     = pairs
local type      = type
local next      = next

local sreverse  = string.reverse
local sformat   = string.format
local sfind     = string.find
local sbyte     = string.byte
local sgsub     = string.gsub
local ssub      = string.sub
local srep      = string.rep
local slen      = string.len

local globalSchedule = {} -- 全局函数回调

_DEBUG = global.isDebugMode

function releasePrint(...)
    if global.isGMMode then
        return
    end
    release_print(...)
end

function Print(...)
    if _DEBUG then
        release_print(...)
    end
end
rawset(_G, "print", Print)

function PrintTableByTree(root)
    if not _DEBUG then
        return nil
    end

    if nil == root then
        release_print("nil")
        return nil
    end

    local cache = {[root] = "."}
    local function _dump(t, space, name)
        local temp = {}
        local value = ""
        local tempStr = ""
        local endPos = nil
        for k, v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp, "+" .. key .. " {" .. cache[v] .. "}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp, "+" .. key .. _dump(v, space .. (next(t, k) and "|" or " ") .. srep(" ", #key), new_key))
            else
                value = tostring(v)
                if nil == value then
                    tempStr = "nil"
                else
                    endPos = sfind(value, "\0")
                    if endPos == nil then
                        tempStr = value
                    elseif endPos == 1 then
                        tempStr = ""
                    else
                        tempStr = ssub(value, 1, endPos)
                    end
                end

                tinsert(temp, "+" .. key .. " : " .. tempStr)
            end
        end
        return tconcat(temp, "\n" .. space)
    end
    release_print("Table:" .. tostring(root) .. "\n" .. _dump(root, "", ""))
end
PrintTable = PrintTableByTree

-- print call traceback
function PrintTraceback()
    local traceback = string.split(debug.traceback("", 2), "\n")
    PrintTable(traceback)
end

function CreateExport(fileName)
    local ui = requireExport(fileName).create()
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

function getResFullPath(path)
    return path
end

function requireCommand(path)
    return require("game/command/" .. path)
end

function requireMediator(path)
    return require("game/mediator/" .. path)
end

function requireProxy(path)
    return require("game/proxy/" .. path)
end

function requireView(path)
    return require("game/view/" .. path)
end

function requireLayerUI(path)
    return require("game/view/layersui/" .. path)
end

function requireMainUI(path)
    return require("game/view/mainui/" .. path)
end

function requireMainUIWIN32(path)
    return require("game/view/mainui-win32/" .. path)
end

function requireExport(path)
    return require("game/view/export/" .. path)
end

-- value object
function requireVO(path)
    return require("game/valueobject/" .. path)
end

function requireUtil(path)
    return require("util/" .. path)
end

function requireConfig(path)
    return require("config/" .. path)
end

function requireGameConfig(path)
    return require("game_config/" .. path)
end

function requireSUI(path)
    return require("GUI/sui/" .. path)
end

function requireCUI(path)
    return require("GUI/CUI/" .. path)
end

function requireGuide(path)
    return require("GUI/guide/" .. path)
end

function requireLayerGUI(path)
    return require("game/view/layersui/gui_layer/" .. path)
end

function releaseLayerGUI(path)
    package.loaded["game/view/layersui/gui_layer/" .. path] = nil
end

function LoadTxt(path, delimiter, callback)
    if nil == path or nil == callback then
        print("LoadText error")
        return
    end

    local fileUtil = global.FileUtilCtl
    local strBuffer = fileUtil:getDataFromFileEx(path)
    strBuffer = sgsub(strBuffer, "\r", "")
    local lineBreak = "\n"

    local lines = string.split(strBuffer, lineBreak)
    local len = 0
    local pos1 = nil
    for k, v in pairs(lines) do
        len = slen(v)
        if len > 0 then
            pos1, _ = sfind(v, "//")
            if not pos1 then -- skip //
                local dataTable
                if delimiter == nil or delimiter == "" or delimiter == "\n" then -- ignore "" \n
                    dataTable = {}
                    dataTable[1] = v
                else
                    dataTable = string.split(v, delimiter)
                end

                callback(dataTable)
            end
        end
    end
end

function Random(b, e) -- 简单随机
    if nil == e then
        return math.random(b)
    end
    return math.random(b, e)
end

function Schedule(callback, interval)
    return global.Scheduler:scheduleScriptFunc(callback, interval, false)
end

function UnSchedule(scheduleID)
    global.Scheduler:unscheduleScriptEntry(scheduleID)
end

--[[--

计划一个全局延时回调，并返回该计划的句柄。
-- @function [parent=#scheduler] PerformWithDelayGlobal
-- @param function listener 回调函数
-- @param number time 延迟时间
-- @return mixed#mixed ret (return value: mixed)  schedule句柄
scheduler.performWithDelayGlobal() 会在等待指定时间后执行一次回调函数，然后自动取消该计划。

]]
function PerformWithDelayGlobal(listener, time)
    local handle
    handle =
        global.Scheduler:scheduleScriptFunc(
        function()
            global.Scheduler:unscheduleScriptEntry(handle)
            listener()
        end,
        time,
        false
    )
    return handle
end

-- 秒转时间 format : h:m:s
-- p2 : 是否转为字符串
function SecondToHMS(sec, isToStr, isSimple)
    local d = math.floor(sec / 86400)
    local h = math.fmod(math.floor(sec / 3600), 24)
    local m = math.fmod(math.floor(sec / 60), 60)
    local s = math.fmod(sec, 60)
    local time = {}
    time.d = d
    time.h = h
    time.m = m
    time.s = s
    if type(isToStr) == "boolean" and isToStr == true then
        if time.d > 0 then
            if isSimple then
                return sformat("%d天%d时", time.d, time.h)
            else
                return sformat("%d天%d时%d分%d秒", time.d, time.h, time.m, time.s)
            end
        else
            if time.h > 0 then
                if isSimple then
                    return sformat("%d时%d分", time.h, time.m)
                else
                    return sformat("%d时%d分%d秒", time.h, time.m, time.s)
                end
            else
                if time.m > 0 then
                    return sformat("%d分%d秒", time.m, time.s)
                else
                    return sformat("%d秒", time.s)
                end
            end
        end
    else
        return time
    end
end

function TimeFormat(time)
    if not time then
        return
    end

    local day,hour,min,sce = 0,0,0,0
    day = math.floor(time / 86400)
    hour = math.fmod( math.floor(time / 3600) , 24)
    min = math.fmod( math.floor(time/60),60)
    sce = math.fmod(time,60)
    return day,hour,min,sce
end

-- 00:00:00
function TimeFormatToString(time)
    local day, h, m, s = TimeFormat(time)
    if day < 1 then
        return sformat("%02d:%02d:%02d", h, m, s)
    end
    return sformat(GET_STRING(2000), day, h, m)
end

function Shader_Grey(node)
    if not node then
        return
    end

    local data = {}
    data.node = node
    global.Facade:sendNotification(global.NoticeTable.GrayNodeShader, data)
end

function Shader_Normal(node)
    if not node then
        return
    end

    local data = {}
    data.node = node
    global.Facade:sendNotification(global.NoticeTable.NormalNodeShader, data)
end

--显示菊花转
function ShowLoadingBar(isCheckOutTimer)
    global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Open, isCheckOutTimer)
end

--关闭菊花转
function HideLoadingBar()
    global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)
end

function EnterWorldLoadingProgress(unit)
    if not global.LoadingPercent then
        global.LoadingPercent = 0
        -- open loading
    end

    if unit then
        global.LoadingPercent = global.LoadingPercent + unit
    end
end

function ClearWorldLoadingProgress()
    global.LoadingPercent = nil
end

function HTTPRequest(url, callback)
    local httpRequest = cc.XMLHttpRequest:new()
    httpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    httpRequest.timeout = 100000 -- 10 s
    httpRequest:open("GET", url)

    if callback then
        local function HttpResponseCB()
            local code = httpRequest.status
            local success = code >= 200 and code < 300
            local response = httpRequest.response

            release_print("Http Request Code:" .. tostring(code))
            callback(success, response)
        end

        httpRequest:registerScriptHandler(HttpResponseCB)
    end

    httpRequest:send()
end

function HTTPRequestPost(url, callback, data, header)
    local httpRequest = cc.XMLHttpRequest:new()
    httpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    httpRequest.timeout = 100000 -- 10 s
    httpRequest:open("POST", url)
    if header then
        for k, v in pairs(header) do
            httpRequest:setRequestHeader(k, v)
        end
    end

    if callback then
        local function HttpResponseCB()
            local code = httpRequest.status
            local success = code >= 200 and code < 300
            local response = httpRequest.response

            release_print("Http Request Code:" .. tostring(code))
            callback(success, response, code)
        end
        httpRequest:setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        httpRequest:registerScriptHandler(HttpResponseCB)
    end

    --httpRequest:setRequestHeader
    httpRequest:send(data)
end

--指定parent获取child
function UIGetChildByName(widget, ...)
    local parent = widget
    local widgetNameList = {...}

    for _, widgetName in pairs(widgetNameList) do
        parent = parent:getChildByName(widgetName)
        if not parent then
            return nil
        end
    end

    return parent
end

-- "#FFFFFF"  --> cc.c3b( 0xff, 0xff, 0xff )
function GetColorFromHexString(hexString)
    hexString = tostring(hexString)
    local hex = sgsub(hexString, "#", "0x")
    local num = tonumber(hex)
    if not num then
        return cc.Color3B.WHITE
    end

    return GetColorFromHex(num)
end

--
function GetColorFromHex(hexadecimalCode)
    local B = bit.band(hexadecimalCode, 0xff)
    local G = bit.band(bit.rshift(hexadecimalCode, 8), 0xff)
    local R = bit.band(bit.rshift(hexadecimalCode, 16), 0xff)

    return cc.c3b(R, G, B)
end

-- cc.c3b( 0xff, 0xff, 0xff )  --> 0xFFFFFF
function GetColorHexFromRBG(rgb)
    return sformat("#%02x%02x%02x", rgb.r, rgb.g, rgb.b)
end

-- "#FFFFFF"  --> cc.c4b( 0xff, 0xff, 0xff, 0xff )
function GetRGBAFromHexString(hexString)
    local hex = sgsub(hexString, "#", "0x")
    local num = tonumber(hex)
    if not num then
        return cc.Color3B.WHITE
    end

    local A = bit.band(num, 0xff)
    local B = bit.band(bit.rshift(num, 8), 0xff)
    local G = bit.band(bit.rshift(num, 16), 0xff)
    local R = bit.band(bit.rshift(num, 24), 0xff)

    return cc.c4b(R, G, B, A)
end

GoodsItem = {}
GoodsItem.create = function(self, data)
    -- self不能使用
    local GoodsItem = require("util/GoodsItem")
    local item = GoodsItem.new()
    item._isGood = true
    item:init(data)
    return item
end

BagItemLayer = {}
BagItemLayer.create = function(data, Zorder)
    if Zorder == global.MMO.BAG_ITEM_ZORDER then 
        local BagItemLayer = requireLayerUI("bag_layer/BagItemLayer")
        local item = BagItemLayer.new()
        item:init(data)
        return item
    elseif Zorder == global.MMO.BAG_TEXT_ZORDER then 
        local BagItemTextLayer = requireLayerUI("bag_layer/BagItemTextLayer")
        local item = BagItemTextLayer.new()
        item:init(data)
        return item  
    elseif Zorder == global.MMO.BAG_EFFECT_ZORDER then 
        local BagItemEffectLayer = requireLayerUI("bag_layer/BagItemEffectLayer")
        local item = BagItemEffectLayer.new()
        item:init(data)
        return item  
    end 
end

SkillItem = {}
SkillItem.create = function(self, data)
    -- self不能使用
    local SkillItem = require("util/SkillItem")
    local item = SkillItem.new()
    item:init(data)
    return item
end

SItemBox = {}
function SItemBox:create(data)
    if not data or not next(data) then
        return 
    end
    local boxindex          = tonumber(data.boxindex)
    local img               = data.img
    local stdmode           = data.stdmode

    local SUIHelper   = require("sui/SUIHelper")
    local img       = SUIHelper.fixImageFileName(img)
    local fullPath  = img
    
    local widget      = ccui.ImageView:create()
    if global.FileUtilCtl:isFileExist(fullPath) then
        widget:loadTexture(fullPath)
    end
    widget:ignoreContentAdaptWithSize(false)
    widget:setContentSize(widget:getVirtualRendererSize())
    widget:setTouchEnabled(true)

    -- 
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local function addItemToITEMBOX(touchPos)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName      = ItemMoveProxy.ItemGoTo.SSR_ITEM_BOX
            local data          = {}
            data.target         = goToName
            data.stdmode        = stdmode
            data.widget         = widget
            data.boxindex       = boxindex
            ItemMoveProxy:CheckAndCallBack( data )
        else
            return -1
        end
    end
    local function setNoswallowMouse()
        return -1
    end
    global.mouseEventController:registerMouseButtonEvent(
        widget,
        {
            down_r    = setNoswallowMouse,
            special_r = addItemToITEMBOX
        }
    )

    global.Facade:sendNotification(global.NoticeTable.SSR_ITEMBOXWidget_Add, {boxindex = boxindex, widget = widget})

    return widget
end

function CheckBit(num, pos)
    return bit.band(bit.rshift(num, pos), 0x1) == 1
end

function H16Bit(value)
    if not value then
        return 0
    end

    return bit.band(bit.rshift(value, 16), 0xffff)
end

function L16Bit(value)
    if not value then
        return 0
    end

    return bit.band(value, 0xffff)
end

function H8Bit(value)
    if not value then
        return 0
    end

    return bit.band(bit.rshift(value, 8), 0xff)
end

function L8Bit(value)
    if not value then
        return 0
    end

    return bit.band(value, 0xff)
end

function Merge16Bit(v1, v2)
    local ret = bit.lshift(v2, 16)
    ret = bit.bor(ret, v1)
    return ret
end

function CreateRedPoint(targetNode, offset)
    local red = nil
    local sprite = cc.Sprite:create(global.MMO.PATH_RES_PUBLIC .. "btn_npcfh_04.png")
    if sprite then
        red = sprite
    end

    if red then
        local size = targetNode:getContentSize()

        local pos = {}
        pos.x = size.width - (offset and offset.x or 0)
        pos.y = size.height - (offset and offset.y or 0)
        red:setPosition(cc.p(pos.x, pos.y))
        targetNode:addChild(red)
    end

    return red
end

function DelayTouchEnabled(target, delay)
    delay = delay or 0.2

    target:stopActionByTag(10999)
    target:setTouchEnabled(false)
    local action = performWithDelay(
        target,
        function()
            target:setTouchEnabled(true)
        end,
        delay
    )
    action:setTag(10999)
end

function GetFrameAnimIndex(act, dir)
    return act * 8 + dir
end

function GetFrameAnimConfigID( rawAnimID, sex, animType )
    -- 0xfffff   f     f     f
    -- animID    type  sex   act
    return animType * 10000000 + sex * 5000000 + rawAnimID
end

--获取服务器时间 (根据服务器和本地的时间差，算出当前服务器的时间)
function GetServerTime()
    local sub = global.MMO.ServerTime_Sub or 0
    return os.time() + sub
end

function ErrorReport(tag, content)
    local tagStr = tostring(tag)
    local contentStr = tostring(content)
    if not tagStr or not contentStr then
        return
    end

    local contentLen = slen(contentStr)
    local reportContent = contentLen <= 512 and contentStr or ssub(contentStr, 1, 512)

    if cc.PLATFORM_OS_ANDROID == global.Platform then
        buglyLog(1, tagStr, reportContent)
        buglyReportLuaException(tagStr, tagStr, false)
    else
        local data = {}
        data.ChannelId = 1
        data.Msg = tagStr .. " : " .. reportContent
        global.Facade:sendNotification(global.NoticeTable.SystemTips, "ERROR! " .. data.Msg)
        global.Facade:sendNotification(global.NoticeTable.AddChatItem, data)
    end
end

function RecordBuglyLogIm(index, value)
    if not index or not value then
        return
    end

    if cc.PLATFORM_OS_ANDROID == global.Platform then
        buglyLog(1, tostring(index), tostring(value))
    else
        release_print(tostring(index) .. ":" .. tostring(value))
    end
end

function RemoveAllWidgetClickEventListener(widget)
    if not widget then
        return
    end

    global.ScriptHandlerMgr:removeObjectAllHandlers(widget)
    widget:addClickEventListener(
        function()
        end
    )
end

function RemoveAllWidgetTouchEventListener(widget)
    if not widget then
        return
    end

    global.ScriptHandlerMgr:removeObjectAllHandlers(widget)
    widget:addTouchEventListener(
        function()
        end
    )
end

function CreateEditBoxByTextField(textField)
    local inputStr = textField:getString()
    local textColor = textField:getColor()
    local placeHolderColor = textField:getPlaceHolderColor()
    local placeHolder = textField:getPlaceHolder()
    local contentSize = textField:getContentSize()
    local fontSize = textField:getFontSize()
    local fontName = textField:getFontName()
    local parent = textField:getParent()
    local anchorPoint = textField:getAnchorPoint()
    local positionX = textField:getPositionX()
    local positionY = textField:getPositionY()
    local maxLength = textField:getMaxLength()
    local maxLengthEnable = textField:isMaxLengthEnabled()
    local horizontalAlignment = textField:getTextHorizontalAlignment()
    local name = textField:getName()
    textField:removeFromParent()
    textField = nil

    local fontPath = global.MMO.PATH_FONT2
    local editBox = ccui.EditBox:create(contentSize, global.MMO.PATH_RES_ALPHA)
    parent:addChild(editBox)
    if global.isMobile then
        editBox:setFontName(fontPath)
    end
    editBox:setFontSize(fontSize)
    editBox:setFontColor(textColor)
    editBox:setColor(textColor)
    editBox:setAnchorPoint(anchorPoint)
    
    if global.Platform == cc.PLATFORM_OS_ANDROID then
        positionX = positionX + 1
        positionY = positionY + 1
        editBox:setNativeOffset(cc.p(0, -13))
    end
    
    editBox:setPosition(cc.p(positionX, positionY))

    if maxLengthEnable then
        editBox:setMaxLength(maxLength)
    end
    editBox:setPlaceHolder(placeHolder)
    editBox:setPlaceholderFontColor(placeHolderColor)
    editBox:setPlaceholderFontSize(fontSize)
    editBox:setTextHorizontalAlignment(horizontalAlignment)
    editBox:setText(inputStr)
    editBox:setName(name)
    return editBox
end

local EditBox = ccui.EditBox
function EditBox:getString()
    return self:getText()
end
function EditBox:setString(input)
    self:setText(input)
end
function EditBox:addEventListener(callback)
    self:onEditHandler(
        function(event)
            local name = event.name
            local sender = event.target
            if name == "began" then
                callback(sender, 0)
            elseif name == "ended" then
                callback(sender, 1)
            elseif name == "changed" then
                callback(sender, 2)
            elseif name == "return" then
                callback(sender, 3)
            elseif name == "send" then
                callback(sender, 4)
            end
        end
    )
end

----------------------------------------------------------------------------
local Text = ccui.Text
local Label = cc.Label
local Widget = ccui.Widget
local Button = ccui.Button
local CheckBox = ccui.CheckBox
local RichText = ccui.RichText
function CheckBox:addClickEventListener(callback)
    self._clickCallBack_ = callback
    local backup = getmetatable(getmetatable(self))[".backup"]
    backup.addClickEventListener(self, callback)
end

function Widget:addTouchBeganEventListener(callback)
    self:addTouchEventListener(
        function(_, eventType)
            if eventType == 0 then
                callback()
            end
        end
    )
end

function Widget:addClickEventListener(callback)
    local backup = nil
    if tolua.type(self) == "ccui.Widget" then
        backup = getmetatable(self)[".backup"]
    elseif tolua.type(self) == "ccui.ListView" then
        backup = getmetatable(getmetatable(getmetatable(self)))[".backup"]
    else
        backup = getmetatable(getmetatable(self))[".backup"]
    end
    if backup then
        if type(backup.onEvent) == "function" then
            backup.onEvent(self, callback)
            self._clickCallBack_ = callback
        elseif type(backup.addClickEventListener) == "function" then
            backup.addClickEventListener(self, callback)
            self._clickCallBack_ = callback
        end
    end
end

function Widget:addTouchEventListener(...)
    local params = {...}
    if #params == 1 then
        self._touchCallBack_ = ...
    else
        self._touchCallBack_ = params[2]
    end

    local backup = nil
    if tolua.type(self) == "ccui.Widget" then
        backup = getmetatable(self)[".backup"]
    elseif tolua.type(self) == "ccui.ListView" then
        backup = getmetatable(getmetatable(getmetatable(self)))[".backup"]
    else
        backup = getmetatable(getmetatable(self))[".backup"]
    end
    backup.addTouchEventListener(self, ...)
end

function Widget:_addClickEventListener(callback)
    self:addClickEventListener(
        function()
            if not self.longTouchEvent then
                callback(self)
            end
        end
    )
end

function Widget:_addLongTouchEventListener(callback)
    local actionTAG = 123321
    self:addTouchEventListener(
        function(_, eventType)
            if eventType == 0 then
                self.longTouchEvent = false
                self:stopActionByTag(actionTAG)
                local action =
                    performWithDelay(
                    self,
                    function()
                        self.longTouchEvent = true
                        callback(self)
                    end,
                    0.7
                )
                action:setTag(actionTAG)
            elseif eventType == 2 or eventType == 3 then
                self:stopActionByTag(actionTAG)
            end
        end
    )
end

function Widget:addMouseOverTips(tips, offset, anchor, param, show)
    local checkCallback = param and param.checkCallback
    global.mouseEventController:registerMouseMoveEvent(
        self,
        {
            enter = function(touchPos)
                if not global.userInputController:isTouching() and self:isVisible() then
                    if not checkCallback or checkCallback(touchPos) then
                        showMouseOverTips(self, tips, offset, anchor)
                    end
                end
            end,
            leave = function()
                hideMouseOverTips()
            end,
            show = show
        }
    )
end

function Button:loadTextureMouseOver(nfileName, mfileName, enterCB, leaveCB)
    local function checkResType(path)
        if global.SpriteFrameCache:getSpriteFrame(path) then
            return 1
        end
        if global.FileUtilCtl:isFileExist(path) then
            return 0
        end
        return 0
    end
    local function checkRes(path)
        local resType = checkResType(path)
        self:loadTextureNormal(path, resType)
    end

    self:setSwallowMouse(true)
    self:setMouseEnabled(true)
    self:addMouseEventListener(function(sender, eventType)
        if eventType == 1 then
            checkRes(mfileName)
            if enterCB then
                enterCB()
            end
            
        elseif eventType == 2 then
            checkRes(nfileName)
            if leaveCB then
                leaveCB()
            end
        end
    end)
end

function Button:setTitleText(str)
    local stProxy = global.Facade:retrieveProxy( global.ProxyTable.StringTable )
    local newStr = stProxy:fixNewLanguageString(str) or ""
    getmetatable(self)[".backup"].setTitleText(self, newStr)
end

function Widget:setString(str)
    local stProxy = global.Facade:retrieveProxy( global.ProxyTable.StringTable )
    local newStr = stProxy:fixNewLanguageString(str) or ""
    getmetatable(self)[".backup"].setString(self, newStr)
end

function Widget:createWithXML(str,data)
    local stProxy = global.Facade:retrieveProxy( global.ProxyTable.StringTable )
    local newStr = stProxy:fixNewLanguageString(str) or ""
    return getmetatable(self)[".backup"].createWithXML(self, newStr, data or {})
end

function Label:setString(str)
    local stProxy = global.Facade:retrieveProxy( global.ProxyTable.StringTable )
    local newStr = stProxy:fixNewLanguageString(str) or ""
    getmetatable(self)[".backup"].setString(self, newStr)
end

-- 调用来自 C++
function g_OnEnterForColor(sender, param)
    -- 自动设置按钮下压效果
    if sender:getDescription() == "Button" and not sender.invalidZoomScale then
        sender:setZoomScale(-0.05)
    end
end

-- 调用来自 C++
function g_ColorStyleRichText(sender, colorStyleID)
end
----------------------------------------------------------------------------

function convert2ZeroPos(node)
    local positionX     = 0
    local positionY     = 0
    if type(node:getPosition()) == "table" then
        positionX       = node:getPosition().x
        positionY       = node:getPosition().y
    else
        positionX       = node:getPositionX()
        positionY       = node:getPositionY()
    end
    local anchorPoint   = node:getAnchorPoint()
    local contentSize   = node:getContentSize()
    local newPosition   = cc.p(positionX - anchorPoint.x * contentSize.width, positionY - anchorPoint.y * contentSize.height)
    newPosition = cc.p(math.floor(newPosition.x), math.floor(newPosition.y))
    node:setAnchorPoint(cc.p(0, 0))
    node:setPosition(newPosition)
    return newPosition
end

function showWorldTips(tips, worldPos, anchorPoint)
    hideMouseOverTips()

    local layoutTips    = ccui.Layout:create()
    layoutTips:setBackGroundColor(cc.c3b(0, 0, 0))
    layoutTips:setBackGroundColorType(1)
    layoutTips:setBackGroundColorOpacity(100)

    local imageFrame    = ccui.ImageView:create()
    layoutTips:addChild(imageFrame)
    imageFrame:loadTexture(global.MMO.PATH_RES_PUBLIC .. "1900000582.png")
    imageFrame:setScale9Enabled(true)
    imageFrame:setCapInsets({x = 10, y = 10, width = 10, height = 10})

    if type(tips) == "function" then
        tips = tips()
    end
    local RichTextHelp  = require("util/RichTextHelp")
    local fontSize      = SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16
    local textTips      = RichTextHelp:CreateRichTextWithFCOLOR(tips, 1136, fontSize, cc.c3b(0xff, 0xff, 0xff))
    layoutTips:addChild(textTips)
    textTips:formatText()

    local rcontentSize  = textTips:getContentSize()
    local lcontentSize  = {width = rcontentSize.width+10, height = rcontentSize.height+10}
    layoutTips:setContentSize(lcontentSize)
    textTips:setAnchorPoint(cc.p(0.5, 0.5))
    textTips:setPosition(cc.p(lcontentSize.width/2, lcontentSize.height/2))
    imageFrame:setContentSize(lcontentSize)
    imageFrame:setPosition(cc.p(lcontentSize.width/2, lcontentSize.height/2))
    layoutTips:setAnchorPoint(anchorPoint)
    layoutTips:setPosition(worldPos)

    convert2ZeroPos(layoutTips)

    layoutTips:setName("__MouseTips")
    global.Facade:sendNotification(global.NoticeTable.Layer_Notice_AddChild, {child = layoutTips})
end

function showMouseOverTips(widget, tips, offset, anchor)
    hideMouseOverTips()

    offset = offset or {x=0, y=0}
    anchor = anchor or {x=0.5, y=0.5}

    local layoutTips    = ccui.Layout:create()
    layoutTips:setBackGroundColor(cc.c3b(0, 0, 0))
    layoutTips:setBackGroundColorType(1)
    layoutTips:setBackGroundColorOpacity(100)

    local imageFrame    = ccui.ImageView:create()
    layoutTips:addChild(imageFrame)
    imageFrame:loadTexture(global.MMO.PATH_RES_PUBLIC .. "1900000582.png")
    imageFrame:setScale9Enabled(true)
    imageFrame:setCapInsets({x = 10, y = 10, width = 10, height = 10})

    if type(tips) == "function" then
        tips = tips()
    end
    local RichTextHelp  = require("util/RichTextHelp")
    local fontSize      = SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16
    local textTips      = RichTextHelp:CreateRichTextWithFCOLOR(tips, 1136, fontSize, cc.c3b(0xff, 0xff, 0xff))
    layoutTips:addChild(textTips)
    textTips:formatText()

    local rcontentSize  = textTips:getContentSize()
    local lcontentSize  = {width = rcontentSize.width+10, height = rcontentSize.height+10}
    layoutTips:setContentSize(lcontentSize)
    textTips:setAnchorPoint(cc.p(0.5, 0.5))
    textTips:setPosition(cc.p(lcontentSize.width/2, lcontentSize.height/2))
    imageFrame:setContentSize(lcontentSize)
    imageFrame:setPosition(cc.p(lcontentSize.width/2, lcontentSize.height/2))

    local contentSize   = widget:getContentSize()
    local anchorPoint   = widget:getAnchorPoint()
    local worldPos      = widget:getWorldPosition()
    local fixWorldPos   = cc.pAdd(worldPos, cc.p((0.5-anchorPoint.x)*contentSize.width, (1-anchorPoint.y)*contentSize.height + lcontentSize.height/2))
    layoutTips:setAnchorPoint(anchor)
    layoutTips:setPosition(cc.pAdd(fixWorldPos, offset))

    convert2ZeroPos(layoutTips)

    layoutTips:setName("__MouseTips")
    global.Facade:sendNotification(global.NoticeTable.Layer_Notice_AddChild, {child = layoutTips})
end

function hideMouseOverTips()
    global.Facade:sendNotification(global.NoticeTable.Layer_Notice_RemoveChild, "__MouseTips")
end

function GetTimeInMS()
    local socket = require "socket"
    return socket.gettime()
end

local Widget = ccui.Widget
function Widget:cloneEx()
    local ret = self:clone()
    ret.UserData = self.UserData

    local function setChildrenUserData(targetNode, originNode)
        local targetChildren = targetNode:getChildren()
        local originChildren = originNode:getChildren()
        if #targetChildren == 0 or #originChildren == 0 then
            return nil
        end

        for key, value in pairs(targetChildren) do
            targetChildren[key].UserData = originChildren[key].UserData

            setChildrenUserData(targetChildren[key], originChildren[key])
        end
    end

    setChildrenUserData(ret, self)
    cloneLabelRender(self,ret)
    return ret
end
function cloneLabelRender(originNode,targetNode)
    if originNode:getDescription() == "BmpText" then 
        GUI:SetBmpTextProperties(targetNode)
        local originNodeRenderer =  originNode:getVirtualRenderer()
        local fontColor = originNodeRenderer:getColor()
        targetNode:setBMFontFilePath()
        targetNode:setFontSize(12)
        targetNode:setTextColor(fontColor)
    end

    local targetChildren = targetNode:getChildren()
    local originChildren = originNode:getChildren()
    if #targetChildren == 0 or #originChildren == 0 then
        return nil
    end
    for i,ch in ipairs(targetChildren) do
        local orich = originChildren[i]
        cloneLabelRender(orich,ch)
    end
end
local function _compareBracket(str)
    local offset = 1
    local strIdx = 2
    local len = string.len(str)
    local IDX = 1
    while 1 do
        IDX = IDX + 1
        if IDX > 10 then
            return nil
        end
        local lIdx = string.find(str, "%(", strIdx) or len
        local rIdx = string.find(str, "%)", strIdx) or len
        if lIdx < rIdx then
            strIdx = lIdx + 1
            offset = offset + 1
        else
            strIdx = rIdx + 1
            offset = offset - 1
        end
        if offset == 0 then
            strIdx = strIdx - 1
            break
        end
        if strIdx > string.len(str) then
            print(">>>>>>>condition () not compare", str, IDX)
            return nil
        end
    end
    return strIdx
end

local function _stringtoCondition(str)
    local rawCondition = string.split(str, "#")
    local conditon = tonumber(str)
    local conditionType = math.floor(conditon/100000)
    local conditionkey = conditon%100000
    local condition = {}
    condition.dType = 1
    condition.type = tonumber(conditionType)
    condition.key1 = tonumber(conditon%100000) or 0
    condition.key2 = 0
    condition.key3 = 0
    return condition
end

function ParseConditionStr(str)
    if not str or str == "" then
        return nil
    end
    local conditions = {}
    local idx = 0
    while 1 do
        idx = idx + 1
        if str == "" or idx > 100 then
            break
        end
        local condition = nil
        local len = string.len(str)
        local andIdx = string.find(str, "#")
        local orIdx = string.find(str, "|")
        local splitIdx = math.min(andIdx or len + 1, orIdx or len + 1)
        local fchar = string.sub(str, 0, 1)
        if fchar == "(" then
            local rightBracketIdx = _compareBracket(str)
            if not rightBracketIdx then
                rightBracketIdx = string.len(str)
                print(">>Bracket compare error:", str)
            end
            condition = ParseConditionStr(string.sub(str, 2, rightBracketIdx - 1))
            conditions[idx] = condition
            local fchar = string.sub(str, rightBracketIdx + 1, rightBracketIdx + 1)
            str = string.sub(str, rightBracketIdx + 2)
            andIdx = string.find(fchar, "#")
            orIdx = string.find(fchar, "|")
        else
            local splitIdx = math.min(andIdx or len + 1, orIdx or len + 1)
            local conditionStr = string.sub(str, 1, splitIdx - 1)
            -- print("idx", andIdx, orIdx, len, str, conditionStr)
            condition = _stringtoCondition(conditionStr)
            conditions[idx] = condition
            str = string.sub(str, splitIdx + 1)
        end
        if condition then
            if andIdx and (not orIdx or orIdx > andIdx) then
                condition.opType = 1
            end
            if orIdx and (not andIdx or andIdx > orIdx) then
                condition.opType = 2
            end
        end
    end
    if #conditions == 0 then
        return nil
    end
    if #conditions == 1 then
        return conditions[1]
    end
    local data = {}
    data.dType = 2
    data.conditions = conditions
    return data
end

function SetRichText(txtObj, richText, color, bAutoLine)
    if bAutoLine == nil then
        bAutoLine = true
    end
    local RichHelp = require("util/RichTextHelp")
    txtObj:setVisible(false)
    local resName = txtObj:getName()
    local richName = resName .. "__rich"
    local richObj = txtObj:getParent():getChildByName(richName)
    if richObj then
        richObj:removeFromParent()
        richObj = nil
    end
    local fontSize = txtObj:getFontSize()
    color = color or GetColorHexFromRBG(txtObj:getTextColor())
    local size = txtObj:getLayoutSize()
    if size.width == 0 then
        print(">>>>>>>SetRichText err!!" .. richText, richName)
        return
    end
    local width = size.width
    if not bAutoLine then
        width = 9999
    end
    local richObj = RichHelp:CreateRichTextWithXML(richText, width, fontSize, color)
    if richObj then
        local ap = txtObj:getAnchorPoint()
        local posX = txtObj:getPositionX()
        local posY = txtObj:getPositionY()
        txtObj:getParent():addChild(richObj)
        richObj:setAnchorPoint(ap)
        richObj:formatText()
        richObj:setPosition(cc.p(posX, posY))
        richObj:setName(richName)
    else
        print("!!!!!!!!!!!!!!richText error", richText)
    end
    return richObj
end

function CloneShadow(sprite)
    if not sprite then
        return
    end

    sprite:setBlendFunc({src = gl.DST_COLOR, dst = gl.ONE_MINUS_SRC_ALPHA})
    sprite:setRotationSkewX(40.0)
    sprite:setScaleY(0.8)
    sprite:setOpacity(150)
    sprite:setColor(cc.Color3B.BLACK)

    global.Facade:sendNotification(global.NoticeTable.HighLightNodeShader, sprite, global.MMO.SHADER_TYPE_SHADOW)
end

--中文转换成竖着显示
function ChineseToVertical(str)
    local UTF8 = require("util/utf8")
    local len = UTF8:length(str)
    local newStr = ""
    for i = 1, len do
        newStr = newStr .. UTF8:sub(str, i, 1)
        if i < len then
            newStr = newStr .. "\n"
        end
    end
    return newStr
end

--哈希表转成按数组
function HashToSortArray(hashTab, sortFunc)
    if hashTab == nil or type(hashTab) ~= "table" then
        return nil
    end

    local sortTable = {}
    for _, v in pairs(hashTab) do
        table.insert(sortTable, v)
    end
    if sortFunc then
        table.sort(sortTable, sortFunc)
    end
    return sortTable
end

function ui_delegate(nativeUI)
    if (nativeUI == nil) then
        return nil
    end
    local function getChildInSubNodes(nodeTable, key)
        if #nodeTable == 0 then
            return nil
        end
        local child = nil
        local subNodeTable = {}
        for _, v in ipairs(nodeTable) do
            child = GUI:getChildByName(v, key)
            if (child) then
                return child
            end
        end
        for _, v in ipairs(nodeTable) do
            local subNodes = GUI:getChildren(v)
            if #subNodes ~= 0 then
                for _, v1 in ipairs(subNodes) do
                    table.insert(subNodeTable, v1)
                end
            end
        end
        return getChildInSubNodes(subNodeTable, key)
    end
    local function getChildByKey(parent, key)
        return getChildInSubNodes({parent}, key)
    end

    local tt = {
        __index = function(t, k)
            local u = getChildByKey(t.nativeUI, k)
            rawset(t, k, u)
            return u
        end
    }
    local r = {["nativeUI"] = nativeUI}
    setmetatable(r, tt)
    return r
end

function getChildInSubNodes(nodeTable, key)
    if #nodeTable == 0 then
        return nil
    end
    local child = nil
    local subNodeTable = {}
    for _, v in ipairs(nodeTable) do
        child = v:getChildByName(key)
        if (child) then
            return child
        end
    end
    for _, v in ipairs(nodeTable) do
        local subNodes = v:getChildren()
        if #subNodes ~= 0 then
            for _, v1 in ipairs(subNodes) do
                table.insert(subNodeTable, v1)
            end
        end
    end
    return getChildInSubNodes(subNodeTable, key)
end

function checkNotchPhone()
    local visibleSize    = global.Director:getVisibleSize()
    local glView         = global.Director:getOpenGLView()
    local viewRect       = glView:getVisibleRect()
    local safeRect       = global.Director:getSafeAreaRect()
    local notch          = (math.abs(viewRect.width - safeRect.width) > 5)
    local deviceRotation = global.L_GameEnvManager:GetDeviceRotation()
    
    if notch then
        local notchWidth    = 50
        viewRect.x          = (deviceRotation == 1 and notchWidth or 0)
        viewRect.y          = 0
        viewRect.width      = viewRect.width - notchWidth
        viewRect.height     = visibleSize.height
    end
    return notch, viewRect
end

-- 根据服务器json参数转换外观
function TransformFeatureByJson(jsonData)
    local ret = {
        clothID   = 0,
        hairID    = 0,
        weaponID  = 0,
        shieldID  = 0,
        mountID   = 0,
        wingsID   = 0,
        weaponEff = 0,
        shieldEffect = 0,
        leftWeaponID = 0,
        leftWeaponEff = 0,
    }

    ret.clothID = jsonData.clothID
    ret.weaponID = jsonData.weaponID
    
    -- 左武器
    ret.leftWeaponID = jsonData.leftWeaponID
    ret.leftWeaponEff = jsonData.leftWeaponEff
    -- 发型
    local hairID = jsonData.Hair

    -- 骑马
    ret.mountID   = jsonData.mountID

    -- 幻武 时装 翅膀 足迹 武器特效
    local wingsID       = jsonData.clothEff
    local weaponEff     = jsonData.weaponEff
    local capID         = jsonData.Cap
    local mountEff      = jsonData.mountEff --足迹特效
    local mountCloth    = jsonData.mountCloth --骑马人物外观
    local shieldID      = jsonData.shieldID --盾牌
    local shieldEffect  = jsonData.shieldEffect --盾牌特效

    if hairID and hairID > 0 then
        ret.hairID = hairID
    end

    if capID and capID > 0 then
        ret.capID = capID
    end

    if wingsID and wingsID > 0 then
        ret.wingsID = wingsID
    end

    if weaponEff and weaponEff > 0 then
        ret.weaponEff = weaponEff
    end

    if mountEff and mountEff > 0 then
        ret.mountEff = mountEff
    end

    if mountCloth and mountCloth > 0 then
        ret.mountCloth = mountCloth
    end

    if shieldID and shieldID > 0 then --盾牌
        ret.shieldID = shieldID
    end

    if shieldEffect and shieldEffect > 0 then --盾牌特效
        ret.shieldEffect = shieldEffect
    end

    return ret
end

--划线
function CreateDrawLine(size, beginPos, endPos, color)
    size = size or 1
    color = color or cc.c4f(1, 0, 0, 1)

    local drowRoot = cc.DrawNode:create(size)
    drowRoot:drawLine(beginPos, endPos, color)
    return drowRoot
end

--[[
    README:
    data.dataLength 总长度
    或者data.items长度
    data.pageLength 每页长度
    data.isShowLat 是否显示上页最后一项
]]
function GetPageData(data)
    if not data then
        return nil
    end
    local length = 0
    if data.dataLength then
        length = data.dataLength
    end
    if data.items then
        length = #data.items
    end
    local pageData = {}
    local page = 1
    local pageLength = data.pageLength or global.MMO.NPC_STORE_LIST_LENGTH
    local isShowLastItem = data.isShowLast

    if isShowLastItem then
        pageLength = pageLength - 1
    end
    local maxPage = math.ceil(length/pageLength)
    for index=page,maxPage do
        local beginItem = (index - 1)*pageLength + 1
        local endItem = index*pageLength
        if isShowLastItem then
            endItem = index*pageLength + 1
        end
        if index == maxPage then
            endItem = length
        end
        pageData[index] = {
            beginItem = beginItem,
            endItem = endItem
        }
    end

    return pageData
end

--文本提示框
function GetWordTips(data)
    local str = data.str or "" --文本
    local width = data.width or 800 --文本宽度
    local richTextHelp = require("util/RichTextHelp")

    local tips = ccui.Layout:create()
    tips:setBackGroundImage(global.MMO.PATH_RES_PRIVATE .. "item_tips/bg_tipszy_05.png")
    tips:setBackGroundImageCapInsets({x = 44, y = 57, width = 47, height = 100})
    tips:setBackGroundImageScale9Enabled(true)
    tips:setAnchorPoint(0, 0)

    local richText = richTextHelp:CreateRichTextWithXML(str, width, 16, "#ffffff")
    richText:formatText()
    richText:setAnchorPoint(0, 1)
    richText:setName("richText")
    tips:addChild(richText)
    local textSize = richText:getContentSize()
    richText:setPosition(10, textSize.height + 10)

    if textSize.width < width then
        width = textSize.width
    end
    tips:setContentSize(cc.size(width + 20, textSize.height + 20))
    return tips
end

function CalcCameraZoom( camera )
    local winSize = global.Director:getWinSize()
    local rtPos = cc.p( winSize.width, winSize.height ) -- right-top
    local lbPos = cc.p( 0, 0 )                          -- left-bottom
    local rtPosGL = camera:projectGL( rtPos )
    local lbPosGL = camera:projectGL( lbPos )

    local zoomWidth = rtPosGL.x - lbPosGL.x
    local zoomHeight = rtPosGL.y - lbPosGL.y

    local scaleX = winSize.width / zoomWidth
    local scaleY = winSize.height / zoomHeight

    return scaleX, scaleY
end

function Screen2World( srcPos )
    local camera = global.gameMapController:GetViewCamera()
    if not camera then
        return nil
    end

    local scaleX, scaleY = CalcCameraZoom( camera )

    local p = cc.p( srcPos.x * scaleX, srcPos.y * scaleY )
    local cameraPos = cc.p(camera:getPosition())
    local winSize = global.Director:getWinSize()
    local centerOfView = cc.p( winSize.width * 0.5 * scaleX, winSize.height * 0.5 * scaleY )
    return cc.pSub(cc.pAdd( cameraPos, p ), centerOfView )
end

function World2Screen( srcPos )
    local camera = global.gameMapController:GetViewCamera()
    if not camera then
        return nil
    end

    local scaleX, scaleY = CalcCameraZoom( camera )

    local cameraPos = cc.p(camera:getPosition())
    local winSize = global.Director:getWinSize()
    local centerOfView = cc.p( winSize.width * 0.5 * scaleX, winSize.height * 0.5 * scaleY )
    local p = cc.pSub( cc.pAdd( srcPos, centerOfView ), cameraPos )
    p.x = p.x / scaleX
    p.y = p.y / scaleY

    return p
end

function RegisterNodeMovable( node, param )
    local itemMoveState = {
        begin = 1,
        moving = 2,
        end_move = 3,
    }
    local pressCallBack = param.pressCallBack
    local clickCallBack = param.clickCallBack
    local replaceClick = param.replaceClick
    local replacePress = param.replacePress
    local doubleEventCallBack = param.doubleEventCallBack
    local nodeFrom = param.nodeFrom
    local beginMoveCallBack = param.beginMoveCall
    local endMoveCallBack = param.endMoveCall
    local cancelMoveCallBack = param.cancelMoveCall
    local itemData = param.itemData
    local isNeedItemData = param.dataNeed
    local isNode = param.moveNode
    local skillId  = param.skillId

    local function resetMoveState( mySelf, bool )
        if mySelf and not tolua.isnull(mySelf) then
            mySelf._movingState = bool
            if bool then
                if beginMoveCallBack then
                    beginMoveCallBack( mySelf, bool )
                end
            else
                if endMoveCallBack then
                    endMoveCallBack( mySelf, bool )
                end
            end
        end
    end

    local function SetGoodItemState(state, movePos)
        if isNeedItemData and not itemData then
            return
        end

        if itemMoveState.begin == state then
            resetMoveState(node,true)
            global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Begin,{
                pos = movePos,
                itemData = itemData,
                cancelCallBack = cancelMoveCallBack,
                from = nodeFrom,
                movingNode = isNode:clone(),
                skillId = skillId
            })
        elseif itemMoveState.moving == state then
    
        elseif itemMoveState.end_move == state then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End, movePos)
        end
    end

    local function clickEventCallBack(clickNode, eventtype)
        --不在道具移动
        if clickNode._movingState then
            return
        end
        local panelPos = clickNode:getWorldPosition()
        if global.isWinPlayMode then
            SetGoodItemState(itemMoveState.begin, panelPos)
        end
        if clickCallBack then
            clickCallBack(clickNode)
        end
    end

    local function pressEventCallBack()
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

    local clickEventCallBack = replaceClick or clickEventCallBack

    local pressEventCallBack = replacePress or pressEventCallBack

    local isEventPress = false
    local isMoved = true
    local hasEventCallOnTouchBegin = false        --只有在响应了touchbegin 时才会去响应延时方法 因为在延时后 鼠标事件的 状态已经被置掉
    local isMobile = not global.isWinPlayMode

    local function delayCallback()
        isEventPress = true

        if pressEventCallBack then
            if not pressEventCallBack then
                return false
            end

            if not isMoved then
                pressEventCallBack()
                return false
            end

            local movedPos = node:getTouchMovePosition()
            local beganPos = node:getTouchBeganPosition()

            local diff = cc.pSub(movedPos, beganPos)
            local distSq = cc.pLengthSQ(diff)
            if distSq <= 100 then
                pressEventCallBack()
            end
        end
    end

    local function touchEvent( touch, eventType )
        if global.isWinPlayMode then
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local itemMoving = ItemMoveProxy:GetMovingItemState()
            if itemMoving then --在道具移动中
                return
            end
        end
        if eventType == 0 then
            isEventPress = false
            isMoved = false
            hasEventCallOnTouchBegin = true

            if pressEventCallBack then
                performWithDelay(node, delayCallback, global.MMO.CLICK_DOUBLE_TIME)
            end
        elseif eventType == 1 then
            
            local movedPos = node:getTouchMovePosition()
            local beganPos = node:getTouchBeganPosition()

            local diff = cc.pSub(movedPos, beganPos)
            local distSq = cc.pLengthSQ(diff)
            if not isMoved and distSq > 100 then
                isMoved = true
                if isMobile then
                    local beginMovePos = node:getWorldPosition()
                    SetGoodItemState(itemMoveState.begin, beginMovePos)
                end
            end
            if isMobile then
                local movedPos = node:getTouchMovePosition()
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Moving,{pos = movedPos})
            end
        elseif eventType == 2 then
            node:stopAllActions()

            if not isMoved then
                if not isEventPress then
                    -- 判断是否有双击事件
                    if doubleEventCallBack then
                        -- 记录上一次点击时间
                        if not node._lastClickTime then
                            node._lastClickTime = true
                            -- 记录单击触发
                            -- 记录进入此处时的状态，避免在延时操作后状态被改变
                            local stateOnbegin = hasEventCallOnTouchBegin
                            node._clickDelayHandler =
                                PerformWithDelayGlobal(
                                function()
                                    if clickEventCallBack and stateOnbegin then
                                        clickEventCallBack(node, eventType)
                                    end

                                    node._lastClickTime = nil
                                end,
                                global.MMO.CLICK_DOUBLE_TIME
                            )
                        else
                            if node._clickDelayHandler then
                                UnSchedule(node._clickDelayHandler)
                                node._clickDelayHandler = nil
                            end

                            if doubleEventCallBack then
                                doubleEventCallBack()
                            end

                            node._lastClickTime = nil
                        end
                    else
                        local stateOnbegin = hasEventCallOnTouchBegin
                        if clickEventCallBack and stateOnbegin then
                            clickEventCallBack(node, eventType)
                        end
                    end
                end
            else
                if isMobile then
                    local endPos = node:getTouchEndPosition()
                    SetGoodItemState(itemMoveState.end_move, endPos)
                end
            end
            hasEventCallOnTouchBegin = false
        elseif eventType == 3 then
            if isMobile then
                local endPos = node:getTouchEndPosition()
                SetGoodItemState(itemMoveState.end_move, endPos)
            end
            hasEventCallOnTouchBegin = false
        end
    end
    node:addTouchEventListener( touchEvent )
end

function CreateStaticUIModel(sex, feature, scale, params)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_UIMODEL)
    return UIModel.main(sex, feature, scale, params)
end

function ParseModelEffect(effect)
    local effectSet = {}
    if not effect then
        return effectSet
    end
    if type(effect) == "number" then
        effect = effect.."#0"
    end
    
    local effectArry = string.split(effect or "","&")
    local isShowLook = tonumber(effectArry[2]) ~= 0
    local effectList = string.split(effectArry[1] or "", "|")
    for i=1,#effectList do
        local effectParam = effectList[i]
        local effectParamPar = string.split(effectParam or "", "#")
        local effectData = {
            effectId = effectParamPar[1] and tonumber(effectParamPar[1]) or 0,
            zOrder = effectParamPar[2] and tonumber(effectParamPar[2]) or 0,
            offX = effectParamPar[3] and tonumber(effectParamPar[3]) or 0,
            offY = effectParamPar[4] and tonumber(effectParamPar[4]) or 0,
            scale = effectParamPar[6] and tonumber(effectParamPar[6]) or 1 --"PC缩放#手机缩放"
        }
        if global.isWinPlayMode then
            effectData.scale = effectParamPar[5] and tonumber(effectParamPar[5]) or 1
            effectData.offX = effectParamPar[7] and tonumber(effectParamPar[7]) or effectData.offX
            effectData.offY = effectParamPar[8] and tonumber(effectParamPar[8]) or effectData.offY
        end
        table.insert(effectSet, effectData)
    end
    return effectSet, isShowLook
end

function GetItemDataNumber(typeId,param)
    local count = 0
    if not typeId then
        return 0
    end
    local countFamilar = param and param.realbool
    if typeId < 100 then
        local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
        count = MoneyProxy:GetMoneyCountById(typeId, countFamilar)
    else
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        count = BagProxy:GetItemCountByIndex(typeId, countFamilar)

        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        count = count + QuickUseProxy:GetQuickUseItemNum(typeId, countFamilar)
    end

    return count
end

-- articleType: 禁止类型(有些绑定可以进行操作)
function CheckItemisBind(itemData, articleType)
    if not itemData then
        return false, false
    end

    -- release_print("===CheckItemisBind: ", itemData.Bind, global.ConstantConfig.bangdingguize or "")
    local cfgArticle = itemData.Article or ""
    if (itemData.Bind and itemData.Bind > 0) or string.len(cfgArticle) > 0 then
        local isBindSelf = false
        if itemData.Bind == itemData.Index then
            isBindSelf = true
        end

        local isMeetType = false
        if itemData.Bind and itemData.Bind > 0 and articleType and articleType > 0 then
            isMeetType = CheckBit(itemData.Bind,articleType-1)
        end

        local bindParam = SL:GetMetaValue("GAME_DATA","bangdingguize") or ""
        local bindArticles = string.split(bindParam,"&")
        local isBind = true
        local checkCount = 0
        local ItemConfigProxy = global.Facade:retrieveProxy( global.ProxyTable.ItemConfigProxy )
        for i,v in ipairs(bindArticles) do
            if v and v ~= "" then
                local vParam = string.split(v,"#")
                isBind = false
                for ii,vv in ipairs(vParam) do
                    if tonumber(vv) then
                        checkCount = checkCount + 1
                        if itemData.Bind and itemData.Bind > 0 then
                            isBind = CheckBit(itemData.Bind,tonumber(vv)-1)
                        end
                        if not isBind then
                            local itemArticleType = ItemConfigProxy:GetBindArticleTypeToItemArticle(tonumber(vv))
                            if itemArticleType then
                                local checkArticleType = {[itemArticleType]=true}
                                if ItemConfigProxy:GetItemArticle(itemData.Index,checkArticleType) then
                                    isBind = true
                                end
                            end
                        end

                        if isBind then
                            break
                        end
                    end
                end
            end

            if isBind == false then
                break
            end
        end

        if not itemData.Bind or itemData.Bind <= 0 then
            if checkCount == 0 then
                isBind = false
            end
        end

        return isBind, isBindSelf, isMeetType
    else
        return false, false, false
    end
end

function GetSimpleNumber(n)
    local unitFunc = function( num,pointBit )
        if pointBit == 0 then
            return math.floor(num)
        end
        local iNum,fNum = math.modf(num)
        local fDecimal = math.pow(10, pointBit)
        local newNum   = tostring(fNum*fDecimal)
        newNum         = tonumber(newNum)
        local newFNum =  math.floor(newNum)
        newFNum = tostring( newFNum )
        newFNum = tonumber( newFNum )
        local newINum = iNum + (newFNum/fDecimal)
        return newINum
    end

    if n >= 100000000 then
        return string.format("%s%s", unitFunc(n/100000000,2), GET_STRING(1045))
    end
    if n >= 100000 then
        return string.format("%d%s", n/10000, GET_STRING(1005))
    end
    if n >= 10000 then
        return string.format("%s%s", unitFunc(n/10000,2), GET_STRING(1005))
    end
    return tostring(n)
end

function GetJobName(job)
    if not job then return nil end
    if job == 4 then
        return GET_STRING(1100)
    elseif job >= 5 and job <= 15 then
        local jobData   = SL:GetMetaValue("GAME_DATA", "MultipleJobSetMap")[job]
        local isOpen    = jobData and jobData.isOpen
        local str       = isOpen and jobData.name or string.format("未命名%s", job)
        return str
    end
    return GET_STRING(1067+job)
end

function ShowSystemTips(str)
    global.Facade:sendNotification(global.NoticeTable.SystemTips, str)
end

function ShowDebugSystemTips(data)
    global.Facade:sendNotification(global.NoticeTable.DebugSystemTips, data)
end

function ShowSystemChat(str, FColor, BColor, mt)
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local mdata     = {
        Msg         = str,
        FColor      = FColor or 249,
        BColor      = BColor or 255,
        ChannelId   = ChatProxy.CHANNEL.System,
        mt          = mt or ChatProxy.MSG_TYPE.SystemTips,
    }
    global.Facade:sendNotification(global.NoticeTable.AddChatItem, mdata)
end

function CheckCanDoSomething(noTips)
    local canDoSomething = true
    local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
    local isTrading = StallProxy:GetMyTradingStatus()
    if canDoSomething and isTrading then
        canDoSomething = false
    end

    if not noTips and not canDoSomething then
        ShowSystemTips(GET_STRING(90170001))
    end
    return canDoSomething
end

function GetGuildOfficialName(official)
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
	return GuildProxy:getGuildTitleByRank(official) or ""
end

local ListView = ccui.ListView
function ListView:paintItems()
    local items      = self:getItems()
    local direction  = self:getDirection()

    local lowerBound = #items - 1
    local upperBound = 0
    
    if (direction ~= 1)  then
        lowerBound = self:getIndex(self:getRightmostItemInCurrentView())
        upperBound = self:getIndex(self:getLeftmostItemInCurrentView())
    end
    
    if (direction ~= 2) then
        lowerBound = math.min(self:getIndex(self:getTopmostItemInCurrentView()), lowerBound)
        upperBound = math.max(self:getIndex(self:getBottommostItemInCurrentView()), upperBound)
    end
    
    for i, item in ipairs(items) do
        item:setVisible(lowerBound <= (i-1) and (i-1) <= upperBound)
    end
end

local ScrollView = ccui.ScrollView
function ScrollView:addMouseScrollPercent(callback)
    self:setMouseEnabled(true)
    self:setSwallowMouse(false)
    self:addMouseEventListener(function(sender, eventType)
        if eventType == 1 then
        elseif eventType == 3 then
            local speed         = 30
            local param         = self:getMouseScrollPosition()
            local scorllX       = param.x
            local scorllY       = param.y
            local contentSize   = self:getContentSize()
            local innerSize     = self:getInnerContainerSize()
            if innerSize.height > contentSize.height then
                local innerPos      = self:getInnerContainerPosition()
                local vHeight       = innerSize.height - contentSize.height
                local dis           = speed * scorllY
                local percent       = (vHeight + innerPos.y + dis) / vHeight * 100
                percent             = math.min(math.max(0, percent), 100)
                self:scrollToPercentVertical(percent, 0.03, false)
                if callback then
                    callback(percent)
                end
            end
        end
    end)
end

function CreateScrollLabel(txt, config)
    local anchorPoint = {0, 0}
    if config and config.anchorPoint then
        anchorPoint = config.anchorPoint
    end
    local layoutName = ccui.Layout:create()
    layoutName:setClippingEnabled(true)
    layoutName:setLayoutComponentEnabled(true)
    layoutName:setAnchorPoint(anchorPoint[1], anchorPoint[2])

    local componentSize = {
        width = 80,
        height = 20
    }
    if config and config.visibleSize then
        componentSize = {
            width = config.visibleSize[1],
            height = config.visibleSize[2]
        }
    end

    local layout = ccui.LayoutComponent:bindLayoutComponent(layoutName)
    layout:setSize(
        {
            width = componentSize.width,
            height = componentSize.height
        }
    )
    local string = txt or ""
    local nameLabel = ccui.Text:create(txt, config and config.fontName or global.MMO.PATH_FONT2, config.fontSize or 18)
    nameLabel:setAnchorPoint(anchorPoint[1], anchorPoint[2])

    if config and config.labelColour then
        nameLabel:setTextColor(config.labelColour)
    end

    if config and config.colorId then
        nameLabel:setTextColor(GET_COLOR_BYID_C3B(config.colorId))
    end

    local maxSize = componentSize.width or 80
    local function StartNameAction(cell)
        local textWid = cell:getContentSize().width
        if textWid > maxSize then
            cell:runAction(
                cc.RepeatForever:create(
                    cc.Sequence:create(cc.MoveBy:create(4, cc.p(-textWid, 0)), cc.MoveBy:create(0, cc.p(textWid, 0)))
                )
            )
        end
    end

    StartNameAction(nameLabel)

    nameLabel:setPosition(cc.p(componentSize.width*anchorPoint[1], componentSize.height*anchorPoint[2]))
    layoutName:addChild(nameLabel)

    return layoutName
end

-- 用于检测goodsitem 是否在listview 并且可视
function CheckNodeCanCallBack( node, mousePos, checkLevel )
    local child = node
    local times = 0
    local checkEnable = true
    local maxTimes = checkLevel or 6
    local function GetParentAndCheck(childNode)
        if times >= maxTimes then
            checkEnable = true
            return
        end
        if not tolua.isnull(childNode) then
            local parent = childNode:getParent()
            if not tolua.isnull(parent) then
                if not parent:isVisible() then
                    checkEnable = false
                    return
                end
                if tolua.iskindof(parent,"ccui.ListView") or tolua.iskindof(parent,"ccui.ScrollView") then
                    local contentSize = parent:getContentSize()
                    local parentPos = parent:getWorldPosition()
                    local anchorPoint = parent:getAnchorPoint()
                    local width = contentSize.width
                    local height = contentSize.height
                    local minX = parentPos.x - width*anchorPoint.x
                    local maxX = parentPos.x + width*(1-anchorPoint.x)
                    local minY = parentPos.y - height*anchorPoint.y
                    local maxY = parentPos.y + height*(1-anchorPoint.y)
                    if mousePos.x < minX or maxX < mousePos.x or mousePos.y < minY or maxY < mousePos.y then
                        checkEnable = false
                        return
                    end
                end
                times = times + 1
                GetParentAndCheck(parent)
            end
        end
    end

    GetParentAndCheck(child)

    return checkEnable
end

function NumberToChinese(szNum)
    ---阿拉伯数字转中文大写
    local szChMoney = ""
    local iLen = 0
    local iNum = 0
    local iAddZero = 0
    local hzUnit = {"", "十", "百", "千", "万", "十", "百", "千", "亿", "十", "百", "千", "万", "十", "百", "千"}
    local hzNum = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
    if nil == tonumber(szNum) then
        return tostring(szNum)
    end
    iLen = string.len(szNum)
    if iLen > 10 or iLen == 0 or tonumber(szNum) < 0 then
        return tostring(szNum)
    end
    for i = 1, iLen do
        iNum = tonumber( string.sub(szNum, i, i) )
        if iNum == 0 and i ~= iLen then
            iAddZero = iAddZero + 1
        else
            if iAddZero > 0 then
                szChMoney = szChMoney .. hzNum[1]
            end
            szChMoney = szChMoney .. hzNum[iNum + 1] --//转换为相应的数字
            iAddZero = 0
        end
        if (iAddZero < 4) and (0 == (iLen - i) % 4 or 0 ~= tonumber(iNum)) then
            szChMoney = szChMoney .. hzUnit[iLen - i + 1]
        end
    end
    local function removeZero(num)
        --去掉末尾多余的 零
        num = tostring(num)
        local szLen = string.len(num)
        local zero_num = 0
        for i = szLen, 1, -3 do
            szNum = string.sub(num, i - 2, i)
            if szNum == hzNum[1] then
                zero_num = zero_num + 1
            else
                break
            end
        end
        num = string.sub(num, 1, szLen - zero_num * 3)
        szNum = string.sub(num, 1, 6)
        --- 开头的 "一十" 转成 "十" , 贴近人的读法
        if szNum == hzNum[2] .. hzUnit[2] then
            num = string.sub(num, 4, string.len(num))
        end
        return num
    end
    return removeZero(szChMoney)
end

function UseItemByIndex(Index)
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)

    local item = nil
    local items = QuickUseProxy:GetQucikUseDataByIndex(Index)
    if items and next(items) then
        item = items[1]
    end

    if not item then
        local items = BagProxy:GetItemDataByItemIndex(Index)
        if items and next(items) then
            item = items[1]
        end
    end

    if item then
        local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
        ItemUseProxy:UseItem(item)
        return true
    end
    
    return false
end

function StoreBuyTipsOpen(storeIndex, limitStr)
    if not storeIndex then
        return
    end
    local PageStoreProxy = global.Facade:retrieveProxy(global.ProxyTable.PageStoreProxy)
    local storeData = PageStoreProxy:GetItemDataByStoreIndex(storeIndex)
    if not storeData or next(storeData) == nil then
        return
    end
    local canBy = PageStoreProxy:CheckStoreLimitStatus(storeIndex)
    if not canBy then
        if limitStr and string.len(limitStr) > 0 then
            ShowSystemTips(limitStr)
        end
        return
    end
    local buyData = {
        data = storeData,
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_StoreBuy_Open, buyData)
end

function PlayEffectOnScreen(data)
    local effectId = data.effectId
    local x = data.x
    local y = data.y
    local playSpeed = data.speed
    local playTimes = data.times
    local playMode = data.mode  --2行会 3地图 4组队
    local isLoop = false

    if playTimes == 0 then
        isLoop = true
    end

    -- 播放特效
    local sfxAnim = global.FrameAnimManager:CreateSFXAnim(effectId)
    sfxAnim:setPosition( x, y)
    sfxAnim:Play(0, 0, true, playSpeed)
    local count  = 0
    local function removeEvent()
        count = count + 1
        if playTimes == count then
            sfxAnim:removeFromParent() 
        end
    end
    sfxAnim:SetAnimEventCallback( removeEvent )

    if data.id then
        sfxAnim:setName(tostring(data.id))
    end 

    local mediator = global.Facade:retrieveMediator("NoticeMediator")

    dump(data)
    if mediator._layer and mediator._layer._root:getChildByName(tostring(data.id)) then
        global.Facade:sendNotification(global.NoticeTable.Layer_Notice_RemoveChild, tostring(data.id))
    end

    if tonumber(playMode) > 1 and tonumber(playMode) < 5 then
        table.insert(mediator._typeEffects[playMode - 1], tostring(data.id))
        dump(mediator._typeEffects[playMode - 1])
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_Notice_AddChild, {child = sfxAnim})
end

function LoByte( value )
    local high_value = math.floor(value/256)
    high_value = high_value*256
    local low_value = value - high_value
    return low_value
end

function HiByte( value )
    local high_value = math.floor(value/256)
    return high_value
end

function AdjustAb(abil, val)
    local lo = LoByte(abil)
    local hi = HiByte(abil)
    local lov = 0
    local hiv = 0
    for i=1, val do
        if (lo+1 < hi) then
            lo = lo + 1
            if lo > 255 then
                lo = 0
            end
            lov = lov +1
        else
            hi = hi + 1
            if hi > 255 then
                hi = 0
            end
            hiv = hiv + 1
        end
    end

    return lov, hiv
end

function SHOW_SUI_DESCTIP(widget, str, width, offset, anchorPoint)
    local btnAnchor     = widget:getAnchorPoint()
    local contentSize   = widget:getContentSize()
    local worldPos      = widget:getWorldPosition()
    --anchorPoint此时为SUI组件设置锚点
    local fixWorldPos   = cc.pAdd(worldPos, cc.p((anchorPoint.x-btnAnchor.x)*contentSize.width, (anchorPoint.y-btnAnchor.y)*contentSize.height))

    offset = offset or {x=0, y=0}
    width = width or 1136

    local tempWorldPos = cc.pAdd(fixWorldPos, offset)
    anchorPoint = cc.p(0.5,0.5)
    global.Facade:sendNotification(global.NoticeTable.Layer_Common_Desc_Open, {str = str, worldPos = tempWorldPos, width = width, anchorPoint = anchorPoint, isSUI = true})
end

function SHOW_DESCTIP( str, width, worldPos, anchorPoint, swallowType)
    worldPos = worldPos or cc.p(0, 0)
    width = width or 1136
    global.Facade:sendNotification(global.NoticeTable.Layer_Common_Desc_Open, {str = str, worldPos = worldPos, width = width, anchorPoint = anchorPoint, swallowType = swallowType})
end

--飞向人物
function ShowFakeDropItemsJustFly(targetID, items)
    if global.L_GameEnvManager:GetEnvDataByKey("isAliCloudPhone") then
        return
    end
    local ServerTimeProxy = global.Facade:retrieveProxy( global.ProxyTable.ServerTimeProxy )
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local sceneRoot = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_ACTOR_SPRITE )

    local target = global.actorManager:GetActor(targetID)
    if not target then
        return nil
    end
    local DROPITEM_RES_PATH   = "res/item"
    local DROPITEM_GROUND_RES_PATH   = "res/item_ground"
    local PUBLIC_UNDEFINE     = "un_define.pvr.ccz"
    local function createDropItem(index, item)
        local itemIndex = item.id or 1

        local itemData  = ItemConfigProxy:GetItemDataByIndex(itemIndex)
        local itemName  = ItemConfigProxy:GetItemNameByIndex(itemIndex)
        if not itemData then
            return nil
        end

        -- 资源路径
        local itemLooks = itemData.Looks or 1
        local groundFile = global.dropItemController:GetItemGroundFile(itemLooks)
        local dropItemTexc = global.CustomCache:GetImage(groundFile)
    
        local itemScale = SL:GetMetaValue("GAME_DATA","itemGroundSacle") or (global.isWinPlayMode and 0.5 or 0.8)
    
        if not dropItemTexc then
            groundFile = string.format("%s/%s",DROPITEM_RES_PATH,PUBLIC_UNDEFINE) 
            dropItemTexc = global.CustomCache:GetImage(groundFile)
            print( "Failed to load drop item avatar:"..fileName.."\n" )
        end

        local dropItemSprite   = cc.Sprite:createWithTexture( dropItemTexc )
        dropItemSprite:setScale(itemScale)
        dropItemSprite.GetBoundingBox = dropItemSprite.getBoundingBox
        --------------
        -- 计算初始坐标和目标坐标
        local originPos = global.sceneManager:MapPos2WorldPos(item.mapX, item.mapY, true)
        -- 创建道具图标
        local imageItem = dropItemSprite--ccui.ImageView:create()
        sceneRoot:addChild(dropItemSprite)
        imageItem:setPosition(originPos)
        imageItem:setTag(index)
        imageItem:setVisible(false)

        ------------
        local function moveToTarget()
            local speed = 400
            local interval = 1/60
            local function callback()
                local target = global.actorManager:GetActor(targetID)
                if not target then
                    global.CustomCache:RmImage(imageItem)
                    return nil
                end
                local targetPos = target:getPosition()
                local curItemPos = cc.p(imageItem:getPosition())

                local distance  = speed * interval
                local destSub   = cc.pSub(targetPos, curItemPos)
                local flyDir    = cc.pNormalize(destSub)
                local displ     = cc.pMul(flyDir, distance)
                local posNew    = cc.pAdd(curItemPos, displ)

                imageItem:setPosition(posNew)

                local destSub   = cc.pSub(targetPos, curItemPos)
                local destDist  = cc.pGetLength(destSub)
                if destDist <= distance*3 then
                    global.CustomCache:RmImage(imageItem)
                end
            end
            
            schedule(imageItem, callback, interval)
            performWithDelay(imageItem, function()
                global.CustomCache:RmImage(imageItem)
            end, 1)
        end
        
        imageItem:runAction(cc.Sequence:create(
            cc.Show:create(),
            cc.CallFunc:create(moveToTarget)
        ))
    end

    -- 
    for index, item in ipairs(items) do
        createDropItem(index, item)
    end
end

--飘经验特效
function EXPFly(actorID,effectID)
    if global.L_GameEnvManager:GetEnvDataByKey("isAliCloudPhone") then
        return
    end
    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end
    local MainPropertyMediator = global.Facade:retrieveMediator("MainPropertyMediator")
    if not MainPropertyMediator or not MainPropertyMediator._layer or not MainPropertyMediator._layer._quickUI or  not MainPropertyMediator._layer._quickUI.LoadingBar_exp then 
        return 
    end
    local  widget = MainPropertyMediator._layer._quickUI.LoadingBar_exp
    local X = actor:GetMapX()
    local Y = actor:GetMapY()
    -- 计算初始坐标和目标坐标
    local originPos = global.sceneManager:MapPos2WorldPos(X, Y)
    
    local sceneRoot = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_UI_NORMAL )
    local sfxRoot = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ACTOR_SFX_FRONT)
    if effectID == 0 then 
        effectID= 5057
    end
    local anim =  global.CustomCache:GetSFXAnim( effectID )
    if not anim then
        return nil
    end

    local Percentage = widget:getPercent()
    local targetPos =  widget:convertToWorldSpace(cc.p(0,0))
    local box = widget:getBoundingBox()

    targetPos.y = 0.5*box.height+targetPos.y
    targetPos.x = targetPos.x + Percentage/100*box.width
    sfxRoot:addChild(anim)
    anim:setLocalZOrder(effectID)
    anim:Play( 0, 0, true)
    anim:setPosition(originPos)
    anim:setVisible(true)
    anim:SetAnimEventCallback(function()
        global.CustomCache:RmSFXAnim(anim)
        local worldpos =  World2Screen(originPos)
        local count =   math.random(3,5)
        for i = 1,count do
            local lz =  global.CustomCache:GetImage(string.format("%slizi.png",global.MMO.PATH_RES_PUBLIC))  
            local newWorldPos = cc.p(worldpos.x + math.random(-50,50),worldpos.y + math.random(-50,50)+180)
            lz:setPosition(newWorldPos)
            sceneRoot:addChild(lz)
            lz:runAction(cc.Sequence:create(
                cc.MoveTo:create(1, targetPos),
                cc.CallFunc:create(function(sender) 
                    global.CustomCache:RmImage(lz)
                    if i == count then 
                        local anim2 = global.CustomCache:GetSFXAnim( 5058 ) 
                        if not anim2 then 
                            return 
                        end
                        sceneRoot:addChild(anim2)
                        anim2:setPosition(targetPos)
                        anim2:Play( 0, 0, false)
                        anim2:SetAnimEventCallback(function()
                            global.CustomCache:RmSFXAnim(anim2)
                        end)
                    end
                end )
            ))
        end
    end)
end

--飞向指定按钮
function ShowFakeDropItemsJustFly2(targetPos,items)
    if global.L_GameEnvManager:GetEnvDataByKey("isAliCloudPhone") then
        return
    end
    local sceneRoot = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_UI_NORMAL )
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local DROPITEM_RES_PATH   = "res/item"
    local DROPITEM_GROUND_RES_PATH   = "res/item_ground"
    local PUBLIC_UNDEFINE     = "un_define.pvr.ccz"
    local function createDropItem(index, item)
        local itemIndex = item.id or 1
        if not tonumber(itemIndex) or tonumber(itemIndex) < 100 then
            return nil
        end

        local itemData  = ItemConfigProxy:GetItemDataByIndex(itemIndex)
        local itemName  = ItemConfigProxy:GetItemNameByIndex(itemIndex)
        if not itemData or not next(itemData) then
            return nil
        end

        -- 资源路径
        local itemLooks = itemData.Looks or 1
        local groundFile = global.dropItemController:GetItemGroundFile(itemLooks)
        local dropItemTexc = global.CustomCache:GetImage(groundFile)
        local itemScale = SL:GetMetaValue("GAME_DATA","itemGroundSacle") or (global.isWinPlayMode and 0.5 or 0.8)
    
        if not dropItemTexc then
            groundFile = string.format("%s/%s",DROPITEM_RES_PATH,PUBLIC_UNDEFINE) 
            dropItemTexc     = global.CustomCache:GetImage(groundFile)
            print( "Failed to load drop item avatar:"..fileName.."\n" )
        end

        local dropItemSprite   = dropItemTexc
        dropItemSprite:setScale(itemScale)
        --------------
        -- 计算初始坐标和目标坐标
        local originPos = global.sceneManager:MapPos2WorldPos(item.mapX, item.mapY, true)
        local worldpos =  World2Screen(originPos)
        -- 创建道具图标
        local imageItem = dropItemSprite
        sceneRoot:addChild(imageItem)
        imageItem:setPosition(worldpos)
        imageItem:setTag(index)
        imageItem:setVisible(false)
        ------------
        local function moveToTarget()
            local speed = 600
            local interval = 1/60
            local function callback()
                local curItemPos = cc.p(imageItem:getPosition())
                local distance  = speed * interval
                local destSub   = cc.pSub(targetPos, curItemPos)
                local flyDir    = cc.pNormalize(destSub)
                local displ     = cc.pMul(flyDir, distance)
                local posNew    = cc.pAdd(curItemPos, displ)
                imageItem:setPosition(posNew)

                local destDist  = cc.pGetLength(destSub)
                if destDist <= 3*distance then
                    global.CustomCache:RmImage(imageItem)
                    SLBridge:onLUAEvent(LUA_EVENT_FLYIN_BTN_ITEM_COMPLETE, {itemIndex = itemIndex})
                end
            end
            
            schedule(imageItem, callback, interval)
        end

        imageItem:runAction(cc.Sequence:create(cc.Show:create(), cc.CallFunc:create(moveToTarget)))
    end

    local scheduleNode = sceneRoot:getChildByName("SCHEDULE_NODE")
    if scheduleNode then
        scheduleNode:removeFromParent()
        scheduleNode = nil
    end
    scheduleNode = cc.Node:create()
    scheduleNode:setName("SCHEDULE_NODE")
    sceneRoot:addChild(scheduleNode)

    local starIndex = 0
    local maxCount = #items
    -- 间隔加载
    local function scheduleCreate(callfunc,delayTime)
        local oneTimeCount = 15
        starIndex = starIndex + 1
        if not callfunc or starIndex > maxCount then
            local scheduleNode = sceneRoot:getChildByName("SCHEDULE_NODE")
            if scheduleNode then
                scheduleNode:removeFromParent()
                scheduleNode = nil
            end
            return
        end
        local endIndex = math.min(starIndex+oneTimeCount-1,maxCount)
        performWithDelay(scheduleNode,function()
            for i = starIndex, endIndex, 1 do
                local item = items[i]
                if item then
                    callfunc(i, item)
                end
            end
            starIndex = endIndex
            scheduleCreate(callfunc)
        end,delayTime or 0.5)
    end

    scheduleCreate(createDropItem,0)
end

--[[
    解析奖励展示 也会把里面的box解析出来
    参数: str="id#count&id#count", sp="&"  parseBox = 是否解析box  默认解析
]]
function ParseRewards(str, sp, parseBox)
    str = str or ""
    sp = sp or "&"
    local rewards = {}
    local sliceStr = string.split(str, sp)
    for i=1, #sliceStr do
        local sliceStr2 = string.split(sliceStr[i], "#")
        local id = tonumber(sliceStr2[1])
        if id then
            local count = tonumber(sliceStr2[2]) or 1
            table.insert(rewards, {id=id, count=count})
        end
    end
    return rewards
end

function JudgeIsRefreshTargetHP(data)
    local proxyPlayerInput = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
    local targetID = proxyPlayerInput:GetTargetID()
    if targetID and targetID == data.actorID then
        ssr.ssrBridge:OnRefreshTargetHP(data.actorID, data.HP, data.maxHP)
    end
end

function randDataID( role_id )
    -- body
    local data_id = role_id

    local function getRandomStr(n)
        local s = ""
        for i = 1, n do
            local type = math.random(1,3)
            if type == 1 then
                s = s .. math.random(0, 9)
            elseif type == 2 then
                s = s .. string.char(math.random(0, 25) + 65)
            elseif type == 3 then
                s = s .. string.char(math.random(0, 25) + 97)
            end
        end
        return s
    end
    
    data_id = data_id.."-"..getRandomStr(16)
    return data_id
end

function CheckPasswordIsSimple(password, account)
    if password and string.len( password ) < 6 then
        return true
    end
    if account == password then
        return true
    end
    if not string.match( password, "[^%d]" ) then
        return true
    end
    if not string.match( password, "[^%a]") then
        return true
    end
    return false
end

function ResetBagPos( )
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local QuickUseProxy = global.Facade:retrieveProxy( global.ProxyTable.QuickUseProxy )
    local bagData = BagProxy:GetBagData()
    for k,v in pairs(bagData) do
        if v.StdMode == 2 then
            local isCanAddToQuick = QuickUseProxy:CheckItemCanAddToQuickUse(v)
            local quickUsePos = QuickUseProxy:CheckQuickUseHasEmpty()
            if isCanAddToQuick and quickUsePos then --快捷栏道具
                QuickUseProxy:AutoAddBagItemToQuick(v, quickUsePos)
            end
        end
    end
    local newData = BagProxy:GetBagData()
    BagProxy:CleanBagPosData()
    BagProxy:AmendHistoryPos(newData, true)
    
    global.Facade:sendNotification(global.NoticeTable.Bag_Pos_Reset)
end

-- 添加全局回调事件
function AddGlobalScheduleFunc(funcMethodName, callback, interval)
    RmoveGlobalScheduleFunc(funcMethodName)
    interval = interval or 1
    globalSchedule[funcMethodName] = {
        sFunc =callback
    }
    globalSchedule[funcMethodName].scheuleId = Schedule( function()
        if globalSchedule[funcMethodName].sFunc then
            globalSchedule[funcMethodName]:sFunc()
        end
    end, interval)

    if callback then
        callback()
    end
end

-- 移除单个全局事件( funcMethodName: 函数名   没参数就删除所有的)
function RmoveGlobalScheduleFunc(funcMethodName)
    if funcMethodName then
        if globalSchedule[funcMethodName] then
            local scheuleId = globalSchedule[funcMethodName].scheuleId
            UnSchedule(scheuleId)
            globalSchedule[funcMethodName] = nil
        end
        return
    end
    globalSchedule = globalSchedule or {}
    for k,v in pairs(globalSchedule) do
        local scheuleId = v.scheuleId
        UnSchedule(scheuleId)
    end
    globalSchedule = {}
end

function CheckEquipPowerThanSelf(itemInfo, from)
    return GUIFunction:CompareEquipOnBody(itemInfo, from)
end

-- uf8字符串截取    str: 字符串    subStar: 截取开始    subEnd: 截取结束
function stringUTF8Sub( str,subStar,subEnd )
    if not str or str == "" then
        return ""
    end
    local charsize = function(ch)
        if not ch then 
            return 0
        elseif ch >= 252 then 
            return 6
        elseif ch >= 248 and ch < 252 then 
            return 5
        elseif ch >= 240 and ch < 248 then 
            return 4
        elseif ch >= 224 and ch < 240 then 
            return 3
        elseif ch >= 192 and ch < 224 then 
            return 2
        elseif ch < 192 then 
            return 1
        end
    end
    subStar                         = subStar or 1
    subEnd                          = subEnd or string.utf8len(str)
    local subLen                    = subEnd-subStar+1
    local byteStar,byteEnd,tempLen  = 0,1,0
    while subStar <= subEnd and subLen > 0 do
        local char = string.byte(str, byteEnd)
        byteEnd = byteEnd + charsize(char)
        tempLen = tempLen + 1
        if tempLen > subStar then
            subLen = subLen - 1
        elseif tempLen == subStar then
            byteStar = byteEnd - charsize(char)
            subLen = subLen - 1
        end
    end
    return string.sub(str, byteStar, byteEnd-1)
end

function CheckInputOnlyChinese( str )
    local charsize = function(ch)
        if not ch then 
            return 0
        elseif ch >= 252 then 
            return 6
        elseif ch >= 248 and ch < 252 then 
            return 5
        elseif ch >= 240 and ch < 248 then 
            return 4
        elseif ch >= 224 and ch < 240 then 
            return 3
        elseif ch >= 192 and ch < 224 then 
            return 2
        elseif ch < 192 then 
            return 1
        end
    end

    -- Unicode 4E00 - 9FA5
    local function checkChinese(ch, k) 
        if k == 1 and ch >= 228 and ch <= 233 then
            return true
        end
        if k and ( k == 2 or k == 3 ) then
            if ch >= 128 and ch <= 191 then
                return true
            end
        end
        return false
    end

    local inputStr = ""
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        if charsize(char) == 3 then
            local index = currentIndex
            local isCh = true
            for i = 1, 3 do
                isCh = isCh and checkChinese(string.byte(str, index + i - 1), i)
            end
            if isCh then
                inputStr = inputStr .. string.sub(str, index, index + 3-1)
            end
        end

        currentIndex = currentIndex + charsize(char)
    end
    return inputStr
end

-- 获取字符串的byte长度
function GetUTF8ByteLen( str )
    local function chsize(char)
        if not char then
            print("not char")
            return 0
        elseif char > 240 then
            return 4
        elseif char > 225 then
            return 3
        elseif char > 192 then
            return 2
        else
            return 1
        end
    end
    local len = 0
    local chineseLen = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        local charS = chsize(char)
        currentIndex = currentIndex + charS
        len = len + charS
        if charS >= 3 then
            chineseLen = chineseLen + 1
        end
    end
    return len,chineseLen
end

function CheckItemCountEnoughEX(data, speicalYuanBao)
    if speicalYuanBao == nil then
        data.speicalYuanBao = true
    else
        data.speicalYuanBao = speicalYuanBao
    end
    local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
    local result = PayProxy:CheckItemCountEX(data)
    return result
end

--------------------------------------------
--%S -> %s  %D -> %d  %x ->%%x %%x ->%%x
-- %s %d %%D %xxx %s %xx %m %  ->%s %d %%d %%xxx %s %%xx %%m %%
function Msg_formatPercent(str)
    if not str then 
        return ""
    end
    str = string.gsub(str,"%%S","%%s")
    str = string.gsub(str,"%%D","%%d")
    str = string.gsub(str,"([^%%])(%%[^sSdD%%])","%1%%%2")
    str = string.gsub(str,"%%$","%%%%")
    str = string.gsub(str,"^%%([^sSdD%%])","%%%%%1")--开头是%x的
    return str
end
--------------------------------------------
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function base64enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function base64dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

function setCusTomCursor(CursorType)
    if CursorType ~= global.CurrentCurSorType  then
        local path = ""
        if CursorType == global.MMO.CURSOR_TYPE_NORMAL then
            path = global.MMO.PATH_RES_PUBLIC.."CustomCursor1.png"
        elseif CursorType == global.MMO.CURSOR_TYPE_PK then
            path = global.MMO.PATH_RES_PUBLIC.."CustomCursor2.png"
        elseif CursorType == global.MMO.CURSOR_TYPE_NPC then 
            path = global.MMO.PATH_RES_PUBLIC.."CustomCursor3.png"
        end
        if setCustomCursor and cc.FileUtils:getInstance():isFileExist(path) then
            setCustomCursor(path) 
        end
        global.CurrentCurSorType = CursorType
    end
end

--刷新坐标变整数
function refPositionByParent(layer)
    if global.isWinPlayMode then 
        local visitChildren
        local refPos = function(v)
            if not v.CheckAndLoadRes then
                local worldpos = v:convertToWorldSpace(cc.p(0,0))
                local newpos = cc.p(math.floor(worldpos.x), math.floor(worldpos.y))
                local pos = cc.p(v:getPosition())
                v:setPosition(cc.pAdd(pos, cc.pSub(newpos, worldpos)))
                local needRefChild = true
                if (v.InitWidgetConfig and tolua.type(v) == "ccui.Widget") or (v._unRefPos and tolua.type(v) == "ccui.ListView") then
                    needRefChild = false
                end
                -- UIModel
                if needRefChild and v:getName() == "baseNode" then
                    needRefChild = false
                end
                if needRefChild then
                    if #v:getChildren() > 0  then 
                        visitChildren(v)
                    end
                end
            end
        end
        visitChildren = function (parent) 
            for i,v in pairs(parent:getChildren()) do
                refPos(v)
            end
        end
        refPos(layer)
    end
end

-- 禁止聊天
function IsForbidSay(autoTaost)
    local envProxy = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local forbidChat = tonumber(envProxy:GetCustomDataByKey("forbidSay")) == 1 or LoginProxy:IsForbidChat() == true
    if forbidChat and autoTaost then
        ShowSystemTips(GET_STRING(30103600))
    end
    return forbidChat
end

-- 禁止取名
function IsForbidName(autoTaost)
    local envProxy = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local LoginProxy = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local forbidName = tonumber(envProxy:GetCustomDataByKey("forbidName")) == 1 or LoginProxy:IsForbidName()
    if forbidName and autoTaost then
        ShowSystemTips(GET_STRING(30103600))
    end
    return forbidName
end

function fixMinusNumber(value)
    if value < 0 then
        return value + 4294967295 + 1
    end
    return value
end

function fixNetMsgHeader(header)
    if header.recog < 0 then
        header.recog = header.recog + 4294967295 + 1
    end
    if header.param1 < 0 then
        header.param1 = header.param1 + 4294967295 + 1
    end
    if header.param2 < 0 then
        header.param2 = header.param2 + 4294967295 + 1
    end
    if header.param3 < 0 then
        header.param3 = header.param3 + 4294967295 + 1
    end
end

function IsForbidOpenBagOrEquip()
    local NPCLayerMediator = global.Facade:retrieveMediator("NPCLayerMediator")
    if NPCLayerMediator and NPCLayerMediator._layer and NPCLayerMediator._forbidBagEquip then
        return true
    end

    return false
end

function CheckLayerOutScreen(tag)
    local LayerFacadeMediator = global.Facade:retrieveMediator("LayerFacadeMediator")
    if tag and tag == "BAG" then
        local mediator = global.Facade:retrieveMediator("BagLayerMediator")
        if not mediator then
            mediator = global.Facade:retrieveMediator("MergeBagLayerMediator")
        end
        return LayerFacadeMediator:checkOutScreen(mediator)
    end
    
    return false         
end

function IterAllChild(root, widget)
    for k,v in pairs(widget:getChildren()) do
        local name = v:getName()
        root[name] = v
        IterAllChild(root, v)
    end
end

function FixPath(path)
    if path and string.len(path) > 0 then
        return sgsub(sgsub(sgsub(sgsub(string.trim(path), [[\\]], "/"), [[\]],  "/"), "dev/", ""), "^/", "")
    else
        return path
    end
end

-- 检测节点是否在容器内
function CheckNodeInInside(node, list)
    local visiblesize = list:getContentSize()
    local worSpacePos = list:getWorldPosition()
    local anchorPoint = list:getAnchorPoint()
    local lowPos = worSpacePos.y - visiblesize.height * anchorPoint.y
    local uprPos = lowPos + visiblesize.height
    local worldPos = node:getWorldPosition()
    if worldPos.y > lowPos and worldPos.y < uprPos then
        return true
    end
    return false
end

function stringToUTF8String(convertStr)
    if type(convertStr) ~= "string" then
        return convertStr
    end

    local utf8Str = ""
    local i = 1
    local numericCodes = string.byte(convertStr, i)
    --
    while numericCodes ~= nil do
        local part1 = 0
        local part2 = 0
        if numericCodes >= 0x00 and numericCodes <= 0x7f then
            part1 = numericCodes
            part2 = 0
        elseif numericCodes >= 0xc0 and numericCodes <= 0xdf then
            local temp1 = 0
            local temp2 = 0
            temp1 = math.fmod(numericCodes, 0x20)

            i = i + 1
            numericCodes = string.byte(convertStr, i)
            temp2 = math.fmod(numericCodes, 0x40)

            part1 = temp2 + 64 * math.fmod(temp1, 0x04)
            part2 = math.floor(temp1 / 4)
        elseif numericCodes >= 0xe0 and numericCodes <= 0xf7 then
            local temp1 = 0
            local temp2 = 0
            local temp3 = 0
            temp1 = math.fmod(numericCodes, 0x10)

            i = i + 1
            numericCodes = string.byte(convertStr, i)
            temp2 = math.fmod(numericCodes, 0x40)

            i = i + 1
            numericCodes = string.byte(convertStr, i)
            temp3 = math.fmod(numericCodes, 0x40)

            part1 = math.fmod(temp2, 0x04) * 64 + temp3
            part2 = temp1 * 16 + math.floor(temp2 / 4)
        else
            part1 = 0x20
            part2 = 0x00
        end
        utf8Str = utf8Str .. string.format("0x%02x%02x", part2, part1)

        i = i + 1
        numericCodes = string.byte(convertStr, i)
    end
    --
    return utf8Str
end

-- 检测日文  unicode 0x0800 ~ 0x4e00
function IsJapaneseLanguage(str)
    if string.len(str or "") < 1 then
        return false
    end

    local UTF8 = require("util/utf8")
    local len = UTF8:length(str)
    for i = 1, len do
        local utf8Str = stringToUTF8String(UTF8:sub(str, i, 1))
        local value = tonumber(utf8Str)
        if value and value >= tonumber(0x0800) and value <= tonumber(0x4e00) then
            return true
        end
    end

    return false
end

-- 获取控件可见状态
function GetWidgetVisible(widget)
    local isVisible = widget:isVisible()
    if not isVisible then
        return false
    end
    local parent = widget:getParent()
    if not parent then
        return true
    end
    return GetWidgetVisible(parent)
end

-- 校验对象合法性
function CheckObjValid(widget)
    if not widget then
        return false
    end
    if tolua.isnull(widget) then
        return false
    end
    return true
end

--拆分文件夹(返回文件夹和文件名)
function GetFileInfoByFilePath(path)
    path = FixPath(path)
    local rerStr = sreverse(path)
    local _, i   = sfind(rerStr, "/")
    if not i then
        return "", path
    end
    local len = slen(path)
    local st  = len - i + 2
    return ssub(path, 1, st-2), ssub(path, st, len)
end

function ReOrderPlayerRender(array)
    local sortKey = {}
    if array[1] < array[2] then -- weapon:1 cloth:2 
        local t = clone(array)
        table.sort(t)
        for i, v in ipairs(t) do
            table.insert(sortKey, table.indexof(array, v))
        end

        table.remove(sortKey, table.indexof(sortKey, 1))
        local clothIdx = table.indexof(sortKey, 2)
        table.insert(sortKey, clothIdx + 1, 1)
    
        local order = {}
        for idx, key in ipairs(sortKey) do
            order[key] = idx - 1
        end
        return order
    end
    return array    
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

local function urlencodeT(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")

    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%-%_%~ :/=?&])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

function encodeToJP(str)
    str = tostring(str)
    local dictTAB = { 
        ['0'] = { 'ā','±','ě','ξ' },
        ['1'] = { '♂','τ','ο','δ' },
        ['2'] = { 'φ','ю','é','ī' },
        ['3'] = { 'ш','ō','ē','п' },
        ['4'] = { 'б','ь','ǒ','я' },
        ['5'] = { '＋','á','σ','α' },
        ['6'] = { 'ó','∩','ǎ','ε' },
        ['7'] = { 'í','ò','ì','°' },
        ['8'] = { 'à','○','ψ','♀' },
        ['9'] = { 'ζ','ョ','è','ǐ' },
        ['"'] = { 'λ','ǘ','ι','ǔ' },
        [','] = { 'ǚ','˙','ù','ü' },
        ['['] = { 'ǖ','ū','ё','з' },
        [']'] = { 'ǜ','ú','ω','э' },
        ['a'] = {'ぃ', 'い', 'ぅ', 'う'},
        ['b'] = {'ぇ', 'え', 'ぉ', 'お'},
        ['c'] = {'か', 'が', 'き', 'ぎ'},
        ['d'] = {'く', 'ぐ', 'け', 'げ'},
        ['e'] = {'こ', 'ご', 'さ', 'ざ'},
        ['f'] = {'し', 'じ', 'す', 'ず'},
        ['g'] = {'せ', 'ぜ', 'そ', 'ぞ'},
        ['h'] = {'た', 'だ', 'ち', 'ぢ'},
        ['i'] = {'っ', 'つ', 'づ', 'て'},
        ['j'] = {'で', 'と', 'ど', 'な'},
        ['k'] = {'に', 'ぬ', 'ね', 'の'},
        ['l'] = {'は', 'ば', 'ぱ', 'ひ'},
        ['m'] = {'び', 'ぴ', 'ふ', 'ザ'},
        ['n'] = {'シ', 'ジ', 'ス', 'ズ'},
        ['o'] = {'セ', 'ゼ', 'ソ', 'ゾ'},
        ['p'] = {'タ', 'ダ', 'チ', 'ヂ'},
        ['q'] = {'ッ', 'バ', 'ポ', 'ㄛ'},
        ['r'] = {'ツ', 'パ', 'マ', 'ㄜ'},
        ['s'] = {'ヅ', 'ヒ', 'ミ', 'ㄝ'},
        ['t'] = {'テ', 'ビ', 'ム', 'ㄞ'},
        ['u'] = {'デ', 'ピ', 'メ', 'ㄟ'},
        ['v'] = {'ト', 'フ', 'モ', 'ㄠ'},
        ['w'] = {'ド', 'ブ', 'ャ', 'ㄡ'},
        ['x'] = {'ナ', 'プ', 'ヤ', 'ㄢ'},
        ['y'] = {'ニ', 'ヘ', 'ュ', 'ㄣ'},
        ['z'] = {'ヌ', 'ベ', 'ユ', 'ㄤ'},
        ['.'] = {'ネ', 'ペ', 'ㄧ', 'ㄥ'},
        [':'] = {'ノ', 'ホ', 'ヨ', 'ㄦ'},
        ['/'] = {'ハ', 'ボ', 'ㄚ', 'ㄨ'},
    }

    local eStr = ""
    for i = 1, #str do
        local t = string.sub(str, i, i)
        local tStr = t
        if dictTAB[t] then
            local table = dictTAB[t]
            tStr = table[math.random(1, #table)]
        end
        eStr = eStr .. tStr
    end
    return eStr
end

function GetReportUrl()
    local url = "https://juhe-h5.dhsf.xqhuyu.com/GB/index.html#/"
    local envProxy   = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    if envProxy then 
        local ReportDoamin = envProxy:GetCustomDataByKey("ReportDoamin")
        if ReportDoamin and string.len(ReportDoamin) > 0 then 
            url = ReportDoamin .. "/GB/index.html#/"
        end
    end
    local loginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local AuthProxy     = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local envProxy      = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local currentSubMod = currentModule:GetCurrentSubMod()
    local userId        = AuthProxy:GetUID()
    local roleName      = loginProxy:GetSelectedRoleName()
    local roleId		= loginProxy:GetSelectedRoleID()
    local serverName    = loginProxy:GetSelectedServerName()
    local serverId      = loginProxy:GetSelectedServerId()
    local gameName      = currentModule:GetName()
    local subName       = currentSubMod:GetName() or ""
    local gameId        = currentModule:GetOperID()
    local channelId     = envProxy:GetChannelID()
    local showName      = string.len(subName) > 0 and ( gameName .. "_" .. subName ) or gameName
    local param =
        string.format("?uid=%s&rolename=%s&gamename=%s&gameid=%s&servername=%s&channelid=%s&roleid=%s&serverid=%s",
        encodeToJP(userId),
        roleName,
        showName,
        gameId,
        serverName,
        channelId,
        encodeToJP(roleId),
        encodeToJP(serverId)
    )
    if global.isIOS then
        param = urlencodeT(param)
    end
    url = url..param
    return url
end

function LoadLayerCUIConfig(key, layer)
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    SUIComponentProxy:loadOriginUIData(key, layer)
    SUIComponentProxy:loadCustomUIData(key, layer)
end

function FindCustomUIDataByKey(rootKey, uiName)
    if not rootKey or not uiName then
        return nil
    end

    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    local customUIData = SUIComponentProxy:findCustomUIData(rootKey)
    local uiData = customUIData and customUIData[uiName] 
    return uiData
end

function IsInSideNode(node, touchPos)
    if tolua.isnull(node) or not next(touchPos) then
        return false
    end
    
    local size = node:getContentSize()
    local anr  = node:getAnchorPoint()
    local pos  = node:getWorldPosition()
    local boundBox = {x = pos.x - size.width * anr.x, y = pos.y - size.height * anr.y, width = size.width, height = size.height}
    
    return cc.rectContainsPoint(boundBox, touchPos)
end

function KEY_MAP_XY(x, y)
    return y * 65536 + x
end

function RestrictCapInsetRect(capInsets, textureSize)
    local x = capInsets.x;
    local y = capInsets.y;
    local width = capInsets.width
    local height = capInsets.height
    
    if textureSize.width < width then
        x = textureSize.width / 2
        width = textureSize.width > 0 and 1 or 0
    end

    if textureSize.height < height then
        y = textureSize.height / 2
        height = textureSize.height > 0 and 1 or 0
    end

    return {x = x, y = y, width = width, height = height}
end

-- 转换成偶数
function ConvertToEven(num, up)
    num = tonumber(num)
    if not num then
        return 0
    end
    return num % 2 == 1 and (up and num + 1 or num - 1) or num
end

--获取函数参数个数
function getFucArgNums(fun)
    local num = 0
    local func = function()
        local hook = function( ... )
            local info = debug.getinfo(2)
            if not info.name then return end
            num = info.nparams
            debug.sethook()
        end
        debug.sethook(hook, "c")
        fun()
    end
    pcall(func)
    return num
end

--增加cocos自定义事件 跟node绑定 
function addCocosCustomEventListener(node, EventName, func)
    if not node then
        return 
    end 
    local eventDispatcher = node:getEventDispatcher()
    local customEventListener = cc.EventListenerCustom:create(EventName, func)
    eventDispatcher:addEventListenerWithSceneGraphPriority(customEventListener, node)
end

--派发cocos自定义事件
function dispatchCocosCustomEvent(EventName)
    global.Director:getEventDispatcher():dispatchCustomEvent(EventName)
end

-- 检查是否需要添加SL加的地图特效
function CheckNeedAddSLMapEffect(lastMapID, mapID)
    local data = SL.CustomMapEffects
    if not data or not next(data) then
       return 
    end

    local sceneImprisonEffectProxy = global.Facade:retrieveProxy(global.ProxyTable.SceneImprisonEffectProxy) 

    if data[lastMapID] and next(data[lastMapID]) then
        for id, data in pairs(data[lastMapID]) do
            global.sceneEffectManager:RmvSceneEffect(id)
            global.actorManager:RemoveActor(id)
            sceneImprisonEffectProxy:RmImprison(id)
        end
    end

    if data[mapID] and next(data[mapID]) then
        for id, item in pairs(data[mapID]) do
            local isInit  = false
            local actorID = id
            local mapX = item.x
            local mapY = item.y
            local sfxActor = global.actorManager:GetActor(actorID)
            if not sfxActor then
                isInit = true
                local paramSfx  = {}
                paramSfx.sfxId  = item.sfxId
                paramSfx.isLoop = item.loop
                paramSfx.type   = global.MMO.EFFECT_TYPE_NORMAL
                sfxActor = global.actorManager:CreateActor(actorID, global.MMO.ACTOR_SEFFECT, paramSfx, item.isBehind, item.isFront)
            end

            local actorPos = global.sceneManager:MapPos2WorldPos(mapX, mapY, true)
            sfxActor:setPosition(actorPos.x, actorPos.y)
            global.actorManager:SetActorMapXY(sfxActor, mapX, mapY)

            global.Facade:sendNotification( global.NoticeTable.DelayDirtyFeature, {actorID = actorID, actor = sfxActor})

            if isInit then
                global.sceneEffectManager:AddSceneEffect(sfxActor)
            end
        end
    end
end

--获取0时区时间
function getGMTime()
    return os.time(os.date("!*t",os.time()))
end

--获取文件内容md5
function GetFileMD5(filePath)
    if not global.FileUtilCtl:isFileExist(filePath) then
        return ""
    end
    local jsonStr = global.FileUtilCtl:getDataFromFileEx(filePath)
    if not jsonStr or jsonStr == "" or jsonStr == filePath then
        return ""
    end
    local md5 = SL:GetStrMD5(jsonStr)
    return md5
end

--小于version 返回小于0  等于返回0  大于返回大于0
function compareBoxVersion(version)
    if not version then 
        return -1
    end
    local boxVersion = global.L_GameEnvManager:GetEnvDataByKey("boxVersion")
    if not boxVersion then 
        return -1
    end
    if type(boxVersion) ~= "string" or type(version) ~= "string" then 
        return -1
    end
    local boxVArr = string.split(boxVersion, ".")
    local vArr = string.split(version, ".")
    local res = 0
    local v = 0
    local bv = 0
    for i,ver in ipairs(boxVArr) do
        v = tonumber(vArr[i]) or -1
        bv = tonumber(ver) or -1
        if v > bv then 
            return -1
        elseif v < bv then
            return 1 
        end  
    end
    return res
end