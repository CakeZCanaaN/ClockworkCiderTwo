--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("CharDemote");
COMMAND.tip = "Demote a character from their position.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local isAdmin = ( player:IsUserGroup("operator") or player:IsAdmin() );
		
	if (player:Team() == CLASS_PRESIDENT or isAdmin) then
		local target = Clockwork.player:FindByID( arguments[1] );
			
		if (target) then
			local team = target:Team();
				
			if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE
			or team == CLASS_SECRETARY or isAdmin) then
				local name = _team.GetName(team);
				
				Clockwork.player:Notify(player, "You have demoted "..target:Name().." from "..name..".");
				Clockwork.player:Notify(target, player:Name().." has demoted you from "..name..".");
				
				Clockwork.class:Set(target, CLASS_CIVILIAN, true, true);
			else
				Clockwork.player:Notify(player, target:Name().." cannot be demoted from this position!");
			end;
		else
			Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
		end;
	else
		Clockwork.player:Notify(player, "You are not the president, or an administrator!");
	end;
end;
COMMAND:Register();