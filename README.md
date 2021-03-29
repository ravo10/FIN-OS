# FIN OS Tool (FIN OPEN SOURCE)

### How to use:
* You can find the stand alone tool under: ***Weapons => ravo Norway => Fin OS Tool***
* **Left-Click to apply** 3 - 26 local origo originated vector points on prop, to get started. This will calculate the area using the length of the cross products
* **( IN_USE + Left-Click ) to add** a flap. Connect by clicking on the fin/flap and on the flap/fin
* **Right-Click to add** fin to *tracked fin table*
* **Reload to remove** fin from prop
* **( IN_USE + SCROLL_WHEEL ) to increase** the scalar value. Look at the fin you want to scale up/down

### How it works:
* It uses **real physics** to calculate lift from the center of the prop, and real life formula for calculating lift: *Force[LIFT] = .5 * rho[AIR] * Velocity[m/s]^2 * Area[m^2] * C[L - angle of attack]*

### Features:
* Supports duplication
* Supports clean up
* Supports SBOX max
* Some ConVar settings

### Console Variables
* **finos_rhodensistyfluidvalue** ( def. = 1.29 ) [ FCVAR_PROTECTED ] - Mass density (rho) that will be applied to Fin OS fin.
* **finos_maxscalarvalue** ( def. = 69 ) [ FCVAR_PROTECTED ] - Maximum scalar value a player can apply to a Fin OS fin.

## BETA
### 0.0.1 ( 28.03.21 )
- Basic functionality
### 0.0.2 ( 28.03.21 )
- Added custom model, spawn icon and menu icon for SWEP tool
- Added a visual way to view the area of the wing
- Added a visual way to see if any vectors are crossing eachother
- Added so you can have as many vector points as the alphabeth is long ( could be infinite )
- Fixed bugs
- Cleaned up and improved code
### 0.0.3 ( 28.03.21 )
- Added a way to adjust the scalar [ 1 - 369 ] for lift ( IN_USE + SCROLL_WHEEL )
- Added so the player can view the current scalar for the lift in the default pop-up settings panel
- Added so the player can Right-Click to view/hide a panel that shows the wing's current speed and attack angle
### 0.0.4 ( 29.03.21 )
- Added so the user can attach another entity that will increase/decrease the *C[L]* value ( a flap )
- Completed the way a fin receives lift ( the logic ) [ BIG CHANGE ]
- Added ConVar "finos_rhodensistyfluidvalue" and "finos_maxscalarvalue"
- Fixed bugs
- Cleaned up and improved code

## @todo
- BUG: Check if any vector lines (two points) are intersecting for area, and do not allow that

## Author
*ravo Norway*
