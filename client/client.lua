class 'BoardClient'


function BoardClient:__init() end

function BoardClient:getPlayers()
	local players = {LocalPlayer};
	for p in Client:GetPlayers() do
		table.insert(players, p);
	end

	for i = 1, 233 do
		table.insert(players, LocalPlayer);
		for p in Client:GetPlayers() do
			table.insert(players, p);
		end
	end

	return players;
end

BoardClient = BoardClient();