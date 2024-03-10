#include "cpu.hpp"


SC_HAS_PROCESS(Cpu);

char** data_string;
int argc;
int read_ddr_cnt = 0;
int write_ddr_cnt = 0;

Cpu::Cpu(sc_core::sc_module_name name,char** strings, int argv) : sc_module(name), offset(sc_core::SC_ZERO_TIME)
{
	if (argv > 1)
	{
		inputFileName = strings[1]; // Set the input file path
	}
	else
	{
		std::cerr << "Error: Missing command-line argument for the input file path." << std::endl;
		// Handle the error appropriately, e.g., set a default file path or terminate the program.
		// Default file path:
		inputFileName = "../data/input_files/katedrala.jpg";
	}
	SC_THREAD(segmentation);
	SC_REPORT_INFO("Cpu", "Constructed.");
	data_string = strings;
	argc = argv;
}
Cpu::~Cpu()
{
    	SC_REPORT_INFO("Cpu", "Destroyed.");
}

void Cpu::createClustersInfo(Mat imgInput, vector<Scalar> &clustersCenters)
{
    int rows = imgInput.rows;
    int cols = imgInput.cols;

    for (int k = 0; k < CLUSTERS_NUMBER; k++)
    {
        int centerRow = k * rows / CLUSTERS_NUMBER;
        int centerCol = k * cols / CLUSTERS_NUMBER;

        Scalar centerPixel = imgInput.at<Vec3b>(centerRow, centerCol);
        Scalar centerK(centerPixel.val[0], centerPixel.val[1], centerPixel.val[2]);
        clustersCenters.push_back(centerK);
    }
}


void Cpu::adjustClusterCenters(Mat imgInput, vector<Scalar> &clustersCenters, vector<Point3i> ptInClusters, double &oldCenter, double newCenter)
{
    double diffChange;

    for (int k = 0; k < CLUSTERS_NUMBER; k++)
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
    newCenter /= CLUSTERS_NUMBER;
    diffChange = abs(oldCenter - newCenter);
    oldCenter = newCenter;
}


Mat Cpu::applyFinalClusterToImage(Mat &imgOutput, vector<Point3i> ptInClusters)
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
    while (clusterColors.size() < CLUSTERS_NUMBER) {
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

void Cpu::segmentation()
{

	//sc_time start_time = sc_time_stamp();

    	Mat imgOrig = imread(inputFileName, IMREAD_COLOR);

    	if (imgOrig.empty())
    	{
        	cout << "Error opening image.\n";
        	return;
    	}

    	int img_rows = imgOrig.rows;
    	int img_cols = imgOrig.cols;

    	// Split the image into RGB channels
    	Mat bgr_img[3];
    	Mat img;
    	
    	imgOrig.convertTo(img, CV_8UC3);
	normalize(img, img, 0, 255, NORM_MINMAX);   	
    	split(img, bgr_img);
    	
    	// The number of clusters is the only parameter to choose
    	vector<Scalar> clustersCenters;
    	vector<Point3i> ptInClusters;
    	
    	double oldCenter = 443;
    	double newCenter = 0;
    	double diffChange = oldCenter - newCenter;

    	// Create clusters information on the whole image
    	createClustersInfo(img, clustersCenters);
    	   		
    	unsigned char* clustersCenters_c = new unsigned char [CLUSTERS_NUMBER*3];
    	clustersCenters_c = scalarArray_to_UcharArray(clustersCenters);
    	  
    	bool done = 0;
    	int ready = 1;
    	bool need_start = 0;
    	bool new_ch = 1;
    	 	      
    	write_hard(ADDR_COLS, img_cols);
    	write_hard(ADDR_ROWS, img_rows);
    	    	
    	while(!done)
    	{
    	
    		if(new_ch)
    		{
    			for(int i = 0; i < CLUSTERS_NUMBER*3; i++)
    				write_bram(3*img_rows*img_cols + i, clustersCenters_c[i]);
    							    			   			
    			delete[] clustersCenters_c;
    			
    			new_ch = 0;
    		}
    	
    		if(ready)
    		{
    			// Store the whole RGB image in a 1D array
		    	unsigned char *img_arr = new unsigned char[3 * img_rows * img_cols];
		    	int img_arr_index = 0;
		    	for (int r = 0; r < img_rows; r++)
		    	{
				for (int c = 0; c < img_cols; c++)
				{
			    		for (int channel = 0; channel < 3; channel++)
			    		{
						img_arr[img_arr_index++] = bgr_img[channel].at<unsigned char>(r, c);						
			    		}
				}
		    	}
		    			    	
		    	for(int i = 0; i < 3*img_rows*img_cols; i++)
				write_bram(i, img_arr[i]);
									
    			delete[] img_arr;
    			
    			need_start = 1;		
    		}
    		
    		if(need_start)
    		{
			write_hard(ADDR_START,1);
			need_start = 0;
    		}
    		
    		while(ready)
    		{
	    		ready = read_hard(ADDR_READY); //U OVOM TRENUTKU READY UZIMA 0
	    		cout<<"IP is about to start"<<endl;
			if (!ready)
				write_hard(ADDR_START,0); //OVOG TRENUTKA SE STARTUJE IP , IZLAZI SE IZ PETLJE
    		}
    		
    		ready = read_hard(ADDR_READY); //ZAVRSIO SE IP
    		
    		cout << "Processing done" << endl;
    		
    		unsigned char* ptInClusters_c = new unsigned char [img_rows*img_cols*3];
    		    		
    		if(ready)
    		{	
    			read_bram(0, ptInClusters_c, img_rows*img_cols*3);     							
		  			
			ptInClusters = UcharArray_to_pointArray(ptInClusters_c, img_rows*img_cols*3);
			    			
			new_ch = 0;
			ready = 0;
			need_start = 0;
			done = 1;
		
		}
    	}  				    	
    	cout <<"CPU processing" <<endl;
    	   		
	adjustClusterCenters(img, clustersCenters, ptInClusters, oldCenter, newCenter);
	Mat imgOutputKNN = img.clone();
   	imgOutputKNN = applyFinalClusterToImage(imgOutputKNN, ptInClusters);
   	
   	imshow("Segmentation", imgOutputKNN);
   	imwrite("data/" + to_string(getTickCount()) + "VP.jpg", imgOutputKNN);
   	  	
	cout<<"Finished."<<endl;
	
	cout << "Simulacija se izvrsi za : " << offset << endl;


	waitKey(0);
}     
    
void Cpu::write_bram(sc_uint<64> addr, unsigned char val)
{
	pl_t pl;	
	offset += sc_core::sc_time(DELAY , sc_core::SC_NS);	
	unsigned char buf;
	read_ddr_cnt++;
	buf = val;
	pl.set_address(VP_ADDR_BRAM_L + addr);
	pl.set_data_length(1); 
	pl.set_data_ptr(&buf);
	pl.set_command( tlm::TLM_WRITE_COMMAND );
	pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
	interconnect_socket->b_transport(pl, offset);
}

void Cpu::read_bram(sc_uint<64> addr, unsigned char *all_data, int length)
{
    	offset += sc_core::sc_time((9 + 1) * DELAY, sc_core::SC_NS);

    	pl_t pl;
    	unsigned char buf;
    	int n = 0;

    	for (int i = 0; i < length; i++)
    	{
        	write_ddr_cnt += 4;
        	pl.set_address(VP_ADDR_BRAM_L + addr + i);
        	pl.set_data_length(1);
        	pl.set_data_ptr(&buf);
        	pl.set_command(tlm::TLM_READ_COMMAND);
        	pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
        	interconnect_socket->b_transport(pl, offset);

        	all_data[n] = buf;
        	n++;
    	}
}


int Cpu::read_hard(sc_uint<64> addr)
{
    	pl_t pl;
    	unsigned char buf[8];
    	pl.set_address(VP_ADDR_IP_HARD_L + addr);
    	pl.set_data_length(1);
    	pl.set_data_ptr(buf);
    	pl.set_command(tlm::TLM_READ_COMMAND);
    	pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    	sc_core::sc_time offset = sc_core::SC_ZERO_TIME;
    	interconnect_socket->b_transport(pl,offset);
    	return toInt(buf);
}

void Cpu::write_hard(sc_uint<64> addr,int val)
{
    	pl_t pl;
    	unsigned char buf[4];
    	toUchar(buf,val); 	
    	pl.set_address(VP_ADDR_IP_HARD_L + addr);
    	pl.set_data_length(1);
    	pl.set_data_ptr(buf);
    	pl.set_command(tlm::TLM_WRITE_COMMAND);
    	pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    	interconnect_socket->b_transport(pl,offset);
}


