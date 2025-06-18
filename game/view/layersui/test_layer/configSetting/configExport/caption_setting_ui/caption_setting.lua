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
	local Panel_menu = GUI:Layout_Create(Panel_main, "Panel_menu", 0.00, 0.00, 300.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_menu, 1)
	GUI:Layout_setBackGroundColor(Panel_menu, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_menu, 76)
	GUI:setTouchEnabled(Panel_menu, false)
	GUI:setTag(Panel_menu, -1)

	-- Create ListView_menu
	local ListView_menu = GUI:ListView_Create(Panel_menu, "ListView_menu", 0.00, 0.00, 300.00, 580.00, 1)
	GUI:ListView_setGravity(ListView_menu, 2)
	GUI:ListView_setItemsMargin(ListView_menu, 2)
	GUI:setTouchEnabled(ListView_menu, true)
	GUI:setTag(ListView_menu, -1)

	-- Create Text_info1
	local Text_info1 = GUI:Text_Create(Panel_menu, "Text_info1", 50.00, 600.00, 16, "#ffffff", [[ID]])
	GUI:setAnchorPoint(Text_info1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info1, false)
	GUI:setTag(Text_info1, -1)
	GUI:Text_enableOutline(Text_info1, "#000000", 1)

	-- Create Text_info2
	local Text_info2 = GUI:Text_Create(Panel_menu, "Text_info2", 180.00, 600.00, 16, "#ffffff", [[备注]])
	GUI:setAnchorPoint(Text_info2, 0.50, 0.50)
	GUI:setTouchEnabled(Text_info2, false)
	GUI:setTag(Text_info2, -1)
	GUI:Text_enableOutline(Text_info2, "#000000", 1)

	-- Create Panel_info
	local Panel_info = GUI:Layout_Create(Panel_main, "Panel_info", 936.00, 0.00, 600.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_info, 1)
	GUI:Layout_setBackGroundColor(Panel_info, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_info, 76)
	GUI:setAnchorPoint(Panel_info, 1.00, 0.00)
	GUI:setTouchEnabled(Panel_info, false)
	GUI:setTag(Panel_info, -1)

	-- Create Text_mobile
	local Text_mobile = GUI:Text_Create(Panel_info, "Text_mobile", 20.00, 600.00, 16, "#ffffff", [[手机端预览：]])
	GUI:setAnchorPoint(Text_mobile, 0.00, 0.50)
	GUI:setTouchEnabled(Text_mobile, false)
	GUI:setTag(Text_mobile, -1)
	GUI:Text_enableOutline(Text_mobile, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_mobile, "img_inputBg", 0.00, -10.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 280, 150)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create img_mobile
	local img_mobile = GUI:Image_Create(img_inputBg, "img_mobile", 110.00, 70.00, "res/private/gui_edit/ImageFile.png")
	GUI:setAnchorPoint(img_mobile, 0.50, 0.50)
	GUI:setTouchEnabled(img_mobile, false)
	GUI:setTag(img_mobile, -1)

	-- Create Text_pc
	local Text_pc = GUI:Text_Create(Panel_info, "Text_pc", 310.00, 600.00, 16, "#ffffff", [[电脑端预览：]])
	GUI:setAnchorPoint(Text_pc, 0.00, 0.50)
	GUI:setTouchEnabled(Text_pc, false)
	GUI:setTag(Text_pc, -1)
	GUI:Text_enableOutline(Text_pc, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_pc, "img_inputBg", 0.00, -10.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 280, 150)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create img_pc
	local img_pc = GUI:Image_Create(img_inputBg, "img_pc", 110.00, 70.00, "res/private/gui_edit/ImageFile.png")
	GUI:setAnchorPoint(img_pc, 0.50, 0.50)
	GUI:setTouchEnabled(img_pc, false)
	GUI:setTag(img_pc, -1)

	-- Create Text_edit
	local Text_edit = GUI:Text_Create(Panel_info, "Text_edit", 20.00, 400.00, 16, "#ffffff", [[文本编辑：]])
	GUI:setAnchorPoint(Text_edit, 0.00, 0.50)
	GUI:setTouchEnabled(Text_edit, false)
	GUI:setTag(Text_edit, -1)
	GUI:Text_enableOutline(Text_edit, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_edit, "img_inputBg", 0.00, -10.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 550, 60)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_edit
	local Input_edit = GUI:TextInput_Create(Text_edit, "Input_edit", 0.00, -10.00, 550.00, 60.00, 17)
	GUI:TextInput_setString(Input_edit, "")
	GUI:TextInput_setPlaceHolder(Input_edit, "编辑内容.......")
	GUI:TextInput_setFontColor(Input_edit, "#ffffff")
	GUI:setAnchorPoint(Input_edit, 0.00, 1.00)
	GUI:setTouchEnabled(Input_edit, true)
	GUI:setTag(Input_edit, -1)

	-- Create Text_showATT
	local Text_showATT = GUI:Text_Create(Panel_info, "Text_showATT", 20.00, 300.00, 16, "#ffffff", [[文本预览：]])
	GUI:setAnchorPoint(Text_showATT, 0.00, 0.50)
	GUI:setTouchEnabled(Text_showATT, false)
	GUI:setTag(Text_showATT, -1)
	GUI:Text_enableOutline(Text_showATT, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_showATT, "img_inputBg", 0.00, -10.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 300, 80)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Node_att
	local Node_att = GUI:Node_Create(Text_showATT, "Node_att", 10.00, -20.00)
	GUI:setAnchorPoint(Node_att, 0.00, 1.00)
	GUI:setTag(Node_att, -1)

	-- Create Text_showType
	local Text_showType = GUI:Text_Create(Panel_info, "Text_showType", 20.00, 180.00, 16, "#ffffff", [[类型：]])
	GUI:setAnchorPoint(Text_showType, 0.00, 0.50)
	GUI:setTouchEnabled(Text_showType, false)
	GUI:setTag(Text_showType, -1)
	GUI:Text_enableOutline(Text_showType, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_showType, "img_inputBg", 60.00, 24.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 100, 30)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_itype
	local Input_itype = GUI:TextInput_Create(Text_showType, "Input_itype", 60.00, 24.00, 100.00, 30.00, 17)
	GUI:TextInput_setString(Input_itype, "")
	GUI:TextInput_setPlaceHolder(Input_itype, "类型.......")
	GUI:TextInput_setFontColor(Input_itype, "#ffffff")
	GUI:setAnchorPoint(Input_itype, 0.00, 1.00)
	GUI:setTouchEnabled(Input_itype, true)
	GUI:setTag(Input_itype, -1)

	-- Create Text_typeinfo
	local Text_typeinfo = GUI:Text_Create(Text_showType, "Text_typeinfo", 180.00, 0.00, 16, "#7b7373", [[选择类型 0：无，1：图片，2：特效]])
	GUI:setTouchEnabled(Text_typeinfo, false)
	GUI:setTag(Text_typeinfo, -1)
	GUI:Text_enableOutline(Text_typeinfo, "#000000", 1)

	-- Create Text_mobileIcon
	local Text_mobileIcon = GUI:Text_Create(Panel_info, "Text_mobileIcon", 20.00, 80.00, 16, "#ffffff", [[移动端图标：]])
	GUI:setAnchorPoint(Text_mobileIcon, 0.00, 0.50)
	GUI:setTouchEnabled(Text_mobileIcon, false)
	GUI:setTag(Text_mobileIcon, -1)
	GUI:Text_enableOutline(Text_mobileIcon, "#000000", 1)

	-- Create Button_pathMobile
	local Button_pathMobile = GUI:Button_Create(Text_mobileIcon, "Button_pathMobile", 150.00, 8.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_pathMobile, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_pathMobile, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_pathMobile, 15, 16, 12, 12)
	GUI:setContentSize(Button_pathMobile, 80, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_pathMobile, false)
	GUI:Button_setTitleText(Button_pathMobile, "选择文件")
	GUI:Button_setTitleColor(Button_pathMobile, "#39b5ef")
	GUI:Button_setTitleFontSize(Button_pathMobile, 14)
	GUI:Button_titleEnableOutline(Button_pathMobile, "#000000", 1)
	GUI:setAnchorPoint(Button_pathMobile, 0.50, 0.50)
	GUI:setTouchEnabled(Button_pathMobile, true)
	GUI:setTag(Button_pathMobile, -1)

	-- Create Text_pathMobile
	local Text_pathMobile = GUI:Text_Create(Text_mobileIcon, "Text_pathMobile", 220.00, 0.00, 16, "#c0c0c0", [[path]])
	GUI:setTouchEnabled(Text_pathMobile, false)
	GUI:setTag(Text_pathMobile, -1)
	GUI:Text_enableOutline(Text_pathMobile, "#000000", 1)

	-- Create Text_pcIcon
	local Text_pcIcon = GUI:Text_Create(Panel_info, "Text_pcIcon", 20.00, 30.00, 16, "#ffffff", [[电脑端图标：]])
	GUI:setAnchorPoint(Text_pcIcon, 0.00, 0.50)
	GUI:setTouchEnabled(Text_pcIcon, false)
	GUI:setTag(Text_pcIcon, -1)
	GUI:Text_enableOutline(Text_pcIcon, "#000000", 1)

	-- Create Button_pathPC
	local Button_pathPC = GUI:Button_Create(Text_pcIcon, "Button_pathPC", 150.00, 8.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_pathPC, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_pathPC, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_pathPC, 15, 16, 12, 12)
	GUI:setContentSize(Button_pathPC, 80, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_pathPC, false)
	GUI:Button_setTitleText(Button_pathPC, "选择文件")
	GUI:Button_setTitleColor(Button_pathPC, "#39b5ef")
	GUI:Button_setTitleFontSize(Button_pathPC, 14)
	GUI:Button_titleEnableOutline(Button_pathPC, "#000000", 1)
	GUI:setAnchorPoint(Button_pathPC, 0.50, 0.50)
	GUI:setTouchEnabled(Button_pathPC, true)
	GUI:setTag(Button_pathPC, -1)

	-- Create Text_pathPC
	local Text_pathPC = GUI:Text_Create(Text_pcIcon, "Text_pathPC", 220.00, 0.00, 16, "#c0c0c0", [[path]])
	GUI:setTouchEnabled(Text_pathPC, false)
	GUI:setTag(Text_pathPC, -1)
	GUI:Text_enableOutline(Text_pathPC, "#000000", 1)

	-- Create Text_effectMobile
	local Text_effectMobile = GUI:Text_Create(Panel_info, "Text_effectMobile", 20.00, 130.00, 16, "#ffffff", [[移动端特效：]])
	GUI:setAnchorPoint(Text_effectMobile, 0.00, 0.50)
	GUI:setTouchEnabled(Text_effectMobile, false)
	GUI:setTag(Text_effectMobile, -1)
	GUI:Text_enableOutline(Text_effectMobile, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_effectMobile, "img_inputBg", 100.00, 24.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 100, 30)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_effectMobile
	local Input_effectMobile = GUI:TextInput_Create(Text_effectMobile, "Input_effectMobile", 100.00, 24.00, 100.00, 30.00, 17)
	GUI:TextInput_setString(Input_effectMobile, "")
	GUI:TextInput_setPlaceHolder(Input_effectMobile, "特效id.......")
	GUI:TextInput_setFontColor(Input_effectMobile, "#ffffff")
	GUI:setAnchorPoint(Input_effectMobile, 0.00, 1.00)
	GUI:setTouchEnabled(Input_effectMobile, true)
	GUI:setTag(Input_effectMobile, -1)

	-- Create Text_effectPc
	local Text_effectPc = GUI:Text_Create(Panel_info, "Text_effectPc", 250.00, 130.00, 16, "#ffffff", [[移动端特效：]])
	GUI:setAnchorPoint(Text_effectPc, 0.00, 0.50)
	GUI:setTouchEnabled(Text_effectPc, false)
	GUI:setTag(Text_effectPc, -1)
	GUI:Text_enableOutline(Text_effectPc, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_effectPc, "img_inputBg", 100.00, 24.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 100, 30)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_effetPc
	local Input_effetPc = GUI:TextInput_Create(Text_effectPc, "Input_effetPc", 100.00, 24.00, 100.00, 30.00, 17)
	GUI:TextInput_setString(Input_effetPc, "")
	GUI:TextInput_setPlaceHolder(Input_effetPc, "特效id.......")
	GUI:TextInput_setFontColor(Input_effetPc, "#ffffff")
	GUI:setAnchorPoint(Input_effetPc, 0.00, 1.00)
	GUI:setTouchEnabled(Input_effetPc, true)
	GUI:setTag(Input_effetPc, -1)

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
	local Button_add = GUI:Button_Create(Panel_main, "Button_add", 905.00, 100.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_add, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_add, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_add, 15, 16, 12, 12)
	GUI:setContentSize(Button_add, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_add, false)
	GUI:Button_setTitleText(Button_add, "增加")
	GUI:Button_setTitleColor(Button_add, "#10ff00")
	GUI:Button_setTitleFontSize(Button_add, 14)
	GUI:Button_titleEnableOutline(Button_add, "#000000", 1)
	GUI:setAnchorPoint(Button_add, 0.50, 0.50)
	GUI:setTouchEnabled(Button_add, true)
	GUI:setTag(Button_add, -1)

	-- Create Button_delete
	local Button_delete = GUI:Button_Create(Panel_main, "Button_delete", 905.00, 60.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_delete, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_delete, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_delete, 15, 16, 12, 12)
	GUI:setContentSize(Button_delete, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_delete, false)
	GUI:Button_setTitleText(Button_delete, "删除")
	GUI:Button_setTitleColor(Button_delete, "#10ff00")
	GUI:Button_setTitleFontSize(Button_delete, 14)
	GUI:Button_titleEnableOutline(Button_delete, "#000000", 1)
	GUI:setAnchorPoint(Button_delete, 0.50, 0.50)
	GUI:setTouchEnabled(Button_delete, true)
	GUI:setTag(Button_delete, -1)

	-- Create Panel_tips
	local Panel_tips = GUI:Layout_Create(Panel_main, "Panel_tips", 800.00, 220.00, 200.00, 120.00, false)
	GUI:Layout_setBackGroundColorType(Panel_tips, 1)
	GUI:Layout_setBackGroundColor(Panel_tips, "#082910")
	GUI:Layout_setBackGroundColorOpacity(Panel_tips, 153)
	GUI:setAnchorPoint(Panel_tips, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_tips, false)
	GUI:setTag(Panel_tips, -1)
	GUI:setVisible(Panel_tips, false)

	-- Create panel_inputBg
	local panel_inputBg = GUI:Layout_Create(Panel_tips, "panel_inputBg", 100.00, 80.00, 130.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(panel_inputBg, 1)
	GUI:Layout_setBackGroundColor(panel_inputBg, "#000000")
	GUI:Layout_setBackGroundColorOpacity(panel_inputBg, 140)
	GUI:setAnchorPoint(panel_inputBg, 0.50, 0.50)
	GUI:setTouchEnabled(panel_inputBg, false)
	GUI:setTag(panel_inputBg, -1)

	-- Create Input_id
	local Input_id = GUI:TextInput_Create(Panel_tips, "Input_id", 100.00, 80.00, 120.00, 25.00, 16)
	GUI:TextInput_setString(Input_id, "")
	GUI:TextInput_setPlaceHolder(Input_id, "请输入id.......")
	GUI:TextInput_setFontColor(Input_id, "#ffffff")
	GUI:setAnchorPoint(Input_id, 0.50, 0.50)
	GUI:setTouchEnabled(Input_id, true)
	GUI:setTag(Input_id, -1)

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