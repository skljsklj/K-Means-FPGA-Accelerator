#include <iostream>
#include <ctime>
#include <cmath>
#include "opencv2/highgui/highgui.hpp"
#include <fstream>

using namespace cv;
using namespace std;

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
}

double computeColorDistance(Scalar pixel, Scalar clusterPixel)
{
    double diffBlue = pixel.val[0] - clusterPixel[0];
    double diffGreen = pixel.val[1] - clusterPixel[1];
    double diffRed = pixel.val[2] - clusterPixel[2];
    double distance = sqrt(pow(diffBlue, 2) + pow(diffGreen, 2) + pow(diffRed, 2));
    return distance;
}

void findAssociatedCluster(Mat imgInput, int clusters_number, vector<Scalar> clustersCenters, vector<Point3i> &ptInClusters)
{
    for (int r = 0; r < imgInput.rows; r++)
    {
        for (int c = 0; c < imgInput.cols; c++)
        {
            double minDistance = INFINITY;
            int closestClusterIndex = 0;
            Scalar pixel = imgInput.at<Vec3b>(r, c);

            for (int k = 0; k < clusters_number; k++)
            {
                Scalar clusterCenter = clustersCenters[k];
                double distance = computeColorDistance(pixel, clusterCenter);
                
                if (distance < minDistance)
                {
                    minDistance = distance;
                    closestClusterIndex = k;
                }
            }
            Point3i pixelPoint(c, r, closestClusterIndex);
            ptInClusters.push_back(pixelPoint);           
        }
    }
}

void adjustClusterCenters(Mat imgInput, int clusters_number, vector<Scalar> &clustersCenters, vector<Point3i> ptInClusters, double &oldCenter, double newCenter)
{
    double diffChange;

    for (int k = 0; k < clusters_number; k++)
    {
        double newBlue = 0;
        double newGreen = 0;
        double newRed = 0;
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

        newBlue /= count;
        newGreen /= count;
        newRed /= count;
        Scalar newPixel(newBlue, newGreen, newRed);
        clustersCenters[k] = newPixel;
    }

    newCenter /= clusters_number;
    diffChange = abs(oldCenter - newCenter);
    //cout << "diffChange is: " << diffChange << endl;
    oldCenter = newCenter;
}

Mat applyFinalClusterToImage(Mat &imgOutput, int clusters_number, vector<Point3i> ptInClusters)
{
    vector<Scalar> clusterColors = {
        Scalar(255, 0, 0),   // Crvena
        Scalar(0, 255, 0),   // Zelena
        Scalar(0, 0, 255),   // Plava
        Scalar(255, 255, 0), // Žuta
        Scalar(255, 0, 255), // Magenta
        Scalar(0, 255, 255)  // Cijan
    };

    // Ako ima manje klastera od 6, generirajte preostale boje nasumično
    while (clusterColors.size() < clusters_number) {
        clusterColors.push_back(Scalar(rand() % 255, rand() % 255, rand() % 255));
    }

    for (int i = 0; i < ptInClusters.size(); i++)
    {
        Scalar clusterColor;
        if (ptInClusters[i].z < clusterColors.size()) {
            clusterColor = clusterColors[ptInClusters[i].z];
        } else {
            // Ako je broj klastera veći od broja fiksnih boja, koristite crnu boju
            clusterColor = Scalar(0, 0, 0);
        }
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
    findAssociatedCluster(imgInput, clusters_number, clustersCenters, ptInClusters);		
    adjustClusterCenters(imgInput, clusters_number, clustersCenters, ptInClusters, oldCenter, newCenter);
    Mat imgOutputKNN = imgInput.clone();
    imgOutputKNN = applyFinalClusterToImage(imgOutputKNN, clusters_number, ptInClusters);
    imshow("Segmentation", imgOutputKNN);
    imwrite("data/" + to_string(getTickCount()) + "SPEC.jpg", imgOutputKNN);
    
    cout<<"Finished."<<endl;

    waitKey(0);
    return 0;
}

