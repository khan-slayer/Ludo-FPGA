# Clock constraint (100 MHz)
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk]

# Clock and Reset
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk] 

## ========reset==========
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Buttons
set_property PACKAGE_PIN T18 [get_ports roll_btn]
set_property IOSTANDARD LVCMOS33 [get_ports roll_btn]
set_property PACKAGE_PIN U17 [get_ports confirm_btn]
set_property IOSTANDARD LVCMOS33 [get_ports confirm_btn]
set_property PACKAGE_PIN W19 [get_ports btn_piece0]
set_property IOSTANDARD LVCMOS33 [get_ports btn_piece0]
set_property PACKAGE_PIN T17 [get_ports btn_piece1]
set_property IOSTANDARD LVCMOS33 [get_ports btn_piece1]



# LEDs
set_property PACKAGE_PIN U16 [get_ports led[0]]
set_property PACKAGE_PIN E19  [get_ports led[1]]
set_property PACKAGE_PIN U19  [get_ports led[2]]
set_property PACKAGE_PIN V19 [get_ports led[3]]
set_property PACKAGE_PIN W18 [get_ports led[4]]
set_property PACKAGE_PIN U15 [get_ports led[5]]
set_property PACKAGE_PIN U14  [get_ports led[6]]
set_property PACKAGE_PIN V14 [get_ports led[7]]
set_property PACKAGE_PIN V13 [get_ports led[8]]
set_property PACKAGE_PIN V3 [get_ports led[9]]
set_property PACKAGE_PIN W3  [get_ports led[10]]
set_property PACKAGE_PIN U3  [get_ports led[11]]
set_property PACKAGE_PIN P3 [get_ports led[12]]
set_property PACKAGE_PIN N3 [get_ports led[13]]
set_property PACKAGE_PIN P1 [get_ports led[14]]
set_property PACKAGE_PIN L1 [get_ports led[15]]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# 7-segment
set_property PACKAGE_PIN W7   [get_ports seg[0]]
set_property PACKAGE_PIN W6  [get_ports seg[1]]
set_property PACKAGE_PIN U8  [get_ports seg[2]]
set_property PACKAGE_PIN V8  [get_ports seg[3]]
set_property PACKAGE_PIN U5  [get_ports seg[4]]
set_property PACKAGE_PIN V5  [get_ports seg[5]]
set_property PACKAGE_PIN U7  [get_ports seg[6]]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]
# 7-segment anodes
set_property PACKAGE_PIN W4   [get_ports an[0]]
set_property PACKAGE_PIN V4  [get_ports an[1]]
set_property PACKAGE_PIN U4  [get_ports an[2]]
set_property PACKAGE_PIN V7  [get_ports an[3]]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

# First 16 sensors
set_property PACKAGE_PIN J1  [get_ports sensor_in[26]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[26]]

set_property PACKAGE_PIN H1 [get_ports sensor_in[25]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[25]]

set_property PACKAGE_PIN L2 [get_ports sensor_in[24]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[24]]

set_property PACKAGE_PIN K2 [get_ports sensor_in[23]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[23]]

set_property PACKAGE_PIN J2 [get_ports sensor_in[22]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[22]]

set_property PACKAGE_PIN H2 [get_ports sensor_in[0]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[0]]

set_property PACKAGE_PIN G2 [get_ports sensor_in[1]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[1]]

set_property PACKAGE_PIN G3 [get_ports sensor_in[2]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[2]]

set_property PACKAGE_PIN A14 [get_ports sensor_in[3]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[3]]

set_property PACKAGE_PIN A16 [get_ports sensor_in[4]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[4]]

set_property PACKAGE_PIN B15 [get_ports sensor_in[5]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[5]]

set_property PACKAGE_PIN B16  [get_ports sensor_in[11]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[11]]

set_property PACKAGE_PIN A15 [get_ports sensor_in[12]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[12]]

set_property PACKAGE_PIN A17 [get_ports sensor_in[13]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[13]]

set_property PACKAGE_PIN C15 [get_ports sensor_in[14]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[14]]

set_property PACKAGE_PIN C16 [get_ports sensor_in[15]]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in[15]]

# Tie-down unused sensors [16..26]
set_property PULLDOWN true [get_ports sensor_in[16]]
set_property PULLDOWN true [get_ports sensor_in[17]]
set_property PULLDOWN true [get_ports sensor_in[18]]
set_property PULLDOWN true [get_ports sensor_in[19]]
set_property PULLDOWN true [get_ports sensor_in[20]]
set_property PULLDOWN true [get_ports sensor_in[21]]
set_property PULLDOWN true [get_ports sensor_in[6]]
set_property PULLDOWN true [get_ports sensor_in[7]]
set_property PULLDOWN true [get_ports sensor_in[8]]
set_property PULLDOWN true [get_ports sensor_in[9]]
set_property PULLDOWN true [get_ports sensor_in[10]]
