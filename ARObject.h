//
//  ARObject.h
//  nARLib
//
//  Created by Naja von Schmude on 13.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARObjectDelegate.h"

/**
 * Base class for all objects, that we want to present in an augmented reality way.
 **/
@interface ARObject : NSObject {
	
	id<ARObjectDelegate>	delegate;
	/// angle of the object (0° north, 90° east and so on), negative values means invalid value
	double					absoluteAngle;
	/// difference angle from the current heading to the absolute angle
	double					angleToCurrentHeading;

}

@property (assign, nonatomic)	id<ARObjectDelegate>	delegate;
@property (assign)				double					absoluteAngle;
@property (readonly)			double					angleToCurrentHeading;

/**
 * Init's a new ARObject with the given absolute angle.
 * @param angle absolute angle of the ARObject
 * @return new object
 **/
- (id) initWithAngle:(double) angle;

/**
 * Updates the object corresponding to the new heading direction
 * @param heading
 *
 **/
- (void) updateWithNewHeading:(double) heading;

/**
 * Tests for equality of self with other
 * @param other
 * @return
 */
- (BOOL) isEqualToARObject:(ARObject*) other;
@end
