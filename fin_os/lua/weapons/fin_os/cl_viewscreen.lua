
local matScreen = Material( "models/weapons/v_fin_os_toolgun/screen" )
local txBackground = surface.GetTextureID( "models/weapons/v_fin_os_toolgun/screen_bg" )

-- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local RTTexture = GetRenderTarget( "GModToolgunScreen", 256, 256 )

surface.CreateFont( "GModToolScreen", { font = "Helvetica", size = 60, weight = 900 } )

local function DrawScrollingText( text, y, texwide )

	local w, h = surface.GetTextSize( text )
	w = w + 64

	y = y - h / 2 -- Center text to y position

	local x = RealTime() * 100 % w * -1

	while ( x < texwide ) do

		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( x + 3, y + 3 )
		surface.DrawText( text )

		surface.SetTextColor( 240, 226, 107, 234 )
		surface.SetTextPos( x, y )
		surface.DrawText( text )

		x = x + w

	end

end

--[[---------------------------------------------------------
	We use this opportunity to draw to the toolmode
		screen's rendertarget texture.
-----------------------------------------------------------]]
function SWEP:RenderScreen()

	local TEX_SIZE = 256
	local mode = GetConVarString( "gmod_toolmode" )
	local oldW = ScrW()
	local oldH = ScrH()

	-- Set the material of the screen to our render target
	matScreen:SetTexture( "$basetexture", RTTexture )

	local OldRT = render.GetRenderTarget()

	-- Set up our view for drawing to the texture
	render.SetRenderTarget( RTTexture )
	render.SetViewPort( 0, 0, TEX_SIZE, TEX_SIZE )
	cam.Start2D()

		-- Background
		surface.SetDrawColor( 0, 193, 255, 255 )
		surface.SetTexture( txBackground )
		surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )

		surface.SetFont( "GModToolScreen" )
		DrawScrollingText( "FIN OS (fly baby)", 104, TEX_SIZE )

	cam.End2D()
	render.SetRenderTarget( OldRT )
	render.SetViewPort( 0, 0, oldW, oldH )

end
