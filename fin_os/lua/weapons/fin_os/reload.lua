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
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() ) then return end

    -- Prevent to fast reload
    if CurTime() - lastReloadTime < 0.7 then return end lastReloadTime = CurTime()

    local OWNER = self:GetOwner()
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
            OWNER:EmitSound( "garrysmod/save_load1.wav", 30, 300 )

            self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
            return

        end

        -- Reset prop to normal
        if not FINOS_RemoveFinAndDataFromEntity( Entity, OWNER, true ) then

            -- Reset area points
            FINOS_AlertPlayer( "**Removed one or two area points from fin", OWNER )
            FINOS_SendNotification( "Removed FIN OS area points", FIN_OS_NOTIFY_UNDO, OWNER )

            -- Play sound
            OWNER:EmitSound( "garrysmod/save_load1.wav", 30, 200 )
            return

        end

        -- Done Cleaning up..
        FINOS_AlertPlayer( "**Removed all FIN OS settings from prop", OWNER )
        FINOS_SendNotification( "Removed FIN OS fin", FIN_OS_NOTIFY_CLEANUP, OWNER, 3.5 )

        -- Play sound
        OWNER:EmitSound( "garrysmod/save_load2.wav", 70, 200 )

        self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
        return

    end

end
