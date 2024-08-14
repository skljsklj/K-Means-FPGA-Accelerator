#!/bin/bash

make

sudo insmod cluster_driver.ko

sudo mknod /dev/cluster_driver c 240 0

sudo chmod o+rw /dev/cluster_driver

echo "Script executed successfully."
