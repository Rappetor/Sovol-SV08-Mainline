# Automatic MCU update

> [!CAUTION]
> - This guide is heavily related to the **_Chapter 8 / Method 1_** of the main guide. If you haven't already read it, you should before using this script
> - As is, it doesn't work for Method 2

<br>

1. Download and open the script `update_klipper_mcus_sv08.sh`<br>

2. Open printer.cfg and replace in the script (line 6 and 7) XXXXXX by your `[MCU]` serial, and YYYYYYY by your `[Extra MCU]`serial:

![alt text](../images/haa/haa_amu_printercfg.jpg)

```bash
#Replace each serial number with the one you find in your printer.cfg file
#HOST_SERIAL = [mcu]
#TOOLHEAD_SERIAL = [extra mcu]
HOSTSERIAL='XXXXXXX'
TOOLHEADSERIAL='YYYYYYY'
```
- You should now have this in the script :
```bash
#Replace each serial number with the one you find in your printer.cfg file
#HOST_SERIAL = [mcu]
#TOOLHEAD_SERIAL = [extra mcu]
HOSTSERIAL='34FFDA05334D593524680951-if00'
TOOLHEADSERIAL='31FF700630464E3225480643-if00'
```
3. Save the file `update_klipper_mcus_sv08.sh` and copy it in your `~/Klipper` folder (via sFtp)

4. Make the script executable :

```bash
sudo chmod +x ~/klipper/update_klipper_mcus_sv08.sh
```

5. You can now use the script with :
```bash
cd "$HOME/klipper" && ./update_klipper_mcus_sv08.sh
```

6. Follow the instructions until the end. You can find the configuration for each MCU in the chapter 8 of the main guide

![alt text](../images/haa/haa_automatic_mcu_update.jpg)
