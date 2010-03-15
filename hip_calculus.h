/*
 *  hip_calculus.h
 *  Image Recognition
 *
 *  Created by Jean-Louis on 2010-02-01.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef HIP_CALCULUS_H
#define HIP_CALCULUS_H
#include "xy.h"

xy rotatePointXY(xy pointVector, xy rotationVector);
void setRotatedSampleGrid(xy sampleGrid[], xy rotationVector);
int getAngle(xy rotationVector);
void variance( float *arr, int no, float *var, float *avg);
void equalize( float *arr, int no);
int bitcount (unsigned long long n);

#endif