local SUIHelper = {}

local SUIDefine = requireSUI("SUIDefine")
local ssplit = string.split

function SUIHelper:getInputTable(fliter)
    local submitTable = {}

    if fliter == nil or fliter == "" or fliter == "0" then
    elseif fliter == "*" then
        for k, v in pairs(self._inputWidgets) do
            local input      = v
            local inputID    = k
            local inputValue = input.widget and input.widget:getString() or ""
            table.insert(submitTable, {id = inputID, value = inputValue, type = input.inputFlag})
        end
    else
        local slices = ssplit(fliter, ",")
        for i, v in ipairs(slices) do
            local inputID    = v
            local input      = self._inputWidgets[inputID]
            local inputValue = input.widget and input.widget:getString() or ""
            table.insert(submitTable, {id = inputID, value = inputValue, type = input.inputFlag})
        end
    end
    return submitTable
end

function SUIHelper:getCheckBoxTable(fliter)
    local submitTable = {}

    if fliter == nil or fliter == "" or fliter == "0" then
        submitTable  = {}
    else
        for k, v in pairs(self._checkboxWidgets) do
            local widget     = v
            local widgetID   = k
            local value      = (widget:isSelected() and 1 or 0)
            table.insert(submitTable, {id = widgetID, value = value})
        end
    end
    return submitTable
end

function SUIHelper:getCheckBoxTableByID(widgetID)
    local submitTable = {}

    local widget = self._checkboxWidgets[widgetID]
    if not widget then
        submitTable = {}
    else
        local value = (widget:isSelected() and 1 or 0)
        table.insert(submitTable, {id = widgetID, value = value})
    end
    return submitTable
end

function SUIHelper:getITEMBOXTable(fliter)
    local submitTable = {}

    if fliter == nil or fliter == "" or fliter == "0" then
        submitTable  = {}
    else
        for k, v in pairs(self._checkboxWidgets) do
            local widget     = v
            local widgetID   = k
            local value      = (widget:isSelected() and 1 or 0)
            table.insert(submitTable, {id = widgetID, value = value})
        end
    end
    return submitTable
end

-- 转换成世界坐标系
SUIHelper.convertToWorldPos = function(sender, input_pos)
    local parent        = sender:getParent()
    local visibleSize   = global.Director:getVisibleSize()
    local parentSize    = parent and parent:getContentSize() or visibleSize

    local x             = tonumber(input_pos.x) or 0
    local y             = tonumber(input_pos.y) or 0
    local fixX          = x
    local fixY          = parentSize.height - y
    
    return cc.p(fixX, fixY)
end

-- 文本换行显示
SUIHelper.fixText = function(text)
    -- trim && convert some special char
    text = string.gsub(text, "\\", "\r\n")
    text = string.trim(text)
    return text
end

-- 根据 colorID 设置文本颜色
SUIHelper.convertToColorText = function(text, colorID)
    return string.format("<color=%s>%s</color>", GET_COLOR_BYID(colorID), text)
end

SUIHelper.modifySizeAble = function(type)
    return (type == "Text" or type == "TextAtlas" or type == "RichText") and false or true
end

-- 窗口是否可用
SUIHelper.modifyWndEnable = function(attr)
    return attr.enable or true
end

-- 设置位置
SUIHelper.setPosition = function(object, attr)
    object:setPosition(cc.p(tonumber(attr.x) or SUIDefine.defaultCUIUnitPosX, tonumber(attr.y) or SUIDefine.defaultCUIUnitPosY))
end

-- 设置大小
SUIHelper.setSize = function(object, attr)
    local width  = tonumber(attr.w) or 0
    local height = tonumber(attr.h) or 0
    if width > 0 and height > 0 then
        object:setContentSize({width = width, height = height})
    end
end

-- 设置描点
SUIHelper.setAnchor = function(object, attr)
    object:setAnchorPoint(cc.p(tonumber(attr.ax) or SUIDefine.anchorPoints[2].x, tonumber(attr.ay) or SUIDefine.anchorPoints[2].y))
end

-- 旋转角度
SUIHelper.setRotate = function(object, attr)
    if attr.rotate then
        local rotate = tonumber(attr.rotate) or 0
        object:setRotation(rotate)
    end
end

SUIHelper.GetStatus = function(status, default_status)
    local _status = status or default_status
    if type(_status) == "string" then
        local states = {
            ["true"] = true, ["false"] = false
        }
        _status = states[_status]
    end
    return _status
end
-- 是否Esc关闭
SUIHelper.IsEscClose = function(esc_close)
    return SUIHelper.GetStatus(esc_close, true)
end
-- 设置窗口可见
SUIHelper.IsVisible = function(visible)
    return SUIHelper.GetStatus(visible, true)
end
-- 是否是弹窗
SUIHelper.IsWidghtPop = function (type)
    local _Pops = {
        ["dialog"] = 1
    }
    return false--_Pops[type] and true or false
end
-- 是否可拖动
SUIHelper.IsDrag = function (tpye, drag)
    return SUIHelper.GetStatus(drag, SUIHelper.IsWidghtPop(tpye))
end
-- 是否可触摸（wnd、Button、ListView、CheckBox默认为true，其它窗口默认为false）
SUIHelper.IsRevmsg = function (tpye, revmsg)
    local default = (tpye == "ScrollView" or tpye == "Button" or tpye == "ListView" or tpye == "CheckBox") and true or false
    return SUIHelper.GetStatus(revmsg, default)
end

-- 获取字体大小
SUIHelper.getCFontSize = function (size)
    return tonumber(size) or SUIDefine.defaultFontSize
end

-- 获取颜色
SUIHelper.getCColor = function (color, NDefault)
    if NDefault and not color then
        return nil
    end 
    
    if tonumber(color) then 
        return GET_COLOR_BYID_C3B(tonumber(color))
    end

    local slices = ssplit(color, ",")

    if #slices > 2 then
        return cc.c3b(tonumber(slices[1]), tonumber(slices[2]), tonumber(slices[3]))
    end

    if #slices > 0 then
        return GetColorFromHexString(slices[1])
    end

    return GET_COLOR_BYID_C3B(SUIDefine.defaultColorID)
end

-- 加载通用属性
SUIHelper.loadCUIBaseAttr = function(unit)
    local render = unit._render
    if not render then
        return
    end

    local attr = unit:GetAttr()
    local type = unit:GetType()

    -- size
    if SUIHelper.modifySizeAble(type) then
        SUIHelper.setSize(render, attr)
    end
    -- anr
    SUIHelper.setAnchor(render, attr)
    -- rotate
    SUIHelper.setRotate(render, attr)
    -- x y
    SUIHelper.setPosition(render, attr)
    -- visible 
    if SUIHelper.modifyWndEnable(attr) then
        render:setVisible(SUIHelper.IsVisible(attr.visible))
    end
end

-- 设置窗体是否可触摸（Image、Text、RichText默认为false，其它窗口默认为true）
SUIHelper.setWndTouched = function(unit)
    local render = unit._render
    if render then
        local type   = unit:GetType()
        local isTouch = (type == "Image" or type == "Text" or type == "RichText") and false or true
        render:setTouchEnabled(isTouch)
    end
end

-- 获取资源路径
SUIHelper.getResFile = function(renderer)
    if not renderer then
        return "", 0
    end

    local sprite = renderer:getSprite()
    if not sprite then
        return "", 0
    end

    return sprite:getResourceName(), sprite:getResourceType()
end

---------------------------Event-----------------------

SUIHelper.addMouseOverTips = function(sender, attr)
    local tips  = attr.tips
    local tipsx = tonumber(attr.tipsx) or 0
    local tipsy = tonumber(attr.tipsy) or 0

    if tips and string.len(tips) > 0 then
        -- 监听事件;
        tips = string.gsub(tips, "%^", "\\")
        sender:addMouseOverTips(tips, cc.p(tipsx, -tipsy), cc.p(0.5, 1))
    end
end

return SUIHelper