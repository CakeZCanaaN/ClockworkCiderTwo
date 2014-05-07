--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

Clockwork.datastream:Hook("VehiclePhysDesc", function(data)
	if (IsValid(data)) then
		Derma_StringRequest("Description", "What is the physical description of this vehicle?", nil, function(text)
			Clockwork.datastream:Start( "VehiclePhysDesc", {data, text} );
		end);
	end;
end);