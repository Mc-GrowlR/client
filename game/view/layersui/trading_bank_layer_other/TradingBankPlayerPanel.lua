local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankPlayerPanel = class("TradingBankPlayerPanel", BaseLayer)

function TradingBankPlayerPanel:ctor()
    TradingBankPlayerPanel.super.ctor(self)
end

function TradingBankPlayerPanel.create(...)
    local layer = TradingBankPlayerPanel.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function TradingBankPlayerPanel:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function TradingBankPlayerPanel:InitGUI(Index)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_PLAYER_FRAME)
    PlayerHeroFrame_Look_TradingBank.main(Index)
    self._CaptureNode = PlayerHeroFrame_Look_TradingBank._ui.Panel_1
    self._panel = self._quickUI.Panel_1

    self:InitEditMode()
end

function TradingBankPlayerPanel:InitEditMode(...)
    local items =     {
        "Image_bg",
        "Node_panel",
        "Button_4",
        "Button_1",
        "Button_2",
        "Panel_btnList"
    }
    for _, widgetName in ipairs(items) do
        if self._quickUI[widgetName] then
            self._quickUI[widgetName].editMode = 1
        end
    end

    if PlayerHeroFrame_Look_TradingBank._pageIDs then
        for _, id in ipairs(PlayerHeroFrame_Look_TradingBank._pageIDs) do
            if self._quickUI["Button_page" .. id] then
                self._quickUI["Button_page" .. id].editMode = 1
                local btnText = self._quickUI["Button_page" .. id]:getChildByName("Text_name")
                if btnText then
                    btnText.editMode = 1
                end
            end
        end
    end
end

--1角色  2 英雄
function TradingBankPlayerPanel:ShowPlayerInfo(data, type)
    if not PlayerHeroFrame_Look_TradingBank._ishero and type == 2 then
        PlayerHeroFrame_Look_TradingBank._curIdx = 1
        PlayerHeroFrame_Look_TradingBank.setButton(type)
        PlayerHeroFrame_Look_TradingBank.changeHeroAndRole()
        PlayerHeroFrame_Look_TradingBank.RefPanel()
        PlayerHeroFrame_Look_TradingBank.InitPage()
    else
        if PlayerHeroFrame_Look_TradingBank._pageid == data then
            return
        end

        if data == SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BAG or data == SLDefine.PlayerPage.MAIN_PLAYER_LAYER_STORAGE then
            PlayerHeroFrame_Look_TradingBank._curIdx = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BAG == data and 2 or 3
            PlayerHeroFrame_Look_TradingBank.ChangePage({ index = data })
        else
            PlayerHeroFrame_Look_TradingBank._curIdx = 1
            PlayerHeroFrame_Look_TradingBank.OpenPage(data, { pageId = data })
        end
        PlayerHeroFrame_Look_TradingBank.RefPanel()
    end
end

function TradingBankPlayerPanel:showHidePanel(data)
    PlayerHeroFrame_Look_TradingBank.showHidePanel(data)
end

function TradingBankPlayerPanel:OnCloseMainLayer(data)
    PlayerHeroFrame_Look_TradingBank.OnCloseMainLayer(data)
end

return TradingBankPlayerPanel