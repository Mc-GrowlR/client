local config   = {}
local platform = cc.Application:getInstance():getTargetPlatform()




--------------------------- Bugly --------------------------------
if cc.PLATFORM_OS_ANDROID == platform then
    config.BuglyID    = "21409c415f"
    config.BuglyDebug = true
end

return config
