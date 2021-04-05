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

-- CONSOLE VARIABLES
CreateConVar( "sbox_maxfin_os", 20 )

CreateConVar(

    "finos_rhodensistyfluidvalue",
    1.29,
    FCVAR_PROTECTED,
    "Mass density ( rho ) that will be applied to Fin OS fin."

)
CreateConVar(

    "finos_maxscalarvalue",
    69,
    FCVAR_PROTECTED,
    "Maximum scalar value a player can apply to a Fin OS fin."

)
CreateConVar(

    "finos_disablestrictmode",
    0,
    FCVAR_PROTECTED,
    "0: Enables strict mode\n1: Disables checking for angle of prop and crossing vector lines, if you just want to f*uck around ( other servers might not accept the duplicate tho )"

)
CreateConVar(

    "finos_disableprintchatmessages",
    1,
    FCVAR_PROTECTED,
    "Disables printing messages in chat ( only legacy )"

)

-- Global variables
if SERVER then

    FIN_OS_NOTIFY_GENERIC = 0
    FIN_OS_NOTIFY_ERROR = 1
    FIN_OS_NOTIFY_UNDO = 2
    FIN_OS_NOTIFY_HINT = 3
    FIN_OS_NOTIFY_CLEANUP = 4

    FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE = 1

    -- Increase this if a big duplication change is added
    FINOS_DUPLICATIONSSETTING_VERSION_CONTROL = 1

end

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:OnDrop()

    self:SetTempFlapRelatedEntity0( nil )
    self:SetTempFlapRelatedEntity1( nil )
    self:SetDisableTool( false )

    timer.Remove( "fin_os__EntAreaPointCrossingLinesTIMER000" .. self:EntIndex() )
    timer.Remove( "fin_os__EntAreaPointCrossingLinesTIMER001" .. self:EntIndex() )

end
function SWEP:Holster( Weapon )

    self:SetTempFlapRelatedEntity0( nil )
    self:SetTempFlapRelatedEntity1( nil )
    self:SetDisableTool( false )

    timer.Remove( "fin_os__EntAreaPointCrossingLinesTIMER000" .. self:EntIndex() )
    timer.Remove( "fin_os__EntAreaPointCrossingLinesTIMER001" .. self:EntIndex() )

    return true

end

hook.Add( "Initialize", "fin_os:Initialize", function()

    -- Add Network Strings
    util.AddNetworkString("FINOS_UpdateEntityTableValue_CLIENT")
    util.AddNetworkString("FINOS_SendLegacyNotification_CLIENT")

end )

-- ///////////////////////////////////////////////////////////////////////////////
-- FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS
-- FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS
-- FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS
-- ///////////////////////////////////////////////////////////////////////////////

-- Duplicator registration
if SERVER then

    duplicator.RegisterEntityModifier( "FinOS", function( Player, Entity, Data )

        local errorMessage1
        local errorMessage2

        if (

            Data[ "FINOS_DUPLICATIONSSETTING_VERSION_CONTROL" ] == FINOS_DUPLICATIONSSETTING_VERSION_CONTROL and
            Data[ "AREAPOINTSTABLE" ] and Data[ "AREAVECTORSTABLE" ] and Data[ "AREAACCEOTEDANGLEANDHITNORMALTABLE" ] and
            Data[ "ANGLEPROPERTIESTABLE" ] and Data[ "PHYSICSPROPERTIESSTABLE" ]

        ) then

            -- Apply the angle ( important )
            Entity:SetAngles( Data[ "ANGLEPROPERTIESTABLE" ][ "BaseAngle" ] )

            -- Write duplicator settings for entity
            -- **Don't need to add AREAPOINTSTABLE, AREAVECTORSTABLE, AREAVECTORSLINESPARAMETERTABLE and AREAPOINTCROSSINGLINESTABLE, since
            -- they will be calculated and added underneath virtually

            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaAcceptedAngleAndHitNormal", Data[ "AREAACCEOTEDANGLEANDHITNORMALTABLE" ], nil, "ID12", true )
            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAngleProperties", Data[ "ANGLEPROPERTIESTABLE" ], nil, "ID6", true )
            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", Data[ "PHYSICSPROPERTIESSTABLE" ], nil, "ID7", true )

            -- Check if valid fin ( no crossing lines )
            local AREAPOINTSTABLE = Data[ "AREAPOINTSTABLE" ]
            local AREAPOINTSTABLELength = #AREAPOINTSTABLE

            local anyVectorLinesCrossingOrAngleHitNormalNotOK = false

            for k, v in pairs( AREAPOINTSTABLE ) do

                -- Virutally add points and check if any lines are crossing
                if not anyVectorLinesCrossingOrAngleHitNormalNotOK then

                    anyVectorLinesCrossingOrAngleHitNormalNotOK = FINOS_SetAreaPointsForFin( {

                        Entity = Entity,
                        HitNormal = Data[ "AREAACCEOTEDANGLEANDHITNORMALTABLE" ][ "firstPointSet_HitNormal" ],
                        HitPos = Entity:LocalToWorld( v )

                    }, Player )

                    if GetConVar( "finos_disablestrictmode" ):GetInt() == 1 then anyVectorLinesCrossingOrAngleHitNormalNotOK = false end

                end

                if k == AREAPOINTSTABLELength then

                    if not anyVectorLinesCrossingOrAngleHitNormalNotOK then

                        FINOS_CalculateAreaForFinBasedOnAreaPoints( Entity, Player, false, false )

                        if GetConVar( "finos_disablestrictmode" ):GetInt() == 1 then

                            FINOS_AlertPlayer( "All points from Fin OS fin duplication was validated ( strict mode disabled )", Player )
                            FINOS_SendNotification( "All points from Fin OS duplication was validated ( strict mode disabled )", FIN_OS_NOTIFY_GENERIC, Player, 3.4 )

                        else

                            FINOS_AlertPlayer( "All points from Fin OS fin duplication was validated ( strict mode ) ", Player )
                            FINOS_SendNotification( "All points from Fin OS duplication was validated ( strict mode ) ", FIN_OS_NOTIFY_GENERIC, Player, 3.4 )

                        end

                    else

                        -- Tell the player how big the current "prev" area is
                        FINOS_CalculateAreaForFinBasedOnAreaPoints( Entity, Player, false, true )

                        FINOS_AlertPlayer( "One or more point from Fin OS fin was not validated ( crossings ) from duplication (this server has strict settings on). Maybe you need to redefine your area", Player )
                        FINOS_SendNotification( "One or more point was not validated from Fin OS duplication", FIN_OS_NOTIFY_ERROR, Player, 4 )

                    end

                    -- Check if trace hitPoint is witin area
                    local IsWitinArea = FINOS_CheckIfLastPointIsWithingAreaOfTriangle( Entity, Player, AREAPOINTSTABLE )

                    if IsWitinArea and #AREAPOINTSTABLE > 2 then FINOS_AddFinWingEntity( Entity, Player, true ) end

                end

            end

        else

            -- Error, tell the Plater that the fin was not added ( he has to add it again )
            errorMessage1 = "**An error occured while adding the Fin OS fin (maybe old version applied before). You'll have to re-apply a new fin manually again"
            errorMessage2 = "An error occured while adding the Fin OS fin. You'll have to apply a new fin"

        end

        if errorMessage1 then FINOS_AlertPlayer( errorMessage1, Player) end
        if errorMessage2 then FINOS_SendNotification( errorMessage2, FIN_OS_NOTIFY_ERROR, Player, 7 ) end

    end )

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

-- New point set
function FINOS_SaveNewPointFromSWEP( Entity, areaPointsTable, lastVectorPointFromSWEP, ID )

    -- For debugging
    -- print( "FINOS_SaveNewPointFromSWEP:", ID )

    -- Insert
    table.insert( areaPointsTable, lastVectorPointFromSWEP )
    FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaPoints", areaPointsTable, nil, "ID8" )

end
function FINOS_CheckIfTheLastTwoVectorLinesAreCrossing( Entity, areaPointsTable, lastVectorPointFromSWEP, player, self )

    -- **ALL POINTS are in it local form relative to the entity, until it gets handled by the crossing points calculator

    local OWNER
    local WEAPON

    if player and player:IsValid() then
        
        OWNER = player
        WEAPON = OWNER:GetActiveWeapon()

    end

    local areaPointsTableLength = #areaPointsTable
    local penultimatePointVector = areaPointsTable[ areaPointsTableLength ]

    -- First time: Create a line between the first a
    if areaPointsTableLength == 1 then

        local firstVectorLineParams = FINOS_GiveVectorLineParameters(

            penultimatePointVector,
            FINOS_CreateVectorFromTwoPoints( penultimatePointVector, lastVectorPointFromSWEP )

        )
        -- Line is not crossing, so store it for later use/check
        FINOS_InsertDataToEntFinTable( Entity, "fin_os__EntAreaVectorLinesParameter", {

            equation1 = { x = firstVectorLineParams.equation1[ "x" ], a = firstVectorLineParams.equation1[ "a" ] },
            equation2 = { y = firstVectorLineParams.equation2[ "y" ], b = firstVectorLineParams.equation2[ "b" ] },
            equation3 = { z = firstVectorLineParams.equation3[ "z" ], c = firstVectorLineParams.equation3[ "c" ] }

        }, nil, "ID0" )

    end

    if areaPointsTableLength >= 1 then

        -- Create a parameter of current ( last two points )
        local newVectorLineParams = FINOS_GiveVectorLineParameters(

            lastVectorPointFromSWEP,
            FINOS_CreateVectorFromTwoPoints( penultimatePointVector, lastVectorPointFromSWEP )

        )

        -- All parameteres of old vector lines, used to calculate any crossing points later on, on these
        -- lines from the penultimate point to the new point from HitPos
        local allParamsOfVectorLines = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaVectorLinesParameter", "ID1" )
        local allParamsOfVectorLinesLength = #allParamsOfVectorLines

        if allParamsOfVectorLinesLength >= 1 then

            -- Add crossings, if it should be e.g. displayed visually
            local actualCrossingLinesResultsTable = FINOS_GatherValidCrossingLines(

                allParamsOfVectorLines,
                newVectorLineParams,
                areaPointsTable

            )
            local actualCrossingLinesResultsTableLength = #actualCrossingLinesResultsTable

            -- Everything OK
            -- Line is not crossing any old ones, so store its parameters for later point checking
            if actualCrossingLinesResultsTableLength == 0 then

                FINOS_InsertDataToEntFinTable( Entity, "fin_os__EntAreaVectorLinesParameter", {

                    equation1 = { x = newVectorLineParams.equation1[ "x" ], a = newVectorLineParams.equation1[ "a" ] },
                    equation2 = { y = newVectorLineParams.equation2[ "y" ], b = newVectorLineParams.equation2[ "b" ] },
                    equation3 = { z = newVectorLineParams.equation3[ "z" ], c = newVectorLineParams.equation3[ "c" ] }

                }, nil, "ID1" )

            elseif GetConVar( "finos_disablestrictmode" ):GetInt() ~= 1 then
                -- Just important if we have strict mode ON

                -- An error: New new line created from the last point from SWEP is crossing another one =>
                -- Store for display CLIENT
                FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaPointCrossingLines", { calculationResults = actualCrossingLinesResultsTable }, nil, "ID1" )

                -- If the function is run from the SWEP
                if self and self:IsValid() then
                    
                    self:SetDisableTool( true )

                    -- Tell the player
                    FINOS_SendNotification( "Unvalid next-point (crossing)!", FIN_OS_NOTIFY_ERROR, OWNER, 3.7 )
                    self:EmitSound( "fin_os/error.wav", 130, 100 )

                end

                local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPoints", "ID18" )

                -- Store some data
                FINOS_SaveNewPointFromSWEP( Entity, AREAPOINTSTABLE, lastVectorPointFromSWEP, "ID2" )

                -- Go back in time
                timer.Create( "fin_os__EntAreaPointCrossingLinesTIMER001" .. self:EntIndex(), 0.5, 1, function()

                    -- Remove crossing line -- Save ( overwrite )
                    table.remove( AREAPOINTSTABLE, #AREAPOINTSTABLE )
                    FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaPoints", AREAPOINTSTABLE, nil, "ID9", true )

                    -- Clear
                    FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaPointCrossingLines", nil )

                    -- Tell player how much we got
                    FINOS_CalculateAreaForFinBasedOnAreaPoints( Entity, OWNER, true )

                    if self and self:IsValid() then timer.Simple( 0.2, function () self:SetDisableTool( false ) end ) end

                end )

                return true

            end

        end

    end

    return false

end
function FINOS_SetAreaPointsForFin( tr, player, self )

    local Entity = tr.Entity
    local OWNER if player and player:IsValid() then OWNER = player end

    -- Get old area points if any
    local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPoints", "ID7" )
    local amountOfPointsUsed = #AREAPOINTSTABLE

    -- How accurate
    local decimals = 0

    local entityAngles = Entity:GetAngles()
    local entityHitNormal = tr.HitNormal

    local isEAndShiftUsedToRotate = math.Round( math.abs( ( entityAngles[ 1 ] + entityAngles[ 2 ] + entityAngles[ 3 ] ) ), 1 ) % 1 <= 0.15

    -- Just important if we have strict mode ON
    if GetConVar( "finos_disablestrictmode" ):GetInt() ~= 1 and not isEAndShiftUsedToRotate and self then

        -- Kiss and tell
        if OWNER and OWNER:IsValid() then

            FINOS_AlertPlayer( [[*Rotate prop with "E" + "Shift" to make fin happy (´°ω°`)]], OWNER )
            FINOS_SendNotification( [[Rotate prop with "E" + "Shift" to make fin happy (´°ω°`)]], FIN_OS_NOTIFY_ERROR, OWNER, 3 )

        end

        return true

    end

    local entityAnglesRounded = Angle( math.Round( entityAngles[ 1 ], decimals ), math.Round( entityAngles[ 2 ], decimals ), math.Round( entityAngles[ 3 ], decimals ) )
    local entityHitNormalRounded = Vector( math.Round( entityHitNormal[ 1 ], decimals ), math.Round( entityHitNormal[ 2 ], decimals ), math.Round( entityHitNormal[ 3 ], decimals ) )

    -- ** Når du treffer overflate, berre aksepter videre: avrundar lokale HitNormal + lokale avrunda vinkelen til (tre desimaler) prop
    if amountOfPointsUsed == 0 then

        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaAcceptedAngleAndHitNormal", {

            firstPointSet_Angles = entityAnglesRounded,
            firstPointSet_HitNormal = entityHitNormalRounded
    
        }, nil,"ID10" )

    end

    -- Just important if we have strict mode ON
    -- Check if point is going to be accepted
    local acceptedAngleAndHitNormal = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaAcceptedAngleAndHitNormal","ID18" )
    if (

        GetConVar( "finos_disablestrictmode" ):GetInt() ~= 1 and (

            entityAnglesRounded ~= acceptedAngleAndHitNormal[ "firstPointSet_Angles" ] or
            entityHitNormalRounded ~= acceptedAngleAndHitNormal[ "firstPointSet_HitNormal" ]
        ) and self

    ) then

        -- --Tell player
        if entityAnglesRounded ~= acceptedAngleAndHitNormal[ "firstPointSet_Angles" ] then

            FINOS_AlertPlayer( "*Align fin to the correct start angle!", OWNER )
            FINOS_SendNotification( "Align fin to the correct start angle!", FIN_OS_NOTIFY_ERROR, OWNER, 3 )
    
        elseif entityHitNormalRounded ~= acceptedAngleAndHitNormal[ "firstPointSet_HitNormal" ] then
    
            FINOS_AlertPlayer( "*You can only apply new points on one side of the Fin OS fin!", OWNER )
            FINOS_SendNotification( "You can only apply new points on one side of the fin!", FIN_OS_NOTIFY_ERROR, OWNER, 3 )
    
        end

        return true

    end

    -- If you got 26, then cancel
    if amountOfPointsUsed == 26 then FINOS_AlertPlayer( "Max points is 26!", OWNER ) return false else

        -- Get some data
        local localHitPos = Entity:WorldToLocal( tr.HitPos )

         -- Check if any vector lines are crossing eachother before continuing
        local anyVectorLinesCrossing = FINOS_CheckIfTheLastTwoVectorLinesAreCrossing( Entity, AREAPOINTSTABLE, localHitPos, OWNER, self )

        if GetConVar( "finos_disablestrictmode" ):GetInt() == 1 or not anyVectorLinesCrossing then

            -- Store some data
            FINOS_SaveNewPointFromSWEP( Entity, AREAPOINTSTABLE, localHitPos, "ID1" )

        end

        if GetConVar( "finos_disablestrictmode" ):GetInt() == 1 then anyVectorLinesCrossing = false end

       return anyVectorLinesCrossing

    end

end

-- Other
function FINOS_GetAreaForFin( ent )

    return FINOS_GetDataToEntFinTable( ent, "fin_os__EntAreaVectors", "ID9" )

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
function FINOS_CheckIfLastPointIsWithingAreaOfTriangle( ent, player, areaPointsTable, self )

    local areaPointsTableLength = #areaPointsTable

    if areaPointsTableLength > 3 then

        --
        -- Calculate area ( split everything up into triangles )
        local combinedLength_Area_Units = 0
        local combinedLength_Area_Units_FromPoint = 0

        for k, _ in pairs( areaPointsTable ) do

            if k < areaPointsTableLength then

                -- Calculate area from penultimate point in table and outwards
                local keyOld1 = k
                local keyOld2 = k + 1

                -- Triangle
                local oldVector1 = FINOS_CreateVectorFromTwoPoints( areaPointsTable[ areaPointsTableLength - 1 ], areaPointsTable[ keyOld1 ] )
                local oldVector2 = FINOS_CreateVectorFromTwoPoints( areaPointsTable[ areaPointsTableLength - 1 ], areaPointsTable[ keyOld2 ] )

                combinedLength_Area_Units = ( combinedLength_Area_Units + 0.5 * FINOS_VectorCrossProduct( oldVector1, oldVector2 ) )

                -- Calculate the last point in table and outwards
                local keyNew1 = k
                local keyNew2 = k + 1

                if k == ( areaPointsTableLength - 1 ) then keyNew2 = 1 end

                -- Triangle
                local newVector1 = FINOS_CreateVectorFromTwoPoints( areaPointsTable[ areaPointsTableLength ], areaPointsTable[ keyNew1 ] )
                local newVector2 = FINOS_CreateVectorFromTwoPoints( areaPointsTable[ areaPointsTableLength ], areaPointsTable[ keyNew2 ] )

                combinedLength_Area_Units_FromPoint = ( combinedLength_Area_Units_FromPoint + 0.5 * FINOS_VectorCrossProduct( newVector1, newVector2 ) )

            end

        end

        -- Important ( can't be to accurate )
        combinedLength_Area_Units = math.ceil( combinedLength_Area_Units )
        combinedLength_Area_Units_FromPoint = math.ceil( combinedLength_Area_Units_FromPoint )

        -- Point is within area, because every triangle drawn from last point outwards,
        -- is the same as the area drawn from the penultimate point outwards ( not allowed )
        if combinedLength_Area_Units_FromPoint <= combinedLength_Area_Units then

            -- Go back in time
            if self and self:IsValid() then

                self:SetDisableTool( true )

                -- Tell the player
                FINOS_SendNotification( "Unvalid next-point (overlap)!", FIN_OS_NOTIFY_ERROR, player, 3.7 )
                self:EmitSound( "fin_os/error.wav", 130, 100 )

                timer.Create( "fin_os__EntAreaPointCrossingLinesTIMER000" .. self:EntIndex(), 0.2, 1, function()

                    -- Remove point -- Save ( overwrite )
                    table.remove( areaPointsTable, areaPointsTableLength )
                    FINOS_AddDataToEntFinTable( ent, "fin_os__EntAreaPoints", areaPointsTable, nil, "ID33", true )

                    self:SetDisableTool( false )

                end )

            else

                -- Remove point -- Save ( overwrite )
                table.remove( areaPointsTable, areaPointsTableLength )
                FINOS_AddDataToEntFinTable( ent, "fin_os__EntAreaPoints", areaPointsTable, nil, "ID32", true )

            end

            return false

        end

    end

    return true

end

-- Vector lines and crossings
function FINOS_GiveVectorLineParameters( vectorPoint, vector )

    return {

        equation1 = { x = vectorPoint.x, a = vector.x },
        equation2 = { y = vectorPoint.y, b = vector.y },
        equation3 = { z = vectorPoint.z, c = vector.z }

    }

end
function FINOS_CalculateIfVectorLineIsCrossingOtherVectorLine( oldLineParameters, newLineParameters, areaPointsTable )

    local t
    local s

    local LHSLocalCrossingPoint
    local RHSLocalCrossingPoint

    local newPointXYZ = ( Vector( newLineParameters.equation1[ "x" ], newLineParameters.equation2[ "y" ], newLineParameters.equation3[ "z" ] ) )
    local oldPointXYZ = ( Vector( oldLineParameters.equation1[ "x" ], oldLineParameters.equation2[ "y" ], oldLineParameters.equation3[ "z" ] ) )

    local newVectorABC = ( Vector( newLineParameters.equation1[ "a" ], newLineParameters.equation2[ "b" ], newLineParameters.equation3[ "c" ] ) )
    local oldVectorABC = ( Vector( oldLineParameters.equation1[ "a" ], oldLineParameters.equation2[ "b" ], oldLineParameters.equation3[ "c" ] ) )

    -- POINT
    local x1
    local x2
    local y1
    local y2

    -- VECTOR
    local a1
    local a2
    local b1
    local b2

    for i = 1, 3 do

        -- Depending on the angle of the prop, the left and right coordinates will change. Try them all
        -- You can use a combo of trace.HitNormal + EntityAngleForwards to see what I am talking about
        if i == 1 then

            -- POINT
            x1 = newPointXYZ.x x2 = oldPointXYZ.x
            y1 = newPointXYZ.y y2 = oldPointXYZ.y
            -- VECTOR
            a1 = newVectorABC.x a2 = oldVectorABC.x
            b1 = newVectorABC.y b2 = oldVectorABC.y

        elseif i == 2 then

            -- POINT
            x1 = newPointXYZ.y x2 = oldPointXYZ.y
            y1 = newPointXYZ.z y2 = oldPointXYZ.z
            -- VECTOR
            a1 = newVectorABC.y a2 = oldVectorABC.y
            b1 = newVectorABC.z b2 = oldVectorABC.z
            
        elseif i == 3 then

            -- POINT
            x1 = newPointXYZ.x x2 = oldPointXYZ.x
            y1 = newPointXYZ.z y2 = oldPointXYZ.z
            -- VECTOR
            a1 = newVectorABC.x a2 = oldVectorABC.x
            b1 = newVectorABC.z b2 = oldVectorABC.z
            
        end

       -- Calculate based on own formula
       t = ( ( y2 + ( b2 * x1 - b2 * x2 ) / a2 - y1 ) / ( ( -a1 * b2 ) / a2 + b1 ) )
       s = ( ( x1 - x2 + a1 * t ) / a2 )

       local equation1LHS = ( newLineParameters.equation1[ "x" ] + newLineParameters.equation1[ "a" ] * t )
       local equation1RHS = ( oldLineParameters.equation1[ "x" ] + oldLineParameters.equation1[ "a" ] * s )
       local equation2LHS = ( newLineParameters.equation2[ "y" ] + newLineParameters.equation2[ "b" ] * t )
       local equation2RHS = ( oldLineParameters.equation2[ "y" ] + oldLineParameters.equation2[ "b" ] * s )
       local equation3LHS = ( newLineParameters.equation3[ "z" ] + newLineParameters.equation3[ "c" ] * t )
       local equation3RHS = ( oldLineParameters.equation3[ "z" ] + oldLineParameters.equation3[ "c" ] * s )

       LHSLocalCrossingPoint = Vector( equation1LHS, equation2LHS, equation3LHS )
       RHSLocalCrossingPoint = Vector( equation1RHS, equation2RHS, equation3RHS )

       -- Important ( can't be to accurate )
       local equation1LHSRounded = math.ceil( equation1LHS )
       local equation1RHSRounded = math.ceil( equation1RHS )
       local equation2LHSRounded = math.ceil( equation2LHS )
       local equation2RHSRounded = math.ceil( equation2RHS )
       local equation3LHSRounded = math.ceil( equation3LHS )
       local equation3RHSRounded = math.ceil( equation3RHS )

       local LHSLocalCrossingPointRounded = Vector( equation1LHSRounded, equation2LHSRounded, equation3LHSRounded )
       local RHSLocalCrossingPointRounded = Vector( equation1RHSRounded, equation2RHSRounded, equation3RHSRounded )

       local crossPointCoordinatesLHS = ( Vector( equation1LHS, equation2LHS, equation3LHS ) )
       local crossPointCoordinatesRHS = ( Vector( equation1RHS, equation2RHS, equation3RHS ) )

       -- Important, or else the values will be to accurate
       local tRounded = math.Round( t, 3 )
       local sRounded = math.Round( s, 3 )

       local isAPointFromToolGun = false

       for k, v in pairs( areaPointsTable ) do

           -- Very important to not get invalid cross points.. Dirty checking here...
           if (

               v == crossPointCoordinatesLHS or
               v == crossPointCoordinatesRHS or
               math.Round( math.abs( tRounded ) ) > 1 or
               math.Round( math.abs( sRounded ) ) > 1 or
               sRounded >= 0 or
               tRounded >= 0 or
               tRounded <= -1 or
               sRounded <= -1

           ) then isAPointFromToolGun = true else --[[ print( tRounded, sRounded ) ]] end

       end

       local crossingLines = ( LHSLocalCrossingPointRounded == RHSLocalCrossingPointRounded and not isAPointFromToolGun )

       -- Maybe finished checking all possible coordinates combos
       if i == 3 or crossingLines then

           return {

               t = t,
               s = s,
               LHSLocalCrossingPoint = LHSLocalCrossingPoint,
               RHSLocalCrossingPoint = RHSLocalCrossingPoint,
               crossingLines = crossingLines

           }

       end

    end

end
function FINOS_GatherValidCrossingLines( allParamsOfVectorLines, newParametersOfLastVectorLine, areaPointsTable )

    -- Crossing vector lines that are not a vector point also, from the area points table
    local calculationResults = {}
    local actualCrossingLinesResultsTable = {}

    -- Loop through all prev. (old) parameters of lines, and check if the current line will cross any of the older vector lines ( not allowed )
    local allParamsOfVectorLinesLength = #allParamsOfVectorLines

    if allParamsOfVectorLinesLength > 2 then

        for k, parametersOfAnOldLine in pairs( allParamsOfVectorLines ) do

            -- Gather all possible outcomes to check later
            table.insert(

                calculationResults,
                FINOS_CalculateIfVectorLineIsCrossingOtherVectorLine( parametersOfAnOldLine, newParametersOfLastVectorLine, areaPointsTable )

            )

        end

    end

    for _, crossingLinesResult in pairs( calculationResults ) do

        if crossingLinesResult[ "crossingLines" ] then

            table.insert( actualCrossingLinesResultsTable, crossingLinesResult )

        end

    end

    return actualCrossingLinesResultsTable

end
function FINOS_CalculateAreaForFinBasedOnAreaPoints( ent, owner, shouldNotSave, dontTellPlayerAfterSaving )

    -- Get area points if any
    local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( ent, "fin_os__EntAreaPoints", "ID8" )
    local areaPointsTableLength = #AREAPOINTSTABLE

    if areaPointsTableLength > 2 then
       
        if not shouldNotSave then

            -- Calculate area
            -- 1 foot = 12 units = 0.3048 meter
            -- units / 12 = foot => foot * 0.3048 = meters
            -- vCPL = VectorCrossProductLength
            local triangleLengthAreaTable = { }

            local combinedLength_Area_Units = 0
            local combinedLength_Area_Foot = 0
            local combinedLength_Area_Meter = 0

            -- Calculate area ( split everything up into triangles )
            for k, _ in pairs( AREAPOINTSTABLE ) do

                if k >= 3 then

                    -- Triangle
                    local newVector1 = FINOS_CreateVectorFromTwoPoints( AREAPOINTSTABLE[ areaPointsTableLength ], AREAPOINTSTABLE[ k - 2 ] )
                    local newVector2 = FINOS_CreateVectorFromTwoPoints( AREAPOINTSTABLE[ areaPointsTableLength ], AREAPOINTSTABLE[ k - 1 ] )

                    combinedLength_Area_Units = ( combinedLength_Area_Units + 0.5 * FINOS_VectorCrossProduct( newVector1, newVector2 ) )

                end

            end

            combinedLength_Area_Foot = ( combinedLength_Area_Units / ( 12 * 12 ) )
            combinedLength_Area_Meter = ( combinedLength_Area_Foot * ( 0.3048 * 0.3048 ) )

            -- Overwrite and store
            FINOS_AddDataToEntFinTable( ent, "fin_os__EntAreaVectors", {

                vCPLFin_Area_Units = math.Round( combinedLength_Area_Units, 2 ),
                vCPLFin_Area_Foot = math.Round( combinedLength_Area_Foot, 2 ),
                vCPLFin_Area_Meter = math.Round( combinedLength_Area_Meter, 2 ),
                pointsUsed = areaPointsTableLength

            }, nil, "ID9" )

            local currentEntAngle = ent:GetAngles()

            FINOS_AddDataToEntFinTable( ent, "fin_os__EntAngleProperties", {

                BaseAngle = currentEntAngle

            }, nil, "ID10" )

            if not dontTellPlayerAfterSaving then

                FINOS_AlertPlayer( "Current area between vectors: " .. FINOS_GetAreaForFin( ent )[ "vCPLFin_Area_Meter" ] .. " m²", owner )
                FINOS_AlertPlayer( "Current base angle (P, Y, R) set to: (" .. math.Round( currentEntAngle[ 1 ] ) .. ", " .. math.Round( currentEntAngle[ 2 ] ) .. ", " .. math.Round( currentEntAngle[ 3 ] ) .. ")", owner )

                FINOS_AlertPlayer( "Fin OS fin configured! Current area is " .. FINOS_GetAreaForFin( ent )[ "vCPLFin_Area_Meter" ] .. " m²", owner )
                FINOS_SendNotification( "Fin configured! Area is " .. FINOS_GetAreaForFin( ent )[ "vCPLFin_Area_Meter" ] .. " m²", FIN_OS_NOTIFY_HINT, owner, 3.5 )

            end

        else

            FINOS_SendNotification( "Fin's area is currently at " .. FINOS_GetAreaForFin( ent )[ "vCPLFin_Area_Meter" ] .. " m²", FIN_OS_NOTIFY_HINT, owner, 3 )

        end

    end

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
function FINOS_AlertPlayer( string, player )

    -- Disabled ( don't need it )
    if GetConVar( "finos_disableprintchatmessages" ):GetInt() == 0 and player and player:IsValid() then

        player:PrintMessage( HUD_PRINTTALK, string )

    end

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

    if not ent or not ent:IsValid() or not AttackAnglesDegreesTable or not RhoMassDensity or not VelocityMetersPerSecond or not AreaMeter or not Scalar then

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

-- Duplication settings for a fin
function FINOS_WriteDuplicatorDataForEntity( Entity ) -- The new entity will have this data

    local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPoints", "ID3" )
    --[[ IDs:
        vCPLFin_Area_Units = Int
        vCPLFin_Area_Foot = Int
        vCPLFin_Area_Meter = Int
        pointsUsed
     ]]
    local AREAVECTORSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaVectors", "ID4" )
    --[[ Array:
        Vector(x, y, z), Vector(x, y, z), Vector(x, y, z) ...
     ]]
    local AREAVECTORSLINESPARAMETERTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaVectorLinesParameter", "ID20" )
    --[[ Array:
        equation1 = { x = Int, a = Int }
        equation2 = { y = Int, b = Int }
        equation3 = { z = Int, c = Int }
     ]]
    local AREAPOINTCROSSINGLINESTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPointCrossingLines", "ID21" )
    --[[ Array:
        calculationResults = {
            t = Int
           s = Int
           LHSLocalCrossingPoint = Int
           RHSLocalCrossingPoint = Int
           crossingLines = true
        }
     ]]
    local AREAACCEOTEDANGLEANDHITNORMALTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaAcceptedAngleAndHitNormal", "ID22" )
    --[[ IDs:
        firstPointSet_Angles = Angles
        firstPointSet_HitNormal = Vector
     ]]
    local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAngleProperties", "ID5" )
    --[[ IDs:
        BaseAngle = Angles
        AttackAngle_Pitch = Int
        AttackAngle_RollCosinus = Int
     ]]
    local PHYSICSPROPERTIESSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", "ID6" )
    --[[ IDs:
        VelocityKmH = Int
        LiftForceNewtonsModified_beingUsed = Int
        LiftForceNewtonsNotModified = Int
        AreaMeterSquared = Int
        FinOS_LiftForceScalarValue = Int
     ]]

    -- Create a new table to store in duplicator settings for the entity
    local Data = {

        FINOS_DUPLICATIONSSETTING_VERSION_CONTROL   = FINOS_DUPLICATIONSSETTING_VERSION_CONTROL,
        AREAPOINTSTABLE                             = AREAPOINTSTABLE,
        AREAVECTORSTABLE                            = AREAVECTORSTABLE,
        AREAVECTORSLINESPARAMETERTABLE              = AREAVECTORSLINESPARAMETERTABLE,
        AREAPOINTCROSSINGLINESTABLE                 = AREAPOINTCROSSINGLINESTABLE,
        AREAACCEOTEDANGLEANDHITNORMALTABLE          = AREAACCEOTEDANGLEANDHITNORMALTABLE,
        ANGLEPROPERTIESTABLE                        = ANGLEPROPERTIESTABLE,
        PHYSICSPROPERTIESSTABLE                     = PHYSICSPROPERTIESSTABLE

    }

    duplicator.StoreEntityModifier( Entity, "FinOS", Data )

end

-- Fin's Wings Brain ( final step )
function FINOS_AddFinWingEntity( ent, owner )

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

    -- Spawn
    entFin:Spawn()
    entFin:Activate()

    ent:SetNWEntity( "fin_os_brain", entFin )

    owner:AddCount( "fin_os", ent )
    owner:AddCleanup( "fin_os", ent )

    ent:SetNWBool( "fin_os_active", true )

    FINOS_WriteDuplicatorDataForEntity( ent )

end

-- ///////////////////////////////////////////////////////////////////////////////
-- ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
-- ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
-- ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
-- ///////////////////////////////////////////////////////////////////////////////

include( "primary_attack.lua" )
include( "secondary_attack.lua" )
include( "reload.lua" )
