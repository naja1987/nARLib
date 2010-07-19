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
			currentHeading;

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
		currentLocation = [newLocation copy];
	}
	else {
		useLocation = NO;
	}
	
	
	// generate notification with new location
	if (useLocation) {
		NSLog(@"New location: %@", [currentLocation description]);
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  // value, key
							  [NSNumber numberWithDouble:(currentLocation.coordinate.latitude)], @"latitude",
							  [NSNumber numberWithDouble:(currentLocation.coordinate.longitude)], @"longitude",
							  nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kLocationChangeNotification object:self userInfo:dict];
	}
	
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	NSLog(@"New heading: %@", [currentHeading description]);
	NSDate* eventDate = newHeading.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
    if (abs(howRecent) > 15.0) { // location older then 15 sec
		return;
    }
	
	if (newHeading.headingAccuracy < 0.0) { // invalid value
		return;
	}
	
	currentHeading = [newHeading copy];
	NSLog(@"New heading: %@", [currentHeading description]);
	
	// generate notification with new heading
	NSDictionary *dict = [NSDictionary dictionaryWithObject:currentHeading forKey:@"heading"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kHeadingChangeNotification object:self userInfo:dict]; 

}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	CLError err = [error code];
	switch (err) {
		case kCLErrorLocationUnknown:
		
			break;
		case kCLErrorHeadingFailure:
		
			break;
		case kCLErrorDenied:
			// user won't let me localize. so stop it!
		
			[self stopLocating];
			break;
		case kCLErrorNetwork:
			
			break;
		default:
			break;
	}	
}

- (BOOL) locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

#pragma mark Implementation

- (void)changeToDeviceOrientation:(CLDeviceOrientation)orientation {
	locationManager.headingOrientation = orientation;
}

@end
