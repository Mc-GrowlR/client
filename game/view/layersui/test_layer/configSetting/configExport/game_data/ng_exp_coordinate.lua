local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create Button_sure
	local Button_sure = GUI:Button_Create(panel_bg, "Button_sure", 264.00, 24.00, "res/private/gui_edit/Button_Normal.png")
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
	local Layout_pc = GUI:Layout_Create(panel_bg, "Layout_pc", 0.00, 300.00, 300.00, 45.00, false)
	GUI:setTouchEnabled(Layout_pc, false)
	GUI:setTag(Layout_pc, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_pc, "Text", 10.00, 13.00, 14, "#ffffff", [[电脑端：]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout_pc, "input_bg", 110.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[X坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_pc_x
	local input_pc_x = GUI:TextInput_Create(input_bg, "input_pc_x", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_x, "")
	GUI:TextInput_setFontColor(input_pc_x, "#ffffff")
	GUI:setTouchEnabled(input_pc_x, true)
	GUI:setTag(input_pc_x, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout_pc, "input_bg_1", 230.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create input_pc_y
	local input_pc_y = GUI:TextInput_Create(input_bg_1, "input_pc_y", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_y, "")
	GUI:TextInput_setFontColor(input_pc_y, "#ffffff")
	GUI:setTouchEnabled(input_pc_y, true)
	GUI:setTag(input_pc_y, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg_1, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[Y坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create Layout_mobile
	local Layout_mobile = GUI:Layout_Create(panel_bg, "Layout_mobile", 0.00, 250.00, 300.00, 45.00, false)
	GUI:setTouchEnabled(Layout_mobile, false)
	GUI:setTag(Layout_mobile, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_mobile, "Text", 10.00, 13.00, 14, "#ffffff", [[手机端：]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout_mobile, "input_bg", 110.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[X坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_mobile_x
	local input_mobile_x = GUI:TextInput_Create(input_bg, "input_mobile_x", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input_mobile_x, "")
	GUI:TextInput_setFontColor(input_mobile_x, "#ffffff")
	GUI:setTouchEnabled(input_mobile_x, true)
	GUI:setTag(input_mobile_x, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout_mobile, "input_bg_1", 230.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create input_mobile_y
	local input_mobile_y = GUI:TextInput_Create(input_bg_1, "input_mobile_y", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input_mobile_y, "")
	GUI:TextInput_setFontColor(input_mobile_y, "#ffffff")
	GUI:setTouchEnabled(input_mobile_y, true)
	GUI:setTag(input_mobile_y, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg_1, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[Y坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create Text
	local Text = GUI:Text_Create(panel_bg, "Text", 13.00, 200.00, 14, "#ffffff", [[字体色]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_color_f
	local Layout_color_f = GUI:Layout_Create(panel_bg, "Layout_color_f", 60.00, 210.00, 30.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(Layout_color_f, 1)
	GUI:Layout_setBackGroundColor(Layout_color_f, "#ff0000")
	GUI:Layout_setBackGroundColorOpacity(Layout_color_f, 255)
	GUI:setAnchorPoint(Layout_color_f, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_color_f, false)
	GUI:setTag(Layout_color_f, -1)

	-- Create input_bg_color_f
	local input_bg_color_f = GUI:Image_Create(panel_bg, "input_bg_color_f", 95.00, 210.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_color_f, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_color_f, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_color_f, false)
	GUI:setAnchorPoint(input_bg_color_f, 0.00, 0.50)
	GUI:setTouchEnabled(input_bg_color_f, false)
	GUI:setTag(input_bg_color_f, -1)

	-- Create input_color_f
	local input_color_f = GUI:TextInput_Create(input_bg_color_f, "input_color_f", 0.00, 0.00, 45.00, 25.00, 14)
	GUI:TextInput_setString(input_color_f, "")
	GUI:TextInput_setFontColor(input_color_f, "#ffffff")
	GUI:TextInput_setMaxLength(input_color_f, 3)
	GUI:setTouchEnabled(input_color_f, true)
	GUI:setTag(input_color_f, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(panel_bg, "Text_1", 158.00, 200.00, 14, "#ffffff", [[描边色]])
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Layout_color_b
	local Layout_color_b = GUI:Layout_Create(panel_bg, "Layout_color_b", 205.00, 210.00, 30.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(Layout_color_b, 1)
	GUI:Layout_setBackGroundColor(Layout_color_b, "#ff0000")
	GUI:Layout_setBackGroundColorOpacity(Layout_color_b, 255)
	GUI:setAnchorPoint(Layout_color_b, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_color_b, false)
	GUI:setTag(Layout_color_b, -1)

	-- Create input_bg_color_b
	local input_bg_color_b = GUI:Image_Create(panel_bg, "input_bg_color_b", 240.00, 210.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_color_b, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_color_b, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_color_b, false)
	GUI:setAnchorPoint(input_bg_color_b, 0.00, 0.50)
	GUI:setTouchEnabled(input_bg_color_b, false)
	GUI:setTag(input_bg_color_b, -1)

	-- Create input_color_b
	local input_color_b = GUI:TextInput_Create(input_bg_color_b, "input_color_b", 0.00, 0.00, 45.00, 25.00, 14)
	GUI:TextInput_setString(input_color_b, "")
	GUI:TextInput_setFontColor(input_color_b, "#ffffff")
	GUI:TextInput_setMaxLength(input_color_b, 3)
	GUI:setTouchEnabled(input_color_b, true)
	GUI:setTag(input_color_b, -1)

	-- Create Layout_exp
	local Layout_exp = GUI:Layout_Create(panel_bg, "Layout_exp", 0.00, 150.00, 300.00, 45.00, false)
	GUI:setTouchEnabled(Layout_exp, false)
	GUI:setTag(Layout_exp, -1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout_exp, "input_bg", 128.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 110, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[最低经验显示点数]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_exp
	local input_exp = GUI:TextInput_Create(input_bg, "input_exp", 0.00, 0.00, 110.00, 25.00, 16)
	GUI:TextInput_setString(input_exp, "")
	GUI:TextInput_setFontColor(input_exp, "#ffffff")
	GUI:setTouchEnabled(input_exp, true)
	GUI:setTag(input_exp, -1)
end
return ui