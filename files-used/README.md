<h1>Files</h1>
In this folder you can find all the files you will need during the mainline Klipper guide. See below for a short summary (in order of the guide).

### /dtb-files
In order to get proper eMMC support we need to add the Sovol dtb file for this (the original 8GB eMMC to be exact, this one will not work unless we use this file). You can find the `sun50i-h616-sovol-emmc.dtb` in this folder. Please add this file on your eMMC (or SD card) BOOT partition in `/dtb/allwinner/`. Next make sure you have `fdtfile=sun50i-h616-sovol-emmc` in your `BoardEnv.txt` file. _This will be done and explained in the guide at **Step 3**._

### /sovol-addons
These scripts were added by Sovol for the Z_OFFSET_CALIBRATION (the [probe_pressure] and [z_offset_calibration] parts in the printer.cfg).
Since the scripts by Sovol do not work anymore with the recent version of Klipper, changes have been made to fix this.

To install these addons you need to copy them (e.g. with an FTP client) to your '~/klipper/klippy/extras/' folder and restart Klipper. _For more info see **Step 5** in the guide and the readme in the /sovol-addons folder._

### /config
Here you will find the files that will go into your `~/printer_data/config` folder on the printer. Please make sure you add the correct serials to your printer.cfg at the `[mcu]` and `[mcu extra_mcu]` entries. _This will be done and explained in the guide at **Step 8**._

### Automatic MCU update script
This is the exception! You can still find and download this script here: [Automatic MCU update script](https://github.com/Rappetor/Sovol-SV08-Mainline/blob/main/Automatic%20MCU%20script%20update)
