local ReconnectCommand = class('ReconnectCommand', framework.SimpleCommand)

function ReconnectCommand:ctor()

end

function ReconnectCommand:execute(note)
    releasePrint( "reconnect success")
    local facade = global.Facade

    local disconnectProxy = facade:retrieveProxy( global.ProxyTable.Disconnect )
    disconnectProxy:SetDisconnect( false )

    global.BuffManager:Cleanup()
    global.ActorEffectManager:Cleanup()
    global.gameMapController:CleanupActor( true )
    global.monsterManager:SetPetOfMainAlive( false ) 

    -- 角色是否活着
    local PlayerProperty = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    if not PlayerProperty:IsAlive() then
        PlayerProperty:setAlive( true )
    end

    local BagProxy = global.Facade:retrieveProxy( global.ProxyTable.Bag )
    BagProxy:SetReconnect(true)
    BagProxy:ClearItemData(true)
    BagProxy:Inited(false)

    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    EquipProxy:ClearEquipData()

    local PetsEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.PetsEquipProxy)
    PetsEquipProxy:ClearEquipData()

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    ItemManagerProxy:CleanItemBelongs()

    local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
    MoneyProxy:ResetInitStatus()

    SL:CloseBagUI()
    SL:CloseMyPlayerUI()

    BagProxy:RequestBagData()

    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:ClearTeam()
    
    local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    npcProxy:Cleanup()

    local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
    global.Facade:sendNotification( global.NoticeTable.Layer_StallLayer_Close)
    StallProxy:CleanMySellData()
    StallProxy:SetMyTradingStatus(false)

    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    GameSettingProxy:OnReConnectInited()

    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    ChatProxy:ClearChatExItemsData()
    ---------------------------------

    -- ssr
    ssr.ssrBridge:onReconnect()

    
    SLBridge:onLUAEvent(LUA_EVENT_RECONNECT)

    ---------------------------------英雄清理
    local HeroBagProxy = global.Facade:retrieveProxy( global.ProxyTable.HeroBagProxy )
    HeroBagProxy:ClearItemData()
    HeroBagProxy:Inited(false)

    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    HeroEquipProxy:ClearEquipData()

    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    HeroPropertyProxy:NoticeOut()
    
    -----召唤物按钮刷新
    local SummonsProxy = global.Facade:retrieveProxy( global.ProxyTable.SummonsProxy )
    SummonsProxy:clear()
    local PetsEquipProxy = global.Facade:retrieveProxy( global.ProxyTable.PetsEquipProxy )
    PetsEquipProxy:clear()
    
    global.Facade:sendNotification( global.NoticeTable.SummonsAliveStatusChange)
    global.Facade:sendNotification(global.NoticeTable.MainExChatClean)
    
end

return ReconnectCommand
