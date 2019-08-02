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
	--print(self:GetParent())
	-- if(!IsValid(self:GetParent())) then
	-- 	print(self:GetParent())
	-- 	print(self.PhysCollide)
	-- 	self:Remove()
	-- 	print("removing..")
	-- end
	if CLIENT then
		--print(self.Parent:GetPos()+self:GetPos()+self.P1,self.Parent:GetPos()+self:GetPos()+self.P2 + Vector(1, 1, 1))
		if(self.P1 and self.P2 and IsValid(self:GetParent())) then
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
    return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac,
		Entity = self
    }

end

function ENT:UpdateCorners(P1, P2)
	local P1_C = Vector()
	P1_C:Set(self:GetParent():GetPos()-P1)
	local P2_C = Vector()
	P2_C:Set(self:GetParent():GetPos()-P2)
	local principle_axis = P1.x == P2.x and "x" or (P1.y == P2.y and "y" or "z")
	self.principal_axis = principle_axis == "x" and 1 or (principle_axis == "y" and 2 or 3)
	self.P1=self:GetParent():GetPos()-P1
	self.P2=self:GetParent():GetPos()-P2
	OrderVectors(P1_C, P2_C)
	self.PhysCollide = CreatePhysCollideBox(P1_C, P2_C + Vector(1, 1, 1))
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetCollisionBoundsWS(self:GetParent():GetPos()+self.P1,self:GetParent():GetPos()+self.P2 + Vector(1, 1, 1))
	self:EnableCustomCollisions(true)
end

function ENT:DrawTranslucent()

    cam.Start3D()
		render.SetColorMaterial()
		--render.DrawBox(self:GetParent():GetPos(),self:GetAngles(),self.P1,self.P2,self:GetColor())
		render.DrawWireframeSphere(Vector(),10,10,10)
		local render1, render2 = self:GetRenderBounds()
		-- render.DrawWireframeBox(Vector(),self:GetAngles(),render1,render2,self:GetColor())
		print(self.P1,self.P2)
		render.DrawWireframeBox(self:GetParent():GetPos(),self:GetAngles(),self.P1,self.P2+Vector(1,1,1),self:GetColor())
		--render.DrawBox(self.Parent:GetPos(),self:GetAngles(),self.P1,self.P2 + Vector(1, 1, 1),self:GetColor())
		--render.DrawWireframeBox(self.Parent:GetPos()+self:GetPos(),self:GetAngles(),render1,render2,self:GetColor())
		render.DrawWireframeSphere(self:GetParent():GetPos()+self:GetPos(),5,10,10, self:GetColor())
		local vec1, vec2 = self:GetCollisionBounds()
		--render.DrawWireframeBox(self:GetPos(),self:GetAngles(),vec1,vec2,self:GetColor())
		-- render.DrawWireframeSphere(LerpVector(0.5,self:GetParent():GetPos()+vec1,self:GetParent():GetPos()+vec2),5,10,10)
		--print(self.Parent:GetPos(),self.P1,self.P2)
	cam.End3D()
end