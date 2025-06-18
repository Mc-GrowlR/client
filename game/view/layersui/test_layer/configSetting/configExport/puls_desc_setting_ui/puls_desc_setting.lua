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
	local Panel_menu = GUI:Layout_Create(Panel_main, "Panel_menu", 0.00, 0.00, 200.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_menu, 1)
	GUI:Layout_setBackGroundColor(Panel_menu, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_menu, 76)
	GUI:setTouchEnabled(Panel_menu, false)
	GUI:setTag(Panel_menu, -1)

	-- Create ListView_menu
	local ListView_menu = GUI:ListView_Create(Panel_menu, "ListView_menu", 0.00, 0.00, 200.00, 580.00, 1)
	GUI:ListView_setGravity(ListView_menu, 2)
	GUI:ListView_setItemsMargin(ListView_menu, 2)
	GUI:setTouchEnabled(ListView_menu, true)
	GUI:setTag(ListView_menu, -1)

	-- Create Text_info1
	local Text_info1 = GUI:Text_Create(Panel_menu, "Text_info1", 50.00, 600.00, 16, "#ffffff", [[Id]])
	GUI:setAnchorPoint(Text_info1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info1, false)
	GUI:setTag(Text_info1, -1)
	GUI:Text_enableOutline(Text_info1, "#000000", 1)

	-- Create Text_info2
	local Text_info2 = GUI:Text_Create(Panel_menu, "Text_info2", 100.00, 600.00, 16, "#ffffff", [[名字]])
	GUI:setAnchorPoint(Text_info2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_info2, false)
	GUI:setTag(Text_info2, -1)
	GUI:Text_enableOutline(Text_info2, "#000000", 1)

	-- Create Panel_info
	local Panel_info = GUI:Layout_Create(Panel_main, "Panel_info", 936.00, 0.00, 700.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_info, 1)
	GUI:Layout_setBackGroundColor(Panel_info, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_info, 76)
	GUI:setAnchorPoint(Panel_info, 1.00, 0.00)
	GUI:setTouchEnabled(Panel_info, false)
	GUI:setTag(Panel_info, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_info, "Text_1", 20.00, 550.00, 16, "#ffffff", [[名字：]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create img_inputBg1
	local img_inputBg1 = GUI:Image_Create(Text_1, "img_inputBg1", 80.00, -4.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg1, 110, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg1, false)
	GUI:setTouchEnabled(img_inputBg1, false)
	GUI:setTag(img_inputBg1, -1)

	-- Create Input_name
	local Input_name = GUI:TextInput_Create(Text_1, "Input_name", 80.00, -4.00, 110.00, 24.00, 16)
	GUI:TextInput_setString(Input_name, "")
	GUI:TextInput_setFontColor(Input_name, "#ffffff")
	GUI:setTouchEnabled(Input_name, true)
	GUI:setTag(Input_name, -1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Panel_info, "Text_2", 20.00, 500.00, 16, "#ffffff", [[未打通：]])
	GUI:setAnchorPoint(Text_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, -1)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_2, "img_inputBg", 80.00, 20.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 550, 100)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_off
	local Input_off = GUI:TextInput_Create(Text_2, "Input_off", 80.00, 20.00, 550.00, 100.00, 16)
	GUI:TextInput_setString(Input_off, "")
	GUI:TextInput_setFontColor(Input_off, "#ffffff")
	GUI:setAnchorPoint(Input_off, 0.00, 1.00)
	GUI:setTouchEnabled(Input_off, true)
	GUI:setTag(Input_off, -1)

	-- Create Text_3
	local Text_3 = GUI:Text_Create(Panel_info, "Text_3", 20.00, 300.00, 16, "#ffffff", [[打通：]])
	GUI:setAnchorPoint(Text_3, 0.00, 0.50)
	GUI:setTouchEnabled(Text_3, false)
	GUI:setTag(Text_3, -1)
	GUI:Text_enableOutline(Text_3, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_3, "img_inputBg", 80.00, 20.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(img_inputBg, 73, 74, 13, 14)
	GUI:setContentSize(img_inputBg, 550, 100)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 1.00)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_on
	local Input_on = GUI:TextInput_Create(Text_3, "Input_on", 80.00, 20.00, 550.00, 100.00, 16)
	GUI:TextInput_setString(Input_on, "")
	GUI:TextInput_setFontColor(Input_on, "#ffffff")
	GUI:setAnchorPoint(Input_on, 0.00, 1.00)
	GUI:setTouchEnabled(Input_on, true)
	GUI:setTag(Input_on, -1)

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