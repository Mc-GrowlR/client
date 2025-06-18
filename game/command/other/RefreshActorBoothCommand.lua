local RefreshActorBoothCommand = class('RefreshActorBoothCommand', framework.SimpleCommand)
local Border            = 28
local ContentWidth      = 200
local OffY              = 60
local CornerOffY        = 96.5
local contentColorID    = 255
local fontSizeMob       = SL:GetMetaValue("GAME_DATA","sceneFontSize") or SL:GetMetaValue("GAME_DATA","SCENE_FONT_SIZE")
local fontSizeWin       = SL:GetMetaValue("GAME_DATA","sceneFontSize_pc") or SL:GetMetaValue("GAME_DATA","SCENE_FONT_SIZE_PC")
local fontSize          = global.isWinPlayMode and fontSizeWin or fontSizeMob

function RefreshActorBoothCommand:ctor()
end

function RefreshActorBoothCommand:execute(notification)
    local data    = notification:getBody()
    local actorID = data.actorID
    local actor = data.actor
    if not actor then
        return
    end

    global.HUDManager:RemoveHUD(actorID, global.MMO.HUD_TYPE_SPRITE, global.MMO.HUD_SPRITE_BOOTH_NAME_BG)
    global.HUDManager:RemoveHUD(actorID, global.MMO.HUD_TYPE_TIPS, global.MMO.HUD_LABEL_BOOTH_NAME)

    if not actor:IsStallStatus() then
        return nil
    end
    if SL:GetMetaValue("SETTING_ENABLED", SLDefine.SETTINGID.SETTING_IDX_IGNORE_STALL) == 1 then 
        return nil
    end
    local spriteOffY    = OffY
    local textOffY      = OffY + 5
    local cornerOffY    = CornerOffY

    -- content
    local hudName = global.HUDManager:GetHUD(actorID, global.MMO.HUD_TYPE_TIPS, global.MMO.HUD_LABEL_BOOTH_NAME)
    if not hudName then
        hudName = global.HUDManager:CreateHUD(actorID, global.MMO.HUD_TYPE_TIPS, global.MMO.HUD_LABEL_BOOTH_NAME, cc.p(0, textOffY + Border * 0.5))
    end
    global.HUDManager:SetHUDOffset(actorID, global.MMO.HUD_TYPE_TIPS, global.MMO.HUD_LABEL_BOOTH_NAME, cc.p(0, textOffY + Border * 0.5))
    
    local boothName = actor:GetStallName()
    local colorID   = tonumber( CHECK_SERVER_OPTION(global.MMO.SERVER_STALL_COLOR) ) or contentColorID
    hudName:removeAllChildren()
    local RichTextHelp = requireUtil("RichTextHelp")
    local textName = RichTextHelp:CreateRichTextWithXML(boothName, ContentWidth, fontSize, GET_COLOR_BYID(colorID))
    hudName:addChild(textName)
    textName:setAnchorPoint(cc.p(0.5, 0))
    textName:formatText()

    -- bg
    local textSize = textName:getContentSize()
    local hudSprite = global.HUDManager:GetHUD(actorID, global.MMO.HUD_TYPE_SPRITE, global.MMO.HUD_SPRITE_BOOTH_NAME_BG)
    if not hudSprite then
        hudSprite = global.HUDManager:CreateHUD(actorID, global.MMO.HUD_TYPE_SPRITE, global.MMO.HUD_SPRITE_BOOTH_NAME_BG, cc.p(0, spriteOffY + Border * 0.5))
        hudSprite:setAnchorPoint(cc.p(0.5, 0))
        hudSprite:setTexture(global.MMO.PATH_RES_PUBLIC .. "1900000676.png")
        hudSprite:setContentSize(cc.size(textSize.width + 20, textSize.height + 10))
    end
    global.HUDManager:SetHUDOffset(actorID, global.MMO.HUD_TYPE_SPRITE, global.MMO.HUD_SPRITE_BOOTH_NAME_BG, cc.p(0, spriteOffY + Border * 0.5))

    -- refresh actor position
    local pos = actor:getPosition()
    actor:setPosition(pos.x, pos.y)
end

return RefreshActorBoothCommand