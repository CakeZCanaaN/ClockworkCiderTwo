--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Spray Can";
ITEM.cost = 10;
ITEM.model = "models/sprayca2.mdl";
ITEM.weight = 1;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.category = "Reusables"
ITEM.business = true;
ITEM.description = "A standard spray can filled with paint.";

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;
ITEM:Register();