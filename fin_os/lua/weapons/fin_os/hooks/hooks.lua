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

            local ENT = pl:GetEyeTrace().Entity

            if ENT and ENT:IsValid() and ENT:GetNWBool( "fin_os_active" ) and pl:GetActiveWeapon():GetClass() == "fin_os" then

                local scalarValue = ENT[ "FinOS_LiftForceScalarValue" ]
                if not scalarValue then ENT[ "FinOS_LiftForceScalarValue" ] = FINOS_DEFAULT_SCALAR_LIFT_FORCE_VALUE end

                local newScalarValue = scalarValue

                if mouseWheelScrollDelta > 0 then newScalarValue = newScalarValue + 0.5 else newScalarValue = newScalarValue - 0.5 end
                if newScalarValue < 0.5 then newScalarValue = 0.5 elseif newScalarValue > GetConVar( "finos_maxscalarvalue" ):GetInt() then newScalarValue = GetConVar( "finos_maxscalarvalue" ):GetInt() end

                -- Store new scalar value
                ENT[ "FinOS_LiftForceScalarValue" ] = newScalarValue

                -- Send to client
                net.Start( "FINOS_UpdateEntityScalarLiftForceValue_CLIENT" )

                    net.WriteTable({

                        ent = ENT,
                        FinOS_LiftForceScalarValue = newScalarValue

                    })
                
                net.Broadcast()

            end

        end

    end

end )
