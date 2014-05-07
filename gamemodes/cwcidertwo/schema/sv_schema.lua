--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:AddFile("models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl");
Clockwork.kernel:AddFile("models/katharsmodels/syringe_out/syringe_out.mdl");
Clockwork.kernel:AddFile("models/katharsmodels/syringe_out/heroine_out.mdl");
Clockwork.kernel:AddFile("models/pmc/pmc_4/pmc__07.mdl");
Clockwork.kernel:AddFile("resource/fonts/sansation.ttf");
Clockwork.kernel:AddFile("models/jaanus/morphi.mdl");
Clockwork.kernel:AddFile("models/jaanus/ecstac.mdl");
Clockwork.kernel:AddFile("models/sprayca2.mdl");
Clockwork.kernel:AddFile("models/cocn.mdl");

Clockwork.kernel:AddDirectory("materials/models/humans/female/group01/cikizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/male/group01/cikizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/female/group01/cirizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/male/group01/cirizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/female/group01/ciaizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/male/group01/ciaizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/female/group01/cilizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/male/group01/cilizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/female/group01/cibizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/male/group01/cibizen_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/female/group01/cityadm_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/male/group01/cityadm_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/female/group01/freerun_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/humans/male/group01/freerun_sheet.*");
Clockwork.kernel:AddDirectory("materials/models/pmc/pmc_4/*.*");
Clockwork.kernel:AddDirectory("materials/models/pmc/pmc_shared/*.*");
Clockwork.kernel:AddDirectory("materials/katharsmodels/contraband/*.*");
Clockwork.kernel:AddDirectory("materials/katharsmodels/syringe_out/*.*");
Clockwork.kernel:AddDirectory("materials/katharsmodels/syringe_in/*.*");
Clockwork.kernel:AddDirectory("materials/jaanus/ecstac_a.*");
Clockwork.kernel:AddDirectory("materials/jaanus/morphi_a.*");
Clockwork.kernel:AddDirectory("materials/models/drug/*.*");
Clockwork.kernel:AddDirectory("materials/models/lagmite/*.*");
Clockwork.kernel:AddDirectory("materials/models/spraycan3.*");
Clockwork.kernel:AddDirectory("materials/models/deadbodies/*.*");
Clockwork.kernel:AddDirectory("models/deadbodies/*.*");
Clockwork.kernel:AddDirectory("models/lagmite/*.*");
Clockwork.kernel:AddDirectory("models/humans/group17/*.mdl");
Clockwork.kernel:AddDirectory("models/humans/group99/*.mdl");
Clockwork.kernel:AddDirectory("models/humans/group09/*.mdl");
Clockwork.kernel:AddDirectory("models/humans/group10/*.mdl");
Clockwork.kernel:AddDirectory("models/humans/group08/*.mdl");
Clockwork.kernel:AddDirectory("models/humans/group07/*.mdl");
Clockwork.kernel:AddDirectory("models/humans/group04/*.mdl");

Clockwork.config:Add("using_life_system", true, true);
Clockwork.config:Add("intro_text_small", "Where the rich get famous.", true);
Clockwork.config:Add("intro_text_big", "DEEP WITHIN EVOCITY, 2010.", true);

Clockwork.config:Get("change_class_interval"):Set(60);
Clockwork.config:Get("enable_gravgun_punt"):Set(false);
Clockwork.config:Get("default_inv_weight"):Set(8);
Clockwork.config:Get("minimum_physdesc"):Set(16);
Clockwork.config:Get("scale_prop_cost"):Set(0);
Clockwork.config:Get("disable_sprays"):Set(false);
Clockwork.config:Get("wages_interval"):Set(360);
Clockwork.config:Get("default_cash"):Set(80);

Clockwork.hint:Add("911", "You can contact the police by using the command $command_prefix$911.");
Clockwork.hint:Add("912", "You can contact secretaries by using the command $command_prefix$912.");
Clockwork.hint:Add("Call", "Call somebody by using the command $command_prefix$call.");
Clockwork.hint:Add("Admins", "The admins are here to help you, please respect them.");
Clockwork.hint:Add("Grammar", "Try to speak correctly in-character, and don't use emoticons.");
Clockwork.hint:Add("Healing", "You can heal players by using the Give command in your inventory.");
Clockwork.hint:Add("Headset", "You can speak to other characters with your class by using $command_prefix$Headset.");
Clockwork.hint:Add("Alliance", "You can create an alliance by using the command $command_prefix$AllyCreate.");
Clockwork.hint:Add("Broadcast", "As the president, you can broadcast to the city with $command_prefix$Broadcast.");
Clockwork.hint:Add("F3 Hotkey", "Press F3 while looking at a character to use a zip tie.");
Clockwork.hint:Add("F4 Hotkey", "Press F4 while looking at a tied character to search them.");
Clockwork.hint:Add("Caller ID", "Set your cell phone number by using the command $command_prefix$SetCallerID.");

Clockwork.datastream:Hook("TakeDownBillboard", function(player, data)
	local billboard = Schema.billboards[data];
	
	if (billboard and billboard.data) then
		if (billboard.data.owner == player) then
			Clockwork.datastream:Start(nil, "BillboardRemove", data);
			
			billboard.uniqueID = nil;
			billboard.data = nil;
			billboard.key = nil;
		end;
	end;
end);

Clockwork.datastream:Hook("PurchaseLottery", function(player, data)
	if (type(data) == "table") then
		local numberOne = tonumber(data[1]) or 1;
		local numberTwo = tonumber(data[2]) or 1;
		local numberThree = tonumber(data[3]) or 1;
		
		local nextLotteryTime = Clockwork.kernel:GetSharedVar("lottery");
		local lotteryTicket = player:GetSharedVar("lottery");
		local curTime = CurTime();
		
		if (nextLotteryTime > curTime and !lotteryTicket) then
			if (Clockwork.player:CanAfford(player, 40)) then
				Clockwork.player:GiveCash(player, -40, "purchasing a lottery ticket");
				
				Schema.lotteryCash = Schema.lotteryCash + 40;
				
				player:SetSharedVar("lottery", true);
				player.lottery = {numberOne, numberTwo, numberThree};
			else
				Clockwork.player:Notify(player, "You need another "..Clockwork.kernel:FormatCash(40 - player:GetCash(), nil, true).."!");
			end;
		elseif (!lotteryTicket) then
			Clockwork.player:Notify(player, "The lottery is currently in progress, please wait!");
		else
			Clockwork.player:Notify(player, "You have already purchased a lottery ticket, please wait.");
		end;
	end;
end);

Clockwork.datastream:Hook("UpdateBillboard", function(player, data)
	if (type(data) == "table") then
		local billboard = Schema.billboards[data.id];
		local color = Color(255, 255, 255, 255);
		local title = string.sub(data.title or "", 0, 18);
		local text = string.sub(data.text or "", 0, 80);
		
		if (data.color) then
			color.r = data.color.r or 255;
			color.g = data.color.g or 255;
			color.b = data.color.b or 255;
		end;
		
		if (billboard) then
			if (billboard.data and IsValid(billboard.data.owner)) then
				if (billboard.data.owner == player) then
					billboard.data = {
						color = color,
						owner = player,
						title = title,
						text = text
					};
					
					Clockwork.datastream:Start( nil, "BillboardAdd", {id = data.id, data = billboard.data} );
				end;
			else
				if (Clockwork.player:CanAfford(player, 60)) then
					billboard.uniqueID = player:UniqueID();
					billboard.data = {
						owner = player,
						color = color,
						title = title,
						text = text
					};
					billboard.key = player:QueryCharacter("key");
					
					Clockwork.datastream:Start( nil, "BillboardAdd", {id = data.id, data = billboard.data} );
					
					Clockwork.player:GiveCash(player, -60, "purchasing a billboard");
				else
					Clockwork.player:Notify(player, "You need another "..Clockwork.kernel:FormatCash(60 - player:GetCash(), nil, true).."!");
				end;
			end;
		end;
	end;
end);

Clockwork.datastream:Hook("JoinAlliance", function(player, data)
	if (player.allianceAuthenticate == data) then
		player:SetCharacterData("leader", nil);
		player:SetCharacterData("alliance", data);
		
		Clockwork.player:Notify(player, "You have joined the '"..data.."' alliance.");
	end;
end);

Clockwork.datastream:Hook("Notepad", function(player, data)
	if (type(data) == "string" and player:HasItemByID("notepad")) then
		player:SetCharacterData("notepad", string.sub(data, 0, 500));
	end;
end);

Clockwork.datastream:Hook("CreateAlliance", function(player, data)
	if (type(data) == "string") then
		local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
		local schemaFolder = Clockwork.kernel:GetSchemaFolder();
		local alliance = string.gsub(string.sub(data, 1, 32), "[%p%d]", "");
		
		local queryObj = Clockwork.database:Select(charactersTable);
			queryObj:AddWhere("_Schema = ?", schemaFolder);
			queryObj:AddWhere("_Data = ?", "%\"alliance\":\""..alliance.."\"%");
			queryObj:SetCallback(function(result)
				if (IsValid(player)) then
					if (Clockwork.database:IsResult(result)) then
						Clockwork.player:Notify(player, "An alliance with the name '"..alliance.."' already exists!");
					else
						player:SetCharacterData("leader", true);
						player:SetCharacterData("alliance", alliance);
						
						Clockwork.player:Notify(player, "You have created the '"..alliance.."' alliance.");
					end;
				end;
			end);
		queryObj:Pull();
	end;
end);

-- A function to load the radios.
function Schema:LoadRadios()
	local radios = Clockwork.kernel:RestoreSchemaData("plugins/radios/"..game.GetMap());
	
	for k, v in pairs(radios) do
		local entity;
		
		if (v.frequency) then
			entity = ents.Create("cw_radio");
		else
			entity = ents.Create("cw_broadcaster");
		end;
		
		Clockwork.player:GivePropertyOffline(v.key, v.uniqueID, entity);
		
		entity:SetAngles(v.angles);
		entity:SetPos(v.position);
		entity:Spawn();
		
		if (IsValid(entity)) then
			entity:SetOff(v.off);
			
			if (v.frequency) then
				entity:SetFrequency(v.frequency);
			end;
		end;
		
		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the radios.
function Schema:SaveRadios()
	local radios = {};
	
	for k, v in pairs( ents.FindByClass("cw_radio") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		if (IsValid(physicsObject)) then
			moveable = physicsObject:IsMoveable();
		end;
		
		radios[#radios + 1] = {
			off = v:GetOff(),
			key = Clockwork.entity:QueryProperty(v, "key"),
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			frequency = v:GetFrequency()
		};
	end;
	
	for k, v in pairs( ents.FindByClass("cw_broadcaster") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		if (IsValid(physicsObject)) then
			moveable = physicsObject:IsMoveable();
		end;
		
		radios[#radios + 1] = {
			off = v:GetOff(),
			key = Clockwork.entity:QueryProperty(v, "key"),
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		};
	end;
	
	Clockwork.kernel:SaveSchemaData("plugins/radios/"..game.GetMap(), radios);
end;

-- A function to make an explosion.
function Schema:MakeExplosion(position, scale)
	local explosionEffect = EffectData();
	local smokeEffect = EffectData();
	
	explosionEffect:SetOrigin(position);
	explosionEffect:SetScale(scale);
	smokeEffect:SetOrigin(position);
	smokeEffect:SetScale(scale);
	
	util.Effect("explosion", explosionEffect, true, true);
	util.Effect("cw_effect_smoke", smokeEffect, true, true);
end;

-- A function to get a player's location.
function Schema:PlayerGetLocation(player)
	local areaNames = Clockwork.plugin:FindByID("Area Names");
	local closest;
	
	if (areaNames) then
		for k, v in pairs(areaNames.areaNames) do
			if (Clockwork.entity:IsInBox(player, v.minimum, v.maximum)) then
				if (string.sub(string.lower(v.name), 1, 4) == "the ") then
					return string.sub(v.name, 5);
				else
					return v.name;
				end;
			else
				local distance = player:GetShootPos():Distance(v.minimum);
				
				if (!closest or distance < closest[1]) then
					closest = {distance, v.name};
				end;
			end;
		end;
		
		if (!completed) then
			if (closest) then
				if (string.sub(string.lower( closest[2] ), 1, 4) == "the ") then
					return string.sub(closest[2], 5);
				else
					return closest[2];
				end;
			end;
		end;
	end;
	
	return "unknown location";
end;

-- A function to load the lottery cash.
function Schema:LoadLotteryCash()
	local lotteryData = Clockwork.kernel:RestoreSchemaData("lottery")[1];

	if (!tonumber(self.lotteryCash)) then
		self.lotteryCash = 0;
	end;
end;

-- A function to save the lottery cash.
function Schema:SaveLotteryCash()
	Clockwork.kernel:SaveSchemaData("lottery", {self.lotteryCash});
end;

-- A function to make a player wear clothes.
function Schema:PlayerWearClothes(player, itemTable)
	local clothes = player:GetCharacterData("clothes");
	local team = player:Team();
	
	if (itemTable) then
		if (team != CLASS_PRESIDENT and team != CLASS_SECRETARY) then
			itemTable:OnChangeClothes(player, true);
			
			player:SetCharacterData("clothes", itemTable.index);
			player:SetSharedVar("clothes", itemTable.index);
		end;
	else
		itemTable = Clockwork.item:FindByID(clothes);
		
		if (itemTable) then
			itemTable:OnChangeClothes(player, false);
			
			player:SetCharacterData("clothes", nil);
			player:SetSharedVar("clothes", 0);
		end;
	end;
	
	if (itemTable) then
		player:GiveItem(Clockwork.item:CreateInstance(itemTable.uniqueID));
	end;
end;

-- A function to get a player's heal amount.
function Schema:GetHealAmount(player, scale)
	local medical = Clockwork.attributes:Fraction(player, ATB_MEDICAL, 35);
	local healAmount = (15 + medical) * (scale or 1);
	
	return healAmount;
end;

-- A function to get a player's dexterity time.
function Schema:GetDexterityTime(player)
	return 7 - Clockwork.attributes:Fraction(player, ATB_DEXTERITY, 5, 5);
end;

-- A function to get whether a player has won the lottery.
function Schema:HasWonLottery(player, numbers, winningNumbers)
	local correctNumbers = 0;
	local numbersCopy = table.Copy(winningNumbers);
	
	for i = 1, 3 do
		for o = 1, 3 do
			if (numbers[i] == numbersCopy[o]) then
				correctNumbers = correctNumbers + 1;
				numbersCopy[o] = nil;
				
				break;
			end;
		end;
	end;
	
	if (correctNumbers == 3) then
		return true;
	else
		return false;
	end;
end;

-- A function to bust down a door.
function Schema:BustDownDoor(player, door, force)
	door.bustedDown = true;
	door:SetNotSolid(true);
	door:DrawShadow(false);
	door:SetNoDraw(true);
	door:EmitSound("physics/wood/wood_box_impact_hard3.wav");
	door:Fire("Unlock", "", 0);
	
	local fakeDoor = ents.Create("prop_physics");
	
	fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD);
	fakeDoor:SetAngles( door:GetAngles() );
	fakeDoor:SetModel( door:GetModel() );
	fakeDoor:SetSkin( door:GetSkin() );
	fakeDoor:SetPos( door:GetPos() );
	fakeDoor:Spawn();
	
	local physicsObject = fakeDoor:GetPhysicsObject();
	
	if (IsValid(physicsObject)) then
		if (!force) then
			if (IsValid(player)) then
				physicsObject:ApplyForceCenter( ( door:GetPos() - player:GetPos() ):GetNormal() * 10000 );
			end;
		else
			physicsObject:ApplyForceCenter(force);
		end;
	end;
	
	Clockwork.entity:Decay(fakeDoor, 300);
	
	Clockwork.kernel:CreateTimer("reset_door_"..door:EntIndex(), 300, 1, function()
		if (IsValid(door)) then
			door:SetNotSolid(false);
			door:DrawShadow(true);
			door:SetNoDraw(false);
			door.bustedDown = nil;
		end;
	end);
end;

-- A function to load the belongings.
function Schema:LoadBelongings()
	local belongings = Clockwork.kernel:RestoreSchemaData("plugins/belongings/"..game.GetMap());
	
	for k, v in pairs(belongings) do
		local entity = ents.Create("cw_belongings");
		
		if (v.inventory["human_meat"]) then
			v.inventory["human_meat"] = nil;
		end;
		
		entity:SetAngles(v.angles);
		entity:SetData(v.inventory, v.cash);
		entity:SetPos(v.position);
		entity:Spawn();
		
		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the belongings.
function Schema:SaveBelongings()
	local belongings = {};
	
	for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
		if (v.areBelongings) then
			if (v.cash > 0 or table.Count(v.inventory) > 0) then
				belongings[#belongings + 1] = {
					cash = v.cash,
					angles = Angle(0, 0, -90),
					moveable = true,
					position = v:GetPos() + Vector(0, 0, 32),
					inventory = v.inventory
				};
			end;
		end;
	end;
	
	for k, v in pairs(ents.FindByClass("cw_belongings")) do
		if (v.cash and v.inventory and (v.cash > 0 or table.Count(v.inventory) > 0)) then
			local physicsObject = v:GetPhysicsObject();
			local moveable;
			
			if (IsValid(physicsObject)) then
				moveable = physicsObject:IsMoveable();
			end;
			
			belongings[#belongings + 1] = {
				cash = v.cash,
				angles = v:GetAngles(),
				moveable = moveable,
				position = v:GetPos(),
				inventory = v.inventory
			};
		end;
	end;
	
	Clockwork.kernel:SaveSchemaData("plugins/belongings/"..game.GetMap(), belongings);
end;

-- A function to make a player drop random items.
function Schema:PlayerDropRandomItems(player, ragdoll)
	local defaultModel = player:GetDefaultModel();
	local defaultSkin = Clockwork.player:GetDefaultSkin(player);
	local inventory = player:GetInventory();
	local clothes = player:GetCharacterData("clothes");
	local model = player:GetModel();
	local cash = player:GetCash();
	local info = {
		inventory = {},
		cash = cash
	};
	
	if (!IsValid(ragdoll)) then
		info.entity = ents.Create("cw_belongings");
	end;
	
	for k, v in pairs(inventory) do
		local itemTable = player:FindItemByID(k);
		
		if (itemTable and itemTable.allowStorage != false
		and !itemTable.isRareItem) then
			local success, fault = player:TakeItem(itemTable);
			
			if (success) then
				info.inventory[k] = v;
			end;
		end;
	end;
	
	player:SetCharacterData("cash", 0, true);
	
	if (!IsValid(ragdoll)) then
		if (table.Count(info.inventory) > 0 or info.cash > 0) then
			info.entity:SetAngles( Angle(0, 0, -90) );
			info.entity:SetData(info.inventory, info.cash);
			info.entity:SetPos( player:GetPos() + Vector(0, 0, 48) );
			info.entity:Spawn();
		else
			info.entity:Remove();
		end;
	else
		if (ragdoll:GetModel() != model) then
			ragdoll:SetModel(model);
		end;
		
		ragdoll.areBelongings = true;
		ragdoll.clothesData = {clothes, defaultModel, defaultSkin};
		ragdoll.inventory = info.inventory;
		ragdoll.cash = info.cash;
	end;
	
	if (Clockwork.config:Get("using_life_system"):Get()) then
		player:SetSharedVar("dead", true);
		player:SetCharacterData("dead", true);
	end;
	
	Clockwork.player:SaveCharacter(player);
end;

-- A function to tie or untie a player.
function Schema:TiePlayer(player, isTied, reset, government)
	if (isTied) then
		if (government) then
			player:SetSharedVar("tied", 2);
		else
			player:SetSharedVar("tied", 1);
		end;
	else
		player:SetSharedVar("tied", 0);
	end;
	
	if (isTied) then
		Clockwork.player:DropWeapons(player);
		Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, player:Name().." has been tied.");
		
		player:Flashlight(false);
		player:StripWeapons();
	elseif (!reset) then
		if (player:Alive() and !player:IsRagdolled()) then 
			Clockwork.player:LightSpawn(player, true, true);
		end;
		
		Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, player:Name().." has been untied.");
	end;
end;