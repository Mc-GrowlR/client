local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create Button_sure
	local Button_sure = GUI:Button_Create(panel_bg, "Button_sure", 263.00, 24.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_sure, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_sure, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_sure, 16, 14, 13, 11)
	GUI:setContentSize(Button_sure, 60, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_sure, false)
	GUI:Button_setTitleText(Button_sure, "保 存")
	GUI:Button_setTitleColor(Button_sure, "#00ff00")
	GUI:Button_setTitleFontSize(Button_sure, 16)
	GUI:Button_titleEnableOutline(Button_sure, "#000000", 1)
	GUI:setAnchorPoint(Button_sure, 0.50, 0.50)
	GUI:setTouchEnabled(Button_sure, true)
	GUI:setTag(Button_sure, -1)

	-- Create Layout0
	local Layout0 = GUI:Layout_Create(panel_bg, "Layout0", 30.00, 300.00, 150.00, 30.00, false)
	GUI:setTouchEnabled(Layout0, true)
	GUI:setTag(Layout0, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(Layout0, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(Layout0, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout0, "Text", 43.00, 15.00, 16, "#ffffff", [[圆形怒气条]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Layout1
	local Layout1 = GUI:Layout_Create(panel_bg, "Layout1", 30.00, 255.00, 150.00, 30.00, false)
	GUI:setTouchEnabled(Layout1, true)
	GUI:setTag(Layout1, -1)

	-- Create img_sel
	local img_sel = GUI:Image_Create(Layout1, "img_sel", 12.00, 15.00, "res/public/btn_npcfh_05.png")
	GUI:setAnchorPoint(img_sel, 0.00, 0.50)
	GUI:setTouchEnabled(img_sel, false)
	GUI:setTag(img_sel, -1)

	-- Create img_unsel
	local img_unsel = GUI:Image_Create(Layout1, "img_unsel", 12.00, 15.00, "res/public/btn_npcfh_06.png")
	GUI:setAnchorPoint(img_unsel, 0.00, 0.50)
	GUI:setTouchEnabled(img_unsel, false)
	GUI:setTag(img_unsel, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout1, "Text", 43.00, 15.00, 16, "#ffffff", [[条形怒气条]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)
end
return ui