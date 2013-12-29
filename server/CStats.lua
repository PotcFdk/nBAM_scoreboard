class 'CStats'

function CStats:__init()
	self.tStatsData = {};

	-- Attach events handlers
	Events:Subscribe("PlayerDeath", self, self.onPlayerDeath);
end

function CStats:setPlayerStat(player, stat, value)
	if (not self.tStatsData[player:GetId()]) then
		self.tStatsData[player:GetId()] = {};
	end
	local oldVal = self.tStatsData[player:GetId()][stat];
	self.tStatsData[player:GetId()][stat] = value;
	Events:Fire("onPlayerStatChanged", {player = player, stat=stat, oldvalue = oldVal, newvalue = value});
	return self;
end

function CStats:getPlayerStat(player, stat)
	if (not self.tStatsData[player:GetId()]) then
		return false;
	end
	return self.tStatsData[player:GetId()][stat];
end


function CStats:onPlayerDeath(args)
	local deaths = self:getPlayerStat(args.player, "deaths") or 0;
	self:setPlayerStat(args.player, "deaths", deaths + 1);

	local kills = self:getPlayerStat(args.killer, "kills") or 0;
	self:setPlayerStat(args.killer, "kills", kills + 1);
end

CStats = CStats();
