class 'CBoardClient'

function CBoardClient:__init()
	-- Board settings
	self.iStartShowRow = 0; -- Start show players from

	self.fBoardWidth = 0.4;
	self.fBoardHeight = 0.75;

	self.iActivationButton = 18;

	self.tBorderColls = 
	{
		{name = "ID", width = 0.1, getter = function(CBoardClientInstance, p) return p:GetId(); end },
		{name = "Player", width = 0.5, getter = function(CBoardClientInstance, p) return string.sub(p:GetName(), 1, 40); end},
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

	-- Attach network events handlers
	Network:Subscribe("SyncPlayerData", self, self.onSyncPlayerData);

	-- Activate server side
	Network:Send("onClientLoaded", LocalPlayer);
end

function CBoardClient:Update()
	self:setPlayers(Client:getServerPlayers());
end

function CBoardClient:SyncRequest()
	Network:Send("SyncRequest", LocalPlayer);
	return self;
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

function CBoardClient:isHudVisible()
	return Key:IsDown(self.iActivationButton);
end

-- Event Handlers:
function CBoardClient:onMouseScroll(args)
	if (self:isHudVisible()) then
		self:setStartShowRow(self:getStartShowRow() - (args.delta * self.fScrollKoeff));
	end
end

-- Network event handlers:
function CBoardClient:onSyncPlayerData(data)
	self.tServerPlayersData = data.playersData;
	self.iServerSlots = data.slotsNum
end


Events:Subscribe("ModuleLoad", function()
	CBoardClient = CBoardClient();
end);