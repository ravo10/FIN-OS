function SWEP:PrimaryAttack()
    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() ) then return false end

    local ENT = tr.Entity
    local OWNER = self:GetOwner()

    if ENT and ENT:IsValid() and not ENT:GetNWBool( "fin_os_is_a_fin_flap" ) then

        if not OWNER:KeyDown( IN_USE ) then

            -- Set vector points on wing for area calculations
            self:SetAreaPointsForFin( tr )
            self:CalculateAreaForFinBasedOnAreaPoints( ENT, OWNER )

            local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAreaPoints", "ID11" )
            if #AREAPOINTSTABLE > 2 then FINOS_AddFinWingEntity( ENT, OWNER ) end

            -- Effect
            self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
            return true

        else

            -- Connect a flap to fin
            if not self:GetTempFlapRelatedEntity0() or not self:GetTempFlapRelatedEntity0():IsValid() then

                self:SetTempFlapRelatedEntity0( ENT )

                self:AlertPlayer( "[FLAP] Selected entity #1" )
                FINOS_SendNotification( "[FLAP] Selected 1 of 2 entities", FIN_OS_NOTIFY_GENERIC, OWNER )

            elseif ENT ~= self:GetTempFlapRelatedEntity0() then

                self:SetTempFlapRelatedEntity1( ENT )

                self:AlertPlayer( "[FLAP] Selected entity #2" )

            else

                -- Reset
                self:SetTempFlapRelatedEntity0( nil )
                self:SetTempFlapRelatedEntity1( nil )

                self:AlertPlayer( "[FLAP] Same entity! Try again" )
                FINOS_SendNotification( "[FLAP] Same entity! Try again", FIN_OS_NOTIFY_ERROR, OWNER )

            end

            local ENT0 = self:GetTempFlapRelatedEntity0()
            local ENT1 = self:GetTempFlapRelatedEntity1()

            -- Maybe create a flap, if ONE of the entities are a fin
            if ENT0:IsValid() and ENT1:IsValid() and ( ENT0:GetNWBool( "fin_os_active" ) and not ENT1:GetNWBool( "fin_os_active" ) ) or ( not ENT0:GetNWBool( "fin_os_active" ) and ENT1:GetNWBool( "fin_os_active" ) ) then

                local ENT_FIN
                local ENT_FLAP

                -- Sort out the one that is the fin
                if ENT0:GetNWBool( "fin_os_active" ) then ENT_FIN = ENT0 ENT_FLAP = ENT1 else ENT_FIN = ENT1 ENT_FLAP = ENT0 end

                -- Create the flap data structure ( same as the fin )
                ENT_FLAP:SetNWBool( "fin_os_is_a_fin_flap", true )
                ENT_FLAP:SetNWEntity( "fin_os_flap_finParentEntity", ENT_FIN )

                local currentEntAngle = ENT_FLAP:GetAngles()

                FINOS_AddDataToEntFinTable( ENT_FLAP, "fin_os__EntAngleProperties", {

                    BaseAngle = currentEntAngle

                }, nil, "ID11" )

                ENT_FIN:SetNWEntity( "fin_os_flapEntity", ENT_FLAP )

                self:AlertPlayer( "[FLAP] Current base angle (P, Y, R) set to: (" .. math.Round( currentEntAngle[ 1 ] ) .. ", " .. math.Round( currentEntAngle[ 2 ] ) .. ", " .. math.Round( currentEntAngle[ 3 ] ) .. ")" )
                self:AlertPlayer( "[FLAP] Flap added to fin! Area is preset to ¼ of the fin area" )
                FINOS_SendNotification( "[FLAP] Flap added to fin! Area is ¼ of the fin", FIN_OS_NOTIFY_GENERIC, OWNER, 3.5 )

                self:SetTempFlapRelatedEntity0( nil )
                self:SetTempFlapRelatedEntity1( nil )

            elseif ENT0:IsValid() and ENT1:IsValid() and not ENT0:GetNWBool( "fin_os_active" ) and not ENT1:GetNWBool( "fin_os_active" ) then

                self:SetTempFlapRelatedEntity0( nil )
                self:SetTempFlapRelatedEntity1( nil )

                self:AlertPlayer( "[FLAP] Select a Fin and Flap! Try again" )
                FINOS_SendNotification( "[FLAP] Select a Fin and Flap! Try again", FIN_OS_NOTIFY_ERROR, OWNER, 3 )

            end

            self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
            return true

        end

    elseif OWNER:KeyDown( IN_USE ) and ENT and ENT:IsValid() and ENT:GetNWBool( "fin_os_is_a_fin_flap" ) then

        self:AlertPlayer( "[FLAP] This entity is already a flap! Reload to remove from fin" )
        FINOS_SendNotification( "[FLAP] This entity is already a flap!", FIN_OS_NOTIFY_ERROR, OWNER )

    end

    return false
end
