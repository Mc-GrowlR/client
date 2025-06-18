local HighlightShaderCommand = class('HighlightShaderCommand', framework.SimpleCommand)

local HighlightGLKey        = "ShaderHighlightColor_noMVP"
local HighlightCoverGLKey   = "ShaderHighlightCover_noMVP"
local HighlightGoldenGLKey  = "ShaderHighlightGoldenColor_noMVP"
local CloneShadowGLKey      = "ShaderCloneShadow_noMVP"
local SlowGLKey             = "ShaderSlowColor_noMVP"
local OutlineGLKey          = "ShaderOutlineColor_noMVP"
local IceGLKey              = "ShaderIceColor_noMVP"
local BlurGLKey             = "ShaderBlurGLKey_noMVP"
local IceAlphaMulitipGLKEY  = "ShaderIceAlphaMulitipColor_noMVP"

function HighlightShaderCommand:ctor()
end

function HighlightShaderCommand:execute(notification)
    local node = notification:getBody()
    local type = notification:getType()

    if not node then
        return
    end

    local GL_P = nil
    
    if type == global.MMO.SHADER_TYPE_HIGHTLIGHT then
        GL_P = self:createHightLightShader()

    elseif type == global.MMO.SHADER_TYPE_HIGHTLIGHT_COVER then
        GL_P = self:createHightLightCoverShader()

    elseif type == global.MMO.SHADER_TYPE_GOLDEN then
        GL_P = self:createGoldenShader()

    elseif type == global.MMO.SHADER_TYPE_SHADOW then
        GL_P = self:createShadowShader()

    elseif type == global.MMO.SHADER_TYPE_SLOW then
        GL_P = self:createSlowShader()

    elseif type == global.MMO.SHADER_TYPE_OUTLINE then
        GL_P = self:createOutlineShader()

    elseif type == global.MMO.SHADER_TYPE_ICE then
        GL_P = self:createIceShader()

    elseif type == global.MMO.SHADER_TYPE_BLUR then
        GL_P = self:createBlurShader()

    elseif type == global.MMO.SHADER_TYPE_ICE_ALPHA_MULTIP then
        GL_P = self:createIceAlphaMulitipShader()

    else
        GL_P = self:createHightLightShader()
    end

    if GL_P then
        node:setGLProgram( GL_P )
    end
end

function HighlightShaderCommand:createHightLightShader()
    local GL_P = global.GLProgramCache:getGLProgram( HighlightGLKey )
    if not GL_P then
        GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/highlight_color_nomvp.frag" )
        global.GLProgramCache:addGLProgram( GL_P, HighlightGLKey )
    end

    return GL_P
end

function HighlightShaderCommand:createHightLightCoverShader()
    local GL_P = global.GLProgramCache:getGLProgram( HighlightCoverGLKey )
    if not GL_P then
        GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/highlight_cover_nomvp.frag" )
        global.GLProgramCache:addGLProgram( GL_P, HighlightCoverGLKey )
    end

    return GL_P
end

function HighlightShaderCommand:createGoldenShader()
    local GL_P = global.GLProgramCache:getGLProgram( HighlightGoldenGLKey )
    if not GL_P then
        GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/highlight_golden_color_nomvp.frag" )
        global.GLProgramCache:addGLProgram( GL_P, HighlightGoldenGLKey )
    end

    return GL_P
end

function HighlightShaderCommand:createShadowShader()
    local GL_P = global.GLProgramCache:getGLProgram( CloneShadowGLKey )
    if not GL_P then
        GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/shadow_blur.fsh" )
        global.GLProgramCache:addGLProgram( GL_P, CloneShadowGLKey )
    end

    return GL_P
end

function HighlightShaderCommand:createSlowShader()
    local GL_P = global.GLProgramCache:getGLProgram( SlowGLKey )
    if not GL_P then
        GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/slow_color_nomvp.frag" )
        global.GLProgramCache:addGLProgram( GL_P, SlowGLKey )
    end

    return GL_P
end

function HighlightShaderCommand:createOutlineShader()
    local GL_P = global.GLProgramCache:getGLProgram( OutlineGLKey )
    if not GL_P then
        GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/highlight_outline_color_nomvp.frag" )
        global.GLProgramCache:addGLProgram( GL_P, OutlineGLKey )
    end

    return GL_P
end

function HighlightShaderCommand:createIceShader()
    local GL_P = global.GLProgramCache:getGLProgram( IceGLKey )
    if not GL_P then
        GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/highlight_ice_color_nomvp.frag" )
        global.GLProgramCache:addGLProgram( GL_P, IceGLKey )
    end

    return GL_P
end

function HighlightShaderCommand:createBlurShader()
    local GL_P = global.GLProgramCache:getGLProgram( BlurGLKey )
    if not GL_P then
        GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/highlight_blur_color_nomvp.frag" )
        global.GLProgramCache:addGLProgram( GL_P, BlurGLKey )
    end

    return GL_P
end

function HighlightShaderCommand:createIceAlphaMulitipShader()
    local GL_P = global.GLProgramCache:getGLProgram( IceAlphaMulitipGLKEY )
    if not GL_P then
        GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/highlight_ice_alpha_mulitip_color_nomvp.frag" )
        global.GLProgramCache:addGLProgram( GL_P, IceGLKey )
    end

    return GL_P
end

return HighlightShaderCommand
