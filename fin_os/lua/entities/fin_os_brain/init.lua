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

-- Constants
local RHO_MASS_DENSITY_AIR = 1.29 -- At 0 degrees celcius

-- Apply Force[LIFT] to fin/wing
function ENT:ApplyForceLiftToFinWing( entParent )

	-- Calculate force for lift
	local CURRENT_GLOBAL_VECTOR_POINT = entParent:LocalToWorld( entParent:OBBCenter() )

	-- Check if we got all the values needed => Velocity = Delta Distance / Delta Time
	if self:GetAllPointsAndTimesAvailable() then

		local AREAVectors = FINOS_GetDataToEntFinTable( entParent, "fin_os__EntAreaVectors" )
		local DRAGVectors = FINOS_GetDataToEntFinTable( entParent, "fin_os__EntDragVectors" )
		
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

		-- Apply force to fin
		-- Uses formula:
		-- F_lift[N] = .5 * rho_air[kg/m^3] * Velocity[m/s]^2 * Area[m^2] * C_lift[Angle of attack on air (WING AND FLAP combined)]
		-- This formula is used in real world applications aswell
		local CURRENT_LIFT_FORCE_FIN_IN_NEWTONS = ( 0.5 * RHO_MASS_DENSITY_AIR * math.pow( CURRENT_VELOCITY_MeterSecond, 2 ) * CURRENT_AREA_METER )

		local entPhysicsObject = entParent:GetPhysicsObject()

		if entPhysicsObject:IsValid() then

			local ANGLEPROPERTIESTABLE = FINOS_GetDataToEntFinTable( entParent, "fin_os__EntAngleProperties" )
			
			local ENT_MAIN_BASE_ANGLES = ANGLEPROPERTIESTABLE[ "Main_Fin_BaseAngle" ]
			local CURRENT_ENT_ANGLES = entParent:GetAngles()

			local CURRENT_MAIN_FIN_ANGLES_OF_ATTACK = Angle(
				( CURRENT_ENT_ANGLES[ 1 ] - ENT_MAIN_BASE_ANGLES[ 1 ] ),
				( CURRENT_ENT_ANGLES[ 2 ] - ENT_MAIN_BASE_ANGLES[ 2 ] ),
				( CURRENT_ENT_ANGLES[ 3 ] - ENT_MAIN_BASE_ANGLES[ 3 ] )
			)

			local CURRENT_ANGLE_OF_ATTACK_PITCH = CURRENT_MAIN_FIN_ANGLES_OF_ATTACK[ 1 ]
			local CURRENT_ANGLE_OF_ATTACK_ROLL = CURRENT_MAIN_FIN_ANGLES_OF_ATTACK[ 3 ]
			local CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS = math.Round( math.cos( math.rad(CURRENT_ANGLE_OF_ATTACK_ROLL) ) )

			-- Being used
			local CURRENT_ATTACK_ANGLE = ( CURRENT_ANGLE_OF_ATTACK_PITCH * CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS )
			CURRENT_MAIN_FIN_ANGLES_OF_ATTACK = ( CURRENT_MAIN_FIN_ANGLES_OF_ATTACK * CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS )
			
			local SCALAR = entParent[ "FinOS_LiftForceScalarValue" ] -- Adds a little more juice
			local CURRENT_LIFT_FORCE_FIN_IN_NEWTONS_MODIFIED = CURRENT_LIFT_FORCE_FIN_IN_NEWTONS * SCALAR * CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS + CURRENT_MAIN_FIN_ANGLES_OF_ATTACK[ 3 ]

			-- ** THE MAGIC ** --
			entPhysicsObject:ApplyForceCenter( Vector(

				CURRENT_MAIN_FIN_ANGLES_OF_ATTACK[ 1 ],
				CURRENT_MAIN_FIN_ANGLES_OF_ATTACK[ 2 ],
				CURRENT_LIFT_FORCE_FIN_IN_NEWTONS_MODIFIED

			) )

			-- Store some data ( can be viewed by player )
			FINOS_AddDataToEntFinTable( entParent, "fin_os__EntAngleProperties", {

				Main_Fin_BaseAngle = ANGLEPROPERTIESTABLE[ "Main_Fin_BaseAngle" ],
				Main_Fin_AttackAngle_Pitch = CURRENT_ATTACK_ANGLE,
				Main_Fin_AttackAngle_RollCosinus = CURRENT_ANGLE_OF_ATTACK_ROLL_COSINUS,
				Flap_Fin_BaseAngle = ANGLEPROPERTIESTABLE[ "Flap_Fin_BaseAngle" ]

			} )
			
			FINOS_AddDataToEntFinTable( entParent, "fin_os__EntPhysicsProperties", {

				VelocityKmH = CURRENT_VELOCITY_KmHour,
				LiftForceNewtonsModified_beingUsed = CURRENT_LIFT_FORCE_FIN_IN_NEWTONS_MODIFIED,
				LiftForceNewtonsNotModified = CURRENT_LIFT_FORCE_FIN_IN_NEWTONS,
				AreaMeterSquared = CURRENT_AREA_METER

			} )

			-- Updated tracked fins for players, if any player has this fin as the tracked one
			for _, OWNER in pairs( player.GetAll() ) do

				local finBeingTrackedByPlayer = OWNER:GetNWEntity( "fin_os_tracked_fin" )

				if finBeingTrackedByPlayer:IsValid() and finBeingTrackedByPlayer == entParent then

					-- Store, so it can be viewed on client side
					FINOS_AddDataToEntFinTable( OWNER, "fin_os__EntBeingTracked", {

						FinBeingTracked = finBeingTrackedByPlayer,
						Main_Fin_AttackAngle_Pitch = CURRENT_ATTACK_ANGLE,
						VelocityKmH = CURRENT_VELOCITY_KmHour,
						LiftForceNewtonsModified_beingUsed = CURRENT_LIFT_FORCE_FIN_IN_NEWTONS_MODIFIED,
						LiftForceNewtonsNotModified = CURRENT_LIFT_FORCE_FIN_IN_NEWTONS,
						AreaMeterSquared = CURRENT_AREA_METER
		
					}, OWNER )

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
