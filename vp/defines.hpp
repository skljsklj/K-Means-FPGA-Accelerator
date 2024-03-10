#ifndef TYPEDEFS_HPP
#define TYPEDEFS_HPP

#define int64 opencv_int64
#define uint64 opencv_uint64

#include <opencv2/core.hpp>
#undef int64
#undef uint64

#define SC_INCLUDE_FX
#include <tlm>
#include <sysc/datatypes/fx/sc_fixed.h>

typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
typedef tlm::tlm_base_protocol_types::tlm_phase_type ph_t;

//registers in Hard
#define ADDR_ROWS 0x00
#define ADDR_COLS 0x01
#define ADDR_START 0x02
#define ADDR_READY 0x03


//number of clusters
#define CLUSTERS_NUMBER 6

//bram size 240KB
#define BRAM_SIZE 0x3A980

//macro for offset
#define DELAY 10

//32-bit data bus, 4 bytes
#define BUS_WIDTH 4

//fixed point data
#define NUM_OF_FIXED_BITS 6
#define FIXED_WIDTH (1 << (NUM_OF_FIXED_BITS*2))

//starting minDistance
#define STARTING_MIN_DIS 443

//AXI&BRAM
#define VP_ADDR_BRAM_L 0x00000000
#define VP_ADDR_BRAM_H 0x00000000 + BRAM_SIZE

#define VP_ADDR_IP_HARD_L 0x40000000
#define VP_ADDR_IP_HARD_H 0x4000000F

#endif	 //TYPEDEFS_HPP
	
