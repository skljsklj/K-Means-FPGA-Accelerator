cd ..
set root_dir [pwd]
cd scripts
set resultDir ../uvm_project

file mkdir $resultDir

create_project seg_col $resultDir -part xc7z010clg400-1
set_property board_part digilentinc.com:zybo:part0:2.0 [current_project]

# ===================================================================================
# Ukljucivanje svih izvornih i simulacionih fajlova u projekat
# ===================================================================================

add_files -norecurse ../dut/bram.vhd
add_files -norecurse ../dut/ip.vhd
add_files -norecurse ../dut/ip_v1_0.vhd
add_files -norecurse ../dut/ip_v1_0_S00_AXI.vhd
add_files -norecurse ../dut/memory_subsystem.vhd
add_files -norecurse ../dut/utils_pkg.vhd

update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/axi_agent/seg_axi_agent_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/agent/seg_agent_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/configuration/configuration_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/sequence/seg_sequence_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/test_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/seg_interface.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/seg_top.sv

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Ukljucivanje uvm biblioteke

set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg UVM_TESTNAME=test_seg_simple -testplusarg UVM_VERBOSITY=UVM_LOW} -objects [get_filesets sim_1]