local BaseUIMediator = requireMediator("BaseUIMediator")
local ssrGUIMediator = class("ssrGUIMediator", BaseUIMediator)
ssrGUIMediator.NAME = "ssrGUIMediator"

function ssrGUIMediator:ctor(mediatorName)
    ssrGUIMediator.NAME = string.format("%s_GUIMediator", mediatorName or "") 
    ssrGUIMediator.super.ctor( self, mediatorName )
end

return ssrGUIMediator