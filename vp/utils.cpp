#include "utils.hpp"
#include <iostream>


int toInt(unsigned char *buf)
{
    int val = 0;
    val += ((int)buf[0]) << 24;
    val += ((int)buf[1]) << 16;
    val += ((int)buf[2]) << 8;
    val += ((int)buf[3]);
    return val;
}

void toUchar(unsigned char *buf,int val)
{
    buf[0] = (char) (val >> 24);
    buf[1] = (char) (val >> 16);
    buf[2] = (char) (val >> 8);
    buf[3] = (char) (val);
}

unsigned char* scalarArray_to_UcharArray(const vector<Scalar>& scalarArray) {
    int arraySize = scalarArray.size() * 3;
    unsigned char* charArray = new unsigned char[arraySize];

    for (int i = 0; i < scalarArray.size(); ++i) {
        charArray[i * 3] = static_cast<unsigned char>(scalarArray[i][0]);  // Blue
        charArray[i * 3 + 1] = static_cast<unsigned char>(scalarArray[i][1]);  // Green
        charArray[i * 3 + 2] = static_cast<unsigned char>(scalarArray[i][2]);  // Red
    }

    return charArray;
}

std::vector<Point3i> UcharArray_to_pointArray(unsigned char* charArray, int size) {
    std::vector<Point3i> pointArray;

    for (int i = 0; i < size; i += 3) {
        int x = static_cast<int>(charArray[i]);
        int y = static_cast<int>(charArray[i + 1]);
        int z = static_cast<int>(charArray[i + 2]);

        pointArray.emplace_back(Point3i{x, y, z});
    }

    return pointArray;
}

