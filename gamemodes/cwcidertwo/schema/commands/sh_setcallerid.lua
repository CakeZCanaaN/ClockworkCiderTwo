--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("SetCallerID");
COMMAND.tip = "Set your caller ID, or cell phone number.";
COMMAND.text = "<string ID>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();

	if (!player.nextCallerID or player.nextCallerID < curTime) then
		local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
		local schemaFolder = Clockwork.kernel:GetSchemaFolder();
		local callerID = string.gsub(arguments[1], "%s%p", "");
			
		if (callerID == "911" or callerID == "912") then
			Clockwork.player:Notify(player, "You cannot set your cell phone number to this!");
				
			return;
		end;
		
		local queryObj = Clockwork.database:Select(charactersTable);
			queryObj:AddWhere("_Schema = ?", schemaFolder);
			queryObj:AddWhere("_Data LIKE ?", "%\"callerid\":\""..callerID.."\"%");
			queryObj:SetCallback(function(result)
				if (IsValid(player)) then
					if (Clockwork.database:IsResult(result)) then
						Clockwork.player:Notify(player, "The cell phone number '"..callerID.."' already exists!");
					else
						player:SetCharacterData("callerid", callerID);
							
						Clockwork.player:Notify(player, "You set your cell phone number to '"..callerID.."'.");
					end;
				end;
			end);
		queryObj:Pull();

		player.nextCallerID = curTime + 5;
	else
		Clockwork.player:Notify(player, "You must wait before you set your caller ID again!");
	end;
end;
COMMAND:Register();