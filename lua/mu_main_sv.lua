ndoc.table.mUpgrades = ndoc.table.mUpgrades or {}
ndoc.table.mActiveUpgrades = ndoc.table.mActiveUpgrades or {}

util.AddNetworkString("mu.buyUpgrade")

// Perform the action of buying an upgrade and calling the execution function
function mu.buyUpgrade(name)
	local netTbl = ndoc.table.mActiveUpgrades[name]

	if (netTbl) then return end

	if (not mu.canBuyUpgrade(name)) then return end
	
	ndoc.table.mActiveUpgrades[name] = 1

	mu.upgrades[name].onBuy()

	economy.takeMoney(mu.upgrades[name].cost)
	
end

// This is typically called when a mayor leaves
function mu.unLoadUpgrades()
	for k,v in ndoc.pairs(ndoc.table.mActiveUpgrades) do
		mu.upgrades[k].unLoad()
		ndoc.table.mActiveUpgrades[k] = nil
	end
end

net.Receive("mu.buyUpgrade", function(_, client)
	if (client:Team() ~= TEAM_MAYOR) then return end
	
	mu.buyUpgrade(net.ReadString())
end)

hook.Add("OnPlayerChangedTeam", "MayorToOther", function(ply, prev, new)
	if (prev == TEAM_MAYOR) then
		mu.unLoadUpgrades()
	end
end)

hook.Add("PlayerDeath", "MayorDeath", function(ply)
	if (ply:Team() == TEAM_MAYOR) then
		mu.unLoadUpgrades()

		ply:changeTeam(TEAM_CITIZEN)
	end
end)