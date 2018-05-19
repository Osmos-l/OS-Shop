--[[
Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName 	= "NPC Shop"
ENT.Author 		= "Osmos"
ENT.Contact 	= "https://steamcommunity.com/id/ThePsyca/"
ENT.Category	= "NLF | Shop"

ENT.AutomaticFrameAdvance = true
   
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:PhysicsCollide(data, physobj)
end

function ENT:PhysicsUpdate(physobj)
end

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

--[[
Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--