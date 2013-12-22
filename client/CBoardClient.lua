class 'CBoardClient'

function CBoardClient:__init()
	-- Board settings
	self.iStartShowRow = 0; -- Start show players from

	self.fBoardWidth = 0.4;
	self.fBoardHeight = 0.75;

	self.tBorderColls = 
	{
		{name = "ID", width = 0.1, getter = function(CBoardClientInstance, p) return p:GetId(); end },
		{name = "Player", width = 0.5, getter = function(CBoardClientInstance, p) return p:GetName(); end},
		{name = "Money", width = 0.3, getter = function(CBoardClientInstance, p) return "$"..formatNumber(self.tServerPlayersData[p:GetId()].money); end},
		{name = "Ping", width = 0.1, getter = function(CBoardClientInstance, p) return tostring(self.tServerPlayersData[p:GetId()].ping); end},
	};

	self.fScrollKoeff = 2;

	self.tServerPlayersData = {};
	self.iServerSlots = 0;

	-- Create an instance of CBoardGUI
	self.CBoardGUI = CBoardHud(self, self.fBoardWidth, self.fBoardHeight, self.tBorderColls);

	-- Attach events handlers
	Events:Subscribe("MouseScroll", self, self.onMouseScroll);
	Events:Subscribe("PlayerJoin", self, function()
		CDebug:Print("onPlayerJoinHandler");
		self:SyncRequest(); 
	end);

	-- Attach network events handlers
	Network:Subscribe("SyncPlayersData", self, self.onSyncPlayersData);
end


function CBoardClient:Update()
	self:setPlayers(Client:getServerPlayers());
end

function CBoardClient:SyncRequest()
	CDebug:Print("CBoardClient:SyncRequest");
	Network:Send("SyncRequest", LocalPlayer);
end

-- Setters/Getters:
function CBoardClient:setStartShowRow(row)
	self.iStartShowRow = math.max(row, 0);
	if (self.iStartShowRow + self.CBoardGUI:getAvailibleRows() > #self:getPlayers()) then
		self.iStartShowRow = #self:getPlayers() - self.CBoardGUI:getAvailibleRows();
	end
	return self;
end

function CBoardClient:getStartShowRow()
	return self.iStartShowRow;
end

function CBoardClient:getPlayers()
	return self.ServerPlayers;
end

function CBoardClient:setPlayers(players)
	self.ServerPlayers = players;
	return self;
end

function CBoardClient:getPlayersCount()
	return #self.ServerPlayers;
end

function CBoardClient:getServerSlots()
	return self.iServerSlots;
end

function CBoardClient:isPlayerAllowedForDraw(player)
	return type(self.tServerPlayersData[player:GetId()]) ~= "nil";
end

-- Event Handlers:
function CBoardClient:onMouseScroll(args)
	self:setStartShowRow(self:getStartShowRow() - (args.delta * self.fScrollKoeff));
end

-- Network event handlers:
function CBoardClient:onSyncPlayersData(data)
	--[[
	for id, tData in pairs(data) do
		CDebug:Print("ID="..tostring(id));
		for k, v in pairs(tData) do
			CDebug:Print(tostring(k).." = "..tostring(v));
		end
	end
	]]
	self.tServerPlayersData = data.playersData;
	self.iServerSlots = data.slotsNum
end



Events:Subscribe("ModulesLoad", function()
	CBoardClient = CBoardClient();
end);