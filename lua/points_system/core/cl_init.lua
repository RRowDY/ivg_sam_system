local openPlayerMenu
local openAdminMenu
local adminMenu
local panel

local function validCheck()
    if IsValid(plyMenu) then plyMenu:Close() end
    if IsValid(adminMenu) then adminMenu:Close() end
end

openPlayerMenu = function(target)
    validCheck()

    local w, h = ScreenScale(150), ScreenScale(180)

    plyMenu = vgui.Create("IVGPoints.Frame")
    plyMenu:SetSize(w, h)
    plyMenu:SetTitle("Editing points for " .. target:GetName(), "ivgpoints/adminicon.png")
    plyMenu:Center()
    plyMenu:MakePopup()
    -- plyMenu.OnClose = function()
    --     plyMenu.scroll:Remove()
    -- end
    -- plyMenu.OnHide = function()
    --     plyMenu.scroll:Hide()
    -- end
    -- plyMenu.OnShow = function()
    --     plyMenu.scroll:Show()
    -- end

    local titleH = plyMenu:GetTitleDock()

    plyMenu.back = vgui.Create("IVGPoints.Button", plyMenu)
    plyMenu.back:SetSize(26, titleH)
    plyMenu.back:SetPos(plyMenu:GetWide() - 50 - plyMenu.back:GetWide(), 0)
    plyMenu.back:SetColor(ivgPoints.color.admin)
    plyMenu.back:SetIcon("ivgpoints/backbutton.png")
    plyMenu.back:SetFont("Trebuchet18")
    plyMenu.back.DoClick = function()
        openAdminMenu()
    end

    plyMenu.studsLabel = vgui.Create("DLabel", plyMenu)
    plyMenu.studsLabel:SetText("Studs")
    plyMenu.studsLabel:SetFont("Trebuchet18")
    plyMenu.studsLabel:SetPos(plyMenu:GetWide() * .5 - plyMenu:GetWide() * .1, titleH + 10)
    plyMenu.studsLabel:SetContentAlignment(5)

    plyMenu.studs = vgui.Create("IVGPoints.TextEntry", plyMenu)
    plyMenu.studs:SetPos(plyMenu:GetWide() * .25, titleH + 40)
    plyMenu.studs:SetSize(plyMenu:GetWide() * .5, 40)
    plyMenu.studs:RequestFocus()
    plyMenu.studs:SetNumeric(true)
    plyMenu.studs:SetValue(target.samData.studs)

    plyMenu.save = vgui.Create("IVGPoints.Button", plyMenu.studs)
    plyMenu.save:SetSize(80, plyMenu.studs:GetTall())
    plyMenu.save:SetPos(plyMenu.studs:GetWide() - plyMenu.save:GetWide(), 0)
    plyMenu.save:SetColor(ivgPoints.color.admin)
    plyMenu.save:SetButtonText("Save")
    plyMenu.save.DoClick = function()
        plyMenu.studs:SetValue(plyMenu.studs:GetInt())
        ivgPoints.confirmWindow("Confirm Change", "Are you sure you want to save this edit?", function(confirm)
            if (confirm) then
                net.Start("ivgPoints.send")
                    net.WriteEntity(target)
                    net.WriteString("Studs")
                    net.WriteString(plyMenu.studs:GetValue())
                net.SendToServer()
            end
        end)
    end

    plyMenu.meritsLabel = vgui.Create("DLabel", plyMenu)
    plyMenu.meritsLabel:SetText("Merits")
    plyMenu.meritsLabel:SetFont("Trebuchet18")
    plyMenu.meritsLabel:SetPos(plyMenu:GetWide() * .5 - plyMenu:GetWide() * .1, titleH + 90)
    plyMenu.meritsLabel:SetContentAlignment(5)

    plyMenu.merits = vgui.Create("IVGPoints.TextEntry", plyMenu)
    plyMenu.merits:SetPos(plyMenu:GetWide() * .25, titleH + 120)
    plyMenu.merits:SetSize(plyMenu:GetWide() * .5, 40)
    plyMenu.merits:RequestFocus()
    plyMenu.merits:SetValue(target.samData.merits)

    plyMenu.save2 = vgui.Create("IVGPoints.Button", plyMenu.merits)
    plyMenu.save2:SetSize(80, plyMenu.merits:GetTall())
    plyMenu.save2:SetPos(plyMenu.merits:GetWide() - plyMenu.save2:GetWide(), 0)
    plyMenu.save2:SetColor(ivgPoints.color.admin)
    plyMenu.save2:SetButtonText("Save")
    plyMenu.save2.DoClick = function()
        ivgPoints.confirmWindow("Confirm Change", "Are you sure you want to save this edit?", function(confirm)
            if (confirm) then
                net.Start("ivgPoints.send")
                    net.WriteEntity(target)
                    net.WriteString("Merits")
                    net.WriteString(plyMenu.merits:GetValue())
                net.SendToServer()
            end
        end)
    end

    -- plyMenu.give = vgui.Create("IVGPoints.Button", plyMenu)
    -- plyMenu.give:SetSize(plyMenu:GetWide() - 20, 40)
    -- plyMenu.give:SetPos(10, titleH + 10)
    -- plyMenu.give:SetRounded(4, true, true, true)
    -- plyMenu.give:SetColor(ivgPoints.color.admin)
    -- plyMenu.give:SetButtonText("Give Studs")
    -- plyMenu.give.DoClick = function()
    --     plyMenu.test = vgui.Create("IVGPoints.Player")
    --     plyMenu.test:SetSize(plyMenu:GetWide() - 20, tall)
    --     plyMenu.test:SetPos(x, y)
    --     plyMenu.test:SetPlayer(LocalPlayer())
    -- end

    -- plyMenu.give2 = vgui.Create("IVGPoints.Button", plyMenu)
    -- plyMenu.give2:SetSize(plyMenu:GetWide() - 20, 40)
    -- plyMenu.give2:SetPos(10, titleH + 60)
    -- plyMenu.give2:SetRounded(4, true, true, true)
    -- plyMenu.give2:SetColor(ivgPoints.color.admin)
    -- plyMenu.give2:SetButtonText("Give Merits")
    -- plyMenu.give2.DoClick = function()
    --     print("TEST")
    -- end

end

net.Receive("ivgPoints.browse", function()
    local targetPlayer = net.ReadEntity()
    local targetData = net.ReadTable()
    targetPlayer.samData = targetData
    openPlayerMenu(targetPlayer)
end)

openAdminMenu = function()
    validCheck()

    local w, h, tall = ScreenScale(150), ScreenScale(180), ScreenScale(20)

    adminMenu = vgui.Create("IVGPoints.Frame")
    adminMenu:SetSize(w, h)
    adminMenu:SetTitle("Administration Panel", "ivgpoints/adminicon.png")
    adminMenu:Center()
    adminMenu:MakePopup()
    adminMenu.OnClose = function()
        adminMenu.scroll:Remove()
    end

    local titleH = adminMenu:GetTitleDock()

    adminMenu.entry = vgui.Create("IVGPoints.TextEntry", adminMenu)
    adminMenu.entry:SetPos( 10, titleH + 10)
    adminMenu.entry:SetSize(adminMenu:GetWide() - 20, 40)
    adminMenu.entry:RequestFocus()
    adminMenu.entry.OnChange = function()
        local val = adminMenu.entry:GetText():Trim()
        if (val != "") then
            adminMenu:DoSearch(val)
        else
            adminMenu:DoSearch()
        end
    end

    adminMenu.scroll = vgui.Create("IVGPoints.ScrollPanel", adminMenu)
    adminMenu.scroll:SetSize(adminMenu:GetWide() - 20, adminMenu:GetTall() - 30 - titleH - adminMenu.entry:GetTall())
    adminMenu.scroll:SetPos(10, titleH + 20 + adminMenu.entry:GetTall())

    function adminMenu:DoSearch(find)
        adminMenu.scroll:Reset()
        local x, y = 0, 0
        for k, v in ipairs(player.GetAll()) do
            if (find != nil and !string.find(v:Name():lower(), find:lower())) then continue end
            panel = vgui.Create("IVGPoints.Player")
            panel:SetSize(adminMenu.scroll:GetWide(), tall)
            panel:SetPos(x, y)
            panel:SetPlayer(v)
            panel.points.DoClick = function()
                RunConsoleCommand("say", ivgPoints.chatCommandPrefix .. "browseplayer " .. panel:GetPlayer():SteamID64())
            end
            adminMenu.scroll:AddItem(panel)
            y = y + panel:GetTall() + 10
        end
    end
    adminMenu:DoSearch()
end

net.Receive("ivgPoints.admin", function()
    openAdminMenu()
end)
