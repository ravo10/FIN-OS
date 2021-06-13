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
CreateConVar(

    "finos_maxfin_os_ent", 20,
    bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ),
    "Change the maximum allowed Fin OS fin's a Player can have at once."

)
CreateConVar(

    "finos_rhodensistyfluidvalue", 1.29,
    bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ),
    "Mass density ( rho ) that will be applied to FIN OS fin."

)
CreateConVar(

    "finos_maxscalarvalue", 69,
    bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ),
    "Maximum scalar value a player can apply to a FIN OS fin."

)
CreateConVar(

    "finos_disablestrictmode", 0,
    bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ),
    "0: Enables strict mode\n1: Disables checking for angle of prop and crossing vector lines, if you just want to f*uck around ( other servers might not accept the duplicate tho )"

)
CreateConVar(

    "finos_disableprintchatmessages", 1,
    bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ),
    "Disables printing messages in chat ( only legacy )"

)

CreateClientConVar( "finos_cl_enableHoverRingBall_fin", "1", true, false )
CreateClientConVar( "finos_cl_enableHoverRingBall_flap", "1", true, false )
CreateClientConVar( "finos_cl_enableAlignAngleHelpers", "1", true, false )
CreateClientConVar( "finos_cl_enableForwardDirectionArrow", "1", true, false )

CreateClientConVar( "finos_cl_gridSizeX", "9", true, false ) --[[ FLOAT ]]
CreateClientConVar( "finos_cl_gridSizeY", "9", true, false ) --[[ FLOAT ]]

CreateClientConVar( "finos_cl_gridColorR", "13", true, false ) --[[ INT ]]
CreateClientConVar( "finos_cl_gridColorG", "146", true, false ) --[[ INT ]]
CreateClientConVar( "finos_cl_gridColorB", "241", true, false ) --[[ INT ]]

-- WIND
CreateConVar( "finos_wind_maxForcePerSquareMeterAreaAllowed", 6000, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "Max Force Per. Square Meter For Area Allowed." )
CreateConVar( "finos_wind_minWindScaleAllowed", 0, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "Min. Wind Scale Allowed." )
CreateConVar( "finos_wind_maxWindScaleAllowed", 1, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "Max. Wind Scale Allowed." )
CreateConVar( "finos_wind_minWildWindScaleAllowed", 0.1, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "Min. Wild Wind Scale Allowed." )
CreateConVar( "finos_wind_maxWildWindScaleAllowed", 6, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "Max. Wild Wind Scale Allowed." )
CreateConVar( "finos_wind_maxActivateThermalWindScaleAllowed", 200, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "Max. Thermal Lift Wind Scale Allowed." )

CreateClientConVar( "finos_cl_wind_enableWind", "0", true, false )
CreateClientConVar( "finos_cl_wind_forcePerSquareMeterArea", "300", true, false ) --[[ FLOAT ]]
CreateClientConVar( "finos_cl_wind_minWindScale", "0.4", true, false ) --[[ FLOAT ]]
CreateClientConVar( "finos_cl_wind_maxWindScale", "0.8", true, false ) --[[ FLOAT ]]

CreateClientConVar( "finos_cl_wind_activateWildWind", "0", true, false )
CreateClientConVar( "finos_cl_wind_minWildWindScale", "1", true, false ) --[[ FLOAT ]]
CreateClientConVar( "finos_cl_wind_maxWildWindScale", "1.13", true, false ) --[[ FLOAT ]]

CreateClientConVar( "finos_cl_wind_activateThermalWind", "0", true, false )
CreateClientConVar( "finos_cl_wind_maxThermalLiftWindScale", "36", true, false ) --[[ FLOAT ]]

-- Global variables
if SERVER then

    FIN_OS_NOTIFY_GENERIC = 0
    FIN_OS_NOTIFY_ERROR = 1
    FIN_OS_NOTIFY_UNDO = 2
    FIN_OS_NOTIFY_HINT = 3
    FIN_OS_NOTIFY_CLEANUP = 4

    FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE = 1

    -- Increase this if a big duplication change is added
    FINOS_DUPLICATIONSSETTING_VERSION_CONTROL = 2

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

-- Functions only important for SWEP tool
function SWEP:GetTrace()

    local OWNER = self:GetOwner()

    local tr = util.GetPlayerTrace( OWNER )
    tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX ) -- https://wiki.facepunch.com/gmod/Enums/CONTENTS
    local trace = util.TraceLine( tr )

    return trace

end

hook.Add( "Initialize", "fin_os:Initialize", function()

    -- Add Network Strings
    util.AddNetworkString( "FINOS_UpdateEntityTableValue_CLIENT" )
    util.AddNetworkString( "FINOS_SendLegacyNotification_CLIENT" )
    util.AddNetworkString( "FINOS_SendEffect_CLIENT" )

    util.AddNetworkString( "FINOS_UpdateWindSettings_SERVER" )

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
            Data[ "AREAPOINTSTABLE" ] and Data[ "FORWARDDIRECTIONPOINTSTABLE" ] and Data[ "AREAVECTORSTABLE" ] and
            Data[ "AREAACCEPTEDANGLEANDHITNORMALTABLE" ] and Data[ "ANGLEPROPERTIESTABLE" ] and Data[ "PHYSICSPROPERTIESSTABLE" ] and
            Data[ "WINDPROPERTIESTABLE" ]

        ) then

            -- Apply the angle ( important )
            Entity:SetLocalAngles( Data[ "ANGLEPROPERTIESTABLE" ][ "BaseAngle" ] )

            -- Write duplicator settings for entity
            -- **Don't need to add AREAPOINTSTABLE, AREAVECTORSTABLE, AREAVECTORSLINESPARAMETERTABLE and AREAPOINTCROSSINGLINESTABLE, since
            -- they will be calculated and added underneath virtually

            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaAcceptedAngleAndHitNormal", Data[ "AREAACCEPTEDANGLEANDHITNORMALTABLE" ], nil, "ID12", true )
            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAngleProperties", Data[ "ANGLEPROPERTIESTABLE" ], nil, "ID6", true )
            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", Data[ "PHYSICSPROPERTIESSTABLE" ], nil, "ID7", true )
            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntWindProperties", Data[ "WINDPROPERTIESTABLE" ], nil, "ID2_Wind", true )
            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntForwardDirectionPoints", Data[ "FORWARDDIRECTIONPOINTSTABLE" ], nil, "ID7.3", true )

            -- For duplication ( finding and setting the flap )
            Entity[ "FinOS_data" ][ "fin_os_fin_has_a_flap" ] = Data[ "FIN_HAS_A_FLAP" ]

            -- Check if valid fin ( no crossing lines )
            local AREAPOINTSTABLE = Data[ "AREAPOINTSTABLE" ]
            local AREAPOINTSTABLELength = #AREAPOINTSTABLE

            local anyVectorLinesCrossingOrAngleHitNormalNotOK = false

            -- Add Area points
            for k, v in pairs( AREAPOINTSTABLE ) do

                if FINOS_FinOSFinMaxAmountReachedByPlayer( Entity, Player ) then return end

                -- Virutally add points and check if any lines are crossing
                if not anyVectorLinesCrossingOrAngleHitNormalNotOK then

                    anyVectorLinesCrossingOrAngleHitNormalNotOK = FINOS_SetAreaPointsForFin( {

                        Entity = Entity,
                        HitNormal = Data[ "AREAACCEPTEDANGLEANDHITNORMALTABLE" ][ "firstPointSet_HitNormal" ],
                        HitPos = Entity:LocalToWorld( v )

                    }, Player )

                    if GetConVar( "finos_disablestrictmode" ):GetInt() == 1 then anyVectorLinesCrossingOrAngleHitNormalNotOK = false end

                end

                if k == AREAPOINTSTABLELength then

                    if not anyVectorLinesCrossingOrAngleHitNormalNotOK then

                        FINOS_CalculateAreaForFinBasedOnAreaPoints( Entity, Player, false, false )

                        if GetConVar( "finos_disablestrictmode" ):GetInt() == 1 then

                            FINOS_AlertPlayer( "All points from FIN OS fin duplication was validated ( strict mode disabled )", Player )
                            FINOS_SendNotification( "All points from FIN OS duplication was validated ( strict mode disabled )", FIN_OS_NOTIFY_GENERIC, Player, 3.4 )

                        else

                            FINOS_AlertPlayer( "All points from FIN OS fin duplication was validated ( strict mode ) ", Player )
                            FINOS_SendNotification( "All points from FIN OS duplication was validated ( strict mode ) ", FIN_OS_NOTIFY_GENERIC, Player, 3.4 )

                        end

                    else

                        -- Tell the player how big the current "prev" area is
                        FINOS_CalculateAreaForFinBasedOnAreaPoints( Entity, Player, false, true )

                        FINOS_AlertPlayer( "One or more point from FIN OS fin was not validated ( crossings ) from duplication (this server has strict settings on). Maybe you need to redefine your area", Player )
                        FINOS_SendNotification( "One or more point was not validated from FIN OS duplication", FIN_OS_NOTIFY_ERROR, Player, 4 )

                    end

                    -- Check if trace hitPoint is witin area
                    local IsWitinArea = FINOS_CheckIfLastPointIsWithingAreaOfTriangle( Entity, Player, AREAPOINTSTABLE )

                    if IsWitinArea and #AREAPOINTSTABLE > 2 then FINOS_AddFinWingEntity( Entity, Player, true ) end

                end

            end

        else

            -- Error, tell the Plater that the fin was not added ( he has to add it again )
            errorMessage1 = "**An error occured while adding the FIN OS fin (maybe old version applied before). You'll have to re-apply a new fin manually again"
            errorMessage2 = "Some static duplicator data has possibly changed since last version. We didn't get everything we need. You'll have to apply a new fin!"

        end

        if errorMessage1 then FINOS_AlertPlayer( errorMessage1, Player) end
        if errorMessage2 then FINOS_SendNotification( errorMessage2, FIN_OS_NOTIFY_ERROR, Player, 7 ) end

    end )
    duplicator.RegisterEntityModifier( "FinOS_Flap", function( Player, Entity, Data )

        if Data[ "ANGLEPROPERTIESTABLE" ] then

            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAngleProperties", Data[ "ANGLEPROPERTIESTABLE" ], nil, "ID6_Flap", true )

            -- Apply the angle ( important )
            Entity:SetLocalAngles( Data[ "ANGLEPROPERTIESTABLE" ][ "BaseAngle" ] )

            Entity[ "FinOS_data" ][ "fin_os_is_a_fin_flap" ] = Data[ "IS_A_FLAP" ]

        end

    end )

end

-- New forward direction ( for drag )
function FINOS_SetNewForwardDirection( Entity, localPointAorB, ID )

    -- For debugging
    -- print( "FINOS_SetNewForwardDirection:", ID )
    local FORWARDDIRECTIONTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntForwardDirectionPoints", "ID11.3" )
    if not FORWARDDIRECTIONTABLE then FORWARDDIRECTIONTABLE = {} end

    local function ResetTable( ID )

        -- For debugging
        -- print( "ResetTable:", ID )

        -- Reset
        FORWARDDIRECTIONTABLE = { ForwardDirectionPoints = {} }
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntForwardDirectionPoints", FORWARDDIRECTIONTABLE, nil, ID, true )

    end

    -- First time
    if not FORWARDDIRECTIONTABLE[ "ForwardDirectionPoints" ] then ResetTable( "ID8.5" ) end

    -- Get how many points already exists
    local pointsAmount = #FORWARDDIRECTIONTABLE[ "ForwardDirectionPoints" ]

    -- Add vector points
    if pointsAmount < 2 then

        -- Insert
        table.insert( FORWARDDIRECTIONTABLE[ "ForwardDirectionPoints" ], localPointAorB )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntForwardDirectionPoints", FORWARDDIRECTIONTABLE, nil, "ID8.3" )
        pointsAmount = #FORWARDDIRECTIONTABLE[ "ForwardDirectionPoints" ]

        -- Alert player
        FINOS_AlertPlayer( "*Added a forward direction point: " .. pointsAmount .. " of 2", OWNER )
        FINOS_SendNotification( "Added a forward direction point: " .. pointsAmount .. " of 2", FIN_OS_NOTIFY_GENERIC, OWNER, 1.8 )

        -- Finished
        if pointsAmount == 2 then

            -- Alert player
            FINOS_AlertPlayer( "*Added forward direction vector! Now continue with AREA POINTS", OWNER )
            FINOS_SendNotification( "Added forward direction vector! Now continue with AREA POINTS", FIN_OS_NOTIFY_HINT, OWNER, 4 )

        end

        return true

    end

    return false

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
                    OWNER:EmitSound( "fin_os/error.wav", 41, 100 )

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

    local entityAngles = Entity:GetAngles()
    local entityHitNormal = tr.HitNormal

    local isEAndShiftUsedToRotate = math.Round( math.abs( ( entityAngles[ 1 ] + entityAngles[ 2 ] + entityAngles[ 3 ] ) ), 1 ) % 1 <= 0.15

    local entityAnglesRounded = Angle( math.Round( entityAngles[ 1 ], FINOS_DevationDecimalsAnglesAlign ), math.Round( entityAngles[ 2 ], FINOS_DevationDecimalsAnglesAlign ), math.Round( entityAngles[ 3 ], FINOS_DevationDecimalsAnglesAlign ) )
    local entityHitNormalRounded = Vector( math.Round( entityHitNormal[ 1 ] ), math.Round( entityHitNormal[ 2 ] ), math.Round( entityHitNormal[ 3 ] ) )

    -- ** Når du treffer overflate, berre aksepter videre: avrundar lokale HitNormal + lokale avrunda vinkelen til (tre desimaler) prop
    if amountOfPointsUsed == 0 then

        -- Just important if we have strict mode ON
        if GetConVar( "finos_disablestrictmode" ):GetInt() ~= 1 and not isEAndShiftUsedToRotate and self then

            -- Kiss and tell
            if OWNER and OWNER:IsValid() then

                FINOS_AlertPlayer( [[*Rotate prop with "E" + "Shift" to make fin happy (´°ω°`)]], OWNER )
                FINOS_SendNotification( [[Rotate prop with "E" + "Shift" to make fin happy (´°ω°`)]], FIN_OS_NOTIFY_ERROR, OWNER, 3 )

            end

            return true

        end

        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaAcceptedAngleAndHitNormal", {

            firstPointSet_Angles = entityAnglesRounded,
            firstPointSet_HitNormal = entityHitNormalRounded
    
        }, nil,"ID10" )

    end

    -- Just important if we have strict mode ON
    -- Check if point is going to be accepted
    local acceptedAngleAndHitNormal = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaAcceptedAngleAndHitNormal","ID18" )

    local angP1, angP2 = entityAnglesRounded.p, acceptedAngleAndHitNormal[ "firstPointSet_Angles" ].p
    local angY1, angY2 = entityAnglesRounded.y, acceptedAngleAndHitNormal[ "firstPointSet_Angles" ].y
    local angR1, angR2 = entityAnglesRounded.r, acceptedAngleAndHitNormal[ "firstPointSet_Angles" ].r

    local notAllowedAngles = ( math.abs( angP1 - angP2 ) > FINOS_AllowedDevationAnglesAlign or math.abs( angY1 - angY2 ) > FINOS_AllowedDevationAnglesAlign or math.abs( angR1 - angR2 ) > FINOS_AllowedDevationAnglesAlign )

    -- Round them all off ater converting to local position
    local hitNormal1 = ( entityHitNormalRounded )
    hitNormal1 = Vector( math.Round( hitNormal1[ 1 ] ), math.Round( hitNormal1[ 2 ] ), math.Round( hitNormal1[ 3 ] ) )
    local hitNormal2 = ( acceptedAngleAndHitNormal[ "firstPointSet_HitNormal" ] )
    hitNormal2 = Vector( math.Round( hitNormal2[ 1 ] ), math.Round( hitNormal2[ 2 ] ), math.Round( hitNormal2[ 3 ] ) )

    local notAllowedHitNormal = ( hitNormal1[ 1 ] ~= hitNormal2[ 1 ] or hitNormal1[ 2 ] ~= hitNormal2[ 2 ] or hitNormal1[ 3 ] ~= hitNormal2[ 3 ] )

    if (

        self and GetConVar( "finos_disablestrictmode" ):GetInt() ~= 1 and (

            notAllowedAngles or notAllowedHitNormal

        )

    ) then

        -- --Tell player
        if notAllowedAngles then

            FINOS_AlertPlayer( "*Align the FIN OS fin to the correct START ANGLES first!", OWNER )
            FINOS_SendNotification( "Align fin to the correct START ANGLES first!", FIN_OS_NOTIFY_ERROR, OWNER, 4 )

        elseif notAllowedHitNormal then

            FINOS_AlertPlayer( "*You can only apply new points on ONE SIDE of the FIN OS fin!", OWNER )
            FINOS_SendNotification( "You can only apply new points on ONE SIDE of the fin!", FIN_OS_NOTIFY_ERROR, OWNER, 4 )

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
                player:EmitSound( "fin_os/error.wav", 41, 100 )

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

                FINOS_AlertPlayer( "FIN OS fin configured! Current area is " .. FINOS_GetAreaForFin( ent )[ "vCPLFin_Area_Meter" ] .. " m²", owner )
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

    if GetConVar( "finos_disableprintchatmessages" ):GetInt() == 0 and player and player:IsValid() then

        player:PrintMessage( HUD_PRINTTALK, string )

    end

end

-- For calculating attack angles on air
function FINOS_CalculateAttackAnglesDegreesFor_CL( ent, useWiremodInput )

    if not ent and not ent:IsValid() then return nil end

    local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( ent, "fin_os__EntAngleProperties", "ID10" )
    local ANGLEPROPERTIESTABLE_Wiremod
    if useWiremodInput then ANGLEPROPERTIESTABLE_Wiremod = FINOS_GetDataToEntFinTable( ent, "fin_os__Wiremod_InputValues", "ID10_Wiremod" ) end

    local ENT_MAIN_BASE_ANGLES = ANGLEPROPERTIESTABLE[ "BaseAngle" ]
    local CURRENT_ENT_ANGLES = ent:GetAngles()

    if not ANGLEPROPERTIESTABLE[ "BaseAngle" ] then return nil end

    local PitchAngles = ( CURRENT_ENT_ANGLES[ 1 ] - ENT_MAIN_BASE_ANGLES[ 1 ] )
    if ANGLEPROPERTIESTABLE_Wiremod then PitchAngles = ANGLEPROPERTIESTABLE_Wiremod[ "AttackAngle_Pitch_Wiremod" ] end

	local CURRENT_MAIN_ANGLES_OF_ATTACK = Angle(

		PitchAngles,
		( CURRENT_ENT_ANGLES[ 2 ] - ENT_MAIN_BASE_ANGLES[ 2 ] ),
		( CURRENT_ENT_ANGLES[ 3 ] - ENT_MAIN_BASE_ANGLES[ 3 ] )

	)

	local CURRENT_ANGLE_OF_ATTACK_ROLL = CURRENT_MAIN_ANGLES_OF_ATTACK[ 3 ]
	local CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS = math.Round( math.cos( math.rad(CURRENT_ANGLE_OF_ATTACK_ROLL) ) )
    if useWiremodInput then CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS = 1 end

    -- For props that can go above 90 degrees
    if not useWiremodInput and CURRENT_MAIN_ANGLES_OF_ATTACK[ 1 ] > 90 then

        CURRENT_MAIN_ANGLES_OF_ATTACK[ 1 ] = ( ( 180 - CURRENT_MAIN_ANGLES_OF_ATTACK[ 1 ] ) - 90 )

    end local CURRENT_ANGLE_OF_ATTACK_PITCH = CURRENT_MAIN_ANGLES_OF_ATTACK[ 1 ]

	-- Being used
	local CURRENT_ATTACK_ANGLE = ( CURRENT_ANGLE_OF_ATTACK_PITCH * CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS )
	CURRENT_MAIN_ANGLES_OF_ATTACK = ( CURRENT_MAIN_ANGLES_OF_ATTACK * CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS )

	return {

		CURRENT_ATTACK_ANGLE = CURRENT_ATTACK_ANGLE,
		CURRENT_MAIN_ANGLES_OF_ATTACK = CURRENT_MAIN_ANGLES_OF_ATTACK,
		CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS = CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS

	}

end
function FINOS_CalculateLiftForce( ent, AttackAnglesDegreesTable, RhoMassDensity, VelocityMetersPerSecond, timeDeltaTime, AreaMeter, Scalar )

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

    -- local CURRENT_MAIN_ANGLES_OF_ATTACK = AttackAnglesDegreesTable[ "CURRENT_MAIN_ANGLES_OF_ATTACK" ]

    -- ** The LIFT Force [ Coefficient ] **
    local CURRENT_CL = 2 * math.pi * math.rad( CURRENT_ATTACK_ANGLE_DEGREES )
    -- local g_CONSTANT_ACCELERTATION = 600 * 0.01635 -- 600 = default gravity. 600 * 0.01635 = 9.81

    -- ** The LIFT Force **
    local CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE = ( 0.5 * RhoMassDensity * math.pow( VelocityMetersPerSecond, 2 ) * AreaMeter )
    -- local CURRENT_LIFT_FORCE_IN_NEWTONS = ( CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE * CURRENT_CL )
    local CURRENT_LIFT_FORCE_IN_NEWTONS = ( CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE * CURRENT_CL )

    -- ** The LIFT Force used IN-GAME **
    local FLAP_LIFT_FORCE_NEWTON = 0
    if ent:GetNWBool( "fin_os_is_a_fin_flap" ) then

        -- Want to directly affect lift positivly or negativly with the attack angle of the flap ( use the preset angle ) [ FLAP ]
        local NEW_CURRENT_CL = 2 * math.pi * math.rad( CURRENT_ATTACK_ANGLE_DEGREES_PRE )
        FLAP_LIFT_FORCE_NEWTON = ( 0.5 * RhoMassDensity * math.pow( VelocityMetersPerSecond, 2 ) * AreaMeter * NEW_CURRENT_CL )

        CURRENT_CL = NEW_CURRENT_CL
        CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED = ( FLAP_LIFT_FORCE_NEWTON * Scalar )

    else

        CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED = ( CURRENT_LIFT_FORCE_IN_NEWTONS * Scalar )

    end

    return {

        CURRENT_LIFT_FORCE_IN_NEWTONS = CURRENT_LIFT_FORCE_IN_NEWTONS,
        CURRENT_LIFT_FORCE_IN_NEWTONS_REALISTIC = CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED,
        CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE = CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE,
        CL = CURRENT_CL

    }

end

-- Duplication settings for a fin
function FINOS_WriteDuplicatorDataForEntity( EntityPhysPropNotFinBrain ) -- The new entity will have this data

    local FORWARDDIRECTIONPOINTSTABLE = FINOS_GetDataToEntFinTable( EntityPhysPropNotFinBrain, "fin_os__EntForwardDirectionPoints", "ID3.3" )
    --[[ IDs:
        ForwardDirectionPoints: Array<Vector(x, y, z), Vector(x, y, z)>
     ]]
    local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( EntityPhysPropNotFinBrain, "fin_os__EntAreaPoints", "ID3" )
    --[[ IDs:
        vCPLFin_Area_Units = Int
        vCPLFin_Area_Foot = Int
        vCPLFin_Area_Meter = Int
        pointsUsed
     ]]
    local AREAVECTORSTABLE = FINOS_GetDataToEntFinTable( EntityPhysPropNotFinBrain, "fin_os__EntAreaVectors", "ID4" )
    --[[ Array:
        Vector(x, y, z), Vector(x, y, z), Vector(x, y, z) ...
    ]]
    local AREAVECTORSLINESPARAMETERTABLE = FINOS_GetDataToEntFinTable( EntityPhysPropNotFinBrain, "fin_os__EntAreaVectorLinesParameter", "ID20" )
    --[[ Array:
        equation1 = { x = Int, a = Int }
        equation2 = { y = Int, b = Int }
        equation3 = { z = Int, c = Int }
     ]]
    local AREAPOINTCROSSINGLINESTABLE = FINOS_GetDataToEntFinTable( EntityPhysPropNotFinBrain, "fin_os__EntAreaPointCrossingLines", "ID21" )
    --[[ Array:
        calculationResults = {
            t = Int
            s = Int
            LHSLocalCrossingPoint = Int
            RHSLocalCrossingPoint = Int
            crossingLines = true
        }
    ]]
    local AREAACCEPTEDANGLEANDHITNORMALTABLE = FINOS_GetDataToEntFinTable( EntityPhysPropNotFinBrain, "fin_os__EntAreaAcceptedAngleAndHitNormal", "ID22" )
    --[[ IDs:
        firstPointSet_Angles = Angles
        firstPointSet_HitNormal = Vector
     ]]
    local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( EntityPhysPropNotFinBrain, "fin_os__EntAngleProperties", "ID5" )
    --[[ IDs:
        BaseAngle = Angles
        AttackAngle_Pitch = Int
        AttackAngle_RollCosinus = Int
    ]]
    local PHYSICSPROPERTIESSTABLE = FINOS_GetDataToEntFinTable( EntityPhysPropNotFinBrain, "fin_os__EntPhysicsProperties", "ID6" )
    --[[ IDs:
        VelocityKmH = Int
        LiftForceNewtonsModified_realistic = Int
        LiftForceNewtonsModified_beingUsed = Int
        LiftForceNewtonsNotModified = Int
        DragForceNewtons = Int
        AreaMeterSquared = Int
        FinOS_LiftForceScalarValue = Int
        FinOS_LiftForceScalarValue_Normal = Int
        FinOS_LiftForceScalarValue_Wiremod = Int
        FINOS_WindAmountNewtonsForArea = Int
     ]]
    local WINDPROPERTIESTABLE = FINOS_GetDataToEntFinTable( EntityPhysPropNotFinBrain, "fin_os__EntWindProperties", "ID1_Wind" )
    --[[ IDs:
        EnableWind = Int
        ForcePerSquareMeterArea = Float
        MinWindScale = Float
        MaxWindScale = Float
        ActivateWildWind = Int
        MinWildWindScale = Float
        MaxWildWindScale = Float
        ActivateThermalWind = Int
        MaxThermalLiftWindScale = Float
     ]]

    -- Create a new table to store in duplicator settings for the entity
    local Data = {

        FINOS_DUPLICATIONSSETTING_VERSION_CONTROL   = FINOS_DUPLICATIONSSETTING_VERSION_CONTROL,
        FORWARDDIRECTIONPOINTSTABLE                 = FORWARDDIRECTIONPOINTSTABLE,
        AREAPOINTSTABLE                             = AREAPOINTSTABLE,
        AREAVECTORSTABLE                            = AREAVECTORSTABLE,
        AREAVECTORSLINESPARAMETERTABLE              = AREAVECTORSLINESPARAMETERTABLE,
        AREAPOINTCROSSINGLINESTABLE                 = AREAPOINTCROSSINGLINESTABLE,
        AREAACCEPTEDANGLEANDHITNORMALTABLE          = AREAACCEPTEDANGLEANDHITNORMALTABLE,
        ANGLEPROPERTIESTABLE                        = ANGLEPROPERTIESTABLE,
        PHYSICSPROPERTIESSTABLE                     = PHYSICSPROPERTIESSTABLE,
        WINDPROPERTIESTABLE                         = WINDPROPERTIESTABLE,
        FIN_HAS_A_FLAP                              = EntityPhysPropNotFinBrain[ "FinOS_data" ][ "fin_os_fin_has_a_flap" ]

    }

    duplicator.StoreEntityModifier( EntityPhysPropNotFinBrain, "FinOS", Data )

end
function FINOS_WriteDuplicatorDataForFlapEntity( EntityFlap ) -- The new entity will have this data

    local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( EntityFlap, "fin_os__EntAngleProperties", "ID5_Flap" )
    --[[ IDs:
        BaseAngle = Angles
        AttackAngle_Pitch = Int
        AttackAngle_RollCosinus = Int
     ]]

    -- Create a new table to store in duplicator settings for the entity
    local Data = {

        ANGLEPROPERTIESTABLE    = ANGLEPROPERTIESTABLE,
        IS_A_FLAP               = EntityFlap[ "FinOS_data" ][ "fin_os_is_a_fin_flap" ]

    }

    duplicator.StoreEntityModifier( EntityFlap, "FinOS_Flap", Data )

end

-- Check if Fin OS fin max amount is reached for Player
function FINOS_FinOSFinMaxAmountReachedByPlayer( ent, owner )
    
    -- Prevent adding more than allowed
    local prevFinOSBrain = ent:GetNWEntity( "fin_os_brain" )
    local prevFinOSBrainValid = prevFinOSBrain and prevFinOSBrain:IsValid()

    if not prevFinOSBrainValid and ( owner:IsValid() and owner:GetNWInt( "fin_os_ent_amount", 0 ) >= GetConVar( "finos_maxfin_os_ent" ):GetInt() and not game.SinglePlayer() ) then

        -- Tell the Player that the max amount is reached
        FINOS_AlertPlayer( "You've hit the FIN OS limit!", owner )
        FINOS_SendNotification( "You've hit the FIN OS limit!", FIN_OS_NOTIFY_ERROR, owner, 2.3 )
        owner:SendLua( [[surface.PlaySound( "fin_os/fin_os_button10.wav" )]] )

        return true

    end

    return false

end
-- Fin's Wings Brain ( final step )
function FINOS_AddFinWingEntity( ent, owner )

    -- Prevent adding more than allowed
    local prevFinOSBrain = ent:GetNWEntity( "fin_os_brain" )
    local prevFinOSBrainValid = prevFinOSBrain and prevFinOSBrain:IsValid()

    -- Set the now current owner ( for use with wind, when adjusting settings )
    ent:SetNWEntity( "fin_os_currentOwner", owner )

    -- Make a fin wing
    local entFin = prevFinOSBrain

    if not prevFinOSBrainValid then

        entFin = ents.Create( "fin_os_brain" )

        entFin:SetPos( ent:LocalToWorld( ent:OBBCenter() ) ) -- Endre til midten av arealet vektor ??
        entFin:SetAngles( ent:GetAngles() )

        entFin:SetName( "fin_os_finWingBrain" )
        entFin:SetParent( ent )
        entFin:SetOwner( owner )
        entFin:SetCreator( owner )

        -- Spawn
        entFin:Spawn()
        entFin:Activate()

    end

    ent:SetNWEntity( "fin_os_brain", entFin )

    ent:SetNWBool( "fin_os_active", true )

    owner:AddCount( "fin_os_brain", entFin )
    owner:AddCleanup( "fin_os_brain", entFin )

    -- For Wiremod
    FINOS_AddDataToEntFinTable( ent, "fin_os__Wiremod_InputValues", {}, nil, "ID0_Wiremod", true )

    -- For Wind
    local FinWindPropertiesTable = FINOS_GetDataToEntFinTable( ent, "fin_os__EntWindProperties", "ID15.Wind" )

    local EnableWind = FinWindPropertiesTable[ "EnableWind" ]
    local ForcePerSquareMeterArea = FinWindPropertiesTable[ "ForcePerSquareMeterArea" ]
    local MinWindScale = FinWindPropertiesTable[ "MinWindScale" ]
    local MaxWindScale = FinWindPropertiesTable[ "MaxWindScale" ]

    local ActivateWildWind = FinWindPropertiesTable[ "ActivateWildWind" ]
    local MinWildWindScale = FinWindPropertiesTable[ "MinWildWindScale" ]
    local MaxWildWindScale = FinWindPropertiesTable[ "MaxWildWindScale" ]

    local ActivateThermalWind = FinWindPropertiesTable[ "ActivateThermalWind" ]
    local MaxThermalLiftWindScale = FinWindPropertiesTable[ "MaxThermalLiftWindScale" ]

    FINOS_AddDataToEntFinTable( ent, "fin_os__EntWindProperties", {

        EnableWind = ( EnableWind or GetConVar( "finos_cl_wind_enableWind" ):GetInt() ),
        ForcePerSquareMeterArea = ( ForcePerSquareMeterArea or GetConVar( "finos_cl_wind_forcePerSquareMeterArea" ):GetFloat() ),
        MinWindScale = ( MinWindScale or GetConVar( "finos_cl_wind_minWindScale" ):GetFloat() ),
        MaxWindScale = ( MaxWindScale or GetConVar( "finos_cl_wind_maxWindScale" ):GetFloat() ),

        ActivateWildWind = ( ActivateWildWind or GetConVar( "finos_cl_wind_activateWildWind" ):GetInt() ),
        MinWildWindScale = ( MinWildWindScale or GetConVar( "finos_cl_wind_minWildWindScale" ):GetFloat() ),
        MaxWildWindScale = ( MaxWildWindScale or GetConVar( "finos_cl_wind_maxWildWindScale" ):GetFloat() ),

        ActivateThermalWind = ( ActivateThermalWind or GetConVar( "finos_cl_wind_activateThermalWind" ):GetInt() ),
        MaxThermalLiftWindScale = ( MaxThermalLiftWindScale or GetConVar( "finos_cl_wind_maxThermalLiftWindScale" ):GetFloat() )

    }, nil, "ID3_Wind", true )

    -- Have to be last
    FINOS_WriteDuplicatorDataForEntity( ent )

    if not prevFinOSBrainValid and not game.SinglePlayer() then owner:SetNWInt( "fin_os_ent_amount", owner:GetNWInt( "fin_os_ent_amount", 0 ) + 1 ) end

end
-- Fin's Flap ( optional )
function FINOS_AddFlapEntity( finEntity, flapEntity )

    if not ( finEntity and finEntity:IsValid() and flapEntity and flapEntity:IsValid() ) then return end

    local currentEntAngle

    -- Create the flap data structure ( same as the fin )
    if (

        (
            flapEntity[ "FinOS_data" ] and
            flapEntity[ "FinOS_data" ][ "fin_os__EntAngleProperties" ][ "BaseAngle" ] and not flapEntity[ "FinOS_data" ][ "fin_os__EntAngleProperties" ][ "BaseAngle" ]
        ) or (
            not flapEntity[ "FinOS_data" ] or ( flapEntity[ "FinOS_data" ] and not flapEntity[ "FinOS_data" ][ "fin_os__EntAngleProperties" ][ "BaseAngle" ] )
        )

    ) then

        currentEntAngle = flapEntity:GetAngles()

        FINOS_AddDataToEntFinTable( flapEntity, "fin_os__EntAngleProperties", {

            BaseAngle = currentEntAngle

        }, nil, "ID11c", true )

    else currentEntAngle = flapEntity[ "FinOS_data" ][ "fin_os__EntAngleProperties" ][ "BaseAngle" ] end

    -- For Wiremod
    FINOS_AddDataToEntFinTable( flapEntity, "fin_os__Wiremod_InputValues", {}, nil, "ID1_Wiremod", true )

    finEntity[ "FinOS_data" ][ "fin_os_fin_has_a_flap" ] = true -- For duplication
    FINOS_WriteDuplicatorDataForEntity( finEntity )

    flapEntity:SetNWBool( "fin_os_is_a_fin_flap", true )

	flapEntity[ "FinOS_data" ][ "fin_os_is_a_fin_flap" ] = true -- For duplication
    FINOS_WriteDuplicatorDataForFlapEntity( flapEntity )

    -- Flap brain
    local anyPrevFlapBrain = flapEntity:GetNWEntity( "fin_os_flap_brain" )
    local entFlapBrain = anyPrevFlapBrain or nil

    if ( anyPrevFlapBrain and not anyPrevFlapBrain:IsValid() ) or not anyPrevFlapBrain then

        entFlapBrain = ents.Create( "fin_os_flap_brain" )

        entFlapBrain:SetPos( flapEntity:LocalToWorld( flapEntity:OBBCenter() ) ) -- Endre til midten av arealet vektor ??
        entFlapBrain:SetAngles( flapEntity:GetAngles() )

        entFlapBrain:SetName( "fin_os_finWingBrain" )
        entFlapBrain:SetParent( flapEntity )
        entFlapBrain:SetOwner( finEntity:GetOwner() )
        entFlapBrain:SetCreator( finEntity:GetOwner() )

        -- Spawn
        entFlapBrain:Spawn()
        entFlapBrain:Activate()

    end

    flapEntity:SetNWEntity( "fin_os_flap_brain", entFlapBrain )
    flapEntity:SetNWEntity( "fin_os_flap_finParentEntity", finEntity )

    finEntity:SetNWEntity( "fin_os_flapEntity", flapEntity )

    return currentEntAngle

end
-- Remove Flap from Fin
function FINOS_RemoveFlapFromFin( flapEntity )

    flapEntity[ "FinOS_data" ][ "fin_os_is_a_fin_flap" ] = false -- For duplication
    FINOS_WriteDuplicatorDataForFlapEntity( flapEntity )

    -- Remove flap from fin
    flapEntity:SetNWBool( "fin_os_is_a_fin_flap", false )
    local FIN_FLAP_FINPARENTENT = flapEntity:GetNWEntity( "fin_os_flap_finParentEntity", nil )

    if FIN_FLAP_FINPARENTENT and FIN_FLAP_FINPARENTENT:IsValid() and FIN_FLAP_FINPARENTENT[ "FinOS_data" ] then

        FIN_FLAP_FINPARENTENT[ "FinOS_data" ][ "fin_os_fin_has_a_flap" ] = false -- For duplication

        -- Update Fin duplication settings
        FINOS_WriteDuplicatorDataForEntity( FIN_FLAP_FINPARENTENT )

    end

    FIN_FLAP_FINPARENTENT:SetNWEntity( "fin_os_flapEntity", nil )
    flapEntity:SetNWEntity( "fin_os_flap_finParentEntity", nil )

    FINOS_AddDataToEntFinTable( flapEntity, "fin_os__EntAngleProperties", nil )

    flapEntity[ "FinOS_data" ] = nil

    local flapBrain = flapEntity:GetNWEntity( "fin_os_flap_brain" )
    if flapBrain and flapBrain:IsValid() then flapBrain:Remove() end

    flapEntity:SetNWEntity( "fin_os_flap_brain", nil )

end
-- Remove Fin from Entity
function FINOS_RemoveFinAndDataFromEntity( ent, owner, onlyBasicCleaning, ignoreFinOSBrain )

    -- Remove fin_os_brain
    local foundOneFinWing = false
    local prevFinOSBrain = ent:GetNWEntity( "fin_os_brain" )
    local prevFinOSBrainValid = prevFinOSBrain and prevFinOSBrain:IsValid()

    if not ignoreFinOSBrain and prevFinOSBrainValid then prevFinOSBrain:Remove() end
    if prevFinOSBrainValid then foundOneFinWing = true end

    -- CLEAN UP
    -- Empty all data
    FINOS_AddDataToEntFinTable( ent, "fin_os__EntForwardDirectionPoints", nil )
    FINOS_AddDataToEntFinTable( ent, "fin_os__EntAreaPoints", nil )
    FINOS_AddDataToEntFinTable( ent, "fin_os__EntAreaVectors", nil )
    FINOS_AddDataToEntFinTable( ent, "fin_os__EntAreaVectorLinesParameter", nil )
    FINOS_AddDataToEntFinTable( ent, "fin_os__EntAreaPointCrossingLines", nil )
    FINOS_AddDataToEntFinTable( ent, "fin_os__EntAreaAcceptedAngleAndHitNormal", nil )
    FINOS_AddDataToEntFinTable( ent, "fin_os__EntAngleProperties", nil )
    FINOS_AddDataToEntFinTable( ent, "fin_os__EntPhysicsProperties", nil )

    ent[ "FinOS_data" ] = nil

    -- Remove saved duplicator settings for entity
    if not ignoreFinOSBrain then duplicator.ClearEntityModifier( ent, "FinOS" ) end

    if onlyBasicCleaning then return foundOneFinWing end

    ent:SetNWBool( "fin_os_active", false )

    -- If the Player has this fin as the tracked one
    if owner and owner:IsValid() and owner:GetNWEntity( "fin_os_tracked_fin" ):IsValid() and owner:GetNWEntity( "fin_os_tracked_fin" ) == ent then

        owner:SetNWEntity( "fin_os_tracked_fin", nil )

        FINOS_AddDataToEntFinTable( owner, "fin_os__EntBeingTracked", nil, owner )

    end

    -- Remove fin
    if ent:GetNWEntity( "fin_os_flapEntity" ):IsValid() then FINOS_RemoveFlapFromFin( ent:GetNWEntity( "fin_os_flapEntity" ) ) end

    if not game.SinglePlayer() then owner:SetNWInt( "fin_os_ent_amount", owner:GetNWInt( "fin_os_ent_amount", 1 ) - 1 ) end

    return foundOneFinWing

end

-- ///////////////////////////////////////////////////////////////////////////////
-- ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
-- ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
-- ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
-- ///////////////////////////////////////////////////////////////////////////////

include( "primary_attack.lua" )
include( "secondary_attack.lua" )
include( "reload.lua" )
