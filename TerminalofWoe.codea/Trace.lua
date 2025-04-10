function failedOrEndedTrace(trace, ttl)
    return { trace = trace or {}, timeToLive = ttl or 1.0 }
end

function boundsForTrace(trace)
    if #trace == 0 then
        return vec2(0, 0), vec2(0, 0)
    end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    
    for _,point in pairs(trace) do
        minX = math.min(minX, point.x)
        minY = math.min(minY, point.y)
        maxX = math.max(maxX, point.x)
        maxY = math.max(maxY, point.y)
    end
    
    return vec2(minX, minY), vec2(maxX, maxY)
end

function drawTrace(trace, alpha)
    strokeWidth(2)
    stroke(118, 212 + 20 * math.random(), 226 + 20 * math.random(), 255 * alpha)
    local prev = trace[1]
    for i = 2,#trace do
        local next = trace[i]
        
        line(prev.x, prev.y, next.x, next.y)
        
        prev = next
    end
end