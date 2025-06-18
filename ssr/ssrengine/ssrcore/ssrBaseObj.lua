local ssrBaseObj = class("ssrBaseObj")
ssrBaseObj.NAME = "ssrBaseObj"

function ssrBaseObj:ctor()
    ssr._registerObj(self)
end

function ssrBaseObj:onEvent(eventName, eventData)
end

return ssrBaseObj