`ifndef SEG_SEQUENCE_PKG_SV
    `define SEG_SEQUENCE_PKG_SV

    package seg_sequence_pkg;

        import uvm_pkg::*;            
        `include "uvm_macros.svh"           

        import seg_agent_pkg::seg_seq_item;
        import seg_agent_pkg::seg_sequencer;

        `include "seg_base_sequence.sv"
        `include "seg_simple_sequence.sv"
    endpackage
`endif 