AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

AddCSLuaFile( "hooks/cl_hooks.lua" )
include( "hooks/cl_hooks.lua" )

include( "cl_viewscreen.lua" )

-- ///////////////////////////////////////////////////////////////////////////////
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- ///////////////////////////////////////////////////////////////////////////////

SWEP.WepSelectIcon = surface.GetTextureID( "vgui/fin_os/fin_os_tool" )
SWEP.ToolNameHeight = 0
SWEP.Gradient = surface.GetTextureID( "gui/gradient" )
SWEP.InfoIcon = surface.GetTextureID( "gui/info" )
SWEP.LastMessage = 0

language.Add( "Undone_fin_os_brain", "Undone a FIN OS" )
language.Add( "Cleanup_fin_os_brain", "FIN OS" )
language.Add( "Cleaned_fin_os_brain", "Cleaned up all FIN OS'" )

net.Receive( "FINOS_SendLegacyNotification_CLIENT", function()

    local data = net.ReadTable()

    local string = data[ "string" ]
    local type = data[ "type" ]
    local lifeSeconds = data[ "lifeSeconds" ]

    -- Send notification
    notification.AddLegacy( string, type, lifeSeconds )

end )

function SWEP:DrawHUD() return true end
