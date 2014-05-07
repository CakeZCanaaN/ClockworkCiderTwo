--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("Call");
COMMAND.tip = "Call another character.";
COMMAND.text = "<string ID> <string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playerCallerID = player:GetCharacterData("callerid");
		
	if (playerCallerID and playerCallerID != "") then
		local eavesdroppers = {};
		local talkRadius = Clockwork.config:Get("talk_radius"):Get();
		local listeners = {};
		local position = player:GetShootPos();
		local callerID = string.gsub(arguments[1], "%s%p", "");
		local text = table.concat(arguments, " ", 2);
			
		if (playerCallerID != callerID) then
			for k, v in ipairs( _player.GetAll() ) do
				if (v:HasInitialized() and v:Alive()) then
					if (v:GetCharacterData("callerid") == callerID) then
						listeners[#listeners + 1] = v;
					elseif (v:GetShootPos():Distance(position) <= talkRadius) then
						if (player != v) then
							eavesdroppers[#eavesdroppers + 1] = v;
						end;
					end;
				end;
			end;
				
			if (#listeners > 0) then
				listeners[#listeners + 1] = player;
					
				Clockwork.chatBox:Add( listeners, player, "call", text, {id = playerCallerID} );
				
				if (#eavesdroppers > 0) then
					Clockwork.chatBox:Add(eavesdroppers, player, "call_eavesdrop", text);
				end;
			else
				Clockwork.player:Notify(player, "The number you dialled could not be found!");
			end;
		else
			Clockwork.player:Notify(player, "You cannot call your own number!");
		end;
	else
		Clockwork.player:Notify(player, "You have not set a cell phone number!");
	end;
end;
COMMAND:Register();