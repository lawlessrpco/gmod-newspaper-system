
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Network setup
util.AddNetworkString("NewsJob:OpenMenu") -- we see which menu based on sent veriables
util.AddNetworkString("NewsJob:UpdateNewspaper") -- make sure to validate ownership :)

function ENT:Initialize()
    self:SetModel("models/props_junk/garbage_newspaper001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self:SetupPhys()

    if IsValid(self:Getowning_ent()) then
        self:CPPISetOwner(self:Getowning_ent())
    end

    -- Set some defualt values
    self:SetPublicationTitle("GMOD News")
    self:SetMarkdownContent("# MAN LANDS ON FUCKING MOON\n**NO FUCKING WAY!!!!**\n*pretty epic*")
    self:SetLastUpdated(CurTime())
end

function ENT:SetupPhys()
    local physObj = self:GetPhysicsObject()
    if not physObj:IsValid() then return end

    physObj:Wake()
end

-- this fails every DRY principle imaginable but whatever /shrug
function ENT:OpenNewspaperMenu(ply)
    if IsValid(self:CPPIGetOwner()) and self:CPPIGetOwner() == ply then
        net.Start("NewsJob:OpenMenu")
            net.WriteBool(true) -- open in edit mode
            net.WriteEntity(self) -- the newspaper entity
        net.Send(ply)
    else
        net.Start("NewsJob:OpenMenu")
            net.WriteBool(false) -- open in edit mode
            net.WriteEntity(self) -- the newspaper entity
        net.Send(ply)
    end
end

function ENT:AttemptUpdate(ply, title, content)
    if !IsValid(self:CPPIGetOwner()) or !self:CPPIGetOwner() == ply then return false, "failed ownership check" end
    if !self:ValidateText(content) then return false, "validation fail" end

    self:SetPublicationTitle(title)
    self:SetMarkdownContent(content)
    self:SetLastUpdated(CurTime())

    return true, ""
end

net.Receive("NewsJob:UpdateNewspaper", function(_, ply)
    local ent = net.ReadEntity()
    local title = net.ReadString()
    local content = net.ReadString()
    if !IsValid(ent) or ent:GetClass() != "newsjob_newspaper" then return end -- don't even bother

    local ok, err = ent:AttemptUpdate(ply, title, content)
    if !ok then
        ply:ChatPrint("Failed to update newspaper: " .. err)
    end
end)

function ENT:Use(ply)
    self:OpenNewspaperMenu(ply)
end
