set_property SRC_FILE_INFO {cfile:/users/tareelou/neural_network_sfixed_V2/neural_network_sfixed.srcs/constrs_1/new/top_constraint.xdc rfile:../../../../../neural_network_sfixed.srcs/constrs_1/new/top_constraint.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:1 export:INPUT save:INPUT read:READ} [current_design]
create_clock -period 6.500 -name clk [get_ports clk]
set_property src_info {type:XDC file:1 line:10 export:INPUT save:INPUT read:READ} [current_design]
set_clock_latency -rise -min 22.000 [get_clocks *clk*]
