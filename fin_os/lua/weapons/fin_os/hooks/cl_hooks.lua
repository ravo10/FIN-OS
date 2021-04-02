-- ///////////////////////////////////////////////////////////////////////////////
-- HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS
-- HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS
-- HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS
-- ///////////////////////////////////////////////////////////////////////////////

-- Check if fin is correct way up
local function WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle )

    if ( rollCosinusFraction ~= 0 or math.abs( pitchAttackAngle ) ~= 0 ) and math.abs( pitchAttackAngle ) < 90 then return "Yes" else return "No" end

end

-- Disable scrolling when player is changing the scalar for Lift Force
local function DisabledScrollingMenuClient( pl, key, disable )

    if key == IN_USE and pl:GetActiveWeapon():GetClass() == "fin_os" then

        -- Update
        LocalPlayer():SetNWBool( "PlayerIsLookingAtFinAndChangingScalarValue", disable )

    end

end

hook.Add( "KeyPress", "fin_os:KeyPress", function( pl, key ) DisabledScrollingMenuClient( pl, key, true ) end )
hook.Add( "KeyRelease", "fin_os:KeyRelease", function( pl, key ) DisabledScrollingMenuClient( pl, key, false ) end )

hook.Add( "HUDPaint", "fin_os:fin_display_settings", function()

    local Player = LocalPlayer()

    if Player and Player:IsValid() then

        local tr = Player:GetEyeTrace()

        local ENT = tr.Entity

        if Player:GetActiveWeapon():GetClass() == "fin_os" then

            local backgroundPosX = ( ScrW() - 300 - 20 )
            local backgroundPosY = 60 + 37

            local textColor = Color( 255, 255, 255, 255 )

            draw.RoundedBox( 8,
                backgroundPosX,
                ( backgroundPosY - 60 + 17 ),
                300,
                48,
                Color( 90, 90, 90, 110 ) -- light Gray

            )
            draw.DrawText(

                "FIN OS",
                "Trebuchet24",
                ( backgroundPosX + 60 ),
                ( backgroundPosY - 45 + 14 ),
                textColor,
                TEXT_ALIGN_LEFT

            )
            draw.DrawText(

                "(ravo Norway)",
                "HudSelectionText",
                ( backgroundPosX + 150 ),
                ( backgroundPosY - 45 + 13 ),
                textColor,
                TEXT_ALIGN_LEFT

            )

            draw.RoundedBox( 2,
                backgroundPosX,
                backgroundPosY,
                300,
                156,
                Color( 18, 220, 255, 200 ) -- lightBlue

            )

            draw.DrawText(

                [[
                    Left-Click to apply fin
                    IN_USE + Left-Click to add a flap
                    
                    Right-Click to track physics
                    Reload to remove fin from prop
                    
                    IN_USE + SCROLL to scale lift force
                ]],
                "GModToolHelp",
                ( backgroundPosX - 97 + 20 ),
                ( backgroundPosY + 20 ),
                Color( 255, 255, 255, 255 ),
                TEXT_ALIGN_LEFT

            )

        end

        -- If player looks at a fin, maybe show the current settings/values
        if ENT and ENT:IsValid() and ENT:GetNWBool( "fin_os_active" ) then

            local FinSettingsTable = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAngleProperties", "ID12" )
            local pitchAttackAngle_FLAP = 0
            local FlapSettingsTable
            local ENT_FLAP = ENT:GetNWEntity( "fin_os_flapEntity" )

            if ENT_FLAP:IsValid() then

                FlapSettingsTable = FINOS_GetDataToEntFinTable( ENT_FLAP, "fin_os__EntAngleProperties", "ID17" )
                if FlapSettingsTable and FlapSettingsTable[ "AttackAngle_Pitch" ] then

                    pitchAttackAngle_FLAP = math.Round( FlapSettingsTable[ "AttackAngle_Pitch" ] )

                end

            end

            local FinPhysicsPropertiesTable = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntPhysicsProperties", "ID13" )

            if
                ( FinSettingsTable[ "AttackAngle_Pitch" ] and FinSettingsTable[ "AttackAngle_RollCosinus" ] ) and
                ( FinPhysicsPropertiesTable[ "VelocityKmH" ] and FinPhysicsPropertiesTable[ "LiftForceNewtonsModified_beingUsed" ] and FinPhysicsPropertiesTable[ "LiftForceNewtonsNotModified" ] and FinPhysicsPropertiesTable[ "AreaMeterSquared" ] )
            then

                -- Show important values to user on screen
                local pitchAttackAngle = math.Round( FinSettingsTable[ "AttackAngle_Pitch" ] )
                local rollCosinusFraction = FinSettingsTable[ "AttackAngle_RollCosinus" ]

                local speed = math.Round( FinPhysicsPropertiesTable[ "VelocityKmH" ] )
                local force_lift = math.Round( FinPhysicsPropertiesTable[ "LiftForceNewtonsModified_beingUsed" ] )
                local area_meter_squared = math.Round( FinPhysicsPropertiesTable[ "AreaMeterSquared" ], 2 )

                local backgroundPosX = ( ScrW() - 300 - 20 )
                local backgroundPosY = 250

                local textColor = Color( 255, 255, 255, 255 )
                local textType = "HudSelectionText"

                draw.RoundedBox( 8,
                    backgroundPosX,
                    backgroundPosY,
                    300,
                    200,
                    Color( 50, 50, 50, 240 ) -- lightBlack Gray

                )

                draw.DrawText(

                    "Air Attack Angle: " .. pitchAttackAngle.. "˚ | " .. pitchAttackAngle_FLAP.. "˚",
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                draw.DrawText(

                    "Roll Angle Cosinus Fraction: " .. rollCosinusFraction,
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 2 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )

                draw.DrawText(

                    "Speed: " .. speed.. " km/h",
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                draw.DrawText(

                    "Force[LIFT]: " .. force_lift.. " N",
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                draw.DrawText(

                    "Area: " .. area_meter_squared.. " m²",
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 3 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                
                draw.DrawText(

                    "Wing correct way up?: " .. WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle ),
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 4 + 20 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                
                draw.DrawText(

                    "Scalar ( Force[LIFT] ): " .. ENT[ "FinOS_LiftForceScalarValue" ],
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 4 + 20 * 2 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )

            end

        elseif ENT and ENT:IsValid() and ENT:GetNWBool( "fin_os_is_a_fin_flap" ) then

            local FinSettingsTable = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAngleProperties", "ID14" )

            if
                ( FinSettingsTable[ "AttackAngle_Pitch" ] and FinSettingsTable[ "AttackAngle_RollCosinus" ] )
            then

                -- Show important values to user on screen
                local pitchAttackAngle = math.Round( FinSettingsTable[ "AttackAngle_Pitch" ] )
                local rollCosinusFraction = FinSettingsTable[ "AttackAngle_RollCosinus" ]

                local backgroundPosX = ( ScrW() - 300 - 20 )
                local backgroundPosY = 250

                local textColor = Color( 255, 255, 255, 255 )

                draw.RoundedBox( 8,
                    backgroundPosX,
                    backgroundPosY,
                    300,
                    110,
                    Color( 50, 50, 50, 230 ) -- lightBlack Gray

                )

                draw.DrawText(

                    "Air Attack Angle: " .. pitchAttackAngle.. "˚ (important)",
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                draw.DrawText(

                    "Roll Angle Cosinus Fraction: " .. rollCosinusFraction,
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 2 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                
                draw.DrawText(

                    "Flap correct way up?: " .. WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle ),
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )

            end

        end

        -- Display tracked fin entity
        local PHYSICSPROPERTIESSTABLE = FINOS_GetDataToEntFinTable( Player, "fin_os__EntBeingTracked", "ID15" )

        if PHYSICSPROPERTIESSTABLE and PHYSICSPROPERTIESSTABLE["FinBeingTracked"] and PHYSICSPROPERTIESSTABLE["FinBeingTracked"]:IsValid() then

            local width = 150

            local backgroundPosX = ( ScrW() - width - 20 )
            local backgroundPosY = ( 250 + 210 )

            local pitchAttackAngle = math.Round( PHYSICSPROPERTIESSTABLE[ "AttackAngle_Pitch_FIN" ] )
            local pitchAttackAngle_FLAP = math.Round( PHYSICSPROPERTIESSTABLE[ "AttackAngle_Pitch_FLAP" ] )
            local rollCosinusFraction = PHYSICSPROPERTIESSTABLE[ "AttackAngle_RollCosinus_FIN" ]

            local speed = math.Round( PHYSICSPROPERTIESSTABLE[ "VelocityKmH" ] )
            local force_lift = math.Round( PHYSICSPROPERTIESSTABLE[ "LiftForceNewtonsModified_beingUsed" ] )
            local area_meter_squared = math.Round( PHYSICSPROPERTIESSTABLE[ "AreaMeterSquared" ], 2 )

            draw.RoundedBox( 8,
                backgroundPosX,
                backgroundPosY,
                width,
                77,
                Color( 255, 238, 170, 203 ) -- lightYellow

            )

            local textColor = Color( 0, 0, 0, 220 )

            draw.DrawText(

                "AAA: " .. pitchAttackAngle.. "˚ | " .. pitchAttackAngle_FLAP.. "˚",
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 ),
                textColor,
                TEXT_ALIGN_LEFT

            )
            draw.DrawText(

                "U up ?: " .. WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle ),
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 + 12 ),
                textColor,
                TEXT_ALIGN_LEFT

            )

            draw.DrawText(

                "Speed: " .. speed.. " km/h",
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 * 3 + 12 + 4 ),
                textColor,
                TEXT_ALIGN_LEFT

            )
            draw.DrawText(

                "Force[LIFT]: " .. force_lift.. " N",
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 * 3 + 12 * 2 + 4 ),
                textColor,
                TEXT_ALIGN_LEFT

            )

        end

    end

end )

hook.Add("HUDShouldDraw", "fin_os:HUDShouldDraw", function( name )

	-- When Player is in slow motion
	if LocalPlayer() and LocalPlayer():GetNWBool( "PlayerIsLookingAtFinAndChangingScalarValue" ) and name == "CHudWeaponSelection" then return false end

end )

hook.Add( "PreDrawTranslucentRenderables", "fin_os:fin_area_visualizer", function( isDrawingDepth, isDrawSkybox )

    local Player = LocalPlayer()

    if Player and Player:IsValid() then

        local tr = Player:GetEyeTrace()

        local ENT = tr.Entity

        if ENT and ENT:IsValid() and Player and Player:IsValid() and Player:GetActiveWeapon():IsValid() and Player:GetActiveWeapon():GetClass() == "fin_os" then

            local FinAreaPointsTable = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAreaPoints", "ID16" )
            local FinAreaPointCrossingLines = FINOS_GetDataToEntFinTable( ENT, "fin_os__EntAreaPointCrossingLines", "ID3" )

            local extraZ = Vector( 0, 0, 0.6 )

            if ENT:GetNWBool( "fin_os_active" ) then

                -- Draw the area visually on entity
                for k, _ in pairs( FinAreaPointsTable ) do

                    if k >= 3 then

                        render.SetMaterial( Material( "models/props_combine/stasisshield_sheet" ) )
                        render.DrawQuad(

                            ENT:LocalToWorld( FinAreaPointsTable[ 1 ] + extraZ ),
                            ENT:LocalToWorld( FinAreaPointsTable[ k - 1 ] + extraZ ),
                            ENT:LocalToWorld( FinAreaPointsTable[ k ] + extraZ ),
                            ENT:LocalToWorld( FinAreaPointsTable[ 1 ] + extraZ ),
                            Color( 255, 255, 255 )
                        )

                    end

                end

            end

            -- Draw lines between points, so the player can see that no vector points are crossing eachother
            for k, v in pairs( FinAreaPointsTable ) do

                local point1 = v
                local point2 = FinAreaPointsTable[ k + 1 ]

                if point1 and point2 then

                    point1 = ENT:LocalToWorld( v + extraZ )
                    point2 = ENT:LocalToWorld( FinAreaPointsTable[ k + 1 ] + extraZ )

                    render.DrawLine( point1, point2, Color( 170, 255, 170 ), true )

                    if ( k + 1 ) == #FinAreaPointsTable then

                        render.DrawLine( point2, ENT:LocalToWorld( FinAreaPointsTable[ 1 ] + extraZ ), Color( 255, 94, 94 ), true )

                    end

                end

            end

            -- Draw a sprit where the line is crossing other lines
            if FinAreaPointCrossingLines[ "calculationResults" ] then

                for k, v in pairs( FinAreaPointCrossingLines[ "calculationResults" ] ) do

                    if v[ "LHSLocalCrossingPoint" ] then

                        local point1 = ENT:LocalToWorld( v[ "LHSLocalCrossingPoint" ] + extraZ )

                        if point1 then

                            render.SetMaterial( Material( "sprites/light_ignorez" ) )
                            render.DrawSprite( point1, 20, 20, Color( 255, 255, 255))

                        end

                    end

                end

            end

        end

    end

    return false

end )
