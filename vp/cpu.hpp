#ifndef CPU_H
#define CPU_H
#define SC_INCLUDE_FX

#include <iostream>
#include <fstream>
#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include <vector>
#include <sstream>

#include "hard.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui/highgui.hpp"

using namespace std;
using namespace cv;

class Cpu : public sc_core::sc_module
{
public:
    SC_HAS_PROCESS(Cpu);
    Cpu(sc_core::sc_module_name name,char** strings, int argv);
    ~Cpu();
    tlm_utils::simple_initiator_socket<Cpu> interconnect_socket;

protected:
    	void segmentation();
    	
    	sc_core::sc_time offset;
    
    	void scan_infile();
    	void writeInFile();
	void adjustClusterCenters(Mat imgInput, vector<Scalar> &clustersCenters, vector<Point3i> ptInClusters, double &oldCenter, double newCenter);
	Mat applyFinalClusterToImage(Mat &imgOutput, vector<Point3i> ptInClusters);
	void createClustersInfo(Mat imgOrig, vector<Scalar> &clustersCenters);

	void read_bram(sc_uint<64> addr, unsigned char *all_data, int length);
	void write_bram(sc_uint<64> addr, unsigned char val);
	int read_hard(sc_uint<64> addr);
	void write_hard(sc_uint<64> addr,int val);

    	std::string inputFileName;
    	//char* image_file_name;
};

#endif

