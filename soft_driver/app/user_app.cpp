#include <iostream>
#include <ctime>
#include <cmath>
#include "opencv2/highgui/highgui.hpp"
#include <fstream>
#include <fcntl.h>
#include <unistd.h>
#include <cstring>
#define CLUSTERS_NUMBER 6
#define DEVICE_PATH "/dev/cluster_driver"

using namespace cv;
using namespace std;


typedef struct {
    unsigned char b;
    unsigned char g;
    unsigned char r;
} Pixel_driver;

void createClustersInfo(Mat imgInput, int clusters_number, vector<Scalar> &clustersCenters)
{
    int rows = imgInput.rows; //RNG ISKLJUCEN
    int cols = imgInput.cols;

    for (int k = 0; k < clusters_number; k++)
    {
        int centerRow = k * rows / clusters_number;
        int centerCol = k * cols / clusters_number;

        Scalar centerPixel = imgInput.at<Vec3b>(centerRow, centerCol);
        Scalar centerK(centerPixel.val[0], centerPixel.val[1], centerPixel.val[2]);
        clustersCenters.push_back(centerK);
    }
    cout << "Clusters created." << endl;
}

void convertClustersCenters(const vector<Scalar> &clustersCenters, Pixel_driver startClusters[6])
{
    for (int i = 0; i < clustersCenters.size(); ++i)
    {
        startClusters[i].b = static_cast<unsigned char>(clustersCenters[i].val[0]);
        startClusters[i].g = static_cast<unsigned char>(clustersCenters[i].val[1]);
        startClusters[i].r = static_cast<unsigned char>(clustersCenters[i].val[2]);
    }
}

void communicateWithDriver(int clusters_number, vector<Point3i> &ptInClusters, Mat imgInput, vector<Scalar> &clustersCenters)
{
    int fd = open(DEVICE_PATH, O_RDWR);
    if (fd < 0)
    {
        cerr << "Failed to open the device file" << endl;
        return;
    }

    // Calculate the total size of the buffer needed
    size_t imageSize = imgInput.rows * imgInput.cols * imgInput.channels();
    size_t clustersSize = clusters_number * sizeof(Pixel_driver);
    size_t totalSize = 2 * sizeof(int) + imageSize + clustersSize;

    // Allocate memory for the buffer
    unsigned char* buffer = new unsigned char[totalSize];

    // Copy image rows and columns to the buffer
    memcpy(buffer, &imgInput.rows, sizeof(int));
    memcpy(buffer + sizeof(int), &imgInput.cols, sizeof(int));

    // Copy image data to the buffer
    memcpy(buffer + 2 * sizeof(int), imgInput.data, imageSize);

    // Copy cluster centers to the buffer
    convertClustersCenters(clustersCenters, reinterpret_cast<Pixel_driver*>(buffer + 2 * sizeof(int) + imageSize));

    // Send the buffer to the driver
    ssize_t bytesSent = write(fd, buffer, totalSize);
    if (bytesSent != totalSize)
    {
        cerr << "Failed to send data to driver" << endl;
        delete[] buffer;
        close(fd);
        return;
    }

    // Read data from the driver directly into ptInClusters
    for (int i = 0; i < imgInput.rows * imgInput.cols; ++i)
    {
        Point3i receivedPoint;
        ssize_t bytesRead = read(fd, &receivedPoint, sizeof(Point3i));
        if (bytesRead != sizeof(Point3i))
        {
            cerr << "Failed to read data from driver" << endl;
            delete[] buffer;
            close(fd);
            return;
        }

        // Add the received Point3i to ptInClusters
        ptInClusters.push_back(receivedPoint);
    }

    cout << "Reading " << ptInClusters.size() << " points from the driver" << endl;

    // Free the buffer and close the file
    delete[] buffer;
    close(fd);
}



void adjustClusterCenters(Mat imgInput, int clusters_number, vector<Scalar> &clustersCenters, vector<Point3i> ptInClusters, double &oldCenter, double newCenter)
{
    double diffChange;

    for (int k = 0; k < clusters_number; k++)
    {
        int newBlue = 0;
        int newGreen = 0;
        int newRed = 0;
        int count = 0;

        for (int i = 0; i < ptInClusters.size(); i++)
        {
            Point3i pt = ptInClusters[i];

            if (pt.z == k)
            {
                Scalar pixel = imgInput.at<Vec3b>(pt.y, pt.x);
                newBlue += pixel.val[0];
                newGreen += pixel.val[1];
                newRed += pixel.val[2];
                count++;
            }
        }

        if (count > 0)
        {
            newBlue /= count;
            newGreen /= count;
            newRed /= count;
            Scalar newPixel(newBlue, newGreen, newRed);
            clustersCenters[k] = newPixel;
        }
    }

    newCenter /= clusters_number;
    diffChange = abs(oldCenter - newCenter);
    oldCenter = newCenter;
    cout << "Adjusted cluster centers." << endl;
}

Mat applyFinalClusterToImage(Mat &imgOutput, int clusters_number, vector<Point3i> ptInClusters)
{
    srand(time(NULL));

    vector<Scalar> clusterColors(clusters_number);
    for (int k = 0; k < clusters_number; k++)
    {
        clusterColors[k] = Scalar(rand() % 255, rand() % 255, rand() % 255);
    }

    for (int i = 0; i < ptInClusters.size(); i++)
    {
        Scalar clusterColor = clusterColors[ptInClusters[i].z];
        imgOutput.at<Vec3b>(ptInClusters[i].y, ptInClusters[i].x) = Vec3b(clusterColor.val[0], clusterColor.val[1], clusterColor.val[2]);
    }

    return imgOutput;
}

int main(int argc, const char *argv[])
{
    if (argc < 2)
    {
        cout << "Please provide the input file name as a command-line argument." << endl;
        return -1;
    }

    string inputFileName = argv[1];
    Mat imgInput = imread(inputFileName, IMREAD_COLOR);

    if (imgInput.empty())
    {
        printf("Error opening image.\n");
        return -1;
    }

    int clusters_number = 6;
    vector<Scalar> clustersCenters;
    vector<Point3i> ptInClusters;
    double oldCenter = INFINITY;
    double newCenter = 0;
    double diffChange = oldCenter - newCenter;

    createClustersInfo(imgInput, clusters_number, clustersCenters);
    communicateWithDriver(clusters_number, ptInClusters, imgInput, clustersCenters);
    //for (int i = 0; i < ptInClusters.size(); i++)
    // {
    //    Point3i pt = ptInClusters[i];
    //    cout << "Point " << i << ": (" << pt.x << ", " << pt.y << ", " << pt.z << ")" << endl;
    //}
    adjustClusterCenters(imgInput, clusters_number, clustersCenters, ptInClusters, oldCenter, newCenter);
    Mat imgOutputKNN = imgInput.clone();
    imgOutputKNN = applyFinalClusterToImage(imgOutputKNN, clusters_number, ptInClusters);
    imshow("Segmentation", imgOutputKNN);
    imwrite("../../data/" + to_string(getTickCount()) + "SPEC.jpg", imgOutputKNN);

    cout << "Finished." << endl;

    waitKey(0);
    return 0;
}

