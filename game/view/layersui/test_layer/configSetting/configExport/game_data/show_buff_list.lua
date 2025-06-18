local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create Button_sure
	local Button_sure = GUI:Button_Create(panel_bg, "Button_sure", 263.00, 16.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_sure, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_sure, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_sure, 16, 14, 13, 11)
	GUI:setContentSize(Button_sure, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(Button_sure, false)
	GUI:Button_setTitleText(Button_sure, "保 存")
	GUI:Button_setTitleColor(Button_sure, "#00ff00")
	GUI:Button_setTitleFontSize(Button_sure, 16)
	GUI:Button_titleEnableOutline(Button_sure, "#000000", 1)
	GUI:setAnchorPoint(Button_sure, 0.50, 0.50)
	GUI:setTouchEnabled(Button_sure, true)
	GUI:setTag(Button_sure, -1)

	-- Create page_btn_1
	local page_btn_1 = GUI:Layout_Create(panel_bg, "page_btn_1", 15.00, 350.00, 130.00, 28.00, false)
	GUI:Layout_setBackGroundColorType(page_btn_1, 1)
	GUI:Layout_setBackGroundColor(page_btn_1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(page_btn_1, 255)
	GUI:setTouchEnabled(page_btn_1, true)
	GUI:setTag(page_btn_1, 1)

	-- Create Text
	local Text = GUI:Text_Create(page_btn_1, "Text", 65.00, 14.00, 14, "#ffffff", [[手机端配置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create page_btn_2
	local page_btn_2 = GUI:Layout_Create(panel_bg, "page_btn_2", 155.00, 350.00, 130.00, 28.00, false)
	GUI:Layout_setBackGroundColorType(page_btn_2, 1)
	GUI:Layout_setBackGroundColor(page_btn_2, "#000000")
	GUI:Layout_setBackGroundColorOpacity(page_btn_2, 255)
	GUI:setTouchEnabled(page_btn_2, true)
	GUI:setTag(page_btn_2, 2)

	-- Create Text
	local Text = GUI:Text_Create(page_btn_2, "Text", 65.00, 14.00, 14, "#ffffff", [[电脑端配置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create bg_node_index
	local bg_node_index = GUI:Image_Create(panel_bg, "bg_node_index", 130.00, 316.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_node_index, 73, 74, 13, 14)
	GUI:setContentSize(bg_node_index, 100, 28)
	GUI:setIgnoreContentAdaptWithSize(bg_node_index, false)
	GUI:setAnchorPoint(bg_node_index, 0.50, 0.00)
	GUI:setTouchEnabled(bg_node_index, true)
	GUI:setTag(bg_node_index, -1)

	-- Create node_index_prefix
	local node_index_prefix = GUI:Text_Create(bg_node_index, "node_index_prefix", -10.00, 13.00, 14, "#ffffff", [[显示位置]])
	GUI:setAnchorPoint(node_index_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(node_index_prefix, false)
	GUI:setTag(node_index_prefix, -1)
	GUI:Text_enableOutline(node_index_prefix, "#000000", 1)

	-- Create Text_node_index
	local Text_node_index = GUI:Text_Create(bg_node_index, "Text_node_index", 5.00, 14.00, 14, "#ffffff", [[左上方]])
	GUI:setAnchorPoint(Text_node_index, 0.00, 0.50)
	GUI:setTouchEnabled(Text_node_index, false)
	GUI:setTag(Text_node_index, -1)
	GUI:Text_enableOutline(Text_node_index, "#000000", 1)

	-- Create arrow
	local arrow = GUI:Image_Create(bg_node_index, "arrow", 90.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow, 0.50, 0.50)
	GUI:setTouchEnabled(arrow, false)
	GUI:setTag(arrow, -1)

	-- Create bg_pos_x
	local bg_pos_x = GUI:Image_Create(panel_bg, "bg_pos_x", 80.00, 296.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_pos_x, 0, 0, 0, 0)
	GUI:setContentSize(bg_pos_x, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_pos_x, false)
	GUI:setAnchorPoint(bg_pos_x, 0.00, 0.50)
	GUI:setTouchEnabled(bg_pos_x, false)
	GUI:setTag(bg_pos_x, -1)

	-- Create pos_x_prefix
	local pos_x_prefix = GUI:Text_Create(bg_pos_x, "pos_x_prefix", -67.00, 13.00, 14, "#ffffff", [[X坐标偏移]])
	GUI:setAnchorPoint(pos_x_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(pos_x_prefix, false)
	GUI:setTag(pos_x_prefix, -1)
	GUI:Text_enableOutline(pos_x_prefix, "#000000", 1)

	-- Create InputX
	local InputX = GUI:TextInput_Create(bg_pos_x, "InputX", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(InputX, "")
	GUI:TextInput_setFontColor(InputX, "#ffffff")
	GUI:setTouchEnabled(InputX, true)
	GUI:setTag(InputX, -1)

	-- Create bg_pos_y
	local bg_pos_y = GUI:Image_Create(panel_bg, "bg_pos_y", 230.00, 296.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_pos_y, 0, 0, 0, 0)
	GUI:setContentSize(bg_pos_y, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_pos_y, false)
	GUI:setAnchorPoint(bg_pos_y, 0.00, 0.50)
	GUI:setTouchEnabled(bg_pos_y, false)
	GUI:setTag(bg_pos_y, -1)

	-- Create pos_y_prefix
	local pos_y_prefix = GUI:Text_Create(bg_pos_y, "pos_y_prefix", -67.00, 13.00, 14, "#ffffff", [[Y坐标偏移]])
	GUI:setAnchorPoint(pos_y_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(pos_y_prefix, false)
	GUI:setTag(pos_y_prefix, -1)
	GUI:Text_enableOutline(pos_y_prefix, "#000000", 1)

	-- Create InputY
	local InputY = GUI:TextInput_Create(bg_pos_y, "InputY", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(InputY, "")
	GUI:TextInput_setFontColor(InputY, "#ffffff")
	GUI:setTouchEnabled(InputY, true)
	GUI:setTag(InputY, -1)

	-- Create bg_width
	local bg_width = GUI:Image_Create(panel_bg, "bg_width", 80.00, 260.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_width, 0, 0, 0, 0)
	GUI:setContentSize(bg_width, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_width, false)
	GUI:setAnchorPoint(bg_width, 0.00, 0.50)
	GUI:setTouchEnabled(bg_width, false)
	GUI:setTag(bg_width, -1)

	-- Create bg_width_prefix
	local bg_width_prefix = GUI:Text_Create(bg_width, "bg_width_prefix", -67.00, 13.00, 14, "#ffffff", [[宽  度]])
	GUI:setAnchorPoint(bg_width_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(bg_width_prefix, false)
	GUI:setTag(bg_width_prefix, -1)
	GUI:Text_enableOutline(bg_width_prefix, "#000000", 1)

	-- Create InputW
	local InputW = GUI:TextInput_Create(bg_width, "InputW", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(InputW, "")
	GUI:TextInput_setFontColor(InputW, "#ffffff")
	GUI:setTouchEnabled(InputW, true)
	GUI:setTag(InputW, -1)

	-- Create bg_height
	local bg_height = GUI:Image_Create(panel_bg, "bg_height", 230.00, 260.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_height, 0, 0, 0, 0)
	GUI:setContentSize(bg_height, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_height, false)
	GUI:setAnchorPoint(bg_height, 0.00, 0.50)
	GUI:setTouchEnabled(bg_height, false)
	GUI:setTag(bg_height, -1)

	-- Create bg_height_prefix
	local bg_height_prefix = GUI:Text_Create(bg_height, "bg_height_prefix", -67.00, 13.00, 14, "#ffffff", [[高  度]])
	GUI:setAnchorPoint(bg_height_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(bg_height_prefix, false)
	GUI:setTag(bg_height_prefix, -1)
	GUI:Text_enableOutline(bg_height_prefix, "#000000", 1)

	-- Create InputH
	local InputH = GUI:TextInput_Create(bg_height, "InputH", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(InputH, "")
	GUI:TextInput_setFontColor(InputH, "#ffffff")
	GUI:setTouchEnabled(InputH, true)
	GUI:setTag(InputH, -1)

	-- Create bg_show_num
	local bg_show_num = GUI:Image_Create(panel_bg, "bg_show_num", 70.00, 224.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_show_num, 0, 0, 0, 0)
	GUI:setContentSize(bg_show_num, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_show_num, false)
	GUI:setAnchorPoint(bg_show_num, 0.00, 0.50)
	GUI:setTouchEnabled(bg_show_num, false)
	GUI:setTag(bg_show_num, -1)

	-- Create show_num_prefix
	local show_num_prefix = GUI:Text_Create(bg_show_num, "show_num_prefix", -64.00, 13.00, 14, "#ffffff", [[显示数量]])
	GUI:setAnchorPoint(show_num_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(show_num_prefix, false)
	GUI:setTag(show_num_prefix, -1)
	GUI:Text_enableOutline(show_num_prefix, "#000000", 1)

	-- Create InputNum
	local InputNum = GUI:TextInput_Create(bg_show_num, "InputNum", 1.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(InputNum, "")
	GUI:TextInput_setFontColor(InputNum, "#ffffff")
	GUI:setTouchEnabled(InputNum, true)
	GUI:setTag(InputNum, -1)

	-- Create bg_dir
	local bg_dir = GUI:Image_Create(panel_bg, "bg_dir", 248.00, 210.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_dir, 73, 74, 13, 14)
	GUI:setContentSize(bg_dir, 100, 28)
	GUI:setIgnoreContentAdaptWithSize(bg_dir, false)
	GUI:setAnchorPoint(bg_dir, 0.50, 0.00)
	GUI:setTouchEnabled(bg_dir, true)
	GUI:setTag(bg_dir, -1)

	-- Create dir_prefix
	local dir_prefix = GUI:Text_Create(bg_dir, "dir_prefix", -3.00, 13.00, 14, "#ffffff", [[滑动方向]])
	GUI:setAnchorPoint(dir_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(dir_prefix, false)
	GUI:setTag(dir_prefix, -1)
	GUI:Text_enableOutline(dir_prefix, "#000000", 1)

	-- Create Text_dir
	local Text_dir = GUI:Text_Create(bg_dir, "Text_dir", 5.00, 14.00, 14, "#ffffff", [[横向]])
	GUI:setAnchorPoint(Text_dir, 0.00, 0.50)
	GUI:setTouchEnabled(Text_dir, false)
	GUI:setTag(Text_dir, -1)
	GUI:Text_enableOutline(Text_dir, "#000000", 1)

	-- Create arrow_dir
	local arrow_dir = GUI:Image_Create(bg_dir, "arrow_dir", 87.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow_dir, 0.50, 0.50)
	GUI:setTouchEnabled(arrow_dir, false)
	GUI:setTag(arrow_dir, -1)

	-- Create bg_dir_tips
	local bg_dir_tips = GUI:Image_Create(panel_bg, "bg_dir_tips", 150.00, 174.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_dir_tips, 73, 74, 13, 14)
	GUI:setContentSize(bg_dir_tips, 100, 28)
	GUI:setIgnoreContentAdaptWithSize(bg_dir_tips, false)
	GUI:setAnchorPoint(bg_dir_tips, 0.50, 0.00)
	GUI:setTouchEnabled(bg_dir_tips, true)
	GUI:setTag(bg_dir_tips, -1)

	-- Create dir_tips_prefix
	local dir_tips_prefix = GUI:Text_Create(bg_dir_tips, "dir_tips_prefix", -10.00, 13.00, 14, "#ffffff", [[Tips显示方向]])
	GUI:setAnchorPoint(dir_tips_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(dir_tips_prefix, false)
	GUI:setTag(dir_tips_prefix, -1)
	GUI:Text_enableOutline(dir_tips_prefix, "#000000", 1)

	-- Create Text_dir_tips
	local Text_dir_tips = GUI:Text_Create(bg_dir_tips, "Text_dir_tips", 5.00, 14.00, 14, "#ffffff", [[左上方]])
	GUI:setAnchorPoint(Text_dir_tips, 0.00, 0.50)
	GUI:setTouchEnabled(Text_dir_tips, false)
	GUI:setTag(Text_dir_tips, -1)
	GUI:Text_enableOutline(Text_dir_tips, "#000000", 1)

	-- Create arrow_dir_tips
	local arrow_dir_tips = GUI:Image_Create(bg_dir_tips, "arrow_dir_tips", 90.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow_dir_tips, 0.50, 0.50)
	GUI:setTouchEnabled(arrow_dir_tips, false)
	GUI:setTag(arrow_dir_tips, -1)

	-- Create bg_end_x
	local bg_end_x = GUI:Image_Create(panel_bg, "bg_end_x", 92.00, 152.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_end_x, 0, 0, 0, 0)
	GUI:setContentSize(bg_end_x, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_end_x, false)
	GUI:setAnchorPoint(bg_end_x, 0.00, 0.50)
	GUI:setTouchEnabled(bg_end_x, false)
	GUI:setTag(bg_end_x, -1)

	-- Create end_x_prefix
	local end_x_prefix = GUI:Text_Create(bg_end_x, "end_x_prefix", -86.00, 13.00, 14, "#ffffff", [[倒计时X坐标]])
	GUI:setAnchorPoint(end_x_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(end_x_prefix, false)
	GUI:setTag(end_x_prefix, -1)
	GUI:Text_enableOutline(end_x_prefix, "#000000", 1)

	-- Create InputEndX
	local InputEndX = GUI:TextInput_Create(bg_end_x, "InputEndX", 0.00, 0.00, 55.00, 25.00, 14)
	GUI:TextInput_setString(InputEndX, "")
	GUI:TextInput_setFontColor(InputEndX, "#ffffff")
	GUI:setTouchEnabled(InputEndX, true)
	GUI:setTag(InputEndX, -1)

	-- Create bg_end_y
	local bg_end_y = GUI:Image_Create(panel_bg, "bg_end_y", 243.00, 152.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_end_y, 0, 0, 0, 0)
	GUI:setContentSize(bg_end_y, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_end_y, false)
	GUI:setAnchorPoint(bg_end_y, 0.00, 0.50)
	GUI:setTouchEnabled(bg_end_y, false)
	GUI:setTag(bg_end_y, -1)

	-- Create end_y_prefix
	local end_y_prefix = GUI:Text_Create(bg_end_y, "end_y_prefix", -80.00, 13.00, 14, "#ffffff", [[倒计时Y坐标]])
	GUI:setAnchorPoint(end_y_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(end_y_prefix, false)
	GUI:setTag(end_y_prefix, -1)
	GUI:Text_enableOutline(end_y_prefix, "#000000", 1)

	-- Create InputEndY
	local InputEndY = GUI:TextInput_Create(bg_end_y, "InputEndY", 0.00, 0.00, 55.00, 25.00, 14)
	GUI:TextInput_setString(InputEndY, "")
	GUI:TextInput_setFontColor(InputEndY, "#ffffff")
	GUI:setTouchEnabled(InputEndY, true)
	GUI:setTag(InputEndY, -1)

	-- Create bg_overlap_x
	local bg_overlap_x = GUI:Image_Create(panel_bg, "bg_overlap_x", 98.00, 116.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_overlap_x, 0, 0, 0, 0)
	GUI:setContentSize(bg_overlap_x, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_overlap_x, false)
	GUI:setAnchorPoint(bg_overlap_x, 0.00, 0.50)
	GUI:setTouchEnabled(bg_overlap_x, false)
	GUI:setTag(bg_overlap_x, -1)

	-- Create overlap_x_prefix
	local overlap_x_prefix = GUI:Text_Create(bg_overlap_x, "overlap_x_prefix", -94.00, 13.00, 14, "#ffffff", [[叠加层数X坐标]])
	GUI:setAnchorPoint(overlap_x_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(overlap_x_prefix, false)
	GUI:setTag(overlap_x_prefix, -1)
	GUI:Text_enableOutline(overlap_x_prefix, "#000000", 1)

	-- Create InputOverlapX
	local InputOverlapX = GUI:TextInput_Create(bg_overlap_x, "InputOverlapX", 0.00, 0.00, 50.00, 25.00, 14)
	GUI:TextInput_setString(InputOverlapX, "")
	GUI:TextInput_setFontColor(InputOverlapX, "#ffffff")
	GUI:setTouchEnabled(InputOverlapX, true)
	GUI:setTag(InputOverlapX, -1)

	-- Create bg_overlap_y
	local bg_overlap_y = GUI:Image_Create(panel_bg, "bg_overlap_y", 248.00, 116.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_overlap_y, 0, 0, 0, 0)
	GUI:setContentSize(bg_overlap_y, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_overlap_y, false)
	GUI:setAnchorPoint(bg_overlap_y, 0.00, 0.50)
	GUI:setTouchEnabled(bg_overlap_y, false)
	GUI:setTag(bg_overlap_y, -1)

	-- Create overlap_y_prefix
	local overlap_y_prefix = GUI:Text_Create(bg_overlap_y, "overlap_y_prefix", -93.00, 13.00, 14, "#ffffff", [[叠加层数Y坐标]])
	GUI:setAnchorPoint(overlap_y_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(overlap_y_prefix, false)
	GUI:setTag(overlap_y_prefix, -1)
	GUI:Text_enableOutline(overlap_y_prefix, "#000000", 1)

	-- Create InputOverlapY
	local InputOverlapY = GUI:TextInput_Create(bg_overlap_y, "InputOverlapY", 0.00, 0.00, 50.00, 25.00, 14)
	GUI:TextInput_setString(InputOverlapY, "")
	GUI:TextInput_setFontColor(InputOverlapY, "#ffffff")
	GUI:setTouchEnabled(InputOverlapY, true)
	GUI:setTag(InputOverlapY, -1)

	-- Create bg_end_color
	local bg_end_color = GUI:Image_Create(panel_bg, "bg_end_color", 105.00, 80.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_end_color, 0, 0, 0, 0)
	GUI:setContentSize(bg_end_color, 35, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_end_color, false)
	GUI:setAnchorPoint(bg_end_color, 0.00, 0.50)
	GUI:setTouchEnabled(bg_end_color, false)
	GUI:setTag(bg_end_color, -1)

	-- Create end_color_prefix
	local end_color_prefix = GUI:Text_Create(bg_end_color, "end_color_prefix", -100.00, 13.00, 14, "#ffffff", [[倒计时颜色]])
	GUI:setAnchorPoint(end_color_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(end_color_prefix, false)
	GUI:setTag(end_color_prefix, -1)
	GUI:Text_enableOutline(end_color_prefix, "#000000", 1)

	-- Create InputEndColor
	local InputEndColor = GUI:TextInput_Create(bg_end_color, "InputEndColor", 0.00, 0.00, 35.00, 25.00, 14)
	GUI:TextInput_setString(InputEndColor, "")
	GUI:TextInput_setFontColor(InputEndColor, "#ffffff")
	GUI:setTouchEnabled(InputEndColor, true)
	GUI:setTag(InputEndColor, -1)

	-- Create Layout_end_color
	local Layout_end_color = GUI:Layout_Create(bg_end_color, "Layout_end_color", -27.00, 0.00, 25.00, 25.00, false)
	GUI:Layout_setBackGroundColorType(Layout_end_color, 1)
	GUI:Layout_setBackGroundColor(Layout_end_color, "#96c8ff")
	GUI:Layout_setBackGroundColorOpacity(Layout_end_color, 255)
	GUI:setTouchEnabled(Layout_end_color, false)
	GUI:setTag(Layout_end_color, -1)

	-- Create bg_overlap_color
	local bg_overlap_color = GUI:Image_Create(panel_bg, "bg_overlap_color", 263.00, 80.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_overlap_color, 0, 0, 0, 0)
	GUI:setContentSize(bg_overlap_color, 35, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_overlap_color, false)
	GUI:setAnchorPoint(bg_overlap_color, 0.00, 0.50)
	GUI:setTouchEnabled(bg_overlap_color, false)
	GUI:setTag(bg_overlap_color, -1)

	-- Create overlap_color_prefix
	local overlap_color_prefix = GUI:Text_Create(bg_overlap_color, "overlap_color_prefix", -113.00, 13.00, 14, "#ffffff", [[叠加层数颜色]])
	GUI:setAnchorPoint(overlap_color_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(overlap_color_prefix, false)
	GUI:setTag(overlap_color_prefix, -1)
	GUI:Text_enableOutline(overlap_color_prefix, "#000000", 1)

	-- Create InputOverlapColor
	local InputOverlapColor = GUI:TextInput_Create(bg_overlap_color, "InputOverlapColor", 0.00, 0.00, 35.00, 25.00, 14)
	GUI:TextInput_setString(InputOverlapColor, "")
	GUI:TextInput_setFontColor(InputOverlapColor, "#ffffff")
	GUI:setTouchEnabled(InputOverlapColor, true)
	GUI:setTag(InputOverlapColor, -1)

	-- Create Layout_overlap_color
	local Layout_overlap_color = GUI:Layout_Create(bg_overlap_color, "Layout_overlap_color", -27.00, 0.00, 25.00, 25.00, false)
	GUI:Layout_setBackGroundColorType(Layout_overlap_color, 1)
	GUI:Layout_setBackGroundColor(Layout_overlap_color, "#96c8ff")
	GUI:Layout_setBackGroundColorOpacity(Layout_overlap_color, 255)
	GUI:setTouchEnabled(Layout_overlap_color, false)
	GUI:setTag(Layout_overlap_color, -1)

	-- Create bg_icon_w
	local bg_icon_w = GUI:Image_Create(panel_bg, "bg_icon_w", 97.00, 45.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_icon_w, 0, 0, 0, 0)
	GUI:setContentSize(bg_icon_w, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_icon_w, false)
	GUI:setAnchorPoint(bg_icon_w, 0.00, 0.50)
	GUI:setTouchEnabled(bg_icon_w, false)
	GUI:setTag(bg_icon_w, -1)

	-- Create icon_w_prefix
	local icon_w_prefix = GUI:Text_Create(bg_icon_w, "icon_w_prefix", -90.00, 13.00, 14, "#ffffff", [[统一图标宽度]])
	GUI:setAnchorPoint(icon_w_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(icon_w_prefix, false)
	GUI:setTag(icon_w_prefix, -1)
	GUI:Text_enableOutline(icon_w_prefix, "#000000", 1)

	-- Create InputIconW
	local InputIconW = GUI:TextInput_Create(bg_icon_w, "InputIconW", 0.00, 0.00, 50.00, 25.00, 14)
	GUI:TextInput_setString(InputIconW, "")
	GUI:TextInput_setFontColor(InputIconW, "#ffffff")
	GUI:setTouchEnabled(InputIconW, true)
	GUI:setTag(InputIconW, -1)

	-- Create bg_icon_h
	local bg_icon_h = GUI:Image_Create(panel_bg, "bg_icon_h", 248.00, 45.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_icon_h, 0, 0, 0, 0)
	GUI:setContentSize(bg_icon_h, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_icon_h, false)
	GUI:setAnchorPoint(bg_icon_h, 0.00, 0.50)
	GUI:setTouchEnabled(bg_icon_h, false)
	GUI:setTag(bg_icon_h, -1)

	-- Create icon_h_prefix
	local icon_h_prefix = GUI:Text_Create(bg_icon_h, "icon_h_prefix", -90.00, 13.00, 14, "#ffffff", [[统一图标高度]])
	GUI:setAnchorPoint(icon_h_prefix, 0.00, 0.50)
	GUI:setTouchEnabled(icon_h_prefix, false)
	GUI:setTag(icon_h_prefix, -1)
	GUI:Text_enableOutline(icon_h_prefix, "#000000", 1)

	-- Create InputIconH
	local InputIconH = GUI:TextInput_Create(bg_icon_h, "InputIconH", 0.00, 0.00, 50.00, 25.00, 14)
	GUI:TextInput_setString(InputIconH, "")
	GUI:TextInput_setFontColor(InputIconH, "#ffffff")
	GUI:setTouchEnabled(InputIconH, true)
	GUI:setTag(InputIconH, -1)

	-- Create Layout_hide_pullDownList
	local Layout_hide_pullDownList = GUI:Layout_Create(panel_bg, "Layout_hide_pullDownList", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(Layout_hide_pullDownList, true)
	GUI:setTag(Layout_hide_pullDownList, -1)
	GUI:setVisible(Layout_hide_pullDownList, false)

	-- Create Image_pulldown_bg
	local Image_pulldown_bg = GUI:Image_Create(panel_bg, "Image_pulldown_bg", 81.00, 316.00, "res/public/1900000677.png")
	GUI:Image_setScale9Slice(Image_pulldown_bg, 22, 21, 33, 34)
	GUI:setContentSize(Image_pulldown_bg, 100, 200)
	GUI:setIgnoreContentAdaptWithSize(Image_pulldown_bg, false)
	GUI:setAnchorPoint(Image_pulldown_bg, 0.50, 1.00)
	GUI:setTouchEnabled(Image_pulldown_bg, false)
	GUI:setTag(Image_pulldown_bg, -1)
	GUI:setVisible(Image_pulldown_bg, false)

	-- Create ListView_pulldown
	local ListView_pulldown = GUI:ListView_Create(Image_pulldown_bg, "ListView_pulldown", 50.00, 199.00, 98.00, 198.00, 1)
	GUI:ListView_setGravity(ListView_pulldown, 5)
	GUI:setAnchorPoint(ListView_pulldown, 0.50, 1.00)
	GUI:setTouchEnabled(ListView_pulldown, true)
	GUI:setTag(ListView_pulldown, -1)

	-- Create bg_dir_fold
	local bg_dir_fold = GUI:Image_Create(panel_bg, "bg_dir_fold", 144.00, 2.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_dir_fold, 73, 74, 13, 14)
	GUI:setContentSize(bg_dir_fold, 100, 28)
	GUI:setIgnoreContentAdaptWithSize(bg_dir_fold, false)
	GUI:setAnchorPoint(bg_dir_fold, 0.50, 0.00)
	GUI:setTouchEnabled(bg_dir_fold, true)
	GUI:setTag(bg_dir_fold, -1)

	-- Create fold_dir_prefix
	local fold_dir_prefix = GUI:Text_Create(bg_dir_fold, "fold_dir_prefix", -3.00, 13.00, 14, "#ffffff", [[按钮收缩方向]])
	GUI:setAnchorPoint(fold_dir_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(fold_dir_prefix, false)
	GUI:setTag(fold_dir_prefix, -1)
	GUI:Text_enableOutline(fold_dir_prefix, "#000000", 1)

	-- Create Text_dir_fold
	local Text_dir_fold = GUI:Text_Create(bg_dir_fold, "Text_dir_fold", 5.00, 14.00, 14, "#ffffff", [[不需要]])
	GUI:setAnchorPoint(Text_dir_fold, 0.00, 0.50)
	GUI:setTouchEnabled(Text_dir_fold, false)
	GUI:setTag(Text_dir_fold, -1)
	GUI:Text_enableOutline(Text_dir_fold, "#000000", 1)

	-- Create arrow_dir_fold
	local arrow_dir_fold = GUI:Image_Create(bg_dir_fold, "arrow_dir_fold", 87.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow_dir_fold, 0.50, 0.50)
	GUI:setTouchEnabled(arrow_dir_fold, false)
	GUI:setTag(arrow_dir_fold, -1)
end
return ui