# SV08 BASIC CONFIGS
Here you can find some slightly modified but almost stock configs for the SV08. Since we went mainline Klipper some changes had to be made.
It will restore as many as the stock Sovol functions as possible and will give you a good starting point.

## Printer cfg
- Please make sure you add the correct serials under the [mcu] and [mcu extra_mcu] configs (check your Sovol printer.cfg backup for this!).
    - Didn't backup your Sovol printer.cfg? You can find it with this command in SSH: `ls /dev/serial/by-id/*` or use KIAUH for this.
- Please uncomment the display import(s) you want to use at the top of the printer.cfg.
- Run currents have been changed to more sensible values (Sovol confused max rating with RMS ratings it seems). Printer now runs more quiet and cooler.
- `max_accel_to_decel` is deprecated, so added new `minimum_cruise_ratio` value.
- Changed the `MCU_fan` to only run when the printer is doing something (either steppers homed or hotend/bed heating) with a 5 minute timeout.
- Changed the `[homing_override]` to go back to center first before homing the other axis.

## Macros
All the .sh scripts have been commented out (if you want that functionality please add it yourself). Changed have been made to the START_PRINT macro so it will now accept your bed & nozzle temperature from the slicer (and use the bed temperature during the init).
- If you want an Auto Z Offset before each print, please uncomment the Z_OFFSET_CALIBRATION in the START_PRINT macro.
- To pass along those temperatures: go to OrcaSlicer -> Edit the printer settings -> Machine G-code -> change your 'START_PRINT' line to this: `START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single]`
- Added a global variable caled 'heat_soak_time' (default 0), please change accordingly. You can also pass along a variable to skip the heatsoak from the slicer, the same as above but add e.g. `HEATSOAK=0` <sub>(0 as in false, not 0 minutes, you pass along you want heatsoak or not. The heatsoak time is configured as a global var in your macros.cfg)</sub>
- Changed the START_PRINT so it does a 'Home Z' after the QGL (which in theory can change your z-offset) to get more consistent results.

## Menu
The menu has been changed in such a way it's a reduced and somewhat more basic menu based on the Sovol menu. Some things might not work or are removed. *Still a work in progress.*

## Crowsnest
Default Sovol crowsnest .conf is added as well. Please add the webcam in Mainsail -> Interface Settings -> Webcams.
