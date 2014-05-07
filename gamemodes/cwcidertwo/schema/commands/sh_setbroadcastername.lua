--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("SetBroadcasterName");
COMMAND.tip = "Set the name of a broadcaster.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
		
	if (IsValid(target)) then
		if (target:GetPos():Distance( player:GetShootPos() ) <= 192) then
			if (target:GetClass() == "cw_broadcaster") then
				target:SetNetworkedString( "name", arguments[1] );
			else
				Clockwork.player:Notify(player, "This entity is not a broadcaster!");
			end;
		else
			Clockwork.player:Notify(player, "This entity is too far away!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end;
COMMAND:Register();