local DebugMediator = requireMediator("DebugMediator")
local SUIManager = class("SUIManager", DebugMediator)
SUIManager.NAME = "SUIManager"

function SUIManager:ctor()
    SUIManager.super.ctor(self, self.NAME)

    self._allITEMBOXWidgets     = {}
    self._ITEMBOXItems          = {}
    
    self._allItemShowWidgets    = {}
    self._itemShowElements      = {}
    self._itemShowItems         = {}
end

function SUIManager:destory()
    if SUIManager.instance then
        global.Facade:removeMediator( SUIManager.NAME )
        SUIManager.instance = nil
    end
end

function SUIManager:Inst()
    if not SUIManager.instance then
        SUIManager.instance = SUIManager.new()
        global.Facade:registerMediator(SUIManager.instance)
    end
    return SUIManager.instance
end

function SUIManager:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.SUIITEMBOXWidgetAdd,
        noticeTable.SUIITEMBOXPutoutAll,
        noticeTable.ReleaseMemory,
    }
end

function SUIManager:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.SUIITEMBOXWidgetAdd == noticeID then
        self:OnSUIITEMBOXWidgetAdd(data)

    elseif noticeTable.SUIITEMBOXPutoutAll == noticeID then
        self:OnSUIITEMBOXPutoutAll(data)

    elseif noticeTable.ReleaseMemory == noticeID then
        self:OnReleaseMemory(data)
    end
end

function SUIManager:OnReleaseMemory(data)
    self._ITEMBOXItems = {}
end

----------------------------
function SUIManager:OnSUIITEMBOXWidgetAdd(data)
    local boxindex = data.boxindex
    local widget   = data.widget

    -- 监听事件;
    widget:registerScriptHandler( function(state)
        if state == "enter" then
            if boxindex then
                self._allITEMBOXWidgets[boxindex] = widget
                self:ReloadITEMBOXWidget(boxindex, false)
            end

        elseif state == "exit" then
            if boxindex then
                self._allITEMBOXWidgets[boxindex] = nil
            end
        end
    end )
end

function SUIManager:OnSUIITEMBOXPutoutAll()
    --
    for boxindex, itembox in pairs(self._ITEMBOXItems) do
        local npcProxy   = global.Facade:retrieveProxy(global.ProxyTable.NPC)
        local submitData =
        {
            index       = boxindex,
            npcid       = npcProxy:GetCurrentNPCID()
        }
        global.SUIManager:RequestITEMBOXPutout(submitData)
        
    end
end

function SUIManager:ReloadAllITEMBOXWidgets()
    for boxindex, itemboxWidget in pairs(self._allITEMBOXWidgets) do
        self:ReloadITEMBOXWidget(boxindex)
    end
end

function SUIManager:ReloadITEMBOXWidget(boxindex,notCheckHave)
    local itemboxWidget = self._allITEMBOXWidgets[boxindex]
    if nil == itemboxWidget then
        return nil
    end
    local itemData      = self._ITEMBOXItems[boxindex]
    
    local MakeIndex     = itemData and itemData.MakeIndex
    if notCheckHave==false and MakeIndex then
        local BagProxy = global.Facade:retrieveProxy( global.ProxyTable.Bag )
        itemData = BagProxy:GetItemDataByMakeIndex(MakeIndex)

        if not itemData then
            local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
            local itemType = ItemManagerProxy:GetItemType(itemData)
            if itemType == ItemManagerProxy.ItemType.Equip then
                local EquipProxy = global.Facade:retrieveProxy( global.ProxyTable.Equip )
                itemData = EquipProxy:GetEquipDataByMakeIndex(MakeIndex) 
            end
        end
    end

    if nil == itemData then
        itemboxWidget:removeChildByName("item")
        return nil
    end

    local contentSize = itemboxWidget:getContentSize()
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    -- 
    local info = {}
    info.index      = itemData.Index
    info.itemData   = itemData
    info.movable    = true
    info.look       = true
    info.from       = ItemMoveProxy.ItemFrom.ITEMBOX
    local goodItem  = GoodsItem:create(info)
    itemboxWidget:removeChildByName("item")
    itemboxWidget:addChild(goodItem)
    goodItem:setName("item")
    goodItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
end

function SUIManager:GetITEMBOXIndexByMakeIndex(makeindex)
    for k, v in pairs(self._ITEMBOXItems) do
        if v.MakeIndex == makeindex then
            return k
        end
    end
    return nil
end


function SUIManager:LoadItemShowWidget(itemid)
    if nil == self._itemShowItems[itemid] then
        self:RequestItemShowInfo(itemid)
        return nil
    end

    for k, element in pairs(self._itemShowElements) do
        if element.itemid == itemid then
            local itemData  = self._itemShowItems[itemid]

            -- 
            local info = {}
            info.index      = itemData.Index
            info.itemData   = itemData
            info.look       = element.showtips == 1
            info.count      = element.itemcount
            info.bgVisible  = element.bgtype == 1
            local goodItem  = GoodsItem:create(info)
            element.widget:removeChildByName("item")
            element.widget:addChild(goodItem)
            goodItem:setName("item")
            goodItem:setPosition(cc.p(35, 35))
        end
    end
end




function SUIManager:onRegister()
    SUIManager.super.onRegister(self)
end

function SUIManager:RegisterMsgHandlerAfterEnterWorld()
    
    local msgType = global.MsgType
    LuaRegisterMsgHandler(msgType.MSG_SC_ITEMBOX_UPDATE, handler(self, self.RespITEMBOXUpdate))
    LuaRegisterMsgHandler(msgType.MSG_SC_ITEMBOX_REMOVE, handler(self, self.RespITEMBOXRemove))
    LuaRegisterMsgHandler(msgType.MSG_SC_ItemShow_INFO, handler(self, self.RespItemShowInfo))
end

function SUIManager:RespITEMBOXUpdate(msg)
    local jsonData  = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end
    local header    = msg:GetHeader()
    local boxindex  = header.recog
    local itemData  = ChangeItemServersSendDatas(jsonData)
    -- dump(header)
    -- dump(jsonData)

    self._ITEMBOXItems[boxindex] = itemData

    -- 
    self:ReloadITEMBOXWidget(boxindex)
end

function SUIManager:RespITEMBOXRemove(msg)
    local header    = msg:GetHeader()
    local boxindex  = header.recog
    self._ITEMBOXItems[boxindex] = nil

    -- dump(boxindex)
    -- 
    self:ReloadITEMBOXWidget(boxindex)
end

function SUIManager:RequestITEMBOXPutin(data)
    -- dump(data)
    SendTableToServer(global.MsgType.MSG_CS_ITEMBOX_PUTIN, data)
end

function SUIManager:RequestITEMBOXPutout(data)
    -- dump(data)
    SendTableToServer(global.MsgType.MSG_CS_ITEMBOX_PUTOUT, data)
end


function SUIManager:RespItemShowInfo(msg)
    local jsonData  = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end

    local itemData  = ChangeItemServersSendDatas(jsonData)

    self._itemShowItems[itemData.Index] = itemData

    -- 
    self:LoadItemShowWidget(itemData.Index)
end

function SUIManager:RequestItemShowInfo(itemid)
    -- dump(itemid)
    LuaSendMsg(global.MsgType.MSG_CS_ItemShow_INFO, itemid)
end

return SUIManager
