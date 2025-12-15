
# Clock (100 MHz on Basys-3) 
set_property PACKAGE_PIN W5 [get_ports {CLK100MHZ}]
set_property IOSTANDARD LVCMOS33 [get_ports {CLK100MHZ}]



#   rst_sync <= {rst_sync[0], BTN_RST_N};  wire T = ~rst_sync[1];
set_property PACKAGE_PIN W19 [get_ports {BTN_RST_N}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN_RST_N}]

) ----------
set_property PACKAGE_PIN V17 [get_ports {SW_LEFT}]   # SW0
set_property IOSTANDARD LVCMOS33 [get_ports {SW_LEFT}]
set_property PACKAGE_PIN V16 [get_ports {SW_RIGHT}]  # SW1
set_property IOSTANDARD LVCMOS33 [get_ports {SW_RIGHT}]


# led[0]  -> U16
# led[1]  -> E19
# led[2]  -> U19
# led[3]  -> V19
# led[4]  -> W18
# led[5]  -> U15

set_property PACKAGE_PIN U15 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]

set_property PACKAGE_PIN W18 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]

set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]

set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]

set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]

set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]

