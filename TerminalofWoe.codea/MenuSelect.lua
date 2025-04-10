MenuSelect = class()

function MenuSelect:init()
    self:layout()
end

function MenuSelect:layout()
    local topOffset = proj.mode.menuTopOffset

    self.refine = Button("REFINE", proj.screenSize.x/4, proj.screenSize.y/2 + topOffset * proj.mode.titleFontScale, 50 * proj.mode.titleFontScale)
    self.refine.selected = true

    topOffset = (topOffset - 50) * proj.mode.titleFontScale
    self.handbook = Button("HANDBOOK", proj.screenSize.x/4, proj.screenSize.y/2 + topOffset, 50 * proj.mode.titleFontScale)

    topOffset = topOffset - 40 * proj.mode.titleFontScale
    self.openFile = Button("↳ Open File", proj.screenSize.x/4, proj.screenSize.y/2 + topOffset, 30 * proj.mode.titleFontScale)
    
    self.complaints = Button("☣ COMPLAINTS", 0, 0, 20 * proj.mode.titleFontScale)
    local w,h = self.complaints:size()
    self.complaints.x = proj.screenSize.x - w - 20 * proj.mode.titleFontScale
    self.complaints.y = proj.screenSize.y - (layout.safeArea.top * (proj.screenSize.x/WIDTH) + h + 20)
    self.complaints.touchPadding = 20

    self.menuButtons = {
        self.refine,
        self.handbook,
    }
end

function MenuSelect:draw()
    pushStyle()
    pushMatrix()

    self.refine:draw()
    self.handbook:draw()

    self.openFile:update()
    self.openFile:draw()    

    self.complaints:draw()        

    textMode(CORNER)
    font("FixedsysExcelsiorIIIb")
    fontSize(30 * proj.mode.titleFontScale)
    fill(118, 222, 236)
    text("Mammalians\nNurtured: " .. math.tointeger(m.mammaliansNurtured()), proj.screenSize.x/4, 25 + proj.mode.mammalianOffset)

    tint(76, 223, 234)
    local w,h = spriteSize(asset.MadeWithCodea)
    sprite(asset.MadeWithCodea, proj.screenSize.x - 60 * proj.mode.madeWithScale, 50 * proj.mode.madeWithScale, 60 * proj.mode.madeWithScale)

    popStyle()
end

function MenuSelect:touched(touch)
    local screenPos = vec2(touch.x, touch.y)
    local worldPos = screenToWorld(screenPos)

    if touch.state == ENDED and touch.tapCount == 1 then
        for i,button in pairs(self.menuButtons) do
            if button:hitTest(worldPos) then
                if button.selected then
                    -- Do nothing
                else
                    for j,button2 in pairs(self.menuButtons) do
                        button2.selected = false
                    end
                    button.selected = true

                    sound(DATA, "ZgBALABAPUBAIX1AtHmfPTXPJTxq7OE+DABAfyhAQEFBQUA7")
                end

                self.openFile.flashRate = 0.1
                tween.delay(0.4, function()
                    self.openFile.flashRate = 0.8
                end)
            end
        end

        if self.openFile:hitTest(worldPos) then
            if self.refine.selected then
                proj.scene = MacroData()
            elseif self.handbook.selected then
                proj.scene = Handbook()             
            end
            
            sound(DATA, "ZgJAUgAqWhgMdxMqVjz4PhGxjD6iL4y+TwAAfzBCPjF2TDYI")
        end

        if self.complaints:hitTest(worldPos) then
            sound(DATA, "ZgJAUgAqWhgMdxMqVjz4PhGxjD6iL4y+TwAAfzBCPjF2TDYI")
            proj.scene = Grievances()
        end

        if worldPos.x > proj.screenSize.x - 100 * proj.mode.madeWithScale and worldPos.y < 100 * proj.mode.madeWithScale then
            sound(DATA, "ZgJAUgAqWhgMdxMqVjz4PhGxjD6iL4y+TwAAfzBCPjF2TDYI")
            proj.scene = Handbook()
        end
    end
end