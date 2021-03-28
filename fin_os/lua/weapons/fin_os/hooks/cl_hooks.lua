hook.Add("HUDPaint", "fin_os:fin_display_settings", function()

    if LocalPlayer() and LocalPlayer():IsValid() then

        local tr = LocalPlayer():GetEyeTrace()

        local ENT = tr.Entity

        -- If player looks at a fin, maybe show the current settings/values
        if ENT and ENT:IsValid() and ENT:GetNWBool("fin_os_active", false) then

            local MainFinSettingsTable = util.JSONToTable( ENT:GetNWString( "fin_os__EntAngleProperties", "{}" ) ) or false
            local MainFinPhysicsPropertiesTable = util.JSONToTable( ENT:GetNWString( "fin_os__EntPhysicsProperties", "{}" ) ) or false

            if
                ( MainFinSettingsTable and MainFinSettingsTable["Main_Fin_AttackAngle_Pitch"] and MainFinSettingsTable["Main_Fin_AttackAngle_RollCosinus"] ) and
                ( MainFinPhysicsPropertiesTable and MainFinPhysicsPropertiesTable["VelocityKmH"] and MainFinPhysicsPropertiesTable["LiftForceNewtonsModified_beingUsed"] and MainFinPhysicsPropertiesTable["LiftForceNewtonsNotModified"] and MainFinPhysicsPropertiesTable["AreaMeterSquared"] )
            then
                -- Show important values to user on screen
                local pitchAttackAngle = math.Round(MainFinSettingsTable["Main_Fin_AttackAngle_Pitch"])
                local rollCosinusFraction = MainFinSettingsTable["Main_Fin_AttackAngle_RollCosinus"]

                local speed = math.Round(MainFinPhysicsPropertiesTable["VelocityKmH"])
                local force_lift = math.Round(MainFinPhysicsPropertiesTable["LiftForceNewtonsNotModified"])
                local area_meter_squared = math.Round(MainFinPhysicsPropertiesTable["AreaMeterSquared"], 2)

                local wingCorrectWayUp = function() if ( rollCosinusFraction ~= 0 or math.abs(pitchAttackAngle) ~= 0 ) and math.abs(pitchAttackAngle) < 90 then return "Yes" else return "No" end end

                local backgroundPosX = ( ScrW() - 300 - 20 )
                local backgroundPosY = 250

                draw.RoundedBox( 8,
                    backgroundPosX,
                    backgroundPosY - 60 - 5,
                    300,
                    60,
                    Color(90, 90, 90, 110) -- light Gray
                )
                draw.DrawText(
                    "FIN OS",
                    "Trebuchet24",
                    ( backgroundPosX + 60 ),
                    ( backgroundPosY - 45 ),
                    Color(255, 255, 255, 255),
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "(ravo Norway)",
                    "HudSelectionText",
                    ( backgroundPosX + 150 ),
                    ( backgroundPosY - 45 ),
                    Color(255, 255, 255, 255),
                    TEXT_ALIGN_LEFT
                )

                draw.RoundedBox( 8,
                    backgroundPosX,
                    backgroundPosY,
                    300,
                    200,
                    Color(50, 50, 50, 230) -- lightBlack Gray
                )

                draw.DrawText(
                    "Air Attack Angle: "..pitchAttackAngle.."˚ (important)",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 ),
                    Color(255, 255, 255, 255),
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "Roll Angle Cosinus Fraction: "..rollCosinusFraction,
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 2 ),
                    Color(255, 255, 255, 255),
                    TEXT_ALIGN_LEFT
                )

                draw.DrawText(
                    "Speed: "..speed.." km/h",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 ),
                    Color(255, 255, 255, 255),
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "Force[LIFT]: "..force_lift.." N",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 ),
                    Color(255, 255, 255, 255),
                    TEXT_ALIGN_LEFT
                )
                draw.DrawText(
                    "Area: "..area_meter_squared.." m²",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 3 ),
                    Color(255, 255, 255, 255),
                    TEXT_ALIGN_LEFT
                )
                
                draw.DrawText(
                    "Wing correct way up?: "..wingCorrectWayUp(),
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 4 + 20 ),
                    Color(255, 255, 255, 255),
                    TEXT_ALIGN_LEFT
                )
            end

        end

    end

end)
