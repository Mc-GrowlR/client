local ui = {}
function ui.init(parent)
	-- Create Layer
	local Layer = GUI:Node_Create(parent, "Layer", 0.00, 0.00)
	GUI:setAnchorPoint(Layer, 0.50, 0.50)
	GUI:setTag(Layer, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Layer, "Panel_1", 0.00, 0.00, 936.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_1, 1)
	GUI:Layout_setBackGroundColor(Panel_1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_1, 102)
	GUI:setTouchEnabled(Panel_1, false)
	GUI:setTag(Panel_1, 4)

	-- Create Layout_page
	local Layout_page = GUI:Layout_Create(Panel_1, "Layout_page", 4.00, 23.00, 100.00, 616.00, false)
	GUI:Layout_setBackGroundColorType(Layout_page, 1)
	GUI:Layout_setBackGroundColor(Layout_page, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_page, 127)
	GUI:setTouchEnabled(Layout_page, false)
	GUI:setTag(Layout_page, -1)

	-- Create ListView_page
	local ListView_page = GUI:ListView_Create(Layout_page, "ListView_page", 0.00, 0.00, 100.00, 615.00, 1)
	GUI:ListView_setGravity(ListView_page, 2)
	GUI:ListView_setItemsMargin(ListView_page, 3)
	GUI:setTouchEnabled(ListView_page, true)
	GUI:setTag(ListView_page, -1)

	-- Create Layout_result
	local Layout_result = GUI:Layout_Create(Panel_1, "Layout_result", 108.00, 23.00, 300.00, 616.00, false)
	GUI:Layout_setBackGroundColorType(Layout_result, 1)
	GUI:Layout_setBackGroundColor(Layout_result, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_result, 158)
	GUI:setTouchEnabled(Layout_result, false)
	GUI:setTag(Layout_result, -1)

	-- Create ListView_items
	local ListView_items = GUI:ListView_Create(Layout_result, "ListView_items", 1.00, 0.00, 300.00, 615.00, 1)
	GUI:ListView_setGravity(ListView_items, 2)
	GUI:ListView_setItemsMargin(ListView_items, 3)
	GUI:setTouchEnabled(ListView_items, true)
	GUI:setTag(ListView_items, -1)

	-- Create panel_item
	local panel_item = GUI:Layout_Create(Layout_result, "panel_item", 0.00, 0.00, 300.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(panel_item, 1)
	GUI:Layout_setBackGroundColor(panel_item, "#96c8ff")
	GUI:Layout_setBackGroundColorOpacity(panel_item, 140)
	GUI:setTouchEnabled(panel_item, true)
	GUI:setTag(panel_item, -1)
	GUI:setVisible(panel_item, false)

	-- Create id
	local id = GUI:Text_Create(panel_item, "id", 5.00, 15.00, 14, "#ffffff", [[文本]])
	GUI:setAnchorPoint(id, 0.00, 0.50)
	GUI:setTouchEnabled(id, false)
	GUI:setTag(id, -1)
	GUI:Text_enableOutline(id, "#000000", 1)

	-- Create name
	local name = GUI:Text_Create(panel_item, "name", 170.00, 15.00, 14, "#ffffff", [[文本]])
	GUI:setAnchorPoint(name, 0.50, 0.50)
	GUI:setTouchEnabled(name, false)
	GUI:setTag(name, -1)
	GUI:Text_enableOutline(name, "#000000", 1)

	-- Create Layout_content
	local Layout_content = GUI:Layout_Create(Panel_1, "Layout_content", 412.00, 24.00, 520.00, 616.00, false)
	GUI:Layout_setBackGroundColorType(Layout_content, 1)
	GUI:Layout_setBackGroundColor(Layout_content, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_content, 160)
	GUI:setTouchEnabled(Layout_content, false)
	GUI:setTag(Layout_content, -1)

	-- Create btn_sure
	local btn_sure = GUI:Layout_Create(Layout_content, "btn_sure", 473.00, 3.00, 80.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_sure, 1)
	GUI:Layout_setBackGroundColor(btn_sure, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_sure, 255)
	GUI:setAnchorPoint(btn_sure, 0.50, 0.00)
	GUI:setTouchEnabled(btn_sure, true)
	GUI:setTag(btn_sure, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_sure, "Text", 40.00, 13.00, 16, "#ffffff", [[保  存]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create bg_input_name
	local bg_input_name = GUI:Image_Create(Layout_content, "bg_input_name", 48.00, 554.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_name, 73, 74, 13, 14)
	GUI:setContentSize(bg_input_name, 250, 50)
	GUI:setIgnoreContentAdaptWithSize(bg_input_name, false)
	GUI:setTouchEnabled(bg_input_name, false)
	GUI:setTag(bg_input_name, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_name, "Text", 0.00, 22.00, 14, "#ffffff", [[标题：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_name
	local input_name = GUI:TextInput_Create(bg_input_name, "input_name", 0.00, 1.00, 246.00, 48.00, 16)
	GUI:TextInput_setString(input_name, "")
	GUI:TextInput_setFontColor(input_name, "#ffffff")
	GUI:setTouchEnabled(input_name, true)
	GUI:setTag(input_name, -1)

	-- Create bg_platform
	local bg_platform = GUI:Layout_Create(Layout_content, "bg_platform", 418.00, 565.00, 85.00, 28.00, false)
	GUI:Layout_setBackGroundImage(bg_platform, "res/public/1900015004.png")
	GUI:Layout_setBackGroundImageScale9Slice(bg_platform, 73, 74, 13, 14)
	GUI:setAnchorPoint(bg_platform, 0.50, 0.00)
	GUI:setTouchEnabled(bg_platform, true)
	GUI:setTag(bg_platform, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_platform, "Text", 0.00, 14.00, 14, "#ffffff", [[显示设备：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_platform
	local Text_platform = GUI:Text_Create(bg_platform, "Text_platform", 33.00, 14.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_platform, 0.50, 0.50)
	GUI:setTouchEnabled(Text_platform, false)
	GUI:setTag(Text_platform, -1)
	GUI:Text_enableOutline(Text_platform, "#000000", 1)

	-- Create arrow_platform
	local arrow_platform = GUI:Image_Create(bg_platform, "arrow_platform", 75.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow_platform, 0.50, 0.50)
	GUI:setTouchEnabled(arrow_platform, false)
	GUI:setTag(arrow_platform, -1)

	-- Create bg_input_desc
	local bg_input_desc = GUI:Image_Create(Layout_content, "bg_input_desc", 2.00, 474.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_desc, 73, 74, 13, 14)
	GUI:setContentSize(bg_input_desc, 516, 50)
	GUI:setIgnoreContentAdaptWithSize(bg_input_desc, false)
	GUI:setTouchEnabled(bg_input_desc, false)
	GUI:setTag(bg_input_desc, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_desc, "Text", 3.00, 53.00, 14, "#ffffff", [[备注说明：]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_desc
	local input_desc = GUI:TextInput_Create(bg_input_desc, "input_desc", 0.00, 1.00, 512.00, 48.00, 16)
	GUI:TextInput_setString(input_desc, "")
	GUI:TextInput_setFontColor(input_desc, "#ffffff")
	GUI:setTouchEnabled(input_desc, true)
	GUI:setTag(input_desc, -1)

	-- Create Node_desc
	local Node_desc = GUI:Node_Create(bg_input_desc, "Node_desc", 70.00, 53.00)
	GUI:setTag(Node_desc, -1)

	-- Create line3
	local line3 = GUI:Layout_Create(Layout_content, "line3", 0.00, 297.00, 520.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line3, 1)
	GUI:Layout_setBackGroundColor(line3, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line3, 255)
	GUI:setAnchorPoint(line3, 0.00, 1.00)
	GUI:setTouchEnabled(line3, false)
	GUI:setTag(line3, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_content, "Text", 10.00, 237.00, 14, "#ffffff", [[主界面显示开启图标配置]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_reset_open
	local btn_reset_open = GUI:Layout_Create(Layout_content, "btn_reset_open", 210.00, 237.00, 72.00, 20.00, false)
	GUI:Layout_setBackGroundColorType(btn_reset_open, 1)
	GUI:Layout_setBackGroundColor(btn_reset_open, "#315284")
	GUI:Layout_setBackGroundColorOpacity(btn_reset_open, 255)
	GUI:setAnchorPoint(btn_reset_open, 0.50, 0.00)
	GUI:setTouchEnabled(btn_reset_open, true)
	GUI:setTag(btn_reset_open, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_reset_open, "Text", 36.00, 10.00, 14, "#ffffff", [[清除配置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_res_open
	local btn_res_open = GUI:Layout_Create(Layout_content, "btn_res_open", 73.00, 200.00, 70.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_res_open, 1)
	GUI:Layout_setBackGroundColor(btn_res_open, "#96c8c8")
	GUI:Layout_setBackGroundColorOpacity(btn_res_open, 178)
	GUI:setTouchEnabled(btn_res_open, true)
	GUI:setTag(btn_res_open, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_res_open, "Text", 35.00, 13.00, 15, "#00ffff", [[选择文件]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_res_tip
	local Text_res_tip = GUI:Text_Create(Layout_content, "Text_res_tip", 220.00, 231.00, 14, "#808080", [[默认读取路径为res/private/new_setting/icon
请将需要的图标放入该目录中]])
	GUI:setAnchorPoint(Text_res_tip, 0.00, 1.00)
	GUI:setTouchEnabled(Text_res_tip, false)
	GUI:setTag(Text_res_tip, -1)
	GUI:Text_enableOutline(Text_res_tip, "#000000", 2)

	-- Create img_res_open
	local img_res_open = GUI:Image_Create(Layout_content, "img_res_open", 181.00, 212.00, "res/private/gui_edit/ImageFile.png")
	GUI:setAnchorPoint(img_res_open, 0.50, 0.50)
	GUI:setTouchEnabled(img_res_open, false)
	GUI:setTag(img_res_open, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Layout_content, "Text_1", 10.00, 206.00, 14, "#ffffff", [[开启图标]])
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create bg_open
	local bg_open = GUI:Layout_Create(Layout_content, "bg_open", 122.00, 180.00, 85.00, 28.00, false)
	GUI:Layout_setBackGroundImage(bg_open, "res/public/1900015004.png")
	GUI:Layout_setBackGroundImageScale9Slice(bg_open, 0, 0, 0, 0)
	GUI:setAnchorPoint(bg_open, 0.50, 1.00)
	GUI:setTouchEnabled(bg_open, true)
	GUI:setTag(bg_open, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_open, "Text", 0.00, 14.00, 14, "#ffffff", [[显示位置：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_open
	local Text_open = GUI:Text_Create(bg_open, "Text_open", 33.00, 14.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_open, 0.50, 0.50)
	GUI:setTouchEnabled(Text_open, false)
	GUI:setTag(Text_open, -1)
	GUI:Text_enableOutline(Text_open, "#000000", 1)

	-- Create arrow_open
	local arrow_open = GUI:Image_Create(bg_open, "arrow_open", 75.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow_open, 0.50, 0.50)
	GUI:setRotation(arrow_open, 180.00)
	GUI:setRotationSkewX(arrow_open, 180.00)
	GUI:setRotationSkewY(arrow_open, 180.00)
	GUI:setTouchEnabled(arrow_open, false)
	GUI:setTag(arrow_open, -1)

	-- Create bg_input_open_x
	local bg_input_open_x = GUI:Image_Create(Layout_content, "bg_input_open_x", 264.00, 152.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_open_x, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_open_x, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_open_x, false)
	GUI:setTouchEnabled(bg_input_open_x, false)
	GUI:setTag(bg_input_open_x, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_open_x, "Text", 0.00, 13.00, 14, "#ffffff", [[X坐标偏移：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_open_x
	local input_open_x = GUI:TextInput_Create(bg_input_open_x, "input_open_x", 0.00, 1.00, 76.00, 25.00, 16)
	GUI:TextInput_setString(input_open_x, "")
	GUI:TextInput_setFontColor(input_open_x, "#ffffff")
	GUI:setTouchEnabled(input_open_x, true)
	GUI:setTag(input_open_x, -1)

	-- Create bg_input_open_y
	local bg_input_open_y = GUI:Image_Create(Layout_content, "bg_input_open_y", 430.00, 152.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_open_y, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_open_y, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_open_y, false)
	GUI:setTouchEnabled(bg_input_open_y, false)
	GUI:setTag(bg_input_open_y, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_open_y, "Text", 0.00, 13.00, 14, "#ffffff", [[Y坐标偏移：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_open_y
	local input_open_y = GUI:TextInput_Create(bg_input_open_y, "input_open_y", 0.00, 1.00, 76.00, 25.00, 16)
	GUI:TextInput_setString(input_open_y, "")
	GUI:TextInput_setFontColor(input_open_y, "#ffffff")
	GUI:setTouchEnabled(input_open_y, true)
	GUI:setTag(input_open_y, -1)

	-- Create line3_1
	local line3_1 = GUI:Layout_Create(Layout_content, "line3_1", 0.00, 145.00, 520.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line3_1, 1)
	GUI:Layout_setBackGroundColor(line3_1, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line3_1, 255)
	GUI:setAnchorPoint(line3_1, 0.00, 1.00)
	GUI:setTouchEnabled(line3_1, false)
	GUI:setTag(line3_1, -1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Layout_content, "Text_2", 9.00, 122.00, 14, "#ffffff", [[主界面显示关闭图标配置]])
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, -1)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create btn_reset_close
	local btn_reset_close = GUI:Layout_Create(Layout_content, "btn_reset_close", 210.00, 122.00, 72.00, 20.00, false)
	GUI:Layout_setBackGroundColorType(btn_reset_close, 1)
	GUI:Layout_setBackGroundColor(btn_reset_close, "#315284")
	GUI:Layout_setBackGroundColorOpacity(btn_reset_close, 255)
	GUI:setAnchorPoint(btn_reset_close, 0.50, 0.00)
	GUI:setTouchEnabled(btn_reset_close, true)
	GUI:setTag(btn_reset_close, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_reset_close, "Text", 36.00, 10.00, 14, "#ffffff", [[清除配置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_1_1
	local Text_1_1 = GUI:Text_Create(Layout_content, "Text_1_1", 11.00, 90.00, 14, "#ffffff", [[关闭图标]])
	GUI:setTouchEnabled(Text_1_1, false)
	GUI:setTag(Text_1_1, -1)
	GUI:Text_enableOutline(Text_1_1, "#000000", 1)

	-- Create btn_res_close
	local btn_res_close = GUI:Layout_Create(Layout_content, "btn_res_close", 73.00, 85.00, 70.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_res_close, 1)
	GUI:Layout_setBackGroundColor(btn_res_close, "#96c8c8")
	GUI:Layout_setBackGroundColorOpacity(btn_res_close, 178)
	GUI:setTouchEnabled(btn_res_close, true)
	GUI:setTag(btn_res_close, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_res_close, "Text", 35.00, 13.00, 15, "#00ffff", [[选择文件]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create img_res_close
	local img_res_close = GUI:Image_Create(Layout_content, "img_res_close", 180.00, 97.00, "res/private/gui_edit/ImageFile.png")
	GUI:setAnchorPoint(img_res_close, 0.50, 0.50)
	GUI:setTouchEnabled(img_res_close, false)
	GUI:setTag(img_res_close, -1)

	-- Create Text_res_tip_1
	local Text_res_tip_1 = GUI:Text_Create(Layout_content, "Text_res_tip_1", 220.00, 116.00, 14, "#808080", [[默认读取路径为res/private/new_setting/icon
请将需要的图标放入该目录中]])
	GUI:setAnchorPoint(Text_res_tip_1, 0.00, 1.00)
	GUI:setTouchEnabled(Text_res_tip_1, false)
	GUI:setTag(Text_res_tip_1, -1)
	GUI:Text_enableOutline(Text_res_tip_1, "#000000", 2)

	-- Create bg_close
	local bg_close = GUI:Layout_Create(Layout_content, "bg_close", 119.00, 68.00, 85.00, 28.00, false)
	GUI:Layout_setBackGroundImage(bg_close, "res/public/1900015004.png")
	GUI:Layout_setBackGroundImageScale9Slice(bg_close, 0, 0, 0, 0)
	GUI:setAnchorPoint(bg_close, 0.50, 1.00)
	GUI:setTouchEnabled(bg_close, true)
	GUI:setTag(bg_close, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_close, "Text", 0.00, 14.00, 14, "#ffffff", [[显示位置：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_close
	local Text_close = GUI:Text_Create(bg_close, "Text_close", 33.00, 14.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_close, 0.50, 0.50)
	GUI:setTouchEnabled(Text_close, false)
	GUI:setTag(Text_close, -1)
	GUI:Text_enableOutline(Text_close, "#000000", 1)

	-- Create arrow_close
	local arrow_close = GUI:Image_Create(bg_close, "arrow_close", 75.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow_close, 0.50, 0.50)
	GUI:setRotation(arrow_close, 180.00)
	GUI:setRotationSkewX(arrow_close, 180.00)
	GUI:setRotationSkewY(arrow_close, 180.00)
	GUI:setTouchEnabled(arrow_close, false)
	GUI:setTag(arrow_close, -1)

	-- Create bg_input_close_x
	local bg_input_close_x = GUI:Image_Create(Layout_content, "bg_input_close_x", 264.00, 40.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_close_x, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_close_x, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_close_x, false)
	GUI:setTouchEnabled(bg_input_close_x, false)
	GUI:setTag(bg_input_close_x, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_close_x, "Text", 0.00, 13.00, 14, "#ffffff", [[X坐标偏移：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_close_x
	local input_close_x = GUI:TextInput_Create(bg_input_close_x, "input_close_x", 0.00, 1.00, 76.00, 25.00, 16)
	GUI:TextInput_setString(input_close_x, "")
	GUI:TextInput_setFontColor(input_close_x, "#ffffff")
	GUI:setTouchEnabled(input_close_x, true)
	GUI:setTag(input_close_x, -1)

	-- Create bg_input_close_y
	local bg_input_close_y = GUI:Image_Create(Layout_content, "bg_input_close_y", 430.00, 40.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_close_y, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_close_y, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_close_y, false)
	GUI:setTouchEnabled(bg_input_close_y, false)
	GUI:setTag(bg_input_close_y, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_close_y, "Text", 0.00, 13.00, 14, "#ffffff", [[Y坐标偏移：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_close_y
	local input_close_y = GUI:TextInput_Create(bg_input_close_y, "input_close_y", 0.00, 1.00, 76.00, 25.00, 16)
	GUI:TextInput_setString(input_close_y, "")
	GUI:TextInput_setFontColor(input_close_y, "#ffffff")
	GUI:setTouchEnabled(input_close_y, true)
	GUI:setTag(input_close_y, -1)

	-- Create Node_attach
	local Node_attach = GUI:Node_Create(Layout_content, "Node_attach", 0.00, 300.00)
	GUI:setTag(Node_attach, -1)

	-- Create line3_1_1
	local line3_1_1 = GUI:Layout_Create(Layout_content, "line3_1_1", 0.00, 505.00, 520.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line3_1_1, 1)
	GUI:Layout_setBackGroundColor(line3_1_1, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line3_1_1, 255)
	GUI:setAnchorPoint(line3_1_1, 0.00, 1.00)
	GUI:setTouchEnabled(line3_1_1, false)
	GUI:setTag(line3_1_1, -1)
	GUI:setVisible(line3_1_1, false)

	-- Create line3_1_1_1
	local line3_1_1_1 = GUI:Layout_Create(Layout_content, "line3_1_1_1", 0.00, 35.00, 520.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line3_1_1_1, 1)
	GUI:Layout_setBackGroundColor(line3_1_1_1, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line3_1_1_1, 255)
	GUI:setAnchorPoint(line3_1_1_1, 0.00, 1.00)
	GUI:setTouchEnabled(line3_1_1_1, false)
	GUI:setTag(line3_1_1_1, -1)

	-- Create Layout_mobile
	local Layout_mobile = GUI:Layout_Create(Layout_content, "Layout_mobile", 0.00, 290.00, 172.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(Layout_mobile, 1)
	GUI:Layout_setBackGroundColor(Layout_mobile, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_mobile, 178)
	GUI:setAnchorPoint(Layout_mobile, 0.00, 1.00)
	GUI:setTouchEnabled(Layout_mobile, true)
	GUI:setTag(Layout_mobile, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_mobile, "Text", 86.00, 15.00, 16, "#ffffff", [[移动端主界面显示图标]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_pc
	local Layout_pc = GUI:Layout_Create(Layout_content, "Layout_pc", 259.00, 290.00, 172.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(Layout_pc, 1)
	GUI:Layout_setBackGroundColor(Layout_pc, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_pc, 178)
	GUI:setAnchorPoint(Layout_pc, 0.50, 1.00)
	GUI:setTouchEnabled(Layout_pc, true)
	GUI:setTag(Layout_pc, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_pc, "Text", 86.00, 15.00, 16, "#ffffff", [[电脑端主界面显示图标]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_show
	local Layout_show = GUI:Layout_Create(Layout_content, "Layout_show", 432.00, 290.00, 172.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(Layout_show, 1)
	GUI:Layout_setBackGroundColor(Layout_show, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_show, 178)
	GUI:setAnchorPoint(Layout_show, 0.50, 1.00)
	GUI:setTouchEnabled(Layout_show, true)
	GUI:setTag(Layout_show, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_show, "Text", 86.00, 15.00, 16, "#ffffff", [[主界面图标显示控制]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create LayoutShowControl
	local LayoutShowControl = GUI:Layout_Create(Layout_content, "LayoutShowControl", 0.00, 36.00, 520.00, 222.00, false)
	GUI:Layout_setBackGroundColorType(LayoutShowControl, 1)
	GUI:Layout_setBackGroundColor(LayoutShowControl, "#000000")
	GUI:Layout_setBackGroundColorOpacity(LayoutShowControl, 255)
	GUI:setTouchEnabled(LayoutShowControl, true)
	GUI:setTag(LayoutShowControl, -1)

	-- Create LayoutControl0
	local LayoutControl0 = GUI:Layout_Create(LayoutShowControl, "LayoutControl0", 30.00, 180.00, 150.00, 30.00, false)
	GUI:setTouchEnabled(LayoutControl0, true)
	GUI:setTag(LayoutControl0, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(LayoutControl0, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(LayoutControl0, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(LayoutControl0, "Text", 43.00, 15.00, 16, "#ffffff", [[仅战士显示]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create LayoutControl1
	local LayoutControl1 = GUI:Layout_Create(LayoutShowControl, "LayoutControl1", 30.00, 149.00, 150.00, 30.00, false)
	GUI:setTouchEnabled(LayoutControl1, true)
	GUI:setTag(LayoutControl1, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(LayoutControl1, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(LayoutControl1, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(LayoutControl1, "Text", 43.00, 15.00, 16, "#ffffff", [[仅法师显示]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create LayoutControl2
	local LayoutControl2 = GUI:Layout_Create(LayoutShowControl, "LayoutControl2", 30.00, 115.00, 150.00, 30.00, false)
	GUI:setTouchEnabled(LayoutControl2, true)
	GUI:setTag(LayoutControl2, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(LayoutControl2, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(LayoutControl2, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(LayoutControl2, "Text", 43.00, 15.00, 16, "#ffffff", [[仅道士显示]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create LayoutControl3
	local LayoutControl3 = GUI:Layout_Create(LayoutShowControl, "LayoutControl3", 30.00, 82.00, 150.00, 30.00, false)
	GUI:setTouchEnabled(LayoutControl3, true)
	GUI:setTag(LayoutControl3, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(LayoutControl3, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(LayoutControl3, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(LayoutControl3, "Text", 43.00, 15.00, 16, "#ffffff", [[不限制职业]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_hide_pullDownList
	local Layout_hide_pullDownList = GUI:Layout_Create(Layout_content, "Layout_hide_pullDownList", -412.00, -24.00, 936.00, 640.00, false)
	GUI:setTouchEnabled(Layout_hide_pullDownList, true)
	GUI:setTag(Layout_hide_pullDownList, -1)
	GUI:setVisible(Layout_hide_pullDownList, false)

	-- Create Image_pulldown_bg
	local Image_pulldown_bg = GUI:Image_Create(Layout_content, "Image_pulldown_bg", 118.00, 69.00, "res/public/1900000677.png")
	GUI:Image_setScale9Slice(Image_pulldown_bg, 22, 21, 33, 34)
	GUI:setContentSize(Image_pulldown_bg, 86, 200)
	GUI:setIgnoreContentAdaptWithSize(Image_pulldown_bg, false)
	GUI:setAnchorPoint(Image_pulldown_bg, 0.50, 0.00)
	GUI:setTouchEnabled(Image_pulldown_bg, false)
	GUI:setTag(Image_pulldown_bg, -1)
	GUI:setVisible(Image_pulldown_bg, false)

	-- Create ListView_pulldown
	local ListView_pulldown = GUI:ListView_Create(Image_pulldown_bg, "ListView_pulldown", 43.00, 197.00, 80.00, 194.00, 1)
	GUI:ListView_setGravity(ListView_pulldown, 2)
	GUI:setAnchorPoint(ListView_pulldown, 0.50, 1.00)
	GUI:setTouchEnabled(ListView_pulldown, true)
	GUI:setTag(ListView_pulldown, -1)

	-- Create Text_notice
	local Text_notice = GUI:Text_Create(Layout_content, "Text_notice", 140.00, 5.00, 18, "#00fb00", [[每次修改数据 记得点击保存]])
	GUI:setTouchEnabled(Text_notice, false)
	GUI:setTag(Text_notice, -1)
	GUI:Text_enableOutline(Text_notice, "#000000", 1)
end
return ui