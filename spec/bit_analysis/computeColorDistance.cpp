#include "computeColorDistance.hpp"

sc_dt::sc_fixed<16,10> computeColorDistance(cv::Scalar pixel, cv::Scalar clusterPixel) {
    sc_dt::sc_fixed<16,16> diffBlue = pixel.val[0] - clusterPixel[0];
    sc_dt::sc_fixed<16,16> diffGreen = pixel.val[1] - clusterPixel[1];
    sc_dt::sc_fixed<16,16> diffRed = pixel.val[2] - clusterPixel[2];

    double diffBlue_double = diffBlue.to_double();
    double diffGreen_double = diffGreen.to_double();
    double diffRed_double = diffRed.to_double();

    double distance_double = sqrt(pow(diffBlue_double, 2) + pow(diffGreen_double, 2) + pow(diffRed_double, 2));

    sc_dt::sc_fixed<16,10> distance = distance_double;

    return distance;
}

