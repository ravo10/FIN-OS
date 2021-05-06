function SWEP:SecondaryAttack()

    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() or self:GetDisableTool() ) then return end

    local OWNER = self:GetOwner()
    local Entity = tr.Entity

    if Entity and Entity:IsValid() and Entity:GetNWBool( "fin_os_active" ) then

        -- Maybe add the current viewed entity fin wing to the panel, or hide panel
        local currentTrackedWingEntity = OWNER:GetNWEntity( "fin_os_tracked_fin" )
        local nextFinWingEntity = Entity

        if currentTrackedWingEntity:IsValid() and nextFinWingEntity:IsValid() and currentTrackedWingEntity == nextFinWingEntity then

            -- Reset
            OWNER:SetNWEntity( "fin_os_tracked_fin", nil )
            
            FINOS_AddDataToEntFinTable( OWNER, "fin_os__EntBeingTracked", nil, OWNER )

            FINOS_SendNotification( "Not tracking this Fin", FIN_OS_NOTIFY_GENERIC, OWNER, 2.5 )

        else

            OWNER:SetNWEntity( "fin_os_tracked_fin", nextFinWingEntity )

            FINOS_AddDataToEntFinTable( OWNER, "fin_os__EntBeingTracked", nil, OWNER )

            FINOS_SendNotification( "Tracking this Fin", FIN_OS_NOTIFY_GENERIC, OWNER, 2.5 )

        end

        self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
        return

    elseif Entity and Entity:IsValid() then

        FINOS_SendNotification( "You can only track a FIN OS Fin!", FIN_OS_NOTIFY_ERROR, OWNER, 1.5 )

    end

    return

end
