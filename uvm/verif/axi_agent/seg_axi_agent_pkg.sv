`ifndef SEG_AXI_AGENT_PKG
    `define SEG_AXI_AGENT_PKG

    package seg_axi_agent_pkg;

        import uvm_pkg::*;
        `include "uvm_macros.svh"

        //import configuration_pkg::*;

        `include "seg_axi_agent_seq_item.sv"
        `include "seg_axi_agent_monitor.sv"
        `include "seg_axi_agent.sv"

    endpackage : seg_axi_agent_pkg

`endif 