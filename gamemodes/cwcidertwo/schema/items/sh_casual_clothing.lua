--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("clothes_base");
	ITEM.cost = 30;
	ITEM.name = "Casual Clothing";
	ITEM.group = "group04";
	ITEM.weight = 0.5;
	ITEM.classes = {CLASS_MERCHANT};
	ITEM.business = true;
	ITEM.description = "Just some nice casual clothing.";
ITEM:Register();