-- ///////////////////////////////////////////////////////////////////////////////
-- HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS
-- HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS
-- HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS
-- ///////////////////////////////////////////////////////////////////////////////

hook.Add( "SetupMove", "fin_os:SetupMove", function( pl, mv, cmd )

    if mv:KeyDown( IN_USE ) then

        local mouseWheelScrollDelta = cmd:GetMouseWheel()

        -- Change the slowdown effect up or down
        if mouseWheelScrollDelta ~= 0 then

            local Entity = pl:GetEyeTrace().Entity

            if Entity and Entity:IsValid() and Entity:GetNWBool( "fin_os_active" ) and pl:GetActiveWeapon():GetClass() == "fin_os" then

                local scalarValue = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", "ID31" )[ "FinOS_LiftForceScalarValue_Normal" ]

                local newScalarValue = scalarValue
                local SCALE = 0.1

                if mouseWheelScrollDelta > 0 then newScalarValue = newScalarValue + SCALE else newScalarValue = newScalarValue - SCALE end
                if newScalarValue < SCALE then newScalarValue = SCALE elseif newScalarValue > GetConVar( "finos_maxscalarvalue" ):GetInt() then newScalarValue = GetConVar( "finos_maxscalarvalue" ):GetInt() end

                -- Store new scalar value
                FINOS_AddDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", { FinOS_LiftForceScalarValue_Normal = newScalarValue }, nil, "ID30" )

                -- Store for duplication
                FINOS_WriteDuplicatorDataForEntity( Entity )

            end

        end

    end

end )
