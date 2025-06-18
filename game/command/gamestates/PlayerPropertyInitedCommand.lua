local PlayerPropertyInitedCommand = class('PlayerPropertyInitedCommand', framework.SimpleCommand)

--README:初始化信息
function PlayerPropertyInitedCommand:ctor()

end

function PlayerPropertyInitedCommand:execute(note)
    -- 初始化设置信息
    local PlayerProperty = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    local envProxy = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    
    -- bag data
    local bagProxy = global.Facade:retrieveProxy( global.ProxyTable.Bag )
    bagProxy:RequestBagData()

    -- begin check game server heart beat
    if global.Platform == cc.PLATFORM_OS_WINDOWS then
        global.LuaBridgeCtl:SetModulesSwitch( global.MMO.Modules_Index_Enable_Check_Heart_Beat, 0 )
    else
        global.LuaBridgeCtl:SetModulesSwitch( global.MMO.Modules_Index_Enable_Check_Heart_Beat, 1 )
    end

    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    GuildProxy:RequestGuildInfo()
    GuildProxy:RequestWorldGuildList()
    GuildProxy:RequestApplyGuildList()
    GuildProxy:RequestGuildAllyApplyList()

    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    GameSettingProxy:OnPropertyInited()

    --friend data
    local FriendProxy = global.Facade:retrieveProxy( global.ProxyTable.FriendProxy )
    FriendProxy:loginRequest()

    -- box996 data
    local Box996Proxy = global.Facade:retrieveProxy( global.ProxyTable.Box996Proxy )
    Box996Proxy:loginRequest()

    -- meridian open data
    if tonumber(SL:GetMetaValue("GAME_DATA", "OpenNGUI")) == 1 then
        local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
        MeridianProxy:RequestGetMeridianInfo()
        MeridianProxy:RequestGetMeridianInfo(true)
    end
end

return PlayerPropertyInitedCommand
