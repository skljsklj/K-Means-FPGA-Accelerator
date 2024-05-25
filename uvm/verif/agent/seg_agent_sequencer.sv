`ifndef SEG_SEQUENCER_SV
    `define SEG_SEQUENCER_SV

class seg_sequencer extends uvm_sequencer#(seg_seq_item);

    `uvm_component_utils(seg_sequencer)

    seg_config cfg;

    function new(string name = "sequencer", uvm_component parent = null);
        super.new(name,parent);

        if(!uvm_config_db#(seg_config)::get(this, "", "seg_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
        
    endfunction : new

endclass : seg_sequencer 

`endif 