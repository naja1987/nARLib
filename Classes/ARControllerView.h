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

@property (nonatomic, readonly) NSMutableArray *objectsAndViews;

- (void) addObject:(ARObject*) object WithViewAR:(ARView*) viewAR WithViewRadar:(ARView*) viewRadar;
- (void) removeObject:(ARObject*) object;
- (void) removeAllObjects;
- (void) redraw;

- (void) activateRadarView:(BOOL) shouldActivate;

- (void) processLocationUpdate:(NSNotification*) notification;
- (void) processHeadingUpdate:(NSNotification*) notification;


@end
