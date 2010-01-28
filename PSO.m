//
//  PSO.m
//  Image Recognition
//
//  Created by Jean-Louis on 2010-01-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PSO.h"


@implementation PSO

- (void)initSwarm{
	beta = 1.0;
	globalBest = [[Particle alloc] init];
	globalBest.mValue = 0;
	for(int i = 0; i < SWARMSIZE; i++){
		//Initialize Particles
		particleArray[i] = [[Particle alloc] initRandom];
		particleArray[i].mValue = 0;
		
		//Set local best to initial values
		localBests[i] = [[Particle alloc] init];
		localBests[i].mX = particleArray[i].mX;
		localBests[i].mVx = particleArray[i].mVx;
		localBests[i].mY = particleArray[i].mY;
		localBests[i].mVy = particleArray[i].mVy;
		localBests[i].mValue = particleArray[i].mValue;
		
		if(particleArray[i].mValue > globalBest.mValue){
			globalBest.mX = particleArray[i].mX;
			globalBest.mVx = particleArray[i].mVx;
			globalBest.mY = particleArray[i].mY;
			globalBest.mVy = particleArray[i].mVy;
			globalBest.mValue = particleArray[i].mValue;
			
		}
	}
}

- (void)performIteration:(unsigned char*) data{
	beta = 1.0;
	[self resetSwarm];
	for(int k = 0; k<100; k++){
	beta -= 0.01;
	
	for(int i = 0; i < SWARMSIZE; i++){
		float r1, r2, r3;
		r1 = (float)random()/RAND_MAX;
		r2 = (float)random()/RAND_MAX;
		r3 = (float)random()/RAND_MAX; 
		//Update Speeds
		if(r3 < 0.05){
			[particleArray[i] resetParticle];
			[localBests[i] resetParticle];
		}else{
			particleArray[i].mVx = beta * particleArray[i].mVx +
									1.0 * r1 * (localBests[i].mX - particleArray[i].mX) +
									1.0 * r2 * (globalBest.mX - particleArray[i].mX);
		
			particleArray[i].mVy = beta * particleArray[i].mVy +
									1.0 * r1 * (localBests[i].mY - particleArray[i].mY) +
									1.0 * r2 * (globalBest.mY - particleArray[i].mY);
		}
		
		//Update Positions
		particleArray[i].mX = particleArray[i].mX + particleArray[i].mVx/10;
		particleArray[i].mY = particleArray[i].mY + particleArray[i].mVy/10;
		
		//Update Best Values
		particleArray[i].mValue = [self evaluateData:data x:particleArray[i].mX y:particleArray[i].mY];
		
		if(particleArray[i].mValue>localBests[i].mValue){
			localBests[i].mX = particleArray[i].mX;
			localBests[i].mVx = particleArray[i].mVx;
			localBests[i].mY = particleArray[i].mY;
			localBests[i].mVy = particleArray[i].mVy;
			localBests[i].mValue = particleArray[i].mValue;
		}
		
		localBests[i].mValue *= 0.9;
		
		if(particleArray[i].mValue>globalBest.mValue){
			globalBest.mX = particleArray[i].mX;
			globalBest.mVx = particleArray[i].mVx;
			globalBest.mY = particleArray[i].mY;
			globalBest.mVy = particleArray[i].mVy;
			globalBest.mValue = particleArray[i].mValue;
		}
	}

	}
	globalBest.mValue *= 0.9;
}

- (float)evaluateData:(unsigned char*) data x:(float)x y:(float)y{
	int offset = 4*((int) x) + 1840 * ((int) y);
	float result = 0;
	if((offset < 320*1840 - 4 - 10*4 - 10*1840) && (offset > 0)){
		for(int k = 0; k<10; k++){
			for(int l = 0; l<10; l++){
				result +=  (float) (data[offset + 1 + 4*k + 1840*l]) +
						   (float) (data[offset + 2 + 4*k + 1840*l]) + 
						   (float) (data[offset + 3 + 4*k + 1840*l]);
			}
		}

	}
	return result;
}

- (void) resetSwarm{
	for(int i = 0; i < SWARMSIZE; i++){
		[particleArray[i] resetParticle];
		[localBests[i] resetParticle];
		globalBest.mValue = 0;
	}
}
		
@end
