local RemoteProxy = requireProxy( "remote/RemoteProxy" )
local ItemTipsProxy   = class( "ItemTipsProxy", RemoteProxy )
ItemTipsProxy.NAME = global.ProxyTable.ItemTipsProxy

--调用场景
ItemTipsProxy.posType =
{
    from_guild_storage_bagLayer     = 1,   --行会仓库中的背包
    from_guild_storageLayer         = 2,   --行会仓库中的仓库
}

function ItemTipsProxy:ctor()
    self.tipsHeight = 0         --tips的高度 显示批量使用界面的时候要用

    self._data = {}				--用来保存tips中道具的信息
    self._suitConfig = {}
    self._newSuitConfig = {}    --新的套装属性表数据
    self._suitNameConfig = {}
    self._customAttConfig = {}  --自定义属性表
    self._btn_show_switch = nil --tips 佩戴/分解/不显示使用按钮的道具类型

    self._extraWidget = {}
    ItemTipsProxy.super.ctor(self)
end

function ItemTipsProxy:onRegister()
    ItemTipsProxy.super.onRegister( self )
end

function ItemTipsProxy:ClearItemTipsData()
    self._data = {}
    self.tipsHeight = 0
end

function ItemTipsProxy:GetItemTipsData()
    return self._data
end

function ItemTipsProxy:AddItemTipsData(data)
    if data.itemData then
        self._data[data.itemData.MakeIndex] = data.itemData
    end
end

function ItemTipsProxy:GetItemTipsDataById(id)
    if id == nil or id == 0 then
        return nil
    end
    return self._data[id]
end

function ItemTipsProxy:setItemData( itemData )
    if itemData and itemData.MakeIndex then
        self._data[itemData.MakeIndex] = itemData
    end
end


function ItemTipsProxy:getRoleInfo( )
    local _proxyPlayer = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )

    local data = {}
    local level = _proxyPlayer:GetRoleLevel()
    local job = _proxyPlayer:GetRoleJob()
    local roleType = 1

    data.job = job or 0
    data.level = level or 0
    data.roleType = roleType
    return data
end

function ItemTipsProxy:setTipsHeight( height )
    self.tipsHeight = height
end

function ItemTipsProxy:getTipsHeight( )
    return self.tipsHeight
end

function ItemTipsProxy:onRegister()
    ItemTipsProxy.super.onRegister( self )
end

function ItemTipsProxy:getSuitConfigById(id)
    return self._suitConfig[id]
end

function ItemTipsProxy:getSuitConfigByName(name)
    return self._suitNameConfig[name]
end

function ItemTipsProxy:getCustomDesc(id)
    if not self._customAttConfig then return nil end
    local config = self._customAttConfig[id]
    if config and config.value then
        return config.value
    end
    return nil
end

function ItemTipsProxy:getCustomIcon(id)
    if not self._customAttConfig then return nil end
    local config = self._customAttConfig[id]
    if config and config.icon and config.icon ~= "" then
        local tubiaoArray = string.split(config.icon or "", "=")
        local key = tubiaoArray[1] and tonumber(tubiaoArray[1]) or nil
        if key and tubiaoArray[2] and tubiaoArray[2] ~= "" then
            local resArray = string.split(tubiaoArray[2] or "", "#")
            local iconStr = global.isWinPlayMode and resArray[1] or resArray[2]
            local iconArray = string.split(iconStr or "", "&")
            return {
                [key] = {res = iconArray[1] or "", x = iconArray[2] and tonumber(iconArray[2]) or 0, y = iconArray[3] and tonumber(iconArray[3]) or 0}
            }
        end
    end
    return nil
end

function ItemTipsProxy:getSpecialDesc(id)
    if not self._specialAttConfig then return nil end
    local config = self._specialAttConfig[id]
    if config then
        return config.caption 
    end
    return nil
end

function ItemTipsProxy:LoadConfig()
    local GameConfigMgrProxy = global.Facade:retrieveProxy(global.ProxyTable.GameConfigMgrProxy)
    local config = GameConfigMgrProxy:getConfigByKey("cfg_suit") or {}
    self._suitConfig = config
    self._suitNameConfig = {}

    for _, v in pairs(config) do
        while true do
            if not v.notes or string.len(v.notes) == 0 then
                break
            end
            local sliceStr = string.split(v.notes, "|")
            local suitList = {}
            if sliceStr[2] == "*" then
                --带*的表示 每个装备单独显示套装属性
                local title = sliceStr[1]
                local equipNames = {}
                local suitAtts = {}
                local names = ""

                for i = 3, #sliceStr do
                    local sliceStr2 = string.split(sliceStr[i], ":")
                    if sliceStr2[1] and sliceStr2[2] then
                        names = names .. sliceStr2[1] .. "|"

                        local sliceNameStr = string.split(sliceStr2[1], "/")
                        local name = #sliceNameStr >= 2 and sliceNameStr[2] or sliceNameStr[1]
                        table.insert(equipNames, name)
                        table.insert(suitAtts, sliceStr2[2])
                    end
                end

                names = string.sub(names, 1, string.len(names) - 1)

                for i, s in pairs(suitAtts) do
                    table.insert(suitList, {name = equipNames[i], notes = sliceStr[1] .. "|" .. #suitAtts .. "|" .. names .. ":" .. s})
                end
            else
                suitList = {{notes = v.notes}}
            end

            for _, data in pairs(suitList) do
                local notes = data.notes
                local first = notes and string.find(notes, ":")
                if first then
                    local oneConfig = {}
                    oneConfig.Idx = v.Idx
                    oneConfig.equipNameStr = string.sub(notes, 1, first - 1)
                    oneConfig.equipAttStr = string.sub(notes, first + 1, -1)
                    local sliceStr = string.split(oneConfig.equipNameStr, "|")

                    local sameName = {}
                    local name = data.name
                    if name then
                        sameName[name] = true
                    else
                        for i = 3, #sliceStr do
                            local sliceNameStr = string.split(sliceStr[i], "/")
                            local name = #sliceNameStr >= 2 and sliceNameStr[2] or sliceNameStr[1]
                            --相同装备只取一个
                            sameName[name] = true
                        end
                    end
                    
                    for name, _ in pairs(sameName) do
                        self._suitNameConfig[name] = self._suitNameConfig[name] or {}
                        table.insert(self._suitNameConfig[name], oneConfig)
                    end
                end
            end
            break
        end
    end

    self._customAttConfig = {}
    local captionCfg = {}
    local captionCfg = GameConfigMgrProxy:getConfigByKey("cfg_custpro_caption") or {}

    local captionFile = global.isIOS and "cfg_custpro_caption.luac" or "cfg_custpro_caption.lua"
    if global.isIOS and not global.FileUtilCtl:isFileExist("scripts/game_config/" .. captionFile) then --ios的文件gm不是luac
        captionFile = "cfg_custpro_caption.lua"
    end
    if global.FileUtilCtl:isFileExist("scripts/game_config/" .. captionFile) then
        captionCfg = {}
        captionCfg = requireGameConfig(captionFile)
    end 

    for _, v in pairs(captionCfg) do
        self._customAttConfig[v.id] = v
    end

    local fileName = global.isIOS and "cfg_suitex.luac" or "cfg_suitex.lua"
    if global.isIOS and not global.FileUtilCtl:isFileExist("scripts/game_config/" .. fileName) then --ios的文件gm不是luac
        fileName = "cfg_suitex.lua"
    end

    if global.FileUtilCtl:isFileExist("scripts/game_config/" .. fileName) then
        local newConfig = requireGameConfig(fileName)
        for _, v in ipairs(newConfig) do
            self._newSuitConfig[v.suitid] = self._newSuitConfig[v.suitid] or {}
            table.insert(self._newSuitConfig[v.suitid], v)
        end
    end
end

-- 获取新的套装属性表数据
function ItemTipsProxy:GetNewSuitConfigById( suitid )
    return self._newSuitConfig[suitid] or {}
end

-- 自定义属性映射att表属性ID
--[[    cusid  自定义id
        mappingid 映射id
        type 类型(0=数值 1=百分比 2=万分比)
--]]
function ItemTipsProxy:LoadCustAbilConfig()
    local GameConfigMgrProxy = global.Facade:retrieveProxy(global.ProxyTable.GameConfigMgrProxy)
    local config = GameConfigMgrProxy:getConfigByKey("cfg_cusabilmapping") or {}
    
    self._custAbilConfig = config
    self._custAbilMap = {}
    for i = 1, #config do
        if config[i] and next(config[i]) then
            local custId = config[i].cusid 
            if custId then 
                self._custAbilMap[custId] = {id = config[i].mappingid, type = config[i].type, showCustomName = config[i].showcustname == 1}
            end
        end
    end
end


function ItemTipsProxy:GetCustAbilMap()
    return self._custAbilMap or {}
end

--------------------------------------------------
function ItemTipsProxy:GetExtraWidgets( ... )
    return self._extraWidget
end

function ItemTipsProxy:AddExtraWidgetByIndex( widget , Index)
    local widget = widget:cloneEx() 
    widget:retain()
 
    if not self._extraWidget then
        self._extraWidget = {}
    end
    if not self._extraWidget[Index] then
        self._extraWidget[Index] = {}
    end
    table.insert( self._extraWidget[Index], widget )
end

function ItemTipsProxy:Cleanup()
    for i, extraData in pairs(self._extraWidget) do
        for _, widget in pairs(extraData) do
            if not tolua.isnull(widget) then
                widget:release()
            end
        end
    end
    self._extraWidget = {}
end

return ItemTipsProxy
