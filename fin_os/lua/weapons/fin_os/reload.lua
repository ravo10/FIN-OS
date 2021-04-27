local lastReloadTime = CurTime()

function SWEP:Reload()

    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() ) then return end

    -- Prevent to fast reload
    if CurTime() - lastReloadTime < 0.7 then return end lastReloadTime = CurTime()

    local OWNER = self:GetOwner()
    local Entity = tr.Entity

    -- Remove fin or flap
    if Entity and Entity:IsValid() then

        -- Check if it is actually a fin or flap
        if not Entity[ "FinOS_data" ] and ( not Entity:GetNWBool( "fin_os_is_a_fin_flap" ) and not Entity:GetNWBool( "fin_os_active" ) ) then

            FINOS_SendNotification( "This is not a FIN OS fin or flap!", FIN_OS_NOTIFY_ERROR, OWNER, 3 )
            return

        end

        -- Remove disabling tool gun
        self:SetDisableTool( false )
        timer.Remove( "fin_os__EntAreaPointCrossingLinesTIMER000" .. self:EntIndex() )
        timer.Remove( "fin_os__EntAreaPointCrossingLinesTIMER001" .. self:EntIndex() )

        if Entity:GetNWBool( "fin_os_is_a_fin_flap" ) then

            FINOS_RemoveFlapFromFin( Entity )

            FINOS_AlertPlayer( "[FLAP] **Removed Flap from fin", OWNER )
            FINOS_SendNotification( "[FLAP] Removed Flap from fin", FIN_OS_NOTIFY_CLEANUP, OWNER, 3.5 )

            -- Play sound
            OWNER:EmitSound( "garrysmod/save_load1.wav", 30, 300 )

            self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
            return

        end

        -- Reset prop to normal
        if not Entity:GetNWBool( "fin_os_is_a_fin_flap" ) and not FINOS_RemoveFinAndDataFromEntity( Entity, OWNER, true ) then

            -- Reset area points
            FINOS_AlertPlayer( "**Removed one or two area points from fin", OWNER )
            FINOS_SendNotification( "Removed FIN OS area points", FIN_OS_NOTIFY_UNDO, OWNER )

            -- Play sound
            OWNER:EmitSound( "garrysmod/save_load1.wav", 30, 200 )
            return

        end

        -- Clean up any flap entities
        self:SetTempFlapRelatedEntity0( nil )
        self:SetTempFlapRelatedEntity1( nil )

        -- Done Cleaning up..
        FINOS_AlertPlayer( "**Removed all FIN OS settings from prop", OWNER )
        FINOS_SendNotification( "Removed FIN OS fin", FIN_OS_NOTIFY_CLEANUP, OWNER, 3.5 )

        -- Play sound
        OWNER:EmitSound( "garrysmod/save_load2.wav", 70, 200 )

        self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
        return

    end

end
