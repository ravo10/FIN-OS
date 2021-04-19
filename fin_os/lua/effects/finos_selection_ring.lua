
EFFECT.Mat = Material( "effects/finos_select_ring" )

function EFFECT:Init( data )

	local size = 8
	self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )

	local Pos = data:GetOrigin() + data:GetNormal() * 2

	self:SetPos( Pos )

	-- This 0.01 is a hack.. to prevent the angle being weird and messing up when we change it back to a normal
	self:SetAngles( data:GetNormal():Angle() + Angle( 0.01, 0.01, 0.01 ) )

	self:SetParentPhysNum( data:GetAttachment() )

	if ( IsValid( data:GetEntity() ) ) then
		self:SetParent( data:GetEntity() )
	end

	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()

	self.Speed = math.Rand( 0.5, 1.1 )
	self.Size = 6
	self.Alpha = 150

	self.Life = 0.5

end

function EFFECT:Think()

	self.Alpha = self.Alpha - FrameTime() * 255 * 6 * self.Speed
	self.Size = self.Size + FrameTime() * 256 * self.Speed

	if ( self.Alpha < 0 ) then return false end
	return true

end

function EFFECT:Render()

	if ( self.Alpha < 1 ) then return end

	render.SetMaterial( self.Mat )

	render.DrawQuadEasy( self:GetPos(), self:GetAngles():Forward(), self.Size, self.Size, Color( 255, math.Rand( 215, 239 ), 16, self.Alpha ) )

end
