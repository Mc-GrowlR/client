GUINetwork = {}

local cjson  = require("cjson")
local slen   = string.len
local ssplit = string.split

-- FIXME: server unsupport lua form

-- function GUINetwork:RegisterMsgHandlerAfterEnterWorld()
--     
--     local msgType = global.MsgType
--     LuaRegisterMsgHandler( msgType.MSG_SC_GUI_PROTO_HELPER_RESPONSE, handler( self, self.handle_MSG_SC_GUI_PROTO_HELPER_RESPONSE ) )
-- end

-- local function loadLua(param)
--     if not param or param == "" then
--         SL:Print("[GUI ERROR] lib996:showformwithcontent luastring is empty")
--         return false
--     end

--     local luaFunc = load(param)
    
--     if not luaFunc then
--         SL:Print("[GUI ERROR] lib996:showformwithcontent luastring load error", param)
--         return false
--     end

--     luaFunc()

--     return true
-- end

-- local function loadGUIForm(filename, param)
--     -- parse param
--     local winName = nil
--     local slices = nil
--     SL.FormParam = {}
--     if param and param ~= "" then
--         slices = ssplit(param, "#")

--         if not slices[1] then
--             SL:Print("[GUI ERROR] lib996:showformwithcontent load form error, can't find dialog", param)
--             return false
--         end

--         -- dialog name
--         winName = table.remove(slices, 1)

--         -- params
--         for i, v in ipairs(slices) do
--             SL.FormParam[i] = v
--         end
--     end

--     -- close, if open
--     local window = GUI:GetWindow(nil, winName)
--     if window then
--         GUI:Win_Close(window)
--     end
    
--     -- win open
--     GUI:Win_Open(filename)
-- end

-- function GUINetwork:handle_MSG_SC_GUI_PROTO_HELPER_RESPONSE( msg )
--     local jsonData = ParseRawMsgToJson(msg)
--     if not jsonData then
--         SL:Print("[GUI ERROR] lib996:showformwithcontent, json data error")
--         return
--     end

--     local filename = jsonData.filename
--     local param = jsonData.param

--     -- 打印，方便查看
--     SL:Print("[GUI LOG] lib996:showformwithcontent: ", filename, param)        

--     -- 执行lua代码
--     if not filename or filename == "" then
--         loadLua(param)
--     else
--         loadGUIForm(filename, param)
--     end
-- end

-- function GUINetwork:SendMsg( filename, funcName, param )
--     if not filename or filename == "" then
--         SL:Print("[GUI ERROR] SL:SubmitForm filename is empty", filename)
--         return
--     end
--     if not funcName or funcName == "" then
--         SL:Print("[GUI ERROR] SL:SubmitForm funcName is empty", funcName)
--         return
--     end

--     -- param  #隔开
--     local jsonData = 
--     {
--         filename = filename,
--         funcName = funcName,
--         param = param,
--     }
-- 	local jsonStr = cjson.encode(jsonData)
-- 	LuaSendMsg( global.MsgType.MSG_CS_GUI_PROTO_HELPER_REQUEST, 0, 0, 0, 0, jsonStr, slen( jsonStr ) )
-- end
