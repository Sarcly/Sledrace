AddCSLuaFile()
ENT.Type="anim"
ENT.Base = "base_anim"
ENT.Spawnable=false
ENT.Category="Sledrace!"
ENT.Author="Sarcly & Intox"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:SetModel("")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
    self:SetColor(Color(0,0,0,120))
end

function ENT:Think()
	if(!IsValid(self.Parent)) then
		print(self.PhysCollide)
		self:Remove()
		print("removing..")
	end
    if CLIENT then
		if(self.P1 and self.P2 and IsValid(self:GetParent())) then
			print(self:GetPos())
            self:SetRenderBounds(self.P1,self.P2 + Vector(1, 1, 1))
        end
	end
end


--[[
	REFACTOR TO BE NOT AN EXCLUSIVELY CLIENTSIDE ENTITY
	MAKE IT NETWORKED, BUT HAVE THE LOCALPLAYER SET THEIR OWN VALUE OF IT, THEN IN THINK OR SOMETHING ELSE HAVE IT PUSH THE CLIENT'S VERSION TO THE SERVER'S NETWORKEDVAR.
	*** DO NOT RENDER THE NETWORKEDVAR ON THE CLIENT ***
]]

function ENT:TestCollision(startpos, delta, isbox, extents)
	--if CLIENT then print("physcollide",self.PhysCollide)	 end
	print("testing collision")
	if not IsValid(self.PhysCollide) then return end
	-- TraceBox expects the trace to begin at the center of the box, but TestCollision is bad
	local max = extents
	local min = -extents
	max.z = max.z - min.z
	min.z = 0
	local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), startpos, startpos + delta, min, max)
	
	if not hit then return end
    self:GetOwner().CurrentFace:SetColor(Color(0,0,0,0))
    self:SetColor(Color(255,0,0,100))
    self:GetOwner().CurrentFace=self
    print(self:GetOwner().CurrentFace)
    return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac,
		Entity = self
    }

end

function ENT:UpdateCorners(P1, P2)
	local P1_C = Vector()
	P1_C:Set(P1)
	local P2_C = Vector()
	P2_C:Set(P2)
	local principle_axis = P1.x == P2.x and "x" or (P1.y == P2.y and "y" or "z")
	self.principal_axis = principle_axis == "x" and 1 or (principle_axis == "y" and 2 or 3)
	self.P1=P1
	self.P2=P2
	OrderVectors(P1_C, P2_C)
	print(self:GetParent():GetPos())
	print(self:GetPos())
	self.PhysCollide = CreatePhysCollideBox(P1_C, P2_C + Vector(1, 1, 1))
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetCollisionBounds(P1_C, P2_C+Vector(1,1,1))
	self:EnableCustomCollisions(true)
end

function ENT:DrawTranslucent()
    cam.Start3D()
		render.SetColorMaterial()
		--render.DrawBox(self:GetParent():GetPos(),self:GetAngles(),self.P1,self.P2,self:GetColor())
		local render1, render2 = self:GetRenderBounds()
		render.DrawWireframeBox(self:GetParent():GetPos(),self:GetAngles(), render1,render2,self:GetColor())
        local vec1, vec2 = self:GetCollisionBounds()
        -- render.DrawWireframeSphere(LerpVector(0.5,self:GetParent():GetPos()+vec1,self:GetParent():GetPos()+vec2),5,10,10)
        render.DrawWireframeSphere(LerpVector(0.5,self:GetParent():GetPos()+self.P1,self:GetParent():GetPos()+self.P2),5,10,10)
    cam.End3D()
end