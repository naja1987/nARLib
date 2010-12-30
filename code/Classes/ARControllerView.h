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
//  ARControllerView.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ARObject.h"
#import "ARView.h"
#import "ARControllerViewAugmentedReality.h"
#import "ARControllerViewRadar.h"

@interface ARControllerView : UIView {

	NSMutableArray						*objectsAndViews;
	double								currentHeading;
	CLLocation							*currentLocation;
	
	ARControllerViewAugmentedReality	*controllerViewAR;
	ARControllerViewRadar				*controllerViewRadar;
	id<ARControllerViewDelegate>		activeControllerView;
	
	BOOL								isRadarActive;
}

/**
 * Adds a new object with a specified augmented reality view and a radar view to the screen.
 * If the object is already present, its view get replaced by the new ones
 * @param object
 * @param viewAR view to present in augmented reality mode
 * @param viewRadar view to present in radar mode
 */
- (void) addObject:(ARObject*) object WithViewAR:(ARView*) viewAR WithViewRadar:(ARView*) viewRadar;

/** 
 * Adds a set of objects with augmented reality views and radar views to the sceen.
 * If the object is already present, its views get replaced by the new ones
 * The order in the mutable arrays must be the same!
 * @param objects
 * @param viewsAR views to present in augmented reality mode
 * @param viewsRadar views to present in radar mode
 */
- (void) addObjects:(NSMutableArray*)objects WithViewsAR:(NSMutableArray*)viewsAR WithViewsRadar:(NSMutableArray*)viewsRadar;

/**
 * Removes the object from the screen
 * @param object
 */
- (void) removeObject:(ARObject*) object;

/**
 * Removes all objects from the screen
 */
- (void) removeAllObjects;

/**
 * Redraws all objects on the screen
 */
- (void) redraw;

/**
 * Activates (or deactivates) the radar view.
 * @param shouldActivate if YES, the radar view gets activated, if NO the normal augmented reality view is shown
 */
- (void) activateRadarView:(BOOL) shouldActivate;

/**
 * Process a location update (by notification)
 * @param notification UserInfo: 
 *           object: NSNumber (double) key: longitude
 *           object: NSNumber (double) key: latitude 
 */
- (void) processLocationUpdate:(NSNotification*) notification;

/**
 * Process a heading update (by notification)
 * @param notification UserInfo: 
 *           object: CLHeading key: heading
 */
- (void) processHeadingUpdate:(NSNotification*) notification;


@end
