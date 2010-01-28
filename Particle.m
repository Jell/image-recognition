//
//  Particle.m
//  Image Recognition
//
//  Created by Jean-Louis on 2010-01-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Particle.h"


@implementation Particle

@synthesize mX, mVx, mY, mVy, mValue;

- (Particle *) initRandom{
	[super init];
	mX = 460.0 * ((float)random()/RAND_MAX);
	mY = 320.0 * ((float)random()/RAND_MAX);
	mVx = 50.0 * ((float)random()/RAND_MAX);
	mVy = 50.0 * ((float)random()/RAND_MAX);
	mValue = 0.0;
	return self;
}
- (void) resetParticle{
	mX = 460.0 * ((float)random()/RAND_MAX);
	mY = 320.0 * ((float)random()/RAND_MAX);
	mVx = 50.0 * ((float)random()/RAND_MAX);
	mVy = 50.0 * ((float)random()/RAND_MAX);
	mValue = 0.0;
}

@end
