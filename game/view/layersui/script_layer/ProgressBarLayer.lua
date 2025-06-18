local BaseLayer = requireLayerUI("BaseLayer")
local ProgressBarLayer = class("ProgressBarLayer", BaseLayer)

function ProgressBarLayer:ctor()
    ProgressBarLayer.super.ctor(self)

    self._data = nil
end

function ProgressBarLayer.create(...)
    local layer = ProgressBarLayer.new()
    if layer:Init(...) then
        return layer
    else
        return nil
    end
end

function ProgressBarLayer:Init(data)
    return true
end

function ProgressBarLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PROGRESS_BAR)
    ProgressBar.main(data)

    self._data = data or {}
end 

function ProgressBarLayer:onActionBegin(actor, act)
    local dis = self._data and tonumber(self._data.dis) or 0
    if dis > 0 then
        if self._data.NoDisJump == 1 and global.MMO.ACTION_STUCK == act then --受击时不中断(后仰动作)
            return
        end
        if dis == 2 and global.MMO.ACTION_SKILL == act then --施法时监听部分技能是否中断
            return
        end
        global.Facade:sendNotification( global.NoticeTable.Layer_ProgressBar_Close )
    end
end

return ProgressBarLayer
