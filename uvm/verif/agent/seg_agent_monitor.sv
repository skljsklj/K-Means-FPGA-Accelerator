`ifndef SEG_MONITOR_SV
    `define SEG_MONITOR_SV

class seg_monitor extends uvm_monitor;

    bit checks_enable = 1;
    bit coverage_enable = 1;

    seg_config cfg;
    
    uvm_analysis_port #(seg_seq_item) item_collected_port;

    `uvm_component_utils_begin(seg_monitor)
        `uvm_field_int(checks_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_component_utils_end

    // Virtual interface
    virtual interface seg_interface s_vif;

    // Current transaction
    seg_seq_item curr_it;

    function new(string name = "seg_monitor", uvm_component parent = null);
        super.new(name,parent);
        item_collected_port = new("item_collected_port", this);

        if(!uvm_config_db#(virtual seg_interface)::get(this, "*", "seg_interface",s_vif))
            `uvm_fatal("NOVIF",{"tocak virtual interface must be set: ",get_full_name(),".s_vif"})
            
        if(!uvm_config_db#(seg_config)::get(this, "", "seg_config",cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set: ",get_full_name(),".cfg"})   
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task main_phase(uvm_phase phase);
		@(posedge s_vif.clk)
		wait(s_vif.ip_enc == 1)

        forever begin
				@(posedge s_vif.ip_enc);
					curr_it = seg_seq_item::type_id::create("curr_it",this);                       
						`uvm_info(get_type_name(), $sformatf("[Monitor] Gathering information..."), UVM_MEDIUM);
                if(s_vif.ip_enc == 1)
                begin
                    curr_it.ip_enc = s_vif.ip_enc;
                    curr_it.ip_addrc = s_vif.ip_addrc;
                    curr_it.ip_doutc = s_vif.ip_doutc; 
                    item_collected_port.write(curr_it);   
                end   
        end
    endtask
endclass:seg_monitor
`endif
                
        