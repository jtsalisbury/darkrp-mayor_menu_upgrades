mu = mu or {}

if (SERVER) then
	AddCSLuaFile("mu_main_sh.lua")
	AddCSLuaFile("mu_main_cl.lua")

	local files = file.Find("upgrades/*.lua", "LUA")
	for k,v in pairs(files) do
		AddCSLuaFile("upgrades/"..v)
	end

	// Include the main files, and search for upgrades. Once found, register them!
	timer.Simple(5, function()	
		include("mu_main_sh.lua")
		include("mu_main_sv.lua")

		for k,v in pairs(files) do
			local upgrade = include("upgrades/"..v)
			mu.registerUpgrade(upgrade)
		end
	end)
else
	
	timer.Simple(5, function()
		include("mu_main_sh.lua")
		include("mu_main_cl.lua")

		// Some upgrades can have client side code, so they need to be called on this realm also!
		local files = file.Find("upgrades/*.lua", "LUA")
		for k,v in pairs(files) do
			local upgrade = include("upgrades/"..v)
			mu.registerUpgrade(upgrade)
		end
	end)
end