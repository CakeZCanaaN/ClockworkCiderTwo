--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("VehiclePhysDesc");
	COMMAND.tip = "Set the physical description of a vehicle.";
	COMMAND.text = "[string Text]";
	COMMAND.flags = CMD_DEFAULT;
	COMMAND.arguments = 0;

	-- Called when the command has been run.
	function COMMAND:OnRun(player, arguments)
		local target = player:GetEyeTraceNoCursor().Entity;

		if (IsValid(target) and target:IsVehicle() and target.ItemTable) then
			if (target:GetPos():Distance( player:GetShootPos() ) <= 192) then
				if (player.vehicles and player.vehicles[target]) then
					if (arguments[1]) then
						local text = table.concat(arguments, " ");

						if (string.len(text) < 8) then
							Clockwork.player:Notify(player, "You did not specify enough text!");

							return;
						end;

						target.PhysDesc = Clockwork.kernel:ModifyPhysDesc(text);
						target:SetNetworkedString("physDesc", target.PhysDesc);
					else
						player.vehiclePhysDesc = target;

						Clockwork.datastream:Start(player, "VehiclePhysDesc", target);
					end;
				else
					Clockwork.player:Notify(player, "You are not the owner of this vehicle!");
				end;
			else
				Clockwork.player:Notify(player, "This entity is too far away!");
			end;
		else
			Clockwork.player:Notify(player, "You must look at a valid vehicle!");
		end;
	end;
COMMAND:Register();