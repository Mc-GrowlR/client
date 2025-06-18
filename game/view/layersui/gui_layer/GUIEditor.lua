local BaseLayer = requireLayerUI("BaseLayer")
local GUIEditor = class("GUIEditor", BaseLayer)

local QuickCell = require("util/QuickCell")
local Queue     = requireUtil("queue")
local cjson     = require("cjson")

local GUIHelper = requireLayerGUI("GUIHelper")
local GUITXTEditorDefine = requireLayerGUI("GUITXTEditorDefine")

local sformat   = string.format
local sfind     = string.find
local sgsub     = string.gsub
local ssub      = string.sub
local strim     = string.trim
local slen      = string.len
local ssplit    = string.split
local sgmatch   = string.gmatch
local supper    = string.upper

local sreverse  = string.reverse

local tInsert   = table.insert
local tRemove   = table.remove
local tSort     = table.sort
local tMerge    = table.merge

local next      = next

local fileUtil     = global.FileUtilCtl
local resourcePath = fileUtil:getDefaultResourceRootPath()
local module       = global.L_ModuleManager:GetCurrentModule()
local mStabPath    = module:GetStabPath()

local fname        = "GUIExport"
local directory    = sformat("dev/%s", fname)
local exportFolder = sformat("%s%s%s", resourcePath, mStabPath, fname)
local cacheFolder  = sformat("%s%s%s", fileUtil:getWritablePath(), mStabPath, fname)
local gmFolder     = sformat("%s%s", resourcePath, directory)

local visibleSize  = global.Director:getVisibleSize()
local _LineColor   = cc.c4f( 1, 0, 0, 0.5 )
local _PathRes     = "res/private/gui_edit/"

local charMask     = { br = "\n", point = ".", t = "\t" }

local defaultViewW = 500
local defaultViewH = 200
local defaultSize  = {width = 60, height = 60}

local InputMode = {
    ANY = 0,
    INT = 1,
    FLOAT = 2,
    STRLINE = 3
}

local RealMode = {
    [InputMode.ANY] = 0,
    [InputMode.INT] = 2,
    [InputMode.FLOAT] = 6,
    [InputMode.STRLINE] = 6
}

local atts          = GUITXTEditorDefine.GUIAttributes
local GUIAttributes = {
    ITEM_SHOW       = atts.ITEM_SHOW,
    RICH_TEXT       = atts.RICH_TEXT,
    SWALLOW         = atts.SWALLOW,
    MESSAGE         = atts.MESSAGE,
    EFFECT          = atts.EFFECT,
    MODEL           = atts.MODEL,
    TEXT_METAVALUE  = atts.TEXT_METAVALUE,
    EQUIP_SHOW      = atts.EQUIP_SHOW,
    EQUIP_AUTO      = atts.EQUIP_AUTO
}

local GUIFuncKeys   = GUITXTEditorDefine.GUIFuncKeys

function GUIEditor:ctor()
    GUIEditor.super.ctor(self)

    -- 提醒消息
    self._systemTipsCells       = Queue.new()

    self._closeListener         = {}

    self._selWidgets            = {}
    self._selWidget             = nil
    self._selTreeNode           = nil
    self._copyWidget            = nil
    self._cutWidget             = nil

    -----------------------------------------------
    self._showNames             = {}

    -----------------------------------------------
    self._files                 = {}
    self._curFile               = nil
    self._curPrefix             = nil
    self._selFileInfo           = {}

    self._defaultPath           = nil           -- 存储路径

    -----------------------------------------------
    self._selDescription        = nil
    self._uiTree                = {}

    self._selUISpecialControl   = {}
    self._selUICommonControl    = {}

    self._GUINames              = {}
    
    self._caches                = {}

    -----------------------------------------------
    self._orderID               = 0

    self._barArrow              = {1, 1, 1, 1}
    -----------------------------------------------
    self._isPressedCtrl         = false         -- 是否按下 Ctrl  键
    self._isPressedSpace        = false         -- 是否按下 SPace 键
    self._KeyBoards = 
    {
        [cc.KeyCode.KEY_LEFT_ARROW] = {         -- Ctrl + ←   左移
            callback = function ()
                self:resetPostion(cc.p(-1, 0))
            end,
            schedule = true,
            scheduleID = nil
        },
        [cc.KeyCode.KEY_RIGHT_ARROW] = {        -- trl + →    右移
            callback = function ()   
                self:resetPostion(cc.p(1, 0))
            end,
            schedule = true,
            scheduleID = nil
        },
        [cc.KeyCode.KEY_UP_ARROW] = {           -- trl + ↑    上移
            callback = function ()
                self:resetPostion(cc.p(0, 1))
            end,
            schedule = true,
            scheduleID = nil
        },
        [cc.KeyCode.KEY_DOWN_ARROW] = {         -- trl + ↓    下移
            callback = function ()
                self:resetPostion(cc.p(0, -1))
            end,
            schedule = true,
            scheduleID = nil
        },
        [cc.KeyCode.KEY_LEFT_CTRL] = {          -- Ctrl 键
            callback = function ()
                self._isPressedCtrl = true
            end
        },
        [cc.KeyCode.KEY_SPACE] = {              -- Space 键
            callback = function ()
                self._isPressedSpace = true
            end
        },
        [cc.KeyCode.KEY_S] = {                  -- Ctrl + S   保存
            callback = function ()
                if self._isPressedCtrl then
                    self:onSaveFile()
                end
            end
        },
        [cc.KeyCode.KEY_C] = {                  -- Ctrl + C   复制
            callback = function ()
                if self._isPressedCtrl then
                    self:onCopyNode()
                end
            end
        },
        [cc.KeyCode.KEY_V] = {                  -- Ctrl + V   黏贴
            callback = function ()
                if self._isPressedCtrl then
                    self:onStickNode()
                    self:SaveCache()
                end
            end
        },
        [cc.KeyCode.KEY_X] = {                  -- Ctrl + X   剪切
            callback = function ()
                if self._isPressedCtrl then
                    self:onCutNode()
                end
            end
        },
        [cc.KeyCode.KEY_1] = {                  -- Ctrl + 1   上对齐
            callback = function ()
                if self._isPressedCtrl then
                    local num = #self._selWidgets
                    if num > 1 then
                        self:SetAlignStyle(1)
                        self:SaveCache()
                    end
                end
            end
        },
        [cc.KeyCode.KEY_2] = {                  -- Ctrl + 2   下对齐
            callback = function ()
                if self._isPressedCtrl then
                    local num = #self._selWidgets
                    if num > 1 then
                        self:SetAlignStyle(2)
                        self:SaveCache()
                    end
                end
            end
        },
        [cc.KeyCode.KEY_3] = {                  -- Ctrl + 3   左对齐
            callback = function ()
                if self._isPressedCtrl then
                    local num = #self._selWidgets
                    if num > 1 then
                        self:SetAlignStyle(3)
                        self:SaveCache()
                    end
                end
            end
        },
        [cc.KeyCode.KEY_4] = {                  -- Ctrl + 4   右对齐
            callback = function ()
                if self._isPressedCtrl then
                    local num = #self._selWidgets
                    if num > 1 then
                        self:SetAlignStyle(4)
                        self:SaveCache()
                    end
                end
            end
        },
        [cc.KeyCode.KEY_H] = {                  -- Ctrl + H   水平分布
            callback = function ()
                if self._isPressedCtrl then
                    local num = #self._selWidgets
                    if num > 2 then
                        self:SetAlignStyle(5)
                        self:SaveCache()
                    end
                end
            end
        },
        [cc.KeyCode.KEY_E] = {                  -- Ctrl + E   垂直分布
            callback = function ()
                if self._isPressedCtrl then
                    local num = #self._selWidgets
                    if num > 2 then
                        self:SetAlignStyle(6)
                        self:SaveCache()
                    end
                end
            end
        },
        [cc.KeyCode.KEY_F5] = {                 -- F5 刷新当前项目列表
            callback = function ()
                self:onRefFile()
            end
        },
        [cc.KeyCode.KEY_Z] = {                  -- Ctrl + Z  撤销
            callback = function ()
                if self._isPressedCtrl then
                    self:onCtrlZ()
                end
            end
        }
    }

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_BACKSPACE, function ()
        self:onKeyBackSpace()
        return true
    end, nil, 0)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_ESCAPE, function ()
        self:onKeyEsc()
        return true
    end, nil, 0)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_ENTER, function ()
        self:onKeyEnter()
        return true
    end, nil, 0)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_KP_ENTER, function ()
        self:onKeyEnter()
        return true
    end, nil, 0)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_DELETE, function ()
        self:onDeleteUI()
        self:SaveCache()
        return true
    end, nil, 0)

    self._CommonAttr = {
        ["TextField_Name"]    = { IMode = InputMode.STRLINE, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetName), SetUIWidget = handler(self, self.SetUIName) },
        ["TextField_NameTip"] = { IMode = InputMode.STRLINE, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetNameTip), SetUIWidget = handler(self, self.SetUINameTip) },
        ["TextField_AnrX"]    = { IMode = InputMode.FLOAT,   Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetAnrX), SetUIWidget = handler(self, self.SetUIAnrX) },
        ["TextField_AnrY"]    = { IMode = InputMode.FLOAT,   Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetAnrY), SetUIWidget = handler(self, self.SetUIAnrY) },
        ["TextField_PosX"]    = { IMode = InputMode.FLOAT,   Len = 10, t = 1, Completed = true, GetVal = handler(self, self.GetPosX), SetWidget = handler(self, self.SetPosX), SetUIWidget = handler(self, self.SetUIPosX) },
        ["TextField_PosY"]    = { IMode = InputMode.FLOAT,   Len = 10, t = 1, Completed = true, GetVal = handler(self, self.GetPosY), SetWidget = handler(self, self.SetPosY), SetUIWidget = handler(self, self.SetUIPosY) },
        ["TextField_Width"]   = { IMode = InputMode.FLOAT,   Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetWidth), SetUIWidget = handler(self, self.SetUIWidth) },
        ["TextField_Height"]  = { IMode = InputMode.FLOAT,   Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetHeight), SetUIWidget = handler(self, self.SetUIHeight) },
        ["TextField_Tag"]     = { IMode = InputMode.FLOAT,   Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetTag), SetUIWidget = handler(self, self.SetUITag) },
        ["TextField_Rotate"]  = { IMode = InputMode.FLOAT,   Len = 5,  t = 1, Completed = true, GetVal = handler(self, self.GetRotate), SetWidget = handler(self, self.SetRotate), SetUIWidget = handler(self, self.SetUIRotate) },
        ["TextField_ScaleX"]  = { IMode = InputMode.FLOAT,   Len = 5,  t = 1, Completed = true, SetWidget = handler(self, self.SetScaleX), SetUIWidget = handler(self, self.SetUIScaleX) },
        ["TextField_ScaleY"]  = { IMode = InputMode.FLOAT,   Len = 5,  t = 1, Completed = true, SetWidget = handler(self, self.SetScaleY), SetUIWidget = handler(self, self.SetUIScaleY) },
        ["TextField_Opacity"] = { IMode = InputMode.INT,     Len = 5,  t = 1, Completed = true, SetWidget = handler(self, self.SetOpacity), SetUIWidget = handler(self, self.SetUIOpacity) },


        ["CheckBox_Visible"]  = { t = 2, SetUIWidget = handler(self, self.SetUIVisible), func = handler(self, self.onIsVisibleEvent) },
        ["CheckBox_Touched"]  = { t = 2, SetUIWidget = handler(self, self.SetUITouched), func = handler(self, self.onIsTouchedEvent) },
        ["Slider_Opacity"]    = { t = 3, func = handler(self, self.onSliderOpacityEvent) },

        ["Image_Mask_opacity"]= {},

        ["Image_Mask_AnrX"]   = {},
        ["Image_Mask_AnrY"]   = {},

        ["Image_Mask_Width"]  = {},
        ["Image_Mask_Height"] = {},

        ["Image_Mask_Touch"]  = {},

        ["Image_Mask_Scale"]  = {},

        ["Image_Mask_Swallow"]= {},
        ["CheckBox_Swallow"]  = { t = 2, SetUIWidget = handler(self, self.SetUISwallow), func = handler(self, self.onItemSwallowEvent) },

        -- 
        ["TextField_Quick_Search"]  = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetQuickSearch) },

        ["Text_unit_x"]       = { t = 99, func = handler(self, self.onChangePosXInputMethod) },
        ["Text_unit_y"]       = { t = 99, func = handler(self, self.onChangePosYInputMethod) },
    }

    self._SpecialAttr = {
        ["TextField_H_align"]       = { IMode = InputMode.INT, Min = 0, Max = 2, Len = 1, t = 1, Completed = true, SetWidget = handler(self, self.SetTextHorizontal), SetUIWidget = handler(self, self.SetUITextHorizontal) },
        ["TextField_V_align"]       = { IMode = InputMode.INT, Min = 0, Max = 2, Len = 1, t = 1, Completed = true, SetWidget = handler(self, self.SetTextVertical), SetUIWidget = handler(self, self.SetUITextVertical) },

        ["TextField_C"]             = { IMode = InputMode.STRLINE, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetColorC), SetUIWidget = handler(self, self.SetUIColorC) },
        ["Button_Color"]            = { t = 2, func = handler(self, self.onOpenClolorSelector), callfunc = handler(self, self.onColorSetCallFunc) },
        ["Panel_Preview"]           = {},

        ["TextField_Outline_C"]     = { IMode = InputMode.STRLINE, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetColorOutlineC), SetUIWidget = handler(self, self.SetUIColorOutlineC) },
        ["Button_Outline_Color"]    = { t = 2, func = handler(self, self.onOpenClolorSelector), callfunc = handler(self, self.onColorOutlineSetCallFunc) }, 
        ["Panel_Outline_Preview"]   = {},
        
        ["TextField_Text"]          = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetText), SetUIWidget = handler(self, self.SetUIText) },
        ["TextField_More_Text"]     = { IMode = InputMode.ANY, t = 1, Completed = true, SetWidget = handler(self, self.SetMoreText), SetUIWidget = handler(self, self.SetUIMoreText) },
        ["TextField_FontSize"]      = { IMode = InputMode.INT, Len = 2, t = 1, Completed = true, SetWidget = handler(self, self.SetFontSize), SetUIWidget = handler(self, self.SetUIFontSize) },
        
        ["TextField_Outline_Width"] = { IMode = InputMode.INT, Len = 4, Min = 1, Completed = true, t = 1, SetWidget = handler(self, self.SetOutlineWidth), SetUIWidget = handler(self, self.SetUIOutlineWidth) },

        ["TextField_N_Res"]         = { IMode = InputMode.STRLINE, Completed = true, t = 1, NotNowRef = true, SetWidget = handler(self, self.SetNorRes), SetUIWidget = handler(self, self.SetUINorRes) },
        ["TextField_P_Res"]         = { IMode = InputMode.STRLINE, Completed = true, t = 1, NotNowRef = true, SetWidget = handler(self, self.SetPreRes), SetUIWidget = handler(self, self.SetUIPreRes) },
        ["TextField_D_Res"]         = { IMode = InputMode.STRLINE, Completed = true, t = 1, NotNowRef = true, SetWidget = handler(self, self.SetDisRes), SetUIWidget = handler(self, self.SetUIDisRes) },
    
        ["Button_N_Res"]            = { t = 2, func = handler(self, self.onOpenGUIResSelector), callfunc = handler(self, self.onResNSetCallFunc) },
        ["Button_P_Res"]            = { t = 2, func = handler(self, self.onOpenGUIResSelector), callfunc = handler(self, self.onResPSetCallFunc) },
        ["Button_D_Res"]            = { t = 2, func = handler(self, self.onOpenGUIResSelector), callfunc = handler(self, self.onResDSetCallFunc) },

        ["TextField_CapInset_L"]    = { IMode = InputMode.INT, Len = 3, t = 1, Completed = true, SetWidget = handler(self, self.SetCapInsetL), SetUIWidget = handler(self, self.SetUICapInsetL) },
        ["TextField_CapInset_R"]    = { IMode = InputMode.INT, Len = 3, t = 1, Completed = true, SetWidget = handler(self, self.SetCapInsetR), SetUIWidget = handler(self, self.SetUICapInsetR) },
        ["TextField_CapInset_T"]    = { IMode = InputMode.INT, Len = 3, t = 1, Completed = true, SetWidget = handler(self, self.SetCapInsetT), SetUIWidget = handler(self, self.SetUICapInsetT) },
        ["TextField_CapInset_B"]    = { IMode = InputMode.INT, Len = 3, t = 1, Completed = true, SetWidget = handler(self, self.SetCapInsetB), SetUIWidget = handler(self, self.SetUICapInsetB) },

        ["TextField_Alignment"]     = { IMode = InputMode.INT, Len = 1, t = 1, Completed = true, SetWidget = handler(self, self.SetAlignment), SetUIWidget = handler(self, self.SetUIAlignment) },
        ["TextField_Margin"]        = { IMode = InputMode.INT, Len = 3, t = 1, Completed = true, SetWidget = handler(self, self.SetMargin), SetUIWidget = handler(self, self.SetUIMargin) },

        ["TextField_Scl_Width"]     = { IMode = InputMode.FLOAT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetInnerWidth), SetUIWidget = handler(self, self.SetUIInnerWidth) },
        ["TextField_Scl_Height"]    = { IMode = InputMode.FLOAT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetInnerHeight), SetUIWidget = handler(self, self.SetUIInnerHeight) },
        ["TextField_Bg_Opacity"]    = { IMode = InputMode.INT, Len = 5, Max = 100, t = 1, Completed = true, SetWidget = handler(self, self.SetBgTextOpacity), SetUIWidget = handler(self, self.SetUITextBgOpacity) },

        ["TextField_FirstChat"]     = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetFristChat), SetUIWidget = handler(self, self.SetUIFristChat) },
        ["TextField_Chat_Width"]    = { IMode = InputMode.INT, Len = 4, t = 1, Completed = true, SetWidget = handler(self, self.SetChatWidth), SetUIWidget = handler(self, self.SetUIChatWidth) },
        ["TextField_Chat_Height"]   = { IMode = InputMode.INT, Len = 4, t = 1, Completed = true, SetWidget = handler(self, self.SetChatHeight), SetUIWidget = handler(self, self.SetUIChatHeight) },

        ["TextField_Space"]         = { IMode = InputMode.INT, Len = 2, t = 1, Completed = true, SetWidget = handler(self, self.SetRTextSpace), SetUIWidget = handler(self, self.SetUIRTextSpace) },
        
        ["TextField_ItemID"]        = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetItemID), SetUIWidget = handler(self, self.SetUIItemID) },
        ["TextField_Item_Num"]      = { IMode = InputMode.INT, Len = 15, t = 1, Completed = true, SetWidget = handler(self, self.SetItemNum), SetUIWidget = handler(self, self.SetUIItemNum) },
        ["TextField_Item_From"]     = { IMode = InputMode.INT, Len = 2, t = 1, Completed = true, SetWidget = handler(self, self.SetItemFrom), SetUIWidget = handler(self, self.SetUIItemFrom) },
        ["TextField_Item_FontSize"] = { IMode = InputMode.INT, Len = 2, t = 1, Completed = true, SetWidget = handler(self, self.SetItemFontSize), SetUIWidget = handler(self, self.SetUIItemFontSize) },
        ["TextField_Item_FontColor"]= { IMode = InputMode.STRLINE, Len = 10,  t = 1, Completed = true, SetWidget = handler(self, self.SetItemFontColor), SetUIWidget = handler(self, self.SetUIItemFontColor) },

        ["Image_Mask_l"] = {},
        ["Image_Mask_r"] = {},
        ["Image_Mask_t"] = {},
        ["Image_Mask_b"] = {},

        ["Image_Mask_Opacity"]  = {},
        ["Image_Mask_Color"]    = {},

        ["Image_Mask_Outline_Color"] = {},
        ["Image_Mask_Outline_Width"] = {},

        ["CheckBox_CustomSize"]  = { t = 2, SetUIWidget = handler(self, self.SetUITextCustomSize), func = handler(self, self.onTextCustomSizeEvent) },

        ["CheckBox_Outline"]     = { t = 2, SetUIWidget = handler(self, self.SetUITextOutline), func = handler(self, self.onTextOutlineEvent) },
        
        ["CheckBox_CapInset"]    = { t = 2, SetUIWidget = handler(self, self.SetUICapInset), func = handler(self, self.onCapInsetEvent) },
        ["CheckBox_Rebound"]     = { t = 2, SetUIWidget = handler(self, self.SetUIRebound), func = handler(self, self.onReboundEvent) },
        ["CheckBox_Cbox_Select"] = { t = 2, SetUIWidget = handler(self, self.SetUICboxSelect), func = handler(self, self.onUICheckBoxSelectEvent) },

        ["CheckBox_LBar_left"]   = { t = 2, SetUIWidget = handler(self, self.SetUILBarLeft), func = handler(self, self.onLBarCheckBoxEvent) },
        ["CheckBox_Dir"]         = { t = 2, SetUIWidget = handler(self, self.SetUIDirection), func = handler(self, self.onDirCheckBoxEvent) },

        ["CheckBox_Clip"]        = { t = 2, SetUIWidget = handler(self, self.SetUIClip), func = handler(self, self.onClipEvent) },
        ["CheckBox_bgtc"]        = { t = 2, SetUIWidget = handler(self, self.SetUIBgtc), func = handler(self, self.onBgtcEvent) },

        ["CheckBox_Play"]        = { t = 2, SetUIWidget = handler(self, self.SetUIEffectPlay), func = handler(self, self.onEffectPlayEvent) },

        ["CheckBox_Item_Look"]            = { t = 2, SetUIWidget = handler(self, self.SetUIItemLook), func = handler(self, self.onItemLookEvent) },
        ["CheckBox_Item_ShowBg"]          = { t = 2, SetUIWidget = handler(self, self.SetUIItemShowBg), func = handler(self, self.onItemShowBgEvent) },
        ["CheckBox_Item_ShowNum"]         = { t = 2, SetUIWidget = handler(self, self.SetUIItemShowNum), func = handler(self, self.onItemShowNumEvent) },
        ["CheckBox_Item_ShowStar"]        = { t = 2, SetUIWidget = handler(self, self.SetUIItemShowStar), func = handler(self, self.onItemShowStarEvent) },
        ["CheckBox_Item_ShowMask"]        = { t = 2, SetUIWidget = handler(self, self.SetUIItemShowMask), func = handler(self, self.onItemShowMaskEvent) },
        ["CheckBox_Item_ShowPowerC"]      = { t = 2, SetUIWidget = handler(self, self.SetUIItemShowPowerC), func = handler(self, self.onItemShowPowerCEvent) },
        ["CheckBox_Item_ShowEffect"]      = { t = 2, SetUIWidget = handler(self, self.SetUIItemShowEffect), func = handler(self, self.onItemShowEffectEvent) },
        ["CheckBox_Item_ShowModelEffect"] = { t = 2, SetUIWidget = handler(self, self.SetUIItemShowModelEffect), func = handler(self, self.onItemShowModelEffectEvent) },
        
        ["Slider_Bg_Opacity"]    = { t = 3, SetUIWidget = handler(self, self.SetUISliderBgOpacity), func = handler(self, self.onSliderBgOpacityEvent) },

        -- Meaasge
        ["TextField_Msg_Text"]   = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgText), SetUIWidget = handler(self, self.SetUIMsgText) },
        ["TextField_MsgID"]      = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgID), SetUIWidget = handler(self, self.SetUIMsgID) },
        ["TextField_Msg_P1"]     = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgParam1), SetUIWidget = handler(self, self.SetUIMsgParam1) },
        ["TextField_Msg_P2"]     = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgParam2), SetUIWidget = handler(self, self.SetUIMsgParam2) },
        ["TextField_Msg_P3"]     = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgParam3), SetUIWidget = handler(self, self.SetUIMsgParam3) },
        
        ["CheckBox_Msg"]         = { t = 2, SetUIWidget = handler(self, self.SetUILuaMsg), func = handler(self, self.onLuaMsgEvent) },

        -- Click
        ["TextField_Click"]      = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetClickFunc), SetUIWidget = handler(self, self.SetUIClickFunc) },
        ["CheckBox_Click"]       = { t = 2, SetUIWidget = handler(self, self.SetUIClick), func = handler(self, self.onClickEvent) },

        ["TextField_Progress"]   = { IMode = InputMode.INT, Len = 3, Max = 100, t = 1, Completed = true, SetWidget = handler(self, self.SetSliderText), SetUIWidget = handler(self, self.SetUISliderText) },
        ["Slider_Progress"]      = { t = 3, SetUIWidget = handler(self, self.SetUISliderProgress), func = handler(self, self.onLBarSliderEvent) },
        
        -- Input
        ["TextField_P_Text"]        = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetInputPlaceholder), SetUIWidget = handler(self, self.SetUIInputPlaceholder) },
        ["TextField_Lenth"]         = { IMode = InputMode.INT, Len = 4, t = 1, Completed = true, SetWidget = handler(self, self.SetInputMaxLenth), SetUIWidget = handler(self, self.SetUIInputMaxLenth) },
        ["TextField_IType"]         = { IMode = InputMode.INT, Len = 1, t = 1, Min = 0, Max = 3, Completed = true, SetWidget = handler(self, self.SetInputType), SetUIWidget = handler(self, self.SetUIInputType) },
        ["CheckBox_Cipher"]         = { t = 2, SetUIWidget = handler(self, self.SetUICipher), func = handler(self, self.onCipherEvent) },

        ["TextField_C2"]            = { IMode = InputMode.STRLINE, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetColorInputPlaceHolder), SetUIWidget = handler(self, self.SetUIColorInputPlaceHolder) },
        ["Button_Color2"]           = { t = 2, func = handler(self, self.onOpenClolorSelector), callfunc = handler(self, self.onColorInputPlaceHolderColorSetCallFunc) },
        ["Panel_Preview2"]          = {},

        -- sex
        ["TextField_Sex"]           = { IMode = InputMode.INT, Len = 1, t = 1, Completed = true, SetWidget = handler(self, self.SetSex), SetUIWidget = handler(self, self.SetUISex) },

        -- Effect
        ["TextField_EffectID"]      = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectID), SetUIWidget = handler(self, self.SetUIEffectID) },
        ["TextField_EffectType"]    = { IMode = InputMode.INT, Len = 1, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectType), SetUIWidget = handler(self, self.SetUIEffectType) },
        ["TextField_Action"]        = { IMode = InputMode.INT, Len = 2, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectAction), SetUIWidget = handler(self, self.SetUIEffectAction) },
        ["TextField_Dir"]           = { IMode = InputMode.INT, Len = 2, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectDir), SetUIWidget = handler(self, self.SetUIEffectDir) },
        ["TextField_Speed"]         = { IMode = InputMode.INT, Len = 3, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectSpeed), SetUIWidget = handler(self, self.SetUIEffectSpeed) },

        -- Model
        ["TextField_MScale"]        = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetMScale), SetUIWidget = handler(self, self.SetUIMScale) },
        ["TextField_HairID"]        = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetHairID), SetUIWidget = handler(self, self.SetUIHairID) },
        ["TextField_HeadID"]        = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetHeadID), SetUIWidget = handler(self, self.SetUIHeadID) },
        ["TextField_HeadEffID"]     = { IMode = InputMode.STRLINE, Len = 100, t = 1, Completed = true, SetWidget = handler(self, self.SetHeadEffID), SetUIWidget = handler(self, self.SetUIHeadEffID) },
        ["TextField_ClothID"]       = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetClothID), SetUIWidget = handler(self, self.SetUIClothID) },
        ["TextField_ClothEffID"]    = { IMode = InputMode.STRLINE, Len = 100, t = 1, Completed = true, SetWidget = handler(self, self.SetClothEffID), SetUIWidget = handler(self, self.SetUIClothEffID) },
        ["TextField_WeaponID"]      = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetWeaponID), SetUIWidget = handler(self, self.SetUIWeaponID) },
        ["TextField_WeaponEffID"]   = { IMode = InputMode.STRLINE, Len = 100, t = 1, Completed = true, SetWidget = handler(self, self.SetWeaponEffID), SetUIWidget = handler(self, self.SetUIWeaponEffID) },
        ["TextField_ShieldID"]      = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetShieldID), SetUIWidget = handler(self, self.SetUIShieldID) },
        ["TextField_ShieldEffID"]   = { IMode = InputMode.STRLINE, Len = 100, t = 1, Completed = true, SetWidget = handler(self, self.SetShieldEffID), SetUIWidget = handler(self, self.SetUIShieldEffID) },
        ["TextField_CapID"]         = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetCapID), SetUIWidget = handler(self, self.SetUICapID) },
        ["TextField_CapEffID"]      = { IMode = InputMode.STRLINE, Len = 100, t = 1, Completed = true, SetWidget = handler(self, self.SetCapEffID), SetUIWidget = handler(self, self.SetUICapEffID) },
        ["TextField_VeilID"]        = { IMode = InputMode.INT, Len = 10, t = 1, Completed = true, SetWidget = handler(self, self.SetVeilID), SetUIWidget = handler(self, self.SetUIVeilID) },
        ["TextField_VeilEffID"]     = { IMode = InputMode.STRLINE, Len = 100, t = 1, Completed = true, SetWidget = handler(self, self.SetVeilEffID), SetUIWidget = handler(self, self.SetUIVeilEffID) },
        ["CheckBox_ShowMold"]       = { t = 2, SetUIWidget = handler(self, self.SetUIShowMold), func = handler(self, self.onShowMoldEvent) },
        ["CheckBox_ShowHair"]       = { t = 2, SetUIWidget = handler(self, self.SetUIShowHair), func = handler(self, self.onShowHairEvent) },

        -- EquipShow
        ["TextField_EquipPos"]              = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetEquipPos), SetUIWidget = handler(self, self.SetUIEquipPos) },
        ["CheckBox_Equip_Look"]             = { t = 2, SetUIWidget = handler(self, self.SetUIEquipLook), func = handler(self, self.onEquipLookEvent) },
        ["CheckBox_Equip_ShowBg"]           = { t = 2, SetUIWidget = handler(self, self.SetUIEquipShowBg), func = handler(self, self.onEquipShowBgEvent) },
        ["CheckBox_Equip_ShowStar"]         = { t = 2, SetUIWidget = handler(self, self.SetUIEquipShowStar), func = handler(self, self.onEquipShowStarEvent) },
        ["CheckBox_Equip_autoUpdate"]       = { t = 2, SetUIWidget = handler(self, self.SetUIEquipAutoUpdate), func = handler(self, self.onEquipAutoUpdateEvent)},
        ["CheckBox_Equip_isHero"]           = { t = 2, SetUIWidget = handler(self, self.SetUIEquipIsHero), func = handler(self, self.onEquipIsHeroEvent)},
        ["CheckBox_Equip_onDouble"]         = { t = 2, SetUIWidget = handler(self, self.SetUIEquipOnDouble), func = handler(self, self.onEquipAddDoubleEvent)},
        ["CheckBox_Equip_onMove"]           = { t = 2, SetUIWidget = handler(self, self.SetUIEquipOnMove), func = handler(self, self.onEquipAddMoveEvent)},
        ["CheckBox_Equip_lookPlayer"]       = { t = 2, SetUIWidget = handler(self, self.SetUIEquipIsLookPlayer), func = handler(self, self.onEquipIsLookPlayerEvent)}
    }
end

function GUIEditor.create()
    local layer = GUIEditor.new()
    if layer:init() then
        return layer
    end
    return nil
end

function GUIEditor:init()
    local root = CreateExport("gui_editor/main_editor.lua")
    if not root then
        return false
    end
    self:addChild(root)

    local cells = CreateExport("gui_editor/main_cells.lua")
    root:getChildByName("Panel_sys"):addChild(cells)

    self._quickUI = ui_delegate(root:getChildByName("Panel_sys"))

    self._Text_Cur_Dir = root:getChildByName("Text_Cur_Dir")
    self._Node_UI = root:getChildByName("Node_ui")
    self._Node_Preview = self._quickUI.Panel_UIPreview:getChildByName("Node_Preview")
    
    local Panel_background = root:getChildByName("Panel_background")
    Panel_background:setContentSize(cc.size(visibleSize.width, visibleSize.height))
    Panel_background:addClickEventListener(function ()
        self:onCancelSelectNode()
        self:resetAllSelectWidget()
    end)

    self._line = cc.DrawNode:create()
    self._line:drawLine(cc.p(0, 0), cc.p(200, 0), cc.Color4F.RED)
    self._quickUI.Panel_tree:addChild(self._line, -1)
    self._line:setVisible(false)

    self._cfgs = SL:Require("game_config/cfg_gui_editor", true)

    self._quickCfgs, self._quickCfgDesc, self._quickCfgEx = self:InitQuickData()

    -- 隐藏帧率
    global.Director:setDisplayStats(false)

    self:cleanup()

    -- 文件页
    self._quickUI.Button_file:addClickEventListener(handler(self, self.onFile))
    -- 关闭GUIEditor
    self._quickUI.Button_close:addClickEventListener(handler(self, self.onCloseUI))

    -- 属性页切换
    self._quickUI.Button_change:addClickEventListener(handler(self, self.onChange))
    self._quickUI.Button_change:setTag(1)

    --节点页切换
    self._quickUI.Button_tree:addClickEventListener(handler(self, self.onNodeTreeChange))
    self._quickUI.Button_tree:setTag(0)

    -- 创建项目
    self._quickUI.Button_createfile:addClickEventListener(handler(self, self.onCreateFile))

    -- 打开项目
    self._quickUI.Button_openfile:addClickEventListener(handler(self, self.onOpenFile))

    -- 一键保存
    self._quickUI.Button_saveAll:addClickEventListener(handler(self, self.onSaveAll))

    -- 快捷UI管理
    self._quickUI.Button_fileManage:addClickEventListener(handler(self, self.onQuickOprateFiles))

    -- 确定创建
    self._quickUI.Button_ok:addClickEventListener(handler(self, self.onCreateOk))

    -- 取消创建
    self._quickUI.Button_cancel:addClickEventListener(handler(self, self.onCreateCancel))

    -- 删除控件
    self._quickUI.Button_Delete:addClickEventListener(handler(self, self.onDeleteUI))

    -- 保存到本地
    self._quickUI.Button_Save:addClickEventListener(handler(self, self.onSaveFile))

    -- 中英文切换
    self._quickUI.Button_Language:addClickEventListener(handler(self, self.onLanguage))

    -- 确认弹窗事件
    self._quickUI.Panel_pop:addClickEventListener(handler(self, self.onClosePop))
    self._quickUI.btn_pop_save:addClickEventListener(handler(self, self.onPopSave))
    self._quickUI.btn_pop_cancel:addClickEventListener(handler(self, self.onClosePop))

    -- tree node item click
    self._quickUI.tree_cell:addTouchEventListener(handler(self, self.onTreeCellEvent))
    self._quickUI.tree_cell:setSwallowTouches(false)

    self._quickUI.tree_cell:getChildByName("Button_arr"):addClickEventListener(handler(self, self.onTreeArrow))

    self._quickUI.ScrollView_1:addClickEventListener(handler(self, self.onCancelSelectNode))

    self._quickUI.Panel_files:addClickEventListener(handler(self, self.hideFiles))

    self._quickUI.TextField_Create_File_Name:setTextHorizontalAlignment(1)
    self._quickUI.TextField_Create_File_Name:setCursorEnabled(true)

    self._quickUI.ScrollView_attr:setVisible(false)
    self._quickUI.Top_attr:setVisible(false)

    self:initAdapet()
    self:initButton()
    
    self:initAttrControl()

    self._listenerKeyBoard = cc.EventListenerKeyboard:create()
    self._listenerKeyBoard:registerScriptHandler(handler(self, self.KeyBoardPressedFunc), cc.Handler.EVENT_KEYBOARD_PRESSED)
    self._listenerKeyBoard:registerScriptHandler(handler(self, self.KeyBoardReleasedFunc), cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self._listenerKeyBoard, 1)

    -- 调整位置层
    local wid = 100000
    local layout = ccui.Layout:create()
    layout:setPosition(cc.p(-wid/2, -wid/2))
    layout:setAnchorPoint(cc.p(0, 0))
    layout:setContentSize(cc.size(wid, wid))
    layout:setClippingEnabled(false)
    layout:setClippingType(0)
    layout:setName("___MAIN_TOUCH_LAYER___")
    self._Node_UI:addChild(layout)
    layout:setVisible(false)
    layout:setLocalZOrder(999)
    self._mouseLayer = layout

    layout:setBackGroundColorType(1)
    layout:setBackGroundColorOpacity(50)
    layout:setBackGroundColor(cc.c3b(0, 0, 0xff))                

    local cLine = ccui.ImageView:create(sformat("%s%s", _PathRes, "direct.png"))
    cLine:setName("___MAIN_COORDINATE_LINE___")
    self._Node_UI:addChild(cLine, 99999)
    cLine:setAnchorPoint(cc.p(0, 0))
    cLine:setPosition(cc.p(-11, -9))

    local lCanvas = ccui.Layout:create()
    lCanvas:setName("___MAIN_CANVAS_LAYOUT___")
    lCanvas:setContentSize(cc.size(1136, 640))
    lCanvas:setBackGroundColorType(1)
    -- lCanvas:setBackGroundColorOpacity(100)
    lCanvas:setBackGroundColor(cc.c3b(100, 100, 100))
    self._Node_UI:addChild(lCanvas, -99999)

    self._Node_UI:setPosition(cc.p(232, 64))

    self._listenerMouse   = cc.EventListenerMouse:create()
    self._listenerMouse:registerScriptHandler(handler(self, self.OnMouseMoved), cc.Handler.EVENT_MOUSE_MOVE)
    self._listenerMouse:registerScriptHandler(handler(self, self.OnMouseUp), cc.Handler.EVENT_MOUSE_UP)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self._listenerMouse, layout)

    self:addCloseEventListener(function() 
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self._listenerKeyBoard)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self._listenerMouse)
    end)

    self._quickUI.Panel_save_path_bg:addClickEventListener(handler(self, self.onSelectSavePath))
    self._quickUI.bg_stab:addClickEventListener(handler(self, self.onSureSavePath))
    self._quickUI.bg_dev:addClickEventListener(handler(self, self.onSureSavePath))
    self._quickUI.Panel_list_touch:addTouchEventListener(function ()
        self._quickUI.Panel_path_list_bg:setVisible(false)
    end)
    self._quickUI.Panel_list_touch:setSwallowTouches(false)

    local Text_stab = self._quickUI.bg_stab:getChildByName("Text_stab")
    Text_stab:setString(exportFolder)

    local Text_dev  = self._quickUI.bg_dev:getChildByName("Text_dev")
    Text_dev:setString(gmFolder)

    self._quickUI.Panel_quick:setVisible(false)

    self:initDefaultPath()

    GUI:UserUILayout(self._quickUI.ScrollView_Button, { dir = 3, x = 8, y = 10, l = 4, t = 4, colnum = 5, sortfunc = function (list)
        tSort(list, function ( a, b ) return a:getTag() < b:getTag() end)
    end })

    self._language = self:GetSaveLoacalValue("lang") or 0
    self:setButtonLanguageText(self._language)

    self._files = self:getAllFiles()
    self:updateAllFiles()

    -- 添加节点树滚轮
    self:addScrollInTree()

    -- 初始化快捷键事件
    self:InitAlignStyleEvent()

    return true
end

function GUIEditor:setButtonLanguageText(lang)
    self._quickUI.Button_Language:setTitleText(({[0] = "英文", [1] = "中文"})[lang])
end

function GUIEditor:SetSaveLocalValue(key, value)
    local userData = UserData:new("GUI_Editor_Cfg")
    userData:setStringForKey(key, cjson.encode(value))
    userData:writeMapDataToFile()
end

function GUIEditor:GetSaveLoacalValue(key)
    local userData = UserData:new("GUI_Editor_Cfg")
    local jsonStr  = userData:getStringForKey(key, "")
    if jsonStr and slen(jsonStr) > 0 then
        return cjson.decode(jsonStr)
    end
end

function GUIEditor:initDefaultPath()
    if global.isGMMode then
        self._defaultPath = gmFolder
    else
        local key = self:GetSaveLoacalValue("path")
        self._defaultPath = key == 2 and gmFolder or exportFolder 
    end
    self._quickUI.Text_save_path:setString(self._defaultPath)
end

function GUIEditor:onSaveAll()
    self._quickUI.Panel_pop:setVisible(true)
    GUI:Timeline_Window1(self._quickUI.Panel_pop_image)
end

function GUIEditor:onClosePop()
    self._quickUI.Panel_pop:setVisible(false)
end

function GUIEditor:onPopSave()
    self:onClosePop()

    local files = self:getAllFiles()
    local luaFiles = {}
        
    for fullfile, flag in pairs(files) do
        local isDir = not sfind(fullfile, ".lua")
        if isDir then
            self:checkExportFolder(fullfile)
        else
            tInsert(luaFiles, {fullfile = fullfile, flag = flag})
        end
    end

    local i = 0
    schedule(self, function ()
        i = i + 1
        local d = luaFiles[i]
        if not d then
            self:stopAllActions()
            global.Facade:sendNotification(global.NoticeTable.Layer_GUIEditor_Close)
            return false
        end
        local fullfile = d.fullfile
        self:open(self:findFileRoot(d.flag), fullfile)
        self:onSaveFile()
    end, 1/60)
end

function GUIEditor:IsDirectory(file)
    return fileUtil:isDirectoryExist(file)
end

-- 向上查找文件夹内容
function GUIEditor:onKeyBackSpace()
    if not self._selDirctor then
        return false
    end

    local isfind = sfind(self._selDirctor, "/")
    if not isfind then
        return false
    end

    local isfind = sfind(self._selDirctor, "/(.+)/")
    if isfind then
        local ts = clone(self._selDirctor)
        ts = sreverse(ts)
        ts = sgsub(ts, "/(.+)/","/")
        ts = sreverse(ts)
        self._selDirctor = ts
    else
        self._selDirctor = nil
    end

    self._files = self:getAllFiles()
    self:updateAllFiles()
end

function GUIEditor:onKeyEnter()
    if not (self._selFileInfo and next(self._selFileInfo)) then
        self._Text_Cur_Dir:setString("")
        return false
    end
    if self._selFileInfo.isDir then
        self._selDirctor = self._selFileInfo.fullfile
        self._files = self:getAllFiles()
        self:updateAllFiles()
    elseif self._selFileInfo.root and self._selFileInfo.fullfile and self._selFileInfo.file then
        self:open(self._selFileInfo.root, self._selFileInfo.fullfile, self._selFileInfo.file)
    end
end

function GUIEditor:getFileName(str)
    local rerStr = sreverse(str)
    local _, i   = sfind(rerStr, "/")
    local len    = slen(str)
    local st     = len - i + 2
    return ssub(str, st, len)
end
    
function GUIEditor:getAllFiles()
    local items       = {}      -- export file
    local gmItems     = {}      -- dev    file
    local cacheItems  = {}      -- cache  file

    local function _GetFiles(folder, name, flag)
        local listfiles = fileUtil:listFiles(folder)
        -- 跳过 2 条
        tRemove(listfiles, 1)
        tRemove(listfiles, 1)

        for i = 1, #listfiles do
            local file = listfiles[i]
            -- 去掉末尾可能出现的 /
            file = sgsub(file, "[/]+$", "")

            local fileName = self:getFileName(file)
            local newStr = name and sformat("%s%s", name, fileName) or fileName

            if self:IsDirectory(file) then -- 是否是文件夹

                newStr = sformat("%s/", newStr)

                if flag == "GM" then
                    gmItems[newStr] = flag
                elseif flag == "CACHE" then
                    cacheItems[newStr] = flag
                else
                    items[newStr] = flag
                end
                _GetFiles(file, newStr, flag)
            elseif sfind(newStr,".lua") then
                if flag == "GM" then
                    gmItems[newStr] = flag
                elseif flag == "CACHE" then
                    cacheItems[newStr] = flag
                else
                    items[newStr] = flag
                end
            end
        end
    end


    _GetFiles(gmFolder, nil, "GM")
    _GetFiles(cacheFolder, nil, "CACHE")
    _GetFiles(exportFolder, nil, "EXPORT")

    -- 合并文件
    tMerge(items, cacheItems)
    tMerge(items, gmItems)
    
    return items
end

function GUIEditor:InitAlignStyleEvent()
    local limits  = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [4] = 1,
        [5] = 2,
        [6] = 2
    }

    local onClick = function (sender, eventType)
        if eventType ~= 2 then
            return false
        end
        
        local tag = sender:getTag()
        local num = #self._selWidgets

        if num > limits[tag] then
            self:SetAlignStyle(tag)
        end
    end
    
    self._quickUI["Button_Key_1"]:addTouchEventListener(onClick)
    self._quickUI["Button_Key_2"]:addTouchEventListener(onClick)
    self._quickUI["Button_Key_3"]:addTouchEventListener(onClick)
    self._quickUI["Button_Key_4"]:addTouchEventListener(onClick)
    self._quickUI["Button_Key_H"]:addTouchEventListener(onClick)
    self._quickUI["Button_Key_V"]:addTouchEventListener(onClick)
    self._quickUI["Button_Key_1"]:setTag(1)
    self._quickUI["Button_Key_2"]:setTag(2)
    self._quickUI["Button_Key_3"]:setTag(3)
    self._quickUI["Button_Key_4"]:setTag(4)
    self._quickUI["Button_Key_H"]:setTag(5)
    self._quickUI["Button_Key_V"]:setTag(6)
end

function GUIEditor:initAttrControl()
    self._selUICommonControl = {}

    for name,d in pairs(self._CommonAttr) do
        if name then
            local widget = self._quickUI[name]
            if widget then
                if d.t == 1 then
                    local editBox = CreateEditBoxByTextField(widget)
                    self._selUICommonControl[name] = editBox
                    self:initTextFieldEvent(self._selUICommonControl[name])
                    self._selUICommonControl[name]:setInputMode(RealMode[d.IMode])
                    if d.Len then
                        self._selUICommonControl[name]:setMaxLength(d.Len)
                    end
                elseif d.t == 2 then
                    self._selUICommonControl[name] = widget
                    self._selUICommonControl[name]:addClickEventListener(d.func)
                elseif d.t == 3 then
                    self._selUICommonControl[name] = widget
                    self._selUICommonControl[name]:addEventListener(d.func)
                elseif d.t == 99 then
                    self._selUICommonControl[name] = widget
                    self._selUICommonControl[name]:addTouchEventListener(d.func)
                else
                    self._selUICommonControl[name] = widget
                end
            end
        end
    end

    self._InputValues = {}

    self._quickUI["Bar1"]:addClickEventListener(handler(self, self.onAttrBar))
    self._quickUI["Bar2"]:addClickEventListener(handler(self, self.onAttrBar))
    self._quickUI["Bar3"]:addClickEventListener(handler(self, self.onAttrBar))
    self._quickUI["Bar4"]:addClickEventListener(handler(self, self.onAttrBar))
    self._quickUI["Bar1"]:setTag(1)
    self._quickUI["Bar2"]:setTag(2)
    self._quickUI["Bar3"]:setTag(3)
    self._quickUI["Bar4"]:setTag(4)
end

function GUIEditor:initTextFieldEvent(widget)
    local CheckIntValue = function (value, min, max)
        if min and value < min then
            value = min
        end
        if max then
            value = math.max(math.min(value, max), 0)
        end
        return value
    end

    widget:addEventListener(function(sender, eventType)
        local name = sender:getName()
        local data = self._CommonAttr[name] or self._SpecialAttr[name]
        if not data then
            return false
        end
        local mode      = data.IMode
        local max       = data.Max
        local min       = data.Min
        local Completed = not data.Completed    -- 输入不校验
        local GetVal    = data.GetVal

        local isRef = false
        local str   = sender:getString()

        if eventType == 1 then
            str = strim(str)
            if mode == InputMode.INT then
                str = tonumber(str) or 0
                if name == "TextField_Alignment" then
                    local dirs = {[1] = {[0] = 0, [1] = 1, [2] = 2, ["default"] = 0}, [2] = {[3] = 3, [4] = 4, [5] = 5, ["default"] = 3}}
                    local dir  = self._selWidget:getDirection()
                    if dirs[dir] then
                        str = dirs[dir][str] or dirs[dir]["default"]
                    end
                else
                    str = CheckIntValue(str, min, max)
                end
                sender:setString(str)

                self:updateCommonAttr(name, str)
                self:updateSpecialAttr(name, str)
            elseif mode == InputMode.FLOAT then
                local len = slen(str)
                if len < 1 then
                    str = 0
                end
                
                if not tonumber(str) then
                    sender:setString(self._InputValues[name] or (GetVal and GetVal() or ""))
                    return false
                end

                str = slen(str) > 0 and str or 0

                str = CheckIntValue(sformat("%.2f", str), min, max)

                self._InputValues[name] = str
                sender:setString(str)

                self:updateCommonAttr(name, str)
                self:updateSpecialAttr(name, str)
            else
                if slen(str or "") < 0 then
                    sender:setString(self._InputValues[name] or "")
                    return false
                end

                if name == "TextField_Name" then
                    local isChange, ID = self:checkIDValid(str)
                    if not isChange then
                        if ID then
                            sender:setString(ID)
                        end
                        return false
                    end
                    str = ID
                end
                self._InputValues[name] = str
                sender:setString(str)

                self:updateCommonAttr(name, str)
                self:updateSpecialAttr(name, str, true)
            end
        elseif eventType == 2 and Completed then
            if sender.closeKeyboard and sfind(str, "\n") and mode ~= InputMode.ANY then
                sender:closeKeyboard()
            else
                if mode ~= InputMode.ANY then
                    str = strim(str)
                end

                if mode == InputMode.INT then
                    str = CheckIntValue(tonumber(str) or 0, min, max)
                    sender:setString(str)
    
                    self:updateCommonAttr(name, str)
                    self:updateSpecialAttr(name, str)
                elseif mode == InputMode.FLOAT then
                    local len = slen(str)
                    if len > 0 then
                        if not tonumber(str) then
                            sender:setString(self._InputValues[name] or (GetVal and GetVal() or ""))
                            return false
                        end
        
                        if max then
                            str = math.max(math.min(str, max), 0)
                        else
                            local i,j,f,m = sfind(str, "(%d+)%.(%d+)")
                            if f then
                                if m and tonumber(m) ~= 0 then
                                    str = tonumber(f) + tonumber(m)/math.pow(10, slen(m))
                                end
                            elseif not sfind(str, "%.") then
                                str = tonumber(str)
                            end
                        end
                    end
                    sender:setString(str)

                    if len < 1 then
                        str = 0
                    end
                    self._InputValues[name] = str
    
                    self:updateCommonAttr(name, str)
                    self:updateSpecialAttr(name, str)
                else
                    sender:setString(str)
                    if not data.NotNowRef then
                        self:updateCommonAttr(name, str)
                        self:updateSpecialAttr(name, str)
                    end
                end
            end
        end
    end)
end

function GUIEditor:onClose()
    for _, listener in pairs(self._closeListener) do
        listener()
    end
    self._quickUI.ScrollView_files:removeAllChildren()
end

function GUIEditor:addCloseEventListener(listener)
    tInsert(self._closeListener, listener)
end

-- 退出
function GUIEditor:onCloseUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIEditor_Close)
end

function GUIEditor:addScrollInTree()
    GUI:SetScrollViewVerticalBar(self._quickUI.Panel_tree, {
        bgPic       = "res/private/gui_edit/scroll/line.png",
        barPic      = "res/private/gui_edit/scroll/p.png",
        Arr1PicN    = "res/private/gui_edit/scroll/t.png",
        Arr1PicP    = "res/private/gui_edit/scroll/t_1.png",
        Arr2PicN    = "res/private/gui_edit/scroll/b.png",
        Arr2PicP    = "res/private/gui_edit/scroll/b_1.png",
        x           = 200,
        y           = 0,
        list        = self._quickUI.ScrollView_1
    })
end

-- 切换
function GUIEditor:onChange(ref, eventType)
    local tag = ref:getTag()
    local x = visibleSize.width
    if tag > 0 then
        x = x + 300
        ref:setTag(0)
    else
        ref:setTag(1)
    end
    self._quickUI.Panel_attr:stopAllActions()
    self._quickUI.Panel_attr:runAction(cc.MoveTo:create(0.2, cc.p(x, self._quickUI.Panel_attr:getPositionY())))
    self._quickUI.Panel_button:stopAllActions()
    self._quickUI.Panel_button:runAction(cc.MoveTo:create(0.2, cc.p(x, self._quickUI.Panel_button:getPositionY())))
end

-- tree 切换
function GUIEditor:onNodeTreeChange(ref, eventType)
    local tag = ref:getTag()
    local x = 0
    if tag > 0 then
        x = x + 215
        ref:setTag(0)
    else
        ref:setTag(1)
    end
    self._quickUI.Panel_tree:stopAllActions()
    self._quickUI.Panel_tree:runAction(cc.MoveTo:create(0.2, cc.p(x, self._quickUI.Panel_tree:getPositionY())))
end

-- 文件
function GUIEditor:onFile(ref, eventType)
    if self._quickUI.Panel_quick:isVisible() then
        self._quickUI.Panel_quick:setVisible(false)
    end
    
    if self._quickUI.Panel_files:isVisible() then
        self:hideFiles()
    else
        self._selDirctor = clone(self._lastDirectory)
        self._files = self:getAllFiles()
        self:updateAllFiles()
        self:showFiles()
    end
    self._quickUI.Panel_create_file:setVisible(false)
end

function GUIEditor:onKeyEsc()
    if self._quickUI.Panel_files:isVisible() then
        return self:hideFiles()
    end
    if self._quickUI.Button_change:getTag() == 1 then
        return self:onChange(self._quickUI.Button_change)
    end
    self:stopAllActions()
    self:onCloseUI()
end

function GUIEditor:onCreateFile(ref, eventType)
    self._quickUI.Panel_create_file:setVisible(true)
    self._quickUI.ScrollView_files:setVisible(false)
    self._quickUI.TextField_Create_File_Name:setString("")
end

function GUIEditor:onOpenFile(ref, eventType)
    self._selDirctor = nil
    self._files = self:getAllFiles()
    self:updateAllFiles()
    self._quickUI.Panel_create_file:setVisible(false)
    self._quickUI.ScrollView_files:setVisible(true)
end

function GUIEditor:onRefFile()
    local isExsit = false
    if self._selDirctor then
        local flag = self._files[self._selDirctor]
        local root = self:findFileRoot(flag)
        local curFile =  sformat("%s/%s", root, sgsub(self._selDirctor, "[/]+$", ""))
        if curFile and self:IsDirectory(curFile) then
            isExsit = true
        end
    end
    if not isExsit and self._selDirctor then
        self:onKeyBackSpace()
    else
        self._files = self:getAllFiles()
        self:updateAllFiles()
    end
    self._quickUI.Panel_create_file:setVisible(false)
    self._quickUI.ScrollView_files:setVisible(true)
end

function GUIEditor:onCtrlZ()
    if not self._IsZing then
        -- 移除当前
        tRemove(self._caches)

        self._IsZing = true
    end

    local source = nil

    local num = #self._caches
    if num > 1 then
        source = tRemove(self._caches)
    else
        source = self._caches[1]
    end

    if not source then
        return false
    end
    
    if type(source) == "table" then
        self._Node_UI:setPosition(source)
    else
        self:InputGUI(source)
        self._Node_UI:setPosition(self._NodePos)
    end
end

function GUIEditor:onCreateOk(ref, eventType)
    local str = self._quickUI.TextField_Create_File_Name:getString()

    if slen(str or "") < 1 then
        return self:AddSystemTips(sformat("<font color = '%s'>请输入有效名字</fount>", "#FF0000"))
    end
    self._quickUI.ScrollView_files:setVisible(false)

    self:checkExportFolder(self._selDirctor)

    local path = self._defaultPath

    if self._selDirctor then
        path = path .. "/" .. self._selDirctor
    else
        if not global.isGMMode and self:GetSaveLoacalValue("path") ~= 2 then
            path = exportFolder
        end
    end

    local filename = sformat("%s.lua", str)
    local filePath = sformat("%s/%s", path, filename)

    filePath = filePath:gsub("//", "/")

    if fileUtil:isFileExist(filePath) then
        return self:AddSystemTips(sformat("<font color = '%s'>文件名重复，请重复命名</fount>", "#FF0000"))
    end

    local content = [[
local ui = {}
function ui.init(parent)
end
return ui
]]

    fileUtil:writeStringToFile(content, filePath)

    self._curFile = filename
    self:hideFiles()
    print("Create New File: ", filename)

    self:open(path, filename, filename)
end

function GUIEditor:onDeleteUI(ref, eventType)
    if #self._selWidgets < 1 then
        return false
    end
    local isRvmSuccuss = false

    local n = self._selWidgets or {}
    for i = 1, #n do
        local widget = n[i]
        if widget and widget.___DRAWNODE___ and widget.___DRAWNODE___:isVisible() then
            if not isRvmSuccuss then
                isRvmSuccuss = self:removeTree(widget)
            else
                self:removeTree(widget)
            end
        end
    end
    if isRvmSuccuss then
        self:onCancelSelectNode()
        self:updateTreeNodes()
    end
end

function GUIEditor:onCreateCancel(ref, eventType)
    self._quickUI.Panel_create_file:setVisible(false)
    self._quickUI.TextField_Create_File_Name:setString("")
    self._quickUI.ScrollView_files:setVisible(false)
end

function GUIEditor:onCancelSelectNode(ref, eventType)
    local chidldrens = self._quickUI.ScrollView_1:getChildren()
    for i = 1, #chidldrens do
        local v = chidldrens[i]
        if v then
            v.cell_bg_2:setVisible(false)
        end
    end
    if self._selWidget and self._selWidget.___DRAWNODE___ then
        self._selWidget.___DRAWNODE___:setVisible(false)
    end
    self._selDescription = nil
    self._selTreeNode = nil
    self._selWidget = nil
    self:updateAttr()
end

function GUIEditor:onTreeArrow(ref, eventType)
    if ref:getRotation() == 0 then
        self:setTreeStatus(ref._widget, true)
        ref:setRotation(90)
        print("-------展开-------")
    else
        self:setTreeStatus(ref._widget, false)
        ref:setRotation(0)
        print("-------折叠-------")
    end
end

function GUIEditor:setTreeStatus(widget, status)
    local function setOpen(children)
        for widget,_ in pairs(children) do
            local item

            local cs = self._quickUI.ScrollView_1:getChildren()
            for k = 1, #cs do
                local v = cs[k]
                if v and v.widget == widget then
                    item = v
                    break
                end
            end
            if item then
                item:setVisible(true)
                if item.Button_arr then
                    item.Button_arr:setRotation(0)
                end
            end

            local idx = self:getTreeIdxByObj(widget)
            if idx then
                self._uiTree[idx].open = false
            end
        end
    end

    local function setClose(children)
        for widget,_ in pairs(children) do
            local item
            local cs = self._quickUI.ScrollView_1:getChildren()
            for k = 1, #cs do
                local v = cs[k]
                if v and v.widget == widget then
                    item = v
                    break
                end
            end
            if item then
                item:setVisible(false)
            end

            local idx = self:getTreeIdxByObj(widget)
            if idx then
                self._uiTree[idx].open = false
                if self._uiTree[idx].children and next(self._uiTree[idx].children) then
                    setClose(self._uiTree[idx].children)
                end
            end
        end
    end

    for i = 1, #self._uiTree do
        local d = self._uiTree[i]
        if d and d.widget == widget then
            d.open = status
            if next(d.children) then
                if status == true then
                    setOpen(d.children)
                else
                    setClose(d.children)
                end
            end
            break
        end
    end

    self:refreshTreeList()
end

function GUIEditor:onTreeCellEvent(ref, eventType)
    local function _SelectTree(sender)
        if self._isPressedCtrl then
            if not self:isSelectWidget(sender.widget) then
                self:selectWidget(sender.widget)
            end
        else
            self:onCancelSelectNode()
            self:resetAllSelectWidget()
            self:selectWidget(sender.widget)
        end
        self._selTreeNode = sender
        self:updateAttr()
        sender.cell_bg_2:setVisible(true)
    end

    self._longPress = self._longPress or false
    if eventType == 0 then
        self._moving = false

        performWithDelay(ref, function()
            if self._selWidget ~= ref.widget then
                _SelectTree(ref)
            end
            self._longPress = true
            
            ref.cell_bg_2:runAction(cc.RepeatForever:create(cc.Blink:create(1, 3)))
        end, global.MMO.CLICK_DOUBLE_TIME)
    elseif eventType == 1 then
        local beganPos = ref:getTouchBeganPosition()
        local movePos  = ref:getTouchMovePosition()
        if math.abs(beganPos.x - movePos.x) > 2 or math.abs(beganPos.y - movePos.y) > 2 then
            ref:stopAllActions()
        end

        ref.cell_bg_2:stopAllActions()

        if not self._longPress then
            return false
        end

        if not self._selWidget then
            return false
        end

        if math.abs(beganPos.y - movePos.y) > 10 then
            self._moving = true
            local nodePos = self._quickUI.Panel_tree:convertToNodeSpace(movePos)

            local posY = self._quickUI.ScrollView_1:getInnerContainerPosition().y
            if posY < 0 then
                nodePos.y = nodePos.y - posY
            end
            ref:setPosition(cc.p(100, nodePos.y))
            self._quickUI.ScrollView_1:setTouchEnabled(false)

            local endPosY  = ref:getPositionY()
            local cur_node = ref.widget

            local childrens = self._quickUI.ScrollView_1:getChildren()
            for k = 1, #childrens do
                local v = childrens[k]
                if cur_node ~= v.widget then
                    local py  = v:getPositionY()
                    local dis = endPosY - py
                    -- 子控件，位置相差5个像素
                    if math.abs(dis) < 5 then
                        self._line:setPositionY(py-12+posY)
                        self._line:setVisible(true)
                    elseif dis > 0 and dis < 12 then
                        self._line:setPositionY(py+12+posY)
                        self._line:setVisible(true)
                    elseif dis > -12 and dis < 0 then
                        self._line:setPositionY(py-12+posY)
                        self._line:setVisible(true)
                    end
                end
            end
        end
    else
        self._quickUI.ScrollView_1:setTouchEnabled(true)
        self._longPress = false

        ref.cell_bg_2:stopAllActions()
        ref:stopAllActions()

        self._line:setVisible(false)

        if self._moving then
            local endPosY  = ref:getPositionY()
            local cur_node = ref.widget

            local cs = self._quickUI.ScrollView_1:getChildren()
            for k = 1, #cs do
                local v = cs[k]
                local aim_node = v.widget
                if cur_node ~= aim_node then
                    local dis = endPosY - v:getPositionY()
                    -- 子控件，位置相差5个像素
                    if math.abs(dis) < 5 then
                        -- 添加到该控件下面
                        print(sformat("把 %s 添加到 %s 里面", cur_node:getName(), aim_node:getName()))
                        return self:changeNodeTree(aim_node, cur_node, 0)
                    elseif dis > 0 and dis < 12 then
                        print(sformat("把 %s 添加到 %s 上面", cur_node:getName(), aim_node:getName()))
                        return self:changeNodeTree(aim_node, cur_node, 1)
                    elseif dis > -12 and dis < 0 then
                        print(sformat("把 %s 添加到 %s 下面", cur_node:getName(), aim_node:getName()))
                        return self:changeNodeTree(aim_node, cur_node, 2)
                    end
                end
            end
            self:updateTreeNodes()
        elseif eventType == 2 then
            ref.cell_bg_2:stopAllActions()
            _SelectTree(ref)
        end
    end
end

function GUIEditor:onSelectSavePath(ref, eventType)
    if global.isGMMode then
        return false
    end
    local panel_list = self._quickUI.Panel_path_list_bg
    local isVisible  = not panel_list:isVisible()
    panel_list:setVisible(isVisible)
end

function GUIEditor:onSureSavePath(ref, eventType)
    self._quickUI.Panel_path_list_bg:setVisible(false)

    local paths = {
        ["bg_stab"] = exportFolder,
        ["bg_dev"]  = gmFolder
    }

    local tags = {
        ["bg_stab"] = 1,
        ["bg_dev"]  = 2
    }

    local name = ref:getName()
    local path = paths[name]
    
    if path == self._defaultPath then
        return false
    end
    self._defaultPath = path

    self:SetSaveLocalValue("path", tags[name])

    self._files = self:getAllFiles()
    self:updateAllFiles()

    self._quickUI.Text_save_path:setString(self._defaultPath)
end

function GUIEditor:showFiles()
    self._quickUI.ScrollView_files:setVisible(true)
    self._quickUI.Panel_files:setVisible(true)
end

function GUIEditor:hideFiles()
    self._quickUI.Panel_files:setVisible(false)
end

function GUIEditor:setListFileSelect(list, filename, bool)
    local chidldrens = list:getChildren()
    for k = 1, #chidldrens do
        local item = chidldrens[k]
        if item and item:isVisible() then
            local visible = item:getName() == filename
            item:getChildByName("cell_bg_2"):setVisible(visible)
            if bool then
                local picTag = visible and 2 or 1
                item:getChildByName("fileMask"):loadTexture(sformat("%sfile_%s.png", _PathRes, picTag))
            end
        end
    end
end

function GUIEditor:findFileRoot(flag)
    return flag == "GM" and gmFolder or (flag == "CACHE" and cacheFolder or exportFolder)
end

function GUIEditor:updateAllFiles()
    local curFile = nil
    if self._selDirctor then
        -- 判断是否有选中的文件
        local flag = self._files[self._selDirctor]
        local root = self:findFileRoot(flag)
        curFile = sformat("%s/%s", root, sgsub(self._selDirctor, "[/]+$", ""))
    end

    local items = {}
    local luaItems = {}

    if curFile and self:IsDirectory(curFile) then
        for fullfile, flag in pairs(self._files) do
            -- 从开头开始匹配才算成功
            local sIndex = sfind(fullfile, sformat("%s%s", self._selDirctor, "(.+)"))
            if sIndex and sIndex == 1 then
                local newID = sgsub(fullfile, self._selDirctor, "", 1)
                local isCurFile = not sfind(newID, "/(.+)")
                if isCurFile then
                    local filename = sgsub(newID, "[/]+$", "")
                    local isDir = not sfind(newID, ".lua")
                    local tb = {file = filename, flag = flag, isDir = isDir, fullfile = fullfile}
                    if isDir then
                        items[#items+1] = tb
                    else
                        luaItems[#luaItems+1] = tb
                    end
                end
            end
        end
    else
        for fullfile, flag in pairs(self._files) do
            -- 是否当前目录下文件
            local isCurFile = not sfind(fullfile, "/(.+)")
            if isCurFile then
                local filename = sgsub(fullfile, "[/]+$", "")
                local isDir = not sfind(fullfile, ".lua")
                local tb = {file = filename, flag = flag, isDir = isDir, fullfile = fullfile}
                if isDir then
                    items[#items+1] = tb
                else
                    luaItems[#luaItems+1] = tb
                end
            end
        end
    end

    tSort(items, function ( a, b ) return a.file < b.file end)
    tSort(luaItems, function ( a, b ) return a.file < b.file end)

    for i = 1, #luaItems do
        local v = luaItems[i]
        if v then
            items[#items+1] = v
        end
    end

    local list = self._quickUI.ScrollView_files
    list:removeAllChildren()

    local size = self._quickUI.file_cell:getContentSize()
    local itemHH = size.height
    local innrHH = math.max(itemHH * #items, list:getContentSize().height)
    list:setInnerContainerSize(cc.size(list:getContentSize().width, innrHH))
    
    for i = 1, #items do
        local file = items[i]

        local item = self._quickUI.file_cell:clone()
        list:addChild(item)
        IterAllChild(item, item)

        item:setPosition(cc.p(0, innrHH - i*itemHH))
        item:setVisible(true)

        local filename = file.file
        local isDir    = file.isDir
        local fullfile = file.fullfile   -- 文件路径全拼（不带跟目录）
        local root     = self:findFileRoot(file.flag)
        file.root = root

        item:setName(filename)

        -- 选中效果
        item.cell_bg_2:setVisible(filename == self._curFile)
        -- 文件名
        if self._language == 1 then
            local newName = (self._cfgs and self._cfgs[filename]) and self._cfgs[filename] or filename
            item.cell_text:setString(newName)
        else
            item.cell_text:setString(filename)
        end

        if isDir then
            item.cell_text:setColor(cc.c3b(255, 255, 0))
            item.fileMask:loadTexture("res/private/gui_edit/image_2.png")
        else
            item.cell_text:setColor(cc.c3b(255, 255, 255))
            item.fileMask:loadTexture("res/private/gui_edit/image_1.png")
        end
        -- 双击事件
        local clickNum = 0
        item:addTouchEventListener(function(_, eventType)
            if eventType == 0 then
                performWithDelay(item, function() clickNum = 0 end, global.MMO.CLICK_DOUBLE_TIME)
            elseif eventType ~= 1 then
                self._selFileInfo = file

                clickNum = clickNum + 1
                self:setListFileSelect(self._quickUI.ScrollView_files, filename)

                if clickNum == 2 then
                    self:onKeyEnter()
                end
            end   
        end)
    end
    list:scrollToTop(0.01, false)
end

---------------------------------------------------------------------------------------
-- 快捷UI管理
function GUIEditor:onQuickOprateFiles()
    local isVisible = self._quickUI.Panel_quick:isVisible()
    if isVisible then
        self._quickUI.Panel_quick:setVisible(false)
    else
        self._Node_Preview:removeAllChildren()
        self:InitQuickUI()
        self._quickUI.Panel_quick:setVisible(true)
    end
end

-- 文件快捷操作
function GUIEditor:HideChildrens(list)
    for i, v in ipairs(list:getChildren()) do
        if v then
            v:setContentSize(v:getContentSize().width, 0)
            v:setVisible(false)
        end
    end
end

function GUIEditor:InitQuickData()
    local cfgs  = SL:Require("game_config/cfg_gui_editor_quick", true)
    local descs = cfgs.ex
        
    local f1 = {}
    local n1 = 0
    local fmap1 = {}
    
    local f2 = {}
    local n2 = 0
    local fmap2 = {}

    local f3 = {}
    local n3 = 0
    local fmap3 = {}
    
    local f4 = {}
    local n4 = 0
    local fmap4 = {}

    local beizhu = {}
    local n = 0

    local setBeizhu = function (desc)
        local nt = #beizhu
        for _, bz in ipairs(desc or {}) do
            if bz then
                tInsert(beizhu[nt], bz)
            end
        end
    end
    
    for i,v in ipairs(cfgs.files) do
        local l = ssplit(v, "#")
        local v1, v2, v3, v4 = l[1], l[2], l[3], l[4]
    
        if v1 and not fmap1[v1] then
            n1 = n1 + 1
            fmap1[v1] = n1

            n = #f1 + 1
            f1[n] = {key = n1, belong = 0, name = v1}

            beizhu[n] = {}
        end
    
        local belong = fmap1[v1]
        if belong and v2 and (sfind(v2, ".lua") or (not fmap2[v2])) then
            local belong = fmap1[v1]
            n2 = n2 > 0 and (n2 + 1) or (belong + 1000)
            fmap2[v2] = n2
            
            n = #f2 + 1
            f2[n] = {key = n2, belong = belong, name = v2}

            setBeizhu(descs[v2] and descs[v2].desc)
        end
    
        local belong = fmap2[v2]
        if belong and v3 and (sfind(v3, ".lua") or (not fmap3[v3])) then
            n3 = n3 > 0 and (n3 + 1) or (belong + 1000)
            fmap3[v3] = n3

            n = #f3 + 1
            f3[n] = {key = n3, belong = belong, name = v3}

            setBeizhu(descs[v3] and descs[v3].desc)
        end
    
        local belong = fmap3[v3]
        if belong and v4 and (sfind(4, ".lua") or (not fmap4[4])) then
            local belong = fmap3[v3]
            n4 = n4 > 0 and (n4 + 1) or (belong + 1000)
            fmap4[v4] = n4

            n = #f4 + 1
            f4[n] = {key = n4, belong = belong, name = v4}

            setBeizhu(descs[v4] and descs[v4].desc)
        end
    end

    return {f1, f2, f3, f4}, beizhu, descs
end

function GUIEditor:InitQuickUI(filterText)
    self._selQuickKeys = {1, nil, nil, nil}
    self:LoadListfiles(1, true, filterText)
    self:LoadListfiles(2)
    self:LoadListfiles(3)
    self:LoadListfiles(4)
end

function GUIEditor:LoadListfiles(bIndex, first, filterText)
    local list = self._quickUI["ListView_f"..bIndex]
    list:removeAllChildren()

    local datas = {}
    if first then
        local files = self._quickCfgs[bIndex] or {}
        if filterText and #filterText > 0 then
            for i, v in ipairs(files) do
                local beizhus = self._quickCfgDesc[v.key]
                local Is = false
                for k, v in ipairs(beizhus or {}) do
                    if sfind(v, filterText) then
                        Is = true
                        break
                    end
                end

                if Is then
                    datas[#datas + 1] = v
                end
            end
        else
            datas = files
        end
    else
        local belong = self._selQuickKeys[bIndex]
        if not belong then
            return list:setVisible(false)
        end

        local files = self._quickCfgs[bIndex] or {}
        for i, v in ipairs(files) do
            if v.belong == belong then
                datas[#datas + 1] = v
            end
        end
    end

    if #datas < 1 then
        return list:setVisible(false)
    end

    list:setVisible(true)
    
    for i, v in ipairs(datas) do
        local item = list:getChildByTag(i)
        if not item then
            item = self._quickUI.file_cell_2:clone()
            list:pushBackCustomItem(item)
            item:setTag(i)
        end
        item:setContentSize(cc.size(item:getContentSize().width, 50))
        item:setVisible(true)

        local fileMask = item:getChildByName("fileMask")
        local cellText = item:getChildByName("cell_text")

        local filename = v.name
        local key      = v.key

        local isLua = sfind(filename, ".lua")
        if isLua then
            cellText:setPositionX(5)
            fileMask:setVisible(false)
        else
            cellText:setPositionX(56)
            fileMask:loadTexture(_PathRes .. "file_1.png")
            fileMask:setVisible(true)
        end

        item:setName(filename)

        local name = self._quickCfgEx[filename] and (self._quickCfgEx[filename].name or filename) or filename
        item:getChildByName("cell_text"):setString(name)

        -- 双击事件
        local clickNum = 0
        item:addTouchEventListener(function(_, eventType)
            if eventType == 0 then
                performWithDelay(item, function() clickNum = 0 end, global.MMO.CLICK_DOUBLE_TIME)
                return false
            end
            if eventType == 1 then
                return false
            end

            clickNum = clickNum + 1
            self:setListFileSelect(list, filename, true)

            if bIndex == 1 then
                self._selQuickKeys = {nil, key, nil, nil}
                self:LoadListfiles(2)
                self:LoadListfiles(3)
                self:LoadListfiles(4)
            elseif bIndex == 2 then
                self._selQuickKeys = {nil, nil, key, nil}
                self:LoadListfiles(3)
                self:LoadListfiles(4)
            elseif bIndex == 3 then
                self._selQuickKeys = {nil, nil, nil, key}
                self:LoadListfiles(4)
            end

            self._Node_Preview:removeAllChildren()

            if isLua then
                local file = self:onFindfileInfo(filename)
                
                self:openPreview(file.root, file.fullfile)

                if clickNum == 2 then
                    self._selFileInfo = self:onFindfileInfo(filename)
                    self:onKeyEnter()
                end
            end
        end)
    end
end

function GUIEditor:onFindfileInfo(filename)
    local flag = self._files[filename]
    if flag then
        return {fullfile = filename, file = self:getFileName(filename), root = self:findFileRoot(flag), isDir = false}
    end
    return {}
end

function GUIEditor:SetQuickSearch(value)
    self:InitQuickUI(value)
end
---------------------------------------------------------------------------------------

function GUIEditor:open(root, fullfile, file)
    self._curFile = file
    self:hideFiles()
    
    local fullpath = sformat("%s/%s", root, fullfile)

    fullpath = fullpath:gsub("//", "/")

    if not fileUtil:isFileExist(fullpath) then
        return false
    end

    self._lastDirectory = self._selDirctor
    self._Text_Cur_Dir:setString(fullpath)

    local source  = fileUtil:getDataFromFileEx(fullpath)
    local succuss = self:InputGUI(source, true)
    if succuss then
        self._selFileInfo = {}
        self._selFileInfo.fullfile = fullfile
    end

    self:SaveCache(source, true)

    self._NodePos = cc.p(self._Node_UI:getPosition())
end

function GUIEditor:openPreview(root, fullfile)
    local fullpath = sformat("%s/%s", root, fullfile)
    if not fileUtil:isFileExist(fullpath) then
        return false
    end
    local source = fileUtil:getDataFromFileEx(fullpath)
    self:InputGUIPreview(source)
end

function GUIEditor:initAdapet()
    local ww = visibleSize.width
    local hh = visibleSize.height
    self._quickUI.Panel_global:setPosition(cc.p(ww - 4, hh - 4))
    self._quickUI.Panel_button:setPosition(cc.p(ww, hh - 50))
    self._quickUI.Panel_shortcut:setPosition(cc.p(ww - 500, hh - 4))

    local atthh = hh - 225
    local attww = self._quickUI.Panel_attr:getContentSize().width

    self._quickUI.Panel_attr:setContentSize(cc.size(attww, atthh))
    self._quickUI.Panel_attr:setPosition(cc.p(ww, atthh))
    self._quickUI.Top_attr:setPositionY(atthh - 48)

    self._quickUI.ScrollView_attr:setContentSize(cc.size(attww, atthh - 75))
    self._quickUI.ScrollView_attr:setPositionY(0)

    self._quickUI.Panel_files:setContentSize(cc.size(ww, hh))
    self._quickUI.Panel_files:setPosition(cc.p(0, 0))

    self._quickUI.Button_openfile:setPosition(cc.p(57, hh - 29))
    self._quickUI.Button_createfile:setPosition(cc.p(57, hh - 74))
    self._quickUI.Button_saveAll:setPosition(cc.p(57, hh - 119))
    self._quickUI.Button_fileManage:setPosition(cc.p(57, hh - 164))
    
    self._quickUI.ScrollView_files:setContentSize(cc.size(ww - 536, hh - 50))
    self._quickUI.ScrollView_files:setInnerContainerSize(cc.size(ww - 536, hh - 50))
    self._quickUI.ScrollView_files:setPosition(cc.p(220, hh - 50))

    local bgWid = ww - 536
    self._quickUI.Panel_save_path_bg:setContentSize(bgWid, self._quickUI.Panel_save_path_bg:getContentSize().height)
    self._quickUI.Panel_path_list_bg:setContentSize(bgWid, self._quickUI.Panel_path_list_bg:getContentSize().height)
    self._quickUI.ListView_paths:setContentSize(bgWid, self._quickUI.ListView_paths:getContentSize().height)
    self._quickUI.bg_stab:setContentSize(bgWid, self._quickUI.bg_stab:getContentSize().height)
    self._quickUI.bg_dev:setContentSize(bgWid, self._quickUI.bg_dev:getContentSize().height)
    
    self._quickUI.Panel_save_path_bg:setPosition(cc.p(220, hh - 25))
    self._quickUI.Text_save_path:setPosition(cc.p(222, hh - 25))
    self._quickUI.Panel_path_list_bg:setPosition(cc.p(220, hh - 43))
    self._quickUI.Panel_list_touch:setPosition(cc.p(-220, 103))
    self._quickUI.Panel_list_touch:setContentSize(cc.size(ww, hh))

    self._quickUI.Panel_create_file:setPosition(cc.p(ww / 2 - 35, hh / 2))

    local treeww = self._quickUI.Panel_tree:getContentSize().width
    self._quickUI.Panel_tree:setContentSize(cc.size(treeww, hh - 190))
    self._quickUI.Panel_tree:setPosition(cc.p(215, 0))

    self._quickUI.ScrollView_1:setContentSize(cc.size(200, hh - 190))
    self._quickUI.ScrollView_1:setPositionY(0)

    self._quickUI.Button_tree:setPositionX(215)

    self._Text_Cur_Dir:setPositionY(hh)

    self._quickUI.Panel_pop:setContentSize(cc.size(ww, hh))

    self._quickUI.Panel_pop_image:setPosition(cc.p(ww / 2, hh / 2))

    self._quickUI.file_cell:setVisible(false)
    self._quickUI.tree_cell:setVisible(false)

    -- file manager
    self._quickUI.Panel_quick:setContentSize(cc.size(ww, hh - 50))

    local fw = self._quickUI.ListView_f1:getContentSize().width
    self._quickUI.ListView_f1:setContentSize(cc.size(fw, hh - 154))
    self._quickUI.ListView_f2:setContentSize(cc.size(fw, hh - 154))
    self._quickUI.ListView_f3:setContentSize(cc.size(fw, hh - 154))
    self._quickUI.ListView_f4:setContentSize(cc.size(fw, hh - 154))

    self._quickUI.Panel_line:setContentSize(cc.size(5,  hh - 50))
    self._quickUI.Panel_line_1:setContentSize(cc.size(2,  hh - 150))
    self._quickUI.Panel_line_2:setContentSize(cc.size(2,  hh - 150))
    self._quickUI.Panel_line_3:setContentSize(cc.size(2,  hh - 150))
    self._quickUI.Panel_line_1:setPositionY(hh / 2 - 140 / 2)
    self._quickUI.Panel_line_2:setPositionY(hh / 2 - 140 / 2)
    self._quickUI.Panel_line_3:setPositionY(hh / 2 - 140 / 2)

    self._quickUI.Panel_quick_bg:setContentSize(cc.size(fw * 4 + 15, hh - 140))

    self._quickUI.Image_QSearch:setPositionY(hh - 100)
end

function GUIEditor:initButton()
    local crls = {
        ["Button_Text"]         = "Text", 
        ["Button_BmpText"]      = "BmpText",
        ["Button_TextAtlas"]    = "TextAtlas",
        ["Button_RText"]        = "RText", 
        ["Button_Img"]          = "ImageView", 
        ["Button_Button"]       = "Button", 
        ["Button_Layout"]       = "Layout", 
        ["Button_Input"]        = "Input", 
        ["Button_CheckBox"]     = "CheckBox", 
        ["Button_Slider"]       = "Slider", 
        ["Button_LoadingBar"]   = "LoadingBar", 
        ["Button_ListView"]     = "ListView", 
        ["Button_ScrollView"]   = "ScrollView",
        ["Button_PageView"]     = "PageView",
        ["Button_Node"]         = "Node",
        ["Button_Sfx"]          = "Effect",
        ["Button_Item"]         = "Item",
        ["Button_Model"]        = "Model",
        ["Button_EquipShow"]    = "EquipShow",
    }
    for key,type in pairs(crls) do
        self._quickUI[key]:addClickEventListener(function () self:createNewWidget(type) end)
    end
end

-- 重新计算子控件深度
function GUIEditor:setChildrenDepth(children, depth)
    depth = depth + 1
    for widget,_ in pairs(children) do
        if widget then
            local idx = self:getTreeIdxByObj(widget)
            if idx then
                self._uiTree[idx].depth = depth
                self:setChildrenDepth(self._uiTree[idx].children, depth)
            end
        end
    end
end

-- 移除老节点并添加到新的节点上
function GUIEditor:changeParent(node, newParent)
    node:retain()
    node:removeFromParent()
    newParent:addChild(node)
    node:release()
    if newParent:getDescription() == "ListView" then
        newParent:doLayout()
    end
end

-- 移除 node 节点下的所有子节点
function GUIEditor:removeOldParent(index, widget)
    for i = 1, #self._uiTree do
        local v = self._uiTree[i]
        if v then
            if self._uiTree[i].children[widget] then
                self._uiTree[i].children[widget] = nil
            end
        end
    end

    local parent = self:GetParent(self._uiTree[index].parent)
    if self._uiNodeMap[parent] then
        self._uiNodeMap[parent][widget] = nil
    end

    self._uiTree[index].parent = {}
end

function GUIEditor:SetMaxValue(children)
    local max = 0
    for k,v in pairs(children) do
        if v and v > max then
            max = v
        end
    end
    return max+1
end

function GUIEditor:GetParent(parent)
    for k,v in pairs(parent) do
        if k then
            return k
        end
    end
    return false
end

-- node2 在 node1 的位置 ( flag: 0子控件, 1上面, 2下面）
function GUIEditor:changeNodeTree(node1, node2, flag)
    if node1 == node2 then
        return false
    end

    local idx1 = self:getTreeIdxByObj(node1)
    if not idx1 then
        return false
    end

    local idx2 = self:getTreeIdxByObj(node2)
    if not idx2 then
        return false
    end

    local ID1Parent = self:GetParent(self._uiTree[idx1].parent)
    local ID2Parent = self:GetParent(self._uiTree[idx2].parent)

    local parentID = self:getTreeIdxByObj(ID1Parent)
    if flag ~= 0 and ID2Parent and parentID and self._uiTree[parentID].widget:getDescription() == "ListView" then
        return false
    end

    self:removeOldParent(idx2, node2)

    if flag == 0 then
        self:changeParent(self._uiTree[idx2].widget, self._uiTree[idx1].widget)

        self._uiTree[idx2].parent = {}
        self._uiTree[idx2].parent[node1] = true

        self._uiTree[idx1].children[node2] = self._uiTree[idx1].children[node2] or self:SetMaxValue(self._uiTree[idx1].children)

        self._uiNodeMap[node1] = self._uiNodeMap[node1] or {}
        self._uiNodeMap[node1][node2] = true

        self._uiTree[idx1].open = true

        local depth = self._uiTree[idx1].depth + 1
        if depth ~= self._uiTree[idx2].depth then
            self._uiTree[idx2].depth = depth
            self:setChildrenDepth(self._uiTree[idx2].children, depth)
        end
    else
        if ID1Parent and parentID and self._uiTree[parentID] then
            self:changeParent(self._uiTree[idx2].widget, self._uiTree[parentID].widget)
            self._uiTree[idx2].parent = {}
            self._uiTree[idx2].parent[ID1Parent] = true

            self._uiNodeMap[ID1Parent] = self._uiNodeMap[ID1Parent] or {}
            self._uiNodeMap[ID1Parent][node2] = true

            self._uiTree[parentID].open = true

            local depth = self._uiTree[idx1].depth
            if depth ~= self._uiTree[idx2].depth then
                self._uiTree[idx2].depth = depth
                self:setChildrenDepth(self._uiTree[idx2].children, depth)
            end

            local newIdx = 1
            local childrens = self._uiTree[parentID].children
            for widget, i in pairs(childrens) do
                if widget and widget == node1 then
                    newIdx = i
                    break
                end
            end

            for widget, i in pairs(childrens) do
                local idx = i > newIdx and i + 1 or (i < newIdx and i - 1 or (flag == 1 and i + 1 or i - 1))
                self._uiTree[parentID].children[widget] = idx
            end

            self._uiTree[parentID].children[node2] = newIdx
        else
            self:changeParent(self._uiTree[idx2].widget, self._Node_UI)

            local depth = self._uiTree[idx1].depth
            if depth ~= self._uiTree[idx2].depth then
                self._uiTree[idx2].depth = depth
                self:setChildrenDepth(self._uiTree[idx2].children, depth)
            end

            local temp = clone(self._uiTree[idx2])
            tRemove(self._uiTree, idx2)

            local newIdx = self:getTreeIdxByObj(node1)
            if newIdx and newIdx > 0 then
                if flag == 2 then
                    newIdx = newIdx + 1
                end
                tInsert(self._uiTree, newIdx, temp)
            else
                tInsert(self._uiTree, temp)
            end
        end
    end

    self:onCancelSelectNode()
    self:sortTree()
    self:updateTreeNodes()
end

function GUIEditor:insertTree(widget, ID, selWidget)
    local children = {}
    local parent = {}
    local open   = false
    local depth  = 1

    self._uiNodeMap = self._uiNodeMap or {}
    self._uiNodeMap[widget] = self._uiNodeMap[widget] or {}
    
    if selWidget then
        for i = 1, #self._uiTree do
            local v = self._uiTree[i]
            if v and v.widget == selWidget then
                depth  = v.depth + 1
                v.open = true
                parent[selWidget]  = true
                v.children[widget] = self:SetMaxValue(v.children)
                self._uiNodeMap[v.widget][widget] = true
                self._showNames[widget] = sformat("%s#%s", self._showNames[selWidget] or selWidget:getName(), widget:getName())
                break
            end
        end
    else
        self._showNames[widget] = widget:getName()
    end 
    tInsert(self._uiTree, {widget = widget, ID = ID, depth = depth, open = open, parent = parent, children = children})

    self:sortTree()
end

function GUIEditor:removeTree(widget)
    -- 删除父节点
    local idx = self:getTreeIdxByObj(widget)
    if not idx then
        return false
    end

    local wParent = self:GetParent(self._uiTree[idx].parent)
    if wParent then
        local parentID = self:getTreeIdxByObj(wParent)
        if parentID and self._uiTree[parentID] and self._uiTree[parentID].children then
            self._uiTree[parentID].children[widget] = nil
        end
    end

    local function delUiTree(swidget)
        for i = 1, #self._uiTree do
            local v = self._uiTree[i]
            if v and v.widget == swidget then
                for childID,_ in pairs(v.children) do
                    if childID then
                        delUiTree(childID)
                    end
                end
                tRemove(self._uiTree, i)
            end         
        end
    end
    delUiTree(widget)

    local isRvmSuccuss = false
    local function delNodeMap(swidget, first)
        if first then
            for k,chilren in pairs(self._uiNodeMap or {}) do
                for _swidget,_ in pairs(chilren) do
                    if _swidget and _swidget == swidget then
                        self._uiNodeMap[k][_swidget] = nil
                        break
                    end
                end
            end
            delNodeMap(swidget)
        else
            if swidget and self._uiNodeMap[swidget] then
                if next(self._uiNodeMap[swidget]) then
                    for k,v in pairs(self._uiNodeMap[swidget]) do
                        self._uiNodeMap[swidget][k] = nil

                        if table.nums(self._uiNodeMap[swidget]) == 0 then
                            self._uiNodeMap[swidget] = nil
                            if not tolua.isnull(swidget) and swidget:getParent() then
                                swidget:removeFromParent()
                            end
                            swidget = nil
                            if not isRvmSuccuss then
                                isRvmSuccuss = true
                            end
                        end

                        delNodeMap(k)
                    end
                else
                    self._uiNodeMap[swidget] = nil
                    if not tolua.isnull(swidget) and swidget:getParent() then
                        swidget:removeFromParent()
                    end
                    swidget = nil
                    if not isRvmSuccuss then
                        isRvmSuccuss = true
                    end
                end
            end
        end
    end
    delNodeMap(widget, true)

    
    if isRvmSuccuss then
        self:sortTree()
    end

    return isRvmSuccuss
end

function GUIEditor:getTreeIdxByObj(widget)
    for i = 1, #self._uiTree do
        local v = self._uiTree[i]
        if v and v.widget == widget then
            return i
        end
    end
    return false
end

-- 把 chidlren 转成有序 table
function GUIEditor:convertChildrenFormat(children)
    local t = {}
    for widget,code in pairs(children) do
        tInsert(t, {widget = widget, i = code })
    end
    if #t > 0 then
        tSort(t, function ( a, b ) return a.i < b.i end)
    end
    return t 
end

function GUIEditor:sortTree()
    local tag = 1

    local function setOrder(children)
        for k = 1, #children do
            local v = children[k]
            local idx = self:getTreeIdxByObj(v.widget)
            if idx then
                self._uiTree[idx].order = tag
                self._uiTree[idx].widget:setLocalZOrder(tag)
                tag = tag + 1
                if next(self._uiTree[idx].children) then
                    setOrder(self:convertChildrenFormat(self._uiTree[idx].children))
                end
            end
        end
    end

    for i = 1, #self._uiTree do
        local v = self._uiTree[i]
        if not next(v.parent) then
            v.order = tag
            tag = tag + 1
            v.widget:setLocalZOrder(tag)
        end
        if not next(v.parent) and next(v.children) then
            setOrder(self:convertChildrenFormat(v.children))
        end
    end

    if #self._uiTree > 0 then
        tSort(self._uiTree, function ( a, b ) return a.order < b.order end)
    end
end

function GUIEditor:updateTreeName(name)
    local oldName = self._selWidget:getName()
    self._selWidget:setName(name)

    local idx = self:getTreeIdxByObj(self._selWidget)
    if idx then
        self._uiTree[idx]["ID"] = name
    end

    local childrens = self._quickUI.ScrollView_1:getChildren()
    for i = 1, #childrens do
        local node = childrens[i]
        if self._selWidget and self._selWidget:getName() == node.widget then
            node.TextTreeName:setName(name)
            break
        end
    end
end

function GUIEditor:getNewID(names, str)
    local keys = {}
    local max  = 1
    
    for name,v in pairs(names) do
        if v and name then
            local _,i,key = sfind(name, sformat("%s%s", str, "_(%d+)"))
            key = key and tonumber(key)
            if key then
                keys[key] = 1
                max = max + 1
            end
        end
    end

    local ID = nil
    for key=1,max do
        if not keys[key] then
            ID = sformat("%s_%s", str, key)
            break
        end
    end

    return ID
end

function GUIEditor:checkIDValid(ID)
    local oldname = self._selWidget:getName()
    if oldname == ID then
        return false, ID
    end

    if not ID then
        return false
    end

    local names = {[self._selWidget:getName()] = true}

    local childrens = self._selWidget:getChildren()
    for i = 1, #childrens do
        local child = childrens[i]
        names[child:getName()] = true
    end

    if not names[ID] then
        return true, ID
    end

    local _ID = self:getNewID(names, ID)
    if _ID then
        return true, _ID
    end

    return false
end

function GUIEditor:createNewWidget(type)
    local CreateNode = {
        ["Text"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Text_Create(parent, ID, 0, 0, 16, "#FFFFFF", "文本")
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["RText"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Widget_Create(parent, ID, 0, 0, 0, 0)

            local rText = self:CreateRText(widget, true)
            widget:setContentSize(rText:getContentSize())

            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["BmpText"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:BmpText_Create(parent, ID, 0, 0, "#FFFFFF", "Bmp文本")
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["TextAtlas"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:TextAtlas_Create(parent, ID, 0, 0, [[./0123456789]], sformat("%s%s", _PathRes, "TextAtlas.png"), 14, 18, ".")
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["ImageView"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Image_Create(parent, ID, 0, 0, sformat("%s%s", _PathRes, "ImageFile.png"))
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["Button"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Button_Create(parent, ID, 0, 0, sformat("%s%s", _PathRes, "Button_Normal.png"))
            GUI:Button_loadTexturePressed(widget, sformat("%s%s", _PathRes, "Button_Press.png"))
            GUI:Button_loadTextureDisabled(widget, sformat("%s%s", _PathRes, "Button_Disable.png"))
            GUI:Button_setTitleColor(widget, "#FFFFFF")
            GUI:Button_setTitleText(widget, "Button")
            GUI:Button_setTitleFontSize(widget, 14)
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["Input"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:TextInput_Create(parent, ID, 0, 0, 100, 25, 16)
            GUI:TextInput_setString(widget, "输入框")
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["CheckBox"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:CheckBox_Create(parent, ID, 0, 0, sformat("%s%s", _PathRes, "CheckBox_Normal.png"), sformat("%s%s", _PathRes, "CheckBox_Press.png"))
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["LoadingBar"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:LoadingBar_Create(parent, ID, 0, 0, sformat("%s%s", _PathRes, "LoadingBar.png"), 0)

            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["Slider"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Slider_Create(parent, ID, 0, 0, sformat("%s%s", _PathRes, "Slider_Bg.png"), sformat("%s%s", _PathRes, "Slider_Bar.png"), sformat("%s%s", _PathRes, "Slider_Ball.png"))
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["Layout"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Layout_Create(parent, ID, 0, 0, defaultViewW, defaultViewH)
            GUI:Layout_setBackGroundColor(widget, "#96C8FF")
            GUI:Layout_setBackGroundColorType(widget, 1)
            GUI:Layout_setBackGroundColorOpacity(widget, 140)
            self:insertTree(widget, ID, self._selWidget)
            
            return widget
        end,
        ["ListView"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:ListView_Create(parent, ID, 0, 0, defaultViewW, defaultViewH, 1)
            GUI:ListView_setBackGroundColor(widget, "#9696FF")
            GUI:ListView_setBackGroundColorType(widget, 1)
            GUI:ListView_setBackGroundColorOpacity(widget, 100)
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["ScrollView"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:ScrollView_Create(parent, ID, 0, 0, defaultViewW, defaultViewH, 1)
            GUI:ScrollView_setBackGroundColor(widget, "#FF9664")
            GUI:ScrollView_setBackGroundColorType(widget, 1)
            GUI:ScrollView_setBackGroundColorOpacity(widget, 100)
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["PageView"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:PageView_Create(parent, ID, 0, 0, defaultViewW, defaultViewH)
            GUI:PageView_setBackGroundColor(widget, "#969664")
            GUI:PageView_setBackGroundColorType(widget, 1)
            GUI:PageView_setBackGroundColorOpacity(widget, 100)
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["Node"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Widget_Create(parent, ID, 0, 0, defaultSize.width, defaultSize.height)
            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["Effect"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Widget_Create(parent, ID, 0, 0, defaultSize.width, defaultSize.height)

            self:CreateEffect(widget, true)

            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["Item"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Widget_Create(parent, ID, 0, 0, 0, 0)

            local item = self:CreateItemShow(widget, true)
            widget:setContentSize(item:getContentSize())

            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["Model"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Widget_Create(parent, ID, 0, 0, defaultSize.width, defaultSize.height)

            self:CreateModel(widget, true)

            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
        ["EquipShow"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:Widget_Create(parent, ID, 0, 0, 0, 0)

            local equipShow = self:CreateEquipShow(widget, true)
            widget:setContentSize(equipShow:getContentSize())

            self:insertTree(widget, ID, self._selWidget)

            return widget
        end,
    }

    if not CreateNode[type] then
        return false
    end

    if self._selDescription == "PageView" and type ~= "Layout" then
        return false
    end

    if self._selDescription == "EquipShow" then
        return false
    end

    local pWidget = self._selWidget or self._Node_UI
    local names = {}
    if self._selWidget then
        names = {[self._selWidget:getName()] = true}
    end

    local childrens = pWidget:getChildren()
    for i = 1, #childrens do
        local child = childrens[i]
        names[child:getName()] = true
    end

    local _ID = names[type] and self:getNewID(names, type) or type
    if not _ID then
        return false
    end

    local widget = CreateNode[type] (_ID)

    self:setWidgetDrawRect(widget)

    self:updateTreeNodes()

    if self._selDescription == "ListView" then
        self._selWidget:jumpToBottom()
    end
end

function GUIEditor:addTextTreeName(node, depth)
    local x = 18 + (depth-1) * 10
    local TextTreeName = GUI:Text_Create(node, "TextTreeName", x, 12, 14, "#BFBFBF", "")
    GUI:setAnchorPoint(TextTreeName, 0, 0.5)
end

function GUIEditor:updateTreeNodes()
    self._quickUI.ScrollView_1:removeAllChildren()

    local function addTreeItem(d)
        local depth  = d.depth or 1
        local open   = d.open
        local ID     = d.ID
        local widget = d.widget
        local children = d.children

        local ui = self._quickUI.tree_cell:clone()
        self:addTextTreeName(ui, depth)

        IterAllChild(ui, ui)

        local showName = ID
        if self._language == 1 then
            local chinesename = GUI:getChineseName(widget)
            if chinesename and chinesename ~= "" then
                showName = chinesename
            end
        end
        ui.TextTreeName:setString(showName)

        ui.widget = widget
        ui:setTag(d.order)

        if open then
            ui.Button_arr:setRotation(90)
        else
            ui.Button_arr:setRotation(0)
        end

        if children and next(children) then
            ui.Button_arr:setVisible(true)
        else
            ui.Button_arr:setVisible(false)
        end

        ui.Button_arr._widget= widget
        ui.Button_arr._depth = depth
        ui.Button_arr:setPositionX(9 + (depth-1) * 10)

        if self._selWidget and self._selWidget == widget then
            ui.cell_bg_2:setVisible(true)
        end

        -- 道具框、装备框重加载下
        if widget:getDescription() == "Item" then
            local item = widget:getChildByName("__ITEM__")
            if item then
                item:removeFromParent()
            end

            self:CreateItemShow(widget)
        elseif widget:getDescription() == "EquipShow" then
            local item = widget:getChildByName("__EQUIPSHOW__")
            if item then
                item:removeFromParent()
            end

            self:CreateEquipShow(widget)
        end

        return ui
    end

    for i = 1, #self._uiTree do
        local d = self._uiTree[i]
        if d then
            local ui = addTreeItem(d)
            ui:setVisible(true)
            self._quickUI.ScrollView_1:addChild(ui)

            local pWidget = self:GetParent(d.parent) 
            if pWidget then 
                local idx = self:getTreeIdxByObj(pWidget)
                if self._uiTree[idx] and not self._uiTree[idx].open then
                    ui:setVisible(false)
                end
            end
        end
    end

    self:refreshTreeList()
end

function GUIEditor:refreshTreeList()
    local preY = GUI:ListView_getInnerContainer(self._quickUI.ScrollView_1):getPositionY()
    local preHeight = self._quickUI.ScrollView_1:getInnerContainerSize().height

    local function sortfunc(list)
        tSort(list, function ( a, b ) return a:getTag() < b:getTag() end)
    end
    GUI:UserUILayout(self._quickUI.ScrollView_1, { dir = 1, addDir = 1, sortfunc = sortfunc })

    local curY = GUI:ListView_getInnerContainer(self._quickUI.ScrollView_1):getPositionY()
    local curHeight = self._quickUI.ScrollView_1:getInnerContainerSize().height

    local height = self._quickUI.ScrollView_1:getContentSize().height
    if curHeight > height then
        local addH = preHeight- curHeight
        GUI:ListView_getInnerContainer(self._quickUI.ScrollView_1):setPositionY(preY+addH)
    else
        GUI:ListView_getInnerContainer(self._quickUI.ScrollView_1):setPositionY(0)
    end
end

---------attr----------------------------------------------------------------------------------
function GUIEditor:onAttrBar(ref, eventType)
    local tag = ref:getTag()
    local idx = self._barArrow[tag]
    if not idx then
        return false
    end
    local bar = self._quickUI["Bar"..tag]
    if not bar then
        return false
    end
    if idx == 1 then
        self._barArrow[tag] = 0
    else
        self._barArrow[tag] = 1
    end
    self:refAttrPostion()
end

function GUIEditor:refAttrPostion()
    local bar1  = self._quickUI.Bar1
    local att1  = self._quickUI.Att1
    local barH  = GUI:getContentSize(bar1).height
    local open1 = self._barArrow[1] == 1

    if not self._selWidget then
        return false
    end
    
    local isWidget = self._selDescription == "Widget"

    -- 该组件是否可以发送消息
    local isMessage = self._selDescription == "Label" or self._selDescription == "Button" or self._selDescription == "ImageView" or self._selDescription == "Layout"

    local ihh = 10
    if bar1 and att1 then
        ihh = open1 and ihh + GUI:getContentSize(att1).height + barH or barH
        GUI:setRotation(bar1:getChildByName("arrow"), open1 and 90 or 0)
    end

    local bar2  = self._quickUI.Bar2
    local att2  = self._quickUI.Att2
    local open2 = self._barArrow[2] == 1
    if bar2 and att2 then
        ihh = open2 and ihh + GUI:getContentSize(att2).height + barH or ihh + barH
        GUI:setRotation(bar2:getChildByName("arrow"), open2 and 90 or 0)
    end

    local bar3  = self._quickUI.Bar3
    local att3  = self._quickUI.Att3
    local open3 = self._barArrow[3] == 1
    if bar3 and att3 and not isWidget then
        ihh = open3 and ihh + GUI:getContentSize(att3).height + barH or ihh + barH
        GUI:setRotation(bar3:getChildByName("arrow"), open3 and 90 or 0)
    end

    local bar4  = self._quickUI.Bar4
    local att4  = self._quickUI.Att4
    local open4 = self._barArrow[4] == 1
    if bar4 and att4 and isMessage then
        ihh = open4 and ihh + GUI:getContentSize(att4).height + barH or ihh + barH
        GUI:setRotation(bar4:getChildByName("arrow"), open4 and 90 or 0)
    end

    local svSize = GUI:getContentSize(self._quickUI.ScrollView_attr)
    ihh = math.max(svSize.height, ihh)
    GUI:ScrollView_setInnerContainerSize(self._quickUI.ScrollView_attr, svSize.width, ihh)

    if bar1 and att1 then
        GUI:setVisible(bar1, true)
        GUI:setPositionY(bar1, ihh)
        ihh = ihh - barH
        if open1 then
            GUI:setVisible(att1, true)
            GUI:setPositionY(att1, ihh)
            ihh = ihh - GUI:getContentSize(att1).height
        else
            GUI:setVisible(att1, false)
        end
    end

    if bar2 and att2 then
        GUI:setVisible(bar2, true)
        GUI:setPositionY(bar2, ihh)
        ihh = ihh - barH
        if open2 then
            GUI:setVisible(att2, true)
            GUI:setPositionY(att2, ihh)
            ihh = ihh - GUI:getContentSize(att2).height
        else
            GUI:setVisible(att2, false)
        end
    end

    if isWidget then
        GUI:setVisible(bar3, false)
        GUI:setVisible(att3, false)
    else
        if bar3 and att3 then
            GUI:setVisible(bar3, true)
            GUI:setPositionY(bar3, ihh)
            ihh = ihh - barH
            if open3 then
                GUI:setVisible(att3, true)
                GUI:setPositionY(att3, ihh)
                ihh = ihh - GUI:getContentSize(att3).height
            else
                GUI:setVisible(att3, false)
            end
        end
    end

    if isMessage then
        if bar4 and att4 then
            GUI:setVisible(bar4, true)
            GUI:setPositionY(bar4, ihh)
            ihh = ihh - barH
            if open4 then
                GUI:setVisible(att4, true)
                GUI:setPositionY(att4, ihh)
                ihh = ihh - GUI:getContentSize(att4).height
            else
                GUI:setVisible(att4, false)
            end
        end
    else
        GUI:setVisible(bar4, false)
        GUI:setVisible(att4, false)
    end
end

function GUIEditor:refAttrList()
    local UIs               = {
        ["ui_Label"]        = "Label", 
        ["ui_BmpText"]      = "BmpText",
        ["ui_TextAtlas"]    = "TextAtlas",
        ["ui_RichText"]     = "RText",
        ["ui_ImageView"]    = "ImageView", 
        ["ui_Button"]       = "Button", 
        ["ui_Layout"]       = "Layout", 
        ["ui_EditBox"]      = "EditBox",
        ["ui_CheckBox"]     = "CheckBox", 
        ["ui_Slider"]       = "Slider", 
        ["ui_LoadingBar"]   = "LoadingBar", 
        ["ui_ListView"]     = "ListView", 
        ["ui_ScrollView"]   = "ScrollView",
        ["ui_PageView"]     = "PageView",
        ["ui_Effect"]       = "Effect",
        ["ui_Item"]         = "Item",
        ["ui_Model"]        = "Model",
        ["ui_EquipShow"]    = "EquipShow",
    }

    local desp = self._selWidget:getDescription()
    if desp == "TextField" then
        desp = "EditBox"
    end

    local root = self._quickUI.Att3:getChildByTag(999)
    if root and UIs[root:getName()] == desp then
        return false
    end
    self._quickUI.Att3:removeAllChildren()
    self._quickUI.Att4:removeAllChildren()
    
    self._selUISpecialControl = {}

    local isWidget = self._selDescription == "Widget"
    if not isWidget then
        local uiName = sformat("%s%s", "ui_", desp)
        root = CreateExport(sformat("gui_editor/%s.lua", uiName)):getChildByName(uiName):clone()
        self._quickUI.Att3:addChild(root, 1, 999)
        IterAllChild(root, root)

        -- 该组件是否可以发送消息
        local isMessage = self._selDescription == "Label" or self._selDescription == "Button" or self._selDescription == "ImageView" or self._selDescription == "Layout"

        local rootEx = {}
        if isMessage then
            rootEx = CreateExport("gui_editor/ui_Message.lua"):getChildByName("ui"):clone()
            self._quickUI.Att4:addChild(rootEx, 1, 999)

            IterAllChild(rootEx, rootEx)

            local att4_hh = rootEx:getContentSize().height
            self._quickUI.Att4:setContentSize(self._quickUI.Att4:getContentSize().width, att4_hh)
            rootEx:setPositionY(att4_hh)
        end

        for name,d in pairs(self._SpecialAttr) do
            if name and (root[name] or rootEx[name]) then
                local widget = root[name] or rootEx[name]
                if widget then
                    if d.t == 1 then
                        local editBox = CreateEditBoxByTextField(widget)
                        self._selUISpecialControl[name] = editBox
                        self:initTextFieldEvent(self._selUISpecialControl[name])
                        self._selUISpecialControl[name]:setInputMode(RealMode[d.IMode])
                        if d.Len then
                            self._selUISpecialControl[name]:setMaxLength(d.Len)
                        end
                    elseif d.t == 2 then
                        self._selUISpecialControl[name] = widget
                        self._selUISpecialControl[name]:addClickEventListener(d.func)
                    elseif d.t == 3 then
                        self._selUISpecialControl[name] = widget
                        self._selUISpecialControl[name]:addEventListener(d.func)
                    elseif d.t == 99 then
                        self._selUISpecialControl[name] = widget
                        self._selUISpecialControl[name]:addTouchEventListener(d.func)
                    else
                        self._selUISpecialControl[name] = widget
                    end
                end
            end
        end

        local att3_hh = root:getContentSize().height
        self._quickUI.Att3:setContentSize(self._quickUI.Att3:getContentSize().width, att3_hh)
        root:setPositionY(att3_hh)
    end

    self:refAttrPostion()
end

function GUIEditor:updateAttr()
    if not self._selWidget then
        self._quickUI.ScrollView_attr:setVisible(false)
        self._quickUI.Top_attr:setVisible(false)
        return false
    end

    if self._selWidget.___DRAWNODE___ then
        self._selWidget.___DRAWNODE___:setVisible(true)
    end

    if self._selWidget.___NODE___ then
        self._selWidget.___NODE___:setVisible(true)
    end

    if self._selWidget.___TOUCHLAYOUT___ then
        self._selWidget.___TOUCHLAYOUT___:setVisible(true)
    end
    
    self._quickUI.ScrollView_attr:setVisible(true)
    self._quickUI.Top_attr:setVisible(true)

    self._selDescription = self._selWidget:getDescription()

    self._InputValues = {}
    
    self:refAttrList()

    self:setCommonAttrUI()
    self:setSpecialAttrUI()

    if self._selDescription == "Label" then
        self._selUICommonControl["Image_Mask_Touch"]:setVisible(false)

        self._selUICommonControl["Image_Mask_Width"]:setLocalZOrder(2)
        self._selUICommonControl["Image_Mask_Height"]:setLocalZOrder(2)

        self._selUICommonControl["Image_Mask_AnrX"]:setVisible(false)
        self._selUICommonControl["Image_Mask_AnrY"]:setVisible(false)

        self:setIgnoreSize()
    elseif self._selDescription == "EditBox" or self._selDescription == "TextField" then
        self._selUICommonControl["Image_Mask_Touch"]:setVisible(false)

        self._selUICommonControl["Image_Mask_opacity"]:setLocalZOrder(2)
        self._selUICommonControl["TextField_Opacity"]:setString(100)
        self._selUICommonControl["Slider_Opacity"]:setPercent(100)
        self._selUICommonControl["Image_Mask_opacity"]:setVisible(true)

        self._selUICommonControl["Image_Mask_Width"]:setVisible(false)
        self._selUICommonControl["Image_Mask_Height"]:setVisible(false)

        self._selUICommonControl["Image_Mask_AnrX"]:setVisible(false)
        self._selUICommonControl["Image_Mask_AnrY"]:setVisible(false)

        self._selUICommonControl["Image_Mask_Swallow"]:setVisible(false)
        self._selUICommonControl["Image_Mask_Scale"]:setVisible(false)
    elseif self._selDescription == "BmpText" or self._selDescription == "RText" or self._selDescription == "Item" or self._selDescription == "EquipShow" then
        self._selUICommonControl["Image_Mask_Touch"]:setVisible(false)

        self._selUICommonControl["Image_Mask_Width"]:setLocalZOrder(2)
        self._selUICommonControl["Image_Mask_Width"]:setVisible(true)
        if self._selDescription == "RText" then
            self._selUICommonControl["Image_Mask_Width"]:setVisible(false)
        else
            self._selUICommonControl["Image_Mask_Height"]:setLocalZOrder(2)
            self._selUICommonControl["Image_Mask_Height"]:setVisible(true)
        end

        self._selUICommonControl["Image_Mask_AnrX"]:setVisible(false)
        self._selUICommonControl["Image_Mask_AnrY"]:setVisible(false)

        self._selUICommonControl["Image_Mask_Swallow"]:setVisible(false)
        self._selUICommonControl["Image_Mask_Scale"]:setVisible(false)
    elseif self._selDescription == "Effect" then
        self._selUICommonControl["Image_Mask_Touch"]:setVisible(false)

        self._selUICommonControl["Image_Mask_Width"]:setVisible(true)
        self._selUICommonControl["Image_Mask_Height"]:setVisible(true)
        self._selUICommonControl["Image_Mask_Width"]:setLocalZOrder(2)
        self._selUICommonControl["Image_Mask_Height"]:setLocalZOrder(2)

        self._selUICommonControl["Image_Mask_AnrX"]:setVisible(true)
        self._selUICommonControl["Image_Mask_AnrY"]:setVisible(true)
        self._selUICommonControl["Image_Mask_AnrX"]:setLocalZOrder(2)
        self._selUICommonControl["Image_Mask_AnrY"]:setLocalZOrder(2)

        self._selUICommonControl["Image_Mask_Swallow"]:setVisible(true)
        self._selUICommonControl["Image_Mask_Swallow"]:setLocalZOrder(2)

        self._selUICommonControl["Image_Mask_Scale"]:setVisible(false)

        self._selUICommonControl["Image_Mask_opacity"]:setLocalZOrder(2)
        self._selUICommonControl["TextField_Opacity"]:setString(100)
        self._selUICommonControl["Slider_Opacity"]:setPercent(100)
        self._selUICommonControl["Image_Mask_opacity"]:setVisible(true)
    elseif self._selDescription == "Model" then
        self._selUICommonControl["Image_Mask_Touch"]:setVisible(false)

        self._selUICommonControl["Image_Mask_Width"]:setVisible(true)
        self._selUICommonControl["Image_Mask_Height"]:setVisible(true)
        self._selUICommonControl["Image_Mask_Width"]:setLocalZOrder(2)
        self._selUICommonControl["Image_Mask_Height"]:setLocalZOrder(2)

        self._selUICommonControl["Image_Mask_AnrX"]:setVisible(true)
        self._selUICommonControl["Image_Mask_AnrY"]:setVisible(true)
        self._selUICommonControl["Image_Mask_AnrX"]:setLocalZOrder(2)
        self._selUICommonControl["Image_Mask_AnrY"]:setLocalZOrder(2)

        self._selUICommonControl["Image_Mask_Swallow"]:setVisible(true)
        self._selUICommonControl["Image_Mask_Swallow"]:setLocalZOrder(2)
        
        self._selUICommonControl["Image_Mask_Scale"]:setVisible(true)
        self._selUICommonControl["Image_Mask_Scale"]:setLocalZOrder(2)

        self._selUICommonControl["Image_Mask_opacity"]:setLocalZOrder(2)
        self._selUICommonControl["TextField_Opacity"]:setString(100)
        self._selUICommonControl["Slider_Opacity"]:setPercent(100)
        self._selUICommonControl["Image_Mask_opacity"]:setVisible(true)
    elseif self._selDescription == "Widget" then
        self._selUICommonControl["Image_Mask_Touch"]:setVisible(true)

        self._selUICommonControl["Image_Mask_Width"]:setVisible(true)
        self._selUICommonControl["Image_Mask_Height"]:setVisible(true)
        self._selUICommonControl["Image_Mask_Width"]:setLocalZOrder(2)
        self._selUICommonControl["Image_Mask_Height"]:setLocalZOrder(2)

        self._selUICommonControl["Image_Mask_AnrX"]:setVisible(true)
        self._selUICommonControl["Image_Mask_AnrY"]:setVisible(true)
        self._selUICommonControl["Image_Mask_AnrX"]:setLocalZOrder(2)
        self._selUICommonControl["Image_Mask_AnrY"]:setLocalZOrder(2)

        self._selUICommonControl["Image_Mask_Swallow"]:setVisible(false)
        self._selUICommonControl["Image_Mask_Scale"]:setVisible(false)
    else
        self._selUICommonControl["Image_Mask_Touch"]:setVisible(false)

        self._selUICommonControl["Image_Mask_opacity"]:setVisible(false)
        self._selUICommonControl["Image_Mask_Width"]:setVisible(false)
        self._selUICommonControl["Image_Mask_Height"]:setVisible(false)

        self._selUICommonControl["Image_Mask_AnrX"]:setVisible(false)
        self._selUICommonControl["Image_Mask_AnrY"]:setVisible(false)

        self._selUICommonControl["Image_Mask_Swallow"]:setVisible(false)
        self._selUICommonControl["Image_Mask_Scale"]:setVisible(false)
    end
end

function GUIEditor:setCommonAttrUI()
    local typeNames      = {
        ["Label"]        = "文本", 
        ["BmpText"]      = "Bmp文本",
        ["TextAtlas"]    = "艺术数字",
        ["RText"]        = "富文本",
        ["ImageView"]    = "图片", 
        ["Button"]       = "按钮", 
        ["Layout"]       = "基础容器", 
        ["EditBox"]      = "输入框",
        ["TextField"]    = "输入框",
        ["CheckBox"]     = "复选框", 
        ["Slider"]       = "滑动条", 
        ["LoadingBar"]   = "进度条", 
        ["ListView"]     = "列表容器", 
        ["ScrollView"]   = "滚动容器",
        ["PageView"]     = "翻页容器",
        ["Widget"]       = "节点",
        ["Effect"]       = "特效",
        ["Item"]         = "道具",
        ["Model"]        = "模型",
        ["EquipShow"]    = "装备框",

    }
    self._quickUI.Text_type:setString(typeNames[self._selDescription] or "其他")

    for name,_ in pairs(self._selUICommonControl) do
        if self._CommonAttr[name] and self._CommonAttr[name].SetUIWidget then
            self._CommonAttr[name].SetUIWidget(self._selUICommonControl[name], self._selWidget)
        end
    end
end

function GUIEditor:setSpecialAttrUI()
    for name,_ in pairs(self._selUISpecialControl or {}) do
        if self._SpecialAttr[name] and self._SpecialAttr[name].SetUIWidget then
            self._SpecialAttr[name].SetUIWidget(self._selUISpecialControl[name], self._selWidget)
        end
    end
end

function GUIEditor:updateCommonAttr(name, value)
    local add = false

    if name and self._CommonAttr[name] and self._CommonAttr[name].SetWidget then
        self._CommonAttr[name].SetWidget(value)
        add = true
    end

    if add then
        self:SaveCache()
    end
end

function GUIEditor:updateSpecialAttr(name, value, inputType)
    local add = false

    if name and self._SpecialAttr[name] and self._SpecialAttr[name].SetWidget then
        self._SpecialAttr[name].SetWidget(value, inputType)
        add = true
    end

    if add then
        self:SaveCache()
    end
end

function GUIEditor:setBgtc(enable)
    self._selUISpecialControl["Image_Mask_Color"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_Opacity"]:setLocalZOrder(2)

    self._selUISpecialControl["Image_Mask_Color"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_Opacity"]:setVisible(not enable)
end

function GUIEditor:setIgnoreSize(isSet)
    local ignoreSize = self._selWidget:isIgnoreContentAdaptWithSize()
    if isSet then
        ignoreSize = not ignoreSize
    end
    self._selWidget:ignoreContentAdaptWithSize(ignoreSize)

    local mWidth  = self._selUICommonControl["Image_Mask_Width"]
    local mHeight = self._selUICommonControl["Image_Mask_Height"]
    if ignoreSize then
        self._selWidget:setTextAreaSize(cc.size(0, 0))
        mWidth:setVisible(true)
        mHeight:setVisible(true)
    else
        mWidth:setVisible(false)
        mHeight:setVisible(false)
    end
end

function GUIEditor:setOutlineState(enable)
    self._selUISpecialControl["Image_Mask_Outline_Color"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_Outline_Width"]:setLocalZOrder(2)

    self._selUISpecialControl["Image_Mask_Outline_Color"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_Outline_Width"]:setVisible(not enable)
end

function GUIEditor:setCapInset(enable)
    self._selUISpecialControl["Image_Mask_l"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_r"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_b"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_t"]:setLocalZOrder(2)

    self._selUISpecialControl["Image_Mask_l"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_r"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_b"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_t"]:setVisible(not enable)

    local rect = self:getCapInset()
    
    self._selUISpecialControl["TextField_CapInset_L"]:setString(sformat("%d", rect.l))
    self._selUISpecialControl["TextField_CapInset_R"]:setString(sformat("%d", rect.r))
    self._selUISpecialControl["TextField_CapInset_T"]:setString(sformat("%d", rect.t))
    self._selUISpecialControl["TextField_CapInset_B"]:setString(sformat("%d", rect.b))
end

function GUIEditor:getCapInset(widget)
    local ui = widget or self._selWidget
    if not ui then
        return false
    end
    if tolua.type(ui) == "ccui.Widget" then
        return false
    end

    local rect   = {x = 0, y = 0, width = 0, height = 0}
    local enable = false
    local uiType = ui:getDescription()
    if uiType == "Layout" or uiType == "ListView" or uiType == "ScrollView" or uiType == "PageView" then
        if ui:isBackGroundImageScale9Enabled() then
            rect = ui:getBackGroundImageCapInsets()
            enable = true
        end
    elseif uiType == "ImageView" then
        if ui:isScale9Enabled() then
            rect = ui:getVirtualRenderer():getCapInsets()
            enable = true
        end
    elseif uiType == "Button" then
        if ui:isScale9Enabled() then
            rect = ui:getRendererNormal():getCapInsets()
            enable = true
        end
    end

    rect.x = math.floor(rect.x + 0.5)
    rect.y = math.floor(rect.y + 0.5)
    rect.width  = math.floor(rect.width + 0.5)
    rect.height = math.floor(rect.height + 0.5)

    if not enable then
        return {l = 0, r = 0, t = 0, b = 0}
    end

    local textureSize = nil
    if uiType == "Layout" or uiType == "ListView" or uiType == "ScrollView" or uiType == "PageView" then
        textureSize = ui:getBackGroundImageTextureSize()
    elseif uiType == "ImageView" then
        textureSize = ui:getVirtualRendererSize()
    elseif uiType == "Button" then
        textureSize = ui:getVirtualRendererSize()
    end

    local capInsets = {l = rect.x, t = rect.y, r = textureSize.width  - rect.x - rect.width, b = textureSize.height - rect.y - rect.height}
    return capInsets
end

function GUIEditor:setCapInsetValue(widget, uiType, rect)
    local textureSize = nil
    if uiType == "Layout" or uiType == "ListView" or uiType == "ScrollView" or uiType == "PageView" then
        textureSize = widget:getBackGroundImageTextureSize()
    elseif uiType == "ImageView" then
        textureSize = widget:getVirtualRendererSize()
    elseif uiType == "Button" then
        textureSize = widget:getVirtualRendererSize()
    end

    local x = rect.l
    local y = rect.t
    local width  = textureSize.width  - rect.l - rect.r
    local height = textureSize.height - rect.t - rect.b
    local capInsets = {x = x, y = y, width = width, height = height}

    if uiType == "Layout" or uiType == "ListView" or uiType == "ScrollView" or uiType == "PageView" then
        widget:setBackGroundImageCapInsets(RestrictCapInsetRect(capInsets, textureSize))
    else
        widget:setCapInsets(capInsets)
    end
end

-- 更新背景透明度
function GUIEditor:updateNodeOpacity(opacity)
    local function setOpacity(children)
        for widget,_ in pairs(children) do
            local idx = self:getTreeIdxByObj(widget)
            if idx then
                local widget = self._uiTree[idx].widget
                if widget then
                    widget:setOpacity(opacity)
                end
                if self._uiTree[idx].children and next(self._uiTree[idx].children) then
                    setOpacity(self._uiTree[idx].children)
                end
            end
        end
    end

    if self._selWidget then
        for i = 1, #self._uiTree do
            local d = self._uiTree[i]
            if d and d.widget == self._selWidget and next(d.children) then
                setOpacity(d.children)
                break
            end
        end
    end
end

function GUIEditor:onDrawRect(node, widget)
    local desc = widget:getDescription()
    local isSpecial = self:IsSpecialNode(desc)

    local size = cc.size(0, 0)
    if isSpecial then
        size = defaultSize
    elseif desc == "RText" then
        size = widget:getChildByName("__RICHTEXT__"):getContentSize()
    else
        size = widget:getContentSize()
    end
    
    local w = size.width
    local h = size.height

    if isSpecial then
        node:drawRect({x = -w/2, y = -h/2}, {x = w/2, y = h/2}, _LineColor)
    else
        node:drawRect({x = 0, y = 0}, {x = w, y = h}, _LineColor)
    end

    if not isSpecial then
        return false
    end

    local img = ccui.ImageView:create("res/private/gui_edit/Node.png")
    local anr = widget:getAnchorPoint()
    if isSpecial then
        img:setPosition({x = 0, y = 0})
    else
        img:setPosition({x = anr.x * w, y = anr.y * h})
    end
    widget:addChild(img)
end

function GUIEditor:resetDrawRect()
    if self._selWidget then
        if self._selWidget.___DRAWNODE___ then
            self._selWidget.___DRAWNODE___:clear()
            self:onDrawRect(self._selWidget.___DRAWNODE___, self._selWidget)
        end

        if self._selWidget.__LAYOUTCOMPONENT__ then
            local desc = self._selWidget:getDescription()
            local size = cc.size(0, 0)
            if desc == "RText" then
                size = self._selWidget:getChildByName("__RICHTEXT__"):getContentSize()
            elseif desc == "Effect" or desc == "Widget" then
                size = defaultSize
            else
                size = self._selWidget:getContentSize()
            end
            self._selWidget.__LAYOUTCOMPONENT__:setSize(size)
        end
    end
end

function GUIEditor:isSelectWidget(target)
    for _, swidget in pairs(self._selWidgets or {}) do
        if swidget and target == swidget then
            return true
        end
    end
    return false
end

function GUIEditor:resetAllSelectWidget()
    local swidgets = self._selWidgets or {}
    for i = 1, #swidgets do
        local swidget = swidgets[i]
        if swidget and swidget.___DRAWNODE___ then
            swidget.___DRAWNODE___:setVisible(false)
        end
    end
    self._selWidgets = {}

    self:SetShortcutState(0)
end

function GUIEditor:selectWidget(widget)
    if widget and widget.___DRAWNODE___ then
        widget.___DRAWNODE___:setVisible(true)
    end

    tInsert(self._selWidgets, widget)

    local num = #self._selWidgets
    if num == 1 then
        self._selWidget = self._selWidgets[1]
    else
        self._selDescription = nil
        self._selWidget = nil
    end

    self:SetShortcutState(num)
end

function GUIEditor:SetShortcutState(num)
    local setAlign = function (opacity, enabled)
        self._quickUI["Button_Key_1"]:setOpacity(opacity)
        self._quickUI["Button_Key_1"]:setTouchEnabled(enabled)

        self._quickUI["Button_Key_2"]:setOpacity(opacity)
        self._quickUI["Button_Key_2"]:setTouchEnabled(enabled)

        self._quickUI["Button_Key_3"]:setOpacity(opacity)
        self._quickUI["Button_Key_3"]:setTouchEnabled(enabled)

        self._quickUI["Button_Key_4"]:setOpacity(opacity)
        self._quickUI["Button_Key_4"]:setTouchEnabled(enabled)
    end

    if num > 2 then
        self._quickUI["Button_Key_V"]:setOpacity(255)
        self._quickUI["Button_Key_V"]:setTouchEnabled(true)

        self._quickUI["Button_Key_H"]:setOpacity(255)
        self._quickUI["Button_Key_H"]:setTouchEnabled(true)

        setAlign(255, true)
    else
        self._quickUI["Button_Key_V"]:setOpacity(128)
        self._quickUI["Button_Key_V"]:setTouchEnabled(false)

        self._quickUI["Button_Key_H"]:setOpacity(128)
        self._quickUI["Button_Key_H"]:setTouchEnabled(false)

        setAlign(num > 1 and 255 or 128, num > 1)
    end
end

function GUIEditor:IsSpecialNode(desc)
    return desc == "Widget" or desc == "Effect" or desc == "Model"
end

-- 选中框
function GUIEditor:setWidgetDrawRect(widget)
    local desc = widget:getDescription()
    local isSpecial = self:IsSpecialNode(desc)
    local size = isSpecial and defaultSize or widget:getContentSize()
    -- draw rect
    if not widget.___DRAWNODE___ then
        local drawNode = cc.DrawNode:create()
        drawNode:setName("___DRAWNODE___")
        
        if desc == "ListView" then
            widget:getInnerContainer():getParent():addChild(drawNode)
        else
            widget:addChild(drawNode)
        end
        widget.___DRAWNODE___ = drawNode

        self:onDrawRect(drawNode, widget)

        drawNode:setVisible(false)
        drawNode:setLocalZOrder(9998)
    end

    local layout = ccui.Layout:create()
    if isSpecial then
        layout:setAnchorPoint({x = 0.5, y = 0.5})
        layout:setPosition({x = 0, y = 0})
    end
    layout:ignoreContentAdaptWithSize(false)
    layout:setClippingEnabled(true)
    layout:setSwallowTouches(true)
    layout:setTouchEnabled(true)
    layout:setLayoutComponentEnabled(true)
    layout:setName("___TOUCHLAYOUT___")
    -- layout:setBackGroundColorType(1)
    -- layout:setBackGroundColor({r = 0, g = 255, b = 0})
    -- layout:setBackGroundColorOpacity(102)
    local LayoutComponent = ccui.LayoutComponent:bindLayoutComponent(layout)
    LayoutComponent:setSize(size)
    widget.___TOUCHLAYOUT___ = layout
    widget.__LAYOUTCOMPONENT__ = LayoutComponent

    if desc == "ListView" or desc == "PageView" then
        if not widget.___NODE___ then
            local node = cc.Node:create()
            node:setName("___NODE___")
            node:setLocalZOrder(9999)
            node:addChild(layout)
            widget:addChild(node)
            widget.___NODE___ = node

            layout.__NotMove__ = desc == "PageView"
        end
    else
        layout:setPropagateTouchEvents(false)
        widget:addChild(layout)
    end

    if desc == "ScrollView" then
        local y = widget:getInnerContainerSize().height - widget:getContentSize().height
        widget.___DRAWNODE___:setPosition(cc.p(0, math.max(y, 0)))
        widget.___TOUCHLAYOUT___:setPosition(cc.p(0, math.max(y, 0)))
    end
    
    local lastPos  = nil
    local clickNum = 0
    local isCanMove = false
    layout:addTouchEventListener(function(ref, eventType)
        if eventType == 0 then
            if self._isPressedCtrl then
                if not self:isSelectWidget(widget) then
                    self:selectWidget(widget)
                end
            else
                if self._selWidget and widget ~= self._selWidget then
                else
                    self:resetAllSelectWidget()
                    self:selectWidget(widget)
                end
            end
            lastPos  = layout:getTouchBeganPosition()
            clickNum = clickNum + 1
            layout:stopAllActions()
            performWithDelay(layout, function()
                clickNum = 0
            end, global.MMO.CLICK_DOUBLE_TIME)

            if self._selWidget then
                if self:IsSpecialNode(self._selDescription) then
                    local worldPos = self._selWidget:getWorldPosition()
                    local w = defaultSize.width
                    local h = defaultSize.height
                    local boundBox = {x = worldPos.x - w/2, y = worldPos.y - h/2, width = w, height = h}
                    isCanMove = cc.rectContainsPoint(boundBox, lastPos)
                else
                    isCanMove = IsInSideNode(self._selWidget, lastPos)
                end
            else
                isCanMove = false
            end

            self._nodeMoving = false
        elseif eventType == 1 then
            if self._isPressedSpace then
                return false
            end

            if not isCanMove then
                return false
            end

            local beganPos = ref:getTouchBeganPosition()
            local movePos  = ref:getTouchMovePosition()
            if math.abs(beganPos.x - movePos.x) < 3 or math.abs(beganPos.y - movePos.y) < 3 then
                return false
            end

            local psub     = cc.pSub(movePos, lastPos)
            lastPos        = layout:getTouchMovePosition()

            for i = 1, #self._selWidgets do
                local swidget = self._selWidgets[i]
                local pos = cc.p(swidget:getPositionX(), swidget:getPositionY())
                swidget:setPosition(cc.pAdd(pos, psub))

                self:SetUIPosX(self._selUICommonControl["TextField_PosX"], swidget)
                self:SetUIPosY(self._selUICommonControl["TextField_PosY"], swidget)

                self._nodeMoving = true
            end
        elseif eventType == 2 then
            if isCanMove then
                print("--------------------------移动保存------------------------")
                self:SaveCache()
            end

            if clickNum == 2 then
                print("----双击--------")
                clickNum = 0
                return false
            end
            print("-----点击----------")
            if not self._isPressedCtrl and self._nodeMoving == false and self._selWidget and widget ~= self._selWidget then
                self:resetAllSelectWidget()
                self:selectWidget(widget)
            end

            local chidldrens = self._quickUI.ScrollView_1:getChildren()
            for i = 1, #chidldrens do
                local child = chidldrens[i]
                if child then
                    child.cell_bg_2:setVisible(false)
                end
            end

            if #self._selWidgets == 1 then
                local item
                local chidldrens = self._quickUI.ScrollView_1:getChildren()
                for i = 1, #chidldrens do
                    local child = chidldrens[i]
                    if child and child.widget == self._selWidgets[1] then
                        item = child
                        break
                    end
                end
                if item then
                    item.cell_bg_2:setVisible(true)
                    self._selTreeNode = item
                    self:updateAttr()
                end
            else
                for i = 1, #self._selWidgets do
                    local v = self._selWidgets[i]
                    if v then
                        local item
                        local chidldrens = self._quickUI.ScrollView_1:getChildren()
                        for k = 1, #chidldrens do
                            local child = chidldrens[k]
                            if child and child.widget == v then
                                item = child
                                break
                            end
                        end
                        if item then
                            item.cell_bg_2:setVisible(true)
                        end
                    end
                end
                self._selTreeNode = nil
                self:updateAttr()
            end
        end
    end)
end

function GUIEditor:KeyBoardPressedFunc(keycode, evt)
    print("keycode: ", keycode)
    if tolua.isnull(self) then
        return false
    end

    if not self._KeyBoards then
        return false
    end

    if self._KeyBoards[keycode] then
        self._KeyBoards[keycode].callback()
    end
    performWithDelay(self, function()
        if self._KeyBoards[keycode] then
            if self._KeyBoards[keycode].schedule then
                if self._KeyBoards[keycode].scheduleID then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._KeyBoards[keycode].scheduleID)
                end
    
                self._KeyBoards[keycode].scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
                    self._KeyBoards[keycode].callback()
                end, 0.01, false)
            end
        end
    end, 0.5)
end

function GUIEditor:KeyBoardReleasedFunc(keycode)
    if tolua.isnull(self) then
        return false
    end
    
    if not self._KeyBoards then
        return false
    end

    self:stopAllActions()

    if self._KeyBoards[keycode] then
        if self._KeyBoards[keycode].schedule and self._KeyBoards[keycode].scheduleID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._KeyBoards[keycode].scheduleID)
        end
    end
    if keycode == cc.KeyCode.KEY_LEFT_CTRL then
        self._isPressedCtrl = false
    end
    if keycode == cc.KeyCode.KEY_SPACE then
        self._isPressedSpace = false
        self._mouseLayer:setVisible(false)
        self:SaveCache(cc.p(self._Node_UI:getPosition()))
        self._lastPos = nil
    end
end

function GUIEditor:OnMouseMoved(sender)
    if not sender then
        return false
    end
    if not self._isPressedSpace then
        return false
    end
    if sender:getMouseButton() == cc.MouseButton.BUTTON_LEFT then
        self._mouseLayer:setVisible(true)

        local mousePosX = sender:getCursorX()
        local mousePosY = sender:getCursorY()
        local cursor    = {x = mousePosX, y = mousePosY}
        if self._lastPos then
            local psub = cc.pSub(cursor, self._lastPos)
            local pos  = cc.p(self._Node_UI:getPositionX(), self._Node_UI:getPositionY())
            self._Node_UI:setPosition(cc.pAdd(pos, psub))
        end
        self._lastPos = cursor
    end
end

function GUIEditor:OnMouseUp(sender)
    self._lastPos = nil
end

-- 调整坐标
function GUIEditor:resetPostion(offPos)
    -- 选中父节点时, 子控件不移动
    local moveNodes = {}
    local temp = {}

    local n = self._selWidgets or {}
    for i = 1, #n do
        local swidget = n[i]
        if swidget then
            temp[swidget] = true
        end
    end

    for swidget,v in pairs(temp) do
        local parent = swidget:getParent()
        if parent and temp[parent] then
        else
            tInsert(moveNodes, swidget)
        end
    end

    local n = moveNodes or {}
    for i = 1, #n do
        local swidget = n[i]
        if swidget then
            local src_pos = cc.p(swidget:getPositionX(), swidget:getPositionY())
            local dst_pos = cc.pAdd(src_pos, offPos)
            swidget:setPosition(dst_pos)
            self:SetUIPosX(self._selUICommonControl["TextField_PosX"], swidget)
            self:SetUIPosY(self._selUICommonControl["TextField_PosY"], swidget)
        end
    end
end

function GUIEditor:cleanup()
    self._Node_UI:removeAllChildren()
    self._Node_UI:setPosition(cc.p(0, 0))
end

-----------------------------------------------------------------------------------------------------------------------
function GUIEditor:SetUIPreview(color)
    self._selUISpecialControl["Panel_Preview"]:setBackGroundColor(color)
end

function GUIEditor:SetUIOutlinePreview(color)
    self._selUISpecialControl["Panel_Outline_Preview"]:setBackGroundColor(color)
end

function GUIEditor:SetUIInputPlaceHolderPreview(color)
    self._selUISpecialControl["Panel_Preview2"]:setBackGroundColor(color)
end

function GUIEditor:SetUIBtnColor(hexColor)
    self._selUISpecialControl["Button_Color"].__color__ = hexColor
end

function GUIEditor:SetUIOutlineBtnColor(hexColor)
    self._selUISpecialControl["Button_Outline_Color"].__color__ = hexColor
end

function GUIEditor:SetUIInputPlaceHolderColor(hexColor)
    self._selUISpecialControl["Button_Color2"].__color__ = hexColor
end

function GUIEditor:SetRTextAttribute(key, value)
    local item = self._selWidget:getChildByName("__RICHTEXT__")
    if item then
        item:removeFromParent()
    end

    self:SetAttribute(GUIAttributes.RICH_TEXT, key, value)
    self:CreateRText(self._selWidget)
end

function GUIEditor:SetRTextUIAttribute(uiWidget, widget, key)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.RICH_TEXT)
    local value = data[key]
    if key == "RColor" then
        value = supper(value)
    end
    uiWidget:setString(value)

    return value
end

function GUIEditor:SetTextHorizontal(value)
    if self._selDescription == "Label" then
        self._selWidget:setTextHorizontalAlignment(value)
    end
end

function GUIEditor:SetUITextHorizontal(uiWidget, widget)
    if self._selDescription == "Label" then
        uiWidget:setString(widget:getTextHorizontalAlignment())
    end
end

function GUIEditor:SetTextVertical(value)
    if self._selDescription == "Label" then
        self._selWidget:setTextVerticalAlignment(value)
    end
end

function GUIEditor:SetUITextVertical(uiWidget, widget)
    if self._selDescription == "Label" then
        uiWidget:setString(widget:getTextVerticalAlignment())
    end
end

function GUIEditor:SetColorC( value )
    local rgbColor = GetColorFromHexString(value)

    if self._selDescription == "Label" or self._selDescription == "BmpText" then
        self._selWidget:setTextColor(rgbColor)
    elseif self._selDescription == "Button" then
        self._selWidget:setTitleColor(rgbColor)
    elseif self._selDescription == "EditBox" then
        self._selWidget:setFontColor(rgbColor)
    elseif self._selDescription == "TextField" then
        self._selWidget:setColor(rgbColor)
    elseif self._selDescription == "LoadingBar" then
        self._selWidget:setColor(rgbColor)
    elseif self._selDescription == "Layout" or self._selDescription == "ListView" or self._selDescription == "ScrollView" or self._selDescription == "PageView" then
        self._selWidget:setBackGroundColor(rgbColor)
    elseif self._selDescription == "RText" then
        self:SetRTextAttribute("RColor", GetColorHexFromRBG(rgbColor))
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUIEditor:SetUIColorC(uiWidget, widget)
    if self._selDescription == "Label" or self._selDescription == "BmpText" then
        local color = widget:getTextColor()
        local hexColor = GetColorHexFromRBG(color)
        uiWidget:setString(supper(hexColor))

        self:SetUIPreview(color)
        self:SetUIBtnColor(hexColor)
    elseif self._selDescription == "Button" then
        local color = widget:getTitleColor()
        local hexColor = GetColorHexFromRBG(color)
        uiWidget:setString(supper(hexColor))

        self:SetUIPreview(color)
        self:SetUIBtnColor(hexColor)
    elseif self._selDescription == "EditBox" then
        local color = widget:getFontColor()
        local hexColor = GetColorHexFromRBG(color)
        uiWidget:setString(supper(hexColor))

        self:SetUIPreview(color)
        self:SetUIBtnColor(hexColor)
    elseif self._selDescription == "TextField" then
        local color = widget:getColor()
        local hexColor = GetColorHexFromRBG(color)
        uiWidget:setString(supper(hexColor))

        self:SetUIPreview(color)
        self:SetUIBtnColor(hexColor)
    elseif self._selDescription == "LoadingBar" then
        local color = widget:getColor()
        local hexColor = GetColorHexFromRBG(color)
        uiWidget:setString(supper(hexColor))

        self:SetUIPreview(color)
        self:SetUIBtnColor(hexColor)
    elseif self._selDescription == "Layout" or self._selDescription == "ListView" or self._selDescription == "ScrollView" or self._selDescription == "PageView" then
        local color = widget:getBackGroundColor()
        local hexColor = GetColorHexFromRBG(color)
        uiWidget:setString(supper(hexColor))

        self:SetUIPreview(color)
        self:SetUIBtnColor(hexColor)
    elseif self._selDescription == "RText" then
        local color = self:SetRTextUIAttribute(uiWidget, widget, "RColor")
        self:SetUIPreview(GetColorFromHexString(color))
        self:SetUIBtnColor(color)
    end
end

function GUIEditor:SetColorOutlineC( value ) 
    local color = GetColorFromHexString(value)
    if self._selDescription == "Label" then
        local render = self._selWidget
        local c = render:getEffectColor()
        render:enableOutline(cc.c4b(color.r, color.g, color.b, c.a), render:getOutlineSize())
    elseif self._selDescription == "Button" then
        local render = self._selWidget:getTitleRenderer()
        local c = render:getEffectColor()
        local a = math.floor(c.a * 255)
        render:enableOutline(cc.c4b(color.r, color.g, color.b, a), render:getOutlineSize())
    end
end

function GUIEditor:SetUIColorOutlineC(uiWidget, widget)
    if self._selDescription == "Label" then
        local color = self._selWidget:getEffectColor()
        local hexColor = GetColorHexFromRBG(color)
        uiWidget:setString(supper(hexColor))

        self:SetUIOutlinePreview(color)
        self:SetUIOutlineBtnColor(hexColor)
    elseif self._selDescription == "Button" then
        local color = self._selWidget:getTitleRenderer():getEffectColor()
        local hexColor = GetColorHexFromRBG(color)
        uiWidget:setString(supper(hexColor))

        self:SetUIOutlinePreview(color)
        self:SetUIOutlineBtnColor(hexColor)
    end
end

function GUIEditor:SetColorInputPlaceHolder( value ) 
    self._selWidget:setPlaceholderFontColor(GetColorFromHexString(value))
end

function GUIEditor:SetUIColorInputPlaceHolder(uiWidget, widget)
    local color = widget:getPlaceholderFontColor()
    local hexColor = GetColorHexFromRBG(color)
    uiWidget:setString(hexColor)
    self:SetUIInputPlaceHolderPreview(color)
    self:SetUIInputPlaceHolderColor(hexColor)
end

function GUIEditor:SetOutlineWidth(value)
    if self._selDescription == "Label" then
        local render = self._selWidget
        local c = render:getEffectColor()
        render:enableOutline(cc.c4b(c.r, c.g, c.b, c.a), value)
    elseif self._selDescription == "Button" then
        local render = self._selWidget:getTitleRenderer()
        local c = render:getEffectColor()
        local r = math.floor(c.r * 255)
        local g = math.floor(c.g * 255)
        local b = math.floor(c.b * 255)
        local a = math.floor(c.a * 255)
        render:enableOutline(cc.c4b(r, g, b, a), value)
    end
end

function GUIEditor:SetUIOutlineWidth(uiWidget, widget)
    if self._selDescription == "Label" then
        uiWidget:setString(widget:getOutlineSize())
    elseif self._selDescription == "Button" then
        uiWidget:setString(widget:getTitleRenderer():getOutlineSize())
    end
end

function GUIEditor:SetMoreText(value)
    if self._selDescription == "Label" or self._selDescription == "BmpText" then
        local isMeta = GUI:Text_AutoUpdateMetaValue(self._selWidget, value)
        if isMeta then
            self:SetAttribeValue(self._selWidget, GUIAttributes.TEXT_METAVALUE, {Param2 = value})
        else
            self:NBEx(self._selWidget, GUIAttributes.TEXT_METAVALUE, {isNB = false})
            self._selWidget:setString(value)
        end
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "RText" then
        self:SetRTextAttribute("Text", value)
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUIEditor:SetUIMoreText(uiWidget, widget)
    if self._selDescription == "Label" then
        local data, isMeta = self:GetAttribeValue(widget, GUIAttributes.TEXT_METAVALUE)
        local text = isMeta and data.Param2 or widget:getString()
        uiWidget:setString(text)
    elseif self._selDescription == "BmpText" then
        uiWidget:setString(widget:getString())
    elseif self._selDescription == "RText" then
        self:SetRTextUIAttribute(uiWidget, widget, "Text")
    end
end

function GUIEditor:SetText(value)
    if self._selDescription == "Button" then
        self._selWidget:setTitleText(value)
    elseif self._selDescription == "EditBox" or self._selDescription == "TextField" then
        self._selWidget:setString(value)
    elseif self._selDescription == "TextAtlas" then
        local stringValue  = value
        local charMapFile  = self._selWidget:getCharMapFile()
        local itemWidth    = self._selWidget:getItemWidth()
        local itemHeight   = self._selWidget:getItemHeight()
        local startCharMap = self._selWidget:getStartCharMap()
        GUI:TextAtlas_setProperty(self._selWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)

        local isMeta = GUI:Text_AutoUpdateMetaValue(self._selWidget, value)
        if isMeta then
            self:SetAttribeValue(self._selWidget, GUIAttributes.TEXT_METAVALUE, {Param2 = value})
        else
            self:NBEx(self._selWidget, GUIAttributes.TEXT_METAVALUE, {isNB = false})
            self._selWidget:setString(value)
        end

        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUIEditor:SetUIText(uiWidget, widget)
    if self._selDescription == "Button" then
        uiWidget:setString(widget:getTitleText())
    elseif self._selDescription == "EditBox" or self._selDescription == "TextField" then
        uiWidget:setString(widget:getString())
    elseif self._selDescription == "TextAtlas" then
        local value = widget:getStringValue()
        uiWidget:setString(value)
    end
end

function GUIEditor:SetFontSize(value)
    if self._selDescription == "Label" then
        self._selWidget:setFontSize(value)
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "Button" then
        self._selWidget:setTitleFontSize(value)
    elseif self._selDescription == "EditBox" or self._selDescription == "TextField" then
        self._selWidget:setFontSize(value)
    elseif self._selDescription == "RText" then
        self:SetRTextAttribute("RSize", value)
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUIEditor:SetUIFontSize(uiWidget, widget)
    if self._selDescription == "Label" then
        uiWidget:setString(widget:getFontSize())
    elseif self._selDescription == "Button" then
        uiWidget:setString(widget:getTitleFontSize())
    elseif self._selDescription == "EditBox" or self._selDescription == "TextField" then
        uiWidget:setString(widget:getFontSize())
    elseif self._selDescription == "RText" then
        self:SetRTextUIAttribute(uiWidget, widget, "RSize")
    end
end

function GUIEditor:SetBtnNRes(res)
    self._selUISpecialControl["Button_N_Res"].__res__ = res
end

function GUIEditor:SetBtnPRes(res)
    self._selUISpecialControl["Button_P_Res"].__res__ = res
end

function GUIEditor:SetBtnDRes(res)
    self._selUISpecialControl["Button_D_Res"].__res__ = res
end

function GUIEditor:SetNorRes(str, inputType)
    str = (str ~= "" and fileUtil:isFileExist(str)) and str or " "
    self:SetBtnNRes(str)

    if self._selDescription == "Layout" or self._selDescription == "ListView" or self._selDescription == "ScrollView" or self._selDescription == "PageView" then
        self._selWidget:setBackGroundImage(str)
        if str == " " then
            self._selWidget:removeBackGroundImage()
        end
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "ImageView" then
        self._selWidget:loadTexture(str)
        if inputType then
            self._selWidget:ignoreContentAdaptWithSize(true)
        else
            self._selWidget:ignoreContentAdaptWithSize(false)
        end
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "Button" then
        self._selWidget:loadTextureNormal(str)
        if inputType then
            self._selWidget:ignoreContentAdaptWithSize(true)
        else
            self._selWidget:ignoreContentAdaptWithSize(false)
        end
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "LoadingBar" then
        self._selWidget:loadTexture(str)
        if inputType then
            self._selWidget:ignoreContentAdaptWithSize(true)
        else
            self._selWidget:ignoreContentAdaptWithSize(false)
        end
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "CheckBox" then
        self._selWidget:loadTextureBackGround(str)
        if inputType then
            self._selWidget:ignoreContentAdaptWithSize(true)
        else
            self._selWidget:ignoreContentAdaptWithSize(false)
        end
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "Slider" then
        self._selWidget:loadBarTexture(str)
        if inputType then
            self._selWidget:ignoreContentAdaptWithSize(true)
        else
            self._selWidget:ignoreContentAdaptWithSize(false)
        end
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "TextAtlas" then
        local stringValue  = self._selWidget:getStringValue()
        local charMapFile  = str
        local itemWidth    = self._selWidget:getItemWidth()
        local itemHeight   = self._selWidget:getItemHeight()
        local startCharMap = self._selWidget:getStartCharMap()
        GUI:TextAtlas_setProperty(self._selWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)

        if inputType then
            self._selWidget:ignoreContentAdaptWithSize(true)
        else
            self._selWidget:ignoreContentAdaptWithSize(false)
        end
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "RText" then
        self:SetRTextAttribute("RFace", str)
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUIEditor:SetPreRes(str)
    str = (str ~= "" and fileUtil:isFileExist(str)) and str or " "
    self:SetBtnPRes(str)

    if self._selDescription == "Button" then
        self._selWidget:loadTexturePressed(str)
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "CheckBox" then
        self._selWidget:loadTextureFrontCross(str)
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "Slider" then
        self._selWidget:loadProgressBarTexture(str)
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUIEditor:SetDisRes(str)
    str = (str ~= "" and fileUtil:isFileExist(str)) and str or " "
    self:SetBtnDRes(str)

    if self._selDescription == "Button" then
        self._selWidget:loadTextureDisabled(str)
        self._selWidget:resetDisabledRender()
        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "Slider" then
        self._selWidget:loadSlidBallTextureNormal(str)
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUIEditor:SetUINorRes(uiWidget, widget)
    if self._selDescription == "Button" or 
        self._selDescription == "ImageView" or 
            self._selDescription == "CheckBox" or 
                self._selDescription == "Slider" or 
                    self._selDescription == "Layout" or
                        self._selDescription == "LoadingBar" or
                            self._selDescription == "ListView" or
                                self._selDescription == "ScrollView" or 
                                    self._selDescription == "PageView" then
        local str = GUITXTEditorDefine.getResPath(widget, "N")
        str = (str ~= "" and fileUtil:isFileExist(str)) and str or " "
        uiWidget:setString(str)
        self:SetBtnNRes(str)
    elseif self._selDescription == "TextAtlas" then
        local charMapFile = widget:getCharMapFile()
        uiWidget:setString(charMapFile)
    elseif self._selDescription == "RText" then
        self:SetRTextUIAttribute(uiWidget, widget, "RFace")
    end
end

function GUIEditor:SetUIPreRes(uiWidget, widget)
    if self._selDescription == "Button" or self._selDescription == "CheckBox" or self._selDescription == "Slider" then
        local str = GUITXTEditorDefine.getResPath(widget, "P")
        str = (str ~= "" and fileUtil:isFileExist(str)) and str or " "
        uiWidget:setString(str)
        self:SetBtnPRes(str)
    end
end

function GUIEditor:SetUIDisRes(uiWidget, widget)
    if self._selDescription == "Button" or self._selDescription == "Slider" then
        local str = GUITXTEditorDefine.getResPath(widget, "D")
        str = (str ~= "" and fileUtil:isFileExist(str)) and str or " "
        uiWidget:setString(str)
        self:SetBtnDRes(str)
    end
end

function GUIEditor:SetCapInsetL(value)
    local rect = self:getCapInset()
    rect.l = value
    self:setCapInsetValue(self._selWidget, self._selDescription, rect)
end

function GUIEditor:SetCapInsetR(value)
    local rect = self:getCapInset()
    rect.r = value
    self:setCapInsetValue(self._selWidget, self._selDescription, rect)
end

function GUIEditor:SetCapInsetT(value)
    local rect = self:getCapInset()
    rect.t = value
    self:setCapInsetValue(self._selWidget, self._selDescription, rect)
end

function GUIEditor:SetCapInsetB(value)
    local rect = self:getCapInset()
    rect.b = value
    self:setCapInsetValue(self._selWidget, self._selDescription, rect)
end

function GUIEditor:SetUICapInsetL(uiWidget, widget)
    local rect = self:getCapInset()
    uiWidget:setString(rect.l)
end

function GUIEditor:SetUICapInsetR(uiWidget, widget)
    local rect = self:getCapInset()
    uiWidget:setString(rect.r)
end

function GUIEditor:SetUICapInsetT(uiWidget, widget)
    local rect = self:getCapInset()
    uiWidget:setString(rect.t)
end

function GUIEditor:SetUICapInsetB(uiWidget, widget)
    local rect = self:getCapInset()
    uiWidget:setString(rect.b)
end

function GUIEditor:SetInputPlaceholder(value)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        self._selWidget:setPlaceHolder(value)
    end
end

function GUIEditor:SetUIInputPlaceholder(uiWidget, widget)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        uiWidget:setString(widget:getPlaceHolder())
    end
end

function GUIEditor:SetInputMaxLenth(value)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        self._selWidget:setMaxLength(value)
    end
end

function GUIEditor:SetUIInputMaxLenth(uiWidget, widget)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        uiWidget:setString(widget:getMaxLength())
    end
end

function GUIEditor:SetInputType(value)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        self._selWidget:setInputMode(value)
    end
end

function GUIEditor:SetUIInputType(uiWidget, widget)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        uiWidget:setString(widget:getInputMode())
    end
end

function GUIEditor:SetBgTextOpacity(value)
    local bgOpacity = math.floor(value / 100 * 255)
    self._selWidget:setBackGroundColorOpacity(bgOpacity)
    self._selUISpecialControl["Slider_Bg_Opacity"]:setPercent(value)
end

-- Model
function GUIEditor:SetModelAttribute(key, value)
    local model = self._selWidget:getChildByName("__MODEL__")
    if model then
        model:removeFromParent()
    end
    
    self:SetAttribute(GUIAttributes.MODEL, key, value)
    self:CreateModel(self._selWidget)
end

function GUIEditor:SetSex(value)
    if self._selDescription == "Effect" then
        self:SetEffectAttribute("sex", value)
    elseif self._selDescription == "Model" then
        self:SetModelAttribute("sex", value)
    end
end

function GUIEditor:SetUISex(uiWidget, widget)
    if self._selDescription == "Effect" then
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "sex")
    elseif self._selDescription == "Model" then
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "sex")
    end
end

function GUIEditor:SetMScale(value)
    self:SetModelAttribute("scale", value)
end

function GUIEditor:SetUIMScale(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "scale")
end

function GUIEditor:SetHairID(value)
    self:SetModelAttribute("hairID", value)
end

function GUIEditor:SetUIHairID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "hairID")
end

function GUIEditor:SetHeadID(value)
    self:SetModelAttribute("headID", value)
end

function GUIEditor:SetUIHeadID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "headID")
end

function GUIEditor:SetHeadEffID(value)
    self:SetModelAttribute("headEffectID", value)
end

function GUIEditor:SetUIHeadEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "headEffectID")
end

function GUIEditor:SetClothID(value)
    self:SetModelAttribute("clothID", value)
end

function GUIEditor:SetUIClothID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "clothID")
end

function GUIEditor:SetClothEffID(value)
    self:SetModelAttribute("clothEffectID", value)
end

function GUIEditor:SetUIClothEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "clothEffectID")
end

function GUIEditor:SetWeaponID(value)
    self:SetModelAttribute("weaponID", value)
end

function GUIEditor:SetUIWeaponID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "weaponID")
end

function GUIEditor:SetWeaponEffID(value)
    self:SetModelAttribute("weaponEffectID", value)
end

function GUIEditor:SetUIWeaponEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "weaponEffectID")
end

function GUIEditor:SetShieldID(value)
    self:SetModelAttribute("shieldID", value)
end

function GUIEditor:SetUIShieldID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "shieldID")
end

function GUIEditor:SetShieldEffID(value)
    self:SetModelAttribute("shieldEffectID", value)
end

function GUIEditor:SetUIShieldEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "shieldEffectID")
end

function GUIEditor:SetCapID(value)
    self:SetModelAttribute("capID", value)
end

function GUIEditor:SetUICapID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "capID")
end

function GUIEditor:SetCapEffID(value)
    self:SetModelAttribute("capEffectID", value)
end

function GUIEditor:SetUICapEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "capEffectID")
end

function GUIEditor:SetVeilID(value)
    self:SetModelAttribute("veilID", value)
end

function GUIEditor:SetUIVeilID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "veilID")
end

function GUIEditor:SetVeilEffID(value)
    self:SetModelAttribute("veilEfffectID", value)
end

function GUIEditor:SetUIVeilEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "veilEfffectID")
end

function GUIEditor:onShowMoldEvent(ref)
    self:SetModelAttribute("notShowMold", ref:isSelected())
end

function GUIEditor:SetUIShowMold(uiWidget, widget)
    local data = self:GetAttribeValue(widget, GUIAttributes.MODEL)
    local isSelect = not GUIHelper:GetStatus(data["notShowMold"], false)
    uiWidget:setSelected(isSelect)
end

function GUIEditor:onShowHairEvent(ref)
    self:SetModelAttribute("notShowHair", ref:isSelected())
end

function GUIEditor:SetUIShowHair(uiWidget, widget)
    local data = self:GetAttribeValue(widget, GUIAttributes.MODEL)
    local isSelect = not GUIHelper:GetStatus(data["notShowHair"], false)
    uiWidget:setSelected(isSelect)
end

-- 背景透明度
function GUIEditor:SetUITextBgOpacity(uiWidget, widget)
    local bgOpacity = widget:getBackGroundColorOpacity()
    uiWidget:setString(math.floor(bgOpacity / 255 * 100))
end

-- 透明度 Slider
function GUIEditor:SetUISliderBgOpacity(uiWidget, widget)
    local bgOpacity = widget:getBackGroundColorOpacity()
    uiWidget:setPercent(math.floor(bgOpacity / 255 * 100))
end

function GUIEditor:SetUIDirection(uiWidget, widget)
    if self._selDescription == "ListView" or self._selDescription == "ScrollView" then
        uiWidget:setSelected(widget:getDirection() == 2)
    end
end

function GUIEditor:SetAlignment(value)
    if self._selDescription == "ListView" then
        self._selWidget:setGravity(value)
        self._selWidget:jumpToBottom()
    end
end

function GUIEditor:SetUIAlignment(uiWidget, widget)
    if self._selDescription == "ListView" then
        uiWidget:setString(widget:getGravity())
    end
end

function GUIEditor:SetMargin(value)
    if self._selDescription == "ListView" then
        self._selWidget:setItemsMargin(value)
        self._selWidget:jumpToBottom()
    end
end

function GUIEditor:SetUIMargin(uiWidget, widget)
    if self._selDescription == "ListView" then
        uiWidget:setString(widget:getItemsMargin())
    end
end

function GUIEditor:SetInnerWidth(value)
    if self._selDescription == "ScrollView" then
        self._selWidget:setInnerContainerSize(cc.size(sformat("%.2f", value), sformat("%.2f", self._selWidget:getInnerContainerSize().height)))
        if self._selWidget.___DRAWNODE___ then
            self._selWidget.___DRAWNODE___:setPositionX(0)
            self._selWidget.___TOUCHLAYOUT___:setPositionX(0)
        end
    end
end

function GUIEditor:SetInnerHeight(value)
    if self._selDescription == "ScrollView" then
        self._selWidget:setInnerContainerSize(cc.size(sformat("%.2f", self._selWidget:getInnerContainerSize().width), sformat("%.2f", value)))
        if self._selWidget.___DRAWNODE___ then
            local y = self._selWidget:getInnerContainerSize().height - self._selWidget:getContentSize().height
            self._selWidget.___DRAWNODE___:setPosition(cc.p(0, math.max(y, 0)))
            self._selWidget.___TOUCHLAYOUT___:setPosition(cc.p(0, math.max(y, 0)))
        end
    end
end

function GUIEditor:SetUIInnerWidth(uiWidget, widget)
    if self._selDescription == "ScrollView" then
        uiWidget:setString(sformat("%.2f", widget:getInnerContainerSize().width))
    end
end

function GUIEditor:SetUIInnerHeight(uiWidget, widget)
    if self._selDescription == "ScrollView" then
        uiWidget:setString(sformat("%.2f", widget:getInnerContainerSize().height))
    end
end

-- 九宫格
function GUIEditor:SetUICapInset(uiWidget, widget)
    if self._selDescription == "Layout" or self._selDescription == "ListView" or self._selDescription == "ScrollView" or self._selDescription == "PageView" then
        local enable = widget:isBackGroundImageScale9Enabled()
        uiWidget:setSelected(enable)
        self:setCapInset(enable)
    elseif self._selDescription == "Button" or self._selDescription == "ImageView" then
        local enable = widget:isScale9Enabled()
        uiWidget:setSelected(enable)
        self:setCapInset(enable)
    end
end

-- 文本自定义尺寸
function GUIEditor:SetUITextCustomSize(uiWidget, widget)
    if not self._selDescription == "Label" then
        return false
    end

    local enable = not widget:isIgnoreContentAdaptWithSize()
    uiWidget:setSelected(enable)
end

-- 文本描边
function GUIEditor:SetUITextOutline(uiWidget, widget)
    if not (self._selDescription == "Label" or self._selDescription == "Button") then
        return false
    end
    
    local render = widget
    if self._selDescription == "Button" then
        render = widget:getTitleRenderer()
    end

    local enable = self:IsOutline(render)
    uiWidget:setSelected(enable)
    self:setOutlineState(enable)
end

-- 回弹
function GUIEditor:SetUIRebound(uiWidget, widget)
    uiWidget:setSelected(widget:isBounceEnabled())
end

-- 选中状态
function GUIEditor:SetUICboxSelect(uiWidget, widget)
    uiWidget:setSelected(widget:isSelected())
end

-- LoadingBar 方向
function GUIEditor:SetUILBarLeft(uiWidget, widget)
    uiWidget:setSelected(widget:getDirection() == ccui.LoadingBarDirection.RIGHT)
end

-- 剪裁
function GUIEditor:SetUIClip(uiWidget, widget)
    uiWidget:setSelected(widget:isClippingEnabled())
end

-- 背景填充
function GUIEditor:SetUIBgtc(uiWidget, widget)
    local isTc = widget:getBackGroundColorType() ~= 0
    uiWidget:setSelected(isTc)
    self:setBgtc(isTc)
end

-- 特效播放
function GUIEditor:SetUIEffectPlay(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EFFECT, "loop")
end

function GUIEditor:SetUIItemLook(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "look")
end

function GUIEditor:SetUIItemShowBg(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "bgVisible")
end

function GUIEditor:SetUIItemShowNum(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "disShowCount")
end

function GUIEditor:SetUIItemShowStar(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "starLv")
end

function GUIEditor:SetUIItemShowMask(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "notShowEquipRedMask")
end

function GUIEditor:SetUIItemShowPowerC(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "checkPower")
end

function GUIEditor:SetUIItemShowEffect(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "isShowEff")
end

function GUIEditor:SetUIItemShowModelEffect(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "showModelEffect")
end

---EquipShow
function GUIEditor:SetUIEquipLook(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "look")
end

function GUIEditor:SetUIEquipShowBg(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "bgVisible")
end

function GUIEditor:SetUIEquipShowStar(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "starLv")
end

function GUIEditor:SetUIEquipShowPowerC(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "checkPower")
end

function GUIEditor:SetUIEquipAutoUpdate(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "autoUpdate")
end

function GUIEditor:SetUIEquipIsHero(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "isHero")
end

function GUIEditor:SetUIEquipOnDouble(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "doubleTakeOff")
end

function GUIEditor:SetUIEquipOnMove(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "movable")
end

function GUIEditor:SetUIEquipIsLookPlayer(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "lookPlayer")
end

-- Input 默认值------------------------------------------------------------------------------------------------------
function GUIEditor:GetPosX()
    if self._selWidget then
        return sformat("%.2f", self._selWidget:getPositionX())
    end
    return 0.00
end

function GUIEditor:GetPosY()
    if self._selWidget then
        return sformat("%.2f", self._selWidget:getPositionY())
    end
    return 0.00
end

function GUIEditor:GetRotate()
    if self._selWidget then
        return sformat("%.2f", self._selWidget:getRotation())
    end
    return 0.00
end

-- Common Attr------------------------------------------------------------------------------------------------------
function GUIEditor:SetName(str)
    if slen(str) > 0 and str ~= self._selWidget:getName() then
        self:updateTreeName(str)

        local chinesename = GUI:getChineseName(self._selWidget)
        if chinesename and chinesename ~= "" then
            return false
        end

        local TextTreeName = self._selTreeNode and self._selTreeNode.TextTreeName
        if TextTreeName then
            TextTreeName:setString(str)
        end
    end
end

function GUIEditor:SetUIName(uiWidget, widget)
    uiWidget:setString(widget:getName())
end

function GUIEditor:SetSliderText(value)
    if self._selDescription == "Slider" or self._selDescription == "LoadingBar" then
        self._selWidget:setPercent(math.floor(value))
        self._selUISpecialControl["Slider_Progress"]:setPercent(value)
    end
end

function GUIEditor:SetUISliderProgress(uiWidget, widget)
    local precent = widget:getPercent()
    uiWidget:setPercent(math.floor(precent))
end

function GUIEditor:SetUISliderText(uiWidget, widget)
    if self._selDescription == "Slider" or self._selDescription == "LoadingBar" then
        uiWidget:setString(widget:getPercent())
    end
end

function GUIEditor:SetNameTip(str)
    if slen(str) > 0 and str ~= GUI:getChineseName(self._selWidget) then
        local TextTreeName = self._selTreeNode and self._selTreeNode.TextTreeName
        if TextTreeName then
            TextTreeName:setString(str)
        end
        GUI:setChineseName(self._selWidget, str)
    end
end

function GUIEditor:SetUINameTip(uiWidget, widget)
    uiWidget:setString(GUI:getChineseName(widget))
end

function GUIEditor:SetAnrX(value)
    self._selWidget:setAnchorPoint(cc.p(value, self._selWidget:getAnchorPoint().y))
end

function GUIEditor:SetUIAnrX(uiWidget, widget)
    local value = sformat("%.2f", widget:getAnchorPoint().x)
    uiWidget:setString(value)
end

function GUIEditor:SetAnrY(value)
    self._selWidget:setAnchorPoint(cc.p(self._selWidget:getAnchorPoint().x, value))
end

function GUIEditor:SetUIAnrY(uiWidget, widget)
    local value = sformat("%.2f", widget:getAnchorPoint().y)
    uiWidget:setString(value)
end

function GUIEditor:SetPosX(value)
    local flag = self._selUICommonControl["Text_unit_x"]:getTag()
    if flag == 2 then
        local parent = self._selWidget:getParent()
        local width  = parent and parent:getContentSize().width or 0

        local x = sformat("%.2f", width * value / 100)
        self._selWidget:setPositionX(x)
    else
        self._selWidget:setPositionX(value)
    end
end

function GUIEditor:SetUIPosX(uiWidget, widget)
    local flag = self._selUICommonControl["Text_unit_x"]:getTag()
    if flag == 2 then
        local parent = widget:getParent()
        local width  = parent and parent:getContentSize().width or 0

        local x = widget:getPositionX()
        local value = width > 0 and sformat("%.2f", x / width * 100) or 0

        uiWidget:setString(value)
    else
        local value = sformat("%.2f", widget:getPositionX())
        uiWidget:setString(value)
    end
end

function GUIEditor:SetPosY(value)
    local flag = self._selUICommonControl["Text_unit_y"]:getTag()
    if flag == 2 then
        local parent = self._selWidget:getParent()
        local height = parent and parent:getContentSize().height or 0

        local y = sformat("%.2f", height * value / 100)
        self._selWidget:setPositionY(y)
    else
        self._selWidget:setPositionY(value)
    end
end

function GUIEditor:SetUIPosY(uiWidget, widget)
    local flag = self._selUICommonControl["Text_unit_y"]:getTag()
    if flag == 2 then
        local parent = widget:getParent()
        local height = parent and parent:getContentSize().height or 0

        local y = widget:getPositionY()
        local value = height > 0 and sformat("%.2f", y / height * 100) or 0

        uiWidget:setString(value)
    else
        local value = sformat("%.2f", widget:getPositionY())
        uiWidget:setString(value)
    end
end

function GUIEditor:SetWidth(value)
    local width, height = value, self._selWidget:getContentSize().height
    self._selWidget:setContentSize(cc.size(width, height))
    if self._selDescription == "ImageView" or self._selDescription == "LoadingBar" or self._selDescription == "Button" or self._selDescription == "CheckBox" or self._selDescription == "Slider" then
        self._selWidget:ignoreContentAdaptWithSize(false)
    elseif self._selDescription == "RText" then
        self:SetRTextAttribute("Width", width)
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
    self:resetDrawRect()
end

function GUIEditor:SetUIWidth(uiWidget, widget)
    if self._selDescription == "RText" then
        self:SetRTextUIAttribute(uiWidget, widget, "Width")
    else
        local value = sformat("%.2f", widget:getContentSize().width)
        uiWidget:setString(value)
    end
end

function GUIEditor:SetHeight(value)
    local width, height = self._selWidget:getContentSize().width, value
    self._selWidget:setContentSize(cc.size(width, height))
    if self._selDescription == "ImageView" or self._selDescription == "LoadingBar" or self._selDescription == "Button" or self._selDescription == "CheckBox"or self._selDescription == "Slider" then
        self._selWidget:ignoreContentAdaptWithSize(false)
    end
    self:resetDrawRect()
end

function GUIEditor:SetUIHeight(uiWidget, widget)
    local value = sformat("%.2f", widget:getContentSize().height)
    uiWidget:setString(value)
end

function GUIEditor:SetTag(value)
    self._selWidget:setTag(value)
end

function GUIEditor:SetUITag(uiWidget, widget)
    local value = widget:getTag()
    uiWidget:setString(value)
end

function GUIEditor:SetRotate(value)
    self._selWidget:setRotation(value)
end

function GUIEditor:SetUIRotate(uiWidget, widget)
    local value = sformat("%.2f", widget:getRotation())
    uiWidget:setString(value)
end

function GUIEditor:SetScaleX(value)
    self._selWidget:setScaleX(sformat("%.2f", value / 100))
end

function GUIEditor:SetUIScaleX(uiWidget, widget)
    local value = sformat("%.2f", widget:getScaleX() * 100)
    uiWidget:setString(value)
end

function GUIEditor:SetScaleY(value)
    self._selWidget:setScaleY(sformat("%.2f", value / 100))
end

function GUIEditor:SetUIScaleY(uiWidget, widget)
    local value = sformat("%.2f", widget:getScaleY() * 100)
    uiWidget:setString(value)
end

function GUIEditor:SetOpacity(value)
    local opacity = math.floor(value / 100 * 255)
    self._selWidget:setOpacity(opacity)
    self._selUICommonControl["Slider_Opacity"]:setPercent(opacity)
    self:updateNodeOpacity(value)
end

function GUIEditor:SetUIOpacity(uiWidget, widget)
    local opacity = widget:getOpacity()
    opacity = math.min(math.ceil(opacity / 255 * 100), 100)
    self._selUICommonControl["Slider_Opacity"]:setPercent(opacity)
    uiWidget:setString(opacity)
end

function GUIEditor:SetUIVisible(uiWidget, widget)
    uiWidget:setSelected(widget:isVisible())
end

function GUIEditor:SetUITouched(uiWidget, widget)
    uiWidget:setSelected(widget:isTouchEnabled())
end

function GUIEditor:SetEffectAttribute(key, value)
    local sfx = self._selWidget:getChildByName("__SFX__")
    if sfx then
        sfx:removeFromParent()
    end
    
    self:SetAttribute(GUIAttributes.EFFECT, key, value)
    self:CreateEffect(self._selWidget)
end

function GUIEditor:SetEffectID(value)
    self:SetEffectAttribute("sfxID", value)
end

function GUIEditor:SetUIEffectID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "sfxID")
end

function GUIEditor:SetEffectAction(value)
    self:SetEffectAttribute("act", value)
end

function GUIEditor:SetUIEffectAction(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "act")
end

function GUIEditor:SetEffectType(value)
    self:SetEffectAttribute("type", value)
end

function GUIEditor:SetUIEffectType(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "type")
end

function GUIEditor:SetEffectDir(value)
    self:SetEffectAttribute("dir", value)
end

function GUIEditor:SetUIEffectDir(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "dir")
end

function GUIEditor:SetEffectSpeed(value)
    self:SetEffectAttribute("speed", value)
end

function GUIEditor:SetUIEffectSpeed(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "speed")
end

function GUIEditor:SetFristChat(value)
    local stringValue  = self._selWidget:getStringValue()
    local charMapFile  = self._selWidget:getCharMapFile()
    local itemWidth    = self._selWidget:getItemWidth()
    local itemHeight   = self._selWidget:getItemHeight()
    local startCharMap = value
    GUI:TextAtlas_setProperty(self._selWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
end

function GUIEditor:SetUIFristChat(uiWidget, widget)
    local startCharMap = widget:getStartCharMap()
    uiWidget:setString(startCharMap)
end

function GUIEditor:SetChatWidth(value)
    local stringValue  = self._selWidget:getStringValue()
    local charMapFile  = self._selWidget:getCharMapFile()
    local itemWidth    = value
    local itemHeight   = self._selWidget:getItemHeight()
    local startCharMap = self._selWidget:getStartCharMap()
    GUI:TextAtlas_setProperty(self._selWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)

    self:resetDrawRect()
    self:setCommonAttrUI()
end

function GUIEditor:SetUIChatWidth(uiWidget, widget)
    local itemWidth = widget:getItemWidth()
    uiWidget:setString(itemWidth)
end

function GUIEditor:SetChatHeight(value)
    local stringValue  = self._selWidget:getStringValue()
    local charMapFile  = self._selWidget:getCharMapFile()
    local itemWidth    = self._selWidget:getItemWidth()
    local itemHeight   = value
    local startCharMap = self._selWidget:getStartCharMap()
    GUI:TextAtlas_setProperty(self._selWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
end

function GUIEditor:SetUIChatHeight(uiWidget, widget)
    local itemHeight = widget:getItemHeight()
    uiWidget:setString(itemHeight)
end

function GUIEditor:SetRTextSpace(value)
    self:SetRTextAttribute("RSpace", value)
    self:resetDrawRect()
    self:setCommonAttrUI()
end

function GUIEditor:SetUIRTextSpace(uiWidget, widget)
    self:SetRTextUIAttribute(uiWidget, widget, "RSpace")
end

function GUIEditor:SetItemAttribute(key, value)
    local item = self._selWidget:getChildByName("__ITEM__")
    if item then
        item:removeFromParent()
    end

    self:SetAttribute(GUIAttributes.ITEM_SHOW, key, value)
    self:CreateItemShow(self._selWidget)
end

local ItemAttrDefault = {
    ["countFontSize"] = 15, ["color"] = "#FFFFFF", ["from"] = 0
}

function GUIEditor:SetItemUIAttribute(uiWidget, widget, key)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.ITEM_SHOW)
    local value = data[key]
    value = (not value and ItemAttrDefault[key]) and ItemAttrDefault[key] or value
    uiWidget:setString(value)
end

function GUIEditor:SetItemID(value)
    self:SetItemAttribute("index", value)
end

function GUIEditor:SetUIItemID(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "index")
end

function GUIEditor:SetItemNum(value)
    self:SetItemAttribute("count", value)
end

function GUIEditor:SetUIItemNum(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "count")
end

function GUIEditor:SetItemFrom(value)
    self:SetItemAttribute("from", value)
end

function GUIEditor:SetUIItemFrom(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "from")
end

function GUIEditor:SetItemFontSize(value)
    self:SetItemAttribute("countFontSize", value)
end

function GUIEditor:SetUIItemFontSize(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "countFontSize")
end

function GUIEditor:SetItemFontColor(value)
    self:SetItemAttribute("color", value)
end

function GUIEditor:SetUIItemFontColor(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "color")
end

function GUIEditor:SetMessageUIAttribute(uiWidget, widget, key)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.MESSAGE)
    uiWidget:setString(data[key])
end

function GUIEditor:SetMsgText(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "MsgData", value)
end

function GUIEditor:SetUIMsgText(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "MsgData")
end

function GUIEditor:SetMsgID(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "MsgID", value)
end

function GUIEditor:SetUIMsgID(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "MsgID")
end

function GUIEditor:SetMsgParam1(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "Param1", value)
end

function GUIEditor:SetUIMsgParam1(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "Param1")
end

function GUIEditor:SetMsgParam2(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "Param2", value)
end

function GUIEditor:SetUIMsgParam2(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "Param2")
end

function GUIEditor:SetMsgParam3(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "Param3", value)
end

function GUIEditor:SetUIMsgParam3(uiWidget, widget)
    if self._selDescription == "CheckBox" then
        local selected = self._selWidget:isSelected()

        local key   = GUIAttributes.MESSAGE
        local key2  = "Param3"
        local value = selected and 1 or 0
        self:SetAttribute(key, key2, value)

        uiWidget:setString(value)
    else
        self:SetMessageUIAttribute(uiWidget, widget, "Param3")
    end
end

function GUIEditor:SetClickFunc(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "FuncBody", value)
end

function GUIEditor:SetUIClickFunc(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "FuncBody")
end

function GUIEditor:SetUILuaMsg(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.MESSAGE, "IsLuaMsg")
end

function GUIEditor:SetUIClick(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.MESSAGE, "IsClick")
end

function GUIEditor:SetUISwallow(uiWidget, widget)
    if self._selDescription == "Item" then
        self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.SWALLOW, "Param2")
    else
        uiWidget:setSelected(widget:isSwallowTouches())
    end
end

function GUIEditor:SetUICipher(uiWidget, widget)
    uiWidget:setSelected(widget:getInputFlag() == 0)
end

-- Common event
function GUIEditor:onSliderOpacityEvent(ref)
    local percent = ref:getPercent()
    self._selUICommonControl["TextField_Opacity"]:setString(percent)

    local opacity = math.floor(percent / 100 * 255)
    self._selWidget:setOpacity(opacity)
    self:updateNodeOpacity(opacity)
end

-- Special event
function GUIEditor:onSliderBgOpacityEvent(ref)
    if self._selWidget then
        local percent = ref:getPercent()
        self._selUISpecialControl["TextField_Bg_Opacity"]:setString(percent)
        self._selWidget:setBackGroundColorOpacity(math.floor(percent / 100 * 255))
    end
end

function GUIEditor:onLuaMsgEvent(ref)
    if self._selWidget then
        self:SetAttribute(GUIAttributes.MESSAGE, "IsLuaMsg", not ref:isSelected())
    end
end

function GUIEditor:onClickEvent(ref)
    if self._selWidget then
        self:SetAttribute(GUIAttributes.MESSAGE, "IsClick", not ref:isSelected())
    end
end

function GUIEditor:onItemSwallowEvent(ref)
    if self._selWidget then
        if self._selDescription == "Item" then
            self:SetAttribute(GUIAttributes.SWALLOW, "Param2", not ref:isSelected())
        else
            self._selWidget:setSwallowTouches(not self._selWidget:isSwallowTouches())
        end
    end
end

function GUIEditor:onChangePosXInputMethod(ref, eventType)
    if eventType ~= 2 then
        return false
    end

    local strs = {
        [1] = " % ", [2] = "像素"
    }

    local tags = {
        [1] = 2, [2] = 1
    }

    local tag = ref:getTag()
    
    ref:setString(strs[tag])
    
    ref:setTag(tags[tag])

    if tag == 1 then
        local parent = self._selWidget:getParent()
        local width  = parent and parent:getContentSize().width or 0

        local x = self._selWidget:getPositionX()
        local value = width > 0 and sformat("%.2f", x / width * 100) or 0

        self._selUICommonControl["TextField_PosX"]:setString(value)
    else
        self._selUICommonControl["TextField_PosX"]:setString(sformat("%.2f", self._selWidget:getPositionX()))
    end
end

function GUIEditor:onChangePosYInputMethod(ref, eventType)
    if eventType ~= 2 then
        return false
    end

    local strs = {
        [1] = " % ", [2] = "像素"
    }

    local tags = {
        [1] = 2, [2] = 1
    }

    local tag = ref:getTag()
    
    ref:setString(strs[tag])
    
    ref:setTag(tags[tag])

    if tag == 1 then
        local parent = self._selWidget:getParent()
        local height = parent and parent:getContentSize().height or 0

        local x = self._selWidget:getPositionY()
        local value = height > 0 and sformat("%.2f", x / height * 100) or 0

        self._selUICommonControl["TextField_PosY"]:setString(value)
    else
        self._selUICommonControl["TextField_PosY"]:setString(sformat("%.2f", self._selWidget:getPositionY()))
    end
end

function GUIEditor:onLBarSliderEvent(ref)
    if self._selWidget then
        local progress = ref:getPercent()
        self._selUISpecialControl["TextField_Progress"]:setString(progress)
        self._selWidget:setPercent(progress)
    end
end

function GUIEditor:onLBarCheckBoxEvent(ref)
    if self._selWidget then
        local isSelect = ref:isSelected()
        if isSelect then
            self._selWidget:setDirection(ccui.LoadingBarDirection.LEFT)
        else
            self._selWidget:setDirection(ccui.LoadingBarDirection.RIGHT)
        end
    end
end

function GUIEditor:onDirCheckBoxEvent(ref)
    if self._selWidget then
        local isSelect = ref:isSelected()
        if isSelect then
            self._selWidget:setDirection(1)
            if self._selDescription == "ListView" then
                self._selWidget:setGravity(0)
                if self._selUISpecialControl["TextField_Alignment"] then
                    self._selUISpecialControl["TextField_Alignment"]:setString(0)
                end
            end
        else
            self._selWidget:setDirection(2)
            if self._selDescription == "ListView" then
                self._selWidget:setGravity(3)
                if self._selUISpecialControl["TextField_Alignment"] then
                    self._selUISpecialControl["TextField_Alignment"]:setString(3)
                end
            end
        end
    end
end

function GUIEditor:onUICheckBoxSelectEvent(ref)
    if self._selWidget then
        local selected = self._selWidget:isSelected()
        self._selWidget:setSelected(not selected)

        local key   = GUIAttributes.MESSAGE
        local key2  = "Param3"
        local value = selected and 0 or 1
        self:SetAttribute(key, key2, value)
    end
end

function GUIEditor:onResNSetCallFunc(res)
    if self._selUISpecialControl["TextField_N_Res"] then
        self._SpecialAttr["TextField_N_Res"].SetWidget(res, 1)
        self._SpecialAttr["TextField_N_Res"].SetUIWidget(self._selUISpecialControl["TextField_N_Res"], self._selWidget)

        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUIEditor:onResPSetCallFunc(res)
    if self._selUISpecialControl["TextField_P_Res"] then
        self._SpecialAttr["TextField_P_Res"].SetWidget(res, 1)
        self._SpecialAttr["TextField_P_Res"].SetUIWidget(self._selUISpecialControl["TextField_P_Res"], self._selWidget)

        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUIEditor:onResDSetCallFunc(res)
    if self._selUISpecialControl["TextField_D_Res"] then
        self._SpecialAttr["TextField_D_Res"].SetWidget(res, 1)
        self._SpecialAttr["TextField_D_Res"].SetUIWidget(self._selUISpecialControl["TextField_D_Res"], self._selWidget)

        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

-- 打开资源选择界面
function GUIEditor:onOpenGUIResSelector(ref)
    releaseLayerGUI("GUIResSelector")
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, {res = ref.__res__, callfunc = self._SpecialAttr[ref:getName()].callfunc})
end

-- 是否设置剪裁
function GUIEditor:onClipEvent()
    if self._selWidget then
        self._selWidget:setClippingEnabled(not self._selWidget:isClippingEnabled())
    end
end

-- 是否开启回弹
function GUIEditor:onReboundEvent()
    if self._selWidget then
        self._selWidget:setBounceEnabled(not self._selWidget:isBounceEnabled())
    end
end

function GUIEditor:onClipEvent()
    if self._selWidget then
        self._selWidget:setClippingEnabled(not self._selWidget:isClippingEnabled())
    end
end

-- 是否背景填充
function GUIEditor:onBgtcEvent()
    if self._selWidget then
        local clipType = self._selWidget:getBackGroundColorType()
        clipType = clipType == 0 and 1 or 0
        self._selWidget:setBackGroundColorType(clipType)
        self:setBgtc(clipType ~= 0)
    end
end

-- 是否九宫格
function GUIEditor:onCapInsetEvent()
    if self._selWidget then
        local enable = false
        if self._selDescription == "Layout" or self._selDescription == "ListView" or self._selDescription == "ScrollView" or self._selDescription == "PageView" then
            enable = not self._selWidget:isBackGroundImageScale9Enabled()
            self._selWidget:setBackGroundImageScale9Enabled(enable)
        elseif self._selDescription == "Button" or self._selDescription == "ImageView" then
            enable = not self._selWidget:isScale9Enabled()
            self._selWidget:setScale9Enabled(enable)
        end
        self:setCapInset(enable)
    end
end

-- 可见性
function GUIEditor:onIsVisibleEvent()
    self._selWidget:setVisible(not self._selWidget:isVisible())
end

-- 触摸
function GUIEditor:onIsTouchedEvent()
    self._selWidget:setTouchEnabled(not self._selWidget:isTouchEnabled())
end

-- 是否描边
function GUIEditor:onTextOutlineEvent()
    if not (self._selDescription == "Label" or self._selDescription == "Button") then
        return false
    end

    local isBtn  = self._selDescription == "Button"
    local render = isBtn and self._selWidget:getTitleRenderer() or self._selWidget 

    local enable = self:IsOutline(render)
    if enable then
        if isBtn then
            render:disableEffect(1)
        else
            render:getVirtualRenderer():disableEffect(1)
        end
    else
        local c = render:getEffectColor()
        local r = isBtn and math.floor(c.r * 255) or c.r
        local g = isBtn and math.floor(c.g * 255) or c.g
        local b = isBtn and math.floor(c.b * 255) or c.b
        local a = isBtn and math.floor(c.a * 255) or c.a
        render:enableOutline(cc.c4b(r, g, b, a), render:getOutlineSize())
    end
    self:setOutlineState(not enable)
end

-- 文本是否自定义尺寸
function GUIEditor:onTextCustomSizeEvent()
    if not self._selWidget then
        return false
    end
    
    self:setIgnoreSize(true)
    self:resetDrawRect()
    self:setCommonAttrUI()
end

function GUIEditor:onCipherEvent()
    local inputFlag = self._selWidget:getInputFlag()
    if inputFlag == 0 then
        self._selWidget:setInputFlag(6)
    else
        self._selWidget:setInputFlag(0)
    end

    local text = self._selWidget:getString()
    self._selWidget:setString(text)
end

-- 特效是否循环播放
function GUIEditor:onEffectPlayEvent(ref)
    self:SetEffectAttribute("loop", not ref:isSelected())
end

function GUIEditor:onItemLookEvent(ref)
    self:SetItemAttribute("look", not ref:isSelected())
end

function GUIEditor:onItemShowBgEvent(ref)
    self:SetItemAttribute("bgVisible", not ref:isSelected())
end

function GUIEditor:onItemShowNumEvent(ref)
    self:SetItemAttribute("disShowCount", not ref:isSelected())
end

function GUIEditor:onItemShowStarEvent(ref)
    self:SetItemAttribute("starLv", not ref:isSelected())
end

function GUIEditor:onItemShowMaskEvent(ref)
    self:SetItemAttribute("notShowEquipRedMask", not ref:isSelected())
end

function GUIEditor:onItemShowPowerCEvent(ref)
    self:SetItemAttribute("checkPower", not ref:isSelected())
end

function GUIEditor:onItemShowEffectEvent(ref)
    self:SetItemAttribute("isShowEff", not ref:isSelected())
end

function GUIEditor:onItemShowModelEffectEvent(ref)
    self:SetItemAttribute("showModelEffect", not ref:isSelected())
end

-- EquipShow
function GUIEditor:SetEquipAttribute(key, value)
    local item = self._selWidget:getChildByName("__EQUIPSHOW__")
    if item then
        item:removeFromParent()
    end

    self:SetAttribute(GUIAttributes.EQUIP_SHOW, key, value)
    if key == "look" then
        self:SetAttribute(GUIAttributes.EQUIP_SHOW, "noMouseTips", not value)
    elseif key == "lookPlayer" and value then
        self:SetAttribute(GUIAttributes.EQUIP_SHOW, "doubleTakeOff", false)
        self:SetAttribute(GUIAttributes.EQUIP_SHOW, "autoUpdate", false)
        self:SetAttribute(GUIAttributes.EQUIP_SHOW, "movable", false)
        self:onEquipLookPlayerCallFunc()
    end
    self:CreateEquipShow(self._selWidget)
end

local EquipAttrDefault = {
    ["countFontSize"] = 15, ["color"] = "#FFFFFF", ["from"] = 0
}

function GUIEditor:SetEquipUIAttribute(uiWidget, widget, key)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.EQUIP_SHOW)
    local value = data[key]
    value = (not value and EquipAttrDefault[key]) and EquipAttrDefault[key] or value
    uiWidget:setString(value)
end

function GUIEditor:SetEquipPos(value)
    self:SetEquipAttribute("pos", tonumber(value))
end

function GUIEditor:SetUIEquipPos(uiWidget, widget)
    self:SetEquipUIAttribute(uiWidget, widget, "pos")
end

function GUIEditor:onEquipLookEvent(ref)
    self:SetEquipAttribute("look", not ref:isSelected())
end

function GUIEditor:onEquipShowBgEvent(ref)
    self:SetEquipAttribute("bgVisible", not ref:isSelected())
end

function GUIEditor:onEquipShowStarEvent(ref)
    self:SetEquipAttribute("starLv", not ref:isSelected())
end

function GUIEditor:onEquipAutoUpdateEvent(ref)
    self:SetEquipAttribute("autoUpdate", not ref:isSelected())
end

function GUIEditor:onEquipIsHeroEvent(ref)
    self:SetEquipAttribute("isHero", not ref:isSelected())
end

function GUIEditor:onEquipAddDoubleEvent(ref)
    self:SetEquipAttribute("doubleTakeOff", not ref:isSelected())
end

function GUIEditor:onEquipAddMoveEvent(ref)
    self:SetEquipAttribute("movable", not ref:isSelected())
end

function GUIEditor:onEquipIsLookPlayerEvent(ref)
    self:SetEquipAttribute("lookPlayer", not ref:isSelected())
end

function GUIEditor:onEquipLookPlayerCallFunc()
    local uiNameList = {"CheckBox_Equip_autoUpdate", "CheckBox_Equip_onDouble", "CheckBox_Equip_onMove"}
    for _, name in ipairs(uiNameList) do
        if self._selUISpecialControl and self._selUISpecialControl[name] then
            if self._SpecialAttr[name] and self._SpecialAttr[name].SetUIWidget then
                self._SpecialAttr[name].SetUIWidget(self._selUISpecialControl[name], self._selWidget)
            end
        end
    end
end

function GUIEditor:onColorSetCallFunc(color)
    if self._SpecialAttr["TextField_C"] then
        self._SpecialAttr["TextField_C"].SetWidget(color)
        self._SpecialAttr["TextField_C"].SetUIWidget(self._selUISpecialControl["TextField_C"], self._selWidget)
    end
end

function GUIEditor:onColorOutlineSetCallFunc(color)
    if self._SpecialAttr["TextField_Outline_C"] then
        self._SpecialAttr["TextField_Outline_C"].SetWidget(color)
        self._SpecialAttr["TextField_Outline_C"].SetUIWidget(self._selUISpecialControl["TextField_Outline_C"], self._selWidget)
    end
end

function GUIEditor:onColorInputPlaceHolderColorSetCallFunc(color)
    if self._SpecialAttr["TextField_C2"] then
        self._SpecialAttr["TextField_C2"].SetWidget(color)
        self._SpecialAttr["TextField_C2"].SetUIWidget(self._selUISpecialControl["TextField_C2"], self._selWidget)
    end
end

function GUIEditor:onOpenClolorSelector(ref)
    releaseLayerGUI("GUIColorSelector")
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIColorSelector_Open, {color = ref.__color__, callfunc = self._SpecialAttr[ref:getName()].callfunc})
end

function GUIEditor:onLanguage(ref)
    local lang = self._language == 0 and 1 or 0
    self._language = lang

    self:SetSaveLocalValue("lang", lang)
    self:setButtonLanguageText(lang)

    self:updateTreeNodes()
end

-- 导出------------------------------------------------------------------------------
function GUIEditor:onSaveFile()
    if not self._selFileInfo then
        return false
    end

    local fullfile = self._selFileInfo.fullfile
    
    self:checkExportFolder(self._lastDirectory or self._selDirctor)

    if not fullfile then
        local listfiles = fileUtil:listFiles(self._defaultPath)
        -- 跳过 2 条
        tRemove(listfiles, 1)
        tRemove(listfiles, 1)

        local idxs = {}
        local is   = false

        for k = 1, #listfiles do
            local v = listfiles[k]
            local n = sgsub(v, sformat("%s/", self._defaultPath), "")
            local i,j,v2 = sfind(n, "新建文件(%d).lua")
            if v2 then
                idxs[tonumber(v2)] = true
            elseif sfind(n, "新建文件.lua") then
                is = true
            end
        end

        if is then
            for i = 1, 100 do
                if idxs[i] then
                else
                    fullfile = sformat("新建文件%s.lua", i)
                    break
                end
            end
        else
            fullfile = "新建文件.lua"
        end

        self._selFileInfo.fullfile = fullfile
    end

    local filePath = self._defaultPath
    if self._lastDirectory then
        filePath = filePath .. "/" .. self._lastDirectory .. self._curFile
    elseif self._selDirctor then
        filePath = filePath .. "/" .. self._selDirctor .. self._curFile
    else
        filePath = filePath .. "/" .. fullfile
    end

    -- 写入到指定文件
    local source = self:OutputGUI()

    fileUtil:writeStringToFile(source, filePath)

    self:AddSystemTips(sformat("%s %s", "导出成功", filePath))
end

-- 检测 ExportFolder 文件夹是否存在
function GUIEditor:checkExportFolder(file)
    local folder = self._defaultPath

    if file then
        folder = sformat("%s/%s", folder, file)
    end
    
    if self:IsDirectory(folder) then
        return false
    end

    fileUtil:createDirectory(folder)
end

function GUIEditor:checkLocalNum()
    local outputUI  = {
        Label       = 1,
        BmpText     = 1,
        TextAtlas   = 1,
        RText       = 1,
        Button      = 1,
        ImageView   = 1,
        CheckBox    = 1,
        EditBox     = 1,
        TextField   = 1,
        Slider      = 1,
        LoadingBar  = 1,
        Layout      = 1,
        ListView    = 1,
        ScrollView  = 1,
        PageView    = 1,
        Widget      = 1,
        Effect      = 1,
        Item        = 1,
        EquipShow   = 1,
    }

    local num = 1

    local function parse(d)
        local widget = d and d.widget
        if widget and outputUI[widget:getDescription()] then
            num = num + 1
        end
    end

    local function parseChilren(children)
        for _,v in pairs(children) do
            local idx = self:getTreeIdxByObj(v.widget)
            if idx then
                parse(self._uiTree[idx])
                if next(self._uiTree[idx].children) then
                    parseChilren(self:convertChildrenFormat(self._uiTree[idx].children))
                end
            end
        end
    end

    for i = 1, #self._uiTree do
        local d = self._uiTree[i]
        if not next(d.parent) then
            parse(d)
        end
        if not next(d.parent) and next(d.children) then
            parseChilren(self:convertChildrenFormat(d.children))
        end
    end

    return num > 200
end

function GUIEditor:SaveCache(source, clear)
    if clear then
        self._caches = {}
    end
    
    self._caches[#self._caches + 1] = source or self:OutputGUI()
    self._IsZing = false
end

function GUIEditor:OutputGUI()
    local outputUI  = {
        Label       = handler(self, self.output_Label),
        BmpText     = handler(self, self.output_BmpText),
        TextAtlas   = handler(self, self.output_TextAtlas),
        RText       = handler(self, self.output_RText),
        Button      = handler(self, self.output_Button),
        ImageView   = handler(self, self.output_Image),
        CheckBox    = handler(self, self.output_CheckBox),
        EditBox     = handler(self, self.output_EditBox),
        TextField   = handler(self, self.output_EditBox),
        Slider      = handler(self, self.output_Slider),
        LoadingBar  = handler(self, self.output_LoadingBar),
        Layout      = handler(self, self.output_Layout),
        ListView    = handler(self, self.output_ListView),
        ScrollView  = handler(self, self.output_ScrollView),
        PageView    = handler(self, self.output_PageView),
        Widget      = handler(self, self.output_Node),
        Effect      = handler(self, self.output_Effect),
        Item        = handler(self, self.output_Item),
        Model       = handler(self, self.output_Model),
        EquipShow   = handler(self, self.output_EquipShow)
    }

    self._repeatName = self:checkLocalNum()

    self._GUINames = {}

    local class = "ui"

    local output = sformat("local %s = {}%s", class, charMask.br)
    output = sformat("%sfunction %s%sinit(parent)", output, class, charMask.point)


    local function parse(d, i)
        local widget = d and d.widget
        if widget then
            local desc = widget:getDescription()
            if outputUI[desc] then
                if i == 1 then
                    output = sformat("%s%s", output, self:brEx())
                else
                    output = sformat("%s%s%s", output, charMask.br, self:brEx())
                end

                local name = widget:getName()
                local pName = "parent"
                if next(d.parent) then
                    pName = self:GetParent(d.parent):getName()
                end
                output = sformat("%s%s", output, outputUI[desc](widget, pName, name))
            end
        end
    end

    local function parseChilren(children)
        for _,v in pairs(children) do
            local idx = self:getTreeIdxByObj(v.widget)
            if idx then
                parse(self._uiTree[idx])
                if next(self._uiTree[idx].children) then
                    parseChilren(self:convertChildrenFormat(self._uiTree[idx].children))
                end
            end
        end
    end

    for i = 1, #self._uiTree do
        local d = self._uiTree[i]
        if not next(d.parent) then
            parse(d, i)
        end
        if not next(d.parent) and next(d.children) then
            parseChilren(self:convertChildrenFormat(d.children))
        end
    end

    output = sformat("%s%send%sreturn %s", output, charMask.br, charMask.br, class)

    return output
end

function GUIEditor:brEx()
    return sformat("%s%s", charMask.br, charMask.t)
end

function GUIEditor:parseCommon(widget, ID)
    local isWidget = tolua.type(widget) == "ccui.Widget"

    local anr  = widget:getAnchorPoint()
    local tag  = widget:getTag()
    local visible = widget:isVisible()
    local touched = not isWidget and widget:isTouchEnabled()
    local scaleX  = widget:getScaleX()
    local scaleY  = widget:getScaleY()
    local opacity = widget:getOpacity()
    local isFlippedX = widget:isFlippedX()
    local isFlippedY = widget:isFlippedY()

    local rotateX = widget:getRotationSkewX()
    local rotateY = widget:getRotationSkewY()
    local rotate  = rotateX == rotateY and rotateX or 0

    local chinesename = GUI:getChineseName(widget)

    local descrip = widget:getDescription()

    local strs = ""

    local br = self:brEx()

    if chinesename ~= "" then
        strs = sformat("%s%s%s", strs, br, sformat([[GUI:setChineseName(%s, "%s")]], ID, chinesename))
    end

    if descrip == "Effect" then
    else
        if anr.x ~= 0 or anr.y ~= 0 then
            strs = sformat("%s%s%s", strs, br, sformat("GUI:setAnchorPoint(%s, %s, %s)", ID, sformat("%.2f", anr.x), sformat("%.2f", anr.y)))
        end
    end

    if isFlippedX then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setFlippedX(%s, %s)", ID, true))
    end

    if isFlippedY then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setFlippedY(%s, %s)", ID, true))
    end

    if rotate ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setRotation(%s, %s)", ID, sformat("%.2f", rotate)))
    end

    if rotateX ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setRotationSkewX(%s, %s)", ID, sformat("%.2f", rotateX)))
    end
    if rotateY ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setRotationSkewY(%s, %s)", ID, sformat("%.2f", rotateY)))
    end

    if scaleX ~= 1 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setScaleX(%s, %s)", ID, sformat("%.2f", scaleX)))
    end
    if scaleY ~= 1 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setScaleY(%s, %s)", ID, sformat("%.2f", scaleY)))
    end

    if opacity ~= 255 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setOpacity(%s, %s)", ID, opacity))
    end

    if not isWidget then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setTouchEnabled(%s, %s)", ID, touched))
    end

    strs = sformat("%s%s%s", strs, br, sformat("GUI:setTag(%s, %s)", ID, tag))

    if visible == false then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setVisible(%s, %s)", ID, false))
    end

    if descrip == "Item" then
        local data = self:GetAttribeValue(widget, GUIAttributes.SWALLOW)
        local IsSwallow = GUIHelper:GetStatus(data.Param2)
        if not IsSwallow then
            strs = sformat("%s%s%s", strs, br, sformat([[GUI:ItemShow_setItemTouchSwallow(%s, %s)]], ID, false))
        end
    elseif descrip ~= "Effect" then
        local IsSwallow = widget:isSwallowTouches()
        if touched ~= IsSwallow then
            strs = sformat("%s%s%s", strs, br, sformat([[GUI:setSwallowTouches(%s, %s)]], ID, IsSwallow))
        end
    end

    return strs
end

function GUIEditor:parseContentSize(widget, ID, nimg, isScale9)
    local size = widget:getContentSize()

    if isScale9 then
        return sformat("GUI:setContentSize(%s, %s, %s)", ID, size.width, size.height)
    end

    local desc = widget:getDescription()
    local temp = nil
    if desc == "Button" then
        temp = ccui.Button:create(nimg)
        temp:loadTextureNormal(nimg)
    elseif desc == "ImageView" then
        temp = ccui.ImageView:create(nimg)
    elseif desc == "LoadingBar" then
        temp = ccui.LoadingBar:create(nimg)
    elseif desc == "Slider" then
        temp = ccui.Slider:create()
        temp:loadBarTexture(nimg)
    elseif desc == "CheckBox" then
        temp = ccui.CheckBox:create()
        temp:loadTextureBackGround(nimg)
    end

    if not temp then
        return false
    end
    
    local tSize = temp:getContentSize()
    if size.width ~= tSize.width or size.height ~= tSize.height then
        return sformat("GUI:setContentSize(%s, %s, %s)", ID, size.width, size.height)
    end

    return false
end

function GUIEditor:formatText(text)
    local l = "[["
    local r = "]]"
    if sfind(text, "%[") or sfind(text, "%]") then
        l = "[==========["
        r = "]==========]"
    end
    return sformat("%s%s%s", l, text, r)
end

function GUIEditor:GetLuaMsgStr(data)
    local msgID = tonumber(data.MsgID) or 0
    if msgID < 1 then
        return ""
    end

    local msgData = data.MsgData or " "
    local param1  = data.Param1 or 0
    local param2  = data.Param2 or 0
    local param3  = data.Param3 or 0

    if GUIHelper:GetStatus(data.IsLuaMsg, false) then
        return sformat([[SL:SendLuaNetMsg(%s, %s, %s, %s, "%s")]], msgID, param1, param2, param3, msgData)
    end
    return sformat([[SL:SendNetMsg(%s, %s, %s, %s, "%s")]], msgID, param1, param2, param3, msgData)
end

function GUIEditor:GetFuncStr(data)
    local isClick  = GUIHelper:GetStatus(data.IsClick, false)
    local funcBody = data.FuncBody or ""
    if slen(funcBody) > 0 or isClick then
        return sformat([[if %s then %s end]], isClick, funcBody)
    end
    return ""
end

function GUIEditor:getMsgStr(widget, ID)
    local data = self:GetAttribeValue(widget, GUIAttributes.MESSAGE)

    -- Lua msg
    local luaMsg  = self:GetLuaMsgStr(data)
    -- Click msg
    local funcMsg = self:GetFuncStr(data)

    if slen(luaMsg) < 1 and slen(funcMsg) < 1 then
        return false
    end

    return sformat([[GUI:addOnClickEvent(%s, function () %s ; %s end)]], ID, luaMsg, sgsub(funcMsg, ";", ""))
end

function GUIEditor:checkRepeatName(ID)
    if not self._repeatName then
        return "local "
    end
    local str = self._GUINames[ID] and "" or "local "
    self._GUINames[ID] = true
    return str
end

function GUIEditor:output_Label(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())
    local fontsize  = widget:getFontSize()
    local fontcolor = GetColorHexFromRBG(widget:getTextColor())

    local br = self:brEx()

    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local data, isMeta = self:GetAttribeValue(widget, GUIAttributes.TEXT_METAVALUE)
    if isMeta then
        local text = data.Param2
        strs = sformat("%s%s", strs, sformat("%s%s = GUI:Text_Create(%s, \"%s\", %s, %s, %s, \"%s\", \"%s\")", defType, ID, parent, ID, x, y, fontsize, fontcolor, text))
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Text_AutoUpdateMetaValue(%s, \"%s\")", ID, text))
    else
        local text = self:formatText(widget:getString())
        strs = sformat("%s%s", strs, sformat("%s%s = GUI:Text_Create(%s, \"%s\", %s, %s, %s, \"%s\", %s)", defType, ID, parent, ID, x, y, fontsize, fontcolor, text)) 
    end

    local ignoreSize = widget:isIgnoreContentAdaptWithSize()
    if not ignoreSize then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))

        local size = widget:getContentSize()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Text_setTextAreaSize(%s, %s, %s)", ID, size.width, size.height))
    end

    local alignH = widget:getTextHorizontalAlignment()
    if alignH and alignH ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Text_setTextHorizontalAlignment(%s, %s)", ID, alignH))
    end

    local alignV = widget:getTextVerticalAlignment()
    if alignV and alignV ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Text_setTextVerticalAlignment(%s, %s)", ID, alignV))
    end

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    local isOutline = self:IsOutline(widget)
    if isOutline then
        local color = widget:getEffectColor()
        local size  = widget:getOutlineSize()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Text_enableOutline(%s, \"%s\", %s)", ID, GetColorHexFromRBG(color), size))
    else
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Text_disableOutLine(%s)", ID))
    end

    local msgStr = self:getMsgStr(widget, ID)
    if msgStr then
        strs = sformat("%s%s%s", strs, br, msgStr)
    end

    return strs
end

function GUIEditor:output_BmpText(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())
    local text = self:formatText(widget:getString())
    local fontcolor = GetColorHexFromRBG(widget:getTextColor())

    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:BmpText_Create(%s, \"%s\", %s, %s, \"%s\", %s)", defType, ID, parent, ID, x, y, fontcolor, text)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), self:brEx(), strs)

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_TextAtlas(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local stringValue  = widget:getStringValue()
    local charMapFile  = widget:getCharMapFile()
    local itemWidth    = widget:getItemWidth()
    local itemHeight   = widget:getItemHeight()
    local startCharMap = widget:getStartCharMap()

    GUI:TextAtlas_setProperty(widget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
    
    GUI:Text_AutoUpdateMetaValue(widget, stringValue)

    local br = self:brEx()

    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:TextAtlas_Create(%s, \"%s\", %s, %s, \"%s\", \"%s\", %s, %s, \"%s\")", defType, ID, parent, ID, x, y, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)

    local data, isMeta = self:GetAttribeValue(widget, GUIAttributes.TEXT_METAVALUE)
    if isMeta then
        local text = data.Param2
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Text_AutoUpdateMetaValue(%s, \"%s\")", ID, text))
    end

    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_RText(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)

    local defType = self:checkRepeatName(ID)

    local data = self:GetAttribeValue(widget, GUIAttributes.RICH_TEXT)
    local Text   = data["Text"]
    local Width  = data["Width"]
    local RSize  = data["RSize"]
    local RColor = data["RColor"]
    local RSpace = data["RSpace"]
    local LinkCB = data["LinkCB"]
    local RFace  = data["RFace"]
    strs = sformat("%s%s", strs, sformat("%s%s = GUI:RichText_Create(%s, \"%s\", %s, %s, \"%s\", %s, %s, \"%s\", %s, %s, \"%s\")", defType, ID, parent, ID, x, y, Text, Width, RSize, RColor, RSpace, LinkCB, RFace))

    
    local cStr, cFuncQueue = self:parseCommon(widget, ID)
    
    strs = sformat("%s%s", strs, cStr)

    return strs
end

function GUIEditor:output_Button(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local br = self:brEx()

    local nimg = GUITXTEditorDefine.getResPath(widget, "N")
    if nimg ~= "" and fileUtil:isFileExist(nimg) then
    else
        nimg = sformat("%s%s", _PathRes, "Button_Normal.png")
    end

    nimg = FixPath(nimg)
    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:Button_Create(%s, \"%s\", %s, %s, \"%s\")", defType, ID, parent, ID, x, y, nimg)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    local pimg = GUITXTEditorDefine.getResPath(widget, "P")
    if pimg ~= "" and fileUtil:isFileExist(pimg) then
        pimg = FixPath(pimg)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_loadTexturePressed(%s, \"%s\")", ID, pimg))
    end

    local dimg = GUITXTEditorDefine.getResPath(widget, "D")
    if dimg ~= "" and fileUtil:isFileExist(dimg) then
        dimg = FixPath(dimg)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_loadTextureDisabled(%s, \"%s\")", ID, dimg))
    end

    local isScale9 = widget:isScale9Enabled()
    if isScale9 then
        local rect = self:getCapInset(widget)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setScale9Slice(%s, %s, %s, %s, %s)", ID, rect.l, rect.r, rect.t, rect.b))
    end

    local sizeStr = self:parseContentSize(widget, ID, nimg, isScale9)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end

    local text = widget:getTitleText()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setTitleText(%s, \"%s\")", ID, text))

    local fontcolor = GetColorHexFromRBG(widget:getTitleColor())
    strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setTitleColor(%s, \"%s\")", ID, fontcolor))

    local fontsize = widget:getTitleFontSize()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setTitleFontSize(%s, %s)", ID, fontsize))
    
    local render = widget:getTitleRenderer()
    local isOutline = self:IsOutline(render)
    if isOutline then
        local c4b = render:getEffectColor()
        local r = math.floor(c4b.r * 255)
        local g = math.floor(c4b.g * 255)
        local b = math.floor(c4b.b * 255)
        local a = math.floor(c4b.a * 255)
        local color = cc.c4b(r, g, b, a)
        local size  = render:getOutlineSize()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_titleEnableOutline(%s, \"%s\", %s)", ID, GetColorHexFromRBG(color), size))
    else
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_titleDisableOutLine(%s)", ID))
    end

    local msgStr = self:getMsgStr(widget, ID)
    if msgStr then
        strs = sformat("%s%s%s", strs, br, msgStr)
    end

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_Image(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local br = self:brEx()

    local nimg = GUITXTEditorDefine.getResPath(widget, "N")
    if nimg ~= "" and fileUtil:isFileExist(nimg) then
    else
        nimg = sformat("%s%s", _PathRes, "ImageFile.png")
    end

    nimg = FixPath(nimg)
    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:Image_Create(%s, \"%s\", %s, %s, \"%s\")", defType, ID, parent, ID, x, y, nimg)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    local isScale9 = widget:isScale9Enabled()
    if isScale9 then
        local rect = self:getCapInset(widget)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Image_setScale9Slice(%s, %s, %s, %s, %s)", ID, rect.l, rect.r, rect.t, rect.b))
    end

    local sizeStr = self:parseContentSize(widget, ID, nimg, isScale9)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end

    local msgStr = self:getMsgStr(widget, ID)
    if msgStr then
        strs = sformat("%s%s%s", strs, br, msgStr)
    end

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_EditBox(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())
    local size = widget:getContentSize()
    local fontsize = widget:getFontSize()

    local br = self:brEx()

    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:TextInput_Create(%s, \"%s\", %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, sformat("%.2f", size.width), sformat("%.2f", size.height), fontsize)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    -- 输入类型
    local inputMode = widget:getInputMode()
    if inputMode ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setInputMode(%s, %s)", ID, inputMode))
    end

    -- 是否加密
    local inputFlag = widget:getInputFlag()
    if inputFlag == 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setInputFlag(%s, 0)", ID))
    end

    local text = widget:getString()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setString(%s, \"%s\")", ID, text))

    local pholder = widget:getPlaceHolder()
    if slen(pholder or "") > 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setPlaceHolder(%s, \"%s\")", ID, pholder))
    end

    local color = cc.c3b(255, 255, 255)
    if widget:getDescription() == "TextField" then
        color = widget:getColor()
    else
        color = widget:getFontColor()
    end
    strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setFontColor(%s, \"%s\")", ID, GetColorHexFromRBG(color)))

    local maxlen = widget:getMaxLength()
    if maxlen > 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setMaxLength(%s, %s)", ID, maxlen))
    end

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_Slider(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local br = self:brEx()

    local nimg = GUITXTEditorDefine.getResPath(widget, "N")
    if nimg ~= "" and fileUtil:isFileExist(nimg) then
    else
        nimg = sformat("%s%s", _PathRes, "Slider_Bg.png")
    end

    local pimg = GUITXTEditorDefine.getResPath(widget, "P")
    if pimg ~= "" and fileUtil:isFileExist(pimg) then
    else
        pimg = sformat("%s%s", _PathRes, "Slider_Bar.png")
    end

    local dimg = GUITXTEditorDefine.getResPath(widget, "D")
    if dimg ~= "" and fileUtil:isFileExist(dimg) then
    else
        dimg = sformat("%s%s", _PathRes, "Slider_Ball.png")
    end

    nimg = FixPath(nimg)
    pimg = FixPath(pimg)
    dimg = FixPath(dimg)
    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:Slider_Create(%s, \"%s\", %s, %s, \"%s\", \"%s\", \"%s\")", defType, ID, parent, ID, x, y, nimg, pimg, dimg)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    local sizeStr = self:parseContentSize(widget, ID, nimg)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end

    local progress = widget:getPercent()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:Slider_setPercent(%s, %s)", ID, progress))
    
    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_LoadingBar(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())
    local dir = widget:getDirection()

    local br = self:brEx()

    local nimg = GUITXTEditorDefine.getResPath(widget, "N")
    if nimg ~= "" and fileUtil:isFileExist(nimg) then
    else
        nimg = sformat("%s%s", _PathRes, "LoadingBar.png")
    end

    nimg = FixPath(nimg)
    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:LoadingBar_Create(%s, \"%s\", %s, %s, \"%s\", %s)", defType, ID, parent, ID, x, y, nimg, dir)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    local sizeStr = self:parseContentSize(widget, ID, nimg)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end

    local progress = widget:getPercent()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:LoadingBar_setPercent(%s, %s)", ID, progress))

    local color = widget:getColor()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:LoadingBar_setColor(%s, \"%s\")", ID, GetColorHexFromRBG(color)))
    
    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_CheckBox(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local br = self:brEx()

    local nimg = GUITXTEditorDefine.getResPath(widget, "N")
    if nimg ~= "" and fileUtil:isFileExist(nimg) then
    else
        nimg = sformat("%s%s", _PathRes, "CheckBox_Normal.png")
    end

    local pimg = GUITXTEditorDefine.getResPath(widget, "P")
    if pimg ~= "" and fileUtil:isFileExist(pimg) then
    else
        pimg = sformat("%s%s", _PathRes, "CheckBox_Press.png")
    end

    nimg = FixPath(nimg)
    pimg = FixPath(pimg)
    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:CheckBox_Create(%s, \"%s\", %s, %s, \"%s\", \"%s\")", defType, ID, parent, ID, x, y, nimg, pimg)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    local sizeStr = self:parseContentSize(widget, ID, nimg)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end

    local isSelect = widget:isSelected()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:CheckBox_setSelected(%s, %s)", ID, isSelect))
    
    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_Layout(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())
    local size = widget:getContentSize()
    local clip = widget:isClippingEnabled()

    local br = self:brEx()

    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:Layout_Create(%s, \"%s\", %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, sformat("%.2f", size.width), sformat("%.2f", size.height), clip)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    local bgImage = GUITXTEditorDefine.getResPath(widget, "N")
    if bgImage ~= "" and fileUtil:isFileExist(bgImage) then
        bgImage = FixPath(bgImage)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Layout_setBackGroundImage(%s, \"%s\")", ID, bgImage))
    end

    local clipType = widget:getBackGroundColorType()
    if clipType ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Layout_setBackGroundColorType(%s, %s)", ID, 1))

        local bgColor = widget:getBackGroundColor()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Layout_setBackGroundColor(%s, \"%s\")", ID, GetColorHexFromRBG(bgColor)))

        local bgOpacity = widget:getBackGroundColorOpacity()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Layout_setBackGroundColorOpacity(%s, %s)", ID, bgOpacity))
    end

    local isScale9 = widget:isBackGroundImageScale9Enabled()
    if isScale9 then
        local rect = self:getCapInset(widget)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Layout_setBackGroundImageScale9Slice(%s, %s, %s, %s, %s)", ID, rect.l, rect.r, rect.t, rect.b))
    end

    local msgStr = self:getMsgStr(widget, ID)
    if msgStr then
        strs = sformat("%s%s%s", strs, br, msgStr)
    end

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_ListView(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())
    local dir  = widget:getDirection()
    local size = widget:getContentSize()

    local br = self:brEx()

    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:ListView_Create(%s, \"%s\", %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, sformat("%.2f", size.width), sformat("%.2f", size.height), dir)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    local bgImage = GUITXTEditorDefine.getResPath(widget, "N")
    if bgImage ~= "" and fileUtil:isFileExist(bgImage) then
        bgImage = FixPath(bgImage)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setBackGroundImage(%s, \"%s\")", ID, bgImage))
    end

    local isClip = widget:isClippingEnabled()
    if not isClip then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setClippingEnabled(%s, %s)", ID, false))
    end

    local clipType = widget:getBackGroundColorType()
    if clipType ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setBackGroundColorType(%s, %s)", ID, 1))

        local bgColor = widget:getBackGroundColor()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setBackGroundColor(%s, \"%s\")", ID, GetColorHexFromRBG(bgColor)))

        local bgOpacity = widget:getBackGroundColorOpacity()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setBackGroundColorOpacity(%s, %s)", ID, bgOpacity))
    end

    local isScale9 = widget:isBackGroundImageScale9Enabled()
    if isScale9 then
        local rect = self:getCapInset(widget)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setBackGroundImageScale9Slice(%s, %s, %s, %s, %s)", ID, rect.l, rect.r, rect.t, rect.b))
    end

    local isRebound = widget:isBounceEnabled()
    if isRebound then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setBounceEnabled(%s, %s)", ID, isRebound))
    end

    local gravity = widget:getGravity()
    if gravity ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setGravity(%s, %s)", ID, gravity))
    end

    local margin = widget:getItemsMargin()
    if margin ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setItemsMargin(%s, %s)", ID, margin))
    end

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_ScrollView(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())
    local dir  = widget:getDirection()
    local size = widget:getContentSize()

    local br = self:brEx()

    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:ScrollView_Create(%s, \"%s\", %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, sformat("%.2f", size.width), sformat("%.2f", size.height), dir)
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    local bgImage = GUITXTEditorDefine.getResPath(widget, "N")
    if bgImage ~= "" and fileUtil:isFileExist(bgImage) then
        bgImage = FixPath(bgImage)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setBackGroundImage(%s, \"%s\")", ID, bgImage))
    end

    local isClip = widget:isClippingEnabled()
    if not isClip then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setClippingEnabled(%s, %s)", ID, false))
    end

    local clipType = widget:getBackGroundColorType()
    if clipType ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setBackGroundColorType(%s, %s)", ID, 1))

        local bgColor = widget:getBackGroundColor()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setBackGroundColor(%s, \"%s\")", ID, GetColorHexFromRBG(bgColor)))

        local bgOpacity = widget:getBackGroundColorOpacity()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setBackGroundColorOpacity(%s, %s)", ID, bgOpacity))
    end

    local isScale9 = widget:isBackGroundImageScale9Enabled()
    if isScale9 then
        local rect = self:getCapInset(widget)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setBackGroundImageScale9Slice(%s, %s, %s, %s, %s)", ID, rect.l, rect.r, rect.t, rect.b))
    end

    local isRebound = widget:isBounceEnabled()
    if isRebound then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setBounceEnabled(%s, %s)", ID, isRebound))
    end

    local innerSize = widget:getInnerContainerSize()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setInnerContainerSize(%s, %s, %s)", ID, sformat("%.2f", innerSize.width), sformat("%.2f", innerSize.height)))
    
    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_PageView(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())
    local dir  = widget:getDirection()
    local size = widget:getContentSize()

    local br = self:brEx()

    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:PageView_Create(%s, \"%s\", %s, %s, %s, %s)", defType, ID, parent, ID, x, y, sformat("%.2f", size.width), sformat("%.2f", size.height))
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    local bgImage = GUITXTEditorDefine.getResPath(widget, "N")
    if bgImage ~= "" and fileUtil:isFileExist(bgImage) then
        bgImage = FixPath(bgImage)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:PageView_setBackGroundImage(%s, \"%s\")", ID, bgImage))
    end

    local isClip = widget:isClippingEnabled()
    if not isClip then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:PageView_setClippingEnabled(%s, %s)", ID, false))
    end

    local clipType = widget:getBackGroundColorType()
    if clipType ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:PageView_setBackGroundColorType(%s, %s)", ID, 1))

        local bgColor = widget:getBackGroundColor()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:PageView_setBackGroundColor(%s, \"%s\")", ID, GetColorHexFromRBG(bgColor)))

        local bgOpacity = widget:getBackGroundColorOpacity()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:PageView_setBackGroundColorOpacity(%s, %s)", ID, bgOpacity))
    end

    local isScale9 = widget:isBackGroundImageScale9Enabled()
    if isScale9 then
        local rect = self:getCapInset(widget)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:PageView_setBackGroundImageScale9Slice(%s, %s, %s, %s, %s)", ID, rect.l, rect.r, rect.t, rect.b))
    end
    
    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_Node(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local br = self:brEx()

    local defType = self:checkRepeatName(ID)
    local strs = sformat("%s%s = GUI:Node_Create(%s, \"%s\", %s, %s)", defType, ID, parent, ID, x, y)
    
    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)
    
    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_Effect(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())
    
    local br = self:brEx()

    local defType = self:checkRepeatName(ID)

    local data = self:GetAttribeValue(widget, GUIAttributes.EFFECT)
    local type  = data["type"]
    local sfxID = data["sfxID"]
    local sex   = data["sex"]
    local act   = data["act"]
    local dir   = data["dir"]
    local speed = data["speed"]
    local strs = sformat("%s%s = GUI:Effect_Create(%s, \"%s\", %s, %s, %s, %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, type, sfxID, sex, act, dir, speed)

    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_Item(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local br = self:brEx()
    
    local defType = self:checkRepeatName(ID)
    
    local dataStr = nil
    local data = self:GetAttribeValue(widget, GUIAttributes.ITEM_SHOW)
    for key, value in pairs(data) do
        dataStr = dataStr and (dataStr .. ", " .. sformat("%s = %s", key, value)) or sformat("%s = %s", key, value)
    end

    local strs = sformat("%s%s = GUI:ItemShow_Create(%s, \"%s\", %s, %s, %s)", defType, ID, parent, ID, x, y, sformat("{%s}", dataStr))

    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs
end

function GUIEditor:output_Model(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local br = self:brEx()
    
    local defType = self:checkRepeatName(ID)

    local featureStr = nil
    local feature = self:getModelData(widget)
    local sex   = 0
    local scale = 1
    for key, value in pairs(feature) do
        if key == "sex" then
            sex = value
        elseif key == "scale" then
            scale = value
        else
            local IsChar = false
            if type(value) == "string" then
                sgsub(value, "[#&]", function () IsChar = true end)
            end

            if IsChar then
                featureStr = featureStr and sformat("%s, %s = \"%s\"", featureStr, key, value) or sformat("%s = \"%s\"", key, value)
            else
                featureStr = featureStr and sformat("%s, %s = %s", featureStr, key, value) or sformat("%s = %s", key, value)
            end
        end
    end
    local strs = sformat("%s%s = GUI:UIModel_Create(%s, \"%s\", %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, sex, sformat("{%s}", featureStr), scale)

    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    return strs 
end

function GUIEditor:output_EquipShow(widget, parent, ID)
    local x = sformat("%.2f", widget:getPositionX())
    local y = sformat("%.2f", widget:getPositionY())

    local br = self:brEx()
    
    local defType = self:checkRepeatName(ID)
    
    local dataStr = nil
    local data = self:GetEquipShowParam(widget)
    local info = data[3]
    info.index = nil
    info.itemData = nil
    local attri = self:GetAttribeValue(widget, GUIAttributes.EQUIP_SHOW)
    if attri and attri.look then
        info.look = attri and attri.look
    end

    local pos = data[1]
    local isHero = data[2] == true
    local autoUpdate = data[4]

    for key, value in pairs(info) do
        dataStr = dataStr and (dataStr .. ", " .. sformat("%s = %s", key, value)) or sformat("%s = %s", key, value)
    end

    local strs = sformat("%s%s = GUI:EquipShow_Create(%s, \"%s\", %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, pos, isHero, sformat("{%s}", dataStr))

    strs = sformat("%s%s%s", sformat("-- Create %s", ID), br, strs)

    strs = sformat("%s%s", strs, self:parseCommon(widget, ID))

    if autoUpdate then
        local str = sformat("GUI:EquipShow_setAutoUpdate(%s)", ID)
        strs = sformat("%s%s%s", strs, br, str)
    end

    return strs
end

-- 导入------------------------------------------------------------------------------
function GUIEditor:InputGUI(source, first)
    if first then
        self._Node_UI:setPosition(cc.p(0, 0))
    end

    self:onCancelSelectNode()
    self:resetAllSelectWidget()

    local childrens = self._Node_UI:getChildren()
    for k = 1, #childrens do
        local v = childrens[k]
        if v then
            local name = v:getName()
            if not (name == "___MAIN_TOUCH_LAYER___" or name == "___MAIN_COORDINATE_LINE___" or name == "___MAIN_CANVAS_LAYOUT___") then
                v:removeFromParent()
                v = nil
            end
        end
    end

    self._uiNodeMap = {}
    self._uiTree = {}

    self._selWidgets = {}
    self._selDescription = nil
    self._selWidget = nil

    self:SetShortcutState(0)


    -- 判断按钮、图片、复选框、滑动条资源是否有效, 无效则替换成默认
    local smtStr = {
        ":loadTexture%((.-),", 
        ":loadTextureNormal%((.-),", ":loadTexturePressed%((.-),", ":loadTextureDisabled%((.-),",
        ":loadTextureBackGround%((.-),", ":loadTextureFrontCross%((.-),",
        ":loadBarTexture%((.-),", ":loadProgressBarTexture%((.-),", ":loadSlidBallTextureNormal%((.-),"
    }
    local mStr = {
        "res/private/gui_edit/ImageFile.png",
        "res/public/0.png",
        "res/private/gui_edit/Button_Press.png",
        "res/private/gui_edit/Button_Disable.png",
        "res/private/gui_edit/CheckBox_Normal.png",
        "res/private/gui_edit/CheckBox_Press.png",
        "res/private/gui_edit/Slider_Bg.png",
        "res/private/gui_edit/Slider_Bar.png",
        "res/private/gui_edit/Slider_Ball.png"
    }

    -- 防止cocos studio中的属性换行情况
    source = sgsub(source, ",\n", ",")

    local temp = ""
    source = ssplit(source, "\n") or {}
    for __ = 1, #(source) do
        local str = source[__]
        local replaceStr = str
        local Is = false
        for k = 1, #smtStr do
            local match = smtStr[k]
            for path in sgmatch(str, match) do
                path = sgsub(path, "[\"\"]", "")
                if not fileUtil:isFileExist(path) then
                    replaceStr = sgsub(replaceStr, path, mStr[k])
                end
                Is = true
                break
            end
            if not Is then
                break
            end
        end

        replaceStr = sgsub(replaceStr, "cc.Node", "ccui.Widget")
        replaceStr = sgsub(replaceStr, "GUI:Node_Create", "GUI:Widget_Create")
        replaceStr = sgsub(replaceStr, "ccui.TextAtlas:create", "GUI:TextAtlas_Create")

        -- ui
        replaceStr = self:dealUI(replaceStr)

        if temp then
            temp = sformat("%s\n%s", temp, replaceStr)
        else
            temp = replaceStr
        end
    end
    source = temp

    local loadfunc = load(source)
    if not loadfunc then
        return false
    end

    local myfunc = loadfunc()
    if not myfunc then
        return false
    end

    local func = myfunc.create or myfunc.init or myfunc.main
    if not func then
        return false
    end

    if myfunc.create then
        self._Node_UI:addChild(func().root)
    else
        func(self._Node_UI)
    end

    -- 保存最大节点信息
    self._PosData = {
        w = 0, h = 0, p = cc.p(0, 0), r = cc.p(0, 0)
    }

    local have = false
    local function updateData(parent, first)
        local chidldrens = parent:getChildren()
        for i = 1, #chidldrens do
            local widget = chidldrens[i]
            if widget then
                local ID = widget:getName()
                local desc = widget:getDescription()

                self:InitNBAttribute(widget)

                if widget.__EFFECT__ then
                    self:CreateEffect(widget)
                elseif widget.__RICH_TEXT__ then
                    local item = self:CreateRText(widget)
                    widget:setContentSize(item:getContentSize())
                elseif widget.__ITEM_SHOW__ then
                    local item = self:CreateItemShow(widget)
                    widget:setContentSize(item:getContentSize())
                elseif widget.__MODEL__ then
                    self:CreateModel(widget)
                elseif widget.__EQUIP_SHOW__ then
                    local equipShow = self:CreateEquipShow(widget)
                    widget:setContentSize(equipShow:getContentSize())
                end

                if not (ID == "" or ID == "___NODE___" or ID == "___TOUCHLAYOUT___" or ID == "___DRAWNODE___" or ID == "__SFX__" or ID == "__MODEL__" or ID == "__RICHTEXT__" or ID == "__ITEM__" or ID == "__EQUIPSHOW__" or ID == "___MAIN_TOUCH_LAYER___" or ID == "___MAIN_COORDINATE_LINE___"  or ID == "___MAIN_CANVAS_LAYOUT___") then
                    have = true
                    self:CheckShowPos(widget)
                    if first then
                        self:insertTree(widget, ID)
                        self:setWidgetDrawRect(widget)
                    else
                        self:insertTree(widget, ID, parent)
                        self:setWidgetDrawRect(widget)
                    end

                    if desc == "ListView" then
                        widget:jumpToBottom()
                    end

                    if desc == "Label"       or 
                        desc == "BmpText"    or
                        desc == "TextAtlas"  or
                        desc == "Button"     or 
                        desc == "ImageView"  or 
                        desc == "Slider"     or 
                        desc == "EditBox"    or 
                        desc == "TextField"  or 
                        desc == "LoadingBar" or 
                        desc == "CheckBox"   or 
                        desc == "Layout"     or  
                        desc == "ListView"   or 
                        desc == "ScrollView" or 
                        desc == "PageView"   or 
                        desc == "Widget"     or
                        desc == "Effect"     or 
                        desc == "Item"       or
                        desc == "EquipShow" then
                        if widget:getChildrenCount() > 0 then
                            updateData(widget, false)
                        end
                    end
                end
            end
        end
    end
    updateData(self._Node_UI, true)
    self:updateTreeNodes()

    if have then
        self._PosData.w = math.min(self._PosData.w, visibleSize.width)
        self._PosData.h = math.min(self._PosData.h, visibleSize.height)
    else
        self._PosData.w = 1136
        self._PosData.h = 640
    end

    local x = (visibleSize.width  - self._PosData.w) / 2 + self._PosData.w * self._PosData.r.x - self._PosData.p.x
    local y = (visibleSize.height - self._PosData.h) / 2 + self._PosData.h * self._PosData.r.y - self._PosData.p.y
    
    if first then
        self._Node_UI:setPosition(cc.p(math.floor(x-50), math.floor(y)))
    end

    return true
end

-- 快捷预览
function GUIEditor:InputGUIPreview(source)
    self._Node_Preview:removeAllChildren()

    -- 防止cocos studio中的属性换行情况
    source = sgsub(source, ",\n", ",")

    local loadfunc = load(source)
    if not loadfunc then
        return false
    end

    local myfunc = loadfunc()
    if not myfunc then
        return false
    end

    local func = myfunc.create or myfunc.init or myfunc.main
    if not func then
        return false
    end

    if myfunc.create then
        self._Node_Preview:addChild(func().root)
    else
        func(self._Node_Preview)
    end

    -- 保存最大节点信息
    self._PosData = {
        w = 0, h = 0, p = cc.p(0, 0), r = cc.p(0, 0)
    }

    local have = false
    
    local function updateData(parent)
        local chidldrens = parent:getChildren()
        for i = 1, #chidldrens do
            local widget = chidldrens[i]
            if widget then
                have = true
                self:CheckShowPos(widget)

                if widget.getChildren then
                    updateData(widget)
                end
            end
        end
    end
    updateData(self._Node_Preview)

    self._Node_Preview:setScale(0.5)

    local maxW = 580
    local maxH = 330

    if have then
        self._PosData.w = math.min(self._PosData.w, maxW)
        self._PosData.h = math.min(self._PosData.h, maxH)
    else
        self._PosData.w = maxW
        self._PosData.h = maxH 
    end

    local x = (maxW - self._PosData.w) / 2 + self._PosData.w * self._PosData.r.x - self._PosData.p.x
    local y = (maxH - self._PosData.h) / 2 + self._PosData.h * self._PosData.r.y - self._PosData.p.y
    
    self._Node_Preview:setPosition(cc.p(math.floor(x), math.floor(y)))
end

function GUIEditor:formatStrValue(str, name, key, value)
    return sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], name, key, value))
end

function GUIEditor:dealRichText(str, contents, matchStr)
    local chars = {}
    for v in sgmatch(contents, "\"(.-)\"") do
        chars[#chars+1] = v
    end
    contents = sgsub(contents, "\"(.-)\"", "")

    local param = ssplit(sformat("[[,%s,]]", contents), ",")
    local i, j, varStr = sfind(str, "(.-)=")

    local parent      = param[2] 
    local ID          = tostring(chars[1])
    local x           = tonumber(param[4])
    local y           = tonumber(param[5])
    local text        = tostring(chars[2])
    local width       = tonumber(param[7])
    local fontSize    = tonumber(param[8])
    local fontColor   = tostring(chars[3])
    local vspace      = tonumber(param[10])
    local hyperlinkCB = param[11]
    local RFace       = chars[4]

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, ID, x, y , defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    local cStr = sformat([[%s.__%s__ = {Text = "%s", Width = %s, RSize = %s, RColor = "%s", FSpace = %s, LinkCB = %s, RFace = "%s"}]], ID, GUIAttributes.RICH_TEXT, text, width, fontSize, fontColor, vspace, hyperlinkCB, RFace)

    str = sformat("%s\n%s", str, cStr)
    
    return str
end

function GUIEditor:dealEffect(str, contents, matchStr)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s )
        param[#param+1] = GUIHelper:format(s)
    end)

    local parent = param[1] 
    local x      = tonumber(param[3])
    local y      = tonumber(param[4])
    local type   = tonumber(param[5])
    local sfxID  = tonumber(param[6])
    local sex    = tonumber(param[7])
    local act    = tonumber(param[8])
    local dir    = tonumber(param[9])
    local speed  = tonumber(param[10])

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, name, x, y, defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    str = sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], name, GUIAttributes.EFFECT, sgsub(cjson.encode({type = type, sfxID = sfxID, sex = sex, act = act, dir = dir, speed = speed}), "\\", "\\\\")))

    return str
end

function GUIEditor:dealItem(str, contents, matchStr)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local itemData = {}
    sgsub(contents, "{(.+)}", function ( s )
        sgsub(s .. ",", "(.-)=(.-),", function ( a, b )
            itemData[strim(a)] = GUIHelper:format(b)
        end)
    end)

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = GUIHelper:format(s) end)

    local parent = param[1] 
    local x      = tonumber(param[3])
    local y      = tonumber(param[4])

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, name, x, y, defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    str = sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], name, GUIAttributes.ITEM_SHOW, sgsub(cjson.encode(itemData), "\\", "\\\\")))

    return str
end

function GUIEditor:dealModel(str, contents, matchStr)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local data = {}
    sgsub(contents, "{(.+)}", function ( s )
        sgsub(s .. ",", "(.-)=(.-),", function ( a, b )
            data[strim(a)] = GUIHelper:format(b)
        end)
    end)

    contents = sgsub(contents, "{(.+)}", "")

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = GUIHelper:format(s) end)

    local parent = param[1] 
    local x      = tonumber(param[3])
    local y      = tonumber(param[4])
    data.sex     = tonumber(param[5])
    data.scale   = tonumber(param[7])

    data.notShowMold = GUIHelper:GetStatus(data["notShowMold"])
    data.notShowHair = GUIHelper:GetStatus(data["notShowHair"])

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, name, x, y, defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    str = sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], name, GUIAttributes.MODEL, sgsub(cjson.encode(data), "\\", "\\\\")))

    return str
end

function GUIEditor:dealMessage(str, contents)
    local msgs = nil        -- Lua 事件
    local func = nil        -- 注册的点击事件
    for k, v in sgmatch(contents, "(.+);(.+)") do
        msgs, func = k, v
    end
    if not msgs then
        msgs = contents
    end

    local k, j, name = sfind(contents, "(.-),")
    
    local data = ""
    local isLuaMsg = false

    sgsub(msgs, "SL:SendLuaNetMsg%((.+)%)", function (s) data = s end)

    if data == "" then
        sgsub(msgs, "SL:SendNetMsg%((.+)%)", function (s) data = s end)
    else
        isLuaMsg = true
    end

    local param   = ssplit(data, ",")
    local msgID   = tonumber(param[1] or 0)
    local param1  = tonumber(param[2] or 0)
    local param2  = tonumber(param[3] or 0)
    local param3  = tonumber(param[4] or 0)
    local msgData = param[5] and GUIHelper:format(param[5]) or ""

    local isClick, funcBody = false, ""
    if func then
        for k, v in sgmatch(func, "if (.-) then (.-) end") do
            isClick, funcBody = GUIHelper:GetStatus(k, isClick), v or ""
        end
    end

    local itemData = {
        IsLuaMsg = isLuaMsg, MsgID = msgID, Param1 = param1, Param2 = param2, Param3 = param3, MsgData = msgData, IsClick = isClick, FuncBody = funcBody
    }

    local strs = sformat([[%s.__%s__ = '%s']], name, GUIAttributes.MESSAGE, sgsub(cjson.encode(itemData), "\\", "\\\\"))

    return strs
end

function GUIEditor:dealMethodAttribute(str, contents, key1)
    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = GUIHelper:format(s) end)

    local ID = param[1]
    local Value = param[2]
    
    local pTable = {}
    if Value then
        pTable.Param2 = Value
    end

    if not next(pTable) then
        return str
    end

    str = sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], ID, key1, sgsub(cjson.encode(pTable), "\\", "\\\\")))

    return str
end

function GUIEditor:dealEquipShow(str, contents, matchStr)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local info = {}
    sgsub(contents, "{(.+)}", function ( s )
        sgsub(s .. ",", "(.-)=(.-),", function ( a, b )
            info[strim(a)] = GUIHelper:format(b)
        end)
    end)

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = GUIHelper:format(s) end)

    local parent    = param[1] 
    local x         = tonumber(param[3])
    local y         = tonumber(param[4])
    local pos       = tonumber(param[5])
    local isHero    = param[6]
    info.pos        = pos
    info.isHero     = isHero

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, name, x, y, defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    str = sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], name, GUIAttributes.EQUIP_SHOW, sgsub(cjson.encode(info), "\\", "\\\\")))

    return str
end

function GUIEditor:dealEquipShowAttri(str, contents, key1)
    local name = contents
    if not name or string.len(name) == 0 then
        return str
    end

    local pTable = {}
    pTable.autoUpdate = true

    str = sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], name, key1, sgsub(cjson.encode(pTable), "\\", "\\\\")))
    return str
end

------------------------------------------------------------------------------------
-- 设置特殊属性值
function GUIEditor:SetAttribeValue(widget, key, value)
    widget:setNB(key, true)
    widget:setNBValue(key, value)
    return value
end

function GUIEditor:GetAttribeValue(widget, key)
    local isNB = widget.IsNB and widget:IsNB(key)
    if isNB then
        return widget:getNBValue(key), true
    end

    local func = GUIFuncKeys[key]
    if func then
        return func(widget)
    end
end

------------------------------------------------------------------------------------

function GUIEditor:dealUI(str)
    local Components = {
        { key = "GUI:RichText_Create%((.+)%)", callfunc = handler(self, self.dealRichText) },
        { key = "GUI:Effect_Create%((.+)%)",   callfunc = handler(self, self.dealEffect)   },
        { key = "GUI:ItemShow_Create%((.+)%)", callfunc = handler(self, self.dealItem)     },
        { key = "GUI:UIModel_Create%((.+)%)",  callfunc = handler(self, self.dealModel)    },
        { key = "GUI:addOnClickEvent%((.+)%)", callfunc = handler(self, self.dealMessage)  },
        { key = "GUI:EquipShow_Create%((.+)%)", callfunc = handler(self, self.dealEquipShow) },
    }

    local AttrFuncs = {
        { key = "GUI:ItemShow_setItemTouchSwallow%((.+)%)", callfunc = handler(self, self.dealMethodAttribute), AKey1 = GUIAttributes.SWALLOW },
        { key = "GUI:Text_AutoUpdateMetaValue%((.+)%)",     callfunc = handler(self, self.dealMethodAttribute), AKey1 = GUIAttributes.TEXT_METAVALUE },
        { key = "GUI:EquipShow_setAutoUpdate%((.+)%)",      callfunc = handler(self, self.dealEquipShowAttri), AKey1 = GUIAttributes.EQUIP_AUTO }
    }

    for m = 1, #Components do
        local var = Components[m]
        local matchStr = var.key
        local callfunc = var.callfunc
        local i, j, contents = sfind(str, matchStr)
        if contents then
            if callfunc then
                str = callfunc(str, contents, matchStr)
                break
            end
        end
    end

    for m = 1, #AttrFuncs do
        local var = AttrFuncs[m]
        local callfunc = var.callfunc
        local i, j, contents = sfind(str, var.key)
        if contents then
            if callfunc then
                str = callfunc(str, contents, var.AKey1, var.Type)
                break
            end
        end
    end

    return str
end
------------------------------------------------------------------------------------

function GUIEditor:CheckShowPos(node)
    local size = node:getContentSize()
    local anr = node:getAnchorPoint()
    local pos = cc.p(node:getPosition())--node.getWorldPosition and node:getWorldPosition() or cc.p(node:getPosition())

    if size.width > self._PosData.w then
        self._PosData.w = size.width
        self._PosData.r = anr
        self._PosData.p = pos
    end

    if size.height > self._PosData.h then
        self._PosData.h = size.height
        self._PosData.r = anr
        self._PosData.p = pos
    end
end

-- CTRL + C
function GUIEditor:onCopyNode()
    print("-- CTRL + C --")
    if self._selWidget then
        self._copyWidget = self:cloneEx(self._selWidget)
        self._copyWidget:retain()
        self._cutWidget = nil
    end
end

-- CTRL + V
function GUIEditor:onStickNode()
    print("-- CTRL + V --")
    if self._cutWidget then
        self:onStick(self._cutWidget)
        self._cutWidget = nil
    elseif self._selWidget then
        self:onCopy(self._copyWidget)
    end
end

-- CTRL + X
function GUIEditor:onCutNode()
    print("-- CTRL + X --")
    if self._selWidget then
        self._cutWidget = self._selWidget
        if self._copyWidget then
            self._copyWidget:autorelease()
            self._copyWidget = nil
        end
    end
end

function GUIEditor:onCopy(node)
    if not node then
        return false
    end
    local ID = node:getName()
    local parent = self._Node_UI
    if self._selWidget then
        parent = self._selWidget
    end
    
    local names = {[parent:getName()] = true}
    
    local chidldrens = parent:getChildren()
    for i = 1, #chidldrens do
        local child = chidldrens[i]
        names[child:getName()] = true
    end
    if names[ID] then
        ID = self:getNewID(names, ID)
    end
    if not ID then
        return false
    end

    local pWidget = self._selWidget or self._Node_UI
    if pWidget:getDescription() == "PageView" and node:getDescription() ~= "Layout" then
        return false
    end
    node = self:cloneEx(node)
    node:setName(ID)
    pWidget:addChild(node)

    self:insertTree(node, ID, self._selWidget)
    self:setWidgetDrawRect(node)

    local function updateData(parent)
        local chidldrens = parent:getChildren()
        for i = 1, #chidldrens do
            local widget = chidldrens[i]
            if widget then
                local ID = widget:getName()
                if not (ID == "" or ID == "___NODE___" or ID == "___TOUCHLAYOUT___" or ID == "___DRAWNODE___" or ID == "__SFX__" or ID == "__MODEL__" or ID == "__RICHTEXT__" or ID == "__ITEM__" or ID == "__EQUIPSHOW__" or ID == "___MAIN_TOUCH_LAYER___" or ID == "___MAIN_COORDINATE_LINE___" or ID == "___MAIN_CANVAS_LAYOUT___") then
                    self:insertTree(widget, ID, parent)
                    self:setWidgetDrawRect(widget)

                    local desc = widget:getDescription()
                    if desc == "Label"       or 
                        desc == "BmpText"    or 
                        desc == "TextAtlas"  or
                        desc == "Button"     or 
                        desc == "ImageView"  or 
                        desc == "Slider"     or 
                        desc == "EditBox"    or 
                        desc == "TextField"  or 
                        desc == "LoadingBar" or 
                        desc == "CheckBox"   or 
                        desc == "Layout"     or  
                        desc == "ListView"   or 
                        desc == "ScrollView" or 
                        desc == "PageView"   or 
                        desc == "Widget"     or
                        desc == "Effect"     or
                        desc == "Item"       or
                        desc == "EquipShow" then
                        if widget:getChildrenCount() > 0 then
                            updateData(widget)
                        end
                    end
                end
            end
        end
    end
    updateData(node)

    self:updateTreeNodes()
end

function GUIEditor:onStick(node)
    if not node or self._selWidget == node then
        return false
    end

    local pWidget = self._selWidget or self._Node_UI
    if pWidget:getDescription() == "PageView" and node:getDescription() ~= "Layout" then
        return false
    end

    local idx2 = self:getTreeIdxByObj(node)
    if not idx2 then
        return false
    end
    self:removeOldParent(idx2, node)

    if self._selWidget then
        local idx1 = self:getTreeIdxByObj(self._selWidget)
        if not idx1 then
            return false
        end

        self:changeParent(self._uiTree[idx2].widget, self._uiTree[idx1].widget)
        self._uiTree[idx2].parent = {}
        self._uiTree[idx2].parent[self._selWidget] = true

        self._uiTree[idx1].children[node] = self._uiTree[idx1].children[node] or self:SetMaxValue(self._uiTree[idx1].children)

        self._uiNodeMap[self._selWidget] = self._uiNodeMap[self._selWidget] or {}
        self._uiNodeMap[self._selWidget][node] = true

        self._uiTree[idx1].open = true

        local depth = self._uiTree[idx1].depth + 1
        if depth ~= self._uiTree[idx2].depth then
            self._uiTree[idx2].depth = depth
            self:setChildrenDepth(self._uiTree[idx2].children, depth)
        end
    else
        self:changeParent(self._uiTree[idx2].widget, self._Node_UI)
        local depth = 1
        if depth ~= self._uiTree[idx2].depth then
            self._uiTree[idx2].depth = depth
            self:setChildrenDepth(self._uiTree[idx2].children, depth)
        end
        local temp = clone(self._uiTree[idx2])
        tRemove(self._uiTree, idx2)
        tInsert(self._uiTree, temp)
    end

    self:sortTree()
    self:updateTreeNodes()
end

-- clone --
function GUIEditor:copySpecialProperties(newWidget, widget)
    local attfunc = {
        Label = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)
            
            newWidget:enableOutline(widget:getEffectColor(), widget:getOutlineSize())
        end,
        BmpText = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            GUI:SetBmpTextProperties(newWidget)

            newWidget:setBMFontFilePath()
            
            local fontColor = widget:getTextColor()
            newWidget:setTextColor(fontColor)

            self:CopyNBAttribute(newWidget, widget)
        end,
        TextAtlas = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            self:CopyNBAttribute(newWidget, widget)

            GUI:TextAtlas_SetCustomFunc(newWidget) 

            local stringValue  = widget:getStringValue()
            local charMapFile  = widget:getCharMapFile()
            local itemWidth    = widget:getItemWidth()
            local itemHeight   = widget:getItemHeight()
            local startCharMap = widget:getStartCharMap()
            GUI:TextAtlas_setProperty(newWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)

            self:CopyNBAttribute(newWidget, widget)
        end,
        RText = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setName(widget:getName())

            local p = cc.p(widget:getPosition())
            newWidget:setPosition(p)

            local anr = widget:getAnchorPoint()
            newWidget:setAnchorPoint(anr)

            local salce = widget:getScale()
            newWidget:setScale(salce)
        end,
        ImageView = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:loadTexture(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isScale9Enabled() then
                self:setCapInsetValue(newWidget, "ImageView", self:getCapInset(widget))
            end

            self:CopyNBAttribute(newWidget, widget)
        end,
        Button = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:loadTextureNormal(GUITXTEditorDefine.getResPath(widget, "N"))
            newWidget:loadTexturePressed(GUITXTEditorDefine.getResPath(widget, "P"))
            newWidget:loadTextureDisabled(GUITXTEditorDefine.getResPath(widget, "D"))
            
            if widget:isScale9Enabled() then
                self:setCapInsetValue(newWidget, "Button", self:getCapInset(widget))
            end

            local c = widget:getTitleRenderer():getEffectColor()
            local r = math.floor(c.r * 255)
            local g = math.floor(c.g * 255)
            local b = math.floor(c.b * 255)
            local a = math.floor(c.a * 255)
            newWidget:getTitleRenderer():enableOutline(cc.c4b(r, g, b, a), widget:getTitleRenderer():getOutlineSize())
        end,
        CheckBox = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:loadTextureBackGround(GUITXTEditorDefine.getResPath(widget, "N"))
            newWidget:loadTextureFrontCross(GUITXTEditorDefine.getResPath(widget, "P"))
        end,
        Slider = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:loadBarTexture(GUITXTEditorDefine.getResPath(widget, "N"))
            newWidget:loadProgressBarTexture(GUITXTEditorDefine.getResPath(widget, "P"))
            newWidget:loadSlidBallTextureNormal(GUITXTEditorDefine.getResPath(widget, "D"))
        end,
        LoadingBar = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:loadTexture(GUITXTEditorDefine.getResPath(widget, "N"))
        end,
        Layout = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setBackGroundImage(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isBackGroundImageScale9Enabled() then
                self:setCapInsetValue(newWidget, "Layout", self:getCapInset(widget))
            end
        end,
        ListView = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setBackGroundImage(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isBackGroundImageScale9Enabled() then
                self:setCapInsetValue(newWidget, "ListView", self:getCapInset(widget))
            end
        end,
        ScrollView = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            self:CopyNBAttribute(newWidget, widget)

            newWidget:setBackGroundImage(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isBackGroundImageScale9Enabled() then
                self:setCapInsetValue(newWidget, "ScrollView", self:getCapInset(widget))
            end
        end,
        PageView = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            self:CopyNBAttribute(newWidget, widget)

            newWidget:setBackGroundImage(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isBackGroundImageScale9Enabled() then
                self:setCapInsetValue(newWidget, "PageView", self:getCapInset(widget))
            end
        end,
        EditBox = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            self:CopyNBAttribute(newWidget, widget)

            newWidget:setName(widget:getName())
            newWidget:setText(widget:getText())
        
            local p = cc.p(widget:getPosition())
            newWidget:setPosition(p)
        
            local anr = widget:getAnchorPoint()
            newWidget:setAnchorPoint(anr)
        
            local fontsize = widget:getFontSize()
            newWidget:setFont(GUI.PATH_FONT2, fontsize)
            newWidget:setPlaceholderFontSize(fontsize)
        
            local maxLen = widget:getMaxLength()
            newWidget:setMaxLength(maxLen)
        
            local color = widget:getFontColor()
            newWidget:setFontColor(color)

            local placeHolder = widget:getPlaceHolder()
            newWidget:setPlaceHolder(placeHolder)

            local placeHolderColor = widget:getPlaceholderFontColor()
            newWidget:setPlaceholderFontColor(placeHolderColor)

            newWidget:setVisible(widget:isVisible())

            newWidget:setTouchEnabled(widget:isTouchEnabled())

            newWidget:setInputMode(widget:getInputMode())

            newWidget:setInputFlag(widget:getInputFlag())
        
            if global.isAndroid then
                newWidget:setNativeOffset(cc.p(0, -13))
            end
        end,
        Effect = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setName(widget:getName())

            local p = cc.p(widget:getPosition())
            newWidget:setPosition(p)

            local anr = widget:getAnchorPoint()
            newWidget:setAnchorPoint(anr)

            local salce = widget:getScale()
            newWidget:setScale(salce)
        end,
        Model = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setName(widget:getName())

            local p = cc.p(widget:getPosition())
            newWidget:setPosition(p)

            local anr = widget:getAnchorPoint()
            newWidget:setAnchorPoint(anr)

            local salce = widget:getScale()
            newWidget:setScale(salce)
        end,
        Item = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            self:CopyNBAttribute(newWidget, widget)
            newWidget:setName(widget:getName())

            local p = cc.p(widget:getPosition())
            newWidget:setPosition(p)

            local anr = widget:getAnchorPoint()
            newWidget:setAnchorPoint(anr)

            local salce = widget:getScale()
            newWidget:setScale(salce)
        end,
        EquipShow = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            self:CopyNBAttribute(newWidget, widget)
            newWidget:setName(widget:getName())

            local p = cc.p(widget:getPosition())
            newWidget:setPosition(p)

            local anr = widget:getAnchorPoint()
            newWidget:setAnchorPoint(anr)

            local scale = widget:getScale()
            newWidget:setScale(scale)
        end
    }
    
    local desc = widget:getDescription()
    if attfunc[desc] then
        attfunc[desc]()
    end
end

function GUIEditor:copyClonedWidgetChildren(target, origin)
    local targetChildren = target:getChildren()
    local originChildren = origin:getChildren()
    if #targetChildren == 0 or #originChildren == 0 then
        return false
    end

    local desc = target:getDescription()
    if desc == "EditBox" or desc == "Effect" or desc == "TextAtlas" or desc == "RText" or desc == "Item" or desc == "LoadingBar" or desc == "Model" or desc == "EquipShow" then
        for key = 1, #originChildren do
            local origin = originChildren[key]
            local originDesc = origin:getDescription()
            local ID = origin:getName()
            if not (ID == "" or ID == "___NODE___" or ID == "___TOUCHLAYOUT___" or ID == "___DRAWNODE___" or ID == "__SFX__" or ID == "__MODEL__" or ID == "__RICHTEXT__" or ID == "__ITEM__" or ID == "__EQUIPSHOW__" or ID == "___MAIN_TOUCH_LAYER___" or ID == "___MAIN_COORDINATE_LINE___"  or ID == "___MAIN_CANVAS_LAYOUT___") then
                if originDesc == "EditBox" then
                    local newTarget = ccui.EditBox:create(origin:getContentSize(), GUI.PATH_RES_ALPHA)
                    target:addChild(newTarget)

                    self:copySpecialProperties(newTarget, origin)
                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif originDesc == "Effect" then
                    local newTarget = ccui.Widget:create()
                    target:addChild(newTarget)
                    self:copySpecialProperties(newTarget, origin)

                    self:CreateEffect(newTarget, true)
                    newTarget:setContentSize(defaultSize)

                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif originDesc == "RText" then 
                    local newTarget = ccui.Widget:create()
                    target:addChild(newTarget)
                    self:copySpecialProperties(newTarget, origin)

                    local rText = self:CreateRText(newTarget, true)
                    newTarget:setContentSize(rText:getContentSize())

                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif originDesc == "RichText" then
                elseif originDesc == "Item" then
                    local newTarget = ccui.Widget:create()
                    target:addChild(newTarget)
                    self:copySpecialProperties(newTarget, origin)

                    local item = self:CreateItemShow(newTarget, true)
                    newTarget:setContentSize(item:getContentSize())

                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif originDesc == "Model" then
                    local newTarget = ccui.Widget:create()
                    target:addChild(newTarget)
                    self:copySpecialProperties(newTarget, origin)

                    self:CreateModel(newTarget, true)
                    newTarget:setContentSize(defaultSize)

                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif originDesc == "EquipShow" then
                    local newTarget = ccui.Widget:create()
                    target:addChild(newTarget)
                    self:copySpecialProperties(newTarget, origin)

                    local item = self:CreateEquipShow(newTarget, true)
                    newTarget:setContentSize(item:getContentSize())

                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif origin.clone then
                    local newTarget = origin:clone()
                    target:addChild(newTarget)

                    self:copySpecialProperties(newTarget, origin)
                    self:copyClonedWidgetChildren(newTarget, origin)
                end
            end
        end
    else
        for key = 1, #targetChildren do
            local target = targetChildren[key]
            local origin = originChildren[key]
            self:copySpecialProperties(target, origin)
            self:copyClonedWidgetChildren(target, origin)
        end
    end
end

function GUIEditor:cloneEx(widget)
    local cloneObj
    local desc = widget:getDescription()
    if desc == "EditBox" then
        cloneObj = ccui.EditBox:create(widget:getContentSize(), GUI.PATH_RES_ALPHA)
        self:copySpecialProperties(cloneObj, widget)
    elseif desc == "Effect" then
        cloneObj = ccui.Widget:create()
        self:copySpecialProperties(cloneObj, widget)

        self:CreateEffect(cloneObj, true)
        cloneObj:setContentSize(defaultSize)
    elseif desc == "RText" then 
        cloneObj = ccui.Widget:create()
        self:copySpecialProperties(cloneObj, widget)

        local rText = self:CreateRText(cloneObj, true)
        cloneObj:setContentSize(rText:getContentSize())
    elseif desc == "RichText" then
    elseif desc == "Item" then
        cloneObj = ccui.Widget:create()
        self:copySpecialProperties(cloneObj, widget)

        local item = self:CreateItemShow(cloneObj, true)
        cloneObj:setContentSize(item:getContentSize())
    elseif desc == "Model" then
        cloneObj = ccui.Widget:create()
        self:copySpecialProperties(cloneObj, widget)

        self:CreateModel(cloneObj, true)
        cloneObj:setContentSize(defaultSize)
    elseif desc == "EquipShow" then
        cloneObj = ccui.Widget:create()
        self:copySpecialProperties(cloneObj, widget)

        local item = self:CreateEquipShow(cloneObj, true)
        cloneObj:setContentSize(item:getContentSize())
    else
        local function funIterChild(parent, newP)
            newP:removeAllChildren()
            
            local childrens = parent:getChildren()
            for k = 1, #childrens do
                local v = childrens[k]
                local item = nil
                local desc = v:getDescription()
                if desc == "EditBox" then
                    item = ccui.EditBox:create(v:getContentSize(), GUI.PATH_RES_ALPHA)
                    newP:addChild(item)
                elseif desc == "Effect" then
                    item = ccui.Widget:create()
                    newP:addChild(item)

                    self:CreateEffect(item, true)
                    item:setContentSize(defaultSize)
                elseif desc == "RText" then 
                    item = ccui.Widget:create()
                    newP:addChild(item)
                        
                    local rText = self:CreateRText(item, true)
                    item:setContentSize(rText:getContentSize())
                elseif desc == "Model" then
                    item = ccui.Widget:create()
                    newP:addChild(item)

                    self:CreateModel(item, true)
                    item:setContentSize(defaultSize)
                elseif desc == "Item" then
                    item = ccui.Widget:create()
                    self:copySpecialProperties(item, v)
                    newP:addChild(item)
                    
                    local itemShow = self:CreateItemShow(item, true)
                    item:setContentSize(itemShow:getContentSize())
                elseif desc == "EquipShow" then
                    item = ccui.Widget:create()
                    self:copySpecialProperties(item, v)
                    
                    local equipShow = self:CreateEquipShow(item, true)
                    item:setContentSize(equipShow:getContentSize())

                    newP:addChild(item)
                elseif v.clone then
                    item = v:clone()
                    newP:addChild(item)
                end
                
                if item and (desc ~= "Item" and desc ~= "EquipShow") then
                    funIterChild(v, item)
                end
            end
        end

        cloneObj = widget:clone()
        cloneObj:removeAllChildren()
        funIterChild(widget, cloneObj)

        self:copySpecialProperties(cloneObj, widget)
    end

    self:copyClonedWidgetChildren(cloneObj, widget)

    return cloneObj
end
-- end --

-- 对齐方式 Ctrl + E    Ctrl + H    Ctrl + 1    Ctrl + 2  Ctrl + 3    Ctrl + 4
function GUIEditor:SetAlignStyle(style)
    local minX, maxX, minY, maxY 
    local tWidgets  = {}
    local allWidth  = 0
    local allHeight = 0

    for _ = 1, #self._selWidgets do
        local widget = self._selWidgets[_]

        local anchor  = widget:getAnchorPoint()
        local _anpX   = anchor.x
        local _anpY   = anchor.y

        local size    = widget:getContentSize()
        local _width  = size.width
        local _height = size.height

        local wPos    = widget:getWorldPosition()
        local _wPosX  = wPos.x
        local _wPosY  = wPos.y

        if style == 1 then
            local _maxY  = _wPosY + _height * (1 - _anpY)
            if not maxY or maxY < _maxY then
                maxY = _maxY
            end
            tInsert(tWidgets, { widget = widget, wPos = wPos, size = size, anchor = anchor })
        elseif style == 2 then
            local _minY  = _wPosY - _height * _anpY
            if not minY or minY > _minY then
                minY = _minY
            end
            tInsert(tWidgets, { widget = widget, wPos = wPos, size = size, anchor = anchor })
        elseif style == 3 then
            local _minX  = _wPosX - _width * _anpX
            if not minX or minX > _minX then
                minX = _minX
            end
            tInsert(tWidgets, { widget = widget, wPos = wPos, size = size, anchor = anchor })
        elseif style == 4 then
            local _maxX  = _wPosX + _width * (1 - _anpX)
            if not maxX or maxX < _maxX then
                maxX = _maxX
            end
            tInsert(tWidgets, { widget = widget, wPos = wPos, size = size, anchor = anchor })
        elseif style == 5 then
            local _minX  = _wPosX - _width * _anpX
            if not minX or minX > _minX then
                minX = _minX
            end

            local _maxX  = _wPosX + _width * (1 - _anpX)
            if not maxX or maxX < _maxX then
                maxX = _maxX
            end

            allWidth = allWidth + _width
            tInsert(tWidgets, { key = _minX, widget = widget, wPos = wPos, size = size, anchor = anchor })
        elseif style == 6 then
            local _minY  = _wPosY - _height * _anpY
            if not minY or minY > _minY then
                minY = _minY
            end

            local _maxY  = _wPosY + _height * (1 - _anpY)
            if not maxY or maxY < _maxY then
                maxY = _maxY
            end

            allHeight = allHeight + _height
            tInsert(tWidgets, { key = _minY, widget = widget, wPos = wPos, size = size, anchor = anchor })
        end
    end

    local margin = 5
    if style == 5 then
        tSort(tWidgets, function ( a, b ) return a.key < b.key end)

        local remain = maxX - minX - allWidth
        if remain > 0 then
            margin = sformat("%.2f", remain / (#self._selWidgets - 1))
        end
    elseif style == 6 then
        tSort(tWidgets, function ( a, b ) return a.key < b.key  end)
        
        local remain = maxY - minY - allHeight
        if remain > 0 then
            margin = sformat("%.2f", remain / (#self._selWidgets - 1))
        end
    end

    for i = 1, #tWidgets do
        local d = tWidgets[i]

        if style == 1 then
            local widget = d.widget
            local height = d.size.height
            local anpY   = d.anchor.y
            local wPos   = d.wPos
            local realY  = maxY - height * (1 - anpY)
            local p = widget:getParent():convertToNodeSpace(cc.p(wPos.x, realY))
            widget:setPosition(p)
        elseif style == 2 then
            local widget = d.widget
            local height = d.size.height
            local anpY   = d.anchor.y
            local wPos   = d.wPos
            local realY  = minY + height * anpY
            local p = widget:getParent():convertToNodeSpace(cc.p(wPos.x, realY))
            widget:setPosition(p)
        elseif style == 3 then
            local widget = d.widget
            local width  = d.size.width
            local anpX   = d.anchor.x
            local wPos   = d.wPos
            local realX  = minX + width * anpX
            local p = widget:getParent():convertToNodeSpace(cc.p(realX, wPos.y))
            widget:setPosition(p)
        elseif style == 4 then
            local widget = d.widget
            local width  = d.size.width
            local anpX   = d.anchor.x
            local wPos   = d.wPos
            local realX  = maxX - width * (1 - anpX)
            local p = widget:getParent():convertToNodeSpace(cc.p(realX, wPos.y))
            widget:setPosition(p)
        elseif style == 5 then
            local widget = d.widget
            local width  = d.size.width
            local anpX   = d.anchor.x
            local wPos   = d.wPos
            local realX  = minX + width * anpX
            local p = widget:getParent():convertToNodeSpace(cc.p(realX, wPos.y))
            widget:setPositionX(p.x)
    
            minX = minX + width + margin
        elseif style == 6 then
            local widget = d.widget
            local height = d.size.height
            local anpY   = d.anchor.y
            local wPos   = d.wPos
            local realY  = minY + height * anpY
            local p = widget:getParent():convertToNodeSpace(cc.p(wPos.x, realY))
            widget:setPositionY(p.y)

            minY = minY + height + margin
        end
    end
end

-- 是否描边
function GUIEditor:IsOutline(render)
    local tType = tolua.type(render)
    if (tType == "ccui.Text" or tType == "cc.Label") and render:getLabelEffectType() == 1 then
        return true
    end
    return false
end

function GUIEditor:AddSystemTips(str)
    GUIHelper.CteateShowTips(self, self._systemTipsCells, str)
end

function GUIEditor:CreateRText(widget, first)
    widget.getDescription = function() 
        return "RText" 
    end

    local params = self:GetAttribeValue(widget, GUIAttributes.RICH_TEXT)

    local Text   = GUIHelper:GetStatus(params.Text)
    local Width  = GUIHelper:GetStatus(params.Width)
    local RSize  = GUIHelper:GetStatus(params.RSize)
    local RColor = GUIHelper:GetStatus(params.RColor)
    local RSpace = GUIHelper:GetStatus(params.RSpace)
    local LinkCB = GUIHelper:GetStatus(params.LinkCB)
    local RFace  = GUIHelper:GetStatus(params.RFace)

    local data = {
        Text = Text, Width = Width, RSize = RSize, RColor = RColor, RSpace = RSpace, LinkCB = LinkCB, RFace = RFace
    }

    if first then
        self:NBEx(widget, GUIAttributes.RICH_TEXT, {isNB = true, value = data})
    end

    self:SetAttribeValue(widget, GUIAttributes.RICH_TEXT, data)

    return GUI:RichText_Create(widget, "__RICHTEXT__", 0, 0, Text, Width, RSize, RColor, RSpace, LinkCB, RFace)
end

function GUIEditor:CreateEffect(widget, first)
    widget.getDescription = function() 
        return "Effect" 
    end

    local params = self:GetAttribeValue(widget, GUIAttributes.EFFECT)

    local type  = tonumber(params.type)  or 4
    local sfxID = tonumber(params.sfxID) or 1
    local sex   = tonumber(params.sex)   or 0
    local act   = tonumber(params.act)   or 0
    local dir   = tonumber(params.dir)   or 0
    local speed = tonumber(params.speed) or 1

    local data = {
        type = type, sfxID = sfxID, sex = sex, act = act, dir = dir, speed = speed
    }

    if first then
        self:NBEx(widget, GUIAttributes.EFFECT, {isNB = true, value = data})
    end

    self:SetAttribeValue(widget, GUIAttributes.EFFECT, data)

    return GUI:Effect_Create(widget, "__SFX__", 0, 0, type, sfxID, sex, act, dir, speed)
end

function GUIEditor:CreateItemShow(widget, first)
    widget.getDescription = function() 
        return "Item" 
    end
    
    local data = self:GetAttribeValue(widget, GUIAttributes.ITEM_SHOW)
    local itemData = {}
    for key, value in pairs(data) do
        itemData[key] = GUIHelper:GetStatus(value)
    end

    if first then
        self:NBEx(widget, GUIAttributes.EFFECT, {isNB = true, value = itemData})
    end

    self:SetAttribeValue(widget, GUIAttributes.ITEM_SHOW, itemData)

    local info = clone(itemData)
    info.look = false
    return GUI:ItemShow_Create(widget, "__ITEM__", 0, 0, info)
end

function GUIEditor:CreateModel(widget, first)
    widget.getDescription = function() 
        return "Model"
    end

    local feature = self:getModelData(widget)

    if first then
        self:NBEx(widget, GUIAttributes.EFFECT, {isNB = true, value = feature})
    end

    self:SetAttribeValue(widget, GUIAttributes.MODEL, feature)

    return GUI:UIModel_Create(widget, "__MODEL__", 0, 0, feature.sex, feature, feature.scale)
end

function GUIEditor:getModelData(widget)
    local function parse(str)
        return str and sgsub(str, "&", "|")
    end

    local keys = {
        clothEffectID  = 1,
        weaponEffectID = 1,
        shieldEffectID = 1,
        headEffectID   = 1,
        capEffectID    = 1,
        veilEfffectID  = 1
    }

    local feature = {sex = 0, scale = 1}

    local data = self:GetAttribeValue(widget, GUIAttributes.MODEL)
    for key, value in pairs(data) do
        local v = GUIHelper:GetStatus(value)
        if key == "sex" then
            feature[key] = v and (tonumber(v) or v) or 0
        elseif key == "scale" then
            feature[key] = v and (tonumber(v) or v) or 1
        elseif keys[key] then
            feature[key] = parse(v)
        else
            feature[key] = v
        end
    end

    return feature
end

function GUIEditor:CreateEquipShow(widget, first)
    widget.getDescription = function() 
        return "EquipShow" 
    end
    
    local data = self:GetAttribeValue(widget, GUIAttributes.EQUIP_SHOW)
    local info = {}
    for key, value in pairs(data) do
        info[key] = GUIHelper:GetStatus(value)
    end

    if first then
        self:NBEx(widget, GUIAttributes.EQUIP_SHOW, {isNB = true, value = info})
    end

    self:SetAttribeValue(widget, GUIAttributes.EQUIP_SHOW, info)

    local param = self:GetEquipShowParam(widget)

    return GUI:EquipShow_Create(widget, "__EQUIPSHOW__", 0, 0, param[1], param[2], param[3])
end

function GUIEditor:GetEquipShowParam(widget)
    local param = {}
    local pos, isHero, autoUpdate = nil, nil, nil
    local data = self:GetAttribeValue(widget, GUIAttributes.EQUIP_SHOW)
    local info = {}
    for key, value in pairs(data) do
        if key == "pos" then
            pos = value
        elseif key == "isHero" then
            isHero = value
        elseif key == "autoUpdate" then
            autoUpdate = value
        else
            info[key] = value
        end
    end
    info.look = false
    param[1] = tonumber(pos)
    param[2] = isHero == true
    param[3] = info
    param[4] = autoUpdate
    return param
end

-- NB 的属性
function GUIEditor:NBEx(widget, key, param)
    local isNB, value = param.isNB, param.value

    widget.setNBValue = function(self, key, value)
        self._NBValue_ = self._NBValue_ or {}
        self._NBValue_[key] = value
    end
    widget.setNB = function(self, key, value)
        self._NB_ = self._NB_ or {}
        self._NB_[key] = value
    end

    widget.getNBValue = function(self, key)
        return self._NBValue_ and self._NBValue_[key]
    end
    widget.IsNB = function(self, key)
        return self._NB_ and self._NB_[key] or false
    end
    
    widget:setNB(key, isNB)
    widget:setNBValue(key, value)
end

function GUIEditor:CopyNBAttribute(widget, srcWidget)
    for key, value in pairs(GUIAttributes) do
        local isNB = srcWidget.IsNB and srcWidget:IsNB(key)
        if isNB then
            self:NBEx(widget, key, {isNB = true, value = clone(srcWidget:getNBValue(key))})
        end
    end
end

function GUIEditor:InitNBAttribute(widget)
    for key, value in pairs(GUIAttributes) do
        local newKey = sformat("__%s__", value)
        local nbValue = widget[newKey]
        if key == GUIAttributes.RICH_TEXT then
            self:NBEx(widget, key, {isNB = nbValue and true or false, value = nbValue})
        elseif key == GUIAttributes.EQUIP_SHOW then
            local exStr = widget[sformat("__%s__", GUIAttributes.EQUIP_AUTO)]
            local nbTable = nbValue and cjson.decode(nbValue)
            local exTable = exStr and cjson.decode(exStr)
            if nbTable and exTable and next(exTable) then
                for k, v in pairs(exTable) do
                    nbTable[k] = v
                end
            end
            self:NBEx(widget, key, {isNB = nbValue and true or false, value = nbTable})
        else
            self:NBEx(widget, key, {isNB = nbValue and true or false, value = nbValue and cjson.decode(nbValue)})
        end
    end
end

function GUIEditor:SetAttribute(key1, key2, value)
    local data = self:GetAttribeValue(self._selWidget, key1)
    data[key2] = value --or nil
    self:NBEx(self._selWidget, key1, {isNB = true, value = data})
end

function GUIEditor:SetUIAttribute(uiWidget, widget, key1, key2)
    local data = self:GetAttribeValue(widget, key1)
    local value = data[key2] or ""
    uiWidget:setString(value)
end

function GUIEditor:SetUICheckAttribute(uiWidget, widget, key1, key2)
    local data = self:GetAttribeValue(widget, key1)
    local isSelect = GUIHelper:GetStatus(data[key2], false)
    uiWidget:setSelected(isSelect)
end

return GUIEditor