--[[
    author:yzy
    time:2021-01-29 15:36:22
]]
local BaseLayer = requireLayerUI("BaseLayer")
local SplitLayer = class("SplitLayer", BaseLayer)

local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)

function SplitLayer:ctor()
    SplitLayer.super.ctor(self)
end

function SplitLayer:Init(data)
    if not data then
        return false
    end

    return true
end

function SplitLayer.create(...)
    local ui = SplitLayer.new()

    if ui and ui:Init(...) then
        return ui
    end
end

function SplitLayer:InitGUI(data)
    if not data then
        return
    end
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_ITEM_SPLIT_POP)
    ItemSplitPop.main(data)

end

return SplitLayer
