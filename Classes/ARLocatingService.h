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
//  ARLocatingService.h
//  nARLib
//
//  Created by Naja von Schmude on 13.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface ARLocatingService : NSObject <CLLocationManagerDelegate> {
	/// location manager
	CLLocationManager	*locationManager;
	/// current location of device
	CLLocation			*currentLocation;
	/// current heading of device
	CLHeading			*currentHeading;
	
	/// you can simulate this service by setting heading and location by yourself
	BOOL				isSimulatingHeading;
	BOOL				isSimulatingLocation;

}

@property (readonly)	CLLocation		*currentLocation;
@property (readonly)	CLHeading		*currentHeading;
@property (assign)		BOOL			isSimulatingHeading;
@property (assign)		BOOL			isSimulatingLocation;

/**
 * Determines if heading is available on the current device
 * @return YES, if we can receive heading information
 */
+ (BOOL) isHeadingAvailable;

/**
 * Starts the locating services
 */
- (void) startLocating;

/**
 * Stops the locating services
 */
- (void) stopLocating;

/**
 * Changes the device orientation (used for calculating the proper heading) to the new orientation
 * @param orientation new device orientation to use for heading events
 */
- (void) changeToDeviceOrientation:(CLDeviceOrientation) orientation;

/**
 * Simulates a new location and sets it to loc
 * @param loc new location
 */
- (void) simulateLocation:(CLLocation*) loc;

/**
 * Simulates a new heading direction and sets it to heading
 * @param heading new heading (you can't create CLHeading instances by yourself but you can create a "faked" heading class with the same functionality)
 */
- (void) simulateHeading:(CLHeading*) heading;
@end
