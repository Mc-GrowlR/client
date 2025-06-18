local MainCollectLayout = class("MainCollectLayout", function()
    return cc.Node:create()
end)

MainCollectLayout._path = global.MMO.PATH_RES_PRIVATE .. "main/collect/"

function MainCollectLayout:ctor()
    self._status = -1 -- -1：初始化状态，可任意切换  0：无，需要隐藏（持续监测中）  1：显示可以采集   2：开始采集  3：采集中  4：采集完成  5：采集结束

    self._collectionID = nil -- 采集物ID
end

function MainCollectLayout.create()
    local layout = MainCollectLayout.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function MainCollectLayout:Init()
    return true
end

function MainCollectLayout:InitGUI(...)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_COLLECT)
    MainCollect.main()

    self._ui = ui_delegate(self)

    if not self._ui then
        return
    end

    -- -- 开始采集
    self._ui.Panel_1:addClickEventListener(function()
        self:SendAutoFindCollection()
    end)

    self:HideCollect(true)
end

function MainCollectLayout:SendAutoFindCollection()
    if self._collectionID then
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local targetID = inputProxy:SetTargetID(self._collectionID, global.MMO.SELETE_TARGET_TYPE_FIND)
    end
    global.Facade:sendNotification(global.NoticeTable.AutoFindCollection)
end

function MainCollectLayout:ShowCollect(collections)
    if not collections or not next(collections) then
        return nil
    end

    local hideSelect = tonumber(SL:GetMetaValue("GAME_DATA", "Hide_Select_Collection")) == 1
    local selectList = self._ui.Panel_1:getChildByName("List_Collect_Select")
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local targetID = inputProxy:GetTargetID()
    local collectionID = self._collectionID

    local tempID = {}
    if selectList then
        local items = selectList:getItems()
        for i, item in ipairs(items) do
            local collectID = item:getName()
            if collections[collectID] then
                tempID[collectID] = collectID
            else
                if collectID == collectionID then
                    collectionID = nil
                end
                local index = selectList:getIndex(item)
                selectList:removeItem(index)
            end
        end
    end

    for k, actor in pairs(collections) do
        if not tempID[k] then
            if not collectionID then
                collectionID = actor and k
            end

            if k == targetID then
                collectionID = actor and k
            end

            if actor and not hideSelect and selectList then
                local item = self:CreateItemCell(actor)
                selectList:pushBackCustomItem(item)
            end
        end
    end

    if not collectionID then
        return
    end

    self._collectionID = collectionID

    if MainCollect and MainCollect.ShowCollectUI then
        MainCollect.ShowCollectUI()
    end
end

function MainCollectLayout:CreateItemCell(actor)
    local widget = self._ui.Panel_1:getChildByName("Layout_Item"):cloneEx()
    widget:setVisible(true)
    widget:setName(actor:GetID())

    local nameText = widget:getChildByName("Text_Name")
    if nameText then
        nameText:setString(actor:GetName())
    end

    widget:addClickEventListener(function()
        self._collectionID = actor:GetID()
        self:SendAutoFindCollection()
    end)

    return widget
end

function MainCollectLayout:HideCollect(isInit)
    if not self._collectionID and not isInit then
        return
    end
    self._collectionID = nil

    if MainCollect and MainCollect.HideCollectUI then
        MainCollect.HideCollectUI()
    end
end

function MainCollectLayout:OnRefreshCollect(data)
    local actor = data and data.actor
    if actor and actor:IsCollection() then
        local selectList = self._ui.Panel_1:getChildByName("List_Collect_Select")
        local item = selectList and selectList:getChildByName(actor:GetID())
        if item then
            selectList:removeChild(item)
            item = nil
        end

        local items = selectList and selectList:getItems() or {}
        if items[1] then
            self._collectionID = items[1]:getName()
        else
            global.Facade:sendNotification(global.NoticeTable.CollectCompleted)
            self:HideCollect()
        end
    end
end

return MainCollectLayout
