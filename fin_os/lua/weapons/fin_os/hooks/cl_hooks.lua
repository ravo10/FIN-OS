local WingCorrectWayUp = function( rollCosinusFraction, pitchAttackAngle )
    
    if ( rollCosinusFraction ~= 0 or math.abs( pitchAttackAngle ) ~= 0 ) and math.abs( pitchAttackAngle ) < 90 then return "Yes" else return "No" end

end

hook.Add( "HUDPaint", "fin_os:fin_display_settings", function()

    local Player = LocalPlayer()

    if Player and Player:IsValid() then

        local tr = Player:GetEyeTrace()

        local ENT = tr.Entity

        -- If player looks at a fin, maybe show the current settings/values
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

                local backgroundPosX = ( ScrW() - 300 - 20 )
                local backgroundPosY = 250

                local textColor = Color( 255, 255, 255, 255 )

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
                    textColor,
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "(ravo Norway)",
                    "HudSelectionText",
                    ( backgroundPosX + 150 ),
                    ( backgroundPosY - 45 ),
                    textColor,
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
                    textColor,
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "Roll Angle Cosinus Fraction: "..rollCosinusFraction,
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 2 ),
                    textColor,
                    TEXT_ALIGN_LEFT
                )

                draw.DrawText(
                    "Speed: "..speed.." km/h",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 ),
                    textColor,
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "Force[LIFT]: "..force_lift.." N",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 ),
                    textColor,
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "Area: "..area_meter_squared.." m²",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 3 ),
                    textColor,
                    TEXT_ALIGN_LEFT
                )
                
                draw.DrawText(
                    "Wing correct way up?: "..WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle ),
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 4 + 20 ),
                    textColor,
                    TEXT_ALIGN_LEFT
                )
                
                draw.DrawText(
                    "Scalar ( Force[LIFT] ): "..ENT[ "FinOS_LiftForceScalarValue" ],
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 4 + 20 * 2 ),
                    textColor,
                    TEXT_ALIGN_LEFT
                )

            end

        end

        -- Display tracked fin entity
        local PHYSICSPROPERTIESSTABLE = FINOS_GetDataToEntFinTable( Player, "fin_os__EntBeingTracked" )

        if PHYSICSPROPERTIESSTABLE and PHYSICSPROPERTIESSTABLE["FinBeingTracked"] and PHYSICSPROPERTIESSTABLE["FinBeingTracked"]:IsValid() then

            local width = 150

            local backgroundPosX = ( ScrW() - width - 20 )
            local backgroundPosY = 250 + 210

            local pitchAttackAngle = math.Round( PHYSICSPROPERTIESSTABLE[ "Main_Fin_AttackAngle_Pitch" ] )
            local rollCosinusFraction = PHYSICSPROPERTIESSTABLE[ "Main_Fin_AttackAngle_RollCosinus" ]

            local speed = math.Round( PHYSICSPROPERTIESSTABLE[ "VelocityKmH" ] )
            local force_lift = math.Round( PHYSICSPROPERTIESSTABLE[ "LiftForceNewtonsNotModified" ] )
            local area_meter_squared = math.Round( PHYSICSPROPERTIESSTABLE[ "AreaMeterSquared" ], 2 )

            draw.RoundedBox( 8,
                backgroundPosX,
                backgroundPosY,
                width,
                77,
                Color( 255, 255, 0, 143 ) -- yellow
            )

            local textColor = Color( 0, 0, 0, 200 )

            draw.DrawText(
                "AAA: "..pitchAttackAngle.."˚",
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 ),
                textColor,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText(
                "U up ?: "..WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle ),
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 + 12 ),
                textColor,
                TEXT_ALIGN_LEFT
            )

            draw.DrawText(
                "Speed: "..speed.." km/h",
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 * 3 + 12 + 4 ),
                textColor,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText(
                "Force[LIFT]: "..force_lift.." N",
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 * 3 + 12 * 2 + 4 ),
                textColor,
                TEXT_ALIGN_LEFT
            )

        end

    end

end )

hook.Add( "PreDrawTranslucentRenderables", "fin_os:fin_area_visualizer", function( isDrawingDepth, isDrawSkybox )

    local Player = LocalPlayer()

    if Player and Player:IsValid() then

        local tr = Player:GetEyeTrace()

        local ENT = tr.Entity

        if Player and Player:IsValid() and Player:GetActiveWeapon():GetClass() == "fin_os" and ENT and ENT:IsValid() then

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

            -- Draw lines between points, so the player can see that no vector points are crossing eachother
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

hook.Add("HUDShouldDraw", "fin_os:HUDShouldDraw", function( name )

	-- When Player is in slow motion
	if LocalPlayer() and LocalPlayer():GetNWBool( "PlayerIsLookingAtFinAndChangingScalarValue" ) and name == "CHudWeaponSelection" then return false end

end)
