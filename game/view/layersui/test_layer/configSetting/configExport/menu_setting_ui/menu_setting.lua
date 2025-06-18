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
	local Panel_menu1 = GUI:Layout_Create(Panel_main, "Panel_menu1", 0.00, 0.00, 200.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_menu1, 1)
	GUI:Layout_setBackGroundColor(Panel_menu1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_menu1, 76)
	GUI:setTouchEnabled(Panel_menu1, false)
	GUI:setTag(Panel_menu1, -1)

	-- Create ListView_menu1
	local ListView_menu1 = GUI:ListView_Create(Panel_menu1, "ListView_menu1", 0.00, 0.00, 200.00, 580.00, 1)
	GUI:ListView_setGravity(ListView_menu1, 2)
	GUI:ListView_setItemsMargin(ListView_menu1, 2)
	GUI:setTouchEnabled(ListView_menu1, true)
	GUI:setTag(ListView_menu1, -1)

	-- Create Text_info1
	local Text_info1 = GUI:Text_Create(Panel_menu1, "Text_info1", 100.00, 600.00, 16, "#ffffff", [[组别]])
	GUI:setAnchorPoint(Text_info1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_info1, false)
	GUI:setTag(Text_info1, -1)
	GUI:Text_enableOutline(Text_info1, "#000000", 1)

	-- Create Panel_menu2
	local Panel_menu2 = GUI:Layout_Create(Panel_main, "Panel_menu2", 200.00, 0.00, 200.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_menu2, 1)
	GUI:Layout_setBackGroundColor(Panel_menu2, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_menu2, 76)
	GUI:setTouchEnabled(Panel_menu2, false)
	GUI:setTag(Panel_menu2, -1)

	-- Create ListView_menu2
	local ListView_menu2 = GUI:ListView_Create(Panel_menu2, "ListView_menu2", 0.00, 0.00, 200.00, 580.00, 1)
	GUI:ListView_setGravity(ListView_menu2, 2)
	GUI:ListView_setItemsMargin(ListView_menu2, 2)
	GUI:setTouchEnabled(ListView_menu2, true)
	GUI:setTag(ListView_menu2, -1)

	-- Create Text_info2
	local Text_info2 = GUI:Text_Create(Panel_menu2, "Text_info2", 100.00, 600.00, 16, "#ffffff", [[名称]])
	GUI:setAnchorPoint(Text_info2, 0.50, 0.50)
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
	local Text_info3 = GUI:Text_Create(Panel_info, "Text_info3", 20.00, 600.00, 16, "#ffffff", [[界面打开条件：]])
	GUI:setAnchorPoint(Text_info3, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info3, false)
	GUI:setTag(Text_info3, -1)
	GUI:Text_enableOutline(Text_info3, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_info3, "img_inputBg", 0.00, -10.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 420, 100)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_value
	local Input_value = GUI:TextInput_Create(Text_info3, "Input_value", 10.00, -20.00, 400.00, 80.00, 16)
	GUI:TextInput_setString(Input_value, "")
	GUI:TextInput_setPlaceHolder(Input_value, "示例：$(LEVEL) >= 1 and $(WINPLAYMODE) == false")
	GUI:TextInput_setFontColor(Input_value, "#10ff00")
	GUI:setAnchorPoint(Input_value, 0.00, 1.00)
	GUI:setTouchEnabled(Input_value, true)
	GUI:setTag(Input_value, -1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(Text_info3, "Text_desc", 14.00, -370.00, 16, "#ffffff", [[]])
	GUI:setIgnoreContentAdaptWithSize(Text_desc, false)
	GUI:Text_setTextAreaSize(Text_desc, 400, 80)
	GUI:setAnchorPoint(Text_desc, 0.00, 1.00)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, -1)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create Text_info4
	local Text_info4 = GUI:Text_Create(Panel_info, "Text_info4", 20.00, 300.00, 16, "#ffffff", [[备注：]])
	GUI:setAnchorPoint(Text_info4, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info4, false)
	GUI:setTag(Text_info4, -1)
	GUI:Text_enableOutline(Text_info4, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_info4, "img_inputBg", 0.00, -10.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 420, 200)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(Text_info4, "Text_desc", 10.00, -20.00, 16, "#10ff00", [[1.变量名有：LEVEL、RELEVEL等等
2.变量名需加入标识：$()
3.可以添加多条件：用 and 和 or 关系变量隔开
4.逻辑运算符：>、<、>=、<=、 == false、== true
5.参考变量地址http://engine-doc.996m2.com/web/#/22/1352]])
	GUI:setIgnoreContentAdaptWithSize(Text_desc, false)
	GUI:Text_setTextAreaSize(Text_desc, 400, 120)
	GUI:setAnchorPoint(Text_desc, 0.00, 1.00)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, -1)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create Button_http
	local Button_http = GUI:Button_Create(Text_info4, "Button_http", 200.00, -170.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_http, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_http, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_http, 0, 0, 0, 0)
	GUI:setContentSize(Button_http, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_http, false)
	GUI:Button_setTitleText(Button_http, "查看")
	GUI:Button_setTitleColor(Button_http, "#10ff00")
	GUI:Button_setTitleFontSize(Button_http, 14)
	GUI:Button_titleEnableOutline(Button_http, "#000000", 1)
	GUI:setAnchorPoint(Button_http, 0.50, 0.50)
	GUI:setTouchEnabled(Button_http, true)
	GUI:setTag(Button_http, -1)

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
	local Panel_tips = GUI:Layout_Create(Panel_main, "Panel_tips", 439.00, 203.00, 200.00, 120.00, false)
	GUI:Layout_setBackGroundColorType(Panel_tips, 1)
	GUI:Layout_setBackGroundColor(Panel_tips, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_tips, 153)
	GUI:setTouchEnabled(Panel_tips, false)
	GUI:setTag(Panel_tips, -1)
	GUI:setVisible(Panel_tips, false)

	-- Create Input_name
	local Input_name = GUI:TextInput_Create(Panel_tips, "Input_name", 100.00, 80.00, 120.00, 25.00, 16)
	GUI:TextInput_setString(Input_name, "")
	GUI:TextInput_setPlaceHolder(Input_name, "请输入描述.......")
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
	GUI:Button_setTitleColor(Btn_yes, "#10ff00")
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
	GUI:Button_setTitleColor(Btn_no, "#10ff00")
	GUI:Button_setTitleFontSize(Btn_no, 14)
	GUI:Button_titleEnableOutline(Btn_no, "#000000", 1)
	GUI:setAnchorPoint(Btn_no, 0.50, 0.50)
	GUI:setTouchEnabled(Btn_no, true)
	GUI:setTag(Btn_no, -1)
end
return ui