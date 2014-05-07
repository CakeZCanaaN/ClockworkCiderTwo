--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when a player's property should be restored.
function Schema:PlayerReturnProperty(player)
	local uniqueID = player:UniqueID();
	local removed = {};
	local key = player:QueryCharacter("key");
	
	for k, v in ipairs(self.billboards) do
		if (v.uniqueID == uniqueID) then
			if (v.key != key) then
				removed[#removed + 1] = k;
				
				v.uniqueID = nil;
				v.data = nil;
				v.key = nil;
			else
				v.data.owner = player;
			end;
		end;
	end;
	
	if (#removed > 0) then
		Clockwork.datastream:Start(nil, "BillboardRemove", removed);
	end;
end;

-- Called when a player's data stream info should be sent.
function Schema:PlayerSendDataStreamInfo(player)
	local billboards = {};
	
	for k, v in ipairs(self.billboards) do
		if (v.data) then
			billboards[#billboards + 1] = {
				data = v.data,
				id = k
			};
		end;
	end;
	
	Clockwork.datastream:Start(player, "Billboards", billboards);
end;

-- Called when a player stuns an entity.
function Schema:PlayerStunEntity(player, entity)
	local target = Clockwork.entity:GetPlayer(entity);
	local strength = Clockwork.attributes:Fraction(player, ATB_STRENGTH, 12, 6);
	
	player:ProgressAttribute(ATB_STRENGTH, 0.5, true);
	
	if (target and target:Alive()) then
		local curTime = CurTime();
		
		if (target.nextStunInfo and curTime <= target.nextStunInfo[2]) then
			target.nextStunInfo[1] = target.nextStunInfo[1] + 1;
			target.nextStunInfo[2] = curTime + 8;
			
			if (target.nextStunInfo[1] == 1) then
				Clockwork.player:SetRagdollState(target, RAGDOLL_KNOCKEDOUT, 60);
			end;
		else
			target.nextStunInfo = {0, curTime + 4};
		end;
		
		target:ViewPunch( Angle(12 + strength, 0, 0) );
		
		Clockwork.datastream:Start(target, "Stunned", 0.5);
	end;
end;

-- Called to check if a player does recognise another player.
function Schema:PlayerDoesRecognisePlayer(player, target, status, simple, default)
	if (status < RECOGNISE_SAVE) then
		local playerTeam = player:Team();
		local targetTeam = target:Team();
		
		if (playerTeam == CLASS_POLICE or playerTeam == CLASS_DISPENSER or playerTeam == CLASS_RESPONSE
		or playerTeam == CLASS_SECRETARY or playerTeam == CLASS_PRESIDENT) then
			if (targetTeam == CLASS_POLICE or targetTeam == CLASS_DISPENSER or targetTeam == CLASS_RESPONSE
			or targetTeam == CLASS_SECRETARY or targetTeam == CLASS_PRESIDENT) then
				return true;
			end;
		end;
	end;
end;

-- Called when a player's weapons should be given.
function Schema:PlayerGiveWeapons(player)
	if (player:Team() == CLASS_POLICE or player:Team() == CLASS_DISPENSER
	or player:Team() == CLASS_RESPONSE) then
		Clockwork.player:GiveSpawnWeapon(player, "cw_stunbaton");
		Clockwork.player:GiveSpawnWeapon(player, "cw_stungun");
	end;
end;

-- Called when a player attempts to use a lowered weapon.
function Schema:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary and (weapon.SilenceTime or weapon.PistolBurst)) then
		return true;
	end;
end;

-- Called when a player attempts to earn wages cash.
function Schema:PlayerCanEarnWagesCash(player, cash)
	local team = player:Team();
	
	if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_SECRETARY
	or team == CLASS_PRESIDENT or team == CLASS_RESPONSE) then
		local noWagesTime = Clockwork.kernel:GetSharedVar("noWagesTime");
		local curTime = CurTime();
		
		if (noWagesTime and noWagesTime >= curTime) then
			Clockwork.player:Notify(player, "You did not earn any wages because the president was killed recently.");
			
			return false;
		end;
	end;
end;

-- Called when a player attempts to earn generator cash.
function Schema:PlayerCanEarnGeneratorCash(player, info, cash)
	local team = player:Team();
	
	if (team == CLASS_POLICE or team == CLASS_SECRETARY or team == CLASS_RESPONSE
	or team == CLASS_PRESIDENT or team == CLASS_DISPENSER) then
		return false;
	end;
end;

-- Called when a player's drop weapon info should be adjusted.
function Schema:PlayerAdjustDropWeaponInfo(player, info)
	if (Clockwork.player:GetWeaponClass(player) == info.itemTable.weaponClass) then
		info.position = player:GetShootPos();
		info.angles = player:GetAimVector():Angle();
	else
		local gearTable = {
			Clockwork.player:GetGear(player, "Throwable"),
			Clockwork.player:GetGear(player, "Secondary"),
			Clockwork.player:GetGear(player, "Primary"),
			Clockwork.player:GetGear(player, "Melee")
		};
		
		for k, v in pairs(gearTable) do
			if (IsValid(v)) then
				local gearItemTable = v:GetItem();
				
				if (gearItemTable and gearItemTable.weaponClass == info.itemTable.weaponClass) then
					local position, angles = v:GetRealPosition();
					
					if (position and angles) then
						info.position = position;
						info.angles = angles;
						
						break;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when an entity is removed.
function Schema:EntityRemoved(entity)
	if (IsValid(entity) and entity:GetClass() == "prop_ragdoll") then
		if (entity.areBelongings) then
			if (table.Count(entity.inventory) > 0 or entity.cash > 0) then
				local belongings = ents.Create("cw_belongings");
				
				belongings:SetAngles( Angle(0, 0, -90) );
				belongings:SetData(entity.inventory, entity.cash);
				belongings:SetPos( entity:GetPos() + Vector(0, 0, 32) );
				belongings:Spawn();
				
				entity.inventory = nil;
				entity.cash = nil;
			end;
		end;
	end;
end;

-- Called when a player's character has loaded.
function Schema:PlayerCharacterLoaded(player)
	player:SetSharedVar("lottery", false);
	player.lottery = nil;
end;

-- Called when an entity's menu option should be handled.
function Schema:EntityHandleMenuOption(player, entity, option, arguments)
	if (entity:GetClass() == "prop_ragdoll" and arguments == "cw_corpseLoot") then
		if (!entity.inventory) then entity.inventory = {}; end;
		if (!entity.cash) then entity.cash = 0; end;
		
		local entityPlayer = Clockwork.entity:GetPlayer(entity);
		
		if (!entityPlayer or !entityPlayer:Alive()) then
			player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
			
			Clockwork.storage:Open( player, {
				name = "Corpse",
				weight = 8,
				entity = entity,
				distance = 192,
				cash = entity.cash,
				inventory = entity.inventory,
				OnTakeItem = function(player, storageTable, itemTable)
					if (entity.clothesData and itemTable.index == entity.clothesData[1]) then
						if (!storageTable.inventory[itemTable.uniqueID]) then
							entity:SetModel( entity.clothesData[2] );
							entity:SetSkin( entity.clothesData[3] );
						end;
					end;
				end,
				OnGiveCash = function(player, storageTable, cash)
					entity.cash = storageTable.cash;
				end,
				OnTakeCash = function(player, storageTable, cash)
					entity.cash = storageTable.cash;
				end
			} );
		end;
	elseif (entity:GetClass() == "cw_belongings" and arguments == "cw_belongingsOpen") then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		
		Clockwork.storage:Open( player, {
			name = "Belongings",
			weight = 100,
			entity = entity,
			distance = 192,
			cash = entity.cash,
			inventory = entity.inventory,
			OnGiveCash = function(player, storageTable, cash)
				entity.cash = storageTable.cash;
			end,
			OnTakeCash = function(player, storageTable, cash)
				entity.cash = storageTable.cash;
			end,
			OnClose = function(player, storageTable, entity)
				if (IsValid(entity)) then
					if ((!entity.inventory and !entity.cash) or (table.Count(entity.inventory) == 0 and entity.cash == 0)) then
						entity:Explode(entity:BoundingRadius() * 2);
						entity:Remove();
					end;
				end;
			end,
			CanGiveItem = function(player, storageTable, itemTable)
				return false;
			end
		} );
	elseif (entity:GetClass() == "cw_broadcaster") then
		if (arguments == "cw_broadcasterToggle") then
			entity:Toggle();
		elseif (arguments == "cw_broadcasterTake") then
			local bSuccess, fault = player:GiveItem(Clockwork.item:CreateInstance("broadcaster"));
			
			if (!bSuccess) then
				Clockwork.player:Notify(entity, fault);
			else
				entity:Remove();
			end;
		end;
	elseif (entity:GetClass() == "cw_breach") then
		entity:CreateDummyBreach();
		entity:BreachEntity(player);
	elseif (entity:GetClass() == "cw_radio") then
		if (option == "Set Frequency" and type(arguments) == "string") then
			if (string.find(arguments, "^%d%d%d%.%d$")) then
				local start, finish, decimal = string.match(arguments, "(%d)%d(%d)%.(%d)");
				
				start = tonumber(start);
				finish = tonumber(finish);
				decimal = tonumber(decimal);
				
				if (start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10) then
					entity:SetFrequency(arguments);
					
					Clockwork.player:Notify(player, "You have set this stationary radio's frequency to "..arguments..".");
				else
					Clockwork.player:Notify(player, "The radio arguments must be between 101.1 and 199.9!");
				end;
			else
				Clockwork.player:Notify(player, "The radio arguments must look like xxx.x!");
			end;
		elseif (arguments == "cw_radioToggle") then
			entity:Toggle();
		elseif (arguments == "cw_radioTake") then
			local bSuccess, fault = player:GiveItem(Clockwork.item:CreateInstance("stationary_radio"));
			
			if (!bSuccess) then
				Clockwork.player:Notify(entity, fault);
			else
				entity:Remove();
			end;
		end;
	end;
end;

-- Called when Clockwork has loaded all of the entities.
function Schema:ClockworkInitPostEntity()
	Clockwork.kernel:SetSharedVar("lottery", CurTime() + 3600);
	
	self:LoadLotteryCash();
	self:LoadBelongings();
	self:LoadRadios();
end;

-- Called just after data should be saved.
function Schema:PostSaveData()
	self:SaveLotteryCash();
	self:SaveBelongings();
	self:SaveRadios();
end;

-- Called when a player's inventory item has been updated.
function Schema:PlayerInventoryItemUpdated(player, itemTable, amount, force)
	local clothes = player:GetCharacterData("clothes");
	
	if (clothes and itemTable.uniqueID == clothes) then
		if (!player:HasItemByID(itemTable.uniqueID)) then
			if (player:Alive()) then
				itemTable:OnChangeClothes(player, false);
			end;
			
			player:SetCharacterData("clothes", nil);
		end;
	elseif (itemTable.uniqueID == "skull_mask") then
		if (player:GetSharedVar("skullMask")) then
			if (!player:HasItemByID(itemTable.uniqueID)) then
				itemTable:OnPlayerUnequipped(player);
			end;
		end;
	elseif (itemTable.uniqueID == "heartbeat_sensor") then
		if (player:GetSharedVar("sensor")) then
			if (!player:HasItemByID(itemTable.uniqueID)) then
				itemTable:OnPlayerUnequipped(player);
			end;
		end;
	end;
end;

-- Called when a player switches their flashlight on or off.
function Schema:PlayerSwitchFlashlight(player, on)
	if (on and player:GetSharedVar("tied") != 0) then
		return false;
	end;
end;

-- Called when a player attempts to spray their tag.
function Schema:PlayerSpray(player)
	if (!player:HasItemByID("spray_can") or player:GetSharedVar("tied") != 0) then
		return true;
	end;
end;

-- Called when a player presses F3.
function Schema:ShowSpare1(player)
	Clockwork.player:RunClockworkCommand(player, "InvAction", "zip_tie", "use");
end;

-- Called when a player presses F4.
function Schema:ShowSpare2(player)
	Clockwork.player:RunClockworkCommand(player, "CharSearch");
end;

-- Called when a player spawns an object.
function Schema:PlayerSpawnObject(player)
	if (player:GetSharedVar("tied") != 0) then
		Clockwork.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
end;

-- Called when a player attempts to breach an entity.
function Schema:PlayerCanBreachEntity(player, entity)
	if (Clockwork.entity:IsDoor(entity)) then
		if (!Clockwork.entity:IsDoorHidden(entity)) then
			return true;
		end;
	end;
end;

-- Called when a player attempts to use the radio.
function Schema:PlayerCanRadio(player, text, listeners, eavesdroppers)
	if (player:HasItemByID("handheld_radio")) then
		if (!player:GetCharacterData("frequency")) then
			Clockwork.player:Notify(player, "You need to set the radio frequency first!");
			
			return false;
		end;
	else
		Clockwork.player:Notify(player, "You do not own a radio!");
		
		return false;
	end;
end;

-- Called when a player attempts to use an entity in a vehicle.
function Schema:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if (entity:IsPlayer() or Clockwork.entity:IsPlayerRagdoll(entity)) then
		return true;
	end;
end;

-- Called when a player attempts to use a door.
function Schema:PlayerCanUseDoor(player, door)
	local team = player:Team();
	
	if (player:GetSharedVar("tied") != 0 or (team != CLASS_POLICE and team != CLASS_SECRETARY
	and team != CLASS_PRESIDENT and team != CLASS_DISPENSER and team != CLASS_RESPONSE)) then
		return false;
	end;
end;

-- Called when a player presses a key.
function Schema:KeyPress(player, key)
	if (key == IN_USE) then
		local untieTime = Schema:GetDexterityTime(player);
		local eyeTrace = player:GetEyeTraceNoCursor();
		local target = eyeTrace.Entity;
		local entity = target;
		
		if (IsValid(target)) then
			target = Clockwork.entity:GetPlayer(target);
			
			if (target and player:GetSharedVar("tied") == 0) then
				if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
					if (target:GetSharedVar("tied") != 0 and target:Alive()) then
						Clockwork.player:SetAction(player, "untie", untieTime);
						
						target:SetSharedVar("beingUntied", true);
						
						Clockwork.player:EntityConditionTimer(player, target, entity, untieTime, 192, function()
							return player:Alive() and target:Alive() and !player:IsRagdolled() and player:GetSharedVar("tied") == 0;
						end, function(success)
							if (success) then
								self:TiePlayer(target, false);
								
								player:ProgressAttribute(ATB_DEXTERITY, 15, true);
							end;
							
							if (IsValid(target)) then
								target:SetSharedVar("beingUntied", false);
							end;
							
							Clockwork.player:SetAction(player, "untie", false);
						end);
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a chat box message has been added.
function Schema:ChatBoxMessageAdded(info)
	if (info.class == "ic") then
		local eavesdroppers = {};
		local talkRadius = Clockwork.config:Get("talk_radius"):Get();
		local listeners = {};
		local players = _player.GetAll();
		local radios = ents.FindByClass("cw_radio");
		local data = {};
		
		for k, v in ipairs(radios) do
			if (!v:GetOff() and info.speaker:GetPos():Distance( v:GetPos() ) <= 80) then
				local frequency = v:GetFrequency();
				
				if (frequency != "") then
					info.shouldSend = false;
					info.listeners = {};
					data.frequency = frequency;
					data.position = v:GetPos();
					data.entity = v;
					
					break;
				end;
			end;
		end;
		
		if (IsValid(data.entity) and data.frequency != "") then
			for k, v in ipairs(players) do
				if (v:HasInitialized() and v:Alive() and !v:IsRagdolled(RAGDOLL_FALLENOVER)) then
					if (( v:GetCharacterData("frequency") == data.frequency and v:GetSharedVar("tied") == 0
					and v:HasItemByID("handheld_radio") ) or info.speaker == v) then
						listeners[v] = v;
					elseif (v:GetPos():Distance(data.position) <= talkRadius) then
						eavesdroppers[v] = v;
					end;
				end;
			end;
			
			for k, v in ipairs(radios) do
				local radioPosition = v:GetPos();
				local radioFrequency = v:GetFrequency();
				
				if (!v:GetOff() and radioFrequency == data.frequency) then
					for k2, v2 in ipairs(players) do
						if (v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2]) then
							if (v2:GetPos():Distance(radioPosition) <= (talkRadius * 2)) then
								eavesdroppers[v2] = v2;
							end;
						end;
						
						break;
					end;
				end;
			end;
			
			if (table.Count(listeners) > 0) then
				Clockwork.chatBox:Add(listeners, info.speaker, "radio", info.text);
			end;
			
			if (table.Count(eavesdroppers) > 0) then
				Clockwork.chatBox:Add(eavesdroppers, info.speaker, "radio_eavesdrop", info.text);
			end;
		end;
	end;
end;

-- Called when a player has used their radio.
function Schema:PlayerRadioUsed(player, text, listeners, eavesdroppers)
	local newEavesdroppers = {};
	local talkRadius = Clockwork.config:Get("talk_radius"):Get() * 2;
	local frequency = player:GetCharacterData("frequency");
	
	for k, v in ipairs( ents.FindByClass("cw_radio") ) do
		local radioPosition = v:GetPos();
		local radioFrequency = v:GetFrequency();
		
		if (!v:GetOff() and radioFrequency == frequency) then
			for k2, v2 in ipairs( _player.GetAll() ) do
				if (v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2]) then
					if (v2:GetPos():Distance(radioPosition) <= talkRadius) then
						newEavesdroppers[v2] = v2;
					end;
				end;
				
				break;
			end;
		end;
	end;
	
	if (table.Count(newEavesdroppers) > 0) then
		Clockwork.chatBox:Add(newEavesdroppers, player, "radio_eavesdrop", text);
	end;
end;

-- Called when a player's radio info should be adjusted.
function Schema:PlayerAdjustRadioInfo(player, info)
	for k, v in ipairs( _player.GetAll() ) do
		if (v:HasInitialized() and v:HasItemByID("handheld_radio")) then
			if (v:GetCharacterData("frequency") == player:GetCharacterData("frequency")) then
				if (v:GetSharedVar("tied") == 0) then
					info.listeners[v] = v;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to use a tool.
function Schema:CanTool(player, trace, tool)
	if (!Clockwork.player:HasFlags(player, "w")) then
		if (string.sub(tool, 1, 5) == "wire_" or string.sub(tool, 1, 6) == "wire2_") then
			player:RunCommand("gmod_toolmode \"\"");
			
			return false;
		end;
	end;
end;

-- Called when a player has been healed.
function Schema:PlayerHealed(player, healer, itemTable)
	local action = Clockwork.player:GetAction(player);
	
	if (itemTable.uniqueID == "health_vial") then
		healer:BoostAttribute(itemTable.name, ATB_DEXTERITY, 2, 600);
		healer:ProgressAttribute(ATB_MEDICAL, 15, true);
	elseif (itemTable.uniqueID == "health_kit") then
		healer:BoostAttribute(itemTable.name, ATB_DEXTERITY, 3, 600);
		healer:ProgressAttribute(ATB_MEDICAL, 25, true);
	elseif (itemTable.uniqueID == "bandage") then
		healer:BoostAttribute(itemTable.name, ATB_DEXTERITY, 1, 600);
		healer:ProgressAttribute(ATB_MEDICAL, 5, true);
	end;
end;

-- Called when a player's data should be restored.
function Schema:PlayerRestoreData(player, data)
	if (!data["blacklist"]) then
		data["blacklist"] = {};
	end;
	
	for k, v in ipairs( data["blacklist"] ) do
		if (!Clockwork.class:FindByID(v)) then
			table.remove(data["blacklist"], k);
		end;
	end;

	Clockwork.datastream:Start(player, "GetBlacklist", data["blacklist"]);
end;

-- Called when a player's character data should be restored.
function Schema:PlayerRestoreCharacterData(player, data)
	if (data["version"] != 1) then
		data["alliance"] = nil;
		data["version"] = 1;
	end;
	
	if (data["callerid"] == "911") then
		data["callerid"] = nil;
	end;
	
	if (!data["hunger"]) then
		data["hunger"] = 0;
	end;

	if (!data["thirst"]) then
		data["thirst"] = 0;
	end;
end;

-- Called when a player's shared variables should be set.
function Schema:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("alliance", player:GetCharacterData("alliance", ""));
	player:SetSharedVar("clothes", player:GetCharacterData("clothes", 0));
	player:SetSharedVar("leader", player:GetCharacterData("leader", false));
	player:SetSharedVar("sensor", player:GetCharacterData("sensor", false));
	player:SetSharedVar("hunger", math.Round(player:GetCharacterData("hunger")));
	player:SetSharedVar("thirst", math.Round(player:GetCharacterData("thirst")));
	
	if (player.cancelDisguise) then
		if (curTime >= player.cancelDisguise or !IsValid(player:GetSharedVar("disguise"))) then
			Clockwork.player:Notify(player, "Your disguise has begun to fade away, your true identity is revealed.");
			
			player.cancelDisguise = nil;
			player:SetSharedVar("disguise", NULL);
		end;
	end;
	
	if (player:Alive() and !player:IsRagdolled() and player:GetVelocity():Length() > 0) then
		local inventoryWeight = Clockwork.inventory:CalculateWeight( player:GetInventory() );
		
		if (inventoryWeight >= player:GetMaxWeight() / 4) then
			player:ProgressAttribute(ATB_STRENGTH, inventoryWeight / 400, true);
		end;
	end;
	
	if (player:Alive()) then
		if (player:GetCharacterData("hunger") == 100) then
			player:BoostAttribute("Thirst", ATB_ACROBATICS, -50);
			player:BoostAttribute("Thirst", ATB_ENDURANCE, -50);
			player:BoostAttribute("Thirst", ATB_STRENGTH, -50);
			player:BoostAttribute("Thirst", ATB_AGILITY, -50);
		else
			player:BoostAttribute("Thirst", ATB_ACROBATICS, false);
			player:BoostAttribute("Thirst", ATB_ENDURANCE, false);
			player:BoostAttribute("Thirst", ATB_STRENGTH, false);
			player:BoostAttribute("Thirst", ATB_AGILITY, false);
		end;
		
		if (player:GetCharacterData("thirst") == 100) then
			player:BoostAttribute("Thirst", ATB_DEXTERITY, -50);
			player:BoostAttribute("Thirst", ATB_MEDICAL, -50);
		else
			player:BoostAttribute("Thirst", ATB_DEXTERITY, false);
			player:BoostAttribute("Thirst", ATB_MEDICAL, false);
		end;
	end;
end;

-- Called when a player has been unragdolled.
function Schema:PlayerUnragdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

-- Called when a player has been ragdolled.
function Schema:PlayerRagdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

-- Called at an interval while a player is connected.
function Schema:PlayerThink(player, curTime, infoTable)
	local frequency = player:GetCharacterData("frequency");
	local ragdolled = player:IsRagdolled();
	local aimVector = tostring( player:GetAimVector() );
	local velocity = player:GetVelocity();
	local alive = player:Alive();
	
	if (player.lastAimVector != aimVector) then
		player.nextKickTime = curTime + 1800;
		player.lastAimVector = aimVector;
	end;
	
	if (player.nextKickTime and curTime >= player.nextKickTime) then
		player:Kick("You have been idle too long.");
	end;
	
	if (alive and !ragdolled) then
		if (!player:InVehicle() and player:GetMoveType() == MOVETYPE_WALK) then
			if (player:IsInWorld()) then
				if (!player:IsOnGround()) then
					player:ProgressAttribute(ATB_ACROBATICS, 0.25, true);
				elseif (infoTable.running) then
					player:ProgressAttribute(ATB_AGILITY, 0.125, true);
				elseif (infoTable.jogging) then
					player:ProgressAttribute(ATB_AGILITY, 0.0625, true);
				end;
			end;
		end;
	end;
	
	if (player:Alive()) then
		player:SetCharacterData("hunger", math.Clamp(player:GetCharacterData("hunger") + 0.008, 0, 100));
		player:SetCharacterData("thirst", math.Clamp(player:GetCharacterData("thirst") + 0.009, 0, 100));
	end;
	
	local acrobatics = Clockwork.attributes:Fraction(player, ATB_ACROBATICS, 175, 50);
	local strength = Clockwork.attributes:Fraction(player, ATB_STRENGTH, 8, 4);
	local agility = Clockwork.attributes:Fraction(player, ATB_AGILITY, 50, 25);
	
	if (clothes != "") then
		local itemTable = Clockwork.item:FindByID(clothes);
		
		if (itemTable and itemTable.pocketSpace) then
			infoTable.inventoryWeight = infoTable.inventoryWeight + itemTable.pocketSpace;
		end;
	end;
	
	infoTable.inventoryWeight = infoTable.inventoryWeight + strength;
	infoTable.jumpPower = infoTable.jumpPower + acrobatics;
	infoTable.runSpeed = infoTable.runSpeed + agility;
end;

-- Called when attempts to use a command.
function Schema:PlayerCanUseCommand(player, commandTable, arguments)
	if (player:GetSharedVar("tied") != 0) then
		local blacklisted = {
			"OrderShipment",
			"Radio"
		};
		
		if (table.HasValue(blacklisted, commandTable.name)) then
			Clockwork.player:Notify(player, "You cannot use this command when you are tied!");
			
			return false;
		end;
	end;
end;

-- Called when a player attempts to change class.
function Schema:PlayerCanChangeClass(player, class)
	local blacklist = player:GetData("Blacklist");
	
	if (player:GetSharedVar("tied") != 0) then
		Clockwork.player:Notify(player, "You cannot change classes when you are tied!");
		
		return false;
	end;
	
	if (blacklist and table.HasValue(blacklist, class.index)) then
		Clockwork.player:Notify(player, "You are blacklisted from this class!");
		
		return false;
	end;
end;

-- Called when a player attempts to use an entity.
function Schema:PlayerUse(player, entity)
	local curTime = CurTime();
	
	if (entity.bustedDown) then
		return false;
	end;
	
	if (player:GetSharedVar("tied") != 0) then
		if (entity:IsVehicle()) then
			if (Clockwork.entity:IsChairEntity(entity) or Clockwork.entity:IsPodEntity(entity)) then
				return;
			end;
		end;
		
		if (!player.nextTieNotify or player.nextTieNotify < CurTime()) then
			Clockwork.player:Notify(player, "You cannot use that when you are tied!");
			
			player.nextTieNotify = CurTime() + 2;
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to destroy an item.
function Schema:PlayerCanDestroyItem(player, itemTable, noMessage)
	if (player:GetSharedVar("tied") != 0) then
		if (!noMessage) then
			Clockwork.player:Notify(player, "You cannot destroy items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to drop an item.
function Schema:PlayerCanDropItem(player, itemTable, noMessage)
	if (player:GetSharedVar("tied") != 0) then
		if (!noMessage) then
			Clockwork.player:Notify(player, "You cannot drop items when you are tied!");
		end;
		
		return false;
	end;
end;

-- Called when a player attempts to use an item.
function Schema:PlayerCanUseItem(player, itemTable, noMessage)
	if (player:GetSharedVar("tied") != 0) then
		if (!noMessage) then
			Clockwork.player:Notify(player, "You cannot use items when you are tied!");
		end;
		
		return false;
	end;
	
	if (Clockwork.item:IsWeapon(itemTable) and !itemTable.fakeWeapon) then
		local throwableWeapon = nil;
		local secondaryWeapon = nil;
		local primaryWeapon = nil;
		local meleeWeapon = nil;
		local fault = nil;
		
		for k, v in ipairs( player:GetWeapons() ) do
			local weaponTable = Clockwork.item:GetByWeapon(v);
			
			if (weaponTable and !weaponTable.fakeWeapon) then
				if (!weaponTable:IsMeleeWeapon() and !weaponTable:IsThrowableWeapon()) then
					if (weaponTable.weight <= 2) then
						secondaryWeapon = true;
					else
						primaryWeapon = true;
					end;
				elseif (weaponTable:IsThrowableWeapon()) then
					throwableWeapon = true;
				else
					meleeWeapon = true;
				end;
			end;
		end;
		
		if (!itemTable:IsMeleeWeapon() and !itemTable:IsThrowableWeapon()) then
			if (itemTable.weight <= 2) then
				if (secondaryWeapon) then
					fault = "You cannot use another secondary weapon!";
				end;
			elseif (primaryWeapon) then
				fault = "You cannot use another secondary weapon!";
			end;
		elseif (itemTable:IsThrowableWeapon()) then
			if (throwableWeapon) then
				fault = "You cannot use another throwable weapon!";
			end;
		elseif (meleeWeapon) then
			fault = "You cannot use another melee weapon!";
		end;
		
		if (fault) then
			if (!noMessage) then
				Clockwork.player:Notify(player, fault);
			end;
			
			return false;
		end;
	end;
end;

-- Called when a player attempts to say something out-of-character.
function Schema:PlayerCanSayOOC(player, text)
	if (!player:Alive()) then
		Clockwork.player:Notify(player, "You don't have permission to do this right now!");
	end;
end;

-- Called when a player attempts to say something locally out-of-character.
function Schema:PlayerCanSayLOOC(player, text)
	if (!player:Alive()) then
		Clockwork.player:Notify(player, "You don't have permission to do this right now!");
	end;
end;

-- Called when chat box info should be adjusted.
function Schema:ChatBoxAdjustInfo(info)
	if (IsValid(info.speaker) and info.speaker:HasInitialized()) then
		if (info.class != "ooc" and info.class != "looc") then
			if (IsValid(info.speaker) and info.speaker:HasInitialized()) then
				if (string.sub(info.text, 1, 1) == "?") then
					info.text = string.sub(info.text, 2);
					info.data.anon = true;
				end;
			end;
		end;
		
		if (info.class == "ic") then
			for k, v in ipairs( ents.FindByClass("cw_broadcaster") ) do
				if (!v:GetOff() and info.speaker:GetPos():Distance( v:GetPos() ) <= 64) then
					for k2, v2 in ipairs( _player.GetAll() ) do
						info.listeners[k2] = v2;
					end;
					
					info.class = "broadcast";
					
					break;
				end;
			end;
		end;
	end;
end;

-- Called when a player destroys generator.
function Schema:PlayerDestroyGenerator(player, entity, generator)
	local team = player:Team();
	local cash = generator.cash;
	
	if (string.find(generator.name, "Lab")) then
		cash = cash / 2;
	end;
	
	if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
		local recipients = {};
		
		table.Add( recipients, _team.GetPlayers(CLASS_DISPENSER) );
		table.Add( recipients, _team.GetPlayers(CLASS_POLICE) );
		
		for k, v in pairs(recipients) do
			Clockwork.player:GiveCash( v, cash, "destroying a "..string.lower(generator.name) );
		end;
	else
		Clockwork.player:GiveCash( player, cash, "destroying a "..string.lower(generator.name) );
	end;
end;

-- Called when a player dies.
function Schema:PlayerDeath(player, inflictor, attacker, damageInfo)
	if (attacker:IsPlayer()) then
		local listeners = {};
		local weapon = attacker:GetActiveWeapon();
		
		for k, v in ipairs( _player.GetAll() ) do
			if (v:IsAdmin() or v:IsUserGroup("operator")) then
				if (v:HasInitialized()) then
					listeners[#listeners + 1] = v;
				end;
			end;
		end;
		
		if (#listeners > 0) then
			Clockwork.chatBox:Add( listeners, attacker, "killed", "", {victim = player} );
		end;
		
		if (IsValid(weapon)) then
			Clockwork.datastream:Start(player, "Death", weapon);
		else
			Clockwork.datastream:Start(player, "Death", false);
		end;
	else
		Clockwork.datastream:Start(player, "Death", false);
	end;
	
	if (damageInfo) then
		local miscellaneousDamage = damageInfo:IsBulletDamage() or damageInfo:IsExplosionDamage();
		local meleeDamage = damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
		
		if (miscellaneousDamage or meleeDamage) then
			self:PlayerDropRandomItems(player, player:GetRagdollEntity());
		end;
	end;
	
	if (player:Team() == CLASS_PRESIDENT) then
		if (attacker:IsPlayer()) then
			local team = attacker:Team();
			
			if (team == CLASS_SECRETARY or team == CLASS_POLICE or team == CLASS_RESPONSE
			or team == CLASS_PRESIDENT or team == CLASS_DISPENSER) then
				return;
			end;
		end;
		
		self.demotePresident = player;
	end;
end;

-- Called each frame that a player is dead.
function Schema:PlayerDeathThink(player)
	if (player:GetCharacterData("dead")) then
		return true;
	end;
end;

-- Called when a player attempts to switch to a character.
function Schema:PlayerCanSwitchCharacter(player, character)
	if (player:GetCharacterData("dead")) then
		return true;
	end;
end;

-- Called when a player's death info should be adjusted.
function Schema:PlayerAdjustDeathInfo(player, info)
	if (player:GetCharacterData("dead")) then
		info.spawnTime = 0;
	end;
end;

-- Called when a player's character screen info should be adjusted.
function Schema:PlayerAdjustCharacterScreenInfo(player, character, info)
	if (character.data["dead"]) then
		info.details = "This character is permanently dead.";
	end;
end;

-- Called when a player attempts to delete a character.
function Schema:PlayerCanDeleteCharacter(player, character)
	if (character.data["dead"]) then
		return true;
	end;
end;

-- Called when a player attempts to use a character.
function Schema:PlayerCanUseCharacter(player, character)
	if (character.data["dead"]) then
		return character.name.." is permanently killed and cannot be used!";
	end;
end;

-- Called each tick.
function Schema:Tick()
	local nextLotteryTime = Clockwork.kernel:GetSharedVar("lottery") or 0;
	local curTime = CurTime();
	
	if (self.demotePresident and !IsValid(self.demotePresident)) then
		Clockwork.kernel:SetSharedVar("noWagesTime", curTime + (Clockwork.config:Get("wages_interval"):Get() * 2));
		self.demotePresident = nil;
	end;
	
	if (curTime >= nextLotteryTime and (!self.lotteryPaused or curTime >= self.lotteryPaused)) then
		math.randomseed(curTime);
		
		local winningNumbers = {
			math.random(1, 10),
			math.random(1, 10),
			math.random(1, 10)
		}
		local lotteryCash = self.lotteryCash;
		local playerWinners = {};
		
		self.lotteryPaused = curTime + 4;
		
		Clockwork.kernel:SetSharedVar("lottery", curTime + 3600);
		
		for k, v in ipairs( _player.GetAll() ) do
			if (v:HasInitialized() and v.lottery) then
				if (self:HasWonLottery(v, v.lottery, winningNumbers)) then
					playerWinners[#playerWinners + 1] = v;
				end;
				
				v:SetSharedVar("lottery", false);
				v.lottery = nil;
			end;
		end;
		
		if (#playerWinners > 0) then
			local cashEach = math.Round(lotteryCash / #playerWinners);
			local playerNames = "";
			local winnerCount = #playerWinners;
			
			self.lotteryCash = 0;
			
			for k, v in ipairs(playerWinners) do
				if (k == 1 or winnerCount == 1) then
					playerNames = v:Name();
				elseif (k == winnerCount) then
					playerNames = playerName.." and "..v:Name();
				else
					playerNames = playerNames..", ";
				end;
				
				Clockwork.player:GiveCash(v, cashEach, "winning the lottery");
			end;
			
			if (winnerCount == 1) then
				Clockwork.chatBox:Add(nil, nil, "lottery", "The lottery is over, "..playerNames.." has won "..Clockwork.kernel:FormatCash(cashEach).."!");
			else
				Clockwork.chatBox:Add(nil, nil, "lottery", "The lottery is over, "..playerNames.." have won "..Clockwork.kernel:FormatCash(cashEach).." each!");
			end;
		end;
	end;
end;

-- Called just before a player dies.
function Schema:DoPlayerDeath(player, attacker, damageInfo)
	self:TiePlayer(player, false, true);
	
	player.beingSearched = nil;
	player.searching = nil;
end;

-- Called when a player's class has been set.
function Schema:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange)
	local generatorEntities = {};
	
	for k, v in pairs(Clockwork.generator.stored) do
		table.Add( generatorEntities, ents.FindByClass(k) );
	end;
	
	if (newClass.index == CLASS_POLICE or newClass.index == CLASS_PRESIDENT
	or newClass.index == CLASS_DISPENSER or newClass.index == CLASS_RESPONSE) then
		if (newClass.index == CLASS_PRESIDENT or newClass.index == CLASS_RESPONSE) then
			player:SetArmor(150);
		else
			player:SetArmor(100);
		end;
		
		player.freeArmor = true;
	elseif (player.freeArmor) then
		player:SetArmor(0);
		player.freeArmor = nil;
	end;
	
	for k, v in pairs(generatorEntities) do
		if (player == v:GetPlayer()) then
			local generator = Clockwork.generator:FindByID( v:GetClass() );
			local itemTable = Clockwork.item:FindByID(generator.name);
			
			if (itemTable and !Clockwork.kernel:HasObjectAccess(player, itemTable)) then
				v:Explode();
				v:Remove();
			end;
		end;
	end;
end;

-- Called when a player's storage should close.
function Schema:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	if (player.searching and entity:IsPlayer()
	and entity:GetSharedVar("tied") == 0) then
		return true;
	end;
end;

-- Called just after a player spawns.
function Schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local skullMask = player:GetCharacterData("skullmask");
	local clothes = player:GetCharacterData("clothes");
	local team = player:Team();

	if (firstSpawn) then
		player:SetSharedVar("tied", 0);
		player:SetSharedVar("beingTied", false);
	end;

	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("hunger", 0);
		player:SetCharacterData("thirst", 0);
	end;
	
	if (!lightSpawn) then
		if (self.demotePresident == player) then
			Clockwork.kernel:SetSharedVar( "noWagesTime", CurTime() + (Clockwork.config:Get("wages_interval"):Get() * 2) );
				Clockwork.class:Set(player, CLASS_CIVILIAN, true, true, true);
			self.demotePresident = nil;
			
			Clockwork.player:SetDefaultModel(player);
		end;
		
		Clockwork.datastream:Start(player, "ClearEffects", false);
		
		player:SetSharedVar("disguise", NULL);
		player.cancelDisguise = nil;
		player.beingSearched = nil;
		player.searching = nil;
	end;
	
	if (player:GetSharedVar("tied") != 0) then
		self:TiePlayer(player, true);
	end;
	
	if (skullMask) then
		local itemTable = Clockwork.item:FindByID("skull_mask");
		
		if (itemTable and player:HasItemByID(itemTable.uniqueID)) then
			Clockwork.player:CreateGear(player, "SkullMask", itemTable);
			
			player:SetSharedVar("skullMask", true);
			player:GiveItem(Clockwork.item:CreateInstance(itemTable.uniqueID));
		else
			player:SetCharacterData("skullmask", nil);
		end;
	end;
	
	if (clothes) then
		local itemTable = Clockwork.item:FindByID(clothes);
		local team = player:Team();
		
		if (itemTable and player:HasItemByID(itemTable.uniqueID)) then
			if (!changeClass or (team != CLASS_POLICE and team != CLASS_DISPENSER
			and team != CLASS_RESPONSE)) then
				self:PlayerWearClothes(player, itemTable);
			end;
		else
			player:SetCharacterData("clothes", nil);
		end;
	end;
end;

-- Called when a player's footstep sound should be played.
function Schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	local clothes = player:GetCharacterData("clothes");
	
	if (clothes) then
		local itemTable = Clockwork.item:FindByID(clothes);
		
		if (itemTable) then
			if (player:IsRunning() or player:IsJogging()) then
				if (itemTable.runSound) then
					if (type(itemTable.runSound) == "table") then
						sound = itemTable.runSound[ math.random(1, #itemTable.runSound) ];
					else
						sound = itemTable.runSound;
					end;
				end;
			elseif (itemTable.walkSound) then
				if (type(itemTable.walkSound) == "table") then
					sound = itemTable.walkSound[ math.random(1, #itemTable.walkSound) ];
				else
					sound = itemTable.walkSound;
				end;
			end;
		end;
	end;
	
	player:EmitSound(sound);
	
	return true;
end;

-- Called when a player throws a punch.
function Schema:PlayerPunchThrown(player)
	player:ProgressAttribute(ATB_STRENGTH, 0.25, true);
end;

-- Called when a player punches an entity.
function Schema:PlayerPunchEntity(player, entity)
	if (entity:IsPlayer() or entity:IsNPC()) then
		player:ProgressAttribute(ATB_STRENGTH, 1, true);
	else
		player:ProgressAttribute(ATB_STRENGTH, 0.5, true);
	end;
end;

-- Called when an entity has been breached.
function Schema:EntityBreached(entity, activator)
	if (Clockwork.entity:IsDoor(entity)) then
		if (entity:GetClass() != "prop_door_rotating") then
			Clockwork.entity:OpenDoor(entity, 0, true, true);
		else
			self:BustDownDoor(activator, entity);
		end;
	end;
end;

-- Called when a player takes damage.
function Schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if (player:Health() <= 10 and math.random() <= 0.75) then
		if (Clockwork.player:GetAction(player) != "die") then
			Clockwork.player:SetRagdollState(player, RAGDOLL_FALLENOVER, nil, nil, Clockwork.kernel:ConvertForce(damageInfo:GetDamageForce() * 32));
			
			Clockwork.player:SetAction(player, "die", 60, 1, function()
				if (IsValid(player) and player:Alive()) then
					player:TakeDamage(player:Health() * 2, attacker, inflictor);
				end;
			end);
		end;
	end;
end;

-- Called when a player's limb damage is healed.
function Schema:PlayerLimbDamageHealed(player, hitGroup, amount)
	if (hitGroup == HITGROUP_HEAD) then
		player:BoostAttribute("Limb Damage", ATB_MEDICAL, false);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, false);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, false);
		player:BoostAttribute("Limb Damage", ATB_AGILITY, false);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, false);
		player:BoostAttribute("Limb Damage", ATB_STRENGTH, false);
	end;
end;

-- Called when a player's limb damage is reset.
function Schema:PlayerLimbDamageReset(player)
	player:BoostAttribute("Limb Damage", nil, false);
end;

-- Called when a player's limb takes damage.
function Schema:PlayerLimbTakeDamage(player, hitGroup, damage)
	local limbDamage = Clockwork.limb:GetDamage(player, hitGroup);
	
	if (hitGroup == HITGROUP_HEAD) then
		player:BoostAttribute("Limb Damage", ATB_MEDICAL, -limbDamage);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, -limbDamage);
		player:BoostAttribute("Limb Damage", ATB_AGILITY, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, -limbDamage);
		player:BoostAttribute("Limb Damage", ATB_STRENGTH, -limbDamage);
	end;
end;

-- A function to scale damage by hit group.
function Schema:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	local endurance = Clockwork.attributes:Fraction(player, ATB_ENDURANCE, 0.5, 0.5);
	local clothes = player:GetCharacterData("clothes");
	
	if (damageInfo:IsFallDamage()) then
		damageInfo:ScaleDamage(1 - endurance);
	else
		damageInfo:ScaleDamage(1.25 - endurance);
	end;
	
	if (clothes) then
		local itemTable = Clockwork.item:FindByID(clothes);
		
		if (itemTable and itemTable.protection) then
			if (damageInfo:IsBulletDamage() or (damageInfo:IsFallDamage() and itemTable.protection >= 0.8)) then
				damageInfo:ScaleDamage(1 - itemTable.protection);
			end;
		end;
	end;
end;

-- Called when an entity takes damage.
function Schema:EntityTakeDamage(entity, damageInfo)
	local inflictor, attacker, amount = damageInfo:GetInflictor(), damageInfo:GetAttacker(), damageInfo:GetDamage();
	local curTime = CurTime();
	local player = Clockwork.entity:GetPlayer(entity);
	
	if (player) then
		if (!player.nextEnduranceTime or CurTime() > player.nextEnduranceTime) then
			player:ProgressAttribute(ATB_ENDURANCE, math.Clamp(damageInfo:GetDamage(), 0, 75) / 10, true);
			player.nextEnduranceTime = CurTime() + 2;
		end;
	end;
	
	if (attacker:IsPlayer()) then
		local strength = Clockwork.attributes:Fraction(attacker, ATB_STRENGTH, 1, 0.5);
		local weapon = Clockwork.player:GetWeaponClass(attacker);
		
		if (damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH)) then
			damageInfo:ScaleDamage(1 + strength);
		end;
		
		if (weapon == "weapon_crowbar") then
			if (entity:IsPlayer()) then
				damageInfo:ScaleDamage(0.1);
			else
				damageInfo:ScaleDamage(0.8);
			end;
		end;
	end;
end;