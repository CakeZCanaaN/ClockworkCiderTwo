--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("Broadcast");
COMMAND.tip = "Broadcast a message as the president.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:Team() == CLASS_PRESIDENT) then
		Clockwork.chatBox:Add( nil, player, "president", arguments[1] );
	else
		Clockwork.player:Notify(player, "You are not the president!");
	end;
end;
COMMAND:Register();