--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

DEFINE_BASECLASS("base_gmodentity");

ENT.Type = "anim";
ENT.Author = "kurozael";
ENT.PrintName = "Paper";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

-- Called when the datatables are setup.
function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Note");
end;