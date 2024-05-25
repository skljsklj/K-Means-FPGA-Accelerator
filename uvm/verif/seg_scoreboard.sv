class seg_scoreboard extends uvm_scoreboard;

    bit checks_enable = 1;
    bit coverage_enable = 1;

    seg_config cfg;

    uvm_analysis_imp#(seg_seq_item, seg_scoreboard) item_collected_import;

    int num_of_tr;

    `uvm_component_utils_begin(seg_scoreboard)
        `uvm_field_int(checks_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_component_utils_end

    function new(string name = "seg_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_collected_import = new("item_collected_import", this);

        if(!uvm_config_db#(seg_config)::get(this,"","seg_config",cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ", get_full_name(),".cfg"})
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
    endfunction : connect_phase

    function void write(seg_seq_item curr_it);
        if(checks_enable)
        begin
            `uvm_info(get_type_name(),$sformatf("\n[Scoreboard] Scoreboard function write called..."), UVM_MEDIUM);
            asrt_img_output : assert(curr_it.img_dinc == cfg.img_gv_data[curr_it.img_addrc/4])
                `uvm_info(get_type_name(), $sformatf("\nMatch succesfull\nObserved value is %d, expected is %d.\n", 
                curr_it.img_dinc, 
                cfg.img_gv_data[curr_it.img_addrc/4]), UVM_MEDIUM)
            
            else
                `uvm_error(get_type_name(), $sformatf("\nObserved mismatch for img_output[%d]\n Observed value is %d, expected is %d.\n",
                curr_it.img_addrc/4,
                curr_it.img_dinc,
                cfg.img_gv_data[curr_it.img_addrc/4]))
            
            ++num_of_tr;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Seg scoreboard examined: %0d transactions", num_of_tr), UVM_LOW);
    endfunction
endclass