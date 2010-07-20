    //
//  ARController.m
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARController.h"
#import "ARNotificationCenter.h"
#import "ARObjectViewTriple.h"
#import "ARGeoLocation.h"

@interface ARController (Private) 

- (BOOL) knowsARObject:(ARObject*) object;
- (ARObjectViewTriple*) getTripleOfObject:(ARObject*) object;

@end


@implementation ARController

@synthesize objectsAndViews;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	objectsAndViews = [[NSMutableArray alloc] init];
	
	arViewController = [[ARAugmentedRealityViewController alloc] initWithNibName:nil bundle:nil];
	radarViewController = [[ARRadarViewController alloc] initWithNibName:@"ARRadarViewController" bundle:nil];
	activeViewController = arViewController;
	isRadarActive = NO;
	
	[self.view addSubview:arViewController.view];
	
	// register for notifications
	[[ARNotificationCenter sharedNotificationCenter] addObserverForHeadingChanges:self selector:@selector(processHeadingUpdate:)];
	[[ARNotificationCenter sharedNotificationCenter] addObserverForLocationChanges:self selector:@selector(processLocationUpdate:)];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[[ARNotificationCenter sharedNotificationCenter] removeObserver:self];
	
	[objectsAndViews removeAllObjects];
	[objectsAndViews release];
	
	[arViewController release];
	[radarViewController release];
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
	
	[activeViewController replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}

- (void) removeObject:(ARObject *)object {
	ARObjectViewTriple *triple = [self getTripleOfObject:object];
	if (triple == nil) { // object not found
		return;
	}
	
	[triple.viewAR removeFromSuperview];
	[triple.viewRadar removeFromSuperview];
	
	[objectsAndViews removeObject:triple];
	
	[activeViewController replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}

- (void) removeAllObjects {
	for (ARObjectViewTriple *triple in objectsAndViews) {
		[triple.viewAR removeFromSuperview];
		[triple.viewRadar removeFromSuperview];
	}
	[objectsAndViews removeAllObjects];
	
	[activeViewController replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
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
	
	arViewController.currentHeading = currentHeading;
	radarViewController.currentHeading = currentHeading;
	
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
	
	[activeViewController updateDisplayWithHeading:currentHeading];
	
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
	[activeViewController replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}

#pragma mark Other

- (void) activateRadarView:(BOOL)shouldActivate {
	isRadarActive = shouldActivate;
	if (isRadarActive) {
		[UIView beginAnimations:@"SwitchToRadarMode" context:arViewController.view];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(removeViewAfterAnimation)];
		[self.view insertSubview:radarViewController.view atIndex:0];
		[arViewController viewWillDisappear:YES];
		[radarViewController viewWillAppear:YES];
		radarViewController.view.alpha = 1.0;
		arViewController.view.alpha = 0.0;
		[UIView commitAnimations];
		activeViewController = radarViewController;
	} else {
		[UIView beginAnimations:@"SwitchTo360Mode" context:radarViewController.view];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(removeViewAfterAnimation)];
		[self.view insertSubview:arViewController.view atIndex:0];
		[radarViewController viewWillDisappear:YES];
		[arViewController viewWillAppear:YES];
		arViewController.view.alpha = 1.0;
		radarViewController.view.alpha = 0.0;
		[UIView commitAnimations];
		activeViewController = arViewController;
	}
	
	[activeViewController replaceViewsWithViewsFromObjectViewTriple:objectsAndViews];
}

- (void)removeViewAfterAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[(UIView *) context removeFromSuperview];
}


@end
