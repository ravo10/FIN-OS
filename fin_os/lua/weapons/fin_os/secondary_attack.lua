function SWEP:SecondaryAttack()
    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() ) then return false end

    local OWNER = self.Owner
    local ENT = tr.Entity

    if ENT:GetNWBool("fin_os_active", false) and OWNER:KeyDown(IN_USE) then

        -- Turn Show settings on/off
        if ENT:GetNWBool("fin_os_show_settings", false) then ENT:SetNWBool("fin_os_show_settings", false) else
            ENT:SetNWBool("fin_os_show_settings", true)
        end

    else
        self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
    end

    return true
end
