local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

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

	-- Create Layout_pc
	local Layout_pc = GUI:Layout_Create(panel_bg, "Layout_pc", 0.00, 300.00, 300.00, 60.00, false)
	GUI:setTouchEnabled(Layout_pc, false)
	GUI:setTag(Layout_pc, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_pc, "Text", 10.00, 50.00, 14, "#ffffff", [[电脑端配置：]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout_pc, "input_bg", 158.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[X偏移]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_pc_x
	local input_pc_x = GUI:TextInput_Create(input_bg, "input_pc_x", 0.00, 0.00, 45.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_x, "")
	GUI:TextInput_setFontColor(input_pc_x, "#ffffff")
	GUI:setTouchEnabled(input_pc_x, true)
	GUI:setTag(input_pc_x, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout_pc, "input_bg_1", 250.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create input_pc_y
	local input_pc_y = GUI:TextInput_Create(input_bg_1, "input_pc_y", 0.00, 0.00, 45.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_y, "")
	GUI:TextInput_setFontColor(input_pc_y, "#ffffff")
	GUI:setTouchEnabled(input_pc_y, true)
	GUI:setTag(input_pc_y, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg_1, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[Y偏移]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create Layout_color_pc
	local Layout_color_pc = GUI:Layout_Create(Layout_pc, "Layout_color_pc", 10.00, 19.00, 30.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(Layout_color_pc, 1)
	GUI:Layout_setBackGroundColor(Layout_color_pc, "#ff0000")
	GUI:Layout_setBackGroundColorOpacity(Layout_color_pc, 255)
	GUI:setAnchorPoint(Layout_color_pc, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_color_pc, false)
	GUI:setTag(Layout_color_pc, -1)

	-- Create input_bg_2
	local input_bg_2 = GUI:Image_Create(Layout_pc, "input_bg_2", 44.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_2, 0, 0, 0, 0)
	GUI:setContentSize(input_bg_2, 66, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_2, false)
	GUI:setTouchEnabled(input_bg_2, false)
	GUI:setTag(input_bg_2, -1)

	-- Create input_pc_color
	local input_pc_color = GUI:TextInput_Create(input_bg_2, "input_pc_color", 0.00, 0.00, 62.00, 25.00, 14)
	GUI:TextInput_setString(input_pc_color, "")
	GUI:TextInput_setPlaceHolder(input_pc_color, "颜色ID")
	GUI:TextInput_setFontColor(input_pc_color, "#ffffff")
	GUI:setTouchEnabled(input_pc_color, true)
	GUI:setTag(input_pc_color, -1)

	-- Create Layout_mobile
	local Layout_mobile = GUI:Layout_Create(panel_bg, "Layout_mobile", 0.00, 220.00, 300.00, 60.00, false)
	GUI:setTouchEnabled(Layout_mobile, false)
	GUI:setTag(Layout_mobile, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_mobile, "Text", 10.00, 50.00, 14, "#ffffff", [[手机端配置：]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout_mobile, "input_bg", 158.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[X偏移]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_mobile_x
	local input_mobile_x = GUI:TextInput_Create(input_bg, "input_mobile_x", 0.00, 0.00, 45.00, 25.00, 16)
	GUI:TextInput_setString(input_mobile_x, "")
	GUI:TextInput_setFontColor(input_mobile_x, "#ffffff")
	GUI:setTouchEnabled(input_mobile_x, true)
	GUI:setTag(input_mobile_x, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout_mobile, "input_bg_1", 250.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create input_mobile_y
	local input_mobile_y = GUI:TextInput_Create(input_bg_1, "input_mobile_y", 0.00, 0.00, 45.00, 25.00, 16)
	GUI:TextInput_setString(input_mobile_y, "")
	GUI:TextInput_setFontColor(input_mobile_y, "#ffffff")
	GUI:setTouchEnabled(input_mobile_y, true)
	GUI:setTag(input_mobile_y, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg_1, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[Y偏移]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create Layout_color_mobile
	local Layout_color_mobile = GUI:Layout_Create(Layout_mobile, "Layout_color_mobile", 10.00, 19.00, 30.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(Layout_color_mobile, 1)
	GUI:Layout_setBackGroundColor(Layout_color_mobile, "#ff0000")
	GUI:Layout_setBackGroundColorOpacity(Layout_color_mobile, 255)
	GUI:setAnchorPoint(Layout_color_mobile, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_color_mobile, false)
	GUI:setTag(Layout_color_mobile, -1)

	-- Create input_bg_2
	local input_bg_2 = GUI:Image_Create(Layout_mobile, "input_bg_2", 44.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_2, 0, 0, 0, 0)
	GUI:setContentSize(input_bg_2, 66, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_2, false)
	GUI:setTouchEnabled(input_bg_2, false)
	GUI:setTag(input_bg_2, -1)

	-- Create input_mobile_color
	local input_mobile_color = GUI:TextInput_Create(input_bg_2, "input_mobile_color", 0.00, 0.00, 62.00, 25.00, 14)
	GUI:TextInput_setString(input_mobile_color, "")
	GUI:TextInput_setPlaceHolder(input_mobile_color, "颜色ID")
	GUI:TextInput_setFontColor(input_mobile_color, "#ffffff")
	GUI:setTouchEnabled(input_mobile_color, true)
	GUI:setTag(input_mobile_color, -1)
end
return ui