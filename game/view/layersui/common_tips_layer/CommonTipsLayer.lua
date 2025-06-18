local BaseLayer = requireLayerUI( "BaseLayer" )
local CommonTipsLayer = class( "CommonTipsLayer", BaseLayer )

CommonTipsLayer.Events = 
{
    Confirm = 1,
    Other = 2,
    onReturn = 3,

    Max = 3,
}

--[[
    data.btnType        --按钮类型 btnType=1:"确定" =2:{"确定","取消"} 
    data.str            --文本
    data.btnDesc        --按钮名字{ "拒绝", "同意" }
    callback            --按钮回调 参数1:点击的按钮id 参数2:数据{editStr=输入框字符串}
    showEdit            --是否显示输入框
    editParams          --输入框参数 可以不传{str, inputMode, maxLength}
]]

function CommonTipsLayer:ctor()
    CommonTipsLayer.super.ctor(self)
end

function CommonTipsLayer.create()
    local layer = CommonTipsLayer.new()
    if layer:Init() then
        return layer
    else
        return nil
    end
end

function CommonTipsLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function CommonTipsLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_COMMON_TIPS_POP)
    CommonTipsPop.main(data)

end

function CommonTipsLayer:handlePressedEnter()
    if CommonTipsPop.HandlePressEnter then
        CommonTipsPop.HandlePressEnter()
    end
end

return CommonTipsLayer