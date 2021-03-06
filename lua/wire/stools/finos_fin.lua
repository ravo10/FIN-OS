if WireToolSetup then
    
    WireToolSetup.setCategory( "Physics/FIN OS Tool" )
    WireToolSetup.open( "finos_fin", "Fin Controller", "gmod_wire_finos_fin", nil, "Fin OS Fin Controllers's" )

    if CLIENT then

        language.Add( "tool.wire_finos_fin.name", "FIN OS Tool - Fin Controller (Wire)" )
        language.Add( "tool.wire_finos_fin.desc", "Spawns a Fin Controller for use with the wire system." )

        language.Add( "Tool.wire_finos_fin.out_AAP",    "Output Angle of Attack (PITCH)"    )
        language.Add( "Tool.wire_finos_fin.out_AM",     "Output Area [METERS]"              )
        language.Add( "Tool.wire_finos_fin.out_AI",     "Output Area [INCHES]"              )
        language.Add( "Tool.wire_finos_fin.out_LFN",    "Output Lift Force"                 )
        language.Add( "Tool.wire_finos_fin.out_DFN",    "Output Drag Force"                 )
        language.Add( "Tool.wire_finos_fin.out_WE",     "Output Wind Enabled"               )
        language.Add( "Tool.wire_finos_fin.out_WFA",    "Output Wind Force Applied"         )
        language.Add( "Tool.wire_finos_fin.out_SCALAR", "Output Scalar"                     )
        language.Add( "Tool.wire_finos_fin.out_KNOTS",  "Output Speed [KNOTS]"              )
        language.Add( "Tool.wire_finos_fin.out_SKMH",   "Output Speed [KPH]"                )
        language.Add( "Tool.wire_finos_fin.out_SMPH",   "Output Speed [MPH]"                )
        language.Add( "Tool.wire_finos_fin.out_MPS",    "Output Speed [MPS]"                )
        language.Add( "Tool.wire_finos_fin.out_BT",     "Output if Being Tracked"           )

        TOOL.Information = { { name = "left", text = "Create/Update " .. TOOL.Name } }

    end
    WireToolSetup.BaseLang()
    WireToolSetup.SetupMax( 20 )

    if SERVER then

        function TOOL:GetConVars()

            return
                self:GetClientNumber( "out_AAP"     ) ~= 0,
                self:GetClientNumber( "out_AM"      ) ~= 0,
                self:GetClientNumber( "out_AI"      ) ~= 0,
                self:GetClientNumber( "out_LFN"     ) ~= 0,
                self:GetClientNumber( "out_DFN"     ) ~= 0,
                self:GetClientNumber( "out_WE"      ) ~= 0,
                self:GetClientNumber( "out_WFA"     ) ~= 0,
                self:GetClientNumber( "out_SCALAR"  ) ~= 0,
                self:GetClientNumber( "out_KNOTS"   ) ~= 0,
                self:GetClientNumber( "out_SKMH"    ) ~= 0,
                self:GetClientNumber( "out_SMPH"    ) ~= 0,
                self:GetClientNumber( "out_MPS"     ) ~= 0,
                self:GetClientNumber( "out_BT"      ) ~= 0

        end

    end

    TOOL.ClientConVar = {
        model       = "models/jaanus/wiretool/wiretool_siren.mdl",
        out_AAP     = 1,
        out_LFN     = 1,
        out_DFN     = 1,
        out_WE      = 1,
        out_WFA     = 1,
        out_SCALAR  = 1,
        out_AM      = 1,
        out_AI      = 1,
        out_KNOTS   = 1,
        out_SKMH    = 1,
        out_SMPH    = 1,
        out_MPS     = 1,
        out_BT      = 1
    }
    cleanup.Register( "wire_finos_fin" )

    function TOOL.BuildCPanel( panel )

        panel:AddControl( "Header", { Text = "#Tool.wire_finos_fin.name", Description = "#Tool.wire_finos_fin.desc" } )
        WireDermaExts.ModelSelect( panel, "wire_finos_fin_model", list.Get( "Wire_Misc_Tools_Models" ), 1 )

        panel:CheckBox( "#Tool.wire_finos_fin.out_AAP",     "wire_finos_fin_out_AAP"    )
        panel:CheckBox( "#Tool.wire_finos_fin.out_AM",      "wire_finos_fin_out_AM"     )
        panel:CheckBox( "#Tool.wire_finos_fin.out_AI",      "wire_finos_fin_out_AI"     )
        panel:CheckBox( "#Tool.wire_finos_fin.out_LFN",     "wire_finos_fin_out_LFN"    )
        panel:CheckBox( "#Tool.wire_finos_fin.out_DFN",     "wire_finos_fin_out_DFN"    )
        panel:CheckBox( "#Tool.wire_finos_fin.out_WE",      "wire_finos_fin_out_WE"     )
        panel:CheckBox( "#Tool.wire_finos_fin.out_WFA",     "wire_finos_fin_out_WFA"    )
        panel:CheckBox( "#Tool.wire_finos_fin.out_SCALAR",  "wire_finos_fin_out_SCALAR" )
        panel:CheckBox( "#Tool.wire_finos_fin.out_KNOTS",    "wire_finos_fin_out_KNOTS"   )
        panel:CheckBox( "#Tool.wire_finos_fin.out_SKMH",    "wire_finos_fin_out_SKMH"   )
        panel:CheckBox( "#Tool.wire_finos_fin.out_SMPH",    "wire_finos_fin_out_SMPH"   )
        panel:CheckBox( "#Tool.wire_finos_fin.out_MPS",     "wire_finos_fin_out_MPS"    )
        panel:CheckBox( "#Tool.wire_finos_fin.out_BT",      "wire_finos_fin_out_BT"     )

    end

end
