local BaseLayer = requireLayerUI("BaseLayer")
local RankLayer = class("RankLayer", BaseLayer)
local richTextHelp = require("util/RichTextHelp")
local cjson = require("cjson")


RankLayer.RankType =
{
    -- 总榜
    RankType_Total = 1,
    -- 战
    RankType_Soldier = 2,
    -- 法
    RankType_Migic = 3,
    -- 道
    RankType_Dao = 4,

}--英雄的 6-9


function RankLayer:ctor()
    RankLayer.super.ctor(self)

end

function RankLayer.create( data )
    local layer = RankLayer.new()
    if layer:Init(data) then
        return layer
    else
        return nil
    end
end

function RankLayer:Init()
    self._quickUI = ui_delegate(self)

    return true
end

function RankLayer:InitGUI(data)
    local setType = nil
    if tonumber(data) and tonumber(data) > 0 then
        setType = tonumber(data)
    end
    local showType = setType or 1

    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_RANK)
    Rank.main(showType)

    self.Panel1 = self._quickUI["Panel_1"]

    self:InitEditMode()
end

function RankLayer:InitEditMode()
    local items = {
        "Image_bg",
        "Button_close",
        "Text_5",
        "Text_level",
        "Text_7",
        "Text_guildName",
        "Button_looks",
        "Image_13",
        "Panel_player",
        "Panel_hero",
        "Button_1",
        "Text_title1",
        "Button_2",
        "Text_title2",
        "Node_model",
        "ListView_list",
    }

    for _, widget in ipairs(items) do
        if self._quickUI[widget] then
            self._quickUI[widget].editMode = 1
        end
    end
end

return RankLayer
