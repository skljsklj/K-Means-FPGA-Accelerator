#include <linux/module.h>
#include <linux/fs.h>
#include <linux/uaccess.h>

//#define ROWS 512
//#define COLS 512
#define MAX_ROWS_COLS 512*512
#define CLUSTERS_NUMBER 6
#define MAX_IMAGE_DATA_SIZE 1024 * 1024
#define DEVICE_NAME "cluster_driver"
#define BUF_LEN 200000

int major_num;
char msg[BUF_LEN];
char *msg_ptr;
unsigned char *dummyImage;
int ROWS = 0,COLS=0;
typedef struct {
    unsigned char b;
    unsigned char g;
    unsigned char r;
} Pixel;

typedef struct {
    int x;
    int y;
    int z;
} Point3i;

Pixel *clustersCenters;
Point3i *ptInClusters;
Pixel startClusters[6];

void findAssociatedCluster(Pixel *clustersCenters, Point3i *ptInClusters, unsigned char* imageData)
{
	for (int r = 0; r < ROWS; r++)
    	{
        	for (int c = 0; c < COLS; c++)
        	{
            		int minDistance = INT_MAX;
            		int closestClusterIndex = 0;

            		Pixel pixel;
            		int index = ((r * COLS) + c) * 3;
            		pixel.b = imageData[index];
            		pixel.g = imageData[index + 1];
            		pixel.r = imageData[index + 2];

            	for (int k = 0; k < CLUSTERS_NUMBER; k++)
            	{
                	Pixel clusterCenter = clustersCenters[k];

		        int diffBlue = pixel.b - clusterCenter.b;
		        int diffGreen = pixel.g - clusterCenter.g;
		        int diffRed = pixel.r - clusterCenter.r;
		        int distance = abs(diffBlue) + abs(diffGreen) + abs(diffRed);

                	if (distance < minDistance)
		        {
		            minDistance = distance;
		            closestClusterIndex = k;
		        }
            	}

		    ptInClusters[(r * COLS) + c].x = c;
		    ptInClusters[(r * COLS) + c].y = r;
		    ptInClusters[(r * COLS) + c].z = closestClusterIndex;
        	}
        
	}
	
	for(int i = 0; i < ROWS*COLS; i++)
	{
       		printk(KERN_INFO "Point %d: (%d, %d, %d)\n", i, ptInClusters[i].x, ptInClusters[i].y, ptInClusters[i].z);
    	}
    	
    	printk(KERN_INFO "Found associated clusters.\n");
}

int cluster_driver_open(struct inode *inode, struct file *file)
{
	return 0;
}

int cluster_driver_release(struct inode *inode, struct file *file)
{
	return 0;
}

ssize_t cluster_driver_write(struct file *file, const char __user *user_buf, size_t count, loff_t *ppos)
{
    // Define variables for image rows and columns
    int img_rows, img_cols;

    // Read the image rows and columns from the user buffer
    if (copy_from_user(&img_rows, user_buf, sizeof(int)))
    {
        printk(KERN_ALERT "Failed to copy image rows from user space\n");
        return -EFAULT;
    }

    if (copy_from_user(&img_cols, user_buf + sizeof(int), sizeof(int)))
    {
        printk(KERN_ALERT "Failed to copy image columns from user space\n");
        return -EFAULT;
    }
    
    ROWS = img_rows;
    COLS = img_cols;

    // Calculate the size of the image data
    size_t imageBytes = img_rows * img_cols * 3;
    // Calculate the size of the cluster centers
    size_t clustersBytes = CLUSTERS_NUMBER * sizeof(Pixel);

    // Check if the user buffer contains both image data and cluster centers
    if (count < 2 * sizeof(int) + imageBytes + clustersBytes)
    {
        printk(KERN_ALERT "Insufficient data in user buffer\n");
        return -EFAULT;
    }

    // Copy image data from user buffer
    if (copy_from_user(dummyImage, user_buf + 2 * sizeof(int), imageBytes))
    {
        printk(KERN_ALERT "Failed to copy image data from user space\n");
        return -EFAULT;
    }

    // Copy cluster centers from user buffer
    if (copy_from_user(startClusters, user_buf + 2 * sizeof(int) + imageBytes, clustersBytes))
    {
        printk(KERN_ALERT "Failed to copy clustersCenters data from user space\n");
        return -EFAULT;
    }

    // Call findAssociatedCluster to populate ptInClusters
    findAssociatedCluster(startClusters, ptInClusters, dummyImage);

    return count;
}



ssize_t cluster_driver_read(struct file *file, char __user *user_buf, size_t count, loff_t *ppos)
{
    	printk(KERN_INFO "Reading from cluster_driver\n");

    	size_t bytes_to_read;
    	size_t remaining_bytes;

    	bytes_to_read = count;
    	remaining_bytes = (ROWS * COLS * sizeof(Point3i)) - *ppos;

    	printk(KERN_INFO "ROWS: %d, COLS: %d, sizeof(Point3i): %zu, *ppos: %lld\n", ROWS, COLS, sizeof(Point3i), *ppos);
    	printk(KERN_INFO "Remaining bytes to read: %zu\n", remaining_bytes);

    	if (remaining_bytes == 0)
    	{
        	printk(KERN_INFO "No more data to read (EOF)\n");
        	return 0; // EOF
    	}

    	if (bytes_to_read > remaining_bytes)
        	bytes_to_read = remaining_bytes;

    	printk(KERN_INFO "Copying %zu bytes to user space\n", bytes_to_read);

    	if (copy_to_user(user_buf, ptInClusters + (*ppos / sizeof(Point3i)), bytes_to_read))
    	{
        	printk(KERN_ALERT "Failed to copy ptInClusters to user space\n");
       		return -EFAULT;
    	}

    	*ppos += bytes_to_read;

    	return bytes_to_read;
}

static const struct file_operations cluster_driver_fops = {
    	.owner = THIS_MODULE,
    	.open = cluster_driver_open,
    	.release = cluster_driver_release,
    	.read = cluster_driver_read,
    	.write = cluster_driver_write,
};

int init_module(void)
{
    	major_num = register_chrdev(0, DEVICE_NAME, &cluster_driver_fops);

    	if (major_num < 0)
    	{
        	printk(KERN_ALERT "Failed to register a major number\n");
        	return major_num;
    	}
	ROWS = kmalloc(sizeof(int),GFP_KERNEL);
	COLS = kmalloc(sizeof(int),GFP_KERNEL);
	printk(KERN_INFO "ROWS: %d", ROWS);
	//printk("COLS:\n %d" COLS);
    	clustersCenters = kmalloc(CLUSTERS_NUMBER * 3 * sizeof(int), GFP_KERNEL);
    	if (!clustersCenters)
    	{
        	printk(KERN_ALERT "Failed to allocate memory for clustersCenters\n");
        	unregister_chrdev(major_num, DEVICE_NAME);
        	return -ENOMEM;
    	}

    	ptInClusters = kmalloc(MAX_ROWS_COLS * 3 * sizeof(int), GFP_KERNEL);
    	
    	if (!ptInClusters)
    	{
        	printk(KERN_ALERT "Failed to allocate memory for ptInClusters\n");
        	kfree(clustersCenters);
        	unregister_chrdev(major_num, DEVICE_NAME);
        	return -ENOMEM;
    	}

    	dummyImage = kmalloc(MAX_ROWS_COLS * 3 * sizeof(int), GFP_KERNEL);
    	if (!dummyImage)
    	{
        	printk(KERN_ALERT "Failed to allocate memory for dummyImage\n");
        	kfree(ptInClusters);
        	kfree(clustersCenters);
        	unregister_chrdev(major_num, DEVICE_NAME);
        	return -ENOMEM;
    	}

    	printk(KERN_INFO "Registered correctly with major number %d\n", major_num);

    	return 0;
}

void cleanup_module(void)
{
    	if (dummyImage)
        	kfree(dummyImage);
    	if (ptInClusters)
        	kfree(ptInClusters);
    	if (clustersCenters)
        	kfree(clustersCenters);
    	unregister_chrdev(major_num, DEVICE_NAME);
    	printk(KERN_INFO "Unregistered %s device\n", DEVICE_NAME);
}

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("Cluster driver");
