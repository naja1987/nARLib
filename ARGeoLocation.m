//
//  ARGeoLocation.m
//  nARLib
//
//  Created by Naja von Schmude on 13.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARGeoLocation.h"


@interface ARGeoLocation (Private) 

+ (double) vectorLength:(CLLocationCoordinate2D)coord;
+ (double) scalarProductCoord1:(CLLocationCoordinate2D) coord1 Coord2:(CLLocationCoordinate2D) coord2;

@end


@implementation ARGeoLocation

@synthesize	coordinate,
			distanceFromCurrentLocation;

static double maxDistance;

#pragma mark Constructurs

+ (void) initialize {
	maxDistance = 1000;
}

- (id) init {
	if (self = [super init]) {
		coordinate.latitude = -1;
		coordinate.longitude = -1;
		distanceFromCurrentLocation = -1;
	}
	
	return self;
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)coords {
	if (self = [super init]) {
		coordinate = coords;
		distanceFromCurrentLocation = -1;
	}
	
	return self;
}

- (id) initWithLongitude:(CLLocationDegrees)longitude Latitude:(CLLocationDegrees)latitude {
	if (self = [super init]) {
		coordinate.longitude = longitude;
		coordinate.latitude = latitude;
		distanceFromCurrentLocation = -1;
	}
	
	return self;
}


- (void) dealloc {
	[super dealloc];
}

#pragma mark Implementation

- (void) updateWithNewLocation:(CLLocation *)location {
	CLLocation *tmpLoc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	distanceFromCurrentLocation = [location distanceFromLocation:tmpLoc];
	
	absoluteAngle = [ARGeoLocation angleBetweenCoordinate1:coordinate AndCoordinate2:location.coordinate];
	[tmpLoc release];
}

+ (double) angleBetweenCoordinate1:(CLLocationCoordinate2D)coord1 AndCoordinate2:(CLLocationCoordinate2D)coord2 {
	// calculation from http://www.movable-type.co.uk/scripts/latlong.html
	
	double differenceLongitude = coord1.longitude - coord2.longitude;
	
	double y = sin(-differenceLongitude) * cos(coord1.latitude);
	double x = cos(coord2.latitude) * sin(coord1.latitude) - sin(coord2.latitude) * cos(coord1.latitude) * cos(-differenceLongitude);
	double bearing = atan2(y, x);
	
	bearing = fmodf(bearing * 180.0 / M_PI + 360.0, 360.0);
	
	return bearing;
}

+ (double) scalarProductCoord1:(CLLocationCoordinate2D) coord1 Coord2:(CLLocationCoordinate2D) coord2 {
	double longitude = coord1.longitude * coord2.longitude;
	double latitude = coord1.latitude * coord2.latitude;
	return longitude + latitude;
}

+ (double) vectorLength:(CLLocationCoordinate2D)coord {
	return sqrt(coord.latitude * coord.latitude + coord.longitude * coord.longitude);
}

+ (double) maxDistance {
	return maxDistance;
}

+ (void) updateMaxDistanceTo:(double)newMaxDistance {
	maxDistance = newMaxDistance;
}

- (NSUInteger) hash {
	int prime = 31;
	int result = 1;
	
	result = prime * result + coordinate.latitude;
	result = prime * result + coordinate.longitude;
	return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToARGeoLocation:other];
}

- (BOOL)isEqualToARGeoLocation:(ARGeoLocation*)other {
    if (self == other)
        return YES;
	if (coordinate.latitude == other.coordinate.latitude &&
		coordinate.longitude == other.coordinate.longitude) {
		return YES;
	}
	return NO;
}

- (NSString*) description {
	return [NSString stringWithFormat:@"%@ coordinate: (%f, %f) distanceToCurrentLoc: %f", [super description], coordinate.latitude, coordinate.longitude, distanceFromCurrentLocation];
}
@end
