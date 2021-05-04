if WireToolSetup then
    
    WireToolSetup.setCategory( "Physics/FIN OS Tool" )
    WireToolSetup.open( "finos_flap", "Flap Controller", "gmod_wire_finos_flap", nil, "Fin OS Flap Controller's" )

    if CLIENT then

        language.Add( "tool.wire_finos_flap.name", "FIN OS Tool - Flap Controller (Wire)" )
        language.Add( "tool.wire_finos_flap.desc", "Spawns a Flap Controller for use with the wire system." )

        language.Add( "Tool.wire_finos_flap.out_AAP",   "Output Attack Angle"   )
        language.Add( "Tool.wire_finos_flap.out_AM",    "Output Area (meters)"  )
        language.Add( "Tool.wire_finos_flap.out_AI",    "Output Area (inches)"  )

        TOOL.Information = { { name = "left", text = "Create/Update " .. TOOL.Name } }

    end
    WireToolSetup.BaseLang()
    WireToolSetup.SetupMax( 20 )

    if SERVER then

        function TOOL:GetConVars()

            return
                self:GetClientNumber( "out_AAP" ) ~= 0,
                self:GetClientNumber( "out_AM" )  ~= 0,
                self:GetClientNumber( "out_AI" )  ~= 0

        end

    end

    TOOL.ClientConVar = {
        model       = "models/jaanus/wiretool/wiretool_siren.mdl",
        out_AAP     = 1,
        out_AM      = 1,
        out_AI      = 0
    }
    cleanup.Register( "wire_finos_flap" )

    function TOOL.BuildCPanel( panel )

        panel:AddControl( "Header", { Text = "#Tool.wire_finos_flap.name", Description = "#Tool.wire_finos_flap.desc" } )
        WireDermaExts.ModelSelect( panel, "wire_finos_flap_model", list.Get( "Wire_Misc_Tools_Models" ), 1 )

        panel:CheckBox( "#Tool.wire_finos_flap.out_AAP",    "wire_finos_flap_out_AAP"   )
        panel:CheckBox( "#Tool.wire_finos_flap.out_AM",     "wire_finos_flap_out_AM"    )
        panel:CheckBox( "#Tool.wire_finos_flap.out_AI",     "wire_finos_flap_out_AI"    )

    end

end
