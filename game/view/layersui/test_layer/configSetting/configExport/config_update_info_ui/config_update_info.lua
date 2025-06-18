local ui = {}
function ui.init(parent)
	-- Create Layer
	local Layer = GUI:Node_Create(parent, "Layer", 0.00, 0.00)
	GUI:setAnchorPoint(Layer, 0.50, 0.50)
	GUI:setTag(Layer, -1)

	-- Create Panel_main
	local Panel_main = GUI:Layout_Create(Layer, "Panel_main", 0.00, 0.00, 936.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_main, 1)
	GUI:Layout_setBackGroundColor(Panel_main, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_main, 76)
	GUI:setTouchEnabled(Panel_main, false)
	GUI:setTag(Panel_main, 4)

	-- Create Text_title
	local Text_title = GUI:Text_Create(Panel_main, "Text_title", 468.00, 605.00, 24, "#00ff00", [[可视化配置更新内容]])
	GUI:setAnchorPoint(Text_title, 0.50, 0.00)
	GUI:setTouchEnabled(Text_title, false)
	GUI:setTag(Text_title, -1)
	GUI:Text_enableOutline(Text_title, "#000000", 1)

	-- Create Text_role
	local Text_role = GUI:Text_Create(Panel_main, "Text_role", 10.00, 5.00, 14, "#bdbdb5", [[1.对比的表为可视化配置中的表。
2.会同步本地没有，官方有的表。
3.会同步官方表中新增的key值。
4.本地已修改的数据，保持不变。]])
	GUI:setIgnoreContentAdaptWithSize(Text_role, false)
	GUI:Text_setTextAreaSize(Text_role, 700, 70)
	GUI:setTouchEnabled(Text_role, false)
	GUI:setTag(Text_role, -1)
	GUI:Text_enableOutline(Text_role, "#000000", 1)

	-- Create Button_update
	local Button_update = GUI:Button_Create(Panel_main, "Button_update", 850.00, 34.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_update, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_update, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_update, 15, 16, 12, 12)
	GUI:setContentSize(Button_update, 120, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_update, false)
	GUI:Button_setTitleText(Button_update, "一键同步官方配置")
	GUI:Button_setTitleColor(Button_update, "#10ff00")
	GUI:Button_setTitleFontSize(Button_update, 14)
	GUI:Button_titleEnableOutline(Button_update, "#000000", 1)
	GUI:setAnchorPoint(Button_update, 0.50, 0.50)
	GUI:setTouchEnabled(Button_update, true)
	GUI:setTag(Button_update, -1)

	-- Create Button_server
	local Button_server = GUI:Button_Create(Panel_main, "Button_server", 680.00, 34.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_server, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_server, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_server, 15, 16, 12, 12)
	GUI:setContentSize(Button_server, 120, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_server, false)
	GUI:Button_setTitleText(Button_server, "同步服务配置")
	GUI:Button_setTitleColor(Button_server, "#10ff00")
	GUI:Button_setTitleFontSize(Button_server, 14)
	GUI:Button_titleEnableOutline(Button_server, "#000000", 1)
	GUI:setAnchorPoint(Button_server, 0.50, 0.50)
	GUI:setTouchEnabled(Button_server, true)
	GUI:setTag(Button_server, -1)
	GUI:setVisible(Button_server, false)

	-- Create ScrollView
	local ScrollView = GUI:ScrollView_Create(Panel_main, "ScrollView", 0.00, 80.00, 936.00, 520.00, 1)
	GUI:ScrollView_setBackGroundColorType(ScrollView, 1)
	GUI:ScrollView_setBackGroundColor(ScrollView, "#000000")
	GUI:ScrollView_setBackGroundColorOpacity(ScrollView, 127)
	GUI:ScrollView_setInnerContainerSize(ScrollView, 936.00, 800.00)
	GUI:setTouchEnabled(ScrollView, true)
	GUI:setTag(ScrollView, -1)

	-- Create Layout
	local Layout = GUI:Layout_Create(ScrollView, "Layout", 0.00, 800.00, 936.00, 800.00, false)
	GUI:setAnchorPoint(Layout, 0.00, 1.00)
	GUI:setTouchEnabled(Layout, false)
	GUI:setTag(Layout, -1)

	-- Create Text_info
	local Text_info = GUI:Text_Create(Layout, "Text_info", 0.00, 800.00, 16, "#4ae74a", [[一.新增字段
1.增加cfg_game_data字段HideNGHUD 隐藏内功条开关
2.增加cfg_game_data字段SUI_FONT_PATH脚本NPC界面字体文件路径统一配置 例如填: "fonts/font1.ttf"
3.增加cfg_game_data字段firstHeroAutoUse优先提示英雄穿戴开关
4.增加cfg_game_data配置auto_set_topHat_posY顶戴显示位置走新老配置开关（ 新配置顶戴称号同时佩戴 称号佩戴需要调整顶戴坐标位置，称号佩戴触发调整）
5.增加cfg_game_data配置红点变量RedPointValue设置（根据m2-功能设置-其他设置-前端变量推送 对应变量 增加前端面板显示变量）
6.增加cfg_game_data配置ide_Select_Collection隐藏采集怪弹窗开关
7.增加cfg_game_data配置手机端主界面聊天栏最大显示条数设置 MobileMainMaxChatNum（ 默认值是7）
8.增加cfg_game_data字段 DEFAULT_FONT_SIZE 配置字体大小设置（游戏里90%以上字体大小会根据这个改变）   
9.增加cfg_game_data字段TradingBankHideSU =1 隐藏交易行 自定义装备按钮
10.增加cfg_game_data字段PCAssistNearShow     PC端导航栏显示任务/附近按钮（0为默认，1为开启，默认为0）
12.增加cfg_game_data字段FindDropItemRange  12  自动捡取范围识别配置
13.增加cfg_game_data字段check_skill_neighbors  0  内挂群体技能新方式(1为开启 群怪才放群体技能)  
14.增加cfg_game_data字段Integratedfashion  1#1   (斗笠#发型) 一体时装是否斗笠和发型  0默认显示 1=不显示  
15.增加cfg_game_data字段auto_set_topHat_posY  1   顶戴显示位置默走新配置 1走老配置（新配置顶戴称号同时佩戴 称号佩戴需要调整顶戴坐标位置，称号佩戴触发调整）
16.增加cfg_game_data字段PCPropertyAdaptCustom  1    PC端是否根据自定义UI聊天框适配（0为默认，1为适配，默认为0）
17.增加cfg_game_data字段FontAtlasAntialiasEnabled  1    PC端抗锯齿模式（0为不开启，1为开启，默认为0）推荐设置为：1  
18.增加cfg_game_data字段ShowSkillCDTime  0    开启技能按钮数字CD显示
19.增加cfg_game_data字段firstHeroAutoUse  0    优先提示英雄穿戴(0不开启 1=开启)
20.增加cfg_game_data字段bangdingguize 模式1：1#2#3:(包含#分割=物品有一个绑定规则时显示锁图标与已绑定标记)模式2(满足&分割物品有全部绑定规则时显示锁图标与已绑定标记)
21.增加cfg_game_data字段prompt  res/public/btn_npcfh_04.png#5#1#0.6|res/public/btn_npcfh_04.png#10#-7#1    背包满物品如:(聚灵珠(大)提示红点(PC端#X坐标#Y坐标#缩放比例|移动端#X坐标#Y坐标#缩放比例)
22.增加cfg_game_data字段：TradingBankHideSUI =1 时隐藏交易行自定义装备按钮
23.增加cfg_gamedata字段：AutoMoveRange_Collection 采集距离,用于采集怪使用，超出距离采集时会自动寻路到此范围内。
24.增加cfg_game_data字段 PCFontConfig  2#12    PC端及面板支持宋体并可统一设置PC字体大小  字体#大小(字体：1黑体 2宋体   大小：0默认 大于0为字体大小)]])
	GUI:setIgnoreContentAdaptWithSize(Text_info, false)
	GUI:Text_setTextAreaSize(Text_info, 936, 800)
	GUI:setAnchorPoint(Text_info, 0.00, 1.00)
	GUI:setTouchEnabled(Text_info, false)
	GUI:setTag(Text_info, -1)
	GUI:Text_enableOutline(Text_info, "#000000", 1)
end
return ui