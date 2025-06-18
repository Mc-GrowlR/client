local ChangeResolutionCommand = class('ChangeResolutionCommand', framework.SimpleCommand)

function ChangeResolutionCommand:ctor()
    self.director     = global.Director
    self.glView       = self.director:getOpenGLView();
end

function ChangeResolutionCommand:execute(notification)
    local data = notification:getBody()
    -- debug
    -- print( "ChangeResolutionCommand,Size:" .. data.size.width .. "," .. data.size.height .. ",Type:" .. data.rType )
    self.glView:setDesignResolutionSize( data.size.width, data.size.height, data.rType );
end


return ChangeResolutionCommand
