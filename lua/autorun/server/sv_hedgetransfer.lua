require("reqwest")
AddCSLuaFile("autorun/sh_hedgetransfer_config.lua")
-- TODO: ADD MORE FEEDBACK
-- TODO: ADD SOUNDS
-- TODO: ADD LOCAL PLAYER CHECK | is this player sending or requesting themself?
-- TODO: ADD IS ANYBODY ELSE ONLINE CHECK? ?
-- TODO: ADD LOGS
-- Precaching network messages
util.AddNetworkString("hta_send")
util.AddNetworkString("hta_send_success")
util.AddNetworkString("hta_received")
util.AddNetworkString("hta_cantafford")
util.AddNetworkString("hta_waitcooldown")
util.AddNetworkString("hta_request")
util.AddNetworkString("hta_reqcantafford")
util.AddNetworkString("hta_request_received")
util.AddNetworkString("hta_receiving_request")
util.AddNetworkString("hta_request_invalid")
util.AddNetworkString("hta_request_accepted")
util.AddNetworkString("hta_request_declined")
local TRANSFER = {}

--[[

    Should have the form like:
      {
        requestId: [STRING],
        requester: [STEAMID],
        from: [STEAMID]
        amount: [NUMBER],
      }

]]
local function fetchTransferOf(reqSteamId, targetSteamId)
    for k, v in ipairs(TRANSFER) do
        if v.requester == reqSteamId and v.from == targetSteamId then return k, v end
    end

    return false
end

local function getTransferById(id)
    for k, v in ipairs(TRANSFER) do
        if v.requestId == id then return k, v end
    end

    return false
end

local function checkIfUserRequestedIt(reqSteamId, targetSteamId)
    local res = fetchTransferOf(reqSteamId, targetSteamId)
    if res then return true, res end

    return false
end

local function sendWebhook(from, to, amount, request)
    if not HT_TRANSFER_WEBHOOK then return end

    if not request then
        reqwest({
            method = "POST",
            url = HT_TRANSFER_WEBHOOK,
            timeout = 30,
            body = util.TableToJSON({
                embed = {
                    {
                        title = "Hedge Transfer Log - Send",
                        description = "A user send money!",
                        url = "steam://connect/" .. game.GetIPAddress(),
                        fields = {
                            {
                                name = "From: ",
                                value = from:Nick(),
                                inline = true,
                            },
                            {
                                name = "To: ",
                                value = to:Nick(),
                                inline = true,
                            },
                            {
                                name = "Amount: ",
                                value = amount,
                                inline = false,
                            },
                        }
                    }
                }
            }),
            type = "application/json",
            headers = {
                ["User-Agent"] = "Hedge Client", -- This is REQUIRED to dispatch a Discord webhook
                
            },
            success = function(status, body, headers) end,
            failed = function(err, errExt)
                print("Error: " .. err .. " (" .. errExt .. ")")
            end
        })
    else
        reqwest({
            method = "POST",
            url = HT_TRANSFER_WEBHOOK,
            timeout = 30,
            body = util.TableToJSON({
                embed = {
                    {
                        title = "Hedge Transfer Log - Request",
                        description = "A user requested money!",
                        url = "steam://connect/" .. game.GetIPAddress(),
                        fields = {
                            {
                                name = "From: ",
                                value = from:Nick(),
                                inline = true,
                            },
                            {
                                name = "To: ",
                                value = to:Nick(),
                                inline = true,
                            },
                            {
                                name = "Amount: ",
                                value = amount,
                                inline = false,
                            },
                        }
                    }
                }
            }),
            type = "application/json",
            headers = {
                ["User-Agent"] = "Hedge Client", -- This is REQUIRED to dispatch a Discord webhook
                
            },
            success = function(status, body, headers) end,
            failed = function(err, errExt)
                print("Error: " .. err .. " (" .. errExt .. ")")
            end
        })
    end
end

local function generateId()
    local template = "xxxxyx"

    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)

        return string.format("%x", v)
    end)
end

-- Receive transfer send
-- Cooldown stuff
local delay = 10
local lastOccurance = -delay

net.Receive("hta_send", function(len, sendingPly)
    local timeElapsed = CurTime() - lastOccurance

    if timeElapsed < delay then
        net.Start("hta_waitcooldown")
        net.Send(sendingPly)

        return
    end

    lastOccurance = CurTime()

    -- Block message if to big
    if len >= 500 then
        print("\nNet message to big. Stopping - HTA\n")

        return
    end

    -- Receive selected player
    local toPly = net.ReadEntity()
    -- Receive amount to transfer
    local amount = net.ReadUInt(32)

    -- Blocking values of 0 or lower, due to security concerns.
    if amount <= 0 then
        print(sendingPly:Nick() .. " Tried sending a value of 0 or lower - HTA")

        return
    end

    -- Handle transaction
    -- Check if sending player can afford transfer amount
    if sendingPly:canAfford(amount) == false then
        net.Start("hta_cantafford")
        net.Send(sendingPly)

        return
    end

    sendingPly:addMoney(-amount)
    toPly:addMoney(amount)
    sendWebhook(sendingPly, toPly, requestAmount)
    -- Letting Sending Player know that the transfer was successful
    net.Start("hta_send_success")
    net.WriteUInt(amount, 32)
    net.Send(sendingPly)
    -- Letting receiving player know that the transfer was successful
    net.Start("hta_received")
    net.WriteUInt(amount, 32)
    net.WriteEntity(sendingPly)
    net.Send(toPly)
end)

-- Receive transfer request
net.Receive("hta_request", function(len, reqPly)
    local timeElapsed = CurTime() - lastOccurance

    if timeElapsed < delay then
        net.Start("hta_waitcooldown")
        net.Send(reqPly)

        return
    end

    lastOccurance = CurTime()

    -- Block message if to big
    if len >= 500 then
        print("\nNet message to big. Stopping - HTA\n")

        return
    end

    -- Player who is getting the request
    local targetPly = net.ReadEntity()

    if not targetPly or not targetPly:IsPlayer() then
        net.Start("hta_request_invalid")
        net.WriteString("The Player you choosen is either vanished or is disconnected")
        net.Send(reqPly)
    end

    -- Amount being requested
    local requestAmount = net.ReadUInt(32)

    if checkIfUserRequestedIt(reqPly:SteamID(), targetPly:SteamID64()) then
        net.Start("hta_request_invalid")
        net.WriteString("You already requested Money from him! Please wait!")
        net.Send(reqPly)
    end

    if targetPly:canAfford(requestAmount) == false then
        net.Start("hta_reqcantafford")
        net.Send(reqPly)

        return
    end

    local request = {
        requestId = generateId(),
        requester = reqPly:SteamID(),
        amount = requestAmount,
        from = targetPly:SteamID()
    }

    sendWebhook(targetPly, reqPly, requestAmount, true)
    -- Adding Request Object
    table.insert(TRANSFER, request)
    -- Letting requesting player know that the request was received
    net.Start("hta_request_received")
    net.WriteEntity(targetPly)
    net.Send(reqPly)
    -- Letting target player know there is a new request
    net.Start("hta_receiving_request")
    -- Sending the amount requested
    net.WriteUInt(requestAmount, 32)
    -- Sending the key for identification
    net.WriteString(request.requestId)
    -- Sending who sent the request
    net.WriteEntity(reqPly)
    net.Send(targetPly)
end)

-- Handle Accepted Request
local function HandleRequest(request)
    local reqPly = player.GetBySteamID(request.requester)
    local fromPly = player.GetBySteamID(request.from)

    if not reqPly and not fromPly then
        print("HTA: An Invalid Request was recieved!")

        return
    elseif not reqPly then
        fromPly:ChatPrint("HTA: The requester is not available anymore ( He disconnected )!")

        return
    end

    sendWebhook(fromPly, reqPly, request.amount)

    if fromPly:canAfford(request.amount) == false then
        net.Start("hta_cantafford")
        net.Send(fromPly)

        return
    end

    reqPly:addMoney(request.amount)
    fromPly:addMoney(-request.amount)
    -- Removing Request from the table
    table.remove(TRANSFER, request)
    -- Letting Requester know that the request was accepted
    net.Start("hta_request_accepted")
    net.WriteUInt(request.amount, 32)
    net.WriteString(request.requestId)
    net.WriteEntity(fromPly)
    net.Send(reqPly)
end

-- Handle Declined Request
local function HandleDecline(request)
    local reqPly = player.GetBySteamID(request.requester)
    local fromPly = player.GetBySteamID(request.from)

    if not reqPly and not fromPly then
        print("HTA: An Invalid Request was recieved!")

        return
    elseif not reqPly then
        fromPly:ChatPrint("HTA: The requester is not available anymore ( He disconnected )!")

        return
    end

    -- Removing Request from the table
    table.remove(TRANSFER, request)
    -- Letting Requester know that the request was declined
    net.Start("hta_request_declined")
    net.WriteUInt(request.amount, 32)
    net.WriteString(request.requestId)
    net.WriteEntity(fromPly)
    net.Send(reqPly)
end

-- All usable prefixes for commands.
local prefixs = {
    ["!"] = true,
    ["/"] = true,
}

-- Commands
local commands = {
    ["acceptrequest"] = function(ply, ...)
        local args = {...}

        local id = args[2]
        local _, request = getTransferById(id)

        if not request then
            ply:ChatPrint("HTA: Your Id you provided is invalid!")

            return false
        end

        HandleRequest(request)
    end,
    ["declinerequest"] = function(ply, ...)
        local args = {...}

        local id = args[2]
        local _, request = getTransferById(id)

        if not request then
            ply:ChatPrint("HTA: Your Id you provided is invalid!")

            return false
        end

        HandleDecline(request)
    end
}

hook.Add("PlayerSay", "commandsblah", function(ply, text)
    if IsValid(ply) and prefixs[string.sub(text, 1, 1)] then
        local split = string.Explode(" ", string.lower(string.sub(text, 2)))
        local cmd = commands[split[1]]

        if cmd then
            cmd(ply, unpack(split, 2))
        end
    end
end)