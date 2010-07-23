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
		
		[object updateWithNewHeading:currentHeading];
		if ([object isKindOfClass:[ARGeoLocation class]]) {
			[(ARGeoLocation*) object updateWithNewLocation:currentLocation];
		}
		
		[objectsAndViews addObject:triple];
		[triple release];
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
