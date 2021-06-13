AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire FinOS FIN Controller"
ENT.RenderGroup     = RENDERGROUP_BOTH
ENT.WireDebugName   = "FinOSFin"

if CLIENT then return end -- No more client

if WireToolSetup then

    local WireInputs = {}
    local WireInputsNames = {

        "Entity(FinOS FIN)",
        "AttackAngle(PITCH)",
        "WindForceBeingApplied(NEWTONS)",
        "Scalar(LIFT/DRAG)"

    }
    local WireInputsTypes = {

        "ENTITY",
        "NORMAL",
        "NORMAL"

    }
    for key, value in pairs( WireInputsNames ) do table.insert( WireInputs, value ) end

    local WireOutputs = {}
    local WireOutputsNames1 = {}
    local WireOutputsNames2 = {}
    local WireOutputsNames = {

        "AttackAngle(PITCH)",
        "Area1(meters[FLOAT])",
        "Area2(inches[FLOAT])",
        "LiftForce(NEWTONS)",
        "DragForce(NEWTONS)",
        "WindEnabled[BOOL]",
        "WindForceBeingApplied(NEWTONS)",
        "Scalar(LIFT/DRAG)",
        "Speed1(KPH)",
        "Speed2(MPH)",
        "Speed3(MPS)",
        "BeingTracked(anyone[BOOL])"

    }
    local WireOutputsTypes = {}
    local WireOutputsTypesActual = {

        "NORMAL",
        "NORMAL",
        "NORMAL",
        "NORMAL",
        "NORMAL",
        "NORMAL",
        "NORMAL",
        "NORMAL",
        "NORMAL",
        "NORMAL",
        "NORMAL",
        "NORMAL"

    }
    local WireOutputsTypesString = {}
    for _, value in pairs( WireOutputsTypesActual ) do table.insert( WireOutputsTypesString, "STRING" ) end

    for key, value in pairs( WireOutputsNames ) do

        table.insert( WireOutputsNames2, value )
        table.insert( WireOutputsNames1, "#" .. value )

    end
    for key, _ in pairs( WireOutputsNames ) do

        table.insert( WireOutputs, WireOutputsNames2[ key ] )
        table.insert( WireOutputs, WireOutputsNames1[ key ] )

        table.insert( WireOutputsTypes, WireOutputsTypesString[ key ] )
        table.insert( WireOutputsTypes, WireOutputsTypesActual[ key ] )

    end

    local fallbackStr, fallbackInt = "n/a", ( 0 / 0 ) --[[ nan ]]
    local BaseTriOut = {

        fallbackStr .. "˚",     fallbackInt,
        fallbackStr .. " m²",   fallbackInt,
        fallbackStr .. " In²",  fallbackInt,
        fallbackStr .. " N",    fallbackInt,
        fallbackStr .. " N",    fallbackInt,
        fallbackStr,            fallbackInt,
        fallbackStr .. " N",    fallbackInt,
        fallbackStr,            fallbackInt,
        fallbackStr .. " kph",  fallbackInt,
        fallbackStr .. " mph",  fallbackInt,
        fallbackStr .. " mps",  fallbackInt,
        fallbackStr,            fallbackInt

    }

    function ENT:Initialize()

        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )

        WireLib.CreateSpecialInputs( self, WireInputs, WireInputsTypes )
        WireLib.CreateSpecialOutputs( self, WireOutputs, WireOutputsTypes )

    end

    function ENT:Setup( out_AAP, out_AM, out_AI, out_LFN, out_DFN, out_WE, out_WFA, out_SCALAR, out_SKMH, out_SMPH, out_MPS, out_BT )

        -- For duplication
        self.out_AAP    = out_AAP
        self.out_AM     = out_AM
        self.out_AI     = out_AI
        self.out_LFN    = out_LFN
        self.out_DFN    = out_DFN
        self.out_WE     = out_WE
        self.out_WFA    = out_WFA
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
            BaseTriOut[ 17 ], BaseTriOut[ 18 ],
            BaseTriOut[ 19 ], BaseTriOut[ 20 ],
            BaseTriOut[ 21 ], BaseTriOut[ 22 ],
            BaseTriOut[ 23 ], BaseTriOut[ 24 ]

        )

    end

    function ENT:ShowOutput( AAP, AM, AI, LFN, DFN, WE, WE_str, WFA, SCALAR, SKMH, SMPH, MPS, BT, BT_str )

        local txt = "OUTPUT DATA: \n"

        if self.out_AAP and AAP         then txt = txt .. string.format( "\nPitch Attack Angle = %s",   AAP     .. "˚" )               end
        if self.out_AM and AM           then txt = txt .. string.format( "\nArea (meters) = %s",        AM      .. " m²" )              end
        if self.out_AI and AI           then txt = txt .. string.format( "\nArea (inches) = %s",        AI      .. " In²" )             end
        if self.out_LFN and LFN         then txt = txt .. string.format( "\nLift Force = %s",           LFN     .. " N" )               end
        if self.out_DFN and DFN         then txt = txt .. string.format( "\nDrag Force = %s",           DFN     .. " N" )               end
        if self.out_WE and WE           then txt = txt .. string.format( "\nWind Enabled = %s",         WE_str  .. " ( " .. WE .. " )" )end
        if self.out_WFA and WFA         then txt = txt .. string.format( "\nWind Force Applied = %s",   WFA     .. " N" )               end
        if self.out_SCALAR and SCALAR   then txt = txt .. string.format( "\nScalar = %s",               SCALAR )                        end
        if self.out_SKMH and SKMH       then txt = txt .. string.format( "\nSpeed (kph) = %s",          SKMH    .. " kph" )             end
        if self.out_SMPH and SMPH       then txt = txt .. string.format( "\nSpeed (mph) = %s",          SMPH    .. " mph" )             end
        if self.out_MPS and MPS         then txt = txt .. string.format( "\nSpeed (mps) = %s",          MPS     .. " mps" )             end
        if self.out_BT and BT           then txt = txt .. string.format( "\nBeing tracked = %s",        BT_str .. " ( " .. BT .. " )" ) end

        self:SetOverlayText( txt .. "\n" )

    end

    function ENT:TriggerInput( iname, value )

        local inputSrc = self.Inputs[ iname ].Src

        if ( iname == WireInputs[ 1 ] and value and value:IsValid() ) then self.FinEntity = value
        elseif ( iname == WireInputs[ 2 ] and value and isnumber( value ) ) then self.PitchAngle = value
        elseif ( iname == WireInputs[ 3 ] and value and isnumber( value ) ) then self.WindForceApplied = value
        elseif ( iname == WireInputs[ 4 ] and value and isnumber( value ) ) then self.Scalar = value end

        if not inputSrc then

            if ( iname == WireInputs[ 1 ] ) then self.FinEntity = nil
            elseif ( iname == WireInputs[ 2 ] ) then self.PitchAngle = nil
            elseif ( iname == WireInputs[ 3 ] ) then self.WindForceApplied = nil
            elseif ( iname == WireInputs[ 4 ] ) then self.Scalar = nil end

        end

    end

    function ENT:TriggerOutput( AAP_str, AAP, AM_str, AM, AI_str, AI, LFN_str, LFN, DFN_str, DFN, WE, WE_str, WFA, WFA_str, SCALAR_str, SCALAR, SKMH_str, SKMH, SMPH_str, SMPH, MPS_str, MPS, BT_str, BT )

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
        if self.out_DFN then
            WireLib.TriggerOutput( self, WireOutputs[ 9 ], DFN_str )
            WireLib.TriggerOutput( self, WireOutputs[ 10 ], DFN )
        end
        if self.out_WE then
            WireLib.TriggerOutput( self, WireOutputs[ 11 ], WE_str )
            WireLib.TriggerOutput( self, WireOutputs[ 12 ], WE )
        end
        if self.out_WFA then
            WireLib.TriggerOutput( self, WireOutputs[ 13 ], WFA_str )
            WireLib.TriggerOutput( self, WireOutputs[ 14 ], WFA )
        end
        if self.out_SCALAR then
            WireLib.TriggerOutput( self, WireOutputs[ 15 ], SCALAR_str )
            WireLib.TriggerOutput( self, WireOutputs[ 16 ], SCALAR )
        end
        if self.out_SKMH then
            WireLib.TriggerOutput( self, WireOutputs[ 17 ], SKMH_str )
            WireLib.TriggerOutput( self, WireOutputs[ 18 ], SKMH )
        end
        if self.out_SMPH then
            WireLib.TriggerOutput( self, WireOutputs[ 19 ], SMPH_str )
            WireLib.TriggerOutput( self, WireOutputs[ 20 ], SMPH )
        end
        if self.out_MPS then
            WireLib.TriggerOutput( self, WireOutputs[ 21 ], MPS_str )
            WireLib.TriggerOutput( self, WireOutputs[ 22 ], MPS )
        end
        if self.out_BT then
            WireLib.TriggerOutput( self, WireOutputs[ 23 ], BT_str )
            WireLib.TriggerOutput( self, WireOutputs[ 24 ], BT )
        end

        self:ShowOutput( AAP, AM, AI, LFN, DFN, WE, WE_str, WFA, SCALAR, SKMH, SMPH, MPS, BT, BT_str )

    end

    duplicator.RegisterEntityClass( "gmod_wire_finos_fin", WireLib.MakeWireEnt, "Data", "out_AAP", "out_AM", "out_AI", "out_LFN", "out_DFN", "out_WE", "out_WFA", "out_SCALAR", "out_SKMH", "out_SMPH", "out_MPS", "out_BT" )

    function ENT:FINOS_UpdateInputValueWireModGlobally( InputData, FINOSDATA_InputWireModTable, TableID, NWBoolString )

        if InputData ~= nil then self.FinEntity:SetNWBool( NWBoolString, true ) else self.FinEntity:SetNWBool( NWBoolString, false ) end

        --[[ Global table ]]
        FINOSDATA_InputWireModTable[ TableID ] = InputData

        return InputData

    end

    function ENT:Think()

        BaseClass.Think( self )

        -- Base
        local AAP       = BaseTriOut[ 2 ]
        local AM        = BaseTriOut[ 4 ]
        local AI        = BaseTriOut[ 6 ]
        local LFN       = BaseTriOut[ 8 ]
        local DFN       = BaseTriOut[ 10 ]
        local WE        = BaseTriOut[ 12 ]
        local WFA       = BaseTriOut[ 14 ]
        local SCALAR    = BaseTriOut[ 16 ]
        local SKMH      = BaseTriOut[ 18 ]
        local SMPH      = BaseTriOut[ 20 ]
        local MPS       = BaseTriOut[ 22 ]
        local BT        = BaseTriOut[ 24 ]

        local AAP_str       = BaseTriOut[ 1 ]
        local AM_str        = BaseTriOut[ 3 ]
        local AI_str        = BaseTriOut[ 5 ]
        local LFN_str       = BaseTriOut[ 7 ]
        local DFN_str       = BaseTriOut[ 9 ]
        local WE_str        = BaseTriOut[ 11 ]
        local WFA_str       = BaseTriOut[ 13 ]
        local SCALAR_str    = BaseTriOut[ 15 ]
        local SKMH_str      = BaseTriOut[ 17 ]
        local SMPH_str      = BaseTriOut[ 19 ]
        local MPS_str       = BaseTriOut[ 21 ]
        local BT_str        = BaseTriOut[ 23 ]

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
                WIREFINFLAPOUTPUTDATA[ "FIN_DragForceNewtons" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_WindEnabled" ] and
                WIREFINFLAPOUTPUTDATA[ "FIN_WindAppliedForceNewtons" ] and
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
                DFN     = round( WIREFINFLAPOUTPUTDATA[ "FIN_DragForceNewtons" ] )
                WE      = round( WIREFINFLAPOUTPUTDATA[ "FIN_WindEnabled" ] )
                WFA     = round( WIREFINFLAPOUTPUTDATA[ "FIN_WindAppliedForceNewtons" ] )
                SCALAR  = WIREFINFLAPOUTPUTDATA[ "FIN_Scalar" ]
                SKMH    = round( WIREFINFLAPOUTPUTDATA[ "FIN_VelocityKmH" ] )
                SMPH    = round( WIREFINFLAPOUTPUTDATA[ "FIN_VelocityMpH" ] )
                MPS     = round( WIREFINFLAPOUTPUTDATA[ "FIN_VelocityMps" ] )
                BT      = WIREFINFLAPOUTPUTDATA[ "FIN_FinBeingTracked" ]

                AAP_str     = AAP .. "˚"
                AM_str      = AM .. " m²"
                AI_str      = AI .. " In²"
                LFN_str     = LFN .. " N"
                DFN_str     = DFN .. " N"
                if WE < 1 then WE_str = "No" else WE_str = "Yes" end
                WFA_str     = WFA .. " N"
                SCALAR_str  = tostring( SCALAR )
                SKMH_str    = SKMH .. " kph"
                SMPH_str    = SMPH .. " mph"
                MPS_str     = MPS .. " mps"
                if BT < 1 then BT_str = "No" else BT_str = "Yes" end

            end

            -- Input
            local AttackPitchAngleInput = self.PitchAngle
            local WindForceBeingApplied = self.WindForceApplied
            local LiftScalarInput = self.Scalar

            -- Tell Fin OS Brain to ignore the original scalar angle from fin prop
            -- Tell Fin OS Brain to ignore the original Wind Force Being Applied from fin prop
            -- Tell Fin OS Brain to ignore the real pitch angle from fin prop
            local FINOSDATA_InputWireModTable = FinEnt[ "FinOS_data" ][ "fin_os__Wiremod_InputValues" ]

            --[[ ATTACK ANGLE ]]self:FINOS_UpdateInputValueWireModGlobally( AttackPitchAngleInput, FINOSDATA_InputWireModTable, "AttackAngle_Pitch_Wiremod", "IgnoreRealPitchAttackAngle" )
            --[[ WIND ]]        self:FINOS_UpdateInputValueWireModGlobally( WindForceBeingApplied, FINOSDATA_InputWireModTable, "WindAmountNewtonsForArea_Wiremod", "IgnoreRealWindForceApplied" )
            --[[ LIFT ]]        self:FINOS_UpdateInputValueWireModGlobally( LiftScalarInput, FINOSDATA_InputWireModTable, "FinOS_LiftForceScalarValue_Wiremod", "IgnoreRealScalarValue" )

        end

        -- Update globally
        self:TriggerOutput( AAP_str, AAP, AM_str, AM, AI_str, AI, LFN_str, LFN, DFN_str, DFN, WE, WE_str, WFA, WFA_str, SCALAR_str, SCALAR, SKMH_str, SKMH, SMPH_str, SMPH, MPS_str, MPS, BT_str, BT )

        self:NextThink( CurTime() + 0.03 ) return true

    end

end
