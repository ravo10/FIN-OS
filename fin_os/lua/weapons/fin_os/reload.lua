local nextReload = CurTime()
function SWEP:Reload()
    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() ) then return false end

    if CurTime() - nextReload < 1 then
        return false
    end
    nextReload = CurTime()

    local WEAPON = self.Weapon
    local ENT = tr.Entity

    -- Reset prop to normal
    local foundOneFinWing = false

    -- Remove fin_os_brain
    local prevFinOSBrain = ENT:GetNWEntity("fin_os_brain")
    if prevFinOSBrain and prevFinOSBrain:IsValid() then foundOneFinWing = true prevFinOSBrain:Remove() end
    
    if not foundOneFinWing and ENT:GetNWString( "fin_os__EntAreaPoints", false ) and #ENT:GetNWString( "fin_os__EntAreaPoints", false ) > 0 then
        -- Reset area points
        ENT:SetNWString( "fin_os__EntAreaPoints", nil )
        self:AlertPlayer("**Removed one or two area points from fin")

        -- Play sound
        WEAPON:EmitSound( "garrysmod/save_load1.wav", 30, 200 )
    end

    if not foundOneFinWing then return false end

    -- CLEAN UP
    -- Empty all data
    ENT:SetNWString( "fin_os__EntAreaPoints", "" )
    ENT:SetNWString( "fin_os__EntAreaVectors", "" )
    ENT:SetNWString( "fin_os__EntAngleProperties", "" )
    ENT:SetNWString( "fin_os__EntPhysicsProperties", "" )

    ENT:SetNWBool("fin_os_active", false)

    duplicator.ClearEntityModifier(ENT, "FinOS")

    -- Done Cleaning up..
    self:AlertPlayer("**Removed all Fin OS settings from prop")

    -- Play sound
    WEAPON:EmitSound( "garrysmod/save_load2.wav", 70, 200 )

    self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
    return true
end
