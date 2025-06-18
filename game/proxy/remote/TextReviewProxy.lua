local RemoteProxy = requireProxy("remote/RemoteProxy")
local TextReviewProxy = class("TextReviewProxy", RemoteProxy)
TextReviewProxy.NAME = global.ProxyTable.TextReviewProxy

local sha1 = require( "sha1/init" )
local cjson = require("cjson")

function TextReviewProxy:ctor()
    TextReviewProxy.super.ctor(self)

    local envProxy  = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    self._isCheckText  = tonumber(envProxy:GetCustomDataByKey("checkText")) == 1

    self._domain = "https://gtf.ai.xingzheai.cn/"
    -- self._domainAbroad = "https://gtf.ai-abroad.xingzheai.cn/"
    self._uri    = "/v2.0/game_chat_ban/detect_text"
    self._url    = "https://gtf.ai.xingzheai.cn/v2.0/game_chat_ban/detect_text"
    self._token  = "9J0IKT8H6NF3UB24"

    self.CONTENT_TYPE = {  --支持“chat”(聊天消息)，“nick”(昵称),"post"(帖 子)，"notice"(公告), "signature"(签名)5种
        "chat","nick","post","notice","signature"
    }

    local envProxy   = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local TextReviewDoamin = envProxy:GetCustomDataByKey("TextReviewDoamin")
    if TextReviewDoamin and string.len(TextReviewDoamin) > 0 then 
        self._domain = TextReviewDoamin .. "/"
        self._url = TextReviewDoamin .. "/v2.0/game_chat_ban/detect_text"
    end
end

function REQUEST_TEXT_REVIEW( contentType, content, autoTips, callbackCB)
    local TextReviewProxy = global.Facade:retrieveProxy( global.ProxyTable.TextReviewProxy )
    return TextReviewProxy:RequestReviewText( contentType, content, autoTips, callbackCB)
end

function TextReviewProxy:RequestReviewText(contentType, content, autoTips, callbackCB)
    local url = self._url
    if not (url and string.len(url) > 0) then
        return nil
    end

    if not contentType or not tonumber(contentType) or not content then
        return nil
    end

    if not self._isCheckText then
        if callbackCB then
            callbackCB(true)
        end
        return false
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            if callbackCB then
                callbackCB(false)
            end
            return false
        end

        local isOk, jsonData = pcall(function ( ... )
            -- body
            return cjson.decode(response)
        end)

        if not isOk then
            releasePrint("TextReview Error : json Data Parsing failed.")
            if callbackCB then
                callbackCB(false)
            end
            return false
        end

        dump(jsonData)
        self.code = jsonData.code
        self.msg = jsonData.msg
        if self.msg and self.msg ~= "success" or self.code == -1 then
            releasePrint("TextReview Error : "..self.msg)
        end
        self.data_id = jsonData.data_id
        self.data = jsonData.data
        -- dump(self.data)
        if self.data and self.data.suggestion then
            -- 
            if self.data.suggestion == "pass" then
                callbackCB(true)
            elseif self.data.suggestion == "review" or self.data.suggestion == "block" then
                if autoTips then
                    ShowSystemTips(GET_STRING(700000010))
                end
                callbackCB(false)
            end
        end

        if self.data and self.data.label then
            -- 
            -- dump(self.data.label)
        end

    end

    local loginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local role_id = loginProxy:GetSelectedRoleID() 

    local originData = {
        {key="data_id",         value= randDataID(role_id)},
        {key="context",         value= content},
        {key="context_type",    value= self.CONTENT_TYPE[tonumber(contentType)]},
        {key="token",           value= self._token},
        -- {key="user_id",         value=data.user_id},
        -- {key="role_id",         value= role_id},
    }
    -- if data.room_id then
    --     table.insert( originData, {key="room_id", value=data.room_id} )
    -- end
    -- if data.area then
    --     table.insert( originData, {key="area", value=data.area} )
    -- end
    local suffix = self:calcDataParam(originData)
    local header = self:getHeader()
    self:HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestReviewText url: " .. url .. "  postData: " .. suffix)
end

function TextReviewProxy:HTTPRequestPost(url, callback, data, header)
    dump({url, callback, data, header},"ssss____")
    local httpRequest = cc.XMLHttpRequest:new()
    httpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    httpRequest.timeout = 100000 -- 10 s
    httpRequest:open("POST", url)
    if header then
        for k, v in pairs(header) do
            httpRequest:setRequestHeader(k, v)
        end
    end

    if callback then
        local function HttpResponseCB()
            local code = httpRequest.status
            local success = code >= 200 and code < 300
            local response = httpRequest.response

            releasePrint("Http Request Code:" .. tostring(code))
            -- print("!!!Http Request readyState: ".. httpRequest.readyState)
            callback(success, response, code)
        end
        -- httpRequest:setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        httpRequest:registerScriptHandler(HttpResponseCB)
    end

    httpRequest:send(data)
end

function TextReviewProxy:getHeader()
    local header = {}
    header["Content-Type"] = "application/json"
    return header
end

function TextReviewProxy:calcDataParam(originData)
    local paramData = {}
    for i, v in ipairs(originData) do
        paramData[v.key] = v.value
    end

    local suffix = cjson.encode(paramData)
    return suffix
end

return TextReviewProxy