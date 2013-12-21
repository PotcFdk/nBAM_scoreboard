class 'CBoardClient'


function CBoardClient:__init()
	-- Board settings
	self.iStartShowRow = 0; -- Start show players from

	self.fBoardWidth = 0.4;
	self.fBoardHeight = 0.75;

	self.tBorderRows = 
	{
		{name = "ID", width = 0.1, getter = function(p) return p:GetId(); end },
		{name = "Player", width = 0.8, getter = function(p) return p:GetName(); end}
	};

	self.fScrollKoeff = 2;

	-- Create CBoardHud class object for work with Hud.
	self.CBoardGUI = CBoardHud(self, self.fBoardWidth, self.fBoardHeight, self.tBorderRows);

	-- Attach events handlers
	Events:Subscribe("MouseScroll", self, self.MouseScroll);
end


function CBoardClient:Update()
	self:setPlayers(Client:getServerPlayers());
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

-- Event Handlers:
function CBoardClient:MouseScroll(args)
	self:setStartShowRow(self:getStartShowRow() - (args.delta * self.fScrollKoeff));
end

Events:Subscribe("ModulesLoad", function()
	CBoardClient = CBoardClient();
end);