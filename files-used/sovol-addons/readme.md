# MODIFIED & UPDATED ADDON SCRIPTS
These scripts were added by Sovol for the Z_OFFSET_CALIBRATION (the [probe_pressure] and [z_offset_calibration] parts in the printer.cfg).
Since the scripts by Sovol do not work anymore with the recent version of Klipper, changes have been made to fix this.

Next to those fixes the script has also been improved to read the location of the 'save_variables' filename from the printer.cfg and to read and apply the variable 'offsetadjust' (*mandatory variable inside your save_variables cfg!*) when running the Z_OFFSET_CALIBRATION (instead of during the init requiring a firmware reset after each change in the e.g. saved_variables.cfg).
Other than that the script is unchanged from how Sovol made it..

- You can either use the Z_OFFSET_CALIBRATION manually once to let the printer determine a Z-Offset and then babystep the last bit and do a SAVE_CONFIG and keep using this Z-Offset.
- *Or* put Z_OFFSET_CALIBRATION right after the QGL and homing in the START_PRINT macro to let it calculate the Z-Offset (with the proper bed temperature) before each print.

***Warning:***
- This script calculates a new Z-Offset value and overrides/overwrites the one you might currently have! So any babystepping you have done and saved in e.g. the Mainsail webinterface will be gone.
-  It uses the 'offsetadjust' for small adjustments. So if you always require a certain offset change to obtain a good first layer (after doing a Z_OFFSET_CALIBRATION), apply this change to the 'offsetadjust' so it will use this adjustment in the calulation

## INSTALL
To install these addons you need to copy them (e.g. with an FTP client) to your '~/klipper/klippy/extras/' folder and restart Klipper.
