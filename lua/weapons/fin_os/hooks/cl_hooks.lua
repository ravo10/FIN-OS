-- ///////////////////////////////////////////////////////////////////////////////
-- HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS
-- HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS
-- HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS HOOKS
-- ///////////////////////////////////////////////////////////////////////////////

-- Check if fin is correct way up
local function WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle, finOrFlapEntity )

    if finOrFlapEntity and finOrFlapEntity:IsValid() and finOrFlapEntity:GetNWBool( "IgnoreRealPitchAttackAngle" ) then return "-" end

    -- if ( rollCosinusFraction ~= 0 or math.abs( pitchAttackAngle ) ~= 0 ) and math.abs( pitchAttackAngle ) < 90 then return "Yes" else return "No" end
    if rollCosinusFraction > -1 and math.abs( pitchAttackAngle ) < 90 then return "Yes" else return "No" end

end

-- Easy check if entity is truly valid
local function EntTruty( entity )

    if entity and entity:IsValid() then return true end

    return false

end

-- Disable scrolling when player is changing the scalar for Lift Force
local function DisabledScrollingMenuClient( pl, key, disable )

    if key == IN_USE and EntTruty( pl:GetActiveWeapon() ) and pl:GetActiveWeapon():GetClass() == "fin_os" then

        -- Update
        LocalPlayer():SetNWBool( "PlayerIsLookingAtFinAndChangingScalarValue", disable )

    end

end

hook.Add( "KeyPress", "fin_os:KeyPress", function( pl, key ) DisabledScrollingMenuClient( pl, key, true ) end )
hook.Add( "KeyRelease", "fin_os:KeyRelease", function( pl, key ) DisabledScrollingMenuClient( pl, key, false ) end )

hook.Add( "HUDPaint", "fin_os:fin_display_settings", function()

    -- For if in the future adding some more text in main window, and needing to move other elements relativly
    local someExtra001 = 14

    local Player = LocalPlayer()

    if EntTruty( Player ) then

        local tr = Player:GetEyeTrace()

        local Entity = tr.Entity

        -- If player looks at a fin, maybe show the current settings/values
        if EntTruty( Entity ) and Entity:GetNWBool( "fin_os_active" ) then

            local FinSettingsTable = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAngleProperties", "ID12" )
            local pitchAttackAngle_FLAP = 0
            local FlapSettingsTable
            local ENT_FLAP = Entity:GetNWEntity( "fin_os_flapEntity" )

            if EntTruty( ENT_FLAP ) then

                FlapSettingsTable = FINOS_GetDataToEntFinTable( ENT_FLAP, "fin_os__EntAngleProperties", "ID17" )
                if FlapSettingsTable and FlapSettingsTable[ "AttackAngle_Pitch" ] then

                    pitchAttackAngle_FLAP = math.Round( FlapSettingsTable[ "AttackAngle_Pitch" ] )

                end

            end

            local FinPhysicsPropertiesTable = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntPhysicsProperties", "ID13" )

            if
                ( FinSettingsTable[ "AttackAngle_Pitch" ] and FinSettingsTable[ "AttackAngle_RollCosinus" ] ) and
                ( FinPhysicsPropertiesTable[ "VelocityKmH" ] and FinPhysicsPropertiesTable[ "LiftForceNewtonsModified_realistic" ] and FinPhysicsPropertiesTable[ "LiftForceNewtonsNotModified" ] and FinPhysicsPropertiesTable[ "AreaMeterSquared" ] )
            then

                -- Show important values to user on screen
                local pitchAttackAngle = math.Round( FinSettingsTable[ "AttackAngle_Pitch" ] )
                local rollCosinusFraction = FinSettingsTable[ "AttackAngle_RollCosinus" ]

                local speed = math.Round( FinPhysicsPropertiesTable[ "VelocityKmH" ] )
                local force_lift = math.Round( FinPhysicsPropertiesTable[ "LiftForceNewtonsModified_realistic" ] )
                local area_meter_squared = math.Round( FinPhysicsPropertiesTable[ "AreaMeterSquared" ], 2 )
                local liftForceScalarValue = FinPhysicsPropertiesTable[ "FinOS_LiftForceScalarValue" ]

                local backgroundPosX = ( ScrW() - 300 - 20 )
                local backgroundPosY = 250 + someExtra001

                local textColor = Color( 255, 255, 255, 255 )
                local textType = "HudSelectionText"

                draw.RoundedBox( 8,
                    backgroundPosX,
                    backgroundPosY,
                    300,
                    200,
                    Color( 78, 99, 105, 129 )

                )

                if EntTruty( Player ) and EntTruty( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() ~= "fin_os" then

                    draw.DrawText(

                        "FIN OS",
                        "Trebuchet24",
                        ( backgroundPosX + 232 ),
                        ( backgroundPosY - 13 ),
                        Color( 247, 245, 162, 220 ),
                        TEXT_ALIGN_LEFT

                    )

                end

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

                    "Wing correct way up?: " .. WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle, Entity ),
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 4 + 20 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                
                draw.DrawText(

                    "Scalar ( Force[LIFT] ): " .. liftForceScalarValue,
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 4 + 20 * 2 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )

            end

        elseif EntTruty( Entity ) and Entity:GetNWBool( "fin_os_is_a_fin_flap" ) then

            local FinSettingsTable = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAngleProperties", "ID14" )

            if FinSettingsTable[ "AttackAngle_Pitch" ] and FinSettingsTable[ "AttackAngle_RollCosinus" ] then

                -- Show important values to user on screen
                local pitchAttackAngle = math.Round( FinSettingsTable[ "AttackAngle_Pitch" ] )
                local rollCosinusFraction = FinSettingsTable[ "AttackAngle_RollCosinus" ]

                local backgroundPosX = ( ScrW() - 300 - 20 )
                local backgroundPosY = 250 + someExtra001

                local textColor = Color( 255, 255, 255, 255 )

                draw.RoundedBox( 8,

                    backgroundPosX,
                    backgroundPosY,
                    300,
                    110,
                    Color( 78, 99, 105, 129 )

                )

                if EntTruty( Player ) and EntTruty( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() ~= "fin_os" then

                    draw.DrawText(

                        "FIN OS",
                        "Trebuchet24",
                        ( backgroundPosX + 232 ),
                        ( backgroundPosY - 13 ),
                        Color( 247, 245, 162, 220 ),
                        TEXT_ALIGN_LEFT

                    )

                end

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

                    "Flap correct way up?: " .. WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle, Entity ),
                    "HudSelectionText",
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )

            end

        end

        if EntTruty( Player ) and EntTruty( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() == "fin_os" then

            local backgroundPosX = ( ScrW() - 300 - 20 )
            local backgroundPosY = 60 + 37

            local textColor = Color( 255, 255, 255, 255 )

            draw.RoundedBox( 4,

                backgroundPosX,
                backgroundPosY - 8,
                300,
                156 + someExtra001,
                Color( 247, 245, 162, 220 )

            )
            draw.DrawText(

                [[
                    Left-Click to apply fin
                    "E" + Left-Click to add a flap
                    
                    Right-Click to track physics
                    Reload to remove fin from prop
                    
                    "E" + Scroll to scale lift force
                    "E" + Middle Mouse Button for Settings Panel
                ]],
                "GModToolHelp",
                ( backgroundPosX - 97 + 20 ),
                ( backgroundPosY + 20 ),
                Color( 70, 73, 72),
                TEXT_ALIGN_LEFT

            )

            draw.RoundedBox( 8,

                backgroundPosX,
                ( backgroundPosY - 60 + 17 ),
                300,
                48,
                Color( 11, 27, 247, 230)

            )
            draw.DrawText(

                "FIN OS",
                "Trebuchet24",
                ( backgroundPosX + 60 ),
                ( backgroundPosY - 45 + someExtra001 ),
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

        end

        -- Display tracked fin entity
        local PHYSICSPROPERTIESSTABLE = FINOS_GetDataToEntFinTable( Player, "fin_os__EntBeingTracked", "ID15" )

        if PHYSICSPROPERTIESSTABLE and PHYSICSPROPERTIESSTABLE["FinBeingTracked"] and EntTruty( PHYSICSPROPERTIESSTABLE["FinBeingTracked"] ) then

            local width = 150

            local backgroundPosX = ( ScrW() - width - 20 )
            local backgroundPosY = ( 250 + 210 ) + someExtra001

            local pitchAttackAngle = math.Round( PHYSICSPROPERTIESSTABLE[ "AttackAngle_Pitch_FIN" ] )
            local pitchAttackAngle_FLAP = math.Round( PHYSICSPROPERTIESSTABLE[ "AttackAngle_Pitch_FLAP" ] )
            local rollCosinusFraction = PHYSICSPROPERTIESSTABLE[ "AttackAngle_RollCosinus_FIN" ]

            local speed = math.Round( PHYSICSPROPERTIESSTABLE[ "VelocityKmH" ] )
            local force_lift = math.Round( PHYSICSPROPERTIESSTABLE[ "LiftForceNewtonsModified_realistic" ] )
            local area_meter_squared = math.Round( PHYSICSPROPERTIESSTABLE[ "AreaMeterSquared" ], 2 )

            draw.RoundedBox( 8,

                backgroundPosX,
                backgroundPosY,
                width,
                77,
                Color( 170, 238, 255, 203 )

            )

            local textColor = Color( 0, 0, 0, 225)

            draw.DrawText(

                "AAA: " .. pitchAttackAngle.. "˚ | " .. pitchAttackAngle_FLAP.. "˚",
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 ),
                textColor,
                TEXT_ALIGN_LEFT

            )
            draw.DrawText(

                "U up ?: " .. WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle, PHYSICSPROPERTIESSTABLE["FinBeingTracked"] ),
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

    local Player = LocalPlayer();

	-- When Player is in slow motion
	if EntTruty (Player ) and Player:GetNWBool( "PlayerIsLookingAtFinAndChangingScalarValue" ) and name == "CHudWeaponSelection" then return false end

end )

hook.Add( "PreDrawTranslucentRenderables", "fin_os:fin_area_visualizer", function( isDrawingDepth, isDrawSkybox )

    local Player = LocalPlayer()

    if EntTruty( Player ) then

        local tr = Player:GetEyeTrace()

        local Entity = tr.Entity

        if EntTruty( Entity ) and EntTruty( Player ) and EntTruty( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() == "fin_os" then

            local FinAreaPointsTable = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPoints", "ID16" )

            if Entity:GetNWBool( "fin_os_active" ) then

                -- Draw the area visually on entity
                for k, _ in pairs( FinAreaPointsTable ) do

                    if k >= 3 then

                        render.SetMaterial( Material( "models/props_combine/stasisshield_sheet" ) )
                        render.DrawQuad(

                            Entity:LocalToWorld( FinAreaPointsTable[ 1 ] ),
                            Entity:LocalToWorld( FinAreaPointsTable[ k - 1 ] ),
                            Entity:LocalToWorld( FinAreaPointsTable[ k ] ),
                            Entity:LocalToWorld( FinAreaPointsTable[ 1 ] ),
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

                    point1 = Entity:LocalToWorld( v )
                    point2 = Entity:LocalToWorld( FinAreaPointsTable[ k + 1 ] )

                    render.DrawLine( point1, point2, Color( 170, 255, 170 ), true )

                    if ( k + 1 ) == #FinAreaPointsTable then

                        render.DrawLine( point2, Entity:LocalToWorld( FinAreaPointsTable[ 1 ] ), Color( 99, 240, 250 ), true )

                    end

                end

            end

            -- Just important if we have strict mode ON
            local FinAreaPointCrossingLines = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPointCrossingLines", "ID3" )

            -- Draw a sprit where the line is crossing other lines
            if GetConVar( "finos_disablestrictmode" ):GetInt() ~= 1 and FinAreaPointCrossingLines[ "calculationResults" ] then

                for k, v in pairs( FinAreaPointCrossingLines[ "calculationResults" ] ) do

                    if v[ "LHSLocalCrossingPoint" ] then

                        local point1 = Entity:LocalToWorld( v[ "LHSLocalCrossingPoint" ] )

                        if point1 then

                            render.SetMaterial( Material( "sprites/light_ignorez" ) )
                            render.DrawSprite( point1, 20, 20, Color( 255, 255, 255 ) )

                        end

                    end

                end

            end

        end

        -- Just important if we have strict mode ON
        -- Tell the Player visually whats going on
        if GetConVar( "finos_disablestrictmode" ):GetInt() ~= 1 and EntTruty( Entity ) and EntTruty( Player ) and EntTruty( Player:GetActiveWeapon() ) and ( Player:GetActiveWeapon():GetClass() == "weapon_physgun" or Player:GetActiveWeapon():GetClass() == "fin_os" ) then

            local FinAcceptedAngleAndHitNormal = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaAcceptedAngleAndHitNormal", "ID19" )

            local FinAcceptedAnglesRounded = FinAcceptedAngleAndHitNormal[ "firstPointSet_Angles" ]

            local decimals = 0
            local FinCurrentAngles = Entity:GetAngles()
            local FinCurrentAnglesRounded = Angle( math.Round( FinCurrentAngles[ 1 ], decimals ), math.Round( FinCurrentAngles[ 2 ], decimals ), math.Round( FinCurrentAngles[ 3 ], decimals ) )
            
            local isEAndShiftUsedToRotate = math.Round( math.abs( ( FinCurrentAngles[ 1 ] + FinCurrentAngles[ 2 ] + FinCurrentAngles[ 3 ] ) ), 1 ) % 1 <= 0

            local entMaxes = Entity:OBBMaxs()

            -- Only for physgun
            if Entity:GetNWBool( "fin_os_active" ) and EntTruty( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() == "weapon_physgun" then

                local colorSignal1 = Color( 200, 170, 255 )
                local colorSignal2 = Color( 200, 170, 255 )
                local colorSignal3 = Color( 200, 170, 255 )
                if FinAcceptedAnglesRounded[ 1 ] - FinCurrentAnglesRounded[ 1 ] <= 0.15 and FinCurrentAnglesRounded[ 1 ] == FinAcceptedAnglesRounded[ 1 ] then colorSignal1 = Color( 170, 255, 170 ) end
                if FinAcceptedAnglesRounded[ 2 ] - FinCurrentAnglesRounded[ 2 ] <= 0.15 and FinCurrentAnglesRounded[ 2 ] == FinAcceptedAnglesRounded[ 2 ] then colorSignal2 = Color( 170, 255, 170 ) end
                if FinAcceptedAnglesRounded[ 3 ] - FinCurrentAnglesRounded[ 3 ] <= 0.15 and FinCurrentAnglesRounded[ 3 ] == FinAcceptedAnglesRounded[ 3 ] then colorSignal3 = Color( 170, 255, 170 ) end

                render.SetMaterial( Material( "sprites/light_ignorez" ) )

                render.DrawSprite( Entity:LocalToWorld( entMaxes - Vector( 0, entMaxes.y, entMaxes.z ) ), 50, 50, colorSignal1 )
                render.DrawSprite( Entity:LocalToWorld( entMaxes - Vector( 0, entMaxes.y, entMaxes.z - 10 ) ), 50, 50, colorSignal2 )
                render.DrawSprite( Entity:LocalToWorld( entMaxes - Vector( 0, entMaxes.y, entMaxes.z - 10 * 2 ) ), 50, 50, colorSignal3 )

            end

            if EntTruty( Player ) and EntTruty( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() == "fin_os" and not isEAndShiftUsedToRotate and not Entity:GetNWBool( "fin_os_is_a_fin_flap" ) then

                local text = [[Rotate me with "Shift" (｀_´)ゞ]]
                local font = "GModWorldtip"
                
                surface.SetFont( font )
                local tW, tH = surface.GetTextSize( text )

                local trace = LocalPlayer():GetEyeTrace()

                -- Get the game's camera angles
                local angle = EyeAngles()
                angle = ( angle + Angle( -180 - angle[ 1 ], 90, -90 - angle[ 1 ] ) )

                local scale = 0.3
                local padding = 5

                local pos = Entity:LocalToWorld( entMaxes - Vector( 0, 0, entMaxes.z + tH / 2 - tH / 2 - 7 + padding ) )
                pos = Player:LocalToWorld( Player:WorldToLocal( pos ) + Vector( -10 * scale, ( tW / 2 - tW / 2 ) * scale, ( -tH ) * scale ) )

                cam.Start3D2D( pos, angle, scale )

                    surface.SetDrawColor( 0, 0, 0, 175)
                    surface.DrawRect( -tW / 2 - padding, -padding, tW + padding * 2, tH + padding * 2 )

                    draw.SimpleText( text, font, -tW / 2, 0, Color( 255, 135, 79) )

                cam.End3D2D()
                
            end

        end

    end

    return false

end )

hook.Add( "PreDrawHalos", "fin_os:PreDrawHalos", function ()

    local Player = LocalPlayer()

    if EntTruty( Player ) then

        local tr = Player:GetEyeTrace()

        local Entity = tr.Entity

        if (
        
            EntTruty( Entity ) and
            ( Entity:GetNWBool( "fin_os_active" ) or Entity:GetNWBool( "fin_os_is_a_fin_flap" ) ) and
            EntTruty( Player ) and
            EntTruty( Player:GetActiveWeapon() ) and
            Player:GetActiveWeapon():GetClass() == "fin_os"

        ) then

            local c = Color(255, 238, 0)

            -- Draw halo around
            local counterMs = ( CurTime() % 1 ) * 3
            local counterSec = math.floor( counterMs + 0.01 )

            halo.Add( { Entity }, Color( 255 * counterSec, 238 * counterMs, 0, 250 ), 1, 1, 1, true, false )

        end

    end

end )

-- Get rid of empty clip sound
hook.Add( "EntityEmitSound", "finos:EntityEmitSound", function( soundDataTable )

    local IsClipEmptySound = soundDataTable[ "OriginalSoundName" ] == "Weapon_Pistol.Empty"

    if CLIENT and LocalPlayer() then
        
        local playerActiveWeapon = LocalPlayer():GetActiveWeapon()

        if playerActiveWeapon and playerActiveWeapon:IsValid() and playerActiveWeapon:GetClass() == "fin_os" and IsClipEmptySound then

            -- Don't allow
            return false

        end
        
    end
	
end )

-- Settings Panel
local middleMouseButtonDownOnce = false
local middleMouseButtonDownOnce2 = false

local openSettingsPanel
local settingsPanelWidth = 400
local settingsPanelheight = 200
local lastSavedPanelPositions = { ScrW() / 2 - settingsPanelWidth / 2, ScrH() / 2 - settingsPanelheight / 2 }

local function createUserSettingsPanel()

    local DermaPanel = vgui.Create( "DFrame" )

    DermaPanel:SetPos( lastSavedPanelPositions[ 1 ], lastSavedPanelPositions[ 2 ] )
    DermaPanel:SetSize( settingsPanelWidth, settingsPanelheight )
    DermaPanel:SetTitle( "Fin Open Source (FIN OS) Tool - Settings Panel [CLIENT]" )
    DermaPanel:SetDraggable( true )
    DermaPanel:MakePopup()

    function DermaPanel:OnClose()

        local x, y = DermaPanel:GetPos()

        -- Save the last position
        lastSavedPanelPositions = { x, y }

        if DermaPanel and DermaPanel:IsValid() then DermaPanel:Remove() end

    end

    -- Hover ring ball
    local CheckboxHoverRingBallFin = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckboxHoverRingBallFin:SetConVar( "finos_cl_enableHoverRingBall_fin" )
    CheckboxHoverRingBallFin:SetText( "Hover Ring Ball → FIN" )
    CheckboxHoverRingBallFin:SetPos( 10, 30 )
    CheckboxHoverRingBallFin:SizeToContents()
    
    local CheckboxHoverRingBallFlap = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckboxHoverRingBallFlap:SetConVar( "finos_cl_enableHoverRingBall_flap" )
    CheckboxHoverRingBallFlap:SetText( "Hover Ring Ball → FLAP" )
    CheckboxHoverRingBallFlap:SetPos( 10, 30 + 20 )
    CheckboxHoverRingBallFlap:SizeToContents()

end

hook.Add( "InputMouseApply", "fin_os:InputMouseApply", function( cmd, x, y, ang )

    if EntTruty( LocalPlayer() ) and LocalPlayer():KeyDown( IN_USE ) then

        local middleMouseButtonDown = input.IsMouseDown( MOUSE_MIDDLE )

        -- If button is off ONCE
        if not middleMouseButtonDown and not middleMouseButtonDownOnce and middleMouseButtonDownOnce2 then end

        if middleMouseButtonDown and not middleMouseButtonDownOnce and not middleMouseButtonDownOnce2 then middleMouseButtonDownOnce = true middleMouseButtonDownOnce2 = true end
        if not middleMouseButtonDown and not middleMouseButtonDownOnce then middleMouseButtonDownOnce2 = false end
        
        -- If button is on ONCE
        if middleMouseButtonDownOnce then

            middleMouseButtonDownOnce = false

            -- Open panel
            if EntTruty( LocalPlayer() ) and EntTruty( LocalPlayer():GetActiveWeapon() ) and LocalPlayer():GetActiveWeapon():GetClass() == "fin_os" then

                createUserSettingsPanel()

            end

        end

    end

end )