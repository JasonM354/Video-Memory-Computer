function stackadd()
    stackindex = stackindex + 1
    stack[stackindex] = 0
end

function stackincrement()
    stack[stackindex] = stack[stackindex] + 1
end

function stackdecrement()
    stack[stackindex] = stack[stackindex] - 1
end

function stackcombine()
    stack[stackindex - 1] = stack[stackindex] + stack[stackindex - 1]
    stack[stackindex] = nil
    stackindex = stackindex - 1
end

function pop(x, y)
    x, y = tonumber(x), tonumber(y)
    if x and y and x < 800 and x > -1 and y < 600 and y > -1 then
        heap[x] = heap[x] or {}
        heap[x][y] = stack[stackindex]
    end
end

function push(x, y)
    x, y = tonumber(x), tonumber(y)
    if x and y and x < 800 and x > -1 and y < 600 and y > -1 then
        stackindex = stackindex + 1
        stack[stackindex] = heap[x] and heap[x][y] or 0
    end
end

function heapwrite()
    if stackindex >= 3 then
        local value = stack[stackindex]
        local x = stack[stackindex - 1]
        local y = stack[stackindex - 2]
        if x and y and x < 800 and x > -1 and y < 600 and y > -1 then
            heap[x] = heap[x] or {}
            heap[x][y] = value
        end
    end
end

function heapread()
    if stackindex >= 2 then
        local x = stack[stackindex]
        local y = stack[stackindex - 1]
        local value = 0
        if x and y and x < 800 and x > -1 and y < 600 and y > -1 then
            value = heap[x] and heap[x][y] or 0
        end
        stackindex = stackindex + 1
        stack[stackindex] = value
    end
end

function drop()
    if stackindex > 0 then
        stack[stackindex] = nil
        stackindex = stackindex - 1
    end
end

function dupe()
    if stackindex > 0 then
        stackindex = stackindex + 1
        stack[stackindex] = stack[stackindex - 1]
    end
end

function pause(num)
    coroutine.yield(num)
end

function label(code)
    local index = 1
    local length = #code
    while index <= length do
        local char = code:sub(index, index)

        if char == ":" then
            local closeindex = code:find(":", index + 1)
            if closeindex then
                local identifier = code:sub(index + 1, closeindex - 1)
                bookmark[identifier] = closeindex
            end
        end
        index = index + 1
    end
end

function run(code)
    local index = 1
    local length = #code
    while index <= length do
        local char = code:sub(index, index)

        if char == "^" then
            stackadd()
        elseif char == "+" then
            stackincrement()
        elseif char == "-" then
            stackdecrement()
        elseif char == "=" then
            stackcombine()
        elseif char == "o" then
            drop()
        elseif char == "*" then
            dupe()
        elseif char == "!" then
            local closeindex = code:find("!", index + 1)
            if closeindex then
                local time = tonumber(code:sub(index + 1, closeindex - 1))
                if time and time > 0 then
                    pause(time)
                end
                index = closeindex
            end
        elseif char == ":" then
            local closeindex = code:find(":", index + 1)
            if closeindex then
                index = closeindex
            end
        elseif char == ";" then
            local closeindex = code:find(";", index + 1)
            local identifier = closeindex and code:sub(index + 1, closeindex - 1) or nil
            if stack[stackindex] ~= 0 and identifier and bookmark[identifier] ~= nil then
                index = bookmark[identifier]
            elseif closeindex then
                index = closeindex
            end
            stackindex = stackindex - 1
        elseif char == "[" then
            local closeindex = code:find("]", index + 1)
            if closeindex then
                local inner = code:sub(index + 1, closeindex - 1)
                if inner == "" then
                    heapwrite()
                else
                    local breakindex = code:find(",", index)
                    if breakindex and breakindex < closeindex then
                        local x = code:sub(index + 1, breakindex - 1)
                        local y = code:sub(breakindex + 1, closeindex - 1)
                        pop(x, y)
                    end
                end
                index = closeindex
            end
        elseif char == "(" then
            local closeindex = code:find(")", index + 1)
            if closeindex then
                local inner = code:sub(index + 1, closeindex - 1)
                if inner == "" then
                    heapread()
                else
                     local breakindex = code:find(",", index)
                    if breakindex and breakindex < closeindex then
                        local x = code:sub(index + 1, breakindex - 1)
                        local y = code:sub(breakindex + 1, closeindex - 1)
                        push(x, y)
                    end
                end
                index = closeindex
            end
        end
        index = index + 1
    end
end

function love.load()
    stack = {}
    stackindex = 0
    heap = {}
    bookmark = {}
    waittime = 0

    local code = love.filesystem.read("samplecode.vc")
    if code then
        label(code)
        co = coroutine.create(function() run(code) end)
    end
end

function love.update(dt)
    if co and coroutine.status(co) ~= "dead" then
        if waittime > 0 then
            waittime = waittime - dt
        else
            local ok, w = coroutine.resume(co)
            if not ok then
                error(w)
            end
            waittime = (w or 0) / 1000
        end
    end
end

function love.draw()
    xStart = 400
    yStart = 300
    xSpacing = 40
    ySpacing = 30

    for x = 0, 799 do
        if heap[x] then
            for y = 0, 599 do
                if heap[x][y] ~= nil then
                    love.graphics.setColor(heap[x][y] / 100, heap[x][y] / 100, heap[x][y] / 100)
                    love.graphics.rectangle("fill", x, y, 1, 1)
                end
            end
        end
    end
end
