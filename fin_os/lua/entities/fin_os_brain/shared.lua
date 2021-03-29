ENT.Base            = "base_entity"  --garrysmod\gamemodes\base\entities\entities
ENT.Type            = "anim"
ENT.ClassName       = "fin_os_brain"
ENT.Category        = "ravo Norway"
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.PrintName		= "Fin OS Wing"
ENT.Author			= "ravo (Norway)"
ENT.Contact			= "N/A"
ENT.Purpose			= "To make the Wing/Fin think and get physical with the air plane."
ENT.Instructions	= "Use it with the custom FIN OS SWEP."

function ENT:SetupDataTables()

    self:NetworkVar( "Vector", 0, "VelocityPointA" )
    self:NetworkVar( "Vector", 1, "VelocityPointB" )

    self:NetworkVar( "String", 0, "VelocityTimeA" )
    self:NetworkVar( "String", 1, "VelocityTimeB" )

    self:NetworkVar( "Bool", 0, "PointAAndTimeAAvailable" )
    self:NetworkVar( "Bool", 1, "PointBAndTimeBAvailable" )
    self:NetworkVar( "Bool", 2, "AllPointsAndTimesAvailable" )
    
    -- First time setup
    if SERVER then

        self:SetVelocityPointA( Vector(0, 0, 0) )
        self:SetVelocityPointB( Vector(0, 0, 0) )

        self:SetVelocityTimeA( "0" )
        self:SetVelocityTimeB( "0" )

        self:SetPointAAndTimeAAvailable( false )
        self:SetPointBAndTimeBAvailable( false )
        self:SetAllPointsAndTimesAvailable( false )

    end

end
