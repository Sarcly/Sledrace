AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local Locations = {
	start={},
	build={},
    finish={},
    wall={},
	track={}
}

GM.Zones = nil

function GM:Initialize()
    if(file.Exists("sledrace/"..game.GetMap()..".txt","DATA")) then
        local fileContents = file.Read("sledrace/"..game.GetMap()..".txt","DATA")
        zones = util.JSONToTable(fileContents)
        for k,v in pairs(zones) do
            for k1,v1 in pairs(zones[k]) do
                if(#v1==0) then 
                    zones[k][k1] = nil
                end
            end
        end
        for k,v in pairs(Locations) do
            if(not zones[k] or #zones[k]==0) then
                for j,ply in pairs(player.GetAll()) do
                    ply:SendLua("notification.AddLegacy(\"Malformed Map Config\",NOTIFY_ERROR,15)")
                end
                return
            end
        end
        self.Zones = zones
        for j,ply in pairs(player.GetAll()) do
            ply:SendLua("notification.AddLegacy(\"Successfully Loaded Map Config\",NOTIFY_GENERIC,15)")
        end
    else
        for j,ply in pairs(player.GetAll()) do
            ply:SendLua("notification.AddLegacy(\"Missing Map Config\",NOTIFY_GENERIC,15)")
        end
    end
end

function GM:Tick()
    if(self.Zones) then
        for k,v in pairs(self.Zones) do
            -- table of tables of box coords
            for k1, v1 in pairs(v) do
                -- find players in each box segment of category, i.e. build -> 3 build boxes -> check all 3
                local entsInBox = ents.FindInBox(v1[1], v1[2])
                for i, ent in pairs(entsInBox) do
                    if(ent:IsPlayer()) then
                        ent.InZone=k
                    end
                end
            end
        end
        for i, ply in pairs(player.GetAll()) do
            if(ply.InZone=="start") then

            end
        end
    end
end

function GM:PlayerSay(sender, text, teamChat)
    if(string.StartWith(text,"!wall")) then
        --if(self.Zones.wall) then
            -- self.Wall = ents.Create("prop_physics")
            -- self.Wall:SetModel("models/props_lab/blastdoor001a.mdl")
            -- self.Wall:SetPos(Vector(self.Zones.wall[1][1][1],self.Zones.wall[1][1][2],self.Zones.wall[1][1][3]))
            -- local minVector = Vector()
            -- PrintTable(self.Zones.wall)
            -- local maxVector1 = Vector(self.Zones.wall[1][2][1],self.Zones.wall[1][2][2],self.Zones.wall[1][2][3])
            -- local maxVector2 = Vector(self.Zones.wall[1][1][1],self.Zones.wall[1][1][2],self.Zones.wall[1][1][3])
            -- local maxVector = maxVector1-maxVector2
            -- self.Wall:PhysicsInitBox(minVector,maxVector)
            -- self.Wall:Spawn()
            -- self.Wall:SetCollisionGroup(COLLISION_GROUP_PLAYER)
            local tr = sender:GetEyeTrace()
            self.Wall =  ents.Create("slr_wall")
            self.Wall:SetPos( tr.HitPos + tr.HitNormal)
            self.Wall:Spawn()
            self.Wall:Activate()
            --self.Wall:SetWallData(self.Zones.wall)
            self.Wall:SetWallData({{Vector(30,30,30),Vector(90,90,90)}})
       -- end
    end 
    return text
end