module seg_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import test_pkg::*;

    logic clk;
    logic rst;

    logic ip_ena;
    logic [31:0] ip_addra;
    logic [23:0] ip_douta;

    logic ip_enb;
    logic [31:0] ip_addrb;
    logic [23:0] ip_doutb;

    // Interface
    seg_interface s_vif(clk,rst,ip_ena,ip_addra,ip_douta,ip_enb,ip_addrb,ip_doutb);

    // DUT
    ip_v1_0 DUT(
        // Interfejs za sliku
        .ena     (ip_ena),
        .wea     (),
        .addra   (ip_addra),
        .dina    (),
        .douta   (ip_douta),
        .reseta  (),
        .clka    (),
        
        // Interfejs za centre
        
        .enb     (ip_enb),
        .web     (),
        .addrb   (ip_addrb),
        .dinb    (),
        .doutb   (ip_doutb),
        .resetb  (),
        .clkb    (),
        
        // Interfejs za izlaz
        
        .enc     (),
        .wec     (s_vif.ip_enc),
        .addrc   (s_vif.ip_addrc),
        .dinc    (s_vif.ip_doutc),
        .doutc   (24'd0),
        .resetc  (),
        .clkc    (),

        // Ports of Axi Slave Bus Interface S00_AXI
        .s00_axi_aclk                  (clk),
        .s00_axi_aresetn               (rst),
        .s00_axi_awaddr                (s_vif.s00_axi_awaddr),
        .s00_axi_awprot                (s_vif.s00_axi_awprot),
        .s00_axi_awvalid               (s_vif.s00_axi_awvalid),
        .s00_axi_awready               (s_vif.s00_axi_awready),
        .s00_axi_wdata                 (s_vif.s00_axi_wdata),
        .s00_axi_wstrb                 (s_vif.s00_axi_wstrb),
        .s00_axi_wvalid                (s_vif.s00_axi_wvalid),
        .s00_axi_wready                (s_vif.s00_axi_wready),
        .s00_axi_bresp                 (s_vif.s00_axi_bresp),
        .s00_axi_bvalid                (s_vif.s00_axi_bvalid),
        .s00_axi_bready                (s_vif.s00_axi_bready),
        .s00_axi_araddr                (s_vif.s00_axi_araddr),
        .s00_axi_arprot                (s_vif.s00_axi_arprot),
        .s00_axi_arvalid               (s_vif.s00_axi_arvalid),
        .s00_axi_arready               (s_vif.s00_axi_arready),
        .s00_axi_rdata                 (s_vif.s00_axi_rdata),
        .s00_axi_rresp                 (s_vif.s00_axi_rresp),
        .s00_axi_rvalid                (s_vif.s00_axi_rvalid),
        .s00_axi_rready                (s_vif.s00_axi_rready)
        );

    bram BRAM_A(
        .clka   (clk), 
        .clkb   (clk),
        .reseta (rst),
        .ena    (s_vif.img_ena),    
        .wea    (1'b1),
        .addra  (s_vif.img_addra),
        .dia    (s_vif.img_douta),
        .doa    (),

        .resetb (rst),
        .enb    (ip_ena),
        .web    (1'b0),
        .addrb  (ip_addra),
        .dib    (24'd0),
        .dob    (ip_douta)
    );

    bram BRAM_B(
        .clka   (clk), 
        .clkb   (clk),
        .reseta (rst),
        .ena    (s_vif.img_enb),    
        .wea    (1'b1),
        .addra  (s_vif.img_addrb),
        .dia    (s_vif.img_doutb),
        .doa    (),
    
        .resetb (rst),
        .enb    (ip_enb),
        .web    (1'b0),
        .addrb  (ip_addrb),
        .dib    (24'd0),
        .dob    (ip_doutb)
    );
    
    initial begin
        uvm_config_db#(virtual seg_interface)::set(null,"uvm_test_top.env","seg_interface",s_vif);
        run_test("test_seg_simple");
    end

    // Clock and reset init
    initial begin
        clk <= 0;
        rst <= 0;
        #50 rst <= 1;
    end

    // Clock generation
    always #50 clk = ~clk;

endmodule : seg_top



