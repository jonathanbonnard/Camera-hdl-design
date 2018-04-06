
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1
#    set_property BOARD_PART em.avnet.com:zed:part0:1.3 [current_project]

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports
  set VGA_D [ create_bd_port -dir O -from 11 -to 0 VGA_D ]
  set VGA_HS [ create_bd_port -dir O VGA_HS ]
  set VGA_VS [ create_bd_port -dir O VGA_VS ]

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
 ] $axi_mem_intercon

  # Create instance: axi_vdma_0, and set properties
  set axi_vdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.2 axi_vdma_0 ]
  set_property -dict [ list \
CONFIG.c_include_mm2s_dre {0} \
CONFIG.c_include_s2mm {0} \
CONFIG.c_mm2s_genlock_mode {1} \
CONFIG.c_mm2s_linebuffer_depth {1024} \
CONFIG.c_mm2s_max_burst_length {16} \
CONFIG.c_s2mm_genlock_mode {0} \
CONFIG.c_s2mm_linebuffer_depth {1024} \
CONFIG.c_s2mm_max_burst_length {16} \
CONFIG.c_use_mm2s_fsync {1} \
CONFIG.c_use_s2mm_fsync {2} \
 ] $axi_vdma_0

  # Create instance: axis2vga_0, and set properties
  set axis2vga_0 [ create_bd_cell -type ip -vlnv milinker:miz702:axis2vga:1.0 axis2vga_0 ]

  # Create instance: miz702_vtc_0, and set properties
  set miz702_vtc_0 [ create_bd_cell -type ip -vlnv milinker:milinker:miz702_vtc:1.0 miz702_vtc_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {25.000000} \
CONFIG.PCW_USE_S_AXI_HP0 {1} \
CONFIG.preset {ZedBoard} \
 ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {2} \
 ] $processing_system7_0_axi_periph

  # Create instance: rst_processing_system7_0_25M, and set properties
  set rst_processing_system7_0_25M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_25M ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXIS_MM2S [get_bd_intf_pins axi_vdma_0/M_AXIS_MM2S] [get_bd_intf_pins axis2vga_0/s_axis]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXI_MM2S [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins axi_vdma_0/M_AXI_MM2S]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins axi_vdma_0/S_AXI_LITE] [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins miz702_vtc_0/S00_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]

  # Create port connections
  connect_bd_net -net axis2vga_0_video_data_out [get_bd_pins axis2vga_0/video_data_o] [get_bd_pins miz702_vtc_0/data_i]
  connect_bd_net -net miz702_vtc_0_active_video_o [get_bd_pins axis2vga_0/active_video_i] [get_bd_pins miz702_vtc_0/active_video_o]
  connect_bd_net -net miz702_vtc_0_data_o [get_bd_ports VGA_D] [get_bd_pins miz702_vtc_0/data_o]
  connect_bd_net -net miz702_vtc_0_fsync_o [get_bd_pins axi_vdma_0/mm2s_fsync] [get_bd_pins miz702_vtc_0/fsync_o]
  set_property -dict [ list \
HDL_ATTRIBUTE.MARK_DEBUG {true} \
HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
 ] [get_bd_nets miz702_vtc_0_fsync_o]
  connect_bd_net -net miz702_vtc_0_hsync_o [get_bd_ports VGA_HS] [get_bd_pins miz702_vtc_0/hsync_o]
  connect_bd_net -net miz702_vtc_0_vsync_o [get_bd_ports VGA_VS] [get_bd_pins miz702_vtc_0/vsync_o]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_vdma_0/m_axi_mm2s_aclk] [get_bd_pins axi_vdma_0/m_axis_mm2s_aclk] [get_bd_pins axi_vdma_0/s_axi_lite_aclk] [get_bd_pins axis2vga_0/s_axis_aclk] [get_bd_pins miz702_vtc_0/s00_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_25M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_25M/ext_reset_in]
  connect_bd_net -net rst_processing_system7_0_25M_interconnect_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_25M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_25M_peripheral_aresetn1 [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins axi_vdma_0/axi_resetn] [get_bd_pins axis2vga_0/s_axis_aresetn] [get_bd_pins miz702_vtc_0/s00_axi_aresetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_25M/peripheral_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces axi_vdma_0/Data_MM2S] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000 -offset 0x43000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_vdma_0/S_AXI_LITE/Reg] SEG_axi_vdma_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs miz702_vtc_0/S00_AXI/S00_AXI_reg] SEG_miz702_vtc_0_S00_AXI_reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port DDR -pg 1 -y 40 -defaultsOSRD
preplace port VGA_VS -pg 1 -y 530 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 60 -defaultsOSRD
preplace port VGA_HS -pg 1 -y 510 -defaultsOSRD
preplace portBus VGA_D -pg 1 -y 590 -defaultsOSRD
preplace inst axi_vdma_0 -pg 1 -lvl 3 -y 380 -defaultsOSRD
preplace inst axis2vga_0 -pg 1 -lvl 4 -y 400 -defaultsOSRD
preplace inst miz702_vtc_0 -pg 1 -lvl 5 -y 550 -defaultsOSRD
preplace inst rst_processing_system7_0_25M -pg 1 -lvl 1 -y 360 -defaultsOSRD
preplace inst axi_mem_intercon -pg 1 -lvl 4 -y 140 -defaultsOSRD
preplace inst processing_system7_0_axi_periph -pg 1 -lvl 2 -y 410 -defaultsOSRD
preplace inst processing_system7_0 -pg 1 -lvl 5 -y 120 -defaultsOSRD
preplace netloc processing_system7_0_DDR 1 5 1 NJ
preplace netloc processing_system7_0_axi_periph_M00_AXI 1 2 1 660
preplace netloc axi_vdma_0_M_AXI_MM2S 1 3 1 1040
preplace netloc processing_system7_0_M_AXI_GP0 1 1 5 380 550 NJ 550 NJ 550 NJ 330 1820
preplace netloc rst_processing_system7_0_25M_interconnect_aresetn 1 1 3 350 120 NJ 120 NJ
preplace netloc axi_vdma_0_M_AXIS_MM2S 1 3 1 N
preplace netloc processing_system7_0_FCLK_RESET0_N 1 0 6 20 260 NJ 260 NJ 260 NJ 260 NJ 260 1790
preplace netloc miz702_vtc_0_vsync_o 1 5 1 NJ
preplace netloc axi_mem_intercon_M00_AXI 1 4 1 1360
preplace netloc miz702_vtc_0_active_video_o 1 3 3 1060 480 NJ 430 1800
preplace netloc axis2vga_0_video_data_out 1 4 1 1360
preplace netloc miz702_vtc_0_hsync_o 1 5 1 NJ
preplace netloc processing_system7_0_FIXED_IO 1 5 1 NJ
preplace netloc rst_processing_system7_0_25M_peripheral_aresetn1 1 1 4 370 570 680 520 1050 520 NJ
preplace netloc miz702_vtc_0_fsync_o 1 2 4 690 490 NJ 490 NJ 440 1790
preplace netloc processing_system7_0_FCLK_CLK0 1 0 6 30 450 360 560 670 500 1030 20 1370 250 1800
preplace netloc miz702_vtc_0_data_o 1 5 1 NJ
preplace netloc processing_system7_0_axi_periph_M01_AXI 1 2 3 660 510 NJ 510 NJ
levelinfo -pg 1 0 190 520 860 1200 1590 1840 -top 0 -bot 660
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


