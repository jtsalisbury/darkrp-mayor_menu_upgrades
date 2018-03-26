local Primary = Color(46, 49, 54, 255)
local DarkPrimary = Color(30, 33, 36)
local LightPrimary = Color(54, 57, 62, 255)
local Green = Color(39, 174, 96)
local Red = Color(231, 76, 60)
local White = Color(230,230,230)

// Add the upgrades menu to the mayor menu
hook.Add("MayorMenuAdditions", "MayorUpgrades", function(cback, w, h)
	local order = mu.sortIntoCategories()

	local pnl = vgui.Create("DPanel")
	pnl:SetSize(w, h)
	function pnl:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Primary)
	end	

	local catList = vgui.Create("DScrollPanel", pnl)
	catList:SetSize(pnl:GetWide() * .25, h)
	catList:SetPos(0, 0)
	local sc = catList:GetVBar()
	function sc:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
	end
	function sc.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, DarkPrimary)
	end
	function sc.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, DarkPrimary)
	end
	function sc.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, DarkPrimary)
	end

	local c = 0
	local activeCategory = nil

	local scroller = vgui.Create("DScrollPanel", pnl)
	scroller:SetSize((pnl:GetWide() * .75) - 5, h)
	scroller:SetPos(catList:GetSize() + 5, 5)
	local sc = scroller:GetVBar()
	function sc:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
	end
	function sc.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, DarkPrimary)
	end
	function sc.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, DarkPrimary)
	end
	function sc.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, DarkPrimary)
	end

	// This function adds the upgrades to the panel based on the current active category
	local subUpgradeWidth, subUpgradeHeight = 150, 50
	local function refreshUpgrades()
		local offset_y = 5
		local w = scroller:GetWide()
		scroller:Clear()

		for k,v in pairs(order[activeCategory]) do
			local upgrade = vgui.Create("DPanel", scroller)
			upgrade:SetSize(150, 50)
			upgrade:SetPos((w / 2) - upgrade:GetWide() / 2, offset_y)
			function upgrade:Paint(w, h)
				local col = LightPrimary

				draw.RoundedBox(0, 0, 0, w, h, col)
				draw.SimpleText(v.name .. " - $" .. string.Comma(v.cost), "SmallTitle", w / 2, upgrade:GetTall() / 4, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local moreInfo = vgui.Create("DButton", upgrade)
			moreInfo:SetSize(upgrade:GetWide() / 2, upgrade:GetTall() / 2)
			moreInfo:SetPos(0, upgrade:GetTall() / 2)
			moreInfo:SetText("")
			function moreInfo:Paint(w, h)
				local col = DarkPrimary
				local bg = LightPrimary
				if (self:IsHovered()) then
					bg = col
				end

				draw.RoundedBox(0, 0, 0, w, h, bg)
				surface.SetDrawColor(col)
				surface.DrawOutlinedRect(0, 0, w, h)

				draw.SimpleText("Info", "SmallTitle", w / 2, h / 2, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
			end
			function moreInfo:DoClick()
				local desc = string.len(v.description) > 0 and v.description or "No Description"
				Derma_Query(desc, "About "..v.name, "Okay", function() end)
			end

			local buy = vgui.Create("DButton", upgrade)
			buy:SetSize(upgrade:GetWide() / 2, upgrade:GetTall() / 2)
			buy:SetPos(moreInfo:GetWide(), upgrade:GetTall() / 2)
			buy:SetText("")
			function buy:Paint(w, h)
				local col = Green
				local bg = Color(0, 0, 0, 0)
				local txt = "Buy"

				if (self:IsHovered()) then
					bg = col
				end
				if (self:GetDisabled()) then
					bg = LightPrimary
					col = DarkPrimary
				end
				if (mu.unlockedUpgrade(v.name)) then
					txt = "Bought!"
					bg = LightPrimary
					col = DarkPrimary
				end

				draw.RoundedBox(0, 0, 0, w, h, bg)
					
				surface.SetDrawColor(col)
				surface.DrawOutlinedRect(0, 0, w, h)

				draw.SimpleText(txt, "SmallTitle", w / 2, h / 2, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			function buy:Think()
				if (mu.canBuyUpgrade(v.name)) then
					self:SetDisabled(false)
				else
					self:SetDisabled(true)
				end
			end
			function buy:DoClick()
				net.Start("mu.buyUpgrade")
					net.WriteString(v.name)
				net.SendToServer()
			end

			offset_y = offset_y + upgrade:GetTall() + 10

			// Some upgrades can have some upgrades, so here we create an algorithm to recursively add the sub upgrades beneath the parent
			if (#v.subUpgrades ~= 0) then
				local rows = math.ceil(#v.subUpgrades / 2) //2 per row, get the rows. 

				local layout = vgui.Create("DIconLayout", scroller)
				layout:SetSize(rows < 1 and #v.subUpgrades * subUpgradeWidth + (#v.subUpgrades * 5) or #v.subUpgrades * subUpgradeWidth + (#v.subUpgrades * 5), rows * subUpgradeHeight + (rows * 5))
				layout:SetPos(w / 2 - layout:GetWide() / 2, offset_y)
				layout:SetSpaceX(5)
				layout:SetSpaceY(5)

				for k,v in pairs(v.subUpgrades) do
					local subUpgrade = layout:Add("DPanel")
					subUpgrade:SetSize(subUpgradeWidth, subUpgradeHeight)
					function subUpgrade:Paint(w, h)
						local col = LightPrimary

						draw.RoundedBox(0, 0, 0, w, h, col)
						draw.SimpleText(v.name .. " - $" .. string.Comma(v.cost), "SmallTitle", w / 2, subUpgrade:GetTall() / 4, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end

					local moreInfo = vgui.Create("DButton", subUpgrade)
					moreInfo:SetSize(subUpgrade:GetWide() / 2, subUpgrade:GetTall() / 2)
					moreInfo:SetPos(0, subUpgrade:GetTall() / 2)
					moreInfo:SetText("")
					function moreInfo:Paint(w, h)
						local col = DarkPrimary
						local bg = LightPrimary
						if (self:IsHovered()) then
							bg = col
						end

						draw.RoundedBox(0, 0, 0, w, h, bg)
						surface.SetDrawColor(col)
						surface.DrawOutlinedRect(0, 0, w, h)

						draw.SimpleText("Info", "SmallTitle", w / 2, h / 2, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
					end
					function moreInfo:DoClick()
						local desc = string.len(v.description) > 0 and v.description or "No Description"
						Derma_Query(desc, "About "..v.name, "Okay", function() end)
					end	

					local buy = vgui.Create("DButton", subUpgrade)
					buy:SetSize(subUpgrade:GetWide() / 2, subUpgrade:GetTall() / 2)
					buy:SetPos(moreInfo:GetWide(), subUpgrade:GetTall() / 2)
					buy:SetText("")
					function buy:Paint(w, h)
						local col = Green
						local bg = Color(0, 0, 0, 0)
						local txt = "Buy"

						if (self:IsHovered()) then
							bg = col
						end
						if (self:GetDisabled()) then
							bg = LightPrimary
							col = DarkPrimary
						end
						if (mu.unlockedUpgrade(v.name)) then
							txt = "Bought!"
							bg = LightPrimary
							col = DarkPrimary
						end

						draw.RoundedBox(0, 0, 0, w, h, bg)
							
						surface.SetDrawColor(col)
						surface.DrawOutlinedRect(0, 0, w, h)

						draw.SimpleText(txt, "SmallTitle", w / 2, h / 2, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
					function buy:Think()
						if (mu.canBuyUpgrade(v.name)) then
							self:SetDisabled(false)
						else
							self:SetDisabled(true)
						end
					end
					function buy:DoClick()
						net.Start("mu.buyUpgrade")
							net.WriteString(v.name)
						net.SendToServer()
					end

				end

				offset_y = offset_y + layout:GetTall() + 10
			end
		end
	end	

	// Register the categories
	local activeBtn = nil
	for k,v in pairs(order) do
		local btn = vgui.Create("DButton", catList)
		btn:SetSize(catList:GetWide(), 30)
		btn:SetPos(0, (32 * c) + 5)
		btn:SetText("")
		function btn:Paint(w, h)
			local col = LightPrimary
			if (self:IsHovered()) then
				col = DarkPrimary
			end
			if (self:GetDisabled()) then
				col = DarkPrimary	
			end

			draw.RoundedBox(0, 0, 0, w, h, col)
			draw.SimpleText(k, "SubTitle", w / 2, h / 2, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		function btn:DoClick()
			activeCategory = k
			if (activeBtn) then
				activeBtn:SetDisabled(false)
			end

			self:SetDisabled(true)
			activeBtn = self

			refreshUpgrades()
		end
		

		c = c + 1
	end

	cback("", "Upgrades", pnl)
end)