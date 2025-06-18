local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create input_bg1
	local input_bg1 = GUI:Image_Create(panel_bg, "input_bg1", 70.00, 310.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg1, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg1, false)
	GUI:setTouchEnabled(input_bg1, false)
	GUI:setTag(input_bg1, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg1, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[系统频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg1, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input1
	local input1 = GUI:TextInput_Create(input_bg1, "input1", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input1, "")
	GUI:TextInput_setFontColor(input1, "#ffffff")
	GUI:setTouchEnabled(input1, true)
	GUI:setTag(input1, -1)

	-- Create input_bg2
	local input_bg2 = GUI:Image_Create(panel_bg, "input_bg2", 220.00, 310.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg2, 74, 72, 16, 10)
	GUI:setContentSize(input_bg2, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg2, false)
	GUI:setTouchEnabled(input_bg2, false)
	GUI:setTag(input_bg2, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg2, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[喊话频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg2, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input2
	local input2 = GUI:TextInput_Create(input_bg2, "input2", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input2, "")
	GUI:TextInput_setFontColor(input2, "#ffffff")
	GUI:setTouchEnabled(input2, true)
	GUI:setTag(input2, -1)

	-- Create input_bg3
	local input_bg3 = GUI:Image_Create(panel_bg, "input_bg3", 70.00, 275.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg3, 74, 72, 16, 10)
	GUI:setContentSize(input_bg3, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg3, false)
	GUI:setTouchEnabled(input_bg3, false)
	GUI:setTag(input_bg3, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg3, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[私聊频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg3, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input3
	local input3 = GUI:TextInput_Create(input_bg3, "input3", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input3, "")
	GUI:TextInput_setFontColor(input3, "#ffffff")
	GUI:setTouchEnabled(input3, true)
	GUI:setTag(input3, -1)

	-- Create input_bg4
	local input_bg4 = GUI:Image_Create(panel_bg, "input_bg4", 220.00, 275.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg4, 74, 72, 16, 10)
	GUI:setContentSize(input_bg4, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg4, false)
	GUI:setTouchEnabled(input_bg4, false)
	GUI:setTag(input_bg4, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg4, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[行会频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg4, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input4
	local input4 = GUI:TextInput_Create(input_bg4, "input4", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input4, "")
	GUI:TextInput_setFontColor(input4, "#ffffff")
	GUI:setTouchEnabled(input4, true)
	GUI:setTag(input4, -1)

	-- Create input_bg5
	local input_bg5 = GUI:Image_Create(panel_bg, "input_bg5", 70.00, 240.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg5, 74, 72, 16, 10)
	GUI:setContentSize(input_bg5, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg5, false)
	GUI:setTouchEnabled(input_bg5, false)
	GUI:setTag(input_bg5, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg5, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[组队频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg5, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input5
	local input5 = GUI:TextInput_Create(input_bg5, "input5", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input5, "")
	GUI:TextInput_setFontColor(input5, "#ffffff")
	GUI:setTouchEnabled(input5, true)
	GUI:setTag(input5, -1)

	-- Create input_bg6
	local input_bg6 = GUI:Image_Create(panel_bg, "input_bg6", 220.00, 240.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg6, 74, 72, 16, 10)
	GUI:setContentSize(input_bg6, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg6, false)
	GUI:setTouchEnabled(input_bg6, false)
	GUI:setTag(input_bg6, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg6, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[附近频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg6, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input6
	local input6 = GUI:TextInput_Create(input_bg6, "input6", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input6, "")
	GUI:TextInput_setFontColor(input6, "#ffffff")
	GUI:setTouchEnabled(input6, true)
	GUI:setTag(input6, -1)

	-- Create input_bg7
	local input_bg7 = GUI:Image_Create(panel_bg, "input_bg7", 70.00, 205.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg7, 74, 72, 16, 10)
	GUI:setContentSize(input_bg7, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg7, false)
	GUI:setTouchEnabled(input_bg7, false)
	GUI:setTag(input_bg7, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg7, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[世界频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg7, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input7
	local input7 = GUI:TextInput_Create(input_bg7, "input7", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input7, "")
	GUI:TextInput_setFontColor(input7, "#ffffff")
	GUI:setTouchEnabled(input7, true)
	GUI:setTag(input7, -1)

	-- Create input_bg8
	local input_bg8 = GUI:Image_Create(panel_bg, "input_bg8", 220.00, 205.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg8, 74, 72, 16, 10)
	GUI:setContentSize(input_bg8, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg8, false)
	GUI:setTouchEnabled(input_bg8, false)
	GUI:setTag(input_bg8, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg8, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[国家频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg8, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input8
	local input8 = GUI:TextInput_Create(input_bg8, "input8", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input8, "")
	GUI:TextInput_setFontColor(input8, "#ffffff")
	GUI:setTouchEnabled(input8, true)
	GUI:setTag(input8, -1)

	-- Create input_bg9
	local input_bg9 = GUI:Image_Create(panel_bg, "input_bg9", 70.00, 170.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg9, 74, 72, 16, 10)
	GUI:setContentSize(input_bg9, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg9, false)
	GUI:setTouchEnabled(input_bg9, false)
	GUI:setTag(input_bg9, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg9, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[联盟频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg9, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input9
	local input9 = GUI:TextInput_Create(input_bg9, "input9", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input9, "")
	GUI:TextInput_setFontColor(input9, "#ffffff")
	GUI:setTouchEnabled(input9, true)
	GUI:setTag(input9, -1)

	-- Create Button_sure
	local Button_sure = GUI:Button_Create(panel_bg, "Button_sure", 263.00, 24.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_sure, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_sure, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_sure, 16, 14, 13, 11)
	GUI:setContentSize(Button_sure, 60, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_sure, false)
	GUI:Button_setTitleText(Button_sure, "保 存")
	GUI:Button_setTitleColor(Button_sure, "#00ff00")
	GUI:Button_setTitleFontSize(Button_sure, 16)
	GUI:Button_titleEnableOutline(Button_sure, "#000000", 1)
	GUI:setAnchorPoint(Button_sure, 0.50, 0.50)
	GUI:setTouchEnabled(Button_sure, true)
	GUI:setTag(Button_sure, -1)

	-- Create input_bg10
	local input_bg10 = GUI:Image_Create(panel_bg, "input_bg10", 220.00, 170.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg10, 74, 72, 16, 10)
	GUI:setContentSize(input_bg10, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg10, false)
	GUI:setTouchEnabled(input_bg10, false)
	GUI:setTag(input_bg10, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg10, "input_prefix", 5.00, 13.00, 14, "#ffffff", [[跨服频道：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(input_bg10, "input_suffix", 63.00, 13.00, 14, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create input9
	local input10 = GUI:TextInput_Create(input_bg10, "input10", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(input10, "")
	GUI:TextInput_setFontColor(input10, "#ffffff")
	GUI:setTouchEnabled(input10, true)
	GUI:setTag(input10, -1)
end
return ui