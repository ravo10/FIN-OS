AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire FinOS FLAP Controller"
ENT.RenderGroup     = RENDERGROUP_BOTH
ENT.WireDebugName   = "FinOSFlap"

if CLIENT then return end -- No more client

if WireToolSetup then

    local WireInputs = {

        "Entity (FinOS FLAP) [ENTITY]",
        "Attack Angle (pitch)[INT]"

    }
    local WireOutputs = {

        "Attack Angle (pitch) [STRING]",
        "Attack Angle (pitch)[INT]",
        "Area1 (meters) [STRING]",
        "Area1 (meters)[FLOAT]",
        "Area2 (inches) [STRING]",
        "Area2 (inches)[FLOAT]"

    }
    local BaseTriOut = {

        "- ˚",      -1,
        "- m²",     -1,
        "- In²",    -1

    }

    function ENT:Initialize()

        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )

        self.Inputs = WireLib.CreateInputs( self, WireInputs )
        WireLib.CreateOutputs( self, WireOutputs )

    end

    function ENT:Setup( out_AAP, out_AM, out_AI )

        -- For duplication
        self.out_AAP  = out_AAP
        self.out_AM   = out_AM
        self.out_AI   = out_AI

        self:TriggerOutput( BaseTriOut[ 1 ], BaseTriOut[ 2 ], BaseTriOut[ 3 ] )

    end

    function ENT:ShowOutput( AAP, AM, AI )

        local txt = "OUTPUT DATA: \n"

        if self.out_AAP and AAP then txt = txt .. string.format( "\nPitch Attack Angle = %s",      AAP .. " ˚" )        end
        if self.out_AM and AM   then txt = txt .. string.format( "\nArea (meters) = %s",    AM .. " m²" )               end
        if self.out_AI and AI   then txt = txt .. string.format( "\nArea (inches) = %s",    AI .. " In²" )              end

        self:SetOverlayText( txt .. "\n" )

    end

    function ENT:TriggerInput( iname, value )

        local inputSrc = self.Inputs[ iname ].Src

        if ( iname == "Entity" and value and value:IsValid() ) then self.FlapEntity = value
        elseif ( iname == WireInputs[ 2 ] and value and isnumber( value ) ) then self.PitchAngle = value end

        if ( not inputSrc and iname == "Entity" ) then self.FlapEntity = nil
        elseif ( not inputSrc and iname == WireInputs[ 2 ] ) then self.PitchAngle = nil end

    end

    function ENT:TriggerOutput( AAP_str, AAP, AM_str, AM, AI_str, AI )

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

        self:ShowOutput( AAP, AM, AI )

    end

    duplicator.RegisterEntityClass( "gmod_wire_finos_flap", WireLib.MakeWireEnt, "Data", "out_AAP", "out_AM", "out_AI" )

    function ENT:Think()

        BaseClass.Think( self )

        -- Base
        local AAP       = BaseTriOut[ 2 ]
        local AM        = BaseTriOut[ 4 ]
        local AI        = BaseTriOut[ 6 ]

        local AAP_str   = BaseTriOut[ 1 ]
        local AM_str    = BaseTriOut[ 3 ]
        local AI_str    = BaseTriOut[ 5 ]

        local FlapEnt = self.FlapEntity

        -- Local: new value logic
        if FlapEnt and FlapEnt:IsValid() and not FlapEnt:GetNWBool( "fin_os_active" ) and FlapEnt:GetNWBool( "fin_os_is_a_fin_flap" ) then

            -- Output
            local WIREFINFLAPOUTPUTDATA = FINOS_GetDataToEntFinTable( FlapEnt, "fin_os__WireOutputData_FLAP", "ID WireFinOS_FLAP" )

            if WIREFINFLAPOUTPUTDATA and (

                WIREFINFLAPOUTPUTDATA[ "FLAP_AttackAngle_Pitch" ] and
                WIREFINFLAPOUTPUTDATA[ "FLAP_AreaMeterSquared" ] and
                WIREFINFLAPOUTPUTDATA[ "FLAP_AreaInchesSquared" ]

            ) then

                local round = math.Round
                
                AAP = round( WIREFINFLAPOUTPUTDATA[ "FLAP_AttackAngle_Pitch" ] )
                AM  = round( WIREFINFLAPOUTPUTDATA[ "FLAP_AreaMeterSquared" ], 2 )
                AI  = round( WIREFINFLAPOUTPUTDATA[ "FLAP_AreaInchesSquared" ], 2 )
                
                AAP_str = AAP .. " ˚"
                AM_str  = AM  .. " m²"
                AI_str  = AI  .. " In²"

            end

            -- Input
            local AttackPitchAngleInput = self.PitchAngle

            -- Tell Fin OS Brain to ignore the real pitch angle from flap prop
            if AttackPitchAngleInput ~= nil then
                
                FlapEnt:SetNWBool( "IgnoreRealPitchAttackAngle", true )

                -- Send to Flap
                FlapEnt[ "FinOS_data" ][ "fin_os__Wiremod_InputValues" ][ "AttackAngle_Pitch_Wiremod" ] = AttackPitchAngleInput

            else FlapEnt:SetNWBool( "IgnoreRealPitchAttackAngle", false ) end

        end

        -- Update globally
        self:TriggerOutput( AAP_str, AAP, AM_str, AM, AI_str, AI )

        self:NextThink( CurTime() + 0.04 ) return true

    end

end
