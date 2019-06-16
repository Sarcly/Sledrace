AddCSLuaFile()
ENT.Author = "Sarcly & Intox"
ENT.Category = "Sledrace!"
ENT.Spawnable = false
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Faces = {{}, {}, {}, {}, {}, {}}
ENT.Corners = {}
ENT.FacesCorners = {}

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "MinBound")
	self:NetworkVar("Vector", 1, "MaxBound")
	self:NetworkVar("Float", 0, "SmallestSide")

	if SERVER then
		self:SetSmallestSide(math.huge)
	end
end

function ENT:Initialize()
	self:SetModel("")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:DrawShadow(false)
	self:EnableCustomCollisions(true)
end

function ENT:UpdateZone(MinBound, MaxBound)
	self:SetMinBound(MinBound)
	self:SetMaxBound(MaxBound)
	local midpoint = LerpVector(.5, MinBound, MaxBound)
	self:SetPos(midpoint)
	self:UpdateFaces()
end

function ENT:Think()
	if SERVER then
	elseif CLIENT then
		self:SetRenderBoundsWS(self:GetMinBound(), self:GetMaxBound())
	end
end

function ENT:UpdateFaces()
	if CLIENT then
		self:SetSmallestSide(math.huge)
		self:GetCorners()
		self.FacesCorners = {{self.Corners[3], self.Corners[5], self.Corners[1], self.Corners[7]}, {self.Corners[4], self.Corners[1], self.Corners[2], self.Corners[3]}, {self.Corners[8], self.Corners[2], self.Corners[6], self.Corners[4]}, {self.Corners[7], self.Corners[6], self.Corners[5], self.Corners[8]}, {self.Corners[4], self.Corners[7], self.Corners[3], self.Corners[8]}, {self.Corners[1], self.Corners[6], self.Corners[3], self.Corners[5]}}

		if IsTableOfEntitiesValid(self.Faces) then
			for i = 1, 6 do
				self.Faces[i]:UpdateCorners(self.FacesCorners[i][1], self.FacesCorners[i][2], self.FacesCorners[i][3], self.FacesCorners[i][4])
				local copycorner1 = Vector(self.Faces[i]:GetCornerP1().x, self.Faces[i]:GetCornerP1().y, self.Faces[i]:GetCornerP1().z)
				local copycorner2 = Vector(self.Faces[i]:GetCornerP2().x, self.Faces[i]:GetCornerP2().y, self.Faces[i]:GetCornerP2().z)
				OrderVectors(copycorner1, copycorner2)
				local diff = copycorner2 - copycorner1
				local shortest_side = math.min(diff.x ~= 0 and diff.x or diff.y, diff.y ~= 0 and diff.y or diff.x, diff.z ~= 0 and diff.z or diff.x)

				if (self:GetSmallestSide() > shortest_side) then
					self:SetSmallestSide(shortest_side)
				end
			end
		else
			for i = 1, 6 do
				if (SERVER) then
					self.Faces[i] = ents.Create("slr_zoneface")
				elseif (CLIENT) then
					self.Faces[i] = ents.CreateClientside("slr_zoneface")
				end

				self.Faces[i]:SetOwner(self:GetOwner())
				self.Faces[i]:Spawn()
				self.Faces[i]:SetIndex(i)
				self.Faces[i]:SetParent(self)
				self.Faces[i]:UpdateCorners(self.FacesCorners[i][1], self.FacesCorners[i][2], self.FacesCorners[i][3], self.FacesCorners[i][4])
				local copycorner1 = Vector(self.Faces[i]:GetCornerP1().x, self.Faces[i]:GetCornerP1().y, self.Faces[i]:GetCornerP1().z)
				local copycorner2 = Vector(self.Faces[i]:GetCornerP2().x, self.Faces[i]:GetCornerP2().y, self.Faces[i]:GetCornerP2().z)
				OrderVectors(copycorner1, copycorner2)
				local diff = copycorner2 - copycorner1
				local shortest_side = math.min(diff.x ~= 0 and diff.x or diff.y, diff.y ~= 0 and diff.y or diff.x, diff.z ~= 0 and diff.z or diff.x)

				if (self:GetSmallestSide() > shortest_side) then
					self:SetSmallestSide(shortest_side)
				end

				self.Faces[i]:SetColor(Color(bit.band(i, 4) * 255, bit.band(i, 2) * 255, bit.band(i, 1) * 255, 40))
			end
		end

		for i = 1, 6 do
			self.Faces[i]:UpdateAdjacentMidpoints()
		end
	end
end

function ENT:GetCorners()
	local MaxBound = Vector(self:GetMaxBound().x, self:GetMaxBound().y, self:GetMaxBound().z)
	local MinBound = Vector(self:GetMinBound().x, self:GetMinBound().y, self:GetMinBound().z)
	OrderVectors(MaxBound, MinBound)

	local maxBoundTable = {
		x = MaxBound.x,
		y = MaxBound.y,
		z = MaxBound.z
	}

	local minBoundTable = {
		x = MinBound.x,
		y = MinBound.y,
		z = MinBound.z
	}

	local corners = {}

	for i = 0, 7 do
		local x = bit.band(i, 1) == 0 and maxBoundTable.x or minBoundTable.x
		local y = bit.band(i, 2) == 0 and maxBoundTable.y or minBoundTable.y
		local z = bit.band(i, 4) == 0 and maxBoundTable.z or minBoundTable.z
		self.Corners[i + 1] = Vector(x, y, z)
	end

	return self.Corners
end

function ENT:GetFaceMidpoint(index)
	local face = self.Faces[index]
	local midpoint = LerpVector(0.5, face:GetCornerP1(), face:GetCornerP2())

	return midpoint
end

function ENT:ToggleDrawDir()
	for i = 1, 6 do
		if self.Faces[i]:GetDrawDir() then
			self.Faces[i]:SetDrawDir(false)
		else
			self.Faces[i]:SetDrawDir(true)
		end
	end
end

function ENT:Draw()
	cam.Start3D()
	render.DrawWireframeBox(Vector(), self:GetAngles(), self:GetMinBound(), self:GetMaxBound())
	render.DrawWireframeSphere(self:GetMaxBound(), 10, 10, 10, Color(0, 255, 0))
	render.DrawWireframeSphere(self:GetMinBound(), 10, 10, 10, Color(255, 0, 0))
	cam.End3D()
end