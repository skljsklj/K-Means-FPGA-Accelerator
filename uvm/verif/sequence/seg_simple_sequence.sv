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

    `uvm_object_utils(seg_simple_sequence)
    seg_seq_item seg_item;

    function new(string name = "seg_simple_sequence");
        super.new(name);
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

        $display("\nPicture resolution is: %d", rows*cols);

        for(i = 0; i < rows*cols; i ++)
        begin
				start_item(seg_item);
				seg_item.bram_axi = 0;
				seg_item.img_ena = 1'b1;
				seg_item.img_addra = i*4;
            $display("Image adrress: %d",seg_item.img_addra);
				seg_item.img_douta = p_sequencer.cfg.img_input_data[i];
            $display("Loaded %d. pixel",i);
				finish_item(seg_item);
        end
			$display("\nImage loaded...\n");

        //********** LOADING CENTERS **********//
			$display("\nCenter loading begins...\n");

        for(j = 0; j < CLUSTER_CEN; j ++)
        begin
				start_item(seg_item);
				seg_item.bram_axi = 2;
				seg_item.img_enb = 1'b1;
				seg_item.img_addrb = j*4;
            $display("Image adrress: %d",seg_item.img_addrb);
				seg_item.img_doutb = p_sequencer.cfg.img_cent_data[j];
            $display("Loaded %d.pixel, bin: %b",j,p_sequencer.cfg.img_cent_data[j]);
				finish_item(seg_item);
        end
        $display("\nCenter loaded...\n");
		
        //  ***********************     START THE PROCESSING   ***********************//   
        $display("\nStarting the system... \n");
        `uvm_do_with(seg_item,{   seg_item.bram_axi == 1; seg_item.s00_axi_awaddr == AXI_BASE+CMD_REG_OFFSET; seg_item.s00_axi_wdata == 32'd1;});

    endtask : body

endclass : seg_simple_sequence
`endif