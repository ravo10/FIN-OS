![alt text](https://repository-images.githubusercontent.com/352235482/93b92c80-90ec-11eb-9efb-7abad5ca096a)
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
* Advanced validity checking of area ( when ```finos_disablestrictmode == 0``` )

### Console Variables
* ```**finos_rhodensistyfluidvalue** ( def. = 1.29 ) [ FCVAR_PROTECTED ]``` - Mass density ( rho ) that will be applied to Fin OS fin.
* ```**finos_maxscalarvalue** ( def. = 69 ) [ FCVAR_PROTECTED ]``` - Maximum scalar value a player can apply to a Fin OS fin.
* ```**finos_disablestrictmode** ( def. = 0 ) [ FCVAR_PROTECTED ]``` - Disables checking for angle of prop and crossing vector lines, if you just want to be joking around ( other servers might not accept the duplicate tho ).
* ```**finos_disableprintchatmessages** ( def. = 1 ) [ FCVAR_PROTECTED ]``` - Disables printing messages in chat ( only legacy ).

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
- Added math and logic for checking if a to be new vector line crosses any old vector lines ( not allowed )
### 0.0.6 ( 05.04.21 )
- Finished up adding a program for checking if a new vector line crosses any old ones ( not allowed )
- Added so after the first point is set, the prop always need to be in that local angle and have the same local normal vector from toolgun hit afterwards ( to not mess up the area ). In simple words: prop needs to have it's original angles for adding points and it can only be on one side ( strict mode )
- Fixed some duplication issues/bugs
- Added so it will check if the duplication has some security issues, like crossing lines ( strict mode )
- Added ConVar "finos_disablestrictmode" ( important to use on servers that want no cheating with area definition )
- Adjusted color to tool menu text
- Added so Player can't set points within the area so it e.g. doubles up ( strict mode )
- Adjusted the color pallette for the control panels

## @todo
- Make a custom world model for the fin tool SWEP
- Fix bones, so it will the Players custom player model
- Make the strict mode better ( ? )
- More testing to make be assured it is stable, for a stable release

## Licence
This addon is created by [ravo (Norway)](https://steamcommunity.com/sharedfiles/filedetails/?id=1647345157) or the uploader of this current viewed [SWEP](https://steamcommunity.com/sharedfiles/filedetails/?id=2440349261) on Steam Workshop.
All of the custom code created by the creator/uploader (this site), that is given for FIN OS Tool, is supplied under the: [CC BY-NC-SA 4.0 Licence](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en) If not specified otherwise.

### Copyright content
* The tool model is a modded version of the original Garry's Mod toolgun

## Author
*ravo Norway*

[PayPal - ravonorway](https://paypal.me/ravonorway)
