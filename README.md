# Sovol-SV08-Mainline
Getting the Sovol SV08 onto mainline Klipper

This HOWTO will describe how to install mainline/regular klipper (via KIAUH) on your Sovol SV08 with the BTT CB1 image.


**TL;DR**: _make backup of klipper config, remove eMMC from printer, write CB1 image to eMMC, change BoardEnv.txt and system.cfg, put eMMC back in printer, install KIAUH; klipper, moonraker and mainsail (and optional extras), create firmware(s), flash toolhead and board MCU's. DONE!_


## WORK IN PROGRESS
This is a work in progress, still some work needs to be done.. You are the guinea pig ;)
- [ ] write and finish up the MCU flashing parts in the HowTo
- [ ] add some images (something about a thousand words)
- [ ] finalize & test the basic printer.cfg, sovol-macros.cfg and sovol-menu.cfg
- [ ] testing the whole how-to in general


# INDEX
- [PREREQUISITES](#prerequisites)
- [(STEP 1) REMOVING THE EMMC FROM THE PRINTER](#step-1-removing-the-emmc-from-the-printer)
- [(STEP 2) WRITE eMMC OS IMAGE](#step-2-write-emmc-os-image)
  - [METHOD 1: WRITE IMAGE DIRECTLY TO eMMC](#method-1-write-image-directly-to-emmc)
  - [METHOD 2: WRITE IMAGE TO SD -> eMMC](#method-2-write-image-to-sd---emmc)
- [(STEP 3) NECESSARY CHANGES TO THE BOARDENV.TXT & SETUP WIFI](#step-3-necessary-changes-to-the-boardenvtxt--setup-wifi)
- [(STEP 4) INSTALL MAINLINE KLIPPER](#step-4-install-mainline-klipper)
- [(STEP 5) CONFIGURE PRINTER/KLIPPER & ADDONS](#step-5-configure-printerklipper--addons)
- [(STEP 6) FLASH TOOLHEAD MCU](#step-6-flash-toolhead-mcu)
- [(STEP 7) FLASH BOARD MCU](#step-7-flash-board-mcu)
- [BIG THANKS!](#big-thanks)
- [Disclaimer](#disclaimer)


# PREREQUISITES
- First create a backup of all the config files on your original Sovol SV08. You can do this in the web/mainsail interface -> Machine -> Select all files/folders -> Download
  - Optionally you can also SSH or FTP into your machine (username/password: sovol/sovol) and backup additional .sh scripts in the /home/sovol/ folder.
- You WILL need the printer.cfg later in this proces (for the /dev/serial/by-id/usb-Klipper_stm32f103xe_ serials).
- You need a 'Makerbase MKS EMMC-ADAPTER V2 USB 3.0' USB adapter to be able to read/write the eMMC.
  - It is recommended to get yourself a seperate eMMC module (MKS eMMC Module) on which you install the new OS Image and mainline klipper. This way you always have a backup (eMMC) of a working printer.
    - 8GB eMMC have been reported not to work properly. Please get yourself a 32GB MKS eMMC to avoid issues.
- If you go for the '*method 2*' you need a big enough SD card (it's also possible to run everything from the SD card by the way).
- You will need an ST-Link V2 (Mini) with the STM32CubeProgrammer software installed to be able to update/flash the MCU firmwares.


# (STEP 1) REMOVING THE eMMC FROM THE PRINTER
1. Obviously power off and disconnect the printer from mains.
2. Put the printer on it's back so you have access to the underside of the printer.
3. Remove the metal plate by removing the 6 screws.
4. You can now see the eMMC module on the board, remove the 2 screws that are holding it in and caefully remove the eMMC module.
  - Take note of the direction of the eMMC module (*hint; you can also see an arrow on the board which way the module goes*)


# (STEP 2) WRITE eMMC OS IMAGE
Ok, first we need to setup our new eMMC module with the correct OS/Linux build. And for this we are going to use the bigtreetech CB1 Linux image (the original Sovol SV08 image was also based on this).

Here we can use 2 methods: **Method 1**; write the CB1 image directly to the eMMC and use it that way, **Method 2**; write the CB1 image to an SD card and use that to get the CB1 image on the eMMC.<br>
<sub>**Method 3**: choose to run everything from the SD card and stop at Method 2.2</sub>

*Reason: it appears some people have boot issues when writing the CB1 image directly to the eMMC (board/eMMC does boot), the second method has been proven to be more succesful in getting a booting eMMC. So method 1 does not work for you? Give method 2 a try, or start with method 2 directly.*


# METHOD 1: WRITE IMAGE DIRECTLY TO eMMC
1. First get yourself de latest image from: https://github.com/bigtreetech/CB1/releases
  - Used in this example 'CB1_Debian11_minimal_kernel5.16_20240319.img.xz'
2. Put the eMMC module in the USB adapter (again, mind the direction of the module, there is an arrow on the adapter) and put the USB adapter in your computer.
3. Use BalenaEtcher (https://github.com/balena-io/etcher/releases) to write the image to the eMMC
  - Used in this example: balenaEtcher-win32-x64-1.19.21.zip (portable, so doesn't need an installer)
  - Open Balena Etcher -> choose Flash from file, browse and choose the downloaded CB1 image -> Select the eMMC drive (e.g. Generic USB STORAGE DEVICE USB device) -> Flash! (this will erase everything on the eMMC!)
4. After the flash is complete you can close BalenaEtcher. If everything is allright you now see a FAT drive called 'BOOT' (if not, eject the USB adapter and put it back in)
  - *You can now continue to **STEP 3***


# METHOD 2: WRITE IMAGE TO SD -> eMMC
1. First get yourself de latest image from: https://github.com/bigtreetech/CB1/releases
  - Used in this example 'CB1_Debian11_minimal_kernel5.16_20240319.img.xz'
2. Use BalenaEtcher (https://github.com/balena-io/etcher/releases) to write the image to the **SD card**
  - Used in this example: balenaEtcher-win32-x64-1.19.21.zip (portable, so doesn't need an installer)
  - Open Balena Etcher -> choose Flash from file, browse and choose the downloaded CB1 image -> Select the **SD card** -> Flash! (this will erase everything on the SD card!)
    - *Sidenote here: you could, if you choose here, run the printer from the SD card and skip the whole eMMC.. Just so you know ;-)*
3. Put the eMMC module in the USB adapter (again, mind the direction of the module, there is an arrow on the adapter) and put the USB adapter in your computer.
4. We need to clear all the partitions from the eMMC (this will erase everything on the eMMC!):
  - In Windows open the command prompt (Win-R -> cmd) and run `diskpart` (be careful with diskpart, we don't want to erase the wrong disk here!)
  - In diskpart do `list disk` and see what disk is your eMMC
  - In diskpart run `select disk <nr>` where <nr> is the number of your eMMC. Please make sure this is the correct disk before you continue!
  - In diskpart run `clean` and it will erase everything/all partitions from the eMMC disk.
  - In diskpart run `exit` to exit
5. *You can now continue to **STEP 3** and then come back here!*
6. If everything is ok you should have booted from the SD card and it's time to copy all the contents to the eMMC and make it bootable.
  - First check if the eMMC is recognized and available:
    - Run the command `fdisk -l` and you should see some storage devices including the eMMC (*e.g. /dev/mmcblk1 for the SD card and /dev/mmcblk2 your eMMC*)
  - Run the command `sudo nand-sata-install`
    - Choose the option 'Boot from eMMC - system on eMMC'
  - It will now create and format a partition (ext4) on the eMMC and it will copy all it's contents from the SD card to the eMMC
  - When it's done poweroff the SV08, remove the SD card and boot from the eMMC. If everything has gone correctly you should now boot from the eMMC and can continue with **STEP 4**.


# (STEP 3) NECESSARY CHANGES TO THE BOARDENV.TXT & SETUP WIFI
To make the CB1 image setup correctly we need to make a few changes to the BoardEnv.txt. Also we need to setup wifi credentials (if not connected via ethernet) in the system.cfg

1. Go to the 'BOOT' drive and open 'BoardEnv.txt' in your favourite text editor.

2. You need the following settings, and only those settings (taken from the Sovol image, please change/add/adapt where necessary):
```
bootlogo=true
overlay_prefix=sun50i-h616
fdtfile=sun50i-h616-biqu-emmc
console=display
overlays=uart3
overlays=ws2812
overlays=spidev1_1
#------------------------------------------------#
rootdev=UUID=795df55f-3e45-4625-a9cb-f6706b356274
rootfstype=ext4
```

<sub>(**NOTE 1**: just keep the rootdev and rootfstype under the #----# line as they are in your BoardEnv.txt, don't copy the above if not the same)</sub><br>
<sub>(**NOTE 2**: fdtfile=sun50i-h616-biqu-emmc is needed so your eMMC is supported and available)</sub>
  - Save your changed BoardEnv.txt!

4. Change the WiFi credentials in the 'system.cfg'
  - optional: uncomment the hostname and set the hotname to e.g. "SV08"
  - Save changes to the system.cfg

5. Eject the USB adapter from your computer and put that eMMC (and **SD card** in case of *method 2*) back into the printer and boot that thang!
  - SSH into the printer (find ip on your router or use previous configured hostname), username/password: biqu/biqu
  - If everything is ok your printer will boot nicely, you can SSH into the printer and you are done with this step and ready to install mainline klipper or continue ***method 2**, point 6, and finalize the write to eMMC*!



# (STEP 4) INSTALL MAINLINE KLIPPER
Time for the fun stuff! Now we shall install KIAUH, Klipper, Moonraker etc.
Please SSH into your printer and then do the following steps.

1. First we will update the OS, do a 'sudo apt update && sudo apt upgrade'
2. Then install git (might already be installed) and KIAUH with the following commands:
  - sudo apt-get update && sudo apt-get install git -y
  - cd ~ && git clone https://github.com/dw-0/kiauh.git

3. Start KIAUH with the following command:
  - ./kiauh/kiauh.sh

4. Install Klipper, Moonraker, Mainsail and Crowsnest (in this order) via KIAUH.
  - So run KIAUH and choose option '1) [Install]' and install those items (using default options, download recommended macro's; Yes).
  - Crowsnest install asks to reboot printer, please do so.

5. You have now installed mainline klipper with the mainsail web-interface!
  - If not rebooted after Crowsnest install: sudo reboot
  - After the board has rebooted, in your browser go to mainsail web-interface (via the ip-address or hostname) and check if it's running.
  - Obviously it will give an error since we still have to put our backupped printer.cfg back.


# (STEP 5) CONFIGURE PRINTER/KLIPPER & ADDONS
Next we have to configure our printer and put back some addons Sovol has added (probe_pressure and z_offset_calibration) and get the basics working.

1. RESTORE THE SOVOL ADDONS (from the /sovol-addons/ directory); use an FTP program to connect to the printer (ip-address or hostname, username/password: biqu/biqu) and put the files 'probe_pressure.py' and 'z_offset_calibration.py' into the '/klipper/klippy/extras/' folder.
2. CONFIGURE PRINTER (from the /config/ directory): now copy the printer.cfg, sovol-macros.cfg, sovol-menu.cfg, saved_variables.cfg and crowsnest.conf to the '/home/biqu/printer_data/config' folder.
- **IMPORTANT**: open your backed up printer.cfg and copy the correct serials under [mcu] and [mcu extra_mcu] (/dev/serial/by-id/usb-Klipper_stm32f103xe_) to your new printer.cfg.

3. Do a firmware_restart (or reboot the whole printer) and you should have a working SV08.
4. Update the slicer start g-code. The START_PRINT macro has been updated/improved: uses your actual bed temperature for meshing etc, does a QGL with home Z, does a Z_OFFSET_CALIBRATION before each print.
  - Go to OrcaSlicer -> Edit the printer settings -> Machine G-code -> change your 'START_PRINT' line to this: START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single]
  - Now you can print and use the sovol presets like before!

<sub>(**NOTE 1**: all the .sh scripts in the macro's and have been commented out and there is a basic but reduced version of the sovol menu. It has all the basics to get you going.)</sub><br>
<sub>(**NOTE 2**: the [adxl345] and [resonance_tester] configs have been commented out, the toolhead mcu needs a new firmware for this, the Sovol MCU firmwares are currently already outdated).</sub>



# (STEP 6) FLASH TOOLHEAD MCU
Next we need to update our toolhead MCU's with a new klipper firmware. For this we need the ST Link USB Adapter and STM32CubeProgrammer installed and ready to go. This will ensure our MCU's are also flashed with mainline klipper and everything can communicate with eachother like it's supposed to.
We start with the toolhead MCU
1.
2.


# (STEP 7) FLASH BOARD MCU
Now it's time to update the board MCU
1. 
2. 


# BIG THANKS!
Big thanks to all the people on the Sovol discords (both official and unofficial) who have helped or participated in this project in any way.
Special thanks go out to: ss1gohan13, michrech, Zappes, cluless, Haagel  - *you guys rock!*


## Disclaimer
This guide and all changes have been made with best intentions but in the end it's your responsibility and *only your responsibility* to apply those changes and modifications to your printer. Neither the author, contributers or Sovol is responsible if things go bad, break, catch fire or start WW3. You do this on your own risk!
