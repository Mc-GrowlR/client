local SUIDefine = {}

SUIDefine.defaultOutline    = SL:GetMetaValue("GAME_DATA","defaultOutlineSize") or 1
SUIDefine.defaultOutlineC   = SL:GetMetaValue("GAME_DATA","defaultOutlineColor") or 0
SUIDefine.defaultColorID    = 255
SUIDefine.defaultFontSize   = global.isPCMode and 12 or 18
SUIDefine.anchorPoints      = {[0]={x=0,y=1}, [1]={x=1,y=1}, [2]={x=0,y=0}, [3]={x=1,y=0}, [4]={x=0.5,y=0.5}}
SUIDefine.defaultTextX      = 25
SUIDefine.defaultTextY      = 20
SUIDefine.interval          = 0.167
SUIDefine.defaultBackgroundWidth = 500
SUIDefine.defaultBackgroundHeight = 200
SUIDefine.defaultCUIUnitWidth  = 501
SUIDefine.defaultCUIUnitHeight = 207
SUIDefine.defaultCUIUnitPosX  = 0
SUIDefine.defaultCUIUnitPosY  = 0
SUIDefine.defaultRichTextWidth = 1136

-- ui组件加载状态
SUIDefine.LoadState = 
{
    UNLOAD  = 0,
    LOADING = 1,
    LOADED  = 2
}

return SUIDefine