local InputCorpseCommand = class('InputCorpseCommand', framework.SimpleCommand)

function InputCorpseCommand:ctor()

end

function InputCorpseCommand:execute(note)
    local facade   = global.Facade
    local data     = note:getBody()
    local corpseID      = data.corpseID
    local priority      = data.priority
    if not corpseID then
        return nil
    end

    local inputProxy    = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    inputProxy:SetCorpseID(corpseID)
end

return InputCorpseCommand
