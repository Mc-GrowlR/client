local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create Button_sure
	local Button_sure = GUI:Button_Create(panel_bg, "Button_sure", 263.00, 16.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_sure, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_sure, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_sure, 16, 14, 13, 11)
	GUI:setContentSize(Button_sure, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(Button_sure, false)
	GUI:Button_setTitleText(Button_sure, "保 存")
	GUI:Button_setTitleColor(Button_sure, "#00ff00")
	GUI:Button_setTitleFontSize(Button_sure, 16)
	GUI:Button_titleEnableOutline(Button_sure, "#000000", 1)
	GUI:setAnchorPoint(Button_sure, 0.50, 0.50)
	GUI:setTouchEnabled(Button_sure, true)
	GUI:setTag(Button_sure, -1)

	-- Create page_btn_1
	local page_btn_1 = GUI:Layout_Create(panel_bg, "page_btn_1", 15.00, 350.00, 130.00, 28.00, false)
	GUI:Layout_setBackGroundColorType(page_btn_1, 1)
	GUI:Layout_setBackGroundColor(page_btn_1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(page_btn_1, 255)
	GUI:setTouchEnabled(page_btn_1, true)
	GUI:setTag(page_btn_1, 1)

	-- Create Text
	local Text = GUI:Text_Create(page_btn_1, "Text", 65.00, 14.00, 14, "#ffffff", [[手机端配置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create page_btn_2
	local page_btn_2 = GUI:Layout_Create(panel_bg, "page_btn_2", 155.00, 350.00, 130.00, 28.00, false)
	GUI:Layout_setBackGroundColorType(page_btn_2, 1)
	GUI:Layout_setBackGroundColor(page_btn_2, "#000000")
	GUI:Layout_setBackGroundColorOpacity(page_btn_2, 255)
	GUI:setTouchEnabled(page_btn_2, true)
	GUI:setTag(page_btn_2, 2)

	-- Create Text
	local Text = GUI:Text_Create(page_btn_2, "Text", 65.00, 14.00, 14, "#ffffff", [[电脑端配置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create bg_res_type
	local bg_res_type = GUI:Image_Create(panel_bg, "bg_res_type", 129.00, 330.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_res_type, 73, 74, 13, 14)
	GUI:setContentSize(bg_res_type, 100, 28)
	GUI:setIgnoreContentAdaptWithSize(bg_res_type, false)
	GUI:setAnchorPoint(bg_res_type, 0.50, 0.50)
	GUI:setTouchEnabled(bg_res_type, true)
	GUI:setTag(bg_res_type, -1)

	-- Create prefix_res_type
	local prefix_res_type = GUI:Text_Create(bg_res_type, "prefix_res_type", -4.00, 13.00, 14, "#ffffff", [[显示样式]])
	GUI:setAnchorPoint(prefix_res_type, 1.00, 0.50)
	GUI:setTouchEnabled(prefix_res_type, false)
	GUI:setTag(prefix_res_type, -1)
	GUI:Text_enableOutline(prefix_res_type, "#000000", 1)

	-- Create Text_res_type
	local Text_res_type = GUI:Text_Create(bg_res_type, "Text_res_type", 5.00, 14.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_res_type, 0.00, 0.50)
	GUI:setTouchEnabled(Text_res_type, false)
	GUI:setTag(Text_res_type, -1)
	GUI:Text_enableOutline(Text_res_type, "#000000", 1)

	-- Create arrow
	local arrow = GUI:Image_Create(bg_res_type, "arrow", 90.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow, 0.50, 0.50)
	GUI:setTouchEnabled(arrow, false)
	GUI:setTag(arrow, -1)

	-- Create bg_star1_img
	local bg_star1_img = GUI:Image_Create(panel_bg, "bg_star1_img", 77.00, 295.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_star1_img, 0, 0, 0, 0)
	GUI:setContentSize(bg_star1_img, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_star1_img, false)
	GUI:setAnchorPoint(bg_star1_img, 0.00, 0.50)
	GUI:setTouchEnabled(bg_star1_img, false)
	GUI:setTag(bg_star1_img, -1)

	-- Create prefix_img1
	local prefix_img1 = GUI:Text_Create(bg_star1_img, "prefix_img1", -60.00, 13.00, 14, "#ffffff", [[个位星星]])
	GUI:setAnchorPoint(prefix_img1, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_img1, false)
	GUI:setTag(prefix_img1, -1)
	GUI:Text_enableOutline(prefix_img1, "#000000", 1)

	-- Create InputImg1
	local InputImg1 = GUI:TextInput_Create(bg_star1_img, "InputImg1", 0.00, 0.00, 160.00, 25.00, 14)
	GUI:TextInput_setString(InputImg1, "")
	GUI:TextInput_setFontColor(InputImg1, "#ffffff")
	GUI:setTouchEnabled(InputImg1, true)
	GUI:setTag(InputImg1, -1)

	-- Create Node_img1
	local Node_img1 = GUI:Node_Create(bg_star1_img, "Node_img1", 203.00, 13.00)
	GUI:setTag(Node_img1, -1)

	-- Create sel_img1
	local sel_img1 = GUI:Layout_Create(bg_star1_img, "sel_img1", 0.00, 0.00, 220.00, 26.00, false)
	GUI:setTouchEnabled(sel_img1, true)
	GUI:setTag(sel_img1, -1)

	-- Create mask_img1
	local mask_img1 = GUI:Layout_Create(bg_star1_img, "mask_img1", 160.00, 0.00, 220.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(mask_img1, 1)
	GUI:Layout_setBackGroundColor(mask_img1, "#808080")
	GUI:Layout_setBackGroundColorOpacity(mask_img1, 183)
	GUI:setAnchorPoint(mask_img1, 1.00, 0.00)
	GUI:setTouchEnabled(mask_img1, true)
	GUI:setTag(mask_img1, -1)
	GUI:setVisible(mask_img1, false)

	-- Create Layout
	local Layout = GUI:Layout_Create(bg_star1_img, "Layout", 161.00, 1.00, 26.00, 24.00, false)
	GUI:Layout_setBackGroundColorType(Layout, 1)
	GUI:Layout_setBackGroundColor(Layout, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout, 153)
	GUI:setTouchEnabled(Layout, false)
	GUI:setTag(Layout, -1)

	-- Create ImageView
	local ImageView = GUI:Image_Create(Layout, "ImageView", -3.00, 2.00, "res/private/gui_edit/image_2.png")
	GUI:setTouchEnabled(ImageView, false)
	GUI:setTag(ImageView, -1)

	-- Create bg_star2_img
	local bg_star2_img = GUI:Image_Create(panel_bg, "bg_star2_img", 77.00, 259.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_star2_img, 0, 0, 0, 0)
	GUI:setContentSize(bg_star2_img, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_star2_img, false)
	GUI:setAnchorPoint(bg_star2_img, 0.00, 0.50)
	GUI:setTouchEnabled(bg_star2_img, false)
	GUI:setTag(bg_star2_img, -1)

	-- Create prefix_img2
	local prefix_img2 = GUI:Text_Create(bg_star2_img, "prefix_img2", -60.00, 13.00, 14, "#ffffff", [[十位星星]])
	GUI:setAnchorPoint(prefix_img2, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_img2, false)
	GUI:setTag(prefix_img2, -1)
	GUI:Text_enableOutline(prefix_img2, "#000000", 1)

	-- Create InputImg2
	local InputImg2 = GUI:TextInput_Create(bg_star2_img, "InputImg2", 0.00, 0.00, 160.00, 25.00, 14)
	GUI:TextInput_setString(InputImg2, "")
	GUI:TextInput_setFontColor(InputImg2, "#ffffff")
	GUI:setTouchEnabled(InputImg2, true)
	GUI:setTag(InputImg2, -1)

	-- Create Node_img2
	local Node_img2 = GUI:Node_Create(bg_star2_img, "Node_img2", 203.00, 13.00)
	GUI:setTag(Node_img2, -1)

	-- Create sel_img2
	local sel_img2 = GUI:Layout_Create(bg_star2_img, "sel_img2", 0.00, 0.00, 220.00, 26.00, false)
	GUI:setTouchEnabled(sel_img2, true)
	GUI:setTag(sel_img2, -1)

	-- Create mask_img2
	local mask_img2 = GUI:Layout_Create(bg_star2_img, "mask_img2", 160.00, 0.00, 220.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(mask_img2, 1)
	GUI:Layout_setBackGroundColor(mask_img2, "#808080")
	GUI:Layout_setBackGroundColorOpacity(mask_img2, 183)
	GUI:setAnchorPoint(mask_img2, 1.00, 0.00)
	GUI:setTouchEnabled(mask_img2, true)
	GUI:setTag(mask_img2, -1)
	GUI:setVisible(mask_img2, false)

	-- Create Layout
	local Layout = GUI:Layout_Create(bg_star2_img, "Layout", 161.00, 1.00, 26.00, 24.00, false)
	GUI:Layout_setBackGroundColorType(Layout, 1)
	GUI:Layout_setBackGroundColor(Layout, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout, 153)
	GUI:setTouchEnabled(Layout, false)
	GUI:setTag(Layout, -1)

	-- Create ImageView
	local ImageView = GUI:Image_Create(Layout, "ImageView", -3.00, 2.00, "res/private/gui_edit/image_2.png")
	GUI:setTouchEnabled(ImageView, false)
	GUI:setTag(ImageView, -1)

	-- Create bg_star3_img
	local bg_star3_img = GUI:Image_Create(panel_bg, "bg_star3_img", 77.00, 223.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_star3_img, 0, 0, 0, 0)
	GUI:setContentSize(bg_star3_img, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_star3_img, false)
	GUI:setAnchorPoint(bg_star3_img, 0.00, 0.50)
	GUI:setTouchEnabled(bg_star3_img, false)
	GUI:setTag(bg_star3_img, -1)

	-- Create prefix_img3
	local prefix_img3 = GUI:Text_Create(bg_star3_img, "prefix_img3", -60.00, 13.00, 14, "#ffffff", [[百位星星]])
	GUI:setAnchorPoint(prefix_img3, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_img3, false)
	GUI:setTag(prefix_img3, -1)
	GUI:Text_enableOutline(prefix_img3, "#000000", 1)

	-- Create InputImg3
	local InputImg3 = GUI:TextInput_Create(bg_star3_img, "InputImg3", 1.00, 0.00, 160.00, 25.00, 14)
	GUI:TextInput_setString(InputImg3, "")
	GUI:TextInput_setFontColor(InputImg3, "#ffffff")
	GUI:setTouchEnabled(InputImg3, true)
	GUI:setTag(InputImg3, -1)

	-- Create Node_img3
	local Node_img3 = GUI:Node_Create(bg_star3_img, "Node_img3", 203.00, 13.00)
	GUI:setTag(Node_img3, -1)

	-- Create sel_img3
	local sel_img3 = GUI:Layout_Create(bg_star3_img, "sel_img3", 0.00, 0.00, 220.00, 26.00, false)
	GUI:setTouchEnabled(sel_img3, true)
	GUI:setTag(sel_img3, -1)

	-- Create mask_img3
	local mask_img3 = GUI:Layout_Create(bg_star3_img, "mask_img3", 160.00, 0.00, 220.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(mask_img3, 1)
	GUI:Layout_setBackGroundColor(mask_img3, "#808080")
	GUI:Layout_setBackGroundColorOpacity(mask_img3, 183)
	GUI:setAnchorPoint(mask_img3, 1.00, 0.00)
	GUI:setTouchEnabled(mask_img3, true)
	GUI:setTag(mask_img3, -1)
	GUI:setVisible(mask_img3, false)

	-- Create Layout
	local Layout = GUI:Layout_Create(bg_star3_img, "Layout", 161.00, 1.00, 26.00, 24.00, false)
	GUI:Layout_setBackGroundColorType(Layout, 1)
	GUI:Layout_setBackGroundColor(Layout, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout, 153)
	GUI:setTouchEnabled(Layout, false)
	GUI:setTag(Layout, -1)

	-- Create ImageView
	local ImageView = GUI:Image_Create(Layout, "ImageView", -3.00, 2.00, "res/private/gui_edit/image_2.png")
	GUI:setTouchEnabled(ImageView, false)
	GUI:setTag(ImageView, -1)

	-- Create bg_star1_sfx
	local bg_star1_sfx = GUI:Image_Create(panel_bg, "bg_star1_sfx", 77.00, 187.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_star1_sfx, 0, 0, 0, 0)
	GUI:setContentSize(bg_star1_sfx, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_star1_sfx, false)
	GUI:setAnchorPoint(bg_star1_sfx, 0.00, 0.50)
	GUI:setTouchEnabled(bg_star1_sfx, false)
	GUI:setTag(bg_star1_sfx, -1)

	-- Create prefix_sfx1
	local prefix_sfx1 = GUI:Text_Create(bg_star1_sfx, "prefix_sfx1", -72.00, 13.00, 14, "#ffffff", [[个位特效ID]])
	GUI:setAnchorPoint(prefix_sfx1, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_sfx1, false)
	GUI:setTag(prefix_sfx1, -1)
	GUI:Text_enableOutline(prefix_sfx1, "#000000", 1)

	-- Create InputSfx1
	local InputSfx1 = GUI:TextInput_Create(bg_star1_sfx, "InputSfx1", 0.00, 0.00, 160.00, 25.00, 14)
	GUI:TextInput_setString(InputSfx1, "")
	GUI:TextInput_setFontColor(InputSfx1, "#ffffff")
	GUI:setTouchEnabled(InputSfx1, true)
	GUI:setTag(InputSfx1, -1)

	-- Create Node_sfx1
	local Node_sfx1 = GUI:Node_Create(bg_star1_sfx, "Node_sfx1", 200.00, 13.00)
	GUI:setTag(Node_sfx1, -1)

	-- Create mask_sfx1
	local mask_sfx1 = GUI:Layout_Create(bg_star1_sfx, "mask_sfx1", 160.00, 0.00, 235.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(mask_sfx1, 1)
	GUI:Layout_setBackGroundColor(mask_sfx1, "#808080")
	GUI:Layout_setBackGroundColorOpacity(mask_sfx1, 183)
	GUI:setAnchorPoint(mask_sfx1, 1.00, 0.00)
	GUI:setTouchEnabled(mask_sfx1, true)
	GUI:setTag(mask_sfx1, -1)
	GUI:setVisible(mask_sfx1, false)

	-- Create bg_star2_sfx
	local bg_star2_sfx = GUI:Image_Create(panel_bg, "bg_star2_sfx", 77.00, 152.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_star2_sfx, 0, 0, 0, 0)
	GUI:setContentSize(bg_star2_sfx, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_star2_sfx, false)
	GUI:setAnchorPoint(bg_star2_sfx, 0.00, 0.50)
	GUI:setTouchEnabled(bg_star2_sfx, false)
	GUI:setTag(bg_star2_sfx, -1)

	-- Create prefix_sfx2
	local prefix_sfx2 = GUI:Text_Create(bg_star2_sfx, "prefix_sfx2", -72.00, 13.00, 14, "#ffffff", [[十位特效ID]])
	GUI:setAnchorPoint(prefix_sfx2, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_sfx2, false)
	GUI:setTag(prefix_sfx2, -1)
	GUI:Text_enableOutline(prefix_sfx2, "#000000", 1)

	-- Create InputSfx2
	local InputSfx2 = GUI:TextInput_Create(bg_star2_sfx, "InputSfx2", 0.00, 0.00, 160.00, 25.00, 14)
	GUI:TextInput_setString(InputSfx2, "")
	GUI:TextInput_setFontColor(InputSfx2, "#ffffff")
	GUI:setTouchEnabled(InputSfx2, true)
	GUI:setTag(InputSfx2, -1)

	-- Create Node_sfx2
	local Node_sfx2 = GUI:Node_Create(bg_star2_sfx, "Node_sfx2", 200.00, 13.00)
	GUI:setTag(Node_sfx2, -1)

	-- Create mask_sfx2
	local mask_sfx2 = GUI:Layout_Create(bg_star2_sfx, "mask_sfx2", 160.00, 0.00, 235.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(mask_sfx2, 1)
	GUI:Layout_setBackGroundColor(mask_sfx2, "#808080")
	GUI:Layout_setBackGroundColorOpacity(mask_sfx2, 183)
	GUI:setAnchorPoint(mask_sfx2, 1.00, 0.00)
	GUI:setTouchEnabled(mask_sfx2, true)
	GUI:setTag(mask_sfx2, -1)
	GUI:setVisible(mask_sfx2, false)

	-- Create bg_star3_sfx
	local bg_star3_sfx = GUI:Image_Create(panel_bg, "bg_star3_sfx", 77.00, 116.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_star3_sfx, 0, 0, 0, 0)
	GUI:setContentSize(bg_star3_sfx, 160, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_star3_sfx, false)
	GUI:setAnchorPoint(bg_star3_sfx, 0.00, 0.50)
	GUI:setTouchEnabled(bg_star3_sfx, false)
	GUI:setTag(bg_star3_sfx, -1)

	-- Create prefix_sfx3
	local prefix_sfx3 = GUI:Text_Create(bg_star3_sfx, "prefix_sfx3", -72.00, 13.00, 14, "#ffffff", [[百位特效ID]])
	GUI:setAnchorPoint(prefix_sfx3, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_sfx3, false)
	GUI:setTag(prefix_sfx3, -1)
	GUI:Text_enableOutline(prefix_sfx3, "#000000", 1)

	-- Create InputSfx3
	local InputSfx3 = GUI:TextInput_Create(bg_star3_sfx, "InputSfx3", 0.00, 0.00, 160.00, 25.00, 14)
	GUI:TextInput_setString(InputSfx3, "")
	GUI:TextInput_setFontColor(InputSfx3, "#ffffff")
	GUI:setTouchEnabled(InputSfx3, true)
	GUI:setTag(InputSfx3, -1)

	-- Create Node_sfx3
	local Node_sfx3 = GUI:Node_Create(bg_star3_sfx, "Node_sfx3", 200.00, 13.00)
	GUI:setTag(Node_sfx3, -1)

	-- Create mask_sfx3
	local mask_sfx3 = GUI:Layout_Create(bg_star3_sfx, "mask_sfx3", 160.00, 0.00, 235.00, 26.00, false)
	GUI:Layout_setBackGroundColorType(mask_sfx3, 1)
	GUI:Layout_setBackGroundColor(mask_sfx3, "#808080")
	GUI:Layout_setBackGroundColorOpacity(mask_sfx3, 183)
	GUI:setAnchorPoint(mask_sfx3, 1.00, 0.00)
	GUI:setTouchEnabled(mask_sfx3, true)
	GUI:setTag(mask_sfx3, -1)
	GUI:setVisible(mask_sfx3, false)

	-- Create bg_res_spaceX
	local bg_res_spaceX = GUI:Image_Create(panel_bg, "bg_res_spaceX", 77.00, 81.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_res_spaceX, 0, 0, 0, 0)
	GUI:setContentSize(bg_res_spaceX, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_res_spaceX, false)
	GUI:setAnchorPoint(bg_res_spaceX, 0.00, 0.50)
	GUI:setTouchEnabled(bg_res_spaceX, false)
	GUI:setTag(bg_res_spaceX, -1)

	-- Create prefix_res_spaceX
	local prefix_res_spaceX = GUI:Text_Create(bg_res_spaceX, "prefix_res_spaceX", -59.00, 13.00, 14, "#ffffff", [[横向间隔]])
	GUI:setAnchorPoint(prefix_res_spaceX, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_res_spaceX, false)
	GUI:setTag(prefix_res_spaceX, -1)
	GUI:Text_enableOutline(prefix_res_spaceX, "#000000", 1)

	-- Create InpuResSpaceX
	local InpuResSpaceX = GUI:TextInput_Create(bg_res_spaceX, "InpuResSpaceX", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(InpuResSpaceX, "")
	GUI:TextInput_setFontColor(InpuResSpaceX, "#ffffff")
	GUI:setTouchEnabled(InpuResSpaceX, true)
	GUI:setTag(InpuResSpaceX, -1)

	-- Create bg_res_spaceY
	local bg_res_spaceY = GUI:Image_Create(panel_bg, "bg_res_spaceY", 237.00, 81.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_res_spaceY, 0, 0, 0, 0)
	GUI:setContentSize(bg_res_spaceY, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_res_spaceY, false)
	GUI:setAnchorPoint(bg_res_spaceY, 0.00, 0.50)
	GUI:setTouchEnabled(bg_res_spaceY, false)
	GUI:setTag(bg_res_spaceY, -1)

	-- Create prefix_res_spaceY
	local prefix_res_spaceY = GUI:Text_Create(bg_res_spaceY, "prefix_res_spaceY", -62.00, 13.00, 14, "#ffffff", [[纵向间隔]])
	GUI:setAnchorPoint(prefix_res_spaceY, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_res_spaceY, false)
	GUI:setTag(prefix_res_spaceY, -1)
	GUI:Text_enableOutline(prefix_res_spaceY, "#000000", 1)

	-- Create InpuResSpaceY
	local InpuResSpaceY = GUI:TextInput_Create(bg_res_spaceY, "InpuResSpaceY", 0.00, 0.00, 60.00, 25.00, 14)
	GUI:TextInput_setString(InpuResSpaceY, "")
	GUI:TextInput_setFontColor(InpuResSpaceY, "#ffffff")
	GUI:setTouchEnabled(InpuResSpaceY, true)
	GUI:setTag(InpuResSpaceY, -1)

	-- Create bg_star_w
	local bg_star_w = GUI:Image_Create(panel_bg, "bg_star_w", 95.00, 45.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_star_w, 0, 0, 0, 0)
	GUI:setContentSize(bg_star_w, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_star_w, false)
	GUI:setAnchorPoint(bg_star_w, 0.00, 0.50)
	GUI:setTouchEnabled(bg_star_w, false)
	GUI:setTag(bg_star_w, -1)

	-- Create prefix_star_w
	local prefix_star_w = GUI:Text_Create(bg_star_w, "prefix_star_w", -90.00, 13.00, 14, "#ffffff", [[单个星星宽度]])
	GUI:setAnchorPoint(prefix_star_w, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_star_w, false)
	GUI:setTag(prefix_star_w, -1)
	GUI:Text_enableOutline(prefix_star_w, "#000000", 1)

	-- Create InputStarW
	local InputStarW = GUI:TextInput_Create(bg_star_w, "InputStarW", 0.00, 0.00, 50.00, 25.00, 14)
	GUI:TextInput_setString(InputStarW, "")
	GUI:TextInput_setFontColor(InputStarW, "#ffffff")
	GUI:setTouchEnabled(InputStarW, true)
	GUI:setTag(InputStarW, -1)

	-- Create bg_star_h
	local bg_star_h = GUI:Image_Create(panel_bg, "bg_star_h", 248.00, 45.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_star_h, 0, 0, 0, 0)
	GUI:setContentSize(bg_star_h, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_star_h, false)
	GUI:setAnchorPoint(bg_star_h, 0.00, 0.50)
	GUI:setTouchEnabled(bg_star_h, false)
	GUI:setTag(bg_star_h, -1)

	-- Create prefix_star_h
	local prefix_star_h = GUI:Text_Create(bg_star_h, "prefix_star_h", -90.00, 13.00, 14, "#ffffff", [[单个星星高度]])
	GUI:setAnchorPoint(prefix_star_h, 0.00, 0.50)
	GUI:setTouchEnabled(prefix_star_h, false)
	GUI:setTag(prefix_star_h, -1)
	GUI:Text_enableOutline(prefix_star_h, "#000000", 1)

	-- Create InputStarH
	local InputStarH = GUI:TextInput_Create(bg_star_h, "InputStarH", 0.00, 0.00, 50.00, 25.00, 14)
	GUI:TextInput_setString(InputStarH, "")
	GUI:TextInput_setFontColor(InputStarH, "#ffffff")
	GUI:setTouchEnabled(InputStarH, true)
	GUI:setTag(InputStarH, -1)

	-- Create Layout_hide_pullDownList
	local Layout_hide_pullDownList = GUI:Layout_Create(panel_bg, "Layout_hide_pullDownList", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(Layout_hide_pullDownList, true)
	GUI:setTag(Layout_hide_pullDownList, -1)
	GUI:setVisible(Layout_hide_pullDownList, false)

	-- Create Image_pulldown_bg
	local Image_pulldown_bg = GUI:Image_Create(panel_bg, "Image_pulldown_bg", 81.00, 316.00, "res/public/1900000677.png")
	GUI:Image_setScale9Slice(Image_pulldown_bg, 22, 21, 33, 34)
	GUI:setContentSize(Image_pulldown_bg, 100, 200)
	GUI:setIgnoreContentAdaptWithSize(Image_pulldown_bg, false)
	GUI:setAnchorPoint(Image_pulldown_bg, 0.50, 1.00)
	GUI:setTouchEnabled(Image_pulldown_bg, false)
	GUI:setTag(Image_pulldown_bg, -1)
	GUI:setVisible(Image_pulldown_bg, false)

	-- Create ListView_pulldown
	local ListView_pulldown = GUI:ListView_Create(Image_pulldown_bg, "ListView_pulldown", 50.00, 199.00, 98.00, 198.00, 1)
	GUI:ListView_setGravity(ListView_pulldown, 5)
	GUI:setAnchorPoint(ListView_pulldown, 0.50, 1.00)
	GUI:setTouchEnabled(ListView_pulldown, true)
	GUI:setTag(ListView_pulldown, -1)
end
return ui