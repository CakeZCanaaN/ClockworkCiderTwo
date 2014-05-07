--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("HeadSet");
COMMAND.tip = "Speak to other members of your class using a headset.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local eavesdroppers = {};
	local talkRadius = Clockwork.config:Get("talk_radius"):Get();
	local listeners = {};
	local position = player:GetShootPos();
	local class = Clockwork.class:FindByID( player:Team() );
		
	if (class and class.headsetGroup) then
		for k, v in ipairs( _player.GetAll() ) do
			local targetClass = Clockwork.class:FindByID( v:Team() );
				
			if (!targetClass or targetClass.headsetGroup != class.headsetGroup) then
				if (v:GetShootPos():Distance(position) <= talkRadius) then
					eavesdroppers[#eavesdroppers + 1] = v;
				end;
			else
				listeners[#listeners + 1] = v;
			end;
		end;
			
		if (#eavesdroppers > 0) then
			Clockwork.chatBox:Add( eavesdroppers, player, "headset_eavesdrop", arguments[1] );
		end;
			
		if (#listeners > 0) then
			Clockwork.chatBox:Add( listeners, player, "headset", arguments[1] );
		end;
	else
		Clockwork.player:Notify(player, "Your class does not have a headset!");
	end;
end;
COMMAND:Register();