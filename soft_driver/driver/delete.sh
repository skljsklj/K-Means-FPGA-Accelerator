#!/bin/bash

sudo rm /dev/cluster_driver

sudo rmmod cluster_driver

make clean
