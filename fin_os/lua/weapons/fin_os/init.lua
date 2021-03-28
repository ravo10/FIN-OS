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

AddCSLuaFile( "hooks/cl_hooks.lua" )

AddCSLuaFile( "primary_attack.lua" )
AddCSLuaFile( "secondary_attack.lua" )
AddCSLuaFile( "reload.lua" )

-- ///////////////////////////////////////////////////////////////////////////////
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- ///////////////////////////////////////////////////////////////////////////////
FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE = 10

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Initialize() end

function SWEP:ShouldDropOnDie() return true end

CreateConVar( "sbox_maxfin_os", 2 )

hook.Add( "Initialize", "fin_os:Initialize", function()

    -- Add Network Strings
    util.AddNetworkString("FINOS_UpdateEntityTableValue_CLIENT")
    util.AddNetworkString("FINOS_UpdateEntityScalarLiftForceValue_CLIENT")

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
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaPoints", Data[ "AREAPOINTSTABLE" ] )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaVectors", Data[ "AREAVECTORSTABLE" ] )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAngleProperties", Data[ "ANGLEPROPERTIESTABLE" ] )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", Data[ "PHYSICSPROPERTIESSTABLE" ] )

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

        local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPoints" )
        --[[ IDs:
            vCPLFin_Area_Units
            vCPLFin_Area_Foot
            vCPLFin_Area_Meter
            pointsUsed
         ]]
        local AREAVECTORSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaVectors" )
        --[[ Array:
            Vector(x, y, z), Vector(x, y, z), Vector(x, y, z) ...
         ]]
        local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAngleProperties" )
        --[[ IDs:
            Main_Fin_BaseAngle
            Main_Fin_AttackAngle_Pitch
            Main_Fin_AttackAngle_RollCosinus
            Flap_Fin_BaseAngle
         ]]
        local PHYSICSPROPERTIESSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties" )
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
	self.Owner:SetAnimation( PLAYER_ATTACK1 ) -- 3rd Person Animation

	if ( not bFirstTimePredicted ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetNormal( hitnormal )
	effectdata:SetEntity( entity )
	effectdata:SetAttachment( physbone )
	util.Effect( "selection_indicator", effectdata )

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetStart( self.Owner:GetShootPos() )
	effectdata:SetAttachment( 1 )
	effectdata:SetEntity( self )
	util.Effect( "ToolTracer", effectdata )

end

function SWEP:SetAreaPointsForFin( tr )

    local ENT = tr.Entity

    -- Get old area points if any
    local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAreaPoints" )
    local amountOfPointsUsed = #AREAPOINTSTABLE

    -- If you got 26, then cancel
    if amountOfPointsUsed == 26 then self:AlertPlayer( "Max points is 26!" ) return true else

        -- Get some data
        local localHitPos = ENT:WorldToLocal( tr.HitPos )

        -- Store some data
        table.insert( AREAPOINTSTABLE, localHitPos )
        FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaPoints", AREAPOINTSTABLE )
        amountOfPointsUsed = #AREAPOINTSTABLE

        local alfabethTable = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" };
        self:AlertPlayer( "Added local area point: "..alfabethTable[ amountOfPointsUsed ].."("..math.Round( localHitPos[1] )..", "..math.Round( localHitPos[2] )..", "..math.Round( localHitPos[3] )..")" )

    end

end
function SWEP:CalculateAreaForFinBasedOnAreaPoints( ent, owner )

    -- Get area points if any
    local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( ent, "fin_os__EntAreaPoints" )
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
        } )

        local currentEntAngle = ent:GetAngles()

        FINOS_AddDataToEntFinTable( ent, "fin_os__EntAngleProperties", {
            Main_Fin_BaseAngle = currentEntAngle
        } )

        self:AlertPlayer( "Current area between vectors: "..self:GetAreaForFin( ent )[ "vCPLFin_Area_Meter" ].." m²" )
        self:AlertPlayer( "Current base angle (P, Y, R) set to: ("..math.Round( currentEntAngle[ 1 ] )..", "..math.Round( currentEntAngle[ 2 ] )..", "..math.Round( currentEntAngle[ 3 ] )..")" )

    end

end
function SWEP:GetAreaForFin( ent )

    return FINOS_GetDataToEntFinTable( ent, "fin_os__EntAreaVectors" )

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

hook.Add( "SetupMove", "mbd:SetupMove001", function( pl, mv, cmd )

    if mv:KeyDown( IN_USE ) then

        local mouseWheelScrollDelta = cmd:GetMouseWheel()

        -- Change the slowdown effect up or down
        if mouseWheelScrollDelta ~= 0 then

            local ENT = pl:GetEyeTrace().Entity

            if ENT and ENT:IsValid() and ENT:GetNWBool( "fin_os_active" ) and pl:GetActiveWeapon():GetClass() == "fin_os" then

                local scalarValue = ENT[ "FinOS_LiftForceScalarValue" ]
                if not scalarValue then ENT[ "FinOS_LiftForceScalarValue" ] = FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE end

                local newScalarValue = scalarValue

                if mouseWheelScrollDelta > 0 then newScalarValue = newScalarValue + 1 else newScalarValue = newScalarValue - 1 end
                if newScalarValue < 1 then newScalarValue = 1 elseif newScalarValue > 396 then newScalarValue = 396 end

                -- Store new scalar value
                ENT[ "FinOS_LiftForceScalarValue" ] = newScalarValue

                -- Send to client
                net.Start( "FINOS_UpdateEntityScalarLiftForceValue_CLIENT" )

                    net.WriteTable({

                        ent = ENT,
                        FinOS_LiftForceScalarValue = newScalarValue

                    })
                
                net.Broadcast()

            end

        end

    end

end )

include( "primary_attack.lua" )
include( "secondary_attack.lua" )
include( "reload.lua" )
