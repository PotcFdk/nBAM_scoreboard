class 'CBoardHud'

function CBoardHud:__init(CBoardClient, width, height, rows)
	self.CBoardClient = CBoardClient;

	-- Settings:
	self.fBoardWidth = width;
	self.fBoardHeight = height;

	self.Color_BordersColor = Color(255, 255, 255, 255);

	self.Color_HeaderColor = Color(0, 0, 0, 90);
	self.Color_HeaderTextColor = Color(255, 255, 255, 255);
	self.fHeaderRowHeight = 28;
	self.fTextSize = 15;

	self.tPlayerRowColor = {
							    Color(0, 0, 0, 70); -- even rows
							    Color(0, 0, 0, 50); -- odd rows
						   };
	self.fPlayerRowHeight = 25;

	self.tBorderRows = rows or
	{
		{name = "ID", width = 0.1, getter = function(p) return p:GetId(); end },
		{name = "Player", width = 0.8, getter = function(p) return p:GetName(); end},
	};

	self.fScrollLineWidth = 10;
	self.Color_ScrollLineColor = {
									default = Color(0, 0, 0, 100),
									hover 	= Color(0, 0, 0, 150)
								 }
	self.fScrollLinePadding = 5;

	self:Update();
	
	-- Attach events handlers
	Events:Subscribe("Render", self, self.Render);
end

function CBoardHud:Update()
	self.CBoardClient:Update();

	self.ScreenSize = Render:GetScreenSize();
	self.BoardPosition = self:getPosition();
	self.BoardSize = self:getSize();
	self.iAvailibleRows = self:getAvailibleRows();


	self:ResetBoardRealHeight();
	self:ResetRowsCounter();
end

function CBoardHud:getSize()
	return { 
				width = math.floor(self.ScreenSize.width * self.fBoardWidth), 
				height = math.floor(self.ScreenSize.height * self.fBoardHeight)
		   };
end

function CBoardHud:getPosition()
	local size = self:getSize();
	return { 
				x = math.floor((self.ScreenSize.width / 2) - (size.width / 2)),
				y = math.floor((self.ScreenSize.height / 2) - (size.height / 2)) 
		   };
end


function CBoardHud:getAvailibleRows()
	return math.floor(math.min(((self.BoardSize.height - self.fHeaderRowHeight) / self.fPlayerRowHeight), #self.CBoardClient:getPlayers()));
end 

function CBoardHud:ResetRowsCounter()
	self._rows = 0;
	return self;
end 

function CBoardHud:IncreaseRowsCounter(num)
	num = num or 1;
	self._rows = self._rows + num;
	return self;
end

function CBoardHud:getRowsCounter()
	return self._rows or 0;
end 

function CBoardHud:ResetBoardRealHeight()
	self.fBoardRealHeight = 0;
	return self;
end 

function CBoardHud:IncreaseBoardRealHeight(num)
	num = num or 1;
	self.fBoardRealHeight = self.fBoardRealHeight + num;
	return self;
end

function CBoardHud:getBoardRealHeight()
	return self.fBoardRealHeight or 0;
end


function CBoardHud:Render()
	self:Update();
	if (not Key:IsDown(18))then
			return end;

	Mouse:SetVisible(false);

	self:DrawHeader();
	self:DrawCanvas();
	self:DrawPlayersRows();
	self:DrawScrollLine();
end

function CBoardHud:DrawHeader()
	Render:FillArea(Vector2(self.BoardPosition.x-1, self.BoardPosition.y), 
		Vector2(self.BoardSize.width + 1, self.fHeaderRowHeight), self.Color_HeaderColor);

	-- Header collumns:
	local w = 0;
	for i, v in ipairs(self.tBorderRows) do
		local text = v.name..":";
		local height = Render:GetTextHeight(text, self.fTextSize, 1);
		Render:DrawText(Vector2(w + self.BoardPosition.x + 10, self.BoardPosition.y + (self.fHeaderRowHeight / 2 - height / 2)), text, 
			self.Color_HeaderTextColor, 15, 1);
		w = w + math.floor(self.BoardSize.width * v.width);
	end


	self:IncreaseBoardRealHeight(self.fHeaderRowHeight);
	self:IncreaseRowsCounter();

	return self;
end

function CBoardHud:DrawCanvas()
	-- Under Header line
	Render:DrawLine(Vector2(self.BoardPosition.x - 1, self.BoardPosition.y + self.fHeaderRowHeight), 
		Vector2(self.BoardPosition.x + self.BoardSize.width + 1, self.BoardPosition.y + self.fHeaderRowHeight), 
		self.Color_BordersColor);

	return self;
end

function CBoardHud:DrawPlayerRow(player, ddd)
	local row = self:getRowsCounter() - 1;
	local y =  math.floor(self.BoardPosition.y + self:getBoardRealHeight());
	Render:FillArea(Vector2(self.BoardPosition.x - 1, y), 
			Vector2(self.BoardSize.width + 1, self.fPlayerRowHeight), self.tPlayerRowColor[(row % 2) + 1]);


	-- Player collumns:
	local w = 0;
	for i, v in ipairs(self.tBorderRows) do
		local text = tostring(v.getter(player));
		local height = Render:GetTextHeight(text, self.fTextSize, 1);
		Render:DrawBorderedText(Vector2(w + self.BoardPosition.x + 10, y + (height / 2)), text..tostring(ddd), 
   			player:GetColor(), self.fTextSize, 1);
		w = w + math.floor(self.BoardSize.width * v.width);
	end

	self:IncreaseBoardRealHeight(self.fPlayerRowHeight);
	self:IncreaseRowsCounter();
	return self;
end

function CBoardHud:DrawPlayersRows()
	for i = 1, self.iAvailibleRows do
		local player = self.CBoardClient:getPlayers()[i + self.CBoardClient:getStartShowRow()];
		self:DrawPlayerRow(player, i + self.CBoardClient:getStartShowRow());
	end
	return self;
end


function CBoardHud:DrawScrollLine()

	if (#self.CBoardClient:getPlayers() <= self:getAvailibleRows()) then
		return end;

	local boardHeight = self:getBoardRealHeight();
	local scrollHeight = math.floor((boardHeight - self.fHeaderRowHeight) * (self:getAvailibleRows() / #self.CBoardClient:getPlayers()));
	local scrollPosY = math.floor((self.BoardPosition.y + self.fHeaderRowHeight) + ((boardHeight - self.fHeaderRowHeight) * (self.CBoardClient:getStartShowRow() / #self.CBoardClient:getPlayers())))

	Render:FillArea(Vector2(self.BoardPosition.x + self.BoardSize.width + self.fScrollLinePadding, scrollPosY), 
		Vector2(self.fScrollLineWidth, scrollHeight), self.Color_ScrollLineColor.default);

	return self;
end