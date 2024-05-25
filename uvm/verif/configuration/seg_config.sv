class seg_config extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE; // Decide if agents are ACTIVE (monitor, agent, sqr, driver) or PASSIVE (monitor only)

    //randc int rand_test_init;
    //int rand_test_num;

    // Slika, centri, izlaz
    string img_input;
    string img_cent;
    string img_gv;

    // Parametri ulazne slike
    int rows = 100;
    int cols = 100;

    int fd;
    int tmp;

    int img_doutc_gv[$]; //mozda ovo nije dobro
    int coverage_goal_cfg;

    int img_input_data[$];
    int img_cent_data[$];
    int img_gv_data[$]; //mozda ovo nije dobro

    `uvm_object_utils_begin(seg_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_object_utils_end

    /*constraint rand_const{
        rand_test_init > 0;
        rand_test_init < 37;
    }*/ //randomizuje koji od testova se bira

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
            $fscanf(fd, "%f\n",tmp);
            img_input_data.push_back(tmp);
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
            $fscanf(fd, "%f\n",tmp);
            img_cent_data.push_back(tmp);
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
            $fscanf(fd, "%f\n",tmp);
            img_gv_data.push_back(tmp);
        end
    end
    else begin
        `uvm_info(get_name(), $sformatf("Error opening izlaz_bits.txt"), UVM_HIGH)
    end
    $fclose(fd);

    endfunction : extracting_data
endclass : seg_config

        
