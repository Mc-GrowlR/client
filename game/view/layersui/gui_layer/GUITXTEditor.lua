local BaseLayer = requireLayerUI("BaseLayer")
local GUITXTEditor = class("GUITXTEditor", BaseLayer)

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

local funcQueue    = "FUNCQUEUE"
local mapsInput    = "keyMaps1"
local mapsSlider   = "keyMaps2"
local pData        = "pData"
local IsQueueFunc  = false
local IsPageFunc   = false
local IsPerFunc    = false
local IsInputFunc  = false
local IsSliderFunc = false
local IsButtonFunc = false
local IsChildUI    = false

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

local FormatType = {
    CCS = 1,
    VAR = 2,
    STR = 3
}

local SerVarNames = {}

local Attributes    = GUITXTEditorDefine.Attributes
local GUIAttributes = GUITXTEditorDefine.GUIAttributes
local FuncKeys      = GUITXTEditorDefine.FuncKeys
local GUIFuncKeys   = GUITXTEditorDefine.GUIFuncKeys
local GUITypeKeys   = GUITXTEditorDefine.GUITypeKeys

function GUITXTEditor:ctor()
    GUITXTEditor.super.ctor(self)

    -- 提醒消息
    self._systemTipsCells       = Queue.new()

    self._closeListener         = {}

    self._selWidgets            = {}
    self._selWidget             = nil
    self._selTreeNode           = nil
    self._copyWidget            = nil
    self._cutWidget             = nil

    -----------------------------------------------
    self._trigger               = {}

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
        [cc.KeyCode.KEY_DELETE] = {             -- Delete     删除选中项  
            callback = function ()
                self:onDeleteUI()
                self:SaveCache()
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


    self._CommonAttr = {
        ["TextField_Name"]    = { IMode = InputMode.STRLINE, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetName), SetUIWidget = handler(self, self.SetUIName) },
        ["TextField_NameTip"] = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetNameTip), SetUIWidget = handler(self, self.SetUINameTip) },
        ["TextField_AnrX"]    = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetAnrX), SetWidget = handler(self, self.SetAnrX), SetUIWidget = handler(self, self.SetUIAnrX) },
        ["TextField_AnrY"]    = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetAnrY), SetWidget = handler(self, self.SetAnrY), SetUIWidget = handler(self, self.SetUIAnrY) },
        ["TextField_PosX"]    = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetPosX), SetWidget = handler(self, self.SetPosX), SetUIWidget = handler(self, self.SetUIPosX) },
        ["TextField_PosY"]    = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetPosY), SetWidget = handler(self, self.SetPosY), SetUIWidget = handler(self, self.SetUIPosY) },
        ["TextField_Width"]   = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetWidth), SetWidget = handler(self, self.SetWidth), SetUIWidget = handler(self, self.SetUIWidth) },
        ["TextField_Height"]  = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetHeight), SetWidget = handler(self, self.SetHeight), SetUIWidget = handler(self, self.SetUIHeight) },
        ["TextField_Tag"]     = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetTag), SetWidget = handler(self, self.SetTag), SetUIWidget = handler(self, self.SetUITag) },
        ["TextField_Rotate"]  = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetRotate), SetWidget = handler(self, self.SetRotate), SetUIWidget = handler(self, self.SetUIRotate) },
        ["TextField_ScaleX"]  = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetScaleX), SetWidget = handler(self, self.SetScaleX), SetUIWidget = handler(self, self.SetUIScaleX) },
        ["TextField_ScaleY"]  = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetScaleY), SetWidget = handler(self, self.SetScaleY), SetUIWidget = handler(self, self.SetUIScaleY) },
        
        ["TextField_Opacity"] = { IMode = InputMode.STRLINE, RMode = InputMode.INT, Max = 100, t = 1, Completed = true, GetVal = handler(self, self.GetOpacity), SetWidget = handler(self, self.SetOpacity), SetUIWidget = handler(self, self.SetUIOpacity) },
        ["TextField_Visible"] = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, GetVal = handler(self, self.GetVisible), SetWidget = handler(self, self.SetVisible), SetUIWidget = handler(self, self.SetUIVisible) },
        ["TextField_Touched"] = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, GetVal = handler(self, self.GetTouched), SetWidget = handler(self, self.SetTouched), SetUIWidget = handler(self, self.SetUITouched) },

        ["Slider_Opacity"]    = { t = 3, func = handler(self, self.onSliderOpacityEvent) },

        ["Image_Mask_opacity"]= {},

        ["Image_Mask_AnrX"]   = {},
        ["Image_Mask_AnrY"]   = {},

        ["Image_Mask_Scale"]  = {},

        ["Image_Mask_Width"]  = {},
        ["Image_Mask_Height"] = {},

        ["Image_Mask_Touch"]  = {},

        ["Image_Mask_Swallow"]= {},

        ["CheckBox_Swallow"]  = { t = 2, SetUIWidget = handler(self, self.SetUISwallow), func = handler(self, self.onItemSwallowEvent) },

        ["Image_Mask_ID"]     = {},
        ["TextField_ID"]      = { IMode = InputMode.INT, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetID), SetUIWidget = handler(self, self.SetUIID) },
        ["TextField_RedID"]   = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetRedID), SetUIWidget = handler(self, self.SetUIRedID) },
        ["TextField_GuideID"] = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetGuideID), SetUIWidget = handler(self, self.SetUIGuideID) },
    }

    self._SpecialAttr = {
        ["TextField_C"]             = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetColorC), SetUIWidget = handler(self, self.SetUIColorC) },
        ["Button_Color"]            = { t = 2, func = handler(self, self.onOpenClolorSelector), callfunc = handler(self, self.onColorSetCallFunc) },
        ["Panel_Preview"]           = {},

        ["TextField_Outline_C"]     = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetColorOutlineC), SetUIWidget = handler(self, self.SetUIColorOutlineC) },
        ["Button_Outline_Color"]    = { t = 2, func = handler(self, self.onOpenClolorSelector), callfunc = handler(self, self.onColorOutlineSetCallFunc) }, 
        ["Panel_Outline_Preview"]   = {},

        ["TextField_Press_C"]       = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetColorButtonPressC), SetUIWidget = handler(self, self.SetUIColorButtonPressC) },
        ["Button_Press_Color"]      = { t = 2, func = handler(self, self.onOpenClolorSelector), callfunc = handler(self, self.onColorButtonPressSetCallFunc) },
        ["Panel_Press_Preview"]     = {},
        
        ["TextField_Text"]          = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, GetVal = handler(self, self.GetText), SetWidget = handler(self, self.SetText), SetUIWidget = handler(self, self.SetUIText) },
        ["TextField_More_Text"]     = { IMode = InputMode.STRLINE, RMode = InputMode.ANY, t = 1, Completed = true, GetVal = handler(self, self.GetText), SetWidget = handler(self, self.SetMoreText), SetUIWidget = handler(self, self.SetUIMoreText) },
        ["TextField_FontSize"]      = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetFontSize), SetUIWidget = handler(self, self.SetUIFontSize) },
        
        ["TextField_Outline_Width"] = { IMode = InputMode.INT, Min = 1, Completed = true, t = 1, SetWidget = handler(self, self.SetOutlineWidth), SetUIWidget = handler(self, self.SetUIOutlineWidth) },

        ["TextField_N_Res"]         = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, Completed = true, t = 1, NotNowRef = true, GetVal = handler(self, self.GetNorRes), SetWidget = handler(self, self.SetNorRes), SetUIWidget = handler(self, self.SetUINorRes) },
        ["TextField_P_Res"]         = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, Completed = true, t = 1, NotNowRef = true, GetVal = handler(self, self.GetPreRes), SetWidget = handler(self, self.SetPreRes), SetUIWidget = handler(self, self.SetUIPreRes) },
        ["TextField_D_Res"]         = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, Completed = true, t = 1, NotNowRef = true, GetVal = handler(self, self.GetDisRes), SetWidget = handler(self, self.SetDisRes), SetUIWidget = handler(self, self.SetUIDisRes) },
    
        ["Button_N_Res"]            = { t = 2, func = handler(self, self.onOpenGUIResSelector), callfunc = handler(self, self.onResNSetCallFunc) },
        ["Button_P_Res"]            = { t = 2, func = handler(self, self.onOpenGUIResSelector), callfunc = handler(self, self.onResPSetCallFunc) },
        ["Button_D_Res"]            = { t = 2, func = handler(self, self.onOpenGUIResSelector), callfunc = handler(self, self.onResDSetCallFunc) },

        ["TextField_CapInset_L"]    = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetCapInsetL), SetUIWidget = handler(self, self.SetUICapInsetL) },
        ["TextField_CapInset_R"]    = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetCapInsetR), SetUIWidget = handler(self, self.SetUICapInsetR) },
        ["TextField_CapInset_T"]    = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetCapInsetT), SetUIWidget = handler(self, self.SetUICapInsetT) },
        ["TextField_CapInset_B"]    = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetCapInsetB), SetUIWidget = handler(self, self.SetUICapInsetB) },

        ["TextField_Alignment"]     = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetAlignment), SetUIWidget = handler(self, self.SetUIAlignment) },
        ["TextField_Margin"]        = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMargin), SetUIWidget = handler(self, self.SetUIMargin) },

        ["TextField_Scl_Width"]     = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetInnerWidth), SetWidget = handler(self, self.SetInnerWidth), SetUIWidget = handler(self, self.SetUIInnerWidth) },
        ["TextField_Scl_Height"]    = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetInnerHeight), SetWidget = handler(self, self.SetInnerHeight), SetUIWidget = handler(self, self.SetUIInnerHeight) },
        ["TextField_Bg_Opacity"]    = { IMode = InputMode.STRLINE, RMode = InputMode.INT, Max = 100, t = 1, Completed = true, SetWidget = handler(self, self.SetBgTextOpacity), SetUIWidget = handler(self, self.SetUITextBgOpacity) },
        
        ["TextField_EffectID"]      = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectID), SetUIWidget = handler(self, self.SetUIEffectID) },
        ["TextField_EffectType"]    = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectType), SetUIWidget = handler(self, self.SetUIEffectType) },
        ["TextField_Sex"]           = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Max = 1, Completed = true, SetWidget = handler(self, self.SetEffectSex), SetUIWidget = handler(self, self.SetUIEffectSex) },
        ["TextField_Action"]        = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectAction), SetUIWidget = handler(self, self.SetUIEffectAction) },
        ["TextField_Dir"]           = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectDir), SetUIWidget = handler(self, self.SetUIEffectDir) },
        ["TextField_Speed"]         = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetEffectSpeed), SetUIWidget = handler(self, self.SetUIEffectSpeed) },

        ["TextField_FirstChat"]     = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetFristChat), SetUIWidget = handler(self, self.SetUIFristChat) },
        ["TextField_Chat_Width"]    = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetChatWidth), SetUIWidget = handler(self, self.SetUIChatWidth) },
        ["TextField_Chat_Height"]   = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetChatHeight), SetUIWidget = handler(self, self.SetUIChatHeight) },

        ["TextField_Space"]         = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetRTextSpace), SetUIWidget = handler(self, self.SetUIRTextSpace) },
        
        ["TextField_ItemID"]        = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetItemID), SetUIWidget = handler(self, self.SetUIItemID) },
        ["TextField_Item_Num"]      = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetItemNum), SetUIWidget = handler(self, self.SetUIItemNum) },
        ["TextField_Item_Data"]     = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetItemData), SetUIWidget = handler(self, self.SetUIItemData) },
        ["TextField_Item_From"]     = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetItemFrom), SetUIWidget = handler(self, self.SetUIItemFrom) },
        ["TextField_Item_FontSize"] = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetItemFontSize), SetUIWidget = handler(self, self.SetUIItemFontSize) },
        ["TextField_Item_FontColor"]= { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetItemFontColor), SetUIWidget = handler(self, self.SetUIItemFontColor) },

        ["Image_Mask_l"] = {},
        ["Image_Mask_r"] = {},
        ["Image_Mask_t"] = {},
        ["Image_Mask_b"] = {},

        ["Image_Mask_Opacity"]  = {},
        ["Image_Mask_Color"]    = {},

        ["Image_Mask_Outline_Color"] = {},
        ["Image_Mask_Outline_Width"] = {},

        ["Image_Mask_MsgParam3"] = {},

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
        ["TextField_Msg_Text"]   = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgText), SetUIWidget = handler(self, self.SetUIMsgText) },
        ["TextField_MsgID"]      = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgID), SetUIWidget = handler(self, self.SetUIMsgID) },
        ["TextField_Msg_P1"]     = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgParam1), SetUIWidget = handler(self, self.SetUIMsgParam1) },
        ["TextField_Msg_P2"]     = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgParam2), SetUIWidget = handler(self, self.SetUIMsgParam2) },
        ["TextField_Msg_P3"]     = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMsgParam3), SetUIWidget = handler(self, self.SetUIMsgParam3) },
        
        ["CheckBox_Msg"]         = { t = 2, SetUIWidget = handler(self, self.SetUILuaMsg), func = handler(self, self.onLuaMsgEvent) },

        -- Click
        ["TextField_Click"]      = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetClickFunc), SetUIWidget = handler(self, self.SetUIClickFunc) },
        ["CheckBox_Click"]       = { t = 2, SetUIWidget = handler(self, self.SetUIClick), func = handler(self, self.onClickEvent) },

        -- 倒计时
        ["CheckBox_CountDown"]   = { t = 2, SetUIWidget = handler(self, self.SetUICountDown), func = handler(self, self.onCountDownEvent) },
        ["TextField_CDFunc"]     = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetCDFunc), SetUIWidget = handler(self, self.SetUICDFunc) },
        ["TextField_EndTime"]    = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, GetVal = handler(self, self.GetEndTime), SetWidget = handler(self, self.SetEndTime), SetUIWidget = handler(self, self.SetUIEndTime) },

        -- Container
        ["TextField_ChildID"]    = { IMode = InputMode.INT, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetChildID), SetUIWidget = handler(self, self.SetUIChildID) },
        ["TextField_ChildNum"]   = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetChildNum), SetUIWidget = handler(self, self.SetUIChildNum) },
        ["TextField_JumpID"]     = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, NotNowRef = true, SetWidget = handler(self, self.SetJumpIndex), SetUIWidget = handler(self, self.SetUIJumpIndex) },
    
        ["TextField_CWidth"]     = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetWidth), SetWidget = handler(self, self.SetCellWidth), SetUIWidget = handler(self, self.SetUICellWidth) },
        ["TextField_CHeight"]    = { IMode = InputMode.STRLINE, RMode = InputMode.FLOAT, t = 1, Completed = true, GetVal = handler(self, self.GetHeight), SetWidget = handler(self, self.SetCellHeight), SetUIWidget = handler(self, self.SetUICellHeight) },

        -- ScrollView 多行
        ["Image_Mask_Margin_x"] = {},
        ["Image_Mask_Margin_y"] = {},
        ["Image_Mask_Margin_l"] = {},
        ["Image_Mask_Margin_t"] = {},
        ["Image_Mask_Colnum"]   = {},
        ["Image_Mask_AddDir"]   = {},

        ["TextField_Margin_X"]  = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMarginX), SetUIWidget = handler(self, self.SetUIMarginX) },
        ["TextField_Margin_Y"]  = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMarginY), SetUIWidget = handler(self, self.SetUIMarginY) },
        ["TextField_Margin_L"]  = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMarginL), SetUIWidget = handler(self, self.SetUIMarginL) },
        ["TextField_Margin_T"]  = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMarginT), SetUIWidget = handler(self, self.SetUIMarginT) },

        ["TextField_Colnum"]    = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetColnum), SetUIWidget = handler(self, self.SetUIColnum) },
        ["TextField_AddDir"]    = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetAddDir), SetUIWidget = handler(self, self.SetUIAddDir) },

        ["CheckBox_MoreRow"]    = { t = 2, SetUIWidget = handler(self, self.SetUISViewMoreRow), func = handler(self, self.onSViewMoreRowEvent) },
        ["CheckBox_PlayAction"] = { t = 2, SetUIWidget = handler(self, self.SetUISViewPlayAction), func = handler(self, self.onSViewPlayActionEvent) },

        ["CheckBox_ButtonPage"] = { t = 2, SetUIWidget = handler(self, self.SetUIButtonPage), func = handler(self, self.onButtonPageEvent) },

        ["TextField_AttachUI"]  = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetAttachUI), SetUIWidget = handler(self, self.SetUIAttachUI)},
    
        -- LoadingBar
        ["TextField_Bar_Interval"]  = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetBarInterval), SetUIWidget = handler(self, self.SetUIBarInterval) },
        ["TextField_Bar_Step"]      = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetBarStep), SetUIWidget = handler(self, self.SetUIBarStep) },

        ["TextField_Bar_LVisible"]  = { IMode = InputMode.INT, Min = 0, Max = 1, t = 1, Completed = true, SetWidget = handler(self, self.SetBarLabelVisible), SetUIWidget = handler(self, self.SetUIBarLabelVisible) },
        ["TextField_Bar_Lx"]        = { IMode = InputMode.FLOAT, t = 1, Completed = true, SetWidget = handler(self, self.SetBarLabelX), SetUIWidget = handler(self, self.SetUIBarLabelX) },
        ["TextField_Bar_Ly"]        = { IMode = InputMode.FLOAT, t = 1, Completed = true, SetWidget = handler(self, self.SetBarLabelY), SetUIWidget = handler(self, self.SetUIBarLabelY) },
        ["TextField_Bar_LSIze"]     = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetBarLabelSize), SetUIWidget = handler(self, self.SetUIBarLabelSize) },
        
        ["TextField_LBar_LC"]       = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetColorLBarLabel), SetUIWidget = handler(self, self.SetUIColorLBarLabel) },
        ["Button_LBar_LColor"]      = { t = 2, func = handler(self, self.onOpenClolorSelector), callfunc = handler(self, self.onColorLBarLColorSetCallFunc) },
        ["Panel_LBar_LPreview"]     = {},

        -- Input
        ["TextField_P_Text"]        = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetInputPlaceholder), SetUIWidget = handler(self, self.SetUIInputPlaceholder) },
        ["TextField_Lenth"]         = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetInputMaxLenth), SetUIWidget = handler(self, self.SetUIInputMaxLenth) },

        ["TextField_IType"]         = { IMode = InputMode.INT, t = 1, Min = 0, Max = 3, Completed = true, SetWidget = handler(self, self.SetInputType), SetUIWidget = handler(self, self.SetUIInputType) },
        ["TextField_IID"]           = { IMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetInputID), SetUIWidget = handler(self, self.SetUIInputID) },

        ["CheckBox_Cipher"]         = { t = 2, SetUIWidget = handler(self, self.SetUICBCipher), func = handler(self, self.onCBCipherEvent) },
        ["CheckBox_Sensitive"]      = { t = 2, SetUIWidget = handler(self, self.SetUIISensitive), func = handler(self, self.onCBSensitiveEvent) },

        ["TextField_C2"]            = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetColorInputPlaceHolder), SetUIWidget = handler(self, self.SetUIColorInputPlaceHolder) },
        ["Button_Color2"]           = { t = 2, func = handler(self, self.onOpenClolorSelector), callfunc = handler(self, self.onColorInputPlaceHolderColorSetCallFunc) },
        ["Panel_Preview2"]          = {},

        ["TextField_Value"]         = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetPerValue), SetUIWidget = handler(self, self.SetUIPerValue) },
        ["TextField_MaxValue"]      = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMaxPerValue), SetUIWidget = handler(self, self.SetUIPerMaxValue) },
        ["TextField_InputIDs"]      = { IMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetInputIDs), SetUIWidget = handler(self, self.SetUIInputIDs) },

        -- Model
        ["TextField_MSex"]          = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetSex), SetUIWidget = handler(self, self.SetUISex) },
        ["TextField_MScale"]        = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetMScale), SetUIWidget = handler(self, self.SetUIMScale) },
        ["TextField_HairID"]        = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetHairID), SetUIWidget = handler(self, self.SetUIHairID) },
        ["TextField_HeadID"]        = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetHeadID), SetUIWidget = handler(self, self.SetUIHeadID) },
        ["TextField_HeadEffID"]     = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetHeadEffID), SetUIWidget = handler(self, self.SetUIHeadEffID) },
        ["TextField_ClothID"]       = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetClothID), SetUIWidget = handler(self, self.SetUIClothID) },
        ["TextField_ClothEffID"]    = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetClothEffID), SetUIWidget = handler(self, self.SetUIClothEffID) },
        ["TextField_WeaponID"]      = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetWeaponID), SetUIWidget = handler(self, self.SetUIWeaponID) },
        ["TextField_WeaponEffID"]   = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetWeaponEffID), SetUIWidget = handler(self, self.SetUIWeaponEffID) },
        ["TextField_ShieldID"]      = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetShieldID), SetUIWidget = handler(self, self.SetUIShieldID) },
        ["TextField_ShieldEffID"]   = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetShieldEffID), SetUIWidget = handler(self, self.SetUIShieldEffID) },
        ["TextField_CapID"]         = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetCapID), SetUIWidget = handler(self, self.SetUICapID) },
        ["TextField_CapEffID"]      = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetCapEffID), SetUIWidget = handler(self, self.SetUICapEffID) },
        ["TextField_VeilID"]        = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetVeilID), SetUIWidget = handler(self, self.SetUIVeilID) },
        ["TextField_VeilEffID"]     = { IMode = InputMode.STRLINE, RMode = InputMode.STRLINE, t = 1, Completed = true, SetWidget = handler(self, self.SetVeilEffID), SetUIWidget = handler(self, self.SetUIVeilEffID) },
        ["TextField_ShowMold"]      = { IMode = InputMode.INT, t = 1, Min = 0, Max = 1, Completed = true, SetWidget = handler(self, self.SetShowMold), SetUIWidget = handler(self, self.SetUIShowMold) },
        ["TextField_ShowHair"]      = { IMode = InputMode.INT, t = 1, Min = 0, Max = 1, Completed = true, SetWidget = handler(self, self.SetShowHair), SetUIWidget = handler(self, self.SetUIShowHair) },

        -- 变灰
        ["TextField_SetGrey"]       = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetSetGrey), SetUIWidget = handler(self, self.SetUISetGrey) },

        -- 选择描述
        ["Button_IType"]            = { t = 99, func = handler(self, self.onArrEvent), TextUI = "TextField_IType", DataTips = {
                                            {key = 0, tip = "0: 任意类型"},
                                            {key = 1, tip = "1: 数字"},
                                            {key = 2, tip = "2: 密码"},
                                            {key = 3, tip = "3: 数字绝对值"} 
                                        }
                                    },

        ["Button_ShowMold"]         = { t = 99, func = handler(self, self.onArrEvent), TextUI = "TextField_ShowMold", DataTips = {
                                            {key = 0, tip = "0: 不显示"},
                                            {key = 1, tip = "1: 显示"}
                                        }
                                    },

        ["Button_ShowHair"]         = { t = 99, func = handler(self, self.onArrEvent), TextUI = "TextField_ShowHair", DataTips = {
                                            {key = 0, tip = "0: 不显示"},
                                            {key = 1, tip = "1: 显示"},
                                        }
                                    },

        -- EquipShow
        ["TextField_EquipPos"]              = { IMode = InputMode.STRLINE, RMode = InputMode.INT, t = 1, Completed = true, SetWidget = handler(self, self.SetEquipPos), SetUIWidget = handler(self, self.SetUIEquipPos) },
        ["CheckBox_Equip_Look"]             = { t = 2, SetUIWidget = handler(self, self.SetUIEquipLook), func = handler(self, self.onEquipLookEvent) },
        ["CheckBox_Equip_ShowBg"]           = { t = 2, SetUIWidget = handler(self, self.SetUIEquipShowBg), func = handler(self, self.onEquipShowBgEvent) },
        ["CheckBox_Equip_ShowStar"]         = { t = 2, SetUIWidget = handler(self, self.SetUIEquipShowStar), func = handler(self, self.onEquipShowStarEvent) },
        ["CheckBox_Equip_autoUpdate"]       = { t = 2, SetUIWidget = handler(self, self.SetUIEquipAutoUpdate), func = handler(self, self.onEquipAutoUpdateEvent)},
        ["CheckBox_Equip_isHero"]           = { t = 2, SetUIWidget = handler(self, self.SetUIEquipIsHero), func = handler(self, self.onEquipIsHeroEvent)},
        ["CheckBox_Equip_onDouble"]         = { t = 2, SetUIWidget = handler(self, self.SetUIEquipOnDouble), func = handler(self, self.onEquipAddDoubleEvent)},
        ["CheckBox_Equip_onMove"]           = { t = 2, SetUIWidget = handler(self, self.SetUIEquipOnMove), func = handler(self, self.onEquipAddMoveEvent)},
    }
end

function GUITXTEditor:onArrEvent(ref, eventType)
    if eventType ~= 2 then
        return false
    end

    if ref:getRotation() == -90 then
        self._Panel_Condition:setVisible(false)
        ref:setRotation(90)
        return false
    end

    local listBG = self._Panel_Condition:getChildByName("List_bg")

    local list = listBG:getChildByName("ListView_condition")
    list:removeAllChildren()

    local item = listBG:getChildByName("item_condition")

    local name = ref.TextUI
    local data = ref.DataTips or {}

    local value = self._selUISpecialControl[name]:getString() or 0
    value = tonumber(value)

    local size = {width = 0, height = -5}
    for _, v in ipairs(data) do
        if v.key then
            local w = item:getChildByName("text"):setString(v.tip):getContentSize().width
            size.height = size.height + 35
            size.width  = math.max(w, size.width)
        end
    end
    local listw = size.width + 10
    local listh = size.height
    list:setContentSize({width = listw, height = listh})
    item:setContentSize({width = listw, height = 30})
    item:getChildByName("select"):setContentSize({width = listw, height = 30})
    item:getChildByName("text"):setPositionX(listw / 2)
    listBG:setContentSize({width = listw + 10, height = listh + 10})

    local addItem = function (key, tip)
        local item = item:clone()
        list:pushBackCustomItem(item)
        item:setTag(key)
        item:setVisible(true)

        item:getChildByName("text"):setString(tip)

        local isSel = value == key
        item:getChildByName("select"):setVisible(isSel)

        item:addClickEventListener(function ()
            self._selUISpecialControl[name]:setString(key)
            self:updateCommonAttr(name, key)
            self:updateSpecialAttr(name, key)
            self:onArrEvent(ref, 2)
        end)

        item:setTouchEnabled(true)
    end

    for _, v in ipairs(data) do
        local key, tip = v.key, v.tip
        if key then
            addItem(key, tip)
        end
    end

    local p = cc.p(ref:getWorldPosition())
    listBG:setPosition(cc.p(p.x, p.y + 15))

    self._Panel_Condition:setVisible(true)
    ref:setRotation(-90)
end

function GUITXTEditor.create()
    local layer = GUITXTEditor.new()
    if layer:init() then
        return layer
    end
    return nil
end

function GUITXTEditor:init()
    local root = CreateExport("gui_txt_editor/main_editor.lua")
    if not root then
        return false
    end
    self:addChild(root)

    local cells = CreateExport("gui_txt_editor/main_cells.lua")
    root:getChildByName("Panel_sys"):addChild(cells)

    self._quickUI = ui_delegate(root:getChildByName("Panel_sys"))

    self._Text_Cur_Dir = root:getChildByName("Text_Cur_Dir")
    self._Node_UI = root:getChildByName("Node_ui")

    self._Panel_Condition = root:getChildByName("Panel_condition")
    self._Panel_Condition:addClickEventListener(function ()
        self._Panel_Condition:setVisible(false)
    end)
    self._Panel_Condition:setSwallowTouches(false)
    self._Panel_Condition:setContentSize(cc.size(visibleSize.width, visibleSize.height))
    
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

    self._cfgs = requireGameConfig("cfg_gui_editor")

    -- 隐藏帧率
    global.Director:setDisplayStats(false)

    self:cleanup()

    -- 文件页
    self._quickUI.Button_file:addClickEventListener(handler(self, self.onFile))
    -- 关闭GUITXTEditor
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

    -- 变量管理UI
    self._quickUI.Button_varManage:addClickEventListener(handler(self, self.onOpenGUIVarManager))

    -- 确定创建
    self._quickUI.Button_ok:addClickEventListener(handler(self, self.onCreateOk))

    -- 取消创建
    self._quickUI.Button_cancel:addClickEventListener(handler(self, self.onCreateCancel))

    -- 创建界面
    self._quickUI.Button_createWin:setVisible(false)
    self._quickUI.Button_createWin:addClickEventListener(handler(self, self.onCreateWin))

    -- 确定创建界面
    self._quickUI.Button_ok_win:addClickEventListener(handler(self, self.onCreateWinOk))

    -- 取消创建界面
    self._quickUI.Button_cancel_win:addClickEventListener(handler(self, self.onCreateWinCancel))

    -- 删除控件
    self._quickUI.Button_Delete:addClickEventListener(handler(self, self.onDeleteUI))

    -- 保存到本地
    self._quickUI.Button_Save:addClickEventListener(handler(self, self.onSaveFile))

    -- 中英文切换
    self._quickUI.Button_Language:addClickEventListener(handler(self, self.onLanguage))

    -- 高级属性
    self._quickUI.Button_Special:addClickEventListener(handler(self, self.onOpenSpecialAtt))

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

    self._quickUI.TextField_Create_win_ID:setTextHorizontalAlignment(1)
    self._quickUI.TextField_Create_win_ID:setCursorEnabled(true)

    self._quickUI.TextField_Create_File_Name_win:setTextHorizontalAlignment(1)
    self._quickUI.TextField_Create_File_Name_win:setCursorEnabled(true)

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

    self:initDefaultPath()

    GUI:UserUILayout(self._quickUI.ScrollView_Button, { dir = 3, x = 8, y = 8, l = 4, t = 4, colnum = 5, sortfunc = function (list)
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

function GUITXTEditor:setButtonLanguageText(lang)
    self._quickUI.Button_Language:setTitleText(({[0] = "英文", [1] = "中文"})[lang])
end

function GUITXTEditor:SetSaveLocalValue(key, value)
    local userData = UserData:new("GUI_Editor_Cfg")
    userData:setStringForKey(key, cjson.encode(value))
    userData:writeMapDataToFile()
end

function GUITXTEditor:GetSaveLoacalValue(key)
    local userData = UserData:new("GUI_Editor_Cfg")
    local jsonStr  = userData:getStringForKey(key, "")
    if jsonStr and slen(jsonStr) > 0 then
        return cjson.decode(jsonStr)
    end
end

function GUITXTEditor:initDefaultPath()
    if global.isGMMode then
        self._defaultPath = gmFolder
    else
        local key = self:GetSaveLoacalValue("path")
        self._defaultPath = key == 2 and gmFolder or exportFolder 
    end
    self._quickUI.Text_save_path:setString(self._defaultPath)
end

function GUITXTEditor:onSaveAll()
    self._quickUI.Panel_pop:setVisible(true)
    GUI:Timeline_Window1(self._quickUI.Panel_pop_image)
end

function GUITXTEditor:onClosePop()
    self._quickUI.Panel_pop:setVisible(false)
end

function GUITXTEditor:onPopSave()
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
            global.Facade:sendNotification(global.NoticeTable.Layer_GUITXTEditor_Close)
            return false
        end
        local fullfile = d.fullfile
        self:open(self:findFileRoot(d.flag), fullfile)
        self:onSaveFile()
    end, 1/60)
end

function GUITXTEditor:IsDirectory(file)
    return fileUtil:isDirectoryExist(file)
end

-- 向上查找文件夹内容
function GUITXTEditor:onKeyBackSpace()
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

function GUITXTEditor:onKeyEnter()
    if not (self._selFileInfo and next(self._selFileInfo)) then
        self._Text_Cur_Dir:setString("")
        return false
    end
    if self._selFileInfo.isDir then
        self._selDirctor = self._selFileInfo.fullfile
        self._files = self:getAllFiles()
        self:updateAllFiles()
    else
        self:open(self._selFileInfo.root, self._selFileInfo.fullfile, self._selFileInfo.file)
    end
end

function GUITXTEditor:getFileName(str)
    local rerStr = sreverse(str)
    local _, i   = sfind(rerStr, "/")
    local len    = slen(str)
    local st     = len - i + 2
    return ssub(str, st, len)
end
    
function GUITXTEditor:getAllFiles()
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

function GUITXTEditor:InitAlignStyleEvent()
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

function GUITXTEditor:initAttrControl()
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
                    if d.RMode then
                        self._selUICommonControl[name]:setMaxLength(999)
                    end
                elseif d.t == 2 then
                    self._selUICommonControl[name] = widget
                    self._selUICommonControl[name]:addClickEventListener(d.func)
                elseif d.t == 3 then
                    self._selUICommonControl[name] = widget
                    self._selUICommonControl[name]:addEventListener(d.func)
                elseif d.t == 99 then
                    self._selUICommonControl[name].TextUI = d.TextUI
                    self._selUICommonControl[name].DataTips = d.DataTips
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

function GUITXTEditor:initTextFieldEvent(widget)
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
        local rmode     = data.RMode
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
                if tonumber(str) then
                    if rmode == InputMode.FLOAT then
                        str = CheckIntValue(sformat("%.2f", tonumber(str)), min, max)
                    elseif rmode == InputMode.INT then
                        str = CheckIntValue(tonumber(str), min, max)
                    end
                elseif rmode == InputMode.FLOAT or rmode == InputMode.INT then
                    if slen(str or "") < 1 then
                        sender:setString(self._InputValues[name] or (GetVal and GetVal() or ""))
                        return false
                    end

                    local name = GUIHelper.GetSerVarName(str)
                    if name then
                        SerVarNames[name] = 1
                    end
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

function GUITXTEditor:onClose()
    for _, listener in pairs(self._closeListener) do
        listener()
    end
    self._quickUI.ScrollView_files:removeAllChildren()
end

function GUITXTEditor:addCloseEventListener(listener)
    tInsert(self._closeListener, listener)
end

-- 退出
function GUITXTEditor:onCloseUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_GUITXTEditor_Close)
end

function GUITXTEditor:addScrollInTree()
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
function GUITXTEditor:onChange(ref, eventType)
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
function GUITXTEditor:onNodeTreeChange(ref, eventType)
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
function GUITXTEditor:onFile(ref, eventType)
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

function GUITXTEditor:onKeyEsc()
    if self._quickUI.Panel_files:isVisible() then
        return self:hideFiles()
    end
    if self._quickUI.Button_change:getTag() == 1 then
        return self:onChange(self._quickUI.Button_change)
    end
    self:stopAllActions()
    self:onCloseUI()
end

function GUITXTEditor:onCreateFile(ref, eventType)
    self._quickUI.Panel_create_file:setVisible(true)
    self._quickUI.ScrollView_files:setVisible(false)
    self._quickUI.TextField_Create_File_Name:setString("")
end

function GUITXTEditor:onOpenFile(ref, eventType)
    self._selDirctor = nil
    self._files = self:getAllFiles()
    self:updateAllFiles()
    self._quickUI.Panel_create_file:setVisible(false)
    self._quickUI.ScrollView_files:setVisible(true)
end

function GUITXTEditor:onRefFile()
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

function GUITXTEditor:onCreateWin()
    self._quickUI.Panel_create_win:setVisible(true)
    self._quickUI.ScrollView_files:setVisible(false)
    self._quickUI.TextField_Create_File_Name_win:setString("")
    self._quickUI.TextField_Create_win_ID:setString("")
end


function GUITXTEditor:CheckTXTWinIDConfig()
    if SL:IsFileExist("scripts/game_config/cfg_win_export.lua") 
        or SL:IsFileExist("scripts/game_config/cfg_win_export.luac") then
        self._ExWinConfig = SL:RequireFile("game_config/cfg_win_export")
    end

    self._ExWinConfig = self._ExWinConfig or {}
end

function GUITXTEditor:onCreateWinOk()
    local str = self._quickUI.TextField_Create_File_Name_win:getString()

    local idStr = self._quickUI.TextField_Create_win_ID:getString()

    if slen(idStr or "") < 1 then
        return self:AddSystemTips(sformat("<font color = '%s'>请输入有效界面ID</fount>", "#FF0000"))
    end

    if slen(str or "") < 1 then
        return self:AddSystemTips(sformat("<font color = '%s'>请输入有效名字</fount>", "#FF0000"))
    end
    self._quickUI.ScrollView_files:setVisible(false)

    self:CheckTXTWinIDConfig()
    if self._ExWinConfig and self._ExWinConfig[idStr] then
        return self:AddSystemTips(sformat("<font color = '%s'>界面ID配置重复，请重新输入</fount>", "#FF0000"))
    end

    self:checkExportFolder()
    
    if self._selDirctor then
        self._defaultPath = self._defaultPath .. "/" .. self._selDirctor
    else
        self._defaultPath = gmFolder
        if not global.isGMMode and self:GetSaveLoacalValue("path") ~= 2 then
            self._defaultPath = exportFolder
        end
    end

    local filename = sformat("%s.lua", str)
    local filePath = sformat("%s/%s", self._defaultPath, filename)

    if fileUtil:isFileExist(filePath) then
        return self:AddSystemTips(sformat("<font color = '%s'>文件名重复，请重新命名</fount>", "#FF0000"))
    end

    self._ExWinConfig[idStr] = {file = (self._selDirctor or "") .. filename}
    SL:SaveTableToConfig(self._ExWinConfig, "cfg_win_export", nil, nil, true)

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

    self._selFileInfo = self._selFileInfo or {}
    self._selFileInfo.file = filename
    self._selFileInfo.fullfile = filename
    self:open(self._defaultPath, filename, filename)
    self:onCreateWinCancel()
end

function GUITXTEditor:onCreateWinCancel(ref, eventType)
    self._quickUI.Panel_create_win:setVisible(false)
    self._quickUI.ScrollView_files:setVisible(true)
    self._quickUI.TextField_Create_File_Name_win:setString("")
    self._quickUI.TextField_Create_win_ID:setString("")
end

function GUITXTEditor:onCtrlZ()

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

function GUITXTEditor:onCreateOk(ref, eventType)
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
        return self:AddSystemTips(sformat("<font color = '%s'>文件名重复，请重新命名</fount>", "#FF0000"))
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

function GUITXTEditor:onDeleteUI(ref, eventType)
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

function GUITXTEditor:onCreateCancel(ref, eventType)
    self._quickUI.Panel_create_file:setVisible(false)
    self._quickUI.TextField_Create_File_Name:setString("")
    self._quickUI.ScrollView_files:setVisible(false)
end

function GUITXTEditor:onCancelSelectNode(ref, eventType)
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

function GUITXTEditor:onTreeArrow(ref, eventType)
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

function GUITXTEditor:setTreeStatus(widget, status)
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

function GUITXTEditor:onTreeCellEvent(ref, eventType)
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

function GUITXTEditor:onSelectSavePath(ref, eventType)
    if global.isGMMode then
        return false
    end
    local panel_list = self._quickUI.Panel_path_list_bg
    local isVisible  = not panel_list:isVisible()
    panel_list:setVisible(isVisible)
end

function GUITXTEditor:onSureSavePath(ref, eventType)
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

function GUITXTEditor:showFiles()
    self._quickUI.ScrollView_files:setVisible(true)
    self._quickUI.Panel_files:setVisible(true)
end

function GUITXTEditor:hideFiles()
    self._quickUI.Panel_files:setVisible(false)
end

function GUITXTEditor:setListFileSelect(filename)
    local chidldrens = self._quickUI.ScrollView_files:getChildren()
    for k = 1, #chidldrens do
        local item = chidldrens[k]
        if item and item:isVisible() then
            local visible = item:getName() == filename
            item.cell_bg_2:setVisible(visible)
        end
    end
end

function GUITXTEditor:findFileRoot(flag)
    return flag == "GM" and gmFolder or (flag == "CACHE" and cacheFolder or exportFolder)
end

function GUITXTEditor:updateAllFiles()
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
                self:setListFileSelect(filename)

                if clickNum == 2 then
                    self:onKeyEnter()
                end
            end   
        end)
    end
    list:scrollToTop(0.01, false)
end

function GUITXTEditor:open(root, fullfile, file)
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
        self._selFileInfo.fullfile = self._selDirctor .. fullfile
    end

    self:SaveCache(source, true)

    self._NodePos = cc.p(self._Node_UI:getPosition())
end

function GUITXTEditor:initAdapet()
    local ww = visibleSize.width
    local hh = visibleSize.height
    self._quickUI.Panel_global:setPosition(cc.p(ww-4, hh-4))
    self._quickUI.Panel_button:setPosition(cc.p(ww, hh - 50))
    self._quickUI.Panel_shortcut:setPosition(cc.p(ww-500, hh-4))

    local atthh = hh - 225
    local attww = self._quickUI.Panel_attr:getContentSize().width

    self._quickUI.Panel_attr:setContentSize(cc.size(attww, atthh))
    self._quickUI.Panel_attr:setPosition(cc.p(ww, atthh))
    self._quickUI.Top_attr:setPositionY(atthh - 48)

    self._quickUI.ScrollView_attr:setContentSize(cc.size(attww, atthh-75))
    self._quickUI.ScrollView_attr:setPositionY(0)

    self._quickUI.Panel_files:setContentSize(cc.size(ww, hh))
    self._quickUI.Panel_files:setPosition(cc.p(0, 0))

    self._quickUI.Button_openfile:setPosition(cc.p(57, hh-29))
    self._quickUI.Button_createfile:setPosition(cc.p(57, hh-74))
    self._quickUI.Button_saveAll:setPosition(cc.p(57, hh-119))
    self._quickUI.Button_varManage:setPosition(cc.p(57, hh-164))
    self._quickUI.Button_createWin:setPosition(cc.p(57, hh-209))
    
    self._quickUI.ScrollView_files:setContentSize(cc.size(ww-536, hh-50))
    self._quickUI.ScrollView_files:setInnerContainerSize(cc.size(ww-536, hh-50))
    self._quickUI.ScrollView_files:setPosition(cc.p(220, hh-50))

    local bgWid = ww - 536
    self._quickUI.Panel_save_path_bg:setContentSize(bgWid, self._quickUI.Panel_save_path_bg:getContentSize().height)
    self._quickUI.Panel_path_list_bg:setContentSize(bgWid, self._quickUI.Panel_path_list_bg:getContentSize().height)
    self._quickUI.ListView_paths:setContentSize(bgWid, self._quickUI.ListView_paths:getContentSize().height)
    self._quickUI.bg_stab:setContentSize(bgWid, self._quickUI.bg_stab:getContentSize().height)
    self._quickUI.bg_dev:setContentSize(bgWid, self._quickUI.bg_dev:getContentSize().height)
    
    self._quickUI.Panel_save_path_bg:setPosition(cc.p(220, hh-25))
    self._quickUI.Text_save_path:setPosition(cc.p(222, hh-25))
    self._quickUI.Panel_path_list_bg:setPosition(cc.p(220, hh-43))
    self._quickUI.Panel_list_touch:setPosition(cc.p(-220, 103))
    self._quickUI.Panel_list_touch:setContentSize(cc.size(ww, hh))

    self._quickUI.Panel_create_file:setPosition(cc.p(ww/2-35, hh/2))
    self._quickUI.Panel_create_win:setPosition(cc.p(ww/2-35, hh/2))

    local treeww = self._quickUI.Panel_tree:getContentSize().width
    self._quickUI.Panel_tree:setContentSize(cc.size(treeww, hh-190))
    self._quickUI.Panel_tree:setPosition(cc.p(215, 0))

    self._quickUI.ScrollView_1:setContentSize(cc.size(200, hh-190))
    self._quickUI.ScrollView_1:setPositionY(0)

    self._quickUI.Button_tree:setPositionX(215)

    self._Text_Cur_Dir:setPositionY(hh)

    self._quickUI.Panel_pop:setContentSize(cc.size(ww, hh))

    self._quickUI.Panel_pop_image:setPosition(cc.p(ww/2, hh/2))

    self._quickUI.file_cell:setVisible(false)
    self._quickUI.tree_cell:setVisible(false)
end

function GUITXTEditor:initButton()
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
        ["Button_TableView"]    = "TableView",
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
function GUITXTEditor:setChildrenDepth(children, depth)
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
function GUITXTEditor:changeParent(node, newParent)
    node:retain()
    node:removeFromParent()
    newParent:addChild(node)
    node:release()
    if newParent:getDescription() == "ListView" then
        newParent:doLayout()
    end
end

-- 移除 node 节点下的所有子节点
function GUITXTEditor:removeOldParent(index, widget)
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

function GUITXTEditor:SetMaxValue(children)
    local max = 0
    for k,v in pairs(children) do
        if v and v > max then
            max = v
        end
    end
    return max+1
end

function GUITXTEditor:GetParent(parent)
    for k,v in pairs(parent) do
        if k then
            return k
        end
    end
    return false
end

-- node2 在 node1 的位置 ( flag: 0子控件, 1上面, 2下面）
function GUITXTEditor:changeNodeTree(node1, node2, flag)
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

function GUITXTEditor:insertTree(widget, ID, selWidget)
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

function GUITXTEditor:removeTree(widget)
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

function GUITXTEditor:getTreeIdxByObj(widget)
    for i = 1, #self._uiTree do
        local v = self._uiTree[i]
        if v and v.widget == widget then
            return i
        end
    end
    return false
end

-- 把 chidlren 转成有序 table
function GUITXTEditor:convertChildrenFormat(children)
    local t = {}
    for widget,code in pairs(children) do
        tInsert(t, {widget = widget, i = code })
    end
    if #t > 0 then
        tSort(t, function ( a, b ) return a.i < b.i end)
    end
    return t 
end

function GUITXTEditor:sortTree()
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

function GUITXTEditor:updateTreeName(name)
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

function GUITXTEditor:getNewID(names, str)
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

function GUITXTEditor:checkIDValid(ID)
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

function GUITXTEditor:createNewWidget(type)
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

            local data = self:GetAttribeValue(widget, GUIAttributes.LOADING_BAR)
            self:createLBarLabel(widget, data)

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
        ["TableView"] = function (ID)
            local parent = self._selWidget or self._Node_UI
            local widget = GUI:TableView_Create(parent, ID, 0, 0, defaultViewW, defaultViewH, 1, defaultViewW, 50, 0)
            GUI:TableView_setBackGroundColor(widget, "#969664")
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

    if (self._selDescription == "PageView" or self._selDescription == "TableView") and type ~= "Layout" then
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
    self:NBEx(widget, Attributes.X, {isNB = false, value = 0})
    self:NBEx(widget, Attributes.Y, {isNB = false, value = 0})
    self:setWidgetDrawRect(widget)

    self:updateTreeNodes()

    if self._selDescription == "ListView" then
        self._selWidget:jumpToBottom()
    end
end

function GUITXTEditor:addTextTreeName(node, depth)
    local x = 18 + (depth-1) * 10
    local TextTreeName = GUI:Text_Create(node, "TextTreeName", x, 12, 14, "#BFBFBF", "")
    GUI:setAnchorPoint(TextTreeName, 0, 0.5)
end

function GUITXTEditor:updateTreeNodes()
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

function GUITXTEditor:refreshTreeList()
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
function GUITXTEditor:onAttrBar(ref, eventType)
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

function GUITXTEditor:refAttrPostion()
    local bar1  = self._quickUI.Bar1
    local att1  = self._quickUI.Att1
    local barH  = GUI:getContentSize(bar1).height
    local open1 = self._barArrow[1] == 1

    if not self._selWidget then
        return false
    end

    -- 该组件是否可以发送消息
    local isMessage = self._selDescription == "Label" or self._selDescription == "Button" or self._selDescription == "ImageView" or self._selDescription == "Layout" or self._selDescription == "CheckBox"

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
    if bar3 and att3 then
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

function GUITXTEditor:refAttrList()
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
        ["ui_TableView"]    = "TableView",
        ["ui_Effect"]       = "Effect",
        ["ui_Item"]         = "Item",
        ["ui_Model"]        = "Model",
        ["ui_Widget"]       = "Widget",
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

    -- 该组件是否可以发送消息
    local isMessage = self._selDescription == "Label" or self._selDescription == "Button" or self._selDescription == "ImageView" or self._selDescription == "Layout" or self._selDescription == "CheckBox"

    local uiName = sformat("%s%s", "ui_", desp)
    root = CreateExport(sformat("gui_txt_editor/%s.lua", uiName)):getChildByName(uiName):clone()
    self._quickUI.Att3:addChild(root, 1, 999)
    IterAllChild(root, root)

    local rootEx = {}
    if isMessage then
        rootEx = CreateExport("gui_txt_editor/ui_Message.lua"):getChildByName("ui"):clone()
        self._quickUI.Att4:addChild(rootEx, 1, 999)

        IterAllChild(rootEx, rootEx)

        if self._selDescription == "CheckBox" then
            rootEx["a7"]:setVisible(false)
            rootEx["a8"]:setVisible(false)
            rootEx["Image_Mask_MsgParam3"]:setVisible(true)
            rootEx["Image_Mask_MsgParam3"]:setLocalZOrder(2)
        end

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
                    if d.RMode then
                        self._selUISpecialControl[name]:setMaxLength(999)
                    end
                elseif d.t == 2 then
                    self._selUISpecialControl[name] = widget
                    self._selUISpecialControl[name]:addClickEventListener(d.func)
                elseif d.t == 3 then
                    self._selUISpecialControl[name] = widget
                    self._selUISpecialControl[name]:addEventListener(d.func)
                elseif d.t == 99 then
                    self._selUISpecialControl[name] = widget
                    self._selUISpecialControl[name].TextUI = d.TextUI
                    self._selUISpecialControl[name].DataTips = d.DataTips
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

    self:refAttrPostion()
end

function GUITXTEditor:updateAttr()
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

    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
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
    elseif self._selDescription == "Label" or self._selDescription == "BmpText" or self._selDescription == "RText" or self._selDescription == "Item" or self._selDescription == "EquipShow" then
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

function GUITXTEditor:setCommonAttrUI()
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
        ["TableView"]    = "TableView",
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

function GUITXTEditor:setSpecialAttrUI()
    for name,_ in pairs(self._selUISpecialControl or {}) do
        if self._SpecialAttr[name] and self._SpecialAttr[name].SetUIWidget then
            self._SpecialAttr[name].SetUIWidget(self._selUISpecialControl[name], self._selWidget)
        end
    end
end

function GUITXTEditor:updateCommonAttr(name, value)
    local add = false

    if name and self._CommonAttr[name] and self._CommonAttr[name].SetWidget then
        self._CommonAttr[name].SetWidget(value)
        add = true
    end

    if add then
        self:SaveCache()
    end
end

function GUITXTEditor:updateSpecialAttr(name, value, inputType)
    local add = false

    if name and self._SpecialAttr[name] and self._SpecialAttr[name].SetWidget then
        self._SpecialAttr[name].SetWidget(value, inputType)
        add = true
    end

    if add then
        self:SaveCache()
    end
end

function GUITXTEditor:setBgtc(enable)
    self._selUISpecialControl["Image_Mask_Color"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_Opacity"]:setLocalZOrder(2)

    self._selUISpecialControl["Image_Mask_Color"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_Opacity"]:setVisible(not enable)
end

function GUITXTEditor:setOutlineState(enable)
    self._selUISpecialControl["Image_Mask_Outline_Color"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_Outline_Width"]:setLocalZOrder(2)

    self._selUISpecialControl["Image_Mask_Outline_Color"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_Outline_Width"]:setVisible(not enable)
end

function GUITXTEditor:setSVMoreRowEdit(enable)
    self._selUISpecialControl["Image_Mask_Margin_x"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_Margin_y"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_Margin_l"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_Margin_t"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_Colnum"]:setLocalZOrder(2)
    self._selUISpecialControl["Image_Mask_AddDir"]:setLocalZOrder(2)

    self._selUISpecialControl["Image_Mask_Margin_x"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_Margin_y"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_Margin_l"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_Margin_t"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_Colnum"]:setVisible(not enable)
    self._selUISpecialControl["Image_Mask_AddDir"]:setVisible(not enable)
end

function GUITXTEditor:setCapInset(enable)
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

function GUITXTEditor:getCapInset(widget)
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

function GUITXTEditor:setCapInsetValue(widget, uiType, rect)
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
function GUITXTEditor:updateNodeOpacity(opacity)
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

function GUITXTEditor:onDrawRect(node, widget)
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

function GUITXTEditor:resetDrawRect()
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

function GUITXTEditor:isSelectWidget(target)
    for _, swidget in pairs(self._selWidgets or {}) do
        if swidget and target == swidget then
            return true
        end
    end
    return false
end

function GUITXTEditor:resetAllSelectWidget()
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

function GUITXTEditor:selectWidget(widget)
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

function GUITXTEditor:SetShortcutState(num)
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

function GUITXTEditor:IsSpecialNode(desc)
    return desc == "Widget" or desc == "Effect" or desc == "Model"
end

-- 选中框
function GUITXTEditor:setWidgetDrawRect(widget)
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

function GUITXTEditor:KeyBoardPressedFunc(keycode, evt)
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

function GUITXTEditor:KeyBoardReleasedFunc(keycode)
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

function GUITXTEditor:OnMouseMoved(sender)
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

function GUITXTEditor:OnMouseUp(sender)
    self._lastPos = nil
end

-- 调整坐标
function GUITXTEditor:resetPostion(offPos)
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

function GUITXTEditor:cleanup()
    self._Node_UI:removeAllChildren()
    self._Node_UI:setPosition(cc.p(0, 0))
end

-----------------------------------------------------------------------------------------------------------------------
function GUITXTEditor:SetUIPreview(color)
    self._selUISpecialControl["Panel_Preview"]:setBackGroundColor(color)
end

function GUITXTEditor:SetUIPressPreview(color)
    self._selUISpecialControl["Panel_Press_Preview"]:setBackGroundColor(color)
end

function GUITXTEditor:SetUIOutlinePreview(color)
    self._selUISpecialControl["Panel_Outline_Preview"]:setBackGroundColor(color)
end

function GUITXTEditor:SetUILBarLPreview(color)
    self._selUISpecialControl["Panel_LBar_LPreview"]:setBackGroundColor(color)
end

function GUITXTEditor:SetUIInputPlaceHolderPreview(color)
    self._selUISpecialControl["Panel_Preview2"]:setBackGroundColor(color)
end

function GUITXTEditor:SetUIBtnColor(hexColor)
    self._selUISpecialControl["Button_Color"].__color__ = hexColor
end

function GUITXTEditor:SetUIBtnPressColor(hexColor)
    self._selUISpecialControl["Button_Press_Color"].__color__ = hexColor
end

function GUITXTEditor:SetUIOutlineBtnColor(hexColor)
    self._selUISpecialControl["Button_Outline_Color"].__color__ = hexColor
end

function GUITXTEditor:SetUILBarLColor(hexColor)
    self._selUISpecialControl["Button_LBar_LColor"].__color__ = hexColor
end

function GUITXTEditor:SetUIInputPlaceHolderColor(hexColor)
    self._selUISpecialControl["Button_Color2"].__color__ = hexColor
end

function GUITXTEditor:SetRTextAttribute(key, value)
    local item = self._selWidget:getChildByName("__RICHTEXT__")
    if item then
        item:removeFromParent()
    end

    self:SetAttribute(GUIAttributes.RICH_TEXT, key, value)
    self:CreateRText(self._selWidget)
end

function GUITXTEditor:SetRTextUIAttribute(uiWidget, widget, key)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.RICH_TEXT)
    local value = data[key]
    if key == "RColor" then
        value = supper(value)
    end
    uiWidget:setString(value)

    return value
end

function GUITXTEditor:SetColorC( value )
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
    elseif self._selDescription == "TableView" then
        self._selWidget:SetBackColor(rgbColor)
    elseif self._selDescription == "RText" then
        self:SetRTextAttribute("RColor", GetColorHexFromRBG(rgbColor))
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUITXTEditor:SetUIColorC(uiWidget, widget)
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
    elseif self._selDescription == "TableView" then
        local color = widget:GetBackColor()
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

function GUITXTEditor:SetColorOutlineC( value ) 
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

function GUITXTEditor:SetUIColorOutlineC(uiWidget, widget)
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

function GUITXTEditor:SetColorButtonPressC( value ) 
    self:SetAttribute(GUIAttributes.BUTTON_CLICKCOLOR, "Param2", value)
end

function GUITXTEditor:SetUIColorButtonPressC(uiWidget, widget)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.BUTTON_CLICKCOLOR)
    local value = supper(data["Param2"])
    uiWidget:setString(value)
    self:SetUIPressPreview(GetColorFromHexString(value))
    self:SetUIBtnPressColor(value)
end

function GUITXTEditor:SetColorLBarLabel( value ) 
    self:SetAttribute(GUIAttributes.LOADING_BAR, "lcolor", value)
end

function GUITXTEditor:SetUIColorLBarLabel(uiWidget, widget)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.LOADING_BAR)
    local value = supper(data["lcolor"] or "#ffffff")
    uiWidget:setString(value)
    self:SetUILBarLPreview(GetColorFromHexString(value))
    self:SetUILBarLColor(value)
end

function GUITXTEditor:SetColorInputPlaceHolder( value ) 
    self._selWidget:setPlaceholderFontColor(GetColorFromHexString(value))
end

function GUITXTEditor:SetUIColorInputPlaceHolder(uiWidget, widget)
    local color = widget:getPlaceholderFontColor()
    local hexColor = GetColorHexFromRBG(color)
    uiWidget:setString(hexColor)
    self:SetUIInputPlaceHolderPreview(color)
    self:SetUIInputPlaceHolderColor(hexColor)
end

function GUITXTEditor:SetOutlineWidth(value)
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

function GUITXTEditor:SetUIOutlineWidth(uiWidget, widget)
    if self._selDescription == "Label" then
        uiWidget:setString(widget:getOutlineSize())
    elseif self._selDescription == "Button" then
        uiWidget:setString(widget:getTitleRenderer():getOutlineSize())
    end
end

function GUITXTEditor:SetMoreText(value)
    if self._selDescription == "Label" or self._selDescription == "BmpText" then
        local text, showText = self:GetRealValue(self._selWidget, Attributes.TEXT, value)
        self._selWidget:setString(showText or text)
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUITXTEditor:SetUIMoreText(uiWidget, widget)
    if self._selDescription == "Label" then
        local value = self:GetAttribeValue(widget, Attributes.TEXT, true)
        uiWidget:setString(value)
    elseif self._selDescription == "BmpText" then
        local value = self:GetAttribeValue(widget, Attributes.TEXT, true)
        uiWidget:setString(value)
    end
end

function GUITXTEditor:SetText(value)
    if self._selDescription == "Button" then
        local text, showText = self:GetRealValue(self._selWidget, Attributes.BTEXT, value)
        self._selWidget:setTitleText(showText or text)
    elseif self._selDescription == "EditBox" or self._selDescription == "TextField" then
        local text, showText = self:GetRealValue(self._selWidget, Attributes.TEXT, value)
        self._selWidget:setString(showText or text)
    elseif self._selDescription == "TextAtlas" then
        local stringValue  = value
        local charMapFile  = self._selWidget:getCharMapFile()
        local itemWidth    = self._selWidget:getItemWidth()
        local itemHeight   = self._selWidget:getItemHeight()
        local startCharMap = self._selWidget:getStartCharMap()
        GUI:TextAtlas_setProperty(self._selWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)

        self._selWidget:setString(value)

        self:resetDrawRect()
        self:setCommonAttrUI()
    elseif self._selDescription == "RText" then
        self:SetRTextAttribute("Text", value)
        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUITXTEditor:SetUIText(uiWidget, widget)
    if self._selDescription == "Button" then
        local text = self:GetAttribeValue(widget, Attributes.BTEXT, true)
        uiWidget:setString(text)
    elseif self._selDescription == "EditBox" or self._selDescription == "TextField" then
        local text = self:GetAttribeValue(widget, Attributes.TEXT, true)
        uiWidget:setString(text)
    elseif self._selDescription == "TextAtlas" then
        local value = widget:getStringValue()
        uiWidget:setString(value)
    elseif self._selDescription == "RText" then
        self:SetRTextUIAttribute(uiWidget, widget, "Text")
    end
end

function GUITXTEditor:SetFontSize(value)
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

function GUITXTEditor:SetUIFontSize(uiWidget, widget)
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

function GUITXTEditor:SetBtnNRes(res)
    self._selUISpecialControl["Button_N_Res"].__res__ = res
end

function GUITXTEditor:SetBtnPRes(res)
    self._selUISpecialControl["Button_P_Res"].__res__ = res
end

function GUITXTEditor:SetBtnDRes(res)
    self._selUISpecialControl["Button_D_Res"].__res__ = res
end

function GUITXTEditor:SetNorRes(str, inputType)
    str = self:GetRealValue(self._selWidget, Attributes.RES1, str)
    str = str or " "
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

function GUITXTEditor:SetPreRes(str)
    str = self:GetRealValue(self._selWidget, Attributes.RES2, str)
    str = str or " "
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

function GUITXTEditor:SetDisRes(str)
    str = self:GetRealValue(self._selWidget, Attributes.RES3, str)
    str = str or " "
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

function GUITXTEditor:SetUINorRes(uiWidget, widget)
    if self._selDescription == "Button" or 
        self._selDescription == "ImageView" or 
            self._selDescription == "CheckBox" or 
                self._selDescription == "Slider" or 
                    self._selDescription == "Layout" or
                        self._selDescription == "LoadingBar" or
                            self._selDescription == "ListView" or
                                self._selDescription == "ScrollView" or 
                                    self._selDescription == "PageView" then

        local str, formatType = self:GetAttribeValue(widget, Attributes.RES1, true)
        if formatType == FormatType.CCS then
            str = (str ~= "" and fileUtil:isFileExist(str)) and str or " "
        end
        uiWidget:setString(str)
        self:SetBtnNRes(str)
    elseif self._selDescription == "TextAtlas" then
        local charMapFile = widget:getCharMapFile()
        uiWidget:setString(charMapFile)
    elseif self._selDescription == "RText" then
        self:SetRTextUIAttribute(uiWidget, widget, "RFace")
    end
end

function GUITXTEditor:SetUIPreRes(uiWidget, widget)
    if self._selDescription == "Button" or self._selDescription == "CheckBox" or self._selDescription == "Slider" then
        local str, formatType = self:GetAttribeValue(widget, Attributes.RES2, true)
        if formatType == FormatType.CCS then
            str = (str ~= "" and fileUtil:isFileExist(str)) and str or " "
        end
        uiWidget:setString(str)
        self:SetBtnPRes(str)
    end
end

function GUITXTEditor:SetUIDisRes(uiWidget, widget)
    if self._selDescription == "Button" or self._selDescription == "Slider" then
        local str, formatType = self:GetAttribeValue(widget, Attributes.RES3, true)
        if formatType == FormatType.CCS then
            str = (str ~= "" and fileUtil:isFileExist(str)) and str or " "
        end
        uiWidget:setString(str)
        self:SetBtnDRes(str)
    end
end

function GUITXTEditor:SetCapInsetL(value)
    local rect = self:getCapInset()
    rect.l = value
    self:setCapInsetValue(self._selWidget, self._selDescription, rect)
end

function GUITXTEditor:SetCapInsetR(value)
    local rect = self:getCapInset()
    rect.r = value
    self:setCapInsetValue(self._selWidget, self._selDescription, rect)
end

function GUITXTEditor:SetCapInsetT(value)
    local rect = self:getCapInset()
    rect.t = value
    self:setCapInsetValue(self._selWidget, self._selDescription, rect)
end

function GUITXTEditor:SetCapInsetB(value)
    local rect = self:getCapInset()
    rect.b = value
    self:setCapInsetValue(self._selWidget, self._selDescription, rect)
end

function GUITXTEditor:SetUICapInsetL(uiWidget, widget)
    local rect = self:getCapInset()
    uiWidget:setString(rect.l)
end

function GUITXTEditor:SetUICapInsetR(uiWidget, widget)
    local rect = self:getCapInset()
    uiWidget:setString(rect.r)
end

function GUITXTEditor:SetUICapInsetT(uiWidget, widget)
    local rect = self:getCapInset()
    uiWidget:setString(rect.t)
end

function GUITXTEditor:SetUICapInsetB(uiWidget, widget)
    local rect = self:getCapInset()
    uiWidget:setString(rect.b)
end

function GUITXTEditor:SetInputPlaceholder(value)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        self._selWidget:setPlaceHolder(value)
    end
end

function GUITXTEditor:SetUIInputPlaceholder(uiWidget, widget)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        uiWidget:setString(widget:getPlaceHolder())
    end
end

function GUITXTEditor:SetInputMaxLenth(value)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        self._selWidget:setMaxLength(value)
    end
end

function GUITXTEditor:SetUIInputMaxLenth(uiWidget, widget)
    if self._selDescription == "EditBox" or self._selDescription == "TextField" then
        uiWidget:setString(widget:getMaxLength())
    end
end

function GUITXTEditor:SetInputID(value)
    if self._selDescription == "Label" then
        self:SetAttribute(GUIAttributes.LABEL_EX, "id", value)
    else
        self:SetAttribute(GUIAttributes.INPUT_EX, "id", value)
    end
end

function GUITXTEditor:SetUIInputID(uiWidget, widget)
    if self._selDescription == "Label" then
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.LABEL_EX, "id")
    else
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.INPUT_EX, "id")
    end
end

function GUITXTEditor:SetInputType(value)
    self:SetAttribute(GUIAttributes.INPUT_EX, "type", value)
end

function GUITXTEditor:SetUIInputType(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.INPUT_EX, "type")
end

function GUITXTEditor:SetUICBCipher(uiWidget, widget)
    local key  = GUIAttributes.INPUT_EX
    local key2 = "cipher"
    self:SetCheckBoxUIAttribute(uiWidget, widget, key, key2)
end

function GUITXTEditor:onCBCipherEvent(ref)
    local key   = GUIAttributes.INPUT_EX
    local key2  = "cipher"
    local value = not ref:isSelected()
    self:SetCheckBoxAttribute(self._selWidget, key, key2, value)
end

function GUITXTEditor:SetUIISensitive(uiWidget, widget)
    local key  = GUIAttributes.INPUT_EX
    local key2 = "checkSensitive"
    self:SetCheckBoxUIAttribute(uiWidget, widget, key, key2)
end

function GUITXTEditor:onCBSensitiveEvent(ref)
    local key   = GUIAttributes.INPUT_EX
    local key2  = "checkSensitive"
    local value = not ref:isSelected()
    self:SetCheckBoxAttribute(self._selWidget, key, key2, value)
end

function GUITXTEditor:SetBgTextOpacity(value)
    local bgOpacity = math.floor(value / 100 * 255)
    self._selWidget:setBackGroundColorOpacity(bgOpacity)
    self._selUISpecialControl["Slider_Bg_Opacity"]:setPercent(value)
end

function GUITXTEditor:SetSetGrey(value)
    self:SetAttribute(GUIAttributes.BUTTON_EX, "grey", value)
end

function GUITXTEditor:SetUISetGrey(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.BUTTON_EX, "grey")
end

function GUITXTEditor:SetInputIDs(value)
    if self._selDescription == "Slider" then
        self:SetAttribute(GUIAttributes.SLIDER_EX, "ids", value)
    else
        self:SetAttribute(GUIAttributes.BUTTON_EX, "ids", value)
    end
end

function GUITXTEditor:SetUIInputIDs(uiWidget, widget)
    if self._selDescription == "Slider" then
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.SLIDER_EX, "ids")
    else
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.BUTTON_EX, "ids")
    end
end

-- Model
function GUITXTEditor:SetModelAttribute(key, value)
    local sfx = self._selWidget:getChildByName("__MODEL__")
    if sfx then
        sfx:removeFromParent()
    end
    
    self:SetAttribute(GUIAttributes.MODEL, key, value)
    self:CreateModel(self._selWidget)
end

function GUITXTEditor:SetSex(value)
    self:SetModelAttribute("sex", value)
end

function GUITXTEditor:SetUISex(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "sex")
end

function GUITXTEditor:SetMScale(value)
    self:SetModelAttribute("scale", value)
end

function GUITXTEditor:SetUIMScale(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "scale")
end

function GUITXTEditor:SetHairID(value)
    self:SetModelAttribute("hairID", value)
end

function GUITXTEditor:SetUIHairID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "hairID")
end

function GUITXTEditor:SetHeadID(value)
    self:SetModelAttribute("headID", value)
end

function GUITXTEditor:SetUIHeadID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "headID")
end

function GUITXTEditor:SetHeadEffID(value)
    self:SetModelAttribute("headEffectID", value)
end

function GUITXTEditor:SetUIHeadEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "headEffectID")
end

function GUITXTEditor:SetClothID(value)
    self:SetModelAttribute("clothID", value)
end

function GUITXTEditor:SetUIClothID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "clothID")
end

function GUITXTEditor:SetClothEffID(value)
    self:SetModelAttribute("clothEffectID", value)
end

function GUITXTEditor:SetUIClothEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "clothEffectID")
end

function GUITXTEditor:SetWeaponID(value)
    self:SetModelAttribute("weaponID", value)
end

function GUITXTEditor:SetUIWeaponID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "weaponID")
end

function GUITXTEditor:SetWeaponEffID(value)
    self:SetModelAttribute("weaponEffectID", value)
end

function GUITXTEditor:SetUIWeaponEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "weaponEffectID")
end

function GUITXTEditor:SetShieldID(value)
    self:SetModelAttribute("shieldID", value)
end

function GUITXTEditor:SetUIShieldID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "shieldID")
end

function GUITXTEditor:SetShieldEffID(value)
    self:SetModelAttribute("shieldEffectID", value)
end

function GUITXTEditor:SetUIShieldEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "shieldEffectID")
end

function GUITXTEditor:SetCapID(value)
    self:SetModelAttribute("capID", value)
end

function GUITXTEditor:SetUICapID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "capID")
end

function GUITXTEditor:SetCapEffID(value)
    self:SetModelAttribute("capEffectID", value)
end

function GUITXTEditor:SetUICapEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "capEffectID")
end

function GUITXTEditor:SetVeilID(value)
    self:SetModelAttribute("veilID", value)
end

function GUITXTEditor:SetUIVeilID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "veilID")
end

function GUITXTEditor:SetVeilEffID(value)
    self:SetModelAttribute("veilEfffectID", value)
end

function GUITXTEditor:SetUIVeilEffID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "veilEfffectID")
end

function GUITXTEditor:SetShowMold(value)
    self:SetModelAttribute("notShowMold", value)
end

function GUITXTEditor:SetUIShowMold(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "notShowMold")
end

function GUITXTEditor:SetShowHair(value)
    self:SetModelAttribute("notShowHair", value)
end

function GUITXTEditor:SetUIShowHair(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.MODEL, "notShowHair")
end

-- 背景透明度
function GUITXTEditor:SetUITextBgOpacity(uiWidget, widget)
    local bgOpacity = widget:getBackGroundColorOpacity()
    uiWidget:setString(math.floor(bgOpacity / 255 * 100))
end

-- 透明度 Slider
function GUITXTEditor:SetUISliderBgOpacity(uiWidget, widget)
    local bgOpacity = widget:getBackGroundColorOpacity()
    uiWidget:setPercent(math.floor(bgOpacity / 255 * 100))
end

function GUITXTEditor:SetUIDirection(uiWidget, widget)
    if self._selDescription == "ListView" or self._selDescription == "ScrollView" then
        uiWidget:setSelected(widget:getDirection() == 2)
    elseif self._selDescription == "TableView" then
        uiWidget:setSelected(widget:getDirectionEx() == 2)
    end
end

function GUITXTEditor:SetAlignment(value)
    if self._selDescription == "ListView" then
        self._selWidget:setGravity(value)
        self._selWidget:jumpToBottom()
    end
end

function GUITXTEditor:SetUIAlignment(uiWidget, widget)
    if self._selDescription == "ListView" then
        uiWidget:setString(widget:getGravity())
    end
end

function GUITXTEditor:SetMargin(value)
    if self._selDescription == "ListView" then
        self._selWidget:setItemsMargin(value)
        self._selWidget:jumpToBottom()
    end
end

function GUITXTEditor:SetUIMargin(uiWidget, widget)
    if self._selDescription == "ListView" then
        uiWidget:setString(widget:getItemsMargin())
    end
end

function GUITXTEditor:SetInnerWidth(value)
    if self._selDescription == "ScrollView" then
        self._selWidget:setInnerContainerSize(cc.size(sformat("%.2f", value), sformat("%.2f", self._selWidget:getInnerContainerSize().height)))
        if self._selWidget.___DRAWNODE___ then
            self._selWidget.___DRAWNODE___:setPositionX(0)
            self._selWidget.___TOUCHLAYOUT___:setPositionX(0)
        end
    end
end

function GUITXTEditor:SetInnerHeight(value)
    if self._selDescription == "ScrollView" then
        self._selWidget:setInnerContainerSize(cc.size(sformat("%.2f", self._selWidget:getInnerContainerSize().width), sformat("%.2f", value)))
        if self._selWidget.___DRAWNODE___ then
            local y = self._selWidget:getInnerContainerSize().height - self._selWidget:getContentSize().height
            self._selWidget.___DRAWNODE___:setPosition(cc.p(0, math.max(y, 0)))
            self._selWidget.___TOUCHLAYOUT___:setPosition(cc.p(0, math.max(y, 0)))
        end
    end
end

function GUITXTEditor:SetUIInnerWidth(uiWidget, widget)
    if self._selDescription == "ScrollView" then
        uiWidget:setString(sformat("%.2f", widget:getInnerContainerSize().width))
    end
end

function GUITXTEditor:SetUIInnerHeight(uiWidget, widget)
    if self._selDescription == "ScrollView" then
        uiWidget:setString(sformat("%.2f", widget:getInnerContainerSize().height))
    end
end

-- 九宫格
function GUITXTEditor:SetUICapInset(uiWidget, widget)
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

-- 文本描边
function GUITXTEditor:SetUITextOutline(uiWidget, widget)
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
function GUITXTEditor:SetUIRebound(uiWidget, widget)
    uiWidget:setSelected(widget:isBounceEnabled())
end

-- 选中状态
function GUITXTEditor:SetUICboxSelect(uiWidget, widget)
    uiWidget:setSelected(widget:isSelected())
end

-- LoadingBar 方向
function GUITXTEditor:SetUILBarLeft(uiWidget, widget)
    uiWidget:setSelected(widget:getDirection() == ccui.LoadingBarDirection.RIGHT)
end

-- 剪裁
function GUITXTEditor:SetUIClip(uiWidget, widget)
    uiWidget:setSelected(widget:isClippingEnabled())
end

-- 背景填充
function GUITXTEditor:SetUIBgtc(uiWidget, widget)
    local isTc = widget:getBackGroundColorType() ~= 0
    uiWidget:setSelected(isTc)
    self:setBgtc(isTc)
end

-- 特效播放
function GUITXTEditor:SetUIEffectPlay(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EFFECT, "loop")
end

function GUITXTEditor:SetUIItemLook(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "look")
end

function GUITXTEditor:SetUIItemShowBg(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "bgVisible")
end

function GUITXTEditor:SetUIItemShowNum(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "disShowCount")
end

function GUITXTEditor:SetUIItemShowStar(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "starLv")
end

function GUITXTEditor:SetUIItemShowMask(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "notShowEquipRedMask")
end

function GUITXTEditor:SetUIItemShowPowerC(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "checkPower")
end

function GUITXTEditor:SetUIItemShowEffect(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "isShowEff")
end

function GUITXTEditor:SetUIItemShowModelEffect(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.ITEM_SHOW, "showModelEffect")
end

function GUITXTEditor:SetMarginX(value)
    self:SetAttribute(GUIAttributes.SCROLLVIEW_MOREROW, "x", value)
end

function GUITXTEditor:SetUIMarginX(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.SCROLLVIEW_MOREROW, "x")
end

function GUITXTEditor:SetMarginY(value)
    self:SetAttribute(GUIAttributes.SCROLLVIEW_MOREROW, "y", value)
end

function GUITXTEditor:SetUIMarginY(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.SCROLLVIEW_MOREROW, "y")
end

function GUITXTEditor:SetMarginL(value)
    self:SetAttribute(GUIAttributes.SCROLLVIEW_MOREROW, "l", value)
end

function GUITXTEditor:SetUIMarginL(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.SCROLLVIEW_MOREROW, "l")
end

function GUITXTEditor:SetMarginT(value)
    self:SetAttribute(GUIAttributes.SCROLLVIEW_MOREROW, "t", value)
end

function GUITXTEditor:SetUIMarginT(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.SCROLLVIEW_MOREROW, "t")
end

function GUITXTEditor:SetAddDir(value)
    self:SetAttribute(GUIAttributes.SCROLLVIEW_MOREROW, "addDir", value)
end

function GUITXTEditor:SetUIAddDir(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.SCROLLVIEW_MOREROW, "addDir")
end

function GUITXTEditor:SetColnum(value)
    self:SetAttribute(GUIAttributes.SCROLLVIEW_MOREROW, "colnum", value)
end

function GUITXTEditor:SetUIColnum(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.SCROLLVIEW_MOREROW, "colnum")
end

function GUITXTEditor:SetUISViewMoreRow(uiWidget, widget)
    local isClick = self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.SCROLLVIEW_MOREROW, "IsClick")
    self:setSVMoreRowEdit(isClick)
end

function GUITXTEditor:SetUISViewPlayAction(uiWidget, widget)
    local isPlay = self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.SCROLLVIEW_MOREROW, "play")
    self:setSVMoreRowEdit(isPlay)
end

function GUITXTEditor:SetUIButtonPage(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.BUTTON_PAGE, "Param2")
end    

function GUITXTEditor:SetAttachUI(value)
    self:SetAttribute(GUIAttributes.ATTACH_NODE, "Param2", value)
end

function GUITXTEditor:SetUIAttachUI(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.ATTACH_NODE, "Param2")
end

function GUITXTEditor:SetPerValue(value)
    local callfunc = function(key)
        value = self:SetAttribute(key, "value", value)
        value = tonumber(value)

        local data = self:GetAttribeValue(self._selWidget, key)
        local maxValue = self:GetRealValue2(data["maxValue"])
        maxValue = tonumber(maxValue)

        if value and maxValue then
            local precent = 0
            if maxValue == 0 then
                precent = 0
            elseif maxValue < value then
                precent = 100
            else
                precent = math.floor(value / maxValue * 100)
            end
            self._selWidget:setPercent(precent)
        end
    end

    if self._selDescription == "Slider" then
        callfunc(GUIAttributes.SLIDER_EX)
    else
        callfunc(GUIAttributes.LOADING_BAR)
    end
end

function GUITXTEditor:SetUIPerValue(uiWidget, widget)
    if self._selDescription == "Slider" then
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.SLIDER_EX, "value")
    else
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.LOADING_BAR, "value")
    end
end

function GUITXTEditor:SetMaxPerValue(value)
    local callfunc = function(key)
        local maxValue = self:SetAttribute(key, "maxValue", value)
        maxValue = tonumber(maxValue)

        local data = self:GetAttribeValue(self._selWidget, key)
        local value = self:GetRealValue2(data["value"])
        value = tonumber(value)

        if value and maxValue then
            local precent = 0
            if maxValue == 0 then
                precent = 0
            elseif maxValue < value then
                precent = 100
            else
                precent = math.floor(value / maxValue * 100)
            end
            self._selWidget:setPercent(precent)
        end
    end

    if self._selDescription == "Slider" then
        callfunc(GUIAttributes.SLIDER_EX)
    else
        callfunc(GUIAttributes.LOADING_BAR)
    end
end

function GUITXTEditor:SetUIPerMaxValue(uiWidget, widget)
    if self._selDescription == "Slider" then
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.SLIDER_EX, "maxValue")
    else
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.LOADING_BAR, "maxValue")
    end
end

function GUITXTEditor:SetBarInterval(value)
    self:SetAttribute(GUIAttributes.LOADING_BAR, "interval", value)
end

function GUITXTEditor:SetUIBarInterval(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.LOADING_BAR, "interval")
end

function GUITXTEditor:SetBarStep(value)
    self:SetAttribute(GUIAttributes.LOADING_BAR, "step", value)
end

function GUITXTEditor:SetUIBarStep(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.LOADING_BAR, "step")
end

function GUITXTEditor:SetBarLabelVisible(value)
    value = self:SetAttribute(GUIAttributes.LOADING_BAR, "lvisible", value)
    local data = self:GetAttribeValue(self._selWidget, GUIAttributes.LOADING_BAR)
    self:createLBarLabel(self._selWidget, data)
end

function GUITXTEditor:SetUIBarLabelVisible(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.LOADING_BAR, "lvisible")
end

function GUITXTEditor:SetBarLabelX(value)
    value = self:SetAttribute(GUIAttributes.LOADING_BAR, "lx", value)
    local data = self:GetAttribeValue(self._selWidget, GUIAttributes.LOADING_BAR)
    self:createLBarLabel(self._selWidget, data)
end

function GUITXTEditor:SetUIBarLabelX(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.LOADING_BAR, "lx")
end

function GUITXTEditor:SetBarLabelY(value)
    value = self:SetAttribute(GUIAttributes.LOADING_BAR, "ly", value)
    local data = self:GetAttribeValue(self._selWidget, GUIAttributes.LOADING_BAR)
    self:createLBarLabel(self._selWidget, data)
end

function GUITXTEditor:SetUIBarLabelY(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.LOADING_BAR, "ly")
end

function GUITXTEditor:SetBarLabelSize(value)
    value = self:SetAttribute(GUIAttributes.LOADING_BAR, "lsize", value)
    local data = self:GetAttribeValue(self._selWidget, GUIAttributes.LOADING_BAR)
    self:createLBarLabel(self._selWidget, data)
end

function GUITXTEditor:SetUIBarLabelSize(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.LOADING_BAR, "lsize")
end


---EquipShow
function GUITXTEditor:SetUIEquipLook(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "look")
end

function GUITXTEditor:SetUIEquipShowBg(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "bgVisible")
end

function GUITXTEditor:SetUIEquipShowStar(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "starLv")
end

function GUITXTEditor:SetUIEquipShowPowerC(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "checkPower")
end

function GUITXTEditor:SetUIEquipAutoUpdate(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "autoUpdate")
end

function GUITXTEditor:SetUIEquipIsHero(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "isHero")
end

function GUITXTEditor:SetUIEquipOnDouble(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "doubleTakeOff")
end

function GUITXTEditor:SetUIEquipOnMove(uiWidget, widget)
    self:SetUICheckAttribute(uiWidget, widget, GUIAttributes.EQUIP_SHOW, "movable")
end

-- Input 默认值------------------------------------------------------------------------------------------------------
function GUITXTEditor:GetAnrX()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.ANRX, true)
    end
    return 0.00
end

function GUITXTEditor:GetAnrY()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.ANRY, true)
    end
    return 0.00
end

function GUITXTEditor:GetScaleX()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.SCALEX, true)
    end
    return 1.00
end

function GUITXTEditor:GetScaleY()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.SCALEY, true)
    end
    return 1.00
end

function GUITXTEditor:GetPosX()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.X, true)
    end
    return 0.00
end

function GUITXTEditor:GetPosY()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.Y, true)
    end
    return 0.00
end

function GUITXTEditor:GetRotate()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.ROTATE, true)
    end
    return 0.00
end

function GUITXTEditor:GetTag()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.TAG, true)
    end
    return -1
end

function GUITXTEditor:GetOpacity()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.OPACITY, true)
    end
    return 100
end

function GUITXTEditor:GetVisible()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.VISIBLE, true)
    end
    return 0
end

function GUITXTEditor:GetTouched()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.ISTOUCH, true)
    end
    return 0
end

-- function GUITXTEditor:GetProgress()
--     if self._selWidget then
--         return self:GetAttribeValue(self._selWidget, Attributes.PERCENT, true)
--     end
--     return 100
-- end

function GUITXTEditor:GetText()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.TEXT, true)
    end
    return ""
end

function GUITXTEditor:GetNorRes()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.RES1, true)
    end
    return ""
end

function GUITXTEditor:GetPreRes()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.RES2, true)
    end
    return ""
end

function GUITXTEditor:GetDisRes()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.RES3, true)
    end
    return ""
end

function GUITXTEditor:GetWidth()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.W, true)
    end
    return 0
end

function GUITXTEditor:GetHeight()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.H, true)
    end
    return 0
end

function GUITXTEditor:GetInnerWidth()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.INNERW, true)
    end
    return defaultViewW
end

function GUITXTEditor:GetInnerHeight()
    if self._selWidget then
        return self:GetAttribeValue(self._selWidget, Attributes.INNERH, true)
    end
    return defaultViewH
end

-- Common Attr------------------------------------------------------------------------------------------------------
function GUITXTEditor:SetName(str)
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

function GUITXTEditor:SetUIName(uiWidget, widget)
    uiWidget:setString(widget:getName())
end

function GUITXTEditor:SetID(value)
    GUI:setID(self._selWidget, value)
end

function GUITXTEditor:SetUIID(uiWidget, widget)
    uiWidget:setString(GUI:getID(widget))

    local idx = self:getTreeIdxByObj(self._selWidget)
    if not idx then
        return false
    end
    local depth = self._uiTree[idx].depth or 1
    self._selUICommonControl["Image_Mask_ID"]:setVisible(depth ~= 1)
    self._selUICommonControl["Image_Mask_ID"]:setLocalZOrder(2)
end

function GUITXTEditor:SetRedID(value)
    self:SetAttribute(GUIAttributes.UIIDS, "redID", value)
end

function GUITXTEditor:SetUIRedID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.UIIDS, "redID")
end

function GUITXTEditor:SetGuideID(value)
    self:SetAttribute(GUIAttributes.UIIDS, "guideID", value)
end

function GUITXTEditor:SetUIGuideID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.UIIDS, "guideID")
end

function GUITXTEditor:SetChildID(value)
    GUI:setChildID(self._selWidget, value)
end

function GUITXTEditor:SetUIChildID(uiWidget, widget)
    uiWidget:setString(GUI:getChildID(widget))
end

function GUITXTEditor:SetChildNum(value)
    if self._selDescription == "TableView" then
        self:SetAttribute(GUIAttributes.TABLE_VIEW, "CellN", value)
    else
        self:SetAttribute(GUIAttributes.CONTAIN_INDEX, "Param2", value)
    end
end

function GUITXTEditor:SetUIChildNum(uiWidget, widget)
    if self._selDescription == "TableView" then
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.TABLE_VIEW, "CellN")
    else
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.CONTAIN_INDEX, "Param2")
    end
end

function GUITXTEditor:SetJumpIndex(value)
    if self._selDescription == "TableView" then
        self:SetAttribute(GUIAttributes.TABLE_VIEW, "JumpIdx", value)
    else
        local nums, showNums = self:GetRealValue(self._selWidget, Attributes.JUMPINDEX, value)
        if nums then
            GUI:setJumpIndex(self._selWidget, nums)
        else
            GUI:setJumpIndex(self._selWidget, showNums)
        end
    end
end

function GUITXTEditor:SetUIJumpIndex(uiWidget, widget)
    if self._selDescription == "TableView" then
        self:SetUIAttribute(uiWidget, widget, GUIAttributes.TABLE_VIEW, "JumpIdx")
    else
        local value = self:GetAttribeValue(widget, Attributes.JUMPINDEX, true)
        uiWidget:setString(value)
    end
end

function GUITXTEditor:SetCellWidth(value)
    self:SetAttribute(GUIAttributes.TABLE_VIEW, "CellW", value)
end

function GUITXTEditor:SetUICellWidth(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.TABLE_VIEW, "CellW")
end

function GUITXTEditor:SetCellHeight(value)
    self:SetAttribute(GUIAttributes.TABLE_VIEW, "CellH", value)
end

function GUITXTEditor:SetUICellHeight(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.TABLE_VIEW, "CellH")
end

function GUITXTEditor:SetNameTip(str)
    if slen(str) > 0 and str ~= GUI:getChineseName(self._selWidget) then
        local TextTreeName = self._selTreeNode and self._selTreeNode.TextTreeName
        if TextTreeName then
            TextTreeName:setString(str)
        end
        GUI:setChineseName(self._selWidget, str)
    end
end

function GUITXTEditor:SetUINameTip(uiWidget, widget)
    uiWidget:setString(GUI:getChineseName(widget))
end

function GUITXTEditor:SetAnrX(value)
    value = self:GetRealValue(self._selWidget, Attributes.ANRX, value)
    value = tonumber(value)
    if value then
        self._selWidget:setAnchorPoint(cc.p(value, self._selWidget:getAnchorPoint().y))
    end
end

function GUITXTEditor:SetUIAnrX(uiWidget, widget)
    local value = self:GetAttribeValue(widget, Attributes.ANRX, true)
    uiWidget:setString(value)
end

function GUITXTEditor:SetAnrY(value)
    value = self:GetRealValue(self._selWidget, Attributes.ANRY, value)
    value = tonumber(value)
    if value then
        self._selWidget:setAnchorPoint(cc.p(self._selWidget:getAnchorPoint().x, value))
    end
end

function GUITXTEditor:SetUIAnrY(uiWidget, widget)
    local value = self:GetAttribeValue(widget, Attributes.ANRY, true)
    uiWidget:setString(value)
end

function GUITXTEditor:SetPosX(value)
    value = self:GetRealValue(self._selWidget, Attributes.X, value)
    value = tonumber(value)
    if value then
        self._selWidget:setPositionX(value)
    end
end

function GUITXTEditor:SetUIPosX(uiWidget, widget)
    local value = self:GetAttribeValue(widget, Attributes.X, true)
    uiWidget:setString(value)
end

function GUITXTEditor:SetPosY(value)
    value = self:GetRealValue(self._selWidget, Attributes.Y, value)
    value = tonumber(value)
    if value then
        self._selWidget:setPositionY(value)
    end
end

function GUITXTEditor:SetUIPosY(uiWidget, widget)
    local value = self:GetAttribeValue(widget, Attributes.Y, true)
    uiWidget:setString(value)
end

function GUITXTEditor:SetWidth(value)
    local width = self:GetRealValue(self._selWidget, Attributes.W, value)
    width = tonumber(width)
    if not width then
        return false
    end

    local height = self._selWidget:getContentSize().height

    if self._selDescription == "ImageView" 
        or self._selDescription == "LoadingBar" 
            or self._selDescription == "Button" 
                or self._selDescription == "CheckBox"
                    or self._selDescription == "Slider" then
        self._selWidget:setContentSize(cc.size(width, height))
        self._selWidget:ignoreContentAdaptWithSize(false)
    elseif self._selDescription == "RText" then
        self._selWidget:setContentSize(cc.size(width, height))

        self:SetRTextAttribute("Width", width)
        self:resetDrawRect()
        self:setCommonAttrUI()
    else
        self._selWidget:setContentSize(cc.size(width, height))
    end
    self:resetDrawRect()
end

function GUITXTEditor:SetUIWidth(uiWidget, widget)
    if self._selDescription == "RText" then
        self:SetRTextUIAttribute(uiWidget, widget, "Width")
    else
        local value = self:GetAttribeValue(widget, Attributes.W, true)
        uiWidget:setString(value)
    end
end

function GUITXTEditor:SetHeight(value)
    local height = self:GetRealValue(self._selWidget, Attributes.H, value)
    height = tonumber(height)
    if not height then
        return false
    end
    self._selWidget:setContentSize(cc.size(self._selWidget:getContentSize().width, height))

    if self._selDescription == "ImageView" 
        or self._selDescription == "LoadingBar" 
            or self._selDescription == "Button" 
                or self._selDescription == "CheckBox"
                    or self._selDescription == "Slider" then
        self._selWidget:ignoreContentAdaptWithSize(false)
    end
    self:resetDrawRect()
end

function GUITXTEditor:SetUIHeight(uiWidget, widget)
    local value = self:GetAttribeValue(widget, Attributes.H, true)
    uiWidget:setString(value)
end

function GUITXTEditor:SetTag(value)
    value = self:GetRealValue(self._selWidget, Attributes.TAG, value)
    value = tonumber(value)
    if value then
        self._selWidget:setTag(value)
    end
end

function GUITXTEditor:SetUITag(uiWidget, widget)
    local value = self:GetAttribeValue(widget, Attributes.TAG, true)
    uiWidget:setString(value)
end

function GUITXTEditor:SetRotate(value)
    value = self:GetRealValue(self._selWidget, Attributes.ROTATE, value)
    value = tonumber(value)
    if value then
        self._selWidget:setRotation(value)
    end
end

function GUITXTEditor:SetUIRotate(uiWidget, widget)
    local value = self:GetAttribeValue(widget, Attributes.ROTATE, true)
    uiWidget:setString(value)
end

function GUITXTEditor:SetScaleX(value)
    value = self:GetRealValue(self._selWidget, Attributes.SCALEX, value)
    value = tonumber(value)
    if value then
        self._selWidget:setScaleX(sformat("%.2f", value / 100))
    end
end

function GUITXTEditor:SetUIScaleX(uiWidget, widget)
    local value, formatType = self:GetAttribeValue(widget, Attributes.SCALEX, true)
    if formatType == FormatType.CCS then
        value = sformat("%.2f", widget:getScaleX() * 100)
    end
    uiWidget:setString(value)
end

function GUITXTEditor:SetScaleY(value)
    value = self:GetRealValue(self._selWidget, Attributes.SCALEY, value)
    value = tonumber(value)
    if value then
        self._selWidget:setScaleY(sformat("%.2f", value / 100))
    end
end

function GUITXTEditor:SetUIScaleY(uiWidget, widget)
    local value, formatType = self:GetAttribeValue(widget, Attributes.SCALEY, true)
    if formatType == FormatType.CCS then
        value = sformat("%.2f", widget:getScaleY() * 100)
    end
    uiWidget:setString(value)
end

function GUITXTEditor:SetOpacity(value)
    value = self:GetRealValue(self._selWidget, Attributes.OPACITY, value)
    value = tonumber(value)
    if value then
        local opacity = math.floor(value / 100 * 255)
        self._selWidget:setOpacity(opacity)
        self._selUICommonControl["Slider_Opacity"]:setPercent(value)
    
        self:updateNodeOpacity(opacity)
    end
end

function GUITXTEditor:SetUIOpacity(uiWidget, widget)
    local opacity, formatType = self:GetAttribeValue(widget, Attributes.OPACITY, true)
    if formatType == FormatType.CCS then
        local percent = math.floor(opacity / 255 * 100)
        self._selUICommonControl["Slider_Opacity"]:setPercent(percent)
        uiWidget:setString(percent)
        return false
    end

    local _, opacity = self:GetStrInt(widget, Attributes.OPACITY)
    opacity = tonumber(opacity)
    if opacity then
        local percent = math.floor(opacity / 255 * 100)
        self._selUICommonControl["Slider_Opacity"]:setPercent(percent)
        uiWidget:setString(percent)
        return false
    end

    local opacity = widget:getOpacity()
    local percent = math.floor(opacity / 255 * 100)
    self._selUICommonControl["Slider_Opacity"]:setPercent(percent)
    uiWidget:setString(percent)
end

function GUITXTEditor:SetVisible(value)
    value = self:GetRealValue(self._selWidget, Attributes.VISIBLE, value)
    local isVisible = tonumber(value)
    if isVisible == 0 then
        isVisible = false
    elseif isVisible == 1 then
        isVisible = true
    elseif type(value) == "boolean" then
        isVisible = value
    else
        isVisible = self._selWidget:isVisible()
    end
    self._selWidget:setVisible(isVisible)
end

function GUITXTEditor:SetUIVisible(uiWidget, widget)
    local visible, formatType = self:GetAttribeValue(widget, Attributes.VISIBLE, true)
    if formatType == FormatType.CCS then
        return uiWidget:setString(visible and 1 or 0)
    end

    local _, visible = self:GetStrBoolean(widget, Attributes.VISIBLE)
    if type(visible) == "boolean" then
        return uiWidget:setString(visible and 1 or 0)
    end

    uiWidget:setString(widget:isVisible() and 1 or 0)
end

function GUITXTEditor:SetTouched(value)
    value = self:GetRealValue(self._selWidget, Attributes.ISTOUCH, value)
    local isTouch = tonumber(value)
    if isTouch == 0 then
        isTouch = false
    elseif isTouch == 1 then
        isTouch = true
    elseif type(value) == "boolean" then
        isTouch = value
    else
        isTouch = self._selWidget:isTouchEnabled()
    end
    self._selWidget:setTouchEnabled(isTouch)
end

function GUITXTEditor:SetUITouched(uiWidget, widget)
    if self._selDescription == "Widget" then
        uiWidget:setString(0)
    elseif widget.isTouchEnabled then
        local enable, formatType = self:GetAttribeValue(widget, Attributes.ISTOUCH, true)
        if formatType == FormatType.CCS then
            return uiWidget:setString(enable and 1 or 0)
        end
        local _, enable = self:GetStrBoolean(widget, Attributes.ISTOUCH)
        if type(enable) == "boolean" then
            return uiWidget:setString(enable and 1 or 0)
        end

        uiWidget:setString(widget:isTouchEnabled() and 1 or 0)
    end
end

function GUITXTEditor:SetEffectAttribute(key, value)
    local sfx = self._selWidget:getChildByName("__SFX__")
    if sfx then
        sfx:removeFromParent()
    end
    
    self:SetAttribute(GUIAttributes.EFFECT, key, value)
    self:CreateEffect(self._selWidget)
end

function GUITXTEditor:SetEffectID(value)
    self:SetEffectAttribute("sfxID", value)
end

function GUITXTEditor:SetUIEffectID(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "sfxID")
end

function GUITXTEditor:SetEffectAction(value)
    self:SetEffectAttribute("act", value)
end

function GUITXTEditor:SetUIEffectAction(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "act")
end

function GUITXTEditor:SetEffectSex(value)
    self:SetEffectAttribute("sex", value)
end

function GUITXTEditor:SetUIEffectSex(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "sex")
end

function GUITXTEditor:SetEffectType(value)
    self:SetEffectAttribute("type", value)
end

function GUITXTEditor:SetUIEffectType(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "type")
end

function GUITXTEditor:SetEffectDir(value)
    self:SetEffectAttribute("dir", value)
end

function GUITXTEditor:SetUIEffectDir(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "dir")
end

function GUITXTEditor:SetEffectSpeed(value)
    self:SetEffectAttribute("speed", value)
end

function GUITXTEditor:SetUIEffectSpeed(uiWidget, widget)
    self:SetUIAttribute(uiWidget, widget, GUIAttributes.EFFECT, "speed")
end

function GUITXTEditor:SetFristChat(value)
    local stringValue  = self._selWidget:getStringValue()
    local charMapFile  = self._selWidget:getCharMapFile()
    local itemWidth    = self._selWidget:getItemWidth()
    local itemHeight   = self._selWidget:getItemHeight()
    local startCharMap = value
    GUI:TextAtlas_setProperty(self._selWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
end

function GUITXTEditor:SetUIFristChat(uiWidget, widget)
    local startCharMap = widget:getStartCharMap()
    uiWidget:setString(startCharMap)
end

function GUITXTEditor:SetChatWidth(value)
    local stringValue  = self._selWidget:getStringValue()
    local charMapFile  = self._selWidget:getCharMapFile()
    local itemWidth    = value
    local itemHeight   = self._selWidget:getItemHeight()
    local startCharMap = self._selWidget:getStartCharMap()
    GUI:TextAtlas_setProperty(self._selWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)

    self:resetDrawRect()
    self:setCommonAttrUI()
end

function GUITXTEditor:SetUIChatWidth(uiWidget, widget)
    local itemWidth = widget:getItemWidth()
    uiWidget:setString(itemWidth)
end

function GUITXTEditor:SetChatHeight(value)
    local stringValue  = self._selWidget:getStringValue()
    local charMapFile  = self._selWidget:getCharMapFile()
    local itemWidth    = self._selWidget:getItemWidth()
    local itemHeight   = value
    local startCharMap = self._selWidget:getStartCharMap()
    GUI:TextAtlas_setProperty(self._selWidget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)
end

function GUITXTEditor:SetUIChatHeight(uiWidget, widget)
    local itemHeight = widget:getItemHeight()
    uiWidget:setString(itemHeight)
end

function GUITXTEditor:SetRTextSpace(value)
    self:SetRTextAttribute("RSpace", value)
    self:resetDrawRect()
    self:setCommonAttrUI()
end

function GUITXTEditor:SetUIRTextSpace(uiWidget, widget)
    self:SetRTextUIAttribute(uiWidget, widget, "RSpace")
end

function GUITXTEditor:SetItemAttribute(key, value)
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

function GUITXTEditor:SetItemUIAttribute(uiWidget, widget, key)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.ITEM_SHOW)
    local value = data[key]
    value = (not value and ItemAttrDefault[key]) and ItemAttrDefault[key] or value
    uiWidget:setString(value)
end

function GUITXTEditor:SetItemID(value)
    self:SetItemAttribute("index", value)
end

function GUITXTEditor:SetUIItemID(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "index")
end

function GUITXTEditor:SetItemNum(value)
    self:SetItemAttribute("count", value)
end

function GUITXTEditor:SetUIItemNum(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "count")
end

function GUITXTEditor:SetItemData(value)
    if sfind(value, "$") then
        return false
    end
    self:SetItemAttribute("itemData", value)
end

function GUITXTEditor:SetUIItemData(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "itemData")
end

function GUITXTEditor:SetItemFrom(value)
    self:SetItemAttribute("from", value)
end

function GUITXTEditor:SetUIItemFrom(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "from")
end

function GUITXTEditor:SetItemFontSize(value)
    self:SetItemAttribute("countFontSize", value)
end

function GUITXTEditor:SetUIItemFontSize(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "countFontSize")
end

function GUITXTEditor:SetItemFontColor(value)
    self:SetItemAttribute("color", value)
end

function GUITXTEditor:SetUIItemFontColor(uiWidget, widget)
    self:SetItemUIAttribute(uiWidget, widget, "color")
end

function GUITXTEditor:SetMessageUIAttribute(uiWidget, widget, key)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.MESSAGE)
    uiWidget:setString(data[key])
end

function GUITXTEditor:SetMsgText(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "MsgData", value)
end

function GUITXTEditor:SetUIMsgText(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "MsgData")
end

function GUITXTEditor:SetMsgID(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "MsgID", value)
end

function GUITXTEditor:SetUIMsgID(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "MsgID")
end

function GUITXTEditor:SetMsgParam1(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "Param1", value)
end

function GUITXTEditor:SetUIMsgParam1(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "Param1")
end

function GUITXTEditor:SetMsgParam2(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "Param2", value)
end

function GUITXTEditor:SetUIMsgParam2(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "Param2")
end

function GUITXTEditor:SetMsgParam3(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "Param3", value)
end

function GUITXTEditor:SetUIMsgParam3(uiWidget, widget)
    if self._selDescription == "CheckBox" then
        local selected = self._selWidget:isSelected()

        local key   = GUIAttributes.MESSAGE
        local key2  = "Param3"
        local value = selected and 1 or 0
        self:SetCheckBoxAttribute(self._selWidget, key, key2, value)

        uiWidget:setString(value)
    else
        self:SetMessageUIAttribute(uiWidget, widget, "Param3")
    end
end

function GUITXTEditor:SetClickFunc(value)
    self:SetAttribute(GUIAttributes.MESSAGE, "FuncBody", value)
end

function GUITXTEditor:SetUIClickFunc(uiWidget, widget)
    self:SetMessageUIAttribute(uiWidget, widget, "FuncBody")
end

function GUITXTEditor:SetEndTime(value)
    local key = GUIAttributes.TEXT_COUNTDOWN
    local data = self:GetAttribeValue(self._selWidget, key)
    data.Param2 = value
    self:NBEx(self._selWidget, key, {isNB = self._selWidget:IsNB(key), value = data})
end

function GUITXTEditor:SetUIEndTime(uiWidget, widget)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.TEXT_COUNTDOWN)
    uiWidget:setString(data.Param2)
end

function GUITXTEditor:SetCDFunc(value)
    local key = GUIAttributes.TEXT_COUNTDOWN
    local data = self:GetAttribeValue(self._selWidget, key)
    data.Param3 = value
    self:NBEx(self._selWidget, key, {isNB = self._selWidget:IsNB(key), value = data})
end

function GUITXTEditor:SetUICDFunc(uiWidget, widget)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.TEXT_COUNTDOWN)
    uiWidget:setString(data.Param3)
end

function GUITXTEditor:SetUILuaMsg(uiWidget, widget)
    local key  = GUIAttributes.MESSAGE
    local key2 = "IsLuaMsg"
    self:SetCheckBoxUIAttribute(uiWidget, widget, key, key2)
end

function GUITXTEditor:SetUIClick(uiWidget, widget)
    local key  = GUIAttributes.MESSAGE
    local key2 = "IsClick"
    self:SetCheckBoxUIAttribute(uiWidget, widget, key, key2)
end

function GUITXTEditor:SetUICountDown(uiWidget, widget)
    local key  = GUIAttributes.TEXT_COUNTDOWN
    local key2 = "IsCheck"
    self:SetCheckBoxUIAttribute(uiWidget, widget, key, key2)
end

function GUITXTEditor:SetUISwallow(uiWidget, widget)
    local key  = GUIAttributes.SWALLOW
    local key2 = "Param2"
    self:SetCheckBoxUIAttribute(uiWidget, widget, key, key2)
end

function GUITXTEditor:SetCheckBoxUIAttribute(uiWidget, widget, key, key2)
    local data = self:GetAttribeValue(widget, key)
    local value = self:GetStatus(data[key2])
    uiWidget:setSelected(value)
    return value
end

function GUITXTEditor:SetCheckBoxAttribute(widget, key, key2, value)
    local data = self:GetAttribeValue(widget, key)
    data[key2] = value
    self:NBEx(widget, key, {isNB = true, value = data})
end

-- Common event
function GUITXTEditor:onSliderOpacityEvent(ref)
    local percent = ref:getPercent()
    self._selUICommonControl["TextField_Opacity"]:setString(percent)

    local opacity = math.floor(percent / 100 * 255)
    self._selWidget:setOpacity(opacity)
    self:updateNodeOpacity(opacity)
end

-- Special event
function GUITXTEditor:onSliderBgOpacityEvent(ref)
    if self._selWidget then
        local percent = ref:getPercent()
        self._selUISpecialControl["TextField_Bg_Opacity"]:setString(percent)
        self._selWidget:setBackGroundColorOpacity(math.floor(percent / 100 * 255))
    end
end

function GUITXTEditor:onLuaMsgEvent(ref)
    if self._selWidget then
        local key   = GUIAttributes.MESSAGE
        local key2  = "IsLuaMsg"
        local value = not ref:isSelected()
        self:SetCheckBoxAttribute(self._selWidget, key, key2, value)
    end
end

function GUITXTEditor:onClickEvent(ref)
    if self._selWidget then
        local key   = GUIAttributes.MESSAGE
        local key2  = "IsClick"
        local value = not ref:isSelected()
        self:SetCheckBoxAttribute(self._selWidget, key, key2, value)
    end
end

function GUITXTEditor:onCountDownEvent(ref)
    if self._selWidget then
        local key   = GUIAttributes.TEXT_COUNTDOWN
        local key2  = "IsCheck"
        local value = not ref:isSelected()
        self:SetCheckBoxAttribute(self._selWidget, key, key2, value)
    end
end

function GUITXTEditor:onItemSwallowEvent(ref)
    if self._selWidget then
        local key   = GUIAttributes.SWALLOW
        local key2  = "Param2"
        local value = not ref:isSelected()
        self:SetCheckBoxAttribute(self._selWidget, key, key2, value)
    end
end

function GUITXTEditor:onLBarCheckBoxEvent(ref)
    if self._selWidget then
        local isSelect = ref:isSelected()
        if isSelect then
            self._selWidget:setDirection(ccui.LoadingBarDirection.LEFT)
        else
            self._selWidget:setDirection(ccui.LoadingBarDirection.RIGHT)
        end
    end
end

function GUITXTEditor:onDirCheckBoxEvent(ref)
    if self._selWidget then
        if self._selDescription == "TableView" then
            local isSelect = ref:isSelected()
            if isSelect then
                self._selWidget:setDirection(1)
            else
                self._selWidget:setDirection(2)
            end
        else
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
end

function GUITXTEditor:onUICheckBoxSelectEvent()
    if self._selWidget then
        local selected = self._selWidget:isSelected()
        self._selWidget:setSelected(not selected)

        local key   = GUIAttributes.MESSAGE
        local key2  = "Param3"
        local value = selected and 0 or 1
        self:SetCheckBoxAttribute(self._selWidget, key, key2, value)

        self._selUISpecialControl["TextField_Msg_P3"]:setString(value)
    end
end

function GUITXTEditor:onResNSetCallFunc(res)
    if self._selUISpecialControl["TextField_N_Res"] then
        self._SpecialAttr["TextField_N_Res"].SetWidget(res, 1)
        self._SpecialAttr["TextField_N_Res"].SetUIWidget(self._selUISpecialControl["TextField_N_Res"], self._selWidget)

        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUITXTEditor:onResPSetCallFunc(res)
    if self._selUISpecialControl["TextField_P_Res"] then
        self._SpecialAttr["TextField_P_Res"].SetWidget(res, 1)
        self._SpecialAttr["TextField_P_Res"].SetUIWidget(self._selUISpecialControl["TextField_P_Res"], self._selWidget)

        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

function GUITXTEditor:onResDSetCallFunc(res)
    if self._selUISpecialControl["TextField_D_Res"] then
        self._SpecialAttr["TextField_D_Res"].SetWidget(res, 1)
        self._SpecialAttr["TextField_D_Res"].SetUIWidget(self._selUISpecialControl["TextField_D_Res"], self._selWidget)

        self:resetDrawRect()
        self:setCommonAttrUI()
    end
end

-- 打开资源选择界面
function GUITXTEditor:onOpenGUIResSelector(ref)
    releaseLayerGUI("GUIResSelector")
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, {res = ref.__res__, callfunc = self._SpecialAttr[ref:getName()].callfunc})
end

-- 打开变量管理界面
function GUITXTEditor:onOpenGUIVarManager(ref)
    releaseLayerGUI("GUIVarManager")
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIVarManager_Open)
end

-- 是否设置剪裁
function GUITXTEditor:onClipEvent()
    if self._selWidget then
        self._selWidget:setClippingEnabled(not self._selWidget:isClippingEnabled())
    end
end

-- 是否开启回弹
function GUITXTEditor:onReboundEvent()
    if self._selWidget then
        self._selWidget:setBounceEnabled(not self._selWidget:isBounceEnabled())
    end
end

function GUITXTEditor:onClipEvent()
    if self._selWidget then
        self._selWidget:setClippingEnabled(not self._selWidget:isClippingEnabled())
    end
end

-- 是否背景填充
function GUITXTEditor:onBgtcEvent()
    if self._selWidget then
        local clipType = self._selWidget:getBackGroundColorType()
        clipType = clipType == 0 and 1 or 0
        self._selWidget:setBackGroundColorType(clipType)
        self:setBgtc(clipType ~= 0)
    end
end

-- 是否九宫格
function GUITXTEditor:onCapInsetEvent()
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

-- 是否描边
function GUITXTEditor:onTextOutlineEvent()
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

-- 特效是否循环播放
function GUITXTEditor:onEffectPlayEvent(ref)
    self:SetEffectAttribute("loop", not ref:isSelected())
end

-- ScrollView 开启多行开关
function GUITXTEditor:onSViewMoreRowEvent(ref)
    local enable = not ref:isSelected()
    self:setSVMoreRowEdit(enable)
    self:SetAttribute(GUIAttributes.SCROLLVIEW_MOREROW, "IsClick", enable)
end

function GUITXTEditor:onSViewPlayActionEvent(ref)
    self:SetAttribute(GUIAttributes.SCROLLVIEW_MOREROW, "play", not ref:isSelected())
end

function GUITXTEditor:onButtonPageEvent(ref)
    self:SetAttribute(GUIAttributes.BUTTON_PAGE, "Param2", not ref:isSelected())
end

function GUITXTEditor:onItemLookEvent(ref)
    self:SetItemAttribute("look", not ref:isSelected())
end

function GUITXTEditor:onItemShowBgEvent(ref)
    self:SetItemAttribute("bgVisible", not ref:isSelected())
end

function GUITXTEditor:onItemShowNumEvent(ref)
    self:SetItemAttribute("disShowCount", not ref:isSelected())
end

function GUITXTEditor:onItemShowStarEvent(ref)
    self:SetItemAttribute("starLv", not ref:isSelected())
end

function GUITXTEditor:onItemShowMaskEvent(ref)
    self:SetItemAttribute("notShowEquipRedMask", not ref:isSelected())
end

function GUITXTEditor:onItemShowPowerCEvent(ref)
    self:SetItemAttribute("checkPower", not ref:isSelected())
end

function GUITXTEditor:onItemShowEffectEvent(ref)
    self:SetItemAttribute("isShowEff", not ref:isSelected())
end

function GUITXTEditor:onItemShowModelEffectEvent(ref)
    self:SetItemAttribute("showModelEffect", not ref:isSelected())
end

-- EquipShow
function GUITXTEditor:SetEquipAttribute(key, value)
    local item = self._selWidget:getChildByName("__EQUIPSHOW__")
    if item then
        item:removeFromParent()
    end

    self:SetAttribute(GUIAttributes.EQUIP_SHOW, key, value)
    if key == "look" then
        self:SetAttribute(GUIAttributes.EQUIP_SHOW, "noMouseTips", not value)
    end
    self:CreateEquipShow(self._selWidget)
end

local EquipAttrDefault = {
    ["countFontSize"] = 15, ["color"] = "#FFFFFF", ["from"] = 0
}

function GUITXTEditor:SetEquipUIAttribute(uiWidget, widget, key)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.EQUIP_SHOW)
    local value = data[key]
    value = (not value and EquipAttrDefault[key]) and EquipAttrDefault[key] or value
    uiWidget:setString(value)
end

function GUITXTEditor:SetEquipPos(value)
    self:SetEquipAttribute("pos", value)
end

function GUITXTEditor:SetUIEquipPos(uiWidget, widget)
    self:SetEquipUIAttribute(uiWidget, widget, "pos")
end

function GUITXTEditor:onEquipLookEvent(ref)
    self:SetEquipAttribute("look", not ref:isSelected())
end

function GUITXTEditor:onEquipShowBgEvent(ref)
    self:SetEquipAttribute("bgVisible", not ref:isSelected())
end

function GUITXTEditor:onEquipShowStarEvent(ref)
    self:SetEquipAttribute("starLv", not ref:isSelected())
end

function GUITXTEditor:onEquipAutoUpdateEvent(ref)
    self:SetEquipAttribute("autoUpdate", not ref:isSelected())
end

function GUITXTEditor:onEquipIsHeroEvent(ref)
    self:SetEquipAttribute("isHero", not ref:isSelected())
end

function GUITXTEditor:onEquipAddDoubleEvent(ref)
    self:SetEquipAttribute("doubleTakeOff", not ref:isSelected())
end

function GUITXTEditor:onEquipAddMoveEvent(ref)
    self:SetEquipAttribute("movable", not ref:isSelected())
end

function GUITXTEditor:onColorSetCallFunc(color)
    if self._SpecialAttr["TextField_C"] then
        self._SpecialAttr["TextField_C"].SetWidget(color)
        self._SpecialAttr["TextField_C"].SetUIWidget(self._selUISpecialControl["TextField_C"], self._selWidget)
    end
end

function GUITXTEditor:onColorOutlineSetCallFunc(color)
    if self._SpecialAttr["TextField_Outline_C"] then
        self._SpecialAttr["TextField_Outline_C"].SetWidget(color)
        self._SpecialAttr["TextField_Outline_C"].SetUIWidget(self._selUISpecialControl["TextField_Outline_C"], self._selWidget)
    end
end

function GUITXTEditor:onColorButtonPressSetCallFunc(color)
    if self._SpecialAttr["TextField_Press_C"] then
        self._SpecialAttr["TextField_Press_C"].SetWidget(color)
        self._SpecialAttr["TextField_Press_C"].SetUIWidget(self._selUISpecialControl["TextField_Press_C"], self._selWidget)
    end
end

function GUITXTEditor:onColorLBarLColorSetCallFunc(color)
    if self._SpecialAttr["TextField_LBar_LC"] then
        self._SpecialAttr["TextField_LBar_LC"].SetWidget(color)
        self._SpecialAttr["TextField_LBar_LC"].SetUIWidget(self._selUISpecialControl["TextField_LBar_LC"], self._selWidget)
    end
end

function GUITXTEditor:onColorInputPlaceHolderColorSetCallFunc(color)
    if self._SpecialAttr["TextField_C2"] then
        self._SpecialAttr["TextField_C2"].SetWidget(color)
        self._SpecialAttr["TextField_C2"].SetUIWidget(self._selUISpecialControl["TextField_C2"], self._selWidget)
    end
end

function GUITXTEditor:onOpenClolorSelector(ref)
    releaseLayerGUI("GUIColorSelector")
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIColorSelector_Open, {color = ref.__color__, callfunc = self._SpecialAttr[ref:getName()].callfunc})
end

function GUITXTEditor:onLanguage(ref)
    local lang = self._language == 0 and 1 or 0
    self._language = lang

    self:SetSaveLocalValue("lang", lang)
    self:setButtonLanguageText(lang)

    self:updateTreeNodes()
end

function GUITXTEditor:onOpenSpecialAtt()
    releaseLayerGUI("GUITXTEditorEvent")
    global.Facade:sendNotification(global.NoticeTable.Layer_GUITXTEditorEvent_Open, {conditions = self._trigger or {}, callback = function (data) self._trigger = data end})
end

-- 导出------------------------------------------------------------------------------
function GUITXTEditor:onSaveFile()
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
function GUITXTEditor:checkExportFolder(file)
    local folder = self._defaultPath

    if file then
        folder = sformat("%s/%s", folder, file)
    end
    
    if self:IsDirectory(folder) then
        return false
    end

    fileUtil:createDirectory(folder)
end

function GUITXTEditor:checkLocalNum()
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
        TableView   = 1,
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

function GUITXTEditor:SaveCache(source, clear)
    if clear then
        self._caches = {}
    end
    
    self._caches[#self._caches + 1] = source or self:OutputGUI()
    self._IsZing = false
end

function GUITXTEditor:OutputGUI()
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
        TableView   = handler(self, self.output_TableView),
        Widget      = handler(self, self.output_Node),
        Effect      = handler(self, self.output_Effect),
        Item        = handler(self, self.output_Item),
        Model       = handler(self, self.output_Model),
        EquipShow   = handler(self, self.output_EquipShow)
    }

    self._repeatName = self:checkLocalNum()

    self._GUINames = {}

    local class = "ui"

    local outputHead = sformat("local %s = {}%s%s", class, charMask.br, charMask.br)

    local output = ""

    local outputCell  = ""
    local cellContent = ""

    local function parse(d, i, parent)
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
                if parent ~= -1 and next(d.parent) then
                    parent = self:GetParent(d.parent):getName()
                end
                output = sformat("%s%s", output, outputUI[desc](widget, parent, name))
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

    local function parse2(d, parent)
        local widget = d and d.widget
        if widget then
            local desc = widget:getDescription()
            if outputUI[desc] then
                if parent == -1 then
                    cellContent = sformat("%s%s", cellContent, self:brEx())
                else
                    cellContent = sformat("%s%s%s", cellContent, charMask.br, self:brEx())
                end

                local name = widget:getName() 
                if parent ~= -1 and next(d.parent) then
                    parent = self:GetParent(d.parent):getName()
                else
                    parent = "parent"
                end
                cellContent = sformat("%s%s", cellContent, outputUI[desc](widget, parent, name, true))
            end
        end
    end

    local function parseChilren2(children)
        for _,v in pairs(children) do
            local idx = self:getTreeIdxByObj(v.widget)
            if idx then
                parse2(self._uiTree[idx])
                if next(self._uiTree[idx].children) then
                    parseChilren2(self:convertChildrenFormat(self._uiTree[idx].children))
                end
            end
        end
    end


    local br = self:brEx()

    local cellFuncStr = ""

    for i = 1, #self._uiTree do
        local d = self._uiTree[i]

        local widget = d.widget
        local cID = GUI:getID(widget)
        if cID > 0 then
            cellContent = ""
            IsChildUI = true
            
            if not next(d.parent) then
                parse2(d, -1)
            end
            if not next(d.parent) and next(d.children) then
                parseChilren2(self:convertChildrenFormat(d.children))
            end

            cellFuncStr = sformat("%s\n%s-- ui.getCell_%s(parent, i)", cellFuncStr, br, cID)

            cellContent = sgsub(cellContent, "GUI:setTag%((.-), (.-)%)", function ( a, b)
                if tonumber(b) == -1 then
                    return sformat("GUI:setTag(%s, i)", a)
                end
            end)
    
            cellContent = sformat("\nfunction ui.getCell_%s(parent, i)%s\n%sreturn %s\nend\n", cID, cellContent, br, widget:getName())
            outputCell  = outputCell .. cellContent

            IsChildUI = false
        end
    end

    for i = 1, #self._uiTree do
        local d = self._uiTree[i]
        if GUI:getID(d.widget) > 0 then
        else
            if not next(d.parent) then
                parse(d, i, "parent")
            end
            if not next(d.parent) and next(d.children) then
                parseChilren(self:convertChildrenFormat(d.children))
            end
        end
    end

    output = output .. cellFuncStr

    local strPageFunc = 
                "\n"        ..  "function ui.setButtonClickBright(list, tag, pressColor)"
            .. "\n\t"       ..      "for _, child in ipairs(list:getChildren()) do"
            .. "\n\t\t"     ..          "local enable = GUI:getTag(child) == tag"
            .. "\n\t\t"     ..          "if enable then"
            .. "\n\t\t\t"   ..              "GUI:setTouchEnabled(child, false)"
            .. "\n\t\t\t"   ..              "GUI:Button_setBright(child, true)"
            .. "\n\t\t\t"   ..              "if pressColor then"
            .. "\n\t\t\t\t" ..                  "GUI:Button_setTitleColor(child, pressColor)"
            .. "\n\t\t\t"   ..              "end"
            .. "\n\t\t"     ..          "else"
            .. "\n\t\t\t"   ..              "GUI:setTouchEnabled(child, true)"
            .. "\n\t\t\t"   ..              "GUI:Button_setBright(child, false)"
            .. "\n\t\t"     ..          "end"
            .. "\n\t"       ..      "end"
            .. "\n"         ..  "end"

    local strPerFunc = 
                "\n"        ..  "function ui.loadLadingBar(widget, value, maxValue, init, interval, step)"   
            .. "\n\t"       ..      "local setLabelText = function (v)"
            .. "\n\t\t"     ..          "local label = widget._renderlabel"
            .. "\n\t\t"     ..          "if GUI:Win_IsNotNull(label) then"
            .. "\n\t\t\t"   ..              "GUI:Text_setString(label, v .. \"%\")"
            .. "\n\t\t"     ..          "end"
            .. "\n\t"       ..      "end"
            .. "\n"           
            .. "\n\t"       ..      "value, maxValue = tonumber(value), tonumber(maxValue)"
            .. "\n"
            .. "\n\t"       ..      "if not value or not maxValue then"
            .. "\n\t\t"     ..          "GUI:LoadingBar_setPercent(widget, 0)"
            .. "\n\t\t"     ..          "setLabelText(0)"
            .. "\n\t\t"     ..          "return false"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "local percent = math.floor(value / maxValue * 100)"
            .. "\n\t"       ..      "percent = math.min(percent, 100)"
            .. "\n"
            .. "\n\t"       ..      "if init then"
            .. "\n\t\t"     ..          "GUI:LoadingBar_setPercent(widget, percent)"
            .. "\n\t\t"     ..          "setLabelText(percent)"
            .. "\n\t\t"     ..          "return false"
            .. "\n\t"       ..      "end"
            .. "\n"                     
            .. "\n\t"       ..      "if tonumber(interval) and tonumber(interval) <= 0 then"
            .. "\n\t\t"     ..          "GUI:LoadingBar_setPercent(widget, percent)"
            .. "\n\t\t"     ..          "return false"
            .. "\n\t"       ..      "end"
            .. "\n"     
            .. "\n\t"       ..      "GUI:stopAllActions(widget)"
            .. "\n\t"       ..      "local from = widget:getPercent()"
            .. "\n\t"     ..        "setLabelText(from)"
            .. "\n"       
            .. "\n\t"       ..      "local function scheduleCB()"
            .. "\n\t\t"     ..          "from = from + step"
            .. "\n\t\t"     ..          "GUI:LoadingBar_setPercent(widget, from)"
            .. "\n"
            .. "\n\t\t"     ..          "setLabelText(from)"
            .. "\n"
            .. "\n\t\t"     ..          "if from >= percent then"
            .. "\n\t\t\t"   ..              "GUI:stopAllActions(widget)"
            .. "\n\t\t"     ..          "end"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "SL:schedule(widget, scheduleCB, interval)"
            .. "\n\t"       ..      "scheduleCB()"
            .. "\n"         ..  "end"

    local strInputFunc = 
                "\n"        ..  "function ui.onInputEvent(sender, eventType)"
            .. "\n\t"       ..      "if eventType ~= 2 then"
            .. "\n\t\t"     ..          "return false"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "local params = GUI:Win_GetParam(sender)"
            .. "\n\t"       ..      "if not params then"
            .. "\n\t\t"     ..          "return false"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "local inputtype = params.type or 0"
            .. "\n\t"       ..      "if not (inputtype == 1 or inputtype == 3) then"
            .. "\n\t\t"     ..          "return false"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "local str = GUI:TextInput_getString(sender)"
            .. "\n\t"       ..      "str = string.gsub(str, \"(.-)([^%d]+)\", \"%1\")"
            .. "\n\t"       ..      "GUI:TextInput_setString(sender, str)"
            .. "\n"
            .. "\n\t"       ..      "if not inputtype == 3 then"
            .. "\n\t\t"     ..          "return false"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "local str = GUI:TextInput_getString(sender)"
            .. "\n\t"       ..      "local num = tonumber(str)"
            .. "\n\t"       ..      "if num and tostring(num) ~= str then"
            .. "\n\t\t"     ..          "GUI:TextInput_setString(sender, num)"
            .. "\n\t"       ..      "end"
            .. "\n"         ..  "end"

    local strButtonFunc = 
                "\n"        ..  "function ui.onButtonTouchEvent(sender, eventType)"
            .. "\n\t"       ..      "if eventType ~= 2 then"
            .. "\n\t\t"     ..          "return false"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "local params = GUI:Win_GetParam(sender)"
            .. "\n\t"       ..      "local ids = params and params.ids"
            .. "\n"
            .. "\n\t"       ..      "if type(ids) ~= \"string\" then"
            .. "\n\t\t"     ..          "return false"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "local strList  = {}"
            .. "\n\t"       ..      "local jsonData = {}"
            .. "\n"
            .. "\n\t"       ..      "for _, id in ipairs(SL:Split(ids, \"#\")) do"
            .. "\n\t\t"     ..          "local id = tonumber(id) or -1"
            .. "\n\t\t"     ..          sformat("local widget = %s[id]", mapsInput)
            .. "\n\t\t"     ..          "if GUI:Win_IsNotNull(widget) then"
            .. "\n\t\t\t"   ..              "local str = GUI:TextInput_getString(widget)"
            .. "\n\t\t\t"   ..              "jsonData[tostring(id)] = str"
            .. "\n"
            .. "\n\t\t\t"   ..              "local params = GUI:Win_GetParam(widget)"
            .. "\n\t\t\t"   ..              "if params.checkSensitive then"
            .. "\n\t\t\t\t" ..                  "table.insert(strList, str)"
            .. "\n\t\t\t"   ..              "end"
            .. "\n\t\t"     ..          "end"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "local sendMsg = function (data)"
            .. "\n\t\t"     ..          "SL:SendNetMsg(0, 0, 0, 0, SL:JsonEncode(data))"
            .. "\n\t"       ..      "end"
            .. "\n"
            .. "\n\t"       ..      "if #strList > 0 then"
            .. "\n\t\t"     ..          "SL:RequestCheckSensitiveWordEx(strList, 2, function (state)"
            .. "\n\t\t\t"   ..              "if state then"
            .. "\n\t\t\t\t" ..                  "sendMsg(jsonData)"
            .. "\n\t\t\t"   ..              "else"
            .. "\n\t\t\t\t" ..                  "SL:ShowSystemTips(\"请不要包含敏感字或者特殊字符！\")"
            .. "\n\t\t\t"   ..              "end"
            .. "\n\t\t"     ..          "end)"
            .. "\n\t"       ..      "else"
            .. "\n\t\t"     ..          "if next(jsonData) then"
            .. "\n\t\t\t"   ..              "sendMsg(jsonData)"
            .. "\n\t\t"     ..          "end"
            .. "\n\t"       ..      "end"
            .. "\n"         ..  "end"

    local strSliderFunc = 
                "\n"        ..  "function ui.onSliderEvent(sender, eventType)"
	        .. "\n\t"       ..      "local percent = math.floor(GUI:Slider_getPercent(sender))"
	        .. "\n\t"       ..      "if eventType == 0 then"
            .. "\n\t\t"     ..	        "local params = GUI:Win_GetParam(sender)"
            .. "\n\t\t"     ..	        "local ids = params and params.ids"
            .. "\n"
            .. "\n\t\t"     ..	        "if type(ids) ~= \"string\" then"
            .. "\n\t\t\t"   ..		        "return false"
            .. "\n\t\t"     ..		    "end"
            .. "\n"
            .. "\n\t\t"     ..	        "for _, id in ipairs(SL:Split(ids, \"#\")) do"
            .. "\n\t\t\t"   ..		        "local id = tonumber(id) or -1"
            .. "\n\t\t\t"   ..		        sformat("local widget = %s[id]", mapsSlider)
            .. "\n\t\t\t"   ..		        "if GUI:Win_IsNotNull(widget) then"
            .. "\n\t\t\t\t" ..			        "local str = GUI:Text_getString(widget)"
            .. "\n\t\t\t\t" ..			        "local newStr = string.gsub(str, \"(%d+)\", percent)"
            .. "\n\t\t\t\t" ..			        "GUI:Text_setString(widget, newStr)"
            .. "\n\t\t\t"   ..		        "end"
            .. "\n\t\t"     ..	        "end"
	        .. "\n\t"       ..      "elseif eventType == 2 then"
            .. "\n\t\t"     ..	        "SL:SendNetMsg(1, 0, 0, percent)"
	        .. "\n\t"       ..      "end"
            .. "\n"         ..  "end"


    if IsQueueFunc then
        outputHead = sformat("%slocal %s = {}%s%s", outputHead, funcQueue, charMask.br, charMask.br)
        if IsInputFunc then
            outputHead = sformat("%slocal %s = {}%s%s", outputHead, mapsInput, charMask.br, charMask.br)
        end
        if IsSliderFunc then
            outputHead = sformat("%slocal %s = {}%s%s", outputHead, mapsSlider, charMask.br, charMask.br)
        end

        if IsPageFunc then
            outputHead = sformat("%slocal %s = {}%s%s", outputHead, pData, charMask.br, charMask.br)
            outputHead = sformat("%sfunction %s%sinit(parent, __update__, i, data)", outputHead, class, charMask.point)
        else
            outputHead = sformat("%sfunction %s%sinit(parent, __update__, i)", outputHead, class, charMask.point)
        end

        local strUpdates = sformat("if __update__ then%s%sreturn %s.update()%send", br, charMask.t, class, br)
        strUpdates = sformat("%s-- Update --%s%s%s-- Update end --", br, br, strUpdates, br)

        local outputTail = "\nend\n"

        local strClear = sformat("%s%s.clear()%s", br, class, br)

        local strEvent = sformat("\t%s.initEvent(parent)%s", class, br)

        if IsPageFunc then
            local strDataVar = sformat("%s%s = data", br, pData)
            output = sformat("%s%s\n%s\n%s\n%s%s%s", outputHead, strUpdates, strDataVar, strClear, strEvent, output, outputTail)
        else
            output = sformat("%s%s\n%s\n%s%s%s", outputHead, strUpdates, strClear, strEvent, output, outputTail)
        end

        local strUpdatefuncs = sformat("\nfunction %s.update()\n\tfor widget, v in pairs(%s) do\n\t\tif v then\n\t\t\tlocal func = GUI:GetRefreshVarFunc(widget)\n\t\t\tif func then\n\t\t\t\tfunc(widget)\n\t\t\tend\n\t\tend\n\tend\nend", class, funcQueue)

        local strClearfuncs = sformat("\nfunction %s.clear()\n\t%s = {}\nend", class, funcQueue) 

        local strEventfuncs = sformat("\nfunction %s.initEvent(parent)%s\nend", class, self:parseTrigger())

        output = sformat("%s%s%s", output, strClearfuncs, charMask.br)

        output = sformat("%s%s%s", output, strEventfuncs, charMask.br)

        output = IsButtonFunc and sformat("%s%s%s", output, strButtonFunc, charMask.br) or output

        output = IsSliderFunc and sformat("%s%s%s", output, strSliderFunc, charMask.br) or output

        output = IsInputFunc and sformat("%s%s%s", output, strInputFunc, charMask.br) or output

        output = IsPageFunc and sformat("%s%s%s", output, strPageFunc, charMask.br) or output

        output = IsPerFunc and sformat("%s%s%s", output, strPerFunc, charMask.br) or output

        output = sformat("%s%s%s%s%sreturn %s", output, outputCell, strUpdatefuncs, charMask.br, charMask.br, class)
    else
        outputHead = sformat("%sfunction %s%sinit(parent)", outputHead, class, charMask.point)
        output = sformat("%s%s%send%s%s%sreturn %s", outputHead, output, charMask.br, charMask.br, outputCell, charMask.br, class)
    end

    self:OutputServerVar()

    return output
end

function GUITXTEditor:OutputServerVar()
    local filepath = "dev/GUIValue/Var_server.lua"
    local data = fileUtil:isFileExist(filepath) and SL:RequireFile(filepath) or {}

    local keys = {}
    for i = 1, #data do
        local key = data[i]
        if key then
            keys[key] = 1
        end
    end

    local str = nil
    for key, _ in pairs(SerVarNames) do
        if not keys[key] then
            data[#data+1] = key
        end
    end

    tSort(data, function ( a, b ) return a < b end)

    local strs = nil
    for i = 1, #data do
        local key = data[i]
        if key then
            key = "\"" .. key .. "\""
            strs = strs and strs .. ",\n\t" .. key or "\t" .. key
        end
    end

    strs = sformat("return \n{\n%s\n}", strs or "")

    fileUtil:writeStringToFile(strs, filepath)
    fileUtil:purgeCachedEntries()
end

function GUITXTEditor:brEx()
    return sformat("%s%s", charMask.br, charMask.t)
end

function GUITXTEditor:parseTrigger()
    local data = self._trigger or {}
    local n = #data
    if n < 1 then
        return ""
    end

    local br = self:brEx()

    local updateStr = sformat("\tui.update()", br)

    local getConditionStr = function (d)
        local str = ""
        for i, v in ipairs(d) do
            if v then
                str = slen(str) > 0 and str .. "\n\n\t\t" or str
                str = sformat("%sif (%s) then %s\t\t%s %s\telse %s\t\t%s %s\tend", str, v.ID, br, v.Act1, br, br, v.Act2, br)
            end
        end
        str = #str > 0 and sformat("%s\n%s%s", str, br, updateStr) or updateStr

        return str
    end

    local bindUIName = "parent"

    local strs  = ""
    local unbindStr = ""

    for i, trg in ipairs(data) do
        local eventID = (trg.events and trg.events[1] and trg.events[1].EventID and slen(trg.events[1].EventID) > 0) and trg.events[1].EventID
        local bindStr = ""
        if eventID then
            local eventName = trg.triggerName

            local str1 = sformat("EVENT_ON(%s, \"%s\", function()%s\t%s %send, %s)", eventID, eventName, br, getConditionStr(trg.conditions or {}), br, bindUIName)
            bindStr = sformat("%s%s%s", bindStr, br, str1)

            strs = #strs > 0 and sformat("%s%s\t\t%s", strs, br, sformat("%s-- Trigger --%s%s-- Trigger end --", br, bindStr, br))  or sformat("%s-- Trigger --%s%s-- Trigger end --", br, bindStr, br)

            -- 注销字符串
            unbindStr = #unbindStr > 0 and sformat("%s%s\t\t%s", unbindStr, br, sformat("EVENT_OFF(%s, \"%s\")", eventID, eventName)) or sformat("EVENT_OFF(%s, \"%s\")", eventID, eventName)
        end
    end
        
    if #strs > 0 then
        unbindStr = sformat("GUI:addStateEvent(%s, function (state)%s\tif state == \"exit\" then%s\t\t%s%s\tend%send)", bindUIName, br, br, unbindStr, br, br)
        strs = strs .. "\n\n\t" .. unbindStr
    end

    return strs
end

function GUITXTEditor:parseCommon(widget, ID, notRef)
    local funcBodys = ""
    local strs = ""

    local br = self:brEx()

    local chinesename = GUI:getChineseName(widget)
    if chinesename ~= "" then
        strs = sformat("%s%s%s", strs, br, sformat([[GUI:setChineseName(%s, "%s")]], ID, chinesename))
    end

    local cID = GUI:getID(widget)
    if cID ~= 0 then
        strs = sformat("%s%s%s", strs, br, sformat([[GUI:setID(%s, %s)]], ID, cID))
    end

    if widget:getDescription() == "Effect" then
    else
        local strAnrX, anrX, Is1 = self:GetStrFloat(widget, Attributes.ANRX)
        local strAnrY, anrY, Is2 = self:GetStrFloat(widget, Attributes.ANRY)
        if not (Is1 and tonumber(anrX) == 0) or not (Is2 and tonumber(anrY) == 0) then
            strs = sformat("%s%s%s", strs, br, sformat("GUI:setAnchorPoint(%s" .. strAnrX .. strAnrY.. ")", ID, anrX, anrY))
        end

        if not Is1 or not Is2 and not notRef then
            funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setAnchorPoint(sender" .. strAnrX .. strAnrY .. ")", anrX, anrY))
        end
    end

    local isFlippedX = widget:isFlippedX()
    if isFlippedX then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setFlippedX(%s, %s)", ID, true))
    end

    local isFlippedY = widget:isFlippedY()
    if isFlippedY then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setFlippedY(%s, %s)", ID, true))
    end

    local strRotate, rotate, Is = self:GetStrFloat(widget, Attributes.ROTATE)
    if not (Is and tonumber(rotate) == 0) then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setRotation(%s" .. strRotate .. ")", ID, rotate))
    end
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setRotation(sender" .. strRotate .. ")", rotate))
    end

    local strScaleX, scaleX, Is = self:GetStrFloat(widget, Attributes.SCALEX)
    if not (Is and tonumber(scaleX) == 1) then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setScaleX(%s" .. strScaleX .. ")", ID, scaleX))
    end
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setScaleX(sender" .. strScaleX .. ")", scaleX))
    end

    local strScaleY, scaleY, Is = self:GetStrFloat(widget, Attributes.SCALEY)
    if not (Is and tonumber(scaleY) == 1) then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setScaleY(%s" .. strScaleY .. ")", ID, scaleY))
    end
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setScaleY(sender" .. strScaleY .. ")", scaleY))
    end

    local strOpacity, opacity, Is = self:GetStrInt(widget, Attributes.OPACITY)
    if not (Is and opacity == 255) then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setOpacity(%s" .. strScaleY .. ")", ID, opacity))
    end
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setScaleX(sender" .. strOpacity .. ")", opacity))
    end

    if tolua.type(widget) == "ccui.Widget" then
    else
        local strTouch, isTouch, Is = self:GetStrBoolean(widget, Attributes.ISTOUCH)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setTouchEnabled(%s" .. strTouch .. ")", ID, isTouch))

        if not Is and not notRef then
            funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setTouchEnabled(sender" .. strTouch .. ")", isTouch))
        end    
    end

    local strTag, tag, Is = self:GetStrInt(widget, Attributes.TAG)
    strs = sformat("%s%s%s", strs, br, sformat("GUI:setTag(%s" .. strTag .. ")", ID, tag))
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setTag(sender" .. strTag .. ")", tag))
    end

    local strVisible, visible, Is = self:GetStrBoolean(widget, Attributes.VISIBLE)
    if not (Is and visible) then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setVisible(%s" .. strVisible .. ")", ID, visible))
    end
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setVisible(sender" .. strVisible .. ")", visible))
    end

    local data = self:GetAttribeValue(widget, GUIAttributes.SWALLOW)
    local IsSwallow = self:GetStatus(data.Param2)
    if widget:getDescription() == "Item" then
        strs = sformat("%s%s%s", strs, br, sformat([[GUI:ItemShow_setItemTouchSwallow(%s, %s)]], ID, IsSwallow))
    elseif widget:getDescription() == "Effect" then
    elseif not IsSwallow then
        strs = sformat("%s%s%s", strs, br, sformat([[GUI:setSwallowTouches(%s, %s)]], ID, false))
    end

    local data = self:GetAttribeValue(widget, GUIAttributes.UIIDS)
    local uStr = nil
    for k, v in pairs(data) do
        if tonumber(v) and tonumber(v) == 0 then
        else
            uStr = uStr and sformat("%s, %s = %s", uStr, k, GUIHelper.ConvertToRunFormart(v)) or sformat("%s = %s", k, GUIHelper.ConvertToRunFormart(v))
        end
    end
    if uStr then
        strs = sformat("%s%s%s", strs, br,  sformat("GUI:setUIIDs(%s, {%s})", ID, uStr))
    end

    return strs, funcBodys
end

function GUITXTEditor:parseContentSize(widget, ID, nimg, isScale9)
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

function GUITXTEditor:formatText(text)
    local l = "[["
    local r = "]]"
    if sfind(text, "%[") or sfind(text, "%]") then
        l = "[==========["
        r = "]==========]"
    end
    return sformat("%s%s%s", l, text, r)
end

function GUITXTEditor:GetLuaMsgStr(data)
    local msgID = data.MsgID and GUIHelper.ConvertToRunFormart(data.MsgID)

    if not msgID or msgID == 0 or msgID == "" then
        return ""
    end

    local msgData = data.MsgData or " "
    local param1  = data.Param1 or 0
    local param2  = data.Param2 or 0
    local param3  = data.Param3 or 0
    
    local isVar   = false

    if msgData ~= " " then
        msgData, isVar = GUIHelper.ConvertToRunFormart(msgData)
        if not isVar then
            msgData = "\"" .. msgData .. "\""
        end
    else
        msgData = nil
    end

    if param1 ~= "" then
        param1 = GUIHelper.ConvertToRunFormart(param1) 
    end

    if param2 ~= "" then
        param2 = GUIHelper.ConvertToRunFormart(param2) 
    end

    if param3 ~= "" then
        param3 = GUIHelper.ConvertToRunFormart(param3) 
    end

    if GUIHelper.ConvertToRunFormart(data.IsLuaMsg) then
        return sformat([[SL:SendLuaNetMsg(%s, %s, %s, %s, %s)]], msgID, param1, param2, param3, msgData)
    end
    return sformat([[SL:SendNetMsg(%s, %s, %s, %s, %s)]], msgID, param1, param2, param3, msgData)
end

function GUITXTEditor:GetFuncStr(data)
    local isClick = self:GetStatus(data.IsClick, false)

    local IsLoad = false

    local funcBody = data.FuncBody or ""
    if funcBody ~= "" then
        funcBody = GUIHelper.ConvertToRunFormart(funcBody)
        IsLoad = true
    end

    if IsLoad or isClick then
        return sformat([[if %s then %s end]], isClick, funcBody)
    end

    return ""
end

function GUITXTEditor:getMsgStr(widget, ID)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.MESSAGE)
    if formatType ~= FormatType.VAR then
        return false
    end

    -- Lua msg
    local luaMsg  = self:GetLuaMsgStr(data)
    -- Click msg
    local funcMsg = self:GetFuncStr(data)

    if IsChildUI and not sfind(funcMsg, "SL:SkipPage%(") then
        funcMsg = sformat("%s SL:SkipPage(pData, i)", funcMsg) 
    end

    if slen(luaMsg) < 1 and slen(funcMsg) < 1 then
        return false
    end

    return sformat([[GUI:addOnClickEvent(%s, function () %s ; %s end)]], ID, luaMsg, sgsub(funcMsg, ";", ""))
end

function GUITXTEditor:getCountDownStr(widget, ID)
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.TEXT_COUNTDOWN)
    local IsCheck = data.IsCheck
    local time    = GUIHelper.ConvertToRunFormart(data.Param2)
    local funcStr = GUIHelper.ConvertToRunFormart(data.Param3)

    if tonumber(time) == 0 and funcStr == "" then
        return false
    end

    local br = self:brEx()

    funcStr = sformat("\tGUI:TEXT_COUNTDOWN(%s, %s, function (sender) %s; end)", ID, time, funcStr)

    funcStr = sgsub(funcStr, ";;", ";")

    local str = sformat("%sif %s then%s%s%send", br, IsCheck, br, funcStr, br)

    str = sformat("%s-- CountDown --%s%s-- CountDown end --", br, str, br)

    return str
end

function GUITXTEditor:checkRepeatName(ID)
    if not self._repeatName then
        return "local "
    end
    local str = self._GUINames[ID] and "" or "local "
    self._GUINames[ID] = true
    return str
end

function GUITXTEditor:output_Label(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:Text_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strFSize, FSize, Is = self:GetStrInt(widget, Attributes.FSIZE)
    str = str .. strFSize
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Text_setFontSize(sender" .. strFSize .. ")", FSize))
    end

    local strFColor, FColor, Is = self:GetStrVar(widget, Attributes.FCOLOR)
    str = str .. strFColor
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Text_setTextColor(sender" .. strFColor .. ")", FColor))
    end

    local strText, text, Is = self:GetStrString(widget, Attributes.TEXT)
    str = str .. strText
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Text_setString(sender" .. strText .. ")", text))
    end

    strs = sformat("%s%s", strs, sformat(str .. ")", defType, ID, parent, ID, x, y, FSize, FColor, text)) 

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    local isOutline = self:IsOutline(widget)
    if isOutline then
        local color = GetColorHexFromRBG(widget:getEffectColor())
        local lineSize = widget:getOutlineSize()
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Text_enableOutline(%s, \"%s\", %s)", ID, color, lineSize))
    else
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Text_disableOutLine(%s)", ID))
    end

    local msgStr = self:getMsgStr(widget, ID)
    if msgStr then
        strs = sformat("%s%s%s", strs, br, msgStr)
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    local data = self:GetAttribeValue(widget, GUIAttributes.LABEL_EX)
    local iID = tonumber(data.id) or 0
    if iID > 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Win_SetParam(%s, {id = %s}, \"Label\")", ID, iID))
        strs = sformat("%s%s%s%s[%s] = %s", strs, br, br, mapsSlider, iID, ID)

        IsSliderFunc = true
    end

    local CDStr = self:getCountDownStr(widget, ID)
    if CDStr then
        strs = sformat("%s%s%s", strs, br, CDStr)
    end

    return strs
end

function GUITXTEditor:output_BmpText(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)

    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:BmpText_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strFColor, FColor, Is = self:GetStrVar(widget, Attributes.FCOLOR)
    str = str .. strFColor
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Text_setTextColor(sender" .. strFColor .. ")", FColor))
    end

    local strText, text, Is = self:GetStrString(widget, Attributes.TEXT)
    str = str .. strText
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Text_setString(sender" .. strText .. ")", text))
    end

    strs = sformat("%s%s", strs, sformat(str .. ")", defType, ID, parent, ID, x, y, FColor, text))

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_TextAtlas(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)

    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:TextAtlas_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local stringValue  = widget:getStringValue()
    local charMapFile  = widget:getCharMapFile()
    local itemWidth    = widget:getItemWidth()
    local itemHeight   = widget:getItemHeight()
    local startCharMap = widget:getStartCharMap()
    GUI:TextAtlas_setProperty(widget, stringValue, charMapFile, itemWidth, itemHeight, startCharMap)

    strs = sformat("%s%s", strs, sformat(str .. ", \"%s\", \"%s\", %s, %s, \"%s\")", defType, ID, parent, ID, x, y, stringValue, charMapFile, itemWidth, itemHeight, startCharMap))

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_RText(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)

    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:RichText_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.RICH_TEXT)
    if formatType == FormatType.VAR then
        local Text, isMatch = GUIHelper.ConvertToRunFormart(data["Text"])
        if not isMatch then
            Text = "\"" .. Text .. "\""
        end
        local Width  = GUIHelper.ConvertToRunFormart(data["Width"])
        local RSize  = GUIHelper.ConvertToRunFormart(data["RSize"])
        local RColor = GUIHelper.ConvertToRunFormart(data["RColor"])
        local RSpace = GUIHelper.ConvertToRunFormart(data["RSpace"])
        local LinkCB = GUIHelper.ConvertToRunFormart(data["LinkCB"])
        local RFace  = GUIHelper.ConvertToRunFormart(data["RFace"])
        strs = sformat("%s%s", strs, sformat(str .. ", %s, %s, %s, \"%s\", %s, %s, \"%s\")", defType, ID, parent, ID, x, y, Text, Width, RSize, RColor, RSpace, LinkCB, RFace))
    else
        local data = GUIFuncKeys[GUIAttributes.RICH_TEXT](widget)
        strs = sformat("%s%s", strs, sformat(str .. ", \"%s\", %s, %s, \"%s\", %s, %s, \"%s\")", defType, ID, parent, ID, x, y, data.Text, data.Width, data.RSize, data.RColor, data.RSpace, data.LinkCB, data.RFace))
    end
    
    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_Button(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)

    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:Button_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strRes1, res1, Is = self:GetStrVar(widget, Attributes.RES1)
    str = str .. strRes1
    if Is then
        if res1 ~= "" and fileUtil:isFileExist(res1) then
        else
            res1 = sformat("%s%s", _PathRes, "Button_Normal.png")
        end
        res1 = FixPath(res1)
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Button_loadTextureNormal(sender" .. strRes1 .. ")", res1))
    end
    
    strs = sformat("%s%s", strs, sformat(str .. ")", defType, ID, parent, ID, x, y, res1))

    local strRes2, res2, Is = self:GetStrVar(widget, Attributes.RES2)
    if Is then
        if res2 ~= "" and fileUtil:isFileExist(res2) then
            res2 = FixPath(res2)
            strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_loadTexturePressed(%s".. strRes2.. ")", ID, res2))
        end
    else
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_loadTexturePressed(%s".. strRes2.. ")", ID, res2))
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Button_loadTexturePressed(sender" .. strRes2 .. ")", res2))
    end

    local strRes3, res3, Is = self:GetStrVar(widget, Attributes.RES3)
    if Is then
        if res3 ~= "" and fileUtil:isFileExist(res3) then
            res3 = FixPath(res3)
            strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_loadTextureDisabled(%s".. strRes3.. ")", ID, res3))
        end
    else
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_loadTextureDisabled(%s".. strRes3.. ")", ID, res3))
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Button_loadTextureDisabled(sender" .. strRes3 .. ")", res3))
    end

    local isScale9 = widget:isScale9Enabled()
    if isScale9 then
        local rect = self:getCapInset(widget)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setScale9Slice(%s, %s, %s, %s, %s)", ID, rect.l, rect.r, rect.t, rect.b))
    end

    local sizeStr = self:parseContentSize(widget, ID, res1, isScale9)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end

    local strText, text, Is = self:GetStrVar(widget, Attributes.BTEXT)
    strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setTitleText(%s" .. strText .. ")", ID, text))
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Button_setTitleText(sender" .. strText .. ")", text))
    end

    local strFColor, FColor, Is = self:GetStrVar(widget, Attributes.TCOLOR)
    strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setTitleColor(%s" .. strFColor .. ")", ID, FColor))
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Button_setTitleColor(sender" .. strFColor .. ")", FColor))
    end

    local size = widget:getTitleFontSize()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setTitleFontSize(%s, %s)", ID, size))
    
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

    local data = self:GetAttribeValue(widget, GUIAttributes.BUTTON_EX)
    local pStr = nil
    local ids = data["ids"]
    if ids and #ids > 0 then
        pStr = sformat("ids = \"%s\"", ids)
        IsButtonFunc = true
    end

    local grey, isMatch = GUIHelper.ConvertToRunFormart(data["grey"])
    if grey then
        pStr = pStr and sformat("%s, grey = %s", pStr, grey) or sformat("grey = %s", grey)
        if isMatch then
            funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Button_setBright(sender, %s == 1)", grey))
            strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setBright(%s, %s == 1)", ID, grey))
        elseif tonumber(grey) == 0 then
            strs = sformat("%s%s%s", strs, br, sformat("GUI:Button_setBright(%s, false)", ID))
        end
    end

    if pStr then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Win_SetParam(%s, {%s}, \"Button\")", ID, pStr))
    end

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    if IsButtonFunc then
        strs = strs .. br .. sformat("GUI:addOnTouchEvent(%s, ui.onButtonTouchEvent)", ID)
    end

    local msgStr = self:getMsgStr(widget, ID)
    if msgStr then
        strs = sformat("%s%s%s", strs, br, msgStr)
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_Image(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)

    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:Image_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strRes1, res1, Is = self:GetStrVar(widget, Attributes.RES1)
    str = str .. strRes1
    if Is then
        if res1 ~= "" and fileUtil:isFileExist(res1) then
        else
            res1 = sformat("%s%s", _PathRes, "ImageFile.png")
        end
        res1 = FixPath(res1)
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Image_loadTexture(sender" .. strRes1 .. ")", res1))
    end

    strs = sformat("%s%s", strs, sformat(str .. ")", defType, ID, parent, ID, x, y, res1))

    local isScale9 = widget:isScale9Enabled()
    if isScale9 then
        local rect = self:getCapInset(widget)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Image_setScale9Slice(%s, %s, %s, %s, %s)", ID, rect.l, rect.r, rect.t, rect.b))
    end

    local sizeStr = self:parseContentSize(widget, ID, res1, isScale9)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)

    strs = sformat("%s%s", strs, cStr)

    local msgStr = self:getMsgStr(widget, ID)
    if msgStr then
        strs = sformat("%s%s%s", strs, br, msgStr)
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_EditBox(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:TextInput_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strW, w, Is3 = self:GetStrFloat(widget, Attributes.W)
    str = str .. strW

    local strH, h, Is4 = self:GetStrFloat(widget, Attributes.H)
    str = str .. strH

    if not Is3 or not Is4 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setContentSize(sender" .. strW .. strH .. ")", w, h))
    end

    local strFSize, FSize, Is = self:GetStrInt(widget, Attributes.FSIZE)
    str = str .. strFSize
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:TextInput_setFontSize(sender" .. strFSize .. ")", FSize))
    end

    strs = sformat("%s%s", strs, sformat(str .. ")", defType, ID, parent, ID, x, y, w, h, FSize))

    local pholder = widget:getPlaceHolder()
    if slen(pholder or "") > 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setPlaceHolder(%s, \"%s\")", ID, pholder))
    end

    local pholderColor = (widget.getPlaceholderFontColor or widget.getPlaceHolderColor)(widget)
    if pholderColor then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setPlaceholderFontColor(%s, \"%s\")", ID, GetColorHexFromRBG(pholderColor)))
    end

    local IsTextField = widget:getDescription() == "TextField"

    local color = IsTextField and widget:getColor() or widget:getFontColor()
    strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setFontColor(%s, \"%s\")", ID, GetColorHexFromRBG(color)))

    local maxlen = widget:getMaxLength()
    if maxlen > 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setMaxLength(%s, %s)", ID, maxlen))
    end

    local data = self:GetAttribeValue(widget, GUIAttributes.INPUT_EX)
    local iID, iType, checkSensitive, isCipher = tonumber(data.id) or 0, tonumber(data.type) or 0, data.checkSensitive or false, data.cipher
    if iType == 1 or iType == 3 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setInputMode(%s, 2)", ID))
    elseif iType == 2 and isCipher then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setInputFlag(%s, 0)", ID))
    end
    strs = sformat("%s%s%s", strs, br, sformat("GUI:Win_SetParam(%s, {id = %s, type = %s, checkSensitive = %s, cipher = %s}, \"Input\")", ID, iID, iType, checkSensitive, isCipher))

    local strText, text, Is = self:GetStrString(widget, Attributes.TEXT)
    strs = sformat("%s%s%s", strs, br, sformat("GUI:TextInput_setString(%s" .. strText .. ")", ID, text))
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:TextInput_setString(sender" .. strText .. ")", text))
    end

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    if iID > 0 then
        IsInputFunc = true
    end

    if IsQueueFunc and IsInputFunc then
        strs = strs .. br .. sformat("GUI:TextInput_addOnEvent(%s, ui.onInputEvent)", ID)
        strs = sformat("%s%s%s%s[%s] = %s", strs, br, br, mapsInput, iID, ID)
    end

    return strs
end

function GUITXTEditor:output_Slider(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:Slider_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strRes1, res1, Is1 = self:GetStrVar(widget, Attributes.RES1)
    str = str .. strRes1
    if Is1 then
        if res1 ~= "" and fileUtil:isFileExist(res1) then
        else
            res1 = sformat("%s%s", _PathRes, "Slider_Bg.png")
        end
        res1 = FixPath(res1)
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Slider_loadBarTexture(sender" .. strRes1 .. ")", res1))
    end

    local strRes2, res2, Is2 = self:GetStrVar(widget, Attributes.RES2)
    str = str .. strRes2
    if Is2 then
        if res2 ~= "" and fileUtil:isFileExist(res2) then
        else
            res2 = sformat("%s%s", _PathRes, "Slider_Bar.png")
        end
        res2 = FixPath(res2)
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Slider_loadProgressBarTexture(sender" .. strRes2 .. ")", res2))
    end

    local strRes3, res3, Is3 = self:GetStrVar(widget, Attributes.RES3)
    str = str .. strRes3
    if Is3 then
        if res3 ~= "" and fileUtil:isFileExist(res3) then
        else
            res3 = sformat("%s%s", _PathRes, "Slider_Ball.png")
        end
        res3 = FixPath(res3)
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Slider_loadSlidBallTextureNormal(sender" .. strRes3 .. ")", res3))
    end
    
    strs = sformat("%s%s", strs, sformat(str .. ")", defType, ID, parent, ID, x, y, res1, res2, res3))

    local sizeStr = self:parseContentSize(widget, ID, res1)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end

    local data = self:GetAttribeValue(widget, GUIAttributes.SLIDER_EX)

    local valueStr, isMatch1 = GUIHelper.ConvertToRunFormart(data["value"])
    local value     = nil
    local cur       = 0
    if isMatch1 then
        value       = tonumber(load(sformat([[return %s]], valueStr))())
        cur         = valueStr
    else
        value       = tonumber(valueStr)
        cur         = value
    end

    local maxValueStr, isMatch2 = GUIHelper.ConvertToRunFormart(data["maxValue"])
    local maxValue  = nil
    local max       = 100
    if isMatch2 then
        maxValue    = tonumber(load(sformat([[return %s]], maxValueStr))())
        max         = maxValueStr
    else
        maxValue    = tonumber(maxValueStr)
        max         = maxValue
    end

    if isMatch1 or isMatch2 then
        local s1 = sformat("local per = math.floor((%s) / (%s) * 100)", cur, max)

        funcBodys = sformat("%s%s\t%s%s\t%s", funcBodys, br, s1, br, "GUI:Slider_setPercent(sender, per)")
        strs = sformat("%s%s%s%s%s", strs, br, s1, br, sformat("GUI:Slider_setPercent(%s, per)", ID))
    else
        local per = math.floor(value / maxValue * 100)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Slider_setPercent(%s, %s)", ID, per))
    end

    local ids = data.ids
    if ids and #ids > 0 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Win_SetParam(%s, {value = %s, maxValue = %s, ids = \"%s\"}, \"Slider\")", ID, valueStr, maxValueStr, data.ids))
    else
        strs = sformat("%s%s%s", strs, br, sformat("GUI:Win_SetParam(%s, {value = %s, maxValue = %s}, \"Slider\")", ID, valueStr, maxValueStr))
    end
    
    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    strs = strs .. br .. sformat("GUI:Slider_addOnEvent(%s, ui.onSliderEvent)", ID)

    return strs
end

function GUITXTEditor:output_LoadingBar(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:LoadingBar_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strRes1, res1, Is = self:GetStrVar(widget, Attributes.RES1)
    str = str .. strRes1
    if Is then
        if res1 ~= "" and fileUtil:isFileExist(res1) then
        else
            res1 = sformat("%s%s", _PathRes, "LoadingBar.png")
        end
        res1 = FixPath(res1)
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:LoadingBar_loadTexture(sender" .. strRes1 .. ")", res1))
    end

    local dir = widget:getDirection()

    strs = sformat("%s%s", strs, sformat(str .. ", %s)", defType, ID, parent, ID, x, y, res1, dir))

    local sizeStr = self:parseContentSize(widget, ID, res1)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end
    
    local color = GetColorHexFromRBG(widget:getColor())
    strs = sformat("%s%s%s", strs, br, sformat("GUI:LoadingBar_setColor(%s, \"%s\")", ID, color))
    
    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    strs = sformat("%s%s", strs, cStr)

    local data = self:GetAttribeValue(widget, GUIAttributes.LOADING_BAR)
    local interval, step, lvisible, lcolor, lsize, lx, ly = data.interval, data.step, data.lvisible, data.lcolor, data.lsize, data.lx, data.ly

    local valueStr, isMatch1 = GUIHelper.ConvertToRunFormart(data["value"])
    local value     = nil
    local cur       = 0
    if isMatch1 then
        value       = tonumber(load(sformat([[return %s]], valueStr))())
        cur         = valueStr
    else
        value       = tonumber(valueStr)
        cur         = value
    end

    local maxValueStr, isMatch2 = GUIHelper.ConvertToRunFormart(data["maxValue"])
    local maxValue  = nil
    local max       = 100
    if isMatch2 then
        maxValue    = tonumber(load(sformat([[return %s]], maxValueStr))())
        max         = maxValueStr
    else
        maxValue    = tonumber(maxValueStr)
        max         = maxValue
    end

    if isMatch1 or isMatch2 then
        local s1 = sformat("local per = math.floor((%s) / (%s) * 100)", cur, max)

        -- funcBodys = sformat("%s%s\t%s%s\t%s", funcBodys, br, s1, br, "GUI:LoadingBar_setPercent(sender, per)")
        strs = sformat("%s%s%s%s%s", strs, br, s1, br, sformat("GUI:LoadingBar_setPercent(%s, per)", ID))
    else
        local per = math.floor(value / maxValue * 100)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:LoadingBar_setPercent(%s, %s)", ID, per))
    end

    strs = sformat("%s%s%s", strs, br, sformat("GUI:Win_SetParam(%s, {value = %s, maxValue = %s, interval = %s, step = %s, lx = %s, ly = %s, lsize = %s, lvisible = %s, lcolor = \"%s\"}, \"LoadingBar\")", ID, valueStr, maxValueStr, interval, step, lx, ly, lsize, lvisible,lcolor))

    strs = strs .. self:createLabelStr(ID, lsize, lx, ly, lvisible, lcolor)
    
    strs = sformat("%s%s%s", strs, br, sformat("ui.loadLadingBar(%s, %s, %s, true, %s, %s)", ID, valueStr, maxValueStr, interval, step))
    
    if isMatch1 or isMatch2 then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("ui.loadLadingBar(sender, %s, %s, false, %s, %s)", valueStr, maxValueStr, interval, step))
        IsPerFunc = true
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:createLabelStr(parent, size, lx, ly, visible, color)
    return 
            "\n\n\t"    .. sformat("local label = cc.Label:createWithTTF(\"\", \"fonts/font2.ttf\", %s)", size)
        ..  "\n\t"      .. sformat("GUI:addChild(%s, label)", parent)
        ..  "\n\t"      .. sformat("GUI:setColor(label, \"%s\")", color)
        ..  "\n\t"      .. sformat("GUI:setPosition(label, %s, %s)", lx, ly)
        ..  "\n\t"      .. sformat("GUI:setVisible(label, %s)", tonumber(visible) == 1)
        ..  "\n\t"      .. sformat("%s._renderlabel = label", parent)
        ..  "\n"
end

function GUITXTEditor:createLBarLabel(parent, data)
    if parent._renderlabel then
        parent._renderlabel:removeFromParent()
    end

    local size, lx, ly, visible, color = tonumber(data.lsize) or 14, tonumber(data.lx) or 0, tonumber(data.ly) or 0, tonumber(data.lvisible) or 0, data.lcolor

    local valueStr, isMatch1 = GUIHelper.ConvertToRunFormart(data["value"])
    local value = nil
    if isMatch1 then
        value = tonumber(load(sformat([[return %s]], valueStr))())
    else
        value = tonumber(valueStr)
    end

    local maxValueStr, isMatch2 = GUIHelper.ConvertToRunFormart(data["maxValue"])
    local maxValue = nil
    if isMatch2 then
        maxValue = tonumber(load(sformat([[return %s]], maxValueStr))())
    else
        maxValue = tonumber(maxValueStr)
    end
    value = value or 0
    maxValue = maxValue or 100

    local per = math.min(math.floor(value / maxValue * 100), 100)
    local label = cc.Label:createWithTTF(per .. "%", "fonts/font2.ttf", size)
    GUI:addChild(parent, label)
    GUI:setColor(label, color)
    GUI:setPosition(label, lx, ly)
    GUI:setVisible(label, visible == 1)
    parent._renderlabel = label
end

function GUITXTEditor:output_CheckBox(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:CheckBox_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strRes1, res1, Is = self:GetStrVar(widget, Attributes.RES1)
    str = str .. strRes1
    if Is then
        if res1 ~= "" and fileUtil:isFileExist(res1) then
        else
            res1 = sformat("%s%s", _PathRes, "CheckBox_Normal.png")
        end
        res1 = FixPath(res1)
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:CheckBox_loadTextureBackGround(sender" .. strRes1 .. ")", res1))
    end

    local strRes2, res2, Is = self:GetStrVar(widget, Attributes.RES2)
    str = str .. strRes2
    if Is then
        if res2 ~= "" and fileUtil:isFileExist(res2) then
        else
            res2 = sformat("%s%s", _PathRes, "CheckBox_Press.png")
        end
        res2 = FixPath(res2)
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:CheckBox_loadTextureFrontCross(sender" .. strRes2 .. ")", res2))
    end

    strs = sformat("%s%s", strs, sformat(str .. ")", defType, ID, parent, ID, x, y, res1, res2))

    local sizeStr = self:parseContentSize(widget, ID, res1)
    if sizeStr then
        strs = sformat("%s%s%s", strs, br, sizeStr)
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setIgnoreContentAdaptWithSize(%s, %s)", ID, false))
    end

    local strSelect, isSelect, Is = self:GetStrBoolean(widget, Attributes.SELECTED)
    strs = sformat("%s%s%s", strs, br, sformat("GUI:CheckBox_setSelected(%s" .. strSelect .. ")", ID, isSelect))
    if not Is and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:CheckBox_setSelected(sender" .. strSelect .. ")", isSelect))
    end
    
    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    local msgStr = self:getMsgStr(widget, ID)
    if msgStr then
        strs = sformat("%s%s%s", strs, br, msgStr)
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_Layout(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:Layout_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strW, w, Is3 = self:GetStrFloat(widget, Attributes.W)
    str = str .. strW

    local strH, h, Is4 = self:GetStrFloat(widget, Attributes.H)
    str = str .. strH

    if not Is3 or not Is4 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setContentSize(sender" .. strW .. strH .. ")", w, h))
    end

    local clip = widget:isClippingEnabled()

    strs = sformat("%s%s", strs, sformat(str .. ", %s)", defType, ID, parent, ID, x, y, w, h, clip))

    local strRes1, res1, Is = self:GetStrVar(widget, Attributes.RES1)
    str = str .. strRes1
    if Is then
        if res1 ~= "" and fileUtil:isFileExist(res1) then
            res1 = FixPath(res1)
            strs = sformat("%s%s%s", strs, br, sformat("GUI:Layout_setBackGroundImage(%s, \"%s\")", ID, res1))
        end
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:Layout_setBackGroundImage(sender" .. strRes1 .. ")", res1))
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

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    local msgStr = self:getMsgStr(widget, ID)
    if msgStr then
        strs = sformat("%s%s%s", strs, br, msgStr)
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:GetContainContent(widget, ID, strs, br)
    local funcBodys = ""

    local childID = GUI:getChildID(widget)
    if childID < 1 then
        return strs, funcBodys
    end

    strs = sformat("%s%s%s", strs, br, sformat([[GUI:setChildID(%s, %s)]], ID, childID))

    local strIndex, index = self:GetStrInt(widget, Attributes.JUMPINDEX)
    strs = sformat("%s%s%s", strs, br, sformat("GUI:setJumpIndex(%s" .. strIndex .. ")", ID, index))

    local data = self:GetAttribeValue(widget, GUIAttributes.CONTAIN_INDEX)
    local strChild = GUIHelper.ConvertToRunFormart(data["Param2"])
    strs = sformat("%s%s%s", strs, br, sformat("GUI:setContainerIndexTable(%s, %s)", ID, strChild))

    local refFuncStr =              "\n\tlocal C_Refresh = function (sender)"
            .. "\n\t\t"         ..  sformat("local tIndex = %s or 0", strChild) 
            .. "\n\t\t"         ..  sformat("GUI:setContainerIndexTable(%s, %s)", ID, strChild)
            .. "\n\t\t"         ..  "GUI:removeAllChildren(sender)"
            .. "\n\t\t"         ..  "if type(tIndex) == \"table\" then"
            .. "\n\t\t\t"       ..      "for _ = 1, #tIndex do"
            .. "\n\t\t\t\t"     ..          "local i = tIndex[_]"
            .. "\n\t\t\t\t"     ..          "if i and tonumber(i) then"
            .. "\n\t\t\t\t\t"   ..              sformat("local cell = %s", sformat("ui.getCell_%s(-1, i)", childID))
            .. "\n\t\t\t\t\t"   ..              "GUI:ListView_pushBackCustomItem(sender, cell)"
            .. "\n\t\t\t\t\t"   ..              "GUI:setVisible(sender, true)"
            .. "\n\t\t\t\t"     ..          "end"
            .. "\n\t\t\t"       ..      "end"
            .. "\n\t\t"         ..  "elseif type(tIndex) == \"number\" then"
            .. "\n\t\t\t"       ..      "for i = 1, tIndex do"
            .. "\n\t\t\t\t"     ..          sformat("local cell = %s", sformat("ui.getCell_%s(-1, i)", childID))
            .. "\n\t\t\t\t"     ..          "GUI:ListView_pushBackCustomItem(sender, cell)"
            .. "\n\t\t\t\t"     ..          "GUI:setVisible(sender, true)"
            .. "\n\t\t\t"       ..      "end"
            .. "\n\t\t"         .. "end"
            .. "\n\t"           .. sformat("\tGUI:ListView_jumpToItem(sender" .. strIndex .. ")", index)
            .. "\n\t"           .. "end"
            .. "\n\n\t"         .. sformat("C_Refresh(%s)", ID)


    local loadStr = sformat("%s%s-- LoadContainer --%s%s-- LoadContainer end --", br, br, refFuncStr, br)

    strs = sformat("%s%s", strs, loadStr)

    funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("C_Refresh(sender)"))

    return strs, funcBodys
end

function GUITXTEditor:output_ListView(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:ListView_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strW, w, Is3 = self:GetStrFloat(widget, Attributes.W)
    str = str .. strW

    local strH, h, Is4 = self:GetStrFloat(widget, Attributes.H)
    str = str .. strH

    if not Is3 or not Is4 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setContentSize(sender" .. strW .. strH .. ")", w, h))
    end

    local dir = widget:getDirection()

    strs = sformat("%s%s", strs, sformat(str .. ", %s)", defType, ID, parent, ID, x, y, w, h, dir))

    local strRes1, res1, Is = self:GetStrVar(widget, Attributes.RES1)
    str = str .. strRes1
    if Is then
        if res1 ~= "" and fileUtil:isFileExist(res1) then
            res1 = FixPath(res1)
            strs = sformat("%s%s%s", strs, br, sformat("GUI:ListView_setBackGroundImage(%s, \"%s\")", ID, res1))
        end
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:ListView_setBackGroundImage(sender" .. strRes1 .. ")", res1))
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

    local data1 = self:GetAttribeValue(widget, GUIAttributes.BUTTON_PAGE)
    IsPageFunc = self:GetStatus(data1.Param2, false)

    local pressColor = nil

    if IsPageFunc then
        strs = strs .. br ..  sformat("GUI:setButtonPage(%s, %s)", ID, true)

        local data2 = self:GetAttribeValue(widget, GUIAttributes.BUTTON_CLICKCOLOR)
        pressColor = "\"" .. self:GetStatus(data2.Param2) .. "\""
        strs = sformat("%s%s%s", strs, br, sformat("GUI:setButtonPressColor(%s, %s)", ID, pressColor))
    end

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    local cFuncQueue2 = ""
    strs, cFuncQueue2 = self:GetContainContent(widget, ID, strs, br)
    if #cFuncQueue2 > 0 then
        cFuncQueue = cFuncQueue .. cFuncQueue2
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    if IsPageFunc then
        strs = strs .. "\n" .. br ..  sformat("local pressColor = %s", pressColor) .. "\n\t" .. sformat("ui.setButtonClickBright(%s, i or 1, pressColor)", ID)
    end

    return strs
end

function GUITXTEditor:GetScrollViewContainContent(widget, ID, strs, br)
    local funcBodys = ""

    local childID = GUI:getChildID(widget)
    if childID < 1 then
        return strs, funcBodys
    end

    strs = sformat("%s%s%s", strs, br, sformat([[GUI:setChildID(%s, %s)]], ID, childID))

    local strIndex, index = self:GetStrInt(widget, Attributes.JUMPINDEX)
    strs = sformat("%s%s%s", strs, br, sformat("GUI:setJumpIndex(%s" .. strIndex .. ")", ID, index))

    local data = self:GetAttribeValue(widget, GUIAttributes.CONTAIN_INDEX)
    local strChild = GUIHelper.ConvertToRunFormart(data["Param2"])
    strs = sformat("%s%s%s", strs, br, sformat("GUI:setContainerIndexTable(%s, %s)", ID, strChild))

    local refFuncStr =              "\n\tlocal C_Refresh = function (sender)"
            .. "\n\t\t"         ..  sformat("local tIndex = %s or 0", strChild) 
            .. "\n\t\t"         ..  sformat("GUI:setContainerIndexTable(%s, %s)", ID, strChild)
            .. "\n\t\t"         ..  "GUI:removeAllChildren(sender)"
            .. "\n\t\t"         ..  "if type(tIndex) == \"table\" then"
            .. "\n\t\t\t"       ..      "for _ = 1, #tIndex do"
            .. "\n\t\t\t\t"     ..          "local i = tIndex[_]"
            .. "\n\t\t\t\t"     ..          "if i and tonumber(i) then"
            .. "\n\t\t\t\t\t"   ..              sformat("local cell = %s", sformat("ui.getCell_%s(-1, i)", childID))
            .. "\n\t\t\t\t\t"   ..              "GUI:ScrollView_addChild(sender, cell)"
            .. "\n\t\t\t\t\t"   ..              "GUI:setVisible(sender, true)"
            .. "\n\t\t\t\t"     ..          "end"
            .. "\n\t\t\t"       ..      "end"
            .. "\n\t\t"         ..  "elseif type(tIndex) == \"number\" then"
            .. "\n\t\t\t"       ..      "for i = 1, tIndex do"
            .. "\n\t\t\t\t"     ..          sformat("local cell = %s", sformat("ui.getCell_%s(-1, i)", childID))
            .. "\n\t\t\t\t"     ..          "GUI:ScrollView_addChild(sender, cell)"
            .. "\n\t\t\t\t"     ..          "GUI:setVisible(sender, true)"
            .. "\n\t\t\t"       ..      "end"
            .. "\n\t\t"         .. "end"
            .. "\n\t"           .. "end"
            .. "\n\n\t"         .. sformat("C_Refresh(%s)", ID)


    local loadStr = sformat("%s%s-- LoadContainer --%s%s-- LoadContainer end --", br, br, refFuncStr, br)

    strs = sformat("%s%s", strs, loadStr)

    funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("C_Refresh(sender)"))

    local data = self:GetAttribeValue(widget, GUIAttributes.SCROLLVIEW_MOREROW)
    local isClick = data.IsClick
    if isClick then
        strs = strs .. "\n\n" .. sformat("\tGUI:UserUILayout(%s, { dir = %s, addDir = %s, x = %s, y = %s, l = %s, t = %s, colnum = %s, play = %s })", ID, 3, data.addDir, data.x, data.y, data.l, data.t, data.colnum, data.play)
        funcBodys = funcBodys .. "\n\t" ..sformat("\tGUI:UserUILayout(sender, { dir = %s, addDir = %s, x = %s, y = %s, l = %s, t = %s, colnum = %s, play = %s })", 3, data.addDir, data.x, data.y, data.l, data.t, data.colnum, data.play)
    end

    return strs, funcBodys
end

function GUITXTEditor:output_ScrollView(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:ScrollView_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strW, w, Is3 = self:GetStrFloat(widget, Attributes.W)
    str = str .. strW

    local strH, h, Is4 = self:GetStrFloat(widget, Attributes.H)
    str = str .. strH

    if not Is3 or not Is4 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setContentSize(sender" .. strW .. strH .. ")", w, h))
    end

    local dir = widget:getDirection()

    strs = sformat("%s%s", strs, sformat(str .. ", %s)", defType, ID, parent, ID, x, y, w, h, dir))

    local strRes1, res1, Is = self:GetStrVar(widget, Attributes.RES1)
    str = str .. strRes1
    if Is then
        if res1 ~= "" and fileUtil:isFileExist(res1) then
            res1 = FixPath(res1)
            strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setBackGroundImage(%s, \"%s\")", ID, res1))
        end
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:ScrollView_setBackGroundImage(sender" .. strRes1 .. ")", res1))
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

    local strInnerW, InnerW, Is5 = self:GetStrFloat(widget, Attributes.INNERW)
    local strInnerH, InnerH, Is6 = self:GetStrFloat(widget, Attributes.INNERH)
    strs = sformat("%s%s%s", strs, br, sformat("GUI:ScrollView_setInnerContainerSize(%s" .. strInnerW .. strInnerH .. ")", ID, InnerW, InnerH))
    if not Is5 or not Is6 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:ScrollView_setInnerContainerSize(sender" .. strInnerW .. strInnerH .. ")", InnerW, InnerH))
    end
    
    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    local cFuncQueue2 = ""
    strs, cFuncQueue2 = self:GetScrollViewContainContent(widget, ID, strs, br)
    if #cFuncQueue2 > 0 then
        cFuncQueue = cFuncQueue .. cFuncQueue2
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_PageView(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:PageView_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strW, w, Is3 = self:GetStrFloat(widget, Attributes.W)
    str = str .. strW

    local strH, h, Is4 = self:GetStrFloat(widget, Attributes.H)
    str = str .. strH

    if not Is3 or not Is4 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setContentSize(sender" .. strW .. strH .. ")", w, h))
    end

    strs = sformat("%s%s", strs, sformat(str .. ")", defType, ID, parent, ID, x, y, w, h))

    local strRes1, res1, Is = self:GetStrVar(widget, Attributes.RES1)
    str = str .. strRes1
    if Is then
        if res1 ~= "" and fileUtil:isFileExist(res1) then
            res1 = FixPath(res1)
            strs = sformat("%s%s%s", strs, br, sformat("GUI:PageView_setBackGroundImage(%s, \"%s\")", ID, res1))
        end
    else
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:PageView_setBackGroundImage(sender" .. strRes1 .. ")", res1))
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
    
    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    strs = self:GetContainContent(widget, ID, strs, br)

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:GetTableViewContainContent(widget, ID, strs, br, JumpIdx, CellN)
    local funcBodys = ""

    local childID = GUI:getChildID(widget)
    if childID < 1 then
        return strs, funcBodys
    end

    strs = sformat("%s%s%s", strs, br, sformat([[GUI:setChildID(%s, %s)]], ID, childID))

    local loadFuncStr =
                "\n\t"      ..  "-- TableViewLoad --"
            .. "\n\t"       ..   sformat("GUI:TableView_setCellCreateEvent(%s, function(parent, idx)", ID)
            .. "\n\t\t"     ..       sformat("local cell = ui.getCell_%s(parent, idx)", childID)
            .. "\n\t\t"     ..       "GUI:setPosition(cell, 0, 0)"
            .. "\n\t\t"     ..       "GUI:setVisible(cell, true)"
            .. "\n\t"       ..   "end)"
            .. "\n\t"       ..   "-- TableViewLoad end --"
            .. "\n\n\t"     ..   sformat("GUI:TableView_scrollToCell(%s, %s)", ID, JumpIdx)

    strs = sformat("%s%s%s", strs, br, loadFuncStr)


    local updateFuncStr = 
                "\t"        ..  sformat("GUI:TableView_setTableViewCellsNumHandler(sender, %s)", CellN)
            .. "\n\t\t"     ..  sformat("GUI:TableView_scrollToCell(%s, %s)", ID, JumpIdx)

    funcBodys = sformat("%s%s%s", funcBodys, br, updateFuncStr)

    return strs, funcBodys
end

function GUITXTEditor:output_TableView(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:TableView_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local strW, w, Is3 = self:GetStrFloat(widget, Attributes.W)
    str = str .. strW

    local strH, h, Is4 = self:GetStrFloat(widget, Attributes.H)
    str = str .. strH

    if not Is3 or not Is4 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setContentSize(sender" .. strW .. strH .. ")", w, h))
    end

    local dir = widget:getDirectionEx()

    local JumpIdx = 1
    local CellN = 0

    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.TABLE_VIEW)
    if formatType == FormatType.VAR then
        local CellW = GUIHelper.ConvertToRunFormart(data["CellW"])
        local CellH = GUIHelper.ConvertToRunFormart(data["CellH"])
        CellN = GUIHelper.ConvertToRunFormart(data["CellN"])
        JumpIdx     = GUIHelper.ConvertToRunFormart(data["JumpIdx"])
        
        strs = sformat("%s%s", strs, sformat(str .. ", %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, w, h, dir, CellW, CellH, CellN, JumpIdx))
    else
        local data = GUIFuncKeys[GUIAttributes.TABLE_VIEW](widget)
        JumpIdx = data.JumpIdx
        CellN   = data.CellN
        strs = sformat("%s%s", strs, sformat(str .. ", %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, w, h, dir, data.CellW, data.CellH, data.CellN, JumpIdx))
    end

    local bgColor = widget:GetBackColor()
    if bgColor.r ~= 255 or bgColor.b ~= 255 or bgColor.g ~= 255 then
        strs = sformat("%s%s%s", strs, br, sformat("GUI:TableView_setBackGroundColor(%s, \"%s\")", ID, GetColorHexFromRBG(bgColor)))
    end

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    strs = sformat("%s%s", strs, cStr)

    local cFuncQueue2 = ""
    strs, cFuncQueue2 = self:GetTableViewContainContent(widget, ID, strs, br, JumpIdx, CellN)
    if #cFuncQueue2 > 0 then
        cFuncQueue = cFuncQueue .. cFuncQueue2
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_Node(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:Node_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    strs = sformat("%s%s", strs, sformat(str .. ")", defType, ID, parent, ID, x, y))
    
    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    local data = self:GetAttribeValue(widget, GUIAttributes.ATTACH_NODE)
    local filePath = data["Param2"]
    if filePath and filePath ~= "" then
        filePath = GUIHelper.ConvertToRunFormart(filePath)
        strs = strs .. br ..  sformat("-- AttachNode %s%s%s-- AttachNode end --", br, sformat("GUI:LoadExportEx(%s, %s)", ID, filePath), br)
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_Effect(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:Effect_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.EFFECT)
    if formatType == FormatType.VAR then
        local type  = GUIHelper.ConvertToRunFormart(data["type"])
        local sfxID = GUIHelper.ConvertToRunFormart(data["sfxID"])
        local sex   = GUIHelper.ConvertToRunFormart(data["sex"])
        local act   = GUIHelper.ConvertToRunFormart(data["act"])
        local dir   = GUIHelper.ConvertToRunFormart(data["dir"])
        local speed = GUIHelper.ConvertToRunFormart(data["speed"])

        strs = sformat("%s%s", strs, sformat(str .. ", %s, %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, type, sfxID, sex, act, dir, speed))
    else
        local data = GUIFuncKeys[GUIAttributes.EFFECT](widget)
        strs = sformat("%s%s", strs, sformat(str .. ", %s, %s, %s, %s, %s, %s)", defType, ID, parent, ID, x, y, data.type, data.sfxID, data.sex, data.act, data.dir, data.speed))
    end

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_Item(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:ItemShow_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end
    
    local dataStr = nil
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.ITEM_SHOW)
    if formatType == FormatType.VAR then
        for key, value in pairs(data) do
            local vValue = GUIHelper.ConvertToRunFormart(value)
            dataStr = dataStr and sformat("%s, %s = %s", dataStr, key, vValue) or sformat("%s = %s", key, vValue)
        end
    end

    dataStr = dataStr or sformat("index = %s, count = %s, look = %s, bgVisible = %s", 1, 1, true, true)

    strs = sformat("%s%s", strs, sformat(str .. ", %s)", defType, ID, parent, ID, x, y, sformat("{%s}", dataStr)))

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:output_Model(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:UIModel_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end

    local featureStr = nil
    local sex, scale, feature = self:getModelData(widget)
    for k, v in pairs(feature) do
        local IsChar = false
        if type(v) == "string" then
            sgsub(v, "[#&]", function () IsChar = true end)
        end
        if IsChar then
            featureStr = featureStr and sformat("%s, %s = \"%s\"", featureStr, k, v) or sformat("%s = \"%s\"", k, v)
        else
            featureStr = featureStr and sformat("%s, %s = %s", featureStr, k, v) or sformat("%s = %s", k, v)
        end
    end

    strs = sformat("%s%s", strs, sformat(str .. ", %s, %s, %s)", defType, ID, parent, ID, x, y, sex, sformat("{%s}", featureStr), scale))

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)
    
    strs = sformat("%s%s", strs, cStr)

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs 
end

function GUITXTEditor:output_EquipShow(widget, parent, ID, notRef)
    local funcBodys = ""

    local br = self:brEx()
    local strs = sformat("%s%s", sformat("-- Create %s", ID), br)
    
    local defType = self:checkRepeatName(ID)

    local str = "%s%s = GUI:EquipShow_Create(%s, \"%s\""

    local strX, x, Is1 = self:GetStrFloat(widget, Attributes.X)
    str = str .. strX

    local strY, y, Is2 = self:GetStrFloat(widget, Attributes.Y)
    str = str .. strY

    if not Is1 or not Is2 and not notRef then
        funcBodys = sformat("%s%s%s%s", funcBodys, br, charMask.t, sformat("GUI:setPosition(sender" .. strX .. strY .. ")", x, y))
    end
    
    local dataStr = nil
    local pos = nil 
    local isHero = false
    local autoUpdate = false
    local info = {}
    local data, formatType = self:GetAttribeValue(widget, GUIAttributes.EQUIP_SHOW)
    if formatType == FormatType.VAR then
        for key, value in pairs(data) do
            local vValue = self:GetStatus(value, false)
            if key == "pos" then
                vValue = GUIHelper.ConvertToRunFormart(value)
                pos = vValue
            elseif key == "isHero" then
                isHero = vValue
            elseif key == "autoUpdate" then
                autoUpdate = vValue
            else
                dataStr = dataStr and sformat("%s, %s = %s", dataStr, key, vValue) or sformat("%s = %s", key, vValue)
            end
        end
    end
    info.index = nil
    info.itemData = nil

    for key, value in pairs(info) do
        dataStr = dataStr and (dataStr .. ", " .. sformat("%s = %s", key, value)) or sformat("%s = %s", key, value)
    end

    dataStr = dataStr or sformat("look = %s, bgVisible = %s", true, true)
    pos = pos or 1

    strs = sformat("%s%s", strs, sformat(str .. ", %s, %s, %s)", defType, ID, parent, ID, x, y, pos, isHero, sformat("{%s}", dataStr)))

    local cStr, cFuncQueue = self:parseCommon(widget, ID, notRef)

    strs = sformat("%s%s", strs, cStr)

    if autoUpdate then
        local str = sformat("GUI:EquipShow_setAutoUpdate(%s)", ID)
        strs = sformat("%s%s%s", strs, br, str)
    end

    if #funcBodys > 0 or #cFuncQueue > 0 then
        funcBodys = sformat("%sGUI:SetRefreshVarFunc(%s, function(sender) %s%s%send)", br, ID, funcBodys, cFuncQueue, br)
        funcBodys = sformat("%s%s-- SetRefreshVarFunc --%s%s-- SetRefreshVarFunc end --", br, br, funcBodys, br)
        strs = sformat("%s%s", strs, funcBodys)
        strs = sformat("%s%s%s%s[%s] = true", strs, br, br, funcQueue, ID)
        IsQueueFunc = true
    end

    return strs
end

function GUITXTEditor:GetStatus(status, default_status)
    if type(status) == "boolean" then
        return status
    end

    local _status = status or default_status

    if _status == "true" then
        return true
    end

    if _status == "false" then
        return false
    end

    return _status
end

-- 导入------------------------------------------------------------------------------
function GUITXTEditor:InputGUI(source, first)
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

    self._trigger = {}

    SerVarNames = {}

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

    -- 去无用代码
    source = sgsub(source, "%-%- ui.getCell_(.-)", "ui.getCell_%1")
    source = sgsub(source, "%-%- Update %-%-(.-)%-%- Update end %-%-", "")
    source = sgsub(source, "%-%- AttachNode %-%-(.-)%-%- AttachNode end %-%-", "")
    source = sgsub(source, "%-%- LoadContainer %-%-(.-)%-%- LoadContainer end %-%-", "")
    source = sgsub(source, "%-%- TableViewLoad %-%-(.-)%-%- TableViewLoad end %-%-", "")
    source = sgsub(source, "%-%- SetRefreshVarFunc %-%-(.-)%-%- SetRefreshVarFunc end %-%-", "")
    source = sgsub(source, "%-%- Trigger %-%-(.-)%-%- Trigger end %-%-", function (s) return sgsub(s, "[ \t\n\r]+", " ") end)
    source = sgsub(source, "%-%- CountDown %-%-(.-)%-%- CountDown end %-%-", function (s) return "--Custom Format-->" .. sgsub(s, "[ \t\n\r]+", " ") end)

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

function GUITXTEditor:dealWidget(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X,       param[3])
    str = self:formatValue(str, name, Attributes.Y,       param[4])
    str = self:formatValue(str, name, Attributes.W,       param[5])
    str = self:formatValue(str, name, Attributes.H,       param[6])

    return str
end

function GUITXTEditor:dealButton(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X,       param[3])
    str = self:formatValue(str, name, Attributes.Y,       param[4])
    str = self:formatValue(str, name, Attributes.RES1,    param[5])

    return str
end

function GUITXTEditor:dealImageView(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X,       param[3])
    str = self:formatValue(str, name, Attributes.Y,       param[4])
    str = self:formatValue(str, name, Attributes.RES1,    param[5])

    return str
end

function GUITXTEditor:dealText(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X,       param[3])
    str = self:formatValue(str, name, Attributes.Y,       param[4])
    str = self:formatValue(str, name, Attributes.FSIZE,   param[5])
    str = self:formatValue(str, name, Attributes.FCOLOR,  param[6])
    str = self:formatValue(str, name, Attributes.TEXT,    param[7])

    return str
end

function GUITXTEditor:dealBmpText(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X,       param[3])
    str = self:formatValue(str, name, Attributes.Y,       param[4])
    str = self:formatValue(str, name, Attributes.FCOLOR,  param[5])
    str = self:formatValue(str, name, Attributes.TEXT,    param[6])

    return str
end

function GUITXTEditor:dealTextAtlas(str, contents)
    str = sgsub(str, "Default/TextAtlas.png", "res/private/gui_edit/TextAtlas.png")

    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)
    
    str = self:formatValue(str, name, Attributes.X, param[3])
    str = self:formatValue(str, name, Attributes.Y, param[4])

    return str
end

function GUITXTEditor:dealLayout(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X, param[3])
    str = self:formatValue(str, name, Attributes.Y, param[4])
    str = self:formatValue(str, name, Attributes.W, param[5])
    str = self:formatValue(str, name, Attributes.H, param[6])

    return str
end

function GUITXTEditor:dealListView(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X, param[3])
    str = self:formatValue(str, name, Attributes.Y, param[4])
    str = self:formatValue(str, name, Attributes.W, param[5])
    str = self:formatValue(str, name, Attributes.H, param[6])

    return str
end

function GUITXTEditor:dealScrollView(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X, param[3])
    str = self:formatValue(str, name, Attributes.Y, param[4])
    str = self:formatValue(str, name, Attributes.W, param[5])
    str = self:formatValue(str, name, Attributes.H, param[6])

    return str
end

function GUITXTEditor:dealPageView(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X, param[3])
    str = self:formatValue(str, name, Attributes.Y, param[4])
    str = self:formatValue(str, name, Attributes.W, param[5])
    str = self:formatValue(str, name, Attributes.H, param[6])

    return str
end

function GUITXTEditor:dealTableView(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X, param[3])
    str = self:formatValue(str, name, Attributes.Y, param[4])
    str = self:formatValue(str, name, Attributes.W, param[5])
    str = self:formatValue(str, name, Attributes.H, param[6])

    local wid = self:GetValue(param[8])
    local hgt = self:GetValue(param[9])
    local num = self:GetValue(param[10])
    local idx = self:GetValue(param[11])

    local cStr = sformat([[%s.__%s__ = '%s']], name, GUIAttributes.TABLE_VIEW, sgsub(cjson.encode({CellW = wid, CellH = hgt, CellN = num, JumpIdx = idx}), "\\", "\\\\"))

    str = sformat("%s\n%s", str, cStr)

    return str
end

function GUITXTEditor:dealTextInput(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X,       param[3])
    str = self:formatValue(str, name, Attributes.Y,       param[4])
    str = self:formatValue(str, name, Attributes.W,       param[5])
    str = self:formatValue(str, name, Attributes.H,       param[6])
    str = self:formatValue(str, name, Attributes.FSIZE,   param[7])

    return str
end

function GUITXTEditor:dealRichText(str, contents, matchStr)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s )
        param[#param+1] = GUIHelper:format(s)
    end)

    local parent        = param[1] 
    local px            = param[3]
    local py            = param[4]
    local text          = self:GetValue(param[5])
    local width         = self:GetValue(param[6])
    local fontSize      = self:GetValue(param[7])
    local fontColor     = self:GetValue(param[8])
    local vspace        = self:GetValue(param[9])
    local hyperlinkCB   = param[10]
    local RFace         = self:GetValue(param[11])

    local xStr = nil
    local x, ismatch = self:GetValue(px)
    if ismatch then
        xStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.X, x)
        x    = load(sformat([[return %s]], px))()
    else
        x    = tonumber(px)
    end

    local yStr = nil
    local y, ismatch = self:GetValue(py)
    if ismatch then
        yStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.Y, y)
        y   = load(sformat("return %s", py))()
    else
        y   = tonumber(py)
    end

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, name, x, y , defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    local cStr = sformat([[%s.__%s__ = {Text = "%s", Width = %s, RSize = %s, RColor = "%s", FSpace = %s, LinkCB = %s, RFace = "%s"}]], name, GUIAttributes.RICH_TEXT, text, width, fontSize, fontColor, vspace, hyperlinkCB, RFace)

    str = sformat("%s\n%s", str, cStr)

    str = xStr and str .. "\n" .. xStr or str
    
    str = yStr and str .. "\n" .. yStr or str
    
    return str
end

function GUITXTEditor:dealEffect(str, contents, matchStr)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s )
        param[#param+1] = GUIHelper:format(s)
    end)

    local parent = param[1] 
    local px     = param[3]
    local py     = param[4]
    local type   = self:GetValue(param[5])
    local sfxID  = self:GetValue(param[6])
    local sex    = self:GetValue(param[7])
    local act    = self:GetValue(param[8])
    local dir    = self:GetValue(param[9])
    local speed  = self:GetValue(param[10])

    local xStr = nil
    local x, ismatch = self:GetValue(px)
    if ismatch then
        xStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.X, x)
        x    = load(sformat([[return %s]], px))()
    else
        x    = tonumber(px)
    end

    local yStr = nil
    local y, ismatch = self:GetValue(py)
    if ismatch then
        yStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.Y, y)
        y   = load(sformat("return %s", py))()
    else
        y   = tonumber(py)
    end

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, name, x, y, defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    local cStr = sformat([[%s.__%s__ = '%s']], name, GUIAttributes.EFFECT, sgsub(cjson.encode({type = type, sfxID = sfxID, sex = sex, act = act, dir = dir, speed = speed}), "\\", "\\\\"))

    str = sformat("%s\n%s", str, cStr)

    str = xStr and str .. "\n" .. xStr or str
    
    str = yStr and str .. "\n" .. yStr or str
    
    return str
end

function GUITXTEditor:dealItem(str, contents, matchStr)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local itemData = {}
    sgsub(contents, "{(.+)}", function ( s )
        sgsub(s .. ",", "(.-)=(.-),", function ( a, b )
            itemData[strim(a)] = self:GetValue(b)
        end)
    end)

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    local parent = param[1] 
    local px     = param[3]
    local py     = param[4]

    local xStr = nil
    local x, ismatch = self:GetValue(px)
    if ismatch then
        xStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.X, x)
        x    = load(sformat([[return %s]], px))()
    else
        x    = tonumber(px)
    end

    local yStr = nil
    local y, ismatch = self:GetValue(py)
    if ismatch then
        yStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.Y, y)
        y   = load(sformat("return %s", py))()
    else
        y   = tonumber(py)
    end

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, name, x, y, defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    local cStr = sformat([[%s.__%s__ = '%s']], name, GUIAttributes.ITEM_SHOW, sgsub(cjson.encode(itemData), "\\", "\\\\"))

    str = sformat("%s\n%s", str, cStr)

    str = xStr and str .. "\n" .. xStr or str
    
    str = yStr and str .. "\n" .. yStr or str

    return str
end

function GUITXTEditor:dealModel(str, contents, matchStr)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local data = {}
    sgsub(contents, "{(.+)}", function ( s )
        sgsub(s .. ",", "(.-)=(.-),", function ( a, b )
            data[strim(a)] = GUIHelper:format(self:GetValue(b))
        end)
    end)

    contents = sgsub(contents, "{(.+)}", "")

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    local parent = param[1] 
    local px     = param[3]
    local py     = param[4]
    data.sex     = self:GetValue(param[5])
    data.scale   = self:GetValue(param[7])

    data.notShowMold = self:GetStatus(data["notShowMold"]) and 0 or 1
    data.notShowHair = self:GetStatus(data["notShowHair"]) and 0 or 1


    local xStr = nil
    local x, ismatch = self:GetValue(px)
    if ismatch then
        xStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.X, x)
        x    = load(sformat([[return %s]], px))()
    else
        x    = tonumber(px)
    end

    local yStr = nil
    local y, ismatch = self:GetValue(py)
    if ismatch then
        yStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.Y, y)
        y   = load(sformat("return %s", py))()
    else
        y   = tonumber(py)
    end

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, name, x, y, defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    local cStr = sformat([[%s.__%s__ = '%s']], name, GUIAttributes.MODEL, sgsub(cjson.encode(data), "\\", "\\\\"))

    str = sformat("%s\n%s", str, cStr)

    str = xStr and str .. "\n" .. xStr or str
    
    str = yStr and str .. "\n" .. yStr or str

    return str
end

function GUITXTEditor:dealLoadingBar(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X,       param[3])
    str = self:formatValue(str, name, Attributes.Y,       param[4])
    str = self:formatValue(str, name, Attributes.RES1,    param[5])

    return str
end

function GUITXTEditor:dealSlider(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X,       param[3])
    str = self:formatValue(str, name, Attributes.Y,       param[4])
    str = self:formatValue(str, name, Attributes.RES1,    param[5])
    str = self:formatValue(str, name, Attributes.RES2,    param[6])
    str = self:formatValue(str, name, Attributes.RES3,    param[7])
    
    return str
end

function GUITXTEditor:dealCheckBox(str, contents)
    local i, j, name = sfind(str, " (.-)(%s*)=")
    if not name then
        return str
    end

    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    str = self:formatValue(str, name, Attributes.X,       param[3])
    str = self:formatValue(str, name, Attributes.Y,       param[4])
    str = self:formatValue(str, name, Attributes.RES1,    param[5])
    str = self:formatValue(str, name, Attributes.RES2,    param[6])
    
    return str
end


function GUITXTEditor:dealEquipShow(str, contents, matchStr)
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
    local px        = param[3]
    local py        = param[4]

    local xStr = nil
    local x, ismatch = self:GetValue(px)
    if ismatch then
        xStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.X, x)
        x    = load(sformat([[return %s]], px))()
    else
        x    = tonumber(px)
    end

    local yStr = nil
    local y, ismatch = self:GetValue(py)
    if ismatch then
        yStr =  sformat([[%s.__%s__ = '%s']], name, Attributes.Y, y)
        y   = load(sformat("return %s", py))()
    else
        y   = tonumber(py)
    end

    local posV = param[5]

    local pos, ismatch = self:GetValue(posV)
    if not ismatch then
        pos = tonumber(posV)
    end

    local isHero    = param[6]
    info.pos        = pos
    info.isHero     = isHero

    local newStr = sformat("GUI:Widget_Create(%s, '%s', %s, %s, %s, %s)", parent, name, x, y, defaultSize.width, defaultSize.height)
    str = sgsub(str, matchStr, newStr)

    str = sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], name, GUIAttributes.EQUIP_SHOW, sgsub(cjson.encode(info), "\\", "\\\\")))

    str = xStr and str .. "\n" .. xStr or str
    
    str = yStr and str .. "\n" .. yStr or str

    return str
end

function GUITXTEditor:dealEquipShowAttri(str, contents, key1)
    local name = contents
    if not name or string.len(name) == 0 then
        return str
    end

    local pTable = {}
    pTable.autoUpdate = true

    str = sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], name, key1, sgsub(cjson.encode(pTable), "\\", "\\\\")))
    return str
end

function GUITXTEditor:dealMessage(str, contents)
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
    local msgID   = self:GetValue(param[1] or 0)
    local param1  = self:GetValue(param[2] or 0)
    local param2  = self:GetValue(param[3] or 0)
    local param3  = self:GetValue(param[4] or 0)
    local msgData = self:GetValue(param[5] and GUIHelper:format(param[5]) or "")

    local isClick, funcBody = false, ""
    if func then
        for k, v in sgmatch(func, "if (.-) then (.-) end") do
            isClick, funcBody = self:GetStatus(k, isClick), GUIHelper.ConvertToShowFormart(v or "")
        end
    end

    local itemData = {
        IsLuaMsg = isLuaMsg, MsgID = msgID, Param1 = param1, Param2 = param2, Param3 = param3, MsgData = msgData, IsClick = isClick, FuncBody = funcBody
    }

    local strs = sformat([[%s.__%s__ = '%s']], name, GUIAttributes.MESSAGE, sgsub(cjson.encode(itemData), "\\", "\\\\"))
    return strs
end

function GUITXTEditor:dealNoticeEvent(str, contents)
    local param       = ssplit(contents, ",")
    local n           = #param
    local EventID     = param[1]
    local triggerName = sgsub(strim(param[2]), "\"", "")
    local widget      = param[n]
    local funcStr     = ""
    for i = 3, n-1 do
        if i > 3 and i < n then
            funcStr = funcStr .. "," .. param[i]
        else
            funcStr = funcStr .. param[i]
        end
    end

    funcStr = strim(funcStr)

    local events = {{EventID = EventID}}

    local conditions = {}
    for v in sgmatch(funcStr, "(if (.-) then (.-) else (.-) end)(.-)") do
        -- print(v)

        local i, j, v1, v2, v3 = sfind(v, "if (.-) then (.-) else (.-) end")
        -- print(v1)
        -- print(v2)
        -- print(v3)
        -- print("**********************************")

        local trimKh = function (s)
            return sgsub(sgsub(s, "[%)]+$", ""), "^[%(]+", "")
        end

        if v1 then
            conditions[#conditions + 1] = {ID = trimKh(v1), Act1 = v2, Act2 = v3}
        end
    end

    local data = {events = cjson.encode(events), triggerName = sformat('%s', triggerName), conditions = cjson.encode(conditions)}
    self:BindNoticeEvent(data)

    return ""
end

function GUITXTEditor:dealUserUILayout(str, contents)
    local name, params = nil, {}
    sgsub(contents, "(.-),%s*{(.-)}", function ( a, b )
        sgsub(b .. ",", "(.-)=(.-),", function ( a, b ) params[strim(a)] = self:GetValue(b) end)
        name = a
    end)

    if not name then
        return str
    end

    params.IsClick = true

    local cStr = sformat([[%s.__%s__ = '%s']], name, GUIAttributes.SCROLLVIEW_MOREROW, sgsub(cjson.encode(params), "\\", "\\\\"))

    return cStr
end

function GUITXTEditor:dealAttribute(str, contents, key1, key2)
    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    local name = param[1] 
    str = self:formatValue(str, name, key1, param[2])
    str = self:formatValue(str, name, key2, param[3])

    return str
end

function GUITXTEditor:dealAttribute2(str, contents, key1, key2)
    local param = {}
    sgsub(contents .. ",", "(.-),(%s*)", function ( s ) param[#param+1] = s end)

    local Param1 = param[1]
    local p2 = self:GetValue(param[2])
    local p3 = self:GetValue(param[3])
    local p4 = self:GetValue(param[4])
    
    local pTable = {}
    if p2 then
        pTable.Param2 = p2
    end

    if p3 then
        pTable.Param3 = p3
    end

    if p4 then
        pTable.Param4 = p4
    end

    if not next(pTable) then
        return ""
    end

    local str = sformat([[%s.__%s__ = '%s']], Param1, key1, sgsub(cjson.encode(pTable), "\\", "\\\\"))
    return str
end

function GUITXTEditor:dealAttribute3(str, contents, key1, key2)
    local s = ssplit(contents, ",")
    local name  = strim(s[1])
    local value = self:GetValue(GUIHelper:format(s[2])) or "#FFFFFF"
    if not name then
        return false
    end

    return sformat([[%s.__%s__ = '%s']], name, key1, sgsub(cjson.encode({Param2 = value}), "\\", "\\\\"))
end

function GUITXTEditor:dealCustomFormat(str, contents, key1)
    local key = "GUI:" .. key1 .. "%((.+)%)"
    local param = {IsCheck = false}
    local n = 1
    sgsub(contents, "if (.-) then (.+) end", function (value1, value2)
        sgsub(value2, key, function (ss)
            sgsub(ss .. ",", "(.-),(%s*)", function (s)
                param["Param"..n] = self:GetValue(sgsub(s, "function %(sender%) (.-) end", "%1"))
                n = n + 1
            end)
        end)
        param.IsCheck = value1
    end)

    if n <= 1 then
        return ""
    end

    str = sformat([[%s.__%s__ = '%s']], param.Param1, key1, sgsub(cjson.encode(param), "\\", "\\\\"))
    return str
end

function GUITXTEditor:dealFunc_SetParam(str, contents, key)
    local params = {}
    local name   = nil
    local type   = nil

    sgsub(contents, "(.-),%s*{(.-)},(.*)", function ( a, b, t )
        sgsub(b .. ",", "(.-)=(.-),", function ( a, b ) params[strim(a)] = self:GetValue(GUIHelper:format(b)) end)
        name = a
        type = GUIHelper:format(t)
    end)

    if not name then
        return ""
    end

    local key = type and GUITypeKeys[type]
    if not key then
        return ""
    end

    return sformat([[%s.__%s__ = '%s']], name, key, sgsub(cjson.encode(params), "\\", "\\\\"))
end

function GUITXTEditor:dealUIIDS(str, contents, key)
    local params = {}
    local name   = nil
    local type   = nil

    sgsub(contents, "(.-),%s*{(.-)}", function ( a, b)
        sgsub(b .. ",", "(.-)=(.-),", function ( a, b ) params[strim(a)] = self:GetValue(GUIHelper:format(b)) end)
        name = a
    end)

    if not name then
        return ""
    end

    return sformat([[%s.__%s__ = '%s']], name, GUIAttributes.UIIDS, sgsub(cjson.encode(params), "\\", "\\\\"))
end

function GUITXTEditor:GetValue(value)
    local value, ismatch = GUIHelper.ConvertToShowFormart(value, "@￥@")
    return value, ismatch
end

function GUITXTEditor:formatStrValue(str, name, key, value)
    return sformat("%s\n%s", str, sformat([[%s.__%s__ = '%s']], name, key, value))
end

------------------------------------------------------------------------------------
-- 变量相关
function GUITXTEditor:formatValue(str, name, key, value)
    local value, ismatch = self:GetValue(value)
    if ismatch then
        return self:formatStrValue(str, name, key, value)
    else
        return str
    end
end

function GUITXTEditor:GetRealValue(widget, key, value)
    local newValue, ismatch = GUIHelper.ConvertToRunFormart(value)
    if not ismatch then
        widget:setNB(key, false)
        return value
    end

    widget:setNB(key, true)
    widget:setNBValue(key, value)
    newValue = load(sformat([[return %s]], newValue))()
    return newValue, value
end

function GUITXTEditor:GetRealValue2(value)
    local newValue, ismatch = GUIHelper.ConvertToRunFormart(value)
    if not ismatch then
        return value
    end

    newValue = load(sformat([[return %s]], newValue))()
    return newValue, value
end

function GUITXTEditor:GetAttribeValue(widget, key)
    local isNB = widget.IsNB and widget:IsNB(key)
    if isNB then
        return widget:getNBValue(key), FormatType.VAR
    else
        local func = FuncKeys[key] or GUIFuncKeys[key]
        if func then
            return func(widget), FormatType.CCS
        end
    end
end

function GUITXTEditor:GetStrFloat(widget, key)
    local value, formatType = self:GetAttribeValue(widget, key)
    if formatType == FormatType.CCS then
        return ", %s", sformat("%.2f", value), true
    end
    value = GUIHelper.ConvertToRunFormart(value)
    return ", %s", value
end

function GUITXTEditor:GetStrInt(widget, key)
    local value, formatType = self:GetAttribeValue(widget, key)
    if formatType == FormatType.CCS then
        return ", %s", tonumber(value), true
    end
    value = GUIHelper.ConvertToRunFormart(value)
    return ", %s", value
end

function GUITXTEditor:GetStrBoolean(widget, key)
    local value, formatType = self:GetAttribeValue(widget, key)
    if formatType == FormatType.VAR then
        value = GUIHelper.ConvertToRunFormart(value)
        return ", %s", value
    end
    return ", %s", value, true
end

function GUITXTEditor:GetStrVar(widget, key)
    local value, formatType = self:GetAttribeValue(widget, key)
    if formatType == FormatType.VAR then
        value = GUIHelper.ConvertToRunFormart(value)
        return ", %s", value
    end
    return ", \"%s\"", value, true
end

function GUITXTEditor:GetStrString(widget, key)
    local value, formatType = self:GetAttribeValue(widget, key)
    if formatType == FormatType.VAR then
        value = GUIHelper.ConvertToRunFormart(value)
        return ", %s", value
    end
    return ", %s", self:formatText(value), true
end
------------------------------------------------------------------------------------

function GUITXTEditor:dealUI(str)
    local Components = {
        { key = "GUI:Widget_Create%((.+)%)",            callfunc = handler(self, self.dealWidget)       },
        
        { key = "GUI:Button_Create%((.+)%)",            callfunc = handler(self, self.dealButton)       },
        { key = "GUI:Image_Create%((.+)%)",             callfunc = handler(self, self.dealImageView)    },
    
        { key = "GUI:Text_Create%((.+)%)",              callfunc = handler(self, self.dealText)         },
        { key = "GUI:BmpText_Create%((.+)%)",           callfunc = handler(self, self.dealBmpText)      },
        { key = "GUI:TextAtlas_Create%((.+)%)",         callfunc = handler(self, self.dealTextAtlas)    },

        { key = "GUI:Layout_Create%((.+)%)",            callfunc = handler(self, self.dealLayout)       },
        { key = "GUI:ListView_Create%((.+)%)",          callfunc = handler(self, self.dealListView)     },
        { key = "GUI:ScrollView_Create%((.+)%)",        callfunc = handler(self, self.dealScrollView)   },
        { key = "GUI:PageView_Create%((.+)%)",          callfunc = handler(self, self.dealPageView)     },
        { key = "GUI:TableView_Create%((.+)%)",         callfunc = handler(self, self.dealTableView)    },

        { key = "GUI:RichText_Create%((.+)%)",          callfunc = handler(self, self.dealRichText)     },

        { key = "GUI:Effect_Create%((.+)%)",            callfunc = handler(self, self.dealEffect)       },
        
        { key = "GUI:ItemShow_Create%((.+)%)",          callfunc = handler(self, self.dealItem)         },
        
        { key = "GUI:UIModel_Create%((.+)%)",           callfunc = handler(self, self.dealModel)        },

        { key = "GUI:Slider_Create%((.+)%)",            callfunc = handler(self, self.dealSlider)       },
        { key = "GUI:CheckBox_Create%((.+)%)",          callfunc = handler(self, self.dealCheckBox)     },

        { key = "GUI:addOnClickEvent%((.+)%)",          callfunc = handler(self, self.dealMessage)      },
        { key = "EVENT_ON%((.+)%)",                     callfunc = handler(self, self.dealNoticeEvent)  },

        { key = "GUI:UserUILayout%((.+)%)",             callfunc = handler(self, self.dealUserUILayout) },

        { key = "GUI:LoadingBar_Create%((.+)%)",        callfunc = handler(self, self.dealLoadingBar)   },

        { key = "GUI:TextInput_Create%((.+)%)",         callfunc = handler(self, self.dealTextInput)    },

        { key = "GUI:Win_SetParam%((.+)%)",             callfunc = handler(self, self.dealFunc_SetParam)},

        { key = "GUI:setUIIDs%((.+)%)",                 callfunc = handler(self, self.dealUIIDS)        },

        { key = "GUI:EquipShow_Create%((.+)%)",         callfunc = handler(self, self.dealEquipShow) },

    }

    local AttrFuncs = {
        { key = "GUI:setPosition%((.+)%)",                      callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.X,      AKey2 = Attributes.Y      },
        { key = "GUI:setAnchorPoint%((.+)%)",                   callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.ANRX,   AKey2 = Attributes.ANRY   },
        { key = "GUI:setContentSize%((.+)%)",                   callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.W,      AKey2 = Attributes.H      },
        { key = "GUI:ScrollView_setInnerContainerSize%((.+)%)", callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.INNERW, AKey2 = Attributes.INNERH },
        { key = "GUI:setPositionX%((.+)%)",                     callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.X        },
        { key = "GUI:setPositionY%((.+)%)",                     callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.Y        },
        { key = "GUI:setAnchorPointX%((.+)%)",                  callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.ANRX     },
        { key = "GUI:setAnchorPointY%((.+)%)",                  callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.ANRY     },
        { key = "GUI:setTag%((.+)%)",                           callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.TAG      },
        { key = "GUI:setRotation%((.+)%)",                      callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.ROTATE   },
        { key = "GUI:setVisible%((.+)%)",                       callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.VISIBLE  },
        { key = "GUI:setOpacity%((.+)%)",                       callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.OPACITY  },
        { key = "GUI:setScaleX%((.+)%)",                        callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.SCALEX   },
        { key = "GUI:setScaleY%((.+)%)",                        callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.SCALEY   },
        { key = "GUI:setTouchEnabled%((.+)%)",                  callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.ISTOUCH  },
        { key = "GUI:Text_setFontSize%((.+)%)",                 callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.FSIZE    },
        { key = "GUI:TextInput_setFontSize%((.+)%)",            callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.FSIZE    },
        { key = "GUI:Text_setTextColor%((.+)%)",                callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.TCOLOR   },
        { key = "GUI:ScrollText_setTextColor%((.+)%)",          callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.TCOLOR   },
        { key = "GUI:Button_setTitleColor%((.+)%)",             callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.TCOLOR   },
        { key = "GUI:Text_setString%((.+)%)",                   callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.TEXT     },
        { key = "GUI:ScrollText_setString%((.+)%)",             callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.TEXT     },
        { key = "GUI:TextInput_setString%((.+)%)",              callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.TEXT     },
        { key = "GUI:TextAtlas_setString%((.+)%)",              callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.TEXT     },
        { key = "GUI:Button_setTitleText%((.+)%)",              callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.BTEXT    },
        { key = "GUI:ProgressTimer_setPercentage%((.+)%)",      callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.PERCENT  },
        { key = "GUI:CheckBox_setSelected%((.+)%)",             callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.SELECTED },
        { key = "GUI:setJumpIndex%((.+)%)",                     callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.JUMPINDEX},

        -- Res
        { key = "GUI:Image_loadTexture%((.+)%)",                      callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES1 }, 

        { key = "GUI:Button_loadTextureNormal%((.+)%)",               callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES1 }, 
        { key = "GUI:Button_loadTexturePressed%((.+)%)",              callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES2 }, 
        { key = "GUI:Button_loadTextureDisabled%((.+)%)",             callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES3 },

        { key = "GUI:LoadingBar_loadTexture%((.+)%)",                 callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES1 }, 

        { key = "GUI:CheckBox_loadTextureFrontCross%((.+)%)",         callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES1 }, 
        { key = "GUI:CheckBox_loadTextureBackGround%((.+)%)",         callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES2 },
        { key = "GUI:CheckBox_loadTextureFrontCrossDisabled%((.+)%)", callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES3 },

        { key = "GUI:Slider_loadBarTexture%((.+)%)",                  callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES1 }, 
        { key = "GUI:Slider_loadProgressBarTexture%((.+)%)",          callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES2 },
        { key = "GUI:Slider_loadSlidBallTextureNormal%((.+)%)",       callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES3 },

        { key = "GUI:Layout_setBackGroundImage%((.+)%)",              callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES1 },
        { key = "GUI:ListView_setBackGroundImage%((.+)%)",            callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES1 },
        { key = "GUI:ScrollView_setBackGroundImage%((.+)%)",          callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES1 },
        { key = "GUI:PageView_setBackGroundImage%((.+)%)",            callfunc = handler(self, self.dealAttribute), AKey1 = Attributes.RES1 },

        { key = "GUI:ItemShow_setItemTouchSwallow%((.+)%)",           callfunc = handler(self, self.dealAttribute2), AKey1 = GUIAttributes.SWALLOW },

        { key = "GUI:setSwallowTouches%((.+)%)",                      callfunc = handler(self, self.dealAttribute2), AKey1 = GUIAttributes.SWALLOW },
        
        { key = "GUI:LoadExportEx%((.+)%)",                           callfunc = handler(self, self.dealAttribute2), AKey1 = GUIAttributes.ATTACH_NODE },

        { key = "GUI:setButtonPage%((.+)%)",                          callfunc = handler(self, self.dealAttribute2), AKey1 = GUIAttributes.BUTTON_PAGE },

        { key = "GUI:setContainerIndexTable%((.+)%)",                 callfunc = handler(self, self.dealAttribute2), AKey1 = GUIAttributes.CONTAIN_INDEX },

        { key = "GUI:setButtonPressColor%((.+)%)",                    callfunc = handler(self, self.dealAttribute3), AKey1 = GUIAttributes.BUTTON_CLICKCOLOR },

        { key = "%-%-Custom Format%-%->(.+)",                         callfunc = handler(self, self.dealCustomFormat), AKey1 = GUIAttributes.TEXT_COUNTDOWN },

        { key = "GUI:EquipShow_setAutoUpdate%((.+)%)",                callfunc = handler(self, self.dealEquipShowAttri), AKey1 = GUIAttributes.EQUIP_AUTO }

    }

    local convertFormat = function (text)
        return GUIHelper.FormatServerVarVALUE(text, SerVarNames)
    end

    for m = 1, #Components do
        local var = Components[m]
        local matchStr = var.key
        local callfunc = var.callfunc
        local i, j, contents = sfind(str, matchStr)
        if contents then
            if callfunc then
                str = callfunc(str, convertFormat(contents), matchStr)
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
                str = callfunc(str, convertFormat(contents), var.AKey1, var.AKey2)
                break
            end
        end
    end

    return str
end
------------------------------------------------------------------------------------

function GUITXTEditor:CheckShowPos(node)
    local size = node:getContentSize()
    local anr = node:getAnchorPoint()
    local pos = node.getWorldPosition and node:getWorldPosition() or cc.p(node:getPosition())

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
function GUITXTEditor:onCopyNode()
    print("-- CTRL + C --")
    if self._selWidget then
        self._copyWidget = self:cloneEx(self._selWidget)
        self._copyWidget:retain()
        self._cutWidget = nil
    end
end

-- CTRL + V
function GUITXTEditor:onStickNode()
    print("-- CTRL + V --")
    if self._cutWidget then
        self:onStick(self._cutWidget)
        self._cutWidget = nil
    elseif self._selWidget then
        self:onCopy(self._copyWidget)
    end
end

-- CTRL + X
function GUITXTEditor:onCutNode()
    print("-- CTRL + X --")
    if self._selWidget then
        self._cutWidget = self._selWidget
        if self._copyWidget then
            self._copyWidget:autorelease()
            self._copyWidget = nil
        end
    end
end

function GUITXTEditor:onCopy(node)
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
    if (pWidget:getDescription() == "PageView" or pWidget:getDescription() == "TableView") and node:getDescription() ~= "Layout" then
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

function GUITXTEditor:onStick(node)
    if not node or self._selWidget == node then
        return false
    end

    local pWidget = self._selWidget or self._Node_UI
    if (pWidget:getDescription() == "PageView" or pWidget:getDescription() == "TableView") and node:getDescription() ~= "Layout" then
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
function GUITXTEditor:copySpecialProperties(newWidget, widget)
    local attfunc = {
        Label = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)

            self:CopyNBAttribute(newWidget, widget)
            
            newWidget:enableOutline(widget:getEffectColor(), widget:getOutlineSize())
        end,
        BmpText = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)

            self:CopyNBAttribute(newWidget, widget)

            GUI:SetBmpTextProperties(newWidget)

            newWidget:setBMFontFilePath()
            
            local fontColor = widget:getTextColor()
            newWidget:setTextColor(fontColor)

            self:CopyNBAttribute(newWidget, widget)
        end,
        TextAtlas = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)

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
            GUI:setID(newWidget, 0)

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
            GUI:setID(newWidget, 0)

            self:CopyNBAttribute(newWidget, widget)

            newWidget:loadTexture(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isScale9Enabled() then
                self:setCapInsetValue(newWidget, "ImageView", self:getCapInset(widget))
            end

            self:CopyNBAttribute(newWidget, widget)
        end,
        Button = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)

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
            GUI:setID(newWidget, 0)

            self:CopyNBAttribute(newWidget, widget)

            newWidget:loadTextureBackGround(GUITXTEditorDefine.getResPath(widget, "N"))
            newWidget:loadTextureFrontCross(GUITXTEditorDefine.getResPath(widget, "P"))
        end,
        Slider = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)

            self:CopyNBAttribute(newWidget, widget)

            newWidget:loadBarTexture(GUITXTEditorDefine.getResPath(widget, "N"))
            newWidget:loadProgressBarTexture(GUITXTEditorDefine.getResPath(widget, "P"))
            newWidget:loadSlidBallTextureNormal(GUITXTEditorDefine.getResPath(widget, "D"))
        end,
        LoadingBar = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)

            self:CopyNBAttribute(newWidget, widget)

            newWidget:loadTexture(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget._renderlabel then
                local data = self:GetAttribeValue(widget, GUIAttributes.LOADING_BAR)
                self:createLBarLabel(newWidget, data)
            end
        end,
        Layout = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setBackGroundImage(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isBackGroundImageScale9Enabled() then
                self:setCapInsetValue(newWidget, "Layout", self:getCapInset(widget))
            end
        end,
        ListView = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)
            GUI:setChildID(newWidget, GUI:getChildID(widget))
            GUI:setJumpIndex(newWidget, GUI:getJumpIndex(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setBackGroundImage(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isBackGroundImageScale9Enabled() then
                self:setCapInsetValue(newWidget, "ListView", self:getCapInset(widget))
            end
        end,
        ScrollView = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)
            GUI:setChildID(newWidget, GUI:getChildID(widget))
            GUI:setJumpIndex(newWidget, GUI:getJumpIndex(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setBackGroundImage(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isBackGroundImageScale9Enabled() then
                self:setCapInsetValue(newWidget, "ScrollView", self:getCapInset(widget))
            end
        end,
        PageView = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)
            GUI:setChildID(newWidget, GUI:getChildID(widget))
            GUI:setJumpIndex(newWidget, GUI:getJumpIndex(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setBackGroundImage(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isBackGroundImageScale9Enabled() then
                self:setCapInsetValue(newWidget, "PageView", self:getCapInset(widget))
            end
        end,
        TableView = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)
            GUI:setChildID(newWidget, GUI:getChildID(widget))

            self:CopyNBAttribute(newWidget, widget)

            newWidget:setBackGroundImage(GUITXTEditorDefine.getResPath(widget, "N"))

            if widget:isBackGroundImageScale9Enabled() then
                self:setCapInsetValue(newWidget, "TableView", self:getCapInset(widget))
            end
        end,
        EditBox = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)

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
        
            if global.isAndroid then
                newWidget:setNativeOffset(cc.p(0, -13))
            end
        end,
        Effect = function ()
            GUI:setChineseName(newWidget, GUI:getChineseName(widget))
            GUI:setID(newWidget, 0)

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
            GUI:setID(newWidget, 0)

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

function GUITXTEditor:copyClonedWidgetChildren(target, origin)
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

                    self:CreateEffect(newTarget, true)
                    newTarget:setContentSize(defaultSize)

                    self:copySpecialProperties(newTarget, origin)
                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif originDesc == "RText" then 
                    local newTarget = ccui.Widget:create()
                    target:addChild(newTarget)

                    local rText = self:CreateRText(newTarget, true)
                    newTarget:setContentSize(rText:getContentSize())

                    self:copySpecialProperties(newTarget, origin)
                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif originDesc == "RichText" then
                elseif originDesc == "Item" then
                    local newTarget = ccui.Widget:create()
                    target:addChild(newTarget)

                    local item = self:CreateItemShow(newTarget, true)
                    newTarget:setContentSize(item:getContentSize())

                    self:copySpecialProperties(newTarget, origin)
                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif originDesc == "Model" then
                    local newTarget = ccui.Widget:create()
                    target:addChild(newTarget)

                    self:CreateModel(newTarget, true)
                    newTarget:setContentSize(defaultSize)

                    self:copySpecialProperties(newTarget, origin)
                    self:copyClonedWidgetChildren(newTarget, origin)
                elseif originDesc == "EquipShow" then
                    local newTarget = ccui.Widget:create()
                    target:addChild(newTarget)

                    local item = self:CreateEquipShow(newTarget, true)
                    newTarget:setContentSize(item:getContentSize())

                    self:copySpecialProperties(newTarget, origin)
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

function GUITXTEditor:cloneEx(widget)
    local cloneObj
    local desc = widget:getDescription()
    if desc == "EditBox" then
        cloneObj = ccui.EditBox:create(widget:getContentSize(), GUI.PATH_RES_ALPHA)
    elseif desc == "Effect" then
        cloneObj = ccui.Widget:create()
        self:CreateEffect(cloneObj, true)
        cloneObj:setContentSize(defaultSize)
    elseif desc == "RText" then 
        cloneObj = ccui.Widget:create()
        local rText = self:CreateRText(cloneObj, true)
        cloneObj:setContentSize(rText:getContentSize())
    elseif desc == "RichText" then
    elseif desc == "Item" then
        cloneObj = ccui.Widget:create()
        local item = self:CreateItemShow(cloneObj, true)
        cloneObj:setContentSize(item:getContentSize())
    elseif desc == "Model" then
        cloneObj = ccui.Widget:create()
        self:CreateModel(cloneObj, true)
        cloneObj:setContentSize(defaultSize)
    elseif desc == "EquipShow" then
        cloneObj = ccui.Widget:create()
        -- self:copySpecialProperties(cloneObj, widget)

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
                    -- self:copySpecialProperties(item, v)
                    newP:addChild(item)
                    
                    local itemShow = self:CreateItemShow(item, true)
                    item:setContentSize(itemShow:getContentSize())
                elseif desc == "EquipShow" then
                    item = ccui.Widget:create()
                    -- self:copySpecialProperties(item, v)
                    
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
    end

    self:copySpecialProperties(cloneObj, widget)
    self:copyClonedWidgetChildren(cloneObj, widget)

    return cloneObj
end
-- end --

-- 对齐方式 Ctrl + E    Ctrl + H    Ctrl + 1    Ctrl + 2  Ctrl + 3    Ctrl + 4
function GUITXTEditor:SetAlignStyle(style)
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
function GUITXTEditor:IsOutline(render)
    local tType = tolua.type(render)
    if (tType == "ccui.Text" or tType == "cc.Label") and render:getLabelEffectType() == 1 then
        return true
    end
    return false
end

function GUITXTEditor:AddSystemTips(str)
    GUIHelper.CteateShowTips(self, self._systemTipsCells, str)
end

function GUITXTEditor:CreateRText(widget, first)
    widget.getDescription = function() 
        return "RText" 
    end

    local getVal = function (key, value)
        if first then
            return value
        end
        return self:GetStatus(self:GetRealValue(widget, key, value))
    end

    local params = self:GetAttribeValue(widget, GUIAttributes.RICH_TEXT)

    local Text   = getVal("Text",   params.Text  )
    local Width  = getVal("Width",  params.Width )
    local RSize  = getVal("RSize",  params.RSize )
    local RColor = getVal("RColor", params.RColor)
    local RSpace = getVal("RSpace", params.RSpace)
    local LinkCB = getVal("LinkCB", params.LinkCB)
    local RFace  = getVal("RFace",  params.RFace )

    return GUI:RichText_Create(widget, "__RICHTEXT__", 0, 0, Text, Width, RSize, RColor, RSpace, LinkCB, RFace)
end

function GUITXTEditor:CreateEffect(widget, first)
    widget.getDescription = function() 
        return "Effect" 
    end

    local getVal = function (key, value)
        if first then
            return value
        end
        return self:GetStatus(self:GetRealValue(widget, key, value))
    end

    local params = self:GetAttribeValue(widget, GUIAttributes.EFFECT)

    local type   = getVal("type",   params.type )
    local sfxID  = getVal("sfxID",  params.sfxID)
    local sex    = getVal("sex",    params.sex  )
    local act    = getVal("act",    params.act  )
    local dir    = getVal("dir",    params.dir  )
    local speed  = getVal("speed",  params.speed)

    type  = tonumber(type)  or 4
    sfxID = tonumber(sfxID) or 1
    sex   = tonumber(sex)   or 0
    act   = tonumber(act)   or 0
    dir   = tonumber(dir)   or 0
    speed = tonumber(speed) or 1

    return GUI:Effect_Create(widget, "__SFX__", 0, 0, type, sfxID, sex, act, dir, speed)
end

function GUITXTEditor:CreateItemShow(widget, first)
    widget.getDescription = function() 
        return "Item" 
    end
    
    local data = self:GetAttribeValue(widget, GUIAttributes.ITEM_SHOW)
    local itemData = {}
    for key, value in pairs(data) do
        local value = first and value or self:GetRealValue(widget, key, value)
        itemData[key] = self:GetStatus(value)
    end

    itemData.look = false

    return GUI:ItemShow_Create(widget, "__ITEM__", 0, 0, itemData)
end

function GUITXTEditor:CreateModel(widget, first)
    widget.getDescription = function() 
        return "Model"
    end

    local sex, scale, feature = self:getModelData(widget, first)

    return GUI:UIModel_Create(widget, "__MODEL__", 0, 0, sex, feature, scale)
end

function GUITXTEditor:getModelData(widget, first)
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

    local feature = {}
    local sex     = 0
    local scale   = 1

    local data = self:GetAttribeValue(widget, GUIAttributes.MODEL)
    for key, value in pairs(data) do
        local nbValue = first and value or self:GetRealValue(widget, key, value)
        nbValue = self:GetStatus(value)
        if key == "sex" then
            sex = nbValue and (tonumber(nbValue) or nbValue) or sex
        elseif key == "scale" then
            scale = nbValue and (tonumber(nbValue) or nbValue) or scale
        elseif key == "notShowMold" or key == "notShowHair" then
            feature[key] = tonumber(nbValue) == 0
        elseif keys[key] then
            feature[key] = parse(nbValue)
        else
            feature[key] = nbValue
        end
    end

    return sex, scale, feature
end

function GUITXTEditor:CreateEquipShow(widget, first)
    widget.getDescription = function() 
        return "EquipShow" 
    end
    
    local data = self:GetAttribeValue(widget, GUIAttributes.EQUIP_SHOW)
    local info = {}
    for key, value in pairs(data) do
        local value = first and value or self:GetRealValue(widget, key, value)
        info[key] = self:GetStatus(value)
    end

    if first then
        self:NBEx(widget, GUIAttributes.EQUIP_SHOW, {isNB = true, value = info})
    end

    local param = self:GetEquipShowParam(info)

    dump(param,"===========================")

    return GUI:EquipShow_Create(widget, "__EQUIPSHOW__", 0, 0, param[1], param[2], param[3])
end

function GUITXTEditor:GetEquipShowParam(data)
    local param = {}
    local pos, isHero, autoUpdate = nil, nil, nil
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
    info.movable = false
    info.doubleTakeOff = false
    param[1] = tonumber(pos) or 1
    param[2] = isHero == true
    param[3] = info
    param[4] = autoUpdate
    return param
end

function GUITXTEditor:BindNoticeEvent(param)
    self._trigger = self._trigger or {}    
    self._trigger[#self._trigger+1] = {triggerName = param.triggerName, events = cjson.decode(param.events), conditions = cjson.decode(param.conditions)}
end

-- NB 的属性
function GUITXTEditor:NBEx(widget, key, param)
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

function GUITXTEditor:CopyNBAttribute(widget, srcWidget)
    for key, value in pairs(Attributes) do
        local newKey = sformat("__%s__", value)
        local nbValue = widget[srcWidget]
        self:NBEx(widget, key, {isNB = nbValue and true or false, value = nbValue})
    end
    
    for key, value in pairs(GUIAttributes) do
        local isNB = srcWidget.IsNB and srcWidget:IsNB(key)
        if isNB then
            self:NBEx(widget, key, {isNB = true, value = clone(srcWidget:getNBValue(key))})
        end
    end
end

function GUITXTEditor:InitNBAttribute(widget)
    for key, value in pairs(Attributes) do
        local newKey = sformat("__%s__", value)
        local nbValue = widget[newKey]
        self:NBEx(widget, key, {isNB = nbValue and true or false, value = nbValue})
    end
    
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

function GUITXTEditor:SetAttribute(key1, key2, value)
    local data = self:GetAttribeValue(self._selWidget, key1)
    data[key2] = value --or nil
    self:NBEx(self._selWidget, key1, {isNB = true, value = data})

    value = self:GetRealValue2(value)
    return value
end

function GUITXTEditor:SetUIAttribute(uiWidget, widget, key1, key2)
    local data = self:GetAttribeValue(widget, key1)
    local value = data[key2] or ""
    uiWidget:setString(value)
end

function GUITXTEditor:SetUICheckAttribute(uiWidget, widget, key1, key2)
    local data = self:GetAttribeValue(widget, key1)
    local isSelect = self:GetStatus(data[key2], false)
    uiWidget:setSelected(isSelect)
    return isSelect
end

return GUITXTEditor