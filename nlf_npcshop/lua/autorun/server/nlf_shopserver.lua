--[[

Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--

--[[ INIT ]]--

util.AddNetworkString("Shop-Client")

util.AddNetworkString("Shop-Server")

--[[ SQL TABLE ]]--

local function osshop_createtable()
	if not sql.TableExists("osshop_data") then
		sql.Query( "CREATE TABLE osshop_data( id INTEGER PRIMARY KEY AUTOINCREMENT ,isweapon varchar(4), name varchar(150), entclass varchar(150), models varchar(400), desc varchar(900), price tinyint(255), only varchar(900) )" )
		print("[ Osshop ] : Create Table")
	end
end

hook.Add( "InitPostEntity", "osshop::InitTable", timer.Simple( 0.1, function() osshop_createtable() end ) )

--[[ PlayerSay Reload Table ]]--

concommand.Add("osshop_reloadtable", function(ply, cmd, args)
	if not osshop.Staff[ ply:GetUserGroup() ] then return end

	local oldtable = sql.Query("SELECT * FROM osshop_data")
	sql.Query( "DROP TABLE osshop_data" )
	osshop_createtable()

	for k, v in pairs( oldtable ) do
		local onlytable = {}
		sql.Query("INSERT INTO osshop_data VALUES( NULL,'"..v.isweapon.."','"..v.name.."','"..v.entclass.."','"..v.models.."','"..v.desc.."','"..tonumber(v.price).."','"..util.TableToJSON(onlytable).."' ) ")
	end
	DarkRP.notify(ply, 3, 4, "Table Reload" )
end)

--[[ HUD ]]--

local function copshud(npc)
        for k, v in pairs (  player.GetAll() ) do
        	if osshop.TeamCops[team.GetName(v:Team())] then

        		DarkRP.notify(v, 3, 4, osshop.lang[kla].txt36)
        		net.Start("Shop-Client")
        		net.WriteInt(-6, 4)
        		net.WriteEntity(npc)
        		net.WriteBool(true)
        		net.Send(v)

        		timer.Simple(osshop.robduration,function() 
        			net.Start("Shop-Client")
        			net.WriteInt(-6, 4)
        			net.WriteEntity(npc)
        			net.WriteBool(false)
        			net.Send(v)
        		end)
			end
		end
end

--[[ Function ]]--

local kla = osshop.choice

net.Receive("Shop-Server", function(len, ply)
	local where = net.ReadInt(4)

	if where == -8 then -- [[ Add Team Restrict ]] --
		if not osshop.Staff[ply:GetUserGroup()] then return end

		local id = net.ReadInt(16)
		local name = net.ReadString()

		local oldt = sql.Query("SELECT * FROM osshop_data WHERE id ="..id)
		local oldtable

		for k , v in pairs ( oldt ) do
			if v.only == "[]" then
				oldtable = {}
			else
				oldtable = util.JSONToTable(v.only)
			end
		end

		if not table.HasValue(oldtable, name) then
			table.insert(oldtable, name)
			sql.Query([[UPDATE osshop_data SET only = ']]..util.TableToJSON(oldtable)..[[' WHERE id = ]]..id)
		else
			DarkRP.notify(ply, 1, 4, osshop.lang[kla].txt40)
		end
	return

	elseif where == -7 then -- [[ Remove Team Restrict ]] --
		if not osshop.Staff[ply:GetUserGroup()] then return end

		local id = net.ReadInt(16)
		local name = net.ReadString()

		local oldt = sql.Query("SELECT * FROM osshop_data WHERE id ="..id)
		local oldtable

		for k , v in pairs ( oldt ) do
			if v.only == "[]" then
				DarkRP.notify(ply, 1, 4, osshop.lang[kla].txt41)
				return
			else
				oldtable = util.JSONToTable(v.only)
			end
		end

		if table.HasValue(oldtable, name) then
			table.RemoveByValue(oldtable, name)
			sql.Query([[UPDATE osshop_data SET only = ']]..util.TableToJSON(oldtable)..[[' WHERE id = ]]..id)
		else
			DarkRP.notify(ply, 1, 4, osshop.lang[kla].txt41)
		end
	return 

	elseif where == -6 then -- [[ Shop Buy ]] --
		local npc = net.ReadEntity()
		local sqlid = net.ReadInt(16)

		if not IsValid(npc) then return end
		if not npc:GetClass() == "nlf_shopx" then return end
		if npc:GetNWBool("Npc::InRobbing") then return end
		if ply:GetPos():Distance(npc:GetPos())>110 then return end

		if osshop.AntiSpam then
			if ply.TimeDelay == nil then
	   			ply.TimeDelay = 0
			end

			if CurTime() <  ply.TimeDelay then 
				DarkRP.notify(ply, 1, 4, osshop.lang[kla].txt31)
				return 
			end
			ply.timedelay = CurTime() + 5
		end

		local oldt = sql.Query("SELECT * FROM osshop_data WHERE id ="..sqlid)
		local oldtable

		for k , v in pairs ( oldt ) do
			if v.only != "[]" then
				oldtable = util.JSONToTable(v.only)
				if not table.HasValue(oldtable, team.GetName(ply:Team()) ) then	 
					DarkRP.notify(ply, 1, 4, osshop.lang[kla].txt42)
					return 
				end
			end

			if ply:getDarkRPVar( "money" ) < tonumber(v.price) then
				DarkRP.notify(ply, 1, 4, osshop.lang[kla].txt19) return
			end 

			ply:addMoney(- v.price)

			if v.isweapon then
				ply:Give(v.entclass)
				DarkRP.notify(ply, 0, 4, osshop.lang[kla].txt20)
			else
					local buyp = ents.Create(v.entclass)
				buyp:SetPos(ply:GetPos() + ply:GetAngles():Forward()*25 + ply:GetAngles():Up()*15)
				buyp:SetAngles(pl:GetAngles())
				buyp:Spawn()
				buyp:Activate()
				DarkRP.notify(ply, 0, 4, osshop.lang[kla].txt21)
			end
		end
	return

	elseif where == -5 then -- [[ Register New Item ]] --

		if not osshop.Staff[ply:GetUserGroup()] then return end

		local info = net.ReadTable()
		local IsWeapoon 
			if info.isw == osshop.lang[kla].yes then
				IsWeapoon = "true"
			elseif info.isw == osshop.lang[kla].no then
				IsWeapoon = "false"
			else
				DarkRP.notify(ply, 1, 4, "[Osshop] : "..osshop.lang[kla].txt22)	return
			end

			if (info.name == osshop.lang[kla].txt13) then
				DarkRP.notify(ply, 1, 4, "[ Osshop ] : "..osshop.lang[kla].txt23) return 
			elseif (info.class == osshop.lang[kla].txt14) then
				DarkRP.notify(ply, 1, 4, "[ Osshop ] : "..osshop.lang[kla].txt24)  return
			elseif (info.model == osshop.lang[kla].txt15) then
				DarkRP.notify(ply, 1, 4, "[ Osshop ] : "..osshop.lang[kla].txt25) return
			elseif (info.price == osshop.lang[kla].txt16) then
				DarkRP.notify(ply, 1, 4, "[ Osshop ] : "..osshop.lang[kla].txt26) return
			elseif (info.desc == osshop.lang[kla].txt17) then
				DarkRP.notify(ply, 1, 4, "[ Osshop ] : "..osshop.lang[kla].txt27) return
			end

			if not sql.TableExists("osshop_data") then
				osshop_createtable()
			end

		local onlytable = {}
			sql.Query("INSERT INTO osshop_data VALUES( NULL,'"..IsWeapoon.."','"..info.name.."','"..info.class.."','"..info.model.."','"..info.desc.."','"..tonumber(info.price).."','"..util.TableToJSON(onlytable).."' ) ")
			DarkRP.notify(ply, 0, 4, "[ Osshop ] : "..osshop.lang[kla].txt28)
		return	

	elseif where == -4 then -- [[ Delete Item from the shop ]] -- 
		if not osshop.Staff[ply:GetUserGroup()] then return end

		local key = net.ReadInt(16)
		local npc = net.ReadEntity()
		local itemt = sql.Query("SELECT * FROM osshop_data")
		local dataitem
			if itemt then 
				dataitem = itemt 
			else
				return
			end
			sql.Query("DELETE FROM osshop_data WHERE id =" .. tonumber(dataitem[key].id))
			DarkRP.notify(ply, 0, 4, "[Osshop] : "..osshop.lang[kla].txt29)

		local myt = sql.Query("SELECT * FROM osshop_data")
		local ntsend 
			if myt then 
				ntsend = myt 
			else
				ntsend = {}
			end

			net.Start("Shop-Client")
			net.WriteInt(-8, 4)
			net.WriteEntity(npc)
			net.WriteTable(ntsend)
			net.Send(ply)
		return

	elseif where == -3 then -- [[ Edit Item Get all info ]] --
		if not osshop.Staff[ply:GetUserGroup()] then return end

		local key = net.ReadInt(16)
		local npc = net.ReadEntity()
		local itemt = sql.Query("SELECT * FROM osshop_data")
		local dataitem
			if itemt[key] then 
				dataitem = itemt[key] 
			else
				return
			end

			net.Start("Shop-Client")
			net.WriteInt(-7, 4)
			net.WriteEntity(npc)
			net.WriteTable(dataitem)
			net.Send(ply)
		return

	elseif where == -2 then -- [[ Edit item from the shop ]] --
		if not osshop.Staff[ply:GetUserGroup()] then return end

		local npc = net.ReadEntity()
		local info = net.ReadTable()
		local IsWeapoon 
			if info.isw == osshop.lang[kla].yes then
				IsWeapoon = "true"
			elseif info.isw == osshop.lang[kla].no then
				IsWeapoon = "false"
			end

		local itemt = sql.Query("SELECT * FROM osshop_data WHERE id ="..info.id)
			if not itemt then
				 return
	  		end
			sql.Query([[UPDATE osshop_data SET isweapon = "]]..IsWeapoon..[[", name = "]]..info.name..[[", entclass = "]]..info.class..[[", models = "]]..info.model..[[", desc = "]]..info.desc..[[", price = "]]..tonumber(info.price)..[[" WHERE id =]]..tonumber(info.id))
			DarkRP.notify(ply, 0, 4, "[Osshop] : "..osshop.lang[kla].txt30)

		local myt = sql.Query("SELECT * FROM osshop_data")
		local ntsend 
			if myt then 
				ntsend = myt 
			else
				ntsend = {}
			end

			net.Start("Shop-Client")
			net.WriteInt(-8, 4)
			net.WriteEntity(npc)
			net.WriteTable(ntsend)
			net.Send(ply)
		return

	elseif where == -1 then -- [[ Start Rob ]] -- 
		local npc = net.ReadEntity()
		
   		if osshop.TeamForRob and not osshop.TeamRob[team.GetName(ply:Team())] then
     		DarkRP.notify(ply, 1, 4, osshop.lang[kla].txt32)
       		return
    	end

    	if not IsValid(npc) then return end
    	if not npc:GetClass() == "nlf_shopx" then return end
    	if npc:GetNWBool("Npc::InRobbing") then return end
    	if ply:GetPos():Distance(npc:GetPos()) > 110 then return end

       	if npc.RobDelay == nil then
            npc.RobDelay = 0
        end

        if CurTime() < npc.RobDelay then
            DarkRP.notify(ply, 1, 4, osshop.lang[kla].txt33)
            return
        end

		copshud(npc)
       	npc:SetNWBool("Npc::InRobbing", true)
        npc:SetNWInt("NPC::Robber", pl)
        npc:SetNWInt("NPC::Timer", CurTime() + osshop.RobDuration)
        DarkRP.notify(ply, 0, 4, osshop.lang[kla].txt34)

        timer.Simple(osshop.robduration, function()
            local pos = (npc:GetPos() + npc:GetAngles():Forward() * 50 + npc:GetAngles():Up() * 50)
           	DarkRP.createMoneyBag(pos, osshop.RobReward)
            DarkRP.notify(ply, 0, 4, osshop.lang[kla].txt35)
            npc:SetNWBool("Npc::InRobbing", false) 
		    npc:SetNWInt("NPC::Robber", nil) 
		   	npc:SetNWInt("NPC::Timer", 0)
            npc.RobDelay = CurTime() + osshop.RobDelay
        end)
    	
	end

end)
--[[
Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--
