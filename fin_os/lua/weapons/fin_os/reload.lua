local lastReloadTime = CurTime()

function SWEP:Reload()

    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() ) then return false end

    -- Prevent to fast reload
    if CurTime() - lastReloadTime < 0.7 then return false end lastReloadTime = CurTime()

    local OWNER = self.Owner
    local WEAPON = self.Weapon
    local ENT = tr.Entity

    -- Reset prop to normal
    local foundOneFinWing = false

    -- Remove fin_os_brain
    local prevFinOSBrain = ENT:GetNWEntity( "fin_os_brain" )
    if prevFinOSBrain and prevFinOSBrain:IsValid() then foundOneFinWing = true prevFinOSBrain:Remove() end
    
    if not foundOneFinWing and ENT[ "FinOS_data" ][ "fin_os__EntAreaPoints" ] then

        -- Reset area points
        FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaPoints", nil )
        self:AlertPlayer( "**Removed one or two area points from fin" )

        -- Play sound
        WEAPON:EmitSound( "garrysmod/save_load1.wav", 30, 200 )

    end

    if not foundOneFinWing then return false end

    -- CLEAN UP
    -- Empty all data
    FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaPoints", nil )
    FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaVectors", nil )
    FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAngleProperties", nil )
    FINOS_AddDataToEntFinTable( ENT, "fin_os__EntPhysicsProperties", nil )

    ENT:SetNWBool( "fin_os_active", false )

    -- If the Player has this fin as the tracked one
    if OWNER:GetNWEntity( "fin_os_tracked_fin" ):IsValid() and OWNER:GetNWEntity( "fin_os_tracked_fin" ) == ENT then

        OWNER:SetNWEntity( "fin_os_tracked_fin", nil )

        FINOS_AddDataToEntFinTable( OWNER, "fin_os__EntBeingTracked", nil, OWNER )

    end

    -- Remove saved duplicator settings for entity
    duplicator.ClearEntityModifier( ENT, "FinOS" )

    -- Done Cleaning up..
    self:AlertPlayer( "**Removed all Fin OS settings from prop" )

    -- Play sound
    WEAPON:EmitSound( "garrysmod/save_load2.wav", 70, 200 )

    self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
    return true

end
