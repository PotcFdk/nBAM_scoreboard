class 'BoardHud'

function BoardHud:__init()

	-- Settings:
	self.fBoardWidth = 0.4;
	self.fBoardHeight = 0.75;

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

	self.tBorderRows = 
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

	self:update();

	self:setStartShowRow(0);
	
	-- Attach events handlers
	Events:Subscribe("Render", self, self.Render);
	Events:Subscribe("MouseScroll", self, self.Scroll);
end

function BoardHud:update()
	self.ScreenSize = { width = Render.Size.x, height = Render.Size.y };
	self.BoardPosition = self:getPosition();
	self.BoardSize = self:getSize();
	self.ServerPlayers = BoardClient:getPlayers();
	self.iAvailibleRows = self:getAvailibleRows();

	self:ResetBoardRealHeight();
	self:ResetRowsCounter();
end

function BoardHud:getSize()
	return { 
				width = math.floor(self.ScreenSize.width * self.fBoardWidth), 
				height = math.floor(self.ScreenSize.height * self.fBoardHeight)
		   };
end

function BoardHud:getPosition()
	local size = self:getSize();
	return { 
				x = math.floor((self.ScreenSize.width / 2) - (size.width / 2)),
				y = math.floor((self.ScreenSize.height / 2) - (size.height / 2)) 
		   };
end


function BoardHud:getAvailibleRows()
	return math.floor(math.min(((self.BoardSize.height - self.fHeaderRowHeight) / self.fPlayerRowHeight), #self.ServerPlayers));
end 

function BoardHud:ResetRowsCounter()
	self._rows = 0;
	return self;
end 

function BoardHud:IncreaseRowsCounter(num)
	num = num or 1;
	self._rows = self._rows + num;
	return self;
end

function BoardHud:getRowsCounter()
	return self._rows or 0;
end 

function BoardHud:ResetBoardRealHeight()
	self.fBoardRealHeight = 0;
	return self;
end 

function BoardHud:IncreaseBoardRealHeight(num)
	num = num or 1;
	self.fBoardRealHeight = self.fBoardRealHeight + num;
	return self;
end

function BoardHud:getBoardRealHeight()
	return self.fBoardRealHeight or 0;
end

function BoardHud:getStartShowRow()
	return self.iStartShowRow;
end

function BoardHud:setStartShowRow(row)
	self.iStartShowRow = math.max(row, 0);
	if (self.iStartShowRow + self:getAvailibleRows() > #self.ServerPlayers) then
		self.iStartShowRow = #self.ServerPlayers - self:getAvailibleRows();
	end
	return self;
end


function BoardHud:Render()
	self:update();
	if (not Key:IsDown(18))then
			return end;

	Mouse:SetVisible(false);

	self:DrawHeader();
	self:DrawCanvas();
	self:DrawPlayersRows();
	self:DrawScrollLine();
end

function BoardHud:DrawHeader()
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

function BoardHud:DrawCanvas()
	-- Under Header line
	Render:DrawLine(Vector2(self.BoardPosition.x, self.BoardPosition.y + self.fHeaderRowHeight), 
		Vector2(self.BoardPosition.x + self.BoardSize.width, self.BoardPosition.y + self.fHeaderRowHeight), 
		self.Color_BordersColor);

	return self;
end

function BoardHud:DrawPlayerRow(player, ddd)
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

function BoardHud:DrawPlayersRows()
	for i = 1, self.iAvailibleRows do
		local player = self.ServerPlayers[i + self:getStartShowRow()];
		self:DrawPlayerRow(player, i + self:getStartShowRow());
	end
	return self;
end


function BoardHud:DrawScrollLine()

	if (#self.ServerPlayers <= self:getAvailibleRows()) then
		return end;

	local boardHeight = self:getBoardRealHeight();
	local scrollHeight = math.floor((boardHeight - self.fHeaderRowHeight) * (self:getAvailibleRows() / #self.ServerPlayers));
	local scrollPosY = math.floor((self.BoardPosition.y + self.fHeaderRowHeight) + ((boardHeight - self.fHeaderRowHeight) * (self:getStartShowRow() / #self.ServerPlayers)))

	Render:FillArea(Vector2(self.BoardPosition.x + self.BoardSize.width + self.fScrollLinePadding, scrollPosY), 
		Vector2(self.fScrollLineWidth, scrollHeight), self.Color_ScrollLineColor.default);

	return self;
end

function BoardHud:Scroll(args)
	self:setStartShowRow(self:getStartShowRow() - args.delta);
end

BoardHud = BoardHud();