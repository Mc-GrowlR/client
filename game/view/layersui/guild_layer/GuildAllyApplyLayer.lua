local BaseLayer = requireLayerUI("BaseLayer")
local GuildAllyApplyLayer = class("GuildAllyApplyLayer", BaseLayer)

function GuildAllyApplyLayer:ctor()
    GuildAllyApplyLayer.super.ctor(self)
end

function GuildAllyApplyLayer.create(...)
    local layer = GuildAllyApplyLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function GuildAllyApplyLayer:Init()
    return true
end

function GuildAllyApplyLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GUILD_ALLY_APPLY)
    GuildAllyApply.main()
end

return GuildAllyApplyLayer

