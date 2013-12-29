class 'CBoardServer'

function CBoardServer:__init()
	self.tSyncData = SCOREBOARD_CONFIGURATION.SYNC_DATA;

	self.iSyncInterval = SCOREBOARD_CONFIGURATION.SYNC_INTERVAL;
	self.fLastUpdate = 0;

	-- Attach event handlers
	Events:Subscribe("PostTick", self, self.onPostTick);
	Events:Subscribe("onPlayerStatChanged", self, self.onPlayerStatChanged);
	--Events:Subscribe("ClientModuleLoad", self, self.SyncPlayersData);

	-- Attach network events handlers
	Network:Subscribe("SyncRequest", self, self.onSyncRequest);
end

function CBoardServer:SyncPlayersData()
	Network:Broadcast("SyncPlayerData", 
		{
			playersData = self:getPlayersDataList(),
			slotsNum = Config:GetValue("Server", "MaxPlayers")
		});
	return self;
end

function CBoardServer:SyncPlayerData(player)
	Network:Send(player, "SyncPlayerData", 
		{
			playersData = self:getPlayersDataList(),
			slotsNum = Config:GetValue("Server", "MaxPlayers")
		});
	return self;
end

function CBoardServer:UpdatePlayerStats(player, stats)
	local syncStats = {};
	if (type(stats) == "string") then stats = {stats}; end
	for i, v in ipairs(stats) do
		syncStats[v] = CStats:getPlayerStat(player, v);
	end
	Network:Broadcast("UpdatePlayerStats", {playerId = player:GetId(), stats = syncStats});
	return self;
end

-- Setters/Getters:
function CBoardServer:getPlayersDataList()
	local data = {};
	for p in Server:GetPlayers() do
		local id = p:GetId();
		data[id] = {};
		for k, f in pairs(self.tSyncData) do
			data[id][k] = f(p);
		end
	end
	return data;
end


-- Event Handlers:
function CBoardServer:onPostTick()
	if (Server:GetElapsedSeconds() - self.fLastUpdate >= self.iSyncInterval) then
		self:SyncPlayersData();
		self.fLastUpdate = Server:GetElapsedSeconds();
	end
end

function CBoardServer:onPlayerStatChanged(args)
	if (table.isValue(SCOREBOARD_CONFIGURATION.INSTANT_STATS_UPDATE, args.stat)) then
		Chat:Broadcast("CBoardServer:onPlayerStatChanged: ".. args.player:GetName().."'s stat \""..args.stat.."\" changed from "..tostring(args.oldvalue).." to "..tostring(args.newvalue), Color( 0, 255, 0 ));
		self:UpdatePlayerStats(args.player, args.stat);
	end
end

-- Network event handlers:
function CBoardServer:onSyncRequest(source)
	self:SyncPlayerData(source);
end

Events:Subscribe("ModuleLoad", function()
	CBoardServer = CBoardServer();
end);