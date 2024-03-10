#ifndef VP_HPP_
#define VP_HPP_

#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "cpu.hpp"
#include "interconnect.hpp"
#include "hard.hpp"
#include "bram.hpp"

class Vp :  public sc_core::sc_module
{
	public:
		Vp(sc_core::sc_module_name name,char** strings, int argv);
		~Vp();

	protected:
		Cpu cpu;
		Interconnect interconnect;
		Hard hard;
		Bram bram;		
};

#endif // VP_HPP_
