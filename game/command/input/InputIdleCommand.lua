local InputIdleCommand = class('InputIdleCommand', framework.SimpleCommand)

function InputIdleCommand:ctor()

end

function InputIdleCommand:execute(note)
    local facade            = global.Facade

    local inputProxy        = facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
    local autoProxy         = facade:retrieveProxy( global.ProxyTable.Auto )

    -- auto move begin
    if not inputProxy:GetMoveInterruptFlag() and autoProxy:IsAutoMoveState() then
        facade:sendNotification( global.NoticeTable.AutoMoveEnd )
    end

    -- clear input move data, except for interrupt move
    if not inputProxy:GetMoveInterruptFlag() and inputProxy:GetPathPointSize() > 0 then
        inputProxy:ClearMove()
    end
end

return InputIdleCommand
