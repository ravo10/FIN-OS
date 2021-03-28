-- ///////////////////////////////////////////////////////////////////////////////
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- ///////////////////////////////////////////////////////////////////////////////
SWEP.PrintName      = "FIN OS Tool"
SWEP.Author         = "ravo (Norway)"
SWEP.Category       = "ravo Norway"
SWEP.Contact        = "N/A"
SWEP.Purpose        = "Produce a FIN (prop-physics)"
SWEP.Instructions   = [[
Left-Click to APPLY
Reload to REMOVE
]]

SWEP.ViewModel  = "models/weapons/v_fin_os_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"

SWEP.ShowViewModel  = true
SWEP.ShowWorldModel = false

SWEP.DrawCrosshair  = true
SWEP.DrawAmmo       = false

SWEP.HoldType = "pistol"

SWEP.ViewModelFOV   = 84.221105527638
SWEP.ViewModelFlip  = false

SWEP.Slot               = 5 -- From 0 - 5
SWEP.SlotPos            = 1 -- From 0 - 128
SWEP.BounceWeaponIcon   = true

SWEP.UseHands   = false
SWEP.Spawnable  = true

SWEP.Weight         = 1
SWEP.AutoSwitchTo   = false
SWEP.AutoSwitchFrom = false

SWEP.Tool = {}

SWEP.ShootSound = Sound( "Airboat.FireGunRevDown" )

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.CanHolster = true
SWEP.CanDeploy  = true

SWEP.ShouldDropOnDie = false

-- Very important
SWEP.IronSightsPos = Vector( 0, 0, 0 )
SWEP.IronSightsAng = Vector( 0, 0, 0 )

cleanup.Register( "fin_os" )

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

-- Data manipulation
local function WriteFinOSTableData( ent, entTableID, _table ) -- This is getting called SERVER and CLIENT side

    -- Maybe reset the table
    if not _table then

        ent[ "FinOS_data" ][ entTableID ] = nil

        return

    end

    if not ent[ "FinOS_data" ] then ent[ "FinOS_data" ] = {} end
    if not ent[ "FinOS_data" ][ entTableID ] then ent[ "FinOS_data" ][ entTableID ] = {} end

    -- Overwrite on SERVER and CLIENT side
    table.Merge( ent[ "FinOS_data" ][ entTableID ], _table )

end

if CLIENT then

    net.Receive( "FINOS_UpdateEntityTableValue_CLIENT", function()

        local data = net.ReadTable()

        -- Overwrite table
        local ent = data[ "ent" ]
        local entTableID = data[ "entTableID" ]
        local _table = data[ "_table" ]

        WriteFinOSTableData( ent, entTableID, _table )

    end )

end

function FINOS_AddDataToEntFinTable( ent, entTableID, _table )

    if SERVER then

        if not ent:IsValid() then return print( "FINOS_AddDataToEntFinTable: 'ent' is not valid. ID: 'entTableID'" ) end

        WriteFinOSTableData( ent, entTableID, _table )

        net.Start("FINOS_UpdateEntityTableValue_CLIENT")
            net.WriteTable({

                ent = ent,
                entTableID = entTableID,
                _table = _table

            })
        net.Broadcast()

    end

end
function FINOS_GetDataToEntFinTable( ent, entTableID )
    if not ent:IsValid() then return print( "FINOS_GetDataToEntFinTable: 'ent' is not valid. ID: 'entTableID'" ) end

    if ent[ "FinOS_data" ] and ent[ "FinOS_data" ][ entTableID ] then

        return ent[ "FinOS_data" ][ entTableID ]

    else

        return {}

    end

end
