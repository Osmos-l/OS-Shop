--[[
Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--

--[[ BLUR ]]--

local blur = Material("pp/blurscreen")

local function blurPanel(firstp, amount)
    local x, y = firstp:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blur)

    for i = 1, 6 do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end

--[[ PANEL ]]--

local kla = osshop.choice
local shopfirstp
local icon = Material("osshop/door.png")
local icon2 = Material("osshop/edit.png")
local icon3 = Material("osshop/delete.png")
local icon4 = Material("osshop/rob.png")

local scrw, scrh = ScrW(), ScrH()
net.Receive("Shop-Client", function(len, pl)
local where = net.ReadInt(4)

    if where == -8 then -- [[ Shop Open ]]--
        local npc = net.ReadEntity()
        local alldata = net.ReadTable()

            shopfirstp = vgui.Create("DFrame")
        shopfirstp:SetSize(600, 600)
        shopfirstp:SetPos(scrw / 2 - 300, scrh)
        shopfirstp:SetTitle("")
        shopfirstp:SetDraggable(true)
        shopfirstp:ShowCloseButton(false)
        shopfirstp:MakePopup()
        shopfirstp:MoveTo(scrw / 2 - 300, scrh / 2 - 300, 0.25, 0, 10)

        function shopfirstp:Paint(w, h)
            blurPanel(self, 5)
            draw.RoundedBox(3, 0, 0, w, h, Color(18, 23, 38, 230))
            draw.SimpleText(osshop.lang[kla].txt1, "Trebuchet18", 300, 8, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        end

            local CScrool = vgui.Create("DScrollPanel", shopfirstp)
        CScrool:Dock(FILL)
        local scrollbar = CScrool:GetVBar()

        function scrollbar:Paint(w, h)
            draw.RoundedBox(3, 0, 0, w, h, Color(18, 23, 38, 200))
        end

        function scrollbar.btnUp:Paint(w, h)
            draw.RoundedBox(3, 6, 0, 8, h, Color(100, 0, 0, 200))
        end

        function scrollbar.btnDown:Paint(w, h)
            draw.RoundedBox(3, 6, 0, 8, h, Color(100, 0, 0, 200))
        end

        function scrollbar.btnGrip:Paint(w, h)
            draw.RoundedBox(3, 6, 0, 8, h, Color(100, 0, 0, 200))
        end

            local exit = vgui.Create("DButton", shopfirstp)
        exit:SetPos(530, 545)
        exit:SetSize(50, 50)
        exit:SetText("")
        exit:SetTextColor(Color(255, 255, 255))

        function exit:Paint(w, h)
            draw.RoundedBox(5, 0, 0, w, h, Color(18, 23, 38))
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        exit.DoClick = function()
            shopfirstp:Remove()
            surface.PlaySound("buttons/button14.wav")
        end

            local rob = vgui.Create("DButton", shopfirstp)
        rob:SetPos(5, 545)
        rob:SetSize(50, 50)
        rob:SetText("")
        rob:SetTextColor(Color(255, 255, 255))

        function rob:Paint(w, h)
            draw.RoundedBox(5, 0, 0, w, h, Color(18, 23, 38))
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(icon4)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        rob.DoClick = function() 
            net.Start("Shop-Server")
            net.WriteInt(-1, 4)
            net.WriteEntity(npc)
            net.SendToServer()
            shopfirstp:Remove()
            surface.PlaySound("buttons/button14.wav")
        end

        for k, v in pairs(alldata) do
        local show = false

            if table.Count(util.JSONToTable(v.only)) >= 1 then
                if table.HasValue(util.JSONToTable(v.only), team.GetName(LocalPlayer():Team())) then
                    show = true
                end
                if osshop.Staff[LocalPlayer():GetUserGroup()] then
                    show = true
                end
            else
                show = true
            end

            if show then

                    local xp = vgui.Create("DPanel", CScrool)
                xp:SetSize(0, 60)
                xp:DockMargin(0, 0, 0, 5)
                xp:Dock(TOP)

                function xp:Paint(w, h)
                    draw.RoundedBox(2, 0, 0, w, h, Color(26, 30, 39))
                    draw.SimpleText(v.name, "Trebuchet18", 80, 5, Color(255, 255, 255))
                    draw.SimpleText(osshop.lang[kla].txt2 .. " " .. v.price .. "" .. osshop.lang[kla].money, "Trebuchet18", 80, 30, Color(255, 255, 255))
                end

                    local desc = vgui.Create("DLabel", xp)
                desc:SetSize(350, 55)
                desc:SetPos(160, 0)
                desc:SetText(osshop.lang[kla].txt3 .. " " .. v.desc)
                desc:SetWrap(true)

                if osshop.Staff[LocalPlayer():GetUserGroup()] then
                        local edit = vgui.Create("DButton", xp)
                    edit:SetSize(20, 20)
                    edit:SetPos(500, 5)
                    edit:SetText("")

                    function edit:Paint(w, h)
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(icon2)
                        surface.DrawTexturedRect(0, 0, w, h)
                    end

                    edit.DoClick = function()
                        surface.PlaySound("buttons/button14.wav")
                        net.Start("Shop-Server")
                        net.WriteInt(-3, 4)
                        net.WriteInt(k, 16)
                        net.WriteEntity(npc)
                        net.SendToServer()
                    end

                        local delete = vgui.Create("DButton", xp)
                    delete:SetSize(20, 20)
                    delete:SetPos(535, 5)
                    delete:SetText("")

                    function delete:Paint(w, h)
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(icon3)
                    surface.DrawTexturedRect(0, 0, w, h)
                    end

                    delete.DoClick = function()
                        surface.PlaySound("buttons/button14.wav")
                            local basc = vgui.Create("DFrame")
                        basc:SetSize(350, 200)
                        basc:SetTitle("")
                        basc:SetDraggable(true)
                        basc:ShowCloseButton(false)
                        basc:MakePopup()
                        basc:Center()

                        function basc:Paint(w, h)
                            blurPanel(self, 5)
                            draw.RoundedBox(3, 0, 0, w, h, Color(18, 23, 38, 200))
                            draw.RoundedBox(3, 0, 0, w, 30, Color(26, 30, 39))
                            draw.SimpleText(osshop.lang[kla].txt4, "Trebuchet18", 175, 8, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                            draw.SimpleText(osshop.lang[kla].txt5, "Trebuchet18", 175, 70, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                        end

                            local yesdel = vgui.Create("DButton", basc)
                        yesdel:SetSize(80, 30)
                        yesdel:SetPos(75, 130)
                        yesdel:SetText(osshop.lang[kla].yes)
                        yesdel:SetTextColor(Color(255, 255, 255))

                        function yesdel:Paint(w, h)
                            draw.RoundedBox(3, 0, 0, w, h, Color(6, 84, 3))
                        end

                        yesdel.DoClick = function()
                            surface.PlaySound("buttons/button14.wav")
                            net.Start("Shop-Server")
                            net.WriteInt(-4, 4)
                            net.WriteInt(k, 16)
                            net.WriteEntity(npc)
                            net.SendToServer()
                            basc:Remove()
                            shopfirstp:Remove()
                        end

                            local nodel = vgui.Create("DButton", basc)
                        nodel:SetSize(80, 30)
                        nodel:SetPos(180, 130)
                        nodel:SetText(osshop.lang[kla].no)
                        nodel:SetTextColor(Color(255, 255, 255))

                        function nodel:Paint(w, h)
                            draw.RoundedBox(3, 0, 0, w, h, Color(100, 0, 0))
                        end

                        nodel.DoClick = function()
                            surface.PlaySound("buttons/button14.wav")
                            basc:Remove()
                        end
                    end
                end

                    local db = vgui.Create("DButton", xp)
                db:SetPos(500, 30)
                db:SetText(osshop.lang[kla].buy)
                db:SetTextColor(Color(255, 255, 255))

                function db:Paint(w, h)
                    draw.RoundedBox(5, 0, 0, w, h, Color(100, 0, 0))
                end

                db.DoClick = function()
                    surface.PlaySound("buttons/button14.wav")
                    net.Start("Shop-Server")
                    net.WriteInt(-6, 4)
                    net.WriteEntity(npc)
                    net.WriteInt(v.id, 16)
                    net.SendToServer()
                    shopfirstp:Remove()
                end

                    local ic = vgui.Create("SpawnIcon", xp)
                ic:SetSize(65, 65)
                ic:SetPos(5, 0)
                ic:SetModel(v.models)
            end
        end
    elseif where == -7 then -- [[ Panel Edit Item ]--

        local npc = net.ReadEntity()
        local txtent = net.ReadTable()
        local txtv

        if txtent.isweapon == "true" then
            txtv = osshop.lang[kla].yes
        elseif txtent.isweapon == "false" then
            txtv = osshop.lang[kla].no
        end

            local firstp = vgui.Create("DFrame")
        firstp:SetSize(300, 430)
        firstp:Center()
        firstp:SetTitle("")
        firstp:SetDraggable(true)
        firstp:ShowCloseButton(false)
        firstp:MakePopup()

        function firstp:Paint(w, h)
            blurPanel(self, 5)
            draw.RoundedBox(3, 0, 0, w, h, Color(18, 23, 38, 230))
            draw.RoundedBox(3, 0, 0, w, 30, Color(26, 30, 39))
            draw.SimpleText(osshop.lang[kla].txt18, "Trebuchet18", 150, 8, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            draw.SimpleText(osshop.lang[kla].txt7, "Trebuchet18", 150, 55, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        end

            local isw = vgui.Create("DComboBox", firstp)
        isw:SetSize(100, 20)
        isw:SetPos(100, 70)
        isw:SetValue(txtv)
        isw:AddChoice(osshop.lang[kla].yes)
        isw:AddChoice(osshop.lang[kla].no)

            local entname = vgui.Create("DTextEntry", firstp)
        entname:SetSize(200, 30)
        entname:SetPos(50, 102)
        entname:SetText(txtent.name)
        entname:SetDrawLanguageID(false)

            local entclass = vgui.Create("DTextEntry", firstp)
        entclass:SetSize(200, 30)
        entclass:SetPos(50, 134)
        entclass:SetText(txtent.entclass)
        entclass:SetDrawLanguageID(false)

            local entmodels = vgui.Create("DTextEntry", firstp)
        entmodels:SetSize(200, 30)
        entmodels:SetPos(50, 166)
        entmodels:SetText(txtent.models)
        entmodels:SetDrawLanguageID(false)

            local entprice = vgui.Create("DTextEntry", firstp)
        entprice:SetSize(200, 30)
        entprice:SetPos(50, 198)
        entprice:SetText(txtent.price)
        entprice:SetDrawLanguageID(false)

            local entdesc = vgui.Create("DTextEntry", firstp)
        entdesc:SetSize(200, 30)
        entdesc:SetPos(50, 230)
        entdesc:SetText(txtent.desc)
        entdesc:SetDrawLanguageID(false)

            local addteam = vgui.Create("DComboBox", firstp)
        addteam:SetSize(200, 30)
        addteam:SetPos(50, 262)

        for k, v in pairs(RPExtraTeams) do
            if not table.HasValue(util.JSONToTable(txtent.only), v.name) then
                addteam:AddChoice(v.name)
            end
        end

        function addteam:OnSelect(value)
            net.Start("Shop-Server")
            net.WriteInt(-8, 4)
            net.WriteInt(txtent.id, 16)
            net.WriteString(addteam:GetValue())
            net.SendToServer()
            chat.AddText(Color(226, 0, 0), "[ Os-Shop] : ", Color(255, 255, 255), " "..osshop.lang[kla].txt38 )
            firstp:Remove()
        end

            local removeteam = vgui.Create("DComboBox", firstp)
        removeteam:SetSize(200, 30)
        removeteam:SetPos(50, 294)

        for k, v in pairs(util.JSONToTable(txtent.only)) do
            removeteam:AddChoice(v)
        end

        function removeteam:OnSelect(value)
            net.Start("Shop-Server")
            net.WriteInt(-7, 4)
            net.WriteInt(txtent.id, 16)
            net.WriteString(removeteam:GetValue())
            net.SendToServer()
            chat.AddText(Color(226, 0, 0), "[ Os-Shop] : ", Color(255, 255, 255), " "..osshop.lang[kla].txt39)
            firstp:Remove()
        end

            local acceptbut = vgui.Create("DButton", firstp)
        acceptbut:SetSize(200, 30)
        acceptbut:SetPos(50, 354)
        acceptbut:SetText(osshop.lang[kla].confirm)
        acceptbut:SetTextColor(Color(255, 255, 255))

        function acceptbut:Paint(w, h)
            draw.RoundedBox(3, 0, 0, w, h, Color(6, 84, 3))
        end

        acceptbut.DoClick = function()
            local info = {
                id = txtent.id,
                isw = isw:GetValue(),
                name = entname:GetValue(),
                class = entclass:GetValue(),
                model = entmodels:GetValue(),
                price = entprice:GetValue(),
                desc = entdesc:GetValue()
            }
            surface.PlaySound("buttons/button14.wav")
            net.Start("Shop-Server")
            net.WriteInt(-2, 4)
            net.WriteEntity(npc)
            net.WriteTable(info)
            net.SendToServer()
            firstp:Remove()
            shopfirstp:Remove()
        end

            local leavebut = vgui.Create("DButton", firstp)
        leavebut:SetSize(200, 30)
        leavebut:SetPos(50, 386)
        leavebut:SetText(osshop.lang[kla].leave)
        leavebut:SetTextColor(Color(255, 255, 255))

        function leavebut:Paint(w, h)
            draw.RoundedBox(3, 0, 0, w, h, Color(100, 0, 0))
        end

        leavebut.DoClick = function()
            surface.PlaySound("buttons/button14.wav")
            firstp:Remove()
        end

    elseif where == -6 then -- [[ Draw and remove Hud ]]--
        local npc = net.ReadEntity()
        local candraw = net.ReadBool()

        if candraw then
            hook.Add("HUDPaint", "Shop::CopsHUD", function()
                local Position = (npc:GetPos() + Vector(0, 0, 80)):ToScreen() -- The author of this function is not me but this developper : https://slownls.fr/
                if math.Round(LocalPlayer():GetPos():Distance(npc:GetPos())) >= 200 then
                    draw.SimpleTextOutlined("●", "ChatFont", Position.x, Position.y - 15, Color(0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25))
                    draw.SimpleTextOutlined(math.Round(LocalPlayer():GetPos():Distance(npc:GetPos()) / 10) .. "m", "ChatFont", Position.x, Position.y, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25))
                end
            end)
        else
            hook.Remove("HUDPaint", "Shop::CopsHUD")
        end
    end

end)

local function NewItem()
        local firstp = vgui.Create("DFrame")
    firstp:SetSize(300, 400)
    firstp:Center()
    firstp:SetTitle("")
    firstp:SetDraggable(true)
    firstp:ShowCloseButton(false)
    firstp:MakePopup()

    function firstp:Paint(w, h)
        blurPanel(self, 5)
        draw.RoundedBox(3, 0, 0, w, h, Color(18, 23, 38, 230))
        draw.RoundedBox(3, 0, 0, w, 30, Color(26, 30, 39))
        draw.SimpleText(osshop.lang[kla].txt6, "Trebuchet18", 150, 8, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText(osshop.lang[kla].txt7, "Trebuchet18", 150, 55, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end

        local isw = vgui.Create("DComboBox", firstp)
    isw:SetSize(100, 20)
    isw:SetPos(100, 70)
    isw:AddChoice(osshop.lang[kla].yes)
    isw:AddChoice(osshop.lang[kla].no)

        local entname = vgui.Create("DTextEntry", firstp)
    entname:SetSize(200, 30)
    entname:SetPos(50, 102)
    entname:SetText(osshop.lang[kla].txt13)
    entname:SetDrawLanguageID(false)

	entname.OnGetFocus = function()
        entname:SetValue("")
    end

        local entclass = vgui.Create("DTextEntry", firstp)
    entclass:SetSize(200, 30)
    entclass:SetPos(50, 134)
    entclass:SetText(osshop.lang[kla].txt14)
    entclass:SetDrawLanguageID(false)

    entclass.OnGetFocus = function()
    	entclass:SetValue("")
    end

        local entmodels = vgui.Create("DTextEntry", firstp)
    entmodels:SetSize(200, 30)
    entmodels:SetPos(50, 166)
    entmodels:SetText(osshop.lang[kla].txt15)
    entmodels:SetDrawLanguageID(false)

    entmodels.OnGetFocus = function()
    	entmodels:SetValue("")
    end

        local entprice = vgui.Create("DTextEntry", firstp)
    entprice:SetSize(200, 30)
    entprice:SetPos(50, 198)
    entprice:SetText(osshop.lang[kla].txt16)
    entprice:SetDrawLanguageID(false)

    entprice.OnGetFocus = function()
    	entprice:SetValue("")
    end

        local entdesc = vgui.Create("DTextEntry", firstp)
    entdesc:SetSize(200, 30)
    entdesc:SetPos(50, 230)
    entdesc:SetText(osshop.lang[kla].txt17)
    entdesc:SetDrawLanguageID(false)

    entdesc.OnGetFocus = function()
    	entdesc:SetValue("")
    end

        local acceptbut = vgui.Create("DButton", firstp)
    acceptbut:SetSize(200, 30)
    acceptbut:SetPos(50, 290)
    acceptbut:SetText(osshop.lang[kla].confirm)
    acceptbut:SetTextColor(Color(255, 255, 255))

    function acceptbut:Paint(w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(6, 84, 3))
    end

    acceptbut.DoClick = function()
        local info = {
            isw = isw:GetValue(),
            name = entname:GetValue(),
            class = entclass:GetValue(),
            model = entmodels:GetValue(),
            price = entprice:GetValue(),
            desc = entdesc:GetValue()
        }
        surface.PlaySound("buttons/button14.wav")
        net.Start("Shop-Server")
        net.WriteInt(-5, 4)
        net.WriteTable(info)
        net.SendToServer()
    	firstp:Remove()
    end

        local leavebut = vgui.Create("DButton", firstp)
    leavebut:SetSize(200, 30)
    leavebut:SetPos(50, 322)
    leavebut:SetText(osshop.lang[kla].leave)
    leavebut:SetTextColor(Color(255, 255, 255))

    function leavebut:Paint(w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(100, 0, 0))
    end

    leavebut.DoClick = function()
        surface.PlaySound("buttons/button14.wav")
        firstp:Remove()
    end
end

--[[ HOOK ]]--

hook.Add("OnPlayerChat", "Shop::OpenNewItem", function(ply, strText)
	local lPlayer = LocalPlayer()
	if ply != lPlayer then return end 
		
	if osshop.Staff[ lPlayer:GetUserGroup() ] and strText == osshop.AddItemCommand then
			NewItem()
		return true
	end

end)

--[[
Addon by Osmos[FR] : https://steamcommunity.com/id/ThePsyca/
Info : Public Addon
]]--
