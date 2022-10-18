AddCSLuaFile("autorun/sh_hedgetransfer_config.lua")

net.Receive("hta_receiving_request", function (len, ply)

    -- Receive amount player requested
    amountRequested = net.ReadUInt(32)
    print(amountRequested)

    -- Receive player who sent request
    sendingPlayer = net.ReadEntity()
    print(sendingPlayer)

    chat.AddText("\n"..sendingPlayer:Nick().." Has Requested "..amountRequested.."$,\nIf you wish to deny the request just ignore it!\nTo accept type /acceptrequest (name)\n")

end)