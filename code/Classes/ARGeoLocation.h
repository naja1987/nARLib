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
//  ARGeoLocation.h
//  nARLib
//
//  Created by Naja von Schmude on 13.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "ARObject.h"


/**
 * Base class for all objects representing a geo-location.
 *
 **/
@interface ARGeoLocation : ARObject {

	/// coordinate of the object
	CLLocationCoordinate2D	coordinate;
	/// distance to this object from the current location (negative values are invalid)
	CLLocationDistance		distanceFromCurrentLocation;
	
}

@property (readonly) CLLocationCoordinate2D		coordinate;
@property (readonly) CLLocationDistance			distanceFromCurrentLocation;

/**
 * Init's a new geo-location object
 * @param coords coordinates of the new object
 * @return new object
 **/
- (id) initWithCoordinate:(CLLocationCoordinate2D) coords;

/**
 * Init's a new geo-location object
 * @param longitude
 * @param latitude
 * @return the new object
 **/
- (id) initWithLongitude:(CLLocationDegrees) longitude Latitude:(CLLocationDegrees) latitude;

/**
 * Update this geo-locations relative values corresponding to the new location
 * @param location new location (mostly the GPS coordinate from the CLLocationManager-events)
 */
- (void) updateWithNewLocation:(CLLocation*) location;

/**
 * Tests for equality of self with other
 * @param other
 * @return
 */
- (BOOL)isEqualToARGeoLocation:(ARGeoLocation*)other;


/**
 * Calculates the difference angle between the two given coordinates. 
 * This is the angle in the geographic system when you are in coord2 and looking directly to coord1.
 * @param coord1
 * @param coord2
 * @return resulting angle
 */
+ (double) angleBetweenCoordinate1:(CLLocationCoordinate2D) coord1 AndCoordinate2:(CLLocationCoordinate2D) coord2;

/**
 * Returns the maximum distance, in which locations are displayed
 * @return maximum distance
 */
+ (double) maxDistance;

/**
 * Updates the maximum distance.
 * @param newMaxDistance new maximum distance
 */
+ (void) updateMaxDistanceTo:(double) newMaxDistance;
@end
