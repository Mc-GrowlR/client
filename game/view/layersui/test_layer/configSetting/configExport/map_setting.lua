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
	local Layout_page = GUI:Layout_Create(Panel_1, "Layout_page", 4.00, 23.00, 200.00, 616.00, false)
	GUI:Layout_setBackGroundColorType(Layout_page, 1)
	GUI:Layout_setBackGroundColor(Layout_page, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_page, 127)
	GUI:setTouchEnabled(Layout_page, false)
	GUI:setTag(Layout_page, -1)

	-- Create ListView_page
	local ListView_page = GUI:ListView_Create(Layout_page, "ListView_page", 1.00, 82.00, 200.00, 535.00, 1)
	GUI:ListView_setGravity(ListView_page, 2)
	GUI:ListView_setItemsMargin(ListView_page, 3)
	GUI:setTouchEnabled(ListView_page, true)
	GUI:setTag(ListView_page, -1)

	-- Create btn_add
	local btn_add = GUI:Layout_Create(Layout_page, "btn_add", 104.00, 44.00, 90.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_add, 1)
	GUI:Layout_setBackGroundColor(btn_add, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_add, 255)
	GUI:setTouchEnabled(btn_add, true)
	GUI:setTag(btn_add, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_add, "Text", 45.00, 15.00, 16, "#ffffff", [[新 增]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_copy
	local btn_copy = GUI:Layout_Create(Layout_page, "btn_copy", 56.00, 7.00, 90.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_copy, 1)
	GUI:Layout_setBackGroundColor(btn_copy, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_copy, 255)
	GUI:setTouchEnabled(btn_copy, true)
	GUI:setTag(btn_copy, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_copy, "Text", 45.00, 15.00, 16, "#ffffff", [[复制新增]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_del
	local btn_del = GUI:Layout_Create(Layout_page, "btn_del", 7.00, 44.00, 90.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_del, 1)
	GUI:Layout_setBackGroundColor(btn_del, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_del, 255)
	GUI:setTouchEnabled(btn_del, true)
	GUI:setTag(btn_del, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_del, "Text", 45.00, 15.00, 16, "#ffffff", [[删 除]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create line
	local line = GUI:Layout_Create(Layout_page, "line", 0.00, 80.00, 200.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line, 1)
	GUI:Layout_setBackGroundColor(line, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line, 255)
	GUI:setTouchEnabled(line, false)
	GUI:setTag(line, -1)

	-- Create Layout_page_mask
	local Layout_page_mask = GUI:Layout_Create(Layout_page, "Layout_page_mask", 0.00, 0.00, 200.00, 616.00, false)
	GUI:Layout_setBackGroundColorType(Layout_page_mask, 1)
	GUI:Layout_setBackGroundColor(Layout_page_mask, "#808080")
	GUI:Layout_setBackGroundColorOpacity(Layout_page_mask, 229)
	GUI:setTouchEnabled(Layout_page_mask, true)
	GUI:setTag(Layout_page_mask, -1)
	GUI:setVisible(Layout_page_mask, false)

	-- Create Layout_result
	local Layout_result = GUI:Layout_Create(Panel_1, "Layout_result", 208.00, 23.00, 360.00, 616.00, false)
	GUI:Layout_setBackGroundColorType(Layout_result, 1)
	GUI:Layout_setBackGroundColor(Layout_result, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_result, 158)
	GUI:setTouchEnabled(Layout_result, false)
	GUI:setTag(Layout_result, -1)

	-- Create result_title_bg
	local result_title_bg = GUI:Layout_Create(Layout_result, "result_title_bg", 55.00, 581.00, 90.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(result_title_bg, 1)
	GUI:Layout_setBackGroundColor(result_title_bg, "#000000")
	GUI:Layout_setBackGroundColorOpacity(result_title_bg, 255)
	GUI:setAnchorPoint(result_title_bg, 0.50, 0.00)
	GUI:setTouchEnabled(result_title_bg, false)
	GUI:setTag(result_title_bg, -1)

	-- Create Text
	local Text = GUI:Text_Create(result_title_bg, "Text", 45.00, 15.00, 16, "#ffffff", [[基础配置：]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create result_tip
	local result_tip = GUI:Text_Create(Layout_result, "result_tip", 180.00, 311.00, 14, "#ff0000", [[注：以上两步如果有文件或参数变动请重新选择并保存]])
	GUI:setAnchorPoint(result_tip, 0.50, 0.00)
	GUI:setTouchEnabled(result_tip, false)
	GUI:setTag(result_tip, -1)
	GUI:Text_enableOutline(result_tip, "#000000", 2)

	-- Create tip1
	local tip1 = GUI:Text_Create(Layout_result, "tip1", 11.00, 556.00, 14, "#ffffff", [[第一步：导入服务端envir/MiniMap.txt]])
	GUI:setTouchEnabled(tip1, false)
	GUI:setTag(tip1, -1)
	GUI:Text_enableOutline(tip1, "#000000", 2)

	-- Create tip2
	local tip2 = GUI:Text_Create(Layout_result, "tip2", 11.00, 444.00, 14, "#ffffff", [[第二步：导入服务端envir/MapInfo.txt]])
	GUI:setTouchEnabled(tip2, false)
	GUI:setTag(tip2, -1)
	GUI:Text_enableOutline(tip2, "#000000", 2)

	-- Create bg_input_minimap
	local bg_input_minimap = GUI:Image_Create(Layout_result, "bg_input_minimap", 11.00, 509.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_minimap, 50, 50, 10, 10)
	GUI:setContentSize(bg_input_minimap, 340, 44)
	GUI:setIgnoreContentAdaptWithSize(bg_input_minimap, false)
	GUI:setTouchEnabled(bg_input_minimap, false)
	GUI:setTag(bg_input_minimap, -1)

	-- Create input_minimap
	local input_minimap = GUI:TextInput_Create(bg_input_minimap, "input_minimap", 0.00, 2.00, 332.00, 40.00, 16)
	GUI:TextInput_setString(input_minimap, "")
	GUI:TextInput_setPlaceHolder(input_minimap, "请输入MiniMap全路径")
	GUI:TextInput_setFontColor(input_minimap, "#ffffff")
	GUI:setTouchEnabled(input_minimap, true)
	GUI:setTag(input_minimap, -1)

	-- Create path_minimap
	local path_minimap = GUI:Text_Create(Layout_result, "path_minimap", 11.00, 506.00, 14, "#808080", [[未选择文件]])
	GUI:setAnchorPoint(path_minimap, 0.00, 1.00)
	GUI:setTouchEnabled(path_minimap, false)
	GUI:setTag(path_minimap, -1)
	GUI:Text_enableOutline(path_minimap, "#000000", 1)

	-- Create bg_input_mapinfo
	local bg_input_mapinfo = GUI:Image_Create(Layout_result, "bg_input_mapinfo", 11.00, 398.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_mapinfo, 50, 50, 10, 10)
	GUI:setContentSize(bg_input_mapinfo, 340, 44)
	GUI:setIgnoreContentAdaptWithSize(bg_input_mapinfo, false)
	GUI:setTouchEnabled(bg_input_mapinfo, false)
	GUI:setTag(bg_input_mapinfo, -1)

	-- Create input_mapinfo
	local input_mapinfo = GUI:TextInput_Create(bg_input_mapinfo, "input_mapinfo", 0.00, 2.00, 332.00, 40.00, 16)
	GUI:TextInput_setString(input_mapinfo, "")
	GUI:TextInput_setPlaceHolder(input_mapinfo, "请输入MapInfo全路径")
	GUI:TextInput_setFontColor(input_mapinfo, "#ffffff")
	GUI:setTouchEnabled(input_mapinfo, true)
	GUI:setTag(input_mapinfo, -1)

	-- Create path_mapinfo
	local path_mapinfo = GUI:Text_Create(Layout_result, "path_mapinfo", 11.00, 395.00, 14, "#808080", [[未选择文件]])
	GUI:setAnchorPoint(path_mapinfo, 0.00, 1.00)
	GUI:setTouchEnabled(path_mapinfo, false)
	GUI:setTag(path_mapinfo, -1)
	GUI:Text_enableOutline(path_mapinfo, "#000000", 1)

	-- Create btn_save_path
	local btn_save_path = GUI:Layout_Create(Layout_result, "btn_save_path", 319.00, 335.00, 60.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_save_path, 1)
	GUI:Layout_setBackGroundColor(btn_save_path, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_save_path, 255)
	GUI:setAnchorPoint(btn_save_path, 0.50, 0.00)
	GUI:setTouchEnabled(btn_save_path, true)
	GUI:setTag(btn_save_path, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_save_path, "Text", 30.00, 13.00, 16, "#ffffff", [[保  存]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create line1
	local line1 = GUI:Layout_Create(Layout_result, "line1", 0.00, 305.00, 360.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line1, 1)
	GUI:Layout_setBackGroundColor(line1, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line1, 255)
	GUI:setAnchorPoint(line1, 0.00, 1.00)
	GUI:setTouchEnabled(line1, false)
	GUI:setTag(line1, -1)

	-- Create Layout_minimap
	local Layout_minimap = GUI:Layout_Create(Layout_result, "Layout_minimap", 0.00, 4.00, 360.00, 270.00, true)
	GUI:setTouchEnabled(Layout_minimap, false)
	GUI:setTag(Layout_minimap, -1)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Layout_minimap, "Image_bg", 180.00, 135.00, "res/private/minimap/1900012103.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setScaleX(Image_bg, 0.54)
	GUI:setScaleY(Image_bg, 0.54)
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, -1)

	-- Create Panel_minimap
	local Panel_minimap = GUI:Layout_Create(Layout_minimap, "Panel_minimap", 180.00, 135.00, 360.00, 270.00, false)
	GUI:setAnchorPoint(Panel_minimap, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_minimap, false)
	GUI:setTag(Panel_minimap, -1)

	-- Create Image_mini_map
	local Image_mini_map = GUI:Image_Create(Panel_minimap, "Image_mini_map", 180.00, 135.00, "res/private/gui_edit/ImageFile.png")
	GUI:setAnchorPoint(Image_mini_map, 0.50, 0.50)
	GUI:setTouchEnabled(Image_mini_map, false)
	GUI:setTag(Image_mini_map, -1)

	-- Create Image_clip
	local Image_clip = GUI:Image_Create(Panel_minimap, "Image_clip", 180.00, 135.00, "res/private/minimap/1900012104.png")
	GUI:setAnchorPoint(Image_clip, 0.50, 0.50)
	GUI:setScaleX(Image_clip, 0.54)
	GUI:setScaleY(Image_clip, 0.54)
	GUI:setTouchEnabled(Image_clip, false)
	GUI:setTag(Image_clip, -1)

	-- Create Node_port
	local Node_port = GUI:Node_Create(Panel_minimap, "Node_port", 50.00, 50.00)
	GUI:setTag(Node_port, -1)

	-- Create icon
	local icon = GUI:Image_Create(Node_port, "icon", 0.00, 0.00, "res/private/minimap/icon_xdtzy_04.png")
	GUI:setAnchorPoint(icon, 0.50, 0.50)
	GUI:setTouchEnabled(icon, false)
	GUI:setTag(icon, -1)

	-- Create nameBG
	local nameBG = GUI:Image_Create(Node_port, "nameBG", 0.00, 13.00, "res/private/minimap/icon_xdtzy_06.png")
	GUI:setContentSize(nameBG, 60, 16)
	GUI:setIgnoreContentAdaptWithSize(nameBG, false)
	GUI:setAnchorPoint(nameBG, 0.50, 0.50)
	GUI:setTouchEnabled(nameBG, false)
	GUI:setTag(nameBG, -1)

	-- Create textName
	local textName = GUI:Text_Create(Node_port, "textName", 0.00, 13.00, 14, "#ffffff", [[文本]])
	GUI:setAnchorPoint(textName, 0.50, 0.50)
	GUI:setTouchEnabled(textName, false)
	GUI:setTag(textName, -1)
	GUI:Text_enableOutline(textName, "#000000", 1)

	-- Create Image_mapNameBG
	local Image_mapNameBG = GUI:Image_Create(Layout_result, "Image_mapNameBG", 80.00, 301.00, "res/private/minimap/1900012107.png")
	GUI:setContentSize(Image_mapNameBG, 150, 25)
	GUI:setIgnoreContentAdaptWithSize(Image_mapNameBG, false)
	GUI:setAnchorPoint(Image_mapNameBG, 0.50, 1.00)
	GUI:setTouchEnabled(Image_mapNameBG, false)
	GUI:setTag(Image_mapNameBG, -1)

	-- Create Text_mapName
	local Text_mapName = GUI:Text_Create(Layout_result, "Text_mapName", 80.00, 297.00, 16, "#00ff00", [[]])
	GUI:setAnchorPoint(Text_mapName, 0.50, 1.00)
	GUI:setTouchEnabled(Text_mapName, false)
	GUI:setTag(Text_mapName, -1)
	GUI:Text_enableOutline(Text_mapName, "#000000", 1)

	-- Create Text_mapSize
	local Text_mapSize = GUI:Text_Create(Layout_result, "Text_mapSize", 358.00, 297.00, 14, "#00ff00", [[]])
	GUI:setAnchorPoint(Text_mapSize, 1.00, 1.00)
	GUI:setTouchEnabled(Text_mapSize, false)
	GUI:setTag(Text_mapSize, -1)
	GUI:Text_enableOutline(Text_mapSize, "#000000", 1)

	-- Create Layout_result_mask
	local Layout_result_mask = GUI:Layout_Create(Layout_result, "Layout_result_mask", 0.00, 0.00, 360.00, 306.00, false)
	GUI:Layout_setBackGroundColorType(Layout_result_mask, 1)
	GUI:Layout_setBackGroundColor(Layout_result_mask, "#808080")
	GUI:Layout_setBackGroundColorOpacity(Layout_result_mask, 229)
	GUI:setTouchEnabled(Layout_result_mask, true)
	GUI:setTag(Layout_result_mask, -1)
	GUI:setVisible(Layout_result_mask, false)

	-- Create Layout_content
	local Layout_content = GUI:Layout_Create(Panel_1, "Layout_content", 572.00, 24.00, 360.00, 616.00, false)
	GUI:Layout_setBackGroundColorType(Layout_content, 1)
	GUI:Layout_setBackGroundColor(Layout_content, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_content, 160)
	GUI:setTouchEnabled(Layout_content, false)
	GUI:setTag(Layout_content, -1)

	-- Create btn_sure
	local btn_sure = GUI:Layout_Create(Layout_content, "btn_sure", 302.00, 3.00, 90.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_sure, 1)
	GUI:Layout_setBackGroundColor(btn_sure, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_sure, 255)
	GUI:setAnchorPoint(btn_sure, 0.50, 0.00)
	GUI:setTouchEnabled(btn_sure, true)
	GUI:setTag(btn_sure, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_sure, "Text", 45.00, 15.00, 16, "#ffffff", [[保  存]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create bg_input_desc
	local bg_input_desc = GUI:Image_Create(Layout_content, "bg_input_desc", 90.00, 575.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_desc, 73, 74, 13, 14)
	GUI:setContentSize(bg_input_desc, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_desc, false)
	GUI:setTouchEnabled(bg_input_desc, false)
	GUI:setTag(bg_input_desc, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_desc, "Text", 0.00, 13.00, 16, "#ffffff", [[标题名称：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_desc
	local input_desc = GUI:TextInput_Create(bg_input_desc, "input_desc", 0.00, 1.00, 160.00, 25.00, 16)
	GUI:TextInput_setString(input_desc, "")
	GUI:TextInput_setFontColor(input_desc, "#ffffff")
	GUI:setTouchEnabled(input_desc, true)
	GUI:setTag(input_desc, -1)

	-- Create bg_input_x
	local bg_input_x = GUI:Image_Create(Layout_content, "bg_input_x", 90.00, 475.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_x, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_x, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_x, false)
	GUI:setTouchEnabled(bg_input_x, false)
	GUI:setTag(bg_input_x, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_x, "Text", 0.00, 13.00, 16, "#ffffff", [[X坐标：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_x
	local input_x = GUI:TextInput_Create(bg_input_x, "input_x", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_x, "")
	GUI:TextInput_setFontColor(input_x, "#ffffff")
	GUI:setTouchEnabled(input_x, true)
	GUI:setTag(input_x, -1)

	-- Create bg_input_y
	local bg_input_y = GUI:Image_Create(Layout_content, "bg_input_y", 240.00, 475.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_y, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_y, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_y, false)
	GUI:setTouchEnabled(bg_input_y, false)
	GUI:setTag(bg_input_y, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_y, "Text", 0.00, 13.00, 16, "#ffffff", [[Y坐标：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_y
	local input_y = GUI:TextInput_Create(bg_input_y, "input_y", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_y, "")
	GUI:TextInput_setFontColor(input_y, "#ffffff")
	GUI:setTouchEnabled(input_y, true)
	GUI:setTag(input_y, -1)

	-- Create bg_input_mapid
	local bg_input_mapid = GUI:Image_Create(Layout_content, "bg_input_mapid", 90.00, 525.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_mapid, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_mapid, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_mapid, false)
	GUI:setTouchEnabled(bg_input_mapid, false)
	GUI:setTag(bg_input_mapid, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_mapid, "Text", 0.00, 13.00, 16, "#ffffff", [[地图ID：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_mapid
	local input_mapid = GUI:TextInput_Create(bg_input_mapid, "input_mapid", 0.00, 0.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_mapid, "")
	GUI:TextInput_setFontColor(input_mapid, "#ffffff")
	GUI:setTouchEnabled(input_mapid, true)
	GUI:setTag(input_mapid, -1)

	-- Create Text_tip
	local Text_tip = GUI:Text_Create(bg_input_mapid, "Text_tip", 113.00, 13.00, 14, "#808080", [[例：盟重土城，填“3”]])
	GUI:setAnchorPoint(Text_tip, 0.00, 0.50)
	GUI:setTouchEnabled(Text_tip, false)
	GUI:setTag(Text_tip, -1)
	GUI:Text_enableOutline(Text_tip, "#000000", 2)

	-- Create line2
	local line2 = GUI:Layout_Create(Layout_content, "line2", 0.00, 452.00, 360.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line2, 1)
	GUI:Layout_setBackGroundColor(line2, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line2, 255)
	GUI:setAnchorPoint(line2, 0.00, 1.00)
	GUI:setTouchEnabled(line2, false)
	GUI:setTag(line2, -1)

	-- Create bg_input_name
	local bg_input_name = GUI:Image_Create(Layout_content, "bg_input_name", 90.00, 410.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_name, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_name, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_name, false)
	GUI:setTouchEnabled(bg_input_name, false)
	GUI:setTag(bg_input_name, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_name, "Text", 0.00, 13.00, 16, "#ffffff", [[显示名称：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_name
	local input_name = GUI:TextInput_Create(bg_input_name, "input_name", 0.00, 1.00, 160.00, 25.00, 16)
	GUI:TextInput_setString(input_name, "")
	GUI:TextInput_setFontColor(input_name, "#ffffff")
	GUI:setTouchEnabled(input_name, true)
	GUI:setTag(input_name, -1)

	-- Create Text_color_title
	local Text_color_title = GUI:Text_Create(Layout_content, "Text_color_title", 90.00, 375.00, 16, "#ffffff", [[字体颜色：]])
	GUI:setAnchorPoint(Text_color_title, 1.00, 0.50)
	GUI:setTouchEnabled(Text_color_title, false)
	GUI:setTag(Text_color_title, -1)
	GUI:Text_enableOutline(Text_color_title, "#000000", 1)

	-- Create Layout_color
	local Layout_color = GUI:Layout_Create(Layout_content, "Layout_color", 170.00, 375.00, 30.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(Layout_color, 1)
	GUI:Layout_setBackGroundColor(Layout_color, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(Layout_color, 255)
	GUI:setAnchorPoint(Layout_color, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_color, true)
	GUI:setTag(Layout_color, -1)

	-- Create switch_outLine
	local switch_outLine = GUI:Layout_Create(Layout_content, "switch_outLine", 212.00, 357.00, 135.00, 36.00, false)
	GUI:setTouchEnabled(switch_outLine, true)
	GUI:setTag(switch_outLine, -1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(switch_outLine, "Text_desc", 85.00, 18.00, 16, "#ffffff", [[开启描边：]])
	GUI:setAnchorPoint(Text_desc, 1.00, 0.50)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, -1)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create CheckBox_able
	local CheckBox_able = GUI:Layout_Create(switch_outLine, "CheckBox_able", 87.00, 18.00, 44.00, 18.00, false)
	GUI:setAnchorPoint(CheckBox_able, 0.00, 0.50)
	GUI:setTouchEnabled(CheckBox_able, false)
	GUI:setTag(CheckBox_able, -1)

	-- Create Panel_off
	local Panel_off = GUI:Layout_Create(CheckBox_able, "Panel_off", 0.00, 0.00, 44.00, 18.00, false)
	GUI:setTouchEnabled(Panel_off, false)
	GUI:setTag(Panel_off, -1)

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

	-- Create line3
	local line3 = GUI:Layout_Create(Layout_content, "line3", 0.00, 343.00, 360.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(line3, 1)
	GUI:Layout_setBackGroundColor(line3, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(line3, 255)
	GUI:setAnchorPoint(line3, 0.00, 1.00)
	GUI:setTouchEnabled(line3, false)
	GUI:setTag(line3, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_content, "Text", 10.00, 310.00, 16, "#ffffff", [[图标配置]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_res
	local btn_res = GUI:Layout_Create(Layout_content, "btn_res", 10.00, 272.00, 70.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(btn_res, 1)
	GUI:Layout_setBackGroundColor(btn_res, "#96c8c8")
	GUI:Layout_setBackGroundColorOpacity(btn_res, 178)
	GUI:setTouchEnabled(btn_res, true)
	GUI:setTag(btn_res, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_res, "Text", 35.00, 13.00, 15, "#00ffff", [[选择文件]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_res_tip
	local Text_res_tip = GUI:Text_Create(Layout_content, "Text_res_tip", 10.00, 264.00, 14, "#808080", [[默认读取路径为
res/private/minimap
请将需要的图标放入该目录中]])
	GUI:setAnchorPoint(Text_res_tip, 0.00, 1.00)
	GUI:setTouchEnabled(Text_res_tip, false)
	GUI:setTag(Text_res_tip, -1)
	GUI:Text_enableOutline(Text_res_tip, "#000000", 2)

	-- Create Text_res_name
	local Text_res_name = GUI:Text_Create(Layout_content, "Text_res_name", 84.00, 276.00, 14, "#ffffff", [[未选择文件]])
	GUI:setTouchEnabled(Text_res_name, false)
	GUI:setTag(Text_res_name, -1)
	GUI:Text_enableOutline(Text_res_name, "#000000", 1)

	-- Create Layout_show
	local Layout_show = GUI:Layout_Create(Layout_content, "Layout_show", 215.00, 210.00, 140.00, 90.00, false)
	GUI:Layout_setBackGroundColorType(Layout_show, 1)
	GUI:Layout_setBackGroundColor(Layout_show, "#ccf783")
	GUI:Layout_setBackGroundColorOpacity(Layout_show, 255)
	GUI:setTouchEnabled(Layout_show, false)
	GUI:setTag(Layout_show, -1)

	-- Create img_res
	local img_res = GUI:Image_Create(Layout_content, "img_res", 285.00, 255.00, "res/private/gui_edit/ImageFile.png")
	GUI:setAnchorPoint(img_res, 0.50, 0.50)
	GUI:setTouchEnabled(img_res, false)
	GUI:setTag(img_res, -1)
	GUI:setVisible(img_res, false)

	-- Create Text_tip1
	local Text_tip1 = GUI:Text_Create(Layout_content, "Text_tip1", 11.00, 180.00, 14, "#ffffff", [[点击图标表现]])
	GUI:setTouchEnabled(Text_tip1, false)
	GUI:setTag(Text_tip1, -1)
	GUI:Text_enableOutline(Text_tip1, "#000000", 1)

	-- Create Text_res_tip_1
	local Text_res_tip_1 = GUI:Text_Create(Layout_content, "Text_res_tip_1", 214.00, 200.00, 14, "#808080", [[按照X，Y定义执行坐标
根据配置的图标点击链
接将XY坐标写入到
<$ToPointX>
<$ToPointY>常量中]])
	GUI:setAnchorPoint(Text_res_tip_1, 0.00, 1.00)
	GUI:setTouchEnabled(Text_res_tip_1, false)
	GUI:setTag(Text_res_tip_1, -1)
	GUI:Text_enableOutline(Text_res_tip_1, "#000000", 2)

	-- Create Text_color
	local Text_color = GUI:Text_Create(Layout_content, "Text_color", 85.00, 375.00, 16, "#ffffff", [[请选择颜色]])
	GUI:setAnchorPoint(Text_color, 0.00, 0.50)
	GUI:setTouchEnabled(Text_color, false)
	GUI:setTag(Text_color, -1)
	GUI:Text_disableOutLine(Text_color)

	-- Create Layout_findpath0
	local Layout_findpath0 = GUI:Layout_Create(Layout_content, "Layout_findpath0", 9.00, 145.00, 110.00, 30.00, false)
	GUI:setTouchEnabled(Layout_findpath0, true)
	GUI:setTag(Layout_findpath0, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(Layout_findpath0, "img_sel", 5.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)
	GUI:setVisible(img_sel, false)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(Layout_findpath0, "img_unsel", 5.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_findpath0, "Text", 40.00, 15.00, 14, "#ffffff", [[无动作]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create Layout_findpath1
	local Layout_findpath1 = GUI:Layout_Create(Layout_content, "Layout_findpath1", 9.00, 110.00, 110.00, 30.00, false)
	GUI:setTouchEnabled(Layout_findpath1, true)
	GUI:setTag(Layout_findpath1, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(Layout_findpath1, "img_sel", 5.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(Layout_findpath1, "img_unsel", 5.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_findpath1, "Text", 40.00, 15.00, 14, "#ffffff", [[自动寻路]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create Layout_findpath2
	local Layout_findpath2 = GUI:Layout_Create(Layout_content, "Layout_findpath2", 9.00, 75.00, 110.00, 30.00, false)
	GUI:setTouchEnabled(Layout_findpath2, true)
	GUI:setTag(Layout_findpath2, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(Layout_findpath2, "img_sel", 5.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(Layout_findpath2, "img_unsel", 5.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_findpath2, "Text", 40.00, 15.00, 14, "#ffffff", [[直接传送]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create Layout_content_mask
	local Layout_content_mask = GUI:Layout_Create(Layout_content, "Layout_content_mask", 0.00, 0.00, 360.00, 616.00, false)
	GUI:Layout_setBackGroundColorType(Layout_content_mask, 1)
	GUI:Layout_setBackGroundColor(Layout_content_mask, "#808080")
	GUI:Layout_setBackGroundColorOpacity(Layout_content_mask, 229)
	GUI:setTouchEnabled(Layout_content_mask, true)
	GUI:setTag(Layout_content_mask, -1)
	GUI:setVisible(Layout_content_mask, false)

	-- Create btn_loadMap
	local btn_loadMap = GUI:Layout_Create(Panel_1, "btn_loadMap", 511.00, 600.00, 90.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_loadMap, 1)
	GUI:Layout_setBackGroundColor(btn_loadMap, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_loadMap, 255)
	GUI:setAnchorPoint(btn_loadMap, 0.50, 0.00)
	GUI:setTouchEnabled(btn_loadMap, true)
	GUI:setTag(btn_loadMap, -1)
	GUI:setVisible(btn_loadMap, false)

	-- Create Text
	local Text = GUI:Text_Create(btn_loadMap, "Text", 45.00, 15.00, 16, "#ffffff", [[导入map]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)
end
return ui