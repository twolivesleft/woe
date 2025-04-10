MacroData = class()

-- States
local IDLE = State "IDLE"
local CAPTURE = State "CAPTURE"
local CAPTURING = State "CAPTURING"
local REPLENISH = State "REPLENISH"
local FINISHING = State "FINISHING"

function randomHex()
    local hex = ""
    for i = 1, 6 do
        local char = math.random(0, 15)
        if char < 10 then
            hex = hex .. tostring(char)
        else
            hex = hex .. string.char(char + 87) -- Convert to a-f
        end
    end
    return "0x" .. string.upper(hex)
end

function MacroData:init()    
    m.createOrLoadBuckets(proj.mode.buckets)

    self.state = IDLE
    
    -- Add jitter parameters
    self.touchPos = vec2(-10000, -10000)  -- Default position
    self.jitterRadius = 150                  -- How far from cursor jitter affects numbers
    self.jitterAmount = 5                    -- Maximum pixels to jitter
    self.jitterCells = {}                    -- Table to store jitter offsets for each cell
    self.jitterTargets = {}                  -- Target positions for smoother movement
    self.jitterSpeed = 0.1                   -- How fast numbers move toward their target (0-1)
    self.newTargetFreq = 15.6                 -- How often to set new target positions (0-1)
    self.time = 0                            -- Internal timer for jitter changes    
    self.leftOverTrace = {}
    
    self.location = randomHex() .. " : " .. randomHex()

    self:layout()

    self.lastState = self.state.id
end

function MacroData:layout()
    self.surges = {
        createSurge(),
        createSurge()
    }
    
    local rows = math.floor(proj.screenSize.y - proj.mode.padding * 2 - proj.mode.numbersOffset.y - (layout.safeArea.top * (proj.screenSize.x/WIDTH))) / proj.mode.rowSpacing
    local cols = math.floor(proj.screenSize.x - proj.mode.padding * 2 - proj.mode.numbersOffset.x) / proj.mode.rowSpacing
    self.data = {}
    
    -- Initialize the grid of numbers
    for y = 1,rows do
        local row = {}
        
        for x = 1,cols do
            table.insert(row, math.random(0, 9))
        end
        
        table.insert(self.data, row)
    end    

    self.buckets = {}

    local bucketWidth = (proj.screenSize.x - 40 - (proj.mode.bucketSpacing * #m.buckets - 1))/#m.buckets
    for i,mBucket in ipairs(m.buckets) do
        local xPos = (i - 1) * ((proj.screenSize.x - 40)/#m.buckets) + (bucketWidth/2) + 20
        local bucket = Bucket(mBucket, vec2(xPos, 40), vec2(bucketWidth, proj.mode.bucketHeight))
        table.insert(self.buckets, bucket)
    end    

    -- Initialize jitter cells and targets
    for y = 1,rows do
        self.jitterCells[y] = {}
        self.jitterTargets[y] = {}
        for x = 1,cols do
            -- Store x,y offsets for each cell
            self.jitterCells[y][x] = vec2()
            self.jitterTargets[y][x] = vec2()
        end
    end

    self.closeButton = Button("☚ BACK", 20, proj.screenSize.y - 30, 15 * proj.mode.titleFontScale)
    self.closeButton.touchPadding = 20
end

function MacroData:draw()
    self.closeButton:draw()

    if self.state ~= FINISHING then
        pushStyle()

        fontSize(15 * proj.mode.titleFontScale)
        font("FixedsysExcelsiorIIIb")
        fill(158, 241, 255)
        local name = string.upper(m.currentFileName())
        local w,h = textSize(name)

        local progress = m.totalProgress()
        -- Format progress (a 0.0 - 1.0 float) as a percentage
        progress = string.format("%d%%", math.tointeger(math.floor(progress * 100)))
        local pw,ph = textSize(progress)

        text(name, proj.screenSize.x - w - 10, proj.screenSize.y - 30 + h/2)
        text(progress, proj.screenSize.x - pw - w - 40, proj.screenSize.y - 30 + ph/2)

        popStyle()
    end

    if self.state.id ~= self.lastState then
        print("State changed to: " .. self.state.id)
        self.lastState = self.state.id
    end

    -- Update jitter positions
    self:updateJitter()

    for _,s in pairs(self.surges) do
        self:updateSurge(s)
    end

    pushStyle()
    font("AmericanTypewriter")

    -- Draw each number with jitter if in range
    for i,row in pairs(self.data) do
        for j,val in pairs(row) do
            local additionalIntensity = 0.0
            local loc = vec2(j * proj.mode.rowSpacing, i * proj.mode.rowSpacing)
            local offset = vec2()
            local intensity = self:intensityForPosition(loc)
            local jitter = self.jitterCells[i][j] * (intensity + 1.0)
            local key = i * 1000 + j

            if self.state == CAPTURING then                
                if self.state.captured[key] then
                    additionalIntensity = self.state.intensity
                    jitter = jitter * additionalIntensity

                    if self.state.destination ~= nil then                        
                        offset = (self.state.destination - loc) * self.state.progress
                    end
                end             
            end

            if self.state == REPLENISH and self.state.captured[key] then
                goto continue
            end

            if self.state == REPLENISH and self.state.rowToInsert then 
                local containsColumn = false
                for _,col in pairs(self.state.columnsToInsert) do
                    if math.tointeger(col) == j then
                        containsColumn = true
                        goto updateintensity
                    end
                end

                ::updateintensity::

                if self.state.rowToInsert == i and containsColumn then
                    additionalIntensity = 0.4
                end             
            end

            local fall = vec2()
            if self.state == FINISHING and self.state.fall[i] ~= nil and self.state.fall[i][j] ~= nil then
                fall = self.state.fall[i][j]              
                
                -- Add a random downward facing vec2 to fall
                local angle = math.random() * math.pi - math.pi/2
                self.state.fall[i][j] = fall + vec2(0, -1):rotate(angle)
            end

            local fade = 1.0
            if self.state == FINISHING then
                -- Compute fade from self.state.fade (0.0 to 1.0) based on which row (i) we are in
                -- and the total number of rows (rows). For example, row 1 should fade out first
                -- followed by row 2, and so on
                local rowSize = 1 / #self.data
                local rowFade = math.max(math.min(self.state.fade - ((i - 1) * rowSize), rowSize), 0) * #self.data
                fade = 1.0 - rowFade
            end
            
            fill(118, 212 + 20 * intensity, 226 + 20 * intensity, 255 * fade)
            fontSize(math.floor((11 + 20 * math.min(intensity + additionalIntensity, 1.0))*3)/3)
            
            -- Apply jitter offset to position            
            blendMode(ADDITIVE)
            local position = loc + proj.mode.numbersOffset + jitter + offset + fall
            text(tostring(val), position.x, position.y)            

            ::continue::
        end
    end

    popStyle()

    if self.state == CAPTURING and self.state.progress then        
        self.state.progress = math.min(self.state.progress + DeltaTime, 1.0)

        if self.state.progress == 1.0 then                        
            self.buckets[self.state.destinationIndex]:close(1.0)
            sound(SOUND_PICKUP, 29298)
            local captureCount = 0
            local rowsToReplenish = {}
            for _,v in pairs(self.state.captured) do
                if rowsToReplenish[v.y] == nil then
                    rowsToReplenish[v.y] = {}
                end

                table.insert(rowsToReplenish[v.y], v.x)                

                captureCount = captureCount + 1
            end

            local bucketModel = m.buckets[self.state.destinationIndex]
            bucketModel.content = math.min(bucketModel.content + captureCount, bucketModel.capacity)
            m.saveProgress()

            self.state = REPLENISH { rows = rowsToReplenish, captured = self.state.captured }
        end
    end

    if self.state == REPLENISH and self.state.rows and not self.state.rowToInsert then
        -- Get last row
        local lastRow = nil
        local noRowsLeft = true
        for i,row in pairs(self.state.rows) do
            if lastRow == nil then
                lastRow = i
            else
                lastRow = math.min(i, lastRow)
            end

            noRowsLeft = false
        end

        -- Replenish numbers in the last row
        if lastRow ~= nil then
            for i,col in pairs(self.state.rows[lastRow]) do
                local newValue = math.random(0, 9)
                self.data[lastRow][col] = newValue
            end

            self.state.rowToInsert = lastRow
            self.state.columnsToInsert = self.state.rows[lastRow]
            self.state.rowInsertionTime = 0.1

            -- Clear captured numbers that will be inserted
            for _,col in pairs(self.state.columnsToInsert) do
                local key = self.state.rowToInsert * 1000 + col
                self.state.captured[key] = nil
            end

            -- Remove the last row from the rows table   
            self.state.rows[lastRow] = nil         
        end

        -- If there are no more rows to replenish, go back to IDLE state
        if noRowsLeft and not self.state.rowInsertionTime then
            self.state.rows = nil

            if m.isFileComplete() then
                -- Create a table with the same size as the numbers (data) and
                -- populate it with a random, downward facing unit vec2 for each number
                local newData = {}
                for i,row in pairs(self.data) do
                    newData[i] = {}
                    for j,val in pairs(row) do
                        -- Rotate the vector by a random angle but ensure it faces down
                        -- use vec2:rotate(radians)
                        local angle = math.random() * math.pi - math.pi/2
                        newData[i][j] = vec2(0, -1):rotate(angle)                            
                    end
                end

                -- If the file is complete, go to FINISHING state
                self.state = FINISHING { fall = newData, fade = 0.0 }

                m.completeFile()

                tween(3.0, self.state.data, { fade = 1.0 }, tween.easing.linear, function ()
                    proj.scene = Mammalians()
                end)

                for i,bucket in pairs(self.buckets) do
                    tween.delay((i - 1) * 0.5 + 0.1, function ()
                        tween(1.0, bucket, { pos = vec2(bucket.pos.x, bucket.pos.y - 200) })
                    end)                    
                end
            else
                -- Otherwise, go back to IDLE state
                self.state = IDLE
            end
        end
    end

    if self.state == REPLENISH and self.state.rowInsertionTime then
        self.state.rowInsertionTime = self.state.rowInsertionTime - DeltaTime
        if self.state.rowInsertionTime <= 0 then
            self.state.rowToInsert = nil
            self.state.rowInsertionTime = nil
        end
    end
    
    blendMode(NORMAL)
    
    if self.state.trace ~= nil then
        drawTrace(self.state.trace, 1.0)
    end

    if self.leftOverTrace.trace ~= nil then
        drawTrace(self.leftOverTrace.trace, self.leftOverTrace.timeToLive)
        self.leftOverTrace.timeToLive = self.leftOverTrace.timeToLive - (DeltaTime/2.0)
        if self.leftOverTrace.timeToLive <= 0 then
            self.leftOverTrace = {}
        end
    end
    
    if DebugDraw then
        ellipseMode(RADIUS)
        fill(230, 161, 19, 190)
        
        for i,row in pairs(self.data) do
            for j,val in pairs(row) do
                local loc = vec2(j * proj.mode.rowSpacing, i * proj.mode.rowSpacing)
                local intensity = intensityForPosition(loc)
                ellipse(loc.x + proj.mode.numbersOffset.x, loc.y + proj.mode.numbersOffset.y, 10 + 20 * intensity)
            end
        end        
        
        for index,surge in pairs(self.surges) do
            if self.state == CAPTURE and self.state.index == index then
                fill(255, 0, 217, 126)
            else
                fill(255, 0, 0, 126)    
            end
            
            ellipse(surge.pos.x, surge.pos.y, surge.radius)
        end
    end

    for i,bucket in pairs(self.buckets) do
        bucket:draw()
    end

    if self.state ~= FINISHING then
        fill(158, 241, 255)
        rect(0, 0, proj.screenSize.x, 15)
        fontSize(12)
        fill(0)
        font("FixedsysExcelsiorIIIb")
        text(self.location, proj.screenSize.x/2, 7.5)
    end
end

function MacroData:touched(touch)
    local screenPos = vec2(touch.x, touch.y)
    local worldPos = screenToWorld(screenPos)
    
    if self.closeButton:hitTest(worldPos) and touch.tapCount == 1 and touch.state == ENDED then
        proj.scene = MenuSelect()
        sound(SOUND_HIT, 12483)
    end

    -- Update the touch position for jitter effect
    if touch.state == BEGAN or touch.state == CHANGED then
        self.touchPos = screenPos
        
        if self.state == CAPTURE then
            table.insert(self.state.trace, worldPos)
        end
    end

    if self.state == CAPTURING then return end
    
    if touch.state == BEGAN then
        local dist,surge,index = self:closestSurgeDistance(worldPos)
        
        if index ~= nil then
            self.state = CAPTURE { index = index, trace = { worldPos } }
        end
    end

    if touch.state == CHANGED or touch.state == ENDED then
        -- Detect if the trace has left the surge at the index and change to abandoned
        if self.state == CAPTURE and self.state.index ~= nil then
            local dist = self.surges[self.state.index].pos:dist(worldPos)
            if dist > self.surges[self.state.index].radius * 1.5 then
                -- We attach the trace to the state so we can fade it out 
                self.leftOverTrace = failedOrEndedTrace(self.state.trace, 0.3)
                self.state = IDLE
                sound(SOUND_HIT, 12483)
            elseif touch.state == ENDED then
                -- We attach the trace to the state so we can fade it out 
                self.leftOverTrace = failedOrEndedTrace(self.state.trace, 0.3)

                -- Clear the surge
                local surgeIndex = self.state.index
                tween(1.0, self.surges[surgeIndex], { radiusScale = 0.0 }, tween.easing.linear, function ()
                    table.remove(self.surges, surgeIndex)

                    local newSurge = createSurge()
                    newSurge.radiusScale = 0.0
                    table.insert(self.surges, newSurge)

                    tween(1.0, newSurge, { radiusScale = 1.0 })
                end)

                -- Get indexes of numbers within the trace bounds
                -- using: function boundsForTrace(trace)
                local lower,upper = boundsForTrace(self.state.trace)
                local minX = math.ceil((lower.x - proj.mode.numbersOffset.x) / proj.mode.rowSpacing)
                local minY = math.ceil((lower.y - proj.mode.numbersOffset.y) / proj.mode.rowSpacing)
                local maxX = math.floor((upper.x - proj.mode.numbersOffset.x) / proj.mode.rowSpacing)
                local maxY = math.floor((upper.y - proj.mode.numbersOffset.y) / proj.mode.rowSpacing)
                local captured = {}

                for i = minY, maxY do
                    for j = minX, maxX do
                        if self.data[i] ~= nil and self.data[i][j] ~= nil then
                            -- Generate unique integer key from i,j
                            local key = i * 1000 + j
                            captured[key] = vec2(j, i)
                        end
                    end
                end

                -- Get a bucket to store the numbers in
                local nextBucketIndex = m.selectNextBucketIndex()

                if nextBucketIndex == nil then
                    -- No buckets available, do nothing
                    self.state = IDLE
                    return
                end
                
                sound(SOUND_EXPLODE, 30078)
                
                local captureState = { captured = captured, intensity = 0.0, progress = nil, destination = nil }
                self.state = CAPTURING(captureState)
                self.buckets[nextBucketIndex]:open(1.0)

                tween(0.5, captureState, { intensity = 0.8 }, tween.easing.quadInOut, function ()
                    local destination = self.buckets[nextBucketIndex].pos
                    captureState.destination = destination - proj.mode.numbersOffset
                    captureState.progress = 0.0
                    captureState.destinationIndex = nextBucketIndex
                    tween(1.5, captureState, { intensity = 0.0 })
                end)
            end            
        end
    end
    
    if touch.state == ENDED then
        self.touchPos = vec2(-10000,-10000)
        -- self.state = IDLE
    end    
end

function MacroData:intensityForPosition(loc)
    local surgeIntensity = 0.0
    local oloc = loc + proj.mode.numbersOffset
    for i,surge in pairs(self.surges) do
        local dist = surge.pos:dist(oloc)
        if dist < surge.radius then
            surgeIntensity = surgeIntensity + (1.0 - math.min(dist / surge.radius, 1.0))
        end
    end
    
    local noiseScale = 100.0
    local intensity = (noise(loc.x/noiseScale + (self.time/3.0), loc.y/noiseScale + (self.time/3.0)) + 1.0)/2.0
    return intensity * surgeIntensity * proj.mode.intensityScaleFactor
end

function directionToDestination(pos, dest)
    local dir = dest - pos
    local dist = dir:len()
    if dist > 0 then
        return dir:normalize()
    else
        return vec2(0, 0)
    end
end