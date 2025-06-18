local RealNameCommand = class('RealNameCommand', framework.SimpleCommand)

function RealNameCommand:ctor()
end

function RealNameCommand:execute(notification)
    local facade = global.Facade
    local data = notification:getBody()
    
    local status = data.status--2成年  3未成年
    local RealNameProxy = global.Facade:retrieveProxy(global.ProxyTable.RealNameProxy)
    RealNameProxy:RequestRealNameRes(data.status == "2" and 1 or 0)
end



return RealNameCommand