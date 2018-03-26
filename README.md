Upgrades should be placed in the lua/upgrades/ folder. 
They should follow this format:

local upgrade = {}

upgrade.name = "" //What is the name of the upgrade?
upgrade.category = "" //what category does it go to?
upgrade.inheritsFrom = "" //Is this a subupgrade? This should be the upgrade name you want it to be a sub upgrade of, or "none" for it's own upgrade.
upgrade.order = 1 //Where does this upgrade come in the list?
upgrade.description = "" //What does this upgrade do?
upgrade.cost = 1000 //How much does this upgrade cost?

//What should this upgrade do when it loads? All hooks you need to add should be done here. 
function upgrade.onBuy()
end

//What should this upgrade do when it unloads? All hooks that were added should be removed here. 
function upgrade.unLoad()
end

//Always return the upgrade so it is added.
return upgrade