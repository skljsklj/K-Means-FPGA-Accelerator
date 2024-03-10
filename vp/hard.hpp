#ifndef HARD_HPP_
#define HARD_HPP_

#include "defines.hpp"
#include "utils.hpp"
#include <systemc>
#include <vector>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

class Hard : public sc_module
{
public:
	Hard(sc_module_name);
	~Hard();
	
	tlm_utils::simple_target_socket<Hard> interconnect_socket;
	tlm_utils::simple_initiator_socket<Hard> bram_socket;
	
	
protected:
	pl_t pl;
	sc_time offset;
	
	//input parameters
	sc_uint<8> rows;
	sc_uint<8> cols;
	sc_uint<1> start;
	
	//output parameters
	sc_uint<1> ready;
	
	void b_transport(pl_t&, sc_time&); 
	void findAssociatedCluster(sc_time&);
	unsigned char read_bram(sc_uint<64> addr);
	void write_bram(sc_uint<64> addr, unsigned char val);	
};

#endif // HARD_HPP_
