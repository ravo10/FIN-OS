hook.Add( "HUDPaint", "fin_os:fin_display_settings", function()

    local Player = LocalPlayer()

    if Player and Player:IsValid() then

        local tr = Player:GetEyeTrace()

        local ENT = tr.Entity

        -- If player looks at a fin, maybe show the current settings/values
        -- and LocalPlayer():GetNWBool( "fin_os_show_settings" )
        if ENT and ENT:IsValid() and ENT:GetNWBool( "fin_os_active" ) then

            local MainFinSettingsTable = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAngleProperties" )
            local MainFinPhysicsPropertiesTable = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntPhysicsProperties" )

            if
                ( MainFinSettingsTable[ "Main_Fin_AttackAngle_Pitch" ] and MainFinSettingsTable[ "Main_Fin_AttackAngle_RollCosinus" ] ) and
                ( MainFinPhysicsPropertiesTable[ "VelocityKmH" ] and MainFinPhysicsPropertiesTable[ "LiftForceNewtonsModified_beingUsed" ] and MainFinPhysicsPropertiesTable[ "LiftForceNewtonsNotModified" ] and MainFinPhysicsPropertiesTable[ "AreaMeterSquared" ] )
            then

                -- Show important values to user on screen
                local pitchAttackAngle = math.Round( MainFinSettingsTable[ "Main_Fin_AttackAngle_Pitch" ] )
                local rollCosinusFraction = MainFinSettingsTable[ "Main_Fin_AttackAngle_RollCosinus" ]

                local speed = math.Round( MainFinPhysicsPropertiesTable[ "VelocityKmH" ] )
                local force_lift = math.Round( MainFinPhysicsPropertiesTable[ "LiftForceNewtonsNotModified" ] )
                local area_meter_squared = math.Round( MainFinPhysicsPropertiesTable[ "AreaMeterSquared" ], 2 )

                local wingCorrectWayUp = function() if ( rollCosinusFraction ~= 0 or math.abs( pitchAttackAngle ) ~= 0 ) and math.abs( pitchAttackAngle ) < 90 then return "Yes" else return "No" end end

                local backgroundPosX = ( ScrW() - 300 - 20 )
                local backgroundPosY = 250

                

                draw.RoundedBox( 8,
                    backgroundPosX,
                    ( backgroundPosY - 60 - 5 ),
                    300,
                    60,
                    Color( 90, 90, 90, 110 ) -- light Gray
                )
                draw.DrawText(
                    "FIN OS",
                    "Trebuchet24",
                    ( backgroundPosX + 60 ),
                    ( backgroundPosY - 45 ),
                    Color( 255, 255, 255, 255 ),
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "(ravo Norway)",
                    "HudSelectionText",
                    ( backgroundPosX + 150 ),
                    ( backgroundPosY - 45 ),
                    Color( 255, 255, 255, 255 ),
                    TEXT_ALIGN_LEFT
                )

                draw.RoundedBox( 8,
                    backgroundPosX,
                    backgroundPosY,
                    300,
                    200,
                    Color( 50, 50, 50, 230 ) -- lightBlack Gray
                )

                draw.DrawText(
                    "Air Attack Angle: "..pitchAttackAngle.."˚ (important)",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 ),
                    Color( 255, 255, 255, 255 ),
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "Roll Angle Cosinus Fraction: "..rollCosinusFraction,
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 2 ),
                    Color( 255, 255, 255, 255 ),
                    TEXT_ALIGN_LEFT
                )

                draw.DrawText(
                    "Speed: "..speed.." km/h",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 ),
                    Color( 255, 255, 255, 255 ),
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "Force[LIFT]: "..force_lift.." N",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 ),
                    Color( 255, 255, 255, 255 ),
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "Area: "..area_meter_squared.." m²",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 3 ),
                    Color( 255, 255, 255, 255 ),
                    TEXT_ALIGN_LEFT
                )
                
                draw.DrawText(
                    "Wing correct way up?: "..wingCorrectWayUp(),
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 4 + 20 ),
                    Color( 255, 255, 255, 255 ),
                    TEXT_ALIGN_LEFT
                )

            end

        end

    end

end )

hook.Add( "PreDrawTranslucentRenderables", "fin_os:fin_area_visualizer", function( isDrawingDepth, isDrawSkybox )

    local Player = LocalPlayer()

    if Player and Player:IsValid() then

        local tr = Player:GetEyeTrace()

        local ENT = tr.Entity

        if Player:GetActiveWeapon():GetClass() == "fin_os" and ENT and ENT:IsValid() then

            local MainFinAreaPointsTable = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAreaPoints" )

            if ENT:GetNWBool( "fin_os_active" ) then

                -- Draw the area visually on entity
                for k, _ in pairs( MainFinAreaPointsTable ) do

                    if k >= 3 then

                        render.SetMaterial( Material( "models/props_combine/stasisshield_sheet" ) )
                        render.DrawQuad(

                            ENT:LocalToWorld( MainFinAreaPointsTable[ 1 ] ),
                            ENT:LocalToWorld( MainFinAreaPointsTable[ k - 1 ] ),
                            ENT:LocalToWorld( MainFinAreaPointsTable[ k ] ),
                            ENT:LocalToWorld( MainFinAreaPointsTable[ 1 ] ),
                            Color( 255, 255, 255 )
                        )

                    end

                end

            end

            -- Draw lines between points, so the player can see that no vector points are crossing each other
            for k, v in pairs( MainFinAreaPointsTable ) do

                local point1 = v
                local point2 = MainFinAreaPointsTable[ k + 1 ]

                if point1 and point2 then

                    point1 = ENT:LocalToWorld( v )
                    point2 = ENT:LocalToWorld( MainFinAreaPointsTable[ k + 1 ] )

                    render.DrawLine( point1, point2, Color( 255, 121, 0 ), true )

                    if ( k + 1 ) == #MainFinAreaPointsTable then

                        render.DrawLine( point2, ENT:LocalToWorld( MainFinAreaPointsTable[ 1 ] ), Color( 255, 121, 0 ), true )

                    end

                end

            end

        end

    end

    return false

end )
