local spaceOn = false
local shiftOn = false
local spaceStay = false

local function flagCheck(flag)
    local mods = {'fn', 'cmd', 'ctrl', 'alt', 'shift'}
    local modifier = false
    for i, value in ipairs(mods) do
        if flag[value] then modifier = true end
    end
    return modifier
end

local function terminate()
    spaceOn = false
    shiftOn = false
    spaceStay = false
end

local function sandsEvent(event)
    local c = event:getKeyCode()
    local f = event:getFlags()
    if event:getType() == hs.eventtap.event.types.keyDown then
        if c == 49 then
            if flagCheck(f) == false then
                if spaceOn == false and shiftOn == false then
                    spaceOn = true
                    spaceStay = true
                    event:setKeyCode(-1)
                elseif spaceOn and spaceStay then
                    event:setKeyCode(-1)
                else
                    terminate()
                end
            end
        elseif spaceOn and c ~= 49 then
            if flagCheck(f) == false then
                shiftOn = true
                event:setFlags({shift=true})
            end
        end
    elseif event:getType() == hs.eventtap.event.types.keyUp then
        if c == 49 then
            if spaceOn and shiftOn == false then
                spaceStay = false
                hs.eventtap.keyStroke({}, "space", 5000)
            else
                terminate()
            end
        end
    end
end
eventtap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, sandsEvent)
eventtap:start()
