local ui = {}
function ui.init(parent)
	-- Create Panel_cancel
	local Panel_cancel = GUI:Layout_Create(parent, "Panel_cancel", 0.00, 0.00, 1136.00, 640.00, false)
	GUI:setTouchEnabled(Panel_cancel, true)
	GUI:setTag(Panel_cancel, -1)

	-- Create Panel_2
	local Panel_2 = GUI:Layout_Create(Panel_cancel, "Panel_2", 573.00, 311.00, 382.00, 509.00, false)
	GUI:setAnchorPoint(Panel_2, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_2, true)
	GUI:setTag(Panel_2, 344)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_2, "Image_bg", 191.00, 254.00, "res/private/trading_bank/bg_jiaoyh_012.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, 345)

	-- Create ButtonClose
	local ButtonClose = GUI:Button_Create(Panel_2, "ButtonClose", 395.00, 485.00, "res/private/trading_bank/1900000510.png")
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

	-- Create Button_1
	local Button_1 = GUI:Button_Create(Panel_2, "Button_1", 322.00, 137.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_1, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_1, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_1, 15, 15, 11, 11)
	GUI:setContentSize(Button_1, 60, 28)
	GUI:setIgnoreContentAdaptWithSize(Button_1, false)
	GUI:Button_setTitleText(Button_1, "复制")
	GUI:Button_setTitleColor(Button_1, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_1, 16)
	GUI:Button_titleEnableOutline(Button_1, "#000000", 1)
	GUI:setAnchorPoint(Button_1, 0.50, 0.50)
	GUI:setTouchEnabled(Button_1, true)
	GUI:setTag(Button_1, 355)

	-- Create Text_state
	local Text_state = GUI:Text_Create(Panel_2, "Text_state", 35.00, 459.00, 15, "#00ff00", [[待支付]])
	GUI:setTouchEnabled(Text_state, false)
	GUI:setTag(Text_state, -1)
	GUI:Text_enableOutline(Text_state, "#000000", 1)

	-- Create Image_item
	local Image_item = GUI:Image_Create(Panel_2, "Image_item", 66.00, 414.00, "res/private/trading_bank/1900000651.png")
	GUI:setAnchorPoint(Image_item, 0.50, 0.50)
	GUI:setTouchEnabled(Image_item, false)
	GUI:setTag(Image_item, 45)

	-- Create Image_head
	local Image_head = GUI:Image_Create(Image_item, "Image_head", 30.00, 30.00, "res/private/trading_bank/img_011.png")
	GUI:setAnchorPoint(Image_head, 0.50, 0.50)
	GUI:setTouchEnabled(Image_head, false)
	GUI:setTag(Image_head, 84)

	-- Create Text_goodsname
	local Text_goodsname = GUI:Text_Create(Panel_2, "Text_goodsname", 113.00, 417.00, 15, "#e1d5b5", [[元宝]])
	GUI:setTouchEnabled(Text_goodsname, false)
	GUI:setTag(Text_goodsname, -1)
	GUI:Text_enableOutline(Text_goodsname, "#000000", 1)

	-- Create Text_count_text
	local Text_count_text = GUI:Text_Create(Panel_2, "Text_count_text", 113.00, 388.00, 15, "#e1d5b5", [[数量:]])
	GUI:setTouchEnabled(Text_count_text, false)
	GUI:setTag(Text_count_text, -1)
	GUI:Text_enableOutline(Text_count_text, "#000000", 1)

	-- Create Text_server_text
	local Text_server_text = GUI:Text_Create(Panel_2, "Text_server_text", 37.00, 340.00, 14, "#e1d5b5", [[游戏区服:]])
	GUI:setTouchEnabled(Text_server_text, false)
	GUI:setTag(Text_server_text, -1)
	GUI:Text_enableOutline(Text_server_text, "#000000", 1)

	-- Create Text_goods_type_text
	local Text_goods_type_text = GUI:Text_Create(Panel_2, "Text_goods_type_text", 37.00, 308.00, 14, "#e1d5b5", [[商品类型:]])
	GUI:setTouchEnabled(Text_goods_type_text, false)
	GUI:setTag(Text_goods_type_text, -1)
	GUI:Text_enableOutline(Text_goods_type_text, "#000000", 1)

	-- Create Text_goods_num_text
	local Text_goods_num_text = GUI:Text_Create(Panel_2, "Text_goods_num_text", 37.00, 277.00, 14, "#e1d5b5", [[商品编号:]])
	GUI:setTouchEnabled(Text_goods_num_text, false)
	GUI:setTag(Text_goods_num_text, -1)
	GUI:Text_enableOutline(Text_goods_num_text, "#000000", 1)

	-- Create Text_goods_price_text
	local Text_goods_price_text = GUI:Text_Create(Panel_2, "Text_goods_price_text", 37.00, 246.00, 14, "#e1d5b5", [[商品价格:]])
	GUI:setTouchEnabled(Text_goods_price_text, false)
	GUI:setTag(Text_goods_price_text, -1)
	GUI:Text_enableOutline(Text_goods_price_text, "#000000", 1)

	-- Create Text_goods_count_text
	local Text_goods_count_text = GUI:Text_Create(Panel_2, "Text_goods_count_text", 37.00, 216.00, 14, "#e1d5b5", [[商品件数:]])
	GUI:setTouchEnabled(Text_goods_count_text, false)
	GUI:setTag(Text_goods_count_text, -1)
	GUI:Text_enableOutline(Text_goods_count_text, "#000000", 1)

	-- Create Text_real_money_text
	local Text_real_money_text = GUI:Text_Create(Panel_2, "Text_real_money_text", 37.00, 172.00, 14, "#e1d5b5", [[实付款:]])
	GUI:setTouchEnabled(Text_real_money_text, false)
	GUI:setTag(Text_real_money_text, -1)
	GUI:Text_enableOutline(Text_real_money_text, "#000000", 1)

	-- Create Text_order_text
	local Text_order_text = GUI:Text_Create(Panel_2, "Text_order_text", 37.00, 127.00, 14, "#e1d5b5", [[订单编号:]])
	GUI:setTouchEnabled(Text_order_text, false)
	GUI:setTag(Text_order_text, -1)
	GUI:Text_enableOutline(Text_order_text, "#000000", 1)

	-- Create Text_time_text
	local Text_time_text = GUI:Text_Create(Panel_2, "Text_time_text", 37.00, 100.00, 14, "#e1d5b5", [[下单时间:]])
	GUI:setTouchEnabled(Text_time_text, false)
	GUI:setTag(Text_time_text, -1)
	GUI:Text_enableOutline(Text_time_text, "#000000", 1)

	-- Create Text_count
	local Text_count = GUI:Text_Create(Panel_2, "Text_count", 156.00, 387.00, 15, "#ffffff", [[100000]])
	GUI:setTouchEnabled(Text_count, false)
	GUI:setTag(Text_count, -1)
	GUI:Text_enableOutline(Text_count, "#000000", 1)

	-- Create Text_money
	local Text_money = GUI:Text_Create(Panel_2, "Text_money", 353.00, 407.00, 30, "#00ff00", [[￥2200]])
	GUI:setAnchorPoint(Text_money, 1.00, 0.00)
	GUI:setTouchEnabled(Text_money, false)
	GUI:setTag(Text_money, -1)
	GUI:Text_enableOutline(Text_money, "#000000", 1)

	-- Create Text_server
	local Text_server = GUI:Text_Create(Panel_2, "Text_server", 348.00, 340.00, 15, "#ffffff", [[天神一区]])
	GUI:setAnchorPoint(Text_server, 1.00, 0.00)
	GUI:setTouchEnabled(Text_server, false)
	GUI:setTag(Text_server, -1)
	GUI:Text_enableOutline(Text_server, "#000000", 1)

	-- Create Text_goods_type
	local Text_goods_type = GUI:Text_Create(Panel_2, "Text_goods_type", 348.00, 308.00, 15, "#ffffff", [[天神一区]])
	GUI:setAnchorPoint(Text_goods_type, 1.00, 0.00)
	GUI:setTouchEnabled(Text_goods_type, false)
	GUI:setTag(Text_goods_type, -1)
	GUI:Text_enableOutline(Text_goods_type, "#000000", 1)

	-- Create Text_goods_num
	local Text_goods_num = GUI:Text_Create(Panel_2, "Text_goods_num", 348.00, 277.00, 15, "#ffffff", [[天神一区]])
	GUI:setAnchorPoint(Text_goods_num, 1.00, 0.00)
	GUI:setTouchEnabled(Text_goods_num, false)
	GUI:setTag(Text_goods_num, -1)
	GUI:Text_enableOutline(Text_goods_num, "#000000", 1)

	-- Create Text_goods_price
	local Text_goods_price = GUI:Text_Create(Panel_2, "Text_goods_price", 348.00, 246.00, 15, "#ffffff", [[天神一区]])
	GUI:setAnchorPoint(Text_goods_price, 1.00, 0.00)
	GUI:setTouchEnabled(Text_goods_price, false)
	GUI:setTag(Text_goods_price, -1)
	GUI:Text_enableOutline(Text_goods_price, "#000000", 1)

	-- Create Text_goods_count
	local Text_goods_count = GUI:Text_Create(Panel_2, "Text_goods_count", 348.00, 216.00, 15, "#ffffff", [[天神一区]])
	GUI:setAnchorPoint(Text_goods_count, 1.00, 0.00)
	GUI:setTouchEnabled(Text_goods_count, false)
	GUI:setTag(Text_goods_count, -1)
	GUI:Text_enableOutline(Text_goods_count, "#000000", 1)

	-- Create Text_real_money
	local Text_real_money = GUI:Text_Create(Panel_2, "Text_real_money", 348.00, 172.00, 15, "#ffffff", [[天神一区]])
	GUI:setAnchorPoint(Text_real_money, 1.00, 0.00)
	GUI:setTouchEnabled(Text_real_money, false)
	GUI:setTag(Text_real_money, -1)
	GUI:Text_enableOutline(Text_real_money, "#000000", 1)

	-- Create Text_order
	local Text_order = GUI:Text_Create(Panel_2, "Text_order", 104.00, 128.00, 15, "#ffffff", [[123456789]])
	GUI:setTouchEnabled(Text_order, false)
	GUI:setTag(Text_order, -1)
	GUI:Text_enableOutline(Text_order, "#000000", 1)

	-- Create Text_time
	local Text_time = GUI:Text_Create(Panel_2, "Text_time", 104.00, 100.00, 15, "#ffffff", [[2020.1.1]])
	GUI:setTouchEnabled(Text_time, false)
	GUI:setTag(Text_time, -1)
	GUI:Text_enableOutline(Text_time, "#000000", 1)

	-- Create Button_cancelOrder
	local Button_cancelOrder = GUI:Button_Create(Panel_2, "Button_cancelOrder", 73.00, 41.00, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_loadTexturePressed(Button_cancelOrder, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_loadTextureDisabled(Button_cancelOrder, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_setTitleText(Button_cancelOrder, "取消订单")
	GUI:Button_setTitleColor(Button_cancelOrder, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_cancelOrder, 14)
	GUI:Button_titleEnableOutline(Button_cancelOrder, "#000000", 1)
	GUI:setTouchEnabled(Button_cancelOrder, true)
	GUI:setTag(Button_cancelOrder, -1)

	-- Create Button_Pay
	local Button_Pay = GUI:Button_Create(Panel_2, "Button_Pay", 221.00, 41.00, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_loadTexturePressed(Button_Pay, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_loadTextureDisabled(Button_Pay, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_setTitleText(Button_Pay, "去支付")
	GUI:Button_setTitleColor(Button_Pay, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_Pay, 14)
	GUI:Button_titleEnableOutline(Button_Pay, "#000000", 1)
	GUI:setTouchEnabled(Button_Pay, true)
	GUI:setTag(Button_Pay, -1)
end
return ui