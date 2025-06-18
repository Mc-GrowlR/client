local BaseLayer = requireLayerUI("BaseLayer")
local LoginRoleLockLayer = class("LoginRoleLockLayer", BaseLayer)

local cjson = require("cjson")

function LoginRoleLockLayer:ctor()
    LoginRoleLockLayer.super.ctor(self)
end

function LoginRoleLockLayer.create(...)
    local node = LoginRoleLockLayer.new()
    if node:Init(...) then
        return node
    end
    return nil
end

function LoginRoleLockLayer:Init(data)
    
    self:LoadRoleData()
    
    return true
end

function LoginRoleLockLayer:LoadRoleData()
    local loadFunc = function ()
        local size = global.Director:getWinSize()
        local maxY = size.height * 0.8
        local loginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        local roleData = loginProxy:GetRoles()
        local widget, height
        for i, v in ipairs(roleData) do
            widget, height = self:CreateShowWidget(v, i)
            widget:setPosition(size.width / 2, maxY)
            maxY = maxY - height
            self:addChild(widget)
        end
    end
    if global.OtherTradingBank then
        local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
        OtherTradingBankProxy:getTradingBankStatus({}, function(code, data, msg)--先判断是不是H5
            if code == 200 then 
                loadFunc()
            else 
                ShowSystemTips(msg or " ")
            end
        end, true, self)
    else
        loadFunc()
    end
end

function LoginRoleLockLayer:OnUpdateRoles()
    self:removeAllChildren()
    self:LoadRoleData()
end

function LoginRoleLockLayer:CreateShowWidget(RoleData, index)
    dump(index,"index___")
    local height = 0
    local Image_2 = ccui.ImageView:create()
    if RoleData.LockChar and ( RoleData.LockChar == 1 or  RoleData.LockChar == 3 ) then
            dump("锁定")
            Image_2:loadTexture(global.MMO.PATH_RES_PUBLIC.."1900000651_2.png")
            Image_2:setScale9Enabled(true)
            Image_2:setCapInsets({x = 21, y = 21, width = 22, height = 22})
            Image_2:setAnchorPoint(0.5, 1)
            local Text_1 = ccui.Text:create()
            Text_1:setAnchorPoint(0, 0)
            Text_1:setFontName(global.MMO.PATH_FONT)
            local descID = global.OtherTradingBankH5 and 600000850 or 600000163
            
            local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
            if OtherTradingBankProxy:getPublishOpen() == 1 then
                Text_1:setString("")
            else
                Text_1:setString(string.format("%s%s", GET_STRING(600000799 + index), GET_STRING(descID)) )
            end
            SET_COLOR_STYLE( Text_1, 222 )
            Text_1:setFontSize(16)
            local size = Text_1:getContentSize()
            Image_2:setContentSize(size.width + 4, size.height + 4)
            Text_1:setPosition(2,2)
            Text_1:addTo(Image_2)
            if global.OtherTradingBankH5 then
                OtherTradingBankProxy:showBackToView()
                height = size.height + 4 + 10
            else
                local btn =  ccui.Button:create()
                btn:setTitleFontSize(18)
                btn:ignoreContentAdaptWithSize(false)
                btn:loadTextureNormal(global.MMO.PATH_RES_PUBLIC.."1900000662.png")
                btn:addTo(Image_2)
                if OtherTradingBankProxy:getPublishOpen() == 1 then
                    btn:setTitleText(GET_STRING(700000140))
                else
                    btn:setTitleText(GET_STRING(600000013))
                end
                btn:setPosition((size.width + 4) / 2, -20)
                btn:addTouchEventListener(function (sender,type)--取回角色
                    if type ~= 2 then
                        return 
                    end
                    if RoleData and RoleData.LockChar and RoleData.LockChar == 3 then
                        local data = {}
                        data.type = 1
                        data.btntext = "确定"
                        data.text =  GET_STRING(600000065)--买家已付款,等待买家确认收货,当前状态无法取回角色。
                        data.callback = function(res)
                            
                        end
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open,data)
                        return
                    end
                    -- 
                    self:getSellCDTime(RoleData)
                end)

                height = size.height + 4 + 57
            end
        
    elseif RoleData.newChar and RoleData.newChar == 1 then
        dump("新角色")
        Image_2:loadTexture(global.MMO.PATH_RES_PUBLIC.."1900000651_2.png")
        Image_2:setScale9Enabled(true)
        Image_2:setCapInsets({x = 21, y = 21, width = 22, height = 22})
        Image_2:setAnchorPoint(0.5, 1)
        local Text_1 = ccui.Text:create()
        Text_1:setAnchorPoint(0, 0)
        Text_1:setFontName(global.MMO.PATH_FONT)
        Text_1:setString(string.format("%s%s", GET_STRING(600000799 + index), GET_STRING(600000802)))
        SET_COLOR_STYLE( Text_1, 222 )
        Text_1:setFontSize(16)
        local size = Text_1:getContentSize()
        Image_2:setContentSize(size.width + 4, size.height + 4)
        Text_1:setPosition(2,2)
        Text_1:addTo(Image_2)
        height = size.height + 4 + 10
    end

    return Image_2, height
end

function LoginRoleLockLayer:getSellCDTime(val)
    --vivo的角色解冻
    local otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    if otherTradingBankProxy:getPublishOpen() == 1 then
        otherTradingBankProxy:unLockPublishRole(self, val, function(code, data, msg)
            if code == 200 then
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification(global.NoticeTable.RestartGame)
            else
                ShowSystemTips(msg)
            end
        end)

        return
    end

    if global.OtherTradingBank then
        otherTradingBankProxy:reqGetSellCDTime(self, {role_id = val.roleid}, function(code, data, msg)
            if code == 200 then
                local time = data
                local data = {}
                data.type = 1
                data.btntext = GET_STRING(600000013)--取回角色
                data.text = string.format(GET_STRING(600000050), time)--取回角色后%s分钟内无法重新寄售
                data.callback = function(res)
                    if res == 1 then
                        if otherTradingBankProxy:getToken() ~= "" then 
                            self:getRole_other(val)
                        else
                            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other,
                            {
                                callback = function(code)
                                    if code == 1 then
                                        self:getRole_other(val)
                                    end
                                end,
                                checkPhone = true
                            })
                        end
                    end
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, data)
            elseif code >= 50000 and code <= 50020 then --token失效
                ShowSystemTips(msg or "")
                global.Facade:sendNotification(
                    global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other,
                    {
                        callback = function(code)
                            if code == 1 then
                                self:getSellCDTime(val)
                            end
                        end
                    }
                )
            else
                ShowSystemTips(msg or "")
            end
        end)
    else
        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:reqGetSellCDTime(self,{},function (success,response,code)
            if success then
                local data = cjson.decode(response)
                if data.code == 200 then
                    local time = data.data
                    local data = {}
                    data.type = 1
                    data.btntext = GET_STRING(600000013)
                    data.text =  string.format(GET_STRING(600000050), time)
                    data.callback = function(res)
                        if res == 1 then 
                            self:getRole(val)
                        end
                    end
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open,data)

                else
                    global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
                end
            end
        end)
    end
end

function LoginRoleLockLayer:getRole_other(val)
    local data = {
        role_id = val.roleid
    }
    
    local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    OtherTradingBankProxy:takeBackRole(self, data, function(code, data, msg)
        if code == 200 then --取回成功
            global.L_NativeBridgeManager:GN_accountLogout()
            global.Facade:sendNotification(global.NoticeTable.RestartGame)
        elseif (code >= 50000 and code <= 50020) or code == 20036 then --token失效  20036 手机号不对
            ShowSystemTips(msg or "")
            global.Facade:sendNotification(
                global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other,
                {
                    callback = function(code)
                        if code == 1 then
                            self:getRole_other(val)
                        end
                    end,
                    checkPhone = true
                }
            )
        else
            ShowSystemTips(msg or "")
        end
    end)
end

function LoginRoleLockLayer:getRole(val)
    local data = { 
        role_id = val.roleid,
    }
    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    TradingBankProxy:takeBackRole(self,data,function (success, response, code )
        if success then
            local data = cjson.decode(response)
            dump({success,response, code},"takeBackRole____")
            if data.code == 200 then--取回成功
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            elseif data.code>=50000 and data.code<=50020 then--token失效
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open,{
                    callback = function (code)
                        if code == 1 then
                            self:getRole(val)
                        end
                    end
                })
            else
                ShowSystemTips(data.msg or "")
            end
        end
    end)
end
return LoginRoleLockLayer
