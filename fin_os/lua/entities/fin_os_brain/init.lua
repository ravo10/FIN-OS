AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()

	self:SetModel("models/maxofs2d/hover_rings.mdl")
	self:SetModelScale( 1 )
	self:Activate()
	
	self:SetColor( Color( 255, 215, 0, 255 ) )

	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNotSolid( true )

	self:AddEFlags( EFL_DONTWALKON )
	self:AddEFlags( EFL_DONTBLOCKLOS )
	
	self:DrawShadow( false)

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

-- Apply Force[LIFT] to fin/wing/flap
function ENT:ApplyForceLiftToFinWing( entParent )

	-- Calculate force for lift
	local CURRENT_GLOBAL_VECTOR_POINT = entParent:LocalToWorld( entParent:OBBCenter() )

	-- Check if we got all the values needed => Velocity = Delta Distance / Delta Time
	if self:GetAllPointsAndTimesAvailable() then

		local AREAVectors = FINOS_GetDataToEntFinTable( entParent, "fin_os__EntAreaVectors", "ID0" )
		local DRAGVectors = FINOS_GetDataToEntFinTable( entParent, "fin_os__EntDragVectors", "ID1" )
		
		-- Variables
		local CURRENT_AREA_METER = AREAVectors[ "vCPLFin_Area_Meter" ]

		-- Check that table values are OK
		if not CURRENT_AREA_METER then return end

		local vectorDeltaDistanceABLength_Units = FINOS_CreateVectorFromTwoPoints( self:GetVelocityPointA(), self:GetVelocityPointB() ):Length()
		local timeDeltaTime = ( tonumber( self:GetVelocityTimeB() ) - tonumber( self:GetVelocityTimeA() ) )

		-- 1 foot = 12 units = 0.3048 meter
		local CURRENT_VELOCITY_UnitsSecond = ( ( vectorDeltaDistanceABLength_Units / timeDeltaTime ) / 3 ) -- The actual velocity in Units/s ( fraction by 3, to get it more realistic ( based on normal walking speed of humans 5 km/h ) )
		local CURRENT_VELOCITY_MeterSecond = ( ( CURRENT_VELOCITY_UnitsSecond / 12 * 0.3048 ) ) -- The actual velocity in m/s
		local CURRENT_VELOCITY_KmHour = ( CURRENT_VELOCITY_MeterSecond * 3.6 ) -- The actual velocity in km/h

		local entPhysicsObject = entParent:GetPhysicsObject()

		if entPhysicsObject:IsValid() then

			local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( entParent, "fin_os__EntAngleProperties", "ID2" )
			local SCALAR = entParent[ "FinOS_LiftForceScalarValue" ] -- Adds a little more juice

			-- ///////////////////////////////////////////////////////////////////////////////
			-- FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN FIN
			-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
			-- ///////////////////////////////////////////////////////////////////////////////

			local ATTACKANGLESFINTABLE = FINOS_CalculateAttackAnglesDegreesFor_CL( entParent )

			-- Calculate Lift Force [ FIN ]
			local CALULATETFORCESFINTABLE = FINOS_CalculateLiftForce(

				entParent,
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

			local ATTACKANGLESFROMFLAPTABLE
			local CURRENT_CL_PERCEPTION_START_ANGLE_DEGREES_FLAP

			local CALULATETFORCESFLAPTABLE

			local CURRENT_LIFT_FORCE_IN_NEWTONS__FLAP = 0
			local CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FLAP = 0

			local ENT_FLAP = entParent:GetNWEntity( "fin_os_flapEntity" ) if ENT_FLAP:IsValid() then

				ATTACKANGLESFROMFLAPTABLE = FINOS_CalculateAttackAnglesDegreesFor_CL( ENT_FLAP )

				if ATTACKANGLESFROMFLAPTABLE then

					-- Calculate Lift Force [ FLAP ]
					CALULATETFORCESFLAPTABLE = FINOS_CalculateLiftForce(

						ENT_FLAP,
						ATTACKANGLESFROMFLAPTABLE,
						GetConVar( "finos_rhodensistyfluidvalue" ):GetInt(),
						CURRENT_VELOCITY_MeterSecond,
						( CURRENT_AREA_METER / 4 ),
						SCALAR
					
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
			FINOS_AddDataToEntFinTable( entParent, "fin_os__EntAngleProperties", {

				BaseAngle = ANGLEPROPERTIESTABLE[ "BaseAngle" ],
				AttackAngle_Pitch = ATTACKANGLESFINTABLE[ "CURRENT_ATTACK_ANGLE" ],
				AttackAngle_RollCosinus = ATTACKANGLESFINTABLE[ "CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS" ]

			}, nil, "ID0" )

			-- Store some data for flap ( can be viewed by player ) [ FLAP ]
			if ENT_FLAP:IsValid() and ATTACKANGLESFROMFLAPTABLE then

				FINOS_AddDataToEntFinTable( ENT_FLAP, "fin_os__EntAngleProperties", {

					AttackAngle_Pitch = ATTACKANGLESFROMFLAPTABLE[ "CURRENT_ATTACK_ANGLE" ],
					AttackAngle_RollCosinus = ATTACKANGLESFROMFLAPTABLE[ "CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS" ]
	
				}, nil, "ID1" )

			end

			FINOS_AddDataToEntFinTable( entParent, "fin_os__EntPhysicsProperties", {

				VelocityKmH = CURRENT_VELOCITY_KmHour,
				LiftForceNewtonsModified_beingUsed = ( CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FLAP ),
				LiftForceNewtonsNotModified = ( CURRENT_LIFT_FORCE_IN_NEWTONS__FIN + CURRENT_LIFT_FORCE_IN_NEWTONS__FLAP ),
				AreaMeterSquared = CURRENT_AREA_METER

			}, nil, "ID2" )

			-- ///////////////////////////////////////////////////////////////////////////////
			-- STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE STORE
			-- TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL TELL
			-- ///////////////////////////////////////////////////////////////////////////////

			-- Updated tracked fins for players, if any player has this fin as the tracked one
			for _, OWNER in pairs( player.GetAll() ) do

				local finBeingTrackedByPlayer = OWNER:GetNWEntity( "fin_os_tracked_fin" )

				if finBeingTrackedByPlayer:IsValid() and finBeingTrackedByPlayer == entParent then

					local FLAPATTACKANGLE = 0
					local FLAPROLLFRACTION = 0

					if ENT_FLAP:IsValid() and ATTACKANGLESFROMFLAPTABLE then

						FLAPATTACKANGLE = ATTACKANGLESFROMFLAPTABLE[ "CURRENT_ATTACK_ANGLE" ]
						FLAPROLLFRACTION = ATTACKANGLESFROMFLAPTABLE[ "CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS" ]
		
					end

					if ATTACKANGLESFINTABLE then

						local FINATTACKANGLE = ATTACKANGLESFINTABLE[ "CURRENT_ATTACK_ANGLE" ]
						local FINROLLFRACTION = ATTACKANGLESFINTABLE[ "CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS" ]

						-- Store, so it can be viewed on client side
						FINOS_AddDataToEntFinTable( OWNER, "fin_os__EntBeingTracked", {

							FinBeingTracked = finBeingTrackedByPlayer,
							AttackAngle_Pitch_FIN = FINATTACKANGLE,
							AttackAngle_RollCosinus_FIN = FINROLLFRACTION,
							AttackAngle_Pitch_FLAP = FLAPATTACKANGLE,
							AttackAngle_RollCosinus_FLAP = FLAPROLLFRACTION,
							VelocityKmH = CURRENT_VELOCITY_KmHour,
							LiftForceNewtonsModified_beingUsed = CURRENT_LIFT_FORCE_IN_NEWTONS_MODIFIED__FIN,
							LiftForceNewtonsNotModified = CURRENT_LIFT_FORCE_IN_NEWTONS__FIN,
							AreaMeterSquared = CURRENT_AREA_METER
			
						}, OWNER, "ID3" )

					end

				end

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

	local entParent = self:GetParent()

	if entParent and entParent:IsValid() then

		self:ApplyForceLiftToFinWing( entParent )

	end

	self:NextThink( CurTime() + 0.03 ) return true

end
