# Automatic MCU update script

## Dependencies
For this script to work it assumes [Katapult](https://github.com/Arksine/katapult) is flashed on each MCU because this script uses Katapult to flash the (newest) Klipper firmware onto the MCU.
Read *Step 7 - Flash Katapult Bootloader* of the guide on how to get Katapult on the SV08 MCU's. And read [this guide](https://github.com/Rappetor/katapult-on-btt-eddy) on how to flash Katapult on the BTT Eddy (if you happen to use Eddy).

## Install
Please look at [Step 8](https://github.com/Rappetor/Sovol-SV08-Mainline/tree/main?tab=readme-ov-file#step-8---flash-klipper-firmware-on-mcus) how to prepare the script.<br>
_Short version:_
- Copy the `update_klipper_mcus_sv08.sh` script to your `~/klipper` folder.
- Edit the script and enter your device serials (the serial parts after `stm32f103xe_`).
- Make the script executable with `sudo chmod +x ~/klipper/update_klipper_mcus_sv08.sh`
- Use the script with the following command:
```bash
cd "$HOME/klipper" && ./update_klipper_mcus_sv08.sh
```

## Troubleshooting
You might get the following error after executing the script: 
```bash
/usr/bin/env: ‘bash\r’: No such file or directory
```
This means you have probably saved the file in Windows (with the Windows/DOS line endings) and we need to convert the line endings to Unix style. The easiest way to do this is to re-save the file with Nano:<br>
- `cd ~/klipper` (Go to the Klipper folder where the script is, if you are not there yet)
- `nano update_klipper_mcus_sv08.sh` (Open the file with Nano)
- `CTRL-O` (Write Out) _But do not press enter/save yet!_
- `ALT-D` (DOS Format) You will see `[DOS Format]` appear or be removed in front of the filename when pressing ALT-D. Make sure there is NO [DOS Format] in front of the filename.
- `Press ENTER` to save (you will see a message `[ Wrote xx lines ]` when the file is saved)
- `CTRL-X` to exit.

We have now converted the wrong line endings to the correct ones and you can once again try to execute the script with:
```bash
cd "$HOME/klipper" && ./update_klipper_mcus_sv08.sh
```
