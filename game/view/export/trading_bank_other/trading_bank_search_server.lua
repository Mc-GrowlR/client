local ui = {}
function ui.init(parent)
	-- Create Scene
	local Scene = GUI:Node_Create(parent, "Scene", 0.00, 0.00)
	GUI:setAnchorPoint(Scene, 0.50, 0.50)
	GUI:setTag(Scene, -1)

	-- Create Panel_cancel
	local Panel_cancel = GUI:Layout_Create(Scene, "Panel_cancel", 0.00, 0.00, 1136.00, 640.00, false)
	GUI:setTouchEnabled(Panel_cancel, true)
	GUI:setTag(Panel_cancel, 465)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Scene, "Image_1", 568.00, 320.00, "res/private/trading_bank/img_phonebg.png")
	GUI:setAnchorPoint(Image_1, 0.50, 0.50)
	GUI:setTouchEnabled(Image_1, true)
	GUI:setTag(Image_1, 466)

	-- Create Button_search
	local Button_search = GUI:Button_Create(Image_1, "Button_search", 271.00, 38.00, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_loadTexturePressed(Button_search, "res/private/trading_bank/btn_jiaoyh_02.png")
	GUI:Button_loadTextureDisabled(Button_search, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_setScale9Slice(Button_search, 15, 15, 12, 10)
	GUI:setContentSize(Button_search, 91, 33)
	GUI:setIgnoreContentAdaptWithSize(Button_search, false)
	GUI:Button_setTitleText(Button_search, "搜索")
	GUI:Button_setTitleColor(Button_search, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_search, 20)
	GUI:Button_titleDisableOutLine(Button_search)
	GUI:setAnchorPoint(Button_search, 0.50, 0.50)
	GUI:setTouchEnabled(Button_search, true)
	GUI:setTag(Button_search, 476)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(Image_1, "Text_desc", 61.00, 223.00, 24, "#ffffff", [[区服名字:]])
	GUI:setAnchorPoint(Text_desc, 0.00, 0.50)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, 472)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create Image_3
	local Image_3 = GUI:Image_Create(Image_1, "Image_3", 167.00, 224.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_3, 8, 8, 10, 10)
	GUI:setContentSize(Image_3, 280, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_3, false)
	GUI:setAnchorPoint(Image_3, 0.00, 0.50)
	GUI:setTouchEnabled(Image_3, false)
	GUI:setTag(Image_3, 474)

	-- Create TextField_4
	local TextField_4 = GUI:TextInput_Create(Image_3, "TextField_4", 0.00, 16.00, 280.00, 32.00, 20)
	GUI:TextInput_setString(TextField_4, "")
	GUI:TextInput_setFontColor(TextField_4, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_4, 13)
	GUI:setAnchorPoint(TextField_4, 0.00, 0.50)
	GUI:setTouchEnabled(TextField_4, true)
	GUI:setTag(TextField_4, 475)

	-- Create Button_close
	local Button_close = GUI:Button_Create(Image_1, "Button_close", 548.00, 239.00, "res/private/trading_bank/1900000510.png")
	GUI:Button_loadTexturePressed(Button_close, "res/private/trading_bank/1900000511.png")
	GUI:Button_loadTextureDisabled(Button_close, "res/private/trading_bank/1900000511.png")
	GUI:Button_setTitleText(Button_close, "")
	GUI:Button_setTitleColor(Button_close, "#ffffff")
	GUI:Button_setTitleFontSize(Button_close, 14)
	GUI:Button_titleEnableOutline(Button_close, "#000000", 1)
	GUI:setTouchEnabled(Button_close, true)
	GUI:setTag(Button_close, -1)

	-- Create Panel_show
	local Panel_show = GUI:Layout_Create(Scene, "Panel_show", 461.00, 383.00, 280.00, 140.00, false)
	GUI:setAnchorPoint(Panel_show, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_show, true)
	GUI:setTag(Panel_show, 154)

	-- Create Image_2
	local Image_2 = GUI:Image_Create(Panel_show, "Image_2", 0.00, 140.00, "res/private/trading_bank/1900000651_2.png")
	GUI:Image_setScale9Slice(Image_2, 21, 21, 21, 21)
	GUI:setContentSize(Image_2, 280, 140)
	GUI:setIgnoreContentAdaptWithSize(Image_2, false)
	GUI:setAnchorPoint(Image_2, 0.00, 1.00)
	GUI:setTouchEnabled(Image_2, false)
	GUI:setTag(Image_2, 144)

	-- Create ListView_1
	local ListView_1 = GUI:ListView_Create(Panel_show, "ListView_1", 1.00, 139.00, 278.00, 138.00, 1)
	GUI:ListView_setGravity(ListView_1, 2)
	GUI:setAnchorPoint(ListView_1, 0.00, 1.00)
	GUI:setTouchEnabled(ListView_1, true)
	GUI:setTag(ListView_1, 155)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Panel_show, "Panel_1", 0.00, 119.00, 278.00, 30.00, true)
	GUI:Layout_setBackGroundColorType(Panel_1, 1)
	GUI:Layout_setBackGroundColor(Panel_1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_1, 255)
	GUI:setAnchorPoint(Panel_1, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_1, true)
	GUI:setTag(Panel_1, 145)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Panel_1, "Image_1", 0.00, 30.00, "res/private/trading_bank/1900000678.png")
	GUI:setContentSize(Image_1, 280, 30)
	GUI:setIgnoreContentAdaptWithSize(Image_1, false)
	GUI:setAnchorPoint(Image_1, 0.00, 1.00)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 153)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_1, "Text_1", 143.00, 14.00, 14, "#ffffff", [[区服名字]])
	GUI:setAnchorPoint(Text_1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 146)
	GUI:Text_enableOutline(Text_1, "#000000", 1)
end
return ui