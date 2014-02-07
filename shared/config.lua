SCOREBOARD_CONFIGURATION = 
{
	WIDTH = 0.4, -- Width of the board. Scale from Screen Size.
	HEIGHT = 0.75, -- Heigth of the board. Scale from Screen Size.

	ACTIVATION_BUTTON = 9, -- Show scoreboard button.

	COLUMNS = -- Scoreboard collumns
	{
		{name = "ID", width = 50, getter = function(CBoardClientInstance, p) return p:GetId(); end },
		{name = "Rank", width = 100, getter = function(CBoardClientInstance, p) return tostring(CBoardClientInstance.tServerPlayersData[p:GetId()].group); end},
		{name = "Player", width = 200, getter = function(CBoardClientInstance, p) return string.sub(p:GetName(), 1, 40); end},
		{name = "Money", width = 80, getter = function(CBoardClientInstance, p) return "$"..formatNumber(CBoardClientInstance.tServerPlayersData[p:GetId()].money); end},
		{name = "Kills", width = 80, getter = function(CBoardClientInstance, p) return tostring(CBoardClientInstance.tServerPlayersData[p:GetId()].kills); end},
		{name = "Deaths", width = 80, getter = function(CBoardClientInstance, p) return tostring(CBoardClientInstance.tServerPlayersData[p:GetId()].deaths); end},
		{name = "Ping", width = 60, getter = function(CBoardClientInstance, p) return tostring(CBoardClientInstance.tServerPlayersData[p:GetId()].ping); end},
	},

	SYNC_DATA =
	{
		ping = function(player) return player:GetPing(); end,
		group = function(player) return player:GetGroup(); end,
		money = function(player) return player:GetMoney(); end,
		kills = function(player) return CStats:getPlayerStat(player, "kills") or 0; end,
		deaths = function(player) return CStats:getPlayerStat(player, "deaths") or 0; end
	},

	SCROLL_SPEED = 2,

	SYNC_INTERVAL = 5, -- Sync interval in seconds;

	INSTANT_STATS_UPDATE = {"kills", "deaths"} -- Values from CStats, thath should be instantly updated.
}