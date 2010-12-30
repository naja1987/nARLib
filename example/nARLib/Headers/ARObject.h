/*
 Copyright (c) 2010, Naja von Schmude
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the organization nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

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
