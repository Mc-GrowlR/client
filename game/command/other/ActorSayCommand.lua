local ActorSayCommand = class('ActorSayCommand', framework.SimpleCommand)
local Border          = 28
local ContentWidth    = 200
local OffY            = 60
local CornerOffY      = 96.5
local contentColorID  = 255
local ChatParseHelp = requireView("layersui/chat_layer/ChatParseHelp")
function ActorSayCommand:ctor()
end


local function rmv_bg_callback( sender, delta )
    local actorID = sender:getName()
    sender:stopAllActions()
    global.HUDManager:RemoveHUD( actorID, global.MMO.HUD_TYPE_SPRITE, global.MMO.HUD_SPRITE_TEXT_BG )
end

local function rmv_bg_corner_callback( sender, delta )
    local actorID = sender:getName()
    sender:stopAllActions()
    global.HUDManager:RemoveHUD( actorID, global.MMO.HUD_TYPE_SPRITE, global.MMO.HUD_SPRITE_TEXT_BG_CORNER )
end

local function rmv_content_callback( sender, delta )
    local actorID = sender:getName()
    sender:stopAllActions()
    sender:removeAllChildren()
    global.HUDManager:RemoveHUD( actorID, global.MMO.HUD_TYPE_TIPS, global.MMO.HUD_TEXT_SPEECH )
end
-- 普通
function ActorSayCommand:createNormalElements(msg)
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local emconfig  = ChatProxy:GetEmoji()
    local fontPath      =  global.MMO.PATH_FONT_HUD2
    local elements  = {}
    local fontSize = 12
    local outline = cc.Color4B.BLACK
    local outlineSize = 1
    msg = string.gsub(msg, "\n", " ")
    while string.len(msg) > 0 do
        local findHead = nil
        local findReplace = nil
        local findSfxId = nil

        for _, v in pairs(emconfig) do
            local replace   = v.replace
            local sfxid     = v.sfxid
            
            if not v.type or v.type == 0 then
                local head, _ = string.find(msg, replace)
                if head then
                    if findHead then
                        if findHead > head then
                            findHead = head
                            findReplace = replace
                            findSfxId = sfxid
                        end
                    else
                        findHead = head
                        findReplace = replace
                        findSfxId = sfxid
                    end
                end
            end

        end
        if findHead and findReplace and findSfxId then
            -- 表情前面的文本截取出来
            local str = string.sub(msg, 1, findHead - 1)
            if str and string.len(str) > 0 then
                local element = ccui.RichElementText:create(0, cc.Color3B.WHITE, 255, str, fontPath, fontSize, 32,"",outline,outlineSize)
                table.insert(elements, element)
            end

            -- 表情字符串替换为空
            msg = string.sub(msg, findHead, -1)
            msg = string.gsub(msg, findReplace, "", 1)

            -- 创建一个表情
            local layout = ccui.Layout:create()
            layout:setContentSize(35, 35)
            layout:registerScriptHandler( function(state)
                if state == "enter" then
                    local emojiSfx = global.FrameAnimManager:CreateSFXAnim(findSfxId)
                    layout:removeAllChildren()
                    layout:addChild(emojiSfx)
                    emojiSfx:setPosition(35/2, 35/2-5)
                    emojiSfx:setScale(0.7)
                    emojiSfx:Play(0, 0, true)
                end
            end )
            local element = ccui.RichElementCustomNode:create(0, cc.Color3B.WHITE, 255, layout)
            table.insert(elements, element)
        else
            if msg and string.len(msg) > 0 then
                local element = ccui.RichElementText:create(0, cc.Color3B.WHITE, 255, msg, fontPath, fontSize, 32,"",outline,outlineSize)
                table.insert(elements, element)
                msg = ""
            end
        end
    end
    return elements
end

function ActorSayCommand:execute(notification)
    local data    = notification:getBody()
    local actorID = data.SendId
    local actor   = global.actorManager:GetActor( actorID )
    if not actor then
        return 
    end
    local textOffY   = OffY
    local cornerOffY = CornerOffY
-----------------
    local content = string.format("%s:%s", data.SendName, data.Msg)
    local telements = self:createNormalElements(content)
    -- 填充
    local richText = ccui.RichText:create()
    for _, v in ipairs(telements) do
        richText:pushBackElement(v)
    end
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(ContentWidth, 0)
    richText:setAnchorPoint(0.5, 0)
    richText:setPosition(0, 0)
    richText:formatText()
    
-------------------
    
    local hudSpeech = global.HUDManager:GetHUD( actorID, global.MMO.HUD_TYPE_TIPS, global.MMO.HUD_TEXT_SPEECH )
    if not hudSpeech then
        hudSpeech = global.HUDManager:CreateHUD( actorID, global.MMO.HUD_TYPE_TIPS, global.MMO.HUD_TEXT_SPEECH, cc.p( 0, textOffY + Border * 0.5 ) )
        -- hudSpeech:enableOutline( cc.Color4B.BLACK, 1 )
        -- hudSpeech:setMaxLineWidth( ContentWidth )
        -- hudSpeech:setAnchorPoint( cc.p( 0.5, 0 ) )
        -- hudSpeech:setColor(GET_COLOR_BYID_C3B(contentColorID))
    else
        global.HUDManager:SetHUDOffset( actorID, global.MMO.HUD_TYPE_TIPS, global.MMO.HUD_TEXT_SPEECH, cc.p( 0, textOffY + Border * 0.5 ) )
    end
    -- hudSpeech:setString( content )
    hudSpeech:stopAllActions()
    hudSpeech:removeAllChildren()
    hudSpeech:addChild(richText)
    refPositionByParent(richText)
    -- run action
    local duration = tonumber( data.time ) or 4.5
    self:createAction( hudSpeech, actorID, rmv_content_callback, duration )

    -- refresh actor position
    local pos = actor:getPosition()
    actor:setPosition( pos.x, pos.y )
end

function ActorSayCommand:createAction( node, actorID, callback, duration )
    node:stopAllActions()
    node:setName( actorID )

    local aDelay   = cc.DelayTime:create( duration )

    node:runAction( cc.Sequence:create( aDelay, cc.CallFunc:create( callback ) ) )
end


return ActorSayCommand
