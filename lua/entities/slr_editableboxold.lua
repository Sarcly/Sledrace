AddCSLuaFile()
ENT.PrintName = "Editable Box OLD"
ENT.Author = "Sarcly & Intox"
ENT.Information = "Box!"
ENT.Category = "Sledrace"
ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Faces = {}
ENT.Corners = {}

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "MinBound", {
		KeyName = "minbound",
		Edit = {
			type = "Vector",
			order = 1
		}
	})

	self:NetworkVar("Vector", 1, "MaxBound", {
		KeyName = "maxbound",
		Edit = {
			type = "Vector",
			order = 2
		}
	})

	for i = 0, 7 do
		self:NetworkVar("Vector", 2 + i, "Corner" .. (bit.band(i, 4) == 0 and "x1" or "x2") .. (bit.band(i, 2) == 0 and "y1" or "y2") .. (bit.band(i, 1) == 0 and "z1" or "z2"))
	end

	self:NetworkVarNotify("MinBound", self.OnBoundsChanged)
	self:NetworkVarNotify("MaxBound", self.OnBoundsChanged)

	if (SERVER) then
		self:SetMinBound(Vector(-10, -10, -10))
		self:SetMaxBound(Vector(10, 10, 10))
		self:SetColor(Vector(255, 0, 0))
	end
end

function ENT:SpawnFunction(ply, tr, ClassName)
	if (not tr.Hit) then return end
	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 20)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel("")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:DrawShadow(false)
	self:EnableCustomCollisions(true)
	self:RebuildPhysics()
	-- if CLIENT then
	--     self.Axis= ents.CreateClientside("slr_edithelper_axis")
	-- else
	--     self.Axis= ents.Create("slr_edithelper_axis")
	--     self.Axis:Setup(self)
	--     util.AddNetworkString("slr_corners")
	-- end
	-- self.Axis:Spawn()
end

function ShouldBoxCollide(ent1, ent2)
	if (ent1 == "slr_editablebox" or ent2 == "slr_editablebox") then return false end
end

hook.Add("ShouldCollide", "slr_boxnocollide", ShouldBoxCollide)

function EditableBoxPhysgunPickup(ply, entity)
	if (entity.ClassName == "slr_editablebox") then
		return false
	else
		return true
	end
end

hook.Add("PhysgunPickup", "slr_nopickup", EditableBoxPhysgunPickup)

function ENT:RebuildFaces()
	local maxBoundTable = {
		x = self:GetMaxBound().x,
		y = self:GetMaxBound().y,
		z = self:GetMaxBound().z
	}

	local minBoundTable = {
		x = self:GetMinBound().x,
		y = self:GetMinBound().y,
		z = self:GetMinBound().z
	}

	for i = 0, 7 do
		local x = bit.band(i, 1) == 0 and maxBoundTable.x or minBoundTable.x
		local y = bit.band(i, 2) == 0 and maxBoundTable.y or minBoundTable.y
		local z = bit.band(i, 4) == 0 and maxBoundTable.z or minBoundTable.z
		self["SetCorner" .. (bit.band(i, 4) == 0 and "x1" or "x2") .. (bit.band(i, 2) == 0 and "y1" or "y2") .. (bit.band(i, 1) == 0 and "z1" or "z2")](self, Vector(x, y, z))
		self.Corners[i + 1] = Vector(x, y, z)
	end

	if (self.Faces) then
		for k, v in pairs(self.Faces) do
			if (v.Entity) then
				v.Entity:Remove()
			end
		end
	end

	self.Faces = {{self.Corners[1], self.Corners[4]}, {self.Corners[1], self.Corners[6]}, {self.Corners[1], self.Corners[7]}, {self.Corners[8], self.Corners[2]}, {self.Corners[8], self.Corners[3]}, {self.Corners[8], self.Corners[5]}} --14 16 17 82 83 85 --Down --Back --Left --Right --Fowards --Up

	for i, v in pairs(self.Faces) do
		v.Entity = ents.Create("slr_editface")
		v.Entity:SetParent(self)
		v.Entity:SetPos(self:GetPos() + LerpVector(.5, v[1], v[2]))
		v.Entity:Spawn()
		v.Entity:Setup(v[1], v[2])
		v.Entity.index = i
	end
end

function ENT:RebuildPhysics(MinBound, MaxBound)
	if SERVER then
		MinBound = MinBound or self:GetMinBound()
		MaxBound = MaxBound or self:GetMaxBound()
		self.PhysCollide = CreatePhysCollideBox(MinBound, MaxBound)
		self:SetCollisionBounds(MinBound, MaxBound)
		self:SetGravity(0)

		if SERVER then
			self:PhysicsInitBox(MinBound, MaxBound)
			self:SetSolid(SOLID_BBOX)
		end

		self:EnableCustomCollisions(true)
		self:DrawShadow(false)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Think()
	if (self:GetPhysicsObject() and self:GetPhysicsObject():IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	if (SERVER) then return end
	self:SetRenderBounds(self:GetMinBound(), self:GetMaxBound())
end

function ENT:OnBoundsChanged(varname, oldvalue, newvalue)
	if SERVER then
		newvalue.x = (math.abs(newvalue.x) == 0) and (varname == "MinBound" and -0.01 or 0.01) or newvalue.x
		newvalue.y = (math.abs(newvalue.y) == 0) and (varname == "MinBound" and -0.01 or 0.01) or newvalue.y
		newvalue.z = (math.abs(newvalue.z) == 0) and (varname == "MinBound" and -0.01 or 0.01) or newvalue.z

		if (varname == "MinBound") then
			self:RebuildPhysics(newvalue, self:GetMaxBound())

			if (self.ToolgunParent) then
				self.ToolgunParent:UpdateCurrentBoxP2(self:GetPos() + newvalue)
			end
		elseif (varname == "MaxBound") then
			self:RebuildPhysics(self:GetMinBound(), newvalue)

			if (self.ToolgunParent) then
				self.ToolgunParent:UpdateCurrentBoxP1(self:GetPos() + newvalue)
			end
		end

		self:RebuildFaces()
	end
end

function ENT:TestCollision(startpos, delta, isbox, extents)
	return nil
end

function ENT:Draw()
	local vec1, vec2 = self:GetCollisionBounds()
	local rbVec1, rbVec2 = self:GetRenderBounds()
	cam.Start3D()
	render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self:GetMinBound(), self:GetMaxBound(), self:GetColor())
	render.DrawWireframeSphere(self:GetPos(), 5, 10, 10, Color(0, 100, 255))
	render.DrawWireframeSphere(self:GetPos() + self:GetMinBound(), 5, 10, 10, Color(255, 0, 0))
	render.DrawWireframeSphere(self:GetPos() + self:GetMaxBound(), 5, 10, 10, Color(0, 255, 0))
	-- for i=0,7 do
	--     render.DrawWireframeSphere(self["GetCorner"..(bit.band(i,4)==0 and "x1"or"x2")..(bit.band(i,2)==0 and"y1"or"y2")..(bit.band(i,1)==0 and "z1"or"z2")](self)+self:GetPos(),5,10,10)
	-- end
	cam.End3D()
end