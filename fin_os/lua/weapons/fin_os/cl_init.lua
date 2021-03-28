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

language.Add( "Undone_fin_os", "Undone a FIN OS" )
language.Add( "Cleanup_fin_os", "Fin OS" )
language.Add( "Cleaned_fin_os", "Cleaned up all FIN OS'" )
language.Add( "sboxlimit_fin_os", "You've reached the FIN OS limit!" )

net.Receive( "FINOS_UpdateEntityScalarLiftForceValue_CLIENT", function()

    local data = net.ReadTable()

    local ent = data[ "ent" ]
    local FinOS_LiftForceScalarValue = data[ "FinOS_LiftForceScalarValue" ]

    -- Overwrite value
    ent[ "FinOS_LiftForceScalarValue" ] = FinOS_LiftForceScalarValue

end )

-- Disable scrolling when player is changing the scalar for Lift Force
local function DisabledScrollingMenuClient( pl, key, disable )

    local ENT = pl:GetEyeTrace().Entity

    if key == IN_USE and ENT and ENT:IsValid() and ENT:GetNWBool( "fin_os_active" ) and pl:GetActiveWeapon():GetClass() == "fin_os" then

        -- Update
        LocalPlayer():SetNWBool( "PlayerIsLookingAtFinAndChangingScalarValue", disable )

    end

end

hook.Add( "KeyPress", "mbd:KeyPress", function( pl, key ) DisabledScrollingMenuClient( pl, key, true ) end )
hook.Add( "KeyRelease", "mbd:KeyRelease", function( pl, key ) DisabledScrollingMenuClient( pl, key, false ) end )

function SWEP:DrawHUD()

    return true

end
