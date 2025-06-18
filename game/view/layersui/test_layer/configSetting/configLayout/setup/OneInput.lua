-- 单个输入，前后缀不同
OneInput = {}

local SID = SLDefine.SETTINGID
local cfgUI = {
    [SID.SETTING_IDX_BGMUSIC]               = {mod = 2, min = 0, max = 100, prefix = "默认音量", suffix = "%"},                 -- 背景音乐
    [SID.SETTING_IDX_EFFECTMUSIC]           = {mod = 2, min = 0, max = 100, prefix = "默认音量", suffix = "%"},                 -- 游戏音乐
    [SID.SETTING_IDX_ROCKER_SHOW_DISTANCE]  = {mod = 6,                     prefix = "默认边距", suffix = "支持一位小数点配置"},  -- 轮盘侧边距
    [SID.SETTING_IDX_SKILL_SHOW_DISTANCE]   = {mod = 6,                     prefix = "默认边距", suffix = "支持一位小数点配置"},  -- 技能侧边距
    [SID.SETTING_IDX_CAMERA_ZOOM]           = {mod = 6,                     prefix = "默认视距", suffix = "支持一位小数点配置"},  -- 地图缩放
}

function OneInput.main(parent, data)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "setup/one_input")

    OneInput._ui = GUI:ui_delegate(parent)

    OneInput._value = data.default

    local cfg = cfgUI[data.id]
    if not cfg then
        return
    end

    -- 前缀
    GUI:Text_setString(OneInput._ui["prefix"], cfg.prefix)

    -- 后缀
    GUI:Text_setString(OneInput._ui["suffix"], cfg.suffix)
    
    -- 输入框
    OneInput._inputName = ""
    local input = OneInput._ui["input"]
    OneInput.input = input
    GUI:TextInput_setInputMode(input, cfg.mod)
    GUI:TextInput_addOnEvent(input, function(sender, eventType)
        if eventType == 1 then
            local str = sender:getString()                
            if cfg.mod == 2 then
                local max  = cfg.max
                local min  = cfg.min
                str = string.trim(str)
                str = tonumber(str) or 0
                if min and str < min then
                    str = min
                end
                if max then
                    str = math.max(math.min(str, max), 0)
                end
                sender:setString(str)
                OneInput._value = str
            else
                str = string.trim(str)
                str = tonumber(str) or ""
                if string.len(str or "") <= 0 then
                    sender:setString(OneInput._value or "")
                    return false
                end
                sender:setString(str)
                OneInput._value = str
            end
        end
    end)
    input:setString(OneInput._value)
end

-- 外部调用，返回当前界面处理数据结果
function OneInput.getValue()
    local ret = {}
    if OneInput._value and tonumber(OneInput._value) then
        ret.default = tonumber(OneInput._value)
    end
    
    return ret
end

return OneInput