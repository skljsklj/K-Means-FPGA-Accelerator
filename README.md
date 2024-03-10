# K-Means-FPGA-Accelerator
K-Means is a clustering algorithm that groups data points based on their similarity or dissimilarity, where similar data points are grouped into the same cluster, while dissimilar ones are placed in different clusters. In our implementation, the measure of similarity is the color of pixels. Pixels with similar colors should be grouped into the same cluster. The algorithm is implemented in three basic steps:

Randomly initializing cluster centers (the number of clusters is a parameter chosen at the beginning).

Iterating until convergence:
a. Calculating the color distance between each pixel and each cluster center.
b. Assigning pixels to the nearest cluster centers (using the minimum color distance).
c. Recalculating the mean values of cluster centers to obtain their new color values.

Applying the final clusters to the image.

Based on profiling conducted in a previous part of the project (designing electronic devices at the system level), we concluded that two functions, findAssociatedCluster and computeColorDistance, consume the most processing time and need to be implemented in hardware, specifically by writing VHDL models for an FPGA. The goal is to design the system's appearance (data path and control path) based on the pseudocode and later, using a hardware description language, achieve the desired functionality of the system. The findAssociatedCluster function calls the computeColorDistance function internally. The functionality of this function is implemented within findAssociatedCluster instead of calling a separate function to facilitate the creation of pseudocode for obtaining the ASMD (Algorithmic State Machine Diagram) diagram.
