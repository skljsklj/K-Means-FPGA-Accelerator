`ifndef SEG_ENVIRONMENT_SV
    `define SEG_ENVIRONMENT_SV
    
    class seg_environment extends uvm_env;
    
    seg_agent agent; 
    seg_axi_agent axi_agent;
    
    seg_config cfg;
    seg_scoreboard s_scbd;

    virtual interface seg_interface s_vif;
    `uvm_component_utils (seg_environment)

    function new(string name = "seg_environment" , uvm_component parent = null);  
       super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Getting interfaces from configuration base //
        if (!uvm_config_db#(virtual seg_interface)::get(this, "", "seg_interface", s_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".s_vif"})

        if (!uvm_config_db#(seg_config)::get(this, "", "seg_config", cfg))
            `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".cfg"})

         // Setting to configurartion base //
        uvm_config_db#(seg_config)::set(this, "agent", "seg_config", cfg);
        uvm_config_db#(seg_config)::set(this, "s_scbd","seg_config", cfg);
        uvm_config_db#(virtual seg_interface)::set(this, "agent", "seg_interface", s_vif);
        uvm_config_db#(virtual seg_interface)::set(this, "axi_agent", "seg_interface", s_vif);

        agent = seg_agent::type_id::create("agent",this);
        axi_agent = seg_axi_agent::type_id::create("axi_agent",this);
        //Dodavanje scoreboard-a
        s_scbd = seg_scoreboard::type_id::create("s_scbd",this);
    endfunction : build_phase   
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.item_collected_port.connect(s_scbd.item_collected_import);
    endfunction
    
    
    endclass : seg_environment

`endif    