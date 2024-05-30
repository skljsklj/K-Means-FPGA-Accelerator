class seg_config extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE; // Decide if agents are ACTIVE (monitor, agent, sqr, driver) or PASSIVE (monitor only)

    // Slika, centri, izlaz
    string img_input;
    string img_cent;
    string img_gv;

    // Parametri ulazne slike
    int rows = 100;
    int cols = 100;
    int i = 0;
    int j = 0;
    int fd;
    int tmp;
    int img_doutc_gv[$]; 
    int coverage_goal_cfg;
    string line_img;
    string line_cen;
    string line_gv;

    logic[23:0] img_input_data[$];
    logic[23:0] img_cent_data[$];
    logic[23:0] img_gv_data[$]; 

    `uvm_object_utils_begin(seg_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "seg_config");
        super.new(name);

        img_input = "../../../../../files\/slika_bits.txt";
        img_cent = "../../../../../files\/centri_bits.txt";
        img_gv = "../../../../../files\/izlaz_bits.txt";

    endfunction

    function void extracting_data();

    //********** UCITAVANJE SLIKE **********//
	
		img_input_data.delete();
		fd = $fopen(img_input, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened slika_bits.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_img, fd);
            img_input_data.push_back(line_img.atobin());
            // Prikazivanje elemenata niza za svaku iteraciju
            $display("Element img_input_data[%0d] = %b",i,  img_input_data[i]);
            i++;    
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening slika_bits.txt"), UVM_HIGH)
    end
    $fclose(fd);

    //********** UCITAVANJE CENTRA **********//

		img_cent_data.delete();
		fd = $fopen(img_cent, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened centri_bits.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_cen, fd);
            $display("Line: %s", line_cen);
            img_cent_data.push_back(line_cen.atobin());
            // Prikazivanje elemenata niza za svaku iteraciju
            $display("Element img_cent_data[%0d] = %b",j,  img_cent_data[j]);
            j++;
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening centri_bits.txt"), UVM_HIGH)
    end
    $fclose(fd);

    //********** UCITAVANJE ZLATNOG VEKTORA **********//

		img_gv_data.delete();
		fd = $fopen(img_gv, "r");
    if(fd) begin
        
        `uvm_info(get_name(), $sformatf("Successfully opened izlaz_bits.txt"), UVM_LOW)
        while(!$feof(fd))
        begin
            $fgets(line_gv, fd);
            img_gv_data.push_back(line_gv.atobin());
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening izlaz_bits.txt"), UVM_HIGH)
    end
    $fclose(fd);

    endfunction : extracting_data
endclass : seg_config

        
