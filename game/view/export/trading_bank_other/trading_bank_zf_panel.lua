local ui = {}
function ui.init(parent)
	-- Create Node
	local Node = GUI:Node_Create(parent, "Node", 0.00, 0.00)
	GUI:setAnchorPoint(Node, 0.50, 0.50)
	GUI:setTag(Node, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Node, "Panel_1", 5.00, 2.00, 281.00, 509.00, false)
	GUI:setAnchorPoint(Panel_1, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_1, false)
	GUI:setTag(Panel_1, 344)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_1, "Image_bg", 140.00, 254.00, "res/private/trading_bank/bg_jiaoyh_011.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, 345)

	-- Create ButtonClose
	local ButtonClose = GUI:Button_Create(Image_bg, "ButtonClose", 293.00, 484.00, "res/private/trading_bank/1900000510.png")
	GUI:Button_loadTexturePressed(ButtonClose, "res/private/trading_bank/1900000511.png")
	GUI:Button_loadTextureDisabled(ButtonClose, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(ButtonClose, 8, 6, 12, 10)
	GUI:setContentSize(ButtonClose, 26, 42)
	GUI:setIgnoreContentAdaptWithSize(ButtonClose, false)
	GUI:Button_setTitleText(ButtonClose, "")
	GUI:Button_setTitleColor(ButtonClose, "#414146")
	GUI:Button_setTitleFontSize(ButtonClose, 14)
	GUI:Button_titleDisableOutLine(ButtonClose)
	GUI:setAnchorPoint(ButtonClose, 0.50, 0.50)
	GUI:setTouchEnabled(ButtonClose, true)
	GUI:setTag(ButtonClose, 357)

	-- Create Panel_12
	local Panel_12 = GUI:Layout_Create(Image_bg, "Panel_12", 0.00, 0.00, 281.00, 507.00, false)
	GUI:setTouchEnabled(Panel_12, true)
	GUI:setTag(Panel_12, 358)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Panel_12, "Image_1", 140.00, 334.00, "res/private/trading_bank/bg_jiaoyh_08.png")
	GUI:setAnchorPoint(Image_1, 0.50, 0.50)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 359)

	-- Create Image_2
	local Image_2 = GUI:Image_Create(Panel_12, "Image_2", 146.00, 461.00, "res/private/trading_bank/word_sxbt_05.png")
	GUI:setAnchorPoint(Image_2, 0.50, 0.50)
	GUI:setTouchEnabled(Image_2, false)
	GUI:setTag(Image_2, 360)

	-- Create Image_3
	local Image_3 = GUI:Image_Create(Panel_12, "Image_3", 143.00, 460.00, "res/private/trading_bank/word_jiaoyh_01.png")
	GUI:setAnchorPoint(Image_3, 0.50, 0.50)
	GUI:setTouchEnabled(Image_3, false)
	GUI:setTag(Image_3, 361)

	-- Create Text_slabel
	local Text_slabel = GUI:Text_Create(Panel_12, "Text_slabel", 39.00, 429.00, 16, "#ffffff", [[区服名称:]])
	GUI:setAnchorPoint(Text_slabel, 0.00, 0.50)
	GUI:setTouchEnabled(Text_slabel, false)
	GUI:setTag(Text_slabel, 362)
	GUI:Text_enableOutline(Text_slabel, "#000000", 1)

	-- Create Text_serverName
	local Text_serverName = GUI:Text_Create(Panel_12, "Text_serverName", 111.00, 429.00, 16, "#ffffff", [[荣耀一区]])
	GUI:setAnchorPoint(Text_serverName, 0.00, 0.50)
	GUI:setTouchEnabled(Text_serverName, false)
	GUI:setTag(Text_serverName, 362)
	GUI:Text_enableOutline(Text_serverName, "#000000", 1)

	-- Create Text_30
	local Text_30 = GUI:Text_Create(Panel_12, "Text_30", 39.00, 398.00, 16, "#ffffff", [[需支付的金额:]])
	GUI:setAnchorPoint(Text_30, 0.00, 0.50)
	GUI:setTouchEnabled(Text_30, false)
	GUI:setTag(Text_30, 362)
	GUI:Text_enableOutline(Text_30, "#000000", 1)

	-- Create Text_money2
	local Text_money2 = GUI:Text_Create(Panel_12, "Text_money2", 146.00, 398.00, 16, "#ffffff", [[￥1200]])
	GUI:setAnchorPoint(Text_money2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_money2, false)
	GUI:setTag(Text_money2, 365)
	GUI:Text_enableOutline(Text_money2, "#000000", 1)

	-- Create Text_time_desc2
	local Text_time_desc2 = GUI:Text_Create(Panel_12, "Text_time_desc2", 39.00, 369.00, 16, "#ffffff", [[剩余支付时间:]])
	GUI:setAnchorPoint(Text_time_desc2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_time_desc2, false)
	GUI:setTag(Text_time_desc2, 362)
	GUI:Text_enableOutline(Text_time_desc2, "#000000", 1)

	-- Create Text_time
	local Text_time = GUI:Text_Create(Panel_12, "Text_time", 141.00, 369.00, 16, "#ffffff", [[180S]])
	GUI:setAnchorPoint(Text_time, 0.00, 0.50)
	GUI:setTouchEnabled(Text_time, false)
	GUI:setTag(Text_time, 362)
	GUI:Text_enableOutline(Text_time, "#000000", 1)

	-- Create Text_time_desc
	local Text_time_desc = GUI:Text_Create(Panel_12, "Text_time_desc", 27.00, 358.00, 16, "#ffffff", [[下单后请在03：00内支付，超时
订单将取消]])
	GUI:setAnchorPoint(Text_time_desc, 0.00, 0.50)
	GUI:setTouchEnabled(Text_time_desc, false)
	GUI:setTag(Text_time_desc, 366)
	GUI:Text_enableOutline(Text_time_desc, "#000000", 1)

	-- Create Text_time_desc3
	local Text_time_desc3 = GUI:Text_Create(Panel_12, "Text_time_desc3", 37.00, 330.00, 16, "#ffffff", [[请在指定时间内完成订单，否
则将取消订单]])
	GUI:setAnchorPoint(Text_time_desc3, 0.00, 0.50)
	GUI:setTouchEnabled(Text_time_desc3, false)
	GUI:setTag(Text_time_desc3, 366)
	GUI:Text_enableOutline(Text_time_desc3, "#000000", 1)

	-- Create Image_2_0
	local Image_2_0 = GUI:Image_Create(Panel_12, "Image_2_0", 145.00, 270.00, "res/private/trading_bank/word_sxbt_05.png")
	GUI:setAnchorPoint(Image_2_0, 0.50, 0.50)
	GUI:setTouchEnabled(Image_2_0, false)
	GUI:setTag(Image_2_0, 367)

	-- Create Image_3_0
	local Image_3_0 = GUI:Image_Create(Panel_12, "Image_3_0", 143.00, 269.00, "res/private/trading_bank/word_jiaoyh_02.png")
	GUI:setAnchorPoint(Image_3_0, 0.50, 0.50)
	GUI:setTouchEnabled(Image_3_0, false)
	GUI:setTag(Image_3_0, 368)

	-- Create Button_buy2
	local Button_buy2 = GUI:Button_Create(Panel_12, "Button_buy2", 143.00, 141.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_buy2, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_buy2, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_buy2, 15, 15, 11, 11)
	GUI:setContentSize(Button_buy2, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_buy2, false)
	GUI:Button_setTitleText(Button_buy2, "提交订单")
	GUI:Button_setTitleColor(Button_buy2, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_buy2, 18)
	GUI:Button_titleEnableOutline(Button_buy2, "#000000", 1)
	GUI:setAnchorPoint(Button_buy2, 0.50, 0.50)
	GUI:setTouchEnabled(Button_buy2, true)
	GUI:setTag(Button_buy2, 369)

	-- Create Panel_pay1
	local Panel_pay1 = GUI:Layout_Create(Panel_12, "Panel_pay1", 30.00, 250.00, 97.00, 25.00, false)
	GUI:setAnchorPoint(Panel_pay1, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_pay1, true)
	GUI:setTag(Panel_pay1, 378)

	-- Create Image_2
	local Image_2 = GUI:Image_Create(Panel_pay1, "Image_2", 14.00, 12.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:setAnchorPoint(Image_2, 0.50, 0.50)
	GUI:setTouchEnabled(Image_2, false)
	GUI:setTag(Image_2, 379)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Image_2, "Image_1", 12.00, 12.00, "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:setAnchorPoint(Image_1, 0.50, 0.50)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 380)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_pay1, "Text_1", 30.00, 11.00, 16, "#ffffff", [[支付宝]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 381)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Panel_pay2
	local Panel_pay2 = GUI:Layout_Create(Panel_12, "Panel_pay2", 30.00, 190.00, 96.00, 25.00, false)
	GUI:setAnchorPoint(Panel_pay2, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_pay2, true)
	GUI:setTag(Panel_pay2, 382)

	-- Create Image_2
	local Image_2 = GUI:Image_Create(Panel_pay2, "Image_2", 14.00, 12.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:setAnchorPoint(Image_2, 0.50, 0.50)
	GUI:setTouchEnabled(Image_2, false)
	GUI:setTag(Image_2, 383)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Image_2, "Image_1", 12.00, 12.00, "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:setAnchorPoint(Image_1, 0.50, 0.50)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 384)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_pay2, "Text_1", 30.00, 11.00, 16, "#ffffff", [[花呗]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 385)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Panel_agreement
	local Panel_agreement = GUI:Layout_Create(Panel_12, "Panel_agreement", 19.00, 17.00, 245.00, 100.00, false)
	GUI:setTouchEnabled(Panel_agreement, true)
	GUI:setTag(Panel_agreement, -1)

	-- Create CheckBox
	local CheckBox = GUI:CheckBox_Create(Panel_agreement, "CheckBox", 8.00, 90.00, "res/private/trading_bank/1900000654.png", "res/private/trading_bank/1900000655.png")
	GUI:CheckBox_setSelected(CheckBox, false)
	GUI:setAnchorPoint(CheckBox, 0.00, 1.00)
	GUI:setTouchEnabled(CheckBox, false)
	GUI:setTag(CheckBox, -1)

	-- Create Panel_pay3
	local Panel_pay3 = GUI:Layout_Create(Panel_12, "Panel_pay3", 30.00, 220.00, 120.00, 25.00, false)
	GUI:setAnchorPoint(Panel_pay3, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_pay3, true)
	GUI:setTag(Panel_pay3, 378)

	-- Create Image_2
	local Image_2 = GUI:Image_Create(Panel_pay3, "Image_2", 14.00, 12.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:setAnchorPoint(Image_2, 0.50, 0.50)
	GUI:setTouchEnabled(Image_2, false)
	GUI:setTag(Image_2, 379)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Image_2, "Image_1", 12.00, 12.00, "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:setAnchorPoint(Image_1, 0.50, 0.50)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 380)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_pay3, "Text_1", 30.00, 11.00, 16, "#ffffff", [[支付宝扫码]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 381)
	GUI:Text_enableOutline(Text_1, "#000000", 1)
end
return ui