local BaseUIMediator = requireMediator( "BaseUIMediator" )
local RedPointMediator = class("RedPointMediator", BaseUIMediator)
RedPointMediator.NAME = "RedPointMediator"

function RedPointMediator:ctor()
    RedPointMediator.super.ctor( self )
end

function RedPointMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
            noticeTable.GameWorldInitComplete,
            noticeTable.NPCTalkLayer_Open_Success,
            noticeTable.SUIComponentUpdate,
            noticeTable.PlayerMoneyChange,
            noticeTable.Bag_Oper_Data,
            noticeTable.Layer_Bag_Load_Success,
            noticeTable.QuickUseItemAdd,
            noticeTable.QuickUseItemRmv,
            noticeTable.QuickUseItemChange,
            noticeTable.Layer_PlayerFrame_Load_Success,
            noticeTable.Layer_Player_Equip_Load_Success,
            noticeTable.PlayerLevelInit,
            noticeTable.PlayerLevelChange,
            noticeTable.PlayerAttribute_Change,
            noticeTable.PlayerManaChange,
            noticeTable.PlayerExpChange,
            noticeTable.PlayerReinLevelChange,
            noticeTable.PlayEquip_Oper_Data,
            noticeTable.PlayEquip_Oper_Init,
            noticeTable.PlayerJobChange,
            noticeTable.PlayerSexChange,
            
            noticeTable.Layer_HeroBag_Load_Success,
            noticeTable.PlayerLevelChange_Hero,
            noticeTable.PlayerAttribute_Change_Hero,
            noticeTable.PlayerManaChange_Hero,
            noticeTable.PlayerExpChange_Hero,
            noticeTable.PlayerReinLevelChange_Hero,
            noticeTable.PlayEquip_Oper_Data_Hero,
            noticeTable.PlayEquip_Oper_Init_Hero,
            noticeTable.PlayerJobChange_Hero,
            noticeTable.PlayerSexChange_Hero,
            noticeTable.Layer_Hero_Logout,

            }
end

function RedPointMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.GameWorldInitComplete == noticeName then
        self:startSchedule(noticeData)
    elseif noticeTable.NPCTalkLayer_Open_Success == noticeName then
        self:onNpcLayerOpen(noticeData)
    elseif noticeTable.SUIComponentUpdate == noticeName then
        self:onSUIComponentUpdate(noticeData)
    elseif noticeTable.PlayerMoneyChange == noticeName then
        self:onPlayerMoneyChange(noticeData)
    elseif noticeTable.Bag_Oper_Data == noticeName then
        self:onBag_Oper_Data(noticeData)
    elseif noticeTable.Layer_Bag_Load_Success == noticeName then
        self:onBagLayerLoadSuccess(noticeData)
    elseif noticeTable.QuickUseItemAdd == noticeName 
    or noticeTable.QuickUseItemRmv == noticeName
    or noticeTable.QuickUseItemChange == noticeName
    then
        self:onQuickUseItemChange(noticeData)
    elseif noticeTable.Layer_PlayerFrame_Load_Success == noticeName then
        self:onPlayerFrameLoadSuccess(noticeData)
    elseif noticeTable.Layer_Player_Equip_Load_Success == noticeName then
        self:onPlayerEquipLoadSuccess(noticeData)
    elseif noticeTable.PlayerLevelChange == noticeName or noticeTable.PlayerLevelInit == noticeName  then
        self:onPlayerLevelChange(noticeData)
    elseif noticeTable.PlayerAttribute_Change == noticeName then
        self:onPlayerAttributeChange(noticeData)
    elseif noticeTable.PlayerManaChange == noticeName then
        self:onPlayerManaChange(noticeData)
    elseif noticeTable.PlayerExpChange == noticeName then
        self:onPlayerExpChange(noticeData)
    elseif noticeTable.PlayerReinLevelChange == noticeName then
        self:onPlayerReinLevelChange(noticeData)
    elseif noticeTable.PlayEquip_Oper_Data == noticeName then 
        self:onPlayEquipChange(noticeData)
    elseif noticeTable.PlayEquip_Oper_Init == noticeName then 
        self:onPlayEquipInit(noticeData)
    elseif noticeTable.PlayerJobChange == noticeName then 
        self:onPlayerJobChange(noticeData)
    elseif noticeTable.PlayerSexChange == noticeName then 
        self:onPlayerSexChange(noticeData)

    elseif noticeTable.Layer_HeroBag_Load_Success == noticeName then
        self:onHeroBagLayerLoadSuccess(noticeData)
    elseif noticeTable.Layer_HeroFrame_Load_Success == noticeName then
        self:onHeroFrameLoadSuccess(noticeData)
    elseif noticeTable.Layer_Hero_Equip_Load_Success == noticeName then
        self:onHeroEquipLoadSuccess(noticeData)
    elseif noticeTable.PlayerLevelChange_Hero == noticeName then
        self:onPlayerLevelChange_Hero(noticeData)
    elseif noticeTable.PlayerAttribute_Change_Hero == noticeName then
        self:onPlayerAttributeChange_Hero(noticeData)
    elseif noticeTable.PlayerManaChange_Hero == noticeName then
        self:onPlayerManaChange_Hero(noticeData)
    elseif noticeTable.PlayerExpChange_Hero == noticeName then
        self:onPlayerExpChange_Hero(noticeData)
    elseif noticeTable.PlayerReinLevelChange_Hero == noticeName then
        self:onPlayerReinLevelChange_Hero(noticeData)
    elseif noticeTable.PlayEquip_Oper_Data_Hero == noticeName  then 
        self:onPlayEquipChange_Hero(noticeData)
    elseif noticeTable.PlayEquip_Oper_Init_Hero == noticeName then 
        self:onPlayEquipInit_Hero(noticeData)
    elseif noticeTable.PlayerJobChange_Hero == noticeName then 
        self:onPlayerJobChange_Hero(noticeData)
    elseif noticeTable.PlayerSexChange_Hero == noticeName then 
        self:onPlayerSexChange_Hero(noticeData)
    elseif noticeTable.Layer_Hero_Logout == noticeName then 
        self:onLayer_Hero_Logout(noticeData)
    end
end



function RedPointMediator:startSchedule(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:StartSchedule()
    end
    local BubbleProxy  = global.Facade:retrieveProxy(global.ProxyTable.BubbleProxy)
    if BubbleProxy then
        BubbleProxy:StartSchedule()
    end
end

function RedPointMediator:onSUIComponentUpdate(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:onSUIComponentUpdate(data)
    end
end

function RedPointMediator:onNpcLayerOpen(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:onNpcLayerOpen()
    end
end

function RedPointMediator:onBagLayerLoadSuccess(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:onBagLayerLoadSuccess()
    end
end

function RedPointMediator:onHeroBagLayerLoadSuccess(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:onHeroBagLayerLoadSuccess()
    end
end

function RedPointMediator:onLayer_Hero_Logout(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:InstertCheckQue("H_LEVEL")
        RedPointProxy:InstertCheckQue("H_RELEVEL")
        RedPointProxy:InstertCheckQue("H_JOB")
        RedPointProxy:InstertCheckQue("H_GENDER")
        RedPointProxy:InstertCheckQue("H_MAXHP")
        RedPointProxy:InstertCheckQue("H_MAXMP")
        RedPointProxy:InstertCheckQue("H_EXP")
        RedPointProxy:InstertCheckQue("H_STARCOUNTALL")
        RedPointProxy:InstertCheckQue("H_HP")
        RedPointProxy:InstertCheckQue("H_MP")
        RedPointProxy:InstertCheckQue("H_MAXAC")
        RedPointProxy:InstertCheckQue("H_MAXMAC")
        RedPointProxy:InstertCheckQue("H_MAXDC")
        RedPointProxy:InstertCheckQue("H_MAXMC")
        RedPointProxy:InstertCheckQue("H_MAXSC")
        for i = 0,16 do
            RedPointProxy:InstertCheckQue("H_USEITEMNAME_"..i)
            RedPointProxy:InstertCheckQue("H_USEITEMID_"..i)
        end
    end
end
function RedPointMediator:onPlayerMoneyChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        local id = data.id or 0
        local ItemConfigProxy = global.Facade:retrieveProxy( global.ProxyTable.ItemConfigProxy )
        local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
        local moneys =  ItemConfigProxy:GetSameReservedByMoneyIndex(id)
        for i,v in ipairs(moneys) do
            RedPointProxy:InstertCheckQue("ITEMINDEX_"..v)
            local name = MoneyProxy:GetMoneyNameById(v)
            RedPointProxy:InstertCheckQue("MONEY_"..name)
        end
        RedPointProxy:InstertCheckQue("ITEMINDEX_"..id)
        local name = MoneyProxy:GetMoneyNameById(id)
        RedPointProxy:InstertCheckQue("MONEY_"..name)
    end
end
function RedPointMediator:onBag_Oper_Data(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        local operID = data.operID or {}
        if (data.opera == global.MMO.Operator_Change) then
            for i,v in ipairs(operID) do
                if v.change and v.change ~= 0 then  
                    local id = v.item.Index or 0
                    RedPointProxy:InstertCheckQue("ITEMINDEX_" .. id)
                end
            end
        else
            for i,v in ipairs(operID) do
                local id = v.item.Index or 0
                RedPointProxy:InstertCheckQue("ITEMINDEX_" .. id)
            end
        end
    end
end

function RedPointMediator:onQuickUseItemChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        local id = (data and data.itemData and data.itemData.Index) or 0
        RedPointProxy:InstertCheckQue("ITEMINDEX_"..id)
    end
end

function RedPointMediator:onPlayerFrameLoadSuccess(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:onPlayerFrameLoadSuccess()
    end
end

function RedPointMediator:onPlayerEquipLoadSuccess(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:onPlayerEquipLoadSuccess()
    end
end

function RedPointMediator:onHeroFrameLoadSuccess(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:onHeroFrameLoadSuccess()
    end
end

function RedPointMediator:onHeroEquipLoadSuccess(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:onHeroEquipLoadSuccess()
    end
end

function RedPointMediator:onPlayerLevelChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:InstertCheckQue("LEVEL")
    end
end
function RedPointMediator:onPlayerLevelChange_Hero(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:InstertCheckQue("H_LEVEL")
    end
end
function RedPointMediator:onPlayerReinLevelChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:InstertCheckQue("RELEVEL")
    end
end
function RedPointMediator:onPlayerReinLevelChange_Hero(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:InstertCheckQue("H_RELEVEL")
    end
end
function RedPointMediator:onPlayerJobChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:InstertCheckQue("JOB")
    end
end
function RedPointMediator:onPlayerJobChange_Hero(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:InstertCheckQue("H_JOB")
    end
end
function RedPointMediator:onPlayerSexChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:InstertCheckQue("GENDER")
    end
end
function RedPointMediator:onPlayerSexChange_Hero(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        RedPointProxy:InstertCheckQue("H_GENDER")
    end
end
function RedPointMediator:onPlayerManaChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        if data.maxHPChange then 
            RedPointProxy:InstertCheckQue("MAXHP")
        end
        if data.maxMPChange then 
            RedPointProxy:InstertCheckQue("MAXMP")
        end
        
    end
end
function RedPointMediator:onPlayerManaChange_Hero(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        if data.maxHPChange then 
            RedPointProxy:InstertCheckQue("H_MAXHP")
        end
        if data.maxMPChange then 
            RedPointProxy:InstertCheckQue("H_MAXMP")
        end
        
    end
end
function RedPointMediator:onPlayerExpChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        if not self._expDelay then
            self._expDelay = true
            PerformWithDelayGlobal(function()
                self._expDelay = false
                RedPointProxy:InstertCheckQue("EXP")
            end,2) 
        
        end
    end
end
function RedPointMediator:onPlayerExpChange_Hero(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        if not self._hexpDelay then
            self._hexpDelay = true
            PerformWithDelayGlobal(function()
                self._hexpDelay = false
                RedPointProxy:InstertCheckQue("H_EXP")
            end,2) 
        end
    end
end

function RedPointMediator:onPlayEquipChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        if not self._EquipChangeDelay then
            self._EquipChangeDelay = true
            PerformWithDelayGlobal(function()
                self._EquipChangeDelay = false
                RedPointProxy:InstertCheckQue("STARCOUNTALL")
                local pos = data.Where or 0
                RedPointProxy:InstertCheckQue("USEITEMNAME_"..pos)
                RedPointProxy:InstertCheckQue("USEITEMID_"..pos)
            end,2) 
        end
    end
end

function RedPointMediator:onPlayEquipChange_Hero(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        if not self._EquipChangeDelay then
            self._EquipChangeDelay = true
            PerformWithDelayGlobal(function()
                self._EquipChangeDelay = false
                RedPointProxy:InstertCheckQue("H_STARCOUNTALL")
                local pos = data and  data.Where or 0
                RedPointProxy:InstertCheckQue("H_USEITEMNAME_"..pos)
                RedPointProxy:InstertCheckQue("H_USEITEMID_"..pos)
            end,2) 
        end
    end
end

function RedPointMediator:onPlayEquipInit(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local equipData =  EquipProxy:GetEquipData()
        for i, v in pairs(equipData) do
            local pos = v.Where or 0
            RedPointProxy:InstertCheckQue("USEITEMNAME_"..pos)
            RedPointProxy:InstertCheckQue("USEITEMID_"..pos)
        end
        RedPointProxy:InstertCheckQue("STARCOUNTALL")
    end
end

function RedPointMediator:onPlayEquipInit_Hero(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        local equipData =  HeroEquipProxy:GetEquipData()
        for i, v in pairs(equipData) do
            local pos = v.Where or 0
            RedPointProxy:InstertCheckQue("H_USEITEMNAME_"..pos)
            RedPointProxy:InstertCheckQue("H_USEITEMID_"..pos)
        end
        RedPointProxy:InstertCheckQue("H_STARCOUNTALL")
    end
end

function RedPointMediator:onPlayerAttributeChange(data)
    local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        local id =  data.id
        local attT =  GUIFunction:PShowAttType()
        if id == attT.HP then 
            RedPointProxy:InstertCheckQue("HP")
        elseif id == attT.MP then 
            RedPointProxy:InstertCheckQue("MP")
        elseif id == attT.Max_DEF then 
            RedPointProxy:InstertCheckQue("MAXAC")
        elseif id == attT.Max_MDF then 
            RedPointProxy:InstertCheckQue("MAXMAC")
        elseif id == attT.Max_ATK then 
            RedPointProxy:InstertCheckQue("MAXDC")
        elseif id == attT.Max_MAT then 
            RedPointProxy:InstertCheckQue("MAXMC")
        elseif id == attT.Max_Daoshu then 
            RedPointProxy:InstertCheckQue("MAXSC")
        end
    end
end
function RedPointMediator:onPlayerAttributeChange_Hero(data)
     local RedPointProxy  = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    if RedPointProxy then 
        local id =  data.id
        local attT =  GUIFunction:PShowAttType()
        if id == attT.HP then 
            RedPointProxy:InstertCheckQue("H_HP")
        elseif id == attT.MP then 
            RedPointProxy:InstertCheckQue("H_MP")
        elseif id == attT.Max_DEF then 
            RedPointProxy:InstertCheckQue("H_MAXAC")
        elseif id == attT.Max_MDF then 
            RedPointProxy:InstertCheckQue("H_MAXMAC")
        elseif id == attT.Max_ATK then 
            RedPointProxy:InstertCheckQue("H_MAXDC")
        elseif id == attT.Max_MAT then 
            RedPointProxy:InstertCheckQue("H_MAXMC")
        elseif id == attT.Max_Daoshu then 
            RedPointProxy:InstertCheckQue("H_MAXSC")
        end
    end
end
return RedPointMediator