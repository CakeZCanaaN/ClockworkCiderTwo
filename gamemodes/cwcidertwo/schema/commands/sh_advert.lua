--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("Advert");
COMMAND.tip = "Send out an advert to all players.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (Clockwork.player:CanAfford(player, 10)) then
		Clockwork.chatBox:Add( nil, player, "advert", arguments[1] );
		Clockwork.player:GiveCash(player, -10, "making an advert");
	else
		Clockwork.player:Notify(player, "You need another "..Clockwork.kernel:FormatCash(10 - player:GetCash(), nil, true).."!");
	end;
end;
COMMAND:Register();