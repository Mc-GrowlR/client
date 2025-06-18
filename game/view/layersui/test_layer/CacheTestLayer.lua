local BaseLayer = requireLayerUI("BaseLayer")
local CacheTestLayer = class("CacheTestLayer", BaseLayer)

local RichTextHelper = requireUtil("RichTextHelp")
local TableViewEx = requireUtil("TableViewEx")


function CacheTestLayer:ctor()
    CacheTestLayer.super.ctor(self)

    self._textureData = {}

    -- 动画
    self._animData = {}
    self._classKey = {
        player  = "玩家",
        monster = "怪物",
        npc     = "NPC",
        effect  = "特效",
        weapon  = "武器",
        shield  = "盾牌",
        wings   = "翅膀",
        hair    = "发型", 
    }

    self._classList = {}
    self._classCache = {}

    -- 场景
    self._sceneData = {}
    -- ui
    self._uiData = {}
    
end

function CacheTestLayer:Init()
    self._root , self.ui = CreateExport("rich_test_layer/cache_test_layer")
    if not self._root then
        return false
    end
    self:addChild(self._root)

    -- close
    local function closeCallback()
        global.Facade:sendNotification( global.NoticeTable.Layer_CacheTest_Close )
    end
    self.ui.Panel_close:addClickEventListener(closeCallback)

    self:refreshData()

    self:InitUI()

    self.ui.Button_class:addClickEventListener(function()
        self:OpenClassLayer(1)
    end)

    self.ui.Button_scene:addClickEventListener(function()
        self:OpenClassLayer(2)
    end)

    self.ui.Button_ui:addClickEventListener(function()
        self:OpenClassLayer(3)
    end)

    return true
end

function CacheTestLayer:Create()
    local ui = CacheTestLayer.new()
    if ui and ui:Init() then
        return ui
    end
end

function CacheTestLayer:refreshData()
    local textureInfo = global.TextureCache:getCachedTextureInfo()
    self._textureData = string.split(textureInfo, "\n")

    self._animSize = 0
    self._sceneSize = 0
    self._uiSize = 0

    local removeList = {}

    table.sort(self._textureData, function(a, b)
        local infoA = {string.find(a, "(.+) => (.+) KB")}
        local infoB = {string.find(b, "(.+) => (.+) KB")}
        if infoA[4] and infoB[4] then
            return tonumber(infoA[4]) > tonumber(infoB[4])
        else
            return false
        end
    end)

    for _, v in ipairs(self._textureData) do
        local find_info = {string.find(v, "(.+) => (.+) KB")}
        if find_info[1] and find_info[2] then
            if string.find(find_info[3], "anim/") then
                self._animSize = self._animSize + tonumber(find_info[4])
                table.insert(self._animData, v)

            elseif string.find(find_info[3], "scene/") then
                self._sceneSize = self._sceneSize + tonumber(find_info[4])
                table.insert(self._sceneData, v)
            else
                self._uiSize = self._uiSize + tonumber(find_info[4])
                table.insert(self._uiData, v)
            end  
        else
            local str = table.remove( self._textureData, _)
            table.insert(removeList, str)
        end
    end

    for _, v in ipairs(removeList) do
        table.insert( self._textureData, v )
    end
    
    self:classifyData()
end

function CacheTestLayer:classifyData( ... )
    for _, v in ipairs(self._animData) do
        local find_info = {string.find(v, "(.+) => (.+) KB")}
        if find_info[3] and find_info[4] then 
            for k, str in pairs(self._classKey) do
                if string.find(find_info[3], k.."/") then
                    if not self._classList[k] then
                        self._classList[k] = {}
                    end
                    table.insert(self._classList[k], v)
                    if not self._classCache[k] then
                        self._classCache[k] = 0
                    end
                    self._classCache[k] = self._classCache[k] + tonumber(find_info[4])
                end
            end
        end
    end
end

function CacheTestLayer:InitUI()
    local animColor = cc.c3b(0,128,0)
    local animM = self._animSize/1024
    if animM >= 250 and animM < 350 then
        animColor = cc.c3b(255, 165, 0)
    elseif animM >= 350 then
        animColor = cc.c3b(255, 0, 0)
    end
    
    self.ui.Text_anim:setString(string.format("%0.5f", self._animSize/1024) .. "M")
    self.ui.Text_scene:setString(string.format("%0.5f", self._sceneSize/1024) .. "M")
    self.ui.Text_ui:setString(string.format("%0.5f", self._uiSize/1024) .. "M")

    self.ui.Text_anim:setTextColor(animColor)
    self.ui.Text_scene:setTextColor(cc.c3b(0,128,0))
    self.ui.Text_ui:setTextColor(cc.c3b(0,128,0))

    self:InitPanel()
end

-- function CacheTestLayer:InitPanel()

--     if self.ui.ListView_ui then
--         self.ui.ListView_ui:removeAllChildren()
--         self.ui.ListView_ui:setClippingType(0)
--     end

--     for i, value in ipairs(self._textureData) do
--         local panel_cell = self.ui.Panel_cell:cloneEx()
--         panel_cell:setVisible(true)
--         local ListView_1 = panel_cell:getChildByName("ListView_1")
--         ListView_1:setClippingType(0)
--         ListView_1:setSwallowTouches(false)
--         ListView_1:getChildByName("Text_1"):setString(value)
--         self.ui.ListView_ui:pushBackCustomItem(panel_cell)
--     end

--     self.ui.ListView_ui:setItemsMargin(5)

-- end

function CacheTestLayer:InitPanel()
    if self.tableView then
        self.tableView:removeSelf()
        self.tableView = nil
    end

    local baseTableViewNum = #self._textureData
    local tableView = TableViewEx.create({
        size = cc.size(900, 500),
        cellSizeForTable = function (tv, view, idx)
            return 900, 40
        end,
        numberOfCellsInTableView = function (tv, view)
            return baseTableViewNum
        end,
        tableCellAtIndex = function (tv, view, idx)
            local i = idx + 1
            local cell = view:dequeueCell()
            if not cell then
                cell = cc.TableViewCell:new()
            else
                cell:removeAllChildren()
            end 

            local panel_cell = self.ui.Panel_cell:cloneEx()
            if panel_cell and self._textureData[i] then
                panel_cell:setVisible(true)
                local ListView_1 = panel_cell:getChildByName("ListView_1")
                ListView_1:setClippingType(0)
                ListView_1:setSwallowTouches(false)
                ListView_1:getChildByName("Text_1"):setString(self._textureData[i])
                cell:addChild(panel_cell)
                panel_cell:align(cc.p(0, 0), 0, 0)
            end

            return cell
        end
    })
    
    self.ui.Panel_ui:addChild(tableView)
    self.tableView = tableView
end

function CacheTestLayer:OpenClassLayer( type )
    self.ui.Panel_bg:removeChildByTag(222)
    local root = CreateExport("rich_test_layer/anim_class_node")
    local panel = root:getChildByName("Panel_1")
    panel:removeFromParent()
    local ui = ui_delegate(panel)
    self.ui.Panel_bg:addChild(panel)
    panel:setTag(222)

    ui.Panel_ui_class:setVisible(type == 1)
    ui.ListView_class:setVisible(type == 1)
    ui.Panel_ui_1:setVisible(type ~= 1)
    

    local function refreshClassView(key)
        ui.Panel_ui_class:removeAllChildren()
        ui.Panel_ui_1:removeAllChildren()
        local data = key and self._classList[key]
        if type == 2 then
            data = self._sceneData
        elseif type == 3 then
            data = self._uiData
        end
        local num = data and #data or 0
        local tableView = TableViewEx.create({
            size = type == 1 and cc.size(780, 500) or cc.size(900, 500),
            cellSizeForTable = function (tv, view, idx)
                if type == 1 then
                    return 780, 40
                else
                    return 900, 40
                end
            end,
            numberOfCellsInTableView = function (tv, view)
                return num
            end,
            tableCellAtIndex = function (tv, view, idx)
                local i = idx + 1
                local cell = view:dequeueCell()
                if not cell then
                    cell = cc.TableViewCell:new()
                else
                    cell:removeAllChildren()
                end 

                local panel_cell = type == 1 and ui.Panel_cell:cloneEx() or ui.Panel_cell_1:cloneEx()
                if panel_cell and data[i] then
                    panel_cell:setVisible(true)
                    local ListView_1 = panel_cell:getChildByName("ListView_1")
                    ListView_1:setClippingType(0)
                    ListView_1:setSwallowTouches(false)
                    ListView_1:getChildByName("Text_1"):setString(data[i])
                    cell:addChild(panel_cell)
                    panel_cell:align(cc.p(0, 0), 0, 0)
                end

                return cell
            end
        })
        if type == 1 then
            ui.Panel_ui_class:addChild(tableView)
        else
            ui.Panel_ui_1:addChild(tableView)
        end
    end

    if type == 1 then
        ui.ListView_class:removeAllChildren()
        self._btnList = {}
        for _, name in pairs(self._classKey) do 
            local btn = ui.Button_type:cloneEx()
            btn:setVisible(true)
            local showStr = name .. string.format(" （%sM）", self._classCache[_] and math.ceil(self._classCache[_]/1024) or 0)
            btn:setTitleText(showStr)
            btn:addClickEventListener(function ( ... )
                self._classType = _
                self:RefreshBtnShow()
                refreshClassView(_)
            end)
            ui.ListView_class:pushBackCustomItem(btn)
            self._btnList[_] = btn 
            if not self._classType then
                self._classType = _
            end
        end

        self:RefreshBtnShow()
    end
    refreshClassView(self._classType)

    ui.Button_back:addClickEventListener(function( ... )
        panel:removeSelf()
    end)
end

function CacheTestLayer:RefreshBtnShow()
    for key, btn in pairs(self._btnList) do
        btn:setBright(key ~= self._classType)
    end
end

return CacheTestLayer
