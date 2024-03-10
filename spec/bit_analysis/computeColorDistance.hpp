#ifndef COMPUTE_COLOR_DISTANCE_HPP
#define COMPUTE_COLOR_DISTANCE_HPP

#include "defines.hpp"

sc_dt::sc_fixed<16,10> computeColorDistance(cv::Scalar pixel, cv::Scalar clusterPixel);

#endif // COMPUTE_COLOR_DISTANCE_HPP

