#!/usr/bin/env bash

#Replace each XXXXXXXX serial number with the one you find in your printer.cfg file (we only need the part after 'usb-Klipper_stm32f103xe_')
#HOSTSERIAL is found under [mcu]
#TOOLHEADSERIAL is found under [extra mcu]

# I'm a string, so I look like: HOSTSERIAL='XXXXXXXX'
HOSTSERIAL='XXXXXXXX'

# I'm an array so I look like: TOOLHEADSERIAL=('XXXXXXXX')
# For multiple serials/toolheads use (mind the space in between items!): TOOLHEADSERIAL=('XXXXXXXX1' 'XXXXXXXX2' 'XXXXXXXX3')
TOOLHEADSERIAL=('XXXXXXXX')

#COLORS
MAGENTA=$'\e[35m\n'
YELLOW=$'\e[33m\n'
RED=$'\e[31m\n'
CYAN=$'\e[36m\n'
NC=$'\e[0m\n'
NC0=$'\e'

#SCRIPT COMMAND DEFINITION
cd "$HOME/klipper"

stop_klipper(){
	echo -e "${YELLOW}Stopping Klipper service.${NC}"
	sudo service klipper stop
}

start_klipper(){
	echo -e "${YELLOW}Starting Klipper service.${NC}"
	sudo service klipper start
}

flash_host(){
	cd "$HOME/klipper"
	echo -e "${YELLOW}Step 1/4: Cleaning and building Klipper firmware for Host MCU.${NC}"
	make clean KCONFIG_CONFIG=host.mcu
	read -p "${CYAN}Check on the following screen that the parameters are correct for the ${RED}HOST${NC0}${CYAN}firmware. Press [Enter] to continue, or [Ctrl+C] to abort.${NC}"
	make menuconfig KCONFIG_CONFIG=host.mcu
	make KCONFIG_CONFIG=host.mcu -j4
	mv ~/klipper/out/klipper.bin host_mcu_klipper.bin
	read -p "${CYAN}Host MCU firmware building complete. Please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort.${NC}"
	echo -e "${YELLOW}Step 2/4: Flashing Klipper to Host MCU.${NC}"
	cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_stm32f103xe_'$HOSTSERIAL'")'
	sleep 3
	~/katapult/scripts/flashtool.py -f ~/klipper/host_mcu_klipper.bin -d /dev/serial/by-id/usb-katapult_stm32f103xe_$HOSTSERIAL
}

flash_toolhead(){
	cd "$HOME/klipper"
	echo -e "${YELLOW}Step 3/4: Cleaning and building Klipper firmware for Toolhead MCU.${NC}"
	make clean KCONFIG_CONFIG=toolhead.mcu
	read -p "${CYAN}Check on the following screen that the parameters are correct for the ${RED}TOOLHEAD${NC0}${CYAN}firmware. Press [Enter] to continue, or [Ctrl+C] to abort.${NC}"
	make menuconfig KCONFIG_CONFIG=toolhead.mcu
	make KCONFIG_CONFIG=toolhead.mcu -j4
	mv ~/klipper/out/klipper.bin toolhead_mcu_klipper.bin
	read -p "${CYAN}Toolhead MCU firmware building complete. Please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort.${NC}"
	echo -e "${YELLOW}Step 4/4: Flashing Klipper to Toolhead(s) MCU.${NC}"
	
	for serial in ${TOOLHEADSERIAL[@]}
	do
		read -p "${MAGENTA}Going to flash Klipper on Toolhead: ${serial}. Press [Enter] to continue, or [Ctrl+C] to abort.${NC}"
		cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_stm32f103xe_'$serial'")'
		sleep 3
		~/katapult/scripts/flashtool.py -f ~/klipper/toolhead_mcu_klipper.bin -d /dev/serial/by-id/usb-katapult_stm32f103xe_$serial
		echo -e "${CYAN}Flashing Klipper on ${serial} complete.${NC}"
	done
}

#SCRIPT EXECUTION
stop_klipper

flash_host

flash_toolhead

read -p "${CYAN}MCU firmwares flashed, please check above for any errors. Press [Enter] to continue, or [Ctrl+C] to abort.${NC}"

start_klipper

cd "$HOME/klipper"
