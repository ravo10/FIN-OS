AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()

	self:SetModel( "models/maxofs2d/hover_rings.mdl" )
	self:SetModelScale( 1.2 )
	self:Activate()
	
	self:SetColor( Color( 255, 215, 0, 255 ) )

	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNotSolid( true )

	self:AddEFlags( EFL_DONTWALKON )
	self:AddEFlags( EFL_DONTBLOCKLOS )
	
	self:DrawShadow( false)

	-- Create the flap data structure ( same as the fin ) ? BUG
	self:SetNWBool( "fin_os_is_a_fin_flap", false )

end

function ENT:GravGunPickupAllowed( pl ) return false end

function ENT:RestAllPointsAndTimesForVelocityCalculation()

	-- Reset Points and Times
	self:SetVelocityPointA( Vector(0, 0, 0) )
	self:SetVelocityPointB( Vector(0, 0, 0) )

	self:SetVelocityTimeA( "0" )
	self:SetVelocityTimeB( "0" )

	self:SetPointAAndTimeAAvailable( false )
	self:SetPointBAndTimeBAvailable( false )
	self:SetAllPointsAndTimesAvailable( false )

end

function ENT:OnRemove()

	-- Remove Completly
	if self and self:IsValid() and self:GetParent() and self:GetParent():IsValid() then

		-- Remove flap
		local flapEntity = self:GetParent():GetNWEntity( "fin_os_flapEntity" )
		if flapEntity and flapEntity:IsValid() then FINOS_RemoveFlapFromFin( flapEntity ) end
		
		FINOS_RemoveFinAndDataFromEntity( self:GetParent(), self:GetOwner(), false, true )
	
	end

end

-- Apply Force Newton
function ENT:FINOS_ApplyForceNewton( Entity, Force, posStart, posEnd, applyForceToStartAlso, allAxis, extraZAxis, zAxisUpwardsUnit, ISWIND, WINDPROPERTIESTABLE )

	zAxisUpwardsUnit = zAxisUpwardsUnit or 0 --[[ 0 - 1 is best; like a unit vector ( normalized vector ) ]]

	local FINALFORCE = Force

	-- Create a forward direction vector
	local pushVector = FINOS_CreateVectorFromTwoPoints( posStart, posEnd ):GetNormalized()

	if allAxis then
		-- Lift in X, Y and Z
		pushVector = ( Vector( pushVector[ 1 ], pushVector[ 2 ], zAxisUpwardsUnit ) * Force )
	else
		-- Only lift in X and Y
		pushVector = ( Vector( pushVector[ 1 ], pushVector[ 2 ], 0 ) * Force )
	end

	if extraZAxis then
		-- Lift extra in Z
		FINALFORCE = ( zAxisUpwardsUnit * Force )

		pushVector = ( Vector( pushVector[ 1 ], pushVector[ 2 ], pushVector[ 3 ] + FINALFORCE ) )
	end

	-- Maybe compute more for WIND
	if ISWIND then

		if allAxis then
			
			-- Wild WIND
			--[[ From: 1 - 6 ( settings panel ) [ the server controls the min and max amount allowed ( def. 1 and 1.13 ) ] ]]
			local minWildWindAmount = WINDPROPERTIESTABLE[ "MinWildWindScale" ]
			local maxWildWindAmount = WINDPROPERTIESTABLE[ "MaxWildWindScale" ]
			
			local rand1 = math.Rand( minWildWindAmount, maxWildWindAmount )
			local rand2 = math.Rand( minWildWindAmount, maxWildWindAmount )

			posEnd[ 1 ] = posEnd[ 1 ] * rand1
			posEnd[ 2 ] = posEnd[ 2 ] * rand2

		end

		if extraZAxis then

			-- Thermal Lift WIND
			--[[ From: 200 ( settings panel ) [ the server controls the max amount allowed ( def. 36 ) ] ]]
			local maxThermalLiftWindAmount = WINDPROPERTIESTABLE[ "MaxThermalLiftWindScale" ]

			pushVector[ 3 ] = pushVector[ 3 ] * math.Rand( 1, maxThermalLiftWindAmount )

		end

	end

	-- Apply
	if applyForceToStartAlso then Entity:GetPhysicsObject():ApplyForceOffset( pushVector, posStart ) end
	Entity:GetPhysicsObject():ApplyForceOffset( pushVector, posEnd )

	return FINALFORCE

end

-- Apply WIND
function ENT:FINOS_ApplyWind( entProp, FORWARDDIRECTIONPOINTSTABLE, CURRENT_AREA_METER, WINDPROPERTIESTABLE, useThisForceInstead )

	local entPropPhysObject			= entProp:GetPhysicsObject()
	local ForwardDirectionPoints	= FORWARDDIRECTIONPOINTSTABLE[ "ForwardDirectionPoints" ]

	local posStart	= entProp:LocalToWorld( FORWARDDIRECTIONPOINTSTABLE[ "ForwardDirectionPoints" ][ 1 ] )
	local posEnd	= entProp:LocalToWorld( FORWARDDIRECTIONPOINTSTABLE[ "ForwardDirectionPoints" ][ 2 ] )

	--------------
	-- SETTINGS --
	local WILDWIND, THERMALWINDLIFT = ( WINDPROPERTIESTABLE[ "ActivateWildWind" ] > 0 ), ( WINDPROPERTIESTABLE[ "ActivateThermalWind" ] > 0 )

	--[[ 0 - 1 ( as in a unit vector ( normalized vector ) ) ]]
	local minWindScale = WINDPROPERTIESTABLE[ "MinWindScale" ]
	local maxWindScale = WINDPROPERTIESTABLE[ "MaxWindScale" ]

	--[[ From: -300000 - 300000 ( settings panel ) [ the server controls the max amount allowed ( def. 300 => ( -300 - 300 ) ) ] ]]
	local WINDFORCEPERMETERSQUARED = ( useThisForceInstead or ( WINDPROPERTIESTABLE[ "ForcePerSquareMeterArea" ] * CURRENT_AREA_METER ) )
	local WINDSCALE = math.Rand( minWindScale, maxWindScale )

	-- Apply WIND
	return self:FINOS_ApplyForceNewton( entProp, ( WINDFORCEPERMETERSQUARED / 2 --[[ Because pushing at two points ]] ), posStart, posEnd, true, WILDWIND, THERMALWINDLIFT, WINDSCALE, true, WINDPROPERTIESTABLE )

end

-- Apply Force[LIFT] to fin/wing/flap
function ENT:ApplyForceLiftToFinWing( entFinParentProp )

	-- Calculate force for lift
	local CURRENT_GLOBAL_VECTOR_POINT = entFinParentProp:LocalToWorld( entFinParentProp:OBBCenter() )

	-- Check if we got all the values needed => Velocity = Delta Distance / Delta Time
	if self:GetAllPointsAndTimesAvailable() then

		local AREAVectors = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__EntAreaVectors", "ID0" )
		if not AREAVectors or not AREAVectors[ "vCPLFin_Area_Meter" ] then return nil end
		
		-- Variables
		local CURRENT_AREA_METER = AREAVectors[ "vCPLFin_Area_Meter" ]
		local CURRENT_AREA_INCHES = ( AREAVectors[ "vCPLFin_Area_Meter" ] * 1550.0031 ) -- 1 inch^2 is 1550.0031 m^2

		-- Check that table values are OK
		if not CURRENT_AREA_METER then return end

		local vectorDeltaDistanceABLength_Units = FINOS_CreateVectorFromTwoPoints(
			Vector( self:GetVelocityPointA()[ 1 ], self:GetVelocityPointA()[ 2 ], 0 ),
			Vector( self:GetVelocityPointB()[ 1 ], self:GetVelocityPointB()[ 2 ], 0 )
		):Length()
		local timeDeltaTime = ( tonumber( self:GetVelocityTimeB() ) - tonumber( self:GetVelocityTimeA() ) )

		-- 1 foot = 12 units = 0.3048 meter
		local CURRENT_VELOCITY_UnitsSecond 	= ( ( vectorDeltaDistanceABLength_Units / timeDeltaTime ) / 3 ) -- The actual velocity in Units/s ( fraction by 3, to get it more realistic ( based on normal walking speed of humans 5 km/h ) )
		local CURRENT_VELOCITY_MeterSecond 	= ( ( CURRENT_VELOCITY_UnitsSecond / 12 * 0.3048 ) ) -- The actual velocity in m/s
		local CURRENT_VELOCITY_KmHour 		= ( CURRENT_VELOCITY_MeterSecond * 3.6 ) -- The actual velocity in km/h
		local CURRENT_VELOCITY_MilesPerHour = ( CURRENT_VELOCITY_MeterSecond * 2.24 ) -- The actual velocity in mph
		local CURRENT_VELOCITY_Knots 		= ( CURRENT_VELOCITY_KmHour * 1.852 ) -- The actual velocity in knots [1 knot = 1.85200 km/h]

		local entPhysicsObject = entFinParentProp:GetPhysicsObject()

		if entPhysicsObject:IsValid() then

			local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__EntAngleProperties", "ID2" )
			local FORWARDDIRECTIONPOINTSTABLE = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__EntForwardDirectionPoints", "ID2.3" )
			local WINDPROPERTIESTABLE = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__EntWindProperties", "ID1_Wind" )

			local SCALAR_Normal = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__EntPhysicsProperties", "ID31" )[ "FinOS_LiftForceScalarValue_Normal" ] -- Adds a little more juice
			local SCALAR_Wiremod if entFinParentProp:GetNWBool( "IgnoreRealScalarValue" ) then
				SCALAR_Wiremod = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__Wiremod_InputValues", "ID31_Wiremod" )[ "FinOS_LiftForceScalarValue_Wiremod" ]
			end

			local SCALAR = SCALAR_Wiremod or SCALAR_Normal

			-- Add scalar to parent if needed ( first time )
			if not SCALAR then SCALAR = FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE end

			-- ///////////////////////////////////////////////////////////////////////////////
			-- FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN
			-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
			-- ///////////////////////////////////////////////////////////////////////////////

			local ATTACKANGLESFINTABLE = FINOS_CalculateAttackAnglesDegreesFor_CL( entFinParentProp, entFinParentProp:GetNWBool( "IgnoreRealPitchAttackAngle" ) )

			-- Calculate Lift Force [ FIN ]
			local CALULATETFORCESFINTABLE = FINOS_CalculateLiftForce(

				entFinParentProp,
				ATTACKANGLESFINTABLE,
				GetConVar( "finos_rhodensistyfluidvalue" ):GetInt(),
				CURRENT_VELOCITY_MeterSecond,
				timeDeltaTime,
				CURRENT_AREA_METER,
				SCALAR

			)

			local CURRENT_LIFT_FORCE_IN_NEWTONS__FIN = CALULATETFORCESFINTABLE[ "CURRENT_LIFT_FORCE_IN_NEWTONS" ]
			local CURRENT_LIFT_FORCE_IN_NEWTONS_REALISTIC__FIN = CALULATETFORCESFINTABLE[ "CURRENT_LIFT_FORCE_IN_NEWTONS_REALISTIC" ]
			local CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE = CALULATETFORCESFINTABLE[ "CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE" ]

			local CL = CALULATETFORCESFINTABLE[ "CL" ]
			local CD = 0.045 + ( math.pow( CL, 2 ) / ( math.pi * CURRENT_AREA_METER * 0.7 ) )  --[[ https://wright.nasa.gov/airplane/drageq.html ]] --[[ e = .7: https://www.grc.nasa.gov/www/k-12/airplane/induced.html ]]
			local CURRENT_LIFT_IN_NEWTONS__FIN = ( CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE * SCALAR ) * CL
			local CURRENT_DRAG_IN_NEWTONS__FIN = ( CURRENT_LIFT_FORCE_IN_NEWTONS_WITHOUTATTACKANGLE * SCALAR ) * CD

			-- ///////////////////////////////////////////////////////////////////////////////
			-- FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP
			-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
			-- ///////////////////////////////////////////////////////////////////////////////

			local ANGLEPROPERTIESFROMFLAPTABLE
			local ATTACKANGLESFROMFLAPTABLE
			local CURRENT_CL_PERCEPTION_START_ANGLE_DEGREES_FLAP

			local CALULATETFORCESFLAPTABLE

			local CURRENT_LIFT_FORCE_IN_NEWTONS__FLAP = 0
			local CURRENT_LIFT_FORCE_IN_NEWTONS_REALISTIC__FLAP = 0

			local ENT_FLAP = entFinParentProp:GetNWEntity( "fin_os_flapEntity" )
			
			if ENT_FLAP and ENT_FLAP:IsValid() then

				ANGLEPROPERTIESFROMFLAPTABLE = FINOS_GetDataToEntFinTable( ENT_FLAP, "fin_os__EntAngleProperties", "ID2" )

				ATTACKANGLESFROMFLAPTABLE = FINOS_CalculateAttackAnglesDegreesFor_CL( ENT_FLAP, ENT_FLAP:GetNWBool( "IgnoreRealPitchAttackAngle" ) )

				if ATTACKANGLESFROMFLAPTABLE then

					-- Calculate Lift Force [ FLAP ]
					CALULATETFORCESFLAPTABLE = FINOS_CalculateLiftForce(

						ENT_FLAP, ATTACKANGLESFROMFLAPTABLE,
						GetConVar( "finos_rhodensistyfluidvalue" ):GetInt(),
						CURRENT_VELOCITY_MeterSecond, timeDeltaTime, ( CURRENT_AREA_METER / 4 ), SCALAR
					
					)

					CURRENT_LIFT_FORCE_IN_NEWTONS__FLAP = CALULATETFORCESFLAPTABLE[ "CURRENT_LIFT_FORCE_IN_NEWTONS" ]
					CURRENT_LIFT_FORCE_IN_NEWTONS_REALISTIC__FLAP = CALULATETFORCESFLAPTABLE[ "CURRENT_LIFT_FORCE_IN_NEWTONS_REALISTIC" ]

				end

			end

			-- ///////////////////////////////////////////////////////////////////////////////
			-- FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN
			-- FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP
			-- APPLY APPLY APPLY APPLY APPLY APPLY APPLY APPLY APPLY APPLY APPLY APPLY APPLY
			-- ///////////////////////////////////////////////////////////////////////////////

			local FLAPANGLEVECTOR1 = 0
			local FLAPANGLEVECTOR2 = 0

			if ENT_FLAP:IsValid() and ATTACKANGLESFROMFLAPTABLE then

				FLAPANGLEVECTOR1 = ATTACKANGLESFROMFLAPTABLE[ "CURRENT_MAIN_ANGLES_OF_ATTACK" ][ 1 ]
				FLAPANGLEVECTOR2 = ATTACKANGLESFROMFLAPTABLE[ "CURRENT_MAIN_ANGLES_OF_ATTACK" ][ 2 ]

			end

			local THEACTUALTOTALLIFTFORCEBEINGUSED = ( CURRENT_LIFT_IN_NEWTONS__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS_REALISTIC__FLAP )

			-- ** THE MAGIC ** --
			entPhysicsObject:ApplyForceCenter( Vector(

				0,
				0,
				THEACTUALTOTALLIFTFORCEBEINGUSED

			) )

			-- ** Drag ** ( CURRENT_DRAG_IN_NEWTONS__FIN * -1 )
			local posStart = entFinParentProp:LocalToWorld( FORWARDDIRECTIONPOINTSTABLE[ "ForwardDirectionPoints" ][ 1 ] )
			local posEnd = entFinParentProp:LocalToWorld( FORWARDDIRECTIONPOINTSTABLE[ "ForwardDirectionPoints" ][ 2 ] )

			self:FINOS_ApplyForceNewton( entFinParentProp, ( ( CURRENT_DRAG_IN_NEWTONS__FIN / 2 --[[ Because pushing at two points ]] ) * -1 ), posStart, posEnd, true, false, false, nil, false )

			-- ///////////////////////////////////////////////////////////////////////////////
			-- WIND WIND WIND WIND WIND WIND WIND WIND WIND WIND WIND WIND WIND WIND WIND WIND
			-- ///////////////////////////////////////////////////////////////////////////////
			local WINDPRODUCEDNEWTONSFORAREA = 0 if WINDPROPERTIESTABLE and WINDPROPERTIESTABLE[ "EnableWind" ] == 1 then
				WireModWindForce = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__Wiremod_InputValues", "ID35_WiremodWind" )[ "WindAmountNewtonsForArea_Wiremod" ]

				WINDPRODUCEDNEWTONSFORAREA = self:FINOS_ApplyWind( entFinParentProp, FORWARDDIRECTIONPOINTSTABLE, CURRENT_AREA_METER, WINDPROPERTIESTABLE, WireModWindForce )
			end

			-- ///////////////////////////////////////////////////////////////////////////////
			-- STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE
			-- ///////////////////////////////////////////////////////////////////////////////

			-- Store some data ( can be viewed by player ) [ FIN ]
			FINOS_AddDataToEntFinTable( entFinParentProp, "fin_os__EntAngleProperties", {

				BaseAngle				= ANGLEPROPERTIESTABLE[ "BaseAngle" ],
				AttackAngle_Pitch		= ATTACKANGLESFINTABLE[ "CURRENT_ATTACK_ANGLE" ],
				AttackAngle_RollCosinus = ATTACKANGLESFINTABLE[ "CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS" ]

			}, nil, "ID0", true )

			-- Store some data for flap ( can be viewed by player ) [ FLAP ]
			if ENT_FLAP and ENT_FLAP:IsValid() and ANGLEPROPERTIESFROMFLAPTABLE and ATTACKANGLESFROMFLAPTABLE then

				FINOS_AddDataToEntFinTable( ENT_FLAP, "fin_os__EntAngleProperties", {

					BaseAngle				= ANGLEPROPERTIESFROMFLAPTABLE[ "BaseAngle" ],
					AttackAngle_Pitch		= ATTACKANGLESFROMFLAPTABLE[ "CURRENT_ATTACK_ANGLE" ],
					AttackAngle_RollCosinus = ATTACKANGLESFROMFLAPTABLE[ "CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS" ]
	
				}, nil, "ID1", true )

			end

			FINOS_AddDataToEntFinTable( entFinParentProp, "fin_os__EntPhysicsProperties", {

				VelocityKmH							= CURRENT_VELOCITY_KmHour,
				LiftForceNewtonsModified_realistic	= ( CURRENT_LIFT_IN_NEWTONS__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS_REALISTIC__FLAP ),
				LiftForceNewtonsModified_beingUsed	= THEACTUALTOTALLIFTFORCEBEINGUSED,
				LiftForceNewtonsNotModified			= ( CURRENT_LIFT_FORCE_IN_NEWTONS__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS__FLAP ),
				DragForceNewtons					= CURRENT_DRAG_IN_NEWTONS__FIN,
				AreaMeterSquared					= CURRENT_AREA_METER,
				FinOS_LiftForceScalarValue			= SCALAR,
				FinOS_LiftForceScalarValue_Normal	= SCALAR_Normal or FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE,
				FinOS_LiftForceScalarValue_Wiremod	= FinOS_LiftForceScalarValue_Wiremod,
				FINOS_WindAmountNewtonsForArea		= WINDPRODUCEDNEWTONSFORAREA

			}, nil, "ID2", true )

			-- ///////////////////////////////////////////////////////////////////////////////
			-- STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE
			-- TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL
			-- ///////////////////////////////////////////////////////////////////////////////

			local FINATTACKANGLE = 0
			local FINROLLFRACTION = 0

			local FLAPATTACKANGLE = 0
			local FLAPROLLFRACTION = 0

			if ATTACKANGLESFINTABLE then

				FINATTACKANGLE = ATTACKANGLESFINTABLE[ "CURRENT_ATTACK_ANGLE" ]
				FINROLLFRACTION = ATTACKANGLESFINTABLE[ "CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS" ]

			end

			if ENT_FLAP:IsValid() and ATTACKANGLESFROMFLAPTABLE then

				FLAPATTACKANGLE = ATTACKANGLESFROMFLAPTABLE[ "CURRENT_ATTACK_ANGLE" ]
				FLAPROLLFRACTION = ATTACKANGLESFROMFLAPTABLE[ "CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS" ]

			end

			local entBeingTracked = 0

			-- Updated tracked fins for players, if any player has this fin as the tracked one
			for _, OWNER in pairs( player.GetAll() ) do

				local finBeingTrackedByPlayer = OWNER:GetNWEntity( "fin_os_tracked_fin" )

				if finBeingTrackedByPlayer:IsValid() and finBeingTrackedByPlayer == entFinParentProp then

					entBeingTracked = 1

					if ATTACKANGLESFINTABLE then

						-- Store, so it can be viewed on client side
						FINOS_AddDataToEntFinTable( OWNER, "fin_os__EntBeingTracked", {

							FinBeingTracked						= finBeingTrackedByPlayer,
							AttackAngle_Pitch_FIN				= FINATTACKANGLE,
							AttackAngle_RollCosinus_FIN			= FINROLLFRACTION,
							AttackAngle_Pitch_FLAP				= FLAPATTACKANGLE,
							AttackAngle_RollCosinus_FLAP		= FLAPROLLFRACTION,
							VelocityKmH							= CURRENT_VELOCITY_KmHour,
							LiftForceNewtonsModified_realistic	= ( CURRENT_LIFT_IN_NEWTONS__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS_REALISTIC__FLAP ),
							LiftForceNewtonsModified_beingUsed	= THEACTUALTOTALLIFTFORCEBEINGUSED,
							LiftForceNewtonsNotModified			= ( CURRENT_LIFT_FORCE_IN_NEWTONS__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS__FLAP ),
							DragForceNewtons					= CURRENT_DRAG_IN_NEWTONS__FIN,
							AreaMeterSquared					= CURRENT_AREA_METER,
							FINOS_WindAmountNewtonsForArea		= WINDPRODUCEDNEWTONSFORAREA,
							EnableWind							= WINDPROPERTIESTABLE[ "EnableWind" ]
			
						}, OWNER, "ID3", true )

					end

				end

			end

			-- Store, so it can be viewed for a Wire Output if needed
			FINOS_AddDataToEntFinTable( entFinParentProp, "fin_os__WireOutputData_FIN", {

				FIN_FinBeingTracked			= entBeingTracked,
				FIN_AttackAngle_Pitch		= FINATTACKANGLE,
				FIN_VelocityKnots			= CURRENT_VELOCITY_Knots,
				FIN_VelocityKmH				= CURRENT_VELOCITY_KmHour,
				FIN_VelocityMpH				= CURRENT_VELOCITY_MeterSecond,
				FIN_VelocityMps				= CURRENT_VELOCITY_MilesPerHour,
				FIN_LiftForceNewtons		= CURRENT_LIFT_IN_NEWTONS__FIN,
				FIN_DragForceNewtons		= CURRENT_DRAG_IN_NEWTONS__FIN,
				FIN_WindEnabled				= WINDPROPERTIESTABLE[ "EnableWind" ],
				FIN_WindAppliedForceNewtons	= WINDPRODUCEDNEWTONSFORAREA,
				FIN_AreaMeterSquared		= CURRENT_AREA_METER,
				FIN_AreaInchesSquared		= CURRENT_AREA_INCHES,
				FIN_Scalar					= SCALAR,

			}, nil, "ID WireOutput001", true )

			if ENT_FLAP:IsValid() then

				FINOS_AddDataToEntFinTable( ENT_FLAP, "fin_os__WireOutputData_FLAP", {

					FLAP_AttackAngle_Pitch	= FLAPATTACKANGLE,
					FLAP_AreaMeterSquared	= ( CURRENT_AREA_METER / 4 ),
					FLAP_AreaInchesSquared	= ( CURRENT_AREA_INCHES / 4 )
	
				}, nil, "ID WireOutput002", true )

			end

		end

		-- Reset Points and Times
		self:RestAllPointsAndTimesForVelocityCalculation()

	else

		if not self:GetPointAAndTimeAAvailable() then

			self:RestAllPointsAndTimesForVelocityCalculation()

			-- Set PointA and TimeA
			self:SetVelocityPointA( CURRENT_GLOBAL_VECTOR_POINT )
			self:SetVelocityTimeA( CurTime() )

			self:SetPointAAndTimeAAvailable( true )

		elseif not self:GetPointBAndTimeBAvailable() then

			-- Set PointB and TimeB
			self:SetVelocityPointB( CURRENT_GLOBAL_VECTOR_POINT )
			self:SetVelocityTimeB( CurTime() )

			self:SetPointBAndTimeBAvailable( true )
			self:SetAllPointsAndTimesAvailable( true )

		end

	end

end

-- Fin Brain
function ENT:Think()

	local entFinParentProp = self:GetParent()

	if entFinParentProp and entFinParentProp:IsValid() then

		self:ApplyForceLiftToFinWing( entFinParentProp )

		-- For after duplication
		local flap = entFinParentProp:GetNWEntity( "fin_os_flapEntity" )

		if (

			entFinParentProp[ "FinOS_data" ] and entFinParentProp[ "FinOS_data" ][ "fin_os_fin_has_a_flap" ] and
			( not flap or ( flap and not flap:IsValid() ) )

		) then

			-- Find the Flap if any, that is welded to the Fin
			for _, ent in pairs( constraint.GetAllConstrainedEntities( entFinParentProp ) ) do
		
				-- Find the Flap that is welded to the Fin, and store it as the flap
				if ent[ "FinOS_data" ] then

					if ent[ "FinOS_data" ][ "fin_os_is_a_fin_flap" ] and ent[ "FinOS_data" ][ "fin_os__EntAngleProperties" ][ "BaseAngle" ] then

						-- Set the Entity as the flap virtually
						FINOS_AddFlapEntity( entFinParentProp, ent )

					end

				end
		
			end

		end

	end

	self:NextThink( CurTime() + 0.03 ) return true

end
