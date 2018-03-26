// This function should be an outline what a real upgrade should do
local upgrade = {}

// What is the name of the upgrade?
upgrade.name = "Armor"

// What category should the upgrade belong to?
upgrade.category = "Defense" 

// Should this be an sub upgrade? If so, put the name of the parent here 
upgrade.inheritsFrom = "none"

// WHere should this upgrade come in the list of other upgrades?
upgrade.order = 1

// Give what this upgrade is about
upgrade.description = "Provides 100 Armor to members of the Civil Protection force."

// How much does it cost
upgrade.cost = 1000

// All code that should be called should be placed in here. Including hooks and other blocks
function upgrade.onBuy()
	hook.Remove("PlayerSpawn", "ArmorPlayers")

	hook.Add("PlayerSpawn", "ArmorPlayers", function(ply)
		timer.Simple(2, function()
			if (ply:isCP()) then 
				ply:SetArmor(100)
			end
		end)
	end)

	hook.Add("OnPlayerChangedTeam", "ArmorPlayersChangeTeam", function(ply, _, to)
		if (ply:isCP()) then
			ply:SetArmor(100)
		end
	end)



	for k,v in pairs(player.GetAll()) do
		if (v:isCP()) then
			v:SetArmor(100)
		end
	end
end

// When this upgrade is removed, this is the code that should be ran
function upgrade.unLoad()
	hook.Remove("PlayerSpawn", "ArmorPlayers")
	hook.Remove("OnPlayerChangedTeam", "ArmorPlayersChangeTeam")
end

// Make sure to return the upgrade table!
return upgrade