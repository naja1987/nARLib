//
//  ARController.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARObject.h"
#import "ARView.h"
#import "ARAugmentedRealityViewController.h"
#import "ARRadarViewController.h"

@interface ARController : UIViewController {
	
	NSMutableArray						*objectsAndViews;
	double								currentHeading;
	
	ARAugmentedRealityViewController	*arViewController;
	ARRadarViewController				*radarViewController;
	id<ARViewControllerDelegate>		activeViewController;
	
	BOOL								isRadarActive;
}

@property (nonatomic, readonly) NSMutableArray *objectsAndViews;

- (void) addObject:(ARObject*) object WithViewAR:(ARView*) viewAR WithViewRadar:(ARView*) viewRadar;
- (void) removeObject:(ARObject*) object;
- (void) removeAllObjects;

- (void) activateRadarView:(BOOL) shouldActivate;

- (void) processLocationUpdate:(NSNotification*) notification;
- (void) processHeadingUpdate:(NSNotification*) notification;


@end
