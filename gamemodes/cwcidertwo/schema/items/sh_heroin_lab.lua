--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("generator_base");
	ITEM.name = "Heroin Lab";
	ITEM.cost = 90;
	ITEM.model = "models/props_lab/reciever01a.mdl";
	ITEM.classes = {CLASS_HUSTLER};
	ITEM.category = "Drug Labs";
	ITEM.business = true;
	ITEM.description = "Manufactures a temporary flow of heroin.";

	ITEM.generatorInfo = {
		powerPlural = "Lifetime",
		powerName = "Lifetime",
		uniqueID = "cw_heroinlab",
		maximum = 2,
		health = 100,
		power = 5,
		cash = 0,
		name = "Heroin Lab",
	};
ITEM:Register();