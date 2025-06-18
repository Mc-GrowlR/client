local RemoteProxy = requireProxy("remote/RemoteProxy")
local PayProxy = class("PayProxy", RemoteProxy)
PayProxy.NAME = global.ProxyTable.PayProxy

function PayProxy:ctor()
    PayProxy.super.ctor(self)
end

-- 获得道具数量 统一接口
function PayProxy:GetItemCount(itemID, bOneID)
    if bOneID then
        return GetItemDataNumber(itemID, { realbool = true })
    end
    return GetItemDataNumber(itemID)
end

-- 检查道具是否符合条件
function PayProxy:CheckItemCount(itemID, itemNum, bOneID, speicalYuanBao)
    local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
    local typeConfig = MoneyProxy:GetMoneyType()
    local myCount = 0
    if speicalYuanBao and (itemID == typeConfig.YuanBao or itemID == typeConfig.BindYuanBao) then
        myCount = self:GetItemCount(typeConfig.YuanBao, bOneID) + self:GetItemCount(typeConfig.BindYuanBao, bOneID)
    else
        myCount = self:GetItemCount(itemID, bOneID)
    end
    return myCount >= itemNum
end

-- 检查道具是否符合条件 带提示 
function PayProxy:CheckItemCountEX(data)
    if not data.itemID and not data.itemNum then
        return false
    end

    if not self:CheckItemCount(data.itemID, data.itemNum, data.bOneID, data.speicalYuanBao) then
        if not data.noTips then 
            local ItemConfigProxy = global.Facade:retrieveProxy( global.ProxyTable.ItemConfigProxy )
            global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(260100), ItemConfigProxy:GetItemNameByIndex(data.itemID)))
        end
        return false
    end

    return true
end

return PayProxy