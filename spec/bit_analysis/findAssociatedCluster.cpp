#include "findAssociatedCluster.hpp"

void findAssociatedCluster(cv::Mat imgInput, int clusters_number, std::vector<cv::Scalar> clustersCenters, std::vector<cv::Point3i>& ptInClusters) {  
    for (int r = 0; r < imgInput.rows; r++) {
        for (int c = 0; c < imgInput.cols; c++) {
            sc_fixed<10,10> minDistance = 443;
            int closestClusterIndex = 0;
            cv::Scalar pixel = imgInput.at<cv::Vec3b>(r, c);

            for (int k = 0; k < clusters_number; k++) {
                cv::Scalar clusterPixel = clustersCenters[k];

                sc_fixed<16,10> distance = computeColorDistance(pixel, clusterPixel);
                
                if (distance < minDistance) {
                    minDistance = distance;
                    closestClusterIndex = k;
                }
            }

            Point3i pixelPoint(c, r, closestClusterIndex);
            ptInClusters.push_back(pixelPoint);
        }
    }
}

