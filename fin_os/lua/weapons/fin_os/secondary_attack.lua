function SWEP:SecondaryAttack()
    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() ) then return false end

    local OWNER = self.Owner
    local ENT = tr.Entity

    if OWNER:GetNWBool( "fin_os_active" ) and OWNER:KeyDown( IN_USE ) then

        -- Turn Show settings on/off
        if OWNER:GetNWBool( "fin_os_show_settings" ) then OWNER:SetNWBool( "fin_os_show_settings", false ) else

            OWNER:SetNWBool( "fin_os_show_settings", true )

        end

    else

        self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )

    end

    return true

end
