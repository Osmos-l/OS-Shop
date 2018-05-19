--[[
Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--

include("shared.lua")

surface.CreateFont( "Font", {
	font = "Coolvetica",
	size = 50,
	weight = 1000,
} )

function ENT:Draw()
    self:DrawModel()
	
    local eye = LocalPlayer():EyeAngles()
    local Pos = self:LocalToWorld(self:OBBCenter()) + Vector(0, 0, 50)
    local Ang = Angle(0, eye.y - 90, 90)
	
    if self:GetPos():Distance(LocalPlayer():GetPos()) > 1500 then return end
	
    cam.Start3D2D(Pos + Vector(0, 0, math.sin(CurTime()) * 2), Ang, 0.2)
    draw.SimpleTextOutlined(osshop.name, "Font", 0, -20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, 0, 1.5, Color(0, 0, 0, 255))

    	if self:GetNWBool("Npc::InRobbing") then
       	 local timere = (self:GetNWInt("NPC::Timer") - CurTime())
       	 local TIMER = string.ToMinutesSeconds(timere)
        draw.SimpleTextOutlined("Braquage : " .. TIMER, "ChatFont", 0, 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, 0, 1.5, Color(0, 0, 0, 255))
    end

    cam.End3D2D()
end

--[[
Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--
