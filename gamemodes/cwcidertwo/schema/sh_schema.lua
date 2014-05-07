--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Schema.billboards = {
	{
		position = Vector(-7847.8687, -7728.4404, 930.2415),
		angles = Angle(0, 90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-5579.8511 -7212.6436, 816.4194),
		angles = Angle(0, -90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-7719.0088, -4902.2466, 929.4857),
		angles = Angle(0, 90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-5615.9512, -10324.8281, 926.2682),
		angles = Angle(0, -90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-5579.8511, -7214.5537, 815.8289),
		angles = Angle(0, -90, 90),
		scale = 0.4375
	},
	{
		position = Vector(-446.1304, 6122.8198, 342.4596),
		angles = Angle(0, 50, 90),
		scale = 0.4375
	},
	{
		position = Vector(3489.8989, -6673.7188, 499.5970),
		angles = Angle(0, -180, 90),
		scale = 0.4375
	},
	{
		position = Vector(427.7188, 4524.6401, 440.7368),
		angles = Angle(0, -90, 90),
		scale = 0.4375
	},
	{
		position = Vector(790.3043, 7232.0161, 571.6388),
		angles = Angle(0, 90, 90),
		scale = 0.4375
	},
	{
		position = Vector(4208.2612, 5631.6914, 723.6007),
		angles = Angle(0, 90, 90),
		scale = 0.4375
	},
	{
		position = Vector(1861.0153, 3574.7188, 523.0126),
		angles = Angle(0, 0, 90),
		scale = 0.4375
	}
};

for k, v in pairs( _file.Find("models/humans/group17/*.mdl", "GAME") ) do
	Clockwork.animation:AddMaleHumanModel("models/humans/group17/"..v);
end;

for k, v in pairs( _file.Find("models/humans/group99/*.mdl", "GAME") ) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group99/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group99/"..v);
	end;
end;

for k, v in pairs( _file.Find("models/humans/group09/*.mdl", "GAME") ) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group09/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group09/"..v);
	end;
end;

for k, v in pairs( _file.Find("models/humans/group10/*.mdl", "GAME") ) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group10/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group10/"..v);
	end;
end;

for k, v in pairs( _file.Find("models/humans/group08/*.mdl", "GAME") ) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group08/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group08/"..v);
	end;
end;

for k, v in pairs( _file.Find("models/humans/group07/*.mdl", "GAME") ) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group07/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group07/"..v);
	end;
end;

for k, v in pairs( _file.Find("models/humans/group04/*.mdl", "GAME") ) do
	if (string.find(string.lower(v), "female")) then
		Clockwork.animation:AddFemaleHumanModel("models/humans/group04/"..v);
	else
		Clockwork.animation:AddMaleHumanModel("models/humans/group04/"..v);
	end;
end;

Clockwork.option:SetKey("model_shipment", "models/props_junk/cardboard_box003b.mdl");
Clockwork.option:SetKey("intro_image", "cidertwo/cidertwo2_logo");
Clockwork.option:SetKey("schema_logo", "cidertwo/cidertwo2_logo");
Clockwork.option:SetKey("menu_music", "music/hl2_song20_submix0.mp3");
Clockwork.option:SetKey("gradient", "cidertwo/gradient2");

Clockwork.attribute:FindByID("Stamina").isOnCharScreen = false;

if (CLIENT) then
	Clockwork.option:SetColor("information", Color(200, 100, 100, 255));
	Clockwork.option:SetFont("bar_text", "cid_TargetIDText");
	Clockwork.option:SetFont("main_text", "cid_MainText");
	Clockwork.option:SetFont("hints_text", "cid_IntroTextTiny");
	Clockwork.option:SetFont("large_3d_2d", "cid_Large3D2D");
	Clockwork.option:SetFont("target_id_text", "cid_TargetIDText");
	Clockwork.option:SetFont("cinematic_text", "cid_CinematicText");
	Clockwork.option:SetFont("date_time_text", "cid_IntroTextSmall");
	Clockwork.option:SetFont("menu_text_big", "cid_MenuTextBig");
	Clockwork.option:SetFont("menu_text_huge", "cid_MenuTextHuge");
	Clockwork.option:SetFont("menu_text_tiny", "cid_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_big", "cid_IntroTextBig");
	Clockwork.option:SetFont("menu_text_small", "cid_IntroTextSmall");
	Clockwork.option:SetFont("intro_text_tiny", "cid_IntroTextTiny");
	Clockwork.option:SetFont("intro_text_small", "cid_IntroTextSmall");
	Clockwork.option:SetFont("player_info_text", "cid_PlayerInfoText");	
end;

Clockwork.quiz:SetName("Agreement");
Clockwork.quiz:SetEnabled(true);
Clockwork.quiz:AddQuestion("I know that because of the logs, I will never get away with rule-breaking.", 1, "Yes.", "No.");
Clockwork.quiz:AddQuestion("When creating a character, I will use a full and appropriate name.", 1, "Yes.", "No.");
Clockwork.quiz:AddQuestion("I understand that the script has vast logs that are checked often.", 1, "Yes.", "No.");
Clockwork.quiz:AddQuestion("I will read the guidelines and directory in the main menu.", 1, "Yes.", "No.");

Clockwork.kernel:IncludePrefixed("cl_schema.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");
Clockwork.kernel:IncludePrefixed("sh_hooks.lua");
Clockwork.kernel:IncludePrefixed("sv_schema.lua");
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");

Clockwork.flag:Add("q", "Special", "Access to the special items.");