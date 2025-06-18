local sequFrameAnimLoader = require( "animation/sequFrameAnimLoader" )
local sequFrameAnimLoaderImpSFX = class('sequFrameAnimLoaderImpSFX', sequFrameAnimLoader)

local ANIM_RES_PATH ="anim/effect/"


function sequFrameAnimLoaderImpSFX:ctor()
    sequFrameAnimLoaderImpSFX.super.ctor(self)
end

function sequFrameAnimLoaderImpSFX:init()
    sequFrameAnimLoaderImpSFX.super.init(self)
end

function sequFrameAnimLoaderImpSFX:convertTexFileName( rawAnimID, sex, act )  
    return string.format( "%ssfx_%04d.png", ANIM_RES_PATH, rawAnimID )
end

function sequFrameAnimLoaderImpSFX:convertPlistFileName( rawAnimID, sex, act )  
    return string.format( "%ssfx_%04d.plist", ANIM_RES_PATH, rawAnimID )
end

function sequFrameAnimLoaderImpSFX:convertTexFileNameByIdx( rawAnimID, sex, act, idx )  
    return string.format( "%ssfx_%04d_%d.png", ANIM_RES_PATH, rawAnimID, sex, act, idx )
end

function sequFrameAnimLoaderImpSFX:convertPlistFileNameByIdx( rawAnimID, sex, act, idx ) 
    return string.format( "%ssfx_%04d_%d.plist", ANIM_RES_PATH, rawAnimID, sex, act, idx )
end

function sequFrameAnimLoaderImpSFX:convertFrameName( rawAnimID, sex, act, dir, frameID )
    return string.format( "sfx_%04d_%04d.png", rawAnimID, frameID )
end

return sequFrameAnimLoaderImpSFX

