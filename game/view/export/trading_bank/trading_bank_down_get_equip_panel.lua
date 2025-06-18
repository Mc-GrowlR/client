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
	local Image_bg = GUI:Image_Create(Panel_2, "Image_bg", 568.00, 320.00, "res/private/trading_bank/bg_npc_08.jpg")
	GUI:setContentSize(Image_bg, 406, 240)
	GUI:setIgnoreContentAdaptWithSize(Image_bg, false)
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, true)
	GUI:setTag(Image_bg, 312)

	-- Create Button_next
	local Button_next = GUI:Button_Create(Image_bg, "Button_next", 304.00, 107.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_next, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_next, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_next, 15, 15, 11, 11)
	GUI:setContentSize(Button_next, 100, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_next, false)
	GUI:Button_setTitleText(Button_next, "确认下架")
	GUI:Button_setTitleColor(Button_next, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_next, 18)
	GUI:Button_titleEnableOutline(Button_next, "#000000", 1)
	GUI:setAnchorPoint(Button_next, 0.50, 0.50)
	GUI:setTouchEnabled(Button_next, true)
	GUI:setTag(Button_next, 314)

	-- Create Button_close
	local Button_close = GUI:Button_Create(Image_bg, "Button_close", 406.00, 199.00, "res/private/trading_bank/1900000510.png")
	GUI:Button_loadTexturePressed(Button_close, "res/private/trading_bank/1900000511.png")
	GUI:Button_loadTextureDisabled(Button_close, "res/private/trading_bank/1900000511.png")
	GUI:Button_setTitleText(Button_close, "")
	GUI:Button_setTitleColor(Button_close, "#ffffff")
	GUI:Button_setTitleFontSize(Button_close, 14)
	GUI:Button_titleEnableOutline(Button_close, "#000000", 1)
	GUI:setTouchEnabled(Button_close, true)
	GUI:setTag(Button_close, -1)

	-- Create Image_titleBg
	local Image_titleBg = GUI:Image_Create(Image_bg, "Image_titleBg", 51.00, 185.00, "res/private/trading_bank/word_sxbt_05.png")
	GUI:setTouchEnabled(Image_titleBg, false)
	GUI:setTag(Image_titleBg, -1)

	-- Create Image_title
	local Image_title = GUI:Image_Create(Image_bg, "Image_title", 201.00, 179.00, "res/private/trading_bank/img_title_down.png")
	GUI:setAnchorPoint(Image_title, 0.50, 0.00)
	GUI:setTouchEnabled(Image_title, false)
	GUI:setTag(Image_title, -1)

	-- Create Image_equipBg
	local Image_equipBg = GUI:Image_Create(Image_bg, "Image_equipBg", 50.00, 81.00, "res/private/trading_bank/img_sell_equipBg.png")
	GUI:setTouchEnabled(Image_equipBg, false)
	GUI:setTag(Image_equipBg, -1)

	-- Create Text_equip_name
	local Text_equip_name = GUI:Text_Create(Image_equipBg, "Text_equip_name", 71.00, 35.00, 16, "#ffffff", [[大吐龙]])
	GUI:setTouchEnabled(Text_equip_name, false)
	GUI:setTag(Text_equip_name, -1)
	GUI:Text_enableOutline(Text_equip_name, "#000000", 1)

	-- Create Text_desc1
	local Text_desc1 = GUI:Text_Create(Image_equipBg, "Text_desc1", 107.00, 14.00, 16, "#ffffff", [[售价:]])
	GUI:setAnchorPoint(Text_desc1, 1.00, 0.50)
	GUI:setTouchEnabled(Text_desc1, false)
	GUI:setTag(Text_desc1, 369)
	GUI:Text_enableOutline(Text_desc1, "#000000", 1)

	-- Create Text_price
	local Text_price = GUI:Text_Create(Image_equipBg, "Text_price", 114.00, 13.00, 14, "#00ff00", [[99元]])
	GUI:setAnchorPoint(Text_price, 0.00, 0.50)
	GUI:setTouchEnabled(Text_price, false)
	GUI:setTag(Text_price, 271)
	GUI:Text_enableOutline(Text_price, "#000000", 1)
end
return ui