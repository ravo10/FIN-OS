-- ///////////////////////////////////////////////////////////////////////////////
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION INITIIALIZATION
-- ///////////////////////////////////////////////////////////////////////////////
SWEP.PrintName = "FIN OS Tool"
SWEP.Author = "ravo (Norway)"
SWEP.Category = "ravo Norway"
SWEP.Contact = "N/A"
SWEP.Purpose = "Produce a FIN (prop-physics)"
SWEP.Instructions = [[
Left-Click to APPLY
Reload to REMOVE
]]

SWEP.ViewModel = "models/weapons/v_fin_os_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"

util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)

SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false

SWEP.HoldType = "pistol"

SWEP.ViewModelFOV = 84.221105527638
SWEP.ViewModelFlip = false

SWEP.Slot = 5 -- From 0 - 5
SWEP.SlotPos = 1 -- From 0 - 128
SWEP.BounceWeaponIcon = true

SWEP.UseHands = false
SWEP.Spawnable = true

SWEP.Weight = 1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Tool = {}

SWEP.ShootSound = Sound( "Airboat.FireGunRevDown" )

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.CanHolster = true
SWEP.CanDeploy = true

SWEP.ShouldDropOnDie = false

-- Very important
SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

cleanup.Register( "fin_os" )

function SWEP:SetupDataTables()
    self:NetworkVar( "String", 0, "ActiveFinEntities" )

    if SERVER then
        self:SetActiveFinEntities( "" )
    end

end

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )
