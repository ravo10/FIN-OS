-- ///////////////////////////////////////////////////////////////////////////////
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- ///////////////////////////////////////////////////////////////////////////////
sound.Add( {
	name = "FinOS.ToolFire",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 66,
	pitch = { 220, 223 },
	sound = "fin_os/fin_os_toolgun_shoot.wav"
} )

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

SWEP.ShootSound = Sound( "FinOS.ToolFire" )

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

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

util.PrecacheSound("fin_os/error.wav")
util.PrecacheSound("fin_os/fin_os_button10.wav")

cleanup.Register( "fin_os_brain" )

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

-- Functions only important for SWEP tool
function SWEP:DoShootEffect( hitpos, hitnormal, entity, physbone, bFirstTimePredicted )

    local IsNotSinglePlayerAndServer = not game.SinglePlayer() and SERVER
    local IsSinglePlayer = game.SinglePlayer()

	self:EmitSound( self.ShootSound )
	if IsNotSinglePlayerAndServer or IsSinglePlayer then self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) end -- View model animation

	-- There's a bug with the model that's causing a muzzle to
	-- appear on everyone's screen when we fire this animation.
	if IsNotSinglePlayerAndServer or IsSinglePlayer then self:GetOwner():SetAnimation( PLAYER_ATTACK1 ) end -- 3rd Person Animation

	if ( not bFirstTimePredicted ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetNormal( hitnormal )
	effectdata:SetEntity( entity )
	effectdata:SetAttachment( physbone )
	util.Effect( "finos_selection_indicator", effectdata )

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetStart( self:GetOwner():GetShootPos() )
	effectdata:SetAttachment( 1 )
	effectdata:SetEntity( self )
	util.Effect( "finos_tooltracer", effectdata )

    if IsNotSinglePlayerAndServer then

        -- Send to client
        net.Start( "FINOS_SendEffect_CLIENT" )

            net.WriteTable( {

                self = self,
                parameters = { hitpos, hitnormal, entity, physbone, bFirstTimePredicted }

            } )

        net.Send( self:GetOwner() )

    end

end

if CLIENT then

    net.Receive( "FINOS_SendEffect_CLIENT", function()

        local data = net.ReadTable()

        local self = data[ "self" ]
        local parameters = data[ "parameters" ]

        self:DoShootEffect( parameters[ 1 ], parameters[ 2 ], parameters[ 3 ], parameters[ 4 ], parameters[ 5 ] )

    end )

end

-- Data manipulation
-- This is getting called SERVER and CLIENT side
local function IsEntValid( ent ) return ent and ent:IsValid() end
local function WriteFinOSTableData( ent, entTableID, _table, insertTableDontMerge, overwriteCurrentTable )

    -- Maybe reset the table
    if not _table then

        if IsEntValid( ent ) and ent[ "FinOS_data" ] then ent[ "FinOS_data" ][ entTableID ] = nil end return

    end

    if IsEntValid( ent ) and not ent[ "FinOS_data" ] then ent[ "FinOS_data" ] = {} end

    if IsEntValid( ent ) and not ent[ "FinOS_data" ][ entTableID ] then ent[ "FinOS_data" ][ entTableID ] = {} end

    -- Overwrite
    if IsEntValid( ent ) and overwriteCurrentTable then

        ent[ "FinOS_data" ][ entTableID ] = _table

    else

        if IsEntValid( ent ) and insertTableDontMerge then

            -- Insert table into table on SERVER side
            table.insert( ent[ "FinOS_data" ][ entTableID ], _table )

        else

            -- Overwrite values on SERVER and CLIENT side
            for k, v in pairs( _table ) do if IsEntValid( ent ) then ent[ "FinOS_data" ][ entTableID ][ k ] = v end end

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

hook.Add( "EntityEmitSound", "TimeWarpSounds", function( soundDataTable )

    local IsClipEmptySound = soundDataTable[ "OriginalSoundName" ] == "Weapon_Pistol.Empty"

    if CLIENT and LocalPlayer() then
        
        local playerActiveWeapon = LocalPlayer():GetActiveWeapon()

        if playerActiveWeapon and playerActiveWeapon:IsValid() and playerActiveWeapon:GetClass() == "fin_os" and IsClipEmptySound then

            -- Don't allow
            return false

        end
        
    end
	
end )