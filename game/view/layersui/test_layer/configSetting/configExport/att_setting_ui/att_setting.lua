local ui = {}
function ui.init(parent)
	-- Create Layer
	local Layer = GUI:Node_Create(parent, "Layer", 0.00, 0.00)
	GUI:setAnchorPoint(Layer, 0.50, 0.50)
	GUI:setTag(Layer, -1)

	-- Create Panel_main
	local Panel_main = GUI:Layout_Create(Layer, "Panel_main", 0.00, 0.00, 936.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_main, 1)
	GUI:Layout_setBackGroundColor(Panel_main, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_main, 76)
	GUI:setTouchEnabled(Panel_main, false)
	GUI:setTag(Panel_main, 4)

	-- Create Panel_menu1
	local Panel_menu1 = GUI:Layout_Create(Panel_main, "Panel_menu1", 0.00, 0.00, 480.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_menu1, 1)
	GUI:Layout_setBackGroundColor(Panel_menu1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_menu1, 76)
	GUI:setTouchEnabled(Panel_menu1, false)
	GUI:setTag(Panel_menu1, -1)

	-- Create ListView_menu1
	local ListView_menu1 = GUI:ListView_Create(Panel_menu1, "ListView_menu1", 0.00, 0.00, 480.00, 580.00, 1)
	GUI:ListView_setGravity(ListView_menu1, 2)
	GUI:ListView_setItemsMargin(ListView_menu1, 2)
	GUI:setTouchEnabled(ListView_menu1, true)
	GUI:setTag(ListView_menu1, -1)

	-- Create Text_info1
	local Text_info1 = GUI:Text_Create(Panel_menu1, "Text_info1", 20.00, 600.00, 16, "#ffffff", [[Id]])
	GUI:setAnchorPoint(Text_info1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_info1, false)
	GUI:setTag(Text_info1, -1)
	GUI:Text_enableOutline(Text_info1, "#000000", 1)

	-- Create Text_info2
	local Text_info2 = GUI:Text_Create(Panel_menu1, "Text_info2", 110.00, 600.00, 16, "#ffffff", [[名称]])
	GUI:setAnchorPoint(Text_info2, 0.50, 0.50)
	GUI:setTouchEnabled(Text_info2, false)
	GUI:setTag(Text_info2, -1)
	GUI:Text_enableOutline(Text_info2, "#000000", 1)

	-- Create Text_info3
	local Text_info3 = GUI:Text_Create(Panel_menu1, "Text_info3", 200.00, 600.00, 16, "#ffffff", [[类型]])
	GUI:setAnchorPoint(Text_info3, 0.50, 0.50)
	GUI:setTouchEnabled(Text_info3, false)
	GUI:setTag(Text_info3, -1)
	GUI:Text_enableOutline(Text_info3, "#000000", 1)

	-- Create Text_info4
	local Text_info4 = GUI:Text_Create(Panel_menu1, "Text_info4", 280.00, 600.00, 16, "#ffffff", [[显示Tips]])
	GUI:setAnchorPoint(Text_info4, 0.50, 0.50)
	GUI:setTouchEnabled(Text_info4, false)
	GUI:setTag(Text_info4, -1)
	GUI:Text_enableOutline(Text_info4, "#000000", 1)

	-- Create Text_info5
	local Text_info5 = GUI:Text_Create(Panel_menu1, "Text_info5", 360.00, 600.00, 16, "#ffffff", [[排序]])
	GUI:setAnchorPoint(Text_info5, 0.50, 0.50)
	GUI:setTouchEnabled(Text_info5, false)
	GUI:setTag(Text_info5, -1)
	GUI:Text_enableOutline(Text_info5, "#000000", 1)

	-- Create Text_info6
	local Text_info6 = GUI:Text_Create(Panel_menu1, "Text_info6", 440.00, 600.00, 16, "#ffffff", [[是否元素]])
	GUI:setAnchorPoint(Text_info6, 0.50, 0.50)
	GUI:setTouchEnabled(Text_info6, false)
	GUI:setTag(Text_info6, -1)
	GUI:Text_enableOutline(Text_info6, "#000000", 1)

	-- Create Panel_info
	local Panel_info = GUI:Layout_Create(Panel_main, "Panel_info", 936.00, 0.00, 450.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_info, 1)
	GUI:Layout_setBackGroundColor(Panel_info, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_info, 76)
	GUI:setAnchorPoint(Panel_info, 1.00, 0.00)
	GUI:setTouchEnabled(Panel_info, false)
	GUI:setTag(Panel_info, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_info, "Text_1", 20.00, 600.00, 16, "#ffffff", [[属性Id：]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create img_inputBg1
	local img_inputBg1 = GUI:Image_Create(Panel_info, "img_inputBg1", 110.00, 600.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg1, 110, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg1, false)
	GUI:setAnchorPoint(img_inputBg1, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg1, false)
	GUI:setTag(img_inputBg1, -1)

	-- Create Input_id
	local Input_id = GUI:TextInput_Create(Panel_info, "Input_id", 110.00, 600.00, 110.00, 24.00, 16)
	GUI:TextInput_setString(Input_id, "")
	GUI:TextInput_setFontColor(Input_id, "#ffffff")
	GUI:setAnchorPoint(Input_id, 0.00, 0.50)
	GUI:setTouchEnabled(Input_id, true)
	GUI:setTag(Input_id, -1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Panel_info, "Text_2", 20.00, 560.00, 16, "#ffffff", [[属性名称：]])
	GUI:setAnchorPoint(Text_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, -1)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create img_inputBg2
	local img_inputBg2 = GUI:Image_Create(Panel_info, "img_inputBg2", 110.00, 560.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg2, 110, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg2, false)
	GUI:setAnchorPoint(img_inputBg2, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg2, false)
	GUI:setTag(img_inputBg2, -1)

	-- Create Input_name
	local Input_name = GUI:TextInput_Create(Panel_info, "Input_name", 110.00, 560.00, 110.00, 24.00, 16)
	GUI:TextInput_setString(Input_name, "")
	GUI:TextInput_setFontColor(Input_name, "#ffffff")
	GUI:setAnchorPoint(Input_name, 0.00, 0.50)
	GUI:setTouchEnabled(Input_name, true)
	GUI:setTag(Input_name, -1)

	-- Create Text_3
	local Text_3 = GUI:Text_Create(Panel_info, "Text_3", 21.00, 520.00, 16, "#ffffff", [[数值类型：]])
	GUI:setAnchorPoint(Text_3, 0.00, 0.50)
	GUI:setTouchEnabled(Text_3, false)
	GUI:setTag(Text_3, -1)
	GUI:Text_enableOutline(Text_3, "#000000", 1)

	-- Create Text
	local Text = GUI:Text_Create(Text_3, "Text", 210.00, 0.00, 14, "#a0a0a4", [[1数值,2万分比,3百分比]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create img_inputBg3
	local img_inputBg3 = GUI:Image_Create(Panel_info, "img_inputBg3", 110.00, 520.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg3, 110, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg3, false)
	GUI:setAnchorPoint(img_inputBg3, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg3, false)
	GUI:setTag(img_inputBg3, -1)

	-- Create Input_type
	local Input_type = GUI:TextInput_Create(Panel_info, "Input_type", 110.00, 520.00, 110.00, 24.00, 16)
	GUI:TextInput_setString(Input_type, "")
	GUI:TextInput_setFontColor(Input_type, "#ffffff")
	GUI:setAnchorPoint(Input_type, 0.00, 0.50)
	GUI:setTouchEnabled(Input_type, true)
	GUI:setTag(Input_type, -1)

	-- Create Text_5
	local Text_5 = GUI:Text_Create(Panel_info, "Text_5", 20.00, 480.00, 16, "#ffffff", [[位置排序：]])
	GUI:setAnchorPoint(Text_5, 0.00, 0.50)
	GUI:setTouchEnabled(Text_5, false)
	GUI:setTag(Text_5, -1)
	GUI:Text_enableOutline(Text_5, "#000000", 1)

	-- Create img_inputBg5
	local img_inputBg5 = GUI:Image_Create(Panel_info, "img_inputBg5", 110.00, 480.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg5, 110, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg5, false)
	GUI:setAnchorPoint(img_inputBg5, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg5, false)
	GUI:setTag(img_inputBg5, -1)

	-- Create Input_sort
	local Input_sort = GUI:TextInput_Create(Panel_info, "Input_sort", 110.00, 480.00, 110.00, 24.00, 16)
	GUI:TextInput_setString(Input_sort, "")
	GUI:TextInput_setFontColor(Input_sort, "#ffffff")
	GUI:setAnchorPoint(Input_sort, 0.00, 0.50)
	GUI:setTouchEnabled(Input_sort, true)
	GUI:setTag(Input_sort, -1)

	-- Create Text_6
	local Text_6 = GUI:Text_Create(Panel_info, "Text_6", 20.00, 440.00, 16, "#ffffff", [[显示Tips：]])
	GUI:setAnchorPoint(Text_6, 0.00, 0.50)
	GUI:setTouchEnabled(Text_6, false)
	GUI:setTag(Text_6, -1)
	GUI:Text_enableOutline(Text_6, "#000000", 1)

	-- Create Text
	local Text = GUI:Text_Create(Text_6, "Text", 210.00, 0.00, 14, "#a0a0a4", [[0不显示,1固定显示,2有属性显示]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create img_inputBg6
	local img_inputBg6 = GUI:Image_Create(Panel_info, "img_inputBg6", 110.00, 440.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg6, 110, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg6, false)
	GUI:setAnchorPoint(img_inputBg6, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg6, false)
	GUI:setTag(img_inputBg6, -1)

	-- Create Input_show
	local Input_show = GUI:TextInput_Create(Panel_info, "Input_show", 110.00, 440.00, 110.00, 24.00, 16)
	GUI:TextInput_setString(Input_show, "")
	GUI:TextInput_setFontColor(Input_show, "#ffffff")
	GUI:setAnchorPoint(Input_show, 0.00, 0.50)
	GUI:setTouchEnabled(Input_show, true)
	GUI:setTag(Input_show, -1)

	-- Create Text_7
	local Text_7 = GUI:Text_Create(Panel_info, "Text_7", 20.00, 400.00, 16, "#ffffff", [[装备Tips：]])
	GUI:setAnchorPoint(Text_7, 0.00, 0.50)
	GUI:setTouchEnabled(Text_7, false)
	GUI:setTag(Text_7, -1)
	GUI:Text_enableOutline(Text_7, "#000000", 1)

	-- Create Text
	local Text = GUI:Text_Create(Text_7, "Text", 210.00, 0.00, 14, "#a0a0a4", [[0或空=显示,1=不显示]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create img_inputBg7
	local img_inputBg7 = GUI:Image_Create(Panel_info, "img_inputBg7", 110.00, 400.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg7, 110, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg7, false)
	GUI:setAnchorPoint(img_inputBg7, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg7, false)
	GUI:setTag(img_inputBg7, -1)

	-- Create Input_equipTips
	local Input_equipTips = GUI:TextInput_Create(Panel_info, "Input_equipTips", 110.00, 400.00, 110.00, 26.00, 16)
	GUI:TextInput_setString(Input_equipTips, "")
	GUI:TextInput_setFontColor(Input_equipTips, "#ffffff")
	GUI:setAnchorPoint(Input_equipTips, 0.00, 0.50)
	GUI:setTouchEnabled(Input_equipTips, true)
	GUI:setTag(Input_equipTips, -1)

	-- Create Text_8
	local Text_8 = GUI:Text_Create(Panel_info, "Text_8", 20.00, 360.00, 16, "#ffffff", [[元素属性：]])
	GUI:setAnchorPoint(Text_8, 0.00, 0.50)
	GUI:setTouchEnabled(Text_8, false)
	GUI:setTag(Text_8, -1)
	GUI:Text_enableOutline(Text_8, "#000000", 1)

	-- Create CB_yuansu
	local CB_yuansu = GUI:CheckBox_Create(Panel_info, "CB_yuansu", 110.00, 360.00, "res/public/1900000682.png", "res/public/1900000683.png")
	GUI:CheckBox_setSelected(CB_yuansu, false)
	GUI:setAnchorPoint(CB_yuansu, 0.00, 0.50)
	GUI:setTouchEnabled(CB_yuansu, true)
	GUI:setTag(CB_yuansu, -1)

	-- Create Text_9
	local Text_9 = GUI:Text_Create(Panel_info, "Text_9", 20.00, 320.00, 16, "#ffffff", [[颜色：]])
	GUI:setAnchorPoint(Text_9, 0.00, 0.50)
	GUI:setTouchEnabled(Text_9, false)
	GUI:setTag(Text_9, -1)
	GUI:Text_enableOutline(Text_9, "#000000", 1)

	-- Create Text
	local Text = GUI:Text_Create(Text_9, "Text", 300.00, 0.00, 14, "#a0a0a4", [[0-255数值]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create img_inputBg9
	local img_inputBg9 = GUI:Image_Create(Panel_info, "img_inputBg9", 180.00, 320.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg9, 110, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg9, false)
	GUI:setAnchorPoint(img_inputBg9, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg9, false)
	GUI:setTag(img_inputBg9, -1)

	-- Create Input_color
	local Input_color = GUI:TextInput_Create(Panel_info, "Input_color", 180.00, 320.00, 110.00, 24.00, 16)
	GUI:TextInput_setString(Input_color, "")
	GUI:TextInput_setFontColor(Input_color, "#ffffff")
	GUI:setAnchorPoint(Input_color, 0.00, 0.50)
	GUI:setTouchEnabled(Input_color, true)
	GUI:setTag(Input_color, -1)

	-- Create panel_color
	local panel_color = GUI:Layout_Create(Panel_info, "panel_color", 110.00, 320.00, 30.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(panel_color, 1)
	GUI:Layout_setBackGroundColor(panel_color, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(panel_color, 255)
	GUI:setAnchorPoint(panel_color, 0.00, 0.50)
	GUI:setTouchEnabled(panel_color, false)
	GUI:setTag(panel_color, -1)

	-- Create Text_10
	local Text_10 = GUI:Text_Create(Panel_info, "Text_10", 20.00, 240.00, 16, "#ffffff", [[备注说明：]])
	GUI:setAnchorPoint(Text_10, 0.00, 0.50)
	GUI:setTouchEnabled(Text_10, false)
	GUI:setTag(Text_10, -1)
	GUI:Text_enableOutline(Text_10, "#000000", 1)

	-- Create img_inputBg10
	local img_inputBg10 = GUI:Image_Create(Panel_info, "img_inputBg10", 20.00, 140.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg10, 250, 80)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg10, false)
	GUI:setTouchEnabled(img_inputBg10, false)
	GUI:setTag(img_inputBg10, -1)

	-- Create Input_desc
	local Input_desc = GUI:TextInput_Create(Panel_info, "Input_desc", 20.00, 140.00, 250.00, 80.00, 16)
	GUI:TextInput_setString(Input_desc, "")
	GUI:TextInput_setFontColor(Input_desc, "#ffffff")
	GUI:setTouchEnabled(Input_desc, true)
	GUI:setTag(Input_desc, -1)

	-- Create Text_11
	local Text_11 = GUI:Text_Create(Panel_info, "Text_11", 20.00, 280.00, 16, "#ffffff", [[附加颜色：]])
	GUI:setAnchorPoint(Text_11, 0.00, 0.50)
	GUI:setTouchEnabled(Text_11, false)
	GUI:setTag(Text_11, -1)
	GUI:Text_enableOutline(Text_11, "#000000", 1)

	-- Create Text
	local Text = GUI:Text_Create(Text_11, "Text", 300.00, 0.00, 14, "#a0a0a4", [[0-255数值]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create img_inputBg11
	local img_inputBg11 = GUI:Image_Create(Panel_info, "img_inputBg11", 180.00, 280.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg11, 110, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg11, false)
	GUI:setAnchorPoint(img_inputBg11, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg11, false)
	GUI:setTag(img_inputBg11, -1)

	-- Create Input_excolor
	local Input_excolor = GUI:TextInput_Create(Panel_info, "Input_excolor", 180.00, 280.00, 110.00, 24.00, 16)
	GUI:TextInput_setString(Input_excolor, "")
	GUI:TextInput_setFontColor(Input_excolor, "#ffffff")
	GUI:setAnchorPoint(Input_excolor, 0.00, 0.50)
	GUI:setTouchEnabled(Input_excolor, true)
	GUI:setTag(Input_excolor, -1)

	-- Create panel_excolor
	local panel_excolor = GUI:Layout_Create(Panel_info, "panel_excolor", 110.00, 280.00, 30.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(panel_excolor, 1)
	GUI:Layout_setBackGroundColor(panel_excolor, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(panel_excolor, 255)
	GUI:setAnchorPoint(panel_excolor, 0.00, 0.50)
	GUI:setTouchEnabled(panel_excolor, false)
	GUI:setTag(panel_excolor, -1)

	-- Create Button_save
	local Button_save = GUI:Button_Create(Panel_main, "Button_save", 905.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_save, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_save, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_save, 15, 16, 12, 12)
	GUI:setContentSize(Button_save, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_save, false)
	GUI:Button_setTitleText(Button_save, "保存")
	GUI:Button_setTitleColor(Button_save, "#10ff00")
	GUI:Button_setTitleFontSize(Button_save, 14)
	GUI:Button_titleEnableOutline(Button_save, "#000000", 1)
	GUI:setAnchorPoint(Button_save, 0.50, 0.50)
	GUI:setTouchEnabled(Button_save, true)
	GUI:setTag(Button_save, -1)

	-- Create Button_add
	local Button_add = GUI:Button_Create(Panel_main, "Button_add", 570.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_add, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_add, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_add, 0, 0, 0, 0)
	GUI:setContentSize(Button_add, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_add, false)
	GUI:Button_setTitleText(Button_add, "添加")
	GUI:Button_setTitleColor(Button_add, "#10ff00")
	GUI:Button_setTitleFontSize(Button_add, 14)
	GUI:Button_titleEnableOutline(Button_add, "#000000", 1)
	GUI:setAnchorPoint(Button_add, 0.50, 0.50)
	GUI:setTouchEnabled(Button_add, true)
	GUI:setTag(Button_add, -1)

	-- Create Button_delete
	local Button_delete = GUI:Button_Create(Panel_main, "Button_delete", 640.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_delete, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_delete, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_delete, 0, 0, 0, 0)
	GUI:setContentSize(Button_delete, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_delete, false)
	GUI:Button_setTitleText(Button_delete, "删除")
	GUI:Button_setTitleColor(Button_delete, "#10ff00")
	GUI:Button_setTitleFontSize(Button_delete, 14)
	GUI:Button_titleEnableOutline(Button_delete, "#000000", 1)
	GUI:setAnchorPoint(Button_delete, 0.50, 0.50)
	GUI:setTouchEnabled(Button_delete, true)
	GUI:setTag(Button_delete, -1)
end
return ui