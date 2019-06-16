AddCSLuaFile()
ENT.Author="Sarcly & Intox"
ENT.PrintName="Zone 3"
ENT.Category="Sledrace!"
ENT.Spawnable = true
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
ENT.Faces = {}
ENT.Corners = {}
ENT.SmallestSide = math.huge

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 100

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
    ent:Spawn()
    ent:Activate()
    ent:SetOwner(ply)
	return ent

end

function ENT:Initialize()
    self:SetModel("")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:EnableCustomCollisions(true)
    if CLIENT then
        self:Setup()
    end
end

function ENT:Setup(topFrontLeft,bottomBackRight)
    topFrontLeft = topFrontLeft and topFrontLeft or Vector(50,50,50)
    bottomBackRight = bottomBackRight and bottomBackRight or Vector(-50,-50,-50)
    self.topFrontLeft=topFrontLeft
    self.bottomBackRight=bottomBackRight
    self:UpdateFaces()

end

function ENT:MakeFaces()
    for i = 1,6 do
        self.Faces[i] = ents.CreateClientside("slr_zoneface2")
        self.Faces[i]:SetOwner(self:GetOwner())
        self.Faces[i]:Spawn()
        self.Faces[i]:SetParent(self)
        self.Faces[i].index = i
        -- self.Faces[i]:SetParent(self)
    end
end

function ENT:UpdateFaces()
    if(#self.Faces==0) then
        self:MakeFaces()
    end
    self.SmallestSide=math.huge
    self:GetCorners()
    self.FacesCorners = {{self.Corners[3], self.Corners[5], self.Corners[1], self.Corners[7]}, {self.Corners[4], self.Corners[1], self.Corners[2], self.Corners[3]}, {self.Corners[8], self.Corners[2], self.Corners[6], self.Corners[4]}, {self.Corners[7], self.Corners[6], self.Corners[5], self.Corners[8]}, {self.Corners[4], self.Corners[7], self.Corners[3], self.Corners[8]}, {self.Corners[1], self.Corners[6], self.Corners[3], self.Corners[5]}}
    for i = 1, 6 do
        print("corners",self:GetPos()+self.FacesCorners[i][1],self:GetPos()+self.FacesCorners[i][2])
        self.Faces[i]:UpdateCorners(self.FacesCorners[i][1], self.FacesCorners[i][2])
        local copycorner1 = Vector(self.Faces[i].P1.x, self.Faces[i].P1.y, self.Faces[i].P1.z)
        local copycorner2 = Vector(self.Faces[i].P2.x, self.Faces[i].P2.y, self.Faces[i].P2.z)
        OrderVectors(copycorner1, copycorner2)
        self.Faces[i]:SetPos(LerpVector(0.5,copycorner1,copycorner2))
        print(self.Faces[i]:GetPos())
        local diff = copycorner2 - copycorner1
        local shortest_side = math.min(diff.x ~= 0 and diff.x or diff.y, diff.y ~= 0 and diff.y or diff.x, diff.z ~= 0 and diff.z or diff.x)

        if (self.SmallestSide > shortest_side) then
            self.SmallestSide = shortest_side
        end

        self.Faces[i]:SetColor(Color(bit.band(i, 4) * 255, bit.band(i, 2) * 255, bit.band(i, 1) * 255, 40))
    end
end

function ENT:GetCorners()
	local MaxBound = Vector()
    local MinBound = Vector()
    MaxBound:Set(self.topFrontLeft)
    MinBound:Set(self.bottomBackRight)
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

	for i = 0, 7 do
		local x = bit.band(i, 1) == 0 and MaxBound.x or MinBound.x
		local y = bit.band(i, 2) == 0 and MaxBound.y or MinBound.y
		local z = bit.band(i, 4) == 0 and MaxBound.z or MinBound.z
		self.Corners[i + 1] = Vector(x, y, z)
	end

end

function ENT:DrawTranslucent()
    cam.Start3D()
        render.DrawWireframeSphere(self:GetPos(), 5,10,10)
        --render.DrawWireframeBox(self:GetPos(),self:GetAngles(),self.topFrontLeft, self.bottomBackRight)
    cam.End3D()
end
