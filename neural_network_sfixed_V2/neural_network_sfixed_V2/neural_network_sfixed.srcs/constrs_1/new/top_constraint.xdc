create_clock -period 6.500 -name clk [get_ports clk]
create_clock -period 6.250 -name pixel[*] [get_ports pixel[*]]
#create_clock -period 6.250 -name weight[*] [get_ports weight[*]]

create_clock -period 7.250 -name VecOut_mux[*] [get_ports VecOut_mux[*]]
#create_clock -period 7.250 -name SWM_neurons[*] [get_ports SWM_neurons[*]]
#create_clock -period 7.250 -name signature_weight[*] [get_ports signature_weight[*]]


set_clock_latency -rise -min 22.0 [get_clocks *clk*]


                 