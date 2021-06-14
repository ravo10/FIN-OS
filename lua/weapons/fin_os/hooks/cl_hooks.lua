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

local function CheckIfWindTypeIsValid( value, windStatus ) if windStatus == "Yes" then return value else return value .. "*" end end

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
            local FinWindPropertiesTable = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntWindProperties", "ID13.Wind" )

            if
                ( FinSettingsTable[ "AttackAngle_Pitch" ] and FinSettingsTable[ "AttackAngle_RollCosinus" ] ) and
                ( FinPhysicsPropertiesTable[ "VelocityKmH" ] and FinPhysicsPropertiesTable[ "LiftForceNewtonsModified_realistic" ] and FinPhysicsPropertiesTable[ "LiftForceNewtonsNotModified" ] and FinPhysicsPropertiesTable[ "AreaMeterSquared" ] )
            then

                -- Show important values to user on screen
                local pitchAttackAngle = math.Round( FinSettingsTable[ "AttackAngle_Pitch" ] or 0 )
                local rollCosinusFraction = FinSettingsTable[ "AttackAngle_RollCosinus" ] or 0

                local speed = math.Round( FinPhysicsPropertiesTable[ "VelocityKmH" ] or 0 )
                local force_lift = math.Round( FinPhysicsPropertiesTable[ "LiftForceNewtonsModified_realistic" ] or 0 )
                local force_drag = math.Round( FinPhysicsPropertiesTable[ "DragForceNewtons" ] or 0 )
                local force_wind = math.Round( FinPhysicsPropertiesTable[ "FINOS_WindAmountNewtonsForArea" ] or 0 )
                local area_meter_squared = math.Round( FinPhysicsPropertiesTable[ "AreaMeterSquared" ] or 0, 2 )
                local liftForceScalarValue = FinPhysicsPropertiesTable[ "FinOS_LiftForceScalarValue" ] or 0

                -- WIND
                local OKMessage = "Yes"
                local NotOkMessage = "No"

                local WindEnabled = ( ( FinWindPropertiesTable[ "EnableWind" ] or 0 ) > 0 )
                if WindEnabled then WindEnabled = OKMessage else WindEnabled = NotOkMessage end
                local WildWind = ( ( FinWindPropertiesTable[ "ActivateWildWind" ] or 0 ) > 0 )
                if WildWind then WildWind = OKMessage else WildWind = NotOkMessage end
                local ThermalWind = ( ( FinWindPropertiesTable[ "ActivateThermalWind" ] or 0 ) > 0 )
                if ThermalWind then ThermalWind = OKMessage else ThermalWind = NotOkMessage end

                local MinWind = math.Round( FinWindPropertiesTable[ "MinWindScale" ] or 0, 2 )
                local MaxWind = math.Round( FinWindPropertiesTable[ "MaxWindScale" ] or 0, 2 )
                local MinWildWind = math.Round( FinWindPropertiesTable[ "MinWildWindScale" ] or 0, 2 )
                local MaxWildWind = math.Round( FinWindPropertiesTable[ "MaxWildWindScale" ] or 0, 2 )
                local MaxThermalLiftWind = math.Round( FinWindPropertiesTable[ "MaxThermalLiftWindScale" ] or 0, 2 )

                local width = 300
                local height = 217
                local backgroundPosX = ( ScrW() - width - 20 )
                local backgroundPosY = 250 + someExtra001

                local textColor = Color( 255, 255, 255, 255 )
                local textColor2 = Color( 252, 242, 99, 251)
                local textType = "HudSelectionText"

                draw.RoundedBox( 8,
                    backgroundPosX,
                    backgroundPosY,
                    width,
                    height,
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

                    "Air Attack Angle: " .. pitchAttackAngle .. "˚ | " .. pitchAttackAngle_FLAP .. "˚",
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

                    "Speed: " .. speed .. " km/h",
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                draw.DrawText(

                    "Force[LIFT]: " .. force_lift .. " N",
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                draw.DrawText(

                    "Force[DRAG]: " .. force_drag .. " N",
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 2.1 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                draw.DrawText(

                    "Force[WIND]: " .. CheckIfWindTypeIsValid( force_wind .. " N", WindEnabled ),
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 3.2 ),
                    textColor2,
                    TEXT_ALIGN_LEFT

                )
                draw.DrawText(

                    "Area: " .. area_meter_squared .. " m²",
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 4 + 5 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                
                draw.DrawText(

                    "Wing correct way up?: " .. WingCorrectWayUp( rollCosinusFraction, pitchAttackAngle, Entity ),
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 5 + 20 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )
                
                draw.DrawText(

                    "Scalar ( Force[LIFT/DRAG] ): " .. liftForceScalarValue,
                    textType,
                    ( backgroundPosX + 20 ),
                    ( backgroundPosY + 20 * 3 + 10 * 2 + 10 * 6 + 20 * 2 ),
                    textColor,
                    TEXT_ALIGN_LEFT

                )

                -- More Wind Information
                local backgroundPosXWind = backgroundPosX + ( width - 215 )
                local backgroundPosYWind = ( backgroundPosY + height + 3 )

                draw.RoundedBox( 8,
                    backgroundPosXWind,
                    backgroundPosYWind,
                    215,
                    190,
                    Color( 78, 99, 105, 129 )

                )

                if EntTruty( Player ) and EntTruty( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() ~= "fin_os" then

                    draw.DrawText(

                        "FIN OS",
                        "Trebuchet24",
                        ( backgroundPosXWind + 232 ),
                        ( backgroundPosYWind - 13 ),
                        Color( 247, 245, 162, 220 ),
                        TEXT_ALIGN_LEFT

                    )

                end

                local leftStartText = ( 20 )

                local topStart = 20
                local leftStart = 3

                draw.DrawText(

                    "WIND:",
                    textType,
                    ( backgroundPosXWind + leftStartText + leftStart ),
                    ( backgroundPosYWind + topStart + 15 * 0 ),
                    Color( 75, 235, 142),
                    TEXT_ALIGN_LEFT

                )

                draw.DrawText(

                    "Enabled: " .. WindEnabled,
                    textType,
                    ( backgroundPosXWind + leftStartText + leftStart + 5 ),
                    ( backgroundPosYWind + topStart + 5 + 15 * 1 ),
                    textColor2,
                    TEXT_ALIGN_LEFT

                )

                draw.DrawText(

                    "Wild: " .. WildWind,
                    textType,
                    ( backgroundPosXWind + leftStartText + leftStart + 5 + 5 ),
                    ( backgroundPosYWind + topStart + 5 + 3 + 15 * 2 ),
                    textColor2,
                    TEXT_ALIGN_LEFT

                )

                draw.DrawText(

                    "Thermal Lift: " .. ThermalWind,
                    textType,
                    ( backgroundPosXWind + leftStartText + leftStart + 5 + 5 ),
                    ( backgroundPosYWind + topStart + 5 + 3 + 15 * 3 ),
                    textColor2,
                    TEXT_ALIGN_LEFT

                )

                draw.DrawText(

                    "Min.: " .. CheckIfWindTypeIsValid( MinWind, WindEnabled ),
                    textType,
                    ( backgroundPosXWind + leftStartText + leftStart + 5 + 5 + 5 ),
                    ( backgroundPosYWind + topStart + 5 + 3 + 17 + 15 * 3 - 4 * 0 ),
                    textColor2,
                    TEXT_ALIGN_LEFT

                )

                draw.DrawText(

                    "Max.: " .. CheckIfWindTypeIsValid( MaxWind, WindEnabled ),
                    textType,
                    ( backgroundPosXWind + leftStartText + leftStart + 5 + 5 + 5 ),
                    ( backgroundPosYWind + topStart + 5 + 3 + 17 + 15 * 4 - 4 * 1 ),
                    textColor2,
                    TEXT_ALIGN_LEFT

                )

                draw.DrawText(

                    "Min. Wild: " .. CheckIfWindTypeIsValid( MinWildWind, WildWind ),
                    textType,
                    ( backgroundPosXWind + leftStartText + leftStart + 5 + 5 + 5 ),
                    ( backgroundPosYWind + topStart + 5 + 3 + 17 + 15 * 5 - 4 * 0 ),
                    textColor2,
                    TEXT_ALIGN_LEFT

                )

                draw.DrawText(

                    "Max. Wild: " .. CheckIfWindTypeIsValid( MaxWildWind, WildWind ),
                    textType,
                    ( backgroundPosXWind + leftStartText + leftStart + 5 + 5 + 5 ),
                    ( backgroundPosYWind + topStart + 5 + 3 + 17 + 15 * 6 - 4 * 1 ),
                    textColor2,
                    TEXT_ALIGN_LEFT

                )

                draw.DrawText(

                    "Max. Th. Lift: " .. CheckIfWindTypeIsValid( MaxThermalLiftWind, ThermalWind ),
                    textType,
                    ( backgroundPosXWind + leftStartText + leftStart + 5 + 5 + 5 ),
                    ( backgroundPosYWind + topStart + 5 + 3 + 17 + 15 * 7 - 4 * 0 ),
                    textColor2,
                    TEXT_ALIGN_LEFT

                )

            end

        elseif EntTruty( Entity ) and Entity:GetNWBool( "fin_os_is_a_fin_flap" ) then

            local FinSettingsTable = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAngleProperties", "ID14" )

            if FinSettingsTable[ "AttackAngle_Pitch" ] and FinSettingsTable[ "AttackAngle_RollCosinus" ] then

                -- Show important values to user on screen
                local pitchAttackAngle = math.Round( FinSettingsTable[ "AttackAngle_Pitch" ] )
                local rollCosinusFraction = FinSettingsTable[ "AttackAngle_RollCosinus" ]

                local width = 300
                local height = 110
                local backgroundPosX = ( ScrW() - width - 20 )
                local backgroundPosY = 250 + someExtra001

                local textColor = Color( 255, 255, 255, 255 )

                draw.RoundedBox( 8,

                    backgroundPosX,
                    backgroundPosY,
                    width,
                    height,
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

            local backgroundPosX = ( ScrW() - 300 - 30 )
            local backgroundPosY = 60 + 37

            local textColor = Color( 255, 255, 255, 255 )

            draw.RoundedBox( 4,

                backgroundPosX,
                backgroundPosY - 8,
                310,
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
                ( backgroundPosX - 97 + 25 ),
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
            local height = 106

            local backgroundPosX = ( ScrW() - width - 20 )
            if EntTruty( Entity ) and Entity:GetNWBool( "fin_os_active" ) then backgroundPosX = ( ScrW() - 300 - 85 - 3 ) end
            local backgroundPosY = ( 250 + 217 + 3 ) + someExtra001

            local pitchAttackAngle = math.Round( PHYSICSPROPERTIESSTABLE[ "AttackAngle_Pitch_FIN" ] or 0 )
            local pitchAttackAngle_FLAP = math.Round( PHYSICSPROPERTIESSTABLE[ "AttackAngle_Pitch_FLAP" ] or 0 )
            local rollCosinusFraction = PHYSICSPROPERTIESSTABLE[ "AttackAngle_RollCosinus_FIN" ] or 0

            local speed = math.Round( PHYSICSPROPERTIESSTABLE[ "VelocityKmH" ] or 0 )
            local force_lift = math.Round( PHYSICSPROPERTIESSTABLE[ "LiftForceNewtonsModified_realistic" ] or 0 )
            local force_drag = math.Round( PHYSICSPROPERTIESSTABLE[ "DragForceNewtons" ] or 0 )
            local force_wind = math.Round( PHYSICSPROPERTIESSTABLE[ "FINOS_WindAmountNewtonsForArea" ] or 0 )
            local area_meter_squared = math.Round( PHYSICSPROPERTIESSTABLE[ "AreaMeterSquared" ] or 0, 2 )

            -- WIND
            local WindEnabled = ( ( PHYSICSPROPERTIESSTABLE[ "EnableWind" ] or 0 ) > 0 )
            if WindEnabled then WindEnabled = "Yes" else WindEnabled = "No" end

            draw.RoundedBox( 8,

                backgroundPosX,
                backgroundPosY,
                width,
                height,
                Color( 170, 238, 255, 203 )

            )

            local textColor = Color( 0, 0, 0, 225)
            local textColor2 = Color( 238, 255, 170)

            draw.DrawText(

                "AAA: " .. pitchAttackAngle.. "˚ | " .. pitchAttackAngle_FLAP .. "˚",
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

                "Force[LIFT]: " .. force_lift .. " N",
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 * 3 + 12 * 2 + 4 + 7.5 ),
                textColor,
                TEXT_ALIGN_LEFT

            )
            draw.DrawText(

                "Force[DRAG]: " .. force_drag .. " N",
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 * 3 + 12 * 2 + 4 * 4 + 7.5 ),
                textColor,
                TEXT_ALIGN_LEFT

            )
            draw.DrawText(

                "Force[WIND]: " .. CheckIfWindTypeIsValid( force_wind .. " N", WindEnabled ),
                "DermaDefaultBold",
                ( backgroundPosX + 10 ),
                ( backgroundPosY + 8 * 3 + 12 * 2 + 4 * 7 + 7.5 ),
                textColor2,
                TEXT_ALIGN_LEFT

            )

        end

    end

end )

hook.Add("HUDShouldDraw", "fin_os:HUDShouldDraw", function( name )

    local Player = LocalPlayer()

	-- When Player is in slow motion
	if EntTruty ( Player ) and Player:GetNWBool( "PlayerIsLookingAtFinAndChangingScalarValue" ) and name == "CHudWeaponSelection" then return false end

end )

local function FINOS_DrawGrid( Entity, type )

    if ( not EntTruty( LocalPlayer() ) or not EntTruty( Entity ) ) or LocalPlayer():GetPos():DistToSqr( Entity:GetPos() ) > 203210 then return nil end

    -- Size of grid
    local amountX = GetConVar( "finos_cl_gridSizeX" ):GetFloat() or 9
    local amountY = GetConVar( "finos_cl_gridSizeY" ):GetFloat() or 9

    local localMinPoint     = Entity:OBBMins()
    local localMaxPoint     = Entity:OBBMaxs()
    local localCenterPoint  = Entity:OBBCenter()

    local minPosPoint1
    local maxPosPoint1

    local minPosPoint2
    local maxPosPoint2

    local minPosPoint3
    local maxPosPoint3

    local centerPos

    if type == "Front" then

        minPosPoint1 = localMaxPoint[ 1 ] -- X
        maxPosPoint1 = localMaxPoint[ 1 ] -- X

        minPosPoint2 = localMinPoint[ 2 ] -- Y
        maxPosPoint2 = localMaxPoint[ 2 ] -- Y

        minPosPoint3 = localMinPoint[ 3 ] -- Z
        maxPosPoint3 = localMaxPoint[ 3 ] -- Z

        centerPos = localCenterPoint[ 3 ] -- Z

    elseif type == "Back" then

        minPosPoint1 = localMinPoint[ 1 ] -- X
        maxPosPoint1 = localMinPoint[ 1 ] -- X

        minPosPoint2 = localMinPoint[ 2 ] -- Y
        maxPosPoint2 = localMaxPoint[ 2 ] -- Y

        minPosPoint3 = localMinPoint[ 3 ] -- Z
        maxPosPoint3 = localMaxPoint[ 3 ] -- Z

        centerPos = localCenterPoint[ 3 ] -- Z

    elseif type == "Top" then

        minPosPoint1 = localMaxPoint[ 3 ] * -1 -- Z
        maxPosPoint1 = localMaxPoint[ 3 ] * -1 -- Z

        minPosPoint2 = localMinPoint[ 2 ] -- X
        maxPosPoint2 = localMaxPoint[ 2 ] -- X

        minPosPoint3 = localMinPoint[ 1 ] -- Y
        maxPosPoint3 = localMaxPoint[ 1 ] -- Y

        centerPos = localCenterPoint[ 1 ] -- Y
    elseif type == "Bottom" then

        minPosPoint1 = localMinPoint[ 3 ] * -1 -- Z
        maxPosPoint1 = localMinPoint[ 3 ] * -1 -- Z

        minPosPoint2 = localMinPoint[ 2 ] -- Y
        maxPosPoint2 = localMaxPoint[ 2 ] -- Y

        minPosPoint3 = localMinPoint[ 1 ] -- X
        maxPosPoint3 = localMaxPoint[ 1 ] -- X

        centerPos = localCenterPoint[ 1 ] -- X
    elseif type == "Right" then

        minPosPoint1 = localMaxPoint[ 2 ] -- Y
        maxPosPoint1 = localMaxPoint[ 2 ] -- Y

        minPosPoint2 = localMinPoint[ 1 ] -- X
        maxPosPoint2 = localMaxPoint[ 1 ] -- X

        minPosPoint3 = localMinPoint[ 3 ] -- Z
        maxPosPoint3 = localMaxPoint[ 3 ] -- Z

        centerPos = localCenterPoint[ 3 ] -- Z
    elseif type == "Left" then

        minPosPoint1 = localMinPoint[ 2 ] -- Y
        maxPosPoint1 = localMinPoint[ 2 ] -- Y

        minPosPoint2 = localMinPoint[ 1 ] -- X
        maxPosPoint2 = localMaxPoint[ 1 ] -- X

        minPosPoint3 = localMinPoint[ 3 ] -- Z
        maxPosPoint3 = localMaxPoint[ 3 ] -- Z

        centerPos = localCenterPoint[ 3 ] -- Z

    else print( "FINOS: Didn't find any matching type for grid.: Front, Back, Top, Bottom, Left or Right." ) return nil end

    local _color = Color( GetConVar( "finos_cl_gridColorR" ):GetInt(), GetConVar( "finos_cl_gridColorG" ):GetInt(), GetConVar( "finos_cl_gridColorB" ):GetInt() )

    local loopCount1 = maxPosPoint3
    local loopCount2 = maxPosPoint2

    centerPos = math.Round( centerPos )

    local function RotateVector( vec1, vec2 )

        if type == "Top" or type == "Bottom" then

            vec1:Rotate( Angle( 90, 0, 0 ) )
            vec2:Rotate( Angle( 90, 0, 0 ) )

        elseif type == "Left" or type == "Right" then

            vec1:Rotate( Angle( 0, 90, 0 ) )
            vec2:Rotate( Angle( 0, 90, 0 ) )

        end

    end
    local function DrawTheLine( vec1, vec2 )

        RotateVector( vec1, vec2 )

        render.DrawLine(
            Entity:LocalToWorld( vec1 ),
            Entity:LocalToWorld( vec2 ),
            _color, true
        )

    end

    -- Center to Top
    for i = 0, math.abs( loopCount1 ) do

        local zPos = ( i * amountY ) + centerPos
        render.SetMaterial( Material( "color" ) )

        local vec1 = Vector( minPosPoint1, minPosPoint2, zPos )
        local vec2 = Vector( maxPosPoint1, maxPosPoint2, zPos )

        -- Normal
        if zPos < math.abs( maxPosPoint3 ) then DrawTheLine( vec1, vec2 ) else

            -- Outer line
            vec1 = Vector( minPosPoint1, minPosPoint2, maxPosPoint3 )
            vec2 = Vector( maxPosPoint1, maxPosPoint2, maxPosPoint3 )

            DrawTheLine( vec1, vec2 )

            break;
        end

    end
    -- Center to Bottom
    for i = 0, math.abs( loopCount1 ) do

        local zPos = ( ( i * amountY * -1 ) + centerPos )
        render.SetMaterial( Material( "color" ) )

        local vec1 = Vector( minPosPoint1, minPosPoint2, zPos )
        local vec2 = Vector( maxPosPoint1, maxPosPoint2, zPos )

        local checkAgains = ( zPos > 0 )
        if centerPos == 0 then checkAgains = ( math.abs( zPos ) < maxPosPoint3 ) end

        if checkAgains then DrawTheLine( vec1, vec2 ) else
            -- Outer line
            vec1 = Vector( minPosPoint1, minPosPoint2, minPosPoint3 )
            vec2 = Vector( maxPosPoint1, maxPosPoint2, minPosPoint3 )

            DrawTheLine( vec1, vec2 )

            break;
        end

    end
    -- Right side
    for i = 0, math.abs( loopCount2 ) do

        local yPos = ( i * amountX )
        render.SetMaterial( Material( "color" ) )

        local vec1 = Vector( minPosPoint1, yPos, minPosPoint3 )
        local vec2 = Vector( maxPosPoint1, yPos, maxPosPoint3 )

        if yPos < math.abs( maxPosPoint2 ) then DrawTheLine( vec1, vec2 ) else
            -- Outer line
            vec1 = Vector( minPosPoint1, maxPosPoint2, minPosPoint3 )
            vec2 = Vector( maxPosPoint1, maxPosPoint2, maxPosPoint3 )

            DrawTheLine( vec1, vec2 )

            break;
        end

    end
    -- Left side
    for i = 0, math.abs( loopCount2 ) do

        local yPos = ( i * amountX * -1 )
        render.SetMaterial( Material( "color" ) )

        local vec1 = Vector( minPosPoint1, yPos, minPosPoint3 )
        local vec2 = Vector( maxPosPoint1, yPos, maxPosPoint3 )

        if yPos > ( math.abs( minPosPoint2 ) * -1 ) then DrawTheLine( vec1, vec2 ) else
            -- Outer line
            vec1 = Vector( minPosPoint1, minPosPoint2, minPosPoint3 )
            vec2 = Vector( maxPosPoint1, minPosPoint2, maxPosPoint3 )

            DrawTheLine( vec1, vec2 )

            break;
        end

    end

end

hook.Add( "PreDrawTranslucentRenderables", "fin_os:fin_area_visualizer", function( isDrawingDepth, isDrawSkybox )

    local Player = LocalPlayer()

    if EntTruty( Player ) then

        local tr = Player:GetEyeTrace()

        local Entity = tr.Entity

        local FinForwardPointsTable = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntForwardDirectionPoints", "ID16.3" )
        local FinAreaPointsTable = FINOS_GetDataToEntFinTable( Entity, "fin_os__EntAreaPoints", "ID16" )

        if EntTruty( Entity ) and EntTruty( Player ) and EntTruty( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() == "fin_os" then

            if not FinForwardPointsTable or not FinForwardPointsTable[ "ForwardDirectionPoints" ] or #FinForwardPointsTable[ "ForwardDirectionPoints" ] < 2 then

                -- Draw grid on all sides
                FINOS_DrawGrid( Entity, "Front" )
                FINOS_DrawGrid( Entity, "Back" )
                FINOS_DrawGrid( Entity, "Top" )
                FINOS_DrawGrid( Entity, "Bottom" )
                FINOS_DrawGrid( Entity, "Right" )
                FINOS_DrawGrid( Entity, "Left" )

            end

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

                    render.SetMaterial( Material( "color" ) )
                    render.DrawLine( point1, point2, Color( 170, 255, 170 ), true )

                    if ( k + 1 ) == #FinAreaPointsTable then

                        render.SetMaterial( Material( "color" ) )
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

        if GetConVar("finos_cl_enableForwardDirectionArrow"):GetInt() == 1 and EntTruty( Entity ) then

            -- Draw forward direction arrow
            if FinForwardPointsTable and FinForwardPointsTable[ "ForwardDirectionPoints" ] and #FinForwardPointsTable[ "ForwardDirectionPoints" ] == 2 then

                local FinForwardFirstPoint = FinForwardPointsTable[ "ForwardDirectionPoints" ][ 1 ]
                local FinForwardLastPoint = FinForwardPointsTable[ "ForwardDirectionPoints" ][ 2 ]

                local arrowScale = 5

                local FinForwardLastPointArrowLeftPoint = FinForwardLastPoint - Vector( 0, arrowScale, arrowScale )
                local FinForwardLastPointArrowRightPoint = FinForwardLastPoint - Vector( 0, arrowScale * -1, arrowScale )

                local _color = Color( 223, 201, 2, 200 )

                -- Middle line
                render.SetMaterial( Material( "color" ) )
                render.DrawLine( Entity:LocalToWorld( FinForwardFirstPoint ), Entity:LocalToWorld( FinForwardLastPoint ), _color, true )

                local spriteSize, size = 30, 5

                render.SetMaterial( Material( "sprites/light_ignorez" ) )
                render.DrawSprite( Entity:LocalToWorld( FinForwardLastPoint ), spriteSize, ( spriteSize / ( spriteSize / size ) ), Color( 6, 212, 240, 200) )
                render.DrawSprite( Entity:LocalToWorld( FinForwardLastPoint ), ( spriteSize / ( spriteSize / size ) ), spriteSize, Color( 158, 240, 6, 200) )
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
            local amountOfPointsUsed = #FinAreaPointsTable

            -- Only for physgun
            if GetConVar("finos_disablestrictmode"):GetInt() ~= 1 and GetConVar("finos_cl_enableAlignAngleHelpers"):GetInt() == 1 and amountOfPointsUsed > 0 and EntTruty( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() == "weapon_physgun" then

                local colorSignal1 = Color( 200, 170, 255 )
                local colorSignal2 = Color( 200, 170, 255 )
                local colorSignal3 = Color( 200, 170, 255 )

                local angP1, angP2 = FinCurrentAnglesRounded.p, FinAcceptedAnglesRounded.p
                local angY1, angY2 = FinCurrentAnglesRounded.y, FinAcceptedAnglesRounded.y
                local angR1, angR2 = FinCurrentAnglesRounded.r, FinAcceptedAnglesRounded.r

                local notAllowedAnglesP = ( math.abs( angP1 - angP2 ) <= FINOS_AllowedDevationAnglesAlign )
                local notAllowedAnglesY = ( math.abs( angY1 - angY2 ) <= FINOS_AllowedDevationAnglesAlign )
                local notAllowedAnglesR = ( math.abs( angR1 - angR2 ) <= FINOS_AllowedDevationAnglesAlign )

                if notAllowedAnglesP then colorSignal1 = Color( 170, 255, 170 ) end
                if notAllowedAnglesY then colorSignal2 = Color( 170, 255, 170 ) end
                if notAllowedAnglesR then colorSignal3 = Color( 170, 255, 170 ) end

                local spriteSize = 40

                render.SetMaterial( Material( "sprites/light_ignorez" ) )
                render.DrawSprite( Entity:LocalToWorld( entMaxes - Vector( 0, entMaxes.y, entMaxes.z - 10 * 0 ) ), spriteSize, spriteSize, colorSignal1 )
                render.DrawSprite( Entity:LocalToWorld( entMaxes - Vector( 0, entMaxes.y, entMaxes.z - 10 * 1 ) ), spriteSize, spriteSize, colorSignal2 )
                render.DrawSprite( Entity:LocalToWorld( entMaxes - Vector( 0, entMaxes.y, entMaxes.z - 10 * 2 ) ), spriteSize, spriteSize, colorSignal3 )

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
local settingsPanelWidth = 900
local settingsPanelWidthLeftSide = 400
local settingsPanelWidthRightSide = ( 500 - 10 )
local settingsPanelheight = 420
local lastSavedPanelPositions = { ScrW() / 2 - settingsPanelWidth / 2, ScrH() / 2 - settingsPanelheight / 2 }

local function createUserSettingsPanel()

    local DermaPanel = vgui.Create( "DFrame" )

    DermaPanel:SetPos( lastSavedPanelPositions[ 1 ], lastSavedPanelPositions[ 2 ] )
    DermaPanel:SetSize( settingsPanelWidth, settingsPanelheight )
    DermaPanel:SetTitle( "Fin Open Source (FIN OS) Tool - Settings Panel [CLIENT]" )
    DermaPanel:SetDraggable( true )
    DermaPanel:MakePopup()

    DermaPanel.Paint = function( s, w, h )
        draw.RoundedBox(8, 0, 0, w, h,
            Color(27, 11, 247, 206)
        )
    end

    function DermaPanel:OnClose()

        local x, y = DermaPanel:GetPos()

        -- Save the last position
        lastSavedPanelPositions = { x, y }

        if DermaPanel and DermaPanel:IsValid() then DermaPanel:Remove() end

    end

    local function addItemBooleanClientSide( text, conVarId, paddingTop, parentPanel, textColor, backgroundColor )

        if not LocalPlayer():IsAdmin() then return end

        local RulePanel = ( parentPanel or DermaPanel ):Add( "DPanel" ) -- Create container for this item
        if paddingTop then RulePanel:DockMargin( 0, paddingTop, 0, 0 ) else RulePanel:DockMargin( 0, 2, 0, 0 ) end

        RulePanel.Paint = function () end

        local CheckBox = RulePanel:Add( "DCheckBoxLabel" )
        CheckBox:Dock( LEFT ) -- Dock it
        CheckBox:SetText( "Check" )
        CheckBox:SetConVar( conVarId )
        CheckBox:SetValue( true )
        CheckBox:SetSize( 0, 0 )

        local ImageCheckBox = RulePanel:Add( "ImageCheckBox" ) -- Create checkbox with image
        ImageCheckBox:SetMaterial( "icon16/accept.png" ) -- Set its image
        ImageCheckBox:SetWidth( 24 ) -- Make the check box a bit wider than the image so it looks nicer
        ImageCheckBox:Dock( LEFT ) -- Dock it
        ImageCheckBox:SetChecked( GetConVar( conVarId ):GetInt() > 0 )

        ImageCheckBox.Paint = function( s, w, h )

            draw.RoundedBox(4, 0, 0, w, h,
                ( backgroundColor or Color(255, 255, 255, 161) )
            )

        end
        ImageCheckBox:SetText("")

        local function CheckBoxChange()

            local currentValue = GetConVar( conVarId ):GetInt()
            if currentValue > 0 then currentValue = 0 else currentValue = 1 end

            CheckBox:SetValue( currentValue )
            CheckBox:SetChecked( currentValue > 0 )

        end

        ImageCheckBox.OnReleased = CheckBoxChange

        local DLabel = RulePanel:Add( "DLabel" ) -- Create text
        DLabel:SetText( text ) -- Set the text
        DLabel:Dock( FILL ) -- Dock it
        DLabel:DockMargin( 5, 0, 0, 0 ) -- Move the text to the right a little
        DLabel:SetTextColor( textColor or Color( 255, 255, 255) ) -- Set text color to black
        DLabel:SetMouseInputEnabled( true ) -- We must accept mouse input

        DLabel.DoClick = function()

            ImageCheckBox:SetChecked( not ImageCheckBox:GetChecked() )
            CheckBoxChange()

        end

        return RulePanel

    end

    -- Hover ring ball
    local CheckboxHoverRingBallFin = addItemBooleanClientSide( "View Hover Ring Ball → FIN", "finos_cl_enableHoverRingBall_fin", 10 )
    CheckboxHoverRingBallFin:SetSize( settingsPanelWidthLeftSide - 20, 20 )
    CheckboxHoverRingBallFin:SetPos( 10, 30 + 23 * 0 )

    local CheckboxHoverRingBallFlap = addItemBooleanClientSide( "View Hover Ring Ball → FLAP", "finos_cl_enableHoverRingBall_flap", 10 )
    CheckboxHoverRingBallFlap:SetSize( settingsPanelWidthLeftSide - 20, 20 )
    CheckboxHoverRingBallFlap:SetPos( 10, 30 + 23 * 1 )

    -- Angle Helpers
    local CheckboxAlignAngleHelpers = addItemBooleanClientSide( "View Correct Start Angle Helpers", "finos_cl_enableAlignAngleHelpers", 10 )
    CheckboxAlignAngleHelpers:SetSize( settingsPanelWidthLeftSide - 20, 20 )
    CheckboxAlignAngleHelpers:SetPos( 10, 30 + 23 * 2 )

    -- Forward Direction
    local CheckboxAlignAngleHelpers = addItemBooleanClientSide( "View Forward Direction when looking at a fin ( START → STAR )", "finos_cl_enableForwardDirectionArrow", 10 )
    CheckboxAlignAngleHelpers:SetSize( settingsPanelWidthLeftSide - 20, 20 )
    CheckboxAlignAngleHelpers:SetPos( 10, 30 + 23 * 3 )

    local GridSizeSliderBox = vgui.Create( "DPanel", DermaPanel )
    GridSizeSliderBox:SetPos( 10, 30 + 23 * 4.2 )
    GridSizeSliderBox:SetSize( settingsPanelWidthLeftSide - 20, ( settingsPanelheight - ( ( 30 + 23 * 4.2 ) + 10 - 2 ) ) )

    GridSizeSliderBox.Paint = function( s, w, h )
        draw.RoundedBox(8, 0, 0, w, h,
            Color(255, 255, 255, 203)
        )
    end

    local GridSizeSliderContainer = vgui.Create( "DForm", GridSizeSliderBox )
    GridSizeSliderContainer:SetName( "Grid Size and Color ( used for Forward Direction [DRAG/WIND] )" )
    GridSizeSliderContainer:SetSize( GridSizeSliderBox:GetWide() - 10 - 2, GridSizeSliderBox:GetTall() )
    GridSizeSliderContainer:SetPos( 6, 6 )

    GridSizeSliderContainer.Paint = function( s, w, h )
        draw.RoundedBox(8, 0, 0, w, h,
            Color(255, 255, 255, 0)
        )
        draw.RoundedBox(2, 0, 0, w, 20,
            Color( 27, 11, 247, 100)
        )
    end

    GridSizeSliderContainer:NumSlider( "X Cord. (def.: 9)", "finos_cl_gridSizeX", 1, 90 )
    GridSizeSliderContainer:NumSlider( "Y Cord. (def.: 9)", "finos_cl_gridSizeY", 1, 90 )

    GridColorMixer = vgui.Create( "DColorMixer", GridSizeSliderContainer )
    GridColorMixer:SetSize( GridSizeSliderContainer:GetWide(), 150 )
    GridColorMixer:SetPos( 0, GridSizeSliderContainer:GetTall() - GridColorMixer:GetTall() - 12 )
    GridColorMixer:SetPalette( false )
    GridColorMixer:SetAlphaBar( false )
    GridColorMixer:SetWangs( true )

    GridColorMixer:SetConVarR( "finos_cl_gridColorR" )
    GridColorMixer:SetConVarG( "finos_cl_gridColorG" )
    GridColorMixer:SetConVarB( "finos_cl_gridColorB" )

    GridColorMixer:SetColor( Color( GetConVar( "finos_cl_gridColorR" ):GetInt(), GetConVar( "finos_cl_gridColorG" ):GetInt(), GetConVar( "finos_cl_gridColorB" ):GetInt() ) )

    -- ** WIND Settings ** --
    local WindSettingsPanel = vgui.Create( "DPanel", DermaPanel )
    WindSettingsPanel:SetPos( settingsPanelWidthLeftSide, 30 )
    WindSettingsPanel:SetSize( settingsPanelWidthRightSide, settingsPanelheight - 39 )

    WindSettingsPanel.Paint = function( s, w, h )
        draw.RoundedBox(8, 0, 0, w, h,
            Color(255, 255, 255, 203)
        )
    end

    local WindSettingTitle = vgui.Create( "DLabel", WindSettingsPanel )
    WindSettingTitle:SetText( "Adjust Wind Settings and Apply ( applies auto. on creation ): →" )
    WindSettingTitle:SetTextColor( Color( 53, 53, 53) )
    WindSettingTitle:SetPos( 10, 5 )
    WindSettingTitle:SizeToContents()

    local WindSettingApplySettingsButton = vgui.Create( "DButton", WindSettingsPanel )
    WindSettingApplySettingsButton:SetText( "Apply to eye target" )
    WindSettingApplySettingsButton:SizeToContents()
    WindSettingApplySettingsButton:SetSize( WindSettingApplySettingsButton:GetWide() + 20, WindSettingApplySettingsButton:GetTall() + 20 )
    WindSettingApplySettingsButton:SetPos( settingsPanelWidthRightSide - WindSettingApplySettingsButton:GetWide() - 5, 5 )
    function WindSettingApplySettingsButton:DoClick()

        -- Apply settings
        local target = LocalPlayer():GetEyeTrace()
        local Entity = target.Entity

        net.Start( "FINOS_UpdateWindSettings_SERVER" )
            net.WriteEntity( Entity )
        net.SendToServer()

        if Entity and Entity:IsValid() and not Entity:IsWorld() then LocalPlayer():SetNWEntity( "fin_os_lastEyeTargetUsedWindSettingsPanel", Entity ) end

    end

    WindSettingApplySettingsButton.Paint = function( s, w, h )
        draw.RoundedBox(6, 0, 0, w, h,
            Color(27, 11, 247, 220)
        )
        local border = 3
        draw.RoundedBox(6, border, border, w - border * 2, h - border * 2,
            Color(72, 243, 123)
        )
    end

    local WindSettingApplySettingsToLastEnteryButton = vgui.Create( "DButton", WindSettingsPanel )
    WindSettingApplySettingsToLastEnteryButton:SetText( "Apply to last eye target" )
    WindSettingApplySettingsToLastEnteryButton:SizeToContents()
    WindSettingApplySettingsToLastEnteryButton:SetSize( WindSettingApplySettingsToLastEnteryButton:GetWide() + 20, WindSettingApplySettingsToLastEnteryButton:GetTall() + 20 )
    WindSettingApplySettingsToLastEnteryButton:SetPos( settingsPanelWidthRightSide - WindSettingApplySettingsToLastEnteryButton:GetWide() - 5, 5 + WindSettingApplySettingsButton:GetTall() + 5 )
    function WindSettingApplySettingsToLastEnteryButton:DoClick()

        -- Apply settings
        local Entity = LocalPlayer():GetNWEntity( "fin_os_lastEyeTargetUsedWindSettingsPanel" )

        net.Start( "FINOS_UpdateWindSettings_SERVER" )
            net.WriteEntity( Entity )
        net.SendToServer()

    end

    WindSettingApplySettingsToLastEnteryButton.Paint = function( s, w, h )
        draw.RoundedBox(6, 0, 0, w, h,
            Color(27, 11, 247, 220)
        )
        local border = 3
        draw.RoundedBox(6, border, border, w - border * 2, h - border * 2,
            Color(248, 238, 97)
        )
    end

    local textColor = Color( 53, 53, 53)
    local backgroundColor = Color( 53, 53, 53, 60)

    local WindSettingCheckBox_EnableWind = addItemBooleanClientSide( "Enable Wind", "finos_cl_wind_enableWind", 10, WindSettingsPanel, textColor, backgroundColor )
    WindSettingCheckBox_EnableWind:SetSize( settingsPanelWidthRightSide / 2 - 20, 20 )
    WindSettingCheckBox_EnableWind:SetPos( 10, 27 + 23 * 0 )

    local WindSettingCheckBox_ActivateWildWind = addItemBooleanClientSide( "Activate Wild Wind", "finos_cl_wind_activateWildWind", 10, WindSettingsPanel, textColor, backgroundColor )
    WindSettingCheckBox_ActivateWildWind:SetSize( settingsPanelWidthRightSide / 2 - 20, 20 )
    WindSettingCheckBox_ActivateWildWind:SetPos( 10, 27 + 23 * 1 )

    local WindSettingCheckBox_ActivateWildWind = addItemBooleanClientSide( "Activate Thermal Wind", "finos_cl_wind_activateThermalWind", 10, WindSettingsPanel, textColor, backgroundColor )
    WindSettingCheckBox_ActivateWildWind:SetSize( settingsPanelWidthRightSide / 2 - 20, 20 )
    WindSettingCheckBox_ActivateWildWind:SetPos( 10, 27 + 23 * 2 )

    local WindSettingSliderContainer = vgui.Create( "DForm", WindSettingsPanel )
    WindSettingSliderContainer:SetName( "Adjust Wind Force ( WIREMOD wil overwrite ) and Scalars:" )
    WindSettingSliderContainer:SetSize( settingsPanelWidthRightSide - 20, WindSettingsPanel:GetTall() - ( ( 30 + 20 * 3.4 ) + 10 ) )
    WindSettingSliderContainer:SetPos( 10, 30 + 20 * 3.4 )

    -- Sliders
    WindSettingSliderContainer:NumSlider( "Wind Force per. m² (def.: 300)", "finos_cl_wind_forcePerSquareMeterArea", -300000, 300000 )

    WindSettingSliderContainer:NumSlider( "Wind[Min.] (def.: 0.4)", "finos_cl_wind_minWindScale", 0, 1 )
    WindSettingSliderContainer:NumSlider( "Wind[Max.] (def.: 0.8)", "finos_cl_wind_maxWindScale", 0, 1 )

    WindSettingSliderContainer:NumSlider( "Wild Wind[Min.] (def.: 1)", "finos_cl_wind_minWildWindScale", 0.1, 6 )
    WindSettingSliderContainer:NumSlider( "Wild Wind[Max.] (def.: 1.13)", "finos_cl_wind_maxWildWindScale", 0.1, 6 )

    WindSettingSliderContainer:NumSlider( "Thermal Lift Wind[Max.] (def.: 36)", "finos_cl_wind_maxThermalLiftWindScale", 0.1, 200 )

    WindSettingSliderContainer.Paint = function( s, w, h )
        draw.RoundedBox(8, 0, 0, w, h,
            Color(255, 255, 255, 0)
        )
        draw.RoundedBox(2, 0, 0, w, 20,
            Color( 27, 11, 247, 100)
        )
    end

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
