    //
//  ARRadarViewController.m
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARRadarViewController.h"
#import "ARView.h"
#import "Utils.h"
#import "ARGeoLocation.h"
#import "ARObjectViewTriple.h"

@interface ARRadarViewController (Private)

- (CGPoint) calculatePositionOfARObjectViewTriple:(ARObjectViewTriple*) triple;
- (void) moveAndTransformARViewOfTriple:(ARObjectViewTriple*) triple;

@end


@implementation ARRadarViewController

@synthesize currentHeading;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	arTriples = [[NSMutableArray alloc] init];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
	for (ARObjectViewTriple *triple in arTriples) {
		[triple.viewRadar removeFromSuperview];
	}
	
	[arTriples removeAllObjects];
	[arTriples release];
	
    [super dealloc];
}

#pragma mark Delegate Implementation

- (void) updateDisplayWithHeading:(double) heading {
	@synchronized(self) {
		currentHeading = heading;
		for (ARObjectViewTriple *triple in arTriples) {
			[self moveAndTransformARViewOfTriple:triple];
		}
	}
}

- (void) replaceViewsWithViewsFromObjectViewTriple:(NSMutableArray*) triples {
	@synchronized(self) {
		for (ARObjectViewTriple *triple in arTriples) {
			[triple.viewRadar removeFromSuperview];
		}
		[arTriples removeAllObjects];
		
		for (ARObjectViewTriple *triple in triples) {
			
			CGPoint p = [self calculatePositionOfARObjectViewTriple:triple];
			triple.viewRadar.layer.position = p;
			
			[arTriples addObject:triple];
			[self.view addSubview:triple.viewRadar];
			
			[self moveAndTransformARViewOfTriple:triple];
		}
	}
}

- (void) moveAndTransformARViewOfTriple:(ARObjectViewTriple *)triple {
	CGPoint p = CGPointMake(-1, -1);
	
	CGFloat centerX = kScreenHeight / 2; // 160
	CGFloat centerY = kScreenWidth / 2; // 240
	CGPoint centerPosition = CGPointMake(centerX, centerY);
	
	CGFloat vectorLength = [triple.viewRadar distanceBetweenPosition1:triple.viewRadar.layer.position Position2:centerPosition];
	
	// mark white when in view in the 360° view
	if (fabsf(triple.object.absoluteAngle - currentHeading) < 25) {
		triple.viewRadar.backgroundLayer.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.65].CGColor;
	}
	else {
		if (triple.viewRadar.defaultBackgroundColor != nil) {
			triple.viewRadar.backgroundLayer.backgroundColor = triple.viewRadar.defaultBackgroundColor.CGColor;
		}
		else {
			triple.viewRadar.backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
		}
	}
	
	// calculate x and y position
	CGFloat posX = 0;
	CGFloat posY = 0;
	CGFloat angle = DegreesToRadians(fmodf(triple.object.absoluteAngle - currentHeading + 360.0, 360.0));
	double cos_ = cos(angle);
	double sin_ = sin(angle);
	
	// interchange sin and cos because on the x-axis are 0°. then, the angle counts clockwise
	posX = centerX + sin_ * vectorLength;
	posY = centerY - cos_ * vectorLength;
	
	p.x = posX;
	p.y = posY;
	
	// calculate last spotView with intersection
	ARObjectViewTriple *lastTripleWithIntersection = nil;
	CGFloat distance = -1;
	
	CGPoint origin = p;
	origin.x -= triple.viewRadar.frame.size.width / 2;
	origin.y -= triple.viewRadar.frame.size.height / 2;
	
	for (ARObjectViewTriple *t in arTriples) {
		if (t == triple) {
			// every spot after this in spotViews wasn't moved yet, so we can't test for intersection
			break;
		}
		
		if ([triple.viewRadar wouldIntersectWithARView:t.viewRadar atPosition:origin]) {
			CGFloat dist = [t.viewRadar distanceBetweenPosition1:t.viewRadar.layer.position Position2:centerPosition];
			//	NSLog(@"Intersection between %@ und %@ (dist: %f, pos: (%f, %f)", spotView, sv, dist, p.x, p.y);
			if (dist > distance) {
				distance = dist;
				lastTripleWithIntersection = t;
			}
		}
	}
	
	// if there is a intersection, then move the spot in it's heading direction until there is no intersection
	if (lastTripleWithIntersection != nil) {
		
		CGFloat offsetX = 0;
		CGFloat offsetY = 0;
		CGFloat width = triple.viewRadar.frame.size.width;
		CGFloat height = triple.viewRadar.frame.size.height;
		
		int i = 2;
		
		while ([triple.viewRadar wouldIntersectWithARView:lastTripleWithIntersection.viewRadar atPosition:CGPointMake(posX + offsetX - width /2, posY - offsetY - height / 2)]) {
			offsetX = sin_ * i;
			offsetY = cos_ * i;
			i += 1;
		}
		
		p.x = posX + offsetX;
		p.y = posY - offsetY; 
		
	}
	
	triple.viewRadar.layer.position = p;
	
	[UIView beginAnimations:@"RadarViewMove" context:NULL];
	[UIView setAnimationDuration:0.25];
	
	if (p.x < triple.viewRadar.frame.size.width / 2 || p.x > 480 - triple.viewRadar.frame.size.width / 2) {
		triple.viewRadar.alpha = 0.0;
	}
	else if (p.y < triple.viewRadar.frame.size.height / 2 || p.y > 320 - triple.viewRadar.frame.size.height / 2) {
		triple.viewRadar.alpha = 0.0;
	}
	// hide spots when outside the current range
	else if ([triple.object isKindOfClass:[ARGeoLocation class]] && ((ARGeoLocation*) triple.object).distanceFromCurrentLocation > [ARGeoLocation maxDistance]) {
		triple.viewRadar.alpha = 0.0;
	}
	else {
		triple.viewRadar.alpha = 1.0;
	}
	
	[UIView commitAnimations];
}

- (CGPoint) calculatePositionOfARObjectViewTriple:(ARObjectViewTriple*) triple {
	CGFloat centerX = kScreenHeight / 2; // 160
	CGFloat centerY = kScreenWidth / 2; // 240
	
	CGFloat vectorLength;
	// move to corresponding distance on the radar when it's a geolocation
	if ([triple.object isKindOfClass:[ARGeoLocation class]]) {
		vectorLength = ((ARGeoLocation*) triple.object).distanceFromCurrentLocation / [ARGeoLocation maxDistance] * centerY;
	}
	else {
		vectorLength = centerY / 3;
	}
	
	// calculate x and y position
	CGFloat posX = 0;
	CGFloat posY = 0;
	CGFloat angle = DegreesToRadians(fmodf(triple.object.absoluteAngle - currentHeading + 360.0, 360.0));
	double cos_ = cos(angle);
	double sin_ = sin(angle);
	
	// interchange sin and cos because on the x-axis are 0°. then, the angle counte clockwise
	posX = centerX + sin_ * vectorLength;
	posY = centerY - cos_ * vectorLength;
	
	return CGPointMake(posX, posY);
	
}


@end
