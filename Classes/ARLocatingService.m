//
//  ARLocatingService.m
//  nARLib
//
//  Created by Naja von Schmude on 13.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARLocatingService.h"
#import "ARNotificationCenter.h"

@implementation ARLocatingService

@synthesize currentLocation,
			currentHeading,
			isSimulatingHeading,
			isSimulatingLocation;

#pragma mark Constructors

- (id) init {
	if (self = [super init]) {
		currentHeading = nil;
		currentLocation = nil;
		
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		locationManager.distanceFilter = 10;
		
		// default position is landscape with home button right
		locationManager.headingOrientation = CLDeviceOrientationLandscapeLeft;
		locationManager.headingFilter = kCLHeadingFilterNone;
		
		isSimulatingHeading = NO;
		isSimulatingLocation = NO;
	}
	
	return self;
}

- (void) dealloc {
	[self stopLocating];
	locationManager.delegate = nil;
	
	[locationManager release];
	[currentHeading release];
	[currentLocation release];
	
	[super dealloc];
}

#pragma mark Start/ Stop

- (void) startLocating {
	[locationManager startUpdatingLocation];
	
	if ([CLLocationManager headingAvailable]) {
		[locationManager startUpdatingHeading];
	}
	else {
		NSLog(@"Heading failure");
		// error
	}

}

- (void) stopLocating {
	[locationManager stopUpdatingLocation];
	[locationManager stopUpdatingHeading];
}

#pragma mark CLLocationManagerDelegate protocol

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (isSimulatingLocation) {
		return;
	}
	
	
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
    if (abs(howRecent) > 15.0) { // location older then 15 sec
		return;
    }
	
	if(newLocation.horizontalAccuracy < 0.0) { // invalid value
		return;
	}
	
	BOOL useLocation = YES;
	
	if (currentLocation == nil) { // take always the first location
		currentLocation = [newLocation copy];
	}
	
	// better accuracy then needed or of former position, so just mark as new current position
	else if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy || newLocation.horizontalAccuracy <= currentLocation.horizontalAccuracy) {
		if (currentLocation != newLocation) {
			[currentLocation release];
			currentLocation = [newLocation copy];
		}
	}
	else {
		useLocation = NO;
	}
	
	
	// generate notification with new location
	if (useLocation) {		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  // value, key
							  [NSNumber numberWithDouble:(currentLocation.coordinate.latitude)], @"latitude",
							  [NSNumber numberWithDouble:(currentLocation.coordinate.longitude)], @"longitude",
							  nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kLocationChangeNotification object:self userInfo:dict];
	}
	
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	if (isSimulatingHeading) {
		return;
	}
	
	NSDate* eventDate = newHeading.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
    if (abs(howRecent) > 15.0) { // location older then 15 sec
		return;
    }
	
	if (newHeading.headingAccuracy < 0.0) { // invalid value
		return;
	}
	
	if (currentHeading != newHeading) {
		[currentHeading release];
		currentHeading = [newHeading copy];
	}
	
	// generate notification with new heading
	NSDictionary *dict = [NSDictionary dictionaryWithObject:currentHeading forKey:@"heading"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kHeadingChangeNotification object:self userInfo:dict]; 

}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	// generate notification with error
	NSDictionary *dict = [NSDictionary dictionaryWithObject:error forKey:@"error"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kCoreLocationErrorNotification object:self userInfo:dict];
}

- (BOOL) locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

#pragma mark Implementation

- (void)changeToDeviceOrientation:(CLDeviceOrientation)orientation {
	locationManager.headingOrientation = orientation;
}

- (void) simulateHeading:(CLHeading *)heading {
	if (currentHeading != heading) {
		[currentHeading release];
		currentHeading = [heading retain];
	}
	
	// generate notification with new heading
	NSDictionary *dict = [NSDictionary dictionaryWithObject:currentHeading forKey:@"heading"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kHeadingChangeNotification object:self userInfo:dict]; 
}

- (void)simulateLocation:(CLLocation *)loc {
	if (currentLocation != loc) {
		[currentLocation release];
		currentLocation = [loc retain];
	}
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  // value, key
						  [NSNumber numberWithDouble:(currentLocation.coordinate.latitude)], @"latitude",
						  [NSNumber numberWithDouble:(currentLocation.coordinate.longitude)], @"longitude",
						  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kLocationChangeNotification object:self userInfo:dict];
}

@end
