function ivgPoints.playerNotify(ply, msg)
    if (SERVER) then
        net.Start("ivgPoints.message")
            net.WriteString(msg)
        net.Send(ply)
    else
        msg = ply
        chat.AddText(ivgPoints.notifyPrefixColor, ivgPoints.notifyPrefix .. " ", color_white, msg)
    end
end

if (CLIENT) then
    net.Receive("ivgPoints.message", function()
        ivgPoints.playerNotify(net.ReadString())
    end)
end