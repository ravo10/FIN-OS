![alt text](https://repository-images.githubusercontent.com/352235482/93b92c80-90ec-11eb-9efb-7abad5ca096a)
# FIN OS Tool (FIN OPEN SOURCE)

**[FIN OS Tool on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2440349261)**

### You can find the stand alone tool under: **Weapons => Tools => Fin OS Tool**

**Made from scratch, and based on the modern lift equation: https://wright.nasa.gov/airplane/lifteq.html**

### How to use:
* You can find the stand alone tool under: ***Weapons => Tools => Fin OS Tool***
* **Left-Click to apply** 3 - 26 local origo originated vector points on prop, to get started. This will calculate the area using .5 the length of the cross product for all the triangles
* **( IN_USE + Left-Click ) to add** a flap. Connect by clicking on the fin/flap and on the flap/fin
* **Right-Click to add** fin to *tracked fin table*
* **Reload to remove** fin/flap from prop
* **( IN_USE + SCROLL_WHEEL ) to increase** the scalar value. Look at the fin you want to scale up/down
* **( IN_USE + MIDDLE_MOUSE ) to open** the client settings panel

### How it works:
* It uses **real physics** to calculate lift from the center of the prop, and real life formula for calculating lift: *Force[LIFT] = .5 * rho[AIR] * Velocity[m/s]^2 * Area[m^2] * C[L - angle of attack]*

### Features:
* Supports duplication
* Supports clean up
* Supports SBOX max
* Some ConVar settings
* Advanced validity checking of area ( when ```finos_disablestrictmode == 0``` )
* Supports Wiremod input/output ( *Physics => FIN OS Tool* )

### Console Variables
* ```finos_maxfin_os_ent ( def. = 20 ) [ FCVAR_PROTECTED, FCVAR_ARCHIVE ]``` - Amount of Fin OS fin's possible for each Player to spawn ( only for multiplayer ).
* ```finos_rhodensistyfluidvalue ( def. = 1.29 ) [ FCVAR_PROTECTED, FCVAR_ARCHIVE ]``` - Mass density ( rho ) that will be applied to Fin OS fin.
* ```finos_maxscalarvalue ( def. = 69 ) [ FCVAR_PROTECTED, FCVAR_ARCHIVE ]``` - Maximum scalar value a player can apply to a Fin OS fin.
* ```finos_disablestrictmode ( def. = 0 ) [ FCVAR_PROTECTED, FCVAR_ARCHIVE ]``` - Disables checking for angle of prop and crossing vector lines, if you just want to be joking around ( other servers might not accept the duplicate tho ).
* ```finos_disableprintchatmessages ( def. = 1 ) [ FCVAR_PROTECTED, FCVAR_ARCHIVE ]``` - Disables printing messages in chat ( only legacy ).

* ```finos_cl_enableHoverRingBall_fin ( def. = 1 ) [ FCVAR_ARCHIVE ]``` - Clientside. Activate or deactivate the markers for a fin.
* ```finos_cl_enableHoverRingBall_flap ( def. = 1 ) [ FCVAR_ARCHIVE ]``` - Clientside. Activate or deactivate the markers for a flap.
* ```finos_cl_enableAlignAngleHelpers ( def. = 1 ) [ FCVAR_ARCHIVE ]``` - Clientside. Activate or deactivate the "Correct Start Angle Helpers".
* ```finos_cl_enableForwardDirectionArrow ( def. = 1 ) [ FCVAR_ARCHIVE ]``` - Clientside. Activate or deactivate the Forward Direction "Arrow".

* ```finos_cl_gridSizeX ( def. = 9 ) [ FCVAR_ARCHIVE ]``` - Clientside. Adjusts the size of the grid in X position.
* ```finos_cl_gridSizeY ( def. = 9 ) [ FCVAR_ARCHIVE ]``` - Clientside. Adjusts the size of the grid in Y position.

* ```finos_cl_gridColorR ( def. = 13 ) [ FCVAR_ARCHIVE ]``` - Clientside. Change the Red channel for the grid color.
* ```finos_cl_gridColorG ( def. = 146 ) [ FCVAR_ARCHIVE ]``` - Clientside. Change the Green channel for the grid color.
* ```finos_cl_gridColorB ( def. = 241 ) [ FCVAR_ARCHIVE ]``` - Clientside. Change the Blue channel for the grid color.

**WIND Settings:**
* ```finos_wind_maxForcePerSquareMeterAreaAllowed ( def. = 6000 => ( -6000 - 6000 ) ) [ FCVAR_PROTECTED, FCVAR_ARCHIVE ]``` - Max. Allowed Wind Force Per. Square Meter of Area.
* ```finos_wind_minWindScaleAllowed ( def. = 0.1 ) [ FCVAR_PROTECTED, FCVAR_ARCHIVE ]``` - Min. Allowed Wild Wind Scale.
* ```finos_wind_maxWindScaleAllowed ( def. = 6 ) [ FCVAR_PROTECTED, FCVAR_ARCHIVE ]``` - Max. Allowed Wild Wind Scale.
* ```finos_wind_maxActivateThermalWindScaleAllowed ( def. = def.: 200 ) [ FCVAR_PROTECTED, FCVAR_ARCHIVE ]``` - Max. Allowed Thermal Lift Wind Scale.

*Client*
* ```finos_cl_wind_enableWind ( def. = 0 )[ 0 or 1 ] [ FCVAR_ARCHIVE ]``` - Clientside. Activate Wind.
* ```finos_cl_wind_forcePerSquareMeterArea ( def. 300 => ( -300 - 300 ) )[ -300000 - 300000 ] [ FCVAR_ARCHIVE ]``` - Clientside. Wind Force Per. Square Meter of Area.
* ```finos_cl_wind_minWindScale ( def. = 0.4 )[ def.: 0 - 1 ( unit vector ) ] [ FCVAR_ARCHIVE ]``` - Clientside. Min. Wind Scale.
* ```finos_cl_wind_maxWindScale ( def. = 0.8 )[ def.: 0 - 1 ( unit vector ) ] [ FCVAR_ARCHIVE ]``` - Clientside. Max. Wind Scale.
* ```finos_cl_wind_activateWildWind ( def. = 0 )[ 0 or 1 ] [ FCVAR_ARCHIVE ]``` - Clientside. Activate Wild Wind.
* ```finos_cl_wind_minWildWindScale ( def. = 1 )[ def.: 0.1 - 6 ] [ FCVAR_ARCHIVE ]``` - Clientside. Min. Wild Wind Scale.
* ```finos_cl_wind_maxWildWindScale ( def. = 1.13 )[ def.: 0.1 - 6 ] [ FCVAR_ARCHIVE ]``` - Clientside. Max. Wild Wind Scale.
* ```finos_cl_wind_activateThermalWind ( def. = 0 )[ 0 or 1 ] [ FCVAR_ARCHIVE ]``` - Clientside. Activate Thermal Lift Wind.
* ```finos_cl_wind_maxThermalLiftWindScale ( def. = 36 )[ >0.1 - def.: 200 ] [ FCVAR_ARCHIVE ]``` - Clientside. Max. Thermal Lift Wind Scale.

## @todo
- Make a custom world model for the fin tool SWEP
- Fix bones, so it will the Players custom player model
- Small issue with props having different angles ( over 90 degrees ) - compensated for that [ DON'T THINK THIS IS AN ISSUE ANYMORE ]
- Make the strict mode better ( ? )

## Licence
This addon is created by [ravo (Norway)](https://steamcommunity.com/sharedfiles/filedetails/?id=1647345157) or the uploader of this current viewed [SWEP](https://steamcommunity.com/sharedfiles/filedetails/?id=2440349261) on Steam Workshop.
All of the custom code created by the creator/uploader (this site), that is given for FIN OS Tool, is supplied under the: [CC BY-NC-SA 4.0 Licence](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en) If not specified otherwise.

### Copyright content
* The tool model is a modded version of the original Garry's Mod toolgun

## Author
*ravo Norway*

[PayPal - ravonorway](https://paypal.me/ravonorway)
