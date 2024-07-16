# TMC 2209 accurate technical settings for Sovol SV08

- Based on the 2209 datasheet and Excel configurator from Trinamic, the Klipper recommendation settings for TMC 2209, and the motors datasheets by Sovol, these are the technical, accurate settings for the TMC 2209.
- Using this leads to better accuracy, slightly less noisy motors and better heat dissipation.

> [!CAUTION]
> - sense_resistor is based on the board specification. Modifying its values can lead to catastrophic failure and even burning the motors.
> - In the [extruder] section, adjust `rotation_distance` to your own values.
> - In the [extruder] section, be careful to uncomment these lines if you haven't done PID calibration:
```python
#control : pid
#pid_kp : 33.838
#pid_ki : 5.223
#pid_kd : 47.752
```

> [!NOTE]
> - You can adjust `microsteps` from 16 to 256. 64 seems to be a safe value.
> - Using more than 64 microsteps for X and Y will lead to overloading the MCU and will cause an error.
> - Using more than 64 microsteps for Z will lead to a heavier load on the MCU, and seems to have no real benefits.
> - To put the stepper in Spreadcycle mode, use `stealthchop_threshold: 0` or comment out the line `stealthchop_threshold: 999999`. Which way you find more readable is a matter of preference.
> - Sovol has slightly OC-ed the TMC 2209 for X, Y and Z at 13 MHz (up from 12). However, the TMC 2209 for the extruder remains at 12 MHz.
> - The X, Y and extruder steppers are set to SpreadCycle mode.
> - The Z steppers are set to Stealthchop. Although slightly less accurate, stealthchop is less noisy, and there's no real advantage to setting Z to SpreadCycle mode.
> - You can try Z steppers in Spreadcycle mode by using this configuration for the four Z steppers, instead of what is below:
```python
#stealthchop_threshold: 999999 
uart_address:3
driver_TBL: 1
driver_TOFF: 3
driver_HSTRT: 0
driver_HEND: 2
```

- These are the values to copy and paste into your printer.cfg:

```python
[stepper_x]
step_pin: PE2
dir_pin: !PE0
enable_pin: !PE3
rotation_distance: 40         
microsteps: 64 #16                
full_steps_per_rotation:200   
endstop_pin: tmc2209_stepper_x: virtual_endstop              
position_min: 0               
position_endstop: 355         
position_max: 355             
homing_speed: 30              
homing_retract_dist: 0        
homing_positive_dir: True     
#--------------------------------------------------------------------
[tmc2209 stepper_x]
uart_pin: PE1
interpolate: False #True             
run_current: 1.061 #1.5
#hold_current: 1.061 #1.5            
sense_resistor: 0.150         
#stealthchop_threshold: 0      
uart_address:3
driver_sgthrs: 75 #65
diag_pin: PE15
driver_TBL: 1
driver_TOFF: 3
driver_HSTRT: 7
driver_HEND: 5

[stepper_y]
step_pin: PB8
dir_pin: !PB6
enable_pin: !PB9
rotation_distance: 40         
microsteps: 64 #16                
full_steps_per_rotation:200   
endstop_pin: tmc2209_stepper_y: virtual_endstop              
position_min: 0               
position_endstop: 364         
position_max: 364            
homing_speed: 30              
homing_retract_dist: 0        
homing_positive_dir: true     
#--------------------------------------------------------------------
[tmc2209 stepper_y]
uart_pin: PB7
interpolate: False #True             
run_current: 1.061 #1.5
#hold_current: 1.061 #1.5             
sense_resistor: 0.150         
#stealthchop_threshold: 0      
uart_address:3
driver_sgthrs: 85 #75 #65
diag_pin: PE13
driver_TBL: 1
driver_TOFF: 3
driver_HSTRT: 7
driver_HEND: 5

[stepper_z] #motherboard：Z3 
step_pin:PC0    
dir_pin:PE5    
enable_pin:!PC1    
rotation_distance: 40         
gear_ratio: 80:12             
microsteps: 64 #16
endstop_pin: probe:z_virtual_endstop           
position_max: 347             
position_min: -5              
#position_endstop: 0
homing_speed: 15.0
homing_retract_dist: 5.0
homing_retract_speed: 15.0
second_homing_speed: 10.0
#--------------------------------------------------------------------
[tmc2209 stepper_z]
uart_pin: PE6 
interpolate: false #true             
run_current: 0.566 #0.58          
#hold_current: 0.566 #0.58         
sense_resistor: 0.150       
stealthchop_threshold: 999999 
uart_address:3
#driver_TBL: 1
#driver_TOFF: 3
#driver_HSTRT: 0
#driver_HEND: 2

[stepper_z1] ##motherboard：Z1
step_pin:PD3  
dir_pin:!PD1 
enable_pin:!PD4 
rotation_distance: 40         
gear_ratio: 80:12            
microsteps: 64 #16        
#--------------------------------------------------------------------
[tmc2209 stepper_z1]
uart_pin:PD2  
interpolate: false #true             
run_current: 0.566 #0.58          
#hold_current: 0.566 #0.58         
sense_resistor: 0.150  
stealthchop_threshold: 999999 
uart_address:3
#driver_TBL: 1
#driver_TOFF: 3
#driver_HSTRT: 0
#driver_HEND: 2

[stepper_z2] ##motherboard：Z2
step_pin:PD7
dir_pin:PD5   
enable_pin:!PB5
rotation_distance: 40         
gear_ratio: 80:12             
microsteps: 64 #16          
#--------------------------------------------------------------------
[tmc2209 stepper_z2]
uart_pin:PD6  
interpolate: false #true             
run_current: 0.566 #0.58          
#hold_current: 0.566 #0.58         
sense_resistor: 0.150   
stealthchop_threshold: 999999 
uart_address:3
#driver_TBL: 1
#driver_TOFF: 3
#driver_HSTRT: 0
#driver_HEND: 2

[stepper_z3] ##motherboard：Z4
step_pin:PD11 
dir_pin:!PD9 
enable_pin:!PD12   
rotation_distance: 40         
gear_ratio: 80:12             
microsteps: 64 #16       
#--------------------------------------------------------------------
[tmc2209 stepper_z3]
uart_pin:PD10    
interpolate: false #true             
run_current: 0.566 #0.58          
#hold_current: 0.566 #0.58         
sense_resistor: 0.150
stealthchop_threshold: 999999 
uart_address:3
#driver_TBL: 1
#driver_TOFF: 3
#driver_HSTRT: 0
#driver_HEND: 2

[extruder]
step_pin: extra_mcu:PA8   
dir_pin: extra_mcu:PB8    
enable_pin:!extra_mcu: PB11   
rotation_distance: 6.745 #6.5 
microsteps: 64                
full_steps_per_rotation: 200 
nozzle_diameter: 0.400        
filament_diameter: 1.75  
max_extrude_only_distance: 150     
heater_pin:extra_mcu:PB9  
sensor_type:my_thermistor_e  
pullup_resistor: 11500
sensor_pin: extra_mcu:PA5  
min_temp: 5                  
max_temp: 305                 
max_power: 1.0                
min_extrude_temp: 5
#control : pid
#pid_kp : 33.838
#pid_ki : 5.223
#pid_kd : 47.752
pressure_advance: 0.025       
pressure_advance_smooth_time: 0.035    
#--------------------------------------------------------------------
[tmc2209 extruder]
uart_pin: extra_mcu:PB10  
interpolate: False #True             
run_current: 0.8
#hold_current: #0.8            
uart_address:3
sense_resistor: 0.150
driver_TBL: 1
driver_TOFF: 3
driver_HSTRT: 7
driver_HEND: 8
```

- You can also modify these settings to get better accuracy for Z-probing and the bed mesh:

```python
[probe]
pin: extra_mcu:PB6    
x_offset: -17                  
y_offset: 10             
#z_offset : 0
speed: 15.0
speed: 5.0
samples: 3 #2
sample_retract_dist: 5.0 #2.0
lift_speed: 50
samples_result: average
samples_tolerance: 0.0075 #0.016
samples_tolerance_retries: 10 #2

[quad_gantry_level]          
speed: 350 #400                   
horizontal_move_z: 5 #10       
retry_tolerance: 0.0075 #0.05      
retries: 5                  
max_adjust: 10 #30

[bed_mesh]
speed: 350 #500                   
split_delta_z: 0.0125 #0.016
```

### - References
- TMC2209 datasheet and configurator: https://www.trinamic.com/products/integrated-circuits/details/tmc2209-la/
- Sovol SV08 motors datasheet: https://github.com/Sovol3d/SV08/tree/main/PDF/02%E7%94%B5%E6%9C%BA%20shengyang%20motor
- Klipper TMC2209 recommended settings: https://www.klipper3d.org/Config_Reference.html#tmc2209
- DrGhetto's TMC Driver Tuning Guide for Klipper: https://github.com/MakerBogans/docs/wiki/TMC-Driver-Tuning

