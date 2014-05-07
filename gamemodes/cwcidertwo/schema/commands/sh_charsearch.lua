--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("CharSearch");
COMMAND.tip = "Search a character if they are tied.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.entity:GetPlayer(player:GetEyeTraceNoCursor().Entity);
		
	if (target) then
		if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
			if (player:GetSharedVar("tied") == 0) then
				if (target:GetSharedVar("tied") != 0) then
					if (target:GetSharedVar("tied") == 2) then
						local team = player:Team();
						
						if (team != CLASS_POLICE and team != CLASS_DISPENSER and team != CLASS_RESPONSE
						and team != CLASS_SECRETARY and team != CLASS_PRESIDENT) then
							Clockwork.player:Notify(player, "You cannot search characters tied by a government class!");
								
							return;
						end;
					end;
						
					if (target:GetVelocity():Length() == 0) then
						if (!player.searching) then
							target.beingSearched = true;
							player.searching = target;
								
							Clockwork.storage:Open(player, {
								name = Clockwork.player:FormatRecognisedText(player, "%s", target),
								weight = target:GetMaxWeight(),
								entity = target,
								distance = 192,
								cash = Clockwork.player:GetCash(target),
								inventory = target:GetInventory(),
								OnClose = function(player, storageTable, entity)
									player.searching = nil;
									
									if (IsValid(entity)) then
										entity.beingSearched = nil;
									end;
								end,
								OnTakeItem = function(player, storageTable, itemTable)
									local target = Clockwork.entity:GetPlayer(storageTable.entity);
									
									if (target) then
										if (target:GetCharacterData("clothes") == itemTable.index) then
											if (!target:HasItemByID(itemTable.index)) then
												target:SetCharacterData("clothes", nil);
												
												itemTable:OnChangeClothes(target, false);
											end;
										elseif (target:GetSharedVar("skullMask")) then
											if (!target:HasItemByID(itemTable.index)) then
												itemTable:OnPlayerUnequipped(target);
											end;
										end;
									end;
								end,
								OnGiveItem = function(player, storageTable, itemTable)
									if (player:GetCharacterData("clothes") == itemTable.index) then
										if (!player:HasItemByID(itemTable.index)) then
											player:SetCharacterData("clothes", nil);
												
											itemTable:OnChangeClothes(player, false);
										end;
									elseif (player:GetSharedVar("skullMask")) then
										if (!player:HasItemByID(itemTable.index)) then
											itemTable:OnPlayerUnequipped(player);
										end;
									end;
								end,
								CanTakeItem = function(target, storageTable, item)
									local itemTable = Clockwork.item:FindByID(item);
									local team = player:Team();
										
									if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE
									or team == CLASS_SECRETARY or team == CLASS_PRESIDENT) then
										if (!itemTable.classes or !table.HasValue(itemTable.classes, CLASS_BLACKMARKET)) then
											Clockwork.player:Notify(player, "You can only take illegal items as a government class!");
												
											return false;
										else
											return true;
										end;
									else
										return true;
									end;
								end,
								CanTakeCash = function(target, storageTable, cash)
									local team = player:Team();
										
									if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE
									or team == CLASS_SECRETARY or team == CLASS_PRESIDENT) then
										Clockwork.player:Notify(player, "You can only take illegal items as a government class!");
											
										return false;
									else
										return true;
									end;
								end
							});
						else
							Clockwork.player:Notify(player, "You are already searching a character!");
						end;
					else
						Clockwork.player:Notify(player, "You cannot search a moving character!");
					end;
				else
					Clockwork.player:Notify(player, "This character is not tied!");
				end;
			else
				Clockwork.player:Notify(player, "You don't have permission to do this right now!");
			end;
		else
			Clockwork.player:Notify(player, "This character is too far away!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a character!");
	end;
end;
COMMAND:Register();