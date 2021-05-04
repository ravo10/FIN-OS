AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()

	self:SetModel( "models/maxofs2d/hover_rings.mdl" )
	self:SetModelScale( 0.3 )
	self:Activate()
	
	self:SetColor( Color( 115, 255, 0) )

	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNotSolid( true )

	self:AddEFlags( EFL_DONTWALKON )
	self:AddEFlags( EFL_DONTBLOCKLOS )
	
	self:DrawShadow( false)

end

function ENT:GravGunPickupAllowed( pl ) return false end

-- Flap Brain
function ENT:Think()

	local entFlapParentProp = self:GetParent()

	if entFlapParentProp and entFlapParentProp:IsValid() then

		local finParentProp = entFlapParentProp:GetNWEntity( "fin_os_flap_finParentEntity" )

		if ( finParentProp and not finParentProp:IsValid() ) or not finParentProp then

			-- Remove Flap properties and self destruct
			FINOS_RemoveFlapFromFin( entFlapParentProp ) self:Remove()

		end

	end

	self:NextThink( CurTime() + 0.6 ) return true

end
