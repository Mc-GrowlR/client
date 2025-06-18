local BaseLayer = requireLayerUI("BaseLayer")
local AuctionMainLayer = class("AuctionMainLayer", BaseLayer)

function AuctionMainLayer:ctor()
    AuctionMainLayer.super.ctor(self)
end

function AuctionMainLayer.create(...)
    local ui = AuctionMainLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function AuctionMainLayer:Init(data)
    self._quickUI = ui_delegate(self)
    return true
end

function AuctionMainLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUCTION_MAIN)
    AuctionMain.main()

    self:InitSearchPanel()

    self:InitEditMode()
end

function AuctionMainLayer:InitEditMode()
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

function AuctionMainLayer:InitSearchPanel()
    local function Confirm_Search( )
        local itemName = self._quickUI.SearchInput:getString()
        if string.len(itemName) < 1 then
            return ShowSystemTips(GET_STRING(300000011))
        end
        global.Facade:sendNotification(global.NoticeTable.AuctionWorldItemSearch, itemName)
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

function AuctionMainLayer:UpdateGroupCells()
    AuctionMain.UpdateGroupCells()
end

function AuctionMainLayer:OnClose()
    AuctionMain.OnClose()
end

return AuctionMainLayer