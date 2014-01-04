local groups = {}

function Player:GetGroup()
	if not groups[tostring(self:GetSteamId())] then
		Events:Fire("nBAM_RequestUpdateGroup", tostring(self:GetSteamId()))
	end
	return groups[tostring(self:GetSteamId())] or "?"
end

local function updatePly(data)
	local ply, group = data.player, data.group	
	groups[ply] = group
end

Events:Subscribe("nBAM_UpdateGroup", updatePly)