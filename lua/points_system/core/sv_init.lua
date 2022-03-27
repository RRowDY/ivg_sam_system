resource.AddFile("materials/ivgpoints/adminicon.png")
resource.AddFile("materials/ivgpoints/backbutton.png")
local IVG = ivgPoints
local directory = IVG.dataFolder

hook.Add("PlayerInitialSpawn", "playerData", function(ply)
    local dataLoad = ivgPoints.loadData(ply)

    if not dataLoad then
        ply.samData = {}
        ply.samData.studs = 0
        ply.samData.merits = 0
    else
        ply.samData = dataLoad
    end
end)

if not file.Exists(directory, "DATA") then
    file.CreateDir(directory)
end

util.AddNetworkString("ivgPoints.message")
util.AddNetworkString("ivgPoints.admin")
util.AddNetworkString("ivgPoints.browse")
util.AddNetworkString("ivgPoints.send")
util.AddNetworkString("ivgPoints.sendStuds")
util.AddNetworkString("ivgPoints.sendMerits")

function ivgPoints.saveData(ply)
    file.Write(directory .. "/" .. ply:SteamID64() .. ".txt", util.TableToJSON(ply.samData))
end

function ivgPoints.loadData(ply)
    local plyFile = directory .. "/" .. ply:SteamID64() .. ".txt"
    if not file.Exists(plyFile, "DATA") then return end
    local fileData = file.Read(plyFile)
    if not fileData then return end

    return util.JSONToTable(fileData)
end

function ivgPoints.setStuds(ply, studAmount)
    if (not IsValid(ply)) then return end
    ply.samData.studs = studAmount
    ivgPoints.saveData(ply)
end

function ivgPoints.setMerits(ply, meritAmount)
    if (not IsValid(ply)) then return end
    ply.samData.merits = meritAmount
    ivgPoints.saveData(ply)
end

IVG.Commands = {
    setstuds = {
        callBack = function(ply, args)
            -- Player Object
            local target = args[2]
            local studAmount = args[3]
            if (studAmount == nil) then
               return
            end
            ivgPoints.setStuds(target, studAmount)
            IVG.playerNotify(ply, "You have set " .. ply:Name() .. "'s studs to " .. studAmount .. ".")
        end,
        validateArgs = function(ply, args)
            local studAmount = args[3]

            if (studAmount == nil or not studAmount) then
                IVG.playerNotify(ply, "No stud amount specified")

                return false
            end
        end,
    },
    setmerits = {
        callBack = function(ply, args)
            -- Player Object
            local target = args[2]
            local meritAmount = args[3]
            if (meritAmount == nil) then
                return
             end
            ivgPoints.setMerits(target, meritAmount)
            IVG.playerNotify(ply, "You have set " .. ply:Name() .. "'s merits to " .. meritAmount .. ".")
        end,
        validateArgs = function(ply, args)
            local meritAmount = args[3]

            if (meritAmount == nil) then
                IVG.playerNotify(ply, "No merit amount specified")

                return false
            end
        end,
    },
    givestuds = {
        callBack = function(ply, args)
            -- Player Object
            local target = args[2]
            local studAmount = args[3]
            if (studAmount == nil) then
                return
             end
            ivgPoints.setStuds(target, ply.samData.studs + studAmount)
            IVG.playerNotify(ply, "You have given " .. ply:Name() .. " " .. studAmount .. " studs.")
        end,
        validateArgs = function(ply, args)
            local studAmount = args[3]

            if (studAmount == nil) then
                IVG.playerNotify(ply, "No stud amount specified")

                return false
            end
        end,
    },
    givemerits = {
        callBack = function(ply, args)
            -- Player Object
            local target = args[2]
            local meritAmount = args[3]
            if (meritAmount == nil) then
                return
             end
            ivgPoints.setMerits(target, ply.samData.merits + meritAmount)
            IVG.playerNotify(ply, "You have given " .. ply:Name() .. " " .. meritAmount .. " merits.")
        end,
        validateArgs = function(ply, args)
            local meritAmount = args[3]

            if (meritAmount == nil) then
                IVG.playerNotify(ply, "No merit amount specified")

                return false
            end
        end,
    },
    browseplayer = {
        callBack = function(ply, args)
            net.Start("ivgPoints.browse")
                net.WriteEntity(args[2])
                net.WriteTable(args[2].samData)
            net.Send(ply)

            return ""
        end
    },
    adminmenu = {
        callBack = function(ply, args)
            net.Start("ivgPoints.admin")
                net.WriteEntity(args[2])
            net.Send(ply)

            return ""
        end,
        noargs = true,
    },
}

hook.Add("PlayerSay", "HandleSamCommands", function(ply, text, team)
    if (not string.StartWith(text, IVG.chatCommandPrefix)) then return end
    local args = string.Explode(" ", text)
    local command = string.TrimLeft(args[1], IVG.chatCommandPrefix)
    -- strip the command of the prefix.
    local commandData = IVG.Commands[command]
    if (not commandData) then return end

    if (not IVG.adminCommandAccess[ply:GetUserGroup()] and not IVG.steamIDAdminAccess[ply:SteamID()]) then
        IVG.playerNotify(ply, "No access!")

        return ""
    end

    if not commandData.noargs then
        local target = args[2]

        if (target == nil) then
            IVG.playerNotify(ply, "Enter Target")

            return ""
        end

        target = target:lower()
        local found = false
        for k, v in ipairs(player.GetAll()) do
            if (string.find(v:Name():lower(), target) or v:SteamID() == target or v:SteamID64() == target) then
                target = v
                found = true
                break
            end
        end

        args[2] = target

        if (not found) then
            IVG.playerNotify(ply, "No target found")

            return ""
        end

        local isValidArgs = commandData.validateArgs and commandData.validateArgs(ply, args) or true
        if (isValidArgs == false) then return "" end
    end

    commandData.callBack(ply, args)

    return ""
end)

net.Receive("ivgPoints.send", function()
    target = net.ReadEntity()
    validator = net.ReadString()
    value = net.ReadString()
    if not target then return end
    if validator == "Studs" then
        ivgPoints.setStuds(target, value)
    elseif validator == "Merits" then
        ivgPoints.setMerits(target,value)
    else
        return
    end
end)
