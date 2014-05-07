--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("PlyUnblacklist");
COMMAND.tip = "Unlacklist a player from a class.";
COMMAND.text = "<string Name> <string Class>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID( arguments[1] )
	local class = Clockwork.class:FindByID( arguments[2] )
		
	if (target) then
		local blacklist = target:GetData("Blacklist");
			
		if (class) then
			if (!table.HasValue(blacklist, class.index)) then
				Clockwork.player:Notify(player, target:Name().." is not on the "..class.." blacklist!");
			else
				Clockwork.player:NotifyAll(player:Name().." has removed "..target:Name().." from the "..class.name.." blacklist.");
					
				Clockwork.datastream:Start( {target}, "SetBlacklisted", {class.index, false} );
					
				for k, v in ipairs(blacklist) do
					if (v == class.index) then
						table.remove(blacklist, k);
							
						break;
					end;
				end;
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid class!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;
COMMAND:Register();