AddCSLuaFile("autorun/sh_hedgetransfer_config.lua")

net.Receive("hta_receiving_request", function(len, ply)
    -- Receive amount player requested
    amountRequested = net.ReadUInt(32)
    requestId = net.ReadString()
    print(amountRequested)
    -- Receive player who sent request
    sendingPlayer = net.ReadEntity()
    print(sendingPlayer)
    chat.AddText("\n" .. sendingPlayer:Nick() .. " Has Requested " .. amountRequested .. "$,\nTo deny it type \"/declinerequest " .. requestId .. "\"\nTo accept type \"/acceptrequest " .. requestId .. "\"")
end)