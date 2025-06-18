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

	-- Create Layout_input
	local Layout_input = GUI:Layout_Create(panel_bg, "Layout_input", 0.00, 300.00, 300.00, 45.00, false)
	GUI:setTouchEnabled(Layout_input, false)
	GUI:setTag(Layout_input, -1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout_input, "input_bg", 100.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg, "input_prefix", -2.00, 14.00, 14, "#ffffff", [[PC字体类型：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_type
	local input_type = GUI:TextInput_Create(input_bg, "input_type", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input_type, "")
	GUI:TextInput_setFontColor(input_type, "#ffffff")
	GUI:setTouchEnabled(input_type, true)
	GUI:setTag(input_type, -1)

	-- Create input_prefix_1
	local input_prefix_1 = GUI:Text_Create(input_bg, "input_prefix_1", 170.00, 14.00, 14, "#c6c6ce", [[(1:黑体，2:宋体)]])
	GUI:setAnchorPoint(input_prefix_1, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix_1, false)
	GUI:setTag(input_prefix_1, -1)
	GUI:Text_enableOutline(input_prefix_1, "#000000", 1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout_input, "input_bg_1", 100.00, -45.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 0, 0, 0, 0)
	GUI:setContentSize(input_bg_1, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg_1, "input_prefix", -2.00, 14.00, 14, "#ffffff", [[PC字体大小：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_size
	local input_size = GUI:TextInput_Create(input_bg_1, "input_size", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input_size, "")
	GUI:TextInput_setFontColor(input_size, "#ffffff")
	GUI:setTouchEnabled(input_size, true)
	GUI:setTag(input_size, -1)
end
return ui