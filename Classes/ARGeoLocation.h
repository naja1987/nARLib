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
