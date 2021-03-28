function SWEP:PrimaryAttack()
    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() ) then return false end

    local ENT = tr.Entity
    local OWNER = self.Owner

    if OWNER:KeyDown( IN_USE ) then return false end

    if ENT and ENT:IsValid() then

        -- Set vector points on wing for area calculations
        self:SetAreaPointsForFin( tr )
        self:CalculateAreaForFinBasedOnAreaPoints( ENT, OWNER )

        local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAreaPoints" )
        if #AREAPOINTSTABLE > 2 then FINOS_AddFinWingEntity( ENT, OWNER ) end

        -- Effect
        self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
        return true

    end

    return false
end
