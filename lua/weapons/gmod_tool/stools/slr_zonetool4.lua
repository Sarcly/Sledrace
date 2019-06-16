TOOL.Category = "Sledrace!"
TOOL.Name = "#tool.slr_zonetool4.name"
TOOL.Command = "gmod_toolmode slr_zonetool4"
TOOL.Modes = {
	Loading="Loading", 
	Create="Create Mode",
	Edit="Edit Mode"
}
TOOL.ModeList = {
	TOOL.Modes.Loading,
	TOOL.Modes.Create,
	TOOL.Modes.Edit
}

TOOL.CurrentBox = {
	Min = nil,
	Max = nil,
	Ent = nil
}

TOOL.ToolNameHeight = 0
TOOL.InfoBoxHeight = 0
TOOL.KeepNoHUDCL = false
TOOL.PreviousDrawHelpState = -1
TOOL.KeyTable={}
function TOOL:Holster()
    self:SetOperation(0)
	if CLIENT then
		GetConVar("gmod_drawhelp"):SetInt(self.PreviousDrawHelpState)
		self.PreviousDrawHelpState = -1
	end
end

function TOOL:UpdateToolMode()
    if self:GetOperation() == 0 then
        self:SetOperation(1)
    elseif self:GetOperation() < #self.ModeList - 1 then
        self:SetOperation(self:GetOperation() + 1)
    elseif self:GetOperation() >= #self.ModeList - 1 then
        self:SetOperation(1)
    end
end

function TOOL:GetToolMode()
    return self.ModeList[self:GetOperation()+1]
end

function ResetToolMode()
    self:SetOperation(0)
end 

function TOOL:PlayerButtonDown(key, ply)
	if CLIENT or (SERVER and IsFirstTimePredicted()) then
		if (!self.KeyTable) then
			self.KeyTable = {}
		end
		-- {bool,bool} first value is if key is currently being pressed, second is if it should fire only once
		if(self.KeyTable[key]) then
			self.KeyTable[key] = {true,self.KeyTable[key][2]}
		else
			self.KeyTable[key] = {true, false}
		end
	end
end

hook.Add("PlayerButtonDown", "ZoneToolDragKeyDown", TOOL.PlayerButtonDown)

function TOOL:PlayerButtonUp(key,ply)
	if CLIENT or (SERVER and IsFirstTimePredicted()) then
		self.KeyTable[key] = {false, false}
	end
end

hook.Add("PlayerButtonUp","ZoneToolDragKeyUp", TOOL.PlayerButtonUp)

function TOOL:ProcessInput()
	if CLIENT or (SERVER and IsFirstTimePredicted()) then
		if self:GetToolMode() == self.Modes.Create then
			--is KeyTable exists && info table for requested button exists && specified key is being help down && is a one time press (false=run as long as key is held down; true=run once on key press) 
			if(self:GetOwner().KeyTable && self:GetOwner().KeyTable[MOUSE_LEFT] && self:GetOwner().KeyTable[MOUSE_LEFT][1] && !self:GetOwner().KeyTable[MOUSE_LEFT][2]) then
				self.CurrentBox.Min = self:GetOwner():GetPos()
				if (self.CurrentBox.Min and self.CurrentBox.Max) then
					self:UpdateEnt()
				end
				self:GetOwner().KeyTable[2]=true
			end
			if(self:GetOwner().KeyTable && self:GetOwner().KeyTable[MOUSE_RIGHT] && self:GetOwner().KeyTable[MOUSE_RIGHT][1] && !self:GetOwner().KeyTable[MOUSE_RIGHT][2]) then
				self.CurrentBox.Max = self:GetOwner():GetPos()
				if (self.CurrentBox.Min and self.CurrentBox.Max) then
					self:UpdateEnt()
				end
				self:GetOwner().KeyTable[MOUSE_RIGHT][2]=true
			end
		end
	end
end

function TOOL:UpdateEnt()

end

function TOOL:Think()
	self:ProcessInput()
	if self:GetToolMode() == self.Modes.Loading then
		self:UpdateToolMode()
	end
end

function TOOL:DrawToolScreen(width, height) --CLIENT ONLY
	surface.SetDrawColor(Color(20, 20, 20))
	surface.DrawRect(0, 0, width, height)
	draw.SimpleText(self:GetToolMode(), "GModToolScreen", width / 2, height / 4, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function TOOL:DrawHUD() --CLIENT ONLY
	if self.PreviousDrawHelpState == -1 then
		self.PreviousDrawHelpState = GetConVar("gmod_drawhelp"):GetInt()
		GetConVar("gmod_drawhelp"):SetInt(0)
	end
	if self.KeepNoHUDCL then return end
	--Small rewrite of the sandbox STool draw HUD because I wanted to be able to use shift and ctrl as modifier keys for keybinds. Im very extra
	local mode = "slr_zonetool4"
	if (not self) then return end
	local x, y = 50, 40
	local w, h = 0, 0
	local TextTable = {}
	local QuadTable = {}
	--Draws the gradient under the tool name and description
	QuadTable.texture = surface.GetTextureID("gui/gradient")
	QuadTable.color = Color(10, 10, 10, 180)
	QuadTable.x = 0
	QuadTable.y = y - 8
	QuadTable.w = 600
	QuadTable.h = self.ToolNameHeight - (y - 8)
	draw.TexturedQuad(QuadTable)
	--Draws the tool name text
	TextTable.font = "GModToolName"
	TextTable.color = Color(240, 240, 240, 255)
	TextTable.pos = {x, y}
	TextTable.text = "#tool." .. mode .. ".name"
	w, h = draw.TextShadow(TextTable, 2)
	y = y + h
	--Draws the description text
	TextTable.font = "GModToolSubtitle"
	TextTable.pos = {x, y}
	TextTable.text = "#tool." .. mode .. ".desc"
	w, h = draw.TextShadow(TextTable, 1)
	y = y + h + 8
	self.ToolNameHeight = y
	--Draws gradient under the info
	QuadTable.y = y
	QuadTable.h = self.InfoBoxHeight
	local alpha = math.Clamp(255 + (self.LastMessage - CurTime()) * 800, 10, 255)
	QuadTable.color = Color(alpha, alpha, alpha, 230)
	draw.TexturedQuad(QuadTable)
	y = y + 4
	TextTable.font = "GModToolHelp"

	if (not self.Information) then
		TextTable.pos = {x + self.InfoBoxHeight, y}
		TextTable.text = self:GetHelpText()
		w, h = draw.TextShadow(TextTable, 1)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetTexture(surface.GetTextureID("gui/info"))
		surface.DrawTexturedRect(x + 1, y + 1, h - 3, h - 3)
		self.InfoBoxHeight = h + 8

		return
	end

	local h2 = 0

	--Loop over all entrys in Information and populate them
	for k, v in pairs(self.Information) do
		-- If element of Information is just a string then make it a table containg the string in name ("string"->{name="string"})
		if (type(v) == "string") then
			v = {
				name = v
			}
		end

		if (not v.name) then continue end --If no name then skip
		if (v.stage and v.stage ~= self:GetStage()) then continue end --If stage if not correct then skip
		if (v.op and v.op ~= self:GetOperation()) then continue end --If operation not correct then skip
		local txt = "#tool." .. GetConVarString("gmod_toolmode") .. "." .. v.name

		if (v.name == "info") then
			txt = self:GetHelpText()
		end

		TextTable.text = txt
		TextTable.pos = {x + 21, y + h2}
		w, h = draw.TextShadow(TextTable, 1)

		--Shortcuts for icons in info space
		if (not v.icon) then
			if (v.name:StartWith("info")) then
				v.icon = "gui/info"
			end

			if (v.name:StartWith("left")) then
				v.icon = "gui/lmb.png"
			end

			if (v.name:StartWith("right")) then
				v.icon = "gui/rmb.png"
			end

			if (v.name:StartWith("reload")) then
				v.icon = "gui/r.png"
			end

			if (v.name:StartWith("use")) then
				v.icon = "gui/e.png"
			end
		end

		if (not v.icon2) then
			if (not v.name:StartWith("use") and v.name:EndsWith("use")) then
				v.icon2 = "gui/e.png"
			end

			--added shift to modifer keys
			if (not v.name:StartWith("shift") and v.name:EndsWith("shift")) then
				v.icon2 = "materials/shift.png"
			end

			--added ctrl to modifer keys
			if (not v.name:StartWith("ctrl") and v.name:EndsWith("ctrl")) then
				v.icon2 = "materials/ctrl.png"
			end
		end

		self.Icons = self.Icons or {}

		if (v.icon and not self.Icons[v.icon]) then
			self.Icons[v.icon] = Material(v.icon)
		end

		if (v.icon2 and not self.Icons[v.icon2]) then
			self.Icons[v.icon2] = Material(v.icon2)
		end

		if (v.icon and self.Icons[v.icon] and not self.Icons[v.icon]:IsError()) then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.Icons[v.icon])
			surface.DrawTexturedRect(x, y + h2, 16, 16) --Icon1 draw (must be 16x16 png)
		end

		if (v.icon2 and self.Icons[v.icon2] and not self.Icons[v.icon2]:IsError()) then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.Icons[v.icon2])
			surface.DrawTexturedRect(x - (11 + (self.Icons[v.icon2]:Width())), y + h2, self.Icons[v.icon2]:Width(), self.Icons[v.icon2]:Height()) --Icon2 draw (must be #x16 png)
			draw.SimpleText("+", "default", x - 8, y + h2 + 2, color_white)
		end

		h2 = h2 + h
	end

	self.InfoBoxHeight = h2 + 8
end

if CLIENT then
    TOOL.Information={
        {name = "loading",op = 0},
		{name = "info"},
		{name = "leftBUILD",op = 1},
		{name = "rightBUILD",op = 1},
        {name = "leftBUILDuse",op = 1},
		{name = "rightBUILDuse",op = 1},
		{name = "leftBUILDctrl",op = 1},
        {name = "rightBUILDctrl",op = 1},
		{name = "reload"}
	}

	language.Add("tool.slr_zonetool4.name", "Sledrace Zone Tool 4")
	language.Add("tool.slr_zonetool4.desc", "Define and edit the nessasary zones for sledrace to work")
	language.Add("tool.slt_zonetool4.loading", "You should no be seeing this =)")
	language.Add("tool.slr_zonetool4.leftBUILD", "Set position one to the player posistion")
	language.Add("tool.slr_zonetool4.rightBUILD", "Set position two to the player posistion")
	language.Add("tool.slr_zonetool4.leftBUILDuse", "Reset position one")
	language.Add("tool.slr_zonetool4.rightBUILDuse", "Reset posistion two")
	language.Add("tool.slr_zonetool4.leftBUILDctrl", "Set posistion one to where the player is looking")
	language.Add("tool.slr_zonetool4.rightBUILDctrl", "Set posistion two to where the player is looking")
end