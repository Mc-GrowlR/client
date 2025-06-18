local ui = {}
function ui.init(parent)
	-- Create Scene
	local Scene = GUI:Node_Create(parent, "Scene", 0.00, 0.00)
	GUI:setAnchorPoint(Scene, 0.50, 0.50)
	GUI:setTag(Scene, -1)

	-- Create Panel_2
	local Panel_2 = GUI:Layout_Create(Scene, "Panel_2", 568.00, 320.00, 1136.00, 640.00, false)
	GUI:setAnchorPoint(Panel_2, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_2, true)
	GUI:setTag(Panel_2, 311)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_2, "Image_bg", 407.00, 320.00, "res/private/trading_bank/bg_jiaoyh_06.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, true)
	GUI:setTag(Image_bg, 312)

	-- Create Panel_p
	local Panel_p = GUI:ScrollView_Create(Image_bg, "Panel_p", 18.00, 349.00, 680.00, 250.00, 1)
	GUI:ScrollView_setBounceEnabled(Panel_p, true)
	GUI:ScrollView_setInnerContainerSize(Panel_p, 680.00, 250.00)
	GUI:setAnchorPoint(Panel_p, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_p, true)
	GUI:setTag(Panel_p, 331)

	-- Create Image_cp
	local Image_cp = GUI:Image_Create(Image_bg, "Image_cp", 87.00, 307.00, "Default/ImageFile.png")
	GUI:setContentSize(Image_cp, 113.59999847412, 64)
	GUI:setIgnoreContentAdaptWithSize(Image_cp, false)
	GUI:setAnchorPoint(Image_cp, 0.50, 0.50)
	GUI:setTouchEnabled(Image_cp, true)
	GUI:setTag(Image_cp, 332)

	-- Create Button_buy
	local Button_buy = GUI:Button_Create(Image_bg, "Button_buy", 609.00, 51.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_buy, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_buy, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_buy, 15, 15, 11, 11)
	GUI:setContentSize(Button_buy, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_buy, false)
	GUI:Button_setTitleText(Button_buy, "购买")
	GUI:Button_setTitleColor(Button_buy, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_buy, 19)
	GUI:Button_titleEnableOutline(Button_buy, "#000000", 1)
	GUI:setAnchorPoint(Button_buy, 0.50, 0.50)
	GUI:setTouchEnabled(Button_buy, true)
	GUI:setTag(Button_buy, 314)

	-- Create Panel_look
	local Panel_look = GUI:Layout_Create(Image_bg, "Panel_look", 358.00, 226.00, 1.00, 1.00, false)
	GUI:setAnchorPoint(Panel_look, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_look, false)
	GUI:setTag(Panel_look, 333)

	-- Create Button_close
	local Button_close = GUI:Button_Create(Image_bg, "Button_close", 724.00, 427.00, "res/private/trading_bank/1900000510.png")
	GUI:Button_loadTexturePressed(Button_close, "res/private/trading_bank/1900000511.png")
	GUI:Button_loadTextureDisabled(Button_close, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_close, 8, 6, 12, 10)
	GUI:setContentSize(Button_close, 26, 42)
	GUI:setIgnoreContentAdaptWithSize(Button_close, false)
	GUI:Button_setTitleText(Button_close, "")
	GUI:Button_setTitleColor(Button_close, "#414146")
	GUI:Button_setTitleFontSize(Button_close, 14)
	GUI:Button_titleDisableOutLine(Button_close)
	GUI:setAnchorPoint(Button_close, 0.50, 0.50)
	GUI:setTouchEnabled(Button_close, true)
	GUI:setTag(Button_close, 334)

	-- Create Text_NameLabel
	local Text_NameLabel = GUI:Text_Create(Image_bg, "Text_NameLabel", 41.00, 400.00, 15, "#f59923", [[商品名称：]])
	GUI:setTouchEnabled(Text_NameLabel, false)
	GUI:setTag(Text_NameLabel, -1)
	GUI:Text_enableOutline(Text_NameLabel, "#000000", 1)

	-- Create Text_Name
	local Text_Name = GUI:Text_Create(Image_bg, "Text_Name", 110.00, 400.00, 15, "#f59923", [[角色七七七七七]])
	GUI:setTouchEnabled(Text_Name, false)
	GUI:setTag(Text_Name, -1)
	GUI:Text_enableOutline(Text_Name, "#000000", 1)

	-- Create Text_JobLabel
	local Text_JobLabel = GUI:Text_Create(Image_bg, "Text_JobLabel", 248.00, 400.00, 15, "#f59923", [[职业：]])
	GUI:setTouchEnabled(Text_JobLabel, false)
	GUI:setTag(Text_JobLabel, -1)
	GUI:Text_enableOutline(Text_JobLabel, "#000000", 1)

	-- Create Text_Job
	local Text_Job = GUI:Text_Create(Image_bg, "Text_Job", 287.00, 400.00, 15, "#f59923", [[战士]])
	GUI:setTouchEnabled(Text_Job, false)
	GUI:setTag(Text_Job, -1)
	GUI:Text_enableOutline(Text_Job, "#000000", 1)

	-- Create Text_ServerLabel
	local Text_ServerLabel = GUI:Text_Create(Image_bg, "Text_ServerLabel", 361.00, 400.00, 15, "#f59923", [[所在区服：]])
	GUI:setTouchEnabled(Text_ServerLabel, false)
	GUI:setTag(Text_ServerLabel, -1)
	GUI:Text_enableOutline(Text_ServerLabel, "#000000", 1)

	-- Create Text_Server
	local Text_Server = GUI:Text_Create(Image_bg, "Text_Server", 430.00, 400.00, 15, "#f59923", [[天天爆一区]])
	GUI:setTouchEnabled(Text_Server, false)
	GUI:setTag(Text_Server, -1)
	GUI:Text_enableOutline(Text_Server, "#000000", 1)

	-- Create Text_PriceLabel
	local Text_PriceLabel = GUI:Text_Create(Image_bg, "Text_PriceLabel", 574.00, 400.00, 15, "#f59923", [[价格：]])
	GUI:setTouchEnabled(Text_PriceLabel, false)
	GUI:setTag(Text_PriceLabel, -1)
	GUI:Text_enableOutline(Text_PriceLabel, "#000000", 1)

	-- Create Text_Price
	local Text_Price = GUI:Text_Create(Image_bg, "Text_Price", 613.00, 400.00, 15, "#f59923", [[666.666]])
	GUI:setTouchEnabled(Text_Price, false)
	GUI:setTag(Text_Price, -1)
	GUI:Text_enableOutline(Text_Price, "#000000", 1)

	-- Create Text_tipsLabel
	local Text_tipsLabel = GUI:Text_Create(Image_bg, "Text_tipsLabel", 41.00, 369.00, 13, "#f59923", [[* 装备图可点击放大，非本区商品装备图仅供参考，可前往商品所在区内交易行查看详情]])
	GUI:setTouchEnabled(Text_tipsLabel, false)
	GUI:setTag(Text_tipsLabel, -1)
	GUI:Text_enableOutline(Text_tipsLabel, "#000000", 1)

	-- Create pay_Node
	local pay_Node = GUI:Layout_Create(Panel_2, "pay_Node", 933.00, 320.00, 10.00, 10.00, false)
	GUI:Layout_setBackGroundColorType(pay_Node, 1)
	GUI:Layout_setBackGroundColor(pay_Node, "#96c8ff")
	GUI:Layout_setBackGroundColorOpacity(pay_Node, 140)
	GUI:setTouchEnabled(pay_Node, false)
	GUI:setTag(pay_Node, -1)
end
return ui