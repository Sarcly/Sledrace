AddCSLuaFile()

ENT.PrintName = "Movable Face OLD"
ENT.Type="anim"
ENT.Base="base_anim"
ENT.Spawnable=true
ENT.AdminOnly=false
ENT.Category="Sledrace"
ENT.Author="Sarcly & Intox"

ENT.CornerP1 = nil
ENT.CornerP2 = nil
ENT.RenderGroup=RENDER_GROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Vector",0,"CornerP1")
    self:NetworkVar("Vector",1,"CornerP2")
    self:NetworkVar("Vector",2,"DiffVector")
end

function ENT:Initialize()
    self:SetColor(Color(0,0,0,25))
    self:SetModel("")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetSolid(SOLID_VPHYSICS)
    self:DrawShadow(false)
    --self:EnableCustomCollisions(true)
end

function ENT:Setup(p1, p2)
    if SERVER then
        local offset = Vector()
        if(p1.x==p2.x)then offset=Vector(1,0,0) 
        elseif(p1.y==p2.y)then offset=Vector(0,1,0)
        elseif(p1.z==p2.z)then offset=Vector(0,0,1)
        end
        self:SetCornerP1(p1)
        self:SetCornerP2(p2+offset)
        self:SetSolid(SOLID_VPHYSICS)
        local diff = self:GetPos()-self:GetParent():GetPos()
        self:SetDiffVector(diff)
        local vec1 = self:GetCornerP1()-diff
        local vec2 = self:GetCornerP2()-diff
        self.PhysCollide=CreatePhysCollideBox(vec1,vec2)
        self:SetCollisionGroup(COLLISION_GROUP_WORLD)

        OrderVectors(vec1,vec2)
        self:SetCollisionBounds(vec1,vec2)
        self:EnableCustomCollisions(true)
    end
end

function ENT:TestCollision( startpos, delta, isbox, extents )
	if not IsValid( self.PhysCollide ) then
		return
	end

	-- TraceBox expects the trace to begin at the center of the box, but TestCollision is bad
	local max = extents
	local min = -extents
	max.z = max.z - min.z
	min.z = 0

	local hit, norm, frac = self.PhysCollide:TraceBox( self:GetPos(), self:GetAngles(), startpos, startpos + delta, min, max )
	if not hit then
		return
	end
	return {
		HitPos = hit,
        Normal = norm,
        Entity=self,
		Fraction = frac,
	 }
end

function ENT:Think()
    if CLIENT then
        local diff = self:GetDiffVector()
        local vec1 = self:GetCornerP1()-diff
        local vec2 = self:GetCornerP2()-diff
        OrderVectors(vec1,vec2)
        self:SetRenderBounds(vec1,vec2)
    end
    if SERVER then
        local tr = self:GetParent().ToolgunParent:GetOwner():GetEyeTrace()
        if (tr.Entity && tr.Entity==self) then
            self:SetColor(Color(0,0,150,50))
        else
            self:SetColor(Color(0,0,0,50))
        end
    end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:Draw()
    local ren1, ren2 = self:GetRenderBounds()
    cam.Start3D()
        local vec1, vec2 = self:GetCollisionBounds()
        render.SetColorMaterial()
        render.DrawBox(self:GetPos(),self:GetAngles(),vec1,vec2,self:GetColor())
    cam.End3D()
end

function TPPlayerSay(sender,text,teamchat)
    if(string.StartWith(text,"`tp"))then
        local exploded = string.Explode(" ",text)
        print(exploded[2], exploded[3],exploded[4])
        sender:SetPos(Vector(exploded[2], exploded[3],exploded[4]))
    end
    if(string.StartWith(text,"`ang")) then
        local exploded = string.Explode(" ",text)
        print(Angle(exploded[2], exploded[3],exploded[4]))
        sender:SetEyeAngles(Angle(exploded[2], exploded[3],exploded[4]))
    end
end 
hook.Add("PlayerSay","SLR_TP_PlayerSay",TPPlayerSay)

function PickupEditableFace(ply,ent)
    if(ent.ClassName=="slr_editface") then
        return false
    end
end
hook.Add("PhysgunPickup","slr_PickupEditableFace", PickupEditableFace)