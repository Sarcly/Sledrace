-- -- TOOL.Category = "Sledrace!"
-- -- TOOL.Name = "#tool.slr_zonetool3.name"
-- -- TOOL.Command = "gmod_toolmode slr_zonetool3"
-- -- TOOL.OpList = {"Loading", "Create Mode", "Edit Mode"}

-- TOOL.CurrentBox = {
-- 	Min = nil,
-- 	Max = nil,
-- 	Ent = nil
-- }

-- TOOL.ToolNameHeight = 0
-- TOOL.InfoBoxHeight = 0
-- TOOL.KeepNoHUDCL = false

-- function TOOL:Holster()
-- 	if SERVER then
-- 		self:SetOperation(0)
-- 	elseif CLIENT then
-- 		self:SetOperation(0)

-- 		if (IsValid(self.CurrentBox.Ent)) then
-- 			self.CurrentBox.Ent:Remove()
-- 		end

-- 		if not self.KeepNoHUDCL then
-- 			GetConVar("gmod_drawhelp"):SetInt(1)
-- 		end
-- 	end
-- end

-- function TOOL:LeftClick(tr)
-- 	if self:GetOperation() == 1 then
-- 		self.CurrentBox.Min = self:GetOwner():GetPos()
-- 		if (self.CurrentBox.Min and self.CurrentBox.Max) then
-- 			self:UpdateEnt()
-- 		end
-- 	elseif self:GetOperation() == 2 then

-- 	end
-- end

-- function TOOL:RightClick(tr)
-- 	if self:GetOperation() == 1 then
-- 		self.CurrentBox.Max = self:GetOwner():GetPos()

-- 		if (self.CurrentBox.Min and self.CurrentBox.Max) then
-- 			self:UpdateEnt()
-- 		end
-- 	elseif self:GetOperation() == 2 then
-- 	end
-- end

-- function TOOL:Reload(tr)
-- 	if SERVER then
-- 		self:UpdateMode()
-- 	end
-- end

-- function TOOL:UpdateMode()
-- 	if SERVER then
-- 		if self:GetOperation() == 0 then
-- 			self:SetOperation(1)
-- 		elseif self:GetOperation() < #self.OpList - 1 then
-- 			self:SetOperation(self:GetOperation() + 1)
-- 		elseif self:GetOperation() >= #self.OpList - 1 then
-- 			self:SetOperation(1)
-- 		end
-- 	end
-- end

-- function TOOL:SpawnEnt()
-- 	if CLIENT then
-- 		self.CurrentBox.Ent = ents.CreateClientside("slr_zone")
-- 	elseif SERVER then
-- 		self.CurrentBox.Ent = ents.Create("slr_zone")
-- 	end

-- 	local midpoint = LerpVector(.5, self.CurrentBox.Min, self.CurrentBox.Max)
-- 	self.CurrentBox.Ent:SetPos(midpoint)
-- 	self.CurrentBox.Ent:Spawn()
-- 	self.CurrentBox.Ent:UpdateZone(self.CurrentBox.Min, self.CurrentBox.Max)
-- end

-- function TOOL:UpdateEnt()
-- 	if SERVER then end

-- 	if (not IsValid(self.CurrentBox.Ent)) then
-- 		self:SpawnEnt()
-- 	else
-- 		self.CurrentBox.Ent:UpdateZone(self.CurrentBox.Min, self.CurrentBox.Max)
-- 	end
-- end

-- function TOOL:Think()
-- 	--Server Side think
-- 	if SERVER then
-- 		--Operation 0 acts as a loading time while we wait to spawn everything and get the tool ready for the player to use
-- 		if (self:GetOperation() == 0) then
-- 			--DO SETUP HERE
-- 			self:UpdateMode()
-- 		end

-- 		if (self:GetOperation() == 2) then end
-- 		--[[
-- 				extend the plane perpindicular to the face's primary plane in the vertical axis-> see where player's trace intersects the plane = hit vector
-- 				hitvector-face's worldspace center position is the distance to pull entity
-- 			]]
-- 		-- local dist = util.DistanceToLine(self:GetOwner():EyePos(), tr.HitPos,edgemidpoint) -- --local component_dist = dist[self.LookingAtFace:GetPrincipalAxis()==1 and "x" or (self.LookingAtFace:GetPrincipalAxis()==2 and "y" or "z")] -- --print(component_dist) -- local axis_vector = Vector(self.LookingAtFace:GetPrincipalAxis()==1 and dist or 0,self.LookingAtFace:GetPrincipalAxis()==2 and dist or 0,self.LookingAtFace:GetPrincipalAxis()==3 and dist or 0)
-- 	else
-- 		if (IsValid(self.LookingAtFace)) then
-- 			self.LookingAtFace = nil
-- 		end

-- 		if (self:GetOperation() == 0) then
-- 			if GetConVar("gmod_drawhelp"):GetInt() == 0 then
-- 				self.KeepNoHUDCL = true
-- 			end

-- 			if not self.KeepNoHUDCL then
-- 				GetConVar("gmod_drawhelp"):SetInt(0) --We need to draw the custom version of the toolgun HUD, so stop drawing the default one
-- 			end
-- 		end
-- 	end

-- 	if (self:GetOperation() == 2) then
-- 		if (self:GetOwner():KeyDown(IN_ATTACK)) then
-- 			if CLIENT then
-- 				local tr = self:GetOwner():GetEyeTrace()
-- 				--PrintTable(tr)

-- 				if (tr.Entity.ClassName == "slr_zoneface" and not self.LookingAtFace) then
-- 					print("setting face....")
-- 					self.LookingAtFace = tr.Entity
-- 				end

-- 				if (IsValid(self.LookingAtFace)) then
-- 					for i = 1, 4 do
-- 						local adjfacemidpoint = self.LookingAtFace["Get" .. (i == 1 and "L" or (i == 2 and "T" or (i == 3 and "R" or "B"))) .. "Midpoint"](self.LookingAtFace)
-- 						local planeNorm = adjfacemidpoint - LerpVector(0.5, self.CurrentBox.Ent:GetMinBound(), self.CurrentBox.Ent:GetMaxBound())
-- 						planeNorm = planeNorm:GetNormalized()
-- 						local edgemidpoint = Vector()

-- 						if (i == 1) then
-- 							edgemidpoint = LerpVector(0.5, self.LookingAtFace:GetCornerP1(), self.LookingAtFace:GetCornerP3())
-- 						elseif (i == 2) then
-- 							edgemidpoint = LerpVector(0.5, self.LookingAtFace:GetCornerP1(), self.LookingAtFace:GetCornerP4())
-- 						elseif (i == 3) then
-- 							edgemidpoint = LerpVector(0.5, self.LookingAtFace:GetCornerP4(), self.LookingAtFace:GetCornerP2())
-- 						elseif (i == 4) then
-- 							edgemidpoint = LerpVector(0.5, self.LookingAtFace:GetCornerP3(), self.LookingAtFace:GetCornerP2())
-- 						end

-- 						local result = util.IntersectRayWithPlane(self:GetOwner():EyePos(), self:GetOwner():GetAimVector(), edgemidpoint, planeNorm)

-- 						if (result) then
-- 							local axisnum = self.LookingAtFace:GetPrincipalAxis()
-- 							local distVector = result - edgemidpoint
-- 							print(i, distVector)
-- 							local axisAdjustedVector = Vector(axisnum == 1 and distVector.x or 0, axisnum == 2 and distVector.y or 0, axisnum == 3 and distVector.z or 0) * (1 / 1000)

-- 							if (self.LookingAtFace:GetIndex() == 5 or self.LookingAtFace:GetIndex() == 1 or self.LookingAtFace:GetIndex() == 2) then
-- 								self.CurrentBox.Ent:SetMinBound(self.CurrentBox.Ent:GetMinBound() + axisAdjustedVector)
-- 								-- self.CurrentBox.Ent:SetMaxBound(self.CurrentBox.Ent+dist[self.LookingAtFace:GetPrincipalAxis()==1 and "x" or ])
-- 							else
-- 								self.CurrentBox.Ent:SetMaxBound(self.CurrentBox.Ent:GetMaxBound() + axisAdjustedVector)
-- 							end

-- 							self.CurrentBox.Ent:UpdateFaces()
-- 							break
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

-- --CLIENT ONLY
-- function TOOL:DrawToolScreen(width, height)
-- 	surface.SetDrawColor(Color(20, 20, 20))
-- 	surface.DrawRect(0, 0, width, height)
-- 	draw.SimpleText(self.OpList[self:GetOperation() + 1], "GModToolScreen", width / 2, height / 4, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- end

-- --CLIENT ONLY
-- function TOOL:DrawHUD()
-- 	if self.KeepNoHUDCL then return end
-- 	--Small rewrite of the sandbox STool draw HUD because I wanted to be able to use shift and ctrl as modifier keys for keybinds. Im very extra
-- 	local mode = "slr_zonetool3"
-- 	if (not self) then return end
-- 	local x, y = 50, 40
-- 	local w, h = 0, 0
-- 	local TextTable = {}
-- 	local QuadTable = {}
-- 	--Draws the gradient under the tool name and description
-- 	QuadTable.texture = surface.GetTextureID("gui/gradient")
-- 	QuadTable.color = Color(10, 10, 10, 180)
-- 	QuadTable.x = 0
-- 	QuadTable.y = y - 8
-- 	QuadTable.w = 600
-- 	QuadTable.h = self.ToolNameHeight - (y - 8)
-- 	draw.TexturedQuad(QuadTable)
-- 	--Draws the tool name text
-- 	TextTable.font = "GModToolName"
-- 	TextTable.color = Color(240, 240, 240, 255)
-- 	TextTable.pos = {x, y}
-- 	TextTable.text = "#tool." .. mode .. ".name"
-- 	w, h = draw.TextShadow(TextTable, 2)
-- 	y = y + h
-- 	--Draws the description text
-- 	TextTable.font = "GModToolSubtitle"
-- 	TextTable.pos = {x, y}
-- 	TextTable.text = "#tool." .. mode .. ".desc"
-- 	w, h = draw.TextShadow(TextTable, 1)
-- 	y = y + h + 8
-- 	self.ToolNameHeight = y
-- 	--Draws gradient under the info
-- 	QuadTable.y = y
-- 	QuadTable.h = self.InfoBoxHeight
-- 	local alpha = math.Clamp(255 + (self.LastMessage - CurTime()) * 800, 10, 255)
-- 	QuadTable.color = Color(alpha, alpha, alpha, 230)
-- 	draw.TexturedQuad(QuadTable)
-- 	y = y + 4
-- 	TextTable.font = "GModToolHelp"

-- 	if (not self.Information) then
-- 		TextTable.pos = {x + self.InfoBoxHeight, y}
-- 		TextTable.text = self:GetHelpText()
-- 		w, h = draw.TextShadow(TextTable, 1)
-- 		surface.SetDrawColor(255, 255, 255, 255)
-- 		surface.SetTexture(surface.GetTextureID("gui/info"))
-- 		surface.DrawTexturedRect(x + 1, y + 1, h - 3, h - 3)
-- 		self.InfoBoxHeight = h + 8

-- 		return
-- 	end

-- 	local h2 = 0

-- 	--Loop over all entrys in Information and populate them
-- 	for k, v in pairs(self.Information) do
-- 		-- If element of Information is just a string then make it a table containg the string in name ("string"->{name="string"})
-- 		if (type(v) == "string") then
-- 			v = {
-- 				name = v
-- 			}
-- 		end

-- 		if (not v.name) then continue end --If no name then skip
-- 		if (v.stage and v.stage ~= self:GetStage()) then continue end --If stage if not correct then skip
-- 		if (v.op and v.op ~= self:GetOperation()) then continue end --If operation not correct then skip
-- 		local txt = "#tool." .. GetConVarString("gmod_toolmode") .. "." .. v.name

-- 		if (v.name == "info") then
-- 			txt = self:GetHelpText()
-- 		end

-- 		TextTable.text = txt
-- 		TextTable.pos = {x + 21, y + h2}
-- 		w, h = draw.TextShadow(TextTable, 1)

-- 		--Shortcuts for icons in info space
-- 		if (not v.icon) then
-- 			if (v.name:StartWith("info")) then
-- 				v.icon = "gui/info"
-- 			end

-- 			if (v.name:StartWith("left")) then
-- 				v.icon = "gui/lmb.png"
-- 			end

-- 			if (v.name:StartWith("right")) then
-- 				v.icon = "gui/rmb.png"
-- 			end

-- 			if (v.name:StartWith("reload")) then
-- 				v.icon = "gui/r.png"
-- 			end

-- 			if (v.name:StartWith("use")) then
-- 				v.icon = "gui/e.png"
-- 			end
-- 		end

-- 		if (not v.icon2) then
-- 			if (not v.name:StartWith("use") and v.name:EndsWith("use")) then
-- 				v.icon2 = "gui/e.png"
-- 			end

-- 			--added shift to modifer keys
-- 			if (not v.name:StartWith("shift") and v.name:EndsWith("shift")) then
-- 				v.icon2 = "materials/shift.png"
-- 			end

-- 			--added ctrl to modifer keys
-- 			if (not v.name:StartWith("ctrl") and v.name:EndsWith("ctrl")) then
-- 				v.icon2 = "materials/ctrl.png"
-- 			end
-- 		end

-- 		self.Icons = self.Icons or {}

-- 		if (v.icon and not self.Icons[v.icon]) then
-- 			self.Icons[v.icon] = Material(v.icon)
-- 		end

-- 		if (v.icon2 and not self.Icons[v.icon2]) then
-- 			self.Icons[v.icon2] = Material(v.icon2)
-- 		end

-- 		if (v.icon and self.Icons[v.icon] and not self.Icons[v.icon]:IsError()) then
-- 			surface.SetDrawColor(255, 255, 255, 255)
-- 			surface.SetMaterial(self.Icons[v.icon])
-- 			surface.DrawTexturedRect(x, y + h2, 16, 16) --Icon1 draw (must be 16x16 png)
-- 		end

-- 		if (v.icon2 and self.Icons[v.icon2] and not self.Icons[v.icon2]:IsError()) then
-- 			surface.SetDrawColor(255, 255, 255, 255)
-- 			surface.SetMaterial(self.Icons[v.icon2])
-- 			surface.DrawTexturedRect(x - (11 + (self.Icons[v.icon2]:Width())), y + h2, self.Icons[v.icon2]:Width(), self.Icons[v.icon2]:Height()) --Icon2 draw (must be #x16 png)
-- 			draw.SimpleText("+", "default", x - 8, y + h2 + 2, color_white)
-- 		end

-- 		h2 = h2 + h
-- 	end

-- 	self.InfoBoxHeight = h2 + 8
-- end

-- if CLIENT then
-- 	TOOL.Information = {
-- 		{
-- 			name = "loading",
-- 			op = 0
-- 		},
-- 		{
-- 			name = "info"
-- 		},
-- 		{
-- 			name = "leftBUILD",
-- 			op = 1
-- 		},
-- 		{
-- 			name = "rightBUILD",
-- 			op = 1
-- 		},
-- 		{
-- 			name = "leftBUILDuse",
-- 			op = 1
-- 		},
-- 		{
-- 			name = "rightBUILDuse",
-- 			op = 1
-- 		},
-- 		{
-- 			name = "leftBUILDctrl",
-- 			op = 1
-- 		},
-- 		{
-- 			name = "rightBUILDctrl",
-- 			op = 1
-- 		},
-- 		{
-- 			name = "reload"
-- 		}
-- 	}

-- 	language.Add("tool.slr_zonetool3.name", "Sledrace Zone Tool 3")
-- 	language.Add("tool.slr_zonetool3.desc", "Define and edit the nessasary zones for sledrace to work")
-- 	language.Add("tool.slt_zonetool3.loading", "You should no be seeing this =)")
-- 	language.Add("tool.slr_zonetool3.leftBUILD", "Set position one to the player posistion")
-- 	language.Add("tool.slr_zonetool3.rightBUILD", "Set position two to the player posistion")
-- 	language.Add("tool.slr_zonetool3.leftBUILDuse", "Reset position one")
-- 	language.Add("tool.slr_zonetool3.rightBUILDuse", "Reset posistion two")
-- 	language.Add("tool.slr_zonetool3.leftBUILDctrl", "Set posistion one to where the player is looking")
-- 	language.Add("tool.slr_zonetool3.rightBUILDctrl", "Set posistion two to where the player is looking")
-- end