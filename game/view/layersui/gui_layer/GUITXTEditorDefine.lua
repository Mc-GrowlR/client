local GUITXTEditorDefine = {}
local RichTextHelp = requireUtil("RichTextHelp")

local SUIHelper = requireSUI("SUIHelper")

local strim     = string.trim
local sgsub     = string.gsub
local ssplit    = string.split
local sformat   = string.format
local sfind     = string.find

local pics = {
    N = {
        Button     = function (widget) return SUIHelper.getResFile(widget:getRendererNormal()) end,
        ImageView  = function (widget) return SUIHelper.getResFile(widget:getVirtualRenderer()) end,
        LoadingBar = function (widget) return widget:getRenderFile().file end,
        Slider     = function (widget) return widget:getBackFile().file end,
        CheckBox   = function (widget) return widget:getBackNormalFile().file end,
        Layout     = function (widget) return widget:getRenderFile().file end,
        ListView   = function (widget) return widget:getRenderFile().file end,
        ScrollView = function (widget) return widget:getRenderFile().file end,
        PageView   = function (widget) return widget:getRenderFile().file end,
        TextAtlas  = function (widget) return widget:getRenderFile().file end
    },
    P = {
        Button     = function (widget) return SUIHelper.getResFile(widget:getRendererClicked()) end,
        Slider     = function (widget) return widget:getProgressBarFile().file end,
        CheckBox   = function (widget) return widget:getCrossNormalFile().file end
    },
    D = {
        Button     = function (widget) return SUIHelper.getResFile(widget:getRendererDisabled()) end,
        Slider     = function (widget) return widget:getBallNormalFile().file end
    }
}

GUITXTEditorDefine.getResPath = function (widget, type)
    local desc = widget:getDescription()
    return (pics[type] and pics[type][desc]) and pics[type][desc](widget) or ""
end

local Attributes = {
    X           = "X",
    Y           = "Y",
    W           = "W",
    H           = "H",
    ANRX        = "ANRX",
    ANRY        = "ANRY",
    FSIZE       = "FSIZE",
    BSIZE       = "BSIZE",
    COLOR       = "COLOR",
    ECOLOR      = "ECOLOR",
    FCOLOR      = "FCOLOR",
    TCOLOR      = "TCOLOR",
    TEXT        = "TEXT",
    BTEXT       = "BTEXT",
    SCALEX      = "SCALEX",
    SCALEY      = "SCALEY",
    ROTATE      = "ROTATE",
    VISIBLE     = "VISIBLE",
    ISTOUCH     = "ISTOUCH",
    OPACITY     = "OPACITY",
    TAG         = "TAG",
    PERCENT     = "PERCENT",
    DIR         = "DIR",
    SELECTED    = "SELECTED",
    INNERW      = "INNERW",
    INNERH      = "INNERH",

    RES1        = "RES1",
    RES2        = "RES2",
    RES3        = "RES3",

    JUMPINDEX   = "JUMPINDEX"
}
GUITXTEditorDefine.Attributes = Attributes

local FuncKeys = {
    [Attributes.X]           = function (widget) return sformat("%.2f", widget:getPositionX())                   end,
    [Attributes.Y]           = function (widget) return sformat("%.2f", widget:getPositionY())                   end,
    [Attributes.W]           = function (widget) return sformat("%.2f", widget:getContentSize().width)           end,
    [Attributes.H]           = function (widget) return sformat("%.2f", widget:getContentSize().height)          end,
    [Attributes.ANRX]        = function (widget) return sformat("%.2f", widget:getAnchorPoint().x)               end,
    [Attributes.ANRY]        = function (widget) return sformat("%.2f", widget:getAnchorPoint().y)               end,
    [Attributes.FSIZE]       = function (widget) return widget:getFontSize()                                     end,
    [Attributes.FCOLOR]      = function (widget) return GetColorHexFromRBG(widget:getTextColor())                end,
    [Attributes.TCOLOR]      = function (widget) return GetColorHexFromRBG(widget:getTitleColor())               end,
    [Attributes.TEXT]        = function (widget) return widget:getString()                                       end,
    [Attributes.BTEXT]       = function (widget) return widget:getTitleText()                                    end,
    [Attributes.SCALEX]      = function (widget) return sformat("%.2f", widget:getScaleX())                      end,
    [Attributes.SCALEY]      = function (widget) return sformat("%.2f", widget:getScaleY())                      end,
    [Attributes.ROTATE]      = function (widget) return sformat("%.2f", widget:getRotation())                    end,
    [Attributes.VISIBLE]     = function (widget) return widget:isVisible()                                       end,
    [Attributes.ISTOUCH]     = function (widget) return widget:isTouchEnabled()                                  end,
    [Attributes.OPACITY]     = function (widget) return widget:getOpacity()                                      end,
    [Attributes.TAG]         = function (widget) return widget:getTag()                                          end,
    [Attributes.PERCENT]     = function (widget) return widget:getPercent()                                      end,
    [Attributes.SELECTED]    = function (widget) return widget:isSelected()                                      end,
    [Attributes.INNERW]      = function (widget) return sformat("%.2f", widget:getInnerContainerSize().width)    end,
    [Attributes.INNERH]      = function (widget) return sformat("%.2f", widget:getInnerContainerSize().height)   end,

    [Attributes.RES1]        = function (widget) return GUITXTEditorDefine.getResPath(widget, "N") end,
    [Attributes.RES2]        = function (widget) return GUITXTEditorDefine.getResPath(widget, "P") end,
    [Attributes.RES3]        = function (widget) return GUITXTEditorDefine.getResPath(widget, "D") end,

    [Attributes.JUMPINDEX]   = function (widget) return GUI:getJumpIndex(widget) end,
}
GUITXTEditorDefine.FuncKeys = FuncKeys

local GUIAttributes = {
    ITEM_SHOW           = "ITEM_SHOW",
    RICH_TEXT           = "RICH_TEXT",
    TEXT_COUNTDOWN      = "TEXT_COUNTDOWN",
    TABLE_VIEW          = "TABLE_VIEW",
    SWALLOW             = "SWALLOW",
    MESSAGE             = "MESSAGE",
    EFFECT              = "EFFECT",
    LOADING_BAR         = "LOADING_BAR",
    LABEL_EX            = "LABEL_EX",
    INPUT_EX            = "INPUT_EX",
    BUTTON_EX           = "BUTTON_EX",
    SLIDER_EX           = "SLIDER_EX",
    MODEL               = "MODEL",
    ATTACH_NODE         = "ATTACH_NODE",
    BUTTON_PAGE         = "BUTTON_PAGE",
    CONTAIN_INDEX       = "CONTAIN_INDEX",
    BUTTON_CLICKCOLOR   = "BUTTON_CLICKCOLOR",
    SCROLLVIEW_MOREROW  = "SCROLLVIEW_MOREROW",
    UIIDS               = "UIIDS",
    TEXT_METAVALUE      = "TEXT_METAVALUE",
    EQUIP_SHOW          = "EQUIP_SHOW",
    EQUIP_AUTO          = "EQUIP_AUTO",
}
GUITXTEditorDefine.GUIAttributes = GUIAttributes

local GUIFuncKeys = {
    [GUIAttributes.ITEM_SHOW]           = function () return {index = 1, count = 1, look = true, bgVisible = true} end,
    [GUIAttributes.RICH_TEXT]           = function () return {Text = "RText", Width = 200, RSize = global.ConstantConfig.DEFAULT_FONT_SIZE, RColor = "#ffffff", RSpace = global.ConstantConfig.DEFAULT_VSPACE, RFace = global.MMO.PATH_FONT2, RCall = nil, LinkCB = nil} end,
    [GUIAttributes.TEXT_COUNTDOWN]      = function () return {IsCheck = false, Param2 = 0, Param3 = ""} end,
    [GUIAttributes.TABLE_VIEW]          = function () return {CellN = 0, CellW = 60, CellH = 60, JumpIdx = 1} end,
    [GUIAttributes.SWALLOW]             = function () return {Param2 = true} end,
    [GUIAttributes.MESSAGE]             = function () return {IsLuaMsg = false, MsgID = 0, Param1 = 0, Param2 = 0, Param3 = 0, MsgData = "", IsClick = false, FuncBody = ""} end,
    [GUIAttributes.EFFECT]              = function () return {type = 4, sfxID = 1, sex = 0, act = 0, dir = 0, speed = 1, loop = true} end,
    [GUIAttributes.LOADING_BAR]         = function () return {value = 0, maxValue = 100, interval = 0, step = 1, lx = 100, ly = 20, lsize = 14, lvisible = 0, lcolor = "#ffffff"} end,
    [GUIAttributes.SLIDER_EX]           = function () return {value = 0, maxValue = 100, ids = ""} end,
    [GUIAttributes.INPUT_EX]            = function () return {id = 0, type = 0, checkSensitive = false, cipher = false} end,
    [GUIAttributes.MODEL]               = function () return {
                                            sex             = 0, 
                                            scale           = 1, 
                                            clothID         = nil, 
                                            clothEffectID   = nil, 
                                            weaponID        = nil, 
                                            weaponEffectID  = nil, 
                                            headID          = nil, 
                                            headEffectID    = nil, 
                                            capID           = nil, 
                                            capEffectID     = nil, 
                                            veilID          = nil, 
                                            veilEffectID    = nil, 
                                            hairID          = nil, 
                                            notShowMold     = 1, 
                                            notShowHair     = 1} end,
    [GUIAttributes.LABEL_EX]            = function () return {id = 0} end,
    [GUIAttributes.BUTTON_EX]           = function () return {ids = "", grey = 1} end,
    [GUIAttributes.ATTACH_NODE]         = function () return {Param2 = ""} end,
    [GUIAttributes.BUTTON_PAGE]         = function () return {Param2 = false} end,
    [GUIAttributes.CONTAIN_INDEX]       = function () return {Param2 = 0} end,
    [GUIAttributes.BUTTON_CLICKCOLOR]   = function () return {Param2 = "#ffffff"} end,
    [GUIAttributes.SCROLLVIEW_MOREROW]  = function () return {IsClick = false, dir = 0, addDir = 0, colnum = 1, x = 0, y = 0, l = 0, t = 0, play = false} end,
    [GUIAttributes.UIIDS]               = function () return {redID = 0, guideID = 0} end,
    [GUIAttributes.TEXT_METAVALUE]      = function () return {Param2 = ""} end,
    [GUIAttributes.EQUIP_SHOW]          = function () return {pos = 1, look = true, bgVisible = true} end,
    [GUIAttributes.EQUIP_AUTO]          = function () return {autoUpdate = false} end,

}
GUITXTEditorDefine.GUIFuncKeys = GUIFuncKeys

local GUITypeKeys = {
    Input       = GUIAttributes.INPUT_EX,
    Label       = GUIAttributes.LABEL_EX,
    Button      = GUIAttributes.BUTTON_EX,
    Slider      = GUIAttributes.SLIDER_EX,
    LoadingBar  = GUIAttributes.LOADING_BAR
}
GUITXTEditorDefine.GUITypeKeys = GUITypeKeys

return GUITXTEditorDefine