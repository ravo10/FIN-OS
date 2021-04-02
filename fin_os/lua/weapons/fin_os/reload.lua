local lastReloadTime = CurTime()

local function RemoveFlapFromFin( ent )

    -- Remove flap from fin
    ent:SetNWBool( "fin_os_is_a_fin_flap", false )
    local FIN_FLAP_FINPARENTENT = ent:GetNWEntity( "fin_os_flap_finParentEntity", nil )

    FIN_FLAP_FINPARENTENT:SetNWEntity( "fin_os_flapEntity", nil )
    ent:SetNWEntity( "fin_os_flap_finParentEntity", nil )

    FINOS_AddDataToEntFinTable( ent, "fin_os__EntAngleProperties", nil )

end

function SWEP:Reload()

    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() ) then return false end

    -- Prevent to fast reload
    if CurTime() - lastReloadTime < 0.7 then return false end lastReloadTime = CurTime()

    local OWNER = self:GetOwner()
    local WEAPON = OWNER:GetActiveWeapon()
    local ENT = tr.Entity

    -- Remove fin or flap
    if ENT and ENT:IsValid() then

        -- Remove disabling tool gun
        self:SetDisableTool( false )
        timer.Remove("fin_os__EntAreaPointCrossingLinesTIMER")

        if ENT:GetNWBool( "fin_os_is_a_fin_flap" ) then

            RemoveFlapFromFin( ENT )

            self:AlertPlayer( "[FLAP] **Removed attachment to a fin" )
            FINOS_SendNotification( "[FLAP] Removed att. to a FIN OS fin", FIN_OS_NOTIFY_CLEANUP, OWNER )

            -- Play sound
            WEAPON:EmitSound( "garrysmod/save_load1.wav", 30, 300 )

            self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
            return true

        end

        -- Reset prop to normal
        local foundOneFinWing = false

        -- Remove fin_os_brain
        local prevFinOSBrain = ENT:GetNWEntity( "fin_os_brain" )
        if prevFinOSBrain and prevFinOSBrain:IsValid() then foundOneFinWing = true prevFinOSBrain:Remove() end
        
        if not foundOneFinWing and ENT[ "FinOS_data" ]  and ENT[ "FinOS_data" ][ "fin_os__EntAreaPoints" ] then

            -- Reset area points
            FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaPoints", nil )
            self:AlertPlayer( "**Removed one or two area points from fin" )
            FINOS_SendNotification( "Removed FIN OS area points", FIN_OS_NOTIFY_UNDO, OWNER )

            -- Play sound
            WEAPON:EmitSound( "garrysmod/save_load1.wav", 30, 200 )

        end

        if not foundOneFinWing then return false end

        -- CLEAN UP
        -- Empty all data
        FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaPoints", nil )
        FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaVectors", nil )
        FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaVectorLinesParameter", nil )
        FINOS_AddDataToEntFinTable( ENT, "fin_os__EntAreaPointCrossingLines", nil )
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

        -- Remove fin
        if ENT:GetNWEntity( "fin_os_flapEntity" ):IsValid() then RemoveFlapFromFin( ENT:GetNWEntity( "fin_os_flapEntity" ) ) end

        -- Done Cleaning up..
        self:AlertPlayer( "**Removed all Fin OS settings from prop" )
        FINOS_SendNotification( "Removed Fin OS", FIN_OS_NOTIFY_CLEANUP, OWNER, 3.5 )

        -- Play sound
        WEAPON:EmitSound( "garrysmod/save_load2.wav", 70, 200 )

        self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
        return true

    end

end
