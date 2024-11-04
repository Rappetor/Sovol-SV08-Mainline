#!/usr/bin/env bash

#Replace each XXXXXXXX and YYYYYYY serial number with the one you find in your printer.cfg file (we only need the part after 'usb-Klipper_stm32f103xe_')
#HOSTSERIAL is found under [mcu]
#TOOLHEADSERIAL is found under [extra mcu]
#EDDYSERIAL is found in your eddy.cfg
# Generic command to find serials: ls /dev/serial/by-id/

# I'm a string, so I look like: HOSTSERIAL='XXXXXXXX'
HOSTSERIAL='XXXXXXXX'

# I'm an array so I look like: TOOLHEADSERIAL=('YYYYYYY')
# For multiple serials/toolheads use (mind the space in between items!): TOOLHEADSERIALS=('YYYYYYY1' 'YYYYYYY2' 'YYYYYYY3')
TOOLHEADSERIALS=('YYYYYYY') # For multiple serials use: TOOLHEADSERIALS=('SERIAL_1' 'SERIAL_2' 'SERIAL_3')

# I'm a string, so I look like: EDDYSERIAL='XXXXXXXX'
# This assumes your Eddy has the Katapult bootloader!
# OPTIONAL, only useful when you have a BTT Eddy otherwise ignore.
EDDYSERIAL='XXXXXXXX'

#COLORS
MAGENTA=$'\e[35m\n'
YELLOW=$'\e[33m\n'
RED=$'\e[31m\n'
CYAN=$'\e[36m\n'
NC=$'\e[0m\n'
NC0=$'\e'
NC1=$'\e[0m'

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
	echo -e "${YELLOW}Cleaning and building Klipper firmware for HOST MCU.${NC}"
	make clean KCONFIG_CONFIG=host.mcu
	read -p "${CYAN}Check on the following screen that the parameters are correct for the ${RED}HOST${CYAN}firmware. Press [Enter] to continue..${NC}"
	make menuconfig KCONFIG_CONFIG=host.mcu
	make KCONFIG_CONFIG=host.mcu -j4
	mv ~/klipper/out/klipper.bin host_mcu_klipper.bin
	read -p "${CYAN}Host MCU firmware building complete. Press [Enter] to flash..${NC}"
	echo -e "${YELLOW}Flashing Klipper to HOST MCU.${NC}"
	cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_stm32f103xe_'$HOSTSERIAL'")'
	sleep 3
	~/katapult/scripts/flashtool.py -f ~/klipper/host_mcu_klipper.bin -d /dev/serial/by-id/usb-katapult_stm32f103xe_$HOSTSERIAL
	read -p "${CYAN}HOST MCU flashed. Check for errors and press [Enter] to continue..${NC}"
}

flash_toolhead(){
	cd "$HOME/klipper"
	echo -e "${YELLOW}Cleaning and building Klipper firmware for TOOLHEAD MCU.${NC}"
	make clean KCONFIG_CONFIG=toolhead.mcu
	read -p "${CYAN}Check on the following screen that the parameters are correct for the ${RED}TOOLHEAD${CYAN}firmware. Press [Enter] to continue..${NC}"
	make menuconfig KCONFIG_CONFIG=toolhead.mcu
	make KCONFIG_CONFIG=toolhead.mcu -j4
	mv ~/klipper/out/klipper.bin toolhead_mcu_klipper.bin
	read -p "${CYAN}Toolhead MCU firmware building complete. Press [Enter] to flash..${NC}"
	echo -e "${YELLOW}Flashing Klipper to TOOLHEAD(s) MCU.${NC}"
	
	for serial in ${TOOLHEADSERIALS[@]}
	do
		read -p "${CYAN}Going to flash Klipper on: ${serial}. Press [Enter] to continue..${NC}"
		cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_stm32f103xe_'$serial'")'
		sleep 3
		~/katapult/scripts/flashtool.py -f ~/klipper/toolhead_mcu_klipper.bin -d /dev/serial/by-id/usb-katapult_stm32f103xe_$serial
		echo -e "${CYAN}Flashing Klipper on ${serial} complete.${NC}"
	done
	read -p "${CYAN}TOOLHEAD MCU(S) flashed. Check for errors and press [Enter] to continue..${NC}"
}

flash_eddy(){
	cd "$HOME/klipper"
	echo -e "${YELLOW}Cleaning and building Klipper firmware for BTT EDDY MCU.${NC}"
	make clean KCONFIG_CONFIG=eddy.mcu
	read -p "${CYAN}Check on the following screen that the parameters are correct for the ${RED}EDDY${CYAN}firmware. Press [Enter] to continue..${NC}"
	make menuconfig KCONFIG_CONFIG=eddy.mcu
	make KCONFIG_CONFIG=eddy.mcu -j4
	mv ~/klipper/out/klipper.bin eddy_mcu_klipper.bin
	read -p "${CYAN}Eddy MCU firmware building complete. Press [Enter] to flash..${NC}"
	echo -e "${YELLOW}Flashing Klipper to BTT EDDY MCU.${NC}"
	cd ~/klipper/scripts/ && python3 -c 'import flash_usb as u; u.enter_bootloader("/dev/serial/by-id/usb-Klipper_rp2040_'$EDDYSERIAL'")'
	sleep 3
	~/katapult/scripts/flashtool.py -f ~/klipper/eddy_mcu_klipper.bin -d /dev/serial/by-id/usb-katapult_rp2040_$EDDYSERIAL
	read -p "${CYAN}BTT EDDY MCU flashed. Check for errors and press [Enter] to continue..${NC}"
}

#SCRIPT EXECUTION
echo "Executing SV08 automatic mcu updater.."
stop_klipper
PS3='Please enter your choice: '
while true; do
	clear
	echo -e "${MAGENTA}SV08 AUTOMATIC MCU UPDATER${NC1}"
	echo -e "Which device do you want to update (build & flash)?"
	options=("HOST MCU" "TOOLHEAD MCU(S)" "BTT EDDY MCU" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"HOST MCU")
				flash_host
				break
				;;
			"TOOLHEAD MCU(S)")
				flash_toolhead
				break
				;;
			"BTT EDDY MCU")
				flash_eddy
				break
				;;
			"Quit")
				echo "Quitting.."
				break 2
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
done

start_klipper

cd "$HOME/klipper"
