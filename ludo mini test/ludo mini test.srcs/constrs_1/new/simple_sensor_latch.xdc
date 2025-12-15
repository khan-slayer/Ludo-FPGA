## simple_sensor_test_basys3.xdc
## Constraint file for single-sensor latch unit test (Basys-3)
## Top-level module: simple_sensor_test_top
## Ports: clk, btn_confirm, sensor_raw, led[2:0]
##
## NOTE: If you want to use different pins (other PMOD pins or buttons) edit the PACKAGE_PIN values.
## See Basys-3 manual for pin map / Pmod assignments. :contentReference[oaicite:2]{index=2} :contentReference[oaicite:3]{index=3}

## -------------------------------------------------------------------
## Clock (100 MHz oscillator on Basys-3)
#set_property PACKAGE_PIN W5 [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]

### -------------------------------------------------------------------
### Confirm button (use BTN center / BTNC here)
### This maps the physical confirm pushbutton to 'btn_confirm' in top module.
#set_property PACKAGE_PIN U18 [get_ports btn_confirm]
#set_property IOSTANDARD LVCMOS33 [get_ports btn_confirm]

### -------------------------------------------------------------------
### Single IR sensor input (use PMOD JA pin 1 -> FPGA pin J1)
### Connect IR module OUT to this pin.
#set_property PACKAGE_PIN J1 [get_ports sensor_raw]
#set_property IOSTANDARD LVCMOS33 [get_ports sensor_raw]

### -------------------------------------------------------------------
### LEDs used for debug: led[0], led[1], led[2]
### Map them to three on-board LEDs (change if you prefer others)
#set_property PACKAGE_PIN U16 [get_ports {led[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

#set_property PACKAGE_PIN E19 [get_ports {led[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

#set_property PACKAGE_PIN V19 [get_ports {led[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

## -------------------------------------------------------------------
## NOTES:
## - Basys-3 uses 3.3V I/O (LVCMOS33). Keep that setting.
## - The PMOD JA1 pin (J1) is convenient for breadboard wiring to the IR module VCC/GND/OUT; check the manual
##   for the JA pin numbering and orientation. :contentReference[oaicite:4]{index=4}
## - If your IR module output is active-low (you said detection gives a '0'), instantiate the latch with INVERT_SENSOR=1
##   (or invert the input in HDL).
## - If you prefer a different pushbutton (BTNU/BTND/BTNL/BTNR), change the PACKAGE_PIN accordingly; see Fig.16. :contentReference[oaicite:5]{index=5}
