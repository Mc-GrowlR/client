local BaseLayer = requireLayerUI("BaseLayer")
local GuildFrameLayer = class("GuildFrameLayer", BaseLayer)

function GuildFrameLayer:ctor()
    GuildFrameLayer.super.ctor(self)
end

function GuildFrameLayer.create(...)
    local layer = GuildFrameLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function GuildFrameLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function GuildFrameLayer:InitGUI(Index)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GUILD_FRAME)
    GuildFrame.main(Index)

    self:InitEditMode()
end

function GuildFrameLayer:InitEditMode()
    local items = {
        "FrameLayout",
        "FrameBG",
        "DressIMG",
        "TitleText",
        "AttachLayout",
        "CloseButton",
    }

    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end

    for i = 1, 3 do
        if self._ui["page_cell_"..i] then
            self._ui["page_cell_"..i].editMode = 1
            local text = self._ui["page_cell_"..i]:getChildByName("PageText") 
            if text then
                text.editMode = 1
            end
        end
    end
end

function GuildFrameLayer:OnClose()
    if GuildFrame then
        GuildFrame.OnClose()
    end
end

function GuildFrameLayer:OnRefresh(data)
    GuildFrame.OnRefresh(data)
end

function GuildFrameLayer:PageTo(data)
    if GuildFrame then
        local layerId = nil
        if data and GuildFrame._pageIDs then
            layerId = GuildFrame._pageIDs[data]
        end
        GuildFrame.PageTo(layerId)
    end
end

function GuildFrameLayer:GetSUIParent()
    return self._ui.FrameBG
end

return GuildFrameLayer
