AddCSLuaFile()
include("modules/slr_matrix.lua")
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.Category = "Sledrace!"
ENT.Author = "Sarcly & Intox"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--[[
    L L ADJ F = 1-> 5
    L T ADJ U = 1-> 4
    L R ADJ B = 1-> 6
    L B ADJ D = 1-> 2
    
    R L ADJ B = 3-> 6
    R T ADJ U = 3-> 4
    R R ADJ F = 3-> 5
    R B ADJ D = 3-> 2

    F L ADJ R = 5-> 3
    F T ADJ U = 5-> 4
    F R ADJ L = 5-> 1
    F B ADJ D = 5-> 2
    
    U L ADJ L = 4-> 1
    U T ADJ F = 4-> 5
    U R ADJ R = 4-> 3
    U B ADJ B = 4-> 6

    B L ADJ L = 6-> 1
    B T ADJ U = 6-> 4
    B R ADJ R = 6-> 3
    B B ADJ D = 6-> 2

    D L ADJ R = 2-> 3
    D T ADJ F = 2-> 5
    D R ADJ L = 2-> 1
    D B ADJ B = 2-> 6
]]
-- ACCESS ADJACENT FACE INDEX IN ORDER OF FACE_ENUMS, GOES LEFT EDGE TOP EDGE RIGHT EDGE BOTTOM EDGE
ENT.AdjacentEdges = {{5, 4, 6, 2}, {3, 5, 1, 6}, {6, 4, 5, 2}, {1, 5, 3, 6}, {3, 4, 1, 2}, {1, 4, 3, 2}}
ENT.FACE_ENUMS = {"ZONE_LEFT", "ZONE_DOWN", "ZONE_RIGHT", "ZONE_UP", "ZONE_FORWARD", "ZONE_BACK"}
ENT.FACE_ANGLES = {Angle(0, -90, 90), Angle(180, 0, 0), Angle(0, 90, 90), Angle(0, 0, 0), Angle(180, 0, -90), Angle(0, 0, 90)}
ENT.FACE_ANGLES_MIRROR = {Angle(0, 90, 90), Angle(0, 0, 0), Angle(0, -90, 90), Angle(180, 0, 0), Angle(0, 0, 90), Angle(180, 0, -90)}
ENT.SmallestFaceSizeCL = 0

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "CornerP1")
	self:NetworkVar("Vector", 1, "CornerP2")
	self:NetworkVar("Vector", 2, "CornerP3")
	self:NetworkVar("Vector", 3, "CornerP4")
	self:NetworkVar("Vector", 4, "LMidpoint")
	self:NetworkVar("Vector", 5, "TMidpoint")
	self:NetworkVar("Vector", 6, "RMidpoint")
	self:NetworkVar("Vector", 7, "BMidpoint")
	self:NetworkVar("Int", 0, "Index")
	self:NetworkVar("Int", 1, "PrincipalAxis")
	self:NetworkVar("Bool", 0, "DrawDir")
end

-- Corners are relative to parent's GetPos (box center)
-- P1=top left P2=bottom right P3=bottom left P4=top right
function ENT:UpdateCorners(P1, P2, P3, P4)
	local P1_C = Vector()
	P1_C:Set(P1)
	local P2_C = Vector()
	P2_C:Set(P2)
	local P3_C = Vector()
	P3_C:Set(P3)
	local P4_C = Vector()
	P4_C:Set(P4)
	local principle_axis = P1.x == P2.x and "x" or (P1.y == P2.y and "y" or "z")
	self:SetPrincipalAxis(principle_axis == "x" and 1 or (principle_axis == "y" and 2 or 3))
	self:SetCornerP1(P1_C)
	self:SetCornerP2(P2_C)
	self:SetCornerP3(P3_C)
	self:SetCornerP4(P4_C)
	OrderVectors(P1_C, P2_C)
	self.PhysCollide = CreatePhysCollideBox(P1_C, P2_C + Vector(1, 1, 1))
	print("PHYSCOLLIDE IS...",self.PhysCollide)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetCollisionBounds(P1_C, P2_C)
	self:EnableCustomCollisions(true)
end

function ENT:UpdateAdjacentMidpoints()
	for i = 1, 4 do
		local currentfaceindex = self.AdjacentEdges[self:GetIndex()][i]
		local midpoint = self:GetOwner():GetFaceMidpoint(currentfaceindex)
		self["Set" .. (i == 1 and "L" or (i == 2 and "T" or (i == 3 and "R" or "B"))) .. "Midpoint"](self, midpoint)
	end
end

function ENT:Initialize()
	self:SetModel("")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self:SetDrawDir(false)
end

function ENT:Think()
	if(!IsValid(self:GetOwner())) then
		print(self.PhysCollide)
		self:Remove()
		print("removing..")
	end
	if CLIENT then
		self:SetRenderBoundsWS(self:GetCornerP1(), self:GetCornerP2() + Vector(1, 1, 1))
	end
end

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
	return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac,
		Entity = self
	}
end

function ENT:DrawTranslucent()
	-- if self:GetDrawDir() then
		local copycorner1 = Vector(self:GetCornerP1().x, self:GetCornerP1().y, self:GetCornerP1().z)
		local copycorner2 = Vector(self:GetCornerP2().x, self:GetCornerP2().y, self:GetCornerP2().z) + Vector(1, 1, 1)
		local temp = self:GetOwner():GetSmallestSide()
		cam.Start3D()
		render.SetColorMaterial()
		render.DrawBox(Vector(), Angle(0, 0, 0), self:GetCornerP1(), self:GetCornerP2(), self:GetColor(), true)
		cam.End3D()
		cam.Start3D2D(LerpVector(.5, copycorner1, copycorner2), self.FACE_ANGLES[self:GetIndex()], 1) --Draws the letters for direction on the outside face
		surface.SetMaterial(Material("materials/face" .. self:GetIndex() .. ".png"))
		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawTexturedRect(-temp / 2, -temp / 2, temp, temp)
		cam.End3D2D()
		cam.Start3D2D(LerpVector(.5, copycorner1, copycorner2), self.FACE_ANGLES_MIRROR[self:GetIndex()], 1) --Draws the letters for directions on the inside face 
		surface.SetMaterial(Material("materials/face" .. self:GetIndex() .. ".png"))
		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawTexturedRect(-temp / 2, -temp / 2, temp, temp)
		cam.End3D2D()
	-- end
end

function VectorToTable(vec)
	return {vec.x, vec.y, vec.z}
end

function PickupEditableFace(ply, ent)
	if (ent.ClassName == "slr_zoneface") then return false end
end

hook.Add("PhysgunPickup", "slr_PickupEditableFace", PickupEditableFace)