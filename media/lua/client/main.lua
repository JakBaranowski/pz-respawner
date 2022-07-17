-- This file contains all entry points for the mod code.

--#region Events

local function OnCreatePlayer(playerIndex, player)
	Logging.print("OnCreatePlayer")
	-- TODO attempt loading PlayerData from file 
	-- if savefile does not exist do code below
	RespawnManager.playerData = PlayerData:new()
	RespawnManager.playerData:SetAll(player)
end

Events.OnCreatePlayer.Add(OnCreatePlayer)

local function OnPlayerDeath(player)
	Logging.print("OnPlayerDeath")
	RespawnManager.playerData:SetAll(player)
end

Events.OnPlayerDeath.Add(OnPlayerDeath)

--#endregion

--#region Overrides

function ISPostDeathUI:modOnRespawn()
    Logging.print("Clicked on respawn")

    if MainScreen.instance:isReallyVisible() then return end
	self:setVisible(false)

    RespawnManager:RespawnPlayer()
end

local super_createChildren = ISPostDeathUI.createChildren

function ISPostDeathUI:createChildren()
    super_createChildren(self)

    self.buttonRespawn:setTitle(getText("IGUI_DeathAnd_Respawn"))
    self.buttonRespawn:setOnClick(self.modOnRespawn)
end

--#endregion
