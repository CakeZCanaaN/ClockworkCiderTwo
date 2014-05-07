--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("SetAgenda");
COMMAND.tip = "Set the active government agenda.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local team = player:Team();
		
	if (team == CLASS_PRESIDENT) then
		Clockwork.kernel:SetSharedVar("agenda", arguments[1]); 
	else
		Clockwork.player:Notify(player, "You are not the president!");
	end;
end;
COMMAND:Register();