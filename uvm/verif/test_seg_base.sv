`ifndef TEST_SEG_BASE_SV
    `define TEST_SEG_BASE_SV

class test_seg_base extends uvm_test;

    `uvm_component_utils(test_seg_base)

    seg_environment env;
    seg_config cfg;

    function new(string name = "test_seg_base", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"Starting build phase...", UVM_LOW);
        cfg = seg_config::type_id::create("cfg");
        cfg.randomize();
        cfg.extracting_data();
        uvm_config_db#(seg_config)::set(this,"*","seg_config",cfg);
        env = seg_environment::type_id::create("env",this); 
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

endclass : test_seg_base

`endif    