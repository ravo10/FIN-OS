-- ///////////////////////////////////////////////////////////////////////////////
-- DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD
-- DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD
-- DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD DOWNLOAD
-- ///////////////////////////////////////////////////////////////////////////////

AddCSLuaFile()

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_viewscreen.lua" )

AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

AddCSLuaFile( "hooks/hooks.lua" )
include("hooks/hooks.lua")
AddCSLuaFile( "hooks/cl_hooks.lua" )

AddCSLuaFile( "primary_attack.lua" )
AddCSLuaFile( "secondary_attack.lua" )
AddCSLuaFile( "reload.lua" )

-- ///////////////////////////////////////////////////////////////////////////////
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- ///////////////////////////////////////////////////////////////////////////////

CreateConVar(
    "finos_rhodensistyfluidvalue",
    1.29,
    FCVAR_PROTECTED,
    "Mass density (rho) that will be applied to Fin OS fin."
)
CreateConVar(
    "finos_maxscalarvalue",
    69,
    FCVAR_PROTECTED,
    "Maximum scalar value a player can apply to a Fin OS fin."
)

FIN_OS_NOTIFY_GENERIC = 0
FIN_OS_NOTIFY_ERROR = 1
FIN_OS_NOTIFY_UNDO = 2
FIN_OS_NOTIFY_HINT = 3
FIN_OS_NOTIFY_CLEANUP = 4

FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE = 1

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Initialize() end

function SWEP:OnDrop()
    
    self:SetTempFlapRelatedEntity0( nil )
    self:SetTempFlapRelatedEntity1( nil )

end
function SWEP:Holster( Weapon )
    
    self:SetTempFlapRelatedEntity0( nil )
    self:SetTempFlapRelatedEntity1( nil )

    return true

end

CreateConVar( "sbox_maxfin_os", 20 )

hook.Add( "Initialize", "fin_os:Initialize", function()

    -- Add Network Strings
    util.AddNetworkString("FINOS_UpdateEntityTableValue_CLIENT")
    util.AddNetworkString("FINOS_UpdateEntityScalarLiftForceValue_CLIENT")
    util.AddNetworkString("FINOS_SendLegacyNotification_CLIENT")

end )

-- ///////////////////////////////////////////////////////////////////////////////
-- FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS
-- FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS
-- FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS
-- ///////////////////////////////////////////////////////////////////////////////

-- Duplicator settings
if SERVER then

    duplicator.RegisterEntityModifier( "FinOS", function( Player, Entity, Data )

        -- Write duplicator settings for entity
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaPoints", Data[ "AREAPOINTSTABLE" ], nil, "ID4" )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaVectors", Data[ "AREAVECTORSTABLE" ], nil, "ID5" )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAngleProperties", Data[ "ANGLEPROPERTIESTABLE" ], nil, "ID6" )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", Data[ "PHYSICSPROPERTIESSTABLE" ], nil, "ID7" )

        local DUPLICATEDENTITY = Data[ "DUPLICATEDENTITY" ]

        if DUPLICATEDENTITY and DUPLICATEDENTITY:IsValid() then

            Entity[ "FinOS_LiftForceScalarValue" ] = DUPLICATEDENTITY[ "FinOS_LiftForceScalarValue" ]

            -- Send to client
            net.Start( "FINOS_UpdateEntityScalarLiftForceValue_CLIENT" )

                net.WriteTable({

                    ent = Entity,
                    FinOS_LiftForceScalarValue = DUPLICATEDENTITY[ "FinOS_LiftForceScalarValue" ]

                })
            
            net.Broadcast()

        end

        -- Add the brain
        FINOS_AddFinWingEntity( Entity, Player, true )
    
    end )

    function FINOS_UpdateDuplicatorDataForEntity( Entity ) -- The new entity will have this data

        local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPoints", "ID3" )
        --[[ IDs:
            vCPLFin_Area_Units
            vCPLFin_Area_Foot
            vCPLFin_Area_Meter
            pointsUsed
         ]]
        local AREAVECTORSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaVectors", "ID4" )
        --[[ Array:
            Vector(x, y, z), Vector(x, y, z), Vector(x, y, z) ...
         ]]
        local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAngleProperties", "ID5" )
        --[[ IDs:
            BaseAngle
            AttackAngle_Pitch
            AttackAngle_RollCosinus
         ]]
        local PHYSICSPROPERTIESSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", "ID6" )
        --[[ IDs:
            VelocityKmH
            LiftForceNewtonsModified_beingUsed
            LiftForceNewtonsNotModified
            AreaMeterSquared
         ]]

        -- Create a new table to store in duplicator settings for the entity
        local Data = {

            DUPLICATEDENTITY = Entity,
            AREAPOINTSTABLE = AREAPOINTSTABLE,
            AREAVECTORSTABLE = AREAVECTORSTABLE,
            ANGLEPROPERTIESTABLE = ANGLEPROPERTIESTABLE,
            PHYSICSPROPERTIESSTABLE = PHYSICSPROPERTIESSTABLE

        }

        duplicator.StoreEntityModifier( Entity, "FinOS", Data )

    end

end

-- Functions only important for SWEP tool
function SWEP:GetTrace()

    local OWNER = self:GetOwner()

    local tr = util.GetPlayerTrace( OWNER )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX ) -- https://wiki.facepunch.com/gmod/Enums/CONTENTS
    local trace = util.TraceLine( tr )
    
    return trace

end
function SWEP:DoShootEffect( hitpos, hitnormal, entity, physbone, bFirstTimePredicted )

	self:EmitSound( self.ShootSound )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) -- View model animation

	-- There's a bug with the model that's causing a muzzle to
	-- appear on everyone's screen when we fire this animation.
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 ) -- 3rd Person Animation

	if ( not bFirstTimePredicted ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetNormal( hitnormal )
	effectdata:SetEntity( entity )
	effectdata:SetAttachment( physbone )
	util.Effect( "selection_indicator", effectdata )

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetStart( self:GetOwner():GetShootPos() )
	effectdata:SetAttachment( 1 )
	effectdata:SetEntity( self )
	util.Effect( "ToolTracer", effectdata )

end

function SWEP:SetAreaPointsForFin( tr )

    local ENT = tr.Entity

    -- Get old area points if any
    local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAreaPoints", "ID7" )
    local amountOfPointsUsed = #AREAPOINTSTABLE

    -- If you got 26, then cancel
    if amountOfPointsUsed == 26 then self:AlertPlayer( "Max points is 26!" ) return true else

        -- Get some data
        local localHitPos = ENT:WorldToLocal( tr.HitPos )

        -- Store some data
        table.insert( AREAPOINTSTABLE, localHitPos )
        FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaPoints", AREAPOINTSTABLE, nil,"ID8" )
        amountOfPointsUsed = #AREAPOINTSTABLE

        local alfabethTable = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" };
        self:AlertPlayer( "Added local area point: " .. alfabethTable[ amountOfPointsUsed ] .. "(" .. math.Round( localHitPos[1] ) .. ", " .. math.Round( localHitPos[2] ) .. ", " .. math.Round( localHitPos[3] ) .. ")" )

        if amountOfPointsUsed == 1 then
            
            self:AlertPlayer( "*Add two or more points.." )
            FINOS_SendNotification( "Add two or more points..", FIN_OS_NOTIFY_GENERIC, OWNER, 1.3 )
        
        end
    end

end
function SWEP:CalculateAreaForFinBasedOnAreaPoints( ent, owner )

    -- Get area points if any
    local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( ent, "fin_os__EntAreaPoints", "ID8" )
    local amountOfPointsUsed = #AREAPOINTSTABLE

    -- Calculate area
    -- 1 foot = 12 units = 0.3048 meter
    -- units / 12 = foot => foot * 0.3048 = meters
    -- vCPL = VectorCrossProductLength
    if amountOfPointsUsed > 2 then
        local triangleLengthAreaTable = { }

        local combinedLength_Area_Units = 0
        local combinedLength_Area_Foot = 0
        local combinedLength_Area_Meter = 0

        -- Calculate area ( split everything up into triangles )
        for k, _ in pairs( AREAPOINTSTABLE ) do
            if k >= 3 then

                -- Triangle
                local newVector1 = FINOS_CreateVectorFromTwoPoints( AREAPOINTSTABLE[ 1 ], AREAPOINTSTABLE[ k - 1 ] )
                local newVector2 = FINOS_CreateVectorFromTwoPoints( AREAPOINTSTABLE[ 1 ], AREAPOINTSTABLE[ k ] )

                combinedLength_Area_Units = combinedLength_Area_Units + 0.5 * FINOS_VectorCrossProduct( newVector1, newVector2 )

            end
        end

        combinedLength_Area_Foot = ( combinedLength_Area_Units / ( 12 * 12 ) )
        combinedLength_Area_Meter = ( combinedLength_Area_Foot * ( 0.3048 * 0.3048 ) )

        -- Overwrite and store
        FINOS_AddDataToEntFinTable( ent, "fin_os__EntAreaVectors", {
            vCPLFin_Area_Units = math.Round( combinedLength_Area_Units, 2 ),
            vCPLFin_Area_Foot = math.Round( combinedLength_Area_Foot, 2 ),
            vCPLFin_Area_Meter = math.Round( combinedLength_Area_Meter, 2 ),
            pointsUsed = amountOfPointsUsed
        }, nil, "ID9" )

        local currentEntAngle = ent:GetAngles()

        FINOS_AddDataToEntFinTable( ent, "fin_os__EntAngleProperties", {

            BaseAngle = currentEntAngle

        }, nil, "ID10" )

        self:AlertPlayer( "Current area between vectors: " .. self:GetAreaForFin( ent )[ "vCPLFin_Area_Meter" ] .. " m²" )
        self:AlertPlayer( "Current base angle (P, Y, R) set to: (" .. math.Round( currentEntAngle[ 1 ] ) .. ", " .. math.Round( currentEntAngle[ 2 ] ) .. ", " .. math.Round( currentEntAngle[ 3 ] ) .. ")" )
        FINOS_SendNotification( "Fin configured! Area is " .. self:GetAreaForFin( ent )[ "vCPLFin_Area_Meter" ] .. " m²", FIN_OS_NOTIFY_HINT, OWNER, 3.5 )

    end

end
function SWEP:GetAreaForFin( ent )

    return FINOS_GetDataToEntFinTable( ent, "fin_os__EntAreaVectors", "ID9" )

end

function SWEP:AlertPlayer( string )

    self:GetOwner():PrintMessage( HUD_PRINTTALK, string )

end

-- Vector calculation
function FINOS_CreateVectorFromTwoPoints( pointA, pointB, round )

    local aX = pointA[ 1 ]
    local aY = pointA[ 2 ]
    local aZ = pointA[ 3 ]
    local bX = pointB[ 1 ]
    local bY = pointB[ 2 ]
    local bZ = pointB[ 3 ]

    local newX = bX - aX
    local newY = bY - aY
    local newZ = bZ - aZ

    if round then
        newX = math.Round( newX )
        newY = math.Round( newY )
        newZ = math.Round( newZ )
    end

    return Vector( newX, newY, newZ )

end
function FINOS_VectorDotProduct( vectorA, vectorB )

    local aX = vectorA[ 1 ]
    local aY = vectorA[ 2 ]
    local aZ = vectorA[ 3 ]
    local bX = vectorB[ 1 ]
    local bY = vectorB[ 2 ]
    local bZ = vectorB[ 3 ]

    return ( ( aX * bX ) + ( aY * bY ) + ( aZ * bZ ) )

end
function FINOS_VectorAngleBetweenTwoVectorsRadians( vectorA, vectorB )

    local cosFraction = ( FINOS_VectorDotProduct( vectorA, vectorB ) ) / ( vectorA:Length() * vectorB:Length() )

    return math.acos( cosFraction )

end
function FINOS_VectorCrossProduct( vectorA, vectorB, round )

    local aX = vectorA[ 1 ]
    local aY = vectorA[ 2 ]
    local aZ = vectorA[ 3 ]
    local bX = vectorB[ 1 ]
    local bY = vectorB[ 2 ]
    local bZ = vectorB[ 3 ]

    local vectorProduct = Vector( ( aY * bZ - bY * aZ ), ( bX * aZ - aX * bZ ), ( aX * bY - bX * aY ) )
    -- This also equals the area of a parallello/rhombus
    local vectorLength = vectorProduct:Length()

    if round then return math.Round( vectorLength ) else return vectorLength end

end

-- Notify
function FINOS_SendNotification( string, type, player, lifeSeconds )

    if not lifeSeconds or lifeSeconds <= 0 then lifeSeconds = 2 end

    net.Start( "FINOS_SendLegacyNotification_CLIENT" )

        net.WriteTable({

            string = string,
            type = type,
            lifeSeconds = lifeSeconds

        })

    if player then net.Send( player ) else net.Broadcast() end

end

-- For calculating attack angles on air
function FINOS_CalculateAttackAnglesDegreesFor_CL( ent )

    if not ent:IsValid() then return nil end

	local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( ent, "fin_os__EntAngleProperties", "ID10" )

	local ENT_MAIN_BASE_ANGLES = ANGLEPROPERTIESTABLE[ "BaseAngle" ]
	local CURRENT_ENT_ANGLES = ent:GetAngles()

    if not ANGLEPROPERTIESTABLE[ "BaseAngle" ] then return nil end

	local CURRENT_MAIN_ANGLES_OF_ATTACK = Angle(
		( CURRENT_ENT_ANGLES[ 1 ] - ENT_MAIN_BASE_ANGLES[ 1 ] ),
		( CURRENT_ENT_ANGLES[ 2 ] - ENT_MAIN_BASE_ANGLES[ 2 ] ),
		( CURRENT_ENT_ANGLES[ 3 ] - ENT_MAIN_BASE_ANGLES[ 3 ] )
	)

	local CURRENT_ANGLE_OF_ATTACK_PITCH = CURRENT_MAIN_ANGLES_OF_ATTACK[ 1 ]
	local CURRENT_ANGLE_OF_ATTACK_ROLL = CURRENT_MAIN_ANGLES_OF_ATTACK[ 3 ]
	local CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS = math.Round( math.cos( math.rad(CURRENT_ANGLE_OF_ATTACK_ROLL) ) )

	-- Being used
	local CURRENT_ATTACK_ANGLE = ( CURRENT_ANGLE_OF_ATTACK_PITCH * CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS )
	CURRENT_MAIN_ANGLES_OF_ATTACK = ( CURRENT_MAIN_ANGLES_OF_ATTACK * CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS )

	return {

		CURRENT_ATTACK_ANGLE = CURRENT_ATTACK_ANGLE,
		CURRENT_MAIN_ANGLES_OF_ATTACK = CURRENT_MAIN_ANGLES_OF_ATTACK,
		CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS = CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS,

	}

end
function FINOS_CalculateLiftForce( ent, AttackAnglesDegreesTable, RhoMassDensity, VelocityMetersPerSecond, AreaMeter, Scalar )

    if not AttackAnglesDegreesTable or not RhoMassDensity or not VelocityMetersPerSecond or not AreaMeter or not Scalar then

        print( "FINOS_CalculateLiftForce Error: One or more parameter is nil" ) return nil

    end

    -- ** Calculate Force[LIFT]. Uses formula ( This formula is used in real world applications aswell ): ** --
    -- F_lift[N] = .5 * rho_air[kg/m^3] * Velocity[m/s]^2 * Area[m^2] * C_lift[Angle of attack on air (WING AND FLAP combined)]
    -- https://wright.nasa.gov/airplane/lifteq.html

    -- Angles ( C[Lift] )
    local CURRENT_ATTACK_ANGLE_DEGREES_PRE = AttackAnglesDegreesTable[ "CURRENT_ATTACK_ANGLE" ]
    local CURRENT_ATTACK_ANGLE_DEGREES_COSINUS = math.cos( math.rad( CURRENT_ATTACK_ANGLE_DEGREES_PRE ) )
    -- When the angle becomes 0 (stall), then we still want to give some type of lift [ FIN ]
    local CURRENT_ATTACK_ANGLE_DEGREES = math.deg( math.acos( math.sin( CURRENT_ATTACK_ANGLE_DEGREES_COSINUS ) ) )
    local CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS = AttackAnglesDegreesTable[ "CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS" ]

    local CURRENT_MAIN_ANGLES_OF_ATTACK = AttackAnglesDegreesTable[ "CURRENT_MAIN_ANGLES_OF_ATTACK" ]

    -- ** The LIFT Force [ Coefficient ] **
    local CURRENT_CL = 2 * math.pi * math.rad( CURRENT_ATTACK_ANGLE_DEGREES )

    -- ** The LIFT Force **
    local CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE = ( 0.5 * RhoMassDensity * math.pow( VelocityMetersPerSecond, 2 ) * AreaMeter )
    local CURRENT_LIFT_FORCE_IN_NEWTONS = ( CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE * CURRENT_CL )

    -- ** The LIFT Force used IN-GAME **
    local FLAP_LIFT_FORCE_NEWTON = 0
    if ent:GetNWBool( "fin_os_is_a_fin_flap" ) then

        -- Want to directly affect lift positivly or negativly with the attack angle of the flap ( use the preset angle ) [ FLAP ]
        local NEW_CURRENT_CL = 2 * math.pi * math.rad( CURRENT_ATTACK_ANGLE_DEGREES_PRE )
        FLAP_LIFT_FORCE_NEWTON = ( 0.5 * RhoMassDensity * math.pow( VelocityMetersPerSecond, 2 ) * AreaMeter * NEW_CURRENT_CL )

        CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED = ( FLAP_LIFT_FORCE_NEWTON * Scalar )

    else

        CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED = ( CURRENT_LIFT_FORCE_IN_NEWTONS * Scalar )

    end

    return {

        CURRENT_LIFT_FORCE_IN_NEWTONS = CURRENT_LIFT_FORCE_IN_NEWTONS,
        CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED = CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED,
        CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE = CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE

    }

end

-- Fin's Wings Brain ( final step )
function FINOS_AddFinWingEntity( ent, owner, duplication )

    -- Remove any (if) current fin wing from entity
    local prevFinOSBrain = ent:GetNWEntity( "fin_os_brain" )
    if prevFinOSBrain and prevFinOSBrain:IsValid() then prevFinOSBrain:Remove() end

    -- Make a fin wing
    local entFin = ents.Create( "fin_os_brain" )

    entFin:SetPos( ent:LocalToWorld( ent:OBBCenter() ) ) -- Endre til midten av arealet vektor ??
    entFin:SetAngles( ent:LocalToWorldAngles( ent:GetAngles() ) )

    entFin:SetName( "fin_os_finWingBrain" )
    entFin:SetParent( ent )
    entFin:SetOwner( owner )
    entFin:SetCreator( owner )

    if not duplication then

        ent[ "FinOS_LiftForceScalarValue" ] = FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE

        net.Start( "FINOS_UpdateEntityScalarLiftForceValue_CLIENT" )
            
            net.WriteTable({

                ent = ent,
                FinOS_LiftForceScalarValue = FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE

            })
        
        net.Broadcast()

    end

    -- Spawn
    entFin:Spawn()
    entFin:Activate()

    ent:SetNWEntity( "fin_os_brain", entFin )

    FINOS_UpdateDuplicatorDataForEntity( ent )

    owner:AddCount( "fin_os", ent )
    owner:AddCleanup( "fin_os", ent )

    ent:SetNWBool( "fin_os_active", true )

end

-- ///////////////////////////////////////////////////////////////////////////////
-- ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
-- ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
-- ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
-- ///////////////////////////////////////////////////////////////////////////////

include( "primary_attack.lua" )
include( "secondary_attack.lua" )
include( "reload.lua" )
