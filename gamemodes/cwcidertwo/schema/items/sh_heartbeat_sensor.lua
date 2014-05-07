--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Heartbeat Sensor";
ITEM.cost = 80;
ITEM.model = "models/gibs/shield_scanner_gib1.mdl";
ITEM.weight = 1.5;
ITEM.classes = {CLASS_BLACKMARKET, CLASS_DISPENSER};
ITEM.category = "Reusables"
ITEM.business = true;
ITEM.description = "A state-of-the-art heartbeat sensor.";

-- Called when the item's local amount is needed.
function ITEM:GetLocalAmount(amount)
	if (Clockwork.Client:GetSharedVar("sensor")) then
		return amount - 1;
	else
		return amount;
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, arguments)
	return player:GetSharedVar("sensor");
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, arguments)
	player:SetCharacterData("sensor", nil);
	player:SetSharedVar("sensor", false);
	player:GiveItem(Clockwork.item:CreateInstance(self.uniqueID));
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:Alive() and !player:IsRagdolled()) then
		player:SetCharacterData("sensor", true);
		player:SetSharedVar("sensor", true);
		player:GiveItem(Clockwork.item:CreateInstance(self.uniqueID));
			
		if (itemEntity) then
			return true;
		end;
	else
		Clockwork.player:Notify(player, "You don't have permission to do this right now!");
	end;
		
	return false;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;
ITEM:Register();