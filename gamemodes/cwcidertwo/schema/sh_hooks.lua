--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when the Clockwork shared variables are added.
function Clockwork.kernel:ClockworkAddSharedVars(globalVars, playerVars)
	globalVars:Number("noWagesTime");
	globalVars:Number("lottery");
	globalVars:String("agenda");
	playerVars:Bool("beingChloro");
	playerVars:Bool("skullMask");
	playerVars:Bool("beingTied");
	playerVars:String("alliance");
	playerVars:Entity("disguise");
	playerVars:Number("clothes", true);
	playerVars:Bool("lottery", true);
	playerVars:Bool("sensor", true);
	playerVars:Bool("dead", true);
	playerVars:Number("hunger", true);
	playerVars:Number("thirst", true);
	playerVars:Bool("leader");
	playerVars:Number("tied");
end;