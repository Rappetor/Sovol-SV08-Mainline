# Automatic update MCU

## !!! WORK IN PROGRESS, TO BE TESTED !!!

----------------------------------------
#### This script works partially. This command works manually, but not with the script:<br>`cd ~/katapult/scripts && python3 flashtool.py -d /dev/serial/by-id/usb-katapult_stm32f103xe_YourMCUMOTHERBOARDIDHere` 
----------------------------------------



-   Create a file :
`sudo nano ~/update_klipper_mcu.sh`

#### REPLACE YourMCUTOOLHEADIDHere and YourMCUMOTHERBOARDIDHere by your own ID (`ls /dev/serial/by-id/*`)

- Paste this into nano :
```
sudo service klipper stop
cd ~/klipper
git pull

make clean
make
cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_stm32f103xe_YourMCUTOOLHEADIDHere")'
cd ~/katapult/scripts && python3 flashtool.py -d /dev/serial/by-id/usb-katapult_stm32f103xe_YourMCUTOOLHEADIDHere
cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_stm32f103xe_YourMCUMOTHERBOARDIDHere")'
cd ~/katapult/scripts && python3 flashtool.py -d /dev/serial/by-id/usb-katapult_stm32f103xe_YourMCUMOTHERBOARDIDHere

read -p "MCU firmwares flashed, please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort"

sudo service klipper start
```
- CTRL+X to save

- Made the file executable :
```
cd ~
sudo chmod 777 ./update_klipper_mcu.sh
```

- You can run this script later with the command :<br>
`./update_klipper_mcu.sh`