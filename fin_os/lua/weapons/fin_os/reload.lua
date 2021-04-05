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
    local Entity = tr.Entity

    -- Remove fin or flap
    if Entity and Entity:IsValid() then

        -- Remove disabling tool gun
        self:SetDisableTool( false )
        timer.Remove( "fin_os__EntAreaPointCrossingLinesTIMER000" .. self:EntIndex() )
        timer.Remove( "fin_os__EntAreaPointCrossingLinesTIMER001" .. self:EntIndex() )

        if Entity:GetNWBool( "fin_os_is_a_fin_flap" ) then

            RemoveFlapFromFin( Entity )

            FINOS_AlertPlayer( "[FLAP] **Removed flap attachment to a fin", OWNER )
            FINOS_SendNotification( "[FLAP] Removed flap att. to a FIN OS fin", FIN_OS_NOTIFY_CLEANUP, OWNER, 3.5 )

            -- Play sound
            WEAPON:EmitSound( "garrysmod/save_load1.wav", 30, 300 )

            self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
            return true

        end

        -- Reset prop to normal
        local foundOneFinWing = false

        -- Remove fin_os_brain
        local prevFinOSBrain = Entity:GetNWEntity( "fin_os_brain" )
        if prevFinOSBrain and prevFinOSBrain:IsValid() then foundOneFinWing = true prevFinOSBrain:Remove() end
        
        if not foundOneFinWing and Entity[ "FinOS_data" ] and Entity[ "FinOS_data" ][ "fin_os__EntAreaPoints" ] then

            -- Reset area points
            FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaPoints", nil )
            FINOS_AlertPlayer( "**Removed one or two area points from fin", OWNER )
            FINOS_SendNotification( "Removed FIN OS area points", FIN_OS_NOTIFY_UNDO, OWNER )

            -- Play sound
            WEAPON:EmitSound( "garrysmod/save_load1.wav", 30, 200 )

        end

        if not foundOneFinWing then return false end

        -- CLEAN UP
        -- Empty all data
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaPoints", nil )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaVectors", nil )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaVectorLinesParameter", nil )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaPointCrossingLines", nil )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAreaAcceptedAngleAndHitNormal", nil )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntAngleProperties", nil )
        FINOS_AddDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", nil )

        Entity:SetNWBool( "fin_os_active", false )

        -- If the Player has this fin as the tracked one
        if OWNER:GetNWEntity( "fin_os_tracked_fin" ):IsValid() and OWNER:GetNWEntity( "fin_os_tracked_fin" ) == Entity then

            OWNER:SetNWEntity( "fin_os_tracked_fin", nil )

            FINOS_AddDataToEntFinTable( OWNER, "fin_os__EntBeingTracked", nil, OWNER )

        end

        -- Remove saved duplicator settings for entity
        duplicator.ClearEntityModifier( Entity, "FinOS" )

        -- Remove fin
        if Entity:GetNWEntity( "fin_os_flapEntity" ):IsValid() then RemoveFlapFromFin( Entity:GetNWEntity( "fin_os_flapEntity" ) ) end

        -- Done Cleaning up..
        FINOS_AlertPlayer( "**Removed all FIN OS settings from prop", OWNER )
        FINOS_SendNotification( "Removed FIN OS fin", FIN_OS_NOTIFY_CLEANUP, OWNER, 3.5 )

        -- Play sound
        WEAPON:EmitSound( "garrysmod/save_load2.wav", 70, 200 )

        self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
        return true

    end

end
