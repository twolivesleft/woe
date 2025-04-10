Handbook = class()

function Handbook:init()
    self.copy1 = "This application was authored within Codea — the sanctioned environment for interactive creation on iPhone and iPad"
    self.copy2 = "You are permitted to examine and modify this Terminal should you possess Codea. Tap below to import the full project directly"
    self.copy3 = "If Codea is not yet among your tools, you may obtain it from the App Store"

    self:layout()
end

function debugRect(x,y,w,h)
    -- pushStyle()
    -- fill(255,0,0, 128)
    -- rect(x, y, w, h)
    -- popStyle()
end

function Handbook:layout()
    self.closeButton = Button("╳", 20, proj.screenSize.y - 50, 30 * proj.mode.titleFontScale)
    self.import = Button("↳ Import into Codea", 0, 0, 20 * proj.mode.titleFontScale)
    self.obtain = Button("↳ Obtain", 0, 0, 20 * proj.mode.titleFontScale)
end

function Handbook:draw()
    self.closeButton:draw()

    pushStyle()

    fill(118, 222, 236)
    tint(118, 222, 236)

    font("AmericanTypewriter")
    textMode(CORNER)
    spriteMode(CENTER)
    rectMode(CORNER)

    if proj.mode.titleFontScale < 1 then
        textWrapWidth(proj.screenSize.x - 20)
    else
        textWrapWidth(proj.screenSize.x - 100)
    end
    
    textAlign(CENTER)
    fontSize(16 * proj.mode.titleFontScale)    

    pushMatrix()

    local yPos = -100
    translate(proj.screenSize.x/2, proj.screenSize.y) 

    local w,h = textSize(self.copy1)
    debugRect(-w/2, yPos, w, h)
    text(self.copy1, -w/2, yPos)        

    w,h = textSize(self.copy2)
    yPos = yPos - h - 10
    debugRect(-w/2, yPos, w,h)
    text(self.copy2, -w/2, yPos)    
    
    w,h = self.import:size()
    yPos = yPos - h - 10
    self.import.x = proj.screenSize.x/2 - w/2
    self.import.y = proj.screenSize.y + yPos
    
    w,h = textSize(self.copy3)
    yPos = yPos - h - 10
    debugRect(-w/2, yPos, w,h)
    text(self.copy3, -w/2, yPos)    

    w,h = self.obtain:size()
    yPos = yPos - h - 10
    self.obtain.x = proj.screenSize.x/2 - w/2
    self.obtain.y = proj.screenSize.y + yPos
    
    popMatrix()      

    sprite(asset.CodeaLineIcon, proj.screenSize.x/2, self.obtain.y - 40, 50)

    popStyle()

    self.import:draw()
    self.import:update()

    self.obtain:draw()
    self.obtain:update()
end

function Handbook:touched(touch)
    local screenPos = vec2(touch.x, touch.y)
    local worldPos = screenToWorld(screenPos)

    if touch.state == ENDED and touch.tapCount == 1 then
        if worldPos.x < 60 and worldPos.y > proj.screenSize.y - 65 then
            sound(SOUND_HIT, 12483)
            proj.scene = MenuSelect()
        end

        if self.obtain:hitTest(worldPos) then
            openURL("https://apps.apple.com/us/app/codea/id439571171")
        end

        if self.import:hitTest(worldPos) then
            shareTerminal()
        end
    end
end