local RemoteProxy = requireProxy("remote/RemoteProxy")
local SUIComponentProxy = class("SUIComponentProxy", RemoteProxy)
SUIComponentProxy.NAME = global.ProxyTable.SUIComponentProxy

local cjson = require("cjson")
local SUIHelper = require("sui/SUIHelper")
local LexicalHelper = require("sui/LexicalHelper")

function SUIComponentProxy:ctor()
    SUIComponentProxy.super.ctor(self)

    self._data          = {}
    for _, v in pairs(global.SUIComponentTable) do
        self._data[v]   = {}
    end

    self._triggers      = {}        -- 触发响应

    -- 自添加UI Lua
    self._WidgetData          = {}
    for _, v in pairs(global.SUIComponentTable) do
        self._WidgetData[v]   = {}
    end

    -- 用于存取脚本拉杆变量数据
    self._sliderWidgets = {}

    -------------- CUI ----------------
    self._cuiNameConfig = {}        -- 自定义UI 名字
    self._originUIData  = {}        -- 原始UI数据
    self._customUIData  = {}        -- 自定义UI数据
    self._pc_customUIData = {}      -- PC端自定义UI数据
    -----------------------------------

    -- 是否上报TXT脚本主界面按钮点击事件
    self._mainUIClickEvent = false

    self:initTriggers()
end

function SUIComponentProxy:SetMainUIClickEvent(state)
    self._mainUIClickEvent = true == state
end

function SUIComponentProxy:ClearData()
    self._data          = {}
    for _, v in pairs(global.SUIComponentTable) do
        self._data[v]   = {}
    end    

    -- 自添加UI Lua
    self._WidgetData          = {}
    for _, v in pairs(global.SUIComponentTable) do
        self._WidgetData[v]   = {}
    end

    -- CUI
    self._cuiNameConfig = {}        
    self._originUIData  = {}        
    self._customUIData  = {}        
    self._pc_customUIData = {} 
end

function SUIComponentProxy:LoadConfig()
    -- 快捷键
    local config = requireGameConfig("cfg_KeyFunc")
    if config then
        for _, v in ipairs(config) do
            local keyCodes = {}
            local slices   = string.split(v.Key, "+")
            for _, key in ipairs(slices) do
                table.insert(keyCodes, cc.KeyCode["KEY_" .. key])
            end
            local pressedCB = function()
                self:onEventKeyCode(v.ID or v.IDX)
            end
            global.userInputController:addKeyboardListener(keyCodes, pressedCB)
        end
    end

    -- CUI
    local path = "data_config/cuidata.json"
    if global.FileUtilCtl:isFileExist(path) then
        local jsonStr  = global.FileUtilCtl:getDataFromFileEx(path)
        if not jsonStr or jsonStr == "" or jsonStr == path then
        else
            local jsonData = cjson.decode(jsonStr)
            self._customUIData = jsonData
        end
    end

    --
    local path = "data_config/pc_cuidata.json"
    if global.FileUtilCtl:isFileExist(path) then
        local jsonStr  = global.FileUtilCtl:getDataFromFileEx(path)
        if not jsonStr or jsonStr == "" or jsonStr == path then
        else
            local jsonData = cjson.decode(jsonStr)
            if jsonData then
                for key, value in pairs(jsonData) do
                    if key and value then
                        self._customUIData[key] = value
                    end
                end
            end
        end
    end

    for _, key in pairs(global.CUIKeyTable) do
        local keyPath = string.format("data_config/ui_config/%s.json", key)
        if global.FileUtilCtl:isFileExist(keyPath) then
            local jsonStr  = global.FileUtilCtl:getDataFromFileEx(keyPath)
            if not jsonStr or jsonStr == "" or jsonStr == keyPath then
            else
                local jsonData = cjson.decode(jsonStr)
                if jsonData then
                    self._customUIData[key] = jsonData
                end
            end
        end
    end
    -- 
    self:loadCUINameConfig()
end

function SUIComponentProxy:onEventKeyCode(id)
    print("function SUIComponentProxy:onEventKeyCode(id)", id)
    LuaSendMsg(global.MsgType.MSG_CS_KEYCODE_EVENT, id)
end

-----------------------------------------------------------------------------
-- 挂接组件
function SUIComponentProxy:updateComponent(data)
    if not data.index or not data.subid then
        return
    end
    if not self._data[data.index] then
        return 
    end

    local index         = data.index            -- ui编号
    local subid         = data.subid            -- 内容编号
    local content       = data.content          -- 内容

    -- update
    self._data[index][subid] = data

    -- update
    global.Facade:sendNotification(global.NoticeTable.SUIComponentUpdate, data)
end

function SUIComponentProxy:removeComponent(data)
    if not data.index or not data.subid then
        return
    end
    if not self._data[data.index] then
        return 
    end

    local index         = data.index            -- ui编号
    local subid         = data.subid            -- 内容编号
    local content       = data.content          -- 内容

    -- remove
    self._data[index][subid] = nil

    -- update
    global.Facade:sendNotification(global.NoticeTable.SUIComponentUpdate, data)
end

function SUIComponentProxy:loadSUIRender(index, subid, root)
    if nil == self._data[index] then
        return nil
    end
    if nil == self._data[index][subid] then
        return nil
    end

    local function linkCB(cdata)
        local tdata = clone(cdata)
        tdata.index = index
        tdata.subid = subid
        self:SubmitAct(tdata)
    end
    
    local function closeCB()
    end

    local mainIndex     = self._mainUIClickEvent and index >= 101 and index <= 109 and index or nil
    local data          = self._data[index][subid]
    local contentSize   = root:getContentSize()
    local rootRect      = cc.rect(0, 0, contentSize.width, contentSize.height)
    local elements      = LexicalHelper:Parse(data.content)
    local ext           = {isImmediate = true, mainIndex = mainIndex}
    local SUILoader     = require("sui/SUILoader").new()
    local trunk         = SUILoader:loadContent(elements, linkCB, closeCB, rootRect, ext)
    return trunk.render
end

function SUIComponentProxy:loadSUIRenderAll(index, root)
    if nil == self._data[index] then
        return nil
    end

    local data              = self._data[index]
    local renders           = {}
    for _, v in pairs(data) do
        renders[v.subid]    = self:loadSUIRender(v.index, v.subid, root)
    end
    return renders
end

function SUIComponentProxy:RespSUIDataUpdate(msg)
    local header   = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)

    if not jsonData then
        return nil
    end

    if header.recog == 0 then
        self:updateComponent(jsonData)

        -- print(" ++++++++++++++++++++++++ ")
        -- dump(jsonData)
        
    elseif header.recog == 1 then
        self:removeComponent(jsonData)

        -- print(" ------------------------ ")
        -- dump(jsonData)

    end
end

function SUIComponentProxy:SubmitAct(data)
    if not data.Act then
        return nil
    end

    local submitData = 
    {
        index = data.index,
        subid = data.subid,
        npcid = data.npcid,
        act   = data.Act,
        Input = data.Input,
        Slider = data.Slider,
        CheckBox = data.CheckBox,
        MenuItem = data.MenuItem,
    }
    local pattern = {string.find(data.Act, "^&(.+)")}
    if pattern and pattern[3] then
        JUMPTO(tonumber(pattern[3]))
    else
        SendTableToServer(global.MsgType.MSG_CS_SUICOMPONENT_SUBMIT, submitData)
    end
end

function SUIComponentProxy:UpdateAttachComponentByLua( data )
    if not data.index or not data.subid then
        return
    end
    if not self._WidgetData[data.index] then
        return 
    end

    local index         = data.index            -- ui编号
    local subid         = data.subid            -- 内容编号
    local content       = data.content          -- 内容
    local type          = data.type             -- 类型 

    if not type or (type and tonumber(type) == 0 )  then
        if not data.content then
            return
        end
        self._WidgetData[index][subid] = data
        self._WidgetData[index][subid].content:retain()
        
    elseif type and tonumber(type) == 1 then
        self._WidgetData[index][subid] = nil
    end

    -- update
    global.Facade:sendNotification(global.NoticeTable.SUIComponentUpdateByLua, data)

end

function SUIComponentProxy:GetWidgetData( index , subid)
    if not index or not self._WidgetData[index] then
        return nil
    end

    if not subid then
        return self._WidgetData[index]
    else
        return self._WidgetData[index][subid]
    end
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- 脚本触发
function SUIComponentProxy:initTriggers()
    -- 背包满
    self._triggers[1] = {
        cValue = nil,
        isAble = false,
        notices = 
        {
            global.NoticeTable.Bag_Oper_Data_Delay
        },
        callback = function()
            local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
            return BagProxy:isToBeFull()
        end
    }
    -- 背包满->空
    self._triggers[2] = 
    {
        cValue = nil,
        isAble = false,
        notices = 
        {
            global.NoticeTable.Bag_Oper_Data_Delay
        },
        callback = function()
            local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
            return not BagProxy:isToBeFull()
        end
    }
end

function SUIComponentProxy:RespTrigger(msg)
    local header    = msg:GetHeader()
    local id        = header.recog
    local isAble    = (header.param1 == 1)
    if not self._triggers[id] then
        return
    end
    self._triggers[id].isAble = isAble

    -- 
    self:checkTrigger(id)
end

function SUIComponentProxy:checkTrigger(id)
    local trigger = self._triggers[id]
    if not trigger then
        return nil
    end
    if not trigger.isAble then
        return nil
    end
    if not trigger.callback then
        return nil
    end
    local enable = trigger.callback()
    if trigger.cValue == enable then
        return nil
    end
    trigger.cValue = enable

    -- 触发了
    if trigger.cValue then
        self:RequestNoticeTrigger(id)
    end
end

function SUIComponentProxy:checkAllTriggers(noticeID)
    for id, trigger in pairs(self._triggers) do
        for _, v in pairs(trigger.notices) do
            if noticeID == v then
                self:checkTrigger(id)
                break
            end
        end
    end
end

function SUIComponentProxy:RequestNoticeTrigger(id)
    print("-------------------SUIComponentProxy:RequestNoticeTrigger", id)
    LuaSendMsg(global.MsgType.MSG_CS_SCRIPT_TRIGGER, id)
end

-----------------------------------------------------------------------------
function SUIComponentProxy:SetSUISliderValueById(sliderid, value)
    self._sliderWidgets[sliderid] = value
end

function SUIComponentProxy:GetSUISliderValueById(sliderid)
    return self._sliderWidgets[sliderid] or 0
end

function SUIComponentProxy:ClearSUISlider()
    self._sliderWidgets = {}
end

-----------------------------------------------------------------------------
function SUIComponentProxy:loadCUINameConfig()
    local path = "data_config/SUIWidgetNameConfig.json"
    if global.FileUtilCtl:isFileExist(path) then
        local jsonStr  = global.FileUtilCtl:getDataFromFileEx(path)
        if not jsonStr or jsonStr == "" or jsonStr == path then
        else
            local jsonData = cjson.decode(jsonStr)
            self._cuiNameConfig = jsonData
        end
    end
end

function SUIComponentProxy:findCUINameByWidgetKey(rootKey, widgetKey)
    if self._cuiNameConfig[rootKey] then
        local name = self._cuiNameConfig[rootKey][widgetKey]
        if name and string.len(name) > 0 then
            name = string.split(name,"|")[1]
            if name then
                return name
            end
        end
    end
    return widgetKey
end

function SUIComponentProxy:getCUIOrderDataByRoot( rootKey )
    local data = self._cuiNameConfig[rootKey]
    if data and next(data) then
        local t = {}
        for key, name in pairs(data) do
            local order = string.split(name, "|")[2]
            if order and tonumber(order) then
                t[tonumber(order)]  = key
            end
        end
        return t
    end
    return {}
end

function SUIComponentProxy:loadOriginUIData(rootKey, root)
    if not (global.isDebugMode or global.isGMMode) then
        return nil
    end

    self._originUIData[rootKey] = {}
    local ouiData = self._originUIData[rootKey]

    local parentName = ""
    local childName = ""
    local widgetKey = ""
    local children = {}
    local function foreachChildren(parent, parentName)
        children = parent:getChildren()
        if #children > 0 then
            for _, child in ipairs(children) do
                childName = child:getName()
                if childName and string.len(childName) > 0 then
                    widgetKey = parentName .. "#" .. childName
                    if child.editMode == 1  then
                        ouiData[widgetKey] = 
                        {
                            key     = widgetKey,
                            widget  = child,
                            x       = child:getPositionX(),
                            y       = child:getPositionY(),
                            width   = child:getContentSize().width,
                            height  = child:getContentSize().height,
                            visible = child:isVisible(),
                        }
                    end
                    foreachChildren(child, widgetKey)
                end
            end
        end
    end
    foreachChildren(root, root:getName())

    -- 
    self._customUIData[rootKey] = self._customUIData[rootKey] or {}
end

function SUIComponentProxy:findOriginUIData(rootKey)
    return self._originUIData[rootKey]
end

function SUIComponentProxy:writeCsutomUIData()
    --英雄信息栏特殊处理 保存即隐藏
    local rootKey = global.CUIKeyTable.HERO_STATE
    local heroStateData = self:findCustomUIData(rootKey)
    if heroStateData then
        if heroStateData["#Panel_1"] then heroStateData["#Panel_1"].visible = 0 end
        if heroStateData["#Button_hero"] then heroStateData["#Button_hero"].visible = 0 end
        if heroStateData["#Button_Lock"] then heroStateData["#Button_Lock"].visible = 0 end
    end

    --目标信息栏 同上处理
    local targetData = self:findCustomUIData(global.CUIKeyTable.MAINTARGET)
    if targetData and targetData["Node#Panel_1"] then
        targetData["Node#Panel_1"].visible = 0
    end

    -- dev
    local rootpath      = global.FileUtilCtl:getDefaultResourceRootPath()
    local modulepath    = rootpath .. "dev/"
    local writepath     = modulepath .. "data_config/cuidata.json"
    local jsonStr       = cjson.encode(self._customUIData)
    global.FileUtilCtl:writeStringToFile(jsonStr, writepath)

    -- PC自定义UI数据
    for key, value in pairs(self._customUIData) do
        if string.find(key, "^pc_") then
            self._pc_customUIData[key] = value
        end
    end

    local writepath     = modulepath .. "data_config/pc_cuidata.json"
    local jsonStr       = cjson.encode(self._pc_customUIData)
    global.FileUtilCtl:writeStringToFile(jsonStr, writepath)

    for _, key in pairs(global.CUIKeyTable) do
        local keyPath = string.format("data_config/ui_config/%s.json", key)
        local writepath = modulepath.. keyPath
        if self._customUIData[key] and next(self._customUIData[key]) then
            local jsonStr = cjson.encode(self._customUIData[key])
            global.FileUtilCtl:writeStringToFile(jsonStr, writepath)
        else
            if global.FileUtilCtl:isFileExist(writepath) then
                global.FileUtilCtl:removeFile( writepath )
            end
        end
    end
    
end

function SUIComponentProxy:findCustomUIData(rootKey)
    return self._customUIData[rootKey]
end

function SUIComponentProxy:resetCustomUIData(rootKey)
    self._customUIData[rootKey] = nil
end

function SUIComponentProxy:loadCustomUIData(rootKey, root, isFlag)
    local customData = self:findCustomUIData(rootKey)
    if not customData then
        return nil
    end

    local parentName = ""
    local childName = ""
    local widgetKey = ""
    local children = {}

    local function loadWidget(widget, cuiData, noPos)
        if not widget or not cuiData then
            return nil
        end
        local offsetx = cuiData.offsetx or 0
        local offsety = cuiData.offsety or 0
        local visible = (cuiData.visible == nil or cuiData.visible == 1) and true or false
        -- noPos 0 不加载坐标  1 2 仅加载X/Y坐标
        if not noPos then
            widget:setPositionX(widget:getPositionX() + offsetx)
            widget:setPositionY(widget:getPositionY() + offsety)
        end
        if noPos and noPos == 1 then    
            widget:setPositionX(widget:getPositionX() + offsetx)
        end
        widget:setVisible(visible)

        local originWidth = widget:getContentSize().width
        local originHeight = widget:getContentSize().height
        if tolua.type(widget) ~= "ccui.Text" then
            if widget.ignoreContentAdaptWithSize then
                widget:ignoreContentAdaptWithSize(false)
            end
        end
        widget:setContentSize(cuiData.width or originWidth, cuiData.height or originHeight)

        local classname = tolua.type(widget)
        if classname == "ccui.ImageView" then
            if cuiData.img and global.FileUtilCtl:isFileExist(cuiData.img)then
                widget:loadTexture(cuiData.img)
            end
            
        elseif classname == "ccui.Button" then
            if cuiData.nimg and global.FileUtilCtl:isFileExist(cuiData.nimg) then
                widget:loadTextureNormal(cuiData.nimg)
            end

            if cuiData.pimg and global.FileUtilCtl:isFileExist(cuiData.pimg) then
                widget:loadTexturePressed(cuiData.pimg)
            end

            if cuiData.dimg and global.FileUtilCtl:isFileExist(cuiData.dimg) then
                widget:loadTextureDisabled(cuiData.dimg)
            end

            if cuiData.text and string.len(cuiData.text) ~= 0 then
                widget:setTitleText(cuiData.text)
                if widgetKey == "#Panel_1#Button_4" and string.find(cuiData.text, "#") and rootKey == global.CUIKeyTable.BAG_MERGE then
                    local textList = string.split(cuiData.text, "#")
                    widget:setTitleText(textList[1])
                end
                if widgetKey == "Panel_1#Button_quick" and string.find(cuiData.text, "#") and rootKey == global.CUIKeyTable.NPC_STORAGE then
                    local textList = string.split(cuiData.text, "#")
                    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
                    local touchType = NPCStorageProxy:GetTouchType() or 1
                    widget:setTitleText(textList[touchType])
                end
            end

            --英雄召唤按钮
            if cuiData.nimgCall and global.FileUtilCtl:isFileExist(cuiData.nimgCall) then
                widget:loadTextureNormal(cuiData.nimgCall)
            end

            if cuiData.pimgCall and global.FileUtilCtl:isFileExist(cuiData.pimgCall) then
                widget:loadTexturePressed(cuiData.pimgCall)
            end

        elseif classname == "ccui.Text" then
            if cuiData.color and string.len(cuiData.color) ~= 0 then
                widget:setTextColor(GetColorFromHexString(cuiData.color))
            end

            if cuiData.fontSize then
                widget:setFontSize(cuiData.fontSize)
            end

            if cuiData.text then
                widget:setString(cuiData.text)
            end

        elseif classname == "ccui.LoadingBar" then
            if cuiData.img and global.FileUtilCtl:isFileExist(cuiData.img)then
                widget:loadTexture(cuiData.img)
            end

        elseif classname == "cc.Node" or classname == "ccui.Layout" then
            if cuiData.zorder and tonumber(cuiData.zorder) then
                widget:setLocalZOrder(tonumber(cuiData.zorder))
            end
        end
    end

    local function foreachChildren(parent, parentName)
        children = parent:getChildren()
        if #children > 0 then
            for _, child in ipairs(children) do
                childName = child:getName()
                if childName and string.len(childName) > 0 then
                    widgetKey = parentName .. "#" .. childName
                    if isFlag then  --特殊处理2合一背包刷新
                        if rootKey == "pc_property" then
                            local allWidgets = {
                                "#Panel_bg#Panel_hp",
                                "#Panel_bg#Panel_act",
                            }
                            for _, key in ipairs(allWidgets) do
                                if widgetKey == key then
                                    loadWidget(child, customData[widgetKey])
                                end
                            end
                            local needCustomXWidgets = {
                                "#Panel_bg#Panel_chat",
                                "#Panel_bg#Panel_chat#ListView_chat",
                                "#Panel_bg#Panel_chat#ListView_chat_ex",
                                "#Panel_bg#Panel_chat#TextField_input",
                                "#Panel_bg#Panel_auto_tips",
                                "#Panel_bg#Button_pick",
                            }
                            for _, key in ipairs(needCustomXWidgets) do
                                if widgetKey == key then
                                    loadWidget(child, customData[widgetKey], 1)
                                end
                            end
                        else
                            for i = 1, 3 do
                                local strKey = string.format( "#Panel_1#Node_1#btnPanel#btn_%s#titleName",i )
                                local strKey1 = string.format( "#Panel_1#Node_1#btnPanel#btn_%s", i )
                                if widgetKey == strKey or widgetKey == strKey1 then
                                    loadWidget(child, customData[widgetKey], 0)
                                end
                            end
                        end
                    else
                        loadWidget(child, customData[widgetKey])
                    end


                    foreachChildren(child, widgetKey)
                end
            end
        end
    end
    foreachChildren(root, root:getName())
end

-----------------------------------------------------------------------------
function SUIComponentProxy:RegisterMsgHandler()
    SUIComponentProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_SUICOMPONENT_UPDATE, handler(self, self.RespSUIDataUpdate))
    LuaRegisterMsgHandler(msgType.MSG_SC_SCRIPT_TRIGGER, handler(self, self.RespTrigger))
end

return SUIComponentProxy
