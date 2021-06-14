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
SWEP.Category       = "Tools"
SWEP.Contact        = "Steam"
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

-- For after when the first area point is set
FINOS_DevationDecimalsAnglesAlign = 2
FINOS_AllowedDevationAnglesAlign = 0.05

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

if SERVER then

    net.Receive( "FINOS_UpdateWindSettings_SERVER", function( len, pl )

        local Entity = net.ReadEntity()

        if not Entity or ( Entity and not Entity:IsValid() ) then

            FINOS_AlertPlayer( "**[WIND] Entity is unvalid!", pl )
            FINOS_SendNotification( "[WIND] Entity is unvalid!", FIN_OS_NOTIFY_ERROR, pl, 3 )

            return nil

        elseif Entity:IsWorld() then

            FINOS_AlertPlayer( "**[WIND] Aim on an Entity to update Wind Settings", pl )
            FINOS_SendNotification( "[WIND] Aim on an Entity to update Wind Settings", FIN_OS_NOTIFY_ERROR, pl, 3 )

            return nil

        elseif not Entity:GetNWBool( "fin_os_active" ) then

            FINOS_AlertPlayer( "**[WIND] This Entity is not an active FIN OS fin!", pl )
            FINOS_SendNotification( "[WIND] This Entity is not an active FIN OS fin!", FIN_OS_NOTIFY_ERROR, pl, 3 )

            return nil

        end

        if Entity:GetNWBool( "fin_os_active" ) and Entity:GetNWEntity( "fin_os_currentOwner" ) ~= pl then --[[ Only allow the owner of fin to adjust wind! ]]

            FINOS_AlertPlayer( "**[WIND] You are not the owner of this fin!", pl )
            FINOS_SendNotification( "[WIND] You are not the owner of this fin!", FIN_OS_NOTIFY_ERROR, pl, 3 )

            pl:EmitSound( "fin_os/error.wav", 41, 100 )

            return nil

        end

        local EnableWind                = GetConVar( "finos_cl_wind_enableWind" ):GetInt()
        local ForcePerSquareMeterArea   = GetConVar( "finos_cl_wind_forcePerSquareMeterArea" ):GetFloat()
        local MinWindScale              = GetConVar( "finos_cl_wind_minWindScale" ):GetFloat()
        local MaxWindScale              = GetConVar( "finos_cl_wind_maxWindScale" ):GetFloat()

        local ActivateWildWind          = GetConVar( "finos_cl_wind_activateWildWind" ):GetInt()
        local MinWildWindScale          = GetConVar( "finos_cl_wind_minWildWindScale" ):GetFloat()
        local MaxWildWindScale          = GetConVar( "finos_cl_wind_maxWildWindScale" ):GetFloat()

        local ActivateThermalWind       = GetConVar( "finos_cl_wind_activateThermalWind" ):GetInt()
        local MaxThermalLiftWindScale   = GetConVar( "finos_cl_wind_maxThermalLiftWindScale" ):GetFloat()

        -- Check/Adjust to allowed settings ( from SERVER )
        local MaxForcePerSquareMeterAreaAllowed     = GetConVar( "finos_wind_maxForcePerSquareMeterAreaAllowed" ):GetFloat()
        local MinWindScaleAllowed                   = GetConVar( "finos_wind_minWindScaleAllowed" ):GetFloat()
        local MaxWindScaleAllowed                   = GetConVar( "finos_wind_maxWindScaleAllowed" ):GetFloat()
        local MinWildWindScaleAllowed               = GetConVar( "finos_wind_minWildWindScaleAllowed" ):GetFloat()
        local MaxWildWindScaleAllowed               = GetConVar( "finos_wind_maxWildWindScaleAllowed" ):GetFloat()
        local MaxActivateThermalWindScaleAllowed    = GetConVar( "finos_wind_maxActivateThermalWindScaleAllowed" ):GetFloat()

        local function r( id, value, limitValue, compare )

            FINOS_AlertPlayer( "**[WIND] The " .. string.upper( id ) .. " SETTING was overwritten to: " .. math.Round( limitValue, 2 ) .. "! Because: " .. math.Round( value, 2 ) .. " " .. compare .. " " .. math.Round( limitValue, 2 ) .. ". Can be adjusted/disabled by admin.", pl )
            FINOS_SendNotification( "[WIND] The " .. string.upper( id ) .. " SETTING was overwritten to: " .. math.Round( limitValue, 2 ) .. "! Because: " .. math.Round( value, 2 ) .. " " .. compare .. " " .. math.Round( limitValue, 2 ) .. ". Can be adjusted/disabled by admin", FIN_OS_NOTIFY_ERROR, pl, 6 )

            if pl and ( pl:IsAdmin() or pl:IsSuperAdmin() ) then FINOS_SendNotification( "You can disable all wind limits with ConVar: finos_wind_disableAllServerLimits", FIN_OS_NOTIFY_HINT, pl, 7.5 ) end

        end

        if GetConVar( "finos_wind_disableAllServerLimits" ):GetInt() == 0 then

            -- Prevent Player setting invalid settings ( let server decide the min/max amount )
            if math.abs( ForcePerSquareMeterArea ) > math.abs( MaxForcePerSquareMeterAreaAllowed ) then r( "Wind Force [Max]", ForcePerSquareMeterArea, MaxForcePerSquareMeterAreaAllowed, ">" ) ForcePerSquareMeterArea = MaxForcePerSquareMeterAreaAllowed end

            if math.abs( MinWindScale ) < math.abs( MinWindScaleAllowed ) then r( "Wind [Min]", MinWindScale, MinWindScaleAllowed, "<" ) MinWindScale = MinWindScaleAllowed end
            if math.abs( MaxWindScale ) > math.abs( MaxWindScaleAllowed ) then r( "Wind [Max]", MaxWindScale, MaxWindScaleAllowed, ">" ) MaxWindScale = MaxWindScaleAllowed end

            if math.abs( MinWildWindScale ) < math.abs( MinWildWindScaleAllowed ) then r( "Wild [Min]", MinWildWindScale, MinWildWindScaleAllowed, "<" ) MinWildWindScale = MinWildWindScaleAllowed end
            if math.abs( MaxWildWindScale ) > math.abs( MaxWildWindScaleAllowed ) then r( "Wild [Max]", MaxWildWindScale, MaxWildWindScaleAllowed, ">" ) MaxWildWindScale = MaxWildWindScaleAllowed end

            if math.abs( MaxThermalLiftWindScale ) > math.abs( MaxActivateThermalWindScaleAllowed ) then r( "Thermal [Max]", MaxThermalLiftWindScale, MaxActivateThermalWindScaleAllowed, ">" ) MaxThermalLiftWindScale = MaxActivateThermalWindScaleAllowed end

        end

        -- Apply to Entity ( store )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntWindProperties", {

            EnableWind                  = EnableWind,
            ForcePerSquareMeterArea     = ForcePerSquareMeterArea,
            MinWindScale                = MinWindScale,
            MaxWindScale                = MaxWindScale,

            ActivateWildWind            = ActivateWildWind,
            MinWildWindScale            = MinWildWindScale,
            MaxWildWindScale            = MaxWildWindScale,

            ActivateThermalWind         = ActivateThermalWind,
            MaxThermalLiftWindScale     = MaxThermalLiftWindScale

        }, nil, "ID1_Wind", true )

        -- Store for duplication
        FINOS_WriteDuplicatorDataForEntity( Entity )

        FINOS_AlertPlayer( "**[WIND] Applied NEW Wind settings for fin!", pl )
        FINOS_SendNotification( "[WIND] Applied NEW Wind settings for fin!", FIN_OS_NOTIFY_GENERIC, pl, 4 )

        pl:EmitSound( "garrysmod/save_load3.wav", 70, 110 )

    end )

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
