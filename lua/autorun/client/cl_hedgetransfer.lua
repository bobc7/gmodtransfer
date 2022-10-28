AddCSLuaFile("autorun/sh_hedgetransfer_config.lua")

local closeX = Material("gmodtransfer/close.png")

-- Function to create the frame of the menu
function hedgeOpenMenu()
    -- If no players online don't open menu
    if player.GetCount() == 1 then
        chat.AddText(Color(255, 255, 255), "| ", HT_ACCENT2, "Hedges Transfer: ", Color(255, 255, 255), "No online players to transfer with :(")
        MsgC("Hedges Transfer Addon | ", Color(255, 82, 82), "Was this a bug? If so report it here!", Color(255, 255, 255), " discord.gg/PQGspxpfFe\n")

        return
    end

    local Frame = vgui.Create("DFrame")
    Frame:SetBackgroundBlur(HT_MENU_BG_BLUR)
    local w = ScrW() * 800 / 1920
    Frame:SetSize(w, ScrH() * 400 / 1080) -- Scaling
    Frame:SetTitle("")
    Frame:SetVisible(true)
    Frame:Center()
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(false)
    Frame:MakePopup()

    Frame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, HT_MENU_COLOR)
        draw.SimpleText(HT_MENU_TITLE, "HT_BUTTON_FONT", 10, 5, HT_MENU_TITLE_COLOR, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local closeButton = Frame:Add("DButton")
    closeButton:SetText("")
    closeButton:SetSize(20,20)
    closeButton:SetPos(w-25,5)

    closeButton.Paint = function(self,w,h)
        local hover = self:IsHovered() and 255 or 220
        surface.SetDrawColor(hover, hover, hover, 255)
	    surface.SetMaterial(closeX)
	    surface.DrawTexturedRect(0, 0, w, h)
    end

    closeButton.DoClick = function(self)
        Frame:Close()
    end

    local leftPanel = Frame:Add("DPanel")
    local rightPanel = Frame:Add("DPanel")

    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, HT_DEFAULT_COLOR)
    end

    -- Add the divider
    local divider = Frame:Add("DHorizontalDivider")
    divider:Dock(FILL)
    divider:SetLeft(leftPanel)
    divider:SetRight(rightPanel)
    divider:SetDividerWidth(4)
    divider:SetLeftMin(250)
    divider:SetRightMin(540)
    divider:SetLeftWidth(150)
    divider:IsDraggable(false)

    divider.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, HT_ACCENT1)
    end

    local topRightPanel = rightPanel:Add("DPanel")
    topRightPanel:Dock(TOP)
    topRightPanel:SetSize(0, 40)

    topRightPanel.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, HT_ACCENT1)
    end

    -- Asking player to select someone to transfer with
    local welcomeLabel = topRightPanel:Add("DLabel")
    welcomeLabel:SetText("Please Select A Player!")
    welcomeLabel:SetFont("HT_BUTTON_FONT")
    welcomeLabel:SetColor(HT_SELECT_TEXT)
    welcomeLabel:Dock(FILL)
    welcomeLabel:DockMargin(0, 13, 0, 0)
    welcomeLabel:SizeToContents() -- Fixes text
    welcomeLabel:SetContentAlignment(8) -- Center it to the top center
    local welcomeSteamID = rightPanel:Add("DLabel")
    welcomeSteamID:SetText("Player SteamID: No Player Selected")
    welcomeSteamID:SetFont("HT_SMALL_INFO")
    welcomeSteamID:SetColor(HT_SELECT_TEXT)
    welcomeSteamID:SetContentAlignment(5)
    welcomeSteamID:SizeToContents()
    welcomeSteamID:Dock(FILL)
    welcomeSteamID:DockMargin(0, 0, 0, 300)
    welcomeSteamID:SetVisible(true)
    local whatAmount = rightPanel:Add("DLabel")
    whatAmount:SetText("How much would you like to Send or Request?")
    whatAmount:SetFont("HT_BIG_INFO")
    whatAmount:SetColor(HT_SELECT_TEXT)
    whatAmount:SetContentAlignment(5)
    whatAmount:SizeToContents()
    whatAmount:Dock(FILL)
    whatAmount:DockMargin(0, 0, 0, 250)
    whatAmount:SetVisible(false)
    -- Set amount you want to transfer
    local setAmount = rightPanel:Add("DNumberWang")
    setAmount:SetDecimals(0)
    setAmount:HideWang()
    setAmount:SizeToContents()
    setAmount:SetFont("HT_BUTTON_FONT")
    setAmount:Dock(FILL)
    -- Moving the element
    setAmount:DockMargin(150, 60, 140, 240)
    setAmount:SetVisible(false)
    setAmount:SetContentAlignment(5)
    setAmount:SetMultiline(false)

    setAmount.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, HT_ACCENT1)
        setAmount:DrawTextEntryText(Color(255, 255, 255), Color(255, 169, 169), Color(255, 255, 255, 249))
    end

    local sendTransfer = rightPanel:Add("DButton")
    sendTransfer:SetFont("HT_BUTTON_FONT")
    sendTransfer:SetText("Send")
    sendTransfer:Dock(FILL)
    sendTransfer:SetVisible(false)
    sendTransfer:DockMargin(140, 120, 290, 100)

    sendTransfer.Paint = function(self, w, h)
        draw.RoundedBox(20, 0, 0, w, h, Color(101, 255, 132))
    end

    local requestTransfer = rightPanel:Add("DButton")
    requestTransfer:SetFont("HT_BUTTON_FONT")
    requestTransfer:SetText("Request")
    requestTransfer:Dock(FILL)
    requestTransfer:SetVisible(false)
    requestTransfer:DockMargin(300, 120, 130, 100)

    requestTransfer.Paint = function(self, w, h)
        draw.RoundedBox(20, 0, 0, w, h, HT_ACCENT2)
    end

    -- Adding the vgui component to scroll
    local scrollList = leftPanel:Add("DScrollPanel")
    scrollList:Dock(FILL)

    scrollList.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, HT_DEFAULT_COLOR)
    end

    -- Add Support Buttons
    local discordButton = scrollList:Add("DButton")
    discordButton:SetText("Support Discord")
    discordButton:SetFont("HT_BUTTON_FONT")
    discordButton:SetColor(HT_DISCORDBUTTON_TEXT)
    discordButton:Dock(TOP)
    discordButton:DockMargin(30, 0, 30, 5)

    discordButton.DoClick = function()
        MsgC(Color(255, 255, 255), "\nJoin the discord here! discord.gg/PQGspxpfFe\n")
        chat.AddText(Color(255, 255, 255), "\nJoin the discord here! discord.gg/PQGspxpfFe\n")
    end

    -- gui.OpenURL('https://discord.gg/KfCzCA78ph') -- TODO: CURRENT BUG ([MENU ERROR] attempt to call a nil value)
    discordButton.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, HT_DISCORDBUTTON_BUTTON)
    end

    local creditsButton = scrollList:Add("DButton")
    creditsButton:SetText("Addon Credits!")
    creditsButton:SetFont("HT_BUTTON_FONT")
    creditsButton:Dock(TOP)
    creditsButton:DockMargin(30, 0, 30, 8)

    creditsButton.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, HT_ACCENT1)
    end

    creditsButton.DoClick = function()
        print("\n\n\n\n\n")
        LocalPlayer():ConCommand("showconsole")
        MsgC(Color(255, 255, 255), "Hedges Transfer Addon Credits!\n\n", Color(216, 147, 255), "Main Developer: Hedges\n", Color(255, 252, 164), "Steam Link: https://steamcommunity.com/id/Hedgess/\nDiscord Link: discord.gg/PQGspxpfFe\n")
    end

    -- Get all players and sort through to make buttons
    local players = player.GetAll()

    for k, v in ipairs(players) do
        -- Don't include client
        if v == LocalPlayer() then continue end
        if !IsValid(v) then continue end
        local buttons = scrollList:Add("DButton")
        buttons:SetText(v:Nick()) -- Setting all button names to that players Nick
        buttons:SetFont("HT_BUTTON_FONT")
        buttons:SetColor(HT_PLAYERBUTTONS_TEXT and HT_PLAYERBUTTONS_TEXT or team.GetColor(v:Team()))
        buttons:Dock(TOP)
        buttons:DockMargin(20, 0, 20, 4)

        local c = HT_PLAYERBUTTONS_BUTTON and HT_PLAYERBUTTONS_BUTTON or team.GetColor(v:Team())
        local hc = Color(c.r * 1.1, c.g * 1.1, c.b * 1.1)
        buttons.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(8, 0, 0, w, h, hc)
            else
                draw.RoundedBox(8, 0, 0, w, h, c)
            end
        end

        -- Handles when the player clicks a button to select a player
        buttons.DoClick = function()
            if not v:IsValid() then
                print("That is not a valid player!")
                return
            end

            welcomeLabel:SetText("Selected Player: " .. v:Nick())
            whatAmount:SetVisible(true)
            setAmount:SetVisible(true)
            sendTransfer:SetVisible(true)
            requestTransfer:SetVisible(true)
            welcomeSteamID:SetText("Player SteamID: " .. v:SteamID())

            -- Handle when a player clicks the send button
            sendTransfer.DoClick = function()
                -- Prevent players from sending empty transfers or exploiting negative numbers
                if setAmount:GetValue() <= 0 then
                    chat.AddText(Color(255, 121, 121), "HTA: ", Color(169, 43, 43), "Value must be greater than 0")
                    return
                end

                -- Begin communication with the server
                net.Start("hta_send")
                -- Send selected player
                net.WriteEntity(v)
                -- Send amount to transfer
                net.WriteUInt(setAmount:GetValue(), 32)
                -- Send all data to the server
                net.SendToServer()
            end
        end

        -- Handle when the player clicks the request button
        requestTransfer.DoClick = function ()
            -- Prevent players from sending empty requests or exploiting negative numbers
            if (setAmount:GetValue() <= 0) then
                chat.AddText(Color(255,121,121), "HTA: ", Color(169,43,43), "Value must be greater than 0")
                return
            end
            -- Begin communication with the server
            net.Start("hta_request")
            -- Send selected player
            net.WriteEntity(v)
            -- Send amount to request
            net.WriteUInt(setAmount:GetValue(), 32)
            -- Send all data to the server
            net.SendToServer()
            return
        end

        -- Letting sending player know the transfer was successful
        net.Receive("hta_send_success", function(len)
            local amount = net.ReadUInt(32)
            chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 255, 255), " Your transfer of " .. amount .. "$ to " .. v:Nick() .. " was ", Color(8, 255, 41), "successful!")
        end)

        -- Letting receiving player know the transfer was successful
        net.Receive("hta_received", function(len)
            local amount = net.ReadUInt(32)
            local sendingPlayer = net.ReadEntity()
            chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 255, 255), " A transfer of " .. amount .. "$ from " .. sendingPlayer:Nick() .. " was ", Color(8, 255, 41), "successful!")
        end)

        -- Letting player know they cannot afford this transaction :(
        net.Receive("hta_cantafford", function(len)
            chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 255, 255), " You cannot afford this transfer!")
        end)

        -- Letting player know the person they requested from cannot afford this request :(
        net.Receive("hta_reqcantafford", function(len)
            chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 255, 255), " The player you are requesting from cannot afford this transfer!")
        end)

        -- Cooldown alert
        net.Receive("hta_waitcooldown", function(len)
            chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 255, 255), " You must wait 10 seconds before trying to send another transfer.")
        end)

        -- Cooldown alert
        net.Receive("hta_request_received", function(len)
            local targetPlayer = net.ReadEntity()
            chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 255, 255), " Your request to " .. targetPlayer:Nick() .. " was successful!")
        end)
    end
end

net.Receive("hta_request_accepted", function()
    local reqAmount = net.ReadUInt(32)
    local reqId = net.ReadString()
    local fromPly = net.ReadEntity()
    chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 255, 255), fromPly:Nick() .. " accepted your Request! ( RequestId: " .. reqId .. ", Amount: " .. reqAmount .. ")")
end)

net.Receive("hta_request_declined", function()
    local reqAmount = net.WriteUInt(request.amount, 32)
    local reqId = net.WriteString(request.requestId)
    local fromPly = net.ReadEntity()
    chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 255, 255), fromPly:Nick() .. " declined your Request! ( RequestId: " .. reqId .. ", Amount: " .. reqAmount .. ")")
end)

net.Receive("hta_request_invalid", function()
    local reason = net.ReadString()

    if reason then
        chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 0, 0), " An Error occured with your request: ")
        chat.AddText("    ", Color(255, 0, 0), reason)
    else
        chat.AddText(Color(255, 114, 114), "HTA:", Color(255, 0, 0), " An Error with your request!")
    end
end)

-- Add Chat Commands
-- TODO: Add check for customization to disable commands while dead?
hook.Add("OnPlayerChat", "hedgeChatOpenTransfer", function(ply, text, teamChat, isDead)
    if ply ~= LocalPlayer() then return end
    text = string.lower(text)

    if text == "/transfer" then
        hedgeOpenMenu()

        return true
    end

    if text == "!transfer" then
        hedgeOpenMenu()

        return true
    end

    if text == "ishtapresent" then
        chat.AddText("Yes, Hedges has made his mark here!")

        return true
    end
end)


concommand.Add("transfer", hedgeOpenMenu) -- Concommand to trigger the menu
-- TODO: Figure out the text highlight color on the buttons?