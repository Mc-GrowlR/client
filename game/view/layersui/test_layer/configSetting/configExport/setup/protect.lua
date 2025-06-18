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
	local line = GUI:Layout_Create(panel_bg, "line", 0.00, 134.00, 520.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line, 1)
	GUI:Layout_setBackGroundColor(line, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line, 255)
	GUI:setTouchEnabled(line, false)
	GUI:setTag(line, -1)

	-- Create Node_list
	local Node_list = GUI:Node_Create(panel_bg, "Node_list", 274.00, 3.00)
	GUI:setTag(Node_list, -1)

	-- Create Text_list
	local Text_list = GUI:Text_Create(Node_list, "Text_list", 0.00, 110.00, 14, "#ffffff", [[可使用的道具ID配置]])
	GUI:setTouchEnabled(Text_list, false)
	GUI:setTag(Text_list, -1)
	GUI:Text_enableOutline(Text_list, "#000000", 1)

	-- Create bg_list
	local bg_list = GUI:Layout_Create(Node_list, "bg_list", 0.00, 0.00, 90.00, 106.00, false)
	GUI:Layout_setBackGroundColorType(bg_list, 1)
	GUI:Layout_setBackGroundColor(bg_list, "#000000")
	GUI:Layout_setBackGroundColorOpacity(bg_list, 153)
	GUI:setTouchEnabled(bg_list, false)
	GUI:setTag(bg_list, -1)

	-- Create list_items
	local list_items = GUI:ListView_Create(Node_list, "list_items", 1.00, 1.00, 88.00, 104.00, 1)
	GUI:ListView_setGravity(list_items, 2)
	GUI:ListView_setItemsMargin(list_items, 1)
	GUI:setTouchEnabled(list_items, true)
	GUI:setTag(list_items, -1)

	-- Create bg_input
	local bg_input = GUI:Image_Create(Node_list, "bg_input", 148.00, 74.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input, 0, 0, 0, 0)
	GUI:setContentSize(bg_input, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input, false)
	GUI:setTouchEnabled(bg_input, false)
	GUI:setTag(bg_input, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input, "Text", -4.00, 13.00, 14, "#ffffff", [[道具ID]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input
	local input = GUI:TextInput_Create(bg_input, "input", 0.00, 1.00, 76.00, 25.00, 16)
	GUI:TextInput_setString(input, "")
	GUI:TextInput_setFontColor(input, "#ffffff")
	GUI:setTouchEnabled(input, true)
	GUI:setTag(input, -1)

	-- Create btn_add
	local btn_add = GUI:Layout_Create(Node_list, "btn_add", 171.00, 10.00, 50.00, 24.00, false)
	GUI:Layout_setBackGroundColorType(btn_add, 1)
	GUI:Layout_setBackGroundColor(btn_add, "#7788ff")
	GUI:Layout_setBackGroundColorOpacity(btn_add, 255)
	GUI:setTouchEnabled(btn_add, true)
	GUI:setTag(btn_add, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_add, "Text", 25.00, 12.00, 14, "#ffffff", [[添加]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_change
	local btn_change = GUI:Layout_Create(Node_list, "btn_change", 171.00, 41.00, 50.00, 24.00, false)
	GUI:Layout_setBackGroundColorType(btn_change, 1)
	GUI:Layout_setBackGroundColor(btn_change, "#7788ff")
	GUI:Layout_setBackGroundColorOpacity(btn_change, 255)
	GUI:setTouchEnabled(btn_change, true)
	GUI:setTag(btn_change, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_change, "Text", 25.00, 12.00, 14, "#ffffff", [[修改]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_del
	local btn_del = GUI:Layout_Create(Node_list, "btn_del", 113.00, 41.00, 50.00, 24.00, false)
	GUI:Layout_setBackGroundColorType(btn_del, 1)
	GUI:Layout_setBackGroundColor(btn_del, "#7788ff")
	GUI:Layout_setBackGroundColorOpacity(btn_del, 255)
	GUI:setTouchEnabled(btn_del, true)
	GUI:setTag(btn_del, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_del, "Text", 25.00, 12.00, 14, "#ffffff", [[删除]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create bg_input_hp
	local bg_input_hp = GUI:Image_Create(panel_bg, "bg_input_hp", 101.00, 93.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_hp, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_hp, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_hp, false)
	GUI:setTouchEnabled(bg_input_hp, false)
	GUI:setTag(bg_input_hp, -1)

	-- Create hp_prefix
	local hp_prefix = GUI:Text_Create(bg_input_hp, "hp_prefix", -4.00, 13.00, 14, "#ffffff", [[默认保护血量]])
	GUI:setAnchorPoint(hp_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(hp_prefix, false)
	GUI:setTag(hp_prefix, -1)
	GUI:Text_enableOutline(hp_prefix, "#000000", 1)

	-- Create input_hp
	local input_hp = GUI:TextInput_Create(bg_input_hp, "input_hp", 0.00, 1.00, 76.00, 25.00, 16)
	GUI:TextInput_setString(input_hp, "")
	GUI:TextInput_setFontColor(input_hp, "#ffffff")
	GUI:setTouchEnabled(input_hp, true)
	GUI:setTag(input_hp, -1)

	-- Create hp_surfix
	local hp_surfix = GUI:Text_Create(bg_input_hp, "hp_surfix", 86.00, 13.00, 14, "#ffffff", [[%]])
	GUI:setAnchorPoint(hp_surfix, 0.00, 0.50)
	GUI:setTouchEnabled(hp_surfix, false)
	GUI:setTag(hp_surfix, -1)
	GUI:Text_enableOutline(hp_surfix, "#000000", 1)

	-- Create bg_input_time
	local bg_input_time = GUI:Image_Create(panel_bg, "bg_input_time", 101.00, 57.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_time, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_time, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_time, false)
	GUI:setTouchEnabled(bg_input_time, false)
	GUI:setTag(bg_input_time, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_time, "Text", -4.00, 13.00, 14, "#ffffff", [[道具使用间隔]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_time
	local input_time = GUI:TextInput_Create(bg_input_time, "input_time", 0.00, 1.00, 76.00, 25.00, 16)
	GUI:TextInput_setString(input_time, "")
	GUI:TextInput_setFontColor(input_time, "#ffffff")
	GUI:setTouchEnabled(input_time, true)
	GUI:setTag(input_time, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(bg_input_time, "Text_1", 86.00, 13.00, 14, "#ffffff", [[毫秒]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create bg_input_default1
	local bg_input_default1 = GUI:Image_Create(panel_bg, "bg_input_default1", 48.00, 93.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_default1, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_default1, 40, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_default1, false)
	GUI:setTouchEnabled(bg_input_default1, false)
	GUI:setTag(bg_input_default1, -1)
	GUI:setVisible(bg_input_default1, false)

	-- Create default1_prefix
	local default1_prefix = GUI:Text_Create(bg_input_default1, "default1_prefix", -4.00, 13.00, 14, "#ffffff", [[周围]])
	GUI:setAnchorPoint(default1_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(default1_prefix, false)
	GUI:setTag(default1_prefix, -1)
	GUI:Text_enableOutline(default1_prefix, "#000000", 1)

	-- Create input_default1
	local input_default1 = GUI:TextInput_Create(bg_input_default1, "input_default1", 0.00, 1.00, 40.00, 25.00, 16)
	GUI:TextInput_setString(input_default1, "")
	GUI:TextInput_setFontColor(input_default1, "#ffffff")
	GUI:setTouchEnabled(input_default1, true)
	GUI:setTag(input_default1, -1)

	-- Create default1_surfix
	local default1_surfix = GUI:Text_Create(bg_input_default1, "default1_surfix", 44.00, 13.00, 14, "#ffffff", [[格有]])
	GUI:setAnchorPoint(default1_surfix, 0.00, 0.50)
	GUI:setTouchEnabled(default1_surfix, false)
	GUI:setTag(default1_surfix, -1)
	GUI:Text_enableOutline(default1_surfix, "#000000", 1)

	-- Create bg_input_default2
	local bg_input_default2 = GUI:Image_Create(bg_input_default1, "bg_input_default2", 76.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_default2, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_default2, 40, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_default2, false)
	GUI:setTouchEnabled(bg_input_default2, false)
	GUI:setTag(bg_input_default2, -1)

	-- Create input_default2
	local input_default2 = GUI:TextInput_Create(bg_input_default2, "input_default2", 0.00, 1.00, 40.00, 25.00, 16)
	GUI:TextInput_setString(input_default2, "")
	GUI:TextInput_setFontColor(input_default2, "#ffffff")
	GUI:setTouchEnabled(input_default2, true)
	GUI:setTag(input_default2, -1)

	-- Create default2_surfix
	local default2_surfix = GUI:Text_Create(bg_input_default2, "default2_surfix", 43.00, 13.00, 14, "#ffffff", [[个敌人使用]])
	GUI:setAnchorPoint(default2_surfix, 0.00, 0.50)
	GUI:setTouchEnabled(default2_surfix, false)
	GUI:setTag(default2_surfix, -1)
	GUI:Text_enableOutline(default2_surfix, "#000000", 1)
end
return ui