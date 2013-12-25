class 'CBoardServer'

function CBoardServer:__init()
	self.tSyncData = 
	{
		ping = function(p) return p:GetPing(); end,
		money = function(p) return p:GetMoney(); end,
	};

	self.iSyncInterval = 5; -- Sync interval in seconds;
	self.fLastUpdate = 0;

	-- Attach event handlers
	Events:Subscribe("PostTick", self, self.onPostTick);
	Events:Subscribe("PlayerJoin", self, function() self:SyncPlayersData(); end);

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

-- Network event handlers:
function CBoardServer:onSyncRequest(source)
	self:SyncPlayerData(source);
end


Network:Subscribe("onClientLoaded", function()
	CBoardServer = CBoardServer();
end);