--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
local TxtTranslator = class("TxtTranslator")

local Element       = require("sui/Element")
local SWidget       = require("sui/SWidget")
local SUIHelper     = require("sui/SUIHelper")
local LexicalHelper = require("sui/LexicalHelper")
local RichTextHelp  = require("util/RichTextHelp")
local QuickCell     = requireUtil("QuickCell")
local TWidget       = require("sui/TWidget")
local cjson         = require("cjson")

local tinsert       = table.insert
local tremove       = table.remove
local ssplit        = string.split
local sfind         = string.find
local sformat       = string.format

local mfloor        = math.floor

local lineS         = sformat("%s%s","\n", "\t")
local tabS          = "\t"
local noParentCode  = -1

------------------------------------------ util

TxtTranslator.isBackground = function(swidget)
    if not swidget then
        return false
    end
    return tonumber(swidget.element.attr.bg) == 1
end
------------------------------------------
------------------------------------------

--
local defaultOutline    = 0
local defaultOutlineC   = 0
local defaultColorID    = 255
local defaultFontSize   = global.isWinPlayMode and 12 or 18
local anchorPoints      = {[0] = {x = 0, y = 1}, [1] = {x = 1, y = 1}, [2] = {x = 0, y = 0}, [3] = {x = 1, y = 0}, [4] = {x = 0.5, y = 0.5}}
local defaultTextX      = 25
local defaultTextY      = 20
local interval          = 0.167

local function transToTable(jsonStr)
    local resultStr = jsonStr
    for v in string.gmatch(resultStr, "\"(.-)\":") do
        resultStr = string.gsub(resultStr, "\"" .. v .. "\"", v)
        break
    end
    for v in string.gmatch(resultStr, ",\"(.-)\":") do
        resultStr = string.gsub(resultStr, "\"" .. v .. "\"" , v)
    end
    for v in string.gmatch(resultStr, "{\"(.-)\":") do
        resultStr = string.gsub(resultStr, "\"" .. v .. "\"" , v)
    end
    resultStr = string.gsub(resultStr, "%[", "{")
    resultStr = string.gsub(resultStr, "%]", "}")
    resultStr = string.gsub(resultStr, "\\/", "/")
    resultStr = string.gsub(resultStr, ",", ", ")
    return string.gsub(resultStr, ":", " = ")
end

local function replace(str, valueList)
    local result = ""

    local function getValueBySrc(source, valueList)
        if valueList and next(valueList) then
            source = string.gsub(source, "^[${]+", "") 
            source = string.gsub(source, "[}]+$", "")
            if source and string.len(source) > 0 and valueList[source] then
                if type(valueList[source]) == "table" then
                    local jsonStr = cjson.encode(valueList[source])
                    return transToTable(jsonStr)
                end
                return tostring(valueList[source])
            elseif source and string.len(source) > 0 and type(valueList[source]) == "boolean" then
                return tostring(valueList[source])
            end
        end
        return "ERROR"
    end
    while string.find(str, "${.-}") do
        local info = {string.find(str, "(${.-})")}
        if info[3] then
            result = result..string.sub(str, 1, info[1] - 1)
            local needRe = string.sub(str, info[1], info[2])
            result = string.format("%s%s", result, getValueBySrc(needRe, valueList))
            str = string.sub(str, info[2] + 1)
        end
    end
    return string.format("%s%s", result, str)
end

local function tranNegNum(num)
    if num < 0 then
        return sformat("(%s)", num)
    end
    return num
end

function TxtTranslator:loadTalkContent(str, filename)
    local NPCProxy          = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local talkData          = NPCProxy:GetCurrentNPCTalkData()
    local backgroundData    = NPCProxy:GetCurrentBackground()

    local function callback(cdata)
    end

    local function closeCB()
    end

    local function loadCompleteCB()
        print("load complete T")
    end

    local needAdd   = (self.trunk == nil)
    local ext       = {background = backgroundData, lastTrunk = self.trunk, lastBackground = self.background, loadCompleteCB = loadCompleteCB   }
    self._content = self:load(str, callback, closeCB, ext)

    -- 保存
    self:SaveToFile(filename, self._content)
end

function TxtTranslator:SaveToFile(fileName, content)
    if not fileName or string.len(fileName) == 0 then
        fileName = "export_file_" .. Random(0, 9999)
    end

    local exportPath = global.FileUtilCtl:getDefaultResourceRootPath() .. "dev/ssrExportFile"
    if not global.FileUtilCtl:isDirectoryExist(exportPath) then
        global.FileUtilCtl:createDirectory(exportPath)
    end

    local filePath = string.format("%s/%s.lua", exportPath, fileName)
    global.FileUtilCtl:writeStringToFile(content, filePath)

    ShowSystemTips("转化成功 ".. exportPath .. " ".. fileName .. ".lua")
end

TxtTranslator.getAnchorByIndex = function(index)
    return anchorPoints[index or 0]
end

TxtTranslator.modifySizeAble = function(swidget)
    local element = swidget.element
    if element.type == "Effect" then
        return false
    end
    if element.type == "Text" then
        return false
    end
    if element.type == "ItemShow" then
        return false
    end
    if element.type == "CostItem" then
        return false
    end
    if element.type == "COUNTDOWN" then
        return false
    end
    if element.type == "EquipShow" or element.type == "HEROEquipShow" or element.type == "PETEQUIPSHOW" then
        return false
    end
    if element.type == "TIMETIPS" then
        return false
    end
    if element.type == "TextAtlas" then
        return false
    end
    if element.type == "UIModel" then
        return false
    end
    if element.type == "ScrapePic" then
        return false
    end
    if element.type == "BmpText" then
        return false
    end
    return true
end

TxtTranslator.modifyAnchorAble = function(swidget)
    local element = swidget.element
    if element.type == "Effect" then
        return false
    end
    if element.type == "UIModel" then
        return false
    end
    return true
end

TxtTranslator.modifyRotateAble = function(swidget)
    return true
end

TxtTranslator.modifyVisible = function(swidget)
    return true
end

TxtTranslator.fixAnchor = function(swidget)
    local content = ""
    local name = swidget.realname or swidget.name
    if tonumber(swidget.element.attr.bg) == 1 and tonumber(swidget.element.attr.show) == 5 or tonumber(swidget.element.attr.show) == 6 then
        local ax            = tonumber(swidget.element.attr.tax)
        local ay            = tonumber(swidget.element.attr.tay)
        ax                  = ax or 0
        ay                  = ay or 1
        content = string.format("GUI:setAnchorPoint(%s, %.2f, %.2f)", name, ax, ay)
        return content
    end
    if swidget.element.attr.ax or swidget.element.attr.ay then
        local ax            = tonumber(swidget.element.attr.ax)
        local ay            = tonumber(swidget.element.attr.ay)
        ax                  = ax or 0
        ay                  = ay or 1
        content = string.format("GUI:setAnchorPoint(%s, %.2f, %.2f)", name, ax, ay)
        return content
        
    end

    local a                 = tonumber(swidget.element.attr.a) or 0
    local anchorPoint       = TxtTranslator.getAnchorByIndex(a)
    content = string.format("GUI:setAnchorPoint(%s, %.2f, %.2f)", name, anchorPoint.x, anchorPoint.y)
    return content
end

TxtTranslator.fixPosition = function(swidget)
    
    local defaultX          = (swidget.element.type == "Text" or swidget.element.type == "RText") and defaultTextX or 0
    local defaultY          = (swidget.element.type == "Text" or swidget.element.type == "RText") and defaultTextY or 0
    local x                 = tonumber(swidget.element.attr.x) or defaultX
    local y                 = tonumber(swidget.element.attr.y) or defaultY

    local percentx          = nil
    local percenty          = nil
    if tonumber(swidget.element.attr.bg) == 1 and tonumber(swidget.element.attr.show) == 5 or  tonumber(swidget.element.attr.show) == 6 then
        percentx            = tonumber(swidget.element.attr.tpercentx)
        percenty            = tonumber(swidget.element.attr.tpercenty)
    else
        percentx            = tonumber(swidget.element.attr.percentx)
        percenty            = tonumber(swidget.element.attr.percenty)
    end

    local name = swidget.realname or swidget.name
    local content = string.format("%s%s%s",
        sformat("local parent = GUI:getParent(%s)", name),
        lineS,
        "local parentSize = GUI:getContentSize(parent)"
    )

    if percentx then
        content = sformat("%s%s%s", content, lineS, 
            sformat("local x = parentSize.width * (%s / 100)", percentx))
    else
        content = sformat("%s%s%s", content, lineS, sformat("local x = %s", x))
    end
    if percenty then
        content = sformat("%s%s%s", content, lineS, 
        sformat("local y = parentSize.height - parentSize.height * (%s / 100)", percenty))
    else
        content = sformat("%s%s%s", content, lineS, sformat("local y = parentSize.height - %s", tranNegNum(y)))
    end

    content = sformat("%s%s%s", content, lineS, sformat("GUI:setPosition(%s, x, y)", name))

    return content
end

TxtTranslator.fixSize = function(swidget)
    
    local width             = tonumber(swidget.element.attr.width) 
    local height            = tonumber(swidget.element.attr.height) 
    local percentwidth      = tonumber(swidget.element.attr.percentwidth)
    local percentheight     = tonumber(swidget.element.attr.percentheight)

    local name = swidget.realname or swidget.name
    local content = ""
    if width or height or percentwidth or percentheight then
        content = sformat("local contentSize = GUI:getContentSize(%s)", name)
        if percentwidth or percentheight then
            content = string.format("%s%s%s%s%s",
                content,
                lineS,
                sformat("local parent = GUI:getParent(%s)", name),
                lineS,
                "local parentSize = GUI:getContentSize(parent)"
            )
        end
        
        if percentwidth then
            content = string.format("%s%s%s",
                content,
                lineS,
                sformat("local width = parentSize.width * (%s / 100)", percentwidth)
            )
        elseif width then
            content = string.format("%s%s%s", content, lineS, sformat("local width = %s", width))
        else
            content = string.format("%s%s%s", content, lineS, "local width = contentSize.width")
        end

        if percentheight then
            content = string.format("%s%s%s",
                content,
                lineS,
                sformat("local height = parentSize.height * (%s / 100)", percentheight)
            )
        elseif height then
            content = string.format("%s%s%s", content, lineS, sformat("local height = %s", height))
        else
            content = string.format("%s%s%s", content, lineS, "local height = contentSize.height")
        end

        content = string.format("%s%s%s", content, lineS, sformat("GUI:setContentSize(%s, width, height)", name))
    end
    return content
end

TxtTranslator.fixRotate = function(swidget)
    local rotate            = tonumber(swidget.element.attr.rotate) or 0
    return rotate
end

TxtTranslator.fixVisible = function(swidget)
    -- 默认0可见 1不可见
    local visible           = tonumber(swidget.element.attr.visible) or 0
    return visible == 0
end

-- load attr
TxtTranslator.loadSWidgetAttr = function(swidget)
    local render    = swidget.render
    local element   = swidget.element
    local name      = swidget.realname or swidget.name
    -- size
    local content = ""
    local function checkNeedLineS(content)
        if content and string.len(content) > 0 then
            return lineS
        end
        return ""
    end
    if TxtTranslator.modifySizeAble(swidget) and not swidget._setSized then
        local sizeStr   = TxtTranslator.fixSize(swidget)
        content = string.format("%s%s%s", content, checkNeedLineS(content), sizeStr)
    end

    -- anchor
    if TxtTranslator.modifyAnchorAble(swidget) then
        local anchorStr = TxtTranslator.fixAnchor(swidget)
        content = string.format("%s%s%s", content, checkNeedLineS(content), anchorStr)
    end

    -- rotate
    if TxtTranslator.modifyRotateAble(swidget) then
        local rotate    = TxtTranslator.fixRotate(swidget)
        content = string.format("%s%s%s", content, checkNeedLineS(content), sformat("GUI:setRotation(%s, %s)", name, rotate))
    end

    -- x y
    content = string.format("%s%s%s", content, checkNeedLineS(content), TxtTranslator.fixPosition(swidget))

    if TxtTranslator.modifyVisible(swidget) then
        local visible = TxtTranslator.fixVisible(swidget)
        content = string.format("%s%s%s", content, checkNeedLineS(content), sformat("GUI:setVisible(%s, %s)", name, tostring(visible)))
    end

    return content
end

------------------------------------------
--- init
function TxtTranslator:ctor()
    defaultOutline = SL:GetMetaValue("GAME_DATA", "defaultOutlineSize") or 0
    defaultOutlineC = SL:GetMetaValue("GAME_DATA", "defaultOutlineColor") or 0
end

------------------------------------------------------------------
-- load
function TxtTranslator:load(source, callback, closeCB, ext)
    local clock             = os.clock()

    -- parse
    local elements = LexicalHelper:Parse(source)

    -- fix background
    self:fixBackground(elements, ext)

    -- content
    local visibleSize       = global.Director:getVisibleSize()
    local _, rootRect       = checkNotchPhone()
    rootRect.width          = visibleSize.width
    rootRect.height         = visibleSize.height
    local content = self:loadContent(elements, callback, closeCB, rootRect, ext)

    --  
    print("load cost", os.clock() - clock)

    return content
end

function TxtTranslator:fixBackground(elements, ext)
    -- 优先级 脚本中设置过bg字段 -> GM指定大背景框 -> 默认背景框
    -- find background
    local background = nil
    for k, v in ipairs(elements) do
        if v.attr["bg"] == "1" then
            if not background then
                background = v
            else
                v.attr["bg"] = nil
            end
        end
    end

    if nil == background then
        if ext and ext.background then
            -- GM指定大背景框
            -- OPENMERCHANTBIGDLG 路径 显示位置  X坐标 Y坐标  高度 宽度 是否显示关闭按钮 关闭按钮X坐标 关闭按钮Y坐标 固定NPC对话框
            if ext.background.Param7 and tonumber(ext.background.Param7) == 1 then
                local element       = {}
                element.type        = "Button"
                element.attr        = {}
                element.attr.nimg   = "public/1900000510.png"  
                element.attr.pimg   = "public/1900000511.png"
                element.attr.link   = "@exit"
                element.attr.x      = tonumber(ext.background.Param8)
                element.attr.y      = tonumber(ext.background.Param9)
                table.insert(elements, 1, element)
            end
            
            local element           = {}
            element.type            = "Img"
            element.attr            = {}
            element.attr.img        = ext.background.Param1
            element.attr.bg         = 1
            element.attr.move       = tonumber(ext.background.Param10) and 1 or 0
            element.attr.reset      = 1
            element.attr.show       = tonumber(ext.background.Param2)
            element.attr.x          = tonumber(ext.background.Param3)
            element.attr.y          = tonumber(ext.background.Param4)
            element.attr.height     = tonumber(ext.background.Param5) ~= 0 and tonumber(ext.background.Param5) or nil
            element.attr.width      = tonumber(ext.background.Param6) ~= 0 and tonumber(ext.background.Param6) or nil
            element.attr.loadDelay  = 1
            table.insert(elements, 1, element)
        else
            -- 默认背景框
            local element           = {}
            element.type            = "Button"
            element.attr            = {}
            element.attr.nimg       = "public/1900000510.png"  
            element.attr.pimg       = "public/1900000511.png"
            element.attr.link       = "@exit"
            element.attr.x          = 546
            element.attr.y          = 0
            table.insert(elements, 1, element)

            local element           = {}
            element.type            = "Layout"
            element.attr            = {}
            element.attr.width      = 80
            element.attr.height     = 80
            element.attr.x          = 545
            element.attr.y          = 0
            element.attr.link       = "@exit"
            table.insert(elements, 1, element)
    
            local element           = {}
            element.type            = "Img"
            element.attr            = {}
            element.attr.img        = "public/bg_npc_01.png"  
            element.attr.bg         = 1
            element.attr.move       = 0
            element.attr.reset      = 1
            element.attr.show       = 0
            element.attr.loadDelay  = 1
            table.insert(elements, 1, element)
        end
    end

    return background
end

function TxtTranslator:loadContent(elements, callback, closeCB, rootRect, ext)
    self._loaders           = 
    {
        ["Img"]             = handler(self, self.load_render_Img),
        ["Text"]            = handler(self, self.load_render_Text),
        ["RText"]           = handler(self, self.load_render_RText),
        ["Input"]           = handler(self, self.load_render_Input),
        ["Button"]          = handler(self, self.load_render_Button),
        ["Effect"]          = handler(self, self.load_render_Effect),
        ["Frames"]          = handler(self, self.load_render_Frames),
        ["Layout"]          = handler(self, self.load_render_Layout),
        ["CheckBox"]        = handler(self, self.load_render_CheckBox),
        ["ListView"]        = handler(self, self.load_render_ListView),
        ["ItemShow"]        = handler(self, self.load_render_ItemShow),
        ["COUNTDOWN"]       = handler(self, self.load_render_COUNTDOWN),
        ["ITEMBOX"]         = handler(self, self.load_render_ITEMBOX),
        ["EquipShow"]       = handler(self, self.load_render_EquipShow),
        -- ["BAGITEMS"]        = handler(self, self.load_render_BAGITEMS),
        -- ["EQUIPITEMS"]      = handler(self, self.load_render_EQUIPITEMS),
        ["DBItemShow"]      = handler(self, self.load_render_DBItemShow),
        ["TIMETIPS"]        = handler(self, self.load_render_TIMETIPS),
        ["TextAtlas"]       = handler(self, self.load_render_TextAtlas),
        ["LoadingBar"]      = handler(self, self.load_render_LoadingBar),
        ["CircleBar"]       = handler(self, self.load_render_CircleBar),
        ["PercentImg"]      = handler(self, self.load_render_PercentImg),
        ["UIModel"]         = handler(self, self.load_render_UIModel),
        ["HEROEquipShow"]   = handler(self, self.load_render_HEROEquipShow),
        -- ["HEROEQUIPITEMS"]  = handler(self, self.load_render_HEROEQUIPITEMS),
        ["HERODBItemShow"]  = handler(self, self.load_render_HERODBItemShow),
        -- ["HEROBAGITEMS"]    = handler(self, self.load_render_HEROBAGITEMS),
        ["RTextX"]          = handler(self, self.load_render_RTextX),
        ["PageView"]        = handler(self, self.load_render_PageView),
        ["Slider"]          = handler(self, self.load_render_Slider),
        ["ScrapePic"]       = handler(self, self.load_render_ScrapePic),
        ["BmpText"]         = handler(self, self.load_render_BmpText),
    }

    -- 
    self._inputWidgets      = {}
    self._checkboxWidgets   = {}

    -- 对比上次，差异化更改
    local lastTrunk             = ext and ext.lastTrunk or nil
    local lastBackground        = ext and ext.lastBackground or nil
    local loadCompleteCB        = ext and ext.loadCompleteCB or nil
    local isImmediate           = ext and ext.isImmediate or false
    local parentNode            = ext and ext.parentNode or nil

    -- load swidgets
    local background            = nil
    local swidgets              = {}
    for i, element in ipairs(elements) do
        -- exist loader
        if self._loaders[element.type] then
            element.attr.id     = element.attr.id or string.format("default_%s", i)
            element.attr.x      = (element.type == "Text" or element.type == "RText" or element.type == "RTextX" or element.type == "BmpText") and (element.attr.x or defaultTextX) or element.attr.x
            element.attr.y      = (element.type == "Text" or element.type == "RText" or element.type == "RTextX" or element.type == "BmpText") and (element.attr.y or defaultTextY) or element.attr.y
    
            -- swidget
            local swidget       = TWidget.new()
            swidget.element     = element
            swidget.render      = nil
            swidget.name        = string.format("%s_%s", element.type, element.attr.id or i)
            swidget.id          = element.attr.id
            swidgets[element.attr.id] = swidget

            -- 记录背景图
            local isBG          = tonumber(element.attr.bg) == 1
            if isBG and not background then
                background      = swidget
            end
        end
    end

    -- tree mode
    for _, element in ipairs(elements) do
        if swidgets[element.attr.id] and swidgets[element.attr.id].element.attr.children then
            local swidget   = swidgets[element.attr.id]
            local branches  = swidget.element.attr.children
            local find_info = {sfind(branches, "{(.-)}")}
            local slices    = ssplit(find_info[3] or branches, ",")
            if #slices > 0 then
                for _, branchID in ipairs(slices) do
                    local branch = swidgets[branchID]
                    if branch and not branch.render and branch.element.attr.id ~= swidget.element.attr.id then
                        if branch.trunk then
                            print("ERROR TxtTranslator: swidget can't be add aegin. swidgetID=" .. element.attr.id .. "  branchID=" .. branchID)
                        else
                            swidget:addBranch(branch)
                        end
                    end
                end
            end
        end
    end

    -- trunk
    local trunk             = TWidget.new()
    trunk.element           = Element.new("Layout")
    trunk.depth             = 0
    trunk.name              = "Layout_1"
    trunk.id                = "Layout_1"
    for _, element in ipairs(elements) do
        local swidget = swidgets[element.attr.id]
        if swidget and swidget.trunk == nil then
            trunk:addBranch(swidget)
        end
    end

    self._content = ""

    local winPositions = {[0] = {x = rootRect.x, y = rootRect.height}, [1] = {x = rootRect.width, y = rootRect.height}, 
                          [2] = {x = rootRect.x, y = 0}, [3] = {x = rootRect.width, y = 0}, [4] = {x = rootRect.width / 2, y = rootRect.height / 2}}
    -- load trunk render
    if trunk and not trunk.render then
        local root_show = background and tonumber(background.element.attr.show) or 0 
        local extParam  = {pos = winPositions[root_show]}
        self._content   = tabS .. self:load_render(trunk, callback, closeCB, extParam)
    end
    ---
    -- load background render
    local backRender = nil
    if background and not background.render then
        local extParam = {parent = trunk and trunk.name}
        self._content = sformat("%s%s%s", self._content, "\n" .. lineS, self:load_render(background, callback, closeCB, extParam))
        backRender = true
    end
    -- size
    if background and backRender and TxtTranslator.modifySizeAble(background) then
        local content = TxtTranslator.fixSize(background)
        if content and string.len(content) > 0 then
            self._content = sformat("%s%s%s", self._content, lineS, content)
        end
        background._setSized = true
    end

    local root_anchor       = cc.p(0, 0)
    local root_position     = cc.p(rootRect.x, 0)
    local root_size         = cc.size(rootRect.width, rootRect.height)
    if background then
        local name          = background.name
        local root_show     = tonumber(background.element.attr.show) or 0
        if root_show == 0 then
            -- 左上
            root_anchor     = cc.p(0, 1)
            root_position   = cc.p(rootRect.x, rootRect.height)

            self._content = sformat("%s%s%s", self._content, lineS, sformat("local root_size = GUI:getContentSize(%s)", name))

        elseif root_show == 1 then
            -- 右上
            root_anchor     = cc.p(1, 1)
            root_position   = cc.p(rootRect.width, rootRect.height)
            self._content = sformat("%s%s%s", self._content, lineS, sformat("local root_size = GUI:getContentSize(%s)", name))

        elseif root_show == 2 then
            -- 左下
            root_anchor     = cc.p(0, 0)
            root_position   = cc.p(rootRect.x, 0)
            self._content = sformat("%s%s%s", self._content, lineS, sformat("local root_size = GUI:getContentSize(%s)", name))

        elseif root_show == 3 then
            -- 右下
            root_anchor     = cc.p(1, 0)
            root_position   = cc.p(rootRect.width, 0)
            self._content = sformat("%s%s%s", self._content, lineS, sformat("local root_size = GUI:getContentSize(%s)", name))

        elseif root_show == 4 then
            -- 中间
            root_anchor     = cc.p(0.5, 0.5)
            root_position   = cc.p(mfloor(rootRect.width / 2), mfloor(rootRect.height / 2))
            self._content = sformat("%s%s%s", self._content, lineS, sformat("local root_size = GUI:getContentSize(%s)", name))

        elseif root_show == 5 or root_show == 6 then
            -- 中间铺满
            local attr      = background.element.attr
            if attr.width or attr.height then
                self._content = sformat("%s%s%s", self._content, lineS, sformat("local root_size = GUI:getContentSize(%s)", name))
            else
                self._content = sformat("%s%s%s", self._content, lineS, sformat("local root_size = {width = %s, height = %s}", root_size.width. root_size.height))
            end
            root_anchor     = cc.p(0.5, 0.5)
            root_position   = cc.p(mfloor(rootRect.width / 2), mfloor(rootRect.height / 2))
            background.element.attr.tax = 0.5
            background.element.attr.tay = 0.5
            background.element.attr.tpercentx = 50
            background.element.attr.tpercenty = 50
        
        elseif root_show == 7 then
            -- 上下居中
            root_anchor.y   = 0.5
            root_position.y = mfloor(rootRect.height / 2)
            self._content = sformat("%s%s%s", self._content, lineS, sformat("local root_size = GUI:getContentSize(%s)", name))

        elseif root_show == 8 then
            -- 左右居中
            root_anchor.x   = 0.5
            root_position.x = mfloor(rootRect.width / 2)
            self._content = sformat("%s%s%s", self._content, lineS, sformat("local root_size = GUI:getContentSize(%s)", name))

        end
    end

    local show = background and tonumber(background.element.attr.show) or 0
    if show == 5 or show == 6 then 
        show = 4
    end
    local anchorPoint = anchorPoints[show] or anchorPoints[4]
    local position = winPositions[show] or cc.p(0, 0)
    
    if trunk.name then
        self._content = sformat("%s%s%s%s%s%s%s%s%s", 
            self._content,
            lineS,
            sformat("GUI:setContentSize(%s, root_size)", trunk.name),
            lineS,
            sformat("GUI:setAnchorPoint(%s, %.2f, %.2f)", trunk.name, anchorPoint.x, anchorPoint.y),
            lineS,
            sformat("GUI:setPosition(%s, %s, %s)", trunk.name, position.x, position.y),
            lineS,
            sformat("GUI:stopAllActions(%s)", trunk.name)
        )
    end

    -- load background attr
    if background and background.name then
        self._content = sformat("%s%s%s", self._content, lineS, TxtTranslator.loadSWidgetAttr(background))
    end

    ---------------------------------------
    -- load renders
    local function loadBranchRenders(loadTrunk)
        if #loadTrunk.branches == 0 then
            return nil
        end

        for _, branch in ipairs(loadTrunk.branches) do
            if not branch.content then
                local extParam = {parent = loadTrunk.name}
                local content = self:load_render(branch, callback, closeCB, extParam)
                if content then
                    branch.content = content
                    
                    -- load show attr
                    content = sformat("%s%s%s", content, lineS, TxtTranslator.loadSWidgetAttr(branch))
                    if loadTrunk.element.type == "ListView" then
                        if loadTrunk.element.attr.default  and tonumber(loadTrunk.element.attr.default) then
                            local default = tonumber(loadTrunk.element.attr.default) - 1
                            local index = math.max(default, 0)
                        end
                    end
                    self._content = sformat("%s%s%s", self._content, "\n" .. lineS, content)
                end
            end
        end
    end

    -- load immediate flag, edit form background
    local loadCount     = 1
    local loadStep      = 50
    isImmediate         = true
    if isImmediate then
        local function loadBranch(loadTrunk)
            if #loadTrunk.branches > 0 then
                loadBranchRenders(loadTrunk)

                for _, branch in ipairs(loadTrunk.branches) do
                    loadBranch(branch)
                end
            end
        end
        loadBranch(trunk)

        -- 装载完成
        if loadCompleteCB then
            loadCompleteCB()
        end
    end

    return self._content
end

function TxtTranslator:load_action(source)
    if not source then
        return nil
    end

    local find_info = {sfind(source, "{(.+)}")}
    if not (find_info[1] and find_info[2] and string.len(find_info[3]) > 0) then
        return nil
    end

    local actions = {}
    local slices  = ssplit(find_info[3], ";")
    for _, slice in ipairs(slices) do
        local slice_info    = {sfind(slice, "(.+):(.+)")}
        local action_type   = tonumber(slice_info[3])
        local params        = ssplit(slice_info[4], "#")
        if action_type == 1 then
            table.insert(actions, cc.ScaleTo:create(tonumber(params[1]), tonumber(params[2]), tonumber(params[2])))
        elseif action_type == 2 then
            table.insert(actions, cc.FadeTo:create(tonumber(params[1]), tonumber(params[2])))
        end
    end

    if not next(actions) then
        return nil
    end
    return cc.Sequence:create(actions)
end

function TxtTranslator:reload_render(swidget)
    local element           = swidget.element
    if element.type == "ListView" then
        local default       = tonumber(element.attr.default)
        if default and swidget.render then
            -- default
            local function callback()
                local index = math.max(default - 1, 0)
                swidget.render:jumpToItem(index, cc.p(0, 0), cc.p(0, 0))
                swidget.render:doLayout()
            end
            performWithDelay(swidget.render, callback, 1/60)
        end
    end
end

function TxtTranslator:load_render(swidget, callback, closeCB, ext)
    local element          = swidget.element
    local loader           = self._loaders[element.type]
    if nil == loader then
        print("load render error")
        return nil
    end

    local content           = loader(swidget, callback, closeCB, ext)
    local prefix            = sformat("-- Create SUI %s", element.type)
    swidget.content         = sformat("%s%s%s", prefix, lineS, content)
    
    return swidget.content
end

function TxtTranslator:load_render_Layout(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local width             = tonumber(element.attr.width) or 1
    local height            = tonumber(element.attr.height) or 1
    local color             = tonumber(element.attr.color)
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox 
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local name              = swidget.name
    local id                = swidget.id
    local parent            = ext and ext.parent
    local content           = ""
    if not parent then
        content = sformat([[local win = GUI:Win_Create("win")]])
        content = sformat("%s%s%s", content, lineS, 
            sformat([[local %s = GUI:Layout_Create(win, "%s", %s, %s, %s, %s)]], name, id, x, y, width, height))
    else
        content = sformat([[local %s = GUI:Layout_Create(%s, "%s", %s, %s, %s, %s)]], name, parent, id, x, y, width, height)
    end

    -- color
    if color then
        content = sformat("%s%s%s%s%s%s%s", content, lineS, 
            sformat("GUI:Layout_setBackGroundColor(%s, \"%s\")", name, GET_COLOR_BYID(color)),
            lineS,
            sformat("GUI:Layout_setBackGroundColorType(%s, 1)", name),
            lineS,
            sformat("GUI:Layout_setBackGroundColorOpacity(%s, 255)", name))
    end

    -- link
    if link and string.len(link) > 0 then
        content = sformat("%s%s%s%s%s", content, lineS, 
            sformat("GUI:setTouchEnabled(%s, true)", name),
            lineS,
            sformat("GUI:addOnClickEvent(%s, function()%s-- %s%send)", name, lineS, link, lineS)
        )
    end

    return content
end

function TxtTranslator:load_render_Text(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local text              = element.attr.text or ""
    local size              = tonumber(element.attr.size) or defaultFontSize
    local color             = element.attr.color or defaultColorID
    local link              = element.attr.link
    local width             = tonumber(element.attr.width)
    local outline           = tonumber(element.attr.outline) or defaultOutline
    local outlinecolor      = tonumber(element.attr.outlinecolor) or defaultOutlineC
    local scrollWidth       = tonumber(element.attr.scrollWidth)
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local auto              = tonumber(element.attr.auto)
    local platform          = tonumber(element.attr.platform)
    local clickInterval     = (tonumber(element.attr.clickInterval) or 0) * 0.001
    local tips              = element.attr.tips
    local tipsx             = tonumber(element.attr.tipsx) or 0
    local tipsy             = tonumber(element.attr.tipsy) or 0
    local tipWidth          = tonumber(element.attr.tipWidth) or 1136
    local simplenum         = tonumber(element.attr.simplenum) or 0
    local scrollWay         = tonumber(element.attr.scrollWay) or 0         -- 0 从右到左 1 从下到上
    local scrollTime        = tonumber(element.attr.scrollTime) or 4
    local scrollHeight      = tonumber(element.attr.scrollHeight)
    local thouFormat        = tonumber(element.attr.thouFormat) or 0
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0
    local hexColor          = element.attr.hexcolor

    local needLine = false
    if string.find(text, "\\") then
        needLine = true
    end

    text = string.gsub(text, "\\", "\r\n")
    text = string.trim(text)
    local showText = needLine and ("[[" .. text .. "]]") or sformat("\"%s\"", text)

    -- 
    local colorTable = {}
    if tonumber(color) then
        table.insert(colorTable, tonumber(color))
    else
        local slices = ssplit(color, ",")
        for _, v in ipairs(slices) do
            table.insert(colorTable, tonumber(v))
        end
    end

    --
    local useHex = false
    local hexColorTable = {}
    if hexColor then
        local slices = ssplit(hexColor, ",")
        for _, v in ipairs(slices) do
            if string.len(v) > 0 and string.find(v, "#") then
                table.insert(hexColorTable, v)
            end
        end
        if #hexColorTable > 0 then
            useHex = true
        end
    end
    local colorHex = useHex and hexColorTable[1] or GET_COLOR_BYID(colorTable[1])

    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = ""
    if scrollWidth then
        swidget.realname =  "scrollLayout_" .. id
        content = sformat("%s%s%s", sformat("local %s = GUI:Layout_Create(%s, \"%s\", %s, %s, %s, 0, true)", swidget.realname, parent, id, x, y, scrollWidth),
            lineS,
            sformat("local %s = GUI:Text_Create(%s, \"%s\", 0, 0, %s, \"%s\", %s)",
                name, swidget.realname, id, size, colorHex, showText)
            )
        -- size 
        content = sformat("%s%s%s", content, lineS, sformat("local widgetSize = GUI:getContentSize(%s)", name))
        if scrollHeight then
            content = sformat("%s%s%s", content, lineS, sformat("local scrollH = %s", scrollHeight))
        else
            content = sformat("%s%s%s", content, lineS, "local scrollH = widgetSize.height")
        end
        content = sformat("%s%s%s", content, lineS, sformat("GUI:setContentSize(%s, %s, scrollH)", swidget.realname, scrollWidth))
        content = sformat("%s%s%s", content, lineS, sformat("GUI:setAnchorPoint(%s, 0.00, 0.00)", name))

    else
        content = sformat("local %s = GUI:Text_Create(%s, \"%s\", %s, %s, %s, \"%s\", %s)", name, parent, id, x, y, size, colorHex, showText)
    end
    if outline > 0 then
        content = sformat("%s%s%s", content, lineS, sformat("GUI:Text_enableOutline(%s, \"%s\", %s)", name, GET_COLOR_BYID(outlinecolor), outline))
    end

    -- width
    if width then
        content = sformat("%s%s%s", content, lineS, sformat("GUI:Text_setMaxLineWidth(%s, %s)", name, width))
    end

    -- link
    if link and string.len(link) > 0 or (tips and string.len(tips) > 0) then
        -- 下划线
        content = sformat("%s%s%s", content, lineS, sformat("GUI:Text_enableUnderline(%s)", name))
        if link then
            content = sformat("%s%s%s%s%s", content, lineS, 
                sformat("GUI:setTouchEnabled(%s, true)", name),
                lineS,
                sformat("GUI:addOnClickEvent(%s, function()%s-- %s%send)", name, lineS, link, lineS)
            )
        end
    end
    
    -- auto color
    local tbl = useHex and hexColorTable or colorTable
    if #tbl > 1 then
        content = sformat("%s%s%s", content, lineS, replace([[local index = 1
${t}local colorTable = ${colorTable}
${t}local function callback()
${t}${t}index = index + 1
${t}${t}if index > #colorTable then
${t}${t}${t}index = 1
${t}${t}end
${t}${t}local color = colorTable[index]
${t}${t}if tonumber(colorTable[index]) then
${t}${t}${t}color = SL:GetHexColorByStyleId(tonumber(colorTable[index]))
${t}${t}end
${t}${t}GUI:Text_setTextColor(${name}, color)
${t}end
${t}SL:schedule(${name}, callback, 1)]], {colorTable = tbl, name = name, t = tabS})
        )
    end

    -- auto scroll

    if scrollWidth then
        if scrollWay == 0 then
            content = sformat("%s%s%s", content, lineS, 
[[GUI:setAnchorPoint(${name}, 0.00, 0.00)
${t}GUI:setPosition(${name}, 0, 0)
${t}GUI:runAction(${name}, GUI:ActionRepeatForever(GUI:ActionSequence(
${t}${t}GUI:ActionMoveBy(${scrollTime}, - widgetSize.width, 0), 
${t}${t}GUI:ActionMoveBy(0, widgetSize.width, 0))))]])
        elseif scrollWay == 1 then
            content = sformat("%s%s%s", content, lineS, 
[[GUI:setAnchorPoint(${name}, 0.00, 1.00)
${t}GUI:setPosition(${name}, 0, scrollH)
${t}GUI:runAction(${name}, GUI:ActionRepeatForever(GUI:ActionSequence(
${t}${t}GUI:ActionMoveBy(${scrollTime}, 0, widgetSize.height), 
${t}${t}GUI:ActionMoveBy(0, 0, - widgetSize.height))))]])
        end
       
        content = replace(content, {
            name = name, scrollTime = scrollTime, t = tabS
        })
        return content
    end

    if simplenum == 1 or thouFormat == 1 then
        content = sformat("%s%s%s", content, lineS, sformat("local str = GUI:Text_getString(%s)", name))

        if simplenum == 1 then
            content = sformat("%s%s%s", content, lineS, replace([[if str and tonumber(str) then
${t}${t}str = SL:GetSimpleNumber(tonumber(str))
${t}${t}GUI:Text_getString(${name}, str)
${t}end]], {name = name, t = tabS}))
        end

        if thouFormat == 1 then
            content = sformat("%s%s%s", content, lineS, replace([[if str and tonumber(str) then
${t}${t}str = SL:GetThousandSepString(tonumber(str))
${t}${t}GUI:Text_getString(${name}, str)
${t}end]], {name = name, t = tabS}))
        end 
    end
    
    return content
end

function TxtTranslator:load_render_TextAtlas(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local img               = element.attr.img or "public/word_tywz_01.png"
    local iwidth            = tonumber(element.attr.iwidth) or 18
    local iheight           = tonumber(element.attr.iheight) or 28
    local schar             = element.attr.schar or "0"
    local text              = element.attr.text or ""
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local img               = SUIHelper.fixImageFileName(img)
    local fullPath          = (img and img ~= "") and string.format(getResFullPath("res/%s"), img) or ""
    if not fullPath or fullPath == "" or not global.FileUtilCtl:isFileExist(fullPath) then
        img                 = SUIHelper.fixImageFileName("public/word_tywz_01.png")
        fullPath            = string.format(getResFullPath("res/%s"), img)
    end

    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = sformat("local %s = GUI:TextAtlas_Create(%s, \"%s\", %s, %s, \"%s\", \"%s\", %s, %s, \"%s\")",
        name, parent, id, x, y, text, fullPath, iwidth, iheight, schar)
    
    return content
end

function TxtTranslator:load_render_RText(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local text              = element.attr.text or ""
    local size              = tonumber(element.attr.size) or defaultFontSize
    local color             = tonumber(element.attr.color) or defaultColorID
    local width             = tonumber(element.attr.width) or 1136
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local outline           = tonumber(element.attr.outline) or defaultOutline
    local outlinecolor      = tonumber(element.attr.outlinecolor) or defaultOutlineC
    local scrollWidth       = tonumber(element.attr.scrollWidth)
    local scrollWay         = tonumber(element.attr.scrollWay) or 0         -- 0 从右到左 1 从下到上
    local scrollTime        = tonumber(element.attr.scrollTime) or 4
    local scrollHeight      = tonumber(element.attr.scrollHeight)
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0
    local colorHex          = GET_COLOR_BYID(color)
    local vspace            = SL:GetMetaValue("GAME_DATA", "DEFAULT_VSPACE")

    local outlineParam = {
        outlineSize = outline,
        outlineColor = GET_COLOR_BYID_C3B(outlinecolor)
    }

    -- text = string.gsub(text, "\\", "<br></br>")
    local needLine = false
    if string.find(text, "\\") then
        needLine = true
    end
    local showText = needLine and ("[[" .. text .. "]]") or sformat("\"%s\"", text)

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = ""
    if scrollWidth then
        swidget.realname = "scrollLayout_" .. id
        content = sformat("%s%s%s",
        sformat("local %s = GUI:Layout_Create(%s, \"%s\", %s, %s, %s, 0, true)", swidget.realname, parent, id, x, y, scrollWidth),
        lineS,
        replace(sformat("local %s = GUI:RichTextFCOLOR_Create(%s, \"%s\", 0, 0, %s, %s, %s, \"%s\", %s, nil, nil, ${outlineParam})",
            name, swidget.realname, id, showText, width, size, colorHex, vspace)
            , {outlineParam = outlineParam})
        )
        -- size 
        content = sformat("%s%s%s", content, lineS, sformat("local widgetSize = GUI:getContentSize(%s)", name))
        if scrollHeight then
            content = sformat("%s%s%s", content, lineS, sformat("local scrollH = %s", scrollHeight))
        else
            content = sformat("%s%s%s", content, lineS, "local scrollH = widgetSize.height")
        end
        content = sformat("%s%s%s", content, lineS, sformat("GUI:setContentSize(%s, %s, scrollH)", swidget.realname, scrollWidth))

    else
        content = replace(sformat("local %s = GUI:RichTextFCOLOR_Create(%s, \"%s\", 0, 0, %s, %s, %s, \"%s\", %s, nil, nil, ${outlineParam})",
                name, parent, id, showText, width, size, colorHex, vspace), {outlineParam = outlineParam})
    end

    -- auto scroll
    if scrollWidth then
        if scrollWay == 0 then
            content = sformat("%s%s%s", content, lineS, [[GUI:setAnchorPoint(${name}, 0.00, 0.00)
${t}GUI:setPosition(${name}, 0, 0)
${t}GUI:runAction(${name}, GUI:ActionRepeatForever(GUI:ActionSequence(
${t}${t}GUI:ActionMoveBy(${scrollTime}, - widgetSize.width, 0), 
${t}${t}GUI:ActionMoveBy(0, widgetSize.width, 0))))]])
           
        elseif scrollWay == 1 then
            content = sformat("%s%s%s", content, lineS, [[GUI:setAnchorPoint(${name}, 0.00, 1.00)
${t}GUI:setPosition(${name}, 0, scrollH)
${t}GUI:runAction(${name}, GUI:ActionRepeatForever(GUI:ActionSequence(
${t}${t}GUI:ActionMoveBy(${scrollTime}, 0, widgetSize.height), 
${t}${t}GUI:ActionMoveBy(0, 0, - widgetSize.height))))]])

        end

        content = replace(content, {
            name = name, scrollTime = scrollTime, t = tabS
        })
        
        return content
    end

    return content
end

function TxtTranslator:load_render_Img(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local bg                = tonumber(element.attr.bg)
    local img               = element.attr.img or ""
    local link              = element.attr.link
    local width             = tonumber(element.attr.width)
    local height            = tonumber(element.attr.height)
    local scale9l           = tonumber(element.attr.scale9l)
    local scale9r           = tonumber(element.attr.scale9r)
    local scale9t           = tonumber(element.attr.scale9t)
    local scale9b           = tonumber(element.attr.scale9b)
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local grey              = tonumber(element.attr.grey) or 0
    local flip              = tonumber(element.attr.flip) or 0
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local img               = SUIHelper.fixImageFileName(img)
    local fullPath          = (img and img ~= "") and string.format(getResFullPath("res/%s"), img) or ""
    
    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = sformat("local %s = GUI:Image_Create(%s, \"%s\", %s, %s, \"%s\")", name, parent, id, x, y, fullPath)
    
    if scale9l and scale9r and scale9t and scale9b then
        content = sformat("%s%s%s", content, lineS, sformat("GUI:Image_setScale9Slice(%s, %s, %s, %s, %s)", name, scale9l, scale9r, scale9t, scale9b))
    end

    if bg == 1 then
        content = sformat("%s%s%s", content, lineS, "GUI:setTouchEnabled(${name}, true)")
        if global.isWinPlayMode then
            content = sformat("%s%s%s%s%s", content, lineS, "GUI:setMouseEnabled(${name}, true)", lineS, "GUI:addMouseMoveEvent(${name}, {})")
        end
    end

    -- grey
    if grey == 1 then
        content = sformat("%s%s%s", content, lineS, "GUI:Img_SetGrey(${name}, true)")
    end

    if flip == 1 then
        content = sformat("%s%s%s", content, lineS, "GUI:setFlippedX(${name}, true)")
    elseif flip == 2 then
        content = sformat("%s%s%s", content, lineS, "GUI:setFlippedY(${name}, true)")
    end

    return replace(content, {name = name})
end

function TxtTranslator:load_render_Button(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local nimg              = element.attr.nimg
    local pimg              = element.attr.pimg
    local mimg              = element.attr.mimg
    local text              = element.attr.text or ""
    local color             = tonumber(element.attr.color) or defaultColorID
    local size              = tonumber(element.attr.size) or defaultFontSize
    local width             = tonumber(element.attr.width)
    local height            = tonumber(element.attr.height)
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local tips              = element.attr.tips
    local tipsx             = tonumber(element.attr.tipsx) or 0
    local tipsy             = tonumber(element.attr.tipsy) or 0
    local textWidth         = tonumber(element.attr.textwidth)
    local grey              = tonumber(element.attr.grey) or 0
    local clickInterval     = (tonumber(element.attr.clickInterval) or 0) * 0.001
    local outline           = tonumber(element.attr.outline) or defaultOutline
    local outlinecolor      = tonumber(element.attr.outlinecolor) or defaultOutlineC
    local tipWidth          = tonumber(element.attr.tipWidth) or 1136
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    text = string.gsub(text, "\\", "\r\n")
    text = string.trim(text)

    local nimg      = SUIHelper.fixImageFileName(nimg)
    local pimg      = SUIHelper.fixImageFileName(pimg)
    local mimg      = SUIHelper.fixImageFileName(mimg)
    local fullPathN = (nimg and string.len(nimg) > 0 and string.format(getResFullPath( "res/%s" ), nimg) or "")
    local fullPathP = (pimg and string.len(pimg) > 0 and string.format(getResFullPath( "res/%s" ), pimg) or "")
    local fullPathM = (mimg and string.len(mimg) > 0 and string.format(getResFullPath( "res/%s" ), mimg) or "")
    
    local name = swidget.name 
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Button_Create(${parent}, "${ID}", ${x}, ${y}, "${nimg}")
${t}GUI:Button_setTitleText(${name}, "${text}")
${t}GUI:Button_setTitleColor(${name}, "${color}")
${t}GUI:Button_setTitleFontSize(${name}, ${size})]], 
        {name = name, text = text, color = GET_COLOR_BYID(color), size = size, parent = parent, ID = id, x = x, y = y, nimg = fullPathN, t = tabS})
   

    if fullPathP ~= "" and global.FileUtilCtl:isFileExist(fullPathP) then
        content = sformat("%s%s%s", content, lineS, 
            sformat("GUI:Button_loadTexturePressed(%s, \"%s\")", name, fullPathP))
    end

    if textWidth then
        content = sformat("%s%s%s", content, lineS, replace([[GUI:Button_setMaxLineWidth(${name}, ${textWidth})]], {name = name, textWidth = textWidth}))
    end
    
    if outline > 0 then
        content = sformat("%s%s%s", content, lineS, 
            sformat("GUI:Button_titleEnableOutline(%s, \"%s\", %s)", name, GET_COLOR_BYID(outlinecolor), outline))
    end

    -- grey
    if grey == 1 then
        content = sformat("%s%s%s", content, lineS, sformat("GUI:Button_SetGrey(%s, true)", name))
    end

    return content
end

function TxtTranslator:load_render_CheckBox(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local checkboxid        = element.attr.checkboxid
    local nimg              = element.attr.nimg
    local pimg              = element.attr.pimg
    local default           = tonumber(element.attr.default) or 0
    local submit            = tonumber(element.attr.submit) or 0
    local delay             = math.max(tonumber(element.attr.delay) or 0, 1 / 60)
    local count             = tonumber(element.attr.count) or 0
    local link              = element.attr.link
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local nimg              = SUIHelper.fixImageFileName(nimg)
    local pimg              = SUIHelper.fixImageFileName(pimg)
    local nimgPath          = nimg and string.format(getResFullPath("res/%s"), nimg)
    local pimgPath          = pimg and string.format(getResFullPath("res/%s"), pimg)
    local isSelected        = default == 1

    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:CheckBox_Create(${parent}, "${ID}", ${x}, ${y}, "${nimgPath}", "${pimgPath}")
${t}GUI:CheckBox_setSelected(${name}, ${isSelected})
${t}GUI:setTouchEnabled(${name}, true)]], 
        {name = name, parent = parent, ID = id, x = x, y = y, nimgPath = nimgPath, pimgPath = pimgPath, isSelected = isSelected, t = tabS})

    return content
end

function TxtTranslator:load_render_ListView(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local width             = element.attr.width or 200
    local height            = element.attr.height or 200
    local color             = tonumber(element.attr.color)
    local direction         = tonumber(element.attr.direction) or 1
    local bounce            = tonumber(element.attr.bounce) or 1
    local margin            = tonumber(element.attr.margin) or 0
    local default           = tonumber(element.attr.default)
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = sformat("local %s = GUI:ListView_Create(%s, \"%s\", %s, %s, %s, %s, %s)",
        name, parent, id, x, y, width, height, direction)
    
    content = sformat("%s%s%s", content, lineS, replace("GUI:ListView_setBounceEnabled(${name}, ${bounce})", {bounce = bounce == 1, name = name}))

    if margin > 0 then
        content = sformat("%s%s%s", content, lineS, sformat("GUI:ListView_setItemsMargin(%s, %s)", name, margin))
    end

    -- color
    if color then
        content = sformat("%s%s%s", content, lineS, replace([[GUI:ListView_setBackGroundColor(${name}, "${color}")
${t}GUI:ListView_setBackGroundColorType(${name}, 1)
${t}GUI:ListView_setBackGroundColorOpacity(${name}, 255)]], {name = name, color = GET_COLOR_BYID(color), t = tabS}))
    end

    -- default
    if default then
        content = sformat("%s%s%s", content, lineS, replace(
[[${t}local default = ${default}
${t}local function callback()
${t}${t}default = default - 1
${t}${t}local index = math.max(default, 0)
${t}${t}GUI:ListView_JumpToItem(${name}, index)
${t}${t}GUI:ListView_doLayout(${name})
${t}end
${t}SL:scheduleOnce(${name}, callback, 1 / 60)]], {default = default, name = name, t = tabS}))
    end
    
    return content
end

function TxtTranslator:load_render_Effect(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local effecttype        = tonumber(element.attr.effecttype) or 0
    local effectid          = tonumber(element.attr.effectid) or 9999
    local sex               = tonumber(element.attr.sex) or 0
    local act               = tonumber(element.attr.act) or 0
    local dir               = tonumber(element.attr.dir) or 5
    local speed             = tonumber(element.attr.speed) or 1
    local scale             = tonumber(element.attr.scale) or 1
    local count             = tonumber(element.attr.count) or 0
    local link              = element.attr.link
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    -- 0.普通特效 1.npc模型 2.怪物模型 3.技能特效 4.人物 5.武器 6.翅膀 7.发型
    local name          = swidget.name
    local id            = swidget.id
    local parent        = ext and ext.parent or noParentCode
    local needScale     = scale ~= 1
    local needCount     = count ~= 0
    local content       = [[local ${name} = GUI:Effect_Create(${parent}, "${ID}", ${x}, ${y}, ${effecttype}, ${effectid}, ${sex}, ${act}, ${dir}, ${speed})]]
    if needScale or needCount then
        content = sformat("%s%s%s", content, lineS, "if ${name} then")
        if needScale then
            content = sformat("%s%s%s", content, lineS, "${t}${name}:setScale(${scale})")
        end
        if needCount then
            content = sformat("%s%s%s", content, lineS,
[[${t}local counting = 0 
${t}${t}GUI:Effect_addOnCompleteEvent(${name}, function()
${t}${t}${t}counting = counting + 1
${t}${t}${t}if counting == ${count} then
${t}${t}${t}${t}GUI:Effect_Stop(${name})
${t}${t}${t}${t}GUI:setVisible(${name}, false)
${t}${t}${t}end
${t}${t}end]])
        end
        content = sformat("%s%s%s", content, lineS, "end")
    end

    content = replace(content, {parent = parent, ID = id, x = x, y = y, name = name, effecttype = effecttype,
        effectid = effectid, act = act, sex = sex, dir = dir, speed = speed, scale = scale, count = count})

    return content
end

function TxtTranslator:load_render_Frames(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local prefix            = element.attr.prefix or ""
    local suffix            = element.attr.suffix or ""
    local speed             = tonumber(element.attr.speed) or 100
    local count             = tonumber(element.attr.count) or 1
    local loop              = tonumber(element.attr.loop) or -1
    local finishframe       = tonumber(element.attr.finishframe) or "nil"
    local finishhide        = tonumber(element.attr.finishhide)
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0
    -- 逻辑差别
    prefix                  = string.format(getResFullPath("res/%s"), prefix)
    speed                   = speed * 10
    count                   = count > 0 and count - 1 or count
        
    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Frames_Create(${parent}, "${ID}", ${x}, ${y}, "${prefix}", "${suffix}", 1, ${finishframe}, ${ext})]],
        {name = name, parent = parent, ID = id, x = x, y = y, prefix = prefix, suffix = suffix, finishframe = finishframe,
        ext = {speed = speed, count = count, loop = loop, finishhide = finishhide}})

    return content
end

function TxtTranslator:load_render_Input(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local inputid           = element.attr.inputid
    local inputtype         = tonumber(element.attr.type) or 0
    local text              = element.attr.text or ""
    local place             = element.attr.place
    local placecolor        = element.attr.placecolor or defaultColorID
    local width             = element.attr.width
    local height            = element.attr.height
    local color             = element.attr.color or defaultColorID
    local size              = element.attr.size or defaultFontSize
    local mincount          = element.attr.mincount
    local maxcount          = tonumber(element.attr.maxcount) or 10000
    local errortips         = element.attr.errortips
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local linkType          = tonumber(element.attr.linkType) or 1
    local link              = element.attr.link
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0
    local fontPath          = global.MMO.PATH_FONT2

    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = [[local ${name} = GUI:TextInput_Create(${parent}, "${ID}", ${x}, ${y}, ${width}, ${height}, ${size})
${t}GUI:TextInput_setFontColor(${name}, "${fontColor}")
${t}GUI:TextInput_setFont(${name}, "${fontPath}", ${size})
${t}GUI:TextInput_setString(${name}, "${text}")]]
    if place then
        content = sformat("%s%s%s", content, lineS, [[GUI:TextInput_setPlaceHolder(${name}, "${place}")
${t}GUI:TextInput_setPlaceholderFontColor(${name}, "${placeColor}")
${t}GUI:TextInput_setPlaceholderFontSize(${name}, ${size})]])
    end
        
    content = sformat("%s%s%s", content, lineS, [[GUI:TextInput_setTextHorizontalAlignment(${name}, 0)
${t}GUI:TextInput_setMaxLength(${name}, ${maxcount})]])

    -- 输入类型
    if inputtype == 1 then
        content = sformat("%s%s%s", content, lineS, [[GUI:TextInput_setInputMode(${name}, 2)]])
    elseif inputtype == 2 then
        content = sformat("%s%s%s", content, lineS, [[GUI:TextInput_setInputMode(${name}, 0)]])
    end

    content = replace(content, {name = name, width = width, height = height, fontColor = GET_COLOR_BYID(tonumber(color)), fontPath = fontPath,
        parent = parent, ID = id, x = x, y = y, size = tonumber(size), text = text, place = place or "", 
        placeColor = GET_COLOR_BYID(tonumber(placecolor)), maxcount = maxcount, t = tabS})
    
    return content
end

function TxtTranslator:load_render_COUNTDOWN(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local time              = tonumber(element.attr.time) or 10
    local count             = tonumber(element.attr.count) or 1
    local color             = tonumber(element.attr.color) or defaultColorID
    local size              = tonumber(element.attr.size) or defaultFontSize
    local showWay           = tonumber(element.attr.showWay) or 0
    local link              = element.attr.link
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0
    local showStr           = showWay == 1 and TimeFormatToString(time) or sformat("%s秒", time)
   
    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Text_Create(${parent}, "${ID}", ${x}, ${y}, ${size}, "${color}", "${str}")]], 
        {name = name, size = size, color = GET_COLOR_BYID(color), str = showStr, parent = parent, ID = id, x = x, y = y})

    content = sformat("%s%s%s", content, lineS, replace([[local counting = 0
${t}local remaining = ${time}
${t}local function callback()]], {t = tabS, time = time}))
    if showWay == 1 then
        content = sformat("%s%s%s", content, lineS, sformat("%sGUI:Text_setString(%s, SL:TimeFormatToStr(remaining))", tabS, name))
    else
        content = sformat("%s%s%s", content, lineS, sformat("%sGUI:Text_setString(%s, remaining .. \"秒\")", tabS, name))
    end
    content = sformat("%s%s%s", content, lineS, replace([[${t}remaining = remaining - 1
${t}${t}if remaining < 0 then
${t}${t}${t}counting  = counting + 1
${t}${t}${t}if counting >= ${count} then
${t}${t}${t}${t}GUI:stopAllActions(${name})
${t}${t}${t}end
${t}${t}end
${t}end
${t}SL:schedule(${name}, callback, 1)
${t}callback()]], {name = name, count = count, t = tabS}))

    return content
end

function TxtTranslator:load_render_ItemShow(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local itemid            = tonumber(element.attr.itemid)  or 1
    local itemcount         = tonumber(element.attr.itemcount) or 1
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local lock              = tonumber(element.attr.lock) or 0
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local countColor        = tonumber(element.attr.color) or defaultColorID
    local effectshow        = tonumber(element.attr.effectshow) or 1
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local contentSize       = cc.size(66, 66)
    
    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Widget_Create(${parent}, "${ID}", ${x}, ${y}, ${width}, ${height})]], {name = name, parent = parent, ID = id, x = x, y = y,
        width = contentSize.width, height = contentSize.height})
 
    local infoStr = [[local info = {}
${t}info.index = ${itemid}
${t}info.look = ${isShowtips}]]

    if not (showtips == 1) and global.isWinPlayMode then
        infoStr = sformat("%s%s%s", infoStr, lineS, "info.noMouseTips = true")
    end
    if effectshow == 2 then
        infoStr = sformat("%s%s%s", infoStr, lineS, "info.showModelEffect = true")
    elseif effectshow == 0 then
        infoStr = sformat("%s%s%s", infoStr, lineS, "info.isShowEff = false")
    end

    infoStr = sformat("%s%s%s", infoStr, lineS, [[info.count = ${itemcount}
${t}info.bgVisible = ${bgVisible}
${t}info.color = ${countColor}
${t}local item = GUI:ItemShow_Create(${name}, "${ID}", ${posX}, ${posY}, info)
${t}GUI:setAnchorPoint(item, 0.50, 0.50)
${t}GUI:setScale(item, ${scale})
${t}GUI:ItemShow_setIconGrey(item, ${isGrey})]])

    content = sformat("%s%s%s", content, lineS, replace(infoStr, {name = name, itemid = itemid, isShowtips = showtips == 1, itemcount = itemcount,
        bgVisible = bgtype == 1, countColor = countColor, posX = contentSize.width / 2, posY = contentSize.height / 2,
        scale = scale, isGrey = grey == 1, ID = id, t = tabS}))

    if lock == 1 then
        content = sformat("%s%s%s", content, lineS, replace([[local imageLock = GUI:Image_Create(${name}, "${ID}", 0, GUI:getContentSize(${name}).height, "${lockPath}")]], {name = name, lockPath = global.MMO.PATH_RES_PUBLIC .. "lock.png", ID = "lock_" .. id}))
        content = sformat("%s%s%s", content, lineS, "GUI:setAnchorPoint(imageLock, 0.00, 1.00)")
        if global.isWinPlayMode then
            content = sformat("%s%s%s", content, lineS, "GUI:setScale(imageLock, 0.7)")
        end
    end
    
    return content
end

function TxtTranslator:load_render_DBItemShow(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local makeindex         = tonumber(element.attr.makeindex)  or 1
    local showtips          = tonumber(element.attr.showtips) or 1
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local count             = tonumber(element.attr.count)
    local link              = element.attr.link
    local effectshow        = tonumber(element.attr.effectshow) or 1 -- 1只显示背包 2只显示内观 0不显示
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local contentSize       = cc.size(66, 66)

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Widget_Create(${parent}, "${ID}", ${x}, ${y}, ${width}, ${height})]], {name = name, parent = parent, ID = id, x = x, y = y,
        width = contentSize.width, height = contentSize.height})
 
    local infoStr = [[local itemData = SL:GetMetaValue("EQUIP_DATA_BY_MAKEINDEX", ${makeindex})
${t}if not itemData then
${t}${t}itemData = SL:GetMetaValue("ITEM_DATA_BY_MAKEINDEX", ${makeindex})
${t}end
${t}if not itemData then
${t}${t}itemData = SL:GetMetaValue("QUICKUSE_DATA_BY_MAKEINDEX", ${makeindex})
${t}end
${t}if not itemData then
${t}${t}itemData = SL:GetMetaValue("LOOKPLAYER_DATA_BY_MAKEINDEX", ${makeindex})
${t}end
${t}if itemData then
${t}${t}local info = {}
${t}${t}info.index = itemData.Index
${t}${t}info.itemData = itemData
${t}${t}info.look = ${isShowtips}]]

    if not (showtips == 1) and global.isWinPlayMode then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.noMouseTips = true")
    end
    if effectshow == 2 then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.showModelEffect = true")
    elseif effectshow == 0 then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.isShowEff = false")
    end

    infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, [[info.bgVisible = ${bgVisible}
${t}${t}info.starLv = ${showstar}
${t}${t}local item = GUI:ItemShow_Create(${name}, "${ID}", ${posX}, ${posY}, info)
${t}${t}GUI:setAnchorPoint(item, 0.50, 0.50)
${t}${t}GUI:setScale(item, ${scale})
${t}${t}GUI:ItemShow_setIconGrey(item, ${isGrey})]])

    if count then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, sformat("GUI:ItemShow_OnRunFunc(item, \"SetCount\", %s)", count))
    end
    infoStr = sformat("%s%s%s", infoStr, lineS, "end")


    content = sformat("%s%s%s", content, lineS, replace(infoStr, {name = name, makeindex = makeindex, isShowtips = showtips == 1,
        bgVisible = bgtype == 1, showstar = showstar, posX = contentSize.width / 2, posY = contentSize.height / 2,
        scale = scale, isGrey = grey == 1, ID = id, t = tabS}))
    
    return content
end

function TxtTranslator:load_render_ITEMBOX(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local width             = tonumber(element.attr.width) or 1
    local height            = tonumber(element.attr.height) or 1
    local boxindex          = tonumber(element.attr.boxindex)
    local img               = element.attr.img
    local stdmode           = element.attr.stdmode
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0


    local img       = SUIHelper.fixImageFileName(img)
    local fullPath  = string.format(getResFullPath("res/%s"), img)
    
    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode

    local stdmodeStr = stdmode
    if string.find(stdmode, ",") then
        local slices = string.split(stdmode, ",")
        stdmodeStr = slices
    elseif stdmode == "*" then
        stdmodeStr = "\"*\""
    end

    local content = replace([[local ${name} = GUI:ItemBox_Create(${parent}, "${ID}", ${x}, ${y}, "${fullPath}", ${boxindex}, ${stdmode})]],
        {name = name, parent = parent, ID = id, x = x, y = y, fullPath = fullPath, boxindex = boxindex, stdmode = stdmodeStr})

    return content
end

function TxtTranslator:load_render_EquipShow(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local index             = tonumber(element.attr.index) or 0
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local link              = element.attr.link
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0
    local effectshow        = tonumber(element.attr.effectshow) or 1

    local contentSize       = cc.size(66, 66)
    
    local name = swidget.name
    local id   = swidget.id
    local parent  = ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Widget_Create(${parent}, "${ID}", ${x}, ${y}, ${width}, ${height})]], {name = name, parent = parent, ID = id, x = x, y = y,
        width = contentSize.width, height = contentSize.height})
 
    local infoStr = [[local equipData = SL:GetMetaValue("EQUIP_DATA", ${index})
${t}if equipData then
${t}${t}local info = {}
${t}${t}info.index = equipData.Index
${t}${t}info.itemData = equipData
${t}${t}info.look = ${isShowtips}]]

    if not (showtips == 1) and global.isWinPlayMode then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.noMouseTips = true")
    end
    if effectshow == 2 then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.showModelEffect = true")
    elseif effectshow == 0 then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.isShowEff = false")
    end

    infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, [[info.bgVisible = ${bgVisible}
${t}${t}info.starLv = ${showstar}
${t}${t}local item = GUI:ItemShow_Create(${name}, "${ID}", ${posX}, ${posY}, info)
${t}${t}GUI:setAnchorPoint(item, 0.50, 0.50)
${t}${t}GUI:setScale(item, ${scale})
${t}${t}GUI:ItemShow_setIconGrey(item, ${isGrey})
${t}end]])

    content = sformat("%s%s%s", content, lineS, replace(infoStr, {name = name, index = index, isShowtips = showtips == 1,
        bgVisible = bgtype == 1, showstar = showstar, posX = contentSize.width / 2, posY = contentSize.height / 2,
        scale = scale, isGrey = grey == 1, ID = id, t = tabS}))   
    
    return content
end

function TxtTranslator:load_render_BAGITEMS(swidget, callback, closeCB, ext)
    local element               = swidget.element
    local condition             = element.attr.condition or ""
    local exclude               = element.attr.exclude or ""
    local select                = element.attr.select or ""
    local count                 = tonumber(element.attr.count) or 12
    local row                   = tonumber(element.attr.row) or 2
    local selecttype            = tonumber(element.attr.selecttype) or 0
    local showstar              = tonumber(element.attr.showstar) == 1
    local iwidth                = tonumber(element.attr.iwidth) or 70
    local iheight               = tonumber(element.attr.iheight) or 70
    local iimg                  = element.attr.iimg
    local filter1               = element.attr.fliter1 or element.attr.filter1 or ""
    local filter2               = element.attr.fliter2 or element.attr.filter2 or ""
    local filter3               = element.attr.fliter3 or element.attr.filter3 or ""
    local link                  = element.attr.link
    local conditionEx           = element.attr.conditionEx
    local conditionParam        = element.attr.conditionParam
    local conditionOnOff        = tonumber(element.attr.conditionOnOff) or 0 
    local condition2            = element.attr.condition2
    local x                     = tonumber(element.attr.x) or 0
    local y                     = tonumber(element.attr.y) or 0
    local effectshow            = tonumber(element.attr.effectshow) or 1
    local exBind                = tonumber(element.attr.exbind) == 1
    local showtips              = (tonumber(element.attr.showtips) or 0) == 1

    -- 是否满足显示条件
    local conditionT            = {}
    local slices1               = ssplit(condition, ",")
    local slices2               = {}
    for _, v in pairs(slices1) do
        slices2                 = ssplit(v, "#")
        tinsert(conditionT, {StdMode = tonumber(slices2[1]), Shape = tonumber(slices2[2])})
    end
    -- 唯一ID过滤
    local excludeT              = {}
    local slices                = ssplit(exclude, ",")
    for _, v in pairs(slices) do
        tinsert(excludeT, tonumber(v))
    end
    
    -- 道具ID过滤，存在不显示
    local filter1T              = {}
    local slices                = ssplit(filter1, ",")
    for _, v in pairs(slices) do
        tinsert(filter1T, tonumber(v))
    end
    
    -- 道具名过滤，存在不显示
    local filter2T              = {}
    local slices                = ssplit(filter2, ",")
    for _, v in pairs(slices) do
        if v ~= "" then
            tinsert(filter2T, v)
        end
    end

    -- 道具ID过滤，存在才显示
    local filter3T              = {}
    local slices                = ssplit(filter3, ",")
    for _, v in pairs(slices) do
        if v ~= "" then
            tinsert(filter3T, v)
        end
    end

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode

    iimg = (iimg and iimg ~= "") and SUIHelper.fixImageFileName(iimg) or "public/1900000664.png"
    local itemParam = {
        width       = iwidth,
        height      = iheight,
        imgBg       = string.format(getResFullPath("res/%s"), iimg),
        showtips    = showtips,
        effectshow  = effectshow
    }

    local conditionList = {
        conditionEx = conditionEx,
        conditionOnOff = conditionOnOff,
        conditionParam = conditionParam,
        condition = condition == "*" and condition or conditionT,
        condition2 = condition2,
        exclude = excludeT,
        filter1 = filter1T,
        filter2 = filter2T,
        filter3 = filter3T,
        exBind  = exBind,
    } 

    local content = replace([[local ${name} = GUI:BAGITEMS_Create(${parent}, "${ID}", ${x}, ${y}, ${conditionList}, ${count}, ${row}, ${showstar}, ${itemParam})]],
    {name = name, parent = parent, ID = id, x = x, y = y, conditionList = conditionList, count = count, row = row, showstar = showstar, itemParam = itemParam})

    return content
end

function TxtTranslator:load_render_EQUIPITEMS(swidget, callback, closeCB, ext)
    local element               = swidget.element
    local positions             = element.attr.positions or "*"
    local select                = element.attr.select or ""
    local count                 = tonumber(element.attr.count) or 12
    local row                   = tonumber(element.attr.row) or 2
    local selecttype            = tonumber(element.attr.selecttype) or 0
    local showstar              = tonumber(element.attr.showstar) == 1
    local iwidth                = tonumber(element.attr.iwidth) or 70
    local iheight               = tonumber(element.attr.iheight) or 70
    local iimg                  = element.attr.iimg
    local link                  = element.attr.link
    local x                     = tonumber(element.attr.x) or 0
    local y                     = tonumber(element.attr.y) or 0
    local effectshow            = tonumber(element.attr.effectshow) or 1

    -- 装备位
    local equipPositions        = {}
    local slices                = ssplit(positions, ",")
    for _, v in ipairs(slices) do
        tinsert(equipPositions, tonumber(v))
    end
    positions = positions == "*" and "\"*\"" or equipPositions

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode

    iimg = (iimg and iimg ~= "") and SUIHelper.fixImageFileName(iimg) or "public/1900000664.png"
    local itemParam = {
        width   = iwidth,
        height  = iheight,
        imgBg   = string.format(getResFullPath("res/%s"), iimg),
        effectshow = effectshow
    }
    
    local content = replace([[local ${name} = GUI:EQUIPITEMS_Create(${parent}, "${ID}", ${x}, ${y}, ${positions}, ${count}, ${row}, ${showstar}, ${itemParam})]],
        {name = name, parent = parent, ID = id, x = x, y = y, positions = positions, count = count, row = row,
        itemParam = itemParam, showstar = showstar})

    return content
end

function TxtTranslator:load_render_TIMETIPS(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local size              = tonumber(element.attr.size) or defaultFontSize
    local color             = tonumber(element.attr.color) or defaultColorID
    local time              = tonumber(element.attr.time) or 0
    local outline           = tonumber(element.attr.outline) or defaultOutline
    local outlinecolor      = tonumber(element.attr.outlinecolor) or defaultOutlineC
    local link              = element.attr.link
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Text_Create(${parent}, "${ID}", ${x}, ${y}, ${size}, ${color}, "")]], 
        {name = name, size = size, color = GET_COLOR_BYID(color), parent = parent, ID = id, x = x, y = y})

    if outline > 0 then
        content = sformat("%s%s%s", content, lineS, sformat("GUI:Text_enableOutline(%s, \"%s\", %s)", name, GET_COLOR_BYID(outlinecolor), outline))
    end

    content = sformat("%s%s%s", content, lineS, sformat([[local endTime = time + SL:GetMetaValue("SERVER_TIME")
${t}local function callback()
${t}${t}local remaining = math.max(endTime - SL:GetMetaValue("SERVER_TIME"), 0)
${t}${t}GUI:Text_setString(${name}, SL:SecondToHMS(remaining, true))
${t}${t}if remaining <= 0 then
${t}${t}${t}-- link
${t}${t}${t}GUI:stopAllAction(${name})
${t}${t}end
${t}end
${t}SL:schedule((${name}, callback, 1)
${t}callback()]], {name = name, time = time, t = tabS}))

    return content
end

function TxtTranslator:load_render_LoadingBar(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local size              = tonumber(element.attr.size) or defaultFontSize
    local color             = tonumber(element.attr.color) or defaultColorID
    local outline           = tonumber(element.attr.outline) or defaultOutline
    local outlinecolor      = tonumber(element.attr.outlinecolor) or defaultOutlineC
    local direction         = tonumber(element.attr.direction) or 0   -- 0从左至右  1从右到左 
    local loadBgImg         = element.attr.loadingbg or "public/bg_szjm_03_1.png"
    local loadBarImg        = element.attr.loadingbar or "public/bg_szjm_03_2.png"
    local startPercent      = tonumber(element.attr.startper) or 0
    local interval          = tonumber(element.attr.interval) or 0.05
    local loadValue         = tonumber(element.attr.loadvalue) or 10
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local offsetX           = tonumber(element.attr.offsetX) or 0
    local offsetY           = tonumber(element.attr.offsetY) or 0

    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local imgBg             = SUIHelper.fixImageFileName(loadBgImg)
    local imgBar            = SUIHelper.fixImageFileName(loadBarImg)
    local fullPathBG        = (imgBg and imgBg ~= "") and string.format(getResFullPath("res/%s"), imgBg) or ""
    local fullPathBAR       = (imgBar and imgBar ~= "") and string.format(getResFullPath("res/%s"), imgBar) or ""  

    local name = swidget.name 
    local id   = swidget.id 
    local parent =  ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Image_Create(${parent}, "${ID}", ${x}, ${y}, "${fullPathBG}")]], 
        {name = name, ID = id, x = x, y = y, fullPathBG = fullPathBG, parent = parent})

    content = sformat("%s%s%s", content, lineS, sformat("local bgSize = GUI:getContentSize(%s)", name))
    local barId = id .. "_Bar"
    if fullPathBAR and fullPathBAR ~= "" and global.FileUtilCtl:isFileExist(fullPathBAR) then
        content = sformat("%s%s%s", content, lineS, replace([[local ${ID} = GUI:LoadingBar_Create(${name}, "${ID}", bgSize.width / 2 + ${offsetX}, bgSize.height / 2 + ${offsetY}, "${fullPathBAR}", ${direction})
${t}GUI:setAnchorPoint(${ID}, 0.50, 0.50)
${t}GUI:LoadingBar_setPercent(${ID}, ${startPercent})]], 
            {name = name, ID = barId, offsetX = tranNegNum(offsetX), offsetY = tranNegNum(offsetY), startPercent = startPercent, fullPathBAR = fullPathBAR, direction = direction, t = tabS})
        )

        local textId = id .. "_Text"
        content = sformat("%s%s%s", content, lineS, replace([[local ${ID} = GUI:Text_Create(${name}, "${ID}", bgSize.width / 2, bgSize.height / 2, ${size}, "${textColor}", "${perStr}")
${t}GUI:setAnchorPoint(${ID}, 0.50, 0.50)
${t}GUI:Text_enableOutline(${ID}, "${outlinecolor}", ${outline})]],
            {perStr = string.format("%s/%s", startPercent, 100), size = size, textColor = GET_COLOR_BYID(color),
            outlinecolor = GET_COLOR_BYID(outlinecolor), outline = outline, name = name, ID = textId, t = tabS})
        )

        content = sformat("%s%s%s", content, lineS, replace([[GUI:stopAllActions(${barId})
${t}local percent = ${startPercent}
${t}local function scheduleCB()
${t}${t}percent = percent + ${loadValue}
${t}${t}GUI:LoadingBar_setPercent(${barId}, percent)
${t}${t}local curPercent = math.floor(percent / 100 * 100)
${t}${t}GUI:Text_setString(${textId}, string.format("%s/%s", curPercent, 100))
${t}${t}if percent >= 100 then
${t}${t}${t}GUI:stopAllActions(${barId})
${t}${t}${t}-- link
${t}${t}end
${t}end
${t}SL:schedule(${barId}, scheduleCB, ${interval})
${t}scheduleCB()]], {startPercent = startPercent, loadValue = loadValue, interval = interval, barId = barId, textId = textId, t = tabS})
        )
    end
   

    return content
end

function TxtTranslator:load_render_CircleBar(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local loadBgImg         = element.attr.loadingbg or "private/sui/bg_xbzy_02.png" 
    local loadBarImg        = element.attr.loadingbar or "private/sui/bg_xbzy_03.png"
    local startPercent      = tonumber(element.attr.startper) or 0
    local endPercent        = tonumber(element.attr.endper) or 100
    local time              = tonumber(element.attr.time) or 1
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local offsetX           = element.attr.offsetX or 0
    local offsetY           = element.attr.offsetY or 0

    local imgBg             = SUIHelper.fixImageFileName(loadBgImg)
    local imgBar            = SUIHelper.fixImageFileName(loadBarImg)
    local fullPathBG        = (imgBg and imgBg ~= "") and string.format(getResFullPath("res/%s"), imgBg) or ""
    local fullPathBAR       = (imgBar and imgBar ~= "") and string.format(getResFullPath("res/%s"), imgBar) or "" 
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0 

    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:CircleBar_Create(${parent}, "${ID}", ${x}, ${y}, "${fullPathBG}", "${fullPathBAR}", ${startPercent}, ${endPercent}, ${time})
${t}GUI:CircleBar_setBarOffSet(${name}, ${offsetX}, ${offsetY})]], {name = name, fullPathBG = fullPathBG, fullPathBAR = fullPathBAR, offsetX = offsetX, offsetY = offsetY,
        startPercent = startPercent, time = time, endPercent = endPercent, parent = parent, ID = id, x = x, y = y})

    return content
end

function TxtTranslator:load_render_PercentImg(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local direction         = tonumber(element.attr.direction) or 0  -- 0 从左到右 1从右到左 2从上往下 3从下往上
    local loadImg           = element.attr.img or "public/bg_szjm_03_2.png"
    local minValue          = tonumber(element.attr.minValue) or 100
    local maxValue          = tonumber(element.attr.maxValue) or 100
    local percent           = math.floor(minValue / maxValue * 100) or 100
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local img               = SUIHelper.fixImageFileName(loadImg)
    local fullPath          = (img and img ~= "") and string.format(getResFullPath("res/%s"), img) or ""
   
    local name = swidget.name
    local id   = swidget.id
    local parent =  ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:PercentImg_Create(${parent}, "${ID}", ${x}, ${y}, "${fullPath}", ${direction}, "${minValue}", "${maxValue}")]],
        {name = name, parent = parent, fullPath = fullPath, ID = id, x = x, y = y,
        direction = direction, minValue = element.attr.minValue or 100, maxValue = element.attr.maxValue or 100})

    return content

end

function TxtTranslator:load_render_UIModel(swidget,callback, closeCB, ext)
    local element           = swidget.element
    local sex               = tonumber(element.attr.sex) or 0 
    local scale             = tonumber(element.attr.scale) or 1
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local function parseEffectStr(str)
        if not str then
            return nil
        end
        return string.gsub(str, "&", "|")
    end

    local feature           = {}
    feature.clothID         = tonumber(element.attr.clothID)
    feature.weaponID        = tonumber(element.attr.weaponID)
    feature.headID          = tonumber(element.attr.headID)
    feature.headEffectID    = parseEffectStr(element.attr.headEffectID)
    feature.weaponEffectID  = parseEffectStr(element.attr.weaponEffectID)
    feature.clothEffectID   = parseEffectStr(element.attr.clothEffectID)
    feature.capID           = tonumber(element.attr.capID)
    feature.shieldID        = tonumber(element.attr.shieldID)
    feature.shieldEffectID  = parseEffectStr(element.attr.shieldEffectID)
    feature.tDressID        = tonumber(element.attr.tDressID)
    feature.tDressEffectID  = parseEffectStr(element.attr.tDressEffectID)
    feature.tWeaponID       = tonumber(element.attr.tWeaponID)
    feature.tWeaponEffectID = parseEffectStr(element.attr.tWeaponEffectID)
    feature.capEffectID     = parseEffectStr(element.attr.capEffectID)
    feature.veilID          = tonumber(element.attr.veilID)
    feature.veilEffectID    = parseEffectStr(element.attr.veilEffectID)
    feature.hairID          = tonumber(element.attr.hairID)
    feature.notShowMold     = element.attr.notShowMold
    feature.notShowHair     = element.attr.notShowHair

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:UIModel_Create(${parent}, "${ID}", ${x}, ${y}, ${sex}, ${feature}, ${scale})]], 
        {name = name, parent = parent, ID = id, x = x, y = y, sex = sex, feature = feature, scale = scale})

    return content
end

---- 英雄相关
function TxtTranslator:load_render_HEROEquipShow(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local index             = tonumber(element.attr.index) or 0
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local link              = element.attr.link
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0
    local effectshow        = tonumber(element.attr.effectshow) or 1

    local contentSize       = cc.size(66,66)
    
    local name = swidget.name
    local id   = swidget.id
    local parent  =  ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Widget_Create(${parent}, "${ID}", ${x}, ${y}, ${width}, ${height})]], {name = name, parent = parent, ID = id, x = x, y = y,
    width = contentSize.width, height = contentSize.height})

    local infoStr = [[local equipData = SL:GetMetaValue("H.EQUIP_DATA", ${index})
${t}if equipData then
${t}${t}local info = {}
${t}${t}info.index = equipData.Index
${t}${t}info.itemData = equipData
${t}${t}info.look = ${isShowtips}]]

    if not (showtips == 1) and global.isWinPlayMode then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.noMouseTips = true")
    end
    if effectshow == 2 then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.showModelEffect = true")
    elseif effectshow == 0 then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.isShowEff = false")
    end

    infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, [[info.bgVisible = ${bgVisible}
${t}${t}info.starLv = ${showstar}
${t}${t}local item = GUI:ItemShow_Create(${name}, "${ID}", ${posX}, ${posY}, info)
${t}${t}GUI:setAnchorPoint(item, 0.50, 0.50)
${t}${t}GUI:setScale(item, ${scale})
${t}${t}GUI:ItemShow_setIconGrey(item, ${isGrey})
${t}end]])

    content = sformat("%s%s%s", content, lineS, replace(infoStr, {name = name, index = index, isShowtips = showtips == 1,
        bgVisible = bgtype == 1, showstar = showstar, posX = contentSize.width / 2, posY = contentSize.height / 2,
        scale = scale, isGrey = grey == 1, ID = id, t = tabS}))   
    
    return content
end

function TxtTranslator:load_render_HEROEQUIPITEMS(swidget, callback, closeCB, ext)
    local element               = swidget.element
    local positions             = element.attr.positions or "*"
    local select                = element.attr.select or ""
    local count                 = tonumber(element.attr.count) or 12
    local row                   = tonumber(element.attr.row) or 2
    local selecttype            = tonumber(element.attr.selecttype) or 0
    local showstar              = tonumber(element.attr.showstar) == 1
    local iwidth                = tonumber(element.attr.iwidth) or 70
    local iheight               = tonumber(element.attr.iheight) or 70
    local iimg                  = element.attr.iimg
    local link                  = element.attr.link
    local x                     = tonumber(element.attr.x) or 0
    local y                     = tonumber(element.attr.y) or 0
    local effectshow            = tonumber(element.attr.effectshow) or 1

    -- 装备位
    local equipPositions        = {}
    local slices                = ssplit(positions, ",")
    for _, v in ipairs(slices) do
        tinsert(equipPositions, tonumber(v))
    end
    positions = positions == "*" and "\"*\"" or equipPositions

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode

    iimg = (iimg and iimg ~= "") and SUIHelper.fixImageFileName(iimg) or "public/1900000664.png"
    local itemParam = {
        width   = iwidth,
        height  = iheight,
        imgBg   = string.format(getResFullPath("res/%s"), iimg),
        effectshow = effectshow
    }
    
    local content = replace([[local ${name} = GUI:EQUIPITEMS_Create(${parent}, "${ID}", ${x}, ${y}, ${positions}, ${count}, ${row}, ${showstar}, ${itemParam}, true)]], 
        {name = name, parent = parent, ID = id, x = x, y = y, positions = positions, count = count, row = row,
        itemParam = itemParam, showstar = showstar})

    return content
end

function TxtTranslator:load_render_HERODBItemShow(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local makeindex         = tonumber(element.attr.makeindex)  or 1
    local showtips          = tonumber(element.attr.showtips) or 1
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local count             = tonumber(element.attr.count)
    local link              = element.attr.link
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0
    local effectshow        = tonumber(element.attr.effectshow) or 1

    local contentSize       = cc.size(66, 66)

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = replace([[local ${name} = GUI:Widget_Create(${parent}, "${ID}", ${x}, ${y}, ${width}, ${height})]], {name = name, parent = parent, ID = id, x = x, y = y,
        width = contentSize.width, height = contentSize.height})
 
    local infoStr = [[local itemData = SL:GetMetaValue("EQUIP_DATA_BY_MAKEINDEX", ${makeindex}, true)
${t}if not itemData then
${t}${t}itemData = SL:GetMetaValue("ITEM_DATA_BY_MAKEINDEX", ${makeindex}, true)
${t}end
${t}if not itemData then
${t}${t}itemData = SL:GetMetaValue("LOOKPLAYER_DATA_BY_MAKEINDEX", ${makeindex})
${t}end
${t}if itemData then
${t}${t}local info = {}
${t}${t}info.index = itemData.Index
${t}${t}info.itemData = itemData
${t}${t}info.look = ${isShowtips}]]

    if not (showtips == 1) and global.isWinPlayMode then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.noMouseTips = true")
    end
    if effectshow == 2 then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.showModelEffect = true")
    elseif effectshow == 0 then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, "info.isShowEff = false")
    end

    infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, [[info.bgVisible = ${bgVisible}
${t}${t}info.starLv = ${showstar}
${t}${t}local item = GUI:ItemShow_Create(${name}, "${ID}", ${posX}, ${posY}, info)
${t}${t}GUI:setAnchorPoint(item, 0.50, 0.50)
${t}${t}GUI:setScale(item, ${scale})
${t}${t}GUI:ItemShow_setIconGrey(item, ${isGrey})]])

    if count then
        infoStr = sformat("%s%s%s", infoStr, lineS .. tabS, sformat("GUI:ItemShow_OnRunFunc(item, \"SetCount\", %s)", count))
    end
    infoStr = sformat("%s%s%s", infoStr, lineS, "end")


    content = sformat("%s%s%s", content, lineS, replace(infoStr, {name = name, makeindex = makeindex, isShowtips = showtips == 1,
        bgVisible = bgtype == 1, showstar = showstar, posX = contentSize.width / 2, posY = contentSize.height / 2,
        scale = scale, isGrey = grey == 1, ID = id, t = tabS}))

    return content
end

function TxtTranslator:load_render_HEROBAGITEMS(swidget, callback, closeCB, ext)
    local element               = swidget.element
    local condition             = element.attr.condition or ""
    local exclude               = element.attr.exclude or ""
    local select                = element.attr.select or ""
    local count                 = tonumber(element.attr.count) or 12
    local row                   = tonumber(element.attr.row) or 2
    local selecttype            = tonumber(element.attr.selecttype) or 0
    local showstar              = tonumber(element.attr.showstar) == 1
    local iwidth                = tonumber(element.attr.iwidth) or 70
    local iheight               = tonumber(element.attr.iheight) or 70
    local iimg                  = element.attr.iimg
    local filter1               = element.attr.fliter1 or element.attr.filter1 or ""
    local filter2               = element.attr.fliter2 or element.attr.filter2 or ""
    local filter3               = element.attr.fliter3 or element.attr.filter3 or ""
    local link                  = element.attr.link
    local conditionEx           = element.attr.conditionEx
    local conditionParam        = element.attr.conditionParam
    local conditionOnOff        = tonumber(element.attr.conditionOnOff) or 0 
    local x                     = tonumber(element.attr.x) or 0
    local y                     = tonumber(element.attr.y) or 0
    local effectshow            = tonumber(element.attr.effectshow) or 1

    -- 是否满足显示条件
    local conditionT            = {}
    local slices1               = ssplit(condition, ",")
    local slices2               = {}
    for _, v in pairs(slices1) do
        slices2                 = ssplit(v, "#")
        tinsert(conditionT, {StdMode = tonumber(slices2[1]), Shape = tonumber(slices2[2])})
    end
    -- 唯一ID过滤
    local excludeT              = {}
    local slices                = ssplit(exclude, ",")
    for _, v in pairs(slices) do
        tinsert(excludeT, tonumber(v))
    end
    
    -- 道具ID过滤，存在不显示
    local filter1T              = {}
    local slices                = ssplit(filter1, ",")
    for _, v in pairs(slices) do
        tinsert(filter1T, tonumber(v))
    end
    
    -- 道具名过滤，存在不显示
    local filter2T              = {}
    local slices                = ssplit(filter2, ",")
    for _, v in pairs(slices) do
        if v ~= "" then
            tinsert(filter2T, v)
        end
    end

    -- 道具ID过滤，存在才显示
    local filter3T              = {}
    local slices                = ssplit(filter3, ",")
    for _, v in pairs(slices) do
        if v ~= "" then
            tinsert(filter3T, v)
        end
    end

    local name = swidget.name
    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode

    iimg = (iimg and iimg ~= "") and SUIHelper.fixImageFileName(iimg) or "public/1900000664.png"
    local itemParam = {
        width = iwidth,
        height = iheight,
        imgBg  = string.format(getResFullPath("res/%s"), iimg),
        effectshow  = effectshow
    }

    local conditionList = {
        conditionEx = conditionEx,
        conditionOnOff = conditionOnOff,
        conditionParam = conditionParam,
        condition = condition == "*" and "\"*\"" or conditionT,
        exclude = excludeT,
        filter1 = filter1T,
        filter2 = filter2T,
        filter3 = filter3T,
    } 

    local content = replace([[local ${name} = GUI:BAGITEMS_Create(${parent}, "${ID}", ${x}, ${y}, ${conditionList}, ${count}, ${row}, ${showstar}, ${itemParam}, true)]],
        {name = name, parent = parent, ID = id, x = x, y = y, conditionList = conditionList, count = count, row = row, showstar = showstar, itemParam = itemParam})


    return content
end

function TxtTranslator:load_render_RTextX(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local text              = element.attr.text or ""
    local size              = tonumber(element.attr.size) or defaultFontSize
    local color             = tonumber(element.attr.color) or defaultColorID
    local width             = tonumber(element.attr.width) or 1136
    local link              = element.attr.link
    local outline           = tonumber(element.attr.outline) or defaultOutline
    local outlinecolor      = tonumber(element.attr.outlinecolor) or defaultOutlineC
    local scrollWidth       = tonumber(element.attr.scrollWidth)
    local scrollWay         = tonumber(element.attr.scrollWay) or 0         -- 0 从右到左 1 从下到上
    local scrollTime        = tonumber(element.attr.scrollTime) or 4
    local scrollHeight      = tonumber(element.attr.scrollHeight)
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0
    local colorHex          = GET_COLOR_BYID(color)
    local vspace            = SL:GetMetaValue("GAME_DATA", "DEFAULT_VSPACE")

    local outlineParam = {
        outlineSize = outline,
        outlineColor = GET_COLOR_BYID_C3B(outlinecolor)
    }
    
    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = ""
    if scrollWidth then
        swidget.realname = "scrollLayout_" .. id
        content = sformat("%s%s%s",
        sformat("local %s = GUI:Layout_Create(%s, \"%s\", %s, %s, %s, 0, true)", swidget.realname, parent, id, x, y, scrollWidth),
        lineS,
        sformat("local %s = GUI:RichText_Create(%s, \"%s\", 0, 0, \"%s\", %s, %s, \"%s\", %s)",
            name, swidget.realname, id, text, width, size, colorHex, vspace)
        )
        -- size 
        content = sformat("%s%s%s", content, lineS, sformat("local widgetSize = GUI:getContentSize(%s)", name))
        if scrollHeight then
            content = sformat("%s%s%s", content, lineS, sformat("local scrollH = %s", scrollHeight))
        else
            content = sformat("%s%s%s", content, lineS, "local scrollH = widgetSize.height")
        end
        content = sformat("%s%s%s", content, lineS, sformat("GUI:setContentSize(%s, %s, scrollH)", swidget.realname, scrollWidth))

    else
        content = sformat("local %s = GUI:RichText_Create(%s, \"%s\", 0, 0, \"%s\", %s, %s, \"%s\", %s)", name, parent, id, text, width, size, colorHex, vspace)
    end

    -- auto scroll
    if scrollWidth then
        if scrollWay == 0 then
            content = sformat("%s%s%s", content, lineS, [[GUI:setAnchorPoint(${name}, 0.00, 0.00)
${t}GUI:setPosition(${name}, 0, 0)
${t}GUI:runAction(${name}, GUI:ActionRepeatForever(GUI:ActionSequence(
${t}${t}GUI:ActionMoveBy(${scrollTime}, - widgetSize.width, 0), 
${t}${t}GUI:ActionMoveBy(0, widgetSize.width, 0))))]])
           
        elseif scrollWay == 1 then
            content = sformat("%s%s%s", content, lineS, [[GUI:setAnchorPoint(${name}, 0.00, 1.00)
${t}GUI:setPosition(${name}, 0, scrollH)
${t}GUI:runAction(${name}, GUI:ActionRepeatForever(GUI:ActionSequence(
${t}${t}GUI:ActionMoveBy(${scrollTime}, 0, widgetSize.height), 
${t}${t}GUI:ActionMoveBy(0, 0, - widgetSize.height))))]])

        end

        content = replace(content, {
            name = name, scrollTime = scrollTime, t = tabS
        })
        
        return content
    end

    return content
end

function TxtTranslator:load_render_PageView(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local width             = element.attr.width or 200
    local height            = element.attr.height or 200
    local color             = tonumber(element.attr.color)
    local default           = tonumber(element.attr.default)
    local cantouch          = tonumber(element.attr.cantouch) or 1
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = sformat("local %s = GUI:PageView_Create(%s, \"%s\", %s, %s, %s, %s)", name, parent, id, x, y, width, height)


    -- color
    if color then
        content = sformat("%s%s%s", content, lineS, replace([[GUI:PageView_setBackGroundColorType(${name}, 1)
${t}GUI:PageView_setBackGroundColor(${name}, "${colorHex}")
${t}GUI:PageView_setBackGroundColorOpacity(${name}, 255)]], {colorHex = GET_COLOR_BYID(color), name = name, t = tabS}))
    end

    if cantouch == 0 then
        content = sformat("%s%s%s", content, lineS, sformat("GUI:setTouchEnabled(%s, false)", name))
    end
    
    return content
end

function TxtTranslator:load_render_Slider(swidget, callback, closeCB, ext)
    local element       = swidget.element
    local sliderid      = element.attr.sliderid
    local ballPath      = element.attr.ballimg or "public/bg_szjm_02_1.png"
    local barPath       = element.attr.barimg or "public/bg_szjm_02.png"
    local bgPath        = element.attr.bgimg or "public/bg_szjm_01.png" 
    local default       = tonumber(element.attr.defvalue) or 0
    local maxValue      = tonumber(element.attr.maxvalue) or 100
    local link          = element.attr.link
    local x             = tonumber(element.attr.x) or 0
    local y             = tonumber(element.attr.y) or 0
    local defaultPer    = mfloor(default)
    ballPath            = string.format(getResFullPath("res/%s"), SUIHelper.fixImageFileName(ballPath))
    barPath             = string.format(getResFullPath("res/%s"), SUIHelper.fixImageFileName(barPath))
    bgPath              = string.format(getResFullPath("res/%s"), SUIHelper.fixImageFileName(bgPath))

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode

    local content = sformat("local %s = GUI:Slider_Create(%s, \"%s\", %s, %s, \"%s\", \"%s\", \"%s\")", 
        name, parent, id, x, y, bgPath, barPath, ballPath)

    content = sformat("%s%s%s", content, lineS, sformat("GUI:Slider_setMaxPercent(%s, %s)", name, maxValue))
    content = sformat("%s%s%s", content, lineS, sformat("GUI:Slider_setPercent(%s, %s)", name, defaultPer))

    return content
end

function TxtTranslator:load_render_ScrapePic(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local showImg           = element.attr.showimg                          -- 展示图片
    local maskImg           = element.attr.maskimg or "public/mask_1.png"   -- 遮罩图片
    local clearHei          = tonumber(element.attr.clearhei) or 16         -- 刮除高度
    local moveTime          = tonumber(element.attr.movetime) or 5          -- 移动时间
    local beginTime         = tonumber(element.attr.begintime)              -- 开始按下时间
    local link              = element.attr.link
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    local path              = SUIHelper.fixImageFileName(showImg)
    local showPath          = (path and path ~= "") and string.format(getResFullPath("res/%s"), path) or ""
    local path              = SUIHelper.fixImageFileName(maskImg)
    local maskPath          = (path and path ~= "") and string.format(getResFullPath("res/%s"), path)

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = sformat("local %s = GUI:ScrapePic_Create(%s, \"%s\", %s, %s, \"%s\", \"%s\", %s, %s%s)",
        name, parent, id, x, y, showPath, maskPath, clearHei, moveTime, beginTime and sformat(", %s", beginTime) or "")
    
    return content
end

function TxtTranslator:load_render_BmpText(swidget, callback, closeCB, ext)
    local element           = swidget.element
    local text              = element.attr.text or ""
    local size              = tonumber(element.attr.size) or defaultFontSize
    local color             = tonumber(element.attr.color) or defaultColorID
    local link              = element.attr.link
    local clickInterval     = (tonumber(element.attr.clickInterval) or 0) * 0.001
    local tips              = element.attr.tips
    local tipsx             = tonumber(element.attr.tipsx) or 0
    local tipsy             = tonumber(element.attr.tipsy) or 0
    local tipWidth          = tonumber(element.attr.tipWidth) or 1136
    local x                 = tonumber(element.attr.x) or 0
    local y                 = tonumber(element.attr.y) or 0

    text = string.gsub(text, "\\", "\r\n")
    text = string.trim(text)

    local name = swidget.name
    local id   = swidget.id
    local parent = ext and ext.parent or noParentCode
    local content = sformat("local %s = GUI:BmpText_Create(%s, \"%s\", %s, %s, \"%s\", \"%s\")", name, parent, id, x, y, GET_COLOR_BYID(color), text)

    content = sformat("%s%s%s", content, lineS, sformat("GUI:Text_setFontSize(%s, %s)", name, size))

    return content
end

return TxtTranslator
