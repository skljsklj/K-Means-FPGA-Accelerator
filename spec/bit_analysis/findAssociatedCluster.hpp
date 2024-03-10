#ifndef FIND_ASSOCIATED_CLUSTER_HPP
#define FIND_ASSOCIATED_CLUSTER_HPP

#include "computeColorDistance.hpp"

void findAssociatedCluster(cv::Mat imgInput, int clusters_number, std::vector<cv::Scalar> clustersCenters, std::vector<cv::Point3i>& ptInClusters);

#endif // FIND_ASSOCIATED_CLUSTER_HPP

