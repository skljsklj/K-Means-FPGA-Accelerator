`ifndef SEG_SIMPLE_SEQUENCE_SV
    `define SEG_SIMPLE_SEQUENCE_SV

    parameter AXI_BASE = 5'b00000;
    parameter ROWS_REG_OFFSET = 0;
    parameter COLS_REG_OFFSET = 4;
    parameter CMD_REG_OFFSET = 8;
    parameter STATUS_REG_OFFSET = 12;

    parameter CLUSTER_CEN = 6;

    int rows, cols;

class seg_simple_sequence extends seg_base_sequence;

    int i = 0;
    int j = 0;
    int k = 0;

    /*covergroup img_data_cover();
        option.per_instance = 1;
        img_pix_value : coverpoint seg_seq_item.img_douta{
            bins low_value = {[0:5,592,405]};
            bins medium_value = {[5,592,406:11,184,810]};
            bins high_value = {[11,184,811:16777215]}; // 24 - bitni brojevi, mozda bude trebalo da se menja
        }
    endgroup*/

    /*covergroup cent_data_cover();
        option.per_instance = 1;
        cent_pix_value : coverpoint seg_seq_item.img_doutb{
            bins low_value = {[0:5,592,405]};
            bins medium_value = {[5,592,406:11,184,810]};
            bins high_value = {[11,184,811:16777215]}; // 24 - bitni brojevi, mozda bude trebalo da se menja
        }   
    endgroup*/

    `uvm_object_utils(seg_simple_sequence)
    seg_seq_item seg_item;

    function new(string name = "seg_simple_sequence");
        super.new(name);
        //img_data_cover = new();
        //cent_data_cover = new();
    endfunction : new

    virtual task body();

        rows = p_sequencer.cfg.rows;
        cols = p_sequencer.cfg.cols;

        seg_item = seg_seq_item::type_id::create("seg_item");

        //********** INITALIZATION OF THE SYSTEM **********//
        $display("AXI initalization starts...\n");
        `uvm_do_with(seg_item, { seg_item.bram_axi == 1; seg_item.s00_axi_awaddr == AXI_BASE + CMD_REG_OFFSET; seg_item.s00_axi_wdata == 32'd0;}); 

        //********** SETTING IMAGE PARAMETERS **********//
        $display("\nSetting image parameters...\n\n");
        `uvm_do_with(seg_item, {seg_item.bram_axi == 1; seg_item.s00_axi_awaddr == AXI_BASE + ROWS_REG_OFFSET; seg_item.s00_axi_wdata == rows;});
        `uvm_do_with(seg_item, {seg_item.bram_axi == 1; seg_item.s00_axi_awaddr == AXI_BASE + COLS_REG_OFFSET; seg_item.s00_axi_wdata == cols;});

        //********** LOADING AN IMAGE **********//
        $display("\nImage loading begins...\n");

        for(i = 0; p_sequencer.cfg.rows * p_sequencer.cfg.cols - 1; i ++)
        begin
            start_item(seg_item);
            seg_item.img_ena = 1'b1;
            seg_item.img_addra = i*4;
            seg_item.img_douta = p_sequencer.cfg.img_input_data[i];
            //img_data_cover.sample();
            finish_item(seg_item);
        end

        start_item(seg_item);
            seg_item.bram_axi = 0;
            seg_item.img_ena = 1'b0;
            seg_item.img_addra = 32'd0;
            seg_item.img_douta = 24'd0;
        finish_item(seg_item);

        //********** LOADING CENTERS **********//
        $display("\nCenter loading begins...\n");

        for(j = 0; CLUSTER_CEN - 1; j ++)
        begin
            start_item(seg_item);
            seg_item.img_enb = 1'b1;
            seg_item.img_addrb = i*4;
            seg_item.img_doutb = p_sequencer.cfg.img_input_data[i];
            //cent_data_cover.sample();
            finish_item(seg_item);
        end

        start_item(seg_item);
            seg_item.bram_axi = 0;
            seg_item.img_enb = 1'b0;
            seg_item.img_addrb = 32'd0;
            seg_item.img_doutb = 24'd0;
        finish_item(seg_item);

        //  ***********************     START THE PROCESSING   ***********************//   

        $display("\nStarting the system... \n");
        `uvm_do_with(seg_item,{   seg_item.bram_axi == 1; seg_item.s00_axi_awaddr == AXI_BASE+CMD_REG_OFFSET; seg_item.s00_axi_wdata == 32'd1;});

        //**********READING THE OUTPUT IMAGE**********//
        $display("Initiate reading from output image");

        for(k = 0; p_sequencer.cfg.rows * p_sequencer.cfg.cols; k++)
        begin
            start_item(seg_item);
                seg_item.bram_axi = 0;
                seg_item.img_wec = 1'b0;
                seg_item.img_addrc = k*4;
                seg_item.img_dinc = 24'd0; //sus
            finish_item(seg_item);
        end

        $display("\n All done!\n");

    endtask : body

endclass : seg_simple_sequence
`endif
        






