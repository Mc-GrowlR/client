--[[
    {
        action = "xxx",
        method = "xxx",
        status = "success" / "failed"
        data = ...
    }

 ]]

local Message = class("Message")
local cjson = require( "cjson" )

function Message:ctor(action, data, ex1, ex2, ex3)
    self.action = action
    self.data = data

    -- 增加扩展参数，只在发送时使用，服务器做不到解析json给脚本
    self.ex1 = ex1
    self.ex2 = ex2
    self.ex3 = ex3
end

function Message:load(stream)
    local obj = cjson.decode(stream)
    if not obj then
        return nil
    end
    self:setAction(obj.action)
    self:setData(obj.data)
    return self
end

function Message:dump()
    local obj = {
        action = self:getAction(),
        data = self:getData(),
        ex1 = self.ex1,
        ex2 = self.ex2,
        ex3 = self.ex3,
    }
    return cjson.encode(obj)
end

function Message:setAction(action)
    self.action = action
end

function Message:getAction()
    return self.action
end

function Message:setData(data)
    self.data = data
end

function Message:getData()
    return self.data
end

return Message