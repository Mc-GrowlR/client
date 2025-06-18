local BaseLayer = requireLayerUI("BaseLayer")
local NPCTalkLayer = class("NPCTalkLayer", BaseLayer)

local SUILoader = nil

function NPCTalkLayer:ctor()
    NPCTalkLayer.super.ctor(self)

    SUILoader = require("sui/SUILoader").new()
    self.trunk = nil
    self.swidgets = nil
    self.background = nil
end

function NPCTalkLayer.create()
    local ui = NPCTalkLayer.new()
    if ui and ui:Init() then
        return ui
    end

    return nil
end

function NPCTalkLayer:Init()
    return true
end

function NPCTalkLayer:loadTalkContent()
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local talkData = NPCProxy:GetCurrentNPCTalkData()
    local backgroundData = NPCProxy:GetCurrentBackground()

    local function callback(cdata)
        if string.find(cdata.Act, "@@") then
            dump(cdata)
            local inputParam = {
                {
                    prefix = "N",
                    key = "@@INPUTINTEGER",
                },
                {
                    prefix = "S",
                    key = "@@INPUTSTRING",
                }
            }
            local function callback(atype, t)
                if atype == 1 then
                    local data = string.split(cdata.Act, "_")
                    local _, _, checkType = string.find(cdata.Act, "_+(%d)")
                    checkType = tonumber(checkType)
                    local act = string.gsub(data[1], "%(.-%)", "")
                    local inputID = 1
                    for _, v in ipairs(inputParam) do
                        if string.find(string.upper(act), v.key) then
                            local ret = string.gsub(string.upper(act), v.key, "")
                            inputID = v.prefix .. ret
                        end
                    end

                    local tdata       = {}
                    tdata.UserID      = talkData.npcID
                    tdata.Act         = string.sub(act, 2, string.len(act))
                    tdata.commonInput = t.editStr or ""
                    tdata.inputID     = inputID
                    local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
                    local function handle_Func(state, str, risk_param)
                        if not str then
                            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1006))
                            return
                        end
                
                        tdata.commonInput = str
                        NPCProxy:ExecuteWithCommonInput(tdata)
                    end
                    if string.len(tdata.commonInput) > 0 then
                        if checkType and checkType == 1 then -- 普通检测敏感词(聊天)
                            if IsForbidSay(true) then
                                return
                            end
                            SensitiveWordProxy:fixSensitiveTalkAddFilter(tdata.commonInput, handle_Func, nil)
                        elseif checkType and checkType == 2 then -- 昵称类
                            if IsForbidName(true) then
                                return
                            end
                            SensitiveWordProxy:IsHaveSensitiveAddFilter(tdata.commonInput, handle_Func)
                        else
                            NPCProxy:ExecuteWithCommonInput(tdata)
                        end
                    else
                        NPCProxy:ExecuteWithCommonInput(tdata)
                    end
                end
            end

            local _, _, inputTips = string.find(cdata.Act, ".+%((.+)%)")
            local inputMode = string.find(string.upper(cdata.Act), inputParam[1].key) and 2 or 0
            local data      = {}
            data.str        = inputTips or GET_STRING(1085)
            data.btnType    = 2
            data.showEdit   = true
            data.editParams = { inputMode = inputMode }
            data.callback   = callback
            global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)

        else
            local cdata = clone(cdata)
            cdata.UserID = talkData.npcID

            NPCProxy:ExecuteWithJsonData(cdata)
        end
    end

    local function closeCB()
        local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
        npcProxy:Cleanup()
    end

    local function loadCompleteCB()
        dump("加载完成")
        global.Facade:sendNotification(global.NoticeTable.GuideEventBegan, { name = "GUIDE_NPC_TALK_LOAD_SUCCESS" })
        global.Facade:sendNotification(global.NoticeTable.NPCTalkLayer_Open_Success)
        global.mouseEventController:ClearLastInsideNode()
    end

    local needAdd = self.trunk == nil
    local ext = { background = backgroundData, lastTrunk = self.trunk, lastBackground = self.background, loadCompleteCB = loadCompleteCB, parentNode = needAdd and self or nil, npcLayer = self }
    self.trunk, self.background = SUILoader:load(talkData.content, callback, closeCB, ext)
end

return NPCTalkLayer