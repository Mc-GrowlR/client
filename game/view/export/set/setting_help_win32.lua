local ui = {}
function ui.init(parent)
	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(parent, "Panel_1", 0.00, 0.00, 606.00, 390.00, false)
	GUI:setTouchEnabled(Panel_1, true)
	GUI:setTag(Panel_1, -1)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Panel_1, "Image_1", 10.00, 380.00, "res/private/new_setting/textBg.png")
	GUI:Image_setScale9Slice(Image_1, 33, 33, 9, 9)
	GUI:setContentSize(Image_1, 586, 360)
	GUI:setIgnoreContentAdaptWithSize(Image_1, false)
	GUI:setAnchorPoint(Image_1, 0.00, 1.00)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, -1)

	-- Create Image_3
	local Image_3 = GUI:Image_Create(Image_1, "Image_3", 124.00, 41.00, "res/private/new_setting/textBg.png")
	GUI:Image_setScale9Slice(Image_3, 33, 33, 9, 9)
	GUI:setContentSize(Image_3, 462, 320)
	GUI:setIgnoreContentAdaptWithSize(Image_3, false)
	GUI:setTouchEnabled(Image_3, false)
	GUI:setTag(Image_3, -1)

	-- Create ListView_1
	local ListView_1 = GUI:ListView_Create(Image_1, "ListView_1", 130.00, 43.00, 445.00, 314.00, 1)
	GUI:ListView_setGravity(ListView_1, 5)
	GUI:setTouchEnabled(ListView_1, true)
	GUI:setTag(ListView_1, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(ListView_1, "Text_1", 22.00, 304.00, 12, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create ListView_2
	local ListView_2 = GUI:ListView_Create(Image_1, "ListView_2", 0.00, 360.00, 124.00, 360.00, 1)
	GUI:ListView_setGravity(ListView_2, 2)
	GUI:ListView_setItemsMargin(ListView_2, 10)
	GUI:setAnchorPoint(ListView_2, 0.00, 1.00)
	GUI:setTouchEnabled(ListView_2, true)
	GUI:setTag(ListView_2, -1)

	-- Create Button_1
	local Button_1 = GUI:Button_Create(Image_1, "Button_1", 0.00, 400.00, "res/public/1900000673.png")
	GUI:Button_loadTexturePressed(Button_1, "res/public/1900000674.png")
	GUI:Button_loadTextureDisabled(Button_1, "res/public/1900000674.png")
	GUI:Button_setScale9Slice(Button_1, 16, 14, 12, 10)
	GUI:setContentSize(Button_1, 120, 35)
	GUI:setIgnoreContentAdaptWithSize(Button_1, false)
	GUI:Button_setTitleText(Button_1, "儿童隐私协议")
	GUI:Button_setTitleColor(Button_1, "#ffffff")
	GUI:Button_setTitleFontSize(Button_1, 16)
	GUI:Button_titleEnableOutline(Button_1, "#000000", 1)
	GUI:setAnchorPoint(Button_1, 0.00, 1.00)
	GUI:setTouchEnabled(Button_1, true)
	GUI:setTag(Button_1, -1)

	-- Create Panel_ICP
	local Panel_ICP = GUI:Layout_Create(Image_1, "Panel_ICP", 127.00, 3.00, 300.00, 38.00, false)
	GUI:setTouchEnabled(Panel_ICP, false)
	GUI:setTag(Panel_ICP, -1)

	-- Create ICP_Desc
	local ICP_Desc = GUI:RichText_Create(Panel_ICP, "ICP_Desc", 8.00, 9.00, "ICP备案号:粤B2-20090059-1824A", 250.00, 14, "#ffffff", 4, nil, "fonts/font2.ttf")
	GUI:setTag(ICP_Desc, -1)

	-- Create ICP_Button
	local ICP_Button = GUI:Button_Create(Panel_ICP, "ICP_Button", 232.00, 5.00, "res/public/btn_fanye_03.png")
	GUI:Button_loadTexturePressed(ICP_Button, "res/public/btn_fanye_03_1.png")
	GUI:Button_loadTextureDisabled(ICP_Button, "res/public/btn_fanye_03_1.png")
	GUI:Button_setTitleText(ICP_Button, "查询")
	GUI:Button_setTitleColor(ICP_Button, "#ffffff")
	GUI:Button_setTitleFontSize(ICP_Button, 14)
	GUI:Button_titleEnableOutline(ICP_Button, "#000000", 1)
	GUI:setTouchEnabled(ICP_Button, true)
	GUI:setTag(ICP_Button, -1)
end
return ui