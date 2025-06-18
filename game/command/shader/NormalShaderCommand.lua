local NormalShaderCommand = class('NormalShaderCommand', framework.SimpleCommand)

function NormalShaderCommand:ctor()
end

function NormalShaderCommand:execute(notification)
    local data = notification:getBody()
    local node = data.node
    if not node then
        return
    end

    local GL_P = global.GLProgramCache:getGLProgram( "ShaderPositionTextureColor_noMVP" )
    if GL_P then
        if tolua.type(node) == "ccui.Button" then
            local normal = node:getRendererNormal()
            local clicked = node:getRendererClicked()
            local disabled = node:getRendererDisabled()
            
            if normal then
                normal:setGLProgram(GL_P)
            end

            if clicked then
                clicked:setGLProgram(GL_P)
            end

            if disabled then
                disabled:setGLProgram(GL_P)
            end
        elseif tolua.type(node) == "ccui.LoadingBar" or tolua.type(node) == "ccui.TextAtlas" then
            local renderer = node:getVirtualRenderer()
            if renderer then
                renderer:setGLProgram(GL_P)
            end
            
        elseif tolua.type(node) == "ccui.CheckBox" then
            local renderer1 = node:getRendererBackground()
            local renderer2 = node:getRendererBackgroundSelected()
            local renderer3 = node:getRendererBackgroundDisabled()
            local renderer4 = node:getVirtualRenderer()
            local renderer5 = node:getRendererFrontCrossDisabled()
            local renderer6 = node:getRendererFrontCross()

            if renderer1 then
                renderer1:setGLProgram(GL_P)
            end

            if renderer2 then
                renderer2:setGLProgram(GL_P)
            end

            if renderer3 then
                renderer3:setGLProgram(GL_P)
            end

            if renderer4 then
                renderer4:setGLProgram(GL_P)
            end

            if renderer5 then
                renderer5:setGLProgram(GL_P)
            end

            if renderer6 then
                renderer6:setGLProgram(GL_P)
            end
        else
            node:setGLProgram( GL_P );
        end
    end
end


return NormalShaderCommand
