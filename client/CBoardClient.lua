class 'CBoardClient'

function CBoardClient:__init()
	-- Board settings
	self.iStartShowRow = 0; -- Start show players from

	self.fBoardWidth = SCOREBOARD_CONFIGURATION.WIDTH;
	self.fBoardHeight = SCOREBOARD_CONFIGURATION.HEIGHT;

	self.iActivationButton = SCOREBOARD_CONFIGURATION.ACTIVATION_BUTTON;

	self.tBorderCols = SCOREBOARD_CONFIGURATION.COLUMNS;

	self.fScrollKoeff = SCOREBOARD_CONFIGURATION.SCROLL_SPEED;

	self.tServerPlayersData = {};
	self.iServerSlots = 0;


	-- Create an instance of CBoardGUI
	self.CBoardGUI = CBoardHud(self, self.fBoardWidth, self.fBoardHeight, self.tBorderCols);

	-- Attach events handlers
	Events:Subscribe("MouseScroll", self, self.onMouseScroll);

	-- Attach network events handlers
	Network:Subscribe("SyncPlayerData", self, self.onSyncPlayerData);
	Network:Subscribe("UpdatePlayerStats", self, self.onUpdatePlayerStats);
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

function CBoardClient:onUpdatePlayerStats(args)
	if (self.tServerPlayersData[args.playerId]) then
		for k, v in pairs(args.stats) do
			self.tServerPlayersData[args.playerId][k] = v;
		end
	end
end

Events:Subscribe("ModuleLoad", function()
	CBoardClient = CBoardClient();
end);