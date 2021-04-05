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

SWEP.ShouldDropOnDie = true

-- Very important
SWEP.IronSightsPos = Vector( 0, 0, 0 )
SWEP.IronSightsAng = Vector( 0, 0, 0 )

cleanup.Register( "fin_os" )

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

function SWEP:SetupDataTables()

    self:NetworkVar( "Entity", 0, "TempFlapRelatedEntity0" )
    self:NetworkVar( "Entity", 1, "TempFlapRelatedEntity1" )

    self:NetworkVar( "Bool", 0, "DisableTool" )
    
    -- First time setup
    if SERVER then

        self:SetTempFlapRelatedEntity0( nil )
        self:SetTempFlapRelatedEntity1( nil )

        self:SetDisableTool( false )

    end

end

-- Data manipulation
-- This is getting called SERVER and CLIENT side
local function WriteFinOSTableData( ent, entTableID, _table, insertTableDontMerge, overwriteCurrentTable )

    -- Maybe reset the table
    if not _table then

        if ent[ "FinOS_data" ] then ent[ "FinOS_data" ][ entTableID ] = nil end return

    end

    if not ent[ "FinOS_data" ] then ent[ "FinOS_data" ] = {} end

    if not ent[ "FinOS_data" ][ entTableID ] then ent[ "FinOS_data" ][ entTableID ] = {} end

    -- Overwrite
    if overwriteCurrentTable then

        ent[ "FinOS_data" ][ entTableID ] = _table

    else

        if insertTableDontMerge then

            -- Insert table into table on SERVER side
            table.insert( ent[ "FinOS_data" ][ entTableID ], _table )

        else

            -- Overwrite values on SERVER and CLIENT side
            for k, v in pairs( _table ) do ent[ "FinOS_data" ][ entTableID ][ k ] = v end

        end

    end

end

if CLIENT then

    net.Receive( "FINOS_UpdateEntityTableValue_CLIENT", function()

        local data = net.ReadTable()

        -- Overwrite table
        local ent = data[ "ent" ]
        local entTableID = data[ "entTableID" ]
        local _table = data[ "_table" ]
        local insertTableDontMerge = data[ "insertTableDontMerge" ]
        local overwriteCurrentTable = data[ "overwriteCurrentTable" ]

        WriteFinOSTableData( ent, entTableID, _table, insertTableDontMerge, overwriteCurrentTable )

    end )

end

function FINOS_GetACopyOfATable( _table )

    local newTable = {}

    for k, v in pairs( _table ) do

        newTable[ k ] = v

    end

    return newTable

end
function FINOS_RemoveOneIndexFromTable( _table )

    local newTable = {}

    for k, v in pairs( _table ) do

        -- Don't include the last one
        if k < #_table then

            newTable[ k ] = v

        end

    end

    return newTable

end

function FINOS_AddDataToEntFinTable( ent, entTableID, _table, Player, ID, overwriteCurrentTable )

    if SERVER then

        if not ent and not ent:IsValid() then print( "FINOS_AddDataToEntFinTable: 'ent' is not valid. entTableID: " .. entTableID .. ". ID: " .. ID ) return end

        WriteFinOSTableData( ent, entTableID, _table, false, overwriteCurrentTable )

        net.Start("FINOS_UpdateEntityTableValue_CLIENT")

            net.WriteTable({

                ent = ent,
                entTableID = entTableID,
                _table = _table,
                insertTableDontMerge = false,
                overwriteCurrentTable = overwriteCurrentTable or false

            })

        if Player and Player:IsValid() then net.Send( Player ) else net.Broadcast() end

    end

end
function FINOS_InsertDataToEntFinTable( ent, entTableID, _table, Player, ID, overwriteCurrentTable )

    if SERVER then

        if not ent and not ent:IsValid() then print( "FINOS_InsertDataToEntFinTable: 'ent' is not valid. entTableID: " .. entTableID.. ". ID: " .. ID ) return end

        WriteFinOSTableData( ent, entTableID, _table, true )

        net.Start("FINOS_UpdateEntityTableValue_CLIENT")

            net.WriteTable({

                ent = ent,
                entTableID = entTableID,
                _table = _table,
                insertTableDontMerge = true,
                overwriteCurrentTable = overwriteCurrentTable or false

            })

        if Player and Player:IsValid() then net.Send( Player ) else net.Broadcast() end

    end

end
function FINOS_GetDataToEntFinTable( ent, entTableID, ID )

    if not ent and not ent:IsValid() then print( "FINOS_GetDataToEntFinTable: 'ent' is not valid. entTableID: " .. entTableID.. ". ID: " .. ID ) return end

    if ent[ "FinOS_data" ] and ent[ "FinOS_data" ][ entTableID ] then

        return ent[ "FinOS_data" ][ entTableID ]

    else

        return {}

    end

end
