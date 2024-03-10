#include "hard.hpp"


SC_HAS_PROCESS(Hard);

Hard::Hard(sc_module_name name):
	sc_module(name),
	ready(1)
	
	{
		interconnect_socket.register_b_transport(this, &Hard::b_transport);
		SC_REPORT_INFO("Hard", "Constructed.");
	}
	
Hard::~Hard()
{
	SC_REPORT_INFO("Hard", "Destroyed");
}

void Hard::b_transport(pl_t &pl, sc_time &offset)
{
	tlm_command cmd = pl.get_command();
	sc_dt::uint64 addr = pl.get_address();
	unsigned int len = pl.get_data_length();
	unsigned char *buf = pl.get_data_ptr();
	pl.set_response_status(TLM_OK_RESPONSE);
	
	switch(cmd)
	{
		case TLM_WRITE_COMMAND:
			switch(addr)
			{
				case ADDR_ROWS:
					rows = toInt(buf);
					cout << "rows = " << rows << endl;
					break;
				case ADDR_COLS:
					cols = toInt(buf);
					cout << "cols = " << cols << endl;
					break;	
				case ADDR_START:
					start = toInt(buf);
					cout << "start = " << start << endl;
					findAssociatedCluster(offset);
					break;	
				default:
					pl.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
					cout << "Wrong address" << endl;
			}
			break;
			
		case TLM_READ_COMMAND:
			switch(addr)
			{
				case ADDR_READY:
					toUchar(buf, ready);
					break;
				default:
					pl.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
			}
			break;
			
		default:
			pl.set_response_status( tlm::TLM_COMMAND_ERROR_RESPONSE );
			cout << "Wrong command" << endl;
	
	}
	offset += sc_time(DELAY, SC_NS);
}

void Hard::findAssociatedCluster(sc_time &system_offset) {    
    pl_t pl;
                                       
    if (start == 1 && ready == 1)
    {
        ready = 0;
        offset += sc_time(DELAY, SC_NS);
    }
    
    else if (start == 0 && ready == 0)
    {   
        cout << "Processing started" << endl;
        
        for(int i = 0; i < rows; i++)
        {
            for(int j = 0; j < cols * 3; j+= 3) //Prolazimo kroz matricu char-ova, gde su susedna 3 bgr takvim redosledom
            {
                
                sc_int<32> minDistance = STARTING_MIN_DIS*FIXED_WIDTH;
                sc_int<8> closestClusterIndex = 0;
                
                for(int k = 0; k < CLUSTERS_NUMBER*3; k+=3)

                {
			sc_int<16> diffBlue = read_bram(i*cols*3 + j) - read_bram(cols*rows*3 + k);
			sc_int<16> diffGreen = read_bram(i*cols*3 + j + 1) - read_bram(cols*rows*3 + k + 1);
			sc_int<16> diffRed = read_bram(i*cols*3 + j + 2) - read_bram(cols*rows*3 + k + 2);

			sc_int<32> distance = diffBlue*diffBlue + diffGreen*diffGreen + diffRed*diffRed;

			//start of sqrt algorithm
			
			sc_int<32> op = distance * FIXED_WIDTH;
			sc_int<32> distance_sqrt = 0;
			sc_int<32> one = 1 << 30;
			
			while(one > op)
				one >>= 2;

			while(one != 0){
				if(op >= distance_sqrt + one){
					op = op - (distance_sqrt + one);
					distance_sqrt = distance_sqrt + 2 * one;
				    }
				distance_sqrt >>= 1;
				one >>= 2;
			}
			
			//end of sqrt algorithm
    	    	        
                    if (distance_sqrt < minDistance)
                    {
                        minDistance = distance_sqrt;
                        closestClusterIndex = k/3;
                    }   
                }   
                write_bram(i*cols*3 + j, j/3);
                write_bram(i*cols*3 + j+1, i);
                write_bram(i*cols*3 + j+2, closestClusterIndex);                                                         
            }
        }       
                                               
        cout<<"Upis iz IP u BRAM zavrsen"<<endl;               
        ready = 1;
    }   
}


void Hard::write_bram(sc_uint<64> addr, unsigned char val)
{
	pl_t pl;
	unsigned char buf;
	buf = val;
	pl.set_address(addr);
	pl.set_data_length(1); 
	pl.set_data_ptr(&buf);
	pl.set_command( tlm::TLM_WRITE_COMMAND );
	pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
	bram_socket->b_transport(pl, offset);
}

unsigned char Hard::read_bram(sc_uint<64> addr)
{
	pl_t pl;
	unsigned char buf;
	pl.set_address(addr);
	pl.set_data_length(1); 
	pl.set_data_ptr(&buf);
	pl.set_command( tlm::TLM_READ_COMMAND );
	pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
	bram_socket->b_transport(pl, offset);
	return buf;
}


