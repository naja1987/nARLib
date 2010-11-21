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

+ (BOOL) isHeadingAvailable {
	return [CLLocationManager headingAvailable];
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
	
	[currentHeading release];
	currentHeading = nil;
	[currentLocation release];
	currentLocation = nil;
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
		currentLocation = [newLocation retain];
	}
	
	// better accuracy then needed or of former position, so just mark as new current position
	else if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy || newLocation.horizontalAccuracy <= currentLocation.horizontalAccuracy) {
		if (currentLocation != newLocation) {
			[currentLocation release];
			currentLocation = [newLocation retain];
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
	
	if (currentHeading == nil) {
		currentHeading = [newHeading retain];
	}
	else if (currentHeading != newHeading) {
		[currentHeading release];
		currentHeading = [newHeading retain];
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
