include("shared.lua")

function ENT:DrawTranslucent()
    self:DrawModel() -- draw the base model
end

local background_color = Color(0, 0, 0, 200)
local select_color = Color(255, 75, 75)
local sel_height = 2

surface.CreateFont("NewsJob:Title", {
    font = "Arial",
    size = 20,
    weight = 500
})

surface.CreateFont("NewsJob:Content", {
    font = "Arial",
    size = 15,
    weight = 500
})

surface.CreateFont("NewsJob:Submit", {
    font = "Arial",
    size = 15,
    weight = 500
})

local function paint_tab(s, w, h)
    if s:IsActive() then
        draw.RoundedBox(0, 0, h - sel_height, w, sel_height, select_color)
    end
end

local function paint_textentry(s, w, h)
    draw.RoundedBox(0, 0, 0, w, h, background_color)
    s:DrawTextEntryText(color_white, ColorAlpha(select_color, 100), color_white)
end

function ENT:OpenMenu(edit_mode)
    print("Opening menu: " .. tostring(edit_menu))

    local frame = vgui.Create("DFrame")
    frame:SetTitle(self:GetPublicationTitle() or "Unknown Publication Title")
    frame:SetSize(ScrW() * .5, ScrH() * .5)
    frame:Center()
    frame:MakePopup()

    frame.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, background_color)
    end

    local tabs = frame:Add("DPropertySheet")
    tabs:Dock(FILL)
    tabs:InvalidateParent(true)
    tabs.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, s.tabScroller:GetTall(), w, h - s.tabScroller:GetTall(), background_color)
    end

    local vtab = tabs:Add("Panel") -- Viewing tab
    local h = vtab:Add("HTML")
    h:Dock(FILL)
    h:DockMargin(10, 10, 10, 10)
    h:SetHTML(string.format([[<!doctypehtml><html lang=en><meta charset=UTF-8><meta content="IE=edge"http-equiv=X-UA-Compatible><meta content="width=device-width,initial-scale=1"name=viewport><title>Publication</title><link href=https://fonts.googleapis.com rel=preconnect><link href=https://fonts.gstatic.com rel=preconnect crossorigin><link href="https://fonts.googleapis.com/css2?family=Gideon+Roman&display=swap"rel=stylesheet><link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&display=swap"rel=stylesheet><script src=https://md-block.verou.me/md-block.js type=module></script><style>*{margin:0;padding:0;color:#fff;font-family:Roboto,sans-serif}h1,h2,h3,h4,h5,h6{font-family:'Gideon Roman',cursive}</style><body><md-block untrusted>%s</md-block>]], self:GetMarkdownContent()))
    tabs:AddSheet("View", vtab, "icon16/newspaper.png").Tab.Paint = paint_tab

    if edit_mode then
        local etab = tabs:Add("DScrollPanel") -- Viewing tab
        local title = etab:Add("DTextEntry")
        title:Dock(TOP)
        title:DockMargin(0, 10, 0, 10)
        title:SetPlaceholderText("Publication Title")
        title:SetTall(30)
        title:SetText(self:GetPublicationTitle())
        title:SetTextColor(color_white)
        title:SetFont("NewsJob:Title")
        title.Paint = paint_textentry

        local content = etab:Add("DTextEntry")
        content:SetPlaceholderText("Publication Content")
        content:InvalidateParent(true)
        content:SetText(self:GetMarkdownContent())
        content:SetTextColor(color_white)
        content:SetFont("NewsJob:Content")
        content:SetMultiline(true)
        content:Dock(TOP)
        content:DockMargin(0, 0, 0, 10)
        content:SetTall(ScrH() * .25)
        content.Paint = paint_textentry

        local submit = etab:Add("DButton")
        submit:Dock(TOP)
        submit:SetText("Submit")
        submit:SetColor(color_white)
        submit:SetFont("NewsJob:Submit")
        submit:SetTall(30)
        submit.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, select_color)
            if s:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(background_color, 100))
            end
        end

        submit.DoClick = function(s)
            local v = self:ValidateText(content:GetText())
            if !v then
                notification.AddLegacy("Newspaper update failed: validation failed (remove andy < or >)", NOTIFY_ERROR, 4)
                return
            end

            net.Start("NewsJob:UpdateNewspaper")
                net.WriteEntity(self)
                net.WriteString(title:GetText())
                net.WriteString(content:GetText())
            net.SendToServer()

            frame:Close()
        end

        tabs:AddSheet("Edit", etab, "icon16/newspaper_add.png").Tab.Paint = paint_tab
    end
end

net.Receive("NewsJob:OpenMenu", function()
    local edit_mode = net.ReadBool()
    local entity = net.ReadEntity()

    if IsValid(entity) and entity:GetClass() == "newsjob_newspaper" then
        entity:OpenMenu(edit_mode)
    end
end)
