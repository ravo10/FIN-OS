AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire FinOS FIN Controller"
ENT.RenderGroup     = RENDERGROUP_BOTH
ENT.WireDebugName   = "FinOSFin"

if CLIENT then return end -- No more client

if WireToolSetup then

    local WireInputs = {

        "Entity (FinOS FIN) [ENTITY]",
        "Scalar (Lift)[INT]",
        "Attack Angle (pitch)[INT]"

    }
    local WireOutputs = {

        "Attack Angle (pitch) [STRING]",
        "Attack Angle (pitch)[INT]",
        "Area1 (meters) [STRING]",
        "Area1 (meters)[FLOAT]",
        "Area2 (inches) [STRING]",
        "Area2 (inches)[FLOAT]",
        "Lift Force (Newtons) [STRING]",
        "Lift Force (Newtons)[INT]",
        "Scalar (Lift) [STRING]",
        "Scalar (Lift)[INT]",
        "Speed1 (Kph) [STRING]",
        "Speed1 (Kph)[INT]",
        "Speed2 (Mph) [STRING]",
        "Speed2 (Mph)[INT]",
        "Speed3 (Mps) [STRING]",
        "Speed3 (Mps)[INT]",
        "Being Tracked (anyone) [STRING]",
        "Being Tracked (anyone)[BOOL]"

    }
    local BaseTriOut = {

        "-˚",       -1,
        "- m²",     -1,
        "- In²",    -1,
        "- N",      -1,
        "-",        -1,
        "- kph",    -1,
        "- mph",    -1,
        "- mps",    -1,
        "-",        -1

    }

    function ENT:Initialize()

        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )

        self[ "Inputs" ] = WireLib.CreateInputs( self, WireInputs )
        WireLib.CreateOutputs( self, WireOutputs )

    end

    function ENT:Setup( out_AAP, out_AM, out_AI, out_LFN, out_SCALAR, out_SKMH, out_SMPH, out_MPS, out_BT )

        -- For duplication
        self.out_AAP    = out_AAP
        self.out_AM     = out_AM
        self.out_AI     = out_AI
        self.out_LFN    = out_LFN
        self.out_SCALAR = out_SCALAR
        self.out_SKMH   = out_SKMH
        self.out_SMPH   = out_SMPH
        self.out_MPS    = out_MPS
        self.out_BT     = out_BT

        self:TriggerOutput(

            BaseTriOut[ 1 ], BaseTriOut[ 2 ],
            BaseTriOut[ 3 ], BaseTriOut[ 4 ],
            BaseTriOut[ 5 ], BaseTriOut[ 6 ],
            BaseTriOut[ 7 ], BaseTriOut[ 8 ],
            BaseTriOut[ 9 ], BaseTriOut[ 10 ],
            BaseTriOut[ 11 ], BaseTriOut[ 12 ],
            BaseTriOut[ 13 ], BaseTriOut[ 14 ],
            BaseTriOut[ 15 ], BaseTriOut[ 16 ],
            BaseTriOut[ 17 ], BaseTriOut[ 18 ]

        )

    end

    function ENT:ShowOutput( AAP, AM, AI, LFN, SCALAR, SKMH, SMPH, MPS, BT, BT_str )

        local txt = "OUTPUT DATA: \n"

        if self.out_AAP and AAP         then txt = txt .. string.format( "\nPitch Attack Angle = %s",   AAP     .. " ˚" )               end
        if self.out_AM and AM           then txt = txt .. string.format( "\nArea (meters) = %s",        AM      .. " m²" )              end
        if self.out_AI and AI           then txt = txt .. string.format( "\nArea (inches) = %s",        AI      .. " In²" )             end
        if self.out_LFN and LFN         then txt = txt .. string.format( "\nLift Force = %s",           LFN     .. " N" )               end
        if self.out_SCALAR and SCALAR   then txt = txt .. string.format( "\nScalar = %s",               SCALAR )                        end
        if self.out_SKMH and SKMH       then txt = txt .. string.format( "\nSpeed (kph) = %s",          SKMH    .. " kph" )             end
        if self.out_SMPH and SMPH       then txt = txt .. string.format( "\nSpeed (mph) = %s",          SMPH    .. " mph" )             end
        if self.out_MPS and MPS         then txt = txt .. string.format( "\nSpeed (mps) = %s",          MPS     .. " mps" )             end
        if self.out_BT and BT           then txt = txt .. string.format( "\nBeing tracked = %s",        BT_str .. " ( " .. BT .. " )" ) end

        self:SetOverlayText( txt .. "\n" )

    end

    function ENT:TriggerInput( iname, value )

        local inputSrc = self.Inputs[ iname ].Src

        if ( iname == "Entity" and value and value:IsValid() ) then self.FinEntity = value
        elseif ( iname == WireInputs[ 2 ] and value and isnumber( value ) ) then self.Scalar = value
        elseif ( iname == WireInputs[ 3 ] and value and isnumber( value ) ) then self.PitchAngle = value end

        if ( not inputSrc and iname == "Entity" ) then self.FinEntity = nil
        elseif ( not inputSrc and iname == WireInputs[ 2 ] ) then self.Scalar = nil
        elseif ( not inputSrc and iname == WireInputs[ 3 ] ) then self.PitchAngle = nil end

    end

    function ENT:TriggerOutput( AAP_str, AAP, AM_str, AM, AI_str, AI, LFN_str, LFN, SCALAR_str, SCALAR, SKMH_str, SKMH, SMPH_str, SMPH, MPS_str, MPS, BT_str, BT )

        if self.out_AAP then
            WireLib.TriggerOutput( self, WireOutputs[ 1 ], AAP_str )
            WireLib.TriggerOutput( self, WireOutputs[ 2 ], AAP )
        end
        if self.out_AM then
            WireLib.TriggerOutput( self, WireOutputs[ 3 ], AM_str )
            WireLib.TriggerOutput( self, WireOutputs[ 4 ], AM )
        end
        if self.out_AI then
            WireLib.TriggerOutput( self, WireOutputs[ 5 ], AI_str )
            WireLib.TriggerOutput( self, WireOutputs[ 6 ], AI )
        end
        if self.out_LFN then
            WireLib.TriggerOutput( self, WireOutputs[ 7 ], LFN_str )
            WireLib.TriggerOutput( self, WireOutputs[ 8 ], LFN )
        end
        if self.out_SCALAR then
            WireLib.TriggerOutput( self, WireOutputs[ 9 ], SCALAR_str )
            WireLib.TriggerOutput( self, WireOutputs[ 10 ], SCALAR )
        end
        if self.out_SKMH then
            WireLib.TriggerOutput( self, WireOutputs[ 11 ], SKMH_str )
            WireLib.TriggerOutput( self, WireOutputs[ 12 ], SKMH )
        end
        if self.out_SMPH then
            WireLib.TriggerOutput( self, WireOutputs[ 13 ], SMPH_str )
            WireLib.TriggerOutput( self, WireOutputs[ 14 ], SMPH )
        end
        if self.out_MPS then
            WireLib.TriggerOutput( self, WireOutputs[ 15 ], MPS_str )
            WireLib.TriggerOutput( self, WireOutputs[ 16 ], MPS )
        end
        if self.out_BT then
            WireLib.TriggerOutput( self, WireOutputs[ 17 ], BT_str )
            WireLib.TriggerOutput( self, WireOutputs[ 18 ], BT )
        end

        self:ShowOutput( AAP, AM, AI, LFN, SCALAR, SKMH, SMPH, MPS, BT, BT_str )

    end

    duplicator.RegisterEntityClass( "gmod_wire_finos_fin", WireLib.MakeWireEnt, "Data", "out_AAP", "out_AM", "out_AI", "out_LFN", "out_SCALAR", "out_SKMH", "out_SMPH", "out_MPS", "out_BT" )

    function ENT:Think()

        BaseClass.Think( self )

        -- Base
        local AAP       = BaseTriOut[ 2 ]
        local AM        = BaseTriOut[ 4 ]
        local AI        = BaseTriOut[ 6 ]
        local LFN       = BaseTriOut[ 8 ]
        local SCALAR    = BaseTriOut[ 10 ]
        local SKMH      = BaseTriOut[ 12 ]
        local SMPH      = BaseTriOut[ 14 ]
        local MPS       = BaseTriOut[ 16 ]
        local BT        = BaseTriOut[ 18 ]

        local AAP_str       = BaseTriOut[ 1 ]
        local AM_str        = BaseTriOut[ 3 ]
        local AI_str        = BaseTriOut[ 5 ]
        local LFN_str       = BaseTriOut[ 7 ]
        local SCALAR_str    = BaseTriOut[ 9 ]
        local SKMH_str      = BaseTriOut[ 11 ]
        local SMPH_str      = BaseTriOut[ 13 ]
        local MPS_str       = BaseTriOut[ 15 ]
        local BT_str        = BaseTriOut[ 17 ]

        local FinEnt = self.FinEntity

        -- Local: new value logic
        if FinEnt and FinEnt:IsValid() and FinEnt:GetNWBool( "fin_os_active" ) and not FinEnt:GetNWBool( "fin_os_is_a_fin_flap" ) then

            -- Output
            local WIREFINFLAPOUTPUTDATA = FINOS_GetDataToEntFinTable( FinEnt, "fin_os__WireOutputData_FIN", "ID WireFinOS_FIN" )

            if WIREFINFLAPOUTPUTDATA and (

                WIREFINFLAPOUTPUTDATA[ "FIN_AttackAngle_Pitch" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_AreaMeterSquared" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_AreaInchesSquared" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_LiftForceNewtons" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_Scalar" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_VelocityKmH" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_VelocityMpH" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_VelocityMps" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_FinBeingTracked" ]

            ) then

                local round = math.Round
                
                AAP     = round( WIREFINFLAPOUTPUTDATA[ "FIN_AttackAngle_Pitch" ] )
                AM      = round( WIREFINFLAPOUTPUTDATA[ "FIN_AreaMeterSquared" ], 2 )
                AI      = round( WIREFINFLAPOUTPUTDATA[ "FIN_AreaInchesSquared" ], 2 )
                LFN     = round( WIREFINFLAPOUTPUTDATA[ "FIN_LiftForceNewtons" ] )
                SCALAR  = WIREFINFLAPOUTPUTDATA[ "FIN_Scalar" ]
                SKMH    = round( WIREFINFLAPOUTPUTDATA[ "FIN_VelocityKmH" ] )
                SMPH    = round( WIREFINFLAPOUTPUTDATA[ "FIN_VelocityMpH" ] )
                MPS     = round( WIREFINFLAPOUTPUTDATA[ "FIN_VelocityMps" ] )
                BT      = WIREFINFLAPOUTPUTDATA[ "FIN_FinBeingTracked" ]
                
                AAP_str     = AAP .. "˚"
                AM_str      = AM .. " m²"
                AI_str      = AI .. " In²"
                LFN_str     = LFN .. " N"
                SCALAR_str  = tostring( SCALAR )
                SKMH_str    = SKMH .. " kph"
                SMPH_str    = SMPH .. " mph"
                MPS_str     = MPS .. " mps"
                if BT < 1 then BT_str = "No" else BT_str = "Yes" end

            end

            -- Input
            local LiftScalarInput = self.Scalar
            local AttackPitchAngleInput = self.PitchAngle

            -- Tell Fin OS Brain to ignore the original scalar angle from fin prop
            if LiftScalarInput ~= nil then FinEnt:SetNWBool( "IgnoreRealScalarValue", true ) else
                FinEnt:SetNWBool( "IgnoreRealScalarValue", false )
            end
            -- Tell Fin OS Brain to ignore the real pitch angle from fin prop
            if AttackPitchAngleInput ~= nil then FinEnt:SetNWBool( "IgnoreRealPitchAttackAngle", true ) else
                FinEnt:SetNWBool( "IgnoreRealPitchAttackAngle", false )
            end

            -- Send to Fin
            if LiftScalarInput ~= nil then
                FinEnt[ "FinOS_data" ][ "fin_os__Wiremod_InputValues" ][ "FinOS_LiftForceScalarValue_Wiremod" ] = LiftScalarInput
            end
            if AttackPitchAngleInput ~= nil then
                FinEnt[ "FinOS_data" ][ "fin_os__Wiremod_InputValues" ][ "AttackAngle_Pitch_Wiremod" ] = AttackPitchAngleInput
            end

        end

        -- Update globally
        self:TriggerOutput( AAP_str, AAP, AM_str, AM, AI_str, AI, LFN_str, LFN, SCALAR_str, SCALAR, SKMH_str, SKMH, SMPH_str, SMPH, MPS_str, MPS, BT_str, BT )

        self:NextThink( CurTime() + 0.04 ) return true

    end

end
