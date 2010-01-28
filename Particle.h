//
//  Particle.h
//  Image Recognition
//
//  Created by Jean-Louis on 2010-01-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Particle : NSObject {
	float mX;
	float mVx;
	float mY;
	float mVy;
	float mValue;
}

@property (nonatomic) float mX, mVx, mY, mVy, mValue;

- (Particle *) initRandom;
- (void) resetParticle;
@end
