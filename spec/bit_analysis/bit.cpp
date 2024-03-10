#include "defines.hpp"

void createClustersInfo(Mat imgInput, int clusters_number, vector<Scalar> &clustersCenters)
{
    int rows = imgInput.rows;
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
    oldCenter = newCenter;
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

SC_MODULE(KMeansSegmentation) {
    sc_in<bool> clk;
    sc_in<bool> reset;
    sc_out<bool> done;
    string imageFileName;

    SC_CTOR(KMeansSegmentation) {
        SC_THREAD(run);
        sensitive << clk.pos();
        async_reset_signal_is(reset, true);
    }

    void run() {
        Mat imgInput = imread(imageFileName, IMREAD_COLOR);

        if (imgInput.empty()) {
            cout << "Error opening image." << endl;
            done.write(true);
            return;
        }

        //---------------------- K-MEANS -----------------------------

        // The number of clusters is the only parameter to choose
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
	imwrite("data/" + to_string(getTickCount()) + "BIT.jpg", imgOutputKNN);

        done.write(true);
    }
};

int sc_main(int argc, char* argv[]) {
    sc_clock clk("clk", 1, SC_NS);
    sc_signal<bool> reset;
    sc_signal<bool> done;

    if (argc < 2) {
        cout << "Image file name not provided." << endl;
        return 1;
    }

    // Get the image file name from the command-line argument
    string imageFileName = argv[1];

    KMeansSegmentation kmeans("kmeans");
    kmeans.clk(clk);
    kmeans.reset(reset);
    kmeans.done(done);
    kmeans.imageFileName = imageFileName;

    reset = true;

    sc_start(1, SC_NS);
    reset = false;
    
    cout<<"Finished."<<endl;
    
    waitKey(0);
    return 0;
}

