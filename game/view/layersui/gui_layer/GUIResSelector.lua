local BaseLayer = requireLayerUI("BaseLayer")
local GUIResSelector = class("GUIResSelector", BaseLayer)
local QuickCell = requireUtil("QuickCell")

local sformat       = string.format
local sfind         = string.find
local sgsub         = string.gsub
local strim         = string.trim
local slen          = string.len
local ssplit        = string.split
local sreverse      = string.reverse
local ssub          = string.sub
local smatch        = string.match

local tInsert       = table.insert
local tRemove       = table.remove
local tSort         = table.sort

local fileUtil      = global.FileUtilCtl
local resourcePath  = fileUtil:getDefaultResourceRootPath()
local mCachePath    = global.L_ModuleManager:GetCurrentModule():GetSubModPath()
local mStabPath     = global.L_ModuleManager:GetCurrentModule():GetStabPath()

local res           = "res/"
local directory     = "dev/"  .. res
local exportFolder  = resourcePath .. mStabPath .. res
local exportFolder2 = resourcePath .. mCachePath .. res
local GMFolder      = resourcePath .. directory
local cacheFolder   = fileUtil:getWritablePath() .. mCachePath .. res
local cacheFolder2  = fileUtil:getWritablePath() .. mStabPath .. res

local pic_w = 140
local pic_h = 140

function GUIResSelector:ctor()
    GUIResSelector.super.ctor(self)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_BACKSPACE, function ()
        self:onKeyBackSpace()
        return true
    end, nil, 0)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_ESCAPE, function ()
        self:onKeyEsc()
        return true
    end, nil, 0)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_ENTER, function ()
        self:onKeyEnter()
        return true
    end, nil, 0)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_KP_ENTER, function ()
        self:onKeyEnter()
        return true
    end, nil, 0)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_DELETE, function ()
        return true
    end, nil, 0)

    -- 清理缓存
    fileUtil:purgeCachedEntries()
end

function GUIResSelector.create(data)
    local layer = GUIResSelector.new()
    if layer:init(data) then
        return layer
    end
    return false
end

function GUIResSelector:init(data)
    local root = CreateExport("gui_editor/res_selector.lua")
    if not root then
        return false
    end
    self:addChild(root)

    self._quickUI = ui_delegate(root)

    self._files = {}

    self:InitEvent()

    self:adaptUI()

    self._res = data and data.res or ""
    self._callfunc = data and data.callfunc
    self:InitUI()

    return true
end

-- 自适应 UI
function GUIResSelector:adaptUI()
    local visible = global.Director:getVisibleSize()
    local ww = visible.width
    local hh = visible.height

    self._quickUI.Panel_background:setContentSize(cc.size(ww, hh))

    self._quickUI.Image_1:setContentSize(cc.size(775, 30))
    self._quickUI.Image_1:setPositionY(hh - 30)

    self._quickUI.Text_Res:setContentSize(cc.size(769, 24))
    self._quickUI.Text_Res:setPositionY(hh - 30)

    self._quickUI.btnClose:setPosition(cc.p(ww, hh))

    local list_hh =  hh - 70
    self._quickUI.list:setContentSize(cc.size(775, list_hh))

    self._quickUI.Panel_slider:setContentSize(cc.size(14, list_hh))
    self._quickUI.Button_1:setPositionY(list_hh)

    self._quickUI.slider:setContentSize(cc.size(list_hh - 48, 14))
    self._quickUI.slider:setPositionY(list_hh / 2)

    local Panel_preview_ww = ww - 819
    self._quickUI.Panel_preview:setContentSize(cc.size(Panel_preview_ww, list_hh))
    self._quickUI.Panel_preview:setPositionX(ww - 15)

    self._quickUI.image:setPosition(cc.p(Panel_preview_ww / 2, (list_hh) / 2))
    self._quickUI.Text_size:setPositionX(Panel_preview_ww / 2)

end

-- Slider Bar ---------------------------------------------------
function GUIResSelector:getListOffY()
    return self._quickUI.list:getInnerContainerSize().height - self._quickUI.list:getContentSize().height
end

function GUIResSelector:updateListPercent(percent)
    self._quickUI.slider:setPercent(percent)
    self._quickUI.list:scrollToPercentVertical(percent, 0.03, false)
end

function GUIResSelector:setSliderBar(percent)
    self._quickUI.slider:setPercent(percent)
end

function GUIResSelector:onScrollPercent(padding)
    local innY = self._quickUI.list:getInnerContainerPosition().y
    local offY = self:getListOffY()

    local percent = math.min(math.max(0, (offY + innY + padding) / offY * 100), 100)
    self:updateListPercent(percent)
end

function GUIResSelector:onSliderEvent()
    local offY = self:getListOffY()
    if offY > 0 then
        self._quickUI.list:scrollToPercentVertical(self._quickUI.slider:getPercent(), 0.03, false)
    else
        self._quickUI.slider:setPercent(100)
    end
end

function GUIResSelector:onScrollEvent()
    local posY = self._quickUI.list:getInnerContainerPosition().y
    local offY = self:getListOffY()
    local percent = 100
    if offY > 0 then
        percent = math.min(math.max(0, (offY + posY) / offY * 100), 100)
    end
    self._quickUI.slider:setPercent(percent)
end

function GUIResSelector:InitEvent()
    self._quickUI.Button_1:addClickEventListener(function () self:onScrollPercent(-150) end)
    self._quickUI.Button_2:addClickEventListener(function () self:onScrollPercent(150)  end)
    self._quickUI.slider:addEventListener(handler(self, self.onSliderEvent))
    self._quickUI.list:addEventListener(handler(self, self.onScrollEvent))
    self._quickUI.list:addMouseScrollPercent(handler(self, self.setSliderBar))
    self._quickUI.btnClose:addClickEventListener(handler(self, self.onClose))
end
-------------------------------------------------------------------

function GUIResSelector:InitUI()
    self._fullPath = (slen(self._res) > 0 and fileUtil:isFileExist(self._res)) and fileUtil:fullPathForFilename(self._res)
    if self._fullPath then
        local filename, folder = self:getFileInfo(self._fullPath)
        self._filename = filename
        self._selDirctor = folder
    else
        if global.isGMMode then
            self._selDirctor = GMFolder
        else
            self._selDirctor = exportFolder
        end
    end


    self._files = self:getAllFiles()
    self:updateListView()
end

-- 加载 Item 到 ListView
function GUIResSelector:updateListView()
    local list = self._quickUI.list
    self._quickUI.list:removeAllChildren()

    local function _CreateCell(i)
        local item = self._quickUI.Panel_item:clone()
        item:setTag(i)
        item:setVisible(true)

        local maxI = 5 * i
        self:refreshItemData(item:getChildByName("item1"), self._files[maxI-4])
        self:refreshItemData(item:getChildByName("item2"), self._files[maxI-3])
        self:refreshItemData(item:getChildByName("item3"), self._files[maxI-2])
        self:refreshItemData(item:getChildByName("item4"), self._files[maxI-1])
        self:refreshItemData(item:getChildByName("item5"), self._files[maxI])

        return item
    end

    local row = math.ceil(#self._files/5)
    list:setInnerContainerSize(cc.size(list:getContentSize().width, math.max(row * 200, list:getContentSize().height)))

    self._index = 0
    self._cells = {}
    for i = 1, row do
        local quickCell = QuickCell:Create({
            wid = 775,
            hei = 200,
            createCell = function() return _CreateCell(i) end})
        self._cells[i] = quickCell
        self._quickUI.list:addChild(quickCell)
    end

    if self._filename then
        local index = 0
        for i, v in ipairs(self._files) do
            if v and v.filename == self._filename then
                index = math.ceil(i/5)
                local pic = self._selDirctor .. "/" .. v.filename
                self:onSelectImage(pic)
                break
            end
        end
        if index > 0 then
            list:jumpToItem(index, cc.p(0,0), cc.p(0, 0))
            self:onScrollPercent(0)
        else
            self:updateListPercent(0)
        end
    else
        self._quickUI.Panel_preview:setVisible(false)
        self:updateListPercent(0)
    end
end

function GUIResSelector:setLineStr(text, str)
    local maxWidth = 130
    
    text:setString(str)

    local width = text:getContentSize().width
    if width < maxWidth then
        return false
    end

    local tempStr = ""
    local newText = ""
    local len     = 0
    local strLen  = slen(str)
    for i = 1, strLen do
        tempStr = tempStr .. ssub(str, i, i)
        text:setString(tempStr)

        local width = text:getContentSize().width
        if width > maxWidth then
            newText = newText .. tempStr .."\n"
            tempStr = ""
            len = len + 1
        end

        if i == strLen then
            newText = newText .. tempStr
        end
    end

    text:setString(newText)
end

-- 属性列表 Item
function GUIResSelector:refreshItemData(item, file)
    if not (file and next(file)) then
        item:setVisible(false)
        return false
    end
    IterAllChild(item, item)
    item:setVisible(true)
    
    local filename = file.filename
    local isDir    = file.flag == 1
    local fullfile = self._selDirctor .. filename

    local pic = isDir and "res/private/gui_edit/file.png" or fullfile
    if isDir then
        pic = "res/private/gui_edit/file.png"
    else
        pic = res .. self:getPattern({GMFolder, cacheFolder, exportFolder2, cacheFolder2, exportFolder}, self._selDirctor) .. filename
    end
    item["icon"]:loadTexture(pic)

    -- 图片尺寸校验
    local size = item["icon"]:getVirtualRendererSize()
    item["icon"]:setContentSize(size)
    local scale = 1
    if size.width > size.height then
        if size.width > pic_w then
            scale = pic_w / size.width
        end
    else
        if size.height > pic_h then
            scale = pic_h / size.height
        end
    end
    item["icon"]:setScale(scale)

    local isSel = self._filename == filename
    item["select"]:setVisible(isSel)
    
    item:setName(filename)
    self:setLineStr(item["Text_name"], filename)

    -- 双击事件
    self._TIME_ = self._TIME_ or 0
    item:addTouchEventListener(function(_, eventType)
        if eventType == 0 then
            performWithDelay(self, function() self._TIME_ = 0 end, global.MMO.CLICK_DOUBLE_TIME)
        elseif eventType == 2 then
            if isDir then
                self._quickUI.Panel_preview:setVisible(false)
            else
                self:onSelectImage(pic)
            end

            self._TIME_ = self._TIME_ + 1

            local isMe = self._filename == filename
            self._filename = filename
            self._fullfile = fullfile
            self._isDir = isDir
            
            self:refreshCells()

            if self._TIME_ == 2 then
                if isMe then
                    self:onKeyEnter()
                else
                    self._TIME_ = 0
                end
            end
        end   
    end)
end

-- 刷新 ListView
function GUIResSelector:refreshCells( )
    for index, cell in ipairs(self._cells) do
        if cell then
            cell:Exit()
            cell:Refresh()
        end
    end
end

-- 右侧选择图片信息
function GUIResSelector:onSelectImage(pic)
    self._quickUI.image:loadTexture(pic)

    local pSize = self._quickUI.Panel_preview:getContentSize()
    local image_w = pSize.width - 20
    local image_h = image_w

    -- 图片尺寸校验
    local size = self._quickUI.image:getVirtualRendererSize()
    self._quickUI.Text_size:setString("尺寸: " .. size.width .. " * ".. size.height)

    self._quickUI.image:setContentSize(size)
    local scale = 1
    if size.width > size.height then
        if size.width > image_w then
            scale = image_w / size.width
        end
    else
        if size.height > image_h then
            scale = image_h / size.height
        end
    end
    self._quickUI.image:setScale(scale)

    self._quickUI.Panel_preview:setVisible(true)
end

function GUIResSelector:getPattern(dirs, dir)
    local pattern = (function ()
        local ts = dirs
        local t  = dir
        
        for _,v in ipairs(ts) do
            local Is = true

            local len = #v
            for i=1,len do
                if string.sub(v, i, i) ~= string.sub(t, i, i) then
                    Is = false
                end
            end
            if Is then
                local s = len + 1
                local e = #t
                if e > s then
                    return string.sub(t, s, e)
                end
            end
        end

        return ""
    end)()

    return pattern
end

function GUIResSelector:getAllFiles()
    local pattern = self:getPattern({GMFolder, cacheFolder, exportFolder2, cacheFolder2, exportFolder}, self._selDirctor)
    self._quickUI.Text_Res:setString(res..pattern)

    local items  = {}
    local files  = {}

    local _items = {}
    local _files = {}

    for _, path in ipairs({GMFolder, cacheFolder, exportFolder, cacheFolder2, exportFolder2}) do
        local folder = path..pattern

        local listfiles = fileUtil:listFiles(folder)
        -- 跳过 2 条
        tRemove(listfiles, 1)
        tRemove(listfiles, 1)

        for k, info in ipairs(listfiles) do
            -- 去掉末尾可能出现的 /
            info = sgsub(info, "[/]+$", "")

            local filename = self:getFileInfo(info)

            if self:IsDirectory(info) then -- 是否是文件夹
                if not _files[filename] then
                    tInsert(files, {filename = filename, flag = 1})
                    _files[filename] = true
                end
            elseif sfind(filename,".png") or sfind(filename,".jpg") then
                if not _items[filename] then
                    tInsert(items, {filename = filename, flag = 0})
                    _items[filename] = true
                end
            end
        end
    end

    tSort(items, function (a, b) 
        local v1 = string.upper(a.filename)
        local v2 = string.upper(b.filename)
        return v1 < v2
    end)
    tSort(files, function (a, b) 
        local v1 = string.upper(a.filename)
        local v2 = string.upper(b.filename)
        return v1 > v2
    end)

    for i, v in ipairs(files) do
        tInsert(items, 1, v)
    end

    return items
end

-- 判断路径是否是文件夹
function GUIResSelector:IsDirectory(file)
    return file and fileUtil:isDirectoryExist(file)
end

-- 通过文件路径获取文件信息（返回: 文件名、文件夹路径）
function GUIResSelector:getFileInfo(str)
    local rerStr = sreverse(str)
    local _, i   = sfind(rerStr, "/")
    local len    = slen(str)
    local st     = len - i + 2
    return ssub(str, st, len), ssub(str, 1, st-1)
end

-- 关闭界面
function GUIResSelector:onClose()
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Close)
end

-- 键盘事件 ---------------------------------------------------
-- 返回上一级目录
function GUIResSelector:onKeyBackSpace()
    self._selDirctor = sgsub(self._selDirctor, "\\\\", "\\")
    if not self._selDirctor then
        return false
    end

    if self._selDirctor == GMFolder or self._selDirctor == cacheFolder or self._selDirctor == exportFolder or self._selDirctor == cacheFolder2 or self._selDirctor == exportFolder2   then
        return false
    end

    local isfind = sfind(self._selDirctor, "/")
    if not isfind then
        return false
    end

    local rs = sreverse(clone(self._selDirctor))
    local pattern = smatch(rs, "/(.-)/")
    if not pattern then
        return false
    end

    self._selDirctor = sreverse(self:getPattern({"/" .. pattern}, rs))
    self._filename = nil
    self._fullfile = nil
    self._isDir = true

    self._files = self:getAllFiles()
    self:updateListView()
end

-- 进入下一级目录
function GUIResSelector:onKeyEnter()
    if self._isDir then
        self._selDirctor = self._fullfile .. "/"
        self._files = self:getAllFiles()
        self:updateListView()
        self._quickUI.Panel_preview:setVisible(false)
    else
        if self._callfunc then
            self._callfunc("res/" .. sgsub(self._fullfile, "(.*)/res/", ""))
            self:onClose()
        end
    end
end

-- Esc 退出键
function GUIResSelector:onKeyEsc()
    cc.Director:getInstance():getEventDispatcher():removeEventListener(self._listenerKeyBoard)
    self:onClose()
end
---------------------------------------------------------------

return GUIResSelector
