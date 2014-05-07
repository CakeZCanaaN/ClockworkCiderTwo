--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("generator_base");
	ITEM.name = "Angel Dust Lab";
	ITEM.cost = 130;
	ITEM.model = "models/props_lab/reciever01a.mdl";
	ITEM.classes = {CLASS_HUSTLER};
	ITEM.category = "Drug Labs";
	ITEM.business = true;
	ITEM.description = "Manufactures a temporary flow of angel dust.";

	ITEM.generatorInfo = {
		powerPlural = "Lifetime",
		powerName = "Lifetime",
		uniqueID = "cw_angeldustlab",
		maximum = 2,
		health = 100,
		power = 5,
		cash = 0,
		name = "Angel Dust Lab",
	};
ITEM:Register();