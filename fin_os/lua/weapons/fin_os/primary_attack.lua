function SWEP:PrimaryAttack()

    local tr = self:GetTrace()
    if ( not tr.Hit or not tr.Entity or not tr.Entity:IsValid() or self:GetDisableTool() ) then return false end

    local Entity = tr.Entity
    local OWNER = self:GetOwner()

    if Entity and Entity:IsValid() and not Entity:GetNWBool( "fin_os_is_a_fin_flap" ) then

        if not OWNER:KeyDown( IN_USE ) then

            -- Importtant
            -- Set vector points on wing for area calculations
            local areAnyVectorLinesCrossingOrAngleHitNormalNotOK = FINOS_SetAreaPointsForFin( tr, OWNER, self )
            local IsWitinArea = false

            local AREAPOINTSTABLE = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPoints", "ID11" )

            if not areAnyVectorLinesCrossingOrAngleHitNormalNotOK then

                -- Check if trace hitPoint is witin area
                IsWitinArea = FINOS_CheckIfLastPointIsWithingAreaOfTriangle( Entity, OWNER, AREAPOINTSTABLE, self )

                if IsWitinArea then FINOS_CalculateAreaForFinBasedOnAreaPoints( Entity, OWNER, false, false ) end

            end

            if IsWitinArea and not areAnyVectorLinesCrossingOrAngleHitNormalNotOK then

                amountOfPointsUsed = #AREAPOINTSTABLE

                local localHitPos = Entity:WorldToLocal( tr.HitPos )

                local alfabethTable = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" };
                FINOS_AlertPlayer( "Added local area point: " .. alfabethTable[ amountOfPointsUsed ] .. "(" .. math.Round( localHitPos[ 1 ] ) .. ", " .. math.Round( localHitPos[ 2 ] ) .. ", " .. math.Round( localHitPos[ 3 ] ) .. ")", OWNER )

                if amountOfPointsUsed == 1 then
                    
                    FINOS_AlertPlayer( "*Add two or more points..", OWNER )
                    FINOS_SendNotification( "Add two or more points..", FIN_OS_NOTIFY_GENERIC, OWNER, 1.3 )

                end

            end

            if IsWitinArea and #AREAPOINTSTABLE > 2 then FINOS_AddFinWingEntity( Entity, OWNER ) end

            -- Effect
            self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
            return false

        else

            -- Connect a flap to fin
            if not self:GetTempFlapRelatedEntity0() or not self:GetTempFlapRelatedEntity0():IsValid() then

                self:SetTempFlapRelatedEntity0( Entity )

                FINOS_AlertPlayer( "[FLAP] Selected entity #1", OWNER )
                FINOS_SendNotification( "[FLAP] Selected 1 of 2 entities", FIN_OS_NOTIFY_GENERIC, OWNER )

            elseif Entity ~= self:GetTempFlapRelatedEntity0() then

                self:SetTempFlapRelatedEntity1( Entity )

                FINOS_AlertPlayer( "[FLAP] Selected entity #2", OWNER )

            else

                -- Reset
                self:SetTempFlapRelatedEntity0( nil )
                self:SetTempFlapRelatedEntity1( nil )

                FINOS_AlertPlayer( "[FLAP] Same entity! Try again", OWNER )
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

                FINOS_AlertPlayer( "[FLAP] Current base angle (P, Y, R) set to: (" .. math.Round( currentEntAngle[ 1 ] ) .. ", " .. math.Round( currentEntAngle[ 2 ] ) .. ", " .. math.Round( currentEntAngle[ 3 ] ) .. ")", OWNER )
                FINOS_AlertPlayer( "[FLAP] Flap added to fin! Area is preset to ¼ of the fin area", OWNER )
                FINOS_SendNotification( "[FLAP] Flap added to fin! Area is ¼ of the fin", FIN_OS_NOTIFY_GENERIC, OWNER, 3.5 )

                self:SetTempFlapRelatedEntity0( nil )
                self:SetTempFlapRelatedEntity1( nil )

            elseif ENT0:IsValid() and ENT1:IsValid() and not ENT0:GetNWBool( "fin_os_active" ) and not ENT1:GetNWBool( "fin_os_active" ) then

                self:SetTempFlapRelatedEntity0( nil )
                self:SetTempFlapRelatedEntity1( nil )

                FINOS_AlertPlayer( "[FLAP] Select a Fin and Flap! Try again", OWNER )
                FINOS_SendNotification( "[FLAP] Select a Fin and Flap! Try again", FIN_OS_NOTIFY_ERROR, OWNER, 3 )

            end

            self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted() )
            return true

        end

    elseif OWNER:KeyDown( IN_USE ) and Entity and Entity:IsValid() and Entity:GetNWBool( "fin_os_is_a_fin_flap" ) then

        FINOS_AlertPlayer( "[FLAP] This entity is already a flap! Reload to remove from fin", OWNER )
        FINOS_SendNotification( "[FLAP] This entity is already a flap!", FIN_OS_NOTIFY_ERROR, OWNER )

    end

    return false

end
