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

	-- Create Layout_title
	local Layout_title = GUI:Layout_Create(panel_bg, "Layout_title", 6.00, 350.00, 60.00, 24.00, false)
	GUI:Layout_setBackGroundColorType(Layout_title, 1)
	GUI:Layout_setBackGroundColor(Layout_title, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_title, 140)
	GUI:setTouchEnabled(Layout_title, false)
	GUI:setTag(Layout_title, -1)

	-- Create Text_title
	local Text_title = GUI:Text_Create(Layout_title, "Text_title", 30.00, 12.00, 14, "#ffffff", [[列表]])
	GUI:setAnchorPoint(Text_title, 0.50, 0.50)
	GUI:setTouchEnabled(Text_title, false)
	GUI:setTag(Text_title, -1)
	GUI:Text_enableOutline(Text_title, "#000000", 1)

	-- Create Layout_list
	local Layout_list = GUI:Layout_Create(panel_bg, "Layout_list", 6.00, 350.00, 142.00, 290.00, false)
	GUI:Layout_setBackGroundColorType(Layout_list, 1)
	GUI:Layout_setBackGroundColor(Layout_list, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_list, 153)
	GUI:setAnchorPoint(Layout_list, 0.00, 1.00)
	GUI:setTouchEnabled(Layout_list, false)
	GUI:setTag(Layout_list, -1)

	-- Create ListView_items
	local ListView_items = GUI:ListView_Create(Layout_list, "ListView_items", 0.00, 266.00, 142.00, 235.00, 1)
	GUI:ListView_setGravity(ListView_items, 5)
	GUI:setAnchorPoint(ListView_items, 0.00, 1.00)
	GUI:setTouchEnabled(ListView_items, true)
	GUI:setTag(ListView_items, -1)

	-- Create btn_del
	local btn_del = GUI:Layout_Create(Layout_list, "btn_del", 138.00, 2.00, 60.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_del, 1)
	GUI:Layout_setBackGroundColor(btn_del, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_del, 255)
	GUI:setAnchorPoint(btn_del, 1.00, 0.00)
	GUI:setTouchEnabled(btn_del, true)
	GUI:setTag(btn_del, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_del, "Text", 30.00, 13.00, 14, "#ffffff", [[删 除]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create title_bg
	local title_bg = GUI:Layout_Create(Layout_list, "title_bg", 0.00, 290.00, 142.00, 24.00, false)
	GUI:Layout_setBackGroundColorType(title_bg, 1)
	GUI:Layout_setBackGroundColor(title_bg, "#000000")
	GUI:Layout_setBackGroundColorOpacity(title_bg, 160)
	GUI:setAnchorPoint(title_bg, 0.00, 1.00)
	GUI:setTouchEnabled(title_bg, false)
	GUI:setTag(title_bg, -1)

	-- Create title_idx
	local title_idx = GUI:Text_Create(title_bg, "title_idx", 25.00, 12.00, 14, "#ffffff", [[序号]])
	GUI:setAnchorPoint(title_idx, 0.50, 0.50)
	GUI:setTouchEnabled(title_idx, false)
	GUI:setTag(title_idx, -1)
	GUI:Text_enableOutline(title_idx, "#000000", 1)

	-- Create title_dir
	local title_dir = GUI:Text_Create(title_bg, "title_dir", 71.00, 12.00, 14, "#ffffff", [[方向]])
	GUI:setAnchorPoint(title_dir, 0.50, 0.50)
	GUI:setTouchEnabled(title_dir, false)
	GUI:setTag(title_dir, -1)
	GUI:Text_enableOutline(title_dir, "#000000", 1)

	-- Create title_act
	local title_act = GUI:Text_Create(title_bg, "title_act", 117.00, 12.00, 14, "#ffffff", [[动作]])
	GUI:setAnchorPoint(title_act, 0.50, 0.50)
	GUI:setTouchEnabled(title_act, false)
	GUI:setTag(title_act, -1)
	GUI:Text_enableOutline(title_act, "#000000", 1)

	-- Create panel_item
	local panel_item = GUI:Layout_Create(Layout_list, "panel_item", 0.00, 264.00, 142.00, 24.00, false)
	GUI:Layout_setBackGroundColorType(panel_item, 1)
	GUI:Layout_setBackGroundColor(panel_item, "#000000")
	GUI:Layout_setBackGroundColorOpacity(panel_item, 160)
	GUI:setAnchorPoint(panel_item, 0.00, 1.00)
	GUI:setTouchEnabled(panel_item, true)
	GUI:setTag(panel_item, -1)
	GUI:setVisible(panel_item, false)

	-- Create idx
	local idx = GUI:Text_Create(panel_item, "idx", 25.00, 12.00, 14, "#ffffff", [[1]])
	GUI:setAnchorPoint(idx, 0.50, 0.50)
	GUI:setTouchEnabled(idx, false)
	GUI:setTag(idx, -1)
	GUI:Text_enableOutline(idx, "#000000", 1)

	-- Create dir
	local dir = GUI:Text_Create(panel_item, "dir", 71.00, 12.00, 14, "#ffffff", [[正上]])
	GUI:setAnchorPoint(dir, 0.50, 0.50)
	GUI:setTouchEnabled(dir, false)
	GUI:setTag(dir, -1)
	GUI:Text_enableOutline(dir, "#000000", 1)

	-- Create act
	local act = GUI:Text_Create(panel_item, "act", 117.00, 12.00, 14, "#ffffff", [[待机]])
	GUI:setAnchorPoint(act, 0.50, 0.50)
	GUI:setTouchEnabled(act, false)
	GUI:setTag(act, -1)
	GUI:Text_enableOutline(act, "#000000", 1)

	-- Create Layout_edit
	local Layout_edit = GUI:Layout_Create(panel_bg, "Layout_edit", 294.00, 350.00, 142.00, 290.00, false)
	GUI:Layout_setBackGroundColorType(Layout_edit, 1)
	GUI:Layout_setBackGroundColor(Layout_edit, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_edit, 153)
	GUI:setAnchorPoint(Layout_edit, 1.00, 1.00)
	GUI:setTouchEnabled(Layout_edit, false)
	GUI:setTag(Layout_edit, -1)

	-- Create btn_add
	local btn_add = GUI:Layout_Create(panel_bg, "btn_add", 291.00, 62.00, 60.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_add, 1)
	GUI:Layout_setBackGroundColor(btn_add, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_add, 255)
	GUI:setAnchorPoint(btn_add, 1.00, 0.00)
	GUI:setTouchEnabled(btn_add, true)
	GUI:setTag(btn_add, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_add, "Text", 30.00, 13.00, 14, "#ffffff", [[新 增]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create bg_node_dir
	local bg_node_dir = GUI:Layout_Create(panel_bg, "bg_node_dir", 243.00, 302.00, 85.00, 28.00, false)
	GUI:Layout_setBackGroundImage(bg_node_dir, "res/public/1900015004.png")
	GUI:Layout_setBackGroundImageScale9Slice(bg_node_dir, 73, 74, 13, 14)
	GUI:setAnchorPoint(bg_node_dir, 0.50, 0.00)
	GUI:setTouchEnabled(bg_node_dir, true)
	GUI:setTag(bg_node_dir, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_node_dir, "Text", 0.00, 14.00, 14, "#ffffff", [[方向：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_dir
	local Text_dir = GUI:Text_Create(bg_node_dir, "Text_dir", 33.00, 14.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_dir, 0.50, 0.50)
	GUI:setTouchEnabled(Text_dir, false)
	GUI:setTag(Text_dir, -1)
	GUI:Text_enableOutline(Text_dir, "#000000", 1)

	-- Create arrow_dir
	local arrow_dir = GUI:Image_Create(bg_node_dir, "arrow_dir", 75.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow_dir, 0.50, 0.50)
	GUI:setTouchEnabled(arrow_dir, false)
	GUI:setTag(arrow_dir, -1)

	-- Create bg_node_act
	local bg_node_act = GUI:Layout_Create(panel_bg, "bg_node_act", 243.00, 255.00, 85.00, 28.00, false)
	GUI:Layout_setBackGroundImage(bg_node_act, "res/public/1900015004.png")
	GUI:Layout_setBackGroundImageScale9Slice(bg_node_act, 0, 0, 0, 0)
	GUI:setAnchorPoint(bg_node_act, 0.50, 0.00)
	GUI:setTouchEnabled(bg_node_act, true)
	GUI:setTag(bg_node_act, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_node_act, "Text", 0.00, 14.00, 14, "#ffffff", [[动作：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_act
	local Text_act = GUI:Text_Create(bg_node_act, "Text_act", 33.00, 14.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_act, 0.50, 0.50)
	GUI:setTouchEnabled(Text_act, false)
	GUI:setTag(Text_act, -1)
	GUI:Text_enableOutline(Text_act, "#000000", 1)

	-- Create arrow_act
	local arrow_act = GUI:Image_Create(bg_node_act, "arrow_act", 75.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow_act, 0.50, 0.50)
	GUI:setTouchEnabled(arrow_act, false)
	GUI:setTag(arrow_act, -1)

	-- Create Layout_hide_pullDownList
	local Layout_hide_pullDownList = GUI:Layout_Create(panel_bg, "Layout_hide_pullDownList", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(Layout_hide_pullDownList, true)
	GUI:setTag(Layout_hide_pullDownList, -1)
	GUI:setVisible(Layout_hide_pullDownList, false)

	-- Create Image_pulldown_bg
	local Image_pulldown_bg = GUI:Image_Create(panel_bg, "Image_pulldown_bg", 6.00, 0.00, "res/public/1900000677.png")
	GUI:Image_setScale9Slice(Image_pulldown_bg, 22, 21, 33, 34)
	GUI:setContentSize(Image_pulldown_bg, 86, 200)
	GUI:setIgnoreContentAdaptWithSize(Image_pulldown_bg, false)
	GUI:setAnchorPoint(Image_pulldown_bg, 0.50, 1.00)
	GUI:setTouchEnabled(Image_pulldown_bg, false)
	GUI:setTag(Image_pulldown_bg, -1)
	GUI:setVisible(Image_pulldown_bg, false)

	-- Create ListView_pulldown
	local ListView_pulldown = GUI:ListView_Create(Image_pulldown_bg, "ListView_pulldown", 43.00, 197.00, 80.00, 194.00, 1)
	GUI:ListView_setGravity(ListView_pulldown, 5)
	GUI:setAnchorPoint(ListView_pulldown, 0.50, 1.00)
	GUI:setTouchEnabled(ListView_pulldown, true)
	GUI:setTag(ListView_pulldown, -1)
end
return ui