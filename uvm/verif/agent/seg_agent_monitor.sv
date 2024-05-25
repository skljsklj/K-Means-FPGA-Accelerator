`ifndef SEG_MONITOR_SV
    `define SEG_MONITOR_SV

class seg_monitor extends uvm_monitor;

    // Standard control fields
    bit checks_enable = 1;
    bit coverage_enable = 1;

    seg_config cfg;
    
    uvm_analysis_port #(seg_seq_item) item_collected_port;

    `uvm_object_utils_begin(seg_monitor)
        `uvm_field_int(checks_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_component_utils_end

    // Virtual interface
    virtual interface seg_interface s_vif;

    // Current transaction
    seg_seq_item curr_it;

    // PLACE FOR COVERAGE //

    /*covergroup output_cover (int coverage_goal);
        option.per_instance = 1;
        option.goal = coverage_goal;
        output_img_address : coverpoint s_vif.img_addrc{
            bins b1 = {[0:10000]}; //treba ispraviti na 10k umesto na 100k
            bins b2 = {[10001:20000]};
            bins b3 = {[20001:30000]};
            bins b4 = {[30001:40000]};
            bins b5 = {[40001:50000]};
            bins b6 = {[50001:60000]};
            bins b7 = {[60001:70000]};
            bins b8 = {[70001:80000]};
            bins b9 = {[80001:90000]};
            bins b10 = {[90001:100000]};
        }
    endgroup*/

    function new(string name = "seg_monitor", uvm_component parent = null);
        super.new(name,parent);
        item_collected_port = new("item_collected_port", this);

        if(!uvm_config_db#(virtual seg_interface)::get(this, "*", "seg_interface",s_vif))
            `uvm_fatal("NOVIF",{"tocak virtual interface must be set: ",get_full_name(),".s_vif"})
            
        if(!uvm_config_db#(seg_config)::get(this, "", "seg_config",cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set: ",get_full_name(),".cfg"})

        //output_cover = new(cfg.coverage_goal_cfg);
        
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task main_phase(uvm_phase phase);
        @(posedge s_vif.clk)
        wait(s_vif.s00_axi_rdata == 0)
        wait(s_vif.s00_axi_rdata == 1)
        wait(s_vif.s00_axi_rdata == 0)
        wait(s_vif.s00_axi_rdata == 1)

        forever begin
            @(posedge s_vif.clk);
            if(s_vif.rst)
            begin
                curr_it = seg_seq_item::type_id::create("curr_it", this);
                if(s_vif.s00_axi_rdata == 1 && s_vif.s00_axi_araddr == 0)
                begin
                    //output_cover.sample();
                    `uvm_info(get_type_name(), $sformatf("[Monitor] Gathering information..."), UVM_MEDIUM);
                    curr_it.img_addrc = s_vif.img_addrc - 4;
                    curr_it.img_dinc = s_vif.img_dinc; //mozda nije dobar port

                    item_collected_port.write(curr_it);
                end
            end
        end
    endtask
endclass:seg_monitor
`endif
                
        