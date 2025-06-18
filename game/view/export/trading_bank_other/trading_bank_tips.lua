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

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Image_1, "Panel_1", 274.00, 174.00, 522.00, 186.00, false)
	GUI:setAnchorPoint(Panel_1, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_1, false)
	GUI:setTag(Panel_1, 467)

	-- Create Text_title
	local Text_title = GUI:Text_Create(Panel_1, "Text_title", 261.00, 181.00, 22, "#ffffff", [[是否下架该商品]])
	GUI:setAnchorPoint(Text_title, 0.50, 1.00)
	GUI:setTouchEnabled(Text_title, false)
	GUI:setTag(Text_title, 468)
	GUI:Text_enableOutline(Text_title, "#000000", 1)

	-- Create ListView_1
	local ListView_1 = GUI:ListView_Create(Panel_1, "ListView_1", 18.00, 152.00, 484.00, 170.00, 1)
	GUI:ListView_setGravity(ListView_1, 5)
	GUI:setAnchorPoint(ListView_1, 0.00, 1.00)
	GUI:setTouchEnabled(ListView_1, true)
	GUI:setTag(ListView_1, 73)

	-- Create Text_txt
	local Text_txt = GUI:Text_Create(Panel_1, "Text_txt", 260.00, 161.00, 18, "#ffffff", [[是否下架该商品]])
	GUI:setAnchorPoint(Text_txt, 0.50, 1.00)
	GUI:setTouchEnabled(Text_txt, false)
	GUI:setTag(Text_txt, 469)
	GUI:Text_enableOutline(Text_txt, "#000000", 1)

	-- Create Text_time
	local Text_time = GUI:Text_Create(Panel_1, "Text_time", 249.00, 28.00, 28, "#ff0000", [[3S]])
	GUI:setAnchorPoint(Text_time, 0.50, 0.50)
	GUI:setTouchEnabled(Text_time, false)
	GUI:setTag(Text_time, 470)
	GUI:Text_enableOutline(Text_time, "#000000", 1)

	-- Create Panel_2
	local Panel_2 = GUI:Layout_Create(Image_1, "Panel_2", 273.00, 173.00, 522.00, 186.00, false)
	GUI:setAnchorPoint(Panel_2, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_2, false)
	GUI:setTag(Panel_2, 471)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_2, "Text_1", 64.00, 108.00, 24, "#ffffff", [[新价格:]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 472)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Panel_2, "Text_2", 64.00, 34.00, 24, "#ffffff", [[当前价格：]])
	GUI:setAnchorPoint(Text_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, 473)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create Image_2
	local Image_2 = GUI:Image_Create(Panel_2, "Image_2", 282.00, 109.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_2, 8, 8, 10, 10)
	GUI:setContentSize(Image_2, 220, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_2, false)
	GUI:setAnchorPoint(Image_2, 0.50, 0.50)
	GUI:setTouchEnabled(Image_2, false)
	GUI:setTag(Image_2, 474)

	-- Create TextField_4
	local TextField_4 = GUI:TextInput_Create(Image_2, "TextField_4", 110.00, 16.00, 220.00, 32.00, 20)
	GUI:TextInput_setString(TextField_4, "")
	GUI:TextInput_setFontColor(TextField_4, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_4, 10)
	GUI:setAnchorPoint(TextField_4, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_4, true)
	GUI:setTag(TextField_4, 475)

	-- Create Button_2
	local Button_2 = GUI:Button_Create(Image_1, "Button_2", 378.00, 43.00, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_loadTexturePressed(Button_2, "res/private/trading_bank/btn_jiaoyh_02.png")
	GUI:Button_loadTextureDisabled(Button_2, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_setScale9Slice(Button_2, 15, 15, 12, 10)
	GUI:setContentSize(Button_2, 91, 33)
	GUI:setIgnoreContentAdaptWithSize(Button_2, false)
	GUI:Button_setTitleText(Button_2, "确定")
	GUI:Button_setTitleColor(Button_2, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_2, 20)
	GUI:Button_titleDisableOutLine(Button_2)
	GUI:setAnchorPoint(Button_2, 0.50, 0.50)
	GUI:setTouchEnabled(Button_2, true)
	GUI:setTag(Button_2, 476)

	-- Create Button_1
	local Button_1 = GUI:Button_Create(Image_1, "Button_1", 160.00, 43.00, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_loadTexturePressed(Button_1, "res/private/trading_bank/btn_jiaoyh_02.png")
	GUI:Button_loadTextureDisabled(Button_1, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_setScale9Slice(Button_1, 15, 15, 12, 10)
	GUI:setContentSize(Button_1, 91, 33)
	GUI:setIgnoreContentAdaptWithSize(Button_1, false)
	GUI:Button_setTitleText(Button_1, "取消")
	GUI:Button_setTitleColor(Button_1, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_1, 20)
	GUI:Button_titleDisableOutLine(Button_1)
	GUI:setAnchorPoint(Button_1, 0.50, 0.50)
	GUI:setTouchEnabled(Button_1, true)
	GUI:setTag(Button_1, 477)

	-- Create payTips
	local payTips = GUI:Image_Create(Scene, "payTips", 565.00, 329.00, "res/private/trading_bank/1900000581.png")
	GUI:Image_setScale9Slice(payTips, 9, 10, 9, 10)
	GUI:setContentSize(payTips, 300, 150)
	GUI:setIgnoreContentAdaptWithSize(payTips, false)
	GUI:setAnchorPoint(payTips, 0.50, 0.50)
	GUI:setTouchEnabled(payTips, false)
	GUI:setTag(payTips, -1)

	-- Create Text
	local Text = GUI:Text_Create(payTips, "Text", 152.00, 81.00, 22, "#ffffff", [[检测支付环境]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)
end
return ui