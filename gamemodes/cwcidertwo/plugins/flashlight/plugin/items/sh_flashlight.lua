--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Flashlight";
	ITEM.model = "models/lagmite/lagmite.mdl";
	ITEM.weight = 0.8;
	ITEM.category = "Reusables";
	ITEM.uniqueID = "cw_flashlight";
	ITEM.fakeWeapon = true;
	ITEM.meleeWeapon = true;
	ITEM.description = "A black flashlight with Maglite printed on the side.";
	ITEM.stockLimit = 5;
ITEM:Register();