mu.upgrades = mu.upgrades or {}

// Registers a new upgrade with given attributes
function mu.registerUpgrade(tbl)
	if (SERVER) then
		ndoc.table.mUpgrades[tbl.name] = ndoc.table.mUpgrades[tbl.name] or {}
		ndoc.table.mUpgrades[tbl.name].description = tbl.description
		ndoc.table.mUpgrades[tbl.name].cost = tbl.cost
		ndoc.table.mUpgrades[tbl.name].category = tbl.category
		ndoc.table.mUpgrades[tbl.name].inheritsFrom = tbl.ineritsFrom
	else
		tbl.onBuy = nil
		tbl.unLoad = nil
	end

	mu.upgrades[tbl.name] = tbl
	print("Loaded Upgrade: ", tbl.name)
end

// This function takes an upgrade and recursively searches for its parent. If the parent isn't found, it is pushed to the end of the queue
function mu.sortCategory(tbl)
	local tempSort = {}

	for k,child in pairs(tbl) do
		if (child.inheritsFrom ~= "none") then
			local foundParent = false

			for i,parent in pairs(tempSort) do
				if (parent.name == child.inheritsFrom) then
					parent.subUpgrades[child.order] = child

					foundParent = true
				end
			end

			if (not foundParent) then
				//the parent wasn't found, so we need to just re-insert it until we load the parent
				table.insert(tbl, child)
			end

		else
			tempSort[child.order] = child
			tempSort[child.order].subUpgrades = {}
		end

	end

	return tempSort
end

// Sorts the upgrades into categories, such as Defense or Offensive
function mu.sortIntoCategories()
	local order = {}

	for k,v in pairs(mu.upgrades) do
		order[v.category] = order[v.category] or {}
		table.insert(order[v.category], v)
	end

	for k,v in pairs(order) do
		order[k] = mu.sortCategory(v)
	end

	return order
end

local order

function mu.canAfford(cost) 
	return economy.canAfford(cost)
end

function mu.unlockedUpgrade(name)
	return ndoc.table.mActiveUpgrades[name]
end

// Checks a list of conditions to see if the upgrade can be bought
function mu.canBuyUpgrade(name)
	order = order or mu.sortIntoCategories()


	local upgrade = mu.upgrades[name]
	local catUpgrades = order[upgrade.category]

	if (upgrade.inheritsFrom ~= "none") then
		
		if (mu.unlockedUpgrade(upgrade.inheritsFrom) and mu.canAfford(upgrade.cost)) then
			return true
		end
		
		return false
	end

	if (mu.upgrades[name].order == 1 and mu.canAfford(upgrade.cost)) then
		return true
	end

	local upgradeBefore = catUpgrades[upgrade.order - 1]
	if (mu.unlockedUpgrade(upgradeBefore.name) and mu.canAfford(upgrade.cost)) then
		return true
	end

	return false
end