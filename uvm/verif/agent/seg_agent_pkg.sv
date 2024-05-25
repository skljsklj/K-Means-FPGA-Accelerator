`ifndef SEG_AGENT_PKG
    `define SEG_AGENT_PKG

    package seg_agent_pkg;

        import uvm_pkg::*;
        `include "uvm_macros.svh"

        import configuration_pkg::*;

        `include "seg_agent_seq_item.sv"
        `include "seg_agent_sequencer.sv"
        `include "seg_agent_driver.sv"
        `include "seg_agent_monitor.sv"
        `include "seg_agent.sv"
        

    endpackage : seg_agent_pkg

`endif 