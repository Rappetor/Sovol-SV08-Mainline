# Sovol-SV08-Mainline

Getting the Sovol SV08 onto mainline Klipper

This repository will describe installing mainline/regular klipper (via KIAUH) on your Sovol SV08 with the BTT CB1 image.<br>
<sub>Run it from either eMMC or SD card, you choose.</sub>

**TL;DR**: _make a backup of klipper config, remove the eMMC from the printer, write CB1 image to eMMC, change BoardEnv.txt and system.cfg, put the eMMC back in the printer, install KIAUH; klipper, moonraker, and mainsail (and optional extras), create firmware(s), flash the tool head MCU and board MCU. DONE!_

<br>

# READ ME FIRST!

This guide uses color codes to showcase important info.

> [!CAUTION]
> If you see text inside a red box, you NEED to read what is in the box.

> [!IMPORTANT]
> If you see text inside the purple box, it's an important piece of information.

> [!NOTE]
> If you see text inside a blue box, this info is typically a helpful tip or a useful note.

Ok, now you can continue.

## WORK IN PROGRESS

> [!NOTE]
> This is a work in progress, and some work needs to be done. You are the guinea pig ;) <br> Found something that doesn't work (properly), please share and contribute!

# INDEX

- [PREREQUISITES](#prerequisites)
- [STEP 1 - REMOVING THE EMMC FROM THE PRINTER](#step-1---removing-the-emmc-from-the-printer)
- [STEP 2 - WRITE eMMC OS IMAGE](#step-2---write-emmc-os-image)
  - [METHOD 1: WRITE IMAGE DIRECTLY TO eMMC](#method-1-write-image-directly-to-emmc)
  - [METHOD 2: WRITE IMAGE TO SD -> eMMC](#method-2-write-image-to-sd---emmc)
- [STEP 3 - CHANGES TO THE BOARDENV.TXT & SETUP WI-FI](#step-3---changes-to-the-boardenvtxt--setup-wi-fi)
- [STEP 4 - INSTALL MAINLINE KLIPPER](#step-4---install-mainline-klipper)
- [STEP 5 - CONFIGURE PRINTER/KLIPPER & ADDONS](#step-5---configure-printerklipper--addons)
- [STEP 6 - STOCK FIRMWARE BACKUP](#step-6---stock-firmware-backup)
- [STEP 7 - FLASH KATAPULT BOOTLOADER](#step-7---flash-katapult-bootloader)
- [STEP 8 - FLASH KLIPPER](#step-8---flash-klipper)
- [BIG THANKS & CONTRIBUTE](#big-thanks--contribute)
- [DISCLAIMER](#disclaimer)

# PREREQUISITES

- First, create a **backup** of all the config files on your original Sovol SV08. You can do this in the web/mainsail interface -> Machine -> Select all files/folders -> Download.
  - Optionally you can also SSH or FTP into your machine (ftp port: 22, username/password: sovol/sovol) and backup additional .sh scripts in the /home/sovol/ folder.
- You WILL need the printer.cfg later in this process (for the /dev/serial/by-id/usb-Klipper*stm32f103xe* serials).
- You need a '**Makerbase MKS EMMC-ADAPTER V2 USB 3.0**' USB adapter to be able to read/write the eMMC.
  - It is recommended to get yourself a separate **eMMC module** (MKS eMMC Module) on which you install the new OS Image and mainline klipper. This way you always have a backup (eMMC) of a working printer.
    - 8GB eMMC has been reported not to work properly. Please get yourself a 32GB MKS eMMC to avoid issues.
- If you go for the '_method 2_' you need a big enough **SD card** (it's also possible to run everything from the SD card by the way).
- You will need an ST-Link V2 (Mini) with the **STM32CubeProgrammer** software installed to be able to update/flash the MCU firmware.
- You can reach the sFTP server on the IP of the printer, on port 22

> [!NOTE]
> Here is one example listing for the adapter and also a 32GB eMMC module <br>https://www.aliexpress.us/item/3256807073480438.html

<br>

# STEP 1 - REMOVING THE eMMC FROM THE PRINTER

> [!CAUTION]
> POWER OFF AND UNPLUG THE PRINTER FROM THE OUTLET.

1. Put the printer on its back, so you have access to the underside of the printer.
2. Remove the metal plate by removing the 6 screws.
3. You can now see the eMMC module on the board, remove the 2 screws that are holding it in, and carefully remove the eMMC module.
   - Take note of the direction of the eMMC module (_hint; you can also see an arrow on the board which way the module goes_)

<br>

# STEP 2 - WRITE eMMC OS IMAGE

Ok, first we need to set up our new eMMC module with the correct OS/Linux build. And for this, we are going to use the BIGTREETECH CB1 Linux image (the original Sovol SV08 image was also based on this).

Here we can use 3 methods:

**Method 1**: Write the CB1 image directly to the eMMC and use it that way

**Method 2**: Write the CB1 image to an SD card and use that to get the CB1 image on the eMMC.

_**Method 3**: Choose to run everything from the SD card and stop at Method 2.2_

> [!NOTE]
> _Reason: it appears some people have boot issues when writing the CB1 image directly to the eMMC (board/eMMC does boot), the second method has been proven to be more successful in getting a booting eMMC. So method 1 does not work for you? Give method 2 a try, or start with method 2 directly._

<br>

## METHOD 1: WRITE IMAGE DIRECTLY TO eMMC

1. Download the **MINIMAL** BIGTREETECH image. Careful, there's also a full image that has an unknown version of Klipper already installed. Go to: https://github.com/bigtreetech/CB1/releases
   - Used in this example 'CB1_Debian11_minimal_kernel5.16_20240319.img.xz': https://github.com/bigtreetech/CB1/releases/download/V2.3.4/CB1_Debian11_minimal_kernel5.16_20240319.img.xz
2. Put the eMMC module in the USB adapter (again, mind the direction of the module, there is an arrow on the adapter) and put the USB adapter in your computer.
3. Use BalenaEtcher (https://github.com/balena-io/etcher/releases) to write the image to the eMMC
   - Used in this example: balenaEtcher-win32-x64-1.19.21.zip (portable, so doesn't need an installer)
   - Open Balena Etcher<br>
     -> Choose "Flash from file", browse and choose the downloaded CB1 image<br>
     -> Select the eMMC drive (e.g. Generic USB STORAGE DEVICE USB device)<br>
     -> Flash! (this will erase everything on the eMMC!)
4. After the flash is complete you can close BalenaEtcher. If everything is alright you now see a FAT drive called 'BOOT' (if not, eject the USB adapter and put it back in)

_You can now continue to **STEP 3**_

<br>

## METHOD 2: WRITE IMAGE TO SD -> eMMC

1. First get yourself de latest image from: https://github.com/bigtreetech/CB1/releases

   - Used in this example 'CB1_Debian11_minimal_kernel5.16_20240319.img.xz': https://github.com/bigtreetech/CB1/releases/download/V2.3.4/CB1_Debian11_minimal_kernel5.16_20240319.img.xz<br>

2. Use BalenaEtcher (https://github.com/balena-io/etcher/releases) to write the image to the **SD card**
   - Used in this example: balenaEtcher-win32-x64-1.19.21.zip (portable, so doesn't need an installer)
   - Open Balena Etcher<br>
     -> Choose "Flash from file", browse and choose the downloaded CB1 image<br>
     -> Select the **SD card** <br>
     -> Flash! (this will erase everything on the SD card!)<br>

> [!NOTE]
> _Sidenote here: you could, if you choose here, run the printer from the SD card and skip the whole eMMC. Just so you know ;-)_

3. Put the eMMC module in the USB adapter (again, mind the direction of the module, there is an arrow on the adapter) and put the USB adapter in your computer.<br>

4. We need to clear all the partitions from the eMMC (this will erase everything on the eMMC!) :
   - In Windows open the command prompt (Win-R -> cmd) and run `diskpart` (be careful with diskpart, we don't want to erase the wrong disk here!)
   - In diskpart do `list disk` and see what disk is your eMMC
   - In diskpart run `select disk <nr>` where <nr> is the number of your eMMC. Please make sure this is the correct disk before you continue!
   - In diskpart run `clean` and it will erase everything/all partitions from the eMMC disk.
   - In diskpart run `exit` to exit

![Diskpart](images/haa/diskpart.png)

_You can now continue to **STEP 3** and then come back here!_

5. If everything is ok you should have booted from the SD card, and it's time to copy all the contents to the eMMC and make it bootable.
   - First, check if the eMMC is recognized and available:
     - Run the command `fdisk -l` and you should see some storage devices including the eMMC (_e.g. /dev/mmcblk1 for the SD card and /dev/mmcblk2 for the eMMC_).
   - Run the command `sudo nand-sata-install`:
     - Choose the option 'Boot from eMMC - system on eMMC'.
   - It will now create and format a partition (ext4) on the eMMC, and it will copy all its contents from the SD card to the eMMC.
   - When it's done power off the SV08, remove the SD card, and boot from the eMMC. If everything has gone correctly you should now boot from the eMMC and can continue with **STEP 4**.

<br>

# STEP 3 - CHANGES TO THE BOARDENV.TXT & SETUP WI-FI

To make the CB1 image setup correctly we need to make a few changes to the BoardEnv.txt. Also, we need to set up Wi-Fi credentials (if not connected via ethernet) in the system.cfg

1. Go to the 'BOOT' drive and make a **BACKUP** of 'BoardEnv.txt' on your hard disk.
2. Open 'BoardEnv.txt' in your favourite text editor.
3. You need the following settings, and only those settings (taken from the Sovol image, please change/add/adapt where necessary):
   ```
   bootlogo=false
   overlay_prefix=sun50i-h616
   fdtfile=sun50i-h616-biqu-emmc
   console=display
   overlays=uart3
   overlays=ws2812
   overlays=spidev1_1
   #------------------------------------------------#
   rootdev=UUID=795...WHATEVER-WAS-THE-ORIGINAL-VALUE-SEE-NOTE-1...274
   rootfstype=ext4
   ```
   > [!NOTE]
   > <sub>**NOTE 1**: just keep the rootdev and rootfstype under the #----# line as they are in your BoardEnv.txt, don't copy the above if not the same</sub><br>
   > <sub>**NOTE 2**: `fdtfile=sun50i-h616-biqu-emmc` is needed so your eMMC is supported and available</sub><br>
   > <sub>**NOTE 3**: if you want to run everything from the SD card, then you can keep it like this: `fdtfile=sun50i-h616-biqu-sd`</sub><br>
   > <sub>**NOTE 4**: by setting bootlogo=false you get the Linux boot messages on the HDMI display, if you set bootlogo=true you only see them when connecting a keyboard and pressing a key.</sub><br>

- Save your changed BoardEnv.txt!

4. Change the Wi-Fi credentials in the 'system.cfg'

   - Optional: uncomment the hostname and set the hostname to e.g. "SV08"
   - Save changes to the system.cfg

5. Eject the USB adapter from your computer then put the eMMC (and **SD card** in case of _method 2_) back into the printer and boot it, then:
   - SSH into the printer (find the IP address on your router or use the configured hostname), username/password: biqu/biqu
   - If everything is ok your printer will boot nicely, you can SSH into the printer, and you are done with this step and ready to install mainline Klipper. You can also continue _**Method 2**, point 6, and finalize writing the system to eMMC!_

<br>

# STEP 4 - INSTALL MAINLINE KLIPPER

Time for the fun stuff! Now we shall install KIAUH, Klipper, Moonraker, etc.
Please SSH into your printer and then do the following steps.

1. First, we will update the OS:<br>

   ```bash
   sudo apt update && sudo apt upgrade
   ```

2. Then install git (which might already be installed) and KIAUH with the following commands:

   ```bash
   sudo apt-get update && sudo apt-get install git -y
   ```

   ```bash
   cd ~ && git clone https://github.com/dw-0/kiauh.git
   ```

3. Start KIAUH with the following command :

   ```bash
   ./kiauh/kiauh.sh
   ```

4. Install Klipper, Moonraker, Mainsail, and Crowsnest (in this order) via KIAUH.

   - So run KIAUH and choose: option **'1) [Install]'** and install those items (_using default options, download recommended macros; Yes_).
   - Crowsnest install asks to reboot the printer, please do so.

5. Install Numpy (needed for input shaping)

   ```bash
   sudo apt update
   sudo apt install python3-numpy python3-matplotlib libatlas-base-dev libopenblas-dev
   ~/klippy-env/bin/pip install -v numpy
   ```

6. You have now installed mainline Klipper with the Mainsail web interface!
   - If you haven't rebooted after installing Crowsnest:<br> `sudo reboot`
   - After the board has rebooted, in your browser go to the Mainsail web interface (via the IP address or hostname) and check if it's running.
   - It will give an error since we still have to put our backed-up printer.cfg back.

<br>

# STEP 5 - CONFIGURE PRINTER/KLIPPER & ADDONS

Next, we have to configure our printer and put back some addons Sovol has added (probe_pressure and z_offset_calibration) and get the basics working.

1. RESTORE THE SOVOL ADDONS _(from the `/sovol-addons/` directory)_:<br>
    - Use an FTP program to connect to the printer (IP address or hostname, ftp port: 22, username/password: biqu/biqu)
    - Put the files 'probe_pressure.py' and 'z_offset_calibration.py' into the '/klipper/klippy/extras/' folder.<br>

2. CONFIGURE PRINTER _(from the `/config/` directory)_ :<br>

   - Copy:<br>
     `printer.cfg`<br>
     `sovol-macros.cfg`<br>
     `sovol-menu.cfg`<br>
     `saved_variables.cfg`<br>
     `crowsnest.conf`<br>

     to the `~/printer_data/config` folder.<br>

   - **IMPORTANT**: Open your backed-up printer.cfg and copy the correct serials under [mcu] and [mcu extra_mcu] (/dev/serial/by-id/usb-Klipper*stm32f103xe*) to your new printer.cfg<br>

3. Do a firmware_restart (or reboot the whole printer) and you should have a working SV08.

4. Update the slicer start g-code. The START_PRINT macro has been updated/improved: uses your actual bed temperature for meshing etc., does a QGL with home Z, and does a Z_OFFSET_CALIBRATION before each print.

   - Go to OrcaSlicer and edit the printer settings :<br>
     -> Machine<br>
     -> G-code<br>
     -> Change your 'START_PRINT' line to this:<br>

     ```
      START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single]
     ```

   - Now you can print and use the sovol presets like before!

> [!NOTE]
> <sub>**NOTE 1**: all the .sh scripts in the macros have been commented out and there is a basic but reduced version of the sovol menu. It has all the basics to get you going.</sub><br>
> <sub>**NOTE 2**: the [adxl345] and [resonance_tester] configs have been commented out at this point, the tool head MCU needs a new firmware for this, do the next steps and you can use it again.</sub>

<br>

# STEP 6 - STOCK FIRMWARE BACKUP

> [!IMPORTANT]
> When connecting the ST-Link to the printer, make sure the printer is powered OFF. The MCU will be powered by the ST-Link.

It's important to make a backup of the current (stock) firmware. This way you can always revert to this stock configuration. These steps apply to both the tool head MCU and mainboard MCU.

1. First, make sure you have a properly installed ST-Link with the STM32CubeProgrammer software.

   - Download the STM32CubeProgrammer software here: https://www.st.com/en/development-tools/stm32cubeprog.html#st-get-software
   - Install the software and make sure the ST-Link is also properly installed; the software should show the serial of your ST-Link just below the CONNECT button (if not you can click on the little refresh button)

2. Turn the printer OFF and remove the ST-Link from your computer, next connect the ST-Link to your board (either tool head or mainboard).

   - MAKE SURE YOU WIRE THIS CORRECTLY, the pinout on the boards is; 3.3v - IO - CLK - GND
   - Refer to your ST-Link manual for the pinout on the adapter!

   ### Toolhead wiring example:

   <p><img src="images/stlink-cables.jpg" alt="toolhead cabling" height="400" align="middle"></p>

   ### Motherboard wiring example:

   <p><img src="images/haa/haa-flash-mb1.jpg" alt="MB cabling" height="400" align="middle"></p><br>

3. Insert the ST-Link into your computer, open the STM32CubeProgrammer software, and press CONNECT. It should now connect and populate the middle screen with memory stuff.
4. Please select `Read all` from the `Read` menu, this will read everything and set the correct size (to save).

![read all](images/stlink-firmware-read-all.jpg)

6. Please select `Save As ..` from the `Read` menu and save the current firmware (e.g. _toolhead_original_firmware.bin_ or _mainboard_original_firmware.bin_).

![save as](images/stlink-firmware-save-as.jpg)

> [!CAUTION]
> Make sure the firmware backup file is 128k. If it is 1 Kilobyte it is too small, and you won't be able to return to the old firmware.
> In case that already happened here is a <a href="firmware-backups/toolhead-0x80000000-sv08-20040628.bin">firmware backup</a> of a SV08 tool head, printer delivered to the EU on 2024-06-28.

<br>

# STEP 7 - FLASH KATAPULT BOOTLOADER

> [!IMPORTANT]
> When connecting the ST-Link to the printer, make sure the printer is powered OFF. The MCU will be powered by the ST-Link.

To make life easier in the future we are going to flash Katapult to our MCUs. This is a bootloader that makes it possible to flash Klipper firmware without the ST-Link via CANBus, USB or UART by the Host.

1. Switch the printer on, SSH into the printer, and install Katapult:

   - Run this command to install Katapult: <br>

   ```bash
   cd ~ && git clone https://github.com/Arksine/katapult
   ```

   - Install pyserial with _(we need this later to flash the firmware)_<br>

   ```bash
   pip3 install pyserial
   ```

2. When it's done, do <br>

   ```bash
   cd ~/katapult && make menuconfig
   ```

   In menuconfig select the following options :<br>
   ![Katapult makemenu config settings](/images/katapult-firmware-settings.jpg)<br>

3. Press Q to quit and save changes.<br>
4. Run the commands to build the firmware (_katapult.bin_):<br>

   ```bash
   make clean
   make
   ```

5. Grab the file `~/katapult/out/katapult.bin` (e.g. with an FTP program) and store it on the computer. You can use this Katapult firmware for both the tool head and the mainboard.
6. Turn OFF the printer again and after it's off insert the ST Link again into the computer and start the STM32CubeProgrammer software and CONNECT.
7. Once connected, on the left side of the software go to the tab 'Erasing & Programming' and execute a `Full chip erase`

![Full chip erase](images/haa/STM32/Etape4.png)

8. Time to flash! Go back to the 'Memory & File editing' tab, click 'Open file', and select the `katapult.bin`, then press the 'Download' button to write the firmware.

![Open file](images/haa/STM32/Etape5.png)<br>

![Download](images/haa/STM32/Etape6.png)<br>

Done! The Katapult bootloader is on the MCU! Please click on 'Disconnect' and then remove the ST-Link from the computer and the board. Do this for both the tool head MCU and the mainboard MCU.

<br>

# STEP 8 - FLASH KLIPPER

> [!NOTE]
> The standard Klipper firmware works on both the toolhead MCU and the mainboard MCU. Originally Sovol made multiple changes to the `stm32f1.c` source for the firmware but they are not mandatory. Only now, the printer starts up silently; no fans, no light, and no display during boot. You CAN get some of this functionality back by enabling GPIO pins during startup, see notes below make menuconfig.

> [!TIP]
> Create a separate text file with the commands (and your serials) for later use. So doing a firmware update is just copying/pasting those commands and you are done much faster!

It's time to create and flash the Klipper firmware! In the future, you only have to do this step when you need to update your Klipper firmware. _This section assumes you already have **Katapult** flashed and **pyserial** (step 7.1) installed._

1. Switch on the printer and SSH into the printer.
2. Open the file printer.cfg. Look at the `[mcu]` and `[extra_mcu]` sections, and copy-paste only the section circled in red for each MCU, we will need it later:

![alt text](images/haa/haa_printercfg.jpg)

- If you have this in your printer.cfg:

![alt text](images/haa/haa_printercfg_tty.jpg)

You have to replace each ID to have the same pattern as above. To do that, find the correct serial name for the MCU with the command<br>

```bash
ls -la /dev/serial/by-id/
```

You will have this :

![alt text](images/haa/haa_lsla.jpg)

Copy the blue part to replace `ttyACM0` or `ttyACM1` in your printer.cfg. At the end, you should have this (with your digits) :

![alt text](images/haa/haa_printercfg2.jpg)

## Two Methods:

#### Method 1 to have the _MCU fan and light_ and _hotend fan_ enabled during boot, as it is in the original Sovol firmware

#### Method 2 to have nothing start at boot<br>

## Method 1:

<br>
1. We are now going to make the Klipper firmware and create a profile for each MCU.<br>

### For the mainboard MCU:

You have to replace xxxx with what you have copied at [2](#step-8---flash-klipper) for the MCU

```bash
sudo service klipper stop
cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_stm32f103xe_xxxx")'
```

Now the MCU is in DFU mode. At this step, if you do `ls /dev/serial/by-id/*`, you will see that it appears with a Katapult ID:

![alt text](<images/haa/klipper firmware.png>)

This is temporary and only during the flashing process in DFU Mode. After completing the flashing, and rebooting the MCU, it will revert to a Klipper ID.
You must never use the Katapult ID in any configuration file.

Now, finish the process :

```bash
cd ~/klipper && make clean KCONFIG_CONFIG=host.mcu
cd ~/klipper && make menuconfig KCONFIG_CONFIG=host.mcu
```

- Choose the following option and add `PA1,PA3` on the last line (_GPIO pins_):<br>

![host_menuconfig](images/haa/haa_host_menuconfig.jpg)<br>

> [!NOTE]
> <sub>**NOTE 1**: Because we are using Katapult as the bootloader, make sure you set the 8 KiB bootloader offset.</sub><br>

- Press Q to quit and save changes.<br>

- Finally, create the firmware and flash the host MCU (your serial should now start with `usb-katapult_`). Once again, replace the xxxx at the end with what you have at [2](#step-8---flash-klipper) for the MCU:<br>

```bash
cd ~/klipper && make KCONFIG_CONFIG=host.mcu && cd ~/katapult/scripts && python3 flashtool.py -d /dev/serial/by-id/usb-katapult_stm32f103xe_xxxx
```

### For the tool head MCU:

You have to replace xxxx with what you have copied at [2](https://github.com/Haagel-FR/Sovol-SV08-Mainline/blob/9a4694ee5ea671ae45c1a426ce40ee3499037206/README.md#L296) for the extra MCU

```bash
sudo service klipper stop
cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_stm32f103xe_xxxx")'
```

Now the MCU is in DFU mode. At this step, if you do `ls /dev/serial/by-id/*`, you will see that it appears with a Katapult ID :

![alt text](<images/haa/klipper firmware.png>)

This is temporary and only during the flashing process in DFU Mode. After completing the flashing, and rebooting the MCU, it will revert to a Klipper ID.
You must never use the Katapult ID in any configuration file.

Now, finish the process :

```bash
cd ~/klipper && make clean KCONFIG_CONFIG=toolhead.mcu
cd ~/klipper && make menuconfig KCONFIG_CONFIG=toolhead.mcu
```

- Choose the following option and add `PA6`on the last line (_GPIO pins_):<br>

![toolhead_menuconfig](images/haa/haa_toolhead_menuconfig.jpg)<br>

> [!NOTE]
> <sub>**NOTE 1**: Because we are using Katapult as a bootloader, make sure you set the 8 KiB bootloader offset.</sub><br>

- Press Q to quit and save changes.<br>

- Create the firmware and flash the tool head MCU (your serial should now start with `usb-katapult_`). Once again, replace the xxxx at the end with what you have at [2](https://github.com/Haagel-FR/Sovol-SV08-Mainline/blob/9a4694ee5ea671ae45c1a426ce40ee3499037206/README.md#L296) for the extra MCU:<br>

```bash
cd ~/klipper && make KCONFIG_CONFIG=host.mcu && cd ~/katapult/scripts && python3 flashtool.py -d /dev/serial/by-id/usb-katapult_stm32f103xe_xxxx
```

2. Restart the printer with :

```bash
sudo shutdown -r now
```

3. After the restart, in case you flashed the tool head MCU you can now uncomment the [adxl345] and [resonance_tester] parts in your printer.cfg

Done! The Klipper firmware on both MCUs has been updated.
<br>

## Method 2:

1. We are now going to create the Klipper firmware, do

```bash
cd ~/klipper
make menuconfig
```

and select the following options:<br>

![Klipper makemenu config settings](/images/klipper-firmware-settings-katapult.jpg)

> <sub>**NOTE 1**: because we are using Katapult as a bootloader, make sure you set the 8 KiB bootloader offset.</sub><br>

2. Press Q to quit and save changes.<br>

3. Run the command to create the Klipper firmware (`klipper.bin`)

```bash
make clean
make
```

4. Since we flashed Katapult earlier we should now be able to flash the Klipper firmware to our MCU from SSH (without the ST-Link):
   - Put the Katapult bootloader in DFU mode with this command:

```bash
cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/xxxxx")'
```

(replace xxxxx with the serial you just copied)<br>

- Now Katapult is in DFU mode, again look for the correct serial with

```bash
ls /dev/serial/by-id/*
```

![alt text](<images/haa/klipper firmware.png>)<br>

You should see one that starts with `usb-katapult_` and use that one (if you haven't flashed Klipper yet after Katapult you probably already had one starting with `usb-katapult_` :thumbsup:).

- Stop the Klipper service with

```bash
sudo service klipper stop
```

- Execute the flash with the following command

```bash
cd ~/katapult/scripts && python3 flashtool.py -d /dev/serial/by-id/xxxxx
```

(again replace xxxxx with the correct serial)

- This will take the default klipper.bin from the `/klipper/out` folder and flash it.
- Start the Klipper service with

```bash
sudo service klipper start
```

5. Do a firmware restart and you are ready. In case you flashed the tool head MCU you can now uncomment the [adxl345] and [resonance_tester] parts in your printer.cfg<br>
   <br>

Done! The Klipper firmware on the MCU has been updated. Do this for both the tool head MCU and the mainboard MCU.

<br>

# BIG THANKS & CONTRIBUTE

Big thanks to all the people on the Sovol discords (both official and unofficial) who have helped or participated in this project in any way.
Special thanks go out to: ss1gohan13, michrech, Zappes, cluless, Haagel, Froh - _you guys rock!_

Do you feel like contributing to this project/guide? That would be awesome! Please make a pull request or issue and then it can be added to the guide!

<br>

# Disclaimer

This guide and all changes have been made with the best intentions but in the end, it's your responsibility and _only your responsibility_ to apply those changes and modifications to your printer. Neither the author, contributors nor Sovol is responsible if things go bad, break, catch fire, or start WW3. You do this at your own risk!
