### openframe_project_wrapper Signoff SDC
### Rev 1
### Date: 10/8/2023


## MASTER CLOCKS
set clk_period 25
create_clock -name clk -period $clk_period [get_ports {gpio_in[38]}] 
puts "\[INFO\]: Systemn clock period: $clk_period"

create_clock -name dll_clk -period 6.666 [get_pins {openframe_example/dll/clockp[1]}]
create_clock -name dll_clk90 -period 6.666 [get_pins {openframe_example/dll/clockp[0]}]

create_clock -name hkspi_clk -period $clk_period [get_ports {gpio_in[4]}] 
set_clock_uncertainty 0.1000 [all_clocks]
set_propagated_clock [all_clocks]

set_clock_groups \
   -name clock_group \
   -logically_exclusive \
   -group [get_clocks {clk}]\
   -group [get_clocks {hkspi_clk}]\
   -group [get_clocks {dll_clk}]\
   -group [get_clocks {dll_clk90}]

# ## INPUT/OUTPUT DELAYS
set input_delay_value 4
set output_delay_value 4
puts "\[INFO\]: Setting output delay to: $output_delay_value"
puts "\[INFO\]: Setting input delay to: $input_delay_value"
set_input_delay $input_delay_value -clock [get_clocks {clk}] [all_inputs]
set_output_delay $output_delay_value -clock [get_clocks {clk}] [all_outputs]

set_max_fanout 18 [current_design]
# synthesis max fanout is 18 

## FALSE PATHS (ASYNCHRONOUS INPUTS)
set_false_path -from [get_ports {resetb*}]
set_false_path -from [get_ports {porb*}]

# disable timing of saving the gpio in 38 (clk) as data
set_false_path -from [get_ports {gpio_in[38]}] -to [get_pins {openframe_example/_34243_/D}]

# add loads for output ports (pads)
# pad input pin cap 0.036793 (pin OUT of pad sky130_ef_io__gpiov2_pad_wrapped)
set out_cap 0.036793
puts "\[INFO\]: Cap load range: $out_cap"
set_load $out_cap [all_outputs]

#add input transition for the inputs ports (pads)
# pad output pin transition range is 0.08:1.5 (pin IN of pad sky130_ef_io__gpiov2_pad_wrapped)
set min_in_tran 0.1
set max_in_tran 1.5
puts "\[INFO\]: Input transition range: $min_in_tran : $max_in_tran"
set_input_transition -min $min_in_tran [all_inputs] 
set_input_transition -min 0 [get_ports v*]
set_input_transition -max $max_in_tran [all_inputs]
set_input_transition -max 0 [get_ports v*]

# check ocv table (not provided) 
set derate 0.05
puts "\[INFO\]: Setting derate factor to: [expr $derate * 100] %"
set_timing_derate -early [expr 1-$derate]
set_timing_derate -late [expr 1+$derate]

# enable dll bypass to not use the dll clk as the core clk
set_case_analysis 1 [get_pins {openframe_example/_35418_/Q}]

