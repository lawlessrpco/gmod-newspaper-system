ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Newspaper"
ENT.Category = "News System"
ENT.Author = "Lion"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- Setup some variables
function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent") -- Required for proper ownership

    -- Article Config
    self:NetworkVar("String", 1, "PublicationTitle") -- Title of the Newspaper
    self:NetworkVar("String", 2, "MarkdownContent") -- The content in markdown
    self:NetworkVar("Int", 3, "LastUpdated") -- When the publication was last updated
end

function ENT:ValidateText(t)
    local arrowStart, _ = string.find(t:lower(), "<")
    local arrow2Start, _ = string.find(t:lower(), ">")

    if arrowStart or arrow2Start then return false end
    return true
end
