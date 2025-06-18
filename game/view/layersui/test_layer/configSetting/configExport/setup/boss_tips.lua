local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 520.00, 170.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create click_cell
	local click_cell = GUI:Layout_Create(panel_bg, "click_cell", 10.00, 138.00, 120.00, 26.00, false)
	GUI:setTouchEnabled(click_cell, true)
	GUI:setTag(click_cell, -1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(click_cell, "Text_desc", 60.00, 13.00, 14, "#ffffff", [[默认勾选]])
	GUI:setAnchorPoint(Text_desc, 1.00, 0.50)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, -1)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create CheckBox_able
	local CheckBox_able = GUI:Layout_Create(click_cell, "CheckBox_able", 71.00, 13.00, 44.00, 18.00, false)
	GUI:setAnchorPoint(CheckBox_able, 0.00, 0.50)
	GUI:setTouchEnabled(CheckBox_able, false)
	GUI:setTag(CheckBox_able, -1)

	-- Create Panel_off
	local Panel_off = GUI:Layout_Create(CheckBox_able, "Panel_off", 0.00, 0.00, 44.00, 18.00, false)
	GUI:setTouchEnabled(Panel_off, false)
	GUI:setTag(Panel_off, -1)
	GUI:setVisible(Panel_off, false)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_off, "Image_bg", 22.00, 9.00, "res/private/new_setting/clickbg2.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, -1)

	-- Create Image_circle
	local Image_circle = GUI:Image_Create(Panel_off, "Image_circle", 10.00, 8.00, "res/private/new_setting/click3.png")
	GUI:setAnchorPoint(Image_circle, 0.50, 0.50)
	GUI:setTouchEnabled(Image_circle, false)
	GUI:setTag(Image_circle, -1)

	-- Create Panel_on
	local Panel_on = GUI:Layout_Create(CheckBox_able, "Panel_on", 0.00, 0.00, 44.00, 18.00, false)
	GUI:setTouchEnabled(Panel_on, false)
	GUI:setTag(Panel_on, -1)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_on, "Image_bg", 22.00, 9.00, "res/private/new_setting/clickbg1.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, -1)

	-- Create Image_circle
	local Image_circle = GUI:Image_Create(Panel_on, "Image_circle", 33.00, 8.00, "res/private/new_setting/click3.png")
	GUI:setAnchorPoint(Image_circle, 0.50, 0.50)
	GUI:setTouchEnabled(Image_circle, false)
	GUI:setTag(Image_circle, -1)

	-- Create line
	local line = GUI:Layout_Create(panel_bg, "line", 0.00, 128.00, 520.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line, 1)
	GUI:Layout_setBackGroundColor(line, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line, 255)
	GUI:setTouchEnabled(line, false)
	GUI:setTag(line, -1)

	-- Create Node_list
	local Node_list = GUI:Node_Create(panel_bg, "Node_list", 0.00, 0.00)
	GUI:setTag(Node_list, -1)

	-- Create Text_list
	local Text_list = GUI:Text_Create(Node_list, "Text_list", 14.00, 105.00, 14, "#ffffff", [[默认怪物列表]])
	GUI:setTouchEnabled(Text_list, false)
	GUI:setTag(Text_list, -1)
	GUI:Text_enableOutline(Text_list, "#000000", 1)

	-- Create bg_list
	local bg_list = GUI:Layout_Create(Node_list, "bg_list", 0.00, 0.00, 260.00, 100.00, false)
	GUI:Layout_setBackGroundColorType(bg_list, 1)
	GUI:Layout_setBackGroundColor(bg_list, "#000000")
	GUI:Layout_setBackGroundColorOpacity(bg_list, 153)
	GUI:setTouchEnabled(bg_list, false)
	GUI:setTag(bg_list, -1)

	-- Create list_items
	local list_items = GUI:ListView_Create(Node_list, "list_items", 0.00, 0.00, 260.00, 100.00, 1)
	GUI:ListView_setGravity(list_items, 2)
	GUI:ListView_setItemsMargin(list_items, 1)
	GUI:setTouchEnabled(list_items, true)
	GUI:setTag(list_items, -1)

	-- Create bg_input
	local bg_input = GUI:Image_Create(Node_list, "bg_input", 345.00, 65.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input, 0, 0, 0, 0)
	GUI:setContentSize(bg_input, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input, false)
	GUI:setTouchEnabled(bg_input, false)
	GUI:setTag(bg_input, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input, "Text", 0.00, 13.00, 14, "#ffffff", [[怪物名称：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input
	local input = GUI:TextInput_Create(bg_input, "input", 0.00, 1.00, 156.00, 25.00, 16)
	GUI:TextInput_setString(input, "")
	GUI:TextInput_setFontColor(input, "#ffffff")
	GUI:setTouchEnabled(input, true)
	GUI:setTag(input, -1)

	-- Create btn_add
	local btn_add = GUI:Layout_Create(Node_list, "btn_add", 286.00, 27.00, 60.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_add, 1)
	GUI:Layout_setBackGroundColor(btn_add, "#7788ff")
	GUI:Layout_setBackGroundColorOpacity(btn_add, 255)
	GUI:setTouchEnabled(btn_add, true)
	GUI:setTag(btn_add, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_add, "Text", 30.00, 13.00, 14, "#ffffff", [[添加]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_change
	local btn_change = GUI:Layout_Create(Node_list, "btn_change", 358.00, 28.00, 60.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_change, 1)
	GUI:Layout_setBackGroundColor(btn_change, "#7788ff")
	GUI:Layout_setBackGroundColorOpacity(btn_change, 255)
	GUI:setTouchEnabled(btn_change, true)
	GUI:setTag(btn_change, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_change, "Text", 30.00, 13.00, 14, "#ffffff", [[修改]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_del
	local btn_del = GUI:Layout_Create(Node_list, "btn_del", 431.00, 28.00, 60.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_del, 1)
	GUI:Layout_setBackGroundColor(btn_del, "#7788ff")
	GUI:Layout_setBackGroundColorOpacity(btn_del, 255)
	GUI:setTouchEnabled(btn_del, true)
	GUI:setTag(btn_del, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_del, "Text", 30.00, 13.00, 14, "#ffffff", [[删除]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)
end
return ui