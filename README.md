# FIN OS Tool (FIN OPEN SOURCE)

**[FIN OS Tool on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2440349261)**

### You can find the stand alone tool under: **Weapons => ravo Norway => Fin OS Tool**

**Made from scratch, and based on the modern lift equation: https://wright.nasa.gov/airplane/lifteq.html**

### How to use:
* You can find the stand alone tool under: ***Weapons => ravo Norway => Fin OS Tool***
* **Left-Click to apply** 3 - 26 local origo originated vector points on prop, to get started. This will calculate the area using .5 the length of the cross product for all the triangles
* **( IN_USE + Left-Click ) to add** a flap. Connect by clicking on the fin/flap and on the flap/fin
* **Right-Click to add** fin to *tracked fin table*
* **Reload to remove** fin/flap from prop
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
- Added a way to adjust the scalar for lift ( IN_USE + SCROLL_WHEEL )
- Added so the player can view the current scalar for the lift in the default pop-up settings panel
- Added so the player can Right-Click to view/hide a panel that shows the wing's current speed and attack angle
### 0.0.4 ( 29.03.21 )
- Added so the user can attach another entity that will increase/decrease the *C[L]* value ( a flap )
- Completed the way a fin receives lift ( the logic ) [ BIG CHANGE ]
- Added ConVar "finos_rhodensistyfluidvalue" and "finos_maxscalarvalue"
- Fixed bugs
- Cleaned up and improved code
### 0.0.41 ( 30.03.21 )
- Updated entity icon
- Updated GUI colors to match new logo
### 0.0.42 ( 30.03.21 )
- Fixed a few minor bugs
### 0.0.5 ( 02.04.21 )
- Math and logic for checking if a to be new vector line crosses any old vector lines ( not allowed )

## @todo
- BUG: Adjust logic for checking if a vector crosses when prop does not not spawn in a perfect position like many flat PHX's

## Licence
This addon is created by [ravo (Norway)](https://steamcommunity.com/sharedfiles/filedetails/?id=1647345157) or the uploader of this current viewed [SWEP](https://steamcommunity.com/sharedfiles/filedetails/?id=2440349261) on Steam Workshop.
All of the custom code created by the creator/uploader (this site), that is given for FIN OS Tool, is supplied under the: [CC BY-NC-SA 4.0 Licence](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en) If not specified otherwise.

### Copyright content
* The tool model is a modded version of the original Garry's Mod toolgun

## Author
*ravo Norway*

[PayPal - ravonorway](https://paypal.me/ravonorway)
