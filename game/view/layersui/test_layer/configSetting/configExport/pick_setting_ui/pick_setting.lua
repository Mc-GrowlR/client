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

	-- Create Panel_menu
	local Panel_menu = GUI:Layout_Create(Panel_main, "Panel_menu", 0.00, 0.00, 400.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_menu, 1)
	GUI:Layout_setBackGroundColor(Panel_menu, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_menu, 76)
	GUI:setTouchEnabled(Panel_menu, false)
	GUI:setTag(Panel_menu, -1)

	-- Create ListView_menu
	local ListView_menu = GUI:ListView_Create(Panel_menu, "ListView_menu", 0.00, 0.00, 400.00, 580.00, 1)
	GUI:ListView_setGravity(ListView_menu, 2)
	GUI:ListView_setItemsMargin(ListView_menu, 2)
	GUI:setTouchEnabled(ListView_menu, true)
	GUI:setTag(ListView_menu, -1)

	-- Create Text_info1
	local Text_info1 = GUI:Text_Create(Panel_menu, "Text_info1", 80.00, 600.00, 16, "#ffffff", [[组别]])
	GUI:setAnchorPoint(Text_info1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info1, false)
	GUI:setTag(Text_info1, -1)
	GUI:Text_enableOutline(Text_info1, "#000000", 1)

	-- Create Text_info2
	local Text_info2 = GUI:Text_Create(Panel_menu, "Text_info2", 220.00, 600.00, 16, "#ffffff", [[分类名称]])
	GUI:setAnchorPoint(Text_info2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info2, false)
	GUI:setTag(Text_info2, -1)
	GUI:Text_enableOutline(Text_info2, "#000000", 1)

	-- Create Panel_info
	local Panel_info = GUI:Layout_Create(Panel_main, "Panel_info", 936.00, 0.00, 500.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_info, 1)
	GUI:Layout_setBackGroundColor(Panel_info, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_info, 76)
	GUI:setAnchorPoint(Panel_info, 1.00, 0.00)
	GUI:setTouchEnabled(Panel_info, false)
	GUI:setTag(Panel_info, -1)

	-- Create Text_info3
	local Text_info3 = GUI:Text_Create(Panel_info, "Text_info3", 20.00, 600.00, 16, "#ffffff", [[说明：]])
	GUI:setAnchorPoint(Text_info3, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info3, false)
	GUI:setTag(Text_info3, -1)
	GUI:Text_enableOutline(Text_info3, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_info3, "img_inputBg", 0.00, -10.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 400, 200)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(Text_info3, "Text_desc", 10.00, -20.00, 16, "#ffffff", [[该功能为内挂拾取分类定义名称
相关的ID需要填入（cfg_equip.xls/cfg_item.xls）第21列Pickset字段中]])
	GUI:setIgnoreContentAdaptWithSize(Text_desc, false)
	GUI:Text_setTextAreaSize(Text_desc, 380, 180)
	GUI:setAnchorPoint(Text_desc, 0.00, 1.00)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, -1)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

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

	-- Create Button_edit
	local Button_edit = GUI:Button_Create(Panel_main, "Button_edit", 710.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_edit, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_edit, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_edit, 0, 0, 0, 0)
	GUI:setContentSize(Button_edit, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_edit, false)
	GUI:Button_setTitleText(Button_edit, "编辑")
	GUI:Button_setTitleColor(Button_edit, "#10ff00")
	GUI:Button_setTitleFontSize(Button_edit, 14)
	GUI:Button_titleEnableOutline(Button_edit, "#000000", 1)
	GUI:setAnchorPoint(Button_edit, 0.50, 0.50)
	GUI:setTouchEnabled(Button_edit, true)
	GUI:setTag(Button_edit, -1)

	-- Create Panel_tips
	local Panel_tips = GUI:Layout_Create(Panel_main, "Panel_tips", 540.00, 130.00, 200.00, 120.00, false)
	GUI:Layout_setBackGroundColorType(Panel_tips, 1)
	GUI:Layout_setBackGroundColor(Panel_tips, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_tips, 153)
	GUI:setTouchEnabled(Panel_tips, false)
	GUI:setTag(Panel_tips, -1)
	GUI:setVisible(Panel_tips, false)

	-- Create Input_group
	local Input_group = GUI:TextInput_Create(Panel_tips, "Input_group", 100.00, 100.00, 120.00, 25.00, 16)
	GUI:TextInput_setString(Input_group, "")
	GUI:TextInput_setPlaceHolder(Input_group, "请输入组别.......")
	GUI:TextInput_setFontColor(Input_group, "#ffffff")
	GUI:setAnchorPoint(Input_group, 0.50, 0.50)
	GUI:setTouchEnabled(Input_group, true)
	GUI:setTag(Input_group, -1)

	-- Create Input_name
	local Input_name = GUI:TextInput_Create(Panel_tips, "Input_name", 100.00, 60.00, 120.00, 25.00, 16)
	GUI:TextInput_setString(Input_name, "")
	GUI:TextInput_setPlaceHolder(Input_name, "请输入名称.......")
	GUI:TextInput_setFontColor(Input_name, "#ffffff")
	GUI:setAnchorPoint(Input_name, 0.50, 0.50)
	GUI:setTouchEnabled(Input_name, true)
	GUI:setTag(Input_name, -1)

	-- Create Btn_yes
	local Btn_yes = GUI:Button_Create(Panel_tips, "Btn_yes", 50.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Btn_yes, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Btn_yes, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(Btn_yes, 45, 25)
	GUI:setIgnoreContentAdaptWithSize(Btn_yes, false)
	GUI:Button_setTitleText(Btn_yes, "确定")
	GUI:Button_setTitleColor(Btn_yes, "#39b5ef")
	GUI:Button_setTitleFontSize(Btn_yes, 14)
	GUI:Button_titleEnableOutline(Btn_yes, "#000000", 1)
	GUI:setAnchorPoint(Btn_yes, 0.50, 0.50)
	GUI:setTouchEnabled(Btn_yes, true)
	GUI:setTag(Btn_yes, -1)

	-- Create Btn_no
	local Btn_no = GUI:Button_Create(Panel_tips, "Btn_no", 150.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Btn_no, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Btn_no, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(Btn_no, 45, 25)
	GUI:setIgnoreContentAdaptWithSize(Btn_no, false)
	GUI:Button_setTitleText(Btn_no, "取消")
	GUI:Button_setTitleColor(Btn_no, "#39b5ef")
	GUI:Button_setTitleFontSize(Btn_no, 14)
	GUI:Button_titleEnableOutline(Btn_no, "#000000", 1)
	GUI:setAnchorPoint(Btn_no, 0.50, 0.50)
	GUI:setTouchEnabled(Btn_no, true)
	GUI:setTag(Btn_no, -1)
end
return ui