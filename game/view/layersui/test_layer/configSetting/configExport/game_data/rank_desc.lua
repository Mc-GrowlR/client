local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(panel_bg, "Text_1", 0.00, 350.00, 14, "#ffffff", [[类型id]])
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create input_bg1
	local input_bg1 = GUI:Image_Create(panel_bg, "input_bg1", 50.00, 345.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg1, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg1, false)
	GUI:setTouchEnabled(input_bg1, false)
	GUI:setTag(input_bg1, -1)

	-- Create input_id
	local input_id = GUI:TextInput_Create(panel_bg, "input_id", 50.00, 345.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_id, "")
	GUI:TextInput_setFontColor(input_id, "#ffffff")
	GUI:setTouchEnabled(input_id, true)
	GUI:setTag(input_id, -1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(panel_bg, "Text_2", 0.00, 300.00, 14, "#ffffff", [[描述]])
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, -1)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create input_bg2
	local input_bg2 = GUI:Image_Create(panel_bg, "input_bg2", 50.00, 295.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg2, 0, 0, 0, 0)
	GUI:setContentSize(input_bg2, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg2, false)
	GUI:setTouchEnabled(input_bg2, false)
	GUI:setTag(input_bg2, -1)

	-- Create input_desc
	local input_desc = GUI:TextInput_Create(panel_bg, "input_desc", 50.00, 295.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_desc, "")
	GUI:TextInput_setFontColor(input_desc, "#ffffff")
	GUI:setTouchEnabled(input_desc, true)
	GUI:setTag(input_desc, -1)

	-- Create Layout_line
	local Layout_line = GUI:Layout_Create(panel_bg, "Layout_line", 0.00, 275.00, 300.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(Layout_line, 1)
	GUI:Layout_setBackGroundColor(Layout_line, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(Layout_line, 255)
	GUI:setTouchEnabled(Layout_line, false)
	GUI:setTag(Layout_line, -1)

	-- Create Text
	local Text = GUI:Text_Create(panel_bg, "Text", 0.00, 250.00, 14, "#ffffff", [[已添加列表]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create LV_item
	local LV_item = GUI:ListView_Create(panel_bg, "LV_item", 0.00, 240.00, 100.00, 240.00, 1)
	GUI:ListView_setBackGroundColorType(LV_item, 1)
	GUI:ListView_setBackGroundColor(LV_item, "#deded6")
	GUI:ListView_setBackGroundColorOpacity(LV_item, 100)
	GUI:ListView_setGravity(LV_item, 5)
	GUI:setAnchorPoint(LV_item, 0.00, 1.00)
	GUI:setTouchEnabled(LV_item, true)
	GUI:setTag(LV_item, -1)

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

	-- Create Button_add
	local Button_add = GUI:Button_Create(panel_bg, "Button_add", 263.00, 300.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_add, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_add, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_add, 0, 0, 0, 0)
	GUI:setContentSize(Button_add, 60, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_add, false)
	GUI:Button_setTitleText(Button_add, "添加")
	GUI:Button_setTitleColor(Button_add, "#00ff00")
	GUI:Button_setTitleFontSize(Button_add, 16)
	GUI:Button_titleEnableOutline(Button_add, "#000000", 1)
	GUI:setAnchorPoint(Button_add, 0.50, 0.50)
	GUI:setTouchEnabled(Button_add, true)
	GUI:setTag(Button_add, -1)

	-- Create Button_clear
	local Button_clear = GUI:Button_Create(panel_bg, "Button_clear", 200.00, 300.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_clear, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_clear, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_clear, 16, 14, 13, 11)
	GUI:setContentSize(Button_clear, 60, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_clear, false)
	GUI:Button_setTitleText(Button_clear, "清除")
	GUI:Button_setTitleColor(Button_clear, "#00ff00")
	GUI:Button_setTitleFontSize(Button_clear, 16)
	GUI:Button_titleEnableOutline(Button_clear, "#000000", 1)
	GUI:setAnchorPoint(Button_clear, 0.50, 0.50)
	GUI:setTouchEnabled(Button_clear, true)
	GUI:setTag(Button_clear, -1)

	-- Create panel_cell
	local panel_cell = GUI:Layout_Create(panel_bg, "panel_cell", 200.00, 150.00, 100.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(panel_cell, 1)
	GUI:Layout_setBackGroundColor(panel_cell, "#008800")
	GUI:Layout_setBackGroundColorOpacity(panel_cell, 140)
	GUI:setTouchEnabled(panel_cell, false)
	GUI:setTag(panel_cell, -1)

	-- Create Text_id
	local Text_id = GUI:Text_Create(panel_cell, "Text_id", 10.00, 15.00, 14, "#ffffff", [[1]])
	GUI:setAnchorPoint(Text_id, 0.00, 0.50)
	GUI:setTouchEnabled(Text_id, false)
	GUI:setTag(Text_id, -1)
	GUI:Text_enableOutline(Text_id, "#000000", 1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(panel_cell, "Text_desc", 50.00, 15.00, 14, "#ffffff", [[级]])
	GUI:setAnchorPoint(Text_desc, 0.00, 0.50)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, -1)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)
end
return ui