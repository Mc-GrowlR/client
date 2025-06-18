local ui = {}
function ui.init(parent)
	-- Create Scene
	local Scene = GUI:Node_Create(parent, "Scene", 0.00, 0.00)
	GUI:setAnchorPoint(Scene, 0.50, 0.50)
	GUI:setTag(Scene, -1)

	-- Create Panel_background
	local Panel_background = GUI:Layout_Create(Scene, "Panel_background", 0.00, 0.00, 3000.00, 3000.00, false)
	GUI:Layout_setBackGroundColorType(Panel_background, 1)
	GUI:Layout_setBackGroundColor(Panel_background, "#808080")
	GUI:Layout_setBackGroundColorOpacity(Panel_background, 229)
	GUI:setTouchEnabled(Panel_background, true)
	GUI:setTag(Panel_background, 20)

	-- Create nodeUI
	local nodeUI = GUI:Node_Create(Scene, "nodeUI", 200.00, 0.00)
	GUI:setTag(nodeUI, -1)

	-- Create Button_close
	local Button_close = GUI:Button_Create(Scene, "Button_close", 1128.00, 640.00, "Default/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_close, "Default/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_close, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_close, 16, 14, 13, 9)
	GUI:setContentSize(Button_close, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_close, false)
	GUI:Button_setTitleText(Button_close, "退出")
	GUI:Button_setTitleColor(Button_close, "#414146")
	GUI:Button_setTitleFontSize(Button_close, 16)
	GUI:Button_titleDisableOutLine(Button_close)
	GUI:setAnchorPoint(Button_close, 1.00, 1.00)
	GUI:setTouchEnabled(Button_close, true)
	GUI:setTag(Button_close, 13)

	-- Create ListView_page
	local ListView_page = GUI:ListView_Create(Scene, "ListView_page", 0.00, 0.00, 200.00, 1136.00, 1)
	GUI:ListView_setBackGroundColorType(ListView_page, 1)
	GUI:ListView_setBackGroundColor(ListView_page, "#000000")
	GUI:ListView_setBackGroundColorOpacity(ListView_page, 76)
	GUI:ListView_setGravity(ListView_page, 5)
	GUI:ListView_setItemsMargin(ListView_page, 2)
	GUI:setTouchEnabled(ListView_page, true)
	GUI:setTag(ListView_page, -1)
end
return ui