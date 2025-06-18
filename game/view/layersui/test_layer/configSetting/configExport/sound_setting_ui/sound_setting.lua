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

	-- Create Panel_info1
	local Panel_info1 = GUI:Layout_Create(Panel_main, "Panel_info1", 0.00, 0.00, 460.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_info1, 1)
	GUI:Layout_setBackGroundColor(Panel_info1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_info1, 12)
	GUI:setTouchEnabled(Panel_info1, false)
	GUI:setTag(Panel_info1, -1)

	-- Create img_title1
	local img_title1 = GUI:Image_Create(Panel_info1, "img_title1", 230.00, 610.00, "res/public/1900015004.png")
	GUI:setContentSize(img_title1, 200, 40)
	GUI:setIgnoreContentAdaptWithSize(img_title1, false)
	GUI:setAnchorPoint(img_title1, 0.50, 0.50)
	GUI:setTouchEnabled(img_title1, false)
	GUI:setTag(img_title1, -1)

	-- Create Text_title1
	local Text_title1 = GUI:Text_Create(Panel_info1, "Text_title1", 230.00, 610.00, 22, "#ffffff", [[官方声音列表]])
	GUI:setAnchorPoint(Text_title1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_title1, false)
	GUI:setTag(Text_title1, -1)
	GUI:Text_enableOutline(Text_title1, "#000000", 1)

	-- Create img_inputBg1
	local img_inputBg1 = GUI:Image_Create(Panel_info1, "img_inputBg1", 180.00, 560.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg1, 240, 30)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg1, false)
	GUI:setAnchorPoint(img_inputBg1, 0.50, 0.50)
	GUI:setTouchEnabled(img_inputBg1, false)
	GUI:setTag(img_inputBg1, -1)

	-- Create Input_search1
	local Input_search1 = GUI:TextInput_Create(Panel_info1, "Input_search1", 180.00, 560.00, 240.00, 30.00, 16)
	GUI:TextInput_setString(Input_search1, "")
	GUI:TextInput_setPlaceHolder(Input_search1, "请输入声音id.......")
	GUI:TextInput_setFontColor(Input_search1, "#ffffff")
	GUI:setAnchorPoint(Input_search1, 0.50, 0.50)
	GUI:setTouchEnabled(Input_search1, true)
	GUI:setTag(Input_search1, -1)

	-- Create Button_search1
	local Button_search1 = GUI:Button_Create(Panel_info1, "Button_search1", 335.00, 560.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_search1, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_search1, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_search1, 0, 0, 0, 0)
	GUI:setContentSize(Button_search1, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_search1, false)
	GUI:Button_setTitleText(Button_search1, "搜索")
	GUI:Button_setTitleColor(Button_search1, "#39b5ef")
	GUI:Button_setTitleFontSize(Button_search1, 14)
	GUI:Button_titleEnableOutline(Button_search1, "#000000", 1)
	GUI:setAnchorPoint(Button_search1, 0.50, 0.50)
	GUI:setTouchEnabled(Button_search1, true)
	GUI:setTag(Button_search1, -1)

	-- Create ListView_info1
	local ListView_info1 = GUI:ListView_Create(Panel_info1, "ListView_info1", 0.00, 50.00, 460.00, 450.00, 1)
	GUI:ListView_setBackGroundColorType(ListView_info1, 1)
	GUI:ListView_setBackGroundColor(ListView_info1, "#000000")
	GUI:ListView_setBackGroundColorOpacity(ListView_info1, 91)
	GUI:ListView_setGravity(ListView_info1, 2)
	GUI:ListView_setItemsMargin(ListView_info1, 2)
	GUI:setTouchEnabled(ListView_info1, true)
	GUI:setTag(ListView_info1, -1)

	-- Create Text_info_1_1
	local Text_info_1_1 = GUI:Text_Create(Panel_info1, "Text_info_1_1", 50.00, 515.00, 16, "#ffffff", [[ID]])
	GUI:setAnchorPoint(Text_info_1_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info_1_1, false)
	GUI:setTag(Text_info_1_1, -1)
	GUI:Text_enableOutline(Text_info_1_1, "#000000", 1)

	-- Create Text_info_1_2
	local Text_info_1_2 = GUI:Text_Create(Panel_info1, "Text_info_1_2", 150.00, 515.00, 16, "#ffffff", [[文件名]])
	GUI:setAnchorPoint(Text_info_1_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info_1_2, false)
	GUI:setTag(Text_info_1_2, -1)
	GUI:Text_enableOutline(Text_info_1_2, "#000000", 1)

	-- Create Text_info_1_3
	local Text_info_1_3 = GUI:Text_Create(Panel_info1, "Text_info_1_3", 300.00, 515.00, 16, "#ffffff", [[备注]])
	GUI:setAnchorPoint(Text_info_1_3, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info_1_3, false)
	GUI:setTag(Text_info_1_3, -1)
	GUI:Text_enableOutline(Text_info_1_3, "#000000", 1)

	-- Create Panel_info2
	local Panel_info2 = GUI:Layout_Create(Panel_main, "Panel_info2", 936.00, 0.00, 460.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_info2, 1)
	GUI:Layout_setBackGroundColor(Panel_info2, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_info2, 12)
	GUI:setAnchorPoint(Panel_info2, 1.00, 0.00)
	GUI:setTouchEnabled(Panel_info2, false)
	GUI:setTag(Panel_info2, -1)

	-- Create img_title2
	local img_title2 = GUI:Image_Create(Panel_info2, "img_title2", 230.00, 610.00, "res/public/1900015004.png")
	GUI:setContentSize(img_title2, 200, 40)
	GUI:setIgnoreContentAdaptWithSize(img_title2, false)
	GUI:setAnchorPoint(img_title2, 0.50, 0.50)
	GUI:setTouchEnabled(img_title2, false)
	GUI:setTag(img_title2, -1)

	-- Create Text_title2
	local Text_title2 = GUI:Text_Create(Panel_info2, "Text_title2", 230.00, 610.00, 22, "#ffffff", [[自定义声音列表]])
	GUI:setAnchorPoint(Text_title2, 0.50, 0.50)
	GUI:setTouchEnabled(Text_title2, false)
	GUI:setTag(Text_title2, -1)
	GUI:Text_enableOutline(Text_title2, "#000000", 1)

	-- Create img_inputBg2
	local img_inputBg2 = GUI:Image_Create(Panel_info2, "img_inputBg2", 180.00, 560.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg2, 240, 30)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg2, false)
	GUI:setAnchorPoint(img_inputBg2, 0.50, 0.50)
	GUI:setTouchEnabled(img_inputBg2, false)
	GUI:setTag(img_inputBg2, -1)

	-- Create Input_search2
	local Input_search2 = GUI:TextInput_Create(Panel_info2, "Input_search2", 180.00, 560.00, 240.00, 30.00, 16)
	GUI:TextInput_setString(Input_search2, "")
	GUI:TextInput_setPlaceHolder(Input_search2, "请输入声音id.......")
	GUI:TextInput_setFontColor(Input_search2, "#ffffff")
	GUI:setAnchorPoint(Input_search2, 0.50, 0.50)
	GUI:setTouchEnabled(Input_search2, true)
	GUI:setTag(Input_search2, -1)

	-- Create Button_search2
	local Button_search2 = GUI:Button_Create(Panel_info2, "Button_search2", 335.00, 560.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_search2, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_search2, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_search2, 0, 0, 0, 0)
	GUI:setContentSize(Button_search2, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_search2, false)
	GUI:Button_setTitleText(Button_search2, "搜索")
	GUI:Button_setTitleColor(Button_search2, "#39b5ef")
	GUI:Button_setTitleFontSize(Button_search2, 14)
	GUI:Button_titleEnableOutline(Button_search2, "#000000", 1)
	GUI:setAnchorPoint(Button_search2, 0.50, 0.50)
	GUI:setTouchEnabled(Button_search2, true)
	GUI:setTag(Button_search2, -1)

	-- Create ListView_info2
	local ListView_info2 = GUI:ListView_Create(Panel_info2, "ListView_info2", 0.00, 50.00, 460.00, 420.00, 1)
	GUI:ListView_setBackGroundColorType(ListView_info2, 1)
	GUI:ListView_setBackGroundColor(ListView_info2, "#000000")
	GUI:ListView_setBackGroundColorOpacity(ListView_info2, 99)
	GUI:ListView_setGravity(ListView_info2, 2)
	GUI:ListView_setItemsMargin(ListView_info2, 2)
	GUI:setTouchEnabled(ListView_info2, true)
	GUI:setTag(ListView_info2, -1)

	-- Create Text_info
	local Text_info = GUI:Text_Create(Panel_info2, "Text_info", 230.00, 520.00, 16, "#ffffff", [[客户端音效目录：mp3/xxx.mp3]])
	GUI:setAnchorPoint(Text_info, 0.50, 0.50)
	GUI:setTouchEnabled(Text_info, false)
	GUI:setTag(Text_info, -1)
	GUI:Text_enableOutline(Text_info, "#000000", 1)

	-- Create Text_info_1_1
	local Text_info_1_1 = GUI:Text_Create(Panel_info2, "Text_info_1_1", 50.00, 485.00, 16, "#ffffff", [[ID]])
	GUI:setAnchorPoint(Text_info_1_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info_1_1, false)
	GUI:setTag(Text_info_1_1, -1)
	GUI:Text_enableOutline(Text_info_1_1, "#000000", 1)

	-- Create Text_info_1_2
	local Text_info_1_2 = GUI:Text_Create(Panel_info2, "Text_info_1_2", 150.00, 485.00, 16, "#ffffff", [[文件名]])
	GUI:setAnchorPoint(Text_info_1_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info_1_2, false)
	GUI:setTag(Text_info_1_2, -1)
	GUI:Text_enableOutline(Text_info_1_2, "#000000", 1)

	-- Create Text_info_1_3
	local Text_info_1_3 = GUI:Text_Create(Panel_info2, "Text_info_1_3", 300.00, 485.00, 16, "#ffffff", [[备注]])
	GUI:setAnchorPoint(Text_info_1_3, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info_1_3, false)
	GUI:setTag(Text_info_1_3, -1)
	GUI:Text_enableOutline(Text_info_1_3, "#000000", 1)

	-- Create Button_add
	local Button_add = GUI:Button_Create(Panel_main, "Button_add", 500.00, 20.00, "res/private/gui_edit/Button_Normal.png")
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
	local Button_delete = GUI:Button_Create(Panel_main, "Button_delete", 560.00, 20.00, "res/private/gui_edit/Button_Normal.png")
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

	-- Create Panel_tips
	local Panel_tips = GUI:Layout_Create(Panel_main, "Panel_tips", 325.00, 150.00, 300.00, 250.00, false)
	GUI:Layout_setBackGroundColorType(Panel_tips, 1)
	GUI:Layout_setBackGroundColor(Panel_tips, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_tips, 153)
	GUI:setTouchEnabled(Panel_tips, false)
	GUI:setTag(Panel_tips, -1)
	GUI:setVisible(Panel_tips, false)

	-- Create Text_id
	local Text_id = GUI:Text_Create(Panel_tips, "Text_id", 30.00, 130.00, 16, "#ffffff", [[id：]])
	GUI:setTouchEnabled(Text_id, false)
	GUI:setTag(Text_id, -1)
	GUI:Text_enableOutline(Text_id, "#000000", 1)

	-- Create Input_id
	local Input_id = GUI:TextInput_Create(Panel_tips, "Input_id", 100.00, 130.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(Input_id, "")
	GUI:TextInput_setPlaceHolder(Input_id, "请输入.......")
	GUI:TextInput_setFontColor(Input_id, "#ffffff")
	GUI:setTouchEnabled(Input_id, true)
	GUI:setTag(Input_id, -1)

	-- Create Text_name
	local Text_name = GUI:Text_Create(Panel_tips, "Text_name", 30.00, 90.00, 16, "#ffffff", [[路径：]])
	GUI:setTouchEnabled(Text_name, false)
	GUI:setTag(Text_name, -1)
	GUI:Text_enableOutline(Text_name, "#000000", 1)

	-- Create Input_name
	local Input_name = GUI:TextInput_Create(Panel_tips, "Input_name", 100.00, 90.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(Input_name, "")
	GUI:TextInput_setPlaceHolder(Input_name, "请输入.......")
	GUI:TextInput_setFontColor(Input_name, "#ffffff")
	GUI:setTouchEnabled(Input_name, true)
	GUI:setTag(Input_name, -1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(Panel_tips, "Text_desc", 30.00, 50.00, 16, "#ffffff", [[备注：]])
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, -1)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create Input_desc
	local Input_desc = GUI:TextInput_Create(Panel_tips, "Input_desc", 100.00, 50.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(Input_desc, "")
	GUI:TextInput_setPlaceHolder(Input_desc, "请输入.......")
	GUI:TextInput_setFontColor(Input_desc, "#ffffff")
	GUI:setTouchEnabled(Input_desc, true)
	GUI:setTag(Input_desc, -1)

	-- Create Btn_yes
	local Btn_yes = GUI:Button_Create(Panel_tips, "Btn_yes", 100.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Btn_yes, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Btn_yes, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(Btn_yes, 45, 25)
	GUI:setIgnoreContentAdaptWithSize(Btn_yes, false)
	GUI:Button_setTitleText(Btn_yes, "确定")
	GUI:Button_setTitleColor(Btn_yes, "#10ff00")
	GUI:Button_setTitleFontSize(Btn_yes, 14)
	GUI:Button_titleEnableOutline(Btn_yes, "#000000", 1)
	GUI:setAnchorPoint(Btn_yes, 0.50, 0.50)
	GUI:setTouchEnabled(Btn_yes, true)
	GUI:setTag(Btn_yes, -1)

	-- Create Btn_no
	local Btn_no = GUI:Button_Create(Panel_tips, "Btn_no", 200.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Btn_no, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Btn_no, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(Btn_no, 45, 25)
	GUI:setIgnoreContentAdaptWithSize(Btn_no, false)
	GUI:Button_setTitleText(Btn_no, "取消")
	GUI:Button_setTitleColor(Btn_no, "#10ff00")
	GUI:Button_setTitleFontSize(Btn_no, 14)
	GUI:Button_titleEnableOutline(Btn_no, "#000000", 1)
	GUI:setAnchorPoint(Btn_no, 0.50, 0.50)
	GUI:setTouchEnabled(Btn_no, true)
	GUI:setTag(Btn_no, -1)

	-- Create Text_showName
	local Text_showName = GUI:Text_Create(Panel_tips, "Text_showName", 150.00, 220.00, 16, "#fb0000", [[]])
	GUI:setAnchorPoint(Text_showName, 0.50, 0.50)
	GUI:setTouchEnabled(Text_showName, false)
	GUI:setTag(Text_showName, -1)
	GUI:Text_enableOutline(Text_showName, "#000000", 1)

	-- Create Text_type
	local Text_type = GUI:Text_Create(Panel_tips, "Text_type", 30.00, 170.00, 16, "#ffffff", [[类型：]])
	GUI:setTouchEnabled(Text_type, false)
	GUI:setTag(Text_type, -1)
	GUI:Text_enableOutline(Text_type, "#000000", 1)

	-- Create img_itemBg
	local img_itemBg = GUI:Image_Create(Text_type, "img_itemBg", 70.00, 10.00, "res/public/1900015004.png")
	GUI:setContentSize(img_itemBg, 130, 30)
	GUI:setIgnoreContentAdaptWithSize(img_itemBg, false)
	GUI:setAnchorPoint(img_itemBg, 0.00, 0.50)
	GUI:setTouchEnabled(img_itemBg, false)
	GUI:setTag(img_itemBg, -1)

	-- Create Button_arrow
	local Button_arrow = GUI:Button_Create(Text_type, "Button_arrow", 188.00, 10.00, "res/public/1900000677_1.png")
	GUI:Button_loadTexturePressed(Button_arrow, "res/public/1900000677_1.png")
	GUI:Button_loadTextureDisabled(Button_arrow, "res/public/1900000677_1.png")
	GUI:Button_setTitleText(Button_arrow, "")
	GUI:Button_setTitleColor(Button_arrow, "#ffffff")
	GUI:Button_setTitleFontSize(Button_arrow, 14)
	GUI:Button_titleEnableOutline(Button_arrow, "#000000", 1)
	GUI:setAnchorPoint(Button_arrow, 0.50, 0.50)
	GUI:setRotation(Button_arrow, 90.00)
	GUI:setRotationSkewX(Button_arrow, 90.00)
	GUI:setRotationSkewY(Button_arrow, 90.00)
	GUI:setTouchEnabled(Button_arrow, true)
	GUI:setTag(Button_arrow, -1)

	-- Create Text_show
	local Text_show = GUI:Text_Create(Text_type, "Text_show", 125.00, 10.00, 16, "#ffffff", [[下拉选择]])
	GUI:setAnchorPoint(Text_show, 0.50, 0.50)
	GUI:setTouchEnabled(Text_show, false)
	GUI:setTag(Text_show, -1)
	GUI:Text_enableOutline(Text_show, "#000000", 1)

	-- Create ListView_item
	local ListView_item = GUI:ListView_Create(Text_type, "ListView_item", 70.00, -204.00, 130.00, 200.00, 1)
	GUI:ListView_setBackGroundColorType(ListView_item, 1)
	GUI:ListView_setBackGroundColor(ListView_item, "#c0c0c0")
	GUI:ListView_setBackGroundColorOpacity(ListView_item, 201)
	GUI:ListView_setGravity(ListView_item, 5)
	GUI:setTouchEnabled(ListView_item, true)
	GUI:setTag(ListView_item, -1)
	GUI:setVisible(ListView_item, false)

	-- Create Panel_item
	local Panel_item = GUI:Layout_Create(Panel_tips, "Panel_item", 324.00, 120.00, 130.00, 30.00, true)
	GUI:setTouchEnabled(Panel_item, true)
	GUI:setTag(Panel_item, -1)
	GUI:setVisible(Panel_item, false)

	-- Create Text_typeName
	local Text_typeName = GUI:Text_Create(Panel_item, "Text_typeName", 65.00, 15.00, 16, "#ffffff", [[施法声音]])
	GUI:setAnchorPoint(Text_typeName, 0.50, 0.50)
	GUI:setTouchEnabled(Text_typeName, false)
	GUI:setTag(Text_typeName, -1)
	GUI:Text_enableOutline(Text_typeName, "#000000", 1)
end
return ui