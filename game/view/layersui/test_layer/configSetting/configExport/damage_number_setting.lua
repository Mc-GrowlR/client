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
	local Layout_page = GUI:Layout_Create(Panel_1, "Layout_page", 5.00, 23.00, 200.00, 616.00, false)
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

	-- Create Layout_content
	local Layout_content = GUI:Layout_Create(Panel_1, "Layout_content", 211.00, 24.00, 726.00, 616.00, false)
	GUI:Layout_setBackGroundColorType(Layout_content, 1)
	GUI:Layout_setBackGroundColor(Layout_content, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_content, 160)
	GUI:setTouchEnabled(Layout_content, false)
	GUI:setTag(Layout_content, -1)

	-- Create bg_title
	local bg_title = GUI:Layout_Create(Layout_content, "bg_title", 363.00, 570.00, 150.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(bg_title, 1)
	GUI:Layout_setBackGroundColor(bg_title, "#000000")
	GUI:Layout_setBackGroundColorOpacity(bg_title, 255)
	GUI:setAnchorPoint(bg_title, 0.50, 0.00)
	GUI:setTouchEnabled(bg_title, false)
	GUI:setTag(bg_title, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_title, "Text", 75.00, 15.00, 16, "#ffffff", [[当前配置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_sure
	local btn_sure = GUI:Layout_Create(Layout_content, "btn_sure", 580.00, 5.00, 90.00, 30.00, false)
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

	-- Create bg_input_name
	local bg_input_name = GUI:Image_Create(Layout_content, "bg_input_name", 80.00, 520.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_name, 73, 74, 13, 14)
	GUI:setContentSize(bg_input_name, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_name, false)
	GUI:setTouchEnabled(bg_input_name, false)
	GUI:setTag(bg_input_name, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_name, "Text", 0.00, 13.00, 16, "#ffffff", [[标题：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_name
	local input_name = GUI:TextInput_Create(bg_input_name, "input_name", 0.00, 0.00, 160.00, 25.00, 16)
	GUI:TextInput_setString(input_name, "")
	GUI:TextInput_setFontColor(input_name, "#ffffff")
	GUI:setTouchEnabled(input_name, true)
	GUI:setTag(input_name, -1)

	-- Create bg_input_zOrder
	local bg_input_zOrder = GUI:Image_Create(Layout_content, "bg_input_zOrder", 590.00, 520.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_zOrder, 73, 74, 13, 14)
	GUI:setContentSize(bg_input_zOrder, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_zOrder, false)
	GUI:setTouchEnabled(bg_input_zOrder, false)
	GUI:setTag(bg_input_zOrder, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_zOrder, "Text", 0.00, 13.00, 16, "#ffffff", [[层级：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_zOrder
	local input_zOrder = GUI:TextInput_Create(bg_input_zOrder, "input_zOrder", 0.00, 0.00, 80.00, 25.00, 16)
	GUI:TextInput_setString(input_zOrder, "")
	GUI:TextInput_setFontColor(input_zOrder, "#ffffff")
	GUI:setTouchEnabled(input_zOrder, true)
	GUI:setTag(input_zOrder, -1)

	-- Create Layout_detail
	local Layout_detail = GUI:Layout_Create(Layout_content, "Layout_detail", 10.00, 40.00, 706.00, 470.00, false)
	GUI:Layout_setBackGroundColorType(Layout_detail, 1)
	GUI:Layout_setBackGroundColor(Layout_detail, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_detail, 102)
	GUI:setTouchEnabled(Layout_detail, false)
	GUI:setTag(Layout_detail, -1)

	-- Create Layout_type
	local Layout_type = GUI:Layout_Create(Layout_detail, "Layout_type", 25.00, 329.00, 220.00, 100.00, false)
	GUI:Layout_setBackGroundColorType(Layout_type, 1)
	GUI:Layout_setBackGroundColor(Layout_type, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_type, 127)
	GUI:setTouchEnabled(Layout_type, false)
	GUI:setTag(Layout_type, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_type, "Text", 110.00, 130.00, 16, "#ffffff", [[飘字类型]])
	GUI:setAnchorPoint(Text, 0.50, 0.00)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_type1
	local Layout_type1 = GUI:Layout_Create(Layout_type, "Layout_type1", 30.00, 118.00, 150.00, 30.00, false)
	GUI:setAnchorPoint(Layout_type1, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_type1, true)
	GUI:setTag(Layout_type1, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(Layout_type1, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(Layout_type1, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_type1, "Text", 43.00, 15.00, 16, "#ffffff", [[图片数值飘字]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_type2
	local Layout_type2 = GUI:Layout_Create(Layout_type, "Layout_type2", 30.00, 88.00, 150.00, 30.00, false)
	GUI:setAnchorPoint(Layout_type2, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_type2, true)
	GUI:setTag(Layout_type2, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(Layout_type2, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(Layout_type2, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_type2, "Text", 43.00, 15.00, 16, "#ffffff", [[单图片飘字]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_type3
	local Layout_type3 = GUI:Layout_Create(Layout_type, "Layout_type3", 30.00, 58.00, 150.00, 30.00, false)
	GUI:setAnchorPoint(Layout_type3, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_type3, true)
	GUI:setTag(Layout_type3, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(Layout_type3, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(Layout_type3, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_type3, "Text", 43.00, 15.00, 16, "#ffffff", [[图片数值飘字(无数字)]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_type4
	local Layout_type4 = GUI:Layout_Create(Layout_type, "Layout_type4", 30.00, 30.00, 150.00, 30.00, false)
	GUI:setAnchorPoint(Layout_type4, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_type4, true)
	GUI:setTag(Layout_type4, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(Layout_type4, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(Layout_type4, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_type4, "Text", 43.00, 15.00, 16, "#ffffff", [[图片数值飘字(单位)]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create bg_input_prefixLen
	local bg_input_prefixLen = GUI:Image_Create(Layout_type, "bg_input_prefixLen", 101.00, -8.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_prefixLen, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_prefixLen, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_prefixLen, false)
	GUI:setTouchEnabled(bg_input_prefixLen, false)
	GUI:setTag(bg_input_prefixLen, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_prefixLen, "Text", 0.00, 13.00, 16, "#ffffff", [[文字长度：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_prefixLen
	local input_prefixLen = GUI:TextInput_Create(bg_input_prefixLen, "input_prefixLen", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_prefixLen, "")
	GUI:TextInput_setFontColor(input_prefixLen, "#ffffff")
	GUI:setTouchEnabled(input_prefixLen, true)
	GUI:setTag(input_prefixLen, -1)

	-- Create Layout_prefixLenMask
	local Layout_prefixLenMask = GUI:Layout_Create(bg_input_prefixLen, "Layout_prefixLenMask", 62.00, 0.00, 145.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(Layout_prefixLenMask, 1)
	GUI:Layout_setBackGroundColor(Layout_prefixLenMask, "#808080")
	GUI:Layout_setBackGroundColorOpacity(Layout_prefixLenMask, 229)
	GUI:setAnchorPoint(Layout_prefixLenMask, 1.00, 0.00)
	GUI:setTouchEnabled(Layout_prefixLenMask, true)
	GUI:setTag(Layout_prefixLenMask, -1)
	GUI:setVisible(Layout_prefixLenMask, false)

	-- Create btn_help_prefixLen
	local btn_help_prefixLen = GUI:Layout_Create(Layout_type, "btn_help_prefixLen", 170.00, -8.00, 40.00, 26.00, false)
	GUI:setTouchEnabled(btn_help_prefixLen, true)
	GUI:setTag(btn_help_prefixLen, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(btn_help_prefixLen, "Text_1", 20.00, 13.00, 22, "#ffffff", [[○]])
	GUI:setAnchorPoint(Text_1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 2)

	-- Create Text
	local Text = GUI:Text_Create(Text_1, "Text", 16.00, 13.00, 20, "#ffffff", [[？]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create bg_input_aftherfixLen
	local bg_input_aftherfixLen = GUI:Image_Create(Layout_type, "bg_input_aftherfixLen", 368.00, -8.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_aftherfixLen, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_aftherfixLen, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_aftherfixLen, false)
	GUI:setTouchEnabled(bg_input_aftherfixLen, false)
	GUI:setTag(bg_input_aftherfixLen, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_aftherfixLen, "Text", 0.00, 13.00, 16, "#ffffff", [[数字后面文字长度：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_aftherfixLen
	local input_aftherfixLen = GUI:TextInput_Create(bg_input_aftherfixLen, "input_aftherfixLen", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_aftherfixLen, "")
	GUI:TextInput_setFontColor(input_aftherfixLen, "#ffffff")
	GUI:setTouchEnabled(input_aftherfixLen, true)
	GUI:setTag(input_aftherfixLen, -1)

	-- Create Layout_aftherfixLenMask
	local Layout_aftherfixLenMask = GUI:Layout_Create(bg_input_aftherfixLen, "Layout_aftherfixLenMask", 62.00, 0.00, 145.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(Layout_aftherfixLenMask, 1)
	GUI:Layout_setBackGroundColor(Layout_aftherfixLenMask, "#808080")
	GUI:Layout_setBackGroundColorOpacity(Layout_aftherfixLenMask, 229)
	GUI:setAnchorPoint(Layout_aftherfixLenMask, 1.00, 0.00)
	GUI:setTouchEnabled(Layout_aftherfixLenMask, true)
	GUI:setTag(Layout_aftherfixLenMask, -1)
	GUI:setVisible(Layout_aftherfixLenMask, false)

	-- Create btn_help_aftherfixLen
	local btn_help_aftherfixLen = GUI:Layout_Create(Layout_type, "btn_help_aftherfixLen", 445.00, -8.00, 40.00, 26.00, false)
	GUI:setTouchEnabled(btn_help_aftherfixLen, true)
	GUI:setTag(btn_help_aftherfixLen, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(btn_help_aftherfixLen, "Text_1", 20.00, 13.00, 22, "#ffffff", [[○]])
	GUI:setAnchorPoint(Text_1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 2)

	-- Create Text
	local Text = GUI:Text_Create(Text_1, "Text", 16.00, 13.00, 20, "#ffffff", [[？]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_size
	local Layout_size = GUI:Layout_Create(Layout_detail, "Layout_size", 270.00, 345.00, 220.00, 100.00, false)
	GUI:Layout_setBackGroundColorType(Layout_size, 1)
	GUI:Layout_setBackGroundColor(Layout_size, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_size, 140)
	GUI:setTouchEnabled(Layout_size, false)
	GUI:setTag(Layout_size, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_size, "Text", 110.00, 108.00, 16, "#ffffff", [[图片尺寸]])
	GUI:setAnchorPoint(Text, 0.50, 0.00)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create bg_input_imgW
	local bg_input_imgW = GUI:Image_Create(Layout_size, "bg_input_imgW", 112.00, 70.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_imgW, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_imgW, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_imgW, false)
	GUI:setAnchorPoint(bg_input_imgW, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_imgW, false)
	GUI:setTag(bg_input_imgW, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_input_imgW, "input_prefix", -30.00, 13.00, 16, "#ffffff", [[宽    度]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_imgW
	local input_imgW = GUI:TextInput_Create(bg_input_imgW, "input_imgW", 0.00, 0.00, 80.00, 25.00, 16)
	GUI:TextInput_setString(input_imgW, "")
	GUI:TextInput_setFontColor(input_imgW, "#ffffff")
	GUI:setTouchEnabled(input_imgW, true)
	GUI:setTag(input_imgW, -1)

	-- Create bg_input_imgH
	local bg_input_imgH = GUI:Image_Create(Layout_size, "bg_input_imgH", 112.00, 30.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_imgH, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_imgH, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_imgH, false)
	GUI:setAnchorPoint(bg_input_imgH, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_imgH, false)
	GUI:setTag(bg_input_imgH, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_input_imgH, "input_prefix", -30.00, 13.00, 16, "#ffffff", [[高    度]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_imgH
	local input_imgH = GUI:TextInput_Create(bg_input_imgH, "input_imgH", 0.00, 0.00, 80.00, 25.00, 16)
	GUI:TextInput_setString(input_imgH, "")
	GUI:TextInput_setFontColor(input_imgH, "#ffffff")
	GUI:setTouchEnabled(input_imgH, true)
	GUI:setTag(input_imgH, -1)

	-- Create Layout_extra
	local Layout_extra = GUI:Layout_Create(Layout_detail, "Layout_extra", 484.00, 335.00, 220.00, 100.00, false)
	GUI:setTouchEnabled(Layout_extra, false)
	GUI:setTag(Layout_extra, -1)

	-- Create bg_input_sfx
	local bg_input_sfx = GUI:Image_Create(Layout_extra, "bg_input_sfx", 112.00, 84.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_sfx, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_sfx, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_sfx, false)
	GUI:setAnchorPoint(bg_input_sfx, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_sfx, false)
	GUI:setTag(bg_input_sfx, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_input_sfx, "input_prefix", -5.00, 13.00, 16, "#ffffff", [[特效显示]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_sfx
	local input_sfx = GUI:TextInput_Create(bg_input_sfx, "input_sfx", 0.00, 0.00, 80.00, 25.00, 16)
	GUI:TextInput_setString(input_sfx, "")
	GUI:TextInput_setFontColor(input_sfx, "#ffffff")
	GUI:setTouchEnabled(input_sfx, true)
	GUI:setTag(input_sfx, -1)

	-- Create Layout_shake
	local Layout_shake = GUI:Layout_Create(Layout_extra, "Layout_shake", 42.00, 46.00, 150.00, 26.00, false)
	GUI:setAnchorPoint(Layout_shake, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_shake, true)
	GUI:setTag(Layout_shake, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_shake, "Text", 1.00, 13.00, 16, "#ffffff", [[震屏开关]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create CheckBox_able
	local CheckBox_able = GUI:Layout_Create(Layout_shake, "CheckBox_able", 85.00, 13.00, 44.00, 18.00, false)
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

	-- Create Layout_LowHpWarning
	local Layout_LowHpWarning = GUI:Layout_Create(Layout_extra, "Layout_LowHpWarning", 42.00, 8.00, 150.00, 26.00, false)
	GUI:setAnchorPoint(Layout_LowHpWarning, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_LowHpWarning, true)
	GUI:setTag(Layout_LowHpWarning, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_LowHpWarning, "Text", 1.00, 13.00, 16, "#ffffff", [[低血警示]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create CheckBox_able
	local CheckBox_able = GUI:Layout_Create(Layout_LowHpWarning, "CheckBox_able", 85.00, 13.00, 44.00, 18.00, false)
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

	-- Create Layout_action
	local Layout_action = GUI:Layout_Create(Layout_detail, "Layout_action", 10.00, 0.00, 405.00, 320.00, false)
	GUI:Layout_setBackGroundColorType(Layout_action, 1)
	GUI:Layout_setBackGroundColor(Layout_action, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_action, 153)
	GUI:setTouchEnabled(Layout_action, false)
	GUI:setTag(Layout_action, -1)

	-- Create act_page1
	local act_page1 = GUI:Layout_Create(Layout_action, "act_page1", 0.00, 320.00, 134.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(act_page1, 1)
	GUI:Layout_setBackGroundColor(act_page1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(act_page1, 255)
	GUI:setAnchorPoint(act_page1, 0.00, 1.00)
	GUI:setTouchEnabled(act_page1, true)
	GUI:setTag(act_page1, -1)

	-- Create Text
	local Text = GUI:Text_Create(act_page1, "Text", 67.00, 15.00, 16, "#ffffff", [[自身飘血]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create act_page2
	local act_page2 = GUI:Layout_Create(Layout_action, "act_page2", 135.00, 320.00, 135.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(act_page2, 1)
	GUI:Layout_setBackGroundColor(act_page2, "#000000")
	GUI:Layout_setBackGroundColorOpacity(act_page2, 255)
	GUI:setAnchorPoint(act_page2, 0.00, 1.00)
	GUI:setTouchEnabled(act_page2, true)
	GUI:setTag(act_page2, -1)

	-- Create Text
	local Text = GUI:Text_Create(act_page2, "Text", 67.00, 15.00, 16, "#ffffff", [[他人飘血]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create act_page3
	local act_page3 = GUI:Layout_Create(Layout_action, "act_page3", 405.00, 320.00, 134.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(act_page3, 1)
	GUI:Layout_setBackGroundColor(act_page3, "#000000")
	GUI:Layout_setBackGroundColorOpacity(act_page3, 255)
	GUI:setAnchorPoint(act_page3, 1.00, 1.00)
	GUI:setTouchEnabled(act_page3, true)
	GUI:setTag(act_page3, -1)

	-- Create Text
	local Text = GUI:Text_Create(act_page3, "Text", 67.00, 15.00, 16, "#ffffff", [[飘血位置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout_action1
	local Layout_action1 = GUI:Layout_Create(Layout_action, "Layout_action1", 0.00, 0.00, 405.00, 285.00, false)
	GUI:Layout_setBackGroundColorType(Layout_action1, 1)
	GUI:Layout_setBackGroundColor(Layout_action1, "#96c8ff")
	GUI:Layout_setBackGroundColorOpacity(Layout_action1, 38)
	GUI:setTouchEnabled(Layout_action1, false)
	GUI:setTag(Layout_action1, -1)

	-- Create bg_input_time
	local bg_input_time = GUI:Image_Create(Layout_action1, "bg_input_time", 162.00, 260.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_time, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_time, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_time, false)
	GUI:setAnchorPoint(bg_input_time, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_time, false)
	GUI:setTag(bg_input_time, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_input_time, "input_prefix", -10.00, 13.00, 16, "#ffffff", [[显示时间]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_time
	local input_time = GUI:TextInput_Create(bg_input_time, "input_time", 0.00, 0.00, 80.00, 25.00, 16)
	GUI:TextInput_setString(input_time, "")
	GUI:TextInput_setFontColor(input_time, "#ffffff")
	GUI:setTouchEnabled(input_time, true)
	GUI:setTag(input_time, -1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(bg_input_time, "input_suffix", 100.00, 13.00, 16, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create bg_input_anchorX
	local bg_input_anchorX = GUI:Image_Create(Layout_action1, "bg_input_anchorX", 207.00, 221.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_anchorX, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_anchorX, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_anchorX, false)
	GUI:setAnchorPoint(bg_input_anchorX, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_anchorX, false)
	GUI:setTag(bg_input_anchorX, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_input_anchorX, "input_prefix", -5.00, 13.00, 16, "#ffffff", [[X坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_anchorX
	local input_anchorX = GUI:TextInput_Create(bg_input_anchorX, "input_anchorX", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_anchorX, "")
	GUI:TextInput_setFontColor(input_anchorX, "#ffffff")
	GUI:setTouchEnabled(input_anchorX, true)
	GUI:setTag(input_anchorX, -1)

	-- Create input_title
	local input_title = GUI:Text_Create(bg_input_anchorX, "input_title", -119.00, 13.00, 16, "#ffffff", [[锚点]])
	GUI:setAnchorPoint(input_title, 0.00, 0.50)
	GUI:setTouchEnabled(input_title, false)
	GUI:setTag(input_title, -1)
	GUI:Text_enableOutline(input_title, "#000000", 1)

	-- Create bg_input_anchorY
	local bg_input_anchorY = GUI:Image_Create(Layout_action1, "bg_input_anchorY", 335.00, 221.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_anchorY, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_anchorY, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_anchorY, false)
	GUI:setAnchorPoint(bg_input_anchorY, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_anchorY, false)
	GUI:setTag(bg_input_anchorY, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_input_anchorY, "input_prefix", -5.00, 13.00, 16, "#ffffff", [[Y坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_anchorY
	local input_anchorY = GUI:TextInput_Create(bg_input_anchorY, "input_anchorY", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_anchorY, "")
	GUI:TextInput_setFontColor(input_anchorY, "#ffffff")
	GUI:setTouchEnabled(input_anchorY, true)
	GUI:setTag(input_anchorY, -1)

	-- Create bg_input_offsetX
	local bg_input_offsetX = GUI:Image_Create(Layout_action1, "bg_input_offsetX", 207.00, 182.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_offsetX, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_offsetX, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_offsetX, false)
	GUI:setAnchorPoint(bg_input_offsetX, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_offsetX, false)
	GUI:setTag(bg_input_offsetX, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_input_offsetX, "input_prefix", -5.00, 13.00, 16, "#ffffff", [[X坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_offsetX
	local input_offsetX = GUI:TextInput_Create(bg_input_offsetX, "input_offsetX", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_offsetX, "")
	GUI:TextInput_setFontColor(input_offsetX, "#ffffff")
	GUI:setTouchEnabled(input_offsetX, true)
	GUI:setTag(input_offsetX, -1)

	-- Create input_title
	local input_title = GUI:Text_Create(bg_input_offsetX, "input_title", -119.00, 13.00, 16, "#ffffff", [[偏移]])
	GUI:setAnchorPoint(input_title, 0.00, 0.50)
	GUI:setTouchEnabled(input_title, false)
	GUI:setTag(input_title, -1)
	GUI:Text_enableOutline(input_title, "#000000", 1)

	-- Create bg_input_offsetY
	local bg_input_offsetY = GUI:Image_Create(Layout_action1, "bg_input_offsetY", 335.00, 182.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_offsetY, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_offsetY, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_offsetY, false)
	GUI:setAnchorPoint(bg_input_offsetY, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_offsetY, false)
	GUI:setTag(bg_input_offsetY, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_input_offsetY, "input_prefix", -5.00, 13.00, 16, "#ffffff", [[Y坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_offsetY
	local input_offsetY = GUI:TextInput_Create(bg_input_offsetY, "input_offsetY", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_offsetY, "")
	GUI:TextInput_setFontColor(input_offsetY, "#ffffff")
	GUI:setTouchEnabled(input_offsetY, true)
	GUI:setTag(input_offsetY, -1)

	-- Create bg_input_scale
	local bg_input_scale = GUI:Image_Create(Layout_action1, "bg_input_scale", 160.00, 143.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_scale, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_scale, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_scale, false)
	GUI:setAnchorPoint(bg_input_scale, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_scale, false)
	GUI:setTag(bg_input_scale, -1)

	-- Create input_scale
	local input_scale = GUI:TextInput_Create(bg_input_scale, "input_scale", 0.00, 0.00, 80.00, 25.00, 16)
	GUI:TextInput_setString(input_scale, "")
	GUI:TextInput_setFontColor(input_scale, "#ffffff")
	GUI:setTouchEnabled(input_scale, true)
	GUI:setTag(input_scale, -1)

	-- Create input_title
	local input_title = GUI:Text_Create(bg_input_scale, "input_title", -72.00, 13.00, 16, "#ffffff", [[缩放]])
	GUI:setAnchorPoint(input_title, 0.00, 0.50)
	GUI:setTouchEnabled(input_title, false)
	GUI:setTag(input_title, -1)
	GUI:Text_enableOutline(input_title, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(bg_input_scale, "input_suffix", 100.00, 13.00, 16, "#ffffff", [[(0-1)例：0.8]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create bg_input_opacity
	local bg_input_opacity = GUI:Image_Create(Layout_action1, "bg_input_opacity", 160.00, 104.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_opacity, 74, 72, 16, 10)
	GUI:setContentSize(bg_input_opacity, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_opacity, false)
	GUI:setAnchorPoint(bg_input_opacity, 0.00, 0.50)
	GUI:setTouchEnabled(bg_input_opacity, false)
	GUI:setTag(bg_input_opacity, -1)

	-- Create input_opacity
	local input_opacity = GUI:TextInput_Create(bg_input_opacity, "input_opacity", 0.00, 0.00, 80.00, 25.00, 16)
	GUI:TextInput_setString(input_opacity, "")
	GUI:TextInput_setFontColor(input_opacity, "#ffffff")
	GUI:setTouchEnabled(input_opacity, true)
	GUI:setTag(input_opacity, -1)

	-- Create input_title
	local input_title = GUI:Text_Create(bg_input_opacity, "input_title", -72.00, 13.00, 16, "#ffffff", [[透明度]])
	GUI:setAnchorPoint(input_title, 0.00, 0.50)
	GUI:setTouchEnabled(input_title, false)
	GUI:setTag(input_title, -1)
	GUI:Text_enableOutline(input_title, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(bg_input_opacity, "input_suffix", 100.00, 13.00, 16, "#ffffff", [[(0-1)例：0.5]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create bg_waitting
	local bg_waitting = GUI:Image_Create(Layout_action1, "bg_waitting", 160.00, 65.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_waitting, 74, 72, 16, 10)
	GUI:setContentSize(bg_waitting, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_waitting, false)
	GUI:setAnchorPoint(bg_waitting, 0.00, 0.50)
	GUI:setTouchEnabled(bg_waitting, false)
	GUI:setTag(bg_waitting, -1)

	-- Create input_waitting
	local input_waitting = GUI:TextInput_Create(bg_waitting, "input_waitting", 0.00, 0.00, 80.00, 25.00, 16)
	GUI:TextInput_setString(input_waitting, "")
	GUI:TextInput_setFontColor(input_waitting, "#ffffff")
	GUI:setTouchEnabled(input_waitting, true)
	GUI:setTag(input_waitting, -1)

	-- Create input_title
	local input_title = GUI:Text_Create(bg_waitting, "input_title", -72.00, 13.00, 16, "#ffffff", [[等待时间]])
	GUI:setAnchorPoint(input_title, 0.00, 0.50)
	GUI:setTouchEnabled(input_title, false)
	GUI:setTag(input_title, -1)
	GUI:Text_enableOutline(input_title, "#000000", 1)

	-- Create input_suffix
	local input_suffix = GUI:Text_Create(bg_waitting, "input_suffix", 102.00, 13.00, 16, "#ffffff", [[秒]])
	GUI:setAnchorPoint(input_suffix, 0.00, 0.50)
	GUI:setTouchEnabled(input_suffix, false)
	GUI:setTag(input_suffix, -1)
	GUI:Text_enableOutline(input_suffix, "#000000", 1)

	-- Create btn_help_prefixLen
	local btn_help_prefixLen = GUI:Layout_Create(Layout_action1, "btn_help_prefixLen", 360.00, 260.00, 40.00, 26.00, false)
	GUI:setTouchEnabled(btn_help_prefixLen, true)
	GUI:setTag(btn_help_prefixLen, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(btn_help_prefixLen, "Text_1", 20.00, 13.00, 22, "#ffffff", [[○]])
	GUI:setAnchorPoint(Text_1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 2)

	-- Create Text
	local Text = GUI:Text_Create(Text_1, "Text", 16.00, 13.00, 20, "#ffffff", [[？]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_act_save
	local btn_act_save = GUI:Layout_Create(Layout_action1, "btn_act_save", 364.00, 5.00, 76.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_act_save, 1)
	GUI:Layout_setBackGroundColor(btn_act_save, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_act_save, 255)
	GUI:setAnchorPoint(btn_act_save, 0.50, 0.00)
	GUI:setTouchEnabled(btn_act_save, true)
	GUI:setTag(btn_act_save, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_act_save, "Text", 38.00, 15.00, 16, "#ffffff", [[记录动作]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create btn_act_reload
	local btn_act_reload = GUI:Layout_Create(Layout_action1, "btn_act_reload", 282.00, 5.00, 76.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_act_reload, 1)
	GUI:Layout_setBackGroundColor(btn_act_reload, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_act_reload, 255)
	GUI:setAnchorPoint(btn_act_reload, 0.50, 0.00)
	GUI:setTouchEnabled(btn_act_reload, true)
	GUI:setTag(btn_act_reload, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_act_reload, "Text", 38.00, 15.00, 16, "#ffffff", [[恢复动作]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create btn_act_del
	local btn_act_del = GUI:Layout_Create(Layout_action1, "btn_act_del", 200.00, 5.00, 76.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_act_del, 1)
	GUI:Layout_setBackGroundColor(btn_act_del, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_act_del, 255)
	GUI:setAnchorPoint(btn_act_del, 0.50, 0.00)
	GUI:setTouchEnabled(btn_act_del, true)
	GUI:setTag(btn_act_del, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_act_del, "Text", 38.00, 15.00, 16, "#ffffff", [[删除动作]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create btn_act_copy
	local btn_act_copy = GUI:Layout_Create(Layout_action1, "btn_act_copy", 118.00, 5.00, 76.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_act_copy, 1)
	GUI:Layout_setBackGroundColor(btn_act_copy, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_act_copy, 255)
	GUI:setAnchorPoint(btn_act_copy, 0.50, 0.00)
	GUI:setTouchEnabled(btn_act_copy, true)
	GUI:setTag(btn_act_copy, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_act_copy, "Text", 38.00, 15.00, 16, "#ffffff", [[复制动作]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create Layout_action2
	local Layout_action2 = GUI:Layout_Create(Layout_action, "Layout_action2", 0.00, 0.00, 405.00, 285.00, false)
	GUI:Layout_setBackGroundColorType(Layout_action2, 1)
	GUI:Layout_setBackGroundColor(Layout_action2, "#96c8ff")
	GUI:Layout_setBackGroundColorOpacity(Layout_action2, 38)
	GUI:setTouchEnabled(Layout_action2, false)
	GUI:setTag(Layout_action2, -1)
	GUI:setVisible(Layout_action2, false)

	-- Create bg_inputX
	local bg_inputX = GUI:Image_Create(Layout_action2, "bg_inputX", 160.00, 221.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_inputX, 0, 0, 0, 0)
	GUI:setContentSize(bg_inputX, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_inputX, false)
	GUI:setAnchorPoint(bg_inputX, 0.00, 0.50)
	GUI:setTouchEnabled(bg_inputX, false)
	GUI:setTag(bg_inputX, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_inputX, "input_prefix", -5.00, 13.00, 16, "#ffffff", [[X坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create inputX
	local inputX = GUI:TextInput_Create(bg_inputX, "inputX", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(inputX, "")
	GUI:TextInput_setFontColor(inputX, "#ffffff")
	GUI:setTouchEnabled(inputX, true)
	GUI:setTag(inputX, -1)

	-- Create bg_inputY
	local bg_inputY = GUI:Image_Create(Layout_action2, "bg_inputY", 290.00, 221.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_inputY, 0, 0, 0, 0)
	GUI:setContentSize(bg_inputY, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_inputY, false)
	GUI:setAnchorPoint(bg_inputY, 0.00, 0.50)
	GUI:setTouchEnabled(bg_inputY, false)
	GUI:setTag(bg_inputY, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(bg_inputY, "input_prefix", -5.00, 13.00, 16, "#ffffff", [[Y坐标]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create inputY
	local inputY = GUI:TextInput_Create(bg_inputY, "inputY", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(inputY, "")
	GUI:TextInput_setFontColor(inputY, "#ffffff")
	GUI:setTouchEnabled(inputY, true)
	GUI:setTag(inputY, -1)

	-- Create btn_pos_save
	local btn_pos_save = GUI:Layout_Create(Layout_action2, "btn_pos_save", 364.00, 5.00, 76.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_pos_save, 1)
	GUI:Layout_setBackGroundColor(btn_pos_save, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_pos_save, 255)
	GUI:setAnchorPoint(btn_pos_save, 0.50, 0.00)
	GUI:setTouchEnabled(btn_pos_save, true)
	GUI:setTag(btn_pos_save, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_pos_save, "Text", 38.00, 15.00, 16, "#ffffff", [[记录位置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create btn_pos_reload
	local btn_pos_reload = GUI:Layout_Create(Layout_action2, "btn_pos_reload", 282.00, 5.00, 76.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_pos_reload, 1)
	GUI:Layout_setBackGroundColor(btn_pos_reload, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_pos_reload, 255)
	GUI:setAnchorPoint(btn_pos_reload, 0.50, 0.00)
	GUI:setTouchEnabled(btn_pos_reload, true)
	GUI:setTag(btn_pos_reload, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_pos_reload, "Text", 38.00, 15.00, 16, "#ffffff", [[恢复位置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create btn_pos_del
	local btn_pos_del = GUI:Layout_Create(Layout_action2, "btn_pos_del", 200.00, 5.00, 76.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_pos_del, 1)
	GUI:Layout_setBackGroundColor(btn_pos_del, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_pos_del, 255)
	GUI:setAnchorPoint(btn_pos_del, 0.50, 0.00)
	GUI:setTouchEnabled(btn_pos_del, true)
	GUI:setTag(btn_pos_del, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_pos_del, "Text", 38.00, 15.00, 16, "#ffffff", [[删除位置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create btn_pos_copy
	local btn_pos_copy = GUI:Layout_Create(Layout_action2, "btn_pos_copy", 118.00, 5.00, 76.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(btn_pos_copy, 1)
	GUI:Layout_setBackGroundColor(btn_pos_copy, "#0000ff")
	GUI:Layout_setBackGroundColorOpacity(btn_pos_copy, 255)
	GUI:setAnchorPoint(btn_pos_copy, 0.50, 0.00)
	GUI:setTouchEnabled(btn_pos_copy, true)
	GUI:setTag(btn_pos_copy, -1)

	-- Create Text
	local Text = GUI:Text_Create(btn_pos_copy, "Text", 38.00, 15.00, 16, "#ffffff", [[复制位置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 2)

	-- Create Layout_action_list
	local Layout_action_list = GUI:Layout_Create(Layout_action, "Layout_action_list", 0.00, 0.00, 76.00, 290.00, false)
	GUI:Layout_setBackGroundColorType(Layout_action_list, 1)
	GUI:Layout_setBackGroundColor(Layout_action_list, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_action_list, 204)
	GUI:setTouchEnabled(Layout_action_list, false)
	GUI:setTag(Layout_action_list, -1)

	-- Create lv_action
	local lv_action = GUI:ListView_Create(Layout_action_list, "lv_action", 0.00, 0.00, 76.00, 285.00, 1)
	GUI:ListView_setGravity(lv_action, 5)
	GUI:ListView_setItemsMargin(lv_action, 1)
	GUI:setTouchEnabled(lv_action, true)
	GUI:setTag(lv_action, -1)

	-- Create Layout_res
	local Layout_res = GUI:Layout_Create(Layout_detail, "Layout_res", 419.00, 0.00, 283.00, 320.00, false)
	GUI:Layout_setBackGroundColorType(Layout_res, 1)
	GUI:Layout_setBackGroundColor(Layout_res, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_res, 153)
	GUI:setTouchEnabled(Layout_res, false)
	GUI:setTag(Layout_res, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_res, "Text", 10.00, 295.00, 16, "#ffffff", [[资源配置]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create btn_res
	local btn_res = GUI:Layout_Create(Layout_res, "btn_res", 10.00, 264.00, 70.00, 26.00, false)
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

	-- Create Text_res_name
	local Text_res_name = GUI:Text_Create(Layout_res, "Text_res_name", 84.00, 268.00, 14, "#ffffff", [[未选择文件]])
	GUI:setTouchEnabled(Text_res_name, false)
	GUI:setTag(Text_res_name, -1)
	GUI:Text_enableOutline(Text_res_name, "#000000", 1)

	-- Create Text_res_tip
	local Text_res_tip = GUI:Text_Create(Layout_res, "Text_res_tip", 8.00, 259.00, 14, "#ffffff", [[默认读取路径为res/private/damage_num
请将需要的图标放入该目录中]])
	GUI:setAnchorPoint(Text_res_tip, 0.00, 1.00)
	GUI:setTouchEnabled(Text_res_tip, false)
	GUI:setTag(Text_res_tip, -1)
	GUI:Text_enableOutline(Text_res_tip, "#000000", 1)

	-- Create Layout_show
	local Layout_show = GUI:Layout_Create(Layout_res, "Layout_show", 6.00, 5.00, 272.00, 180.00, false)
	GUI:Layout_setBackGroundColorType(Layout_show, 1)
	GUI:Layout_setBackGroundColor(Layout_show, "#ccf783")
	GUI:Layout_setBackGroundColorOpacity(Layout_show, 229)
	GUI:setTouchEnabled(Layout_show, false)
	GUI:setTag(Layout_show, -1)

	-- Create img_res
	local img_res = GUI:Image_Create(Layout_res, "img_res", 5.00, 207.00, "res/private/gui_edit/ImageFile.png")
	GUI:setAnchorPoint(img_res, 0.00, 0.50)
	GUI:setTouchEnabled(img_res, false)
	GUI:setTag(img_res, -1)

	-- Create bg_input_id
	local bg_input_id = GUI:Image_Create(Layout_content, "bg_input_id", 369.00, 520.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input_id, 0, 0, 0, 0)
	GUI:setContentSize(bg_input_id, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input_id, false)
	GUI:setTouchEnabled(bg_input_id, false)
	GUI:setTag(bg_input_id, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_input_id, "Text", 0.00, 13.00, 16, "#ffffff", [[飘字ID：]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_id
	local input_id = GUI:TextInput_Create(bg_input_id, "input_id", 0.00, 0.00, 96.00, 25.00, 16)
	GUI:TextInput_setString(input_id, "")
	GUI:TextInput_setFontColor(input_id, "#ffffff")
	GUI:setTouchEnabled(input_id, true)
	GUI:setTag(input_id, -1)

	-- Create Text_notice
	local Text_notice = GUI:Text_Create(Layout_content, "Text_notice", 120.00, 5.00, 18, "#00fb00", [[飘血动画 先记录动作 再点击点击保存]])
	GUI:setTouchEnabled(Text_notice, false)
	GUI:setTag(Text_notice, -1)
	GUI:Text_enableOutline(Text_notice, "#000000", 1)

	-- Create Layout_enable
	local Layout_enable = GUI:Layout_Create(Layout_content, "Layout_enable", 30.00, 575.00, 150.00, 26.00, false)
	GUI:setAnchorPoint(Layout_enable, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_enable, true)
	GUI:setTag(Layout_enable, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_enable, "Text", 1.00, 13.00, 16, "#ffffff", [[开关：]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create CheckBox_able
	local CheckBox_able = GUI:Layout_Create(Layout_enable, "CheckBox_able", 50.00, 12.00, 44.00, 18.00, false)
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
end
return ui