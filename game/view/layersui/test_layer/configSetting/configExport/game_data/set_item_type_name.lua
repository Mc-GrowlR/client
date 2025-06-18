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

	-- Create Button_set
	local Button_set = GUI:Button_Create(panel_bg, "Button_set", 190.00, 24.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_setScale9Slice(Button_set, 16, 28, 13, 10)
	GUI:setContentSize(Button_set, 60, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_set, false)
	GUI:Button_setTitleText(Button_set, "配 置")
	GUI:Button_setTitleColor(Button_set, "#00ff00")
	GUI:Button_setTitleFontSize(Button_set, 16)
	GUI:Button_titleEnableOutline(Button_set, "#000000", 1)
	GUI:setAnchorPoint(Button_set, 0.50, 0.50)
	GUI:setTouchEnabled(Button_set, true)
	GUI:setTag(Button_set, -1)

	-- Create ScrollView_items
	local ScrollView_items = GUI:ScrollView_Create(panel_bg, "ScrollView_items", 0.00, 367.00, 300.00, 323.00, 1)
	GUI:ScrollView_setInnerContainerSize(ScrollView_items, 300.00, 323.00)
	GUI:setAnchorPoint(ScrollView_items, 0.00, 1.00)
	GUI:setTouchEnabled(ScrollView_items, true)
	GUI:setTag(ScrollView_items, -1)
end
return ui