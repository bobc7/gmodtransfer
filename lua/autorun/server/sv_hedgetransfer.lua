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
        amount: [NUMBER],
        from: [STEAMID]
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

net.Receive("hta_send", function(len, sendingPlayer)
    local timeElapsed = CurTime() - lastOccurance

    if timeElapsed < delay then
        net.Start("hta_waitcooldown")
        net.Send(sendingPlayer)

        return
    end

    lastOccurance = CurTime()

    -- Block message if to big
    if len >= 500 then
        print("\nNet message to big. Stopping - HTA\n")

        return
    end

    -- Receive selected player
    local selPlayer = net.ReadEntity()
    -- Receive amount to transfer
    local amount = net.ReadUInt(32)

    -- Blocking values of 0 or lower, due to security concerns.
    if amount <= 0 then
        print(sendingPlayer:Nick() .. " Tried sending a value of 0 or lower - HTA")

        return
    end

    -- Handle transaction
    -- Check if sending player can afford transfer amount
    if sendingPlayer:canAfford(amount) == false then
        net.Start("hta_cantafford")
        net.Send(sendingPlayer)

        return
    end

    sendingPlayer:addMoney(-amount)
    selPlayer:addMoney(amount)
    -- Letting Sending Player know that the transfer was successful
    net.Start("hta_send_success")
    net.WriteUInt(amount, 32)
    net.Send(sendingPlayer)
    -- Letting receiving player know that the transfer was successful
    net.Start("hta_received")
    net.WriteUInt(amount, 32)
    net.WriteEntity(sendingPlayer)
    net.Send(selPlayer)
end)

-- Receive transfer request
net.Receive("hta_request", function(len, reqPlayer)
    local timeElapsed = CurTime() - lastOccurance

    if timeElapsed < delay then
        net.Start("hta_waitcooldown")
        net.Send(reqPlayer)

        return
    end

    lastOccurance = CurTime()

    -- Block message if to big
    if len >= 500 then
        print("\nNet message to big. Stopping - HTA\n")

        return
    end

    -- Player who is getting the request
    local targetPlayer = net.ReadEntity()

    if not targetPlayer or not targetPlayer:IsPlayer() then
        net.Start("hta_request_invalid")
        net.WriteString("The Player you choosen is either vanished or is disconnected")
        net.Send(reqPlayer)
    end

    -- Amount being requested
    local requestAmount = net.ReadUInt(32)

    if checkIfUserRequestedIt(reqPlayer:SteamID(), targetPlayer:SteamID64()) then
        net.Start("hta_request_invalid")
        net.WriteString("You already requested Money from him! Please wait!")
        net.Send(reqPlayer)
    end

    if targetPlayer:canAfford(requestAmount) == false then
        net.Start("hta_reqcantafford")
        net.Send(reqPlayer)

        return
    end

    local request = {
        requestId = generateId(),
        requester = reqPlayer:SteamID(),
        amount = requestAmount,
        from = targetPlayer:SteamID()
    }

    -- Adding Request Object
    table.insert(TRANSFER, request)
    -- Letting requesting player know that the request was received
    net.Start("hta_request_received")
    net.WriteEntity(targetPlayer)
    net.Send(reqPlayer)
    -- Letting target player know there is a new request
    net.Start("hta_receiving_request")
    -- Sending the amount requested
    net.WriteUInt(requestAmount, 32)
    -- Sending the key for identification
    net.WriteString(request.requestId)
    -- Sending who sent the request
    net.WriteEntity(reqPlayer)
    net.Send(targetPlayer)
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

    if fromPly:canAfford(amount) == false then
        net.Start("hta_cantafford")
        net.Send(fromPly)

        return
    end

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

    table.remove(TRANSFER, request)
    -- Letting Requester know that the request was declined
    net.Start("hta_request_declined")
    net.WriteUInt(request.amount, 32)
    net.WriteString(request.requestId)
    net.WriteEntity(fromPly)
    net.Send(reqPly)
end

-- timer.Create("netcooldown", 1, 1, receiveRequestSend)
-- TODO: ADD TRANSFER REASON?
hook.Add("PlayerSay", "hedgeChatServerCommands", function(ply, txt, tc)
    if string.StartsWith(txt, "/acceptrequest ") then
        local id = string.sub(txt, 16)
        local _, request = getTransferById(id)

        if not request then
            ply:ChatPrint("HTA: Your Id you provided is invalid!")

            return false
        end

        HandleRequest(request)
    elseif string.StartsWith(txt, "/declinerequest ") then
        local id = string.sub(txt, 16)
        local _, request = getTransferById(id)

        if not request then
            ply:ChatPrint("HTA: Your Id you provided is invalid!")

            return false
        end

        HandleDecline(request)
    end
end)