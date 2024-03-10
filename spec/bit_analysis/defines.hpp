#define int64 opencv_int64
#define uint64 opencv_uint64

#include <opencv2/core.hpp>
#undef int64
#undef uint64

#include <iostream>
#include <ctime>
#include <cmath>
#include <systemc.h>
#include "opencv2/highgui/highgui.hpp"
#include <sysc/datatypes/fx/sc_fixed.h>
#include "computeColorDistance.hpp"
#include "findAssociatedCluster.hpp"
#include <vector>

using namespace cv;
using namespace std;
using namespace sc_dt;
using namespace sc_core;

