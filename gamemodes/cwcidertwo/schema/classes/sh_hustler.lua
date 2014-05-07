--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = Clockwork.class:New("Hustler");
	CLASS.wages = 5;
	CLASS.limit = 16;
	CLASS.color = Color(150, 125, 100, 255);
	CLASS.classes = {"Civilian"};
	CLASS.description = "A city drug dealer who manufactures illegal highs.\nThey have low wages compared to legal classes.";
	CLASS.defaultPhysDesc = "Wearing nice and clean clothes";
CLASS_HUSTLER = CLASS:Register();