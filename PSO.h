//
//  PSO.h
//  Image Recognition
//
//  Created by Jean-Louis on 2010-01-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Particle.h"

#define SWARMSIZE 50



@interface PSO : NSObject {
	@public
	Particle *particleArray[SWARMSIZE];
	Particle *globalBest;
	@private
	Particle *localBests[SWARMSIZE];
	float beta;
}

- (void)initSwarm;
- (void)resetSwarm;
- (void)performIteration:(unsigned char*) data;
- (float)evaluateData:(unsigned char*) data x:(float)x y:(float)y;

@end
