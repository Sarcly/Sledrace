AddCSLuaFile()

function EFFECT:Init(effectData)
	--update corner logic
	local P1_C = Vector()
	P1_C:Set(effectData.P1)
	local P2_C = Vector()
	P2_C:Set(effectData.P2)
	local principle_axis = P1.x == P2.x and "x" or (P1.y == P2.y and "y" or "z")
	self.principal_axis = principle_axis == "x" and 1 or (principle_axis == "y" and 2 or 3)
	self.P1=P1
	self.P2=P2
	OrderVectors(P1_C, P2_C)
	self.PhysCollide = CreatePhysCollideBox(P1_C, P2_C + Vector(1, 1, 1))
	print(self.PhysCollide)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetCollisionBoundsWS(self:GetParent():GetPos()+self.P1,self:GetParent():GetPos()+self.P2 + Vector(1, 1, 1))
	self:EnableCustomCollisions(true)
end

function EFFECT:Think()
	if(!IsValid(self:GetParent())) then
		print(self:GetParent())
		print(self.PhysCollide)
		self:Remove()
		print("removing..")
	end
	if CLIENT then
		--print(self.Parent:GetPos()+self:GetPos()+self.P1,self.Parent:GetPos()+self:GetPos()+self.P2 + Vector(1, 1, 1))
		if(self.P1 and self.P2 and IsValid(self:GetParent())) then
            self:SetRenderBoundsWS(self:GetParent():GetPos()+self.P1,self:GetParent():GetPos()+self.P2 + Vector(1, 1, 1))
        end
	end
end

function EFFECT:TestCollision(startpos, delta, isbox, extents)
	print(self)
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
    return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac,
		Entity = self
    }

end

function EFFECT:UpdateCorners(P1, P2)

end


function EFFECT:Render()
    cam.Start3D()
		render.SetColorMaterial()
		--render.DrawBox(self:GetParent():GetPos(),self:GetAngles(),self.P1,self.P2,self:GetColor())
		render.DrawWireframeSphere(Vector(),10,10,10)
		local render1, render2 = self:GetRenderBounds()
		--render.DrawWireframeBox(Vector(),self:GetAngles(),self:GetParent():GetPos()+self.P1,self:GetParent():GetPos()+self.P2 + Vector(1, 1, 1),self:GetColor())
		--render.DrawBox(self.Parent:GetPos(),self:GetAngles(),self.P1,self.P2 + Vector(1, 1, 1),self:GetColor())
		--render.DrawWireframeBox(self.Parent:GetPos()+self:GetPos(),self:GetAngles(),render1,render2,self:GetColor())
		render.DrawWireframeSphere(self:GetPos()+self:GetParent():GetPos(),5,10,10, self:GetColor())
		local vec1, vec2 = self:GetCollisionBounds()
		render.DrawWireframeBox(Vector(),self:GetAngles(),vec1,vec2,self:GetColor())
		-- render.DrawWireframeSphere(LerpVector(0.5,self:GetParent():GetPos()+vec1,self:GetParent():GetPos()+vec2),5,10,10)
		--print(self.Parent:GetPos(),self.P1,self.P2)
	cam.End3D()
end