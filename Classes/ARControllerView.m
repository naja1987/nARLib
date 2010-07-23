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
//  ARControllerView.m
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARControllerView.h"
#import "ARNotificationCenter.h"
#import "ARObjectViewTriple.h"
#import "ARGeoLocation.h"
#import "Utils.h"

@interface ARControllerView (Private) 

- (BOOL) knowsARObject:(ARObject*) object;
- (ARObjectViewTriple*) getTripleOfObject:(ARObject*) object;

@end


@implementation ARControllerView

@synthesize objectsAndViews;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		objectsAndViews = [[NSMutableArray alloc] init];
		
		controllerViewAR = [[ARControllerViewAugmentedReality alloc] initWithFrame:self.frame];
		controllerViewRadar = [[ARControllerViewRadar alloc] initWithFrame:self.frame];
		
		activeControllerView = controllerViewAR;
		isRadarActive = NO;
		
		[self addSubview:controllerViewRadar];
		[self addSubview:controllerViewAR];
		controllerViewRadar.hidden = YES;
		controllerViewRadar.alpha = 0.0;
		
		// register for notifications
		[[ARNotificationCenter sharedNotificationCenter] addObserverForHeadingChanges:self selector:@selector(processHeadingUpdate:)];
		[[ARNotificationCenter sharedNotificationCenter] addObserverForLocationChanges:self selector:@selector(processLocationUpdate:)];
		
		self.autoresizingMask =UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
		controllerViewAR.contentMode = UIViewContentModeCenter;
		controllerViewRadar.contentMode = UIViewContentModeCenter;
		controllerViewAR.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
		controllerViewRadar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


- (void)dealloc {
	[[ARNotificationCenter sharedNotificationCenter] removeObserver:self];
	
	[objectsAndViews removeAllObjects];
	[objectsAndViews release];
	
	[controllerViewAR removeFromSuperview];
	[controllerViewRadar removeFromSuperview];
	
	[controllerViewAR release];
	[controllerViewRadar release];
    [super dealloc];
}

#pragma mark Object Handling

- (void) addObject:(ARObject *)object WithViewAR:(ARView *)viewAR WithViewRadar:(ARView *)viewRadar {
	ARObjectViewTriple *triple = [self getTripleOfObject:object];
	
	// the object is already known, so just replace the view ...
	if (triple != nil) {
		[triple.viewAR removeFromSuperview];
		triple.viewAR = viewAR;
		[triple.viewRadar removeFromSuperview];
		triple.viewRadar = viewRadar;
	}
	else {
		triple = [[ARObjectViewTriple alloc] initWithObject:object ViewAR:viewAR ViewRadar:viewRadar];
		
		// update for current heading and location (to be sure)
		[object updateWithNewHeading:currentHeading];
		if ([object isKindOfClass:[ARGeoLocation class]]) {
			[(ARGeoLocation*) object updateWithNewLocation:currentLocation];
		}
		
		[objectsAndViews addObject:triple];
		[triple release];
	}
	
	[activeControllerView replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}

- (void) addObjects:(NSMutableArray *)objects WithViewsAR:(NSMutableArray *)viewsAR WithViewsRadar:(NSMutableArray *)viewsRadar {
	if (!([objects count] == [viewsAR count] && [objects count] == [viewsRadar count])) {
		// TODO some type of error handling
		return;
	}
	
	for (int i = 0; i < [objects count]; ++i) {
		ARObject *object = [objects objectAtIndex:i];
		ARView *viewAR = [viewsAR objectAtIndex:i];
		ARView *viewRadar = [viewsRadar objectAtIndex:i];
		
		ARObjectViewTriple *triple = [self getTripleOfObject:object];
		
		// the object is already known, so just replace the view ...
		if (triple != nil) {
			[triple.viewAR removeFromSuperview];
			triple.viewAR = viewAR;
			[triple.viewRadar removeFromSuperview];
			triple.viewRadar = viewRadar;
		}
		else {
			triple = [[ARObjectViewTriple alloc] initWithObject:object ViewAR:viewAR ViewRadar:viewRadar];
			
			// update for current heading and location (to be sure)
			[object updateWithNewHeading:currentHeading];
			if ([object isKindOfClass:[ARGeoLocation class]]) {
				[(ARGeoLocation*) object updateWithNewLocation:currentLocation];
			}
			
			[objectsAndViews addObject:triple];
			[triple release];
		}
	}
	
	[activeControllerView replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}

- (void) removeObject:(ARObject *)object {
	ARObjectViewTriple *triple = [self getTripleOfObject:object];
	if (triple == nil) { // object not found
		return;
	}
	
	[triple.viewAR removeFromSuperview];
	[triple.viewRadar removeFromSuperview];
	
	[objectsAndViews removeObject:triple];
	
	[activeControllerView replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}

- (void) removeAllObjects {
	for (ARObjectViewTriple *triple in objectsAndViews) {
		[triple.viewAR removeFromSuperview];
		[triple.viewRadar removeFromSuperview];
	}
	[objectsAndViews removeAllObjects];
	
	[activeControllerView replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}

- (BOOL) knowsARObject:(ARObject *)object {
	for (ARObjectViewTriple *triple in objectsAndViews) {
		ARObject *o = triple.object;
		
		if ([o isEqual:object]) {
			return YES;
		}
	}
	
	return NO;
}

- (ARObjectViewTriple*) getTripleOfObject:(ARObject *)object {
	for (ARObjectViewTriple *triple in objectsAndViews) {
		ARObject *o = triple.object;
		
		if ([o isEqual:object]) {
			return triple;
		}
	}
	
	return nil;
}

#pragma mark Process incoming notifications

- (void) processHeadingUpdate:(NSNotification *)notification {
	// extract heading information from notification
	CLHeading *heading = [[notification userInfo] valueForKey:@"heading"];
	currentHeading = heading.trueHeading;
	
	controllerViewAR.currentHeading = currentHeading;
	controllerViewRadar.currentHeading = currentHeading;
	
	for (ARObjectViewTriple *pair in objectsAndViews) {
		[pair.object updateWithNewHeading:currentHeading];
		
		// updates the object
		if (pair.object.delegate != nil) {
			[pair.object.delegate update];
		}
		
		// updates the corresponding view with the new information from the object
		if (pair.viewAR.delegate != nil) {
			[pair.viewAR.delegate updateWithInfosFromObject:pair.object];
		}
		
	}
	
	[activeControllerView updateDisplayWithHeading:currentHeading];
	
}

- (void) processLocationUpdate:(NSNotification *)notification {
	// extract location from notification
	double latitude = [[[notification userInfo] valueForKey:@"latitude"] doubleValue];
	double longitude = [[[notification userInfo] valueForKey:@"longitude"] doubleValue];
	CLLocation *loc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
	
	for (ARObjectViewTriple *pair in objectsAndViews) {
		
		// just update location for ARGeoLocation objects ...
		if ([pair.object isKindOfClass:[ARGeoLocation class]]) {
			ARGeoLocation *geoloc = (ARGeoLocation*) pair.object;
			[geoloc updateWithNewLocation:loc];
			
			// update the object
			if (geoloc.delegate != nil) {
				[geoloc.delegate update];
			}
			
			// update the corresponding view with the new information from the object
			if (pair.viewAR.delegate != nil) {
				[pair.viewAR.delegate updateWithInfosFromObject:geoloc];
			}
		}
	}
	
	[loc release];
	[activeControllerView replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}

#pragma mark Other

- (void) redraw {
	[activeControllerView redraw];
}

- (void) activateRadarView:(BOOL)shouldActivate {	
	isRadarActive = shouldActivate;
	if (isRadarActive) {
		[UIView beginAnimations:@"SwitchToRadarMode" context:controllerViewAR];
		[UIView setAnimationDuration:0.5];
		[controllerViewRadar setNeedsLayout];
		[self bringSubviewToFront:controllerViewRadar];
		controllerViewRadar.hidden = NO;
		controllerViewRadar.alpha = 1.0;
		controllerViewAR.alpha = 0.0;
		controllerViewAR.hidden = YES;
		[UIView commitAnimations];
		activeControllerView = controllerViewRadar;
	} else {
		[UIView beginAnimations:@"SwitchTo360Mode" context:controllerViewRadar];
		[UIView setAnimationDuration:0.5];
		[self bringSubviewToFront:controllerViewAR];
		controllerViewAR.hidden = NO;
		controllerViewAR.alpha = 1.0;
		controllerViewRadar.alpha = 0.0;
		controllerViewRadar.hidden = YES;
		[UIView commitAnimations];
		activeControllerView = controllerViewAR;
	}
	
	[activeControllerView replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}


@end
