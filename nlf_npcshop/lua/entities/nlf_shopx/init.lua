--[[
Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local kla = osshop.choice

function ENT:Initialize()
	self:SetModel(osshop.skin)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	self:SetBloodColor(BLOOD_COLOR_RED)
	self:SetNWBool("Npc::InRobbing", false)
	self:SetNWInt("NPC::Robber", nil)
	self:SetNWInt("NPC::Timer", 0)
end


function ENT:AcceptInput(name, activator, caller)	
		if (name == "Use" and caller:IsPlayer()) then

		if  not self:GetNWBool("Npc::InRobbing") then
			local myt = sql.Query("SELECT * FROM osshop_data")
			local ntsend 
			if myt then 
				ntsend = myt 
			else
				ntsend = {}
			end

			net.Start("Shop::Open")
			net.WriteEntity(self)
			net.WriteTable(ntsend)
			net.Send(caller)
		else
			DarkRP.notify(caller, 1, 4, osshop.lang[kla].txt36)
		end
		end
end

--[[
Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--