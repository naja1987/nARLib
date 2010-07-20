    //
//  ARAugmentedRealityViewController.m
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARAugmentedRealityViewController.h"
#import "ARView.h"
#import "ARObjectViewTriple.h"
#import "ARGeoLocation.h"

#define kAR3DPerspectiveZDistance -500

@interface ARAugmentedRealityViewController (Private) 

- (void) moveAndTransformARViewOfTriple:(ARObjectViewTriple*) triple;
- (CGPoint) calculatePositionOfARObjectViewTriple:(ARObjectViewTriple*) triple;
- (void) unoverlapViews;

@end


@implementation ARAugmentedRealityViewController

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
	
	CATransform3D sublayerTransform = CATransform3DIdentity;
	sublayerTransform.m34 = 1.0 / -kAR3DPerspectiveZDistance; // do 3d perspective magic
	
	transformerView = [[UIView alloc] initWithFrame:self.view.bounds];
	transformerView.opaque = NO;
	transformerView.backgroundColor = [UIColor clearColor];
	transformerView.layer.sublayerTransform = sublayerTransform;
	[self.view addSubview:transformerView];
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
	for (ARView *view in arTriples) {
		[view removeFromSuperview];
	}
	[arTriples removeAllObjects];
	[transformerView removeFromSuperview];
	[transformerView release];
	
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
		// remove old stuff
		for (ARObjectViewTriple *triple in arTriples) {
			[triple.viewAR removeFromSuperview]; 
		}
		[arTriples removeAllObjects];
		
		
		for (ARObjectViewTriple *triple in triples) {
			CGPoint p = [self calculatePositionOfARObjectViewTriple:triple];			
			triple.viewAR.layer.position = p;
			[arTriples addObject:triple];
			[transformerView addSubview:triple.viewAR];
			
			[self moveAndTransformARViewOfTriple:triple];
		}
		[self unoverlapViews];
	}
}

- (void) unoverlapViews {
	@synchronized(self) {
		//        output = new RectangleSet
		//        while input.length > 0 do
		//          nextRect = input.pop()
		//          intersected = output.findIntersected(nextRect)
		//          if intersected then
		//            output.remove(intersected)
		//            input.push(nextRect.merge(intersected))
		//          else
		//            output.insert(nextRect)
		//        done
		
		NSMutableArray *unoverlaped = [[NSMutableArray alloc] init];
		NSMutableArray *overlaped = [[NSMutableArray alloc] init];
		for(ARObjectViewTriple *triple in arTriples) {
			[overlaped addObject:triple];
		}
		
		while([overlaped count] > 0) {
			ARObjectViewTriple *triple = [overlaped objectAtIndex:0];
			[overlaped removeObjectAtIndex:0];
			
			BOOL isIntersection = NO;
			ARObjectViewTriple *tripleIntersected = nil;
			for(ARObjectViewTriple *t in unoverlaped) {
				if([triple.viewAR intersectsWithARView:t.viewAR]) {
					isIntersection = YES;
					tripleIntersected = t;
					break;
				}
			}
			
			if(isIntersection) {
				[unoverlaped removeObject:tripleIntersected];
				
				// different behaviour between ARGeoLocation's and normal ARObjects ...
				if ([triple.object isKindOfClass:[ARGeoLocation class]] && [tripleIntersected isKindOfClass:[ARGeoLocation class]]) {
					
					ARGeoLocation *geolocTriple = (ARGeoLocation*) triple.object;
					ARGeoLocation *geolocTripleIntersected = (ARGeoLocation*) tripleIntersected.object;
					
					if (geolocTriple.distanceFromCurrentLocation < geolocTripleIntersected.distanceFromCurrentLocation) {
						// move tripleIntersected up
						CGPoint p = tripleIntersected.viewAR.layer.position;
						p.y = triple.viewAR.layer.position.y - triple.viewAR.layer.frame.size.height - 2;
						tripleIntersected.viewAR.layer.position = p;
					}
					else {
						// move triple up
						CGPoint p = triple.viewAR.layer.position;
						p.y = tripleIntersected.viewAR.layer.position.y - tripleIntersected.viewAR.layer.frame.size.height - 2;
						triple.viewAR.layer.position = p;
					}

					
				}
				// the geolocations have less priority ...
				else if ([triple.object isKindOfClass:[ARGeoLocation class]] && ![tripleIntersected isKindOfClass:[ARGeoLocation class]]) {
					// move triple up
					CGPoint p = triple.viewAR.layer.position;
					p.y = tripleIntersected.viewAR.layer.position.y - tripleIntersected.viewAR.layer.frame.size.height - 2;
					triple.viewAR.layer.position = p;
				}
				else if (![triple.object isKindOfClass:[ARGeoLocation class]] && [tripleIntersected isKindOfClass:[ARGeoLocation class]]) {
					// move tripleIntersected up
					CGPoint p = tripleIntersected.viewAR.layer.position;
					p.y = triple.viewAR.layer.position.y - triple.viewAR.layer.frame.size.height - 2;
					tripleIntersected.viewAR.layer.position = p;
				}
				else {
					// move tripleIntersected up
					CGPoint p = tripleIntersected.viewAR.layer.position;
					p.y = triple.viewAR.layer.position.y - triple.viewAR.layer.frame.size.height - 2;
					tripleIntersected.viewAR.layer.position = p;
				}

				[overlaped addObject:triple];
				[overlaped addObject:tripleIntersected];
			}
			else {
				[unoverlaped addObject:triple];
			}
		}
		[overlaped release];
		
		[unoverlaped removeAllObjects];
		[unoverlaped release];
	}
	
}

- (CGPoint) calculatePositionOfARObjectViewTriple:(ARObjectViewTriple*) triple {
	CGPoint p = CGPointMake(-1, -1);
	CGFloat circle = 360.0;
	CGFloat caa = kCameraApartueAngle;
	p.x = kScreenHeight - (fmodf(currentHeading - triple.object.absoluteAngle + caa / 2, circle) * kScreenHeight / caa);
	
	CGFloat usableScreenHeight = kScreenWidth - triple.viewAR.frame.size.height;
	
	// if it's a geo-location position view corresponding to the distance to the location
	if ([triple.object isKindOfClass:[ARGeoLocation class]]) {
		p.y =  usableScreenHeight - ((ARGeoLocation *) triple.object).distanceFromCurrentLocation / [ARGeoLocation maxDistance] * usableScreenHeight + triple.viewAR.frame.size.height / 2;
	}
	// otherwise place object in the middle ...
	else {
		p.y = usableScreenHeight - usableScreenHeight / 2 + triple.viewAR.frame.size.height / 2;
	}
	
	return p;
}

- (void) moveAndTransformARViewOfTriple:(ARObjectViewTriple *)triple {
	// calculate new position (just in x direction)
	CGFloat oldY = triple.viewAR.layer.position.y;
	CGPoint p = [self calculatePositionOfARObjectViewTriple:triple];
	p.y = oldY;
	
	CGFloat circle = 360.0;
	CGFloat caa = kCameraApartueAngle;
	CGFloat mod = fmodf(currentHeading - triple.object.absoluteAngle + caa / 2, circle);
	
	CGFloat angle = caa / 2 - fmodf(mod, caa);
	
	triple.viewAR.layer.position = p;
	
	[UIView beginAnimations:@"ARViewMove" context:NULL];
	[UIView setAnimationDuration:0.25];
	if (p.x < 0 || p.x > kScreenHeight) {
		triple.viewAR.alpha = 0.0;
	}
	else if (p.y < triple.viewAR.frame.size.height / 2 || p.y > kScreenWidth - triple.viewAR.frame.size.height / 2 ) {
		triple.viewAR.alpha = 0.0;
	}
	else if ([triple.object isKindOfClass:[ARGeoLocation class]] && 
			 ((ARGeoLocation*) triple.object).distanceFromCurrentLocation > [ARGeoLocation maxDistance]) {
		triple.viewAR.alpha = 0.0;
	}
	else {
		triple.viewAR.layer.transform = CATransform3DMakeRotation(angle * M_PI/180, 0, 1, 0);
		triple.viewAR.alpha = 1.0;
	}
	[UIView commitAnimations];
	
	
}


@end
