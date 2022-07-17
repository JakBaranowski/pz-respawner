-- PlayerData attempts to store all player data that can be later used to
-- recreate the player.

PlayerData = {
    Safehouse = nil,
    Forename = "",
    Surname = "",
    Female = false,
    Visual = {
        Skin = {
            Texture = nil,
            Color = nil,
        },
        Hair = {
            Model = nil,
            Color = nil,
        },
        Beard = {
            Model = nil,
            Color = nil,
        },
        BodyHair = 0,
    },
    Profession = "",
    Observations = {},
    Perks = {},
    Traits = {},
    Recipes = {},
    Inventory = {},
    WornItems = {},
}

function PlayerData:new()
    local o = {}
    setmetatable(o, self)
    o.__index = self
    o.Safehouse = nil
    o.Forename = ""
    o.Surname = ""
    o.Female = false
    o.Visual = {
        Skin = {
            Texture = nil,
            Color = nil,
        },
        Hair = {
            Model = nil,
            Color = nil,
        },
        Beard = {
            Model = nil,
            Color = nil,
        },
        BodyHair = 0,
    }
    o.Profession = ""
    o.Observations = {}
    o.Perks = {}
    o.Traits = {}
    o.Recipes = {}
    o.Inventory = {}
    o.WornItems = {}
    Logging.print("New PlayerData object "..tostring(o))
    return o
end

function PlayerData:SetSafehouseSpawn(isoPlayer)
    Logging.print("PlayerData:SetSafehouseSpawn")
    local safehouse = SafeHouse.hasSafehouse(isoPlayer)
    if safehouse and safehouse:isRespawnInSafehouse(isoPlayer:getUsername()) then
        self.Safehouse = {
            safehouse:getX() + (safehouse:getH() / 2),
            safehouse:getY() + (safehouse:getW() / 2),
            0
        }
    end
end

function PlayerData:SetName(isoPlayer)
    Logging.print("PlayerData:SetName")
    local descriptor = isoPlayer:getDescriptor()
    self.Forename = descriptor:getForename()
    self.Surname = descriptor:getSurname()
end

function PlayerData:SetVisual(isoPlayer)
    Logging.print("PlayerData:SetVisual")
    local humanVisual = isoPlayer:getHumanVisual()
    self.Female = isoPlayer:isFemale()
    self.Visual.Skin.Texture = humanVisual:getSkinTexture()
    self.Visual.Skin.Color = humanVisual:getSkinColor()
    self.Visual.Hair.Model = humanVisual:getHairModel()
    self.Visual.Hair.Color = humanVisual:getHairColor()
    self.Visual.Beard.Model = humanVisual:getBeardModel()
    self.Visual.Beard.Color = humanVisual:getBeardColor()
    self.Visual.BodyHair = humanVisual:getBodyHairIndex()
end

function PlayerData:SetProfession(isoPlayer)
    Logging.print("PlayerData:SetProffesion")
    self.Profession = isoPlayer:getDescriptor():getProfession()
end

function PlayerData:SetObservations(isoPlayer)
    Logging.print("PlayerData:SetObservations")
    local observations = isoPlayer:getDescriptor():getObservations()
    self.Observations = {}
    for i = 0, observations:size() - 1 do
        local name = observations:get(i)
        table.insert(self.Observations, name)
    end
end

function PlayerData:SetTraits(isoPlayer)
    Logging.print("PlayerData:SetTraits")
    local traits = isoPlayer:getTraits()
    self.Traits = {}
    for i = 0, traits:size() - 1 do
        local name = traits:get(i)
        table.insert(self.Traits, name)
    end
end

function PlayerData:SetPerks(isoPlayer)
    Logging.print("PlayerData:SetPerks")
    local perkList = PerkFactory.PerkList
    local playerXp = isoPlayer:getXp()
    self.Perks = {} -- May not be needed
    for i = 0, perkList:size() - 1 do
        local perk = perkList:get(i)
        local name = PerkFactory.getPerkName(perk)
        local experience = playerXp:getXP(perk)
        self.Perks[name] = experience
    end
end

function PlayerData:SetRecipes(isoPlayer)
    Logging.print("PlayerData:SetRecipes")
    local knownRecipes = isoPlayer:getKnownRecipes()
    self.Recipes = {}
    for i = 0, knownRecipes:size() - 1 do
        table.insert(self.Recipes, knownRecipes:get(i))
    end
end

local function startsWith(check, prefix)
    return string.sub(check, 1, #prefix) == prefix
end

function PlayerData:SetInventory(isoPlayer)
    Logging.print("PlayerData:SetInventory")
    local items = isoPlayer:getInventory():getItems()
    self.Inventory = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if not startsWith(item:getName(), "Base.Wound_") then
            table.insert(self.Inventory, item)
        end
    end
end

function PlayerData:SetWornItems(isoPlayer)
    Logging.print("PlayerData:SetWornItems")
    local wornItems = isoPlayer:getWornItems()
    self.WornItems = {}
    for i = 0, wornItems:size() - 1 do
        local wornItem = wornItems:get(i)
        local wornItemLocation = wornItem:getLocation()
        if not wornItemLocation == "Wound" then
            table.insert(self.WornItems, {wornItemLocation, wornItem})
        end
    end
end

function PlayerData:DebugPrint()
    if self.Safehouse then
        Logging.print("SpawnsSafeHouse:".." X "..self.Safehouse[1].." Y "..self.Safehouse[2].." Z "..self.Safehouse[3])
    end
    Logging.print("Name: "..self.Forename.." "..self.Surname)
    Logging.print("Profession: "..self.Profession)
    Logging.print("Female: "..tostring(self.Female))
    Logging.print("SkinTexture: "..tostring(self.Visual.Skin.Texture))
    Logging.print("SkinColor: "..tostring(self.Visual.Skin.Color))
    Logging.print("HairModel: "..tostring(self.Visual.Hair.Model))
    Logging.print("HairColor: "..tostring(self.Visual.Hair.Color))
    Logging.print("BodyHairIndex: "..tostring(self.Visual.BodyHairIndex))
    Logging.print("BeardModel: "..tostring(self.Visual.Beard.Model))
    Logging.print("BeardColor: "..tostring(self.Visual.Beard.Color))
    Logging.print("Observations "..tostring(self.Observations))
    for index, value in ipairs(self.Observations) do
        Logging.print(index.." "..value)
    end
    Logging.print("Traits "..tostring(self.Traits))
    for index, value in ipairs(self.Traits) do
        Logging.print(index.." "..value)
    end
    Logging.print("Perks "..tostring(self.Perks))
    for key, value in pairs(self.Perks) do
        Logging.print(key.." "..tostring(value))
    end
    Logging.print("Recipes "..tostring(self.Recipes))
    for index, value in ipairs(self.Recipes) do
        Logging.print(index.." "..tostring(value))
    end
    Logging.print("Inventory "..tostring(self.Inventory))
	for index, value in ipairs(self.Inventory) do
		Logging.print(index.." "..tostring(value))
	end
	Logging.print("WornItems "..tostring(self.WornItems))
	for index, value in ipairs(self.WornItems) do
        Logging.print(index.." "..tostring(value[1]).." "..tostring(value[2]))
	end
end

function PlayerData:SetAll(isoPlayer)
    Logging.print("PlayerData:Set")
    self:SetSafehouseSpawn(isoPlayer)
    self:SetName(isoPlayer)
    self:SetVisual(isoPlayer)
    self:SetProfession(isoPlayer)
    self:SetObservations(isoPlayer)
    self:SetTraits(isoPlayer)
    self:SetPerks(isoPlayer)
    self:SetRecipes(isoPlayer)
    self:SetInventory(isoPlayer)
    self:SetWornItems(isoPlayer)
    self:DebugPrint()
end

function PlayerData:Save()
    Logging.print("PlayerData:Save")
    -- TODO a way of saving the data from PlayerData
end

function PlayerData:Load()
    Logging.print("PlayerData:Load")
    -- TODO instantiate a new PlayerData object using data from save file
end

return PlayerData
