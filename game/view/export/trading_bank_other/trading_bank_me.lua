local ui = {}
function ui.init(parent)
	-- Create Node
	local Node = GUI:Node_Create(parent, "Node", 0.00, 0.00)
	GUI:setAnchorPoint(Node, 0.50, 0.50)
	GUI:setTag(Node, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Node, "Panel_1", 0.00, 0.00, 732.00, 445.00, false)
	GUI:setTouchEnabled(Panel_1, true)
	GUI:setTag(Panel_1, 89)

	-- Create Panel_show
	local Panel_show = GUI:Layout_Create(Panel_1, "Panel_show", 1.00, 0.00, 732.00, 445.00, false)
	GUI:setTouchEnabled(Panel_show, false)
	GUI:setTag(Panel_show, 415)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_show, "Text_1", 82.00, 372.00, 20, "#f8e6c6", [[我的交易币:]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 369)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Text_1_0
	local Text_1_0 = GUI:Text_Create(Panel_show, "Text_1_0", 82.00, 326.00, 20, "#f8e6c6", [[待入账交易币:]])
	GUI:setAnchorPoint(Text_1_0, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1_0, false)
	GUI:setTag(Text_1_0, 370)
	GUI:Text_enableOutline(Text_1_0, "#000000", 1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(Panel_show, "Text_desc", 129.00, 285.00, 18, "#00ff00", [[待入账说明]])
	GUI:setAnchorPoint(Text_desc, 0.50, 0.50)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, 386)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create Text_me
	local Text_me = GUI:Text_Create(Panel_show, "Text_me", 207.00, 372.00, 20, "#f8e6c6", [[0]])
	GUI:setAnchorPoint(Text_me, 0.00, 0.50)
	GUI:setTouchEnabled(Text_me, false)
	GUI:setTag(Text_me, 371)
	GUI:Text_enableOutline(Text_me, "#000000", 1)

	-- Create Text_wait
	local Text_wait = GUI:Text_Create(Panel_show, "Text_wait", 215.00, 326.00, 20, "#f8e6c6", [[0]])
	GUI:setAnchorPoint(Text_wait, 0.00, 0.50)
	GUI:setTouchEnabled(Text_wait, false)
	GUI:setTag(Text_wait, 372)
	GUI:Text_enableOutline(Text_wait, "#000000", 1)

	-- Create Button_getMoney
	local Button_getMoney = GUI:Button_Create(Panel_show, "Button_getMoney", 294.00, 325.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_getMoney, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_getMoney, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_getMoney, 35, 36, 13, 14)
	GUI:setContentSize(Button_getMoney, 100, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_getMoney, false)
	GUI:Button_setTitleText(Button_getMoney, "提  现")
	GUI:Button_setTitleColor(Button_getMoney, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_getMoney, 17)
	GUI:Button_titleEnableOutline(Button_getMoney, "#000000", 1)
	GUI:setAnchorPoint(Button_getMoney, 0.00, 0.50)
	GUI:setTouchEnabled(Button_getMoney, true)
	GUI:setTag(Button_getMoney, 385)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Panel_show, "Text_2", 54.00, 176.00, 18, "#2abb2a", [[]])
	GUI:setAnchorPoint(Text_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, 47)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create Button_copy
	local Button_copy = GUI:Button_Create(Panel_show, "Button_copy", 82.00, 174.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_copy, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_copy, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_copy, 35, 36, 13, 14)
	GUI:setContentSize(Button_copy, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_copy, false)
	GUI:Button_setTitleText(Button_copy, "复制唯一码")
	GUI:Button_setTitleColor(Button_copy, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_copy, 17)
	GUI:Button_titleEnableOutline(Button_copy, "#000000", 1)
	GUI:setTouchEnabled(Button_copy, true)
	GUI:setTag(Button_copy, 141)
	GUI:setVisible(Button_copy, false)

	-- Create Text_desc_1
	local Text_desc_1 = GUI:Text_Create(Panel_show, "Text_desc_1", 284.00, 189.00, 18, "#00ff00", [[唯一码说明]])
	GUI:setAnchorPoint(Text_desc_1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_desc_1, false)
	GUI:setTag(Text_desc_1, 386)
	GUI:setVisible(Text_desc_1, false)
	GUI:Text_enableOutline(Text_desc_1, "#000000", 1)

	-- Create Button_identity
	local Button_identity = GUI:Button_Create(Panel_show, "Button_identity", 78.00, 139.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_identity, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_identity, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_identity, 0, 0, 0, 0)
	GUI:setContentSize(Button_identity, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_identity, false)
	GUI:Button_setTitleText(Button_identity, "实名认证")
	GUI:Button_setTitleColor(Button_identity, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_identity, 17)
	GUI:Button_titleEnableOutline(Button_identity, "#000000", 1)
	GUI:setTouchEnabled(Button_identity, true)
	GUI:setTag(Button_identity, 141)

	-- Create Button_extract_record
	local Button_extract_record = GUI:Button_Create(Panel_show, "Button_extract_record", 235.00, 139.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_extract_record, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_extract_record, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_extract_record, 0, 0, 0, 0)
	GUI:setContentSize(Button_extract_record, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_extract_record, false)
	GUI:Button_setTitleText(Button_extract_record, "提现记录")
	GUI:Button_setTitleColor(Button_extract_record, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_extract_record, 17)
	GUI:Button_titleEnableOutline(Button_extract_record, "#000000", 1)
	GUI:setTouchEnabled(Button_extract_record, true)
	GUI:setTag(Button_extract_record, 141)

	-- Create Image_redPoint
	local Image_redPoint = GUI:Image_Create(Button_extract_record, "Image_redPoint", 107.00, 25.00, "res/private/trading_bank_other/Img_redPoint.png")
	GUI:setTouchEnabled(Image_redPoint, false)
	GUI:setTag(Image_redPoint, -1)

	-- Create Button_buy_record
	local Button_buy_record = GUI:Button_Create(Panel_show, "Button_buy_record", 391.00, 139.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_buy_record, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_buy_record, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_buy_record, 0, 0, 0, 0)
	GUI:setContentSize(Button_buy_record, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_buy_record, false)
	GUI:Button_setTitleText(Button_buy_record, "交易订单")
	GUI:Button_setTitleColor(Button_buy_record, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_buy_record, 17)
	GUI:Button_titleEnableOutline(Button_buy_record, "#000000", 1)
	GUI:setTouchEnabled(Button_buy_record, true)
	GUI:setTag(Button_buy_record, 141)

	-- Create Button_help
	local Button_help = GUI:Button_Create(Panel_show, "Button_help", 546.00, 139.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_help, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_help, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_help, 0, 0, 0, 0)
	GUI:setContentSize(Button_help, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_help, false)
	GUI:Button_setTitleText(Button_help, "帮助中心")
	GUI:Button_setTitleColor(Button_help, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_help, 17)
	GUI:Button_titleEnableOutline(Button_help, "#000000", 1)
	GUI:setTouchEnabled(Button_help, true)
	GUI:setTag(Button_help, 141)

	-- Create Button_suggest
	local Button_suggest = GUI:Button_Create(Panel_show, "Button_suggest", 611.00, 346.00, "res/private/trading_bank_other/btn_suggest.png")
	GUI:Button_setTitleText(Button_suggest, "")
	GUI:Button_setTitleColor(Button_suggest, "#ffffff")
	GUI:Button_setTitleFontSize(Button_suggest, 14)
	GUI:Button_titleEnableOutline(Button_suggest, "#000000", 1)
	GUI:setTouchEnabled(Button_suggest, true)
	GUI:setTag(Button_suggest, -1)

	-- Create Button_bindPhone
	local Button_bindPhone = GUI:Button_Create(Panel_show, "Button_bindPhone", 78.00, 76.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_bindPhone, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_bindPhone, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_bindPhone, 0, 0, 0, 0)
	GUI:setContentSize(Button_bindPhone, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_bindPhone, false)
	GUI:Button_setTitleText(Button_bindPhone, "绑定手机")
	GUI:Button_setTitleColor(Button_bindPhone, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_bindPhone, 17)
	GUI:Button_titleEnableOutline(Button_bindPhone, "#000000", 1)
	GUI:setTouchEnabled(Button_bindPhone, true)
	GUI:setTag(Button_bindPhone, 141)

	-- Create Button_reqBuy_record
	local Button_reqBuy_record = GUI:Button_Create(Panel_show, "Button_reqBuy_record", 235.00, 76.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_reqBuy_record, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_reqBuy_record, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_reqBuy_record, 0, 0, 0, 0)
	GUI:setContentSize(Button_reqBuy_record, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_reqBuy_record, false)
	GUI:Button_setTitleText(Button_reqBuy_record, "求购记录")
	GUI:Button_setTitleColor(Button_reqBuy_record, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_reqBuy_record, 17)
	GUI:Button_titleEnableOutline(Button_reqBuy_record, "#000000", 1)
	GUI:setTouchEnabled(Button_reqBuy_record, true)
	GUI:setTag(Button_reqBuy_record, 141)

	-- Create Text_ID
	local Text_ID = GUI:Text_Create(Panel_show, "Text_ID", 82.00, 418.00, 20, "#f8e6c6", [[ID:]])
	GUI:setAnchorPoint(Text_ID, 0.00, 0.50)
	GUI:setTouchEnabled(Text_ID, false)
	GUI:setTag(Text_ID, 369)
	GUI:Text_enableOutline(Text_ID, "#000000", 1)

	-- Create Button_copy_ID
	local Button_copy_ID = GUI:Button_Create(Panel_show, "Button_copy_ID", 294.00, 417.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_copy_ID, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_copy_ID, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_copy_ID, 35, 36, 13, 14)
	GUI:setContentSize(Button_copy_ID, 100, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_copy_ID, false)
	GUI:Button_setTitleText(Button_copy_ID, "复制")
	GUI:Button_setTitleColor(Button_copy_ID, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_copy_ID, 17)
	GUI:Button_titleEnableOutline(Button_copy_ID, "#000000", 1)
	GUI:setAnchorPoint(Button_copy_ID, 0.00, 0.50)
	GUI:setTouchEnabled(Button_copy_ID, true)
	GUI:setTag(Button_copy_ID, 385)

	-- Create Button_KeFu
	local Button_KeFu = GUI:Button_Create(Panel_show, "Button_KeFu", 391.00, 76.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_KeFu, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_KeFu, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_KeFu, 0, 0, 0, 0)
	GUI:setContentSize(Button_KeFu, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_KeFu, false)
	GUI:Button_setTitleText(Button_KeFu, "交易行客服")
	GUI:Button_setTitleColor(Button_KeFu, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_KeFu, 17)
	GUI:Button_titleEnableOutline(Button_KeFu, "#000000", 1)
	GUI:setTouchEnabled(Button_KeFu, true)
	GUI:setTag(Button_KeFu, 141)

	-- Create Panel_getMomey
	local Panel_getMomey = GUI:Layout_Create(Panel_1, "Panel_getMomey", 0.00, 0.00, 732.00, 445.00, false)
	GUI:setTouchEnabled(Panel_getMomey, false)
	GUI:setTag(Panel_getMomey, 415)
	GUI:setVisible(Panel_getMomey, false)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_getMomey, "Text_1", 89.00, 366.00, 18, "#f8e6c6", [[支付宝姓名:]])
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 369)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Panel_getMomey, "Text_2", 89.00, 299.00, 18, "#f8e6c6", [[支付宝账号:]])
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, 370)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create Text_name
	local Text_name = GUI:Text_Create(Panel_getMomey, "Text_name", 200.00, 377.00, 18, "#ffffff", [[海伦]])
	GUI:setAnchorPoint(Text_name, 0.00, 0.50)
	GUI:setTouchEnabled(Text_name, false)
	GUI:setTag(Text_name, 371)
	GUI:Text_enableOutline(Text_name, "#000000", 1)

	-- Create Text_tips
	local Text_tips = GUI:Text_Create(Panel_getMomey, "Text_tips", 89.00, 354.00, 16, "#dddddd", [[必须提现至该姓名绑定的支付宝账号]])
	GUI:setAnchorPoint(Text_tips, 0.00, 0.50)
	GUI:setTouchEnabled(Text_tips, false)
	GUI:setTag(Text_tips, 372)
	GUI:Text_enableOutline(Text_tips, "#000000", 1)

	-- Create Button_getMoney
	local Button_getMoney = GUI:Button_Create(Panel_getMomey, "Button_getMoney", 366.00, 73.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_getMoney, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_getMoney, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_getMoney, 0, 0, 0, 0)
	GUI:setContentSize(Button_getMoney, 115, 37)
	GUI:setIgnoreContentAdaptWithSize(Button_getMoney, false)
	GUI:Button_setTitleText(Button_getMoney, "提现")
	GUI:Button_setTitleColor(Button_getMoney, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_getMoney, 24)
	GUI:Button_titleEnableOutline(Button_getMoney, "#000000", 1)
	GUI:setAnchorPoint(Button_getMoney, 0.50, 0.50)
	GUI:setScaleX(Button_getMoney, 0.90)
	GUI:setScaleY(Button_getMoney, 0.90)
	GUI:setTouchEnabled(Button_getMoney, true)
	GUI:setTag(Button_getMoney, 385)

	-- Create Button_back
	local Button_back = GUI:Button_Create(Panel_getMomey, "Button_back", 25.00, 382.00, "res/private/trading_bank_other/btn_back.png")
	GUI:Button_setScale9Slice(Button_back, 0, 0, 0, 0)
	GUI:setContentSize(Button_back, 38, 38)
	GUI:setIgnoreContentAdaptWithSize(Button_back, false)
	GUI:Button_setTitleText(Button_back, "")
	GUI:Button_setTitleColor(Button_back, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_back, 17)
	GUI:Button_titleEnableOutline(Button_back, "#000000", 1)
	GUI:setTouchEnabled(Button_back, true)
	GUI:setTag(Button_back, 141)

	-- Create Button_extract_record
	local Button_extract_record = GUI:Button_Create(Panel_getMomey, "Button_extract_record", 575.00, 362.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_extract_record, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_extract_record, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_extract_record, 0, 0, 0, 0)
	GUI:setContentSize(Button_extract_record, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_extract_record, false)
	GUI:Button_setTitleText(Button_extract_record, "提现记录")
	GUI:Button_setTitleColor(Button_extract_record, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_extract_record, 17)
	GUI:Button_titleEnableOutline(Button_extract_record, "#000000", 1)
	GUI:setTouchEnabled(Button_extract_record, true)
	GUI:setTag(Button_extract_record, 141)

	-- Create img_red
	local img_red = GUI:Image_Create(Button_extract_record, "img_red", -3.00, 24.00, "res/private/trading_bank_other/Img_redPoint.png")
	GUI:setTouchEnabled(img_red, false)
	GUI:setTag(img_red, -1)

	-- Create Text_mindesc
	local Text_mindesc = GUI:Text_Create(Panel_getMomey, "Text_mindesc", 89.00, 243.00, 18, "#f8e6c6", [[提现金额（最低提现10元）]])
	GUI:setTouchEnabled(Text_mindesc, false)
	GUI:setTag(Text_mindesc, 370)
	GUI:Text_enableOutline(Text_mindesc, "#000000", 1)

	-- Create Image_getMoney
	local Image_getMoney = GUI:Image_Create(Panel_getMomey, "Image_getMoney", 91.00, 172.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_getMoney, 10, 10, 10, 10)
	GUI:setContentSize(Image_getMoney, 320, 64)
	GUI:setIgnoreContentAdaptWithSize(Image_getMoney, false)
	GUI:setTouchEnabled(Image_getMoney, false)
	GUI:setTag(Image_getMoney, 134)

	-- Create Input_getMoney
	local Input_getMoney = GUI:TextInput_Create(Image_getMoney, "Input_getMoney", 47.00, -1.00, 265.00, 64.00, 50)
	GUI:TextInput_setString(Input_getMoney, "")
	GUI:TextInput_setFontColor(Input_getMoney, "#ffffff")
	GUI:TextInput_setMaxLength(Input_getMoney, 9)
	GUI:setTouchEnabled(Input_getMoney, true)
	GUI:setTag(Input_getMoney, -1)

	-- Create Text_rmb
	local Text_rmb = GUI:Text_Create(Image_getMoney, "Text_rmb", 0.00, 0.00, 60, "#ffffff", [[￥]])
	GUI:setTouchEnabled(Text_rmb, false)
	GUI:setTag(Text_rmb, -1)
	GUI:Text_enableOutline(Text_rmb, "#000000", 1)

	-- Create Text_4
	local Text_4 = GUI:Text_Create(Panel_getMomey, "Text_4", 89.00, 142.00, 18, "#f8e6c6", [[当前可提现交易币：]])
	GUI:setTouchEnabled(Text_4, false)
	GUI:setTag(Text_4, 370)
	GUI:Text_enableOutline(Text_4, "#000000", 1)

	-- Create Text_money
	local Text_money = GUI:Text_Create(Panel_getMomey, "Text_money", 245.00, 154.00, 18, "#ffffff", [[20000]])
	GUI:setAnchorPoint(Text_money, 0.00, 0.50)
	GUI:setTouchEnabled(Text_money, false)
	GUI:setTag(Text_money, 371)
	GUI:Text_enableOutline(Text_money, "#000000", 1)

	-- Create Text_getAll
	local Text_getAll = GUI:Text_Create(Panel_getMomey, "Text_getAll", 332.00, 155.00, 18, "#00ff00", [[全部提现]])
	GUI:setAnchorPoint(Text_getAll, 0.00, 0.50)
	GUI:setTouchEnabled(Text_getAll, false)
	GUI:setTag(Text_getAll, 371)
	GUI:Text_enableOutline(Text_getAll, "#000000", 1)

	-- Create Text_tips_sxf
	local Text_tips_sxf = GUI:Text_Create(Panel_getMomey, "Text_tips_sxf", 89.00, 128.00, 16, "#dddddd", [[每次提现需支付5%的手续费（最低0.1）]])
	GUI:setAnchorPoint(Text_tips_sxf, 0.00, 0.50)
	GUI:setTouchEnabled(Text_tips_sxf, false)
	GUI:setTag(Text_tips_sxf, 372)
	GUI:Text_enableOutline(Text_tips_sxf, "#000000", 1)

	-- Create Panel_agreement
	local Panel_agreement = GUI:Layout_Create(Panel_getMomey, "Panel_agreement", 226.00, 21.00, 260.00, 30.00, false)
	GUI:setTouchEnabled(Panel_agreement, true)
	GUI:setTag(Panel_agreement, -1)

	-- Create CheckBox
	local CheckBox = GUI:CheckBox_Create(Panel_agreement, "CheckBox", 8.00, 6.00, "res/private/trading_bank/1900000654.png", "res/private/trading_bank/1900000655.png")
	GUI:CheckBox_setSelected(CheckBox, false)
	GUI:setTouchEnabled(CheckBox, false)
	GUI:setTag(CheckBox, -1)

	-- Create Text_5
	local Text_5 = GUI:Text_Create(Panel_agreement, "Text_5", 30.00, 4.00, 18, "#ffffff", [[我已阅读并接受]])
	GUI:setTouchEnabled(Text_5, false)
	GUI:setTag(Text_5, 371)
	GUI:Text_enableOutline(Text_5, "#000000", 1)

	-- Create Text_agreement
	local Text_agreement = GUI:Text_Create(Panel_agreement, "Text_agreement", 148.00, 5.00, 18, "#00ff00", [[【合作协议】]])
	GUI:setTouchEnabled(Text_agreement, true)
	GUI:setTag(Text_agreement, 371)
	GUI:Text_enableOutline(Text_agreement, "#000000", 1)

	-- Create Button_help
	local Button_help = GUI:Button_Create(Panel_getMomey, "Button_help", 448.00, 156.00, "res/private/trading_bank/1900001024.png")
	GUI:Button_setScale9Slice(Button_help, 0, 0, 0, 0)
	GUI:setContentSize(Button_help, 34, 34)
	GUI:setIgnoreContentAdaptWithSize(Button_help, false)
	GUI:Button_setTitleText(Button_help, "")
	GUI:Button_setTitleColor(Button_help, "#414146")
	GUI:Button_setTitleFontSize(Button_help, 14)
	GUI:Button_titleEnableOutline(Button_help, "#000000", 1)
	GUI:setAnchorPoint(Button_help, 0.50, 0.50)
	GUI:setTouchEnabled(Button_help, true)
	GUI:setTag(Button_help, 181)

	-- Create Image_account
	local Image_account = GUI:Image_Create(Panel_getMomey, "Image_account", 192.00, 286.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_account, 10, 10, 10, 10)
	GUI:setContentSize(Image_account, 310, 48)
	GUI:setIgnoreContentAdaptWithSize(Image_account, false)
	GUI:setTouchEnabled(Image_account, false)
	GUI:setTag(Image_account, 134)

	-- Create Text_account
	local Text_account = GUI:TextInput_Create(Image_account, "Text_account", 4.00, 2.00, 300.00, 40.00, 18)
	GUI:TextInput_setString(Text_account, "")
	GUI:TextInput_setFontColor(Text_account, "#ffffff")
	GUI:TextInput_setMaxLength(Text_account, 32)
	GUI:setTouchEnabled(Text_account, true)
	GUI:setTag(Text_account, -1)

	-- Create Panel_info
	local Panel_info = GUI:Layout_Create(Panel_1, "Panel_info", 0.00, 0.00, 732.00, 445.00, false)
	GUI:setTouchEnabled(Panel_info, false)
	GUI:setTag(Panel_info, 415)
	GUI:setVisible(Panel_info, false)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_info, "Text_1", 219.00, 296.00, 20, "#f8e6c6", [[姓    名   :]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 369)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Text_1_0
	local Text_1_0 = GUI:Text_Create(Panel_info, "Text_1_0", 219.00, 241.00, 20, "#f8e6c6", [[身 份 证:]])
	GUI:setAnchorPoint(Text_1_0, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1_0, false)
	GUI:setTag(Text_1_0, 370)
	GUI:Text_enableOutline(Text_1_0, "#000000", 1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(Panel_info, "Text_desc", 366.00, 167.00, 18, "#00ff00", [[您已完成认证,无法修改实名信息如有疑问,请联系客服]])
	GUI:setAnchorPoint(Text_desc, 0.50, 0.50)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, 386)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create Text_name
	local Text_name = GUI:Text_Create(Panel_info, "Text_name", 310.00, 297.00, 20, "#ffffff", [[海伦*]])
	GUI:setAnchorPoint(Text_name, 0.00, 0.50)
	GUI:setTouchEnabled(Text_name, false)
	GUI:setTag(Text_name, 371)
	GUI:Text_enableOutline(Text_name, "#000000", 1)

	-- Create Text_code
	local Text_code = GUI:Text_Create(Panel_info, "Text_code", 309.00, 240.00, 20, "#ffffff", [[330421222452124212]])
	GUI:setAnchorPoint(Text_code, 0.00, 0.50)
	GUI:setTouchEnabled(Text_code, false)
	GUI:setTag(Text_code, 372)
	GUI:Text_enableOutline(Text_code, "#000000", 1)

	-- Create Button_back
	local Button_back = GUI:Button_Create(Panel_info, "Button_back", 25.00, 382.00, "res/private/trading_bank_other/btn_back.png")
	GUI:Button_setScale9Slice(Button_back, 0, 0, 0, 0)
	GUI:setContentSize(Button_back, 38, 38)
	GUI:setIgnoreContentAdaptWithSize(Button_back, false)
	GUI:Button_setTitleText(Button_back, "")
	GUI:Button_setTitleColor(Button_back, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_back, 17)
	GUI:Button_titleEnableOutline(Button_back, "#000000", 1)
	GUI:setTouchEnabled(Button_back, true)
	GUI:setTag(Button_back, 141)

	-- Create Panel_getMoney_record
	local Panel_getMoney_record = GUI:Layout_Create(Panel_1, "Panel_getMoney_record", 0.00, 0.00, 732.00, 445.00, false)
	GUI:setTouchEnabled(Panel_getMoney_record, false)
	GUI:setTag(Panel_getMoney_record, 415)
	GUI:setVisible(Panel_getMoney_record, false)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_getMoney_record, "Text_1", 109.00, 415.00, 20, "#f8e6c6", [[提现记录]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 369)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Button_back
	local Button_back = GUI:Button_Create(Panel_getMoney_record, "Button_back", 25.00, 397.00, "res/private/trading_bank_other/btn_back.png")
	GUI:Button_setScale9Slice(Button_back, 0, 0, 0, 0)
	GUI:setContentSize(Button_back, 38, 38)
	GUI:setIgnoreContentAdaptWithSize(Button_back, false)
	GUI:Button_setTitleText(Button_back, "")
	GUI:Button_setTitleColor(Button_back, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_back, 17)
	GUI:Button_titleEnableOutline(Button_back, "#000000", 1)
	GUI:setTouchEnabled(Button_back, true)
	GUI:setTag(Button_back, 141)

	-- Create ImageView
	local ImageView = GUI:Image_Create(Panel_getMoney_record, "ImageView", 0.00, 387.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setTouchEnabled(ImageView, false)
	GUI:setTag(ImageView, -1)

	-- Create ListView
	local ListView = GUI:ListView_Create(Panel_getMoney_record, "ListView", 0.00, 0.00, 732.00, 385.00, 1)
	GUI:ListView_setGravity(ListView, 5)
	GUI:setTouchEnabled(ListView, true)
	GUI:setTag(ListView, -1)

	-- Create Panel_item
	local Panel_item = GUI:Layout_Create(Panel_getMoney_record, "Panel_item", 0.00, 0.00, 732.00, 90.00, false)
	GUI:setTouchEnabled(Panel_item, true)
	GUI:setTag(Panel_item, -1)

	-- Create ImageBG
	local ImageBG = GUI:Image_Create(Panel_item, "ImageBG", 0.00, 0.00, "res/private/trading_bank/word_jiaoyh_019.png")
	GUI:setContentSize(ImageBG, 732, 90)
	GUI:setIgnoreContentAdaptWithSize(ImageBG, false)
	GUI:setTouchEnabled(ImageBG, false)
	GUI:setTag(ImageBG, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_item, "Text_1", 20.00, 74.00, 18, "#f8e6c6", [[提现]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 369)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Panel_item, "Text_2", 20.00, 45.00, 18, "#f8e6c6", [[提现手续费：]])
	GUI:setAnchorPoint(Text_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, 369)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create Text_sxf
	local Text_sxf = GUI:Text_Create(Panel_item, "Text_sxf", 122.00, 45.00, 18, "#ffffff", [[5]])
	GUI:setAnchorPoint(Text_sxf, 0.00, 0.50)
	GUI:setTouchEnabled(Text_sxf, false)
	GUI:setTag(Text_sxf, 369)
	GUI:Text_enableOutline(Text_sxf, "#000000", 1)

	-- Create Text_time
	local Text_time = GUI:Text_Create(Panel_item, "Text_time", 20.00, 16.00, 18, "#ffffff", [[2023.6.30     10.39]])
	GUI:setAnchorPoint(Text_time, 0.00, 0.50)
	GUI:setTouchEnabled(Text_time, false)
	GUI:setTag(Text_time, 369)
	GUI:Text_enableOutline(Text_time, "#000000", 1)

	-- Create Text_count
	local Text_count = GUI:Text_Create(Panel_item, "Text_count", 685.00, 60.00, 18, "#00ff00", [[1000]])
	GUI:setAnchorPoint(Text_count, 1.00, 0.50)
	GUI:setTouchEnabled(Text_count, false)
	GUI:setTag(Text_count, 369)
	GUI:Text_enableOutline(Text_count, "#000000", 1)

	-- Create Image_redPoint
	local Image_redPoint = GUI:Image_Create(Panel_item, "Image_redPoint", 714.00, 72.00, "res/private/trading_bank_other/Img_redPoint.png")
	GUI:setTouchEnabled(Image_redPoint, false)
	GUI:setTag(Image_redPoint, -1)

	-- Create Text_state
	local Text_state = GUI:Text_Create(Panel_item, "Text_state", 690.00, 30.00, 16, "#ff0000", [[审核中]])
	GUI:setAnchorPoint(Text_state, 1.00, 0.50)
	GUI:setTouchEnabled(Text_state, false)
	GUI:setTag(Text_state, 369)
	GUI:Text_enableOutline(Text_state, "#000000", 1)

	-- Create Panel_opt_record
	local Panel_opt_record = GUI:Layout_Create(Panel_1, "Panel_opt_record", 0.00, 0.00, 732.00, 445.00, false)
	GUI:setTouchEnabled(Panel_opt_record, false)
	GUI:setTag(Panel_opt_record, 415)
	GUI:setVisible(Panel_opt_record, false)

	-- Create Button_back
	local Button_back = GUI:Button_Create(Panel_opt_record, "Button_back", 25.00, 397.00, "res/private/trading_bank_other/btn_back.png")
	GUI:Button_setScale9Slice(Button_back, 0, 0, 0, 0)
	GUI:setContentSize(Button_back, 38, 38)
	GUI:setIgnoreContentAdaptWithSize(Button_back, false)
	GUI:Button_setTitleText(Button_back, "")
	GUI:Button_setTitleColor(Button_back, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_back, 17)
	GUI:Button_titleEnableOutline(Button_back, "#000000", 1)
	GUI:setTouchEnabled(Button_back, true)
	GUI:setTag(Button_back, 141)

	-- Create ImageView
	local ImageView = GUI:Image_Create(Panel_opt_record, "ImageView", 0.00, 387.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setTouchEnabled(ImageView, false)
	GUI:setTag(ImageView, -1)

	-- Create ListView
	local ListView = GUI:ListView_Create(Panel_opt_record, "ListView", 0.00, 0.00, 732.00, 385.00, 1)
	GUI:ListView_setGravity(ListView, 5)
	GUI:setTouchEnabled(ListView, true)
	GUI:setTag(ListView, -1)

	-- Create Panel_item
	local Panel_item = GUI:Layout_Create(Panel_opt_record, "Panel_item", 0.00, 0.00, 732.00, 135.00, false)
	GUI:setTouchEnabled(Panel_item, true)
	GUI:setTag(Panel_item, -1)

	-- Create ImageBG
	local ImageBG = GUI:Image_Create(Panel_item, "ImageBG", 5.00, 0.00, "res/private/trading_bank_other/img_bg.png")
	GUI:setTouchEnabled(ImageBG, false)
	GUI:setTag(ImageBG, -1)

	-- Create Text_name
	local Text_name = GUI:Text_Create(Panel_item, "Text_name", 103.00, 64.00, 16, "#f8e6c6", [[哈哈]])
	GUI:setAnchorPoint(Text_name, 0.00, 0.50)
	GUI:setTouchEnabled(Text_name, false)
	GUI:setTag(Text_name, 369)
	GUI:Text_enableOutline(Text_name, "#000000", 1)

	-- Create Text_countOrlevel
	local Text_countOrlevel = GUI:Text_Create(Panel_item, "Text_countOrlevel", 194.00, 64.00, 16, "#f8e6c6", [[等级：]])
	GUI:setAnchorPoint(Text_countOrlevel, 0.00, 0.50)
	GUI:setTouchEnabled(Text_countOrlevel, false)
	GUI:setTag(Text_countOrlevel, 369)
	GUI:Text_enableOutline(Text_countOrlevel, "#000000", 1)

	-- Create Text_countOrlevel_num
	local Text_countOrlevel_num = GUI:Text_Create(Panel_item, "Text_countOrlevel_num", 238.00, 64.00, 16, "#ffffff", [[100]])
	GUI:setAnchorPoint(Text_countOrlevel_num, 0.00, 0.50)
	GUI:setTouchEnabled(Text_countOrlevel_num, false)
	GUI:setTag(Text_countOrlevel_num, 369)
	GUI:Text_enableOutline(Text_countOrlevel_num, "#000000", 1)

	-- Create Text_job
	local Text_job = GUI:Text_Create(Panel_item, "Text_job", 140.00, 64.00, 16, "#ffffff", [[(战士)]])
	GUI:setAnchorPoint(Text_job, 0.00, 0.50)
	GUI:setTouchEnabled(Text_job, false)
	GUI:setTag(Text_job, 369)
	GUI:Text_enableOutline(Text_job, "#000000", 1)

	-- Create Text_time
	local Text_time = GUI:Text_Create(Panel_item, "Text_time", 29.00, 113.00, 18, "#ffffff", [[2023.6.30     10:39:12]])
	GUI:setAnchorPoint(Text_time, 0.00, 0.50)
	GUI:setTouchEnabled(Text_time, false)
	GUI:setTag(Text_time, 369)
	GUI:Text_enableOutline(Text_time, "#000000", 1)

	-- Create Text_count
	local Text_count = GUI:Text_Create(Panel_item, "Text_count", 698.00, 63.00, 16, "#00ff00", [[￥20000]])
	GUI:setAnchorPoint(Text_count, 1.00, 0.50)
	GUI:setTouchEnabled(Text_count, false)
	GUI:setTag(Text_count, 369)
	GUI:Text_enableOutline(Text_count, "#000000", 1)

	-- Create Text_state
	local Text_state = GUI:Text_Create(Panel_item, "Text_state", 704.00, 113.00, 16, "#ff0000", [[买家已付款]])
	GUI:setAnchorPoint(Text_state, 1.00, 0.50)
	GUI:setTouchEnabled(Text_state, false)
	GUI:setTag(Text_state, 369)
	GUI:Text_enableOutline(Text_state, "#000000", 1)

	-- Create Image_item
	local Image_item = GUI:Image_Create(Panel_item, "Image_item", 59.00, 48.00, "res/private/trading_bank/1900000651.png")
	GUI:setAnchorPoint(Image_item, 0.50, 0.50)
	GUI:setTouchEnabled(Image_item, false)
	GUI:setTag(Image_item, 45)

	-- Create Image_head
	local Image_head = GUI:Image_Create(Image_item, "Image_head", 30.00, 30.00, "res/private/trading_bank/img_011.png")
	GUI:setAnchorPoint(Image_head, 0.50, 0.50)
	GUI:setTouchEnabled(Image_head, false)
	GUI:setTag(Image_head, 84)

	-- Create Text_server
	local Text_server = GUI:Text_Create(Panel_item, "Text_server", 102.00, 30.00, 16, "#f8e6c6", [[天神一区]])
	GUI:setAnchorPoint(Text_server, 0.00, 0.50)
	GUI:setTouchEnabled(Text_server, false)
	GUI:setTag(Text_server, 369)
	GUI:Text_enableOutline(Text_server, "#000000", 1)

	-- Create Text_dz
	local Text_dz = GUI:Text_Create(Panel_item, "Text_dz", 588.00, 63.00, 16, "#f8e6c6", [[待到帐金额：]])
	GUI:setAnchorPoint(Text_dz, 1.00, 0.50)
	GUI:setTouchEnabled(Text_dz, false)
	GUI:setTag(Text_dz, 369)
	GUI:Text_enableOutline(Text_dz, "#000000", 1)

	-- Create Text_dz2
	local Text_dz2 = GUI:Text_Create(Panel_item, "Text_dz2", 493.00, 28.00, 16, "#f8e6c6", [[到账时间：]])
	GUI:setAnchorPoint(Text_dz2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_dz2, false)
	GUI:setTag(Text_dz2, 369)
	GUI:Text_enableOutline(Text_dz2, "#000000", 1)

	-- Create Text_dz_time
	local Text_dz_time = GUI:Text_Create(Panel_item, "Text_dz_time", 578.00, 27.00, 18, "#ffffff", [[2021.3.26   14:12]])
	GUI:setAnchorPoint(Text_dz_time, 0.00, 0.50)
	GUI:setTouchEnabled(Text_dz_time, false)
	GUI:setTag(Text_dz_time, 369)
	GUI:Text_enableOutline(Text_dz_time, "#000000", 1)

	-- Create Button_1
	local Button_1 = GUI:Button_Create(Panel_item, "Button_1", 666.00, 47.00, "res/private/trading_bank/1900000611.png")
	GUI:Button_setScale9Slice(Button_1, 0, 0, 0, 0)
	GUI:setContentSize(Button_1, 76, 33)
	GUI:setIgnoreContentAdaptWithSize(Button_1, false)
	GUI:Button_setTitleText(Button_1, "去支付")
	GUI:Button_setTitleColor(Button_1, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_1, 16)
	GUI:Button_titleEnableOutline(Button_1, "#000000", 1)
	GUI:setAnchorPoint(Button_1, 0.50, 0.50)
	GUI:setTouchEnabled(Button_1, true)
	GUI:setTag(Button_1, 51)

	-- Create Button_buy_record
	local Button_buy_record = GUI:Button_Create(Panel_opt_record, "Button_buy_record", 88.00, 395.00, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTexturePressed(Button_buy_record, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTextureDisabled(Button_buy_record, "res/private/trading_bank/1900000680.png")
	GUI:Button_setScale9Slice(Button_buy_record, 35, 36, 13, 14)
	GUI:setContentSize(Button_buy_record, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_buy_record, false)
	GUI:Button_setTitleText(Button_buy_record, "我买的")
	GUI:Button_setTitleColor(Button_buy_record, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_buy_record, 17)
	GUI:Button_titleEnableOutline(Button_buy_record, "#000000", 1)
	GUI:setTouchEnabled(Button_buy_record, true)
	GUI:setTag(Button_buy_record, 141)

	-- Create Button_sell_record
	local Button_sell_record = GUI:Button_Create(Panel_opt_record, "Button_sell_record", 201.00, 395.00, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTexturePressed(Button_sell_record, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTextureDisabled(Button_sell_record, "res/private/trading_bank/1900000680.png")
	GUI:Button_setScale9Slice(Button_sell_record, 0, 0, 0, 0)
	GUI:setContentSize(Button_sell_record, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_sell_record, false)
	GUI:Button_setTitleText(Button_sell_record, "我卖的")
	GUI:Button_setTitleColor(Button_sell_record, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_sell_record, 17)
	GUI:Button_titleEnableOutline(Button_sell_record, "#000000", 1)
	GUI:setTouchEnabled(Button_sell_record, true)
	GUI:setTag(Button_sell_record, 141)

	-- Create Panel_help_center
	local Panel_help_center = GUI:Layout_Create(Panel_1, "Panel_help_center", 0.00, 0.00, 732.00, 445.00, false)
	GUI:setTouchEnabled(Panel_help_center, false)
	GUI:setTag(Panel_help_center, 415)
	GUI:setVisible(Panel_help_center, false)

	-- Create Image_searchBg
	local Image_searchBg = GUI:Image_Create(Panel_help_center, "Image_searchBg", 95.00, 402.00, "res/private/trading_bank_other/img_listBg.png")
	GUI:Image_setScale9Slice(Image_searchBg, 10, 10, 10, 7)
	GUI:setContentSize(Image_searchBg, 250, 28)
	GUI:setIgnoreContentAdaptWithSize(Image_searchBg, false)
	GUI:setTouchEnabled(Image_searchBg, false)
	GUI:setTag(Image_searchBg, -1)

	-- Create Input_search
	local Input_search = GUI:TextInput_Create(Image_searchBg, "Input_search", 5.00, 1.00, 240.00, 25.00, 16)
	GUI:TextInput_setString(Input_search, "")
	GUI:TextInput_setPlaceHolder(Input_search, "关键词搜索")
	GUI:TextInput_setFontColor(Input_search, "#ffffff")
	GUI:TextInput_setMaxLength(Input_search, 18)
	GUI:setTouchEnabled(Input_search, true)
	GUI:setTag(Input_search, -1)

	-- Create Button_search
	local Button_search = GUI:Button_Create(Panel_help_center, "Button_search", 384.00, 417.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_search, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_search, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_search, 15, 15, 11, 11)
	GUI:setContentSize(Button_search, 60, 28)
	GUI:setIgnoreContentAdaptWithSize(Button_search, false)
	GUI:Button_setTitleText(Button_search, "搜索")
	GUI:Button_setTitleColor(Button_search, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_search, 16)
	GUI:Button_titleEnableOutline(Button_search, "#000000", 1)
	GUI:setAnchorPoint(Button_search, 0.50, 0.50)
	GUI:setTouchEnabled(Button_search, true)
	GUI:setTag(Button_search, 355)

	-- Create Image_line
	local Image_line = GUI:Image_Create(Panel_help_center, "Image_line", 0.00, 384.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setTouchEnabled(Image_line, false)
	GUI:setTag(Image_line, -1)

	-- Create ListView_help
	local ListView_help = GUI:ListView_Create(Panel_help_center, "ListView_help", 1.00, 3.00, 730.00, 380.00, 1)
	GUI:ListView_setGravity(ListView_help, 5)
	GUI:setTouchEnabled(ListView_help, true)
	GUI:setTag(ListView_help, -1)

	-- Create help_item
	local help_item = GUI:Layout_Create(Panel_help_center, "help_item", 1.00, 294.00, 730.00, 60.00, false)
	GUI:setTouchEnabled(help_item, true)
	GUI:setTag(help_item, -1)

	-- Create ImageBG
	local ImageBG = GUI:Image_Create(help_item, "ImageBG", 0.00, 0.00, "res/private/trading_bank/word_jiaoyh_019.png")
	GUI:setContentSize(ImageBG, 732, 60)
	GUI:setIgnoreContentAdaptWithSize(ImageBG, false)
	GUI:setTouchEnabled(ImageBG, false)
	GUI:setTag(ImageBG, -1)

	-- Create Image_line
	local Image_line = GUI:Image_Create(help_item, "Image_line", 0.00, 0.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setTouchEnabled(Image_line, false)
	GUI:setTag(Image_line, -1)

	-- Create Text_title
	local Text_title = GUI:Text_Create(help_item, "Text_title", 3.00, 22.00, 16, "#00ff00", [[文本]])
	GUI:setTouchEnabled(Text_title, false)
	GUI:setTag(Text_title, -1)
	GUI:Text_enableOutline(Text_title, "#000000", 1)

	-- Create Button_back
	local Button_back = GUI:Button_Create(Panel_help_center, "Button_back", 25.00, 397.00, "res/private/trading_bank_other/btn_back.png")
	GUI:Button_setScale9Slice(Button_back, 0, 0, 0, 0)
	GUI:setContentSize(Button_back, 38, 38)
	GUI:setIgnoreContentAdaptWithSize(Button_back, false)
	GUI:Button_setTitleText(Button_back, "")
	GUI:Button_setTitleColor(Button_back, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_back, 17)
	GUI:Button_titleEnableOutline(Button_back, "#000000", 1)
	GUI:setTouchEnabled(Button_back, true)
	GUI:setTag(Button_back, 141)

	-- Create Panel_reqBuy_record
	local Panel_reqBuy_record = GUI:Layout_Create(Panel_1, "Panel_reqBuy_record", 0.00, 0.00, 732.00, 445.00, false)
	GUI:setTouchEnabled(Panel_reqBuy_record, false)
	GUI:setTag(Panel_reqBuy_record, 415)
	GUI:setVisible(Panel_reqBuy_record, false)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_reqBuy_record, "Text_1", 109.00, 415.00, 20, "#f8e6c6", [[求购记录]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 369)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Button_back
	local Button_back = GUI:Button_Create(Panel_reqBuy_record, "Button_back", 25.00, 397.00, "res/private/trading_bank_other/btn_back.png")
	GUI:Button_setScale9Slice(Button_back, 0, 0, 0, 0)
	GUI:setContentSize(Button_back, 38, 38)
	GUI:setIgnoreContentAdaptWithSize(Button_back, false)
	GUI:Button_setTitleText(Button_back, "")
	GUI:Button_setTitleColor(Button_back, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_back, 17)
	GUI:Button_titleEnableOutline(Button_back, "#000000", 1)
	GUI:setTouchEnabled(Button_back, true)
	GUI:setTag(Button_back, 141)

	-- Create ImageView
	local ImageView = GUI:Image_Create(Panel_reqBuy_record, "ImageView", 0.00, 369.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setTouchEnabled(ImageView, false)
	GUI:setTag(ImageView, -1)

	-- Create Text_job_label
	local Text_job_label = GUI:Text_Create(Panel_reqBuy_record, "Text_job_label", 52.00, 349.00, 16, "#f8e6c6", [[求购职业]])
	GUI:setAnchorPoint(Text_job_label, 0.50, 0.50)
	GUI:setTouchEnabled(Text_job_label, false)
	GUI:setTag(Text_job_label, 369)
	GUI:Text_enableOutline(Text_job_label, "#000000", 1)

	-- Create ImageView_2
	local ImageView_2 = GUI:Image_Create(Panel_reqBuy_record, "ImageView_2", 103.00, 327.00, "res/private/trading_bank/bg_yyxsz_02.png")
	GUI:setContentSize(ImageView_2, 2, 43)
	GUI:setIgnoreContentAdaptWithSize(ImageView_2, false)
	GUI:setTouchEnabled(ImageView_2, false)
	GUI:setTag(ImageView_2, -1)

	-- Create Text_level_label
	local Text_level_label = GUI:Text_Create(Panel_reqBuy_record, "Text_level_label", 189.00, 349.00, 16, "#f8e6c6", [[等级]])
	GUI:setAnchorPoint(Text_level_label, 0.50, 0.50)
	GUI:setTouchEnabled(Text_level_label, false)
	GUI:setTag(Text_level_label, 369)
	GUI:Text_enableOutline(Text_level_label, "#000000", 1)

	-- Create ImageView_2_1
	local ImageView_2_1 = GUI:Image_Create(Panel_reqBuy_record, "ImageView_2_1", 270.00, 327.00, "res/private/trading_bank/bg_yyxsz_02.png")
	GUI:setContentSize(ImageView_2_1, 2, 43)
	GUI:setIgnoreContentAdaptWithSize(ImageView_2_1, false)
	GUI:setTouchEnabled(ImageView_2_1, false)
	GUI:setTag(ImageView_2_1, -1)

	-- Create Text_price_label
	local Text_price_label = GUI:Text_Create(Panel_reqBuy_record, "Text_price_label", 364.00, 349.00, 16, "#f8e6c6", [[金额(元)]])
	GUI:setAnchorPoint(Text_price_label, 0.50, 0.50)
	GUI:setTouchEnabled(Text_price_label, false)
	GUI:setTag(Text_price_label, 369)
	GUI:Text_enableOutline(Text_price_label, "#000000", 1)

	-- Create ImageView_2_2
	local ImageView_2_2 = GUI:Image_Create(Panel_reqBuy_record, "ImageView_2_2", 454.00, 327.00, "res/private/trading_bank/bg_yyxsz_02.png")
	GUI:setContentSize(ImageView_2_2, 2, 43)
	GUI:setIgnoreContentAdaptWithSize(ImageView_2_2, false)
	GUI:setTouchEnabled(ImageView_2_2, false)
	GUI:setTag(ImageView_2_2, -1)

	-- Create Text_time_label
	local Text_time_label = GUI:Text_Create(Panel_reqBuy_record, "Text_time_label", 552.00, 349.00, 16, "#f8e6c6", [[发布时间]])
	GUI:setAnchorPoint(Text_time_label, 0.50, 0.50)
	GUI:setTouchEnabled(Text_time_label, false)
	GUI:setTag(Text_time_label, 369)
	GUI:Text_enableOutline(Text_time_label, "#000000", 1)

	-- Create ImageView_2_2_1
	local ImageView_2_2_1 = GUI:Image_Create(Panel_reqBuy_record, "ImageView_2_2_1", 640.00, 327.00, "res/private/trading_bank/bg_yyxsz_02.png")
	GUI:setContentSize(ImageView_2_2_1, 2, 43)
	GUI:setIgnoreContentAdaptWithSize(ImageView_2_2_1, false)
	GUI:setTouchEnabled(ImageView_2_2_1, false)
	GUI:setTag(ImageView_2_2_1, -1)

	-- Create Text_opt_label
	local Text_opt_label = GUI:Text_Create(Panel_reqBuy_record, "Text_opt_label", 688.00, 349.00, 16, "#f8e6c6", [[操作]])
	GUI:setAnchorPoint(Text_opt_label, 0.50, 0.50)
	GUI:setTouchEnabled(Text_opt_label, false)
	GUI:setTag(Text_opt_label, 369)
	GUI:Text_enableOutline(Text_opt_label, "#000000", 1)

	-- Create ImageView_1
	local ImageView_1 = GUI:Image_Create(Panel_reqBuy_record, "ImageView_1", 0.00, 325.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setTouchEnabled(ImageView_1, false)
	GUI:setTag(ImageView_1, -1)

	-- Create ListView
	local ListView = GUI:ListView_Create(Panel_reqBuy_record, "ListView", 0.00, 0.00, 732.00, 326.00, 1)
	GUI:ListView_setGravity(ListView, 5)
	GUI:setTouchEnabled(ListView, true)
	GUI:setTag(ListView, -1)

	-- Create Panel_item
	local Panel_item = GUI:Layout_Create(Panel_reqBuy_record, "Panel_item", 0.00, 0.00, 732.00, 50.00, false)
	GUI:setTouchEnabled(Panel_item, true)
	GUI:setTag(Panel_item, -1)

	-- Create ImageBG
	local ImageBG = GUI:Image_Create(Panel_item, "ImageBG", 0.00, 0.00, "res/private/trading_bank/word_jiaoyh_019.png")
	GUI:setContentSize(ImageBG, 732, 50)
	GUI:setIgnoreContentAdaptWithSize(ImageBG, false)
	GUI:setTouchEnabled(ImageBG, false)
	GUI:setTag(ImageBG, -1)

	-- Create Text_job
	local Text_job = GUI:Text_Create(Panel_item, "Text_job", 52.00, 27.00, 16, "#f8e6c6", [[战士]])
	GUI:setAnchorPoint(Text_job, 0.50, 0.50)
	GUI:setTouchEnabled(Text_job, false)
	GUI:setTag(Text_job, 369)
	GUI:Text_enableOutline(Text_job, "#000000", 1)

	-- Create Text_level
	local Text_level = GUI:Text_Create(Panel_item, "Text_level", 189.00, 26.00, 16, "#f8e6c6", [[100-200]])
	GUI:setAnchorPoint(Text_level, 0.50, 0.50)
	GUI:setTouchEnabled(Text_level, false)
	GUI:setTag(Text_level, 369)
	GUI:Text_enableOutline(Text_level, "#000000", 1)

	-- Create Text_price
	local Text_price = GUI:Text_Create(Panel_item, "Text_price", 362.00, 26.00, 16, "#f8e6c6", [[0-200]])
	GUI:setAnchorPoint(Text_price, 0.50, 0.50)
	GUI:setTouchEnabled(Text_price, false)
	GUI:setTag(Text_price, 369)
	GUI:Text_enableOutline(Text_price, "#000000", 1)

	-- Create Text_time
	local Text_time = GUI:Text_Create(Panel_item, "Text_time", 552.00, 26.00, 16, "#f8e6c6", [[2023.11.8 14:00]])
	GUI:setAnchorPoint(Text_time, 0.50, 0.50)
	GUI:setTouchEnabled(Text_time, false)
	GUI:setTag(Text_time, 369)
	GUI:Text_enableOutline(Text_time, "#000000", 1)

	-- Create Text_delete
	local Text_delete = GUI:Text_Create(Panel_item, "Text_delete", 688.00, 26.00, 16, "#ff0000", [[删除]])
	GUI:setAnchorPoint(Text_delete, 0.50, 0.50)
	GUI:setTouchEnabled(Text_delete, false)
	GUI:setTag(Text_delete, 369)
	GUI:Text_enableOutline(Text_delete, "#000000", 1)
end
return ui