`ifndef TEST_PKG_SV
    `define TEST_PKG_SV

package test_pkg; 
    
        import uvm_pkg::*;
        `include "uvm_macros.svh"

        import seg_agent_pkg::*;
        import seg_axi_agent_pkg::*;
        import seg_sequence_pkg::*;
        import configuration_pkg::*;

        `include "seg_scoreboard.sv"
        `include "seg_enviroment.sv"
        `include "test_seg_base.sv"
        `include "test_seg_simple.sv"

endpackage : test_pkg

    `include "seg_interface.sv"

`endif