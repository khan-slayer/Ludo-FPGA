## mini_ludo_sensors_fixed.xdc
## Cleaned XDC for mini_ludo_top (6 IR sensors + LEDs + 7-seg + buttons)
## NOTE: Change PACKAGE_PIN values only if you intentionally want different pins.

# 100 MHz clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Roll button (BTN for dice roll)
set_property PACKAGE_PIN U18 [get_ports btn_roll]
set_property IOSTANDARD LVCMOS33 [get_ports btn_roll]

# Confirm button (BTN for sensor confirm)
set_property PACKAGE_PIN U17 [get_ports btn_confirm]
set_property IOSTANDARD LVCMOS33 [get_ports btn_confirm]

# IR sensors mapped to PMOD/IO pins (sensor_raw[0..5])
set_property PACKAGE_PIN L3  [get_ports {sensor_raw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sensor_raw[0]}]

set_property PACKAGE_PIN J3  [get_ports {sensor_raw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sensor_raw[1]}]

set_property PACKAGE_PIN M19 [get_ports {sensor_raw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sensor_raw[2]}]

set_property PACKAGE_PIN M18 [get_ports {sensor_raw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sensor_raw[3]}]

set_property PACKAGE_PIN J1  [get_ports {sensor_raw[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sensor_raw[4]}]

set_property PACKAGE_PIN K17 [get_ports {sensor_raw[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sensor_raw[5]}]

# LEDs mapping (make sure these are the pins that worked for you)
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN V19 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN W18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

set_property PACKAGE_PIN U15 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

set_property PACKAGE_PIN U14 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

set_property PACKAGE_PIN V14 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

set_property PACKAGE_PIN V13 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]

# Seven-segment segments (seg[0]=a ... seg[6]=g)
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]

set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]

set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]

set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]

set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]

set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]

set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

# Seven-segment anodes
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]

set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]

set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]

set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
