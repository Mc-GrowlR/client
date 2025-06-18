local BaseLayer = requireLayerUI("BaseLayer")
local PurchaseMainLayer = class("AuctionMainLayer", BaseLayer)

function PurchaseMainLayer:ctor()
    PurchaseMainLayer.super.ctor(self)
end

function PurchaseMainLayer.create(...)
    local ui = PurchaseMainLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function PurchaseMainLayer:Init(data)
    self._quickUI = ui_delegate(self)
    local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    self._itemConfig = AuctionProxy:GetItemConfig()
    return true
end

function PurchaseMainLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PURCHASE_MAIN)
    PurchaseMain.main()

    self:InitSearchPanel()

    self:InitEditMode()
end

function PurchaseMainLayer:InitEditMode()
    local items = {
        "FrameLayout",
        "FrameBG",
        "DressIMG",
        "TitleText",
        "AttachLayout",
        "CloseButton",
        "Panel_search",
        "Button_confirm"
    }

    for _, widgetName in ipairs(items) do
        if self._quickUI[widgetName] then
            self._quickUI[widgetName].editMode = 1
        end
    end
end

function PurchaseMainLayer:SearchAllItemsByKeyWord(str)
    if not str or string.len(str) == 0 then
        ShowSystemTips(GET_STRING(700000021))
        return nil
    end
   
    local matchItems = {}

    local specialR  = {"%[", "%]", "%(","%)","%*"}
    for _, key in ipairs(specialR) do
        str = string.gsub(str, key, "%"..key)
    end
    
    if string.len(str) > 32 then
        ShowSystemTips(GET_STRING(700000021))
        return nil
    end

    for _, v  in pairs(self._itemConfig) do
        if #matchItems > 36 then
            break
        end
        if string.find(v.Name, str) then
            table.insert(matchItems, v.Index)
        end
    end

    if #matchItems > 35 then
        ShowSystemTips(GET_STRING(700000020))
        return nil
    elseif #matchItems == 0 then
        ShowSystemTips(GET_STRING(700000021))
        return nil
    end

    local matchIndexStr = table.concat(matchItems, ",")
    return matchIndexStr
end

function PurchaseMainLayer:InitSearchPanel()
    local function Confirm_Search( )
        local itemName = self._quickUI.SearchInput:getString()
        if string.len(itemName) < 1 then
            ShowSystemTips(GET_STRING(300000011))
            SLBridge:onLUAEvent(LUA_EVENT_PURCHASE_SEARCH_ITEM_UPDATE, nil)
            return
        end
        local searchItem = self:SearchAllItemsByKeyWord(itemName)
        SLBridge:onLUAEvent(LUA_EVENT_PURCHASE_SEARCH_ITEM_UPDATE, searchItem)
    end

    self._quickUI.SearchInput:addEventListener(function(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
            self._quickUI.SearchInput:setString("")
        elseif eventType == ccui.TextFiledEventType.insert_text then
            local str = sender:getString()
            if sender.closeKeyboard and string.find(str, "\n") then
                sender:closeKeyboard()
                sender:setString(string.trim(str))
                performWithDelay(self._quickUI.SearchInput, function() Confirm_Search() end, 0.01)
            end
        end
    end)

    self._quickUI.Button_confirm:addClickEventListener(Confirm_Search)
end

function PurchaseMainLayer:OnClose()
    if PurchaseMain and PurchaseMain.OnClose then
        PurchaseMain.OnClose()
    end
end

return PurchaseMainLayer