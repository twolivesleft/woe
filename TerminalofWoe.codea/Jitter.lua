function MacroData:updateJitter()
    -- Update timer
    self.time = self.time + DeltaTime
    
    -- Occasionally set new target positions
    local setNewTargets = (self.time % (1/self.newTargetFreq)) < DeltaTime
    
    -- For each cell in the grid
    for i=1, #self.data do
        for j=1, #self.data[i] do
            -- Calculate the screen position of this cell
            local cellPos = worldToScreen(vec2(j * 33, i * 33)) + proj.mode.numbersOffset
            local cellX = cellPos.x
            local cellY = cellPos.y
            
            -- Distance from touch point to this cell
            local dist = vec2(cellX, cellY):dist(self.touchPos)
            
            -- If within jitter radius
            if dist < self.jitterRadius then
                -- More jitter for closer cells
                local jitterScale = 1 - (dist / self.jitterRadius)
                local maxJitter = self.jitterAmount * jitterScale
                
                -- Generate new targets periodically
                if setNewTargets then
                    -- Noise function that creates more natural movement
                    local angle = math.random() * math.pi * 2
                    local radius = math.random() * maxJitter
                    
                    self.jitterTargets[i][j].x = math.cos(angle) * radius
                    self.jitterTargets[i][j].y = math.sin(angle) * radius
                end
                
                -- Smoothly move current position toward target position
                self.jitterCells[i][j].x = self.jitterCells[i][j].x + 
                (self.jitterTargets[i][j].x - self.jitterCells[i][j].x) * self.jitterSpeed
                self.jitterCells[i][j].y = self.jitterCells[i][j].y + 
                (self.jitterTargets[i][j].y - self.jitterCells[i][j].y) * self.jitterSpeed
            else
                -- Smoothly return to original position
                self.jitterTargets[i][j].x = 0
                self.jitterTargets[i][j].y = 0
                
                self.jitterCells[i][j].x = self.jitterCells[i][j].x * (1 - self.jitterSpeed)
                self.jitterCells[i][j].y = self.jitterCells[i][j].y * (1 - self.jitterSpeed)
            end
        end            
    end
end