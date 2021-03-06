###################################################################################################
## This constraints file contains default clock frequencies to be used during creation of a 
## Synthesis Design Checkpoint (DCP). For best results the frequencies should be modified 
## to match the target frequencies. 
## This constraints file is not used in top-down/global synthesis (not the default flow of Vivado).
###################################################################################################


##################################################################################################
## 
##  Xilinx, Inc. 2010            www.xilinx.com 
##  �� 11 2 17:11:26 2015
##  Generated by MIG Version 2.0
##  
##################################################################################################
##  File name :       mig.xdc
##  Details :     Constraints file
##                    FPGA Family:       ARTIX7
##                    FPGA Part:         XC7A100T-CSG324
##                    Speedgrade:        -1
##                    Design Entry:      VERILOG
##                    Frequency:         200 MHz
##                    Time Period:       5000 ps
##################################################################################################

##################################################################################################
## Controller 0
## Memory Device: DDR2_SDRAM->Components->MT47H64M16HR-25E
## Data Width: 16
## Time Period: 5000
## Data Mask: 1
##################################################################################################

create_clock -name sys_clk_i -period 5 [get_ports sys_clk_i]
set_propagated_clock sys_clk_i
          