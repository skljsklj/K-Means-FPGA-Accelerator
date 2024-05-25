`ifndef SEG_AGENT_SV
    `define SEG_AGENT_SV

class seg_agent extends uvm_agent;
    
    //komponente

    seg_driver drv;
    seg_sequencer seqr;
    seg_monitor mon;
    virtual interface seg_interface s_vif;

    //konfiguracija
    seg_config cfg;
    
    `uvm_component_utils_begin(seg_agent)
        `uvm_field_object(cfg,UVM_DEFAULT);
        `uvm_field_object(drv,UVM_DEFAULT);
        `uvm_field_object(seqr,UVM_DEFAULT);
        `uvm_field_object(mon,UVM_DEFAULT);
    `uvm_component_utils_end

    function new(string name = "seg_agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if(!uvm_config_db#(virtual seg_interface)::get(this,"","seg_interface",s_vif))
            `uvm_fatal("NOVIF", {"Virtual interface must be set:",get_full_name(),".s_vif"})

        if(!uvm_config_db#(seg_config)::get(this,"","seg_config",cfg))
            `uvm_fatal("NOCONFIG", {"Config object must be set for:",get_full_name(),".cfg"})

        uvm_config_db#(seg_config)::set(this,"mon","seg_config",cfg);
        uvm_config_db#(seg_config)::set(this,"seqr","seg_config",cfg);
        uvm_config_db#(virtual seg_interface)::set(this,"*","seg_interface",s_vif);

        mon = seg_monitor::type_id::create("mon",this);
        if(cfg.is_active == UVM_ACTIVE) 
        begin
            drv = seg_driver::type_id::create("drv",this);
            seqr = seg_sequencer::type_id::create("seqr",this);
        end

    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(cfg.is_active == UVM_ACTIVE) 
        begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction : connect_phase

endclass : seg_agent 

`endif