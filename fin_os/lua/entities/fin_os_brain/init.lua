AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()

	self:SetModel( "models/maxofs2d/hover_rings.mdl" )
	self:SetModelScale( 1 )
	self:Activate()
	
	self:SetColor( Color( 255, 215, 0, 255 ) )

	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNotSolid( true )

	self:AddEFlags( EFL_DONTWALKON )
	self:AddEFlags( EFL_DONTBLOCKLOS )
	
	self:DrawShadow( false)

	-- Create the flap data structure ( same as the fin )
	self:SetNWBool( "fin_os_is_a_fin_flap", false )

end

function ENT:GravGunPickupAllowed(pl) return false end

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
	if self and self:IsValid() and self:GetParent() and self:GetParent():IsValid() then FINOS_RemoveFinAndDataFromEntity( self:GetParent(), self:GetOwner(), false, true ) end

end

-- Apply Force[LIFT] to fin/wing/flap
function ENT:ApplyForceLiftToFinWing( entFinParentProp )

	-- Calculate force for lift
	local CURRENT_GLOBAL_VECTOR_POINT = entFinParentProp:LocalToWorld( entFinParentProp:OBBCenter() )

	-- Check if we got all the values needed => Velocity = Delta Distance / Delta Time
	if self:GetAllPointsAndTimesAvailable() then

		local AREAVectors = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__EntAreaVectors", "ID0" )
		
		-- Variables
		local CURRENT_AREA_METER = AREAVectors[ "vCPLFin_Area_Meter" ]
		local CURRENT_AREA_INCHES = ( AREAVectors[ "vCPLFin_Area_Meter" ] * 1550.0031 ) -- 1 inch^2 is 1550.0031 m^2

		-- Check that table values are OK
		if not CURRENT_AREA_METER then return end

		local vectorDeltaDistanceABLength_Units = FINOS_CreateVectorFromTwoPoints( self:GetVelocityPointA(), self:GetVelocityPointB() ):Length()
		local timeDeltaTime = ( tonumber( self:GetVelocityTimeB() ) - tonumber( self:GetVelocityTimeA() ) )

		-- 1 foot = 12 units = 0.3048 meter
		local CURRENT_VELOCITY_UnitsSecond = ( ( vectorDeltaDistanceABLength_Units / timeDeltaTime ) / 3 ) -- The actual velocity in Units/s ( fraction by 3, to get it more realistic ( based on normal walking speed of humans 5 km/h ) )
		local CURRENT_VELOCITY_MeterSecond = ( ( CURRENT_VELOCITY_UnitsSecond / 12 * 0.3048 ) ) -- The actual velocity in m/s
		local CURRENT_VELOCITY_KmHour = ( CURRENT_VELOCITY_MeterSecond * 3.6 ) -- The actual velocity in km/h
		local CURRENT_VELOCITY_MilesPerHour = ( CURRENT_VELOCITY_MeterSecond * 2.24 ) -- The actual velocity in mph

		local entPhysicsObject = entFinParentProp:GetPhysicsObject()

		if entPhysicsObject:IsValid() then

			local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__EntAngleProperties", "ID2" )
			local SCALAR = FINOS_GetDataToEntFinTable( entFinParentProp, "fin_os__EntPhysicsProperties", "ID31" )[ "FinOS_LiftForceScalarValue" ] -- Adds a little more juice

			-- Add scalar to parent if needed ( first time )
			if not SCALAR then SCALAR = FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE end

			-- ///////////////////////////////////////////////////////////////////////////////
			-- FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN
			-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
			-- ///////////////////////////////////////////////////////////////////////////////

			local ATTACKANGLESFINTABLE = FINOS_CalculateAttackAnglesDegreesFor_CL( entFinParentProp )

			-- Calculate Lift Force [ FIN ]
			local CALULATETFORCESFINTABLE = FINOS_CalculateLiftForce(

				entFinParentProp,
				ATTACKANGLESFINTABLE,
				GetConVar( "finos_rhodensistyfluidvalue" ):GetInt(),
				CURRENT_VELOCITY_MeterSecond,
				CURRENT_AREA_METER,
				SCALAR

			)

			local CURRENT_LIFT_FORCE_IN_NEWTONS__FIN = CALULATETFORCESFINTABLE[ "CURRENT_LIFT_FORCE_IN_NEWTONS" ]
			local CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FIN = CALULATETFORCESFINTABLE[ "CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED" ]

			-- ///////////////////////////////////////////////////////////////////////////////
			-- FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP FLAP
			-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
			-- ///////////////////////////////////////////////////////////////////////////////

			local ANGLEPROPERTIESFROMFLAPTABLE
			local ATTACKANGLESFROMFLAPTABLE
			local CURRENT_CL_PERCEPTION_START_ANGLE_DEGREES_FLAP

			local CALULATETFORCESFLAPTABLE

			local CURRENT_LIFT_FORCE_IN_NEWTONS__FLAP = 0
			local CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FLAP = 0

			local ENT_FLAP = entFinParentProp:GetNWEntity( "fin_os_flapEntity" )
			
			if ENT_FLAP and ENT_FLAP:IsValid() then

				ANGLEPROPERTIESFROMFLAPTABLE = FINOS_GetDataToEntFinTable( ENT_FLAP, "fin_os__EntAngleProperties", "ID2" )
				ATTACKANGLESFROMFLAPTABLE = FINOS_CalculateAttackAnglesDegreesFor_CL( ENT_FLAP )

				if ATTACKANGLESFROMFLAPTABLE then

					-- Calculate Lift Force [ FLAP ]
					CALULATETFORCESFLAPTABLE = FINOS_CalculateLiftForce(

						ENT_FLAP, ATTACKANGLESFROMFLAPTABLE,
						GetConVar( "finos_rhodensistyfluidvalue" ):GetInt(),
						CURRENT_VELOCITY_MeterSecond, ( CURRENT_AREA_METER / 4 ), SCALAR
					
					)

					CURRENT_LIFT_FORCE_IN_NEWTONS__FLAP = CALULATETFORCESFLAPTABLE[ "CURRENT_LIFT_FORCE_IN_NEWTONS" ]
					CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FLAP = CALULATETFORCESFLAPTABLE[ "CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED" ]

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

			-- ** THE MAGIC ** --
			entPhysicsObject:ApplyForceCenter( Vector(

				( ATTACKANGLESFINTABLE[ "CURRENT_MAIN_ANGLES_OF_ATTACK" ][ 1 ] + FLAPANGLEVECTOR1 ),
				( ATTACKANGLESFINTABLE[ "CURRENT_MAIN_ANGLES_OF_ATTACK" ][ 2 ] + FLAPANGLEVECTOR2 ),
				( CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FLAP )

			) )

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
				LiftForceNewtonsModified_beingUsed	= ( CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FLAP ),
				LiftForceNewtonsNotModified			= ( CURRENT_LIFT_FORCE_IN_NEWTONS__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS__FLAP ),
				AreaMeterSquared					= CURRENT_AREA_METER,
				FinOS_LiftForceScalarValue			= SCALAR

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
							LiftForceNewtonsModified_beingUsed	= CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FIN,
							LiftForceNewtonsNotModified			= CURRENT_LIFT_FORCE_IN_NEWTONS__FIN,
							AreaMeterSquared					= CURRENT_AREA_METER
			
						}, OWNER, "ID3", true )

					end

				end

			end

			-- Store, so it can be viewed for a Wire Output if needed
			FINOS_AddDataToEntFinTable( entFinParentProp, "fin_os__WireOutputData_FIN", {

				FIN_FinBeingTracked		= entBeingTracked,
				FIN_AttackAngle_Pitch	= FINATTACKANGLE,
				FIN_VelocityKmH			= CURRENT_VELOCITY_KmHour,
				FIN_VelocityMpH			= CURRENT_VELOCITY_MeterSecond,
				FIN_VelocityMps			= CURRENT_VELOCITY_MilesPerHour,
				FIN_LiftForceNewtons	= CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FIN,
				FIN_AreaMeterSquared	= CURRENT_AREA_METER,
				FIN_AreaInchesSquared	= CURRENT_AREA_INCHES,
				FIN_Scalar				= SCALAR,

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

	end

	self:NextThink( CurTime() + 0.03 ) return true

end
