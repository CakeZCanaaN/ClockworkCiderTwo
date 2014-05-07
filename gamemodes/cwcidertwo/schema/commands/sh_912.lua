--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("912");
COMMAND.tip = "Send a message out to all secretaries.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playerCallerID = player:GetCharacterData("callerid");
		
	if (playerCallerID and playerCallerID != "") then
		local curTime = CurTime();
			
		if (!player.nextSend912 or curTime >= player.nextSend912) then
			local eavesdroppers = {};
			local talkRadius = Clockwork.config:Get("talk_radius"):Get();
			local listeners = {};
			local position = player:GetShootPos();
				
			for k, v in ipairs( _player.GetAll() ) do
				if (v:Team() == CLASS_SECRETARY or player == v) then
					listeners[#listeners + 1] = v;
				elseif (v:GetShootPos():Distance(position) <= talkRadius) then
					eavesdroppers[#eavesdroppers + 1] = v;
				end;
			end;
				
			player.nextSend912 = curTime + 30;
				
			if (#listeners > 0) then
				Clockwork.player:Notify("The line is busy, or there is nobody to take the call!");
					
				Clockwork.chatBox:Add( listeners, player, "912", arguments[1], {id = playerCallerID} );
					
				if (#eavesdroppers > 0) then
					Clockwork.chatBox:Add( eavesdroppers, player, "912_eavesdrop", arguments[1] );
				end;
			end;
		else
			Clockwork.player:Notify(player, "You can not call 912 for another "..math.Round( math.ceil(player.nextSend912 - curTime) ).." second(s)!");
		end;
	else
		Clockwork.player:Notify(player, "You have not set a cell phone number!");
	end;
end;
COMMAND:Register();