-- name of the folder that will hold the player's data
ivgPoints.dataFolder = "ivgpoints"

-- prefix used for the chat command
ivgPoints.chatCommandPrefix = "!"

-- admin ranks that will be able to access the menu
ivgPoints.adminCommandAccess = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["moderator"] = true,
}

-- steam ids that will be able to access the menu
ivgPoints.steamIDAdminAccess = {
    ["STEAM_0:1:51795447"] = true,
}

-- notification prefix when points are given / taken
ivgPoints.notifyPrefix = "[IVG Points]"

-- notification prefix color
ivgPoints.notifyPrefixColor = Color(110,197,117)

-- ui colors
ivgPoints.color = {
    white           = Color(255, 255, 255),
    black           = Color(0, 0, 0),
    close           = Color(127,23,52),
    title           = Color(96, 64, 136),
    background      = Color(129, 84, 177),
    admin           = Color(185, 110, 39),
    grip            = Color(39, 185, 88),
}