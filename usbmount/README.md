# Auto-Mount USB Stick for Sovol SV08

## Overview
This script automatically mounts a USB stick and lists G-code files in the LCD `SDCard` menu. This functionality was missing after installing mainline Klipper on the Sovol SV08. The code is based on the open-source Sovol GitHub repository for SV08, which can be found [here](https://github.com/Sovol3d/SV08/tree/main/home/sovol/usbmount).

## Installation

1. Upload this folder to the `/home/biqu` directory on your SV08 using an SCP tool.
2. SSH into your SV08.
3. Run the following commands:

```bash
cd /home/biqu/usbmount
sudo make install PREFIX=/usr
```

This will install the necessary files and you should see the following output in the terminal:

```bash
install -D makerbase-automount /usr/bin/makerbase-automount
install -Dm644 60-usbmount.rules /usr/lib/udev/rules.d/60-usbmount.rules
install -Dm644 makerbase-automount@.service /usr/lib/systemd/system/makerbase-automount@.service
install -d /etc/makerbase-automount.d
install -Cm644 makerbase-automount.d/* /etc/makerbase-automount.d/
```

## Uninstallation

To remove the installation, run:

```bash
cd /home/biqu/usbmount
sudo make clean PREFIX=/usr
```

The following files will be deleted:

```bash
sudo rm /usr/bin/makerbase-automount
sudo rm /usr/lib/udev/rules.d/60-usbmount.rules
sudo rm /usr/lib/systemd/system/makerbase-automount@.service
sudo rm -rf /etc/makerbase-automount.d
```

## Features

1. Automatically lists G-code files from the USB stick under the `SDCard` menu on the LCD
2. Allows configuration of WiFi settings through `wifi.cfg` file in USB stick
  - If the SSID in `wifi.cfg` matches the current WiFi SSID, the file is renamed to `wifi.cfg.unchanged`.
  - If the SSID in `wifi.cfg` is different from the current SSID, the system will attempt to connect to the new network:
    - If the connection is successful, `wifi.cfg` will be renamed to `wifi.cfg.setup`.
    - If the connection fails, `wifi.cfg` will be renamed to `wifi.cfg.invalid`.
3. The log for mounting USB stick is written `/tmp/usbmount.log`
