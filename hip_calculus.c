/*
 *  hip_calculus.c
 *  Image Recognition
 *
 *  Created by Jean-Louis on 2010-02-01.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "hip_calculus.h"
#include "math.h"
#include "stdlib.h"

xy rotatePointXY(xy pointVector, xy rotationVector){
	xy result = {0, 0};
	
	float ad = rotationVector.x;
	float op = rotationVector.y;
	float hyp = sqrt(ad*ad + op*op);
	if(hyp > 0){
		result.x = (int)((pointVector.x * ad - pointVector.y * op)/hyp);
		result.y = (int)((pointVector.x * op + pointVector.y * ad)/hyp);
	}
	return result;
}

void setRotatedSampleGrid(xy sampleGrid[], xy rotationVector){
	
	for(int i = 0; i<8; i++){
		for(int j = 0; j<8; j++){
			xy pointVector = {-7 + 2*i, -7 + 2*j};
			sampleGrid[i + 8*j] = rotatePointXY(pointVector, rotationVector);
		}
	}
}

int getAngle(xy rotationVector){
	return (int) (180 * atan2((float)rotationVector.y, (float)rotationVector.x) / M_PI);
}