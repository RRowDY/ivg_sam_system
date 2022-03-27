local IVG = ivgPoints

-- Scroll Panel
PANEL = {}

AccessorFunc(PANEL, "m_bDrawBorder", "DrawBorder", FORCE_BOOL)
AccessorFunc(PANEL, "m_bUseSizeLimit", "UseSizeLimit", FORCE_BOOL)

function PANEL:Init()
    self:SetDrawBorder(false)
    self:SetUseSizeLimit(false)

    self.VBar:SetWide(6)
    self.VBar.btnUp:Remove()
    self.VBar.btnDown:Remove()

    self.VBar.targetScroll = 0
    self.VBar.scrollSpeed = 4

    self.VBar.SetUp = function(bar, barSize, canvasSize)
        bar.BarSize = barSize
        bar.CanvasSize = math.max(canvasSize - barSize, 1)
        if (self:GetUseSizeLimit()) then
            bar:SetEnabled(canvasSize > barSize)
        else
            bar:SetEnabled(true)
        end
        bar:InvalidateLayout()
    end

    function self.VBar:Paint(w, h)
    end

    function self.VBar.btnGrip:Paint(w, h)
        local parent = self:GetParent():GetParent()
        local x, y = parent:ScreenToLocal(gui.MousePos())
        local x2, y2 = parent:GetPos()
        local w2, h2 = parent:GetSize()

        if (x >= 0 and x <= w2 and y >= 0 and y <= h2) then
            draw.RoundedBox(4, 0, 0, w, h, IVG.color.grip)
        end
    end

    function self.VBar:OnMouseWheeled(delta)
        self.scrollSpeed = self.scrollSpeed + 50 * FrameTime()
        self:AddScroll(delta * -self.scrollSpeed)
    end

    function self.VBar:OnCursorMoved(x, y)
        if (!self.Enabled) then
            return
        end
        if (!self.Dragging) then
            return
        end
        local x = 0
        local y = gui.MouseY()
        local x, y = self:ScreenToLocal(x, y)
        y = y - self.HoldPos
        local TrackSize = self:GetTall() - self:GetWide() * 2 - self.btnGrip:GetTall()
        y = y / TrackSize
        self.targetScroll = y * self.CanvasSize
    end

    function self.VBar:PerformLayout()
        local scroll = self:GetScroll() / self.CanvasSize
        local barSize = math.max(self:BarScale() * self:GetTall(), 0)
        local trake = self:GetTall() - barSize
        trake = trake + 1
        scroll = scroll * trake
        self.btnGrip:SetPos(0, scroll)
        self.btnGrip:SetSize(self:GetWide(), barSize)
    end

    function self.VBar:Think()
        self.scrollSpeed = math.Approach(self.scrollSpeed, 4, math.abs(4 - self.scrollSpeed) * FrameTime())
        self.Scroll = math.Approach(self.Scroll, self.targetScroll, 10 * math.abs(self.targetScroll - self.Scroll) * FrameTime())
        if (!self.Dragging) then
            if (self.targetScroll < 0) then
                self.targetScroll = math.Approach(self.targetScroll, 0, 10 * math.abs(0 - self.Scroll) * FrameTime())
            elseif (self.targetScroll > self.CanvasSize) then
                self.targetScroll = math.Approach(self.targetScroll, self.CanvasSize, 10 * math.abs(self.CanvasSize - self.Scroll) * FrameTime())
            end
        end
    end

    function self.VBar:SetScroll(amount)
        self.targetScroll = amount
        self:InvalidateLayout()
        local func = self:GetParent().OnVScroll
        if (func) then
            func(self:GetParent(), self:GetOffset())
        else
            self:GetParent():InvalidateLayout()
        end
    end
end

function PANEL:Reset()
    self:GetCanvas():Clear(true)
    self:PerformLayout()
end

function PANEL:Think()
    self.pnlCanvas:SetPos(0, -self.VBar.Scroll)
end

function PANEL:PerformLayout()
    local w, h = self:GetSize()
    self:Rebuild()
    self.VBar:SetUp(h, self.pnlCanvas:GetTall())
    if (self.VBar.Enabled) then
        self.pnlCanvas:SetWide(w)
    else
        self.pnlCanvas:SetWide(w)
        self.pnlCanvas:SetPos(0, 0)
    end
    self:Rebuild()
end
vgui.Register("IVGPoints.ScrollPanel", PANEL, "DScrollPanel")

-- Player Panel

PANEL = {}

function PANEL:Init()
    self.avatar = vgui.Create("AvatarImage", self)
    self.points = vgui.Create("IVGPoints.Button", self)
    self.points:SetButtonText("Edit Points")
    self.points:SetRounded(4, false, true, false, true)
    self.points:SetColor(IVG.color.admin)
end

function PANEL:SetPlayer(pl)
    self.Player = pl
    self.Name = pl:Name()
    self.avatar:SetPlayer(pl, self:GetTall())
end

function PANEL:GetPlayer()
    return self.Player
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, IVG.color.title)
    draw.RoundedBox(4, 3, 3, self:GetTall() - 6, self:GetTall() - 6, team.GetColor(self.Player:Team()))
    draw.SimpleText(self.Name, "Trebuchet18", self:GetTall() + 5, h * .5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:PerformLayout()
    self.avatar:SetSize(self:GetTall() - 8, self:GetTall() - 8)
    self.avatar:SetPos(4, 4)

    self.points:SetSize(80, self:GetTall())
    self.points:SetPos(self:GetWide() - self.points:GetWide(), 0)
end
vgui.Register("IVGPoints.Player", PANEL, "Panel")


 -- Button Panel
PANEL = {}

function PANEL:Init()
    self:SetText("")
    self.cornerRadius = 0
    self.topLeft, self.topRight, self.bottomLeft, self.bottomRight = false, false, false, false
    self.buttonColor = Color(150, 150, 150)
    self.textColor = IVG.color.white
    self.font = "Trebuchet18"
    self.text = ""
    self.icon = false
    self.hover = true
end

function PANEL:SetRounded(radius, topLeft, topRight, bottomLeft, bottomRight)
    self.cornerRadius = radius and radius or self.cornerRadius
    self.topLeft = topLeft and topLeft or self.topLeft
    self.topRight = topRight and topRight or self.topRight
    self.bottomLeft = bottomLeft and bottomLeft or self.bottomLeft
    self.bottomRight = bottomRight and bottomRight or self.bottomRight
end

function PANEL:SetFont(font)
    self.font = font
end

function PANEL:SetColor(button)
    self.buttonColor = button and button or self.buttonColor
end

function PANEL:SetButtonText(text)
    self.text = text
end

function PANEL:SetIcon(icon)
    self.icon = Material(icon, "smooth")
end

function PANEL:SetNoHovered()
    self.hover = false
end

function PANEL:Paint(w, h)
    local col = self.buttonColor
    if (self.hover) then
        if (self:IsHovered()) then
            col = self.buttonColor
        else
            col = Color(self.buttonColor.r, self.buttonColor.g, self.buttonColor.b, 175)
        end
    end
    draw.RoundedBoxEx(self.cornerRadius, 0, 0, w, h, col, self.topLeft, self.topRight, self.bottomLeft, self.bottomRight)
    if (self.icon) then
        surface.SetDrawColor(color_white)
        surface.SetMaterial(self.icon)
        surface.DrawTexturedRect(2, 2, 22, 22)
        draw.SimpleText(self.text, self.font, 26, h * .5, self.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText(self.text, self.font, w * .5, h * .5, self.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end
vgui.Register("IVGPoints.Button", PANEL, "DButton")

-- Frame Panel

PANEL = {}

function PANEL:Init()
    self.lblTitle:SetText("")
    self:ShowCloseButton(false)
    self:SetDraggable(false)

    self.close = vgui.Create("IVGPoints.Button", self)
    self.close:SetButtonText("X")
    self.close:SetFont("Trebuchet18")
    self.close:SetColor(IVG.color.close)
    self.close:SetRounded(8, false, true)
    self.close.DoClick = function()
        self:Close()
    end

    self:SetAlpha(0)
    self:Show()
end

function PANEL:SetTitle(title, icon)
    self.Title = title
    self.Icon = icon
end

function PANEL:GetTitleDock()
    return 26
end

function PANEL:OnShow()
end

function PANEL:Show()
    self:OnShow()
    self:AlphaTo(255, .15)
    self:SetVisible(true)
end

function PANEL:OnHide()
end

function PANEL:Hide()
    self:OnHide()
    self:AlphaTo(0, .07, 0, function()
        self:SetVisible(false)
    end)
end

function PANEL:Close(closeBack)
    self:OnClose()
    self:AlphaTo(0, .07, 0, function()
        self:Remove()
        if (closeBack) then closeBack() end
    end)
end

function PANEL:PerformLayout()
    local w = self:GetWide()

    self:SetSize(w, self:GetTall())
    self.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, IVG.color.background)
        draw.RoundedBoxEx(8, 0, 0, w, self:GetTitleDock(), IVG.color.title, true, true)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(Material(self.Icon, "smooth"))
        surface.DrawTexturedRect(10, 2, 22, 22)

        draw.SimpleText(self.Title, "Trebuchet18", 36, self:GetTitleDock() * .5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.close:SetSize(50, self:GetTitleDock())
    self.close:SetPos(w - self.close:GetWide(), 0)
end
vgui.Register("IVGPoints.Frame", PANEL, "DFrame")

-- Text Entry Panel

PANEL = {}

function PANEL:Init()
    self:SetDrawLanguageID(false)
    self:SetFont("Trebuchet18")
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, IVG.color.title)
    self:DrawTextEntryText(IVG.color.grip, IVG.color.admin, IVG.color.admin)
end
vgui.Register("IVGPoints.TextEntry", PANEL, "DTextEntry")

-- Confirm Window
local confirmWindow

function ivgPoints.confirmWindow(title, message, callback)
    if IsValid(confirmWindow) then confirmWindow:Remove() end

    confirmWindow = vgui.Create("Panel")
    confirmWindow:SetSize(ScrW(), ScrH())
    confirmWindow:SetPos(0, 0)
    confirmWindow.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
    end

    local frame = vgui.Create("IVGPoints.Frame", confirmWindow)
    frame:SetTitle(title, "ivgpoints/adminicon.png")
    frame:MakePopup()
    frame.close.DoClick = function()
        if (callback) then
            callback(false)
        end
        confirmWindow:Remove()
    end

    local text = vgui.Create("DLabel", frame)
    text:SetFont("Trebuchet18")
    text:SetText(message)
    text:SetTextColor(color_white)
    text:SizeToContents()
    frame:SetSize(text:GetWide() + 20, 100)
    frame:Center()
    text:SetPos(frame:GetWide() * .5 - text:GetWide() * .5, 35)

    local yes, no = vgui.Create("IVGPoints.Button", frame), vgui.Create("IVGPoints.Button", frame)
    yes:SetSize(frame:GetWide() * .5, 30)
    yes:SetPos(frame:GetWide() * .5, frame:GetTall() - yes:GetTall())
    yes:SetButtonText("Yes")
    yes:SetRounded(8, false, false, false, true)
    yes:SetColor(Color(0, 255, 0, 255))
    yes.DoClick = function()
        if (callback) then
            callback(true)
        end
        confirmWindow:Remove()
    end

    no:SetSize(frame:GetWide() * .5, 30)
    no:SetPos(0, frame:GetTall() - no:GetTall())
    no:SetButtonText("No")
    no:SetRounded(8, false, false, true)
    no:SetColor(Color(255, 0, 0))
    no.DoClick = function()
        if (callback) then
            callback(false)
        end
        confirmWindow:Remove()
    end
end