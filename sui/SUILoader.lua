--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
local SUILoader = class("SUILoader")

local Element       = require("sui/Element")
local SWidget       = require("sui/SWidget")
local SUIHelper     = require("sui/SUIHelper")
local LexicalHelper = require("sui/LexicalHelper")
local RichTextHelp  = require("util/RichTextHelp")
local QuickCell     = requireUtil("QuickCell")
local cjson         = require("cjson")

local tinsert       = table.insert
local tremove       = table.remove
local ssplit        = string.split
local sfind         = string.find

local mfloor        = math.floor

local DEBUG_MODE    = false

------------------------------------------ util
SUILoader.convertToDesignPos = function(swidget, input_pos)
    local parent        = swidget.render:getParent()
    local visibleSize   = global.Director:getVisibleSize()
    local parentSize    = parent and parent:getContentSize() or visibleSize

    local x             = tonumber(input_pos.x) or 0
    local y             = tonumber(input_pos.y) or 0
    local fixX          = x
    local fixY          = parentSize.height-y
    
    return cc.p(fixX, fixY)
end

SUILoader.convertToOpenGLPos = function(swidget, input_pos)
    local parent        = swidget.render:getParent()
    local visibleSize   = global.Director:getVisibleSize()
    local parentSize    = parent and parent:getContentSize() or visibleSize

    local x             = tonumber(input_pos.x) or 0
    local y             = tonumber(input_pos.y) or 0
    local fixX          = x
    local fixY          = parentSize.height-y
    
    return cc.p(fixX, fixY)
end

SUILoader.compareSWidget = function(a, b)
    if not a or not b then
        return 0
    end
    if #a.branches ~= #b.branches then
        return -5
    end

    local eleA = a.element
    local eleB = b.element
    if not eleA or not eleB then
        return -1
    end

    -- 类型不同
    if eleA.type ~= eleB.type then
        return -2
    end

    -- 重新加载
    local reloadA   = tonumber(eleA.attr.reload) or 0
    local reloadB   = tonumber(eleB.attr.reload) or 0
    if reloadB == 1 then
        return -6
    end
    if eleA.type == "Frames" then
        return -6
    end
    if eleA.type == "Effect" and (eleA.attr.count == 1 or eleB.attr.count == 1) then
        return -6
    end
    if eleA.type == "CheckBox" then
        return -6
    end
    if eleA.type == "COUNTDOWN" then
        return -6
    end
    if eleA.type == "BAGITEMS" or eleA.type == "HEROBAGITEMS" or eleA.type == "DLINKITEMS" then
        return -6
    end
    if eleA.type == "EQUIPITEMS" or eleA.type == "HEROEQUIPITEMS" then
        return -6
    end
    if eleA.type == "DBItemShow" or eleA.type == "HERODBItemShow" or eleA.type == "MKItemShow" then
        return -6
    end
    if eleA.type == "Input" then
        return -6
    end
    if eleA.type == "TIMETIPS" then
        return -6
    end
    if eleA.type == "LoadingBar" then
        return -6
    end
    if eleA.type == "Slider" then
        return -6
    end
    if eleA.type == "MenuItem" then
        return -6
    end
    if eleA.type == "ScrapePic" then
        return -6
    end

    local ignored   = {[1]="id", [2]="default", [3]="reload", [4]="loadCount", [5]="loadDelay", [6]="loadStep", [7]="tax", [8]="tay", [9]="tpercentx", [10]="tpercenty"}
    local attrA     = clone(eleA.attr)
    local attrB     = clone(eleB.attr)
    for _, v in ipairs(ignored) do
        attrA[v] = nil
        attrB[v] = nil
    end
    for key, value in pairs(attrA) do
        if not attrB[key] then
            -- 属性数量不同
            return -3
        end
        if value ~= attrB[key] then
            -- 属性值不同
            return -4
        end
        attrB[key] = nil
    end
    if next(attrB) then
        -- 属性数量不同
        return -3
    end

    -- 属性相同
    return 1
end

SUILoader.isBackground = function(swidget)
    if not swidget then
        return false
    end
    return tonumber(swidget.element.attr.bg) == 1
end
------------------------------------------
------------------------------------------

--
local defaultOutline    = 1
local defaultOutlineC   = 0
local defaultColorID    = 255
local defaultFontSize   = global.isWinPlayMode and 12 or 18
local anchorPoints      = {[0]={x=0,y=1}, [1]={x=1,y=1}, [2]={x=0,y=0}, [3]={x=1,y=0}, [4]={x=0.5,y=0.5}}
local defaultTextX      = 25
local defaultTextY      = 20
local interval          = 0.167
local defaultFontPath   = SL:GetMetaValue("GAME_DATA", "SUI_FONT_PATH") or global.MMO.PATH_FONT2

SUILoader.getAnchorByIndex = function(index)
    return anchorPoints[index or 0]
end

SUILoader.modifySizeAble = function(swidget)
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

SUILoader.modifyAnchorAble = function(swidget)
    local element = swidget.element
    if element.type == "Effect" then
        return false
    end
    if element.type == "UIModel" then
        return false
    end
    return true
end

SUILoader.modifyRotateAble = function(swidget)
    return true
end

SUILoader.modifyVisible = function(swidget)
    return true
end

SUILoader.modifyOpacity = function(swidget)
    local element = swidget.element
    if element.type == "CostItem" then
        return false
    end
    if element.type == "QuickTextView" then
        return false
    end
    if element.type == "ItemShow" or element.type == "DBItemShow" or element.type == "HERODBItemShow" or element.type == "MKItemShow" then
        return false
    end
    if element.type == "EquipShow" or element.type == "HEROEquipShow" or element.type == "PETEQUIPSHOW" then
        return false
    end
    return true
end

SUILoader.fixAnchor = function(swidget)
    if tonumber(swidget.element.attr.bg) == 1 and (tonumber(swidget.element.attr.show) == 5 or tonumber(swidget.element.attr.show) == 6) then
        local ax            = tonumber(swidget.element.attr.tax)
        local ay            = tonumber(swidget.element.attr.tay)
        ax                  = ax or 0
        ay                  = ay or 1
        return cc.p(ax, ay)
    end
    if swidget.element.attr.ax or swidget.element.attr.ay then
        local ax            = tonumber(swidget.element.attr.ax)
        local ay            = tonumber(swidget.element.attr.ay)
        ax                  = ax or 0
        ay                  = ay or 1
        return cc.p(ax, ay)
    end

    local a                 = tonumber(swidget.element.attr.a) or 0
    return SUILoader.getAnchorByIndex(a)
end

SUILoader.fixPosition = function(swidget)
    local parent            = swidget.render:getParent()
    local parentSize        = parent:getContentSize()

    local defaultX          = (swidget.element.type == "Text" or swidget.element.type == "RText" or swidget.element.type == "RTextX" or swidget.element.type == "BmpText") and defaultTextX or 0
    local defaultY          = (swidget.element.type == "Text" or swidget.element.type == "RText" or swidget.element.type == "RTextX" or swidget.element.type == "BmpText") and defaultTextY or 0
    local x                 = tonumber(swidget.element.attr.x) or defaultX
    local y                 = parentSize.height - (tonumber(swidget.element.attr.y) or defaultY)

    local percentx          = nil
    local percenty          = nil
    if tonumber(swidget.element.attr.bg) == 1 and (tonumber(swidget.element.attr.show) == 5 or tonumber(swidget.element.attr.show) == 6) then
        percentx            = tonumber(swidget.element.attr.tpercentx)
        percenty            = tonumber(swidget.element.attr.tpercenty)
    else
        percentx            = tonumber(swidget.element.attr.percentx)
        percenty            = tonumber(swidget.element.attr.percenty)
    end
    if percentx then
        x                   = parentSize.width * (percentx/100)
    end
    if percenty then
        y                   = parentSize.height - parentSize.height * (percenty/100)
    end

    return cc.p(x, y)
end

SUILoader.fixSize = function(swidget)
    local parent            = swidget.render:getParent()
    local parentSize        = parent:getContentSize()

    local contentSize       = swidget.render:getContentSize()
    local defaultWidth      = contentSize.width
    local defaultHeight     = contentSize.height
    local width             = tonumber(swidget.element.attr.width) or defaultWidth
    local height            = tonumber(swidget.element.attr.height) or defaultHeight

    local percentwidth      = tonumber(swidget.element.attr.percentwidth)
    local percentheight     = tonumber(swidget.element.attr.percentheight)
    if percentwidth then
        width               = parentSize.width * (percentwidth/100)
    end
    if percentheight then
        height              = parentSize.height * (percentheight/100)
    end
    
    return cc.size(width, height)
end

SUILoader.fixRotate = function(swidget)
    local rotate            = tonumber(swidget.element.attr.rotate) or 0
    return rotate
end

SUILoader.fixVisible = function(swidget)
    -- 默认0可见 1不可见
    local visible           = tonumber(swidget.element.attr.visible) or 0
    return visible == 0
end

SUILoader.fixOpacity = function(swidget)
    -- 默认不透明度 255
    local opacity           = tonumber(swidget.element.attr.opacity) or 255
    return opacity
end

-- load attr
SUILoader.loadSWidgetAttr = function(swidget)
    local render    = swidget.render
    local element   = swidget.element

    -- size
    if SUILoader.modifySizeAble(swidget) then
        local size      = SUILoader.fixSize(swidget)
        render:ignoreContentAdaptWithSize(false)
        render:setContentSize(size)
    end

    -- anchor
    if SUILoader.modifyAnchorAble(swidget) then
        local anchor    = SUILoader.fixAnchor(swidget)
        render:setAnchorPoint(anchor)
    end

    -- rotate
    if SUILoader.modifyRotateAble(swidget) then
        local rotate    = SUILoader.fixRotate(swidget)
        render:setRotation(rotate)
    end

    -- x y
    local position  = SUILoader.fixPosition(swidget)
    render:setPosition(position)
    local worldPos = render:convertToWorldSpace(cc.p(0, 0))
    local tranPos =  cc.p(mfloor(worldPos.x), mfloor(worldPos.y))
    render:setPosition(cc.pAdd(position, cc.pSub(tranPos, worldPos)))

    if SUILoader.modifyVisible(swidget) then
        local visible = SUILoader.fixVisible(swidget)
        render:setVisible(visible)
    end

    if SUILoader.modifyOpacity(swidget) then
        local opacity = SUILoader.fixOpacity(swidget)
        if render.setOpacity then
            render:setOpacity(opacity)
        end
    end

end


------------------------------------------
--- SUILoad Core
function SUILoader:ctor()
    defaultOutline = SL:GetMetaValue("GAME_DATA","defaultOutlineSize") or 0
    defaultOutlineC = SL:GetMetaValue("GAME_DATA","defaultOutlineColor") or 0
end

function SUILoader:getInputTable(fliter)
    local submitTable = {}

    if fliter == nil or fliter == "" or fliter == "0" then
    elseif fliter == "*" then
        for k, v in pairs(self._inputWidgets) do
            local input      = v
            local inputID    = k
            local inputValue = input.widget and input.widget:getString() or ""
            table.insert(submitTable, {id = inputID, value = inputValue, type = input.inputFlag, isChatInput = input.isChatInput, isNameInput = input.isNameInput})
        end
    else
        local slices = ssplit(fliter, ",")
        for i, v in ipairs(slices) do
            local inputID    = v
            local input      = self._inputWidgets[inputID]
            local inputValue = input.widget and input.widget:getString() or ""
            table.insert(submitTable, {id = inputID, value = inputValue, type = input.inputFlag, isChatInput = input.isChatInput, isNameInput = input.isNameInput})
        end
    end
    return submitTable
end

function SUILoader:getCheckBoxTable(fliter)
    local submitTable = {}

    if fliter == nil or fliter == "" or fliter == "0" then
        submitTable  = {}
    else
        for k, v in pairs(self._checkboxWidgets) do
            local widget     = v
            local widgetID   = k
            local value      = (widget:isSelected() and 1 or 0)
            table.insert(submitTable, {id = widgetID, value = value})
        end
    end
    return submitTable
end

function SUILoader:getCheckBoxTableByID(widgetID)
    local submitTable = {}

    local widget = self._checkboxWidgets[widgetID]
    if not widget then
        submitTable = {}
    else
        local value = (widget:isSelected() and 1 or 0)
        table.insert(submitTable, {id = widgetID, value = value})
    end
    return submitTable
end

function SUILoader:getSliderTableByID(widgetID)
    local submitTable = {}

    local param = self._sliderWidgets[widgetID]
    if not param or not param.widget then
        submitTable = {}
    else
        local value = param and param.value or 0
        table.insert(submitTable, {id = widgetID, value = value})
    end
    return submitTable
end

function SUILoader:getMenuItemTableByID(widgetID)
    local submitTable = {}

    local param = self._menuItemWidgets[widgetID]
    if not param or not param.widget then
        submitTable = {}
    else
        local value = param and param.value or ""
        value = param.widget:getString() or ""
        table.insert(submitTable, {id = widgetID, value = value})
    end
    return submitTable
end

function SUILoader:addMouseOverTips(widget, element)
    widget:setSwallowMouse(false)
    widget:setMouseEnabled(false)

    local tips              = element.attr.tips
    local tipsx             = tonumber(element.attr.tipsx) or 0
    local tipsy             = tonumber(element.attr.tipsy) or 0

    if tips and string.len(tips) > 0 then
        -- 监听事件;
        tips = string.gsub(tips, "%^", "\\")
        widget:addMouseOverTips(tips, cc.p(tipsx, -tipsy), cc.p(0.5, 1))
    end
end


------------------------------------------------------------------
-- load
function SUILoader:load(source, callback, closeCB, ext)
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
    local trunk, background = self:loadContent(elements, callback, closeCB, rootRect, ext)

    print("load cost", os.clock() - clock)

    return trunk, background
end

function SUILoader:fixBackground(elements, ext)
    -- 优先级 脚本中设置过bg字段 -> GM指定大背景框 -> 默认背景框
    -- dump(elements)
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
            element.attr.img        = SL:GetMetaValue("WINPLAYMODE") and "public_win32/bg_npc_01.png" or "public/bg_npc_01.png"  
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

function SUILoader:loadContent(elements, callback, closeCB, rootRect, ext)
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
        ["CostItem"]        = handler(self, self.load_render_CostItem),
        ["COUNTDOWN"]       = handler(self, self.load_render_COUNTDOWN),
        ["ITEMBOX"]         = handler(self, self.load_render_ITEMBOX),
        ["EquipShow"]       = handler(self, self.load_render_EquipShow),
        ["BAGITEMS"]        = handler(self, self.load_render_BAGITEMS),
        ["EQUIPITEMS"]      = handler(self, self.load_render_EQUIPITEMS),
        ["DBItemShow"]      = handler(self, self.load_render_DBItemShow),
        ["TIMETIPS"]        = handler(self, self.load_render_TIMETIPS),
        ["TextAtlas"]       = handler(self, self.load_render_TextAtlas),
        ["LoadingBar"]      = handler(self, self.load_render_LoadingBar),
        ["CircleBar"]       = handler(self, self.load_render_CircleBar),
        ["PercentImg"]      = handler(self, self.load_render_PercentImg),
        ["UIModel"]         = handler(self, self.load_render_UIModel),
        ["HEROEquipShow"]   = handler(self, self.load_render_HEROEquipShow),
        ["HEROEQUIPITEMS"]  = handler(self, self.load_render_HEROEQUIPITEMS),
        ["HERODBItemShow"]  = handler(self, self.load_render_HERODBItemShow),
        ["HEROBAGITEMS"]    = handler(self, self.load_render_HEROBAGITEMS),
        ["QuickTextView"]   = handler(self, self.load_render_QuickTextView),
        ["RTextX"]          = handler(self, self.load_render_RTextX),
        ["DLINKITEMS"]      = handler(self, self.load_render_DLINKITEMS),
        ["MKItemShow"]      = handler(self, self.load_render_MKItemShow),
        ["PETEQUIPSHOW"]    = handler(self, self.load_render_PETEQUIPSHOW),
        ["PageView"]        = handler(self, self.load_render_PageView),
        ["Slider"]          = handler(self, self.load_render_Slider),
        ["MenuItem"]        = handler(self, self.load_render_MenuItem),
        ["ScrapePic"]       = handler(self, self.load_render_ScrapePic),
        ["BmpText"]         = handler(self, self.load_render_BmpText),
    }

    -- 
    self._inputWidgets      = {}
    self._checkboxWidgets   = {}
    self._sliderWidgets     = {}
    self._menuItemWidgets   = {}

    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)

    -- 对比上次，差异化更改
    local lastTrunk             = ext and ext.lastTrunk or nil
    local lastBackground        = ext and ext.lastBackground or nil
    local loadCompleteCB        = ext and ext.loadCompleteCB or nil
    local isImmediate           = ext and ext.isImmediate or false
    local parentNode            = ext and ext.parentNode or nil
    local npcLayer              = ext and ext.npcLayer or nil --刷新npcLayer的background
    if npcLayer then
        SUIComponentProxy:ClearSUISlider()
    end
    -- load swidgets
    local background            = nil
    local swidgets              = {}
    for i, element in ipairs(elements) do
        -- exist loader
        if self._loaders[element.type] then
            element.attr.id     = element.attr.id or string.format("default_%s", i)
            element.attr.x      = (element.type == "Text" or element.type == "RText" or element.type == "RTextX" or element.type == "BmpText") and (element.attr.x or defaultTextX) or element.attr.x
            element.attr.y      = (element.type == "Text" or element.type == "RText" or element.type == "RTextX" or element.type == "BmpText") and (element.attr.y or defaultTextY) or element.attr.y
            element.attr._mainIndex= ext and ext.mainIndex    -- 主界面的按钮/图片点击需上报， 加的标识
            -- swidget
            local swidget       = global.SWidgetCache:generateSWidget()
            swidget.element     = element
            swidget.render      = nil
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
                            print("ERROR SUILoader: swidget can't be add aegin. swidgetID=" .. element.attr.id .. "  branchID=" .. branchID)
                        else
                            swidget:addBranch(branch)
                        end
                    end
                end
            end
        end
    end

    -- trunk
    local trunk             = global.SWidgetCache:generateSWidget()
    trunk.element           = Element.new("Layout")
    trunk.depth             = 0
    for _, element in ipairs(elements) do
        local swidget = swidgets[element.attr.id]
        if swidget and swidget.trunk == nil then
            trunk:addBranch(swidget)
        end
    end

    -- compare
    if lastTrunk then
        local backgroundR = SUILoader.compareSWidget(lastBackground, background)
        -- 
        local function fixBranches(trunkL, trunkC)
            if #trunkL.branches <= 0 then
                if #trunkC.branches > 0 then
                    for index, branch in ipairs(trunkC.branches) do
                        trunkL:addBranch(branch)
                    end
                end
                return nil
            end

            -- 数量不同
            local additions = {}
            if #trunkL.branches < #trunkC.branches then
                for i = #trunkL.branches+1, #trunkC.branches do
                    tinsert(additions, trunkC.branches[i])
                end
            end

            local rmvitemsL     = {}
            local insertitemsL  = {}
            for index, branch in ipairs(trunkL.branches) do
                local branchL   = branch
                local branchC   = trunkC.branches[index]
                local compareR  = SUILoader.compareSWidget(branchL, branchC)

                if compareR == 0 then
                    tinsert(rmvitemsL, branchL)

                elseif compareR == 1 and backgroundR == 1 then
                    if SUILoader.isBackground(branchL) and SUILoader.isBackground(branchC) then
                        background = branchL
                    end 
                    local element = branchC.element
                    if element.type == "ListView" and tonumber(element.attr.reload) == 2 then
                        local default       = tonumber(element.attr.default)
                        if branchL.element then
                            branchL.element.attr.default = default
                        end
                    end
                    self:reload_render(branchL)
                    fixBranches(branchL, branchC)

                elseif backgroundR ~= 1 or compareR == -1 or compareR == -2 or compareR == -3 or compareR == -4 or compareR == -5 or compareR == -6 then
                    tinsert(rmvitemsL, branchL)
                    tinsert(insertitemsL, {branch=branchC, index=index})
                end
            end

            for index, branch in ipairs(rmvitemsL) do
                trunkL:removeBranch(branch)
            end
            for index, item in ipairs(insertitemsL) do
                trunkL:insertBranch(item.branch, item.index)
            end
            for index, branch in ipairs(additions) do
                trunkL:addBranch(branch)
            end
        end
        fixBranches(lastTrunk, trunk)

        -- 
        trunk = lastTrunk
    end


    -- load trunk render
    if trunk and not trunk.render then
        trunk.render        = self:load_render(trunk, callback, closeCB)
    end
    ---
    if parentNode and not trunk.render:getParent() then 
        trunk.render:addTo(parentNode)
    end
    -- load background render
    if background and not background.render then
        background.render   = self:load_render(background, callback, closeCB)
        trunk:addBranchRender(background)
    end
    -- size
    if background and background.render and SUILoader.modifySizeAble(background) then
        local size          = SUILoader.fixSize(background)
        background.render:ignoreContentAdaptWithSize(false)
        background.render:setContentSize(size)
    end

    local root_anchor       = cc.p(0, 0)
    local root_position     = cc.p(mfloor(rootRect.x), 0)
    local root_size         = cc.size(rootRect.width, rootRect.height)
    if background then
        local root_show     = tonumber(background.element.attr.show) or 0
        if root_show == 0 then
            -- 左上
            root_anchor     = cc.p(0, 1)
            root_position   = cc.p(mfloor(rootRect.x), rootRect.height)
            root_size       = background.render:getContentSize()

        elseif root_show == 1 then
            -- 右上
            root_anchor     = cc.p(1, 1)
            root_position   = cc.p(rootRect.width, rootRect.height)
            root_size       = background.render:getContentSize()

        elseif root_show == 2 then
            -- 左下
            root_anchor     = cc.p(0, 0)
            root_position   = cc.p(mfloor(rootRect.x), 0)
            root_size       = background.render:getContentSize()

        elseif root_show == 3 then
            -- 右下
            root_anchor     = cc.p(1, 0)
            root_position   = cc.p(rootRect.width, 0)
            root_size       = background.render:getContentSize()

        elseif root_show == 4 then
            -- 中间
            root_anchor     = cc.p(0.5, 0.5)
            root_position   = cc.p(mfloor((rootRect.width)/2), mfloor(rootRect.height/2))
            root_size       = background.render:getContentSize()

            -- 尺寸处理成偶数，防止特效抖动
            root_size = {width = ConvertToEven(root_size.width), height = ConvertToEven(root_size.height)}

        elseif root_show == 5  or root_show == 6 then
            -- 中间铺满
            local attr      = background.element.attr
            root_size       = (attr.width or attr.height) and background.render:getContentSize() or root_size
            root_anchor     = cc.p(0.5, 0.5)
            root_position   = cc.p(mfloor((rootRect.width)/2), mfloor(rootRect.height/2))
            background.element.attr.tax = 0.5
            background.element.attr.tay = 0.5
            background.element.attr.tpercentx = 50
            background.element.attr.tpercenty = 50

            -- 尺寸处理成偶数，防止特效抖动
            root_size = {width = ConvertToEven(root_size.width), height = ConvertToEven(root_size.height)}

        elseif root_show == 7 then
            -- 上下居中
            root_anchor.y   = 0.5
            root_position.y = mfloor(rootRect.height / 2)
            root_size       = background.render:getContentSize()

            -- 尺寸处理成偶数，防止特效抖动
            root_size.height = ConvertToEven(root_size.height)

        elseif root_show == 8 then
            -- 左右居中
            root_anchor.x   = 0.5
            root_position.x = mfloor(rootRect.width / 2)
            root_size       = background.render:getContentSize()
        
            -- 尺寸处理成偶数，防止特效抖动
            root_size.width = ConvertToEven(root_size.width)
        end
    end
    trunk.render:setContentSize(root_size)
    trunk.render:setAnchorPoint(root_anchor)
    trunk.render:setPosition(root_position)
    trunk.render:stopAllActions()

    -- load background attr
    if background and background.render then
        SUILoader.loadSWidgetAttr(background)
    end

    -- DEBUG
    if DEBUG_MODE then
        trunk.render:setBackGroundColor(cc.Color3B.RED)
        trunk.render:setBackGroundColorType(1)
        trunk.render:setBackGroundColorOpacity(80)
    end

    ---------------------------------------
    -- load renders
    local function loadBranchRenders(loadTrunk)
        if #loadTrunk.branches == 0 then
            return nil
        end

        for _, branch in ipairs(loadTrunk.branches) do
            if not branch.render then
                local render = self:load_render(branch, callback, closeCB)
                if render then
                    branch.render = render
    
                    -- add to trunk
                    loadTrunk:addBranchRender(branch)
                    
                    -- load show attr
                    SUILoader.loadSWidgetAttr(branch)
                    if loadTrunk.element.type == "ListView" then
                        if loadTrunk.element.attr.default  and tonumber(loadTrunk.element.attr.default) then
                            local default = tonumber(loadTrunk.element.attr.default) - 1
                            local index = math.max(default, 0)
                            loadTrunk.render:jumpToItem(index, cc.p(0, 0), cc.p(0, 0))
                        end
                        loadTrunk.render:doLayout()
                    end
                    if loadTrunk.element.type == "PageView" then
                        if loadTrunk.element.attr.default  and tonumber(loadTrunk.element.attr.default) then
                            local default = tonumber(loadTrunk.element.attr.default) - 1
                            local index = math.max(default, 0)
                            loadTrunk.render:setCurrentPageIndex(index)
                        end
                        loadTrunk.render:doLayout()
                    end
                end
            end
        end
    end

    -- load immediate flag, edit form background
    local loadCount     = 1
    local loadStep      = 50
    if background then
        if isImmediate == false then
            isImmediate = true
            -- 
            if tonumber(background.element.attr.loadDelay) == 1 then
                isImmediate = false
            end
        end

        loadCount       = tonumber(background.element.attr.loadCount) or loadCount
        loadStep        = tonumber(background.element.attr.loadStep) or loadStep
        if npcLayer then 
            npcLayer.background = background
        end
    end
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
    else
        local loadQueue = {}
        local loadTrunk = nil
        tinsert(loadQueue, trunk)
        local function scheduleCB(sender, loadInit)
            local step = loadInit and loadCount or loadStep
            for i=1, step do
                if #loadQueue == 0 then
                    trunk.render:stopAllActions()

                    -- 装载完成
                    if loadCompleteCB then
                        loadCompleteCB()
                    end
                    return
                end

                -- load render
                loadTrunk = tremove(loadQueue, 1)
                loadBranchRenders(loadTrunk)

                if #loadTrunk.branches > 0 then
                    for _, branch in ipairs(loadTrunk.branches) do
                        if #branch.branches > 0 then
                            tinsert(loadQueue, branch)
                        end
                    end
                end
            end
        end
        schedule(trunk.render, scheduleCB, interval)
        scheduleCB(trunk.render, true)
    end

    return trunk, background
end

function SUILoader:load_action(source)
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
            dump(params)
            table.insert(actions, cc.FadeTo:create(tonumber(params[1]), tonumber(params[2])))
        end
    end

    if not next(actions) then
        return nil
    end
    return cc.Sequence:create(actions)
end

function SUILoader:reload_render(swidget)
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
    if element.type == "PageView" then
        local default       = tonumber(element.attr.default)
        if default and swidget.render then
            -- default
            local function callback()
                local index = math.max(default - 1, 0)
                swidget.render:setCurrentPageIndex(index)
                swidget.render:doLayout()
            end
            performWithDelay(swidget.render, callback, 1/60)
        end
    end
end

function SUILoader:load_render(swidget, callback, closeCB)
    local element           = swidget.element
    local loader            = self._loaders[element.type]
    if nil == loader then
        print("load render error")
        return nil
    end

    local render            = loader(swidget, callback, closeCB)
    render:setCascadeOpacityEnabled(true)
    render:setName(element.attr.id)
    return render
end

function SUILoader:linkFuncWithCheckWords(callback, param)
    if not callback or not param then
        return
    end
    local fixInput = param.Input
    local function checkFunc(i)
        local v = fixInput[i]
        if v and (v.isChatInput or v.isNameInput) then
            local isNameCheck = v.isNameInput
            local isChatCheck = v.isChatInput
            if isNameCheck and IsForbidName(true) then
                return
            end
            if isChatCheck and IsForbidSay(true) then
                return
            end
            
            local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
            local function handle_Func(state, str, risk_param)
                if not str then
                    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1006))
                    return
                end
        
                v.value = str
                if i == #fixInput then
                    param.Input      = (#fixInput > 0 and fixInput or nil)
                    callback(param)
                else
                    checkFunc(i + 1)
                end
            end
            if isNameCheck then
                SensitiveWordProxy:IsHaveSensitiveAddFilter(v.value, handle_Func)
            else
                SensitiveWordProxy:fixSensitiveTalkAddFilter(v.value, handle_Func, nil)
            end
        else
            if i == #fixInput then
                param.Input = (#fixInput > 0 and fixInput or nil)
                callback(param)
            else
                checkFunc(i + 1)
            end
        end
    end
    if fixInput and #fixInput > 0 then
        checkFunc(1)
    else
        callback(param)
    end
end

function SUILoader:load_render_Text(swidget, callback)
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
    local hexColor          = element.attr.hexcolor
    local bl                = math.floor(tonumber(element.attr.bl) or 0)


    text = string.gsub(text, "\\", "\r\n")
    text = string.trim(text)

    if tonumber(text) and bl >= 1 and bl <= 3 then
        local unitFunc = function(num, pointBit)
            pointBit = pointBit or 2
            if pointBit == 0 then
                return math.floor(num)
            end
            local iNum, fNum = math.modf(num)
            local fDecimal = math.pow(10, tostring(pointBit))
            local newFNum = math.floor(tostring(fNum * fDecimal))
            local newINum = iNum + (newFNum / fDecimal)
            return newINum
        end

        local blValue = 100
        if bl == 2 then
            blValue = 10000
        elseif bl == 3 then
            blValue = 1000
        end
        text = string.format("%s%%", unitFunc(text/blValue))
    end

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

    local widget = global.SWidgetCache:generateRender("ccui.Text")
    widget:setScale(1)
    widget:setString(text)
    widget:setFontSize(size)
    widget:setFontName(defaultFontPath)
    widget:setTextColor(useHex and GetColorFromHexString(hexColorTable[1]) or GET_COLOR_BYID_C3B(colorTable[1]))
    widget:setTouchEnabled(false)
    widget:stopAllActions()
    widget:disableEffect(1)
    widget:disableEffect(6)
    widget:getVirtualRenderer():setMaxLineWidth(0)
    widget:enableOutline(GET_COLOR_BYID_C3B(outlinecolor), outline)

    -- 加入元变量组件管理
    local isMateValue = false
    local metaValue = {}
    local content = text
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
    if isMateValue then
        widget.useMetaValue = true
        global.Facade:sendNotification(global.NoticeTable.SUIMetaWidgetAdd, {metaValue = metaValue, widget = widget, lifewidget = widget, simplenum = simplenum, thouFormat = thouFormat})
    end
    
    -- width
    if width then
        local contentSize = widget:getContentSize()
        local renderer = widget:getVirtualRenderer()
        renderer:setMaxLineWidth(width)
    end

    -- link
    if link and string.len(link) > 0 or (tips and string.len(tips) > 0) then
        widget:setTouchEnabled(true)
        widget:addClickEventListener(function()
            DelayTouchEnabled(widget, clickInterval)

            widget:setScale(1 + 0.2)
            local function reback()
                widget:setScale(1)
            end
            performWithDelay(widget, reback, 0.03)
            
            if callback and link then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end

            if not global.isWinPlayMode then
                if tips and string.len(tips) > 0 then
                    local offset  = cc.p(tipsx, -tipsy)
                    local anchorPoint = cc.p(0.5, 1)
        
                    tips  = string.gsub(tips, "%^", "\\")
                    SHOW_SUI_DESCTIP( widget ,tips, tipWidth, offset, anchorPoint)
                end
            end

        end)

        -- 下划线
        widget:getVirtualRenderer():enableUnderline()
    end
    
    -- auto color
    local tbl = useHex and hexColorTable or colorTable
    if #tbl > 1 then
        local index = 1
        local function callback()
            index = index + 1
            if index > #tbl then
                index = 1
            end

            local color = useHex and GetColorFromHexString(tbl[index]) or GET_COLOR_BYID_C3B(tbl[index])
            widget:setTextColor(color)

            if link and string.len(link) > 0 then
                -- 下划线
                widget:getVirtualRenderer():disableEffect(6)
                widget:getVirtualRenderer():enableUnderline()
            end
        end
        schedule(widget, callback, 1)
    end

    self:addMouseOverTips(widget, element)

    -- auto scroll
    if scrollWidth then
        local widgetSize   = widget:getContentSize()
        local scrollH      = scrollHeight or widgetSize.height
        local scrollLayout = global.SWidgetCache:generateRender("ccui.Layout")
        scrollLayout:setClippingType(0)
        scrollLayout:setClippingEnabled(true)
        scrollLayout:setContentSize(cc.size(scrollWidth, scrollH))
        scrollLayout:addChild(widget)
        widget:setAnchorPoint(cc.p(0, 0))
        widget:setPosition(cc.p(0, 0))
        if scrollWay == 0 then
            widget:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(scrollTime, cc.p(-widgetSize.width, 0)), 
                cc.MoveBy:create(0, cc.p(widgetSize.width, 0)))
            ))
        elseif scrollWay == 1 then
            widget:setAnchorPoint(cc.p(0,1))
            widget:setPosition(cc.p(0, scrollH))
            widget:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(scrollTime, cc.p(0, widgetSize.height)),
                cc.MoveBy:create(0, cc.p(0, -widgetSize.height))
            )))
        end
        return scrollLayout
    end

    -- auto event
    if widget:getChildByName("textAuto") then
        widget:removeChildByName("textAuto")
    end
    if platform == global.OperatingMode and auto and link and string.len(link) > 0 then
        local textAuto = ccui.Text:create()
        widget:addChild(textAuto)
        textAuto:setName("textAuto")
        textAuto:setString(string.format("(%s)", auto))
        textAuto:setFontSize(size)
        textAuto:setFontName(defaultFontPath)
        textAuto:setColor(cc.Color3B.WHITE)
        textAuto:setAnchorPoint(cc.p(0, 0.5))
        textAuto:setPosition(cc.p(widget:getContentSize().width + 3, widget:getContentSize().height/2))
        widget:disableEffect(6)

        local function autoCB()
            auto = auto - 1
            auto = math.max(auto, 0)
            textAuto:setString(string.format("(%s)", auto))  

            if auto == 0 then
                textAuto:stopAllActions()
                textAuto:removeFromParent()
                if callback then
                    local inputTable    = self:getInputTable(submitInput)
                    local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                    local jsonData      = {}
                    jsonData.Act        = link
                    jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    self:linkFuncWithCheckWords(callback, jsonData)
                end
            end
        end
        schedule(textAuto, autoCB, 1)
    end

    if simplenum == 1 then
        local text = widget:getString()
        if text and tonumber(text) then
            text = GetSimpleNumber(tonumber(text))
            widget:setString(text)
        end
    end

    if thouFormat == 1 then
        local text = widget:getString()
        if text and tonumber(text) then
            text = string.formatnumberthousands(tonumber(text))
            widget:setString(text)
        end
    end
    
    return widget
end

function SUILoader:load_render_TextAtlas(swidget, callback)
    local element           = swidget.element
    local img               = element.attr.img or "public/word_tywz_01.png"
    local iwidth            = tonumber(element.attr.iwidth) or 18
    local iheight           = tonumber(element.attr.iheight) or 28
    local schar             = element.attr.schar or "0"
    local text              = element.attr.text or ""

    local img               = SUIHelper.fixImageFileName(img)
    local fullPath          = (img and img ~= "") and string.format(getResFullPath("res/%s"), img) or ""
    if not fullPath or fullPath == "" or not global.FileUtilCtl:isFileExist(fullPath) then
        img                 = SUIHelper.fixImageFileName("public/word_tywz_01.png")
        fullPath            = string.format(getResFullPath("res/%s"), img)
    end

    local widget = ccui.TextAtlas:create()
    widget:setProperty( "", fullPath, iwidth, iheight, schar )
    widget:setScale(1)
    

    -- 加入元变量组件管理
    local isMateValue = false
    local metaValue = {}
    local content = text
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
    if isMateValue then
        widget.useMetaValue = true
        global.Facade:sendNotification(global.NoticeTable.SUIMetaWidgetAdd, {metaValue = metaValue, widget = widget, lifewidget = widget})
    else
        widget:setString(text)
    end
    
    
    return widget
end

function SUILoader:load_render_RText(swidget, callback)
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


    local function textCB(str)
        if callback then
            local jsonData      = {}
            jsonData.Act        = str
            callback(jsonData)
        end
    end
    local ttfConfig = {
        outlineSize = outline,
        outlineColor = GET_COLOR_BYID_C3B(outlinecolor)
    }
    local SUI_RTEXT_FONT_PATH = SL:GetMetaValue("WINPLAYMODE") and SL:GetMetaValue("GAME_DATA","SUI_RTEXT_FONT_PATH") or nil
    local fontPath = SUI_RTEXT_FONT_PATH or defaultFontPath
    local widget = RichTextHelp:CreateRichTextWithFCOLOR(text, width, size, color, ttfConfig, textCB, SL:GetMetaValue("GAME_DATA","DEFAULT_VSPACE"), fontPath)

    self:addMouseOverTips(widget, element)

    -- auto scroll
    if scrollWidth then
        local widgetSize   = widget:getContentSize()
        local scrollH      = scrollHeight or widgetSize.height
        local scrollLayout = global.SWidgetCache:generateRender("ccui.Layout")
        scrollLayout:setClippingEnabled(true)
        scrollLayout:setClippingType(0)
        scrollLayout:setContentSize(cc.size(scrollWidth, scrollH))
        scrollLayout:addChild(widget)
        widget:setAnchorPoint(cc.p(0, 0))
        widget:setPosition(cc.p(0, 0))
        if scrollWay == 0 then
            widget:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(scrollTime, cc.p(-widgetSize.width, 0)), 
                cc.MoveBy:create(0, cc.p(widgetSize.width, 0)))
            ))
        elseif scrollWay == 1 then
            widget:setAnchorPoint(cc.p(0, 1))
            widget:setPosition(cc.p(0, scrollH))
            widget:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(scrollTime, cc.p(0, widgetSize.height)),
                cc.MoveBy:create(0, cc.p(0, -widgetSize.height))
            )))
        end
        return scrollLayout
    end

    return widget
end

function SUILoader:load_render_Img(swidget, callback)
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
    local tips              = element.attr.tips
    local tipsx             = tonumber(element.attr.tipsx) or 0
    local tipsy             = tonumber(element.attr.tipsy) or 0
    local tipWidth          = tonumber(element.attr.tipWidth) or 1136
    local mainIndex         = element.attr._mainIndex

    local widget            = nil
    local img               = SUIHelper.fixImageFileName(img)
    local fullPath          = (img and img ~= "") and string.format(getResFullPath("res/%s"), img) or ""
    if not fullPath or fullPath == "" or not global.FileUtilCtl:isFileExist(fullPath) then
        widget              = global.SWidgetCache:generateEmptyImageRender("ccui.ImageView")
    else
        widget              = global.SWidgetCache:generateRender("ccui.ImageView")
    end
    
    widget:loadTexture(fullPath)
    widget:ignoreContentAdaptWithSize(false)
    widget:setContentSize(widget:getVirtualRendererSize())
    widget:setCapInsets(cc.rect(0, 0, 0, 0))
    widget:setScale9Enabled(false)
    widget:setTouchEnabled(false)
    
    if scale9l and scale9r and scale9t and scale9b then
        local contentSize   = widget:getContentSize()
        local x             = scale9l
        local y             = scale9t
        local width         = contentSize.width-scale9l-scale9r
        local height        = contentSize.height-scale9t-scale9b
        widget:setScale9Enabled(true)
        widget:setCapInsets({x = x, y = y, width = width, height = height})
    end

    -- link
    widget._linkClick = false
    if link and string.len(link) > 0 then
        widget:setTouchEnabled(true)
        widget:addClickEventListener(function()

            if mainIndex then
                -- 数据上报
                local NativeBridgeProxy = global.Facade:retrieveProxy(global.ProxyTable.NativeBridgeProxy)
                NativeBridgeProxy:GN_MainUIClickEvent({
                    index = mainIndex,
                    id = element.attr.id,
                    link = link
                })
            end

            if callback and link then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end

            if not global.isWinPlayMode then
                if tips and string.len(tips) > 0 then
                    local offset  = cc.p(tipsx, -tipsy)
                    local anchorPoint = cc.p(0.5, 1)
            
                    tips  = string.gsub(tips, "%^", "\\")
                    SHOW_SUI_DESCTIP( widget ,tips, tipWidth, offset, anchorPoint)
                end
            end
        end)
        if bg == 1 then
            widget._linkClick = true
        end
    end

    if bg == 1 then
        widget:setTouchEnabled(true)
        if global.isWinPlayMode then
            widget:setMouseEnabled(true)
            global.mouseEventController:registerMouseMoveEvent(widget)
        end
    end

    self:addMouseOverTips(widget, element)

    -- grey
    if grey == 1 then
        Shader_Grey(widget)
    else
        Shader_Normal(widget)
    end

    if flip == 1 then
        widget:setFlippedX(true)
    elseif flip == 2 then
        widget:setFlippedY(true)
    end


    return widget
end

function SUILoader:load_render_Button(swidget, callback, closeCB)
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
    local mainIndex         = element.attr._mainIndex

    text = string.gsub(text, "\\", "\r\n")
    text = string.trim(text)

    local nimg      = SUIHelper.fixImageFileName(nimg)
    local pimg      = SUIHelper.fixImageFileName(pimg)
    local mimg      = SUIHelper.fixImageFileName(mimg)
    local fullPathN = (nimg and string.len(nimg) > 0 and string.format(getResFullPath( "res/%s" ), nimg) or "")
    local fullPathP = (pimg and string.len(pimg) > 0 and string.format(getResFullPath( "res/%s" ), pimg) or "")
    local fullPathM = (mimg and string.len(mimg) > 0 and string.format(getResFullPath( "res/%s" ), mimg) or "")

    local widget    = nil
    local isNormalExist = fullPathN ~= "" and global.FileUtilCtl:isFileExist(fullPathN)
    local isPressExist = fullPathP ~= "" and global.FileUtilCtl:isFileExist(fullPathP)
    local isMouseExist = fullPathM ~= "" and global.FileUtilCtl:isFileExist(fullPathM)
    local Button_Type = 1
    --1-normalAndPress 2-Normal 3-Press 4-nil
    if isNormalExist and isPressExist  then
        Button_Type      = 1
    elseif  isNormalExist then 
        Button_Type = 2
    elseif isPressExist then 
        Button_Type = 3
    else
        Button_Type = 4
    end
    widget = global.SWidgetCache:generateButtonRender(Button_Type)
    widget:resetNormalRender()
    widget:resetPressedRender()
    widget:setTitleText(text)
    widget:setTitleColor(GET_COLOR_BYID_C3B(color))
    widget:setTitleFontName(defaultFontPath)
    widget:setTitleFontSize(size)
    widget:setTouchEnabled(false)
    widget:getTitleRenderer():setMaxLineWidth(0)
    widget:getTitleRenderer():enableOutline(GET_COLOR_BYID_C3B(outlinecolor), outline)


    if isNormalExist then
        widget:loadTextureNormal(fullPathN)
    end
    if isPressExist then
        widget:loadTexturePressed(fullPathP)
    end

    -- 
    widget:ignoreContentAdaptWithSize(false)
    widget:setContentSize(widget:getVirtualRendererSize())
    local showTips      = tips and string.len(tips) > 0
    if isNormalExist and (isMouseExist or showTips) then
        if global.isWinPlayMode then
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
                if isMouseExist and isNormalExist then
                    widget:loadTextureNormal(path, resType)
                end
            end

            local offset        = cc.p(tipsx, -tipsy)
            local anchor        = cc.p(0.5, 1)
            local function enterCB(touchPos)
                if global.userInputController:isTouching() or not widget:isVisible() then
                    return false
                end
                if not CheckNodeCanCallBack(widget, touchPos) then
                    return false
                end
                checkRes(fullPathM)
                if showTips then
                    tips        = string.gsub(tips, "%^", "\\")
                    showMouseOverTips(widget, tips, offset, anchor)
                end
            end
            local function leaveCB()
                checkRes(fullPathN)
                hideMouseOverTips()
            end
            -- widget:loadTextureMouseOver(fullPathN, fullPathM, enterCB, leaveCB)
            global.mouseEventController:registerMouseMoveEvent(
                widget,
                {
                    enter = enterCB,
                    leave = leaveCB,
                    checkIsVisible = true
                }
            )
        
        end
    end

    -- 加入元变量组件管理
    local isMateValue = false
    local metaValue = {}
    local content = text
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
    if isMateValue then
        widget.useMetaValue = true
        global.Facade:sendNotification(global.NoticeTable.SUIMetaWidgetAdd, {metaValue = metaValue, widget = widget, lifewidget = widget})
    end

    if textWidth then
        local renderer = widget:getTitleRenderer()
        renderer:setMaxLineWidth(textWidth)
    end
    
    -- link
    if link and string.len(link) > 0 or (tips and string.len(tips) > 0) then
        widget:setTouchEnabled(true)
        widget:addClickEventListener(function()
            DelayTouchEnabled(widget, clickInterval)

            if mainIndex then
                -- 数据上报
                local NativeBridgeProxy = global.Facade:retrieveProxy(global.ProxyTable.NativeBridgeProxy)
                NativeBridgeProxy:GN_MainUIClickEvent({
                    index = mainIndex,
                    id = element.attr.id,
                    link = link
                })
            end

            if link == "@DEFAULT_CLOSE" then
                if closeCB then
                    closeCB()
                end

            elseif callback and link then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end

            if not global.isWinPlayMode then
                if tips and string.len(tips) > 0 then
                    local offset  = cc.p(tipsx, -tipsy)
                    local anchorPoint = cc.p(0.5, 1)
            
                    tips  = string.gsub(tips, "%^", "\\")
                    SHOW_SUI_DESCTIP( widget ,tips, tipWidth, offset, anchorPoint)
                end
            end

        end)
    end

    -- if nil == mimg then
    --     self:addMouseOverTips(widget, element)
    -- end

    -- grey
    if grey == 1 then
        Shader_Grey(widget)
    else
        Shader_Normal(widget)
    end

    return widget
end

function SUILoader:load_render_CheckBox(swidget, callback)
    local element           = swidget.element
    local checkboxid        = element.attr.checkboxid
    local nimg              = element.attr.nimg
    local pimg              = element.attr.pimg
    local default           = tonumber(element.attr.default) or 0
    local submit            = tonumber(element.attr.submit) or 0
    local delay             = math.max(tonumber(element.attr.delay) or 0, 1/60)
    local count             = tonumber(element.attr.count) or 0
    local link              = element.attr.link


    local nimg = SUIHelper.fixImageFileName(nimg)
    local pimg = SUIHelper.fixImageFileName(pimg)
    local widget = ccui.CheckBox:create()
    widget:loadTextureBackGround(string.format(getResFullPath("res/%s"), nimg))
    widget:loadTextureFrontCross(string.format(getResFullPath("res/%s"), pimg))
    widget:setSelected(default == 1)
    widget:setTouchEnabled(true)
    widget:ignoreContentAdaptWithSize(false)
    widget:stopAllActions()

    -- link
    if link and string.len(link) > 0 then
        widget:addEventListener(function()
            local counting = 0
            local function delayCB()
                if callback then
                    local checkBoxTable = self:getCheckBoxTableByID(checkboxid)
                    local jsonData      = {}
                    jsonData.Act        = link
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    callback(jsonData)
                end

                counting = counting + 1
                if count ~= -1 and counting >= count then
                    widget:stopAllActions()
                end
            end
            widget:stopAllActions()
            schedule(widget, delayCB, delay)
        end)
    end
    
    if checkboxid and self._checkboxWidgets then
        self._checkboxWidgets[checkboxid] = widget
    end

    return widget
end

function SUILoader:load_render_ListView(swidget, callback)
    local element           = swidget.element
    local width             = element.attr.width or 200
    local height            = element.attr.height or 200
    local color             = tonumber(element.attr.color)
    local direction         = tonumber(element.attr.direction) or 1
    local bounce            = tonumber(element.attr.bounce) or 1
    local margin            = tonumber(element.attr.margin) or 0
    local default           = tonumber(element.attr.default)
    local cantouch          = tonumber(element.attr.cantouch) or 1

    local widget = global.SWidgetCache:generateRender("ccui.ListView") 
    widget:ignoreContentAdaptWithSize(false)
    widget:setClippingEnabled(true)
    widget:setClippingType(0)
    widget:setTouchEnabled(true)
    widget:setDirection(direction)
    widget:setGravity(0)
    widget:setItemsMargin(margin)
    widget:setBounceEnabled(bounce == 1)
    widget:setBackGroundColorType(0)
    widget:stopAllActions()

    if DEBUG_MODE then
        widget:setBackGroundColorType(1)
        widget:setBackGroundColorOpacity(100)
        widget:setBackGroundColor(cc.Color3B.GREEN)
    end

    -- color
    if color then
        widget:setBackGroundColorType(1)
        widget:setBackGroundColorOpacity(255)
        widget:setBackGroundColor(GET_COLOR_BYID_C3B(color))
    end

    -- default
    if default then
        -- default
        local function callback()
            default = default - 1
            local index = math.max(default, 0)
            widget:jumpToItem(index, cc.p(0, 0), cc.p(0, 0))
            widget:doLayout()
        end
        performWithDelay(widget, callback, 1/60)
    end

    if cantouch == 0 then
        widget:setTouchEnabled(false)
    else
        widget._unRefPos = true
    end
    
    return widget
end

function SUILoader:load_render_Effect(swidget, callback)
    local element           = swidget.element
    local effecttype        = tonumber(element.attr.effecttype) or 0
    local effectid          = tonumber(element.attr.effectid) or 9999
    local sex               = tonumber(element.attr.sex) or 0
    local act               = tonumber(element.attr.act) or 0
    local dir               = tonumber(element.attr.dir) or 5
    local speed             = tonumber(element.attr.speed) or 1
    local scale             = tonumber(element.attr.scale) or 1
    local count             = tonumber(element.attr.count) or 0
    local grey              = tonumber(element.attr.grey) or 0
    local link              = element.attr.link
    local scalex            = tonumber(element.attr.scalex)
    local scaley            = tonumber(element.attr.scaley)

    -- 0.普通特效 1.npc模型 2.怪物模型 3.技能特效 4.人物 5.武器 6.翅膀 7.发型
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

    if widget then
        widget:setScale(scale)
        if not tonumber(element.attr.scale) and scalex then
            widget:setScaleX(scalex)
        end
        if not tonumber(element.attr.scale) and scaley then
            widget:setScaleY(scaley)
        end
        
        
        -- 播放次数
        local counting = 0
        widget:SetAnimEventCallback(
            function(_, eventType)
                counting = counting + 1
                
                if counting == count then
                    if link then
                        if callback then
                            local jsonData      = {}
                            jsonData.Act        = link
                            callback(jsonData)
                        end
                    end

                    widget:Stop()
                    widget:setVisible(false)
                end
            end
        )

        -- 灰化处理
        if grey == 1 then
            Shader_Grey(widget)
        else
            Shader_Normal(widget)
        end
    end

    return widget
end

function SUILoader:load_render_Frames(swidget, callback)
    local element           = swidget.element
    local prefix            = element.attr.prefix
    local suffix            = element.attr.suffix
    local speed             = tonumber(element.attr.speed) or 100
    local count             = tonumber(element.attr.count) or 1
    local loop              = tonumber(element.attr.loop) or -1
    local finishframe       = tonumber(element.attr.finishframe)
    local finishhide        = tonumber(element.attr.finishhide)
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox

    local img       = SUIHelper.fixImageFileName(prefix .. "1" .. suffix)
    local fullPath  = string.format(getResFullPath("res/%s"), img)
    local widget    = nil
    if global.FileUtilCtl:isFileExist(fullPath) then
        widget      = global.SWidgetCache:generateRender("ccui.ImageView")
    else
        widget      = ccui.ImageView:create()
    end
    widget:loadTexture(fullPath)
    widget:ignoreContentAdaptWithSize(false)
    widget:setContentSize(widget:getVirtualRendererSize())
    widget:setTouchEnabled(false)
    widget:setCapInsets(cc.rect(0, 0, 0, 0))
    widget:setScale9Enabled(false)
    widget:stopAllActions()

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
    schedule(widget, delayCB, speed*0.01)
    delayCB()

    -- link
    if link and string.len(link) > 0 then
        widget:setTouchEnabled(true)
        widget:addClickEventListener(function()
            if callback then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end
        end)
    end

    return widget
end

function SUILoader:load_render_Input(swidget, callback)
    local element           = swidget.element
    local inputid           = element.attr.inputid
    local inputtype         = tonumber(element.attr.type) or 0
    local text              = element.attr.text or ""
    local place             = element.attr.place
    local placecolor        = element.attr.placecolor or defaultColorID
    local width             = element.attr.width
    local height            = element.attr.height
    local color             = element.attr.color or defaultColorID
    local size              = tonumber(element.attr.size) or defaultFontSize
    local mincount          = element.attr.mincount
    local maxcount          = tonumber(element.attr.maxcount) or 10000
    local errortips         = element.attr.errortips
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local linkType          = tonumber(element.attr.linkType) or 1
    local link              = element.attr.link
    local onlyCh            = tonumber(element.attr.onlyCh) and tonumber(element.attr.onlyCh) == 1
    local isChatInput       = (tonumber(element.attr.isChatInput) or 1) == 1
    local isNameInput       = tonumber(element.attr.isNameInput) == 1

    local fontPath = defaultFontPath
    local widget = ccui.EditBox:create({width=width, height=height}, global.MMO.PATH_RES_ALPHA)
    widget:setFontColor(GET_COLOR_BYID_C3B(tonumber(color)))
    widget:setColor(GET_COLOR_BYID_C3B(tonumber(color)))
    if global.isMobile then
        widget:setFontName(fontPath)
    end
    widget:setFontSize(size)
    widget:setString(text)
    widget:setPlaceHolder(place)
    widget:setPlaceholderFontColor(GET_COLOR_BYID_C3B(tonumber(placecolor)))
    widget:setPlaceholderFontSize(size)
    widget:setTextHorizontalAlignment(0)
    widget:setMaxLength(maxcount)

    -- native offset
    if global.Platform == cc.PLATFORM_OS_WINDOWS then
    elseif global.Platform == cc.PLATFORM_OS_ANDROID then
        widget:setNativeOffset( cc.p( 0, -15 ) )
    else
    end

    -- 输入类型
    if inputtype == 1 or inputtype == 3 then
        widget:setInputMode(2)
    elseif inputtype == 2 then
        widget:setInputFlag(0)
    end

    if inputid and self._inputWidgets then
        self._inputWidgets[inputid] = {widget = widget, inputFlag = (inputtype ~= 1 and "INPUTTEXT" or ""), isChatInput = isChatInput, isNameInput = isNameInput}
    end

    local function eventCB(sender, eventType)
        if eventType == 2 and onlyCh then
            local str = sender:getString()
            sender:setString(CheckInputOnlyChinese(str))
        end
        if eventType == 2 and (inputtype == 1 or inputtype == 3) then
            local str = sender:getString()
            if string.find(str,"[^%d]+") then
                local s, d = string.find(str,"[^%d]+") 
                local str1 = string.sub(str, 1, s-1)
                local str2 = string.sub(str, d+1)
                sender:setString(str1..str2)
            end
            if inputtype == 3 then
                local str = sender:getString()
                local num = tonumber(str)
                if num and tostring(num) ~= str then
                    sender:setString(num)
                end
            end
        end
    end

    if link then
        widget:addEventListener(function(sender, eventType)
            eventCB(sender, eventType)
            if linkType == eventType then
                if callback then
                    local inputTable    = self:getInputTable(submitInput)
                    local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                    local jsonData      = {}
                    jsonData.Act        = link
                    jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    self:linkFuncWithCheckWords(callback, jsonData)
                end
            end
        end)
    else
        widget:addEventListener(eventCB)
    end
    
    return widget
end

function SUILoader:load_render_COUNTDOWN(swidget, callback)
    local element           = swidget.element
    local time              = tonumber(element.attr.time) or 10
    local count             = tonumber(element.attr.count) or 1
    local color             = tonumber(element.attr.color) or defaultColorID
    local size              = tonumber(element.attr.size) or defaultFontSize
    local showWay           = tonumber(element.attr.showWay) or 0
    local outline           = tonumber(element.attr.outline) or defaultOutline
    local outlinecolor      = tonumber(element.attr.outlinecolor) or defaultOutlineC
    local link              = element.attr.link


    local widget = global.SWidgetCache:generateRender("ccui.Text")
    if showWay == 1 then
        widget:setString(TimeFormatToString(time))
    else
        widget:setString(string.format(GET_STRING(2006), time))
    end
    widget:setFontSize(size)
    widget:setFontName(defaultFontPath)
    widget:setTextColor(GET_COLOR_BYID_C3B(color))
    widget:enableOutline(GET_COLOR_BYID_C3B(outlinecolor), outline)
    widget:setTouchEnabled(false)
    widget:stopAllActions()

    local counting = 0
    local remaining = time
    local function scheduleCallback()
        if showWay == 1 then
            widget:setString(TimeFormatToString(remaining))
        else
            widget:setString(string.format(GET_STRING(2006), remaining))
        end
        remaining = remaining - 1
        if remaining < 0 then
            -- link
            if link and string.len(link) > 0 then
                if callback then
                    local jsonData = {}
                    jsonData.Act   = link
                    callback(jsonData)
                end
            end

            remaining = time
            counting  = counting + 1
            if count > 0 and counting >= count then
                widget:stopAllActions()
            end
        end
    end
    schedule(widget, scheduleCallback, 1)
    scheduleCallback()

    return widget
end

function SUILoader:load_render_ItemShow(swidget, callback)
    local element           = swidget.element
    local itemid            = tonumber(element.attr.itemid) or 1
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
    local dblink            = element.attr.dblink
    local effectshow        = tonumber(element.attr.effectshow) or 1
    local itemDataStr       = element.attr.itemdata
    local itemName          = element.attr.itemname
    local itemData          = nil

    if itemDataStr and string.len(tostring(itemDataStr)) > 0 then
        local json = cjson.decode(itemDataStr)
        if json and next(json) then
            itemData = ChangeItemServersSendDatas(json)
        end
    end

    if itemName and string.len(itemName) > 0 then
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local index = ItemConfigProxy:GetItemIndexByName(itemName)
        if index and not tonumber(element.attr.itemid) then
            itemid = index
        end
    end

    local contentSize       = cc.size(66,66)
    
    local widget            = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    local info              = {}
    info.index              = itemid
    info.look               = showtips == 1
    info.count              = itemcount
    info.bgVisible          = bgtype == 1
    info.color              = countColor
    info.itemData           = itemData
    if not info.look and global.isWinPlayMode then
        info.noMouseTips = true
    end
    if effectshow == 2 then
        info.showModelEffect = true
    elseif effectshow == 0 then
        info.isShowEff = false
    end
    local goodsItem         = GoodsItem:create(info)
    widget:addChild(goodsItem)
    goodsItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
    goodsItem:setScale(scale)
    goodsItem:setIconGrey(grey == 1)

    if dblink and string.len(dblink) > 0 then
        if not (showtips == 1) then
            goodsItem:addLookItemInfoEvent(nil, 2)
        end
        goodsItem:addDoubleEventListener(function()
            if callback then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = dblink
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end
        end)
    end

    if lock == 1 then
        local imageLock     = ccui.ImageView:create()
        imageLock:setAnchorPoint(cc.p(0, 1))
        goodsItem:addChild(imageLock)
        if global.isWinPlayMode then
            imageLock:setScale(0.7)
        end
        imageLock:loadTexture(global.MMO.PATH_RES_PUBLIC .. "lock.png")
        imageLock:setPosition(cc.p(0, goodsItem:getContentSize().height))
    end

    if link and not dblink then
        local linkWidget    = global.SWidgetCache:generateRender("ccui.Widget")
        widget:addChild(linkWidget)
        linkWidget:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        linkWidget:setContentSize(contentSize)
        linkWidget:setTouchEnabled(true)
        linkWidget:setSwallowTouches(false)
        linkWidget:addClickEventListener(function()
            if callback then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end
        end)
    end

    
    return widget
end

function SUILoader:load_render_DBItemShow(swidget, callback)
    local element           = swidget.element
    local makeindex         = tonumber(element.attr.makeindex)  or 1
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local count             = tonumber(element.attr.count)
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local dblink            = element.attr.dblink
    local effectshow        = tonumber(element.attr.effectshow) or 1 -- 1只显示背包 2只显示内观 0不显示

    local itemData          = nil
    if not itemData then
        local EquipProxy    = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        itemData            = EquipProxy:GetEquipDataByMakeIndex(makeindex)
    end
    if not itemData then
        local BagProxy      = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        itemData            = BagProxy:GetItemDataByMakeIndex(makeindex)
    end

    if not itemData then
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        itemData            = QuickUseProxy:GetQucikUseDataByMakeIndex(makeindex)
    end

    if not itemData then
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        itemData = LookPlayerProxy:GetLookPlayerItemDataByMakeIndex(makeindex)
    end


    local contentSize       = cc.size(66,66)
    local widget            = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    if itemData then
        local info          = {}
        info.index          = itemData.Index
        info.itemData       = itemData
        info.look           = showtips == 1
        info.bgVisible      = bgtype == 1
        info.starLv         = showstar
        if not info.look and global.isWinPlayMode then
            info.noMouseTips = true
        end
        if effectshow == 2 then
            info.showModelEffect = true
        elseif effectshow == 0 then
            info.isShowEff = false
        end
        local goodsItem     = GoodsItem:create(info)
        widget:addChild(goodsItem)
        goodsItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        goodsItem:setScale(scale)
        goodsItem:setIconGrey(grey == 1)
        if count then
            goodsItem:setCount(count)
        end
        if dblink and string.len(dblink) then
            if not (showtips == 1) then
                goodsItem:addLookItemInfoEvent(nil, 2)
            end
            goodsItem:addDoubleEventListener(function()
                if callback then
                    local inputTable    = self:getInputTable(submitInput)
                    local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                    local jsonData      = {}
                    jsonData.Act        = dblink
                    jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    self:linkFuncWithCheckWords(callback, jsonData)
                end
            end)
        end
    end

    if link and string.len(link) > 0 and not dblink then
        local linkWidget    = global.SWidgetCache:generateRender("ccui.Widget")
        widget:addChild(linkWidget)
        linkWidget:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        linkWidget:setContentSize(contentSize)
        linkWidget:setTouchEnabled(true)
        linkWidget:setSwallowTouches(false)
        linkWidget:addClickEventListener(function()
            if callback then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end
        end)
    end
    
    return widget
end

function SUILoader:load_render_CostItem(swidget, callback)
    local element           = swidget.element
    local itemid            = tonumber(element.attr.itemid) or 1
    local itemcount         = tonumber(element.attr.itemcount) or 1

    local CostItemCell      = requireLayerUI("extra_layer/CostItemCell")
    local widget            = CostItemCell:create(string.format("%s#%s", itemid, itemcount))

    return widget
end

function SUILoader:load_render_Layout(swidget, callback)
    local element           = swidget.element
    local width             = tonumber(element.attr.width) or 1
    local height            = tonumber(element.attr.height) or 1
    local color             = tonumber(element.attr.color)
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox

    local widget = global.SWidgetCache:generateRender("ccui.Layout")
    widget:setContentSize(cc.size(width, height))
    widget:setBackGroundColorType(0)
    widget:setTouchEnabled(false)

    if DEBUG_MODE then
        widget:setBackGroundColorType(1)
        widget:setBackGroundColorOpacity(100)
        widget:setBackGroundColor(cc.Color3B.BLUE)
    end

    -- color
    if color then
        widget:setBackGroundColorType(1)
        widget:setBackGroundColorOpacity(255)
        widget:setBackGroundColor(GET_COLOR_BYID_C3B(color))
    end

    -- link
    if link and string.len(link) > 0 then
        widget:setTouchEnabled(true)
        widget:addClickEventListener(function()
            if callback then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end
        end)
    end

    return widget
end

function SUILoader:load_render_ITEMBOX(swidget, callback)
    local element           = swidget.element
    local width             = tonumber(element.attr.width) or 1
    local height            = tonumber(element.attr.height) or 1
    local boxindex          = tonumber(element.attr.boxindex)
    local img               = element.attr.img
    local stdmode           = element.attr.stdmode


    local img       = SUIHelper.fixImageFileName(img)
    local fullPath  = string.format(getResFullPath("res/%s"), img)
    
    local widget    = nil
    if img and img ~= "" and global.FileUtilCtl:isFileExist(fullPath) then
        widget      = global.SWidgetCache:generateRender("ccui.ImageView")
    else
        widget      = ccui.ImageView:create()
    end

    widget:loadTexture(fullPath)
    widget:ignoreContentAdaptWithSize(false)
    widget:setContentSize(widget:getVirtualRendererSize())
    widget:setCapInsets(cc.rect(0, 0, 0, 0))
    widget:setScale9Enabled(false)
    widget:setTouchEnabled(true)

    -- 
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local function addItemToITEMBOX(touchPos)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName      = ItemMoveProxy.ItemGoTo.ITEMBOX
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

    
    -- 
    self:addMouseOverTips(widget, element)

    -- 加入管理
    global.Facade:sendNotification(global.NoticeTable.SUIITEMBOXWidgetAdd, {boxindex = boxindex, widget = widget})

    return widget
end

function SUILoader:load_render_EquipShow(swidget, callback)
    local element           = swidget.element
    local index             = tonumber(element.attr.index) or 0
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local dblink            = element.attr.dblink
    local effectshow        = tonumber(element.attr.effectshow) or 1 -- 1只显示背包 2只显示内观 0不显示

    local contentSize       = cc.size(66,66)
    
    local widget            = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)


    local EquipProxy        = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local equipData         = EquipProxy:GetEquipDataByPos(index)
    if equipData then
        local info          = {}
        info.index          = equipData.Index
        info.itemData       = equipData
        info.look           = showtips == 1
        info.bgVisible      = bgtype == 1
        info.starLv         = showstar
        if not info.look and global.isWinPlayMode then
            info.noMouseTips = true
        end
        if effectshow == 2 then
            info.showModelEffect = true
        elseif effectshow == 0 then
            info.isShowEff = false
        end
        local goodsItem     = GoodsItem:create(info)
        widget:addChild(goodsItem)
        goodsItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        goodsItem:setScale(scale)
        goodsItem:setIconGrey(grey == 1)

        if dblink and string.len(dblink) then
            if not (showtips == 1) then
                goodsItem:addLookItemInfoEvent(nil, 2)
            end
            goodsItem:addDoubleEventListener(function()
                if callback then
                    local inputTable    = self:getInputTable(submitInput)
                    local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                    local jsonData      = {}
                    jsonData.Act        = dblink
                    jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    self:linkFuncWithCheckWords(callback, jsonData)
                end
            end)
        end
    end

    if link and not dblink then
        local linkWidget    = global.SWidgetCache:generateRender("ccui.Widget")
        widget:addChild(linkWidget)
        linkWidget:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        linkWidget:setContentSize(contentSize)
        linkWidget:setTouchEnabled(true)
        linkWidget:setSwallowTouches(false)
        linkWidget:addClickEventListener(function()
            if callback then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end
        end)
    end

    
    return widget
end

function SUILoader:load_render_BAGITEMS(swidget, callback)
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
    local dblink                = element.attr.dblink
    local effectshow            = tonumber(element.attr.effectshow) or 1
    local exBind                = tonumber(element.attr.exbind) == 1
    local showtips              = (tonumber(element.attr.showtips) or 0) == 1
    local includeQuick          = (tonumber(element.attr.includequick) or 0) == 1
    local clickInterval         = (tonumber(element.attr.clickInterval) or 0) * 0.001

    local itemscaleX            = iwidth / 70
    local itemscaleY            = iheight / 70

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

        -- 绑定过滤
        if exBind and CheckItemisBind(item) then
            return false
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
        if condition == "*" then
            return true
        end
        for _, v in pairs(conditionT) do
            if v.StdMode == item.StdMode and (not v.Shape or v.Shape == item.Shape) then
                return true
            end
        end

        if condition2 then
            if tonumber(item.sDivParam2) and tonumber(item.sDivParam2) == tonumber(condition2) then
                return true
            elseif string.find(tostring(condition2), "#") then
                local paramList = string.split(tostring(condition2), "#")
                for _, param in ipairs(paramList) do
                    if tonumber(param) == tonumber(item.sDivParam2) then
                        return true
                    end
                end
            end
        end
        return false
    end

    -- 是否选中
    local selects               = {}
    local slices                = ssplit(select, ",")
    for _, v in pairs(slices) do
        tinsert(selects, tonumber(v))
    end
    local function selectAble(item)
        for _, v in pairs(selects) do
            if v == item.MakeIndex then
                return true
            end
        end
        return false
    end


    local itemWid               = iwidth
    local itemHei               = iheight
    local col                   = math.ceil(count / row)
    local contentSize           = cc.size(col * itemWid, row * itemHei)

    local widget                = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    -- 
    local boxes = {}
    for i = 1, count do
        local x                 = ((i - 1) % col + 0.5) * itemWid
        local y                 = contentSize.height - (mfloor((i - 1) / col) + 0.5) * itemHei
        local iimg              = (iimg and iimg ~= "") and SUIHelper.fixImageFileName(iimg) or "public/1900000664.png"
        local fullPath          = string.format(getResFullPath("res/%s"), iimg)
        local imageBG           = ccui.ImageView:create()
        widget:addChild(imageBG)
        imageBG:loadTexture(fullPath)
        GUI:Image_setScale9Slice(imageBG, 21, 22, 21, 22)
	    GUI:setContentSize(imageBG, itemWid, itemHei)        
        imageBG:setTouchEnabled(false)
        imageBG:setAnchorPoint(cc.p(0.5, 0.5))
        imageBG:setPosition(cc.p(x, y))
        tinsert(boxes, imageBG)
    end

    -- bag items
    local BagProxy              = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local items                 = {}
    local BagMaxNum = BagProxy:GetMaxBag()
    for i = 1, BagMaxNum do
        local itemMakeIndex     = BagProxy:GetMakeIndexByBagPos(i)
        if itemMakeIndex then
            local itemData      = BagProxy:GetItemDataByMakeIndex(itemMakeIndex)
            if itemData and conditionAble(itemData) then
                tinsert(items, itemData)
            end
        end
    end

    if includeQuick then
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        local quickUseData = QuickUseProxy:GetQuickUseData()
        for _, itemData in pairs(quickUseData) do
            if itemData and conditionAble(itemData) then
                tinsert(items, itemData)
            end
        end
    end
    -- 

    -- show
    for index, item in ipairs(items) do
        local imageBG           = boxes[index]
        if imageBG then
            local size          = imageBG:getContentSize()

            -- 道具图标
            local info = {index = item.Index, itemData = item, starLv = showstar}
            if effectshow == 2 then
                info.showModelEffect = true
            elseif effectshow == 0 then
                info.isShowEff = false
            end
            info.look           = showtips
            if not info.look and global.isWinPlayMode then
                info.noMouseTips = true
            end
            local goodsItem     = GoodsItem:create(info)
            imageBG:addChild(goodsItem)
            goodsItem:setPosition(cc.p(size.width/2, size.height/2))
            goodsItem._canLooks = true
            goodsItem:addLookItemInfoEvent(nil, 1)
            goodsItem:setScaleX(itemscaleX)
            goodsItem:setScaleY(itemscaleY)
            
            -- link
            if link and string.len(link) > 0 then
                goodsItem:addTouchEventListener(function()
                    if clickInterval > 0 then
                        goodsItem:DelayTouchEnabled(clickInterval)
                    end
                    local selected          = clone(selects)
                    if selecttype == 0 then
                        -- 多选
                        if selectAble(item) then
                            for key, value in pairs(selected) do
                                if item.MakeIndex == value then
                                    table.remove(selected, key)
                                    break
                                end
                            end
                        else
                            tinsert(selected, item.MakeIndex)
                        end
                    else
                        -- 单选
                        if selectAble(item) then
                            selected = {}
                        else
                            selected = {item.MakeIndex}
                        end
                    end

                    local jsonData          = {}
                    jsonData.Act            = link
                    jsonData.SelectItemID   = table.concat(selected, ",")
                    callback(jsonData)
                end, 2)
            end

            -- 选中
            if selectAble(item) then
                local imageS    = ccui.ImageView:create()
                imageBG:addChild(imageS)
                imageS:loadTexture(global.MMO.PATH_RES_PUBLIC .. "1900000678_2.png")
                imageS:ignoreContentAdaptWithSize(true)
                imageS:setCapInsets(cc.rect(0, 0, 0, 0))
                imageS:setScale9Enabled(false)
                imageS:setTouchEnabled(false)
                imageS:setAnchorPoint(cc.p(0.5,0.5))
                imageS:setPosition(cc.p(size.width/2, size.height/2))
                imageS:setScaleX(itemscaleX)
                imageS:setScaleY(itemscaleY)
            end

            if dblink and string.len(dblink) then
                goodsItem:addDoubleEventListener(function()
                    local jsonData          = {}
                    jsonData.Act            = dblink
                    jsonData.SelectItemID   = item.MakeIndex
                    callback(jsonData)
                end)
            end
        end
    end

    return widget
end

function SUILoader:load_render_EQUIPITEMS(swidget, callback)
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
    local effectshow            = tonumber(element.attr.effectshow) or 1 -- 1只显示背包 2只显示内观 0不显示

    local itemscaleX            = iwidth / 70
    local itemscaleY            = iheight / 70

    -- 装备位
    local equipPositions        = {}
    local slices                = ssplit(positions, ",")
    for _, v in ipairs(slices) do
        tinsert(equipPositions, tonumber(v))
    end

    -- 是否选中
    local selects               = {}
    local slices                = ssplit(select, ",")
    for _, v in pairs(slices) do
        tinsert(selects, tonumber(v))
    end
    local function selectAble(item)
        for _, v in pairs(selects) do
            if v == item.MakeIndex then
                return true
            end
        end
        return false
    end


    local itemWid               = iwidth
    local itemHei               = iheight
    local col                   = math.ceil(count / row)
    local contentSize           = cc.size(col * itemWid, row * itemHei)

    local widget                = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    -- 
    local boxes = {}
    for i = 1, count do
        local x                 = ((i - 1) % col + 0.5) * itemWid
        local y                 = contentSize.height - (mfloor((i - 1) / col) + 0.5) * itemHei
        local iimg              = (iimg and iimg ~= "") and SUIHelper.fixImageFileName(iimg) or "public/1900000664.png"
        local fullPath          = string.format(getResFullPath("res/%s"), iimg)
        local imageBG           = ccui.ImageView:create()
        widget:addChild(imageBG)
        imageBG:loadTexture(fullPath)
        GUI:Image_setScale9Slice(imageBG, 21, 22, 21, 22)
	    GUI:setContentSize(imageBG, itemWid, itemHei)
        imageBG:setTouchEnabled(false)
        imageBG:setAnchorPoint(cc.p(0.5, 0.5))
        imageBG:setPosition(cc.p(x, y))
        tinsert(boxes, imageBG)
    end

    -- items
    local items                 = {}
    local EquipProxy            = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    if positions == "*" then
        local equipTypeConfig   = EquipProxy:GetEquipTypeConfig()
        for equipPos = equipTypeConfig.Equip_Type_Dress, equipTypeConfig.Equip_Type_Shield do
            local equipData     = EquipProxy:GetEquipDataByPos(equipPos)
            if equipData then
                tinsert(items, equipData)
            end
        end
    else
        for _, equipPos in ipairs(equipPositions) do
            local equipData     = EquipProxy:GetEquipDataByPos(equipPos)
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

            -- 道具图标
            local info = {index = item.Index, itemData = item, starLv = showstar}
            if effectshow == 2 then
                info.showModelEffect = true
            elseif effectshow == 0 then
                info.isShowEff = false
            end
            local goodsItem     = GoodsItem:create(info)
            imageBG:addChild(goodsItem)
            goodsItem:setPosition(cc.p(size.width/2, size.height/2))
            goodsItem._canLooks = true
            goodsItem:addLookItemInfoEvent(nil, 1)
            goodsItem:setScaleX(itemscaleX)
            goodsItem:setScaleY(itemscaleY)
            
            -- link
            if link and string.len(link) > 0 then
                goodsItem:addTouchEventListener(function()
                    local selected          = clone(selects)
                    if selecttype == 0 then
                        -- 多选
                        if selectAble(item) then
                            for key, value in pairs(selected) do
                                if item.MakeIndex == value then
                                    table.remove(selected, key)
                                    break
                                end
                            end
                        else
                            tinsert(selected, item.MakeIndex)
                        end
                    else
                        -- 单选
                        if selectAble(item) then
                            selected = {}
                        else
                            selected = {item.MakeIndex}
                        end
                    end

                    local jsonData          = {}
                    jsonData.Act            = link
                    jsonData.SelectItemID   = table.concat(selected, ",")
                    callback(jsonData)
                end, 2)
            end

            -- 选中
            if selectAble(item) then
                local imageS    = ccui.ImageView:create()
                imageBG:addChild(imageS)
                imageS:loadTexture(global.MMO.PATH_RES_PUBLIC .. "1900000678_2.png")
                imageS:ignoreContentAdaptWithSize(true)
                imageS:setCapInsets(cc.rect(0, 0, 0, 0))
                imageS:setScale9Enabled(false)
                imageS:setTouchEnabled(false)
                imageS:setAnchorPoint(cc.p(0.5,0.5))
                imageS:setPosition(cc.p(size.width/2, size.height/2))
                imageS:setScaleX(itemscaleX)
                imageS:setScaleY(itemscaleY)
            end
        end
    end

    return widget
end

function SUILoader:load_render_TIMETIPS(swidget, callback)
    local element           = swidget.element
    local size              = tonumber(element.attr.size) or defaultFontSize
    local color             = tonumber(element.attr.color) or defaultColorID
    local time              = tonumber(element.attr.time) or 0
    local outline           = tonumber(element.attr.outline) or defaultOutline
    local outlinecolor      = tonumber(element.attr.outlinecolor) or defaultOutlineC
    local link              = element.attr.link

    local widget            = ccui.Text:create()
    widget:setString("")
    widget:setFontSize(size)
    widget:setFontName(defaultFontPath)
    widget:setTextColor(GET_COLOR_BYID_C3B(color))
    widget:enableOutline(GET_COLOR_BYID_C3B(outlinecolor), outline)

    local endTime           = time + GetServerTime()
    local function scheduleCB()
        local remaining = math.max(endTime - GetServerTime(), 0)
        widget:setString(SecondToHMS(remaining, true))
        if remaining <= 0 then
            -- link
            if link and string.len(link) > 0 then
                if callback then
                    local jsonData = {}
                    jsonData.Act   = link
                    callback(jsonData)
                end
            end
            widget:stopAllActions()
        end
    end
    schedule(widget, scheduleCB, 1)
    scheduleCB()
    
    return widget
end

function SUILoader:load_render_LoadingBar(swidget, callback)
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
    local offsetX           = element.attr.offsetX or 0
    local offsetY           = element.attr.offsetY or 0
    local endPercent        = tonumber(element.attr.endper) or 100

    local imgBg             = SUIHelper.fixImageFileName(loadBgImg)
    local imgBar            = SUIHelper.fixImageFileName(loadBarImg)
    local fullPathBG        = (imgBg and imgBg ~= "") and string.format(getResFullPath("res/%s"), imgBg) or ""
    local fullPathBAR       = (imgBar and imgBar ~= "") and string.format(getResFullPath("res/%s"), imgBar) or ""  

    local widget = ccui.ImageView:create()
    widget:ignoreContentAdaptWithSize(false)
    if fullPathBG and  fullPathBG ~= "" and global.FileUtilCtl:isFileExist(fullPathBG) then
        widget:loadTexture(fullPathBG)
    end

    local LoadingBar = ccui.LoadingBar:create()
    if fullPathBAR and fullPathBAR ~= "" and global.FileUtilCtl:isFileExist(fullPathBAR) then
        LoadingBar:loadTexture(fullPathBAR)
    end
    LoadingBar:ignoreContentAdaptWithSize(false)
    LoadingBar:setPercent(startPercent)
    if direction == 1 then
        LoadingBar:setDirection(1)
    end
    LoadingBar:setPosition(cc.p(widget:getContentSize().width/2 + offsetX, widget:getContentSize().height/2 + offsetY))
    widget:addChild(LoadingBar)

    local percentText = ccui.Text:create()
    percentText:setString(string.format(GET_STRING(1053), startPercent, 100))
    percentText:setAnchorPoint(0.5, 0.5)
    percentText:setPosition(cc.p(widget:getContentSize().width/2, widget:getContentSize().height/2))
    percentText:setFontSize(size)
    percentText:setFontName(defaultFontPath)
    percentText:setTextColor(GET_COLOR_BYID_C3B(color))
    percentText:enableOutline(GET_COLOR_BYID_C3B(outlinecolor), outline)
    widget:addChild(percentText)

    LoadingBar:stopAllActions()
    local percent   = startPercent
    local function scheduleCB()
        percent = percent + loadValue
        
        percent = math.min(percent, endPercent)
        LoadingBar:setPercent(percent)
        local curPercent = mfloor(percent/100 * 100)
        percentText:setString(string.format(GET_STRING(1053), curPercent, 100))

        -- 
        if percent >= endPercent  then
            LoadingBar:stopAllActions()

            if link and string.len(link) > 0 then
                if callback then
                    local inputTable    = self:getInputTable(submitInput)
                    local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                    local jsonData      = {}
                    jsonData.Act        = link
                    jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    self:linkFuncWithCheckWords(callback, jsonData)
                end
            end

        end
    end
    schedule(LoadingBar, scheduleCB, interval)
    scheduleCB()

    return widget
end

function SUILoader:load_render_CircleBar(swidget, callback)
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

    local widget = ccui.ImageView:create()
    widget:ignoreContentAdaptWithSize(false)
    if fullPathBG and fullPathBG ~= "" and global.FileUtilCtl:isFileExist(fullPathBG) then
        widget:loadTexture(fullPathBG)
    end

    local contentSize = widget:getContentSize()
    if fullPathBAR and fullPathBAR ~= "" and global.FileUtilCtl:isFileExist(fullPathBAR) then
        local loadingBar = cc.ProgressTimer:create(cc.Sprite:create(fullPathBAR))
        widget:addChild(loadingBar)
        loadingBar:setPosition(cc.p(contentSize.width / 2 + offsetX, contentSize.height / 2 + offsetY))
        loadingBar:setPercentage(startPercent)
        local function loadEndCallBack()
            loadingBar:stopAllActions()

            if link and string.len(link) > 0 then
                if callback then
                    local inputTable    = self:getInputTable(submitInput)
                    local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                    local jsonData      = {}
                    jsonData.Act        = link
                    jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    self:linkFuncWithCheckWords(callback, jsonData)
                end
            end
        end
        loadingBar:runAction(
            cc.Sequence:create(
                cc.ProgressFromTo:create(time, startPercent, endPercent),
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(loadEndCallBack)
            )
        )
    end
    
    return widget
end

function SUILoader:load_render_PercentImg(swidget, callback)
    local element           = swidget.element
    local direction         = tonumber(element.attr.direction) or 0  -- 0 从左到右 1从右到左 2从上往下 3从下往上
    local loadImg           = element.attr.img or "public/bg_szjm_03_2.png"
    local minValue          = tonumber(element.attr.minValue) or 100
    local maxValue          = tonumber(element.attr.maxValue) or 100
    local percent           = mfloor( minValue/maxValue * 100) or 100

    local img               = SUIHelper.fixImageFileName(loadImg)
    local fullPath          = (img and img ~= "") and string.format(getResFullPath("res/%s"), img) or ""
   
    local widget = ccui.LoadingBar:create()
    if fullPath and fullPath ~= "" and global.FileUtilCtl:isFileExist(fullPath) then
        widget:loadTexture(fullPath)
    end
    widget:ignoreContentAdaptWithSize(false)

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
        widget:setDirection(direction)
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

    -- 加入元变量组件管理
    local isMateValue = false
    if not tonumber(element.attr.minValue) or not tonumber(element.attr.maxValue) then
        local metaValue = {}
        local content = element.attr.minValue
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
        local content2 = element.attr.maxValue
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

function SUILoader:load_render_UIModel(swidget,callback)
    local element           = swidget.element
    local sex               = tonumber(element.attr.sex) or 0 
    local scale             = tonumber(element.attr.scale) or 1

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

    local UIModel = CreateStaticUIModel(sex, feature, scale, {ignoreStaticScale = true})
    if UIModel then
        return UIModel
    end
end

---- 英雄相关
function SUILoader:load_render_HEROEquipShow(swidget, callback)
    local element           = swidget.element
    local index             = tonumber(element.attr.index) or 0
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local dblink            = element.attr.dblink
    local effectshow        = tonumber(element.attr.effectshow) or 1

    local contentSize       = cc.size(66,66)
    
    local widget            = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    local equipData = HeroEquipProxy:GetEquipDataByPos(index)
    if equipData then
        local info          = {}
        info.index          = equipData.Index
        info.itemData       = equipData
        info.look           = showtips == 1
        info.bgVisible      = bgtype == 1
        info.starLv         = showstar
        if not info.look and global.isWinPlayMode then
            info.noMouseTips = true
        end
        if effectshow == 2 then
            info.showModelEffect = true
        elseif effectshow == 0 then
            info.isShowEff = false
        end
        info.from           = ItemMoveProxy.ItemFrom.HERO_EQUIP
        local goodsItem     = GoodsItem:create(info)
        widget:addChild(goodsItem)
        goodsItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        goodsItem:setScale(scale)
        goodsItem:setIconGrey(grey == 1)

        if dblink and string.len(dblink) then
            if not (showtips == 1) then
                goodsItem:addLookItemInfoEvent(nil, 2)
            end
            goodsItem:addDoubleEventListener(function()
                if callback then
                    local inputTable    = self:getInputTable(submitInput)
                    local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                    local jsonData      = {}
                    jsonData.Act        = dblink
                    jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    callback(jsonData)
                end
            end)
        end
    end

    if link and not dblink then
        local linkWidget    = global.SWidgetCache:generateRender("ccui.Widget")
        widget:addChild(linkWidget)
        linkWidget:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        linkWidget:setContentSize(contentSize)
        linkWidget:setTouchEnabled(true)
        linkWidget:setSwallowTouches(false)
        linkWidget:addClickEventListener(function()
            if callback then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end
        end)
    end
    
    return widget
end

function SUILoader:load_render_HEROEQUIPITEMS(swidget, callback)
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
    local effectshow            = tonumber(element.attr.effectshow) or 1

    local itemscaleX            = iwidth / 70
    local itemscaleY            = iheight / 70

    -- 装备位
    local equipPositions        = {}
    local slices                = ssplit(positions, ",")
    for _, v in ipairs(slices) do
        tinsert(equipPositions, tonumber(v))
    end

    -- 是否选中
    local selects               = {}
    local slices                = ssplit(select, ",")
    for _, v in pairs(slices) do
        tinsert(selects, tonumber(v))
    end
    local function selectAble(item)
        for _, v in pairs(selects) do
            if v == item.MakeIndex then
                return true
            end
        end
        return false
    end


    local itemWid               = iwidth
    local itemHei               = iheight
    local col                   = math.ceil(count / row)
    local contentSize           = cc.size(col * itemWid, row * itemHei)

    local widget                = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    -- 
    local boxes = {}
    for i = 1, count do
        local x                 = ((i - 1) % col + 0.5) * itemWid
        local y                 = contentSize.height - (mfloor((i - 1) / col) + 0.5) * itemHei
        local iimg              = (iimg and iimg ~= "") and SUIHelper.fixImageFileName(iimg) or "public/1900000664.png"
        local fullPath          = string.format(getResFullPath("res/%s"), iimg)
        local imageBG           = ccui.ImageView:create()
        widget:addChild(imageBG)
        imageBG:loadTexture(fullPath)
        GUI:Image_setScale9Slice(imageBG, 21, 22, 21, 22)
	    GUI:setContentSize(imageBG, itemWid, itemHei)
        imageBG:setTouchEnabled(false)
        imageBG:setAnchorPoint(cc.p(0.5, 0.5))
        imageBG:setPosition(cc.p(x, y))
        tinsert(boxes, imageBG)
    end

    -- items
    local items                 = {}
    local HeroEquipProxy            = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    if positions == "*" then
        local equipTypeConfig   = HeroEquipProxy:GetEquipTypeConfig()
        for equipPos = equipTypeConfig.Equip_Type_Dress, equipTypeConfig.Equip_Type_Shield do
            local equipData     = HeroEquipProxy:GetEquipDataByPos(equipPos)
            if equipData then
                tinsert(items, equipData)
            end
        end
    else
        for _, equipPos in ipairs(equipPositions) do
            local equipData     = HeroEquipProxy:GetEquipDataByPos(equipPos)
            if equipData then
                tinsert(items, equipData)
            end
        end
    end

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    -- show
    for index, item in ipairs(items) do
        local imageBG           = boxes[index]
        if imageBG then
            local size          = imageBG:getContentSize()

            -- 道具图标
            local info = {index = item.Index, itemData = item, starLv = showstar}
            if effectshow == 2 then
                info.showModelEffect = true
            elseif effectshow == 0 then
                info.isShowEff = false
            end
            info.from           = ItemMoveProxy.ItemFrom.HERO_EQUIP
            local goodsItem     = GoodsItem:create(info)
            imageBG:addChild(goodsItem)
            goodsItem:setPosition(cc.p(size.width/2, size.height/2))
            goodsItem._canLooks = true
            goodsItem:addLookItemInfoEvent(nil, 1)
            goodsItem:setScaleX(itemscaleX)
            goodsItem:setScaleY(itemscaleY)
            
            -- link
            if link and string.len(link) > 0 then
                goodsItem:addTouchEventListener(function()
                    local selected          = clone(selects)
                    if selecttype == 0 then
                        -- 多选
                        if selectAble(item) then
                            for key, value in pairs(selected) do
                                if item.MakeIndex == value then
                                    table.remove(selected, key)
                                    break
                                end
                            end
                        else
                            tinsert(selected, item.MakeIndex)
                        end
                    else
                        -- 单选
                        if selectAble(item) then
                            selected = {}
                        else
                            selected = {item.MakeIndex}
                        end
                    end

                    local jsonData          = {}
                    jsonData.Act            = link
                    jsonData.SelectItemID   = table.concat(selected, ",")
                    callback(jsonData)
                end, 2)
            end

            -- 选中
            if selectAble(item) then
                local imageS    = ccui.ImageView:create()
                imageBG:addChild(imageS)
                imageS:loadTexture(global.MMO.PATH_RES_PUBLIC .. "1900000678_2.png")
                imageS:ignoreContentAdaptWithSize(true)
                imageS:setCapInsets(cc.rect(0, 0, 0, 0))
                imageS:setScale9Enabled(false)
                imageS:setTouchEnabled(false)
                imageS:setAnchorPoint(cc.p(0.5,0.5))
                imageS:setPosition(cc.p(size.width/2, size.height/2))
                imageS:setScaleX(itemscaleX)
                imageS:setScaleY(itemscaleY)
            end
        end
    end

    return widget
end

function SUILoader:load_render_HERODBItemShow(swidget, callback)
    local element           = swidget.element
    local makeindex         = tonumber(element.attr.makeindex)  or 1
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local count             = tonumber(element.attr.count)
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local dblink            = element.attr.dblink
    local effectshow        = tonumber(element.attr.effectshow) or 1

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local itemData          = nil
    local from              = nil
    if not itemData then
        local HeroEquipProxy    = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        itemData                = HeroEquipProxy:GetEquipDataByMakeIndex(makeindex)
        if itemData then
            from = ItemMoveProxy.ItemFrom.HERO_EQUIP
        end
    end
    if not itemData then
        local HeroBagProxy      = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
        itemData                = HeroBagProxy:GetItemDataByMakeIndex(makeindex)
        if itemData then
            from = ItemMoveProxy.ItemFrom.HERO_BAG
        end
    end

    if not itemData then
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        itemData = LookPlayerProxy:GetLookPlayerItemDataByMakeIndex(makeindex)
    end

    local contentSize       = cc.size(66,66)
    local widget            = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    if itemData then
        local info          = {}
        info.index          = itemData.Index
        info.itemData       = itemData
        info.look           = showtips == 1
        info.bgVisible      = bgtype == 1
        info.starLv         = showstar
        if not info.look and global.isWinPlayMode then
            info.noMouseTips = true
        end
        if effectshow == 2 then
            info.showModelEffect = true
        elseif effectshow == 0 then
            info.isShowEff = false
        end
        info.from           = from
        local goodsItem     = GoodsItem:create(info)
        widget:addChild(goodsItem)
        goodsItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        goodsItem:setScale(scale)
        goodsItem:setIconGrey(grey == 1)
        if count then
            goodsItem:setCount(count)
        end
        if dblink and string.len(dblink) then
            if not (showtips == 1) then
                goodsItem:addLookItemInfoEvent(nil, 2)
            end
            goodsItem:addDoubleEventListener(function()
                if callback then
                    local inputTable    = self:getInputTable(submitInput)
                    local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                    local jsonData      = {}
                    jsonData.Act        = dblink
                    jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    self:linkFuncWithCheckWords(callback, jsonData)
                end
            end)
        end
    end

    if link and string.len(link) > 0 and not dblink then
        local linkWidget    = global.SWidgetCache:generateRender("ccui.Widget")
        widget:addChild(linkWidget)
        linkWidget:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        linkWidget:setContentSize(contentSize)
        linkWidget:setTouchEnabled(true)
        linkWidget:setSwallowTouches(false)
        linkWidget:addClickEventListener(function()
            if callback then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end
        end)
    end
    
    return widget
end

function SUILoader:load_render_HEROBAGITEMS(swidget, callback)
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
    local dblink                = element.attr.dblink
    local effectshow            = tonumber(element.attr.effectshow) or 1

    local itemscaleX            = iwidth / 70
    local itemscaleY            = iheight / 70

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
        if condition == "*" then
            return true
        end
        for _, v in pairs(conditionT) do
            if v.StdMode == item.StdMode and (not v.Shape or v.Shape == item.Shape) then
                return true
            end
        end
        return false
    end

    -- 是否选中
    local selects               = {}
    local slices                = ssplit(select, ",")
    for _, v in pairs(slices) do
        tinsert(selects, tonumber(v))
    end
    local function selectAble(item)
        for _, v in pairs(selects) do
            if v == item.MakeIndex then
                return true
            end
        end
        return false
    end


    local itemWid               = iwidth
    local itemHei               = iheight
    local col                   = math.ceil(count / row)
    local contentSize           = cc.size(col * itemWid, row * itemHei)

    local widget                = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    -- 
    local boxes = {}
    for i = 1, count do
        local x                 = ((i - 1) % col + 0.5) * itemWid
        local y                 = contentSize.height - (mfloor((i - 1) / col) + 0.5) * itemHei
        local iimg              = (iimg and iimg ~= "") and SUIHelper.fixImageFileName(iimg) or "public/1900000664.png"
        local fullPath          = string.format(getResFullPath("res/%s"), iimg)
        local imageBG           = ccui.ImageView:create()
        widget:addChild(imageBG)
        imageBG:loadTexture(fullPath)
        GUI:Image_setScale9Slice(imageBG, 21, 22, 21, 22)
	    GUI:setContentSize(imageBG, itemWid, itemHei)
        imageBG:setTouchEnabled(false)
        imageBG:setAnchorPoint(cc.p(0.5, 0.5))
        imageBG:setPosition(cc.p(x, y))
        tinsert(boxes, imageBG)
    end

    -- bag items
    local HeroBagProxy          = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    local items                 = {}
    for i = 1, global.MMO.MAX_ITEM_NUMBER do
        local itemMakeIndex     = HeroBagProxy:GetMakeIndexByBagPos(i)
        if itemMakeIndex then
            local itemData      = HeroBagProxy:GetItemDataByMakeIndex(itemMakeIndex)
            if itemData and conditionAble(itemData) then
                tinsert(items, itemData)
            end
        end
    end
    -- 

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    -- show
    for index, item in ipairs(items) do
        local imageBG           = boxes[index]
        if imageBG then
            local size          = imageBG:getContentSize()

            -- 道具图标
            local info = {index = item.Index, itemData = item, starLv = showstar}
            if effectshow == 2 then
                info.showModelEffect = true
            elseif effectshow == 0 then
                info.isShowEff = false
            end
            info.from           = ItemMoveProxy.ItemFrom.HERO_BAG
            local goodsItem     = GoodsItem:create(info)
            imageBG:addChild(goodsItem)
            goodsItem:setPosition(cc.p(size.width/2, size.height/2))
            goodsItem._canLooks = true
            goodsItem:addLookItemInfoEvent(nil, 1)
            goodsItem:setScaleX(itemscaleX)
            goodsItem:setScaleY(itemscaleY)
            
            -- link
            if link and string.len(link) > 0 then
                goodsItem:addTouchEventListener(function()
                    local selected          = clone(selects)
                    if selecttype == 0 then
                        -- 多选
                        if selectAble(item) then
                            for key, value in pairs(selected) do
                                if item.MakeIndex == value then
                                    table.remove(selected, key)
                                    break
                                end
                            end
                        else
                            tinsert(selected, item.MakeIndex)
                        end
                    else
                        -- 单选
                        if selectAble(item) then
                            selected = {}
                        else
                            selected = {item.MakeIndex}
                        end
                    end

                    local jsonData          = {}
                    jsonData.Act            = link
                    jsonData.SelectItemID   = table.concat(selected, ",")
                    callback(jsonData)
                end, 2)
            end

            -- 选中
            if selectAble(item) then
                local imageS    = ccui.ImageView:create()
                imageBG:addChild(imageS)
                imageS:loadTexture(global.MMO.PATH_RES_PUBLIC .. "1900000678_2.png")
                imageS:ignoreContentAdaptWithSize(true)
                imageS:setCapInsets(cc.rect(0, 0, 0, 0))
                imageS:setScale9Enabled(false)
                imageS:setTouchEnabled(false)
                imageS:setAnchorPoint(cc.p(0.5,0.5))
                imageS:setPosition(cc.p(size.width/2, size.height/2))
                imageS:setScaleX(itemscaleX)
                imageS:setScaleY(itemscaleY)
            end

            if dblink and string.len(dblink) then
                goodsItem:addDoubleEventListener(function()
                    local jsonData          = {}
                    jsonData.Act            = dblink
                    jsonData.SelectItemID   = item.MakeIndex
                    callback(jsonData)
                end)
            end
        end
    end

    return widget
end
---

function SUILoader:load_render_QuickTextView(swidget, callback)
    local element           = swidget.element
    local text              = element.attr.text or ""
    local size              = tonumber(element.attr.size) or defaultFontSize
    local color             = element.attr.color or defaultColorID
    local outline           = tonumber(element.attr.outline) or defaultOutline
    local outlinecolor      = tonumber(element.attr.outlinecolor) or defaultOutlineC
    local direction         = tonumber(element.attr.direction) or 1
    local bounce            = tonumber(element.attr.bounce) or 1
    local margin            = tonumber(element.attr.margin) or 0
    local width             = tonumber(element.attr.width) or 800
    local height            = tonumber(element.attr.height) or global.Director:getVisibleSize().height
    local count             = tonumber(element.attr.count) or 1

    local function createText( str )
        local item = global.SWidgetCache:generateRender("ccui.Text")
        item:setScale(1)
        item:setString(str)
        item:setFontSize(size)
        item:setFontName(defaultFontPath)
        item:setTextColor(GET_COLOR_BYID_C3B(color))
        item:setTouchEnabled(false)
        item:stopAllActions()
        item:disableEffect(1)
        item:disableEffect(6)
        item:getVirtualRenderer():setMaxLineWidth(0)
        item:enableOutline(GET_COLOR_BYID_C3B(outlinecolor), outline)

        return item
    end

    local function createItem(loadText, wid, hei)
        local panel =  global.SWidgetCache:generateRender("ccui.Layout")
        panel:setClippingEnabled(true)
        panel:setContentSize(cc.size(wid, hei))
        for i = 1, count do
            if loadText and next(loadText) and loadText[i] then
                local str = loadText[i]
                local item = global.SWidgetCache:generateRender("ccui.Text")
                item:setScale(1)
                item:setString(str)
                item:setFontSize(size)
                item:setFontName(global.MMO.PATH_FONT)
                item:setTextColor(GET_COLOR_BYID_C3B(color))
                item:setTouchEnabled(false)
                item:stopAllActions()
                item:disableEffect(1)
                item:disableEffect(6)
                item:getVirtualRenderer():setMaxLineWidth(0)
                item:enableOutline(GET_COLOR_BYID_C3B(outlinecolor), outline)
                item:setAnchorPoint(cc.p(0,0))
                item:setPosition(cc.p(wid/count*(i-1), 0))
                panel:addChild(item)
            end
        end
        return panel
    end

    local widget = global.SWidgetCache:generateRender("ccui.ListView") 
    widget:ignoreContentAdaptWithSize(false)
    widget:setClippingEnabled(true)
    widget:setClippingType(0)
    widget:setTouchEnabled(true)
    widget:setDirection(direction)
    widget:setGravity(0)
    widget:setItemsMargin(margin)
    widget:setBounceEnabled(bounce == 1)
    widget:setBackGroundColorType(0)
    widget:stopAllActions()

    local textList = string.split(text, "\\")
    local itemHei = 10
    if textList and textList[1] then
        itemHei = createText(textList[1]):getContentSize().height
    end
    local screenHeight = height-- global.Director:getVisibleSize().height
    local limitSize = math.ceil(screenHeight/itemHei)

    local loadText = clone(textList)
    local loadNum = 0
    local function loadItem( ... )
        local lastIndex = #widget:getItems() - 1
        while next(loadText) and loadNum < limitSize do
            loadNum = loadNum + 1
            local cell_data = {}
            cell_data.wid = width
            cell_data.hei = itemHei

            local strList = {}
            for i = 1, count do
                if loadText and next(loadText) then
                    table.insert( strList, table.remove( loadText,1 ))
                end
            end
            cell_data.createCell = function ()
                local cell = createItem(strList, cell_data.wid, cell_data.hei)
                return cell
            end

            local quickCell = QuickCell:Create(cell_data)
            widget:pushBackCustomItem(quickCell)
        end
        if lastIndex >= 0 then
            widget:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
        end
    end

    loadItem()
    local loadForce = true
    widget:addScrollViewEventListener(function(sender, eventType)
        local itemNum = #sender:getItems()
        local BottomItem = sender:getBottommostItemInCurrentView()
        local innerPos = widget:getInnerContainerPosition()
        if (eventType ==  1 or ((eventType == 10 or eventType == 9) and innerPos.y == 0)) and next(loadText) then 
            loadNum = 0
            if loadForce then
                loadForce = false
                PerformWithDelayGlobal( function()
                    loadForce = true
                end, 0.5 )
                loadItem()
            end
        end
    end)
    widget:addMouseScrollPercent()
    return widget
end

function SUILoader:load_render_RTextX(swidget, callback)
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


    local function textCB(str)
        if callback then
            local jsonData      = {}
            jsonData.Act        = str
            callback(jsonData)
        end
    end
    local ttfConfig = {
        outlineSize = outline,
        outlineColor = GET_COLOR_BYID_C3B(outlinecolor)
    }
    local SUI_RTEXT_FONT_PATH = SL:GetMetaValue("WINPLAYMODE") and SL:GetMetaValue("GAME_DATA","SUI_RTEXT_FONT_PATH") or nil
    local fontPath = SUI_RTEXT_FONT_PATH or defaultFontPath
    local widget = RichTextHelp:CreateRichTextWithXML(text, width, size, GET_COLOR_BYID(color), fontPath, textCB, SL:GetMetaValue("GAME_DATA","DEFAULT_VSPACE"))

    self:addMouseOverTips(widget, element)

    -- auto scroll
    if scrollWidth then
        local widgetSize   = widget:getContentSize()
        local scrollH      = scrollHeight or widgetSize.height
        local scrollLayout = global.SWidgetCache:generateRender("ccui.Layout")
        scrollLayout:setClippingEnabled(true)
        scrollLayout:setClippingType(0)
        scrollLayout:setContentSize(cc.size(scrollWidth, scrollH))
        scrollLayout:addChild(widget)
        widget:setAnchorPoint(cc.p(0, 0))
        widget:setPosition(cc.p(0, 0))
        if scrollWay == 0 then
            widget:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(scrollTime, cc.p(-widgetSize.width, 0)), 
                cc.MoveBy:create(0, cc.p(widgetSize.width, 0)))
            ))
        elseif scrollWay == 1 then
            widget:setAnchorPoint(cc.p(0, 1))
            widget:setPosition(cc.p(0, scrollH))
            widget:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(scrollTime, cc.p(0, widgetSize.height)),
                cc.MoveBy:create(0, cc.p(0, -widgetSize.height))
            )))
        end
        return scrollLayout
    end

    return widget
end

function SUILoader:load_render_DLINKITEMS(swidget, callback)
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
    
    local itemscaleX            = iwidth / 70
    local itemscaleY            = iheight / 70

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
        if condition == "*" then
            return true
        end
        for _, v in pairs(conditionT) do
            if v.StdMode == item.StdMode and (not v.Shape or v.Shape == item.Shape) then
                return true
            end
        end
        return false
    end

    local itemWid               = iwidth
    local itemHei               = iheight
    local col                   = math.ceil(count / row)
    local contentSize           = cc.size(col * itemWid, row * itemHei)

    local widget                = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    -- 
    local boxes = {}
    for i = 1, count do
        local x                 = ((i - 1) % col + 0.5) * itemWid
        local y                 = contentSize.height - (mfloor((i - 1) / col) + 0.5) * itemHei
        local iimg              = (iimg and iimg ~= "") and SUIHelper.fixImageFileName(iimg) or "public/1900000664.png"
        local fullPath          = string.format(getResFullPath("res/%s"), iimg)
        local imageBG           = ccui.ImageView:create()
        widget:addChild(imageBG)
        imageBG:loadTexture(fullPath)
        GUI:Image_setScale9Slice(imageBG, 21, 22, 21, 22)
	    GUI:setContentSize(imageBG, itemWid, itemHei)
        imageBG:setTouchEnabled(false)
        imageBG:setAnchorPoint(cc.p(0.5, 0.5))
        imageBG:setPosition(cc.p(x, y))
        tinsert(boxes, imageBG)
    end

    -- bag items
    local BagProxy              = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local items                 = {}
    local BagMaxNum = BagProxy:GetMaxBag()
    for i = 1, BagMaxNum do
        local itemMakeIndex     = BagProxy:GetMakeIndexByBagPos(i)
        if itemMakeIndex then
            local itemData      = BagProxy:GetItemDataByMakeIndex(itemMakeIndex)
            if itemData and conditionAble(itemData) then
                tinsert(items, itemData)
            end
        end
    end
    -- 

    -- show
    for index, item in ipairs(items) do
        local imageBG           = boxes[index]
        if imageBG then
            local size          = imageBG:getContentSize()

            -- 道具图标
            local goodsItem     = GoodsItem:create({index = item.Index, itemData = item, starLv = showstar,look = true})
            imageBG:addChild(goodsItem)
            goodsItem:setPosition(cc.p(size.width/2, size.height/2))
            goodsItem:setScaleX(itemscaleX)
            goodsItem:setScaleY(itemscaleY)
            
            -- link
            if link and string.len(link) > 0 then
                goodsItem:addDoubleEventListener(function()
                    local jsonData          = {}
                    jsonData.Act            = link
                    jsonData.SelectItemID   = item.MakeIndex
                    callback(jsonData)
                end)
            end
        end
    end

    return widget
end

function SUILoader:load_render_MKItemShow(swidget, callback)
    local element           = swidget.element
    local makeindex         = tonumber(element.attr.makeindex)  or 1
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local count             = tonumber(element.attr.count)
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local canmove           = tonumber(element.attr.canmove) or 0
    local effectshow        = tonumber(element.attr.effectshow) or 1 -- 1只显示背包 2只显示内观 0不显示

    local itemData          = nil
    if not itemData then
        local PetsEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.PetsEquipProxy)
        itemData             = PetsEquipProxy:GetEquipDataByMakeIndex(makeindex)
    end

    -- 人物
    if not itemData then
        local EquipProxy    = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        itemData            = EquipProxy:GetEquipDataByMakeIndex(makeindex)
    end
    if not itemData then
        local BagProxy      = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        itemData            = BagProxy:GetItemDataByMakeIndex(makeindex)
    end
    -- 英雄
    if not itemData then
        local HeroEquipProxy    = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        itemData                = HeroEquipProxy:GetEquipDataByMakeIndex(makeindex)
    end
    if not itemData then
        local HeroBagProxy      = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
        itemData                = HeroBagProxy:GetItemDataByMakeIndex(makeindex)
    end

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local contentSize       = cc.size(66,66)
    local widget            = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)

    if itemData then
        local info          = {}
        info.index          = itemData.Index
        info.itemData       = itemData
        -- info.look           = showtips == 1
        info.bgVisible      = bgtype == 1
        info.starLv         = showstar
        info.from           = ItemMoveProxy.ItemFrom.PETS_EQUIP
        info.movable        = false
        if effectshow == 2 then
            info.showModelEffect = true
        elseif effectshow == 0 then
            info.isShowEff = false
        end
        local goodsItem     = GoodsItem:create(info)
        widget:addChild(goodsItem)
        goodsItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        goodsItem:setScale(scale)
        goodsItem:setIconGrey(grey == 1)
        if count then
            goodsItem:setCount(count)
        end
        
        local function linkFunc()
            if link and string.len(link) > 0 then
                local jsonData          = {}
                jsonData.Act            = link
                jsonData.SelectItemID   = itemData.MakeIndex
                if callback then
                    callback(jsonData)
                end
            end
        end

        local itemMoveState = {
            begin = 1,
            moving = 2,
            end_move = 3,
        }

        local function SetGoodItemState(state, movePos)
            if not itemData then
                return
            end

            if itemMoveState.begin == state then
                if widget and not tolua.isnull(widget) then
                    widget._movingState = true
                    widget:setVisible(false)
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Begin,{
                    pos = movePos,
                    itemData = itemData,
                    linkFunc  = linkFunc,
                    cancelCallBack = function()
                        if widget and not tolua.isnull(widget) then
                            widget._movingState = false
                            widget:setVisible(true)
                        end
                    end,
                    from = ItemMoveProxy.ItemFrom.PETS_EQUIP
                })
            elseif itemMoveState.moving == state then
        
            elseif itemMoveState.end_move == state then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End, movePos)
            end
        end

        local function doubleEventCallBack()
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local itemMoving = ItemMoveProxy:GetMovingItemState()
            if itemMoving then --在道具移动中
                return
            end
            if itemData then
                linkFunc()
            end
        end

        local function clickEventCallBack(widget, eventtype)
            if tolua.isnull(widget) then
                return
            end
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            
            if not itemData or widget._movingState then
                return
            end
            local panelPos = widget:getWorldPosition()
            if global.isWinPlayMode and canmove == 1 then
                SetGoodItemState(itemMoveState.begin, panelPos)
            else
                if showtips == 1 then
                    local data = {}
                    data.itemData = itemData
                    data.pos = panelPos
                    data.from = ItemMoveProxy.ItemFrom.PETS_EQUIP
                    global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, data)
                end
            end
        end

        local pressEventCallBack = clickEventCallBack

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
    
                local movedPos = widget:getTouchMovePosition()
                local beganPos = widget:getTouchBeganPosition()
    
                local diff = cc.pSub(movedPos, beganPos)
                local distSq = cc.pLengthSQ(diff)
                if distSq <= 100 then
                    pressEventCallBack()
                end
            end
        end

        local function touchEvent( touch, eventType )
            if global.OperatingMode == global.MMO.OPERATING_MODE_WINDOWS then
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
                    performWithDelay(widget, delayCallback, global.MMO.CLICK_DOUBLE_TIME)
                end
            elseif eventType == 1 then
                local movedPos = widget:getTouchMovePosition()
                local beganPos = widget:getTouchBeganPosition()

                local diff = cc.pSub(movedPos, beganPos)
                local distSq = cc.pLengthSQ(diff)
                if not isMoved and distSq > 100 then
                    isMoved = true
                    if isMobile and canmove == 1 then
                        local beginMovePos = widget:getWorldPosition()
                        SetGoodItemState(itemMoveState.begin, beginMovePos)
                    end
                end
                if isMobile then
                    local movedPos = widget:getTouchMovePosition()
                    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Moving,{pos = movedPos})
                end
            elseif eventType == 2 then
                widget:stopAllActions()
    
                if not isMoved then
                    if not isEventPress then
                        -- 判断是否有双击事件
                        if doubleEventCallBack then
                            -- 记录上一次点击时间
                            if not widget._lastClickTime then
                                widget._lastClickTime = true
                                -- 记录单击触发
                                -- 记录进入此处时的状态，避免在延时操作后状态被改变
                                local stateOnbegin = hasEventCallOnTouchBegin
                                widget._clickDelayHandler =
                                    PerformWithDelayGlobal(
                                    function()
                                        if clickEventCallBack and stateOnbegin then
                                            clickEventCallBack(widget, eventType)
                                        end
    
                                        widget._lastClickTime = nil
                                    end,
                                    global.MMO.CLICK_DOUBLE_TIME
                                )
                            else
                                if widget._clickDelayHandler then
                                    UnSchedule(widget._clickDelayHandler)
                                    widget._clickDelayHandler = nil
                                end
    
                                if doubleEventCallBack then
                                    doubleEventCallBack()
                                end
    
                                widget._lastClickTime = nil
                            end
                        else
                            if clickEventCallBack then
                                clickEventCallBack(widget, eventType)
                            end
                        end
                    end
                else
                    if isMobile and canmove == 1 then
                        local endPos = widget:getTouchEndPosition()
                        SetGoodItemState(itemMoveState.end_move, endPos)
                    end
                end
                hasEventCallOnTouchBegin = false
            elseif eventType == 3 then
                if isMobile and canmove == 1 then
                    local endPos = widget:getTouchEndPosition()
                    SetGoodItemState(itemMoveState.end_move, endPos)
                end
                hasEventCallOnTouchBegin = false
            end
        end
        widget:setTouchEnabled(true)
        widget:addTouchEventListener( touchEvent )

    end

    return widget
end

function SUILoader:load_render_PETEQUIPSHOW(swidget, callback)
    local element           = swidget.element
    local index             = tonumber(element.attr.index) or 0
    local showtips          = tonumber(element.attr.showtips) or 1
    local bgtype            = tonumber(element.attr.bgtype)
    local scale             = tonumber(element.attr.scale) or 1
    local grey              = tonumber(element.attr.grey) or 0
    local showstar          = tonumber(element.attr.showstar) == 1
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local dblink            = element.attr.dblink

    local contentSize       = cc.size(66,66)
    local widget            = global.SWidgetCache:generateRender("ccui.Widget")
    widget:setContentSize(contentSize)


    local PetsEquipProxy    = global.Facade:retrieveProxy(global.ProxyTable.PetsEquipProxy)
    local curSelectPetIdx   = PetsEquipProxy:GetSelectPetIdx()
    local equipData         = PetsEquipProxy:GetEquipDataByPos(curSelectPetIdx, index)
    if equipData then
        local info          = {}
        info.index          = equipData.Index
        info.itemData       = equipData
        info.look           = showtips == 1
        info.bgVisible      = bgtype == 1
        info.starLv         = showstar
        if not info.look and global.isWinPlayMode then
            info.noMouseTips = true
        end
        local goodsItem     = GoodsItem:create(info)
        widget:addChild(goodsItem)
        goodsItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        goodsItem:setScale(scale)
        goodsItem:setIconGrey(grey == 1)

        if dblink and string.len(dblink) then
            if not (showtips == 1) then
                goodsItem:addLookItemInfoEvent(nil, 2)
            end
            goodsItem:addDoubleEventListener(function()
                if callback then
                    local inputTable    = self:getInputTable(submitInput)
                    local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                    local jsonData      = {}
                    jsonData.Act        = dblink
                    jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                    jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                    self:linkFuncWithCheckWords(callback, jsonData)
                end
            end)
        end
    end

    if link and not dblink then
        local linkWidget    = global.SWidgetCache:generateRender("ccui.Widget")
        widget:addChild(linkWidget)
        linkWidget:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
        linkWidget:setContentSize(contentSize)
        linkWidget:setTouchEnabled(true)
        linkWidget:setSwallowTouches(false)
        linkWidget:addClickEventListener(function()
            if callback then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
            end
        end)
    end

    return widget
end

function SUILoader:load_render_PageView(swidget, callback)
    local element           = swidget.element
    local width             = element.attr.width or 200
    local height            = element.attr.height or 200
    local color             = tonumber(element.attr.color)
    -- local direction         = tonumber(element.attr.direction) or 2
    local default           = tonumber(element.attr.default)
    local cantouch          = tonumber(element.attr.cantouch) or 1

    local widget = ccui.PageView:create()
    widget:ignoreContentAdaptWithSize(false)
    widget:setClippingEnabled(true)
    widget:setClippingType(0)
    widget:setTouchEnabled(true)
    -- widget:setDirection(direction)
    widget:setBackGroundColorType(0)
    widget:stopAllActions()

    if DEBUG_MODE then
        widget:setBackGroundColorType(1)
        widget:setBackGroundColorOpacity(100)
        widget:setBackGroundColor(cc.Color3B.GREEN)
    end

    -- color
    if color then
        widget:setBackGroundColorType(1)
        widget:setBackGroundColorOpacity(255)
        widget:setBackGroundColor(GET_COLOR_BYID_C3B(color))
    end

    -- default
    if default then
        -- default
        local function callback()
            default = default - 1
            local index = math.max(default, 0)
            widget:setCurrentPageIndex(index)
            widget:doLayout()
        end
        performWithDelay(widget, callback, 1/60)
    end

    if cantouch == 0 then
        widget:setTouchEnabled(false)
    end
    
    return widget
end

function SUILoader:load_render_Slider(swidget, callback)
    local element       = swidget.element
    local sliderid      = element.attr.sliderid
    local ballPath      = element.attr.ballimg or "public/bg_szjm_02_1.png"
    local barPath       = element.attr.barimg or "public/bg_szjm_02.png"
    local bgPath        = element.attr.bgimg or "public/bg_szjm_01.png" 
    local default       = tonumber(element.attr.defvalue) or 0
    local maxValue      = tonumber(element.attr.maxvalue) or 100
    local link          = element.attr.link

    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)

    local defaultPer    = mfloor(default)

    ballPath = SUIHelper.fixImageFileName(ballPath)
    barPath = SUIHelper.fixImageFileName(barPath)
    bgPath = SUIHelper.fixImageFileName(bgPath)

    local widget = ccui.Slider:create()
    widget:loadBarTexture(string.format(getResFullPath("res/%s"), bgPath), 0)
    widget:loadProgressBarTexture(string.format(getResFullPath("res/%s"), barPath), 0)
    widget:loadSlidBallTextureNormal(string.format(getResFullPath("res/%s"), ballPath), 0)
    
    widget:ignoreContentAdaptWithSize(false)
    widget:setTouchEnabled(true)

    widget:setMaxPercent(maxValue)
    widget:setPercent(defaultPer)
    widget:addEventListener(function(_, eventType)
        if eventType == 0 then
            local per = widget:getPercent()
            local curValue = mfloor(per)
            if self._sliderWidgets[sliderid] then
                self._sliderWidgets[sliderid].value = curValue
            end
            SUIComponentProxy:SetSUISliderValueById(sliderid, curValue)
            global.Facade:sendNotification(global.NoticeTable.SUISlider_Value_Change)
            
        elseif eventType == 2 then
            if callback then
                local sliderTable   = self:getSliderTableByID(sliderid)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Slider     = (#sliderTable > 0 and sliderTable or nil)
                callback(jsonData)
            end
        end
    end)

    if sliderid and self._sliderWidgets then
        self._sliderWidgets[sliderid] = {
            widget = widget,
            value = default
        }
        SUIComponentProxy:SetSUISliderValueById(sliderid, default)
        global.Facade:sendNotification(global.NoticeTable.SUISlider_Value_Change)
    end

    return widget
end

local function fixPosition(p)
    if not p then
        return nil
    end
    if tonumber(p) then
        return mfloor(p)
    end
    return cc.p(mfloor(p.x), mfloor(p.y))
end

function SUILoader:load_render_MenuItem(swidget, callback)
    local element       = swidget.element
    local menuid        = element.attr.menuid
    local imgPath       = element.attr.img or "public/1900000668.png"
    local arrowPath     = element.attr.arrowimg or "public/btn_szjm_01.png"
    local listPath      = element.attr.listimg or "public/1900000677.png"
    local itemname      = element.attr.itemname
    local select        = element.attr.select or ""
    local selectimg     = element.attr.selectimg or "public/1900000678.png"
    local direction     = tonumber(element.attr.direction) or 0  -- 默认0下拉 1上拉
    local width         = tonumber(element.attr.width)  
    local height        = tonumber(element.attr.height)
    local itemHei       = tonumber(element.attr.itemhei) or 16
    local fontSize      = tonumber(element.attr.fontsize) or 14
    local fontColor     = tonumber(element.attr.fontcolor) or 255
    local selectColor   = tonumber(element.attr.selectcolor)
    local maxHei        = tonumber(element.attr.maxhei)
    local link          = element.attr.link

    local itemList = {}
    if itemname and string.len(itemname) > 0 then
        itemList = string.split(itemname, "#")
    end
    local selectPath = string.format(getResFullPath("res/%s"), SUIHelper.fixImageFileName(selectimg)) 
    imgPath = string.format(getResFullPath("res/%s"), SUIHelper.fixImageFileName(imgPath)) 
    arrowPath = string.format(getResFullPath("res/%s"), SUIHelper.fixImageFileName(arrowPath)) 
    listPath = string.format(getResFullPath("res/%s"), SUIHelper.fixImageFileName(listPath)) 

    -- 默认显示选项
    local widget = ccui.ImageView:create()
    widget:loadTexture(imgPath)
    widget:ignoreContentAdaptWithSize(false)
    if not width then
        width = widget:getVirtualRendererSize().width
    end
    if not height then
        height = widget:getVirtualRendererSize().height
    end
    widget:setContentSize(cc.size(width, height))

    local arrow = ccui.ImageView:create()
    arrow:loadTexture(arrowPath)
    arrow:setAnchorPoint(cc.p(1, 0.5))
    arrow:setPosition(fixPosition(cc.p(width - 6, height / 2)))
    arrow:setFlippedY(direction == 0)
    arrow:addTo(widget)

    local showText = ccui.Text:create()
    showText:setAnchorPoint(cc.p(0.5, 0.5))
    showText:setPosition(fixPosition(cc.p(width / 2, height / 2)))
    showText:setFontName(global.MMO.PATH_FONT)
    showText:setFontSize(fontSize)
    showText:setTextColor(GET_COLOR_BYID_C3B(fontColor))
    showText:setString(select)
    showText:addTo(widget)

    if not next(itemList) then
        return widget
    end

    local menuListView = nil
    local itemCells = {}
    local isOpen = false

    local function onRefreshSelect()
        for _, cell in ipairs(itemCells) do
            local titleText = cell.title
            local selectImg = cell.selectImg
            if titleText and selectImg then
                local name = titleText:getString()
                if select and name == select then
                    selectImg:setVisible(true)
                    if selectColor then
                        titleText:setTextColor(GET_COLOR_BYID_C3B(selectColor))
                    end
                else
                    selectImg:setVisible(false)
                    titleText:setTextColor(GET_COLOR_BYID_C3B(fontColor))
                end
            end
        end
        showText:setString(select)
        arrow:setFlippedY(direction == 0)
        if widget:getChildByTag(777) then
            widget:removeChildByTag(777)
            isOpen = false
        end
    end

    local function showItemList()
        isOpen = not isOpen
        if widget:getChildByTag(777) then
            widget:removeChildByTag(777)
        end
        if not isOpen then
            arrow:setFlippedY(direction == 0)
            return 
        end
        arrow:setFlippedY(direction ~= 0)

        local num = #itemList
        local menuListBg = ccui.ImageView:create()
        menuListBg:loadTexture(listPath)
        menuListBg:ignoreContentAdaptWithSize(false)
        menuListBg:setScale9Enabled(true)
        menuListBg:setCapInsets({x = 21, y = 33, width = 23, height = 34})
        local aPoint = direction == 0 and cc.p(0, 1) or cc.p(0, 0)
        menuListBg:setAnchorPoint(aPoint)
        local posX = width * (0 - widget:getAnchorPoint().x)
        local posY = direction == 0 and height * (0 - widget:getAnchorPoint().y) or height * (1 - widget:getAnchorPoint().y)
        local posY = direction == 0 and 0 or height
        menuListBg:setPosition(fixPosition(cc.p(0, posY)))
        menuListBg:setTag(777)
        widget:addChild(menuListBg)
        
        menuListView = ccui.ListView:create()
        menuListBg:addChild(menuListView)
        menuListView:setPosition(fixPosition(cc.p(width/2, 3)))
        menuListView:setAnchorPoint(cc.p(0.5, 0))
        menuListView:setContentSize(cc.size(width, 0))
        menuListView:setClippingEnabled(true)
        menuListView:setClippingType(0)
        menuListView:setTouchEnabled(true)
        menuListView:setDirection(1)
    
        for id, name in ipairs(itemList) do
            if string.len(name) > 0 then
                local channel_cell = ccui.Layout:create()
                channel_cell:setContentSize(cc.size(width, itemHei))

                local selectImg = ccui.ImageView:create()
                selectImg:setPosition(fixPosition(cc.p(width/2, itemHei/2)))
                selectImg:loadTexture(selectPath)
                selectImg:ignoreContentAdaptWithSize(false)
                selectImg:setContentSize(cc.size(width, itemHei))
                selectImg:addTo(channel_cell)

                local titleText = ccui.Text:create()
                titleText:setAnchorPoint(cc.p(0.5, 0.5))
                titleText:setPosition(fixPosition(cc.p(width/2, itemHei/2)))
                titleText:setFontName(global.MMO.PATH_FONT)
                titleText:setFontSize(fontSize)
                titleText:setString(name)
                titleText:addTo(channel_cell)

                if select and name == select then
                    selectImg:setVisible(true)
                    if selectColor then
                        titleText:setTextColor(GET_COLOR_BYID_C3B(selectColor))
                    end
                else
                    selectImg:setVisible(false)
                    titleText:setTextColor(GET_COLOR_BYID_C3B(fontColor))
                end
                channel_cell:setTouchEnabled(true)
                channel_cell:addClickEventListener(function()
                    select = name
                    onRefreshSelect()
                    if callback then
                        local menuTable     = self:getMenuItemTableByID(menuid)
                        local jsonData      = {}
                        jsonData.Act        = link
                        jsonData.MenuItem   = (#menuTable > 0 and menuTable or nil)
                        callback(jsonData)
                    end
                end)
                menuListView:pushBackCustomItem(channel_cell)

                itemCells[id] = {cell = channel_cell, title = titleText, selectImg = selectImg}
            end
        end

        local count = #menuListView:getChildren()
        local listWid = menuListView:getContentSize().width
        local rHei = count * itemHei
        local listHei = maxHei and math.min(rHei, maxHei) or rHei
        menuListView:setContentSize(cc.size(listWid, listHei))
        menuListBg:setContentSize(cc.size(listWid + 4, listHei + 6))
    end

    widget:setTouchEnabled(true)
    widget:addClickEventListener(function ()
        DelayTouchEnabled(widget)
        showItemList()
    end)

    if menuid and self._menuItemWidgets then
        self._menuItemWidgets[menuid] = {
            widget = showText,
            value = select
        }
    end
        
    return widget
end

function SUILoader:load_render_ScrapePic(swidget, callback)
    local element           = swidget.element
    local showImg           = element.attr.showimg                          -- 展示图片
    local maskImg           = element.attr.maskimg or "public/mask_1.png"   -- 遮罩图片
    local clearHei          = element.attr.clearhei                         -- 刮除高度
    local moveTime          = tonumber(element.attr.movetime) or 5          -- 移动时间
    local beginTime         = tonumber(element.attr.begintime)              -- 开始按下时间
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox

    local widget = global.SWidgetCache:generateRender("ccui.Layout")
    widget:setBackGroundColorType(0)
    widget:setTouchEnabled(false)


    local path              = SUIHelper.fixImageFileName(showImg)
    local img               = nil
    local fullPath          = (path and path ~= "") and string.format(getResFullPath("res/%s"), path) or ""
    if not fullPath or fullPath == "" or not global.FileUtilCtl:isFileExist(fullPath) then
        img                 = global.SWidgetCache:generateEmptyImageRender("ccui.ImageView")
    else
        img                 = global.SWidgetCache:generateRender("ccui.ImageView")
    end
    
    img:loadTexture(fullPath)
    img:ignoreContentAdaptWithSize(false)
    img:setContentSize(img:getVirtualRendererSize())
    widget:addChild(img)
    local imgSize = img:getContentSize()
    widget:setContentSize(imgSize)
    img:setAnchorPoint(cc.p(0.5, 0.5))
    img:setPosition(cc.p(fixPosition(imgSize.width / 2), fixPosition(imgSize.height / 2)))

    if imgSize.width == 0 or imgSize.height == 0 then
        return widget
    end

    local radius = clearHei and mfloor(clearHei / 2) or 8
    local drawNode = cc.DrawNode:create()
    widget:addChild(drawNode)
    drawNode:retain()
    drawNode:drawSolidCircle(cc.p(0, 0), radius, 0, radius, 1, 1, cc.c4b(0, 0, 0, 0))
    drawNode:setVisible(false)

    local renderTexture = cc.RenderTexture:create(imgSize.width, imgSize.height)
    widget:addChild(renderTexture, 10)
    renderTexture:retain()
    renderTexture:setPosition(cc.p(fixPosition(imgSize.width / 2), fixPosition(imgSize.height / 2)))

    local mask              = nil
    local path              = SUIHelper.fixImageFileName(maskImg)
    local fullPath          = (path and path ~= "") and string.format(getResFullPath("res/%s"), path)
    if not fullPath or fullPath == "" or not global.FileUtilCtl:isFileExist(fullPath) then
        mask                = global.SWidgetCache:generateEmptyImageRender("ccui.ImageView")
    else
        mask                = global.SWidgetCache:generateRender("ccui.ImageView")
    end
    mask:loadTexture(fullPath)
    mask:ignoreContentAdaptWithSize(false)
    mask:setContentSize(imgSize)
    mask:setAnchorPoint(cc.p(0.5, 0.5))
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

            if callback and link and string.len(link) > 0 then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                self:linkFuncWithCheckWords(callback, jsonData)
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
                midPos = fixPosition(GUI:convertToNodeSpace(widget, midPos.x, midPos.y))
                local rectNode = cc.DrawNode:create()
                local posList = {
                    cc.p(- distance / 2 , - height / 2),
                    cc.p(- distance / 2 , height / 2),
                    cc.p(distance / 2 , height / 2),
                    cc.p(distance / 2 , - height / 2)
                }
                rectNode:drawSolidPoly(posList, 4, cc.c4b(0,0,0,0))
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
            lastMovePos = nil
            moveBT = nil
        end
    end)

    return widget
end

function SUILoader:load_render_BmpText(swidget, callback)
    local element           = swidget.element
    local text              = element.attr.text or ""
    local size              = tonumber(element.attr.size) or defaultFontSize
    local color             = tonumber(element.attr.color) or defaultColorID
    local link              = element.attr.link
    local submitInput       = element.attr.submitInput
    local submitCheckBox    = element.attr.submitCheckBox
    local clickInterval     = (tonumber(element.attr.clickInterval) or 0) * 0.001
    local tips              = element.attr.tips
    local tipsx             = tonumber(element.attr.tipsx) or 0
    local tipsy             = tonumber(element.attr.tipsy) or 0
    local tipWidth          = tonumber(element.attr.tipWidth) or 1136


    text = string.gsub(text, "\\", "\r\n")
    text = string.trim(text)

    local widget = ccui.Text:create()
    GUI:SetBmpTextProperties(widget)

    widget:setBMFontFilePath()
    widget:setFontSize(size)
    widget:setTextColor(GET_COLOR_BYID_C3B(color))
    widget:setString(text)

    if link and string.len(link) > 0 or (tips and string.len(tips) > 0) then
        widget:setTouchEnabled(true)
        widget:addClickEventListener(function()
            DelayTouchEnabled(widget, clickInterval)

            widget:setScale(1 + 0.2)
            local function reback()
                widget:setScale(1)
            end
            performWithDelay(widget, reback, 0.03)
            
            if callback and link then
                local inputTable    = self:getInputTable(submitInput)
                local checkBoxTable = self:getCheckBoxTable(submitCheckBox)
                local jsonData      = {}
                jsonData.Act        = link
                jsonData.Input      = (#inputTable > 0 and inputTable or nil)
                jsonData.CheckBox   = (#checkBoxTable > 0 and checkBoxTable or nil)
                callback(jsonData)
            end

            if not global.isWinPlayMode then
                if tips and string.len(tips) > 0 then
                    local offset  = cc.p(tipsx, -tipsy)
                    local anchorPoint = cc.p(0.5, 1)
        
                    tips  = string.gsub(tips, "%^", "\\")
                    SHOW_SUI_DESCTIP( widget ,tips, tipWidth, offset, anchorPoint)
                end
            end

        end)

        -- 下划线
        widget:getVirtualRenderer():enableUnderline()
    end

    self:addMouseOverTips(widget, element)

    return widget
end

return SUILoader
