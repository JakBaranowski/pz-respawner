-- RespawnManager takes care of all the logic required for respawning the player.

require "ISUI/ISPanelJoypad"

RespawnManager = ISPanelJoypad:derive("RespawnManager")

function RespawnManager:RespawnPlayer()

	Logging.print("Making sure Post Death UI is removed")
    if ISPostDeathUI.instance[self.playerIndex] then
		ISPostDeathUI.instance[self.playerIndex]:removeFromUIManager()
		ISPostDeathUI.instance[self.playerIndex] = nil
	end

	Logging.print("Creating new survivor for the player")
	MainScreen.instance.desc = SurvivorFactory.CreateSurvivor()

    Logging.print("Setting new survivor forename and surname")
    MainScreen.instance.desc:setForename(self.playerData.Forename)
    MainScreen.instance.desc:setSurname(self.playerData.Surname)
	MainScreen.instance.desc:setFemale(self.playerData.Female)

	Logging.print("Setting new survivor visuals")
	local humanVisual = MainScreen.instance.desc:getHumanVisual()
	humanVisual:setSkinTextureName(self.playerData.Visual.Skin.Texture)
	humanVisual:setSkinColor(self.playerData.Visual.Skin.Color)
	humanVisual:setHairModel(self.playerData.Visual.Hair.Model)
	humanVisual:setHairColor(self.playerData.Visual.Hair.Color)
	humanVisual:setBeardModel(self.playerData.Visual.Beard.Model)
	humanVisual:setBeardColor(self.playerData.Visual.Beard.Color)
	humanVisual:setBodyHairIndex(self.playerData.Visual.BodyHair)

	Logging.print("Setting new survivor profession")
	MainScreen.instance.desc:setProfession(self.playerData.Profession)
	MainScreen.instance.desc:setProfessionSkills(
		ProfessionFactory.getProfession(self.playerData.Profession)
	)

	Logging.print("Getting world")
	local world = getWorld()

	-- TODO allow player spawn at last slept / claimed bed, 
	if self.playerData.Safehouse then
		Logging.print("Setting spawn point")
		local worldX = math.floor(self.playerData.Safehouse[1] / 300)
		local worldY = math.floor(self.playerData.Safehouse[2] / 300)
		local posX = self.playerData.Safehouse[1] - worldX * 300
		local posY = self.playerData.Safehouse[2] - worldY * 300
		local posZ = self.playerData.Safehouse[3]

		world:setLuaSpawnCellX(worldX)
		world:setLuaSpawnCellY(worldY)
		world:setLuaPosX(posX)
		world:setLuaPosY(posY)
		world:setLuaPosZ(posZ)
	end

	Logging.print("Setting lua player description")
	world:setLuaPlayerDesc(MainScreen.instance.desc)

	Logging.print("Setting new player traits")
	world:getLuaTraits():clear()
	for _, trait in ipairs(self.playerData.Traits) do
		Logging.print("Adding trait "..trait)
		world:addLuaTrait(trait)
	end

	Logging.print("Setting new player")
	self:SetPlayer()

	Logging.print("Getting new player")
	local player = getPlayer()

	Logging.print("Setting new player perk levels")
	local perkList = PerkFactory.PerkList
	local playerXp = player:getXp()
	for i = 0, perkList:size() - 1 do
		local perk = perkList:get(i)
		local name = PerkFactory.getPerkName(perk)
		local xpDifference = self.playerData.Perks[name] - playerXp:getXP(perk)
		Logging.print("Adding "..xpDifference.." to perk "..name)
		playerXp:AddXP(perk, xpDifference, false, false, true)
		Logging.print("XP after adding "..playerXp:getXP(perk))
	end

	Logging.print("Setting new player known recipes")
	for _, recipeName in ipairs(self.playerData.Recipes) do
		player:learnRecipe(recipeName)
	end

	-- Get inventory and worn items
	local wornItems = player:getWornItems()
	local inventory = player:getInventory()

	-- Make sure that the inventory and worn items are empty
	inventory:removeAllItems()
	wornItems:clear()

	Logging.print("Setting new player inventory")
	for _, item in ipairs(self.playerData.Inventory) do
		inventory:addItem(item)
	end

	Logging.print("Setting new player worn items")
	for _, wornItem in ipairs(self.playerData.WornItems) do
		wornItems:setItem(wornItem[1], wornItem[2])
	end

	-- Update inventory
	player:setInventory(inventory)
	triggerEvent("OnClothingUpdated", player)
	player:update()
end

function RespawnManager:SetPlayer()
    if self.joypadData then return self:SetPlayerJoypad() end
	self:SetPlayerMouse()
end

function RespawnManager:SetPlayerMouse()
	Logging.print("Setting player mouse")
	setPlayerMouse(nil)
end

function RespawnManager:SetPlayerJoypad()
	Logging.print("Setting player controller")
	local controller = self.joypadData.controller
	local joypadData = JoypadState.joypads[self.playerIndex+1]
	JoypadState.players[self.playerIndex+1] = joypadData
	joypadData.player = self.playerIndex
	joypadData:setController(controller)
	joypadData:setActive(true)
	local username = nil
	if isClient() and self.playerIndex > 0 then
		username = CoopUserName.instance:getUserName()
	end
	setPlayerJoypad(self.playerIndex, self.joypadIndex, nil, username)

	self.joypadData.focus = nil
	self.joypadData.lastfocus = nil
	self.joypadData.prevfocus = nil
	self.joypadData.prevprevfocus = nil
end
