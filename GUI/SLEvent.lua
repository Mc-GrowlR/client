function EVENT_ON(key, tag, eventCB, widget)
    SL:RegisterLUAEvent(key, tag, eventCB, widget)
end

function EVENT_OFF(key, tag)
    SL:UnRegisterLUAEvent(key, tag)
end