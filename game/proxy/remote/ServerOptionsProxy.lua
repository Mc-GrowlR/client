local RemoteProxy = requireProxy("remote/RemoteProxy")
local ServerOptionsProxy = class("ServerOptionsProxy", RemoteProxy)
ServerOptionsProxy.NAME = global.ProxyTable.ServerOptionsProxy

function ServerOptionsProxy:ctor()
    ServerOptionsProxy.super.ctor(self)

    self._data = {}
end

function ServerOptionsProxy:setOptions(data)
    if not data then
        return
    end

    self._data = data
end

function ServerOptionsProxy:setOptionByKey(k, v)
    self._data[k] = v
end

function ServerOptionsProxy:checkOption(id)
    return self._data[id]
end

function CHECK_SERVER_OPTION(id)
    local ServerOptionsProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerOptionsProxy)
    if not ServerOptionsProxy then
        return false
    end
    return ServerOptionsProxy:checkOption(id)
end

return ServerOptionsProxy