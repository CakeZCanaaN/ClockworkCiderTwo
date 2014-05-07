--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("drug_base");
	ITEM.name = "Morphine";
	ITEM.model = "models/jaanus/morphi.mdl";
	ITEM.attributes = {Endurance = 75};
	ITEM.description = "Some bottled blue pills, they're good for your endurance.";
ITEM:Register();