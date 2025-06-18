local BaseLayer = requireLayerUI("BaseLayer")
local darklayer = class("darklayer", BaseLayer)
local darkShader = "darkShader"
function darklayer:ctor()
    darklayer.super.ctor(self)
end

function darklayer.create(...)
    local ui = darklayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function darklayer:Init(data)
    if SL:GetMetaValue("GAME_DATA", "dark") ~= 1 then
        return true
    end
    self._glProgram = global.GLProgramCache:getGLProgram( darkShader )
    if not self._glProgram then
        self._glProgram = cc.GLProgram:createWithFilenames( "shader/dark.vert", "shader/dark.frag" )
        global.GLProgramCache:addGLProgram( self._glProgram, darkShader )
    end

    
    self.glNode = gl.glNodeCreate()

    local rootNode = global.sceneGraphCtl:GetGameWorldRoot()
    rootNode:addChild(self.glNode)
    self.glNode:setCameraMask(cc.CameraFlag.USER1, true)
    self.glNode:registerScriptDrawHandler(handler(self,self.onDraw))
    return true
end

function darklayer:onDraw(transform, transformUpdated)
    local DarkLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
    local curState = DarkLayerProxy:getCurState()
    if curState == DarkLayerProxy.STATE.daytime then 
        return 
    end
    local camera = global.gameMapController:GetViewCamera()
    if not camera then
        return
    end
    -- self.glNode:setPosition(camera:getPosition())
    local gameWorldPos =  cc.p(camera:getPosition())
    -- dump(gameWorldPos,"gameWorldPos___")
    self._glProgram:use()
    self._glProgram:setUniformsForBuiltins()
    local size = cc.Director:getInstance():getWinSize()
    local viewScaleX, viewScaleY = CalcCameraZoom( camera )
    local vertices = { 
        gameWorldPos.x + size.width*viewScaleX/2, gameWorldPos.y - size.height*viewScaleY/2,
        gameWorldPos.x + size.width*viewScaleX/2, gameWorldPos.y + size.height*viewScaleY/2, 
        gameWorldPos.x - size.width*viewScaleX/2, gameWorldPos.y - size.height*viewScaleY/2,
        gameWorldPos.x - size.width*viewScaleX/2, gameWorldPos.y + size.height*viewScaleY/2, 
    }
    local vao = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, vao)
    gl.bufferData(gl.ARRAY_BUFFER, table.getn(vertices), vertices, gl.STATIC_DRAW)
    gl.bindBuffer(gl.ARRAY_BUFFER, 0)
    ------------render-------------
    
    local nodeData = global.darkNodeManager:getAllNodes()
    local nodeInfo = {}
    for i, v in pairs(nodeData) do
        table.insert(nodeInfo,v.x or 0)
        table.insert(nodeInfo,v.y or 0)
        table.insert(nodeInfo,v.r or 0)
        table.insert(nodeInfo,v.w or 0)
    end
    -- dump(nodeInfo,"nodeInfo___")
    local opacity = DarkLayerProxy:getOpacity()
    local nodenum = global.darkNodeManager:getNodeNums()
    local opacityLocation = gl.getUniformLocation(self._glProgram:getProgram(), "opacity")
    self._glProgram:setUniformLocationF32(opacityLocation,opacity)
    local nodenumLocation = gl.getUniformLocation(self._glProgram:getProgram(), "nodenum")
    self._glProgram:setUniformLocationI32(nodenumLocation, nodenum)
    local nodeinfoLocation = gl.getUniformLocation(self._glProgram:getProgram(), "nodeinfo")
    self._glProgram:setUniformLocationWithMatrix2fv(nodeinfoLocation,nodeInfo ,nodenum)
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA )
    gl.glEnableVertexAttribs(cc.VERTEX_ATTRIB_FLAG_POSITION)
    gl.bindBuffer(gl.ARRAY_BUFFER, vao)
    gl.vertexAttribPointer(cc.VERTEX_ATTRIB_POSITION, 2, gl.FLOAT, false, 0, 0);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
    gl.bindBuffer(gl.ARRAY_BUFFER, 0)
    gl.deleteBuffer(vao)
end


return darklayer