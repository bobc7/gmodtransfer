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

-- Receive transfer send

-- Cooldown stuff

local delay = 10 local lastOccurance = -delay

net.Receive("hta_send", function (len, sendingPlayer)

    local timeElapsed = CurTime() - lastOccurance

    if (timeElapsed < delay) then

        net.Start("hta_waitcooldown")

        net.Send(sendingPlayer)

    return end

    lastOccurance = CurTime()

    -- Block message if to big

    if (len >= 500) then

        print("\nNet message to big. Stopping - HTA\n")

    return end

    -- Receive selected player

    local selPlayer = net.ReadEntity()

    -- Receive amount to transfer

    local amount = net.ReadUInt(32)

    -- Blocking values of 0 or lower, due to security concerns.

    if (amount <= 0) then

        print(sendingPlayer:Nick() .. " Tried sending a value of 0 or lower - HTA")
        return
    end

    -- Handle transaction

    -- Check if sending player can afford transfer amount

    if (sendingPlayer:canAfford(amount) == false) then

        net.Start("hta_cantafford")

        net.Send(sendingPlayer)
    return end

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

net.Receive("hta_request", function (len, reqPlayer)

    local timeElapsed = CurTime() - lastOccurance

    if (timeElapsed < delay) then

        net.Start("hta_waitcooldown")

        net.Send(reqPlayer)
    return end

    lastOccurance = CurTime()

        -- Block message if to big

        if (len >= 500) then
            print("\nNet message to big. Stopping - HTA\n")
        return end

    -- Player who is getting the request

    local targetPlayer = net.ReadEntity()

    -- Amount being requested

    local requestAmount = net.ReadUInt(32)

    if (targetPlayer:canAfford(requestAmount) == false) then

        net.Start("hta_reqcantafford")

        net.Send(reqPlayer)
    return end

    -- Letting requesting player know that the request was received

    net.Start("hta_request_received")

    net.WriteEntity(targetPlayer)

    net.Send(reqPlayer)


    local function receiveRequestSend()


            -- Letting target player know there is a new request

        net.Start("hta_receiving_request")

            -- Sending the amount requested

        net.WriteUInt(requestAmount, 32)

            -- Sending who sent the request

        net.WriteEntity(reqPlayer)

        net.Send(targetPlayer)
    end
    receiveRequestSend()

    -- timer.Create("netcooldown", 1, 1, receiveRequestSend)

end)
-- TODO: ADD TRANSFER REASON?