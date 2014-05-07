--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Drug Base";
ITEM.model = "models/cocn.mdl";
ITEM.weight = 0.1;
ITEM.useText = "Get High";
ITEM.attributes = {};
ITEM.expireTime = 3600;
ITEM.isBaseItem = true;
ITEM.description = "A generic illegal high, feels good man.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local action = Clockwork.player:GetAction(player);
		
	if (action != "drug") then
		local consumeTime = Schema:GetDexterityTime(player);
			
		Clockwork.player:SetAction(player, "drug", consumeTime, nil, function()
			if (IsValid(player)) then
				Clockwork.datastream:Start(player, "GetHigh", self.expireTime / 3);
					
				Clockwork.player:SetDrunk(player, self.expireTime / 8);
					
				player:TakeItem(self);
				
				for k, v in pairs(self.attributes) do
					player:BoostAttribute(self.name, k, v, self.expireTime);
				end;
			end;
		end);
			
		Clockwork.player:SetMenuOpen(player, false);
			
		if (itemEntity) then
			return true;
		else
			return false;
		end;
	else
		Clockwork.player:Notify(player, "Your character is already getting high!");
			
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	local action = Clockwork.player:GetAction(player);
		
	if (action == "drug") then
		Clockwork.player:Notify(player, "Your character is already getting high!");
		
		return false;
	end;
end;
ITEM:Register();