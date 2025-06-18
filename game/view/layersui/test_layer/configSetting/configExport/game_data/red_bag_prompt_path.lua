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

	-- Create Image_line
	local Image_line = GUI:Image_Create(panel_bg, "Image_line", 150.00, 200.00, "res/public/1900000667.png")
	GUI:setContentSize(Image_line, 300, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_line, false)
	GUI:setAnchorPoint(Image_line, 0.50, 0.00)
	GUI:setTouchEnabled(Image_line, false)
	GUI:setTag(Image_line, -1)

	-- Create Text_moblie
	local Text_moblie = GUI:Text_Create(panel_bg, "Text_moblie", 180.00, 300.00, 16, "#ffffff", [[移动端]])
	GUI:setTouchEnabled(Text_moblie, false)
	GUI:setTag(Text_moblie, -1)
	GUI:Text_enableOutline(Text_moblie, "#000000", 1)

	-- Create Text_pc
	local Text_pc = GUI:Text_Create(panel_bg, "Text_pc", 180.00, 120.00, 16, "#ffffff", [[PC端]])
	GUI:setTouchEnabled(Text_pc, false)
	GUI:setTag(Text_pc, -1)
	GUI:Text_enableOutline(Text_pc, "#000000", 1)

	-- Create input_pathMoble
	local input_pathMoble = GUI:Image_Create(panel_bg, "input_pathMoble", 70.00, 340.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_pathMoble, 74, 72, 16, 10)
	GUI:setContentSize(input_pathMoble, 220, 26)
	GUI:setIgnoreContentAdaptWithSize(input_pathMoble, false)
	GUI:setTouchEnabled(input_pathMoble, false)
	GUI:setTag(input_pathMoble, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_pathMoble, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[路径：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_m_path
	local input_m_path = GUI:TextInput_Create(input_pathMoble, "input_m_path", 0.00, 0.00, 220.00, 25.00, 16)
	GUI:TextInput_setString(input_m_path, "")
	GUI:TextInput_setFontColor(input_m_path, "#ffffff")
	GUI:setTouchEnabled(input_m_path, true)
	GUI:setTag(input_m_path, -1)

	-- Create input_x
	local input_x = GUI:Image_Create(panel_bg, "input_x", 70.00, 300.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_x, 74, 72, 16, 10)
	GUI:setContentSize(input_x, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(input_x, false)
	GUI:setTouchEnabled(input_x, false)
	GUI:setTag(input_x, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_x, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[X坐标：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_m_x
	local input_m_x = GUI:TextInput_Create(input_x, "input_m_x", 0.00, 0.00, 50.00, 25.00, 16)
	GUI:TextInput_setString(input_m_x, "")
	GUI:TextInput_setFontColor(input_m_x, "#ffffff")
	GUI:setTouchEnabled(input_m_x, true)
	GUI:setTag(input_m_x, -1)

	-- Create input_y
	local input_y = GUI:Image_Create(panel_bg, "input_y", 70.00, 260.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_y, 74, 72, 16, 10)
	GUI:setContentSize(input_y, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(input_y, false)
	GUI:setTouchEnabled(input_y, false)
	GUI:setTag(input_y, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_y, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[Y坐标：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_m_y
	local input_m_y = GUI:TextInput_Create(input_y, "input_m_y", 0.00, 0.00, 50.00, 25.00, 16)
	GUI:TextInput_setString(input_m_y, "")
	GUI:TextInput_setFontColor(input_m_y, "#ffffff")
	GUI:setTouchEnabled(input_m_y, true)
	GUI:setTag(input_m_y, -1)

	-- Create input_scale
	local input_scale = GUI:Image_Create(panel_bg, "input_scale", 70.00, 220.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_scale, 74, 72, 16, 10)
	GUI:setContentSize(input_scale, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(input_scale, false)
	GUI:setTouchEnabled(input_scale, false)
	GUI:setTag(input_scale, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_scale, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[缩放：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_m_scale
	local input_m_scale = GUI:TextInput_Create(input_scale, "input_m_scale", 0.00, 0.00, 50.00, 25.00, 16)
	GUI:TextInput_setString(input_m_scale, "")
	GUI:TextInput_setFontColor(input_m_scale, "#ffffff")
	GUI:setTouchEnabled(input_m_scale, true)
	GUI:setTag(input_m_scale, -1)

	-- Create input_pathPC
	local input_pathPC = GUI:Image_Create(panel_bg, "input_pathPC", 70.00, 160.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_pathPC, 74, 72, 16, 10)
	GUI:setContentSize(input_pathPC, 220, 26)
	GUI:setIgnoreContentAdaptWithSize(input_pathPC, false)
	GUI:setTouchEnabled(input_pathPC, false)
	GUI:setTag(input_pathPC, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_pathPC, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[路径：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_pc_path
	local input_pc_path = GUI:TextInput_Create(input_pathPC, "input_pc_path", 0.00, 0.00, 220.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_path, "")
	GUI:TextInput_setFontColor(input_pc_path, "#ffffff")
	GUI:setTouchEnabled(input_pc_path, true)
	GUI:setTag(input_pc_path, -1)

	-- Create input_x_1
	local input_x_1 = GUI:Image_Create(panel_bg, "input_x_1", 70.00, 120.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_x_1, 74, 72, 16, 10)
	GUI:setContentSize(input_x_1, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(input_x_1, false)
	GUI:setTouchEnabled(input_x_1, false)
	GUI:setTag(input_x_1, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_x_1, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[X坐标：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_pc_x
	local input_pc_x = GUI:TextInput_Create(input_x_1, "input_pc_x", 0.00, 0.00, 50.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_x, "")
	GUI:TextInput_setFontColor(input_pc_x, "#ffffff")
	GUI:setTouchEnabled(input_pc_x, true)
	GUI:setTag(input_pc_x, -1)

	-- Create input_y_1
	local input_y_1 = GUI:Image_Create(panel_bg, "input_y_1", 70.00, 80.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_y_1, 74, 72, 16, 10)
	GUI:setContentSize(input_y_1, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(input_y_1, false)
	GUI:setTouchEnabled(input_y_1, false)
	GUI:setTag(input_y_1, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_y_1, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[Y坐标：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_pc_y
	local input_pc_y = GUI:TextInput_Create(input_y_1, "input_pc_y", 0.00, 0.00, 50.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_y, "")
	GUI:TextInput_setFontColor(input_pc_y, "#ffffff")
	GUI:setTouchEnabled(input_pc_y, true)
	GUI:setTag(input_pc_y, -1)

	-- Create input_scale_1
	local input_scale_1 = GUI:Image_Create(panel_bg, "input_scale_1", 70.00, 40.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_scale_1, 74, 72, 16, 10)
	GUI:setContentSize(input_scale_1, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(input_scale_1, false)
	GUI:setTouchEnabled(input_scale_1, false)
	GUI:setTag(input_scale_1, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_scale_1, "input_prefix", -3.00, 13.00, 14, "#ffffff", [[缩放：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_pc_scale
	local input_pc_scale = GUI:TextInput_Create(input_scale_1, "input_pc_scale", 0.00, 0.00, 50.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_scale, "")
	GUI:TextInput_setFontColor(input_pc_scale, "#ffffff")
	GUI:setTouchEnabled(input_pc_scale, true)
	GUI:setTag(input_pc_scale, -1)
end
return ui